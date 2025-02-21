% 07/21/24

clear all
close all

% Read the text file into a table
file = 'allData_Unscored_022025.txt';
data = readtable(file, 'Delimiter', '\t');

% Extract the relevant columns (assuming the salts are in column 3 and concentrations in column 4, and metrics from column 10 to 56)
salts = data{:, 3};
concentrations = data{:, 4};
metrics = data{:, 10:56};

% Convert salts and concentrations to strings
saltsStr = string(salts);
concentrationsStr = string(concentrations);

% Combine salts and concentrations into a single categorical variable
categories = strcat(saltsStr, '_', concentrationsStr);

% Initialize variables for multiple runs
numRuns = 20;
accuracies = zeros(numRuns, 1);
allConfMat = zeros(numel(unique(categories)));

for run = 1:numRuns
    % Split the data into training and test sets (70% training, 30% test)
    cv = cvpartition(categories, 'HoldOut', 0.3);
    trainIdx = training(cv);
    testIdx = test(cv);

    trainData = metrics(trainIdx, :);
    trainLabels = categories(trainIdx);

    testData = metrics(testIdx, :);
    testLabels = categories(testIdx);

    % Replace NaNs with the mean of the respective feature
    trainData = fillmissing(trainData, 'constant', mean(trainData, 'omitnan'));
    testData = fillmissing(testData, 'constant', mean(trainData, 'omitnan'));

    % Normalize the data
    % trainData = normalize(trainData);
    % testData = normalize(testData);
    trainDataMean = mean(trainData, 1);
    trainDataStd = std(trainData, 0, 1);
    trainData = (trainData - trainDataMean) ./ trainDataStd;
    testData = (testData - trainDataMean) ./ trainDataStd;

    % Convert categorical labels to numerical indices
    [uniqueCategories, ~, trainLabels] = unique(trainLabels);
    [~, ~, testLabels] = unique(testLabels);

    % Convert labels to categorical
    trainLabels = categorical(trainLabels);
    testLabels = categorical(testLabels);

    % Define the network architecture
    inputSize = size(trainData, 2);
    numClasses = numel(uniqueCategories);
    layers = [
        featureInputLayer(inputSize, 'Normalization', 'zscore')
        fullyConnectedLayer(1024, 'WeightsInitializer', 'he')
        batchNormalizationLayer
        reluLayer
        dropoutLayer(0.5)
        fullyConnectedLayer(512, 'WeightsInitializer', 'he')
        batchNormalizationLayer
        reluLayer
        dropoutLayer(0.5)
        fullyConnectedLayer(256, 'WeightsInitializer', 'he')
        batchNormalizationLayer
        reluLayer
        dropoutLayer(0.5)
        fullyConnectedLayer(128, 'WeightsInitializer', 'he')
        batchNormalizationLayer
        reluLayer
        dropoutLayer(0.5)
        fullyConnectedLayer(numClasses)
        softmaxLayer
        classificationLayer];

    % Training options with early stopping, advanced regularization, and adaptive learning rate
    options = trainingOptions('adam', ...
        'MiniBatchSize', 128, ...
        'MaxEpochs', 500, ...
        'InitialLearnRate', 0.001, ...
        'LearnRateSchedule', 'piecewise', ...
        'LearnRateDropFactor', 0.5, ...
        'LearnRateDropPeriod', 10, ...
        'L2Regularization', 0.01, ...
        'Shuffle', 'every-epoch', ...
        'ValidationData', {testData, testLabels}, ...
        'ValidationPatience', 10, ...
        'Verbose', false, ...
        'Plots', 'training-progress');

    % Train the network with early stopping and store training info
    [net, info] = trainNetwork(trainData, trainLabels, layers, options);

    % Predict the test set
    predictedLabels = classify(net, testData);

    % Calculate accuracy
    accuracy = sum(predictedLabels == testLabels) / numel(testLabels) * 100;
    accuracies(run) = accuracy;

    % Compute the confusion matrix for this run
    confMat = confusionmat(testLabels, predictedLabels);
    allConfMat = allConfMat + confMat;
end

% Calculate mean accuracy and standard deviation
meanAccuracy = mean(accuracies);
stdDevAccuracy = std(accuracies);

% Normalize the confusion matrix by the number of runs
avgConfMat = allConfMat / numRuns;

% Display the confusion matrix with labels
figure;
set(gcf, 'color', 'w'); % Set figure background to white
confusionchart(round(avgConfMat), uniqueCategories,FontSize = 14);
% title('Average Confusion Matrix for 20 Runs');

% Display mean accuracy and standard deviation
fprintf('Mean Accuracy: %.2f%%\n', meanAccuracy);
fprintf('Standard Deviation: %.2f%%\n', stdDevAccuracy);
