%%systematic comparison modelfit with increasing freedom
clear; close all;
load('summaryORA3.mat')

%Data estimates
%dpssym = decisionsPerSubject(data, []);
% Uncert = load('estimates_uncertaintyFull3_ORA_20March2019');
% uncertNLL = Uncert.allbestNLL(:,2);
% DDM = load('estimates_DDMTwobounds_ORA3_19March2019.mat');
% DDMNLL = DDM.allbestNLL(:,2);
% optimal = load('estimates_optimalFull_ORA3_19March2019.mat');
% optimalNLL = optimal.allbestNLL(:,2);

% 
% %Optimal generated data
%  dpssym = decisionsPerSubject(data, [24:167]);
% Uncert = load('estimates_generatedOptimal_recoveredUncertainty');
% uncertNLL = Uncert.allbestNLL(:,1);
% DDM = load('estimates_generatedOptimal_recoveredDDM.mat');
% DDMNLL = DDM.allbestNLL(:,1);
% optimal = load('estimates_generatedOptimal_recoveredOptimal');
% optimalNLL = optimal.allbestNLL(:,1);
% kSamples = load('estimates_Recovered_Optimal_KSamples24Juy2021');
% kSamplesNLL = kSamples.allbestNLL(:,1);
% kSamplesNLL = kSamplesNLL(1:20);
% 
% %Uncertainty generated data
%  dpssym = decisionsPerSubject(data, [24:167]);
% Uncert = load('estimates_generatedUncertainty_recoveredUncertainty.mat');
% uncertNLL = Uncert.allbestNLL(:,1);
% DDM = load('estimates_generatedUncertainty_recoveredDDM.mat');
% DDMNLL = DDM.allbestNLL(:,1);
% optimal = load('estimates_generatedUncertainty_recoveredOptimal');
% optimalNLL = optimal.allbestNLL(:,1);
% kSamples = load('estimates_Recovered_Uncertainty_KSamples24Juy2021');
% kSamplesNLL = kSamples.allbestNLL(:,1);
% kSamplesNLL = kSamplesNLL(1:20);

%DDM generated data
dpssym = decisionsPerSubject(data, [24:167]);
% Uncert = load('estimates_generatedDDM_recoveredUncertainty.mat');
% uncertNLL = Uncert.allbestNLL(:,1);
DDM = load('estimates_generatedDDM_recoveredDDM.mat');
DDMNLL = DDM.allbestNLL(:,1);
% optimal = load('estimates_generatedDDM_recoveredOptimal');
% optimalNLL = optimal.allbestNLL(:,1);
kSamples = load('estimates_Recovered_Threshold_KSamples24Juy2021');
kSamplesNLL = kSamples.allbestNLL(:,1);
kSamplesNLL = kSamplesNLL(1:20);

% %Count generated data
% dpssym = decisionsPerSubject(data, []);
% Uncert = load('estimates_Recovery_Ksamples_uncertainty23July2021.mat');
% uncertNLL = Uncert.allbestNLL(:,1);
% DDM = load('estimates_Recovery_Ksamples_Threshold_23July2021.mat');
% DDMNLL = DDM.allbestNLL(:,1);
% optimal = load('estimates_Recovery_Ksamples_Optimal_23July2021');
% optimalNLL = optimal.allbestNLL(:,1);
% kSamples = load('estimates_Recovery_KSamples_KSamples23Juy2021');
% kSamplesNLL = kSamples.allbestNLL(:,1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % AIC's & BIC's
%optimalBIC  = (log(dpssym(:,2)))*6 - (2* -optimalNLL);
%uncertBIC  = (log(dpssym(:,2)))*4 - (2* -uncertNLL);
thresholdBIC  = (log(dpssym(:,2)))*3 - (2* -DDMNLL);
countBIC  = (log(dpssym(:,2)))*3 - (2* -kSamplesNLL);

diffsB =  thresholdBIC - countBIC;

% BIC bootstrapped 95% CI of the summed difference
BIC = diffsB; 
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