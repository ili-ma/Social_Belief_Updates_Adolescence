% FITTING Count model
clear all; close all

load('summaryORA3.mat')
% load('generated_DDM_modelRecovery_ORA.mat')

%%generated data
 %load('generated_Optimal_modelRecovery_ORA.mat')
 %load('generated_uncertainty_modelRecovery_ORA.mat')
 %load('generated_DDM_modelRecovery_ORA.mat')
 %load('generated_Ksamples_modelRecovery_ORA.mat')

subjvec = unique(data.subjid);
numinit = 100; 


for subjidx = 1:length(subjvec) % 20 for generated data
    subjidx
    idx = find(data.subjid == subjvec(subjidx));
    datasubj.red    = data.red(idx);
    datasubj.green  = data.green(idx);
    datasubj.choice = data.choice(idx);
    
    myNLL = @(pars) mymodelKSamples_ORA(pars, datasubj);

    init         = NaN(numinit, 2); % nr of parameters 
    init(:,1)    = rand(numinit, 1) * 2; %beta softmax
    init(:,2)    = randi(25, numinit, 1); % criterion
    
    lowLimits =  [0   0];
    highLimits = [5  25];
    
    for runidx = 1:numinit
        [pars_per_run(subjidx, runidx, :), NLL(runidx)] = fmincon(myNLL, init(runidx,:),[],[],[],[], lowLimits, highLimits, [], optimset('Display', 'off'));
    end
    [bestNLL, bestrun] = min(NLL);
    pars_est(subjidx,:) = pars_per_run(subjidx, bestrun,:);
    allbestNLL(subjidx) = bestNLL;
end

% allbestNLL = [subjvec, allbestNLL']
% pars_est = [subjvec, pars_est]
allbestNLL = allbestNLL';

save '../modelcomparisons_code/estimates_KSamples_ORA3_06Feb2022' pars_est allbestNLL
% writematrix(pars_est, '../modelcomparisons_code/estimates_KSamples_ORA3_13Jan2022.csv')
% save '../Recoveries/estimates_generatedDDM_recoveredKsamples' pars_est allbestNLL
%writematrix(pars_est, '../Recoveries/estimates_generatedUncertainty_recoveredKsamples_all.csv')
