% 07/18/24 ... Trying to reduce the number of metrics and check Random
% Forest results. The trimming follows correlation values.

clear all
close all

% Main parameters
numSeeds = 3; % Number of seeds for reproducibility
numTrees = 100; % Number of trees in the forest
maxDepth = 10; % Maximum depth of the trees
minLeafSize = 5; % Minimum leaf size
numMetricsToCheck = 47; % Check all metrics
numFeatures = round(sqrt(numMetricsToCheck)); % Number of features to consider at each split

% Read the text file into a table
file = 'allData_ZScored.txt';
data = readtable(file, 'Delimiter', '\t');

% Extract the relevant columns (assuming the salts are in column 3 and concentrations in column 4, and metrics from column 10 to column 56)
salts = data{:, 3};
concentrations = data{:, 4};
metrics = data{:, 10:56};
metricNames = data.Properties.VariableNames(10:56); % Get metric names for plotting

% Convert salts and concentrations to strings
saltsStr = string(salts);
concentrationsStr = string(concentrations);

% Combine salts and concentrations into a single categorical variable
categories = categorical(saltsStr);

% Split the data into training and test sets (70% training, 30% test)
cv = cvpartition(categories, 'HoldOut', 0.3);
trainIdx = training(cv);
testIdx = test(cv);

trainData = metrics(trainIdx, :);
testData = metrics(testIdx, :);
trainLabels = categories(trainIdx);
testLabels = categories(testIdx);

% Train the Random Forest model with parameters to reduce overfitting
rfModel = TreeBagger(numTrees, trainData, trainLabels, ...
    'MaxNumSplits', maxDepth, ...
    'MinLeafSize', minLeafSize, ...
    'NumPredictorsToSample', numFeatures, ...
    'OOBPrediction', 'On', ...
    'Method', 'classification', ...
    'OOBPredictorImportance', 'on'); % Set OOBPredictorImportance to 'on'

% Predict the test set
predictedLabels = predict(rfModel, testData);
predictedLabels = categorical(predictedLabels);

% Compute the confusion matrix and accuracy
confMat = confusionmat(testLabels, predictedLabels);
testAccuracy = sum(diag(confMat)) / sum(confMat, 'all') * 100;


% Display the test accuracy
disp(['Test Accuracy: ', num2str(testAccuracy), '%']);

% Plot the OOB error
oobErrorVals = oobError(rfModel);
figure;
plot(oobErrorVals);
title('Out-of-Bag Error Estimate');
xlabel('Number of Grown Trees');
ylabel('OOB Error');

% Visualize the feature importance
featureImportance = rfModel.OOBPermutedPredictorDeltaError;
figure;
bar(featureImportance);
title('Feature Importance Estimates');
xlabel('Feature Index');
ylabel('Importance');
xticks(1:length(metricNames));
xticklabels(metricNames);
set(gca, 'XTickLabel', get(gca, 'XTickLabel'), 'FontSize', 16);
xtickangle(45);

% Save the model and results
save('rfModel.mat', 'rfModel');
save('testAccuracy.mat', 'testAccuracy');
save('oobError.mat', 'oobErrorVals');
