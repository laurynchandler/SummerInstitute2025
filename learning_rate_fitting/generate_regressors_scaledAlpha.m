function [regressor_matrix, prediction_errors]=generate_regressors_scaledAlpha(sub_data, params)
%%%% INPUTS:
% sub_data: a single subject's data from learning
% params: list of values to be optimized
%%%% OUTPUTS
% regressor matrix: variables to use as regressors when fitting trial-level RTs
% prediction errors: the inferred prediction error on each trial

%% set up matrices to store variables
maxTrials = height(sub_data);
transition_matrix = ones(3, 2)*0.5; % rows correspond to cues, columns to targets
counter_matrix = zeros(3, 2); % stores the number of times each outcome is observed for each cue
prediction_errors = zeros(maxTrials, 1);
counterfactual_updates = zeros(maxTrials, 1);
same_cue_transition = zeros(maxTrials, 1);
same_image_transition = zeros(maxTrials, 1);
trial_prediction = zeros(maxTrials, 1);
regressor_matrix = zeros(maxTrials, 4);

%% do cue learning
for i=1:maxTrials
    cue = sub_data.cueIdx(i);
    image = sub_data.imageIdx(i);
    counter_matrix(cue, image) = counter_matrix(cue, image) + 1;

    trial_prediction(i) = transition_matrix(cue, image);
    prediction_errors(i) = 1 - transition_matrix(cue, image);
    counterfactual_updates(i) = 0 - transition_matrix(cue, 3-image); % update probabilities for unobserved image

    % scale alpha by the number of elapsed trials
    alpha = params(1) + (params(2)/ i);
    alpha  = 1./(1 + exp(-alpha)); 

    transition_matrix(cue, image) = transition_matrix(cue, image) + alpha * prediction_errors(i);
    transition_matrix(cue, 3-image) = transition_matrix(cue, 3-image) + alpha * counterfactual_updates(i);

    if i > 1
        if cue == sub_data.cueIdx(i-1)
            same_cue_transition(i) = 1;
        end
        if image == sub_data.imageIdx(i-1)
            same_image_transition(i) = 1;
        end
    end
end

%% store values
regressor_matrix(:,1) = 1;
regressor_matrix(:,2) = trial_prediction;
regressor_matrix(:,3) = same_cue_transition;
regressor_matrix(:,end) = 1:length(regressor_matrix);