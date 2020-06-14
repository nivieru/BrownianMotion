function maxProj = maxProjection(videoFilename)
% MAXPROJECTION create a max projection of video

    % validate if file exists
    isFile = exist(videoFilename,'file');
    if isFile == 7 % videoFilename is a directory
        DIR = videoFilename;
        fn = ls(fullfile(DIR,'*.avi'));
        if length(fn) == 0
            error('video file not found in dir');
        else
            videoFilename = fullfile(DIR,fn);
        end
    elseif isFile ~=2
        error('file not found');
    end
    
    v = VideoReader(videoFilename);
    maxProj = [];
    frameNum = 0;
    while hasFrame(v)
        frame = readFrame(v);
        frameNum = frameNum + 1;
        if size(frame,3) > 1
            frame = squeeze(frame(:,:,1)); % The video has 3 channels but is really BW, keep only one channel.
        end
        if isempty(maxProj)
            maxProj = frame;
        else
            maxProj = max(cat(3,maxProj,frame),[],3);
        end
    end
end

