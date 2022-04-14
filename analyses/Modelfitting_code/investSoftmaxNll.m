function nll = investSoftmaxNll(data, pars_est, softmaxPars)
    %investSoftmax Compute the likelihood of each investment decision
    % This function can be called with the data for all subjects or
    % with filtered per person data.
    T = 25;
    m = 2;
    b0 = softmaxPars(1);
    b1 = softmaxPars(2);
    nll = 0;
    exclude = [];
    
    if ~isfield(data, 'rawChoice')
        disp('data does not have the rawChoice field. Can''t fit data');
        return;
    end
    
    includedSubjects = [];
    prevSubj = nan;
    for row = find(data.rawChoice ~= 0)'
        subject = data.subjid(row);
        if ismember(subject, exclude)
            % skip excluded subjects
            continue;
        end
        if subject ~= prevSubj
            includedSubjects = [includedSubjects subject];
            subjIdx = numel(includedSubjects);
            risk = 0;
            alpha_prior = pars_est(subjIdx, 4);
            beta_prior = pars_est(subjIdx, 5);
            DeltaUtable = computeDeltaUtable(T, m, alpha_prior, beta_prior, risk);
            prevSubj = subject;
        end
        
        actualDecision = data.rawChoice(row);
        nGreen = data.green(row);
        nOpen = nGreen + data.red(row);
        deltaU = DeltaUtable(nGreen + 1, nOpen + 1);
        pInvest = 1 / (1 + exp(-b0 - b1 * deltaU));
        if actualDecision > 0
            pActualDecision = pInvest;
        else
            pActualDecision = 1 - pInvest;
        end
        nll = nll - log(pActualDecision);
    end
    
    if numel(includedSubjects) ~= 1 && numel(includedSubjects) ~= size(pars_est, 1)
        disp(['Should have seen ' num2str(size(pars_est, 1)) ' subjects but saw ' num2str(numel(includedSubjects))]);
    end
end

