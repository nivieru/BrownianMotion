function [tracksForMsdanalyzer, framerate] = tracksFromMovie(videoFilename, trackingParameters)
    %TRACKSFROMMOVIE
    %Inputs:
    %	videoFilename - name of avi file or a directory containing avi file
    %	calibration - microns per pixel
    %Outputs:
    %   tracksForMsdanalyzer - particle tracks formatted for MSDAnalyzer
%-------------------------------------------------------------------------%
    
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
    elseif ifFile ~=2
        error('file not found');
    end
    
    v = VideoReader(videoFilename);
    framerate = v.FrameRate;
    cntAll = [];
    
    % Parameters for bandpass, or drop Bandpass if not needed
    BPlnoise = trackingParameters.BPlnoise;
    BPlobject = trackingParameters.BPlobject;
    
    % Parameters for pkfnd
    PKthreshold = trackingParameters.PKthreshold;
    PKsize = trackingParameters.PKsize;
    
    % Parameters for cnt
    CNTinteractive = trackingParameters.CNTinteractive;
    CNTsize = trackingParameters.CNTsize;
    
    frameNum = 0;
    while hasFrame(v)
        frame = readFrame(v);
        frameNum = frameNum + 1;
        if size(frame,3) > 1
            frame = squeeze(frame(:,:,1)); % The video has 3 channels but is really BW, keep only one channel.
        end
        frameBpass = bpass(frame,BPlnoise,BPlobject); % Bandpass filter. Might not be needed, or a different filte could be better.
        pk = pkfnd(frameBpass,PKthreshold,PKsize); % Peak finder.
        cnt = cntrd(double(frameBpass),pk,CNTsize, CNTinteractive); % Locate particle centers.
        cntAll = [cntAll; cnt, ones(size(cnt,1),1) * frameNum]; % Collect data from all frames, add frame number.
    end
    
    % Can now further filter particles based on cntAll(:,3) (squared radius), and cntAll(:,4) (brightness) if needed;
        
    % Parametrs for tracking
    param.mem = trackingParameters.mem;
    param.dim = trackingParameters.dim;
    param.good = trackingParameters.good;
    param.quiet = trackingParameters.quiet;
    maxdisp = trackingParameters.maxdisp;
    
    calibration = trackingParameters.calibration'
    trDiffAll = [];
    tracks = track(cntAll(:,[1,2,5]), maxdisp, param); % generate particle tracks
    for trackNum = 1:max(tracks(:,4)) % collect tracks in format suitable for msdAnalyzer
        tr = tracks(tracks(:,4) == trackNum,:);
        tracksForMsdanalyzer{trackNum} = [tr(:,3)/framerate,tr(:,1:2)*calibration];
    end
end

