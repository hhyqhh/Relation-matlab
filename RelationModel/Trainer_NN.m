function surrogate = Trainer_NN(varargin)
    % Trainer_NN Trains a neural network model using provided samples and optionally evaluates its performance.
    %
    % Inputs:
    %   varargin{1} - Xs, features matrix where rows are samples and columns are features.
    %   varargin{2} - ys, labels associated with each sample in Xs.
    %   varargin{3} (optional) - If present, indicates that the data should be split into training and testing sets.
    %
    % Outputs:
    %   surrogate - A struct containing the trained model and normalization structure, and optionally the test error.

    % Extract features and labels from input arguments
    Xs = varargin{1};
    ys = varargin{2};

    % Check if data should be split into training and testing sets
    if length(varargin) > 2
        [Xs_train, ys_train, Xs_test, ys_test] = Split2TrainTest(Xs, ys);
    else
        [Xs_train, ys_train] = deal(Xs, ys);
    end

    % Determine the dimensionality of the input features
    X_Dim = size(Xs_train, 2);

    % Normalize the training data
    [Xs_train_nor, nor_struct] = mapminmax(Xs_train');
    Xs_train_nor = Xs_train_nor';

    % Convert labels to one-hot encoding for neural network training
    ys_train_onehot = OneHotConvert(ys_train, 1);

    % Define the neural network architecture
    net = patternnet([ceil(X_Dim * 1.5), X_Dim * 1, ceil(X_Dim / 2)]);
    net.trainParam.showWindow = 0; % Disable training window for non-interactive sessions

    % Train the neural network
    net = train(net, Xs_train_nor', ys_train_onehot');

    % Store the normalization structure and trained model in the surrogate struct
    surrogate.nor_struct = nor_struct;
    surrogate.model = net;

    % If test data is provided, evaluate the model's performance
    if length(varargin) > 2
        % Normalize the test data using the same normalization structure
        Xs_test_nor = mapminmax('apply', Xs_test', nor_struct)';
        
        % Predict labels for the test data
        ys_pre = OneHotConvert(net(Xs_test_nor')', 2);
        
        % Calculate and store the test error
        t_err = sum(ys_pre ~= ys_test) / size(ys_pre, 1);
        surrogate.t_err = t_err;
    end
    surrogate.model_name = 'NN';
end
