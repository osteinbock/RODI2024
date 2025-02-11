% Read results from joinResults.m which in turn came from several runs of RODI_MainProcessing_062524.m 
% the data is then z-scored by metric
% 07/12/24

clear all
close all

% Read the text file into a table
file = 'allData_Unscored_092324.txt';
data = readtable(file, 'Delimiter', '\t');


% Exclude rows where Quality is equal to zero
data = data(data.Quality ~= 0, :);

% Replace NaN values with zeros in numeric columns only
numericData = data{:, 10:end};

% Z-score all columns except the first nine
zScoredData = numericData*0;
for i = 1:size(numericData, 2)
    zScoredData(:, i) = (numericData(:, i) - mean(numericData(:, i), 'omitnan')) ./ std(numericData(:, i), 'omitnan');
end

% Create a new table with z-scored columns
zScoredTable = [data(:, 1:9), array2table(zScoredData, 'VariableNames', data.Properties.VariableNames(10:end))];

% Optionally, write the modified table to a new file
writetable(zScoredTable, 'allData_ZScored.txt', 'Delimiter', '\t');

% Display the modified data
imagesc(zScoredData, [-10 10]);
colormap(hot);
colorbar;
