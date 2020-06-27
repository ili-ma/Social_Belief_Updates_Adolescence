% Alternative "heuristics" model. This assumes that people stop
% sampling as soon as the posterior width (the standard deviation of the beta distribution) has reached a criterion k.
% If U is positive, keep sampling. If U is negative stop sampling.
% Stop samping when you have k_pos more green than red or k_neg more red than green

function [U, Gradient] = computeCount_twobounds_collapse(T, k_pos, k_neg, collapse)

nOpen = repmat(0:T, T + 1, 1);
nGreen = repmat((0:T)', 1, T + 1);
diff = 2 * nGreen - nOpen;
collapseTable = exp(-collapse * nOpen);
distToK_pos = k_pos * collapseTable - diff;
U = min(distToK_pos, k_neg * collapseTable + diff);
% The gradient has to include the end state after the last sample
% has been drawn, but U must not include it because U is about
% taking samples which is impossible in a completely opened field.
U = U(1:T, 1:T);
% This table holds the gradient between the borders.
% Exactly at k_neg (adjusted by collapse) the gradient is 0.
% Exactly at k_pos (adjusted by collapse) the gradient is 1.
% Beyond this range the values are extrapolated.
Gradient = 1 - (distToK_pos ./ ((k_pos + k_neg) * collapseTable));