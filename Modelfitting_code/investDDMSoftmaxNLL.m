function nll = investDDMSoftmaxNLL(investData, softmaxPars)
    % Compute the likelihood of each investment decision
    % investdata.rawChoice should be 1 for invest and -1 for not invest
    intercept = softmaxPars(1);
    slope = softmaxPars(2);
    
    choiceMoments = investData.rawChoice ~= 0;
    choices = investData.rawChoice(choiceMoments);
    diff = investData.green(choiceMoments) - investData.red(choiceMoments);
    
    pInvest = (1 ./ (1 + exp(-slope * (diff - intercept))));
    pActualDecision = (choices < 0) + choices .* pInvest;
    pActualDecision(pActualDecision == 0) = realmin;
    
    nll = -sum(log(pActualDecision));
end