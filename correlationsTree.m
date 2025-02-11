% 07/15/24

clear all
close all

% Set the background color for all figures to white
set(0, 'DefaultFigureColor', 'w');

% Read the text file into a table
file = 'allData_ZScored.txt';
data = readtable(file, 'Delimiter', '\t');

% Extract the 47 metrics columns (assuming they are from column 10 to column 56)
metrics = data{:, 10:56};

% Verify the number of columns
disp('Number of metrics columns:');
disp(size(metrics, 2));

% Determine the number of rows with NaN values
rowsWithNaN = any(isnan(metrics), 2);
numRowsWithNaN = sum(rowsWithNaN);
totalRows = size(metrics, 1);
percentageExcluded = (numRowsWithNaN / totalRows) * 100;

% Handle NaN values by computing the correlation matrix with 'Rows', 'complete'
correlationMatrix = corr(metrics, 'Rows', 'complete');

% Verify the size of the correlation matrix
disp('Size of the correlation matrix:');
disp(size(correlationMatrix));

% Compute the average absolute entry for each column, excluding the diagonal
n = size(correlationMatrix, 1);
avgAbsCorr = sum(abs(correlationMatrix) - eye(n), 1) / (n - 1);

% Get the sorted indices based on the average absolute correlation
[~, sortedIdx] = sort(avgAbsCorr, 'descend');

% Perform hierarchical clustering to reorder the correlation matrix
distances = pdist(abs(correlationMatrix), 'euclidean'); % Use absolute correlation for clustering
linkages = linkage(distances, 'average');  % Perform average linkage clustering
clustOrder = optimalleaforder(linkages, distances); % Get optimal leaf order

% Verify the linkage and clustering order
disp('Size of the linkage matrix:');
disp(size(linkages));
disp('Clustering order:');
disp(clustOrder);

% Create a figure for the original correlation coefficient matrix
figure;
imagesc(abs(correlationMatrix));
hcb1 = colorbar;
colormap(jet);
title(sprintf('Correlation Coefficient Matrix (%.2f%% rows excluded)', percentageExcluded));
xlabel('Metrics');
ylabel('Metrics');
ylabel(hcb1, 'abs(correlation)');

% Set axis labels as indices
set(gca, 'XTick', 1:n, 'XTickLabel', 1:n);
set(gca, 'YTick', 1:n, 'YTickLabel', 1:n);

% Create a separate figure for the reordered correlation coefficient matrix
figure;
sortedCorrelationMatrix = correlationMatrix(sortedIdx, sortedIdx);
imagesc(abs(sortedCorrelationMatrix));
hcb2 = colorbar;
colormap(jet);
title(sprintf('Reordered Correlation Coefficient Matrix (Sorted by Avg Abs Correlation) (%.2f%% rows excluded)', percentageExcluded));
xlabel('Metrics');
ylabel('Metrics');
ylabel(hcb2, 'abs(correlation)');

% Set axis labels as indices
set(gca, 'XTick', 1:n, 'XTickLabel', sortedIdx);
set(gca, 'YTick', 1:n, 'YTickLabel', sortedIdx);

% Create a figure for the hierarchical clustering reordered correlation coefficient matrix
figure;
%figure('Position',[0 100 2500 1000]);
clusteredCorrelationMatrix = correlationMatrix(clustOrder, clustOrder);
imagesc(abs(clusteredCorrelationMatrix));
hcb3 = colorbar;
colormap(jet);
title(sprintf('Reordered Correlation Coefficient Matrix (Hierarchical Clustering) (%.2f%% rows excluded)', percentageExcluded));
xlabel('Metrics','FontSize', 12);
%ylabel('Metrics','FontSize', 16);
ylabel(hcb3, 'abs(correlation)','FontSize', 12);

% Set axis labels as indices
set(gca, 'XTick', 1:n, 'XTickLabel', clustOrder, 'FontSize', 12);
set(gca, 'YTick', 1:n, 'YTickLabel', clustOrder, 'FontSize', 12, 'YTickLabelRotation', 0);


% % Adjust font size for better readability
% set(gca, 'FontSize', 10);

% Create a figure for the hierarchy tree
figure;
subplot(3,1,2);
[H, T, outperm] = dendrogram(linkages, 0, 'Labels', cellstr(num2str((1:n)')), 'Reorder', clustOrder);
arrayfun(@(h) set(h, 'LineWidth', 2.5, 'Color', [0 0 1]), H);
set(gca, 'XTick', 1:n, 'XTickLabel', clustOrder, 'FontSize', 12);
%title('Hierarchy Tree for Metrics');
%xlabel('Metrics Index');
ylabel('Distance');
