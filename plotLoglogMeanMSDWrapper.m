function loglogMeanMSDFig = plotLoglogMeanMSDWrapper(ma, lfo, t_fit, x_err, D, vaFlag)
loglogMeanMSDFig = figure;  % Plot mean MSD and loglog fit on a log-log scale
[h, ha] = ma.plotMeanMSD();
if isstruct(h)
    hLine = h.mainLine;
else
    hLine = h;
end
hLine.DisplayName = 'Mean MSD';
t = hLine.XData; % use t-data from figure to plot fit
y = exp(log(t)*lfo.p1 + lfo.p2); % Exponentiate fit back to linear scale.
hold on;
fh = plot(t,y);
fh.DisplayName = 'fit';
ma.labelPlotMSD;
title('Mean MSD (log scale)');
ha.XScale = 'log';
ha.YScale = 'log';
legendItems = [hLine,fh];
if exist('vaFlag', 'var') && vaFlag==true
    %plot visual aids of slope 1 and 2
    tVA = linspace(0.3,2,5);
    DVA1 = D/2;
    yVA1 = DVA1*4*tVA;
    VA1h = plot(tVA,yVA1);
    VA1h.DisplayName = 'slope=1 (visual aid)';
    DVA2 = D*4;
    yVA2 = DVA2*4*tVA.^2;
    VA2h = plot(tVA,yVA2);
    VA2h.DisplayName = 'slope=2 (visual aid)';
    legendItems = [legendItems, VA1h,VA2h];
end
if exist('t_fit', 'var') && ~isempty(t_fit)
    htf = plot(t_fit, ones(size(t_fit))*y(2), 'LineWidth', 3, 'Color', [0,0,0,0.5]);
    htf.DisplayName = 'Fit region';
    legendItems = [legendItems, htf];
end
if exist('x_err', 'var') && ~isempty(x_err)
    hxr = plot(t, ones(size(t))*x_err, '--', 'Color', [0.3,0.3,0.3]);
    hxr.DisplayName = 'Detection resolution';
    legendItems = [legendItems, hxr];
end

legend(legendItems)
