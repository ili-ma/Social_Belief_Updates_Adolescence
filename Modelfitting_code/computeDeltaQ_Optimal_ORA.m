function [DeltaQ, V, VS] = computeDeltaQ_Optimal_ORA(T, m, c, risk, alpha_0, beta_0)

%% Initializations

% VS is the value of a sample
[Q0, Q1, VS] = deal(NaN(T,T));
V = NaN(T+1,T+1);

% Value of end state (t = T + 1)
t           = T + 1;
openSquares = t - 1;
nPos        = (0:openSquares)';
nNeg        = openSquares - nPos;
alpha       = alpha_0 + nPos;
beta        = beta_0  + nNeg;

U0          = 1;
U1_term1    = m .* alpha./(alpha+beta);
U1_term2    = m^2 .* alpha .* beta./(alpha+beta).^2;
U1          = U1_term1 - risk * U1_term2; 

V(:,T+1) = max(U0, U1);  % value of state alpha at time T+1

% Bellman: going back from time T to time 1
for t = T:-1:1
    openSquares = t - 1;
    nPos  = (0:openSquares)';
    nNeg  = openSquares - nPos;
    alpha = alpha_0 + nPos;
    beta  = beta_0  + nNeg;
    
    % If not sampling but deciding
    U0          = 1; % utility of not investing
    U1_term1    = m .* alpha./(alpha+beta);
    U1_term2    = m^2 .* alpha .* beta./(alpha+beta).^2; 
    U1          = U1_term1 - risk * U1_term2; 
    Q0(1:t,t)   = max(U0, U1); % utility of making an investment decision now
    
    % If continuing to sample
    pPos        = alpha./(alpha + beta);
    pNeg        = 1 - pPos;
    VS(1:t,t)   = pPos .* V(nPos + 2, t+1) + pNeg .* V(nPos + 1, t+1);
    Q1(1:t,t)   = VS(1:t,t) - (c/120);
    V(1:t,t)    = max(Q0(1:t,t),Q1(1:t,t));
end
DeltaQ = Q1-Q0;
