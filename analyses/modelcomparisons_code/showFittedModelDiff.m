% Plots the policies of the three models and the differences between them.
function showFittedModelDiff()
    policycolors = jet;
    policy_scale = [0, 1];

    diffcolors = jet;
    diff_scale = [-0.5, 0.5];

    load('estimates_optimalFull_ORA3_19March2019.mat');
    pars_optimal = pars_est;
    probs_optimal = squeeze(mean(getProbs(pars_optimal)));

    load('estimates_uncertaintyFull3_ORA_20March2019.mat');
    pars_heuristic = pars_est;
    probs_heuristic = squeeze(mean(getProbs(pars_heuristic)));

    load('estimates_DDMTwobounds_ORA3_19March2019.mat');
    pars_count = pars_est;
    probs_count = squeeze(mean(getProbs(pars_count)));

    figure('Position', [20, 450, 1400, 300]);
    addPlot(1, probs_optimal,   policy_scale, policycolors, 'Optimal');
    addPlot(2, probs_heuristic, policy_scale, policycolors, 'Uncertainty');
    addPlot(3, probs_count,     policy_scale, policycolors, 'DDM');

    subplot(1, 4, 4);
    colorbar;
    axis off;

    figure('Position', [20, 20, 1400, 300]);
    addPlot(1, probs_optimal - probs_heuristic, diff_scale, diffcolors, 'Optimal - Uncertainty');
    addPlot(2, probs_optimal - probs_count,     diff_scale, diffcolors, 'Optimal - DDM');
    addPlot(3, probs_heuristic - probs_count,   diff_scale, diffcolors, 'Uncertainty - DDM');
    
    subplot(1, 4, 4);
    caxis(diff_scale);
    colorbar;
    axis off;
end

function addPlot(nr, data, scale, colors, title_text)
    subplot(1, 4, nr);
    img = imagesc(data, scale);
    if ~exist('OCTAVE_VERSION', 'builtin')
        set(img, 'AlphaData', ~isnan(data));
    end
    title(title_text);
    set(gca,'YDir','normal');
    ticks = [1, 6, 11, 16, 21, 25];
    labels = {'0','5','10', '15', '20', '24'};
    set(gca, 'XTick', ticks);
    set(gca, 'YTick', ticks);
    set(gca, 'XTickLabel', labels);
    set(gca, 'YTickLabel', labels);
    xlabel('n samples');
    ylabel('positive samples');
    colormap(colors);
end