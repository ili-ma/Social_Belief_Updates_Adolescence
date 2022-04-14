clear all; close all;
load estimates_uncertaintyFull3_ORA_20March2019;

m = 2;
T = 25;
lapse_est = 0;
recipvec = [0 0.2 0.4 0.6 0.8 1.0];

data.subjid = [];
data.trialNr = [];
data.recip = [];
data.choice = [];
data.green = [];
data.red = [];
data.time = [];

nsims = 10; %unique combinations of recip
for subjidx = 1:length(pars_est)
    subjectnr = 7000 + subjidx;
    trialNr = 1;
            
        % Estimates
        beta1_est  = pars_est(subjidx, 2);
        k_est   = pars_est(subjidx, 3);
        alpha0_est   = pars_est(subjidx, 4);
        beta0_est   = pars_est(subjidx, 5);

        DeltaQ = computeUncertainty_ORA(T, m, k_est, alpha0_est, beta0_est);
        prob_sample = 1./(1+exp(- beta1_est * DeltaQ));

        for recipidx = 1:length(recipvec)
            recip = recipvec(recipidx);

            for trialidx = 1: nsims
                decisionmade = 0;
                ngreen = 0;
                nred = 0;
                time = 1;
                while decisionmade == 0 && (ngreen + nred < T)
                    data.subjid = [data.subjid; subjectnr];
                    data.trialNr = [data.trialNr; trialNr];
                    data.recip = [data.recip; recip];
                    data.green = [data.green; ngreen];
                    data.red = [data.red; nred];
                    data.time = [data.time; time];

                    if rand < lapse_est
                        decidetosample = rand < 0.5;
                    else
                        decidetosample = rand < prob_sample(ngreen + 1, ngreen + nred + 1);
                    end

                    if decidetosample == 0
                        decisionmade = 1;
                        data.choice = [data.choice; -1];
                    else
                        samplegood   = rand < recip;
                        ngreen = ngreen + samplegood;
                        nred = nred + (1-samplegood);
                        data.choice = [data.choice; 1];
                    end
                    time = time + 1;
                end
                trialNr = trialNr + 1;
            end
        end
end

save generated_uncertainty_modelRecovery_ORA data