% 07/12/24

clear all
close all

% Read the text file into a table
file = 'allData_ZScored.txt';
data = readtable(file, 'Delimiter', '\t');

% Get unique combinations of columns 3 and 4
[uniqueCombinations, ~, idx] = unique(data(:, [3, 4]), 'rows');

% Initialize an empty table to store the averaged data
numMetrics = width(data) - 9;
averagedData = array2table(zeros(height(uniqueCombinations), numMetrics), 'VariableNames', data.Properties.VariableNames(10:end));
categories = cell(height(uniqueCombinations), 1);

% Loop through each unique combination and calculate the averages
for i = 1:height(uniqueCombinations)
    % Find the rows corresponding to the current unique combination
    rows = idx == i;
    
    % Calculate the average for each column, ignoring the first nine
    averages = mean(data{rows, 10:end}, 'omitnan');
    
    % Store the results in the averagedData table
    averagedData{i, :} = averages;
    
    % Store the category information
    categories{i} = sprintf('%s_%s', string(table2array(uniqueCombinations(i, 1))), string(table2array(uniqueCombinations(i, 2))));
end

% Create the final table with categories
finalAveragedData = [table(categories, 'VariableNames', {'Category'}), averagedData];

% Calculate the averages for each unique value in column 3
[uniqueCol3, ~, idxCol3] = unique(data(:, 3));
averagedDataCol3 = array2table(zeros(height(uniqueCol3), numMetrics), 'VariableNames', data.Properties.VariableNames(10:end));
categoriesCol3 = cell(height(uniqueCol3), 1);

for i = 1:height(uniqueCol3)
    % Find the rows corresponding to the current unique value in column 3
    rows = idxCol3 == i;
    
    % Calculate the average for each column, ignoring the first nine
    averages = mean(data{rows, 10:end}, 'omitnan');
    
    % Store the results in the averagedDataCol3 table
    averagedDataCol3{i, :} = averages;
    
    % Store the category information
    categoriesCol3{i} = string(table2array(uniqueCol3(i, 1)));
end

% Create the final table with categories defined by column 3
finalAveragedDataCol3 = [table(categoriesCol3, 'VariableNames', {'Category'}), averagedDataCol3];

% Calculate standard deviations for sorting
stdCol3 = std(table2array(finalAveragedDataCol3(:, 2:end)), 0, 1, 'omitnan');
stdComb = std(table2array(finalAveragedData(:, 2:end)), 0, 1, 'omitnan');

% Get the sorted indices based on standard deviations
[~, sortedIdxCol3] = sort(stdCol3, 'descend');
[~, sortedIdxComb] = sort(stdComb, 'descend');

% Sort the numeric data and update column names
sortedDataCol3 = table2array(finalAveragedDataCol3(:, 2:end));
sortedDataCol3 = sortedDataCol3(:, sortedIdxCol3);
sortedDataComb = table2array(finalAveragedData(:, 2:end));
sortedDataComb = sortedDataComb(:, sortedIdxComb);

% Optionally, write the averaged data to a new file
% writetable(finalAveragedData, 'averagedData_byCategory.txt', 'Delimiter', '\t');

% Display the averaged data in subplots
figure(1);
set(gcf, 'color', 'w');

% Upper subplot: categories defined by column 3
subplot(2, 1, 1);
imagesc(sortedDataCol3);
colormap(jet);
hcb1 = colorbar;
xlabel('Metrics');
title('Z Scored Averages by Salt Disregarding Concentrations');
set(gca, 'YTick', 1:length(categoriesCol3), 'YTickLabel', ...
    {'KCl', 'KNO_3', 'NH_4Cl', 'Na_2SO_3', 'Na_2SO_4', 'NaCl', 'NaNO_3'});
ylabel(hcb1, 'Z-Score Average by Category');

% Set x-tick labels to the original indices
set(gca, 'XTick', 1:numMetrics, 'XTickLabel', sortedIdxCol3);

% ---
% ---

% Lower subplot: categories defined by combinations of columns 3 and 4
subplot(2, 1, 2);
imagesc(sortedDataComb);
colormap(parula);
hcb2 = colorbar;
xlabel('Metrics',"Position",[25 40]);
title('Z Scored Averages by Salts and Concentrations (10%,30%,50%,70%,90%)','FontSize', 12);

% Custom y-tick positions
ytickPositions = [3, 8, 13, 18, 23, 28, 33];
ytickLabels = {'KCl', 'KNO_3', 'NH_4Cl', 'Na_2SO_3', 'Na_2SO_4', 'NaCl', 'NaNO_3'};

% Set the y-ticks and labels
set(gca, 'YTick', ytickPositions, 'YTickLabel', ytickLabels, 'FontSize', 12);
ylabel(hcb2, 'Z-Score Average by Category', 'FontSize', 12);

% Set x-tick labels to the original indices
set(gca, 'XTick', 1:numMetrics, 'XTickLabel', sortedIdxComb, 'FontSize', 12);

% Add dashed lines to the lower subplot
hold on;
plot([1 numMetrics], [5.5 5.5], 'k--');
plot([1 numMetrics], [10.5 10.5], 'k--');
plot([1 numMetrics], [15.5 15.5], 'k--');
plot([1 numMetrics], [20.5 20.5], 'k--');
plot([1 numMetrics], [25.5 25.5], 'k--');
plot([1 numMetrics], [30.5 30.5], 'k--');
plot([1 numMetrics], [35.5 35.5], 'k--');

% Identify columns with at least one NaN
nanCols = any(ismissing(data));

% Display indices of columns containing NaNs
nanColIndices = find(nanCols);
disp('Indices of columns containing at least one NaN:');
disp(nanColIndices);
