%parameter recovery tests

%input pars
load('estimates_optimalFull_ORA3_19March2019.mat')
Optimal_input = pars_est(1:20,:);
load('estimates_uncertaintyFull3_ORA_20March2019.mat')
Uncertainty_input = pars_est;
load('estimates_DDMTwobounds_ORA3_19March2019.mat')
DDM_input = pars_est(1:20,:);

%recovered pars
load('estimates_generatedOptimal_recoveredOptimal.mat')
Optimal_rec = pars_est;
load('estimates_generatedUncertainty_recoveredUncertainty_all.mat')
Uncertainty_rec = pars_est;
load('estimates_generatedDDM_recoveredDDM.mat')
DDM_rec = pars_est;

% [h, p, stats] ttest(Optimal_input(:,2),Optimal_rec(:,1)
% [h, p, stats] ttest(Optimal_input(:,3),Optimal_rec(:,2)
% [h, p, stats] ttest(Optimal_input(:,4),Optimal_rec(:,3)
% [h, p, stats] ttest(Optimal_input(:,5),Optimal_rec(:,4)
% [h, p, stats] ttest(Optimal_input(:,6),Optimal_rec(:,5)
% [h, p, stats] ttest(Optimal_input(:,7),Optimal_rec(:,6)


par1 = Uncertainty_input(:,2) - Uncertainty_rec(:,1)
par2 = Uncertainty_input(:,3) - Uncertainty_rec(:,2)
par3 = Uncertainty_input(:,4) - Uncertainty_rec(:,3)
par4 = Uncertainty_input(:,5) - Uncertainty_rec(:,4)

[p, h, stats] = signrank(Uncertainty_input(:,2), Uncertainty_rec(:,1))
[p, h, stats] = signrank(Uncertainty_input(:,3), Uncertainty_rec(:,2))
[p, h, stats] = signrank(Uncertainty_input(:,4), Uncertainty_rec(:,3))
[p, h, stats] = signrank(Uncertainty_input(:,5), Uncertainty_rec(:,4))


diffsA =  par41
% AIC bootstrapped 95% CI of the median difference
AIC = diffsA; 
nboot = 100000;
sum_boot = NaN(nboot,1);
for i = 1:nboot
   % Draw bootstrap sample
   AIC_boot = randsample(AIC, length(AIC), 1);
   sum_boot(i) = median(AIC_boot);
end
sumAIC = median(AIC)
CI_lowerAIC = quantile(sum_boot, 0.025);
CI_upperAIC = quantile(sum_boot, 0.975);
disp('CI_Low_AIC')
disp(num2str(CI_lowerAIC,'%.2f'))
disp('CI_Up_AIC')
disp(num2str(CI_upperAIC,'%.2f'))

