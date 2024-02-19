function [XXs, Ls] = CategoryCriteriaGenerator(decs, catalog)
    % CategoryCriteriaGenerator Generates decision matrices and labels for category criteria.
    %
    % Inputs:
    %   decs - A matrix where each row represents a decision vector.
    %   catalog - A vector indicating the category of each decision vector in decs.
    %
    % Outputs:
    %   XXs - The generated decision matrices for training/testing.
    %   Ls - The labels corresponding to each row in XXs.

    % Find indices of positive (Xp) and negative (Xn) categories
    Xp_index = catalog == 1;
    Xn_index = catalog ~= 1;

    % Generate all possible combinations within and across categories
    XpXp = combvec(decs(catalog == 1, :)', decs(catalog == 1, :)')';
    XpXn = combvec(decs(catalog == 1, :)', decs(catalog ~= 1, :)')';
    XnXp = combvec(decs(catalog ~= 1, :)', decs(catalog == 1, :)')';
    XnXn = combvec(decs(catalog ~= 1, :)', decs(catalog ~= 1, :)')';

    % Remove self-combinations for XpXp and XnXn to avoid redundancy
    t_ind = combvec(1:sum(Xp_index), 1:sum(Xp_index));
    t_equ_ind = t_ind(1, :) == t_ind(2, :);
    XpXp(t_equ_ind, :) = [];

    t_ind = combvec(1:sum(Xn_index), 1:sum(Xn_index));
    t_equ_ind = t_ind(1, :) == t_ind(2, :);
    XnXn(t_equ_ind, :) = [];

    % Label balancing: Adjust the number of samples in each category combination to ensure balance
    t_num = ceil(size(XpXn, 1) / 2);

    % Adjust the sample size for each combination to ensure balanced labels
    if size(XpXp, 1) > t_num && size(XnXn, 1) > t_num
        XpXp = XpXp(randperm(size(XpXp, 1), t_num), :);
        XnXn = XnXn(randperm(size(XnXn, 1), t_num), :);
    elseif size(XpXp, 1) < t_num
        XnXn = XnXn(randperm(size(XnXn, 1), t_num * 2 - size(XpXp, 1)), :);
    elseif size(XnXn, 1) < t_num
        XpXp = XpXp(randperm(size(XpXp, 1), t_num * 2 - size(XnXn, 1)), :);
    end

    % Combine all combinations and generate the corresponding labels
    XXs = [XpXp; XnXn; XpXn; XnXp];
    Ls = [zeros(size(XpXp, 1), 1); zeros(size(XnXn, 1), 1); ...
          ones(size(XpXn, 1), 1); -1 .* ones(size(XnXp, 1), 1)];
end
