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

% urgency = load('EstimatesHauserBasicModel_ORA');
% urgencyNLL = urgency.allbestNLL(:,2);

KSamples = load('estimates_KSamples_ORA');
KSamplesNLL = KSamples.allbestNLL(:,1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % AIC's & BIC's
optimalAIC  = -2* (( -optimalNLL) - 6);
optimalBIC  = (log(dpssym(:,2)))*6 - (2* -optimalNLL);

uncertAIC  = -2* (( -uncertNLL) - 4);
uncertBIC  = (log(dpssym(:,2)))*4 - (2* -uncertNLL);

ThresholdAIC  = -2* (( -DDMNLL) - 3);
ThresholdBIC  = (log(dpssym(:,2)))*3 - (2* -DDMNLL);

KsamplesAIC  = -2* (( -KSamplesNLL) - 2);
KsamplesBIC  = (log(dpssym(:,2)))*2 - (2* -KSamplesNLL);

% urgencyAIC  = -2* (( -urgencyNLL) - 5);
% urgencyBIC = (log(dpssym(:,2)))*5 - (2* -urgencyNLL);

diffsA =  ThresholdAIC - KsamplesAIC; 
diffsB =  uncertBIC - ThresholdBIC  

% AIC bootstrapped 95% CI of the summed difference
AIC = diffsA; 
nboot = 10000000;
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

load('agedata.mat')
[rho,pval] = corr(Agedata(:,3),diffsB)

%VBA
%create transposed matrix
LLs = [-uncertNLL'; -DDMNLL'; -optimalNLL'; -KSamplesNLL']
age = Agedata(:,2)';
BICs = [-uncertBIC'; -ThresholdBIC'; -optimalBIC'; -KsamplesBIC']
[posterior,out] = VBA_groupBMC(BICs)
f  = out.Ef 
EP = out.ep
PEP = (1-out.bor)*out.ep + out.bor/length(out.ep)

BICssave = [-uncertBIC, -ThresholdBIC, -optimalBIC, -KsamplesBIC, age']
csvwrite('BICsAge.csv',BICssave)
group1 = readmatrix('BICsAge_10_12.csv')
group1(:,5) = []
group2 = readmatrix('BICsAge_13_15.csv')
group2(:,5) = []
group3 = readmatrix('BICsAge_16_18.csv')
group3(:,5) = []
group4 = readmatrix('BICsAge_19_21.csv')
group4(:,5) = []
group5 = readmatrix('BICsAge_22_24.csv')
group5(:,5) = []
[h, p] = VBA_groupBMC_btwGroups({group1', group2', group3', group4', group5'})