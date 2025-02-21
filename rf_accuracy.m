clear all
close all

% Read the text file into a table
file = 'allData_Unscored_022025.txt';
data = readtable(file, 'Delimiter', '\t');

% Extract the relevant columns (assuming the salts are in column 3 and concentrations in column 4, and metrics from column 10 to column 56)
salts = data{:, 3};
concentrations = data{:, 4};
metrics = data{:, 10:56};

% Convert salts and concentrations to strings
saltsStr = string(salts);
concentrationsStr = string(concentrations);

% Combine salts and concentrations into a single categorical variable
categories = categorical(strcat(saltsStr, '_', concentrationsStr));

% Parameters for Random Forest and cross-validation
numTrees = 100;
numRuns = 20;

accuracies = zeros(numRuns, 1); % Store accuracies for all runs
accuraciesSalts = zeros(numRuns, 1); % Store accuracies for salts-only case

% Initialize confusion matrices for accumulation
uniqueCategories = categorical(unique(categories)); % Ensure it's categorical
numCategories = numel(uniqueCategories);
confMatSum = zeros(numCategories, numCategories); % For salts + concentrations

uniqueSalts = categorical(unique(saltsStr)); % Ensure it's categorical
numSalts = numel(uniqueSalts);
confMatSaltsSum = zeros(numSalts, numSalts); % For salts only

for i = 1:numRuns
    % Split the data into training and test sets (70% training, 30% test)
    cv = cvpartition(categories, 'HoldOut', 0.3);
    trainIdx = training(cv);
    testIdx = test(cv);

    trainData = metrics(trainIdx, :);
    trainLabels = categories(trainIdx);

    testData = metrics(testIdx, :);
    testLabels = categories(testIdx);


    % --------------------------------------
    % Z-Scoring: Use only training set statistics
    % --------------------------------------
    
    % Compute mean and standard deviation of the training data
    trainDataMean = mean(trainData, 1);
    trainDataStd = std(trainData, 0, 1);
    
    % Apply z-scoring to the training data
    trainData = (trainData - trainDataMean) ./ trainDataStd;
    
    % Apply the same z-scoring transformation to the test data
    testData = (testData - trainDataMean) ./ trainDataStd;
     % --------------------------------------



    % Train a random forest classifier
    rng(i); % Use different random seed for each run
    rfModel = TreeBagger(numTrees, trainData, trainLabels, 'OOBPrediction', 'On', 'Method', 'classification');

    % Predict the test set
    predictedLabels = predict(rfModel, testData);

    % Convert cell array of predicted labels to categorical
    predictedLabels = categorical(predictedLabels);

    % Compute the confusion matrix for the current run
    confMat = confusionmat(testLabels, predictedLabels, 'Order', uniqueCategories);
    confMatSum = confMatSum + confMat; % Accumulate the confusion matrix

    % Compute the accuracy for the current run
    accuracies(i) = sum(diag(confMat)) / sum(confMat(:));

    % ------------------------
    % Second case: Only salts as categories
    % ------------------------

    categoriesSalts = categorical(saltsStr); % Use only salts as categories

    % Split the data into training and test sets (70% training, 30% test)
    cvSalts = cvpartition(categoriesSalts, 'HoldOut', 0.3);
    trainIdxSalts = training(cvSalts);
    testIdxSalts = test(cvSalts);

    trainDataSalts = metrics(trainIdxSalts, :);
    trainLabelsSalts = categoriesSalts(trainIdxSalts);

    testDataSalts = metrics(testIdxSalts, :);
    testLabelsSalts = categoriesSalts(testIdxSalts);


    % --------------------------------------
    % Z-Scoring: Use only training set statistics
    % --------------------------------------
    
    % Compute mean and standard deviation of the training data
    trainDataSaltsMean = mean(trainDataSalts, 1);
    trainDataSaltsStd = std(trainDataSalts, 0, 1);
    
    % Apply z-scoring to the training data
    trainDataSalts = (trainDataSalts - trainDataSaltsMean) ./ trainDataSaltsStd;
    
    % Apply the same z-scoring transformation to the test data
    testDataSalts = (testDataSalts - trainDataSaltsMean) ./ trainDataSaltsStd;
     % --------------------------------------




    % Train a random forest classifier
    rfModelSalts = TreeBagger(numTrees, trainDataSalts, trainLabelsSalts, 'OOBPrediction', 'On', 'Method', 'classification');

    % Predict the test set
    predictedLabelsSalts = predict(rfModelSalts, testDataSalts);

    % Convert cell array of predicted labels to categorical
    predictedLabelsSalts = categorical(predictedLabelsSalts);

    % Compute the confusion matrix for the current run
    confMatSalts = confusionmat(testLabelsSalts, predictedLabelsSalts, 'Order', uniqueSalts);
    confMatSaltsSum = confMatSaltsSum + confMatSalts; % Accumulate the confusion matrix

    % Compute the accuracy for the current run
    accuraciesSalts(i) = sum(diag(confMatSalts)) / sum(confMatSalts(:));
end

% Calculate the mean and standard deviation of accuracies for both cases
meanAccuracy = mean(accuracies);
stdAccuracy = std(accuracies);
meanAccuracySalts = mean(accuraciesSalts);
stdAccuracySalts = std(accuraciesSalts);

% Display overall accuracy (mean ± std)
fprintf('Overall accuracy (Salts + Concentrations): %.2f ± %.2f%%\n', meanAccuracy * 100, stdAccuracy * 100);
fprintf('Overall accuracy (Salts Only): %.2f ± %.2f%%\n', meanAccuracySalts * 100, stdAccuracySalts * 100);

% ------------------------
% Plot confusion matrices for the average case
% ------------------------

% Average confusion matrices over all runs and round to nearest integer
confMatAvg = round(confMatSum / numRuns);
confMatSaltsAvg = round(confMatSaltsSum / numRuns);

% Confusion matrix for salts and concentrations
figure("Color","white");
confMatChart = confusionchart(confMatAvg, uniqueCategories, 'RowSummary', 'off', 'ColumnSummary', 'off');
title(sprintf('Average Confusion Matrix (Salts + Concentrations)\nMean Accuracy: %.2f%%', meanAccuracy * 100));

% Adjust the font size of the numbers inside the confusion chart
confMatChart.FontSize = 16;

% Confusion matrix for salts only
figure("Color","white");
confMatSaltsChart = confusionchart(confMatSaltsAvg, uniqueSalts, 'RowSummary', 'row-normalized', 'ColumnSummary', 'off');
title(sprintf('Average Confusion Matrix (Salts Only)\nMean Accuracy: %.2f%%', meanAccuracySalts * 100));

% Adjust the font size of the numbers inside the confusion chart
confMatSaltsChart.FontSize = 14;
