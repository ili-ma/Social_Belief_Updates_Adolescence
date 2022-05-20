% Fitting Uncertainty model
clear all; close all
%%data
load('summaryORA3.mat')

%%firsthalf
%load('secondhalf_ORA.mat')
%data = second

%%generated data
 %load('generated_Optimal_modelRecovery_ORA.mat')
 %load('generated_uncertainty_modelRecovery_ORA.mat')
 %load('generated_DDM_modelRecovery_ORA.mat')

subjvec = unique(data.subjid);
numinit = 100; 


for subjidx = 1:length(subjvec) % 20 for generated data
    subjidx
    idx = find(data.subjid == subjvec(subjidx));
    datasubj.red    = data.red(idx);
    datasubj.green  = data.green(idx);
    datasubj.choice = data.choice(idx);
    
    myNLL = @(pars) mymodelUncertainty_ORA(pars, datasubj);

    init         = NaN(numinit, 4); % nr of parameters 
    init(:,1)    = randi(150, numinit,1); %beta softmax
    init(:,2)    = rand(numinit,1); % criterion
    init(:,3)     = rand(numinit,1) + 1; %Alphaprior
    init(:,4)     = rand(numinit,1) + 1; %Betaprior

%a = 20; b = 70; r = (b-a).*rand(10,1) + a

% 
%     % without prior
%     lowLimits = [0 0];
%     highLimits = [inf 1];
    
    lowLimits =  [0   0 1  1 ];
    highLimits = [inf 1 inf inf];
    
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
    
    myNLL = @(pars) mymodelUncertainty_ORA(pars, datasubj);
end

% allbestNLL = [subjvec, allbestNLL']
% pars_est = [subjvec, pars_est]
allbestNLL =  allbestNLL'
save estimates_uncertaintyFull3_ORA_20March2019 pars_est allbestNLL

