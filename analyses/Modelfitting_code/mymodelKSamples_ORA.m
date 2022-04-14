function NLL = mymodelKSamples_ORA(pars, data)
	T     = 25;
	m     = 2;
	beta1 = pars(1);
	k     = pars(2);

	trialidx   = find(data.red + data.green < T);
	thistime   = data.red(trialidx) + data.green(trialidx) + 1;
	thischoice = data.choice(trialidx);
	usedQ = k + 1 - thistime;

	% DeltaQ = computeKsamplesinSoftmax_ORA(T, m, k);
	% linearidx           = sub2ind(size(DeltaQ), data.green(trialidx) + 1, thistime);
	% DeltaQ_vectorized   = DeltaQ(:);
	% usedQ = DeltaQ_vectorized(linearidx)

	% Log likelihood
	prediction = 1 ./ (1 + exp(- thischoice .* (beta1 * usedQ)));
	NLL = -sum(log(prediction));
end
