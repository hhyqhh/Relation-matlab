function [ind, scores] = CategoryCriteriaUser(surrogate, Us, Xs, catalog)
    % CategoryCriteriaUser Evaluates and ranks unlabelled samples based on their classification criteria scores.
    %
    % Inputs:
    %   surrogate - A struct representing the surrogate model used for prediction.
    %   Us - A matrix where each row represents an unlabelled decision vector.
    %   Xs - A matrix where each row represents a labelled decision vector.
    %   catalog - A vector indicating the category of each decision vector in Xs.
    %
    % Outputs:
    %   ind - Indices of the unlabelled samples in Us, sorted by their scores in descending order.
    %   scores - A vector of scores for each unlabelled sample in Us.

    % Separate positive and negative samples based on the catalog
    Xp = Xs(catalog == 1, :);
    Xn = Xs(catalog ~= 1, :);

    % Count the number of positive and negative samples
    Xp_num = size(Xp, 1);
    Xn_num = size(Xn, 1);
    Us_num = size(Us, 1);

    % Initialize the scores vector for unlabelled samples
    scores = zeros(Us_num, 1);

    % Pre-allocate memory for the data to be predicted
    pre_data = zeros(2 * (Xp_num + Xn_num) * Us_num, 2 * size(Xp, 2));

    % Construct the data for prediction by combining Us with Xp and Xn in all possible ways
    for i = 1:Us_num
        original = (i - 1) * 2 * (Xp_num + Xn_num);

        % Combine Us with Xp
        Ui = repmat(Us(i, :), Xp_num, 1);
        pre_data(original + 1:original + Xp_num, :) = [Xp, Ui]; % Xp_Ui
        pre_data(original + 1 + Xp_num:original + Xp_num * 2, :) = [Ui, Xp]; % Ui_Xp

        % Combine Us with Xn
        Ui = repmat(Us(i, :), Xn_num, 1);
        pre_data(original + 1 + Xp_num * 2:original + Xp_num * 2 + Xn_num, :) = [Xn, Ui]; % Xn_Ui
        pre_data(original + 1 + Xn_num + Xp_num * 2:original + Xn_num * 2 + Xp_num * 2, :) = [Ui, Xn]; % Ui_Xn
    end

    if strcmpi(surrogate.model_name, 'NN')
        % Normalize the data using the normalization structure from the surrogate model
        pre_data_nor = mapminmax('apply', pre_data', surrogate.nor_struct)';
    
        % Predict the outcomes using the surrogate model
        pre_out = surrogate.model(pre_data_nor')';
    elseif strcmpi(surrogate.model_name, 'CNN')
        pre_data = Convert2CNNInput(pre_data);
        pre_out  = classify(surrogate.model,pre_data);
        pre_out  = OneHotConvert(str2double(cellstr(pre_out)),1);
    else

    end


    % Calculate scores for each unlabelled sample by aggregating the predictions
    for i = 1:Us_num
        C_SCORE = zeros(1, 2);
        original = (i - 1) * 2 * (Xp_num + Xn_num);
        
        % Aggregate predictions for combinations with Xp
        pre_XpUi = sum(pre_out(original + 1:original + Xp_num, :), 1) ./ Xp_num;
        C_SCORE(1) = C_SCORE(1) + pre_XpUi(2) + pre_XpUi(3);
        C_SCORE(2) = C_SCORE(2) + pre_XpUi(1);

        pre_UiXp = sum(pre_out(original + 1 + Xp_num:original + Xp_num * 2, :), 1) ./ Xp_num;
        C_SCORE(1) = C_SCORE(1) + pre_UiXp(2) + pre_UiXp(1);
        C_SCORE(2) = C_SCORE(2) + pre_UiXp(3);

        % Aggregate predictions for combinations with Xn
        pre_XnUi = sum(pre_out(original + 1 + Xp_num * 2:original + Xp_num * 2 + Xn_num, :), 1) ./ Xn_num;
        C_SCORE(1) = C_SCORE(1) + pre_XnUi(3);
        C_SCORE(2) = C_SCORE(2) + pre_XnUi(2) + pre_XnUi(1);

        pre_UiXn = sum(pre_out(original + 1 + Xn_num + Xp_num * 2:original + Xn_num * 2 + Xp_num * 2, :), 1) ./ Xn_num;
        C_SCORE(1) = C_SCORE(1) + pre_UiXn(1);
        C_SCORE(2) = C_SCORE(2) + pre_UiXn(2) + pre_UiXn(3);

        % Calculate the final score for each unlabelled sample
        scores(i) = C_SCORE(1) - C_SCORE(2);
    end

    % Sort the unlabelled samples based on their scores in descending order
    [~, ind] = sort(scores, 'descend');
end
