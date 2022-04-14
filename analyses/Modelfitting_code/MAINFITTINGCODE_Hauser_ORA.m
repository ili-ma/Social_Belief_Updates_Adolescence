% FITTING
clear all; close all

%data
load('summaryORA3.mat')

subjvec = unique(data.subjid);
numinit = 100;  % Number of starting points for parameter fitting

for subjidx = 1:length(subjvec)
    subjidx
    idx = find(data.subjid == subjvec(subjidx));
    datasubj.red    = data.red(idx);
    datasubj.green  = data.green(idx);
    datasubj.choice = data.choice(idx);
    
    myNLL = @(pars) mymodel_Hauser(pars, datasubj);
    
    init        = NaN(numinit, 7); %n parameters
    init(:,1)   = rand(numinit,1) * -1; %k is negative. for the positive beta intercept use randn
    init(:,2)   = rand(numinit,1) * 30 + 20; %beta softmax
    init(:,3)   = rand(numinit,1) * 10 + 5; %scaleFactor
    init(:,4)   = rand(numinit,1) * 1 + 0.2; %slope
    init(:,5)   = rand(numinit,1) * 25; % patience parameter
    %init(:,6)   = rand(numinit,1) * 2 - 1; % risk
    init(:,6)   = randn(numinit,1) * 5 + 1; %Alphaprior
    init(:,7)   = randn(numinit,1) * 5 + 1; %Betaprior
   % init(:,10)  = rand(numinit,1) * 0.1; %lapse, remove for free prior
    
    for runidx = 1:numinit
        %init(runidx,:)
        % pars volgorde: beta0, logbeta1, cost00, cost01, cost10, cost11
        % (code = costMoneySocial). last parameter = lowerbound. If only
        % interested in bestNll replace pars_per_run(runidx, :) by ~
        [pars_per_run(subjidx, runidx, :), NLL(runidx)] = fmincon(myNLL, init(runidx,:),[],[],[],[], [-inf 0 0 0 -inf 1 1],[10 inf inf inf inf inf inf], [], optimset('Display', 'off'));
       % [pars_per_run(subjidx, runidx, :), NLL(runidx)] = fmincon(myNLL, init(runidx,:),[],[],[],[], [-inf 0 0 0 -inf],[10 inf inf inf inf], [], optimset('Display', 'off'));
    end
    NLL
    [~, bestrun] = min(NLL); %probeer alle waarden op te slaan voor consistentie!
    %[fittedpars, bestNLL] = fmincon(myNLL, init(bestrun,:),[],[],[],[], [-inf 0 0 0 -inf -inf -inf -inf -inf .1 .1],[10 inf inf inf inf inf inf inf inf inf inf], [], optimset('Display', 'off'));
    [fittedpars, bestNLL] = fmincon(myNLL, init(bestrun,:),[],[],[],[], [-inf 0 0 0 -inf 1 1],[10 inf inf inf inf inf inf], [], optimset('Display', 'off'));
    pars_est(subjidx,:) = fittedpars;
    allbestNLL(subjidx) = bestNLL;
    
end

for subjidx = 1:length(subjvec)
    subjidx
    idx = find(data.subjid == subjvec(subjidx));
    datasubj.red    = data.red(idx);
    datasubj.green  = data.green(idx);
    datasubj.choice = data.choice(idx);
    
    myNLL = @(pars) mymodel_Hauser(pars, datasubj);
end


allbestNLL = [subjvec, allbestNLL']
pars_est = [subjvec, pars_est]

save EstimatesHauserfullModel_ORA_NoRisk pars_est allbestNLL
%save estimates_allfitsestimates_optimalNeg_29032018_k pars_per_run
