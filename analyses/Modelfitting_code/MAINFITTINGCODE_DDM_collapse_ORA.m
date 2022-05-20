% FITTING Threshold model collapsing bounds
clear all; close all

load('summaryORA3.mat')
subjvec = unique(data.subjid);

numinit = 100; % Number of starting points for parameter fitting

for subjidx = 1:length(subjvec)
    subjidx
    idx = find(data.subjid == subjvec(subjidx));
    datasubj.red    = data.red(idx);
    datasubj.green  = data.green(idx);
    datasubj.choice = data.choice(idx);
    
    myNLL = @(pars) mymodelDDM_collapse_ORA(pars, datasubj);
    
    init         = NaN(numinit, 3);
    init(:,1)    = rand(numinit,1); %beta softmax
    init(:,2)    = randi(13, numinit,1); % bound
    init(:,3)    = -rand(numinit,1); % collapse rate
    
    lowLimits = [0 0 -1];
    highLimits = [100 inf 0];
    
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
    
    myNLL = @(pars) mymodelDDM_collapse_ORA(pars, datasubj);
end

allbestNLL = [subjvec, allbestNLL']
pars_est = [subjvec, pars_est]

save estimates_DDMcollapse_ORA3_19March2019 pars_est allbestNLL

