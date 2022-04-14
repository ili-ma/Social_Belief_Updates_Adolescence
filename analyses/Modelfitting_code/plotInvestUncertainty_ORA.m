% nBins = 10
% load summaryORA_prepped
% load estimates_optimalfull_ORA29Jan2019; load invest_optimal_ORA;

function plotInvestUncertainty_ORA(data, pars_est, softmax_pars_est, nBins)
if ~isfield(data, 'rawChoice')
    disp('data does not have the rawChoice field. Can''t plot data');
    return;
end
exclude = [];

subjects = setdiff(unique(data.subjid), exclude)
nSubjects = size(pars_est, 1) - 2
T = 25;
m = 2;
% We sort the actually occuring deltaUs from the data and cut them up in
% the required amount of bins, then compute the centers
binCentersPp = NaN(nSubjects, nBins);
% The proportion of invest choices for a given bin
binProportionsPp = NaN(nSubjects, nBins);
pInvestsFromModel = NaN(nSubjects, nBins);
% Each subject has their own priors and risk aversion, so to interpret the data we have to go subject by subject
for subjIdx = 1:nSubjects
    %!!!!!!!!!! Collect subbject information DIFFERENT PARS FOR HEURISTIC AND OPTIMAL
    subjectNr = subjects(subjIdx);
    risk = 0;%change for sym and other models!!!!
    alpha_prior = pars_est(subjIdx, 4);
    beta_prior = pars_est(subjIdx, 5);
    DeltaUtable = computeDeltaUtable(T, m, alpha_prior, beta_prior, risk);
    
    b0s = softmax_pars_est(subjIdx, 2);
    b1s = softmax_pars_est(subjIdx, 3);
    
            conditionNr = 1;
            choiceIdx = data.rawChoice ~= 0 & data.subjid == subjectNr;
            nGoods = data.green(choiceIdx);
            nOpens = nGoods + data.red(choiceIdx);
            dus = DeltaUtable(sub2ind(size(DeltaUtable), nGoods + 1, nOpens + 1));
            choices = data.rawChoice(choiceIdx);
            invests = 0.5 * (choices + 1);
            % Put the invest data in a table with accompanying deltaU
            investTable = [dus invests];
            % Sort them on delta u
            investTable = sortrows(investTable, 1);
            %         figure;
            %         plot(investTable(:,1), 1 ./ (1 + exp(-softmax_pars_est(subjIdx, 1) - softmax_pars_est(subjIdx, 2) * investTable(:,1))), 'bo');
            %         hold on;
            %         plot(investTable(:,1), investTable(:,2) - 0.1 + 0.2 * rand(size(investTable, 1), 1), 'ko');
            % fill the center- and proportions table
            binSize = ceil(size(investTable, 1) / nBins);
            for binNr = 1:nBins
                first = (binNr - 1) * binSize + 1;
                last = min(binNr * binSize, size(investTable, 1));
                binCentersPp(subjIdx, binNr) = mean(investTable(first:last, 1));
                binProportionsPp(subjIdx, binNr) = mean(investTable(first:last, 2));
                pInvestsFromModel(subjIdx, binNr) = mean(1 ./ (1 + exp(-b0s - b1s * investTable(first:last, 1))));
            end
end

% Aggregate statistics
avgBinProps = squeeze(mean(binProportionsPp));
sems = squeeze(std(binProportionsPp)) ./ sqrt(nSubjects);
binCenters = squeeze(mean(binCentersPp));
interval = [min(binCenters(:)) max(binCenters(:))];
modelLight = [0.8 0.8 0.8];%
% modelDark = [0.6 0.6 0.6];
% dataLight = [0.4 0.4 0.4];
% dataDark = [0.2 0.2 0.2];

% Compute model data for the shaded area
%     for sub = 1:3
%         figure
%         plot(binCenters, pInvestsFromModel(sub,:));
%         hold on;
%         plot(binCenters, binProportionsPp(sub,:), 'ko')
%     end

modelBinCenters = mean(binCentersPp);
modelMeans = mean(pInvestsFromModel);
modelSems = std(pInvestsFromModel) ./ sqrt(nSubjects);
highModel = modelMeans + modelSems;
lowModel = modelMeans - modelSems;
X = [modelBinCenters fliplr(modelBinCenters)];
Y = [highModel fliplr(lowModel)];
usable = ~isnan(X) & ~isnan(Y);
fill(X(usable), Y(usable), modelLight, 'FaceAlpha', 1, 'EdgeAlpha', 0);
set(gca,'xtick', -0.8:0.2:0.8);

hold on;

% Data line and error bars
highData = avgBinProps + sems;
lowData = avgBinProps - sems;
colors = [0.7 .7 .7; 0 0 0]';%[.9961 .9412 .5; 0.9922 0.8000 0.5412; 0.9882 0.5529 0.3490; 0.8431 0.1882 0.1216]'; %[.6 .6 .6; .4 .4 .4; .2 .2 .2; 0 0 0]';%
% We have to make a loop because errorbar won't accept an array of colors
errorbar(binCenters, avgBinProps,...
    avgBinProps - lowData,...
    highData - avgBinProps,...
    '.', 'Linewidth', 1.5, 'Color', colors(:, 2));
set(gca,'XLim', ([-1 1]), 'box', 'off'); % replace ([-1 1]) by interval if you want adjusted x-axis
% conditionNr = 1 + money + 2 * social;
legend({'', 'Invest decisions Optimal model'}, 'Location', 'southeast');

%%%%%%%%%% log odds %%%%%%%%%
% figure;
% % Force the data into the range [0...1]
% highModel = min(1, highModel);
% lowModel = max(0, lowModel);
% X = [modelBinCenters fliplr(modelBinCenters)];
% Y = [log(highModel ./ (1 - highModel)) fliplr(log(lowModel ./ (1 - lowModel)))];
% usable = ~isnan(X) & ~isnan(Y);
% fill(X(usable), Y(usable), modelLight, 'FaceAlpha', 0.6, 'EdgeAlpha', 0);
% hold on;
% 
% % log odds line from model
% plot(modelBinCenters, log(modelMeans ./ (1 - modelMeans)), 'Color', modelDark);
% 
% % log odds from data
% dataMeanLOs = log(max(0, avgBinProps ./ (1 - avgBinProps)));
% dataLowLOs = log(max(0, lowData ./ (1 - lowData)));
% dataHighLOs = log(max(0, highData ./ (1 - highData)));
% for c = 1:nConditions
%     errorbar(binCenters(:,c), dataMeanLOs(:,c), dataMeanLOs(:,c) - dataLowLOs(:,c), dataHighLOs(:,c) - dataMeanLOs(:,c), 'Color', colors(:,c));
% end

set(gca,'XLim', interval)
hold off;
end
