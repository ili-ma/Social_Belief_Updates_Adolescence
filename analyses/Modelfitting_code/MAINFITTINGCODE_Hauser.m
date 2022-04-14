% FITTING
clear all; close all

% %Generated
% load('generated_Uncertainty_modelRecovery.mat')
% subjvec = 8001:8020;%max(data.subjid);

%symmetric
load('Summary_Semus_sym.mat')
data = Summary_Semus_sym;
subjvec = 4001:max(data.subjid);
subjvec = setdiff(subjvec, [4025 4027 4028 4039 4041]); %exclude in sym (include 4028 in analysis but not plot)

%%positive
% load('summaryNew.mat')
% subjvec = 1001:max(data.subjid);
% subjvec = setdiff(subjvec, [1007 1012 1019]); %exclude in asym pos

%negative
% load('summary_Neg.mat')
% subjvec = unique(data.subjid);
%subjvec = setdiff(subjvec, [5001 5005 5020 50202]); %exclude in asym pos

numinit = 100; % Number of starting points for parameter fitting

for subjidx = 1:length(subjvec)
    subjidx
    idx = find(data.subjid == subjvec(subjidx));
    datasubj.money  = data.money(idx);
    datasubj.social = data.social(idx);
    datasubj.red    = data.red(idx);
    datasubj.green  = data.green(idx);
    datasubj.choice = data.choice(idx);
    
    myNLL = @(pars) mymodel_Hauser(pars, datasubj);
    
    init        = NaN(numinit, 8); %n parameters
    init(:,1)   = rand(numinit,1) * -1; %k is negative. for the positive beta intercept use randn
    init(:,2)   = rand(numinit,1) * 30 + 20; %beta softmax
    init(:,3)   = rand(numinit,1) * 10 + 5; %scaleFactor
    init(:,4)   = rand(numinit,1) * 1 + 0.2; %slope
    init(:,5:8) = rand(numinit,4) * 25; %4 patience parameters
   % init(:,9)   = rand(numinit,1) * 2 - 1; % risk
    %init(:,10)   = randn(numinit,1) * 5 + 1; %Alphaprior
    %init(:,11)   = randn(numinit,1) * 5 + 1; %Betaprior
   % init(:,10)  = rand(numinit,1) * 0.1; %lapse, remove for free prior
    
    for runidx = 1:numinit
        %init(runidx,:)
        % pars volgorde: beta0, logbeta1, cost00, cost01, cost10, cost11
        % (code = costMoneySocial). last parameter = lowerbound. If only
        % interested in bestNll replace pars_per_run(runidx, :) by ~
       % [pars_per_run(subjidx, runidx, :), NLL(runidx)] = fmincon(myNLL, init(runidx,:),[],[],[],[], [-inf 0 0 0 -inf -inf -inf -inf -inf .1 .1],[10 inf inf inf inf inf inf inf inf inf inf], [], optimset('Display', 'off'));
        [pars_per_run(subjidx, runidx, :), NLL(runidx)] = fmincon(myNLL, init(runidx,:),[],[],[],[], [-inf 0 0 0 -inf -inf -inf -inf],[10 inf inf inf inf inf inf inf], [], optimset('Display', 'off'));
    end
    NLL
    [~, bestrun] = min(NLL); %probeer alle waarden op te slaan voor consistentie!
    %[fittedpars, bestNLL] = fmincon(myNLL, init(bestrun,:),[],[],[],[], [-inf 0 0 0 -inf -inf -inf -inf -inf .1 .1],[10 inf inf inf inf inf inf inf inf inf inf], [], optimset('Display', 'off'));
    [fittedpars, bestNLL] = fmincon(myNLL, init(bestrun,:),[],[],[],[], [-inf 0 0 0 -inf -inf -inf -inf],[10 inf inf inf inf inf inf inf], [], optimset('Display', 'off'));
    pars_est(subjidx,:) = fittedpars;
    allbestNLL(subjidx) = bestNLL;
    
end

for subjidx = 1:length(subjvec)
    subjidx
    idx = find(data.subjid == subjvec(subjidx));
    datasubj.money  = data.money(idx);
    datasubj.social = data.social(idx);
    datasubj.red    = data.red(idx);
    datasubj.green  = data.green(idx);
    datasubj.choice = data.choice(idx);
    
    myNLL = @(pars) mymodel_Hauser(pars, datasubj);
end


allbestNLL = [subjvec', allbestNLL']
pars_est = [subjvec', pars_est]

save ExtimatesHauserBasicModel pars_est allbestNLL
%save estimates_allfitsestimates_optimalNeg_29032018_k pars_per_run
