% Compute information gain. A high loss of entropy (delta E is very low) means you
% gain a lot of information. Stop sampling when you gain little information.
function U = ComputeEIG_ORA(T, m, k, alpha_0, beta_0)
    entropy = computeEntropy(T + 1, alpha_0, beta_0);
    U = deal(NaN(T,T));
    for t = 1:T
        alpha = (0:t-1)' + alpha_0;
        beta = (t-1:-1:0)' + beta_0;
        pPos = alpha ./ (alpha + beta);
        pNeg = 1 - pPos;
        expectedEntropy = pPos .* entropy(2:t+1, t+1) + pNeg .* entropy(1:t, t+1);
        % expectedEntropy - entropy is delta E, or entropy loss.
        % Flipping the sign means the interpretation becomes information
        % gain and k is positive meaning the minimum wanted gain.
        U(1:t,t) = -(expectedEntropy - entropy(1:t, t)) - k;
    end
end

% Compute entropy of beta distribution. Entropy is negative.
% 0 is low informatin to -Inf is high information.
function E = computeEntropy(T, alpha_0, beta_0)
    E = deal(NaN(T,T));
    for t = T:-1:1
        alpha = (0:t-1)' + alpha_0;
        beta = (t-1:-1:0)' + beta_0;

        B = (gamma(alpha).* gamma(beta))./ gamma(alpha+beta);

        E(1:t,t) = log(B) - (alpha-1).* psi(alpha) - (beta-1).* psi(beta) + (alpha+beta-2).* psi(alpha+beta);
    end
end