function plotafterfitting_uncertainty_ORA()
	plotafterfitting_template(...
        "estimates_uncertaintyFull3_ORA_20March2019.mat",...
        @(pars_est, subjid) compute_prob_sample(pars_est, subjid),...
		'Uncertainty model'...
    );
end

function prob_sample = compute_prob_sample(pars_est, subjid)
    T = 25;
    m = 2;
	pars_idx = find(pars_est(:,1) == subjid);
	beta1_est  = pars_est(pars_idx, 2);
	k_est      = pars_est(pars_idx, 3);
	alpha_0    = pars_est(pars_idx, 4); %replace priors with 1 for basic model
	beta_0     = pars_est(pars_idx, 5);

	DeltaQ = computeUncertainty_ORA(T, m, k_est, alpha_0, beta_0);
	prob_sample = 1 ./ (1 + exp(- beta1_est * DeltaQ));
end
