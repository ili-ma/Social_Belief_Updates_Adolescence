% subsetting half of the data to estimate priors on first and second task
% half. First contains trial 1 to 30. Second contains trail 31 to 60

% %for splitting the data
% idx = data.trial < 31
% first.subjid        = data.subjid(idx);
% first.trial         = data.trial(idx);
% first.gender        = data.gender(idx);
% first.ageExact      = data.ageExact(idx);
% first.age           = data.age(idx);
% first.trialstart    = data.trialstart(idx);
% first.recip         = data.recip(idx);
% first.rawChoice     = data.rawChoice(idx);
% first.choice        = data.choice(idx);
% first.green         = data.green(idx);
% first.red           = data.red(idx);
% first.open          = data.open(idx);
% first.closed        = data.closed(idx);
% 
% save firsthalf_ORA first
% 
% idx = data.trial > 30
% second.subjid        = data.subjid(idx);
% second.trial         = data.trial(idx);
% second.gender        = data.gender(idx);
% second.ageExact      = data.ageExact(idx);
% second.age           = data.age(idx);
% second.trialstart    = data.trialstart(idx);
% second.recip         = data.recip(idx);
% second.rawChoice     = data.rawChoice(idx);
% second.choice        = data.choice(idx);
% second.green         = data.green(idx);
% second.red           = data.red(idx);
% second.open          = data.open(idx);
% second.closed        = data.closed(idx);
% 
% save secondhalf_ORA second

%analyze the data
load('estimates_firstHalfUncertainty_ORA.mat')
first = pars_est
load('estimates_secondHalfUncertainty_ORA.mat')
second = pars_est
load('agedata.mat')


%compute delta prior
deltaAlpha = first(:,3) - second(:,3);
deltaBeta = first(:,4) - second(:,4);

%correlations
[rho,pval] = corr(detaAlpha,Agedata(:,3));
[rho,pval] = corr(detaBeta,Agedata(:,3));

[rho,pval] = corr(first(:,3), second(:,3));
[rho,pval] = corr(first(:,4), second(:,4));

%paired non-parametric tests (wilcoxon signed-rank)
%alpha
[p,h,stats] = signrank(first(:,3), second(:,3))
median([first(:,3), second(:,3)])

%beta
[p,h,stats] = signrank(first(:,4), second(:,4))


diffsA = deltaAlpha
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
CI_lowerAIC = quantile(sum_boot, 0.025)
CI_upperAIC = quantile(sum_boot, 0.975)



%prior mean
firstmean = first(:,3)./(first(:,3) + first(:,4))
secondmean = second(:,3)./(second(:,3) + second(:,4))
deltamean = firstmean - secondmean