function plotafterfitting_Optimal_ORA()
    plotafterfitting_template(...
        "estimates_optimalFull_ORA3_19March2019.mat",...
        @(pars_est, subjid) compute_prob_sample(pars_est, subjid),...
        'Sample Cost model'...
    );
end

function prob_sample = compute_prob_sample(pars_est, subjid)
    T = 25;
    m = 2;
	pars_idx = find(pars_est(:,1) == subjid);
    k_est     = pars_est(pars_idx, 2);% beta0_est = pars_est(subjidx, 1);
    beta1_est = pars_est(pars_idx, 3);
    c_est     = pars_est(pars_idx, 4);
    
    risk_est   = pars_est(pars_idx, 5);
    alpha_est  = pars_est(pars_idx, 6);
    beta_est   = pars_est(pars_idx, 7);
    
    DeltaQ      = computeDeltaQ_Optimal_ORA(T, m, c_est, risk_est, alpha_est, beta_est);
    prob_sample = 1 ./ (1 + exp(-(beta1_est * (DeltaQ - k_est))));
end
