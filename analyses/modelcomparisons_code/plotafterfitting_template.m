function plotafterfitting_template(data_filename, prob_function, plot_title)
	load('summaryORA3.mat')
	data.ageGroup(data.age >   0) = 1;
	data.ageGroup(data.age >= 13) = 2;
	data.ageGroup(data.age >= 16) = 3;
	data.ageGroup(data.age >= 19) = 4;
	data.ageGroup(data.age >= 21) = 5;
	data.ageGroup = data.ageGroup';
	alldata = data;
	ageLabels = {"10 - 12 years", "13 - 15 years", "16 - 18 years", "19 - 21 years", "21 - 24 years"};

	load(data_filename)

	m = 2;
	T = 25;
	recipvec = unique(data.recip);
	lapse_est = 0;

	figure('Position', [10, 120, 1600, 300]);
	for ageGroup = 1:5
		data = struct();
		idx = alldata.ageGroup == ageGroup;
		data.subjid  = alldata.subjid(idx);
		data.trial   = alldata.trial(idx);
		data.recip   = alldata.recip(idx);
		data.choice  = alldata.choice(idx);
		data.green   = alldata.green(idx);
		data.red     = alldata.red(idx);
		data.open    = alldata.open(idx);
		data.closed  = alldata.closed(idx);
		
		subjvec = unique(data.subjid);
		
		[mean_nsamp_data_subj, mean_nsamp_model_subj] = deal(NaN(length(subjvec), length(recipvec)));

		subplot(1, 5, ageGroup);
		nsims = 1000;
		for subjidx = 1:length(subjvec)
			subjid = subjvec(subjidx);
			prob_sample = prob_function(pars_est, subjid);

			for recipidx = 1:length(recipvec)
				recip = recipvec(recipidx);

				nsamp = NaN(nsims,1);
				for i = 1: nsims
					decisionmade = 0;
					ngreen = 0;
					nred = 0;
					while decisionmade == 0 & (ngreen + nred < T)
						if rand < lapse_est
							decidetosample = rand < 0.5;
						else
							decidetosample = rand < prob_sample(ngreen + 1, ngreen + nred + 1);
						end

						if decidetosample == 0
							decisionmade = 1;
						else
							samplegood   = rand < recip;
							ngreen = ngreen + samplegood;
							nred = nred + (1-samplegood);
						end

					end
					nsamp(i) = ngreen + nred;
				end

				mean_nsamp_model_subj(subjidx, recipidx) = mean(nsamp);
			end
		end

		% Number of samples from the data
		for subjidx = 1:length(subjvec)
			subject = subjvec(subjidx);
			for recipidx = 1:length(recipvec)
				recip = recipvec(recipidx);
				idx = find(data.subjid == subject & data.recip == recip & (data.closed > 0));
				trialstarttimes = [find(data.red(idx) + data.green(idx) == 0); length(idx) + 1];
				mean_nsamp_data_subj(subjidx, recipidx) = mean(diff(trialstarttimes)-1);
			end
		end

		mean_nsamp_data = squeeze(mean(mean_nsamp_data_subj, 1));
		sem_nsamp_data = squeeze(std(mean_nsamp_data_subj,[],1))/sqrt(length(subjvec));

		mean_nsamp_model = squeeze(mean(mean_nsamp_model_subj, 1));
		sem_nsamp_model = squeeze(std(mean_nsamp_model_subj,[],1))/sqrt(length(subjvec));

		% Plot number of samples as a function of reciprocation probability per
		% cost condition.  Line and errorbar is data. Shaded regions is model
		% prediction.
		color = [0, 0.2, 0.5];

		hold on;
		xlabel('Reciprocation probability'); ylabel('Samples');
		axis([-0.1 1.1 0 25]);
		title(ageLabels{ageGroup});
		set(gca,'xtick', recipvec);
		set(gca,'ytick', 0:5:25);

		data_mean = squeeze(mean_nsamp_data(:));
		data_sem = squeeze(sem_nsamp_data(:));
		model_mean = squeeze(mean_nsamp_model(:));
		model_sem = squeeze(sem_nsamp_model(:));
		set(gca,'FontSize', 12)
		X = [recipvec; flipud(recipvec)];
		Y = [data_mean + data_sem; flipud(data_mean - data_sem)];
		%fill(X,Y, color, 'FaceAlpha', 0.6, 'EdgeAlpha', 0); %colors and transparency
		Y = [model_mean + model_sem; flipud(model_mean - model_sem)];
		fill(X,Y, color, 'FaceAlpha', 0.6, 'EdgeAlpha', 0); %colors and transparency
		ebar = errorbar(recipvec, data_mean, data_sem, '-', 'LineWidth', 1.8);
		ebar.Color = 0.7 * color;
		ylim([8, 25]);
		%errorbar(recipvec, model_mean, model_sem, '.k', 'LineWidth', 1.2)
		grid off

	end
	sgtitle(plot_title);
end
