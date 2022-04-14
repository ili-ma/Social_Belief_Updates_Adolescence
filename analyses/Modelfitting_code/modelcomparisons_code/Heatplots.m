% Plots the policies of the three models and the differences between them.
function Heatplots()
    steal_pink = pink;

    policycolors = jet; % 1 - repmat(steal_pink(:,1), 1, 3);
    policy_scale = [0, 10];

    diffcolors = jet;
    diff_scale = [-1.5, 1.5];

    % Time correction
    tc = repmat(1:26, 26, 1);
    % Enable this line to disable time boost
    tc = ones(26, 26); % disable time correction
    n_trials = 60;
    
    load('summaryORA3.mat');
    
    counts_data = coverage(data);

    load('estimates_optimalFull_ORA3_19March2019.mat');
    pars_optimal = pars_est;
    probs_optimal = getProbs(pars_optimal);
    counts_optimal = makeFreq(probs_optimal) * n_trials;

    load('estimates_uncertaintyFull3_ORA_20March2019.mat');
    pars_heuristic = pars_est;
    probs_heuristic = getProbs(pars_heuristic);
    counts_heuristic = makeFreq(probs_heuristic) * n_trials;

    load('estimates_DDMTwobounds_ORA3_19March2019.mat');
    pars_ddm = pars_est;
    probs_ddm = getProbs(pars_ddm);
    counts_ddm = makeFreq(probs_ddm) * n_trials;

    load('estimates_Ksamples_ORA3_13Jan2022.mat');
    pars_count = pars_est;
    probs_count = getProbs(pars_count);
    counts_count = makeFreq(probs_count) * n_trials;

    figure('Position', [20, 450, 1700, 300]);
    addPlot(1, 5, tc .* counts_data,      policy_scale, policycolors, 'Human Data');
%     addPlot(2, tc .* counts_optimal,   policy_scale, policycolors, 'Optimal');
%     addPlot(3, tc .* counts_heuristic, policy_scale, policycolors, 'Uncertainty');
%     addPlot(4, tc .* counts_ddm,       policy_scale, policycolors, 'DDM');

    figure('Position', [20, 20, 1700, 300]);
%     addPlot(1, 4, tc .* (counts_data - counts_optimal),   diff_scale, diffcolors, 'Data - Optimal');
    addPlot(2, 4, tc .* (counts_data - counts_heuristic), diff_scale, diffcolors, 'Data - Uncertainty');
    addPlot(3, 4, tc .* (counts_data - counts_ddm),       diff_scale, diffcolors, 'Data - DDM');
    addPlot(4, 4, tc .* (counts_data - counts_count),     diff_scale, diffcolors, 'Data - Count');
    
    subplot(1, 4, 1);
    caxis(diff_scale);
    colorbar;
    axis off;
end

function addPlot(nr, total, data, scale, colors, title_text)
    subplot(1, total, nr);
    img = imagesc(data, scale);
    if ~exist('OCTAVE_VERSION', 'builtin')
        set(img, 'AlphaData', ~isnan(data));
    end
    title(title_text);
    set(gca,'YDir','normal');
    ticks = [1, 6, 11, 16, 21, 26];
    labels = {'0','5','10', '15', '20', '25'};
    set(gca, 'XTick', ticks);
    set(gca, 'YTick', ticks);
    set(gca, 'XTickLabel', labels);
    set(gca, 'YTickLabel', labels);
    set(gca, 'FontSize', 16);
    xlabel('samples');
    ylabel('green samples');
    hold on;
    plot(1 + [0 size(data, 2)], 1 + [0 0.5 * size(data, 1)], 'w-');
    colormap(colors);
    %colorbar;
    hold off;
end