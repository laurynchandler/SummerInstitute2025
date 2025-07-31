%%%% Fit learning rates to reaction times.
% If 'models' specified, just compute model evidence
%%%% INPUTS
% datadir: directory where data are stored
% submat: individual subject data
%%%% OUTPUTS
% models: a fitted model ?

%% load in data
if (~exist('datadir', 'var'))
    datadir='data/';
end

% load in everyone's data
behav_data = readtable([datadir 'learning.csv']);

% define output directory
outdir = 'fits/';

% create table to store results
nrow = length(unique(behav_data.subID));
fits = table(NaN([nrow 1]), NaN([nrow 1]), NaN([nrow 1]), ...
    'variableNames', {'subID', 'fitted_alpha', '-loglikelihood'});

%% define optimization preferences
warning off all
options  = optimset('Algorithm', 'interior-point', 'MaxFunEvals', 1e5, 'MaxIter', 1e5, ...
    'display', 'notify', 'Diagnostics', 'off');

% step size during optimization
gridstep = 0.05;
search_space  = [-1-gridstep 1+gridstep];     % initial values for the model parameters

%% iterate through subjects
for sub = unique(behav_data.subID)'

    % subset to just this subject's data
    sub_data = behav_data(behav_data.subID == sub, :);
    sub_data = sub_data(~isnan(sub_data.imgLockedRT), :);
    fits.subID(sub) = sub;
    loglikelihood = Inf;

    % define anonymous function for estimating alpha jointly using RTs & observed transitions
    thisfit = @(x) fit_function('generate_regressors_simpleRW', sub_data, x);
    disp(['Fitting subject ' num2str(sub) '...']);

    % search through parameter space
    for k = min(search_space):gridstep:max(search_space)
        alpha = k;
        try
            [temp_best_params, temp_loglik] = fmincon(thisfit, alpha, [], [], [], [], -Inf, Inf, [], options);
        catch xcept
            disp('fmincon error');
            xcept
            temp_best_params = alpha;
            temp_loglik = loglikelihood;
        end
        if (temp_loglik < loglikelihood-(1e-32))
            %temp_best_params(1) = 1./(1 + exp(-temp_best_params(1));            % Convert omega to alpha
            disp(['Subject ' num2str(sub) ', new best parameters: ' num2str(temp_best_params)]);
            fits.fitted_alpha(sub) = temp_best_params;
            fits.("-loglikelihood")(sub) = temp_loglik;
            %temp_loglik
        end
    end
end % for each subject

%% tidy & write out fits
fits = rmmissing(fits);
writetable(fits, 'first_fits.csv');