%% Global parameters and initializations
trackingDir = 'tracking'; % path of tracking code
msdDir = 'msdanalyzer'; % path of msdanalyser code
addpath(genpath(trackingDir)); % Add code to path
addpath(genpath(msdDir));

set(0, 'DefaultFigureRenderer', 'painters');
format = '-dpdf'; % Save plots with this format. '-dpdf' and '-depsc' are vector formats, good for making figures in adobe illustrator or the free alternative inkscape. '-dpng' will save a bitmap image
calibration = 0.5; % Video calibration in microns per pixel, change as needed

videoFilename = 'C:\Users\Nivieru\Nextcloud\Documents\lab5-6\dima and eliya\Mix810xfluoor_April_15_2019_16-36-54'; % Enter video filename or directory here.

d = datetime;
d.Format = 'dd-MM-yy HH_mm_ss';
outputDirname = ['out_',char(d)]; % add date and time to output dir name so we don't automatically overwite.

[path,fn,ext] = fileparts(videoFilename); % get output path from filename.
if isempty(ext) %no extension - fn is actually the last part of the path.
    path = fullfile(path,fn);
end
outputDir = fullfile(path,outputDirname);

fprintf('writing to folder: %s\n', outputDir);
ff = @(filename) fullfile(outputDir, filename); % Function to add outputDir to filnames;
mkdir(outputDir); % make output dir
writecell({videoFilename}, ff('videoFilename.txt')); % save video file name

%% Parameters for video proccesing and particle traking.
%%% Test and change accordingly. Different exposures, obectives and imaging
%%% parameters ay require different parameters here.

trackingParameters.calibration = calibration;
% Parameters for bandpass
trackingParameters.BPlnoise = 0.5;
trackingParameters.BPlobject = 15;
trackingParameters.BPthreshold = 0;

% Parameters for pkfnd
trackingParameters.PKthreshold = 5;
trackingParameters.PKsize = 15;

% Parameters for cnt
trackingParameters.CNTinteractive = false; % Change to true to test particle detection during call to cnt; 
trackingParameters.CNTsize = 15; % Must be odd number

% parametrs for tracking
trackingParameters.maxdisp = 5; % Might need to change
trackingParameters.mem = 2; % Might need to change
trackingParameters.dim = 2; % Two dimensions, don't change
trackingParameters.good = 5; % Might need to change
trackingParameters.quiet = 0;

% parameters for particle filtering, probably not needed so left empty.
trackingParameters.FLradius = [];
trackingParameters.FLbrightness = [];

save(ff('trackingParameters'),'trackingParameters'); % Save parameters.

%% Get tracks from video
[tracksForMsdanalyzer, framerate] = tracksFromMovie(videoFilename, trackingParameters); % Get tracks from video
save(ff('tracks'),'tracksForMsdanalyzer'); % Save tracks so we can reuse them without running everything again
save(ff('framerate'), 'framerate');

%% Use MSDAnalyzer object
clip_factor = [0,0.25]; % What region of the data to use for the fits

ma = msdanalyzer(2,'um','sec', 1/framerate);% Initialize MSDAnalyzer object
ma = ma.addAll(tracksForMsdanalyzer); % Add tracks to msd object

%%% Plot tracks
tracksFig = figure; % Plot tracks
hold on;
ma.plotTracks;
ma.labelPlotTracks;
title('tracks before drift correction');
savefig(tracksFig,ff('tracksFig.fig'),'compact');
print(tracksFig, ff('tracksFig'), format); % Save plot

%%% Sanity check - plot tracks over a max projection of the movie to see if they make sense
maxProj = maxProjection(videoFilename); % Calculate max projection
imageX = [1, size(maxProj,2)] * calibration; % Image coordinates to match calibration
imageY = [1, size(maxProj,1)] * calibration;
maxProjFig = figure;
imshow(imadjust(maxProj, stretchlim(maxProj, 0.05)), 'XData', imageX, 'YData', imageY); % Show max projection with enhanced contrast
ax = gca;
ax.YDir = 'Normal';
axis on;
hps = ma.plotTracks;
for i=1:numel(hps) % Make tracks semi-transparent
    hps(i).Color(4) = 0.5;
end
ma.labelPlotTracks;
title('tracks over max projection');
savefig(maxProjFig,ff('maxProjFig.fig'),'compact');
print(maxProjFig, ff('maxProjFig'), format);

