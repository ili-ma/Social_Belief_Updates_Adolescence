% FITTING Threshold model two collapsing bounds
clear; close all

load('generated_Ksamples_modelRecovery_ORA.mat')
subjvec = unique(data.subjid);
numinit = 100; 

for subjidx = 1:length(subjvec)
    subjidx
    idx = find(data.subjid == subjvec(subjidx));
    datasubj.red    = data.red(idx);
    datasubj.green  = data.green(idx);
    datasubj.choice = data.choice(idx);
    
    myNLL = @(pars) mymodelDDM_twobounds_collapse_ORA(pars, datasubj);
    
    init       = NaN(numinit, 3); % parameters
    init(:,1)  = rand(numinit,1); %beta softmax
    init(:,2)  = randi(13, numinit,1);
    init(:,3)  = randi(13, numinit,1);
    %init(:,4)  = -rand(numinit,1) * 0.001;
    
    %lowLimits = [0 0 0 -1];
    %highLimits = [100 inf inf 0];
    lowLimits = [0 0 0];
    highLimits = [100 inf inf];
    
    for runidx = 1:numinit
        [pars_per_run(subjidx, runidx, :), NLL(runidx)] = fmincon(myNLL, init(runidx,:),[],[],[],[], lowLimits, highLimits, [], optimset('Display', 'off'));
    end
    NLL
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
    
    myNLL = @(pars) mymodelDDM_twobounds_collapse_ORA(pars, datasubj);
end

allbestNLL = [subjvec, allbestNLL']
pars_est = [subjvec, pars_est]

save estimate_Recovery_Ksamples_Threshold_23July2021 pars_est allbestNLL
%save estimates_allfitsoptimalPosBias_freePriors pars_per_run
