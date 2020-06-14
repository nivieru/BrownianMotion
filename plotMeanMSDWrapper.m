function meanMSDFig = plotMeanMSDWrapper(ma, fo, t_fit, Dtheory)
% PLOTMEANMSDWRAPPER plot Mean MSD, fit, and theoretical line.
% INPUTS:
% ma - MSDAnalyzser object.
% fo (optional) - linear fit to mean MSD.
% t_fit (optional) - times at which the fit was taken.
% Dtheory (optional) - theoretical value if diffusion coefficient to plot
%   against experiemntal result.

meanMSDFig = figure;  
[h, ~] = ma.plotMeanMSD(gca, false); % plotMeanMSD(gca, true) will also plot the standard deviation
if isstruct(h)
    hLine = h.mainLine;
    hPatch = h.patch;
    hPatch.DisplayName = 'Standard deviation';
    legendItems = [hLine, hPatch];
else
    hLine = h;
    legendItems = [hLine];
end
hLine.DisplayName = 'Mean MSD';
hold on;

if exist('fo', 'var')
    hf = plot(fo);
    hf.DisplayName = 'Fit';
    legendItems = [legendItems, hf];
end

if exist('Dtheory', 'var') && ~isempty(Dtheory)
    % plot theoretical line:
    x = hLine.XData; % use t-data from figure to plot fit
    y = 4*Dtheory*x;
    ht = plot(x,y);
    ht.DisplayName = 'Theoretical line';
    legendItems = [legendItems, ht];
end

if exist('t_fit', 'var') && ~isempty(t_fit)
    htf = plot(t_fit, zeros(size(t_fit)), 'LineWidth', 3, 'Color', [0,0,0,0.5]);
    htf.DisplayName = 'Fit region';
    legendItems = [legendItems, htf];
end
ma.labelPlotMSD;
title('Mean MSD');
legend(legendItems);
