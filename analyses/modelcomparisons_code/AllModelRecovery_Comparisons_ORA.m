%%systematic comparison modelfit with increasing freedom
%clear; close all;
load('generated_Ksamples_modelRecovery_ORA.mat')
dpssym = decisionsPerSubject(data, []);

Uncert = load('estimates_Recovery_Ksamples_uncertainty23July2021.mat');
uncertNLL = Uncert.allbestNLL(:,1);

DDM = load('estimates_Recovery_Ksamples_Threshold_23July2021.mat');
DDMNLL = DDM.allbestNLL(:,1);

optimal = load('estimates_Recovery_Ksamples_Optimal_23July2021.mat');
optimalNLL = optimal.allbestNLL(:,1);

count = load('estimates_Recovery_KSamples_KSamples23Juy2021.mat');
countNLL = count.allbestNLL(:,1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
optimalBIC  = (log(dpssym(1:20,2)))*6 - (2* -optimalNLL(1:20,:));
uncertBIC  = (log(dpssym(1:20,2)))*4 - (2* -uncertNLL(1:20,:));
threshBIC  = (log(dpssym(1:20,2)))*3 - (2* -DDMNLL(1:20,:));
countBIC  = (log(dpssym(1:20,2)))*2 - (2* -countNLL(1:20,:));

diffsB =  uncertBIC - optimalBIC; 
compMat = [uncertBIC, optimalBIC, threshBIC,countBIC]
[~, idx]=min(compMat')
sum(idx == 4)/length(idx) % number shows how often the model in that index number wins.
% % BIC bootstrapped 95% CI of the summed difference
% BIC = diffsB; 
% nboot = 1000000;
% sum_boot = NaN(nboot,1);
% for i = 1:nboot
%    % Draw bootstrap sample
%    BIC_boot = randsample(BIC, length(BIC), 1);
%    sum_boot(i) = sum(BIC_boot);
% end
% sumBIC = sum(BIC)
% CI_lowerBIC = quantile(sum_boot, 0.025);
% CI_upperBIC = quantile(sum_boot, 0.975);
% disp('CI_Low_BIC')
% disp(num2str(CI_lowerBIC,'%.2f'))
% disp('CI_Up_BIC')
% disp(num2str(CI_upperBIC,'%.2f'))