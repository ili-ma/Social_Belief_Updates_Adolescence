% This script fits the Threshold model invest data

clear; close all
load('summaryORA3.mat');
load estimates_DDMTwobounds_ORA3_19March2019

subjvec = unique(data.subjid);
nSubjects = length(subjvec);

nParameters = 2;
numinit = 100; % Number of starting points for parameter fitting

softmax_pars_per_run = NaN(nSubjects, numinit, 2);
NLL = NaN(1, numinit);
softmax_pars_est = NaN(nSubjects, nParameters);
softmax_bestNLL = NaN(nSubjects, 1);

for subjidx = 1:nSubjects
    subjectNr = subjvec(subjidx);
    [subjidx, subjectNr]
    
    % Select only the data for the current subject
    datasubj = subjectData(subjectNr, data);
    
    myNLL = @(pars) investDDMSoftmaxNLL(datasubj, pars);
    
    init        = NaN(numinit, 1); %
    init(:,1)   = rand(numinit,1) * 2 - 1; %softmax intercept
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

softmax_bestNLL = [subjvec, softmax_bestNLL]
softmax_pars_est = [subjvec, softmax_pars_est]

save invest_DDM_ORA softmax_pars_est softmax_bestNLL

