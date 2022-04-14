function NLL = mymodel_Hauser(pars, data)
k = pars(1); %beta0
beta1 = pars(2);
scaleFactor = pars(3);
slope = pars(4);
c = pars(5);
risk = 0;% pars(6); 
alphaPrior = pars(6);%1;
betaPrior = pars(7); %1;

lapse = 0;

NLL = 0;
m = 2;
T = 25;

        DeltaQ = computeDeltaQ_Optimal_Hauser(T, m, scaleFactor, slope, c, risk, alphaPrior, betaPrior);
        
        trialidx   = find(data.red + data.green < T);
        
        thistime   = data.red(trialidx) + data.green(trialidx) + 1;
        thischoice = data.choice(trialidx);
        
        linearidx           = sub2ind(size(DeltaQ), data.green(trialidx) + 1, thistime);
        DeltaQ_vectorized   = DeltaQ(:);
        
        % Log likelihood
        prediction = 1./(1+exp(- thischoice .* (beta1 * (DeltaQ_vectorized(linearidx) - k)))); %(beta0 + beta1 * DeltaQ_vectorized(linearidx))));
       % prediction = lapse * 0.5 + (1-lapse) * prediction;
        NLL = NLL - sum(log(prediction));