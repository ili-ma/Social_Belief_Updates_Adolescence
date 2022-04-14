function plotafterfitting_DDMTwobounds_ORA()
    plotafterfitting_template(...
        "estimates_DDMTwobounds_ORA3_19March2019.mat",...
        @(pars_est, subjid) compute_prob_sample(pars_est, subjid),...
        'Threshold model'...
    );
end

function prob_sample = compute_prob_sample(pars_est, subjid)
    T = 25;
    m = 2;
	pars_idx = find(pars_est(:,1) == subjid);
    beta1_est    = pars_est(pars_idx, 2);
    kpos_est     = pars_est(pars_idx, 3);
    kneg_est     = pars_est(pars_idx, 4);
    collapse     = 0;
    
    DeltaQ = computeDDM_twobounds_ORA(T, kpos_est, kneg_est, collapse);
    prob_sample = 1 ./ (1 + exp(- beta1_est * DeltaQ));
end
