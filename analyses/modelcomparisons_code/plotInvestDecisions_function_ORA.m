function [binCentersPp, binProportionsPp, pInvestsFromModel, ages] = plotInvestDecisions_function_ORA(data, pars_est, softmax_pars_est, nBins)
	if ~isfield(data, 'rawChoice')
		disp('data does not have the rawChoice field. Can''t plot data');
		return;
	end
	% Excluded participant list
	exclude = [];
	subjects = setdiff(unique(data.subjid), exclude);
	nSubjects = size(pars_est, 1);
	T = 25;
	m = 2;
	% We sort the actually occuring deltaUs from the data and cut them up in
	% the required amount of bins, then compute the centers
	binCentersPp = NaN(nSubjects, nBins);
	% The proportion of invest choices for a given bin
	binProportionsPp = NaN(nSubjects, nBins);
	pInvestsFromModel = NaN(nSubjects, nBins);
	ages = NaN(nSubjects, nBins);
	% Each subject has their own priors and risk aversion, so to interpret the data we have to go subject by subject
	for subjIdx = 1:nSubjects
		%!!!!!!!!!! Collect subbject information DIFFERENT PARS FOR HEURISTIC AND OPTIMAL
		subjectNr = subjects(subjIdx);
		ages(subjIdx, :) = data.ageExact(find(data.subjid == subjectNr, 1));
		risk = 0;
		alpha_prior = pars_est(subjIdx, 4);
		beta_prior = pars_est(subjIdx, 5);

		b0s = softmax_pars_est(subjIdx, 2);
		b1s = softmax_pars_est(subjIdx, 3);

		DeltaUtable = computeDeltaUtable(T, m, alpha_prior, beta_prior, risk);
		choiceIdx = data.rawChoice ~= 0 & data.subjid == subjectNr;
		nGoods = data.green(choiceIdx);
		nOpens = nGoods + data.red(choiceIdx);
		dus = DeltaUtable(sub2ind(size(DeltaUtable), nGoods + 1, nOpens + 1));
		choices = data.rawChoice(choiceIdx);
		invests = 0.5 * (choices + 1);
		% Put the invest data in a table with accompanying deltaU
		investTable = [dus invests];
		% Sort them on delta u
		investTable = sortrows(investTable, 1);
		% fill the center- and proportions table
		binSize = ceil(size(investTable, 1) / nBins);
		for binNr = 1:nBins
			first = (binNr - 1) * binSize + 1;
			last = min(binNr * binSize, size(investTable, 1));
			binCentersPp(subjIdx, binNr) = mean(investTable(first:last, 1));
			binProportionsPp(subjIdx, binNr) = mean(investTable(first:last, 2));
			pInvestsFromModel(subjIdx, binNr) = mean(1 ./ (1 + exp(-b0s - b1s * investTable(first:last, 1))));
		end
	end
end
