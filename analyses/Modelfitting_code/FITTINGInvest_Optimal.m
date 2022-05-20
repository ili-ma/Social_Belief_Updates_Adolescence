% This script fits the Sample Cost Model invest choices

load('summaryORA3.mat'); 
load ('estimates_optimalFull_ORA3_19March2019.mat');

subjvec = unique(data.subjid);
numinit = 100; % Number of starting points for parameter fitting

for subjidx = 1:length(subjvec)
    subjectNr = subjvec(subjidx);
    [subjidx, subjectNr]
    
    datasubj = subjectData(subjectNr, data);
    pars_est_row = pars_est(:,1) == subjectNr;
    pars_est_subj = pars_est(pars_est_row, :);
    
    myNLL = @(pars) investSoftmaxNlloptimal(datasubj, pars_est_subj, pars);    
    init        = NaN(numinit, 2); %
    init(:,1)   = rand(numinit,1); %softmax intercept
    init(:,2)   = rand(numinit,1) * 10; %beta softmax (comment for null model)
    
    for runidx = 1:numinit
       [softmax_pars_per_run(subjidx, runidx, :), NLL(runidx)] = fmincon(myNLL, init(runidx,:),[],[],[],[], [-inf -inf],[inf inf], [], optimset('Display', 'off')); 
    end
    [~, bestrun] = min(NLL); 
    [fittedpars, bestNLL] = fmincon(myNLL, init(bestrun,:),[],[],[],[], [-inf -inf],[inf inf], [], optimset('Display', 'off'));
    fittedpars
    
    softmax_pars_est(subjidx,:) = fittedpars;
    softmax_bestNLL(subjidx) = bestNLL;
end

softmax_bestNLL = [subjvec, softmax_bestNLL']
softmax_pars_est = [subjvec, softmax_pars_est]

save invest_Optimal_ORA3 softmax_pars_est softmax_bestNLL

