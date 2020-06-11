function [ff, varargout] = loadAnalysis(analysisFolder, varargin)
ff = @(filename) fullfile(analysisFolder, filename); % Function to add outputDir to filnames;
if length(varargin) == 0
    loadFiles = {'framerate', 'trackingParameters', 'tracks', 'ma', 'results', 'videoFilename'};
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
