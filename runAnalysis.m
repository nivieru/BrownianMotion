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
trackingParameters.BPlnoise = 1;
trackingParameters.BPlobject = 10;

% Parameters for pkfnd
trackingParameters.PKthreshold = 5;
trackingParameters.PKsize = 4;

% Parameters for cnt
trackingParameters.CNTinteractive = false; % Change to true to test particle detection during call to cnt; 
trackingParameters.CNTsize = 7;

% parametrs for tracking
trackingParameters.maxdisp = 5; % Might need to change
trackingParameters.mem = 2; % Might need to change
trackingParameters.dim = 2; % Two dimensions, don't change
trackingParameters.good = 5; % Might need to change
trackingParameters.quiet = 0;

save(ff('trackingParameters'),'trackingParameters'); % Save parameters.

%% Get tracks from video
[tracksForMsdanalyzer, framerate] = tracksFromMovie(videoFilename, trackingParameters); % Get tracks from video
save(ff('tracks'),'tracksForMsdanalyzer'); % Save tracks so we can reuse them without running everything again
save(ff('framerate'), 'framerate');

%% Use MSDAnalyzer object
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

%%% Sanity check - plot tracks over a max projection of movie to see if they make sense
maxProj = maxProjection(videoFilename); % caculate max projection
imageX = [1, size(maxProj,2)] * calibration; % image coordinates to match calibration
imageY = [1, size(maxProj,1)] * calibration;
maxProjFig = figure;
imshow(imadjust(maxProj, stretchlim(maxProj, 0.05)), 'XData', imageX, 'YData', imageY); % show max projection with enhanced contrast
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
ma = ma.fitMSD;
ma = ma.fitLogLogMSD;
[fo, gof] = ma.fitMeanMSD;

meanMSDFig = figure;  % Plot mean MSD and linear fit
[~, ha] = ma.plotMeanMSD;
hold on;
plot(fo);
ma.labelPlotMSD;
title('Mean MSD');
savefig(meanMSDFig,ff('meanMSDFig.fig'),'compact');
print(meanMSDFig, ff('meanMSDFig'), format);

MSDFig = figure;  % Plot mean MSD and linear fit
[~, ha] = ma.plotMSD;
hold on;
title('MSD');
savefig(meanMSDFig,ff('MSDFig.fig'),'compact');
print(meanMSDFig, ff('MSDFig'), format);

[lfo, lgof] = ma.fitLogLogMeanMSD;
loglogMeanMSDFig = figure;  % Plot mean MSD and loglog fit on a log-log scale
[h, ha] = ma.plotMeanMSD;
x = h.XData;
y = exp(log(x)*lfo.p1 + lfo.p2); % exponentiate fit back to linear scale.
hold on;
plot(x,y);
ma.labelPlotMSD;
title('Mean MSD (log scale)');
ha.XScale = 'log';
ha.YScale = 'log';
savefig(meanMSDFig,ff('loglogMeanMSDFig.fig'),'compact');
print(meanMSDFig, ff('loglogMeanMSDFig'), format);

save(ff('msdAnalyzerObj'),'ma'); % Save MSDanalyzer object so we can return to it later without running everything again.

