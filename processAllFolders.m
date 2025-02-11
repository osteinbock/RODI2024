% Clear previous variables and close figures
clear;
clc;

% List of folders and corresponding script names
folders = {'Na2SO490','NaNO370','NaNO390'};  % Add your folder names here

% Number of folders
numFolders = length(folders);

% Loop through each folder
for i = 1:5
    % Retrieve the folder and script names
    folders = {'Na2SO490','NaNO370','NaNO390'};
    currentFolder = folders{i};
    scriptName = [currentFolder, '.m'];
    
    % Check if folder exists
    if isfolder(currentFolder)
        % Change to the current folder
        cd(currentFolder);
        
        % Check if script exists in the folder
        if exist(scriptName, 'file') == 2
            % Run the script
            run(scriptName);
        else
            disp(['Script ', scriptName, ' not found in ', currentFolder]);
        end
        
        % Return to the original directory
        cd('..');
    end
end
