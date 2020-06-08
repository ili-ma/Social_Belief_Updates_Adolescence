function NLL = mymodel_Optimal_ORA(pars, data)
k       = pars(1);
beta1   = pars(2);
c       = pars(3);
risk    = pars(4); 
alpha_0 = pars(5);
beta_0  = pars(6); 

NLL = 0;
m = 2;
T = 25;

        DeltaQ = computeDeltaQ_Optimal_ORA(T, m, c, risk, alpha_0, beta_0);
        
        trialidx   = find(data.red + data.green < T);
        
        thistime   = data.red(trialidx) + data.green(trialidx) + 1;
        thischoice = data.choice(trialidx);
        
        linearidx           = sub2ind(size(DeltaQ), data.green(trialidx) + 1, thistime);
        DeltaQ_vectorized   = DeltaQ(:);
        
        % Log likelihood
        prediction = 1./(1+exp(- thischoice .* (beta1 * (DeltaQ_vectorized(linearidx) - k)))); 
        NLL = NLL - sum(log(prediction));
