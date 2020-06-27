
function U = computeDDM_collapse_ORA(T, m, k, collapse)

nOpen = repmat(0:T-1, T, 1);
nGreen = repmat((0:T-1)', 1, T);

U = k * exp(collapse*(T-nOpen)) - abs(nOpen - 2 * nGreen);
