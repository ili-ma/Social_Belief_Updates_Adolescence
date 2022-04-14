%systematic comparison modelfit with increasing freedom for count model
clear all;
load('summaryORA3.mat')
dpssym      = decisionsPerSubject(data, []);

% twoboundscollapse = load('estimates_DDMTwoboundsCollapse_Prepped_ORA_29Jan2019.mat')
% twoboundscollapseNLL = twoboundscollapse.allbestNLL

twobounds =  load('estimates_DDMTwobounds_ORA3_19March2019.mat')
twoboundsNLL = twobounds.allbestNLL

collapse = load('estimates_DDMcollapse_ORA3_19March2019.mat')
collapseNLL = collapse.allbestNLL

basic = load('estimates_DDMbasic_ORA3_29March2019.mat')
basicNLL = basic.allbestNLL

generatedKsamples = load('estimates_Recovered_KSamples_KSamples23Juy2021.mat')
generatedKsamplesNLL = generatedKsamples.allbestNLL


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% AIC's 
basicAIC  = -2 * ((-basicNLL) - 2);
twoboundsAIC = -2* (( -twoboundsNLL) - 3);
collapseAIC  = -2* (( -collapseNLL) - 3);
%twoboundscollapseAIC = -2 * (( -twoboundscollapseNLL) - 4);

% BIC's
%twoboundscollapseBIC = (log(dpssym(:,2)))*4 - (2* -twoboundscollapseNLL);
twoboundsBIC = (log(dpssym(:,2)))*3 - (2* -twoboundsNLL);
collapseBIC  = (log(dpssym(:,2)))*3 - (2* -collapseNLL);
basicBIC     = (log(dpssym(:,2)))*2 - (2* -basicNLL);


diffsA = basicBIC - twoboundsAIC;%collapseAIC;%twoboundscollapseAIC;% - twoboundsAIC;
diffsB = collapseBIC - twoboundsBIC;%collapseBIC;%twoboundscollapseBIC;% - twoboundsBIC;

% AIC bootstrapped 95% CI
% AIC = diffsA(:,2); % indicate AIC for which you want to calculate the CI
% nboot = 100000;
% sum_boot = NaN(nboot,1);
% for i = 1:nboot
%    % Draw bootstrap sample
%    AIC_boot = randsample(AIC, length(AIC), 1);
%    sum_boot(i) = median(AIC_boot);
% end
% summed = median(diffsA(:,2))
% CI_lowerAIC = quantile(sum_boot, 0.025)
% CI_upperAIC = quantile(sum_boot, 0.975)

% BIC bootstrapped 95% CI
BIC = diffsB(:,2); % indicate AIC for which you want to calculate the CI
nboot = 100000;
sum_boot = NaN(nboot,1);
for i = 1:nboot
   % Draw bootstrap sample
   BIC_boot = randsample(BIC, length(BIC), 1);
   sum_boot(i) = sum(BIC_boot);
end
summed = sum(diffsB(:,2))
CI_lowerBIC = quantile(sum_boot, 0.025)
CI_upperBIC = quantile(sum_boot, 0.975)

