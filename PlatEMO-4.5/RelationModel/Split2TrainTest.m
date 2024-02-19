function [TrainIn, TrainOut, TestIn, TestOut] = Split2TrainTest(Input, Output)
    % Split2TrainTest Splits data into training and testing sets with class balance.
    %
    % This function takes a dataset (Input, Output) and splits it into
    % training and testing sets while trying to maintain the class balance.
    % The classes are determined based on the unique values in Output.
    % 
    % Inputs:
    %   Input - The input features matrix where each row is a sample.
    %   Output - The output vector where each element is the class label of the corresponding sample.
    %
    % Outputs:
    %   TrainIn - The input features matrix for the training set.
    %   TrainOut - The output vector for the training set.
    %   TestIn - The input features matrix for the testing set.
    %   TestOut - The output vector for the testing set.

    % The proportion of the data to be used for training
    pha = 3/4;

    % Find indices of each class in the output
    index0 = find(Output == 0);
    indexp1 = find(Output == 1);
    indexn1 = find(Output == -1);

    % Initialize logical index vectors for training data selection
    K0 = false(1, length(index0));
    Kp1 = false(1, length(indexp1));
    Kn1 = false(1, length(indexn1));

    % Randomly select a proportion 'pha' of indices for each class to include in the training set
    K0(randperm(length(index0), ceil(pha * length(index0)))) = true;
    Kp1(randperm(length(indexp1), ceil(pha * length(indexp1)))) = true;
    Kn1(randperm(length(indexn1), ceil(pha * length(indexn1)))) = true;

    % Combine selected indices for all classes to form the training set indices
    K = [index0(K0); indexp1(Kp1); indexn1(Kn1)];

    % Extract training data based on the selected indices
    TrainIn = Input(K, :);
    TrainOut = Output(K);

    % Extract testing data based on the remaining indices
    TestIn = Input(setdiff(1:size(Input, 1), K), :);
    TestOut = Output(setdiff(1:size(Input, 1), K));

    % Shuffle the training data to ensure random distribution
    Train_randindex = randperm(size(TrainOut, 1), size(TrainOut, 1));
    TrainIn = TrainIn(Train_randindex, :);
    TrainOut = TrainOut(Train_randindex);

    % Shuffle the testing data to ensure random distribution
    Test_randindex = randperm(size(TestOut, 1), size(TestOut, 1));
    TestIn = TestIn(Test_randindex, :);
    TestOut = TestOut(Test_randindex);
end
