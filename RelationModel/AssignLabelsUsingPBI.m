function [labels, ratio] = AssignLabelsUsingPBI(varargin)
    % Assigns labels using the Penalty-based Boundary Intersection (PBI) method.
    % varargin{1}: Population object (matrix)
    % varargin{2}: Reference points object (matrix)
    % varargin{3} (optional): Penalty coefficient delta
    selfadapt = true;

    if nargin == 3
        selfadapt = false;
        delt = varargin{3};
    end

    % Initialize self-adaptation flag
    selfAdapt = true;

    if nargin == 3
        selfAdapt = false;
        penaltyCoefficient = varargin{3}; % penalty coefficient
    end

    Pop = varargin{1};
    Ref = varargin{2};

    if selfAdapt
        lowerBound = -20;
        upperBound = 20;

        ratio = 0;

        % Self-adaptation of penalty coefficient
        while ratio > 0.7 || ratio < 0.3
            midPoint = (lowerBound + upperBound) / 2;

            if abs(lowerBound - upperBound) < 1e-1
                break;
            end

            [labels, ratio] = split_data(Pop, Ref, midPoint);

            if ratio > 0.7
                lowerBound = midPoint;
            elseif ratio < 0.3
                upperBound = midPoint;
            end

        end

    else
        [labels, ~] = split_data(Pop, Ref, penaltyCoefficient);
    end

end

function [Output, rate] = split_data(Pop, Ref, delt)

    N = size(Pop, 1);
    popind = 1:N;
    Output = true(N, 1);
    [~, ref_index] = max(1 - pdist2(Pop, Ref, 'cosine'), [], 2);

    Z = min(Pop, [], 1);

    for i = 1:size(Ref, 1)
        sub_pop = Pop(ref_index == i, :);
        sub_popind = popind(ref_index == i);
        BOUND = Ref(i, :);
        w = BOUND - Z;
        W = w ./ sqrt(sum((w) .^ 2, 2));

        normW = sqrt(sum((W) .^ 2, 2));
        normP = sqrt(sum((sub_pop - repmat(Z, size(sub_pop, 1), 1)) .^ 2, 2));
        normR = sqrt(sum((BOUND - Z) .^ 2, 2));
        CosineP = (sum((sub_pop - repmat(Z, size(sub_pop, 1), 1)) .* repmat(W, size(sub_pop, 1), 1), 2) ./ normW ./ normP) -1e-6;
        %CosineR = (sum((BOUND-Z).*(W),2)./normW./normR)-1e-6;

        g = normP .* CosineP + delt * normP .* sqrt(1 - CosineP .^ 2);
        k = normR;
        g = g ./ k;

        Output(sub_popind(g > 1)) = false;
    end

    rate = sum(Output == 1) / length(Output);
end
