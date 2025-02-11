clear all
close all

% Read the text file into a table
file = 'allData_ZScored.txt';
data = readtable(file, 'Delimiter', '\t');

% Extract the relevant columns (assuming the salts are in column 3, concentrations in column 4, and metrics from column 10 to 56)
directories = data{:, 1};
filenames = data{:, 2}; % Assuming the filenames are in column 2
salts = data{:, 3};
concentrations = data{:, 4};
metrics = data{:, 10:56};

% Convert salts and concentrations to strings
saltsStr = string(salts);
concentrationsStr = string(concentrations);

% Combine salts and concentrations into a single categorical variable
categories = strcat(saltsStr, '_', concentrationsStr);

% Debug: Check the size of the original data
disp('Size of original data:');
disp(size(data));

% Split the data into training and test sets (70% training, 30% test)
cv = cvpartition(categories, 'HoldOut', 0.3);
trainIdx = training(cv);
testIdx = test(cv);

% Extract training and test data
trainData = metrics(trainIdx, :);
trainLabels = categories(trainIdx);

testData = metrics(testIdx, :);
testLabels = categories(testIdx);

% Debug: Check the sizes of the indices
disp('Size of trainIdx:');
disp(sum(trainIdx));

disp('Size of testIdx:');
disp(sum(testIdx));

% Debug: Check the sizes of the extracted data
disp('Size of trainData:');
disp(size(trainData));

disp('Size of testData:');
disp(size(testData));

% Replace NaNs with the mean of the respective feature
trainData = fillmissing(trainData, 'constant', mean(trainData, 'omitnan'));
testData = fillmissing(testData, 'constant', mean(testData, 'omitnan'));

% Normalize the data
trainData = normalize(trainData);
testData = normalize(testData);

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

% Debug: Check the size of testData again before classification
disp('Size of testData before classification:');
disp(size(testData));

% Predict the test set
predictedLabels = classify(net, testData);

% Debug: Check sizes after classification
disp('Length of testIdx (sum):');
disp(sum(testIdx));

disp('Length of predictedLabels:');
disp(length(predictedLabels));

% Ensure predictedLabels is the same length as the test data size
assert(length(predictedLabels) == sum(testIdx), 'Length of predictedLabels does not match length of testIdx.');

% Get the actual test indices
testIndices = find(testIdx);

% Select randomly 120 entries from the test set, ensuring we do not exceed the bounds
numEntries = min(120, length(testIndices));
randomIndices = randperm(length(testIndices), numEntries);

% Extract the relevant information for the selected entries
selectedTestIndices = testIndices(randomIndices);
selectedDirectories = directories(selectedTestIndices);
selectedFilenames = filenames(selectedTestIndices); % Add filenames to the selection
selectedSalts = salts(selectedTestIndices);
selectedConcentrations = concentrations(selectedTestIndices);
selectedPredictedLabels = predictedLabels(randomIndices);

% Convert the predicted numerical labels back to their string categories
selectedPredictedCategories = uniqueCategories(double(selectedPredictedLabels));

% Split the predicted categories back into salts and concentrations
predictedSaltsConcs = split(selectedPredictedCategories, '_');
predictedSalts = predictedSaltsConcs(:, 1);
predictedConcentrations = predictedSaltsConcs(:, 2);

% Create a table with the selected entries
selectedTable = table(selectedDirectories, selectedFilenames, selectedSalts, selectedConcentrations, predictedSalts, predictedConcentrations, ...
    'VariableNames', {'Directory', 'Filename', 'Salt', 'Concentration', 'PredictedSalt', 'PredictedConcentration'});

% Write the table to a text file
writetable(selectedTable, 'predictedEntries.txt', 'Delimiter', '\t');

fprintf('Selected entries saved to predictedEntries.txt\n');
