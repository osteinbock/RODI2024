% Read the output file from the previous script
outputFile = 'predictedEntries.txt';
data = readtable(outputFile, 'Delimiter', '\t');

% Convert relevant columns to strings if they are not already
data.Directory = string(data.Directory);
data.Filename = string(data.Filename);
data.Salt = string(data.Salt);
data.PredictedSalt = string(data.PredictedSalt);

% Get the number of samples, limited to 60 for testing
numSamples = 117; %min(height(data), 60);

% Create a VideoWriter object to write the movie
outputVideo = VideoWriter('C:/Users/as24cf/Desktop/predictionsMLP.mp4', 'MPEG-4');
outputVideo.FrameRate = 1; % 1 frame per second
open(outputVideo);

% Define a figure size that is a multiple of two
figureWidth = 1920;
figureHeight = 1080;

% Create a figure without border
figure('Units', 'pixels', 'Position', [100, 100, figureWidth, figureHeight], 'Color', 'black');

for i = 1:numSamples
    % Update the path to reflect the new directory structure
    imgPath = fullfile('C:/Users/as24cf/Desktop/RODI/RODI_new', data.Directory(i), data.Filename(i));
   
    % Check if the image file exists
    if ~isfile(imgPath)
        warning('File "%s" does not exist.', imgPath);
        continue;
    end
   
    img = rgb2gray(imread(imgPath));
    imgBin = (img > 70);

    % Find center of the largest blob
    labeledImage = bwlabel(imgBin);
    blobStats = regionprops(labeledImage, 'Area', 'Centroid');
    [~, idx] = max([blobStats.Area]);
    ct = blobStats(idx).Centroid;
    
    t = max(1, round(ct(2)) - 1500);
    b = min(size(img, 1), round(ct(2)) + 1500);
    l = max(1, round(ct(1)) - 1500);
    r = min(size(img, 2), round(ct(1)) + 1500);
   
    img = img(t:b, l:r);
   
    % Resize while maintaining aspect ratio
    [imgHeight, imgWidth] = size(img);
    aspectRatio = imgWidth / imgHeight;
    if (aspectRatio > (figureWidth / figureHeight))
        img = imresize(img, [NaN, figureWidth], 'bilinear'); % Resize based on width
    else
        img = imresize(img, [figureHeight, NaN], 'bilinear'); % Resize based on height
    end
   
    % Center the image within the figure size
    [imgHeight, imgWidth] = size(img);
    verticalPadding = floor((figureHeight - imgHeight) / 2);
    horizontalPadding = floor((figureWidth - imgWidth) / 2);
    paddedImg = padarray(img, [verticalPadding, horizontalPadding], 0, 'both');
    % If the image still doesn't fill the entire figure area, add more padding
    if size(paddedImg, 1) < figureHeight
        paddedImg = padarray(paddedImg, [figureHeight - size(paddedImg, 1), 0], 0, 'post');
    end
    if size(paddedImg, 2) < figureWidth
        paddedImg = padarray(paddedImg, [0, figureWidth - size(paddedImg, 2)], 0, 'post');
    end
   
    % Display the image using imagesc
    imagesc(paddedImg,[40 0.95*max(max(paddedImg))]);
    colormap(gray);
    axis off;
    set(gca, 'Position', [0 0 1 1]); % Remove any margins
   
    % True salt and concentration
    trueSalt1 = sprintf('True Salt:');
    trueSalt2 = sprintf('%s', data.Salt(i));
    trueConc1 = sprintf('True Concentration:');
    trueConc2 = sprintf('%d%%', data.Concentration(i));
    predictedSalt1 = sprintf('Predicted Salt:');
    predictedSalt2 = sprintf('%s', data.PredictedSalt(i));
    predictedConc1 = sprintf('Predicted Concentration:');
    predictedConc2 = sprintf('%d%%', data.PredictedConcentration(i));
    folderName = sprintf('Folder: %s', data.Directory(i));
    fileName = sprintf('File: %s', data.Filename(i));
   
    % Determine colors for the predicted text
    saltColor = 'green';
    concColor = 'green';
    waitTime = 0.3; % Default wait time
    if data.Salt(i) ~= data.PredictedSalt(i) && data.Concentration(i) ~= data.PredictedConcentration(i)
        saltColor = 'red';
        concColor = 'red';
        waitTime = 2.5; % Increased wait time for wrong predictions
    elseif data.Salt(i) ~= data.PredictedSalt(i)
        saltColor = 'red';
        waitTime = 2.5; % Increased wait time for wrong predictions
    elseif data.Concentration(i) ~= data.PredictedConcentration(i)
        concColor = 'red';
        waitTime = 2.5; % Increased wait time for wrong predictions
    end
   
    % Show the true salt and concentration in white font on top
    xspc1=170;
    xspc2=280;
    text(600, 80, trueSalt1, 'Color', 'white', 'FontSize', 16, 'FontWeight', 'bold', 'BackgroundColor', 'black');
    text(600+xspc1, 80, trueSalt2, 'Color', 'white', 'FontSize', 16, 'FontWeight', 'bold', 'BackgroundColor', 'black');
    text(1000, 80, trueConc1, 'Color', 'white', 'FontSize', 16, 'FontWeight', 'bold', 'BackgroundColor', 'black');
    text(1000+xspc2, 80, trueConc2, 'Color', 'white', 'FontSize', 16, 'FontWeight', 'bold', 'BackgroundColor', 'black');
    text(600, 125, predictedSalt1, 'Color', saltColor, 'FontSize', 16, 'FontWeight', 'bold', 'BackgroundColor', 'black');
    text(600+xspc1, 125, predictedSalt2, 'Color', saltColor, 'FontSize', 16, 'FontWeight', 'bold', 'BackgroundColor', 'black');
    text(1000, 125, predictedConc1, 'Color', concColor, 'FontSize', 16, 'FontWeight', 'bold', 'BackgroundColor', 'black');
    text(1000+xspc2, 125, predictedConc2, 'Color', concColor, 'FontSize', 16, 'FontWeight', 'bold', 'BackgroundColor', 'black');
%     % Show folder name and file name in white font at the bottom
%     text(700, 1000, folderName, 'Color', 'white', 'FontSize', 8, 'FontWeight', 'bold', 'BackgroundColor', 'black', 'Interpreter', 'none');
%     text(700, 1050, fileName, 'Color', 'white', 'FontSize', 8, 'FontWeight', 'bold', 'BackgroundColor', 'black', 'Interpreter', 'none');
    text(735, 1050, 'Multi-Layer Perceptron Neural Network, Batista et al.', 'Color', 'white', 'FontSize', 10, 'FontWeight', 'bold', 'BackgroundColor', 'black', 'Interpreter', 'none');
   
    % Pause for the determined wait time
    pause(waitTime);
   
    % Get the frame and write it to the video
    frame = getframe(gcf); % Get the entire figure
    frame = imresize(frame.cdata, [figureHeight, figureWidth]); % Resize to match figure size
    writeVideo(outputVideo, frame);
end

% Close the video file
close(outputVideo);

fprintf('Movie saved as predictions.mp4\n');
