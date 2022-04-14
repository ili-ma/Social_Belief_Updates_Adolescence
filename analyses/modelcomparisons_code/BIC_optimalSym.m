% %load data for decisions per subject

load('summaryORA3.mat')
dpssym      = decisionsPerSubject(data, []);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Noise and cost
Basic = load('estimates_optimalbasic_ORA3_19March2019.mat')
basicNLL = Basic.allbestNLL;

% Noise, cost and risk
risk = load('estimates_optimalrisk_ORA3_19March2019.mat')
riskNLL = risk.allbestNLL;

%full model
full = load('estimates_optimalFull_ORA3_19March2019.mat')
fullmodelNLL = full.allbestNLL;


urgencybasic = load('EstimatesHauserBasicModel_ORA.mat')
urgencybasicNLL = urgencybasic.allbestNLL;

urgencyfull = load('EstimatesHauserfullModel_ORA_NoRisk.mat')
urgencyfullNLL = urgencyfull.allbestNLL;

%AIC & BIC
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
basicAIC  = -2 * ((-basicNLL) - 3);
riskAIC  = -2 * ((-riskNLL) - 4);
fullmodelAIC = -2 * ((-fullmodelNLL) - 6);
urgencybasicAIC = -2 * ((-urgencybasicNLL) - 5);
urgencyfullAIC = -2 * ((-urgencyfullNLL) - 7);


basicBIC  = (log(dpssym(:,2)))*3 - (2* -basicNLL);
riskBIC  = (log(dpssym(:,2)))*4 - (2* -riskNLL);
fullmodelBIC =  (log(dpssym(:,2)))*6 - (2* -fullmodelNLL);
urgencybasicBIC =  (log(dpssym(:,2)))*5 - (2* -urgencybasicNLL);
urgencyfullBIC =  (log(dpssym(:,2)))*7 - (2* -urgencyfullNLL);


diffsA =  urgencybasicAIC - urgencyfullAIC;%- fullmodelAIC;
diffsB  = urgencybasicBIC - urgencyfullBIC;% - fullmodelBIC;
% AIC bootstrapped 95% CI of the summed difference
AIC = diffsA(:,2); % indicate AIC for which you want to calculate the CI
nboot = 1000000;
sum_boot = NaN(nboot,1);
for i = 1:nboot
   % Draw bootstrap sample
   AIC_boot = randsample(AIC, length(AIC), 1);
   sum_boot(i) = sum(AIC_boot);
end
sumAIC = sum(AIC)
CI_lowerAIC = quantile(sum_boot, 0.025);
CI_upperAIC = quantile(sum_boot, 0.975);
disp('CI_Low_AIC')
disp(num2str(CI_lowerAIC,'%.2f'))
disp('CI_Up_AIC')
disp(num2str(CI_upperAIC,'%.2f'))

% BIC bootstrapped 95% CI of the summed difference
BIC = diffsB(:,2); % indicate AIC for which you want to calculate the CI
nboot = 1000000;
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
