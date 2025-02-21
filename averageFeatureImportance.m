% Main parameters
numSeeds = 3; % Number of seeds for reproducibility
numTrees = 100; % Number of trees in the forest
maxDepth = 10; % Maximum depth of the trees
minLeafSize = 5; % Minimum leaf size
numMetricsToCheck = 47; % Check all metrics
numFeatures = round(sqrt(numMetricsToCheck)); % Number of features to consider at each split
numRuns = 20; % Number of runs for averaging

% Read the text file into a table
file = 'allData_Unscored_022025.txt';
data = readtable(file, 'Delimiter', '\t');

% Extract the relevant columns
salts = data{:, 3};
concentrations = data{:, 4};
metrics = data{:, 10:56};

% Convert salts and concentrations to strings
saltsStr = string(salts);
categories = categorical(saltsStr);

% Initialize array to hold feature importance for each run
allFeatureImportances = zeros(numRuns, size(metrics, 2));

for run = 1:numRuns
    % Split the data into training and test sets
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

    % Train the Random Forest model
    rfModel = TreeBagger(numTrees, trainData, trainLabels, ...
        'MaxNumSplits', maxDepth, ...
        'MinLeafSize', minLeafSize, ...
        'NumPredictorsToSample', numFeatures, ...
        'OOBPrediction', 'On', ...
        'Method', 'classification', ...
        'OOBPredictorImportance', 'On');

    % Store the feature importance for this run
    allFeatureImportances(run, :) = rfModel.OOBPermutedPredictorDeltaError;
end

% Calculate the average feature importance across all runs
averageFeatureImportance = mean(allFeatureImportances, 1);

% Plot the average feature importance
figure;
bar(averageFeatureImportance);
% title('Average Feature Importance Estimates over 20 Runs');
xlabel('Feature Index');
ylabel('Importance');
xticks(1:length(data.Properties.VariableNames(10:56)));
xticklabels(data.Properties.VariableNames(10:56));
set(gca, 'XTickLabel', get(gca, 'XTickLabel'), 'FontSize', 16);
xtickangle(45);

% Save the model and results
save('rfModel.mat', 'rfModel'); % This saves the last model; adjust as needed
save('averageFeatureImportance.mat', 'averageFeatureImportance');
