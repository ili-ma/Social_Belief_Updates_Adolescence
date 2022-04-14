function probs = getProbs(pars)
    T = 25;
    m = 2;
    
    if isstruct(pars)
		disp("Get probabilites for human data");
        % Getting proportions from experimental data works different
        subjects = unique(pars_est(:,1));
        for subject_index = 1:length(subjects)
            subject = subjects(subject_index);
            probs(subject_index, :, :) = getProbsData(pars, T, subject);
        end
        return;
    else
        switch size(pars, 2)
        case 7 % optimal
            disp("Get probabilites for optimal model");
            probsSource = @(pars, T, m) getProbsOptimal(pars, T, m);
        case 5 % heuristics
            disp("Get probabilites for heuristic/uncertainty model");
            probsSource = @(pars, T, m) getProbsHeuristic(pars, T, m);
        case 4 % ddm
            disp("Get probabilites for ddm model");
            probsSource = @(pars, T, m) getProbsDDM(pars, T, m);
        case 6 % urgency
            disp("Get probabilites for urgency model");
            probsSource = @(pars, T, m) getProbsUrgency(pars, T, m);
        case 2 % count - missing subject nr
            disp("Get probabilites for count model");
            probsSource = @(pars, T, m) getProbsCount(pars, T, m);
        otherwise
            disp(['Don''t know which model has ' num2str(size(pars, 2)) ' parameters']);
            probsSource = @(pars, T, m) getProbsNaN(pars, T, m);
        end
    end

    % Gather the probs for all subjects (all rows of estimated pars)
    for subject_index = 1:size(pars, 1)
        probs(subject_index,:, :) = probsSource(pars(subject_index, :), T, m);

    end
end

function probs = getProbsNaN(pars, T, m)
    probs = NaN(25);
end

function probs = getProbsOptimal(pars, T, m)
    k       = pars(2);
    beta1   = pars(3);
    c       = pars(4);
    risk    = pars(5);
    alpha_0 = pars(6);
    beta_0  = pars(7);
    
    table = computeDeltaQ_Optimal_ORA(T, m, c, risk, alpha_0, beta_0);
    probs = 1 ./ (1 + exp(-beta1 * (table - k)));
end

function probs = getProbsHeuristic(pars, T, m)
    beta1   = pars(2);
    k       = pars(3);
    alpha_0 = pars(4);
    beta_0  = pars(5);

    DeltaQ = computeUncertainty_ORA(T, m, k, alpha_0, beta_0);
    probs = 1 ./ (1 + exp(-1 * (beta1 * DeltaQ)));
end

function probs = getProbsCount(pars, T, m)
    beta1 = pars(1);
    k     = pars(2);

    DeltaQ = computeKsamplesinSoftmax_ORA(T, m, k);
    probs = 1 ./ (1 + exp(-1 * (beta1 * DeltaQ)));
    % For consistency with the other methods we block out the unreachable states
    for col = 1:(size(probs,2) - 1)
        probs(col + 1 : end, col) = NaN;
    end
end

function probs = getProbsDDM(pars, T, m)
    beta1       = pars(2);
    k_pos       = pars(3);
    k_neg       = pars(4);
    collapse    = 0;

    DeltaQ = computeDDM_twobounds_ORA(T, k_pos, k_neg, collapse);
    probs = 1 ./ (1 + exp(-1 * (beta1 * DeltaQ)));
    % For consistency with the other methods we block out the unreachable states
    for col = 1:(size(probs,2) - 1)
        probs(col + 1 : end, col) = NaN;
    end
end

function probs = getProbsUrgency(pars, T, m)
    k       = pars(2);
    beta1   = pars(3);
    scaleFactor = pars(4);
    slope    = pars(5);
    c = pars(6);
    risk = 0;
    alphaPrior = 1;
    betaPrior  = 1;
    
    
    table = computeDeltaQ_Optimal_Hauser(T, m, scaleFactor, slope, c, risk, alphaPrior, betaPrior);
    probs = 1 ./ (1 + exp(-beta1 * (table - k)));
end

function probs = getProbsData(data, T, subject)
    counts = zeros(T, T);
    samples = zeros(T, T);
    indices = find(data.subjid == subject);
    for index = 1:length(indices)
        action = indices(index);
        n_green = data.green(action);
        n_open = n_green + data.red(action);
        if n_open < T
            counts(n_green + 1, n_open + 1) = counts(n_green + 1, n_open + 1) + 1;
            if data.choice(action) > 0
                samples(n_green + 1, n_open + 1) = samples(n_green + 1, n_open + 1) + 1;
            end
        end
    end
    probs = samples ./ counts;
    highestCount = max(counts(:));
    cutoff = max(3, highestCount / 100);
    probs(counts < cutoff) = NaN;
end