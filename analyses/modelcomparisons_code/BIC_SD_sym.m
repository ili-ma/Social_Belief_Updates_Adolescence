%load data for decisions per subject
clear; close all;
load('summaryORA3.mat')
dpssym      = decisionsPerSubject(data, []);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% basic model, threshold, cost
basic = load('estimates_uncertaintyBasic3_ORA_20March2019.mat');
basicNLL = basic.allbestNLL(:,2);

% full model, threshold, noise and priors
full = load('estimates_uncertaintyFull3_ORA_20March2019.mat');
fullNLL = full.allbestNLL(:,2);

% AIC & BIC
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
basicAIC  = -2 * ((-basicNLL) - 2);
fullAIC  = -2 * ((-fullNLL) - 4);

basicBIC  = (log(dpssym(:,2)))*2 - (2* -basicNLL);
fullBIC  = (log(dpssym(:,2)))*4 - (2* -fullNLL);

diffsA = basicAIC - fullAIC;
diffsB = basicBIC - fullBIC;
% % AIC bootstrapped 95% CI of the summed difference
% AIC = diffsA; % indicate AIC for which you want to calculate the CI
% nboot = 100000;
% sum_boot = NaN(nboot,1);
% for i = 1:nboot
%    % Draw bootstrap sample
%    AIC_boot = randsample(AIC, length(AIC), 1);
%    sum_boot(i) = sum(AIC_boot);
% end
% sumAIC = sum(AIC)
% CI_lowerAIC = quantile(sum_boot, 0.025);
% CI_upperAIC = quantile(sum_boot, 0.975);
% disp('CI_Low_AIC')
% disp(num2str(CI_lowerAIC,'%.2f'))
% disp('CI_Up_AIC')
% disp(num2str(CI_upperAIC,'%.2f'))

% BIC bootstrapped 95% CI of the summed difference
BIC = diffsB; % indicate AIC for which you want to calculate the CI
nboot = 100000;
sum_boot = NaN(nboot,1);
for i = 1:nboot
   % Draw bootstrap sample
   BIC_boot = randsample(BIC, length(BIC), 1);
   sum_boot(i) = sum(BIC_boot);
end
sumBIC = sum(BIC)
CI_lowerBIC = quantile(sum_boot, 0.025);
CI_upperBIC = quantile(sum_boot, 0.975);
disp('CI_Low_BIC')
disp(num2str(CI_lowerBIC,'%.2f'))
disp('CI_Up_BIC')
disp(num2str(CI_upperBIC,'%.2f'))
