clear all; close all;
load('summaryORA3.mat')
data.ageGroup(data.age >0) = 1;
data.ageGroup(data.age >12) = 2;
data.ageGroup(data.age >16) = 3;
data.ageGroup(data.age >19) = 4;
data.ageGroup(data.age >21) = 5;
data.ageGroup = data.ageGroup';
alldata = data;

load estimates_EIGfull_ORA_20April2019.mat

m = 2;
T = 25;
recipvec = unique(data.recip);
lapse_est = 0;


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
    
    [mean_nsamp_data_subj mean_nsamp_model_subj] = deal(NaN(length(subjvec), length(recipvec)));

    nsims = 1000;
    figure;
    for subjidx = 1:length(subjvec)
        subjidx;
        subjid = subjvec(subjidx);
                 % Estimates
                pars_idx = find(pars_est(:,1) == subjid);
                beta1_est  = pars_est(pars_idx, 2);
                k_est      = pars_est(pars_idx, 3);
                alpha_0    = pars_est(pars_idx, 4); %replace priors with 1 for basic model
                beta_0     = pars_est(pars_idx, 5);

                DeltaQ = ComputeEIG_ORA(T, m, k_est, alpha_0, beta_0);
                prob_sample = 1./(1+exp(- beta1_est * DeltaQ));

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
    xlabel('Reciprocation probability'); ylabel('Number of samples');
    axis([-0.1 1.1 0 25]);
    title('Uncertainty model');
    set(gca,'xtick', recipvec);
    set(gca,'ytick', 0:5:25);

    thingsWithALegend = [];

    data_mean = squeeze(mean_nsamp_data(:));
    data_sem = squeeze(sem_nsamp_data(:));
    model_mean = squeeze(mean_nsamp_model(:));
    model_sem = squeeze(sem_nsamp_model(:));
    set(gca,'FontSize',30)
    X = [recipvec; flipud(recipvec)];
    Y = [data_mean + data_sem; flipud(data_mean - data_sem)];
    %fill(X,Y, color, 'FaceAlpha', 0.6, 'EdgeAlpha', 0); %colors and transparency
    Y = [model_mean + model_sem; flipud(model_mean - model_sem)];
    fill(X,Y, color, 'FaceAlpha', 0.6, 'EdgeAlpha', 0); %colors and transparency
    ebar = errorbar(recipvec, data_mean, data_sem, '-', 'LineWidth', 1.8);
    ebar.Color = 0.7 * color;
    ylim([0, 25]);
    %errorbar(recipvec, model_mean, model_sem, '.k', 'LineWidth', 1.2)
    grid off

end    