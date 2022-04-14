load estimates_uncertaintyFull3_ORA_20March2019.mat
load invest_Uncertainty_ORA3.mat
load summaryORA3.mat

scatterBins = 6;
bins = 6;

[sctCenters, sctData, sctModel, age] = plotInvestDecisions_function_ORA(data, pars_est, softmax_pars_est, scatterBins);
[binCenters, binData, binModel, ~  ] = plotInvestDecisions_function_ORA(data, pars_est, softmax_pars_est, bins);

figure;
hold on;

%Scatter plot
plotInvestCreateScatterPlot_function_ORA(age, sctData, sctModel, true, false);

colorbar();

% Rotated ellipses
%plotInvestCreateEllipsePlot(binCenters, binData, binModel);

% SEM ellipses
%legendHandles = plotInvestCreateSemEllipsePlot(binCenters, binData, binModel);


% plot([0 1], [0 1], 'k--', 'LineWidth', 2);

%set(gca,'XLim', ([0 1]), 'box', 'off', 'FontSize',20);