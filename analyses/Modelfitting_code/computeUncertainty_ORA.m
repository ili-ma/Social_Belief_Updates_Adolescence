function U = computeUncertainty_ORA(T, m, k, alpha_0, beta_0)

U = deal(NaN(T,T));

for t = T:-1:1
    alpha = (0:t-1)' + alpha_0;
    beta = (t-1:-1:0)' + beta_0;

    stDev = sqrt(alpha .* beta./((alpha + beta).^2 .*(alpha + beta + 1))); 
    
    U(1:t,t) = stDev - k;
end