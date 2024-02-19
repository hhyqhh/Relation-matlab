function surrogate = Trainer_CNN(varargin)
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

    Xs = Convert2CNNInput(Xs);
    ys = categorical(ys);

    layers = [
        imageInputLayer([2 size(Xs,2) 1])
        convolution2dLayer([2,2],100)
        reluLayer
        convolution2dLayer([1,2],30)
        reluLayer
        dropoutLayer(0.2)
        fullyConnectedLayer(30)
        fullyConnectedLayer(3)
        softmaxLayer
        classificationLayer
    ];


    sam_num = size(Xs,4);
    idx = randperm(size(Xs,4),ceil(sam_num*0.2));
    X_validation = Xs(:,:,:,idx);
    Xs(:,:,:,idx) = [];
    y_validation = ys(idx);
    ys(idx) = [];


    if gpuDeviceCount > 0 && canUseGPU % 对于R2020b及以后的版本
        executionEnvironment = 'gpu';
    elseif gpuDeviceCount > 0 % 对于R2020a及之前的版本
        executionEnvironment = 'gpu';
    else
        executionEnvironment = 'cpu';
    end

    options = trainingOptions('sgdm', ...
    'InitialLearnRate',0.01, ...
    'MaxEpochs',100, ...
    'Shuffle','every-epoch', ...
    'ValidationFrequency',30, ...
    'ValidationData',{X_validation,y_validation},'Verbose',false, ...
    'ExecutionEnvironment',executionEnvironment);
    % 'Plots','training-progress','Verbose',true);

    net = trainNetwork(Xs,ys,layers,options);
    surrogate.model = net;
    surrogate.model_name = 'CNN';

end
