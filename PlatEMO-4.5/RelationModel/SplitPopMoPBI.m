function [labels, referencePoints] = SplitPopMoPBI(Population, numRefPoints)
    % SplitPopMoPBI Splits the population into categories based on PBI method.
    % 
    % This function splits the population into two categories based on the
    % reference points and the Penalty-based Boundary Intersection (PBI) method.
    % 
    % Inputs:
    %    Population - A Population object from Platemo framework, containing
    %                 individuals of the current population.
    %    numRefPoints - The number of reference points to be used.
    %
    % Outputs:
    %    labels - An array containing the label of each solution in the
    %             population, indicating its category.
    %    referencePoints - The selected reference points from the population.
    
        % Select reference points from the population
        referencePoints = RefSelect(Population, numRefPoints);
        
        % Assign labels to each solution based on PBI method
        labels = AssignLabelsUsingPBI(Population.objs, referencePoints.objs);
    end
    

    