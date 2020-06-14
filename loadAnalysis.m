function [ff, varargout] = loadAnalysis(analysisFolder, varargin)
% LOADANALYSIS loads selected .mat files saved to the analysis folder
% INPUTS:
% analysisFolder - The analysis folder.
% varargin - a comma seperated list of filenames (without the .mat suffix)
%   to load.
% OUTPUTS:
% ff - a handle to a function that adds the analysisFolder path to a
%   filename. To be used to save or load from the analysis folder.
%   varargout - variable to hold the loaded data. One for each of varargin.
%
% Example usages:
% [ff, ma, framerate] = loadAnalysis(analysisFolder, 'ma', 'framerate');
% ff = loadAnalysis(analysisFolder, []); % Don't load anything, just get
%   the ff function to use for loading or saving.


ff = @(filename) fullfile(analysisFolder, filename); % Function to add analysisFolder to filnames;
if isempty(varargin) % Default to load everything
    loadFiles = {'framerate', 'trackingParameters', 'tracksForMsdanalyzer', 'ma', 'results', 'videoFilename'};
else
    loadFiles = varargin;
end
varargout = cell(size(loadFiles));
for i=1:length(loadFiles)
    if isfile(ff([loadFiles{i},'.mat']))
        S = load(ff(loadFiles{i}));
        fn = fieldnames(S);
        varargout{i}=S.(fn{1});
    end
end
