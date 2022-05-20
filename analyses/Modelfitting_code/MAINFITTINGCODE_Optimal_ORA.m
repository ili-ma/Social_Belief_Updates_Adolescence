% FITTING Sample cost model
clear all; close all
% %data
%  load('generated_Ksamples_modelRecovery_ORA.mat')

%generated data
load('generated_Optimal_modelRecovery_ORA.mat')
%load('generated_uncertainty_modelRecovery_ORA.mat')
%load('generated_DDM_modelRecovery_ORA.mat')


subjvec = unique(data.subjid);
numinit = 100; % Number of starting points for parameter fitting

for subjidx = 1:length(subjvec) % for generated data run 20 subjects
    subjidx
    idx = find(data.subjid == subjvec(subjidx));
    datasubj.red    = data.red(idx);
    datasubj.green  = data.green(idx);
    datasubj.choice = data.choice(idx);
    
    myNLL = @(pars) mymodel_Optimal_ORA(pars, datasubj);
    
    init        = NaN(numinit, 6); 
    init(:,1)   = rand(numinit,1) * -0.1;      %k
    init(:,2)   = randi(150, numinit,1) + 50;  %beta 0
    init(:,3)   = rand(numinit,1) * 0.1;       %cost
    init(:,4)   = rand(numinit,1) * 0.1;       %risk
    init(:,5)   = randn(numinit,1) + 1;        %Alphaprior
    init(:,6)   = randn(numinit,1) + 1;        %Betaprior
    
%     lowLimits =  [-1  10  0];
%     highLimits = [ 0  inf 10]; 
%     
%     lowLimits =  [-1  10  0  -1];
%     highLimits = [ 0  inf 10   1]; 
%     
    lowLimits =  [-1  10  0  -1  1   1];
    highLimits = [ 0  inf 5   1  26 26]; 
    
    for runidx = 1:numinit
        [pars_per_run(subjidx, runidx, :), NLL(runidx)] = fmincon(myNLL, init(runidx,:),[],[],[],[], lowLimits, highLimits, [], optimset('Display', 'off'));
    end
    NLL;
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
    
    myNLL = @(pars) mymodel_Optimal_ORA(pars, datasubj);
end

allbestNLL = [subjvec, allbestNLL']
pars_est = [subjvec, pars_est]

save "../Recoveries/estimate_generatedOptimal_recoveredOptimal_all" pars_est allbestNLL
%save estimates_allfitsoptimalPosBias_freePriors pars_per_run
writematrix(pars_est, "../Recoveries/estimate_generatedOptimal_recoveredOptimal_all.csv")
