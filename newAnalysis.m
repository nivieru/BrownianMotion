function [ff,analysisDir] = newAnalysis(videoFilename, timestampFlag)
if exist('timestampFlag', 'var') && timestampFlag == true
    d = datetime;
    d.Format = 'dd-MM-yy HH_mm_ss';
    outputDirname = ['out_',char(d)]; % add date and time to output dir name so we don't automatically overwite.
else
    outputDirname = 'out';
end

[path,fn,ext] = fileparts(videoFilename); % get output path from filename.
if isempty(ext) %no extension - fn is actually the last part of the path.
    path = fullfile(path,fn);
end

analysisDir = fullfile(path,outputDirname);
ff = @(filename) fullfile(analysisDir, filename); % Function to add outputDir to filnames;
fprintf('Making folder: %s\n', analysisDir);
mkdir(analysisDir); % make output dir
writecell({videoFilename}, ff('videoFilename.txt')); % save video file name to text file
save(ff('videoFilename'),'videoFilename');% also save video file name to .mat file


