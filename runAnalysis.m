%%% runAnalysis
%%% This script is used to run the entire brownian motion analysis,
%%% starting with extraction of the tracks from te movie, loading the
%%% tracks into an MSDAnalyzer object, plotting the tracks, analyzing the
%%% Mean Squared Displacement, plotting and extracting results - diffusion
%%% coefficient D and time exponent alpha.
%%% The tracks, parameters, MSDAnalyzer object, and results are saved in a
%%% timestamped analysis folder inside the movie folder.
%%%
%%% Note that on every run the scpript will generate a new analysis folder
%%% after completing the tracking phase. Set timestampFlag to false to
%%% avoid timestamping the analysis folder, thus overwriting the old
%%% analysis if run on the same movie.
%%%
%%% The first part of the script does path and graphics initializations,
%%% make sure trackingDir and msdDir point to the correct folders.
%%% The second part contains parameters for the video analysis and particle
%%% tracking, these probably needs to be changed. run the first time with
%%% interactive=true to check bandpass result and particle detection and
%%% optimizing parameters before continuing. When ready, change interactive
%%% to false.
%%% The third part runs the tracking code and saves the tracks and
%%% parameters into the analysis folder.
%%% The last part runs the MSD analysis code.
%%% After saving the tracks to the analysis folder, you can re-run only the
%%% last part of the script (or copy it to a seperate script) to repeat the
%%% MSD analysis.

%% Global parameters and initializations
trackingDir = 'tracking'; % path of tracking code
msdDir = 'msdanalyzer'; % path of msdanalyser code
addpath(genpath(trackingDir)); % Add code to path
addpath(genpath(msdDir));
set(0, 'DefaultFigureRenderer', 'painters');
%% Parameters 
videoDirOrFilename = 'C:\Users\Nivieru\Nextcloud\Documents\lab5-6\dima and eliya\Mix1110xflour_April_15_2019_17-44-07'; % Enter video filename or directory here.
interactive = true; % Cahnge to false to run with no pauses 
timestampFlag = true; % Change to false to avoid timestamping 

%%% Parameters for video proccesing and particle tracking.
%%% Test and change accordingly. Different exposures, obectives and imaging
%%% parameters may require different parameters here.

trackingParameters.calibration = 0.7353; % um per pixel
% Parameters for bandpass
trackingParameters.BPlnoise = 0.5;
trackingParameters.BPlobject = 10;
trackingParameters.BPthreshold = 2;

% Parameters for pkfnd
trackingParameters.PKthreshold = 10;
trackingParameters.PKsize = 9;

% Parameters for cnt
trackingParameters.CNTsize = 9; % Must be odd number

% parametrs for tracking
trackingParameters.maxdisp = 5; % Might need to change
trackingParameters.mem = 2; % Might need to change
trackingParameters.dim = 2; % Two dimensions, don't change
trackingParameters.good = 5; % Might need to change
trackingParameters.quiet = 0;

% parameters for particle filtering, probably not needed so left empty.
trackingParameters.FLradius = [];
trackingParameters.FLbrightness = [];


%% Get tracks from video
[tracksForMsdanalyzer, framerate] = tracksFromMovie(videoDirOrFilename, trackingParameters, interactive); % Get tracks from video

[ff,analysisDir] = newAnalysis(videoDirOrFilename, timestampFlag); % Initialize a new analysis folder. This will cereate a new time-stamped folder on each run.
%ff = loadAnalysis(analysisDir) % Use this line instead of the line above to rewrite to an existing  analysis folder.

save(ff('trackingParameters'),'trackingParameters'); % Save parameters.
save(ff('framerate'), 'framerate');
save(ff('tracksForMsdanalyzer'),'tracksForMsdanalyzer'); % Save tracks so we can reuse them without running everything again

%% Analyse tracks using MSDAnalyzer
clip_factor = [0.02, 0.18]; % Region of data to fit.
forceNewAnalysis = false;
[ff, ma, results] = runMSDAnalysis(analysisDir, clip_factor, forceNewAnalysis);
