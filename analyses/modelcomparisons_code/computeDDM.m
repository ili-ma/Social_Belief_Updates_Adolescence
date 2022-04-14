function U = computeDDM(T, m, k)

nOpen = repmat(0:T-1, T, 1);
nGreen = repmat((0:T-1)', 1, T);

U = k - abs(nOpen - 2 * nGreen);