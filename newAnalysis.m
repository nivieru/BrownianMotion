function [ff,analysisDir] = newAnalysis(videoDirOrFilename, timestampFlag)
% NEWANALYSIS creates an analysis folder in the video containing folder.
% INPUTS:
% videoDirOrFilename - Path to the video file or its contating folder. 
% timestampFlag - If true, time-stamp the anlysis folder, to avoid
%   overwriting previous results.
% OUTPUTS:
% ff - handle to a function that adds the analysisFolder path to a
%   filename. To be used to save or load from the analysis folder.
% analysisDir - path to analysis folder.

if exist('timestampFlag', 'var') && timestampFlag == true
    d = datetime;
    d.Format = 'dd-MM-yy HH_mm_ss';
    outputDirname = ['out_',char(d)]; % add date and time to output dir name so we don't automatically overwite.
else
    outputDirname = 'out';
end

[path,fn,ext] = fileparts(videoDirOrFilename); % get output path from filename.
if isempty(ext) % no extension - fn is actually the last part of the path.
    path = fullfile(path,fn);
end

analysisDir = fullfile(path,outputDirname);
% ff = @(filename) fullfile(analysisDir, filename); % Function to add analysisDir to filnames;
ff = loadAnalysis(analysisDir, []); % get ff function that adds analysisDir to filnames;
fprintf('Making folder: %s\n', analysisDir);
mkdir(analysisDir); % make output dir
writecell({videoDirOrFilename}, ff('videoFilename.txt')); % save video file name to text file
save(ff('videoFilename'),'videoDirOrFilename');% also save video file name to .mat file


