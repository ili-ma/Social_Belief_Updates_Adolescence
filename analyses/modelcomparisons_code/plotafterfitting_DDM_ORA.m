clear all; close all;
load('summaryORA_prepped.mat')
load .mat
subjvec = unique(data.subjid);

m = 2;
T = 25;
recipvec = unique(data.recip);
lapse_est = 0;


[mean_nsamp_data_subj mean_nsamp_model_subj] = deal(NaN(length(subjvec), length(recipvec)));

nsims = 1000;
figure;
for subjidx = 1:length(subjvec)
    subjidx;
             % Estimates
            beta1_est            = pars_est(subjidx, 2);
            k_est                = pars_est(subjidx, 3);
            %collapse_est         = pars_est(subjidx, 6);
           % priorDifference_est = pars_est(subjidx, 6);
            DeltaQ = computeDDM(T, m, k_est); % model specification computeCount_collapsingbound(T, m, k_est, collapse_est);
            beta1_est
            k_est
            prob_sample = 1./(1+exp(- beta1_est * DeltaQ))
            
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
title('DDM basic');
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
%errorbar(recipvec, model_mean, model_sem, '.k', 'LineWidth', 1.2)
grid off

    