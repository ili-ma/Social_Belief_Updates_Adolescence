function NLL = mymodelDDM_twobounds_collapse_ORA(pars, data)
beta1    = pars(1);
k_pos    = pars(2);
k_neg    = pars(3);
collapse = pars(4);

NLL = 0;
T = 25;

        DeltaQ = computeCount_twobounds_collapse(T, k_pos, k_neg, collapse);
        trialidx   = find(data.red + data.green < T);
        
        thistime   = data.red(trialidx) + data.green(trialidx) + 1;
        thischoice = data.choice(trialidx);
        
        linearidx           = sub2ind(size(DeltaQ), data.green(trialidx) + 1, thistime);
        DeltaQ_vectorized   = DeltaQ(:);
        
        % Log likelihood
        prediction = 1./(1+exp(- thischoice .* (beta1 * DeltaQ_vectorized(linearidx))));
        NLL = NLL - sum(log(prediction)); 
    

