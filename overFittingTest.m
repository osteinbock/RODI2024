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
file = 'allData_Unscored_022025.txt';
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

% Variables to accumulate results
allAccuracies = zeros(20, 1);
allOOBErrors = zeros(100, 1); % Assuming 100 trees for plotting OOB error
allFeatureImportance = zeros(numMetricsToCheck, 20); % Store feature importance for each run

% Loop to run 20 times with different seeds
for i = 1:20
    % Split the data into training and test sets (70% training, 30% test)
    cv = cvpartition(categories, 'HoldOut', 0.3);
    trainIdx = training(cv);
    testIdx = test(cv);

    trainData = metrics(trainIdx, :);
    testData = metrics(testIdx, :);
    trainLabels = categories(trainIdx);
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

    % Store the accuracy
    allAccuracies(i) = testAccuracy;

    % Plot the OOB error for the current run (accumulate values)
    oobErrorVals = oobError(rfModel);
    allOOBErrors = allOOBErrors + oobErrorVals(:); % Sum OOB error values over all runs

    % Store feature importance for the current run
    featureImportance = rfModel.OOBPermutedPredictorDeltaError;
    allFeatureImportance(:, i) = featureImportance;

    % Display the test accuracy for the current run
    disp(['Run ', num2str(i), ' - Test Accuracy: ', num2str(testAccuracy), '%']);
end

% Calculate the average accuracy across all runs
avgAccuracy = mean(allAccuracies);
stddevAccuracy = std(allAccuracies);

% Plot the average Out-of-Bag (OOB) error for all runs
avgOOBError = allOOBErrors / 20; % Average over all 20 runs
figure;
plot(avgOOBError);
title(['Average Out-of-Bag Error Estimate (20 Runs)']);
xlabel('Number of Grown Trees');
ylabel('OOB Error');
saveas(gcf, 'Average_OOB_Error.png'); % Save figure

% Calculate and plot the average feature importance
avgFeatureImportance = mean(allFeatureImportance, 2); % Average across all runs
figure;
bar(avgFeatureImportance);
xlabel('Feature Index');
ylabel('Average Importance');
xticks(1:length(metricNames));
xticklabels(metricNames);
set(gca, 'XTickLabel', get(gca, 'XTickLabel'), 'FontSize', 16);
xtickangle(45);
title('Average Feature Importance (20 Runs)');
saveas(gcf, 'Average_Feature_Importance.png'); % Save figure

% Display the average accuracy across all runs
disp(['Average Accuracy across 20 runs: ', num2str(avgAccuracy), '%']);
disp(['Standard Deviation of Accuracy: ', num2str(stddevAccuracy), '%']);
