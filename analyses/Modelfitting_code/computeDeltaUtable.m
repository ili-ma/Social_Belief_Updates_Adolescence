function DeltaU = computeDeltaUtable(T, m, alpha_0, beta_0, risk)
    U1 = NaN(T+1,T+1);

    % Value of end state (t = T + 1)
    for t = 1:T+1
        openSquares = t - 1;
        nPos  = (0:openSquares)';
        nNeg  = openSquares - nPos;
        alpha = alpha_0 + nPos;
        beta  = beta_0  + nNeg;
        alpha_plus_beta = openSquares + alpha_0 + beta_0;

        U1_term1    = m * alpha / alpha_plus_beta;
        U1_term2    = m * beta  / alpha_plus_beta .* U1_term1; % 
        U1(1:t, t)  = U1_term1 - risk * U1_term2; % SD instead of variance
    end
    % U0 is per definition always 1
    DeltaU = U1 - 1;
end