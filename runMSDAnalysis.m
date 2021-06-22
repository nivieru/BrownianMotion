function [ff, ma, results] = runMSDAnalysis(analysisDir, clip_factor, loadExisting)
%% runMSDAnalysis Helper function to use MSDAnalyzer object
% This function creates or loads an existitng MSDAnalyzer object, run the
% MSD analysis. plots the tracks and MSD, and computes D and alpha.
%
% Inputs: 
% analysisDir - analysis folder. If the anlysisDir does not already contain
%   a saved MSDAnalyzer object in file ma.mat, or if forceNewAnalysis is
%   true, a new MSDAnalyzer object will be created and the MSD copmuted,
%   fitted and plotted. Otherwise this function will load the existing
%   MSDAnalyzer object and only do the fits and plots.
%
% clip_factor - region of data to use for fits - will determine the
%   computed values of D and alpha.
%
% loadExisting [default: false] - if set to true will load an existing
%   analysis instead of doing the analysis again.

%format = '-dpng';
format = '-dpdf'; % Save plots with this format. '-dpdf' and '-depsc' are vector formats, good for making figures in adobe illustrator or the free alternative inkscape. '-dpng' will save a bitmap image

results.clip_factor = clip_factor;

% Read tracks and parameters from disk:
[ff, framerate, trackingParameters, tracksForMsdanalyzer, videoFilename] = loadAnalysis(analysisDir, 'framerate', 'trackingParameters', 'tracksForMsdanalyzer', 'videoFilename');

if exist('loadExisting', 'var') && loadExisting==false
    ma = [];
else
    % try to read existing MSDAnalyzer from disk:
    [~, ma] = loadAnalysis(analysisDir,'ma'); % return empty [] if file doesn't exist
end

if isempty(ma)
    fprintf('Running new MSD analysis...');
    % Initialize new MSDAnalyzer object:
    ma = msdanalyzer(2,'um','sec', 1/framerate);
    ma = ma.addAll(tracksForMsdanalyzer); % Add tracks to msd object
    ma = ma.computeDrift('angvelocity',[200, 50]); % Linear and rotational drift correction. Or try 'velocity' for only linear drift correction.
    ma = ma.computeMSD; % Compute MSD for all tracks:
    ma = ma.fitMSD(results.clip_factor); % Fit each individual track, might be usfeul for something later
    ma = ma.fitLogLogMSD(results.clip_factor); % Fit each individual track, ight be usfeul for something later
    save(ff('ma'),'ma'); % Save MSDanalyzer object so we can return to it later without running everything again.
else
    fprintf('Existing MSD analysis loaded');
end

%%% Plot tracks
tracksFig = figure; % Plot tracks
hold on;
ma.plotTracks;
ma.labelPlotTracks;
title('tracks before drift correction');
savefig(tracksFig,ff('tracksFig.fig'),'compact');
print(tracksFig, ff('tracksFig'), format); % Save plot

%%% Sanity check - plot tracks over a max projection of the movie to see if they make sense
maxProjFig = plotMaxProjectionWrapper(ma, videoFilename, trackingParameters.calibration);
savefig(maxProjFig,ff('maxProjFig.fig'),'compact');
print(maxProjFig, ff('maxProjFig'), format);

%%% plot drift-corrected tracks
correctedTracksFig = figure;  % Plot tracks after linear and rotational drift correction.
ma.plotTracks(gca, [], true);
ma.labelPlotTracks;
title('tracks after drift correction');
savefig(correctedTracksFig,ff('correctedTracksFig.fig'),'compact');
print(correctedTracksFig, ff('correctedTracksFig'), format);

%%% Fit mean MSD, and extract results from fit
[results.fo, results.gof, t_fit] = ma.fitMeanMSD([],results.clip_factor);
results.D.val = results.fo.p1/4; % Diffusion coefficient D [um^/s]
ci = confint(results.fo);
results.D.err = diff(ci(:,1)/8); % 95% error bounds on D
fprintf('D = %.3f +- %.2f um^2/s\n', results.D.val, results.D.err);

%%% Fit log-log of mean MSD, and extract results from fit
[results.lfo, results.lgof, ~] = ma.fitLogLogMeanMSD([],results.clip_factor);
results.alpha.val = results.lfo.p1; % alpha ( <x^2> ~ t^alpha )
lci = confint(results.lfo);
results.alpha.err = diff(lci(:,1)/2); % 95% error bounds on alpha
fprintf('alpha = %.3f +- %.3f\n', results.alpha.val, results.alpha.err);

%%% Plot all particles MSDs
MSDFig = figure;
[~, ~] = ma.plotMSD;
title('MSD');
savefig(MSDFig,ff('MSDFig.fig'),'compact');
print(MSDFig, ff('MSDFig'), format);

%%% Plot mean MSD
Dtheory = []; % Put a value here to also plot a theoretical line.
meanMSDFig = plotMeanMSDWrapper(ma, results.fo, t_fit, Dtheory);
savefig(meanMSDFig,ff('meanMSDFig.fig'),'compact');
print(meanMSDFig, ff('meanMSDFig'), format);

%%% Plot mean MSD on log-log scale
vaFlag = true; % Change to false to omit visual aids;
x_err = []; % Put here expected uncertainty in x to also plot detection resolution;
loglogMeanMSDFig = plotLoglogMeanMSDWrapper(ma, results.lfo, t_fit, x_err, results.D.val, vaFlag);
savefig(loglogMeanMSDFig,ff('loglogMeanMSDFig.fig'),'compact');
print(loglogMeanMSDFig, ff('loglogMeanMSDFig'), format);

save(ff('results'),'results'); % Save results.
