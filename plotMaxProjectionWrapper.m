function maxProjFig = plotMaxProjectionWrapper(ma, videoFilename, calibration)
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
