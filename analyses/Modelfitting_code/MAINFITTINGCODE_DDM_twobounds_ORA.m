% FITTING Threshold model two bounds
clear all; close all
%data
%load('summaryORA3.mat')

%generated data
%load('generated_Optimal_modelRecovery_ORA.mat')
 %load('generated_uncertainty_modelRecovery_ORA.mat')
load('generated_DDM_modelRecovery_ORA.mat')

subjvec = unique(data.subjid);
numinit = 100; % Number of starting points for parameter fitting


for subjidx = 1:length(subjvec)
    subjidx
    idx = find(data.subjid == subjvec(subjidx));
    datasubj.red    = data.red(idx);
    datasubj.green  = data.green(idx);
    datasubj.choice = data.choice(idx);
    
    myNLL = @(pars) mymodelDDM_twobounds_ORA(pars, datasubj);
    
    init         = NaN(numinit, 3);
    init(:,1)    = rand(numinit,1); %beta softmax
    init(:,2)    = randi(13, numinit,1); % positive bound
    init(:,3)    = randi(13, numinit,1); % negative bound
    
    lowLimits = [0 0 0];
    highLimits = [100 inf inf];
    
    for runidx = 1:numinit
        [pars_per_run(subjidx, runidx, :), NLL(runidx)] = fmincon(myNLL, init(runidx,:),[],[],[],[], lowLimits, highLimits, [], optimset('Display', 'off'));
    end
%     NLL
    [~, bestrun] = min(NLL);
    [fittedpars, bestNLL] = fmincon(myNLL, init(bestrun,:),[],[],[],[], lowLimits, highLimits, [], optimset('Display', 'off'));
    
    pars_est(subjidx,:) = fittedpars;
    allbestNLL(subjidx) = bestNLL;
    
end

for subjidx = 1:length(subjvec)
    subjidx
    idx = find(data.subjid == subjvec(subjidx));
    datasubj.red    = data.red(idx);
    datasubj.green  = data.green(idx);
    datasubj.choice = data.choice(idx);
    
    myNLL = @(pars) mymodelDDM_twobounds_ORA(pars, datasubj);
end

% allbestNLL = [subjvec, allbestNLL']
% pars_est = [subjvec, pars_est]
allbestNLL =  allbestNLL'

save estimates_generatedDDM_recoveredDDM_all pars_est allbestNLL
writematrix(pars_est, "estimates_generatedDDM_recoveredDDM_all.csv")