%%% Drift correction
ma = ma.computeDrift('angvelocity'); % Linear and rotational drift correction. Or try 'velocity' for only linear drift correction.
correctedTracksFig = figure;  % Plot tracks after linear and rotational drift correction.
ma.plotTracks(gca, [], true);
ma.labelPlotTracks;
title('tracks after drift correction');
savefig(correctedTracksFig,ff('correctedTracksFig.fig'),'compact');
print(correctedTracksFig, ff('correctedTracksFig'), format);

%%% Mean Squared Displacement calculation
ma = ma.computeMSD;

ma = ma.fitMSD(clip_factor);
ma = ma.fitLogLogMSD(clip_factor);

% fit mean MSD, and extract results from fit:
[fo, gof] = ma.fitMeanMSD([],clip_factor);
D.val = fo.p1/4; % diffusion coefficient [um^/s]
ci = confint(fo);
D.err = diff(ci(:,1)/8); % 95% error bounds on D
fprintf('D = %.3f +- %.2f um^2/s\n', D.val, D.err);

% fit log-log of mean MSD, and extract results from fit:
[lfo, lgof] = ma.fitLogLogMeanMSD([],clip_factor);
% extract results from fit:
alpha.val = lfo.p1; % alpha
lci = confint(lfo);
alpha.err = diff(lci(:,1)/2); % 95% error bounds on alpha
fprintf('alpha = %.3f +- %.3f\n', alpha.val, alpha.err);

MSDFig = figure;  % Plot all particles MSDs
[~, ~] = ma.plotMSD;
hold on;
title('MSD');
savefig(meanMSDFig,ff('MSDFig.fig'),'compact');
print(meanMSDFig, ff('MSDFig'), format);

meanMSDFig = figure;  % Plot mean MSD and linear fit
[h, ~] = ma.plotMeanMSD(gca, false); % plotMeanMSD(gca, true) will also plot the standard deviation
if isstruct(h)
    hLine = h.mainLine;
    hPatch = h.patch;
    hPatch.DisplayName = 'Standard deviation';
else
    hLine = h;
end
hLine.DisplayName = 'Mean MSD';
hold on;
hf = plot(fo);
hf.DisplayName = 'fit';
% theoretical value:
Kb = 1.38e-23; % Kg*m^2/s^2/K^2;
eta = 0.87e-3; % Pa*s , at 26C
T = 299; % Kelvin at 26C
R = 1e-6; % m
DH2O_theory = Kb*T/(6*pi*eta*R) *1e12; %um^2/s
x = hLine.XData; % use t-data from figure to plot fit
y = 4*DH2O_theory*x;
ht = plot(x,y);
ht.DisplayName = 'theoretical value';
ma.labelPlotMSD;
title('Mean MSD');
if isstruct(h)
    legend([hLine,hPatch,hf,ht]);
else
    legend([hLine,hf,ht]);
end
savefig(meanMSDFig,ff('meanMSDFig.fig'),'compact');
print(meanMSDFig, ff('meanMSDFig'), format);


loglogMeanMSDFig = figure;  % Plot mean MSD and loglog fit on a log-log scale
[h, ha] = ma.plotMeanMSD();
if isstruct(h)
    hLine = h.mainLine;
else
    hLine = h;
end
hLine.DisplayName = 'Mean MSD';
x = hLine.XData; % use t-data from figure to plot fit
y = exp(log(x)*lfo.p1 + lfo.p2); % Exponentiate fit back to linear scale.
hold on;
fh = plot(x,y);
fh.DisplayName = 'fit';
ma.labelPlotMSD;
title('Mean MSD (log scale)');
ha.XScale = 'log';
ha.YScale = 'log';

%plot visual aids of slope 1 and 2
tVA = linspace(0.3,2,5);
DVA1 = D/2;
yVA1 = DVA1*4*tVA;
VA1h = plot(tVA,yVA1);
VA1h.DisplayName = 'slope=1 (visual aid)';
DVA2 = D*4;
yVA2 = DVA2*4*tVA.^2;
VA2h = plot(tVA,yVA2);
VA2h.DisplayName = 'slope=2 (visual aid)';

legend([hLine,fh,VA1h,VA2h])
savefig(loglogMeanMSDFig,ff('loglogMeanMSDFig.fig'),'compact');
print(loglogMeanMSDFig, ff('loglogMeanMSDFig'), format);

save(ff('msdAnalyzerObj'),'ma'); % Save MSDanalyzer object so we can return to it later without running everything again.
save(ff('clip_factor'),'clip_factor'); % Save clip_facor.
save(ff('D'),'D'); % Save results.
save(ff('alpha'),'alpha'); % Save results.

