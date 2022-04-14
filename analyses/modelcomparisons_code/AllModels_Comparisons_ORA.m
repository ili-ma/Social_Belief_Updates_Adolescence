%%systematic comparison modelfit with increasing freedom
%clear; close all;
load('summaryORA3.mat')
dpssym = decisionsPerSubject(data, []);

Uncert = load('estimates_uncertaintyFull3_ORA_20March2019');
uncertNLL = Uncert.allbestNLL(:,2);

DDM = load('estimates_DDMTwobounds_ORA3_19March2019.mat');
DDMNLL = DDM.allbestNLL(:,2);

optimal = load('estimates_optimalFull_ORA3_19March2019');
optimalNLL = optimal.allbestNLL(:,2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
optimalBIC  = (log(dpssym(:,2)))*6 - (2* -optimalNLL);
uncertBIC  = (log(dpssym(:,2)))*4 - (2* -uncertNLL);
countBIC  = (log(dpssym(:,2)))*3 - (2* -DDMNLL);
diffsB =  uncertBIC - optimalBIC; %countBIC ;

% BIC bootstrapped 95% CI of the summed difference
BIC = diffsB; 
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