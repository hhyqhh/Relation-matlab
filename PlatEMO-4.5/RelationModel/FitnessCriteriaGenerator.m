function varargout = FitnessCriteriaGenerator(varargin)
    
    if nargin == 2
        decs = varargin{1};
        fitness = varargin{2};
    
    
        % Calculate the length of the input vectors
        len_decs = size(decs, 1);
        % Generate all possible index combinations
        ind1 = combvec(1:len_decs, 1:len_decs);
        % Identify the indices where both elements are equal
        equind = ind1(1, :) == ind1(2, :);
        
        % Generate all possible combinations of decs and fitness
        decsCombinations = combvec(decs', decs')';
        fitnessCombinations = combvec(fitness', fitness')';
        % Initialize the label array
        labels = zeros(size(fitnessCombinations, 1), 1);
        % Assign labels based on the comparison result of fitness values
        labels(fitnessCombinations(:, 1) < fitnessCombinations(:, 2)) = 1;
        labels(fitnessCombinations(:, 1) >= fitnessCombinations(:, 2)) = -1;
        
        % Remove combinations and labels corresponding to equal indices
        decsCombinations(equind, :) = [];
        labels(equind) = [];
        
        % Set the output variables
        varargout = {decsCombinations,labels};
    else
        decs = varargin{1};
        decsCombinations = combvec(decs', decs')';
        varargout = {decsCombinations};
    end

end
