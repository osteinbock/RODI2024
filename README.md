Execution of MATLAB files:

1. RODI_MainProcessing.m: This script processes a sequence of images to analyze dried salt drops. It reads images, applies thresholds for binary conversion, detects and crops edges, and calculates various metrics such as area, eccentricity, and intensity variations. Results are saved to 'results.txt' and renamed manually according to the salt name and concentration.

2. joinResults.m: This MATLAB script reads data from the 35 different ‘result’ files, extracts and processes the salt name and concentration from the file names, adds these as new columns to the data, and combines all the processed data into a single table. The combined table is then optionally saved to a new file. A ‘Quality’ column is manually added with a default value of 1. A very small number of entries are then set to 0, if the corresponding deposit pattern is strongly atypical (e.g. significant splashing). This process is discussed in the main manuscript.

3. zScoring.m: This MATLAB script reads the dataset from the text file saved after executing joinResults.m, excludes rows where the 'Quality' column is zero. It then z-scores all columns except the first nine, creates a new table with the z-scored data, optionally saves it to a new file, and displays a heatmap of the z-scored data.

4. categoryMeans.m: This MATLAB script processes the dataset by reading it from the text file containing the z-scored data, calculating averages for specific metric columns based on unique combinations of categories (salts and concentrations) in the data, and displaying the results in two subplots. The upper subplot shows averages by salt type, disregarding concentrations, while the lower subplot shows averages by unique salt-concentration combinations, visualized using heatmaps.

5. categoryMeans_sorted.m: This MATLAB script processes data from the tab-delimited text file of the z-scored data, calculates the average of specific columns grouped by unique combinations of values in columns 3 (salt names) and 4 (concentrations), and then creates two sets of averaged data: one by the combination of columns 3 and 4, and another by unique values in column 3. It sorts the data based on standard deviation, displays the results as heatmaps in two subplots, and identifies columns containing NaN values.

6. correlationsTree.m: This MATLAB script reads the tab-delimited data file of the z-scored data, computes the correlation matrix of selected columns, and visualizes the correlation matrix in multiple forms: original, reordered by average absolute correlation, and reordered by hierarchical clustering. It also creates a dendrogram to represent the hierarchical clustering of the metrics.

7. MLP_4e.m: This MATLAB script reads the tab-separated text file of the z-scored data, extracts relevant columns (salts, concentrations, and metrics), and processes the data for classification. It runs a neural network (Multilayer Perceptron) training process 20 times, each time splitting the data into training and testing sets, handling missing values, normalizing data, and calculating accuracy and confusion matrices for each run. Finally, it computes the average accuracy, standard deviation, and displays an average confusion matrix.

8. rf_accuracy.m: This MATLAB script performs classification of data using Random Forest. It reads a dataset (the z-scored data), splits it into training and test sets (70%/30%), and trains a Random Forest model to predict categories based on given metrics. The script computes accuracies, accumulates confusion matrices, and calculates the mean and standard deviation of accuracy across multiple runs (20). It generates confusion matrices for both cases (salts + concentrations, and salts only), and displays them with the average accuracy.

9. XGBoost_OnlySalts.m: This MATLAB script runs the XGBoost model via Python to classify data over 20 repeated runs, calculates and accumulates the average confusion matrix, and computes the average accuracy and standard deviation based on 7 different salt categories. It processes the data (splitting it into training and test sets), trains the model, evaluates its performance, and displays the average confusion matrix with accuracy statistics. The script requires Python 3.8, as indicated by the path to the Python executable. 

10. XGBoost_SaltsAndConcs.m: This script is similar to the previous one, XGBoost_OnlySalts.m, but performs the training and classification based on 7 different salts as well as 5 different concentrations for each salt.

11. averageFeatureImportance.m: This MATLAB script trains a Random Forest classifier on z-scored data, with the goal of evaluating feature importance over multiple runs. It splits the data into training and test sets, trains the model on the training data, and computes the feature importance using out-of-bag error. The script averages the feature importance across multiple runs and then plots the results. It also saves the trained model and the averaged feature importance.

12. moviePredict1.m: This MATLAB script processes a dataset from a text file, splits it into training and test sets, and trains a neural network model to predict salt types and concentrations based on given metrics. It handles missing data, normalizes features, and applies categorical labels, while using advanced training options such as early stopping and adaptive learning. After training, the script classifies the test set, selects random test entries, and saves the results (predictions and corresponding information) to a text file.

13. moviePredict2.m: This MATLAB script generates a video displaying images along with predicted and true labels (salt type and concentration) for each image based the results saved after executing moviePredict1.m. It processes up to 117 samples, visualizes the results with annotations, and saves the output as a video file (predictionsMLP.mp4). The images are resized and padded to fit a defined figure size, and the script includes conditional color coding for correct or incorrect predictions.

14. overFittingTest.m: This MATLAB script trains a Random Forest model on the z-scored data to predict salt types. It splits the data into training and testing sets, trains the model with parameters aimed at reducing overfitting, evaluates the model's performance using out-of-bag error and feature importance, and saves the model and results. While feature importance is analyzed, this script does not perform explicit feature selection based on correlation.

15. processAllFolders.m: This MATLAB script loops through a list of specified folders, checks if each folder exists, and attempts to run a corresponding script (named after the folder). If the script exists, it is executed; otherwise, a message is displayed. The script ensures that it returns to the original directory after processing each folder.

This repository also contains several obj files for 3D printing small components used in the construction of RODI (see SI file provided along with our 2025 paper in Digital discovery for details)


 
