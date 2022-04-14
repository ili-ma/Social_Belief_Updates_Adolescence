% nBins = 10
% load summaryORA_prepped
% load invest_DDM_ORA

function plotInvestVarBinsdeterminedbinsizeDDM(data, softmax_pars_est, nBins)
    
    exclude = [];
    subjects = setdiff(unique(data.subjid), exclude);
    nSubjects = size(softmax_pars_est, 1);
    T = 25;
    m = 2;
    
    nConditions = 1;
    % We sort the actually occuring deltaUs from the data and cut them up in
    % the required amount of bins, then compute the centers
    binCentersPp = NaN(nSubjects, nBins, nConditions);
    % The proportion of invest choices for a given bin
    binProportionsPp = NaN(nSubjects, nBins, nConditions);
    pInvestsFromModel = NaN(nSubjects, nBins, nConditions);
    % Each subject has their own priors and risk aversion, so to interpret the data we have to go subject by subject
    for subjIdx = 1:nSubjects
        subjectNr = subjects(subjIdx);
        
        b0s = softmax_pars_est(subjIdx, 2);
        b1s = softmax_pars_est(subjIdx, 3);
        
                conditionNr = 1;
                choiceIdx = data.rawChoice ~= 0 & data.subjid == subjectNr;
                nGoods = data.green(choiceIdx);
                nReds = data.red(choiceIdx);
                diffs = nGoods - nReds;
                choices = data.rawChoice(choiceIdx); % -1 not invest, 1 invest
                invests = 0.5 * (choices + 1); % 0 not invest, 1 invest
                % Put the invest data in a table with accompanying differences in red/green
                investTable = [diffs invests];
                % Sort them on difference
                investTable = sortrows(investTable, 1);

                binSize = ceil(size(investTable, 1) / nBins);
                for binNr = 1:nBins
                    first = (binNr - 1) * binSize + 1;
                    last = min(binNr * binSize, size(investTable, 1));
                    binCentersPp(subjIdx, binNr, conditionNr) = mean(investTable(first:last, 1));
                    binProportionsPp(subjIdx, binNr, conditionNr) = mean(investTable(first:last, 2));
                    pInvestsFromModel(subjIdx, binNr, conditionNr) = mean(1 ./ (1 + exp(-b1s * (investTable(first:last, 1) - b0s))));
                end
    end
    % Aggregate statistics

    avgBinProps = squeeze(mean(binProportionsPp));
    sems = squeeze(std(binProportionsPp)) ./ sqrt(nSubjects);
    binCenters = squeeze(mean(binCentersPp));
    interval = [min(binCenters(:)) max(binCenters(:))];
    modelLight = [0.6 0.6 0.6];

    % Compute model data for the shaded area
    %     for sub = 1:3
    %         figure
    %         plot(binCenters, pInvestsFromModel(sub,:));
    %         hold on;
    %         plot(binCenters, binProportionsPp(sub,:), 'ko')
    %     end

    modelBinCenters = mean(mean(binCentersPp, 3));
    modelMeans = mean(mean(pInvestsFromModel, 3));
    modelSems = std(mean(pInvestsFromModel, 3)) ./ sqrt(nSubjects);
    highModel = modelMeans + modelSems;
    lowModel = modelMeans - modelSems;
    X = [modelBinCenters fliplr(modelBinCenters)];
    Y = [highModel fliplr(lowModel)];
    usable = ~isnan(X) & ~isnan(Y);
    fill(X(usable), Y(usable), modelLight, 'FaceAlpha', 1, 'EdgeAlpha', 0);
    set(gca,'xtick', -15:5:15);
    %set(gca,'XMinorTick', 'on');
    %set(gca,'MinorTickValues', [-1:0.1:1]);
    %set(gca,'TickLength', [0.02, 0.02]);

    hold on;

    % Model line
    % plot(binCenters, modelMeans, 'Color', modelLight);

    % Data line and error bars
    highData = avgBinProps + sems;
    lowData = avgBinProps - sems;
    colors = [.7 0.7 .7; 0.5 .5 0.5; 0.3 0.3 0.3; 0 0 0]';%[.9961 .9412 .5; 0.9922 0.8000 0.5412; 0.9882 0.5529 0.3490; 0.8431 0.1882 0.1216]'; %[.6 .6 .6; .4 .4 .4; .2 .2 .2; 0 0 0]';%
    % We have to make a loop because errorbar won't accept an array of colors
    for condition = 1:nConditions
        errorbar(binCenters(:, condition), avgBinProps(:, condition),...
            avgBinProps(:, condition) - lowData(:, condition),...
            highData(:, condition) - avgBinProps(:, condition),...
            '.', 'Linewidth', 1.5, 'Color', colors(:, condition));
    end
    set(gca,'XLim', ([-1 1]), 'box', 'off'); % replace ([-1 1]) by interval if you want adjusted x-axis
    % conditionNr = 1 + money + 2 * social;
    legend({'', 'Invest decisions DDM'}, 'Location', 'southeast');

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
