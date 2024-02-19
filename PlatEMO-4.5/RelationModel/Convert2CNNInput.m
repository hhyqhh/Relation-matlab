function XX_img = Convert2CNNInput(XXs)
    % Determine the number of samples and the number of features per sample
    numSamples = size(XXs, 1);
    featuresPerSample = size(XXs, 2);
    
    % Ensure the number of features per sample is even
    if mod(featuresPerSample, 2) ~= 0
        error('The number of features per sample must be even.');
    end
    
    % Initialize the CNN input format array
    % Assuming features are split into two parts, each part in a different row
    XX_img = zeros(2, featuresPerSample/2, 1, numSamples);
    
    % Iterate over each sample to allocate features into the CNN input format array
    for sampleIndex = 1:numSamples
        XX_img(1,:,1,sampleIndex) = XXs(sampleIndex, 1:featuresPerSample/2);
        XX_img(2,:,1,sampleIndex) = XXs(sampleIndex, featuresPerSample/2+1:end);
    end
end
