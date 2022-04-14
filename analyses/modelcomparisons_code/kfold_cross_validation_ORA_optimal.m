function result = kfold_cross_validation_ORA_optimal()
    load('summaryORA3.mat');
    subjvec = unique(data.subjid)';
    %subjvec = setdiff(subjvec, [4001]); %exclude 
    
    n_folds = 6; % we have 60 trials, 10 per recip prob. So 6 folds leads to 50 held-in and 10 held-out trials.
    numinit = 100; % Number of starting points for parameter fitting

    % To get quick test results:
%      numinit = 2;
%      n_folds = 5;
%      subjvec = [1 2];
    
    bar = waitbar(0, 'Splitting the data', 'Name','Cross Validation', 'Position', [100, 100, 300, 45]);
    folds = split(data, subjvec', n_folds);
    result = subjvec';
    for validation_fold_nr = 1:n_folds
        waitbar(validation_fold_nr / n_folds, bar, sprintf('Validating fold %d/%d', validation_fold_nr, n_folds));
        % start with an empty selection
        training = select(folds(1), false);
        for train_fold_nr = 1:n_folds
            if train_fold_nr ~= validation_fold_nr
                training = combine(training, folds(train_fold_nr));
            end
        end
        [~, pars_est] = fitRiskaversionFreepriors(training, subjvec, numinit);
        fold_result = validate(folds(validation_fold_nr), pars_est);
        result = [result fold_result];
        save k_fold_probabilities result
    end
    delete(bar);
end

function folds = split(data, subjvec, n_folds)
    % Make sure the choice column is encoded as expected
    if ~isequal(unique(data.choice), [-1;1]) || sum(data.choice == 1) < sum(data.choice == -1)
        error('Choice column must be encoded with 1 for sample and -1 for decide');
    end
    % Initialize the folds to empty selections
    for fold_nr = 1:n_folds
        folds(fold_nr) = select(data, false);
    end
    % To make sure every reciprocation is
    % represented equally in all folds we split per recip condition per person
    
    % Because of rounding the first folds would get more trials than later
    % ones. To compensate we keep a counter to bias another fold
    % each time. If everybody has exactly the same number of trials per
    % condition then this isn't needed, but it doesn't hurt either.
    condition = 0;
            for recip = unique(data.recip)'
                for subj = subjvec'
                    % First select all the data for this recip/subj combination
                    selection = select(data, data.subjid == subj & data.recip == recip);
                    % Recode the choice column to 0 for sample and 1 for
                    % decide. Then make a cumulative sum. This will assign an
                    % ad hoc trial number so we can keep trials together. We
                    % need to shift it down because the row below the decision
                    % row is the first one that belongs to the next trial.
                    decisions = [0; 0.5 * (1 - selection.choice)];
                    trial_nrs = cumsum(decisions(1:length(selection.choice))); % starts at 0
                    if max(trial_nrs) + 1 ~= 10
                        fprintf('ATTENTION %d %d %d %3.1f %d\n', subj, recip, max(trial_nrs) + 1);
                    end
                    % Assign each trial to a fold
                    for fold_nr = 1:n_folds
                        folds(fold_nr) = combine(folds(fold_nr), select(selection, mod(trial_nrs + condition, n_folds) == (fold_nr - 1)));
                    end
                    condition = condition + 1;
                end
            end
end

function result = select(data, idx)
    result.subjid = data.subjid(idx);
    result.recip = data.recip(idx);
    result.red = data.red(idx);
    result.green = data.green(idx);
    result.choice = data.choice(idx);
end

function result = combine(data1, data2)
    result.subjid = [data1.subjid; data2.subjid];
    result.recip = [data1.recip; data2.recip];
    result.red = [data1.red; data2.red];
    result.green = [data1.green; data2.green];
    result.choice = [data1.choice; data2.choice];
end

function probs = validate(data, pars_all)
    probs = [];
    
    m = 2;
    T = 25;

    for subjIndex = 1:size(pars_all, 1)
        subj = pars_all(subjIndex, 1);
        subjData = select(data, data.subjid == subj);
        subjProbs = [];
        pars = pars_all(subjIndex, 2:end);
        k     = pars(1); 
        beta1 = pars(2);
        c_est  = pars(3);
        risk_est       = pars(4); 
        alphaPrior = pars(5);
        betaPrior  = pars(6);
        

                DeltaQ = computeDeltaQ_Optimal_ORA(T, m, c_est, risk_est, alphaPrior, betaPrior);

                trialidx   = find(subjData.red + subjData.green < T);

                thistime   = subjData.red(trialidx) + subjData.green(trialidx) + 1;
                thischoice = subjData.choice(trialidx);

                linearidx           = sub2ind(size(DeltaQ), subjData.green(trialidx) + 1, thistime);
                DeltaQ_vectorized   = DeltaQ(:);

                % Log likelihood
                subjProbs = [subjProbs; 1./(1 + exp(- thischoice .* (beta1 * (DeltaQ_vectorized(linearidx) - k))))];
            end
        end
        % subjProbs now contains the probabilities of each sample decision
        probs = [probs; mean(subjProbs)];
    end
end