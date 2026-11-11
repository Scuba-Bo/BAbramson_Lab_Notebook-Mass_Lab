% Master Pipeline: Batch Coral Segmentation (Versatile)
clc; clear; close all force; warning off;

% --- 1. SETTINGS & DIRECTORIES ---
imgFolder = '/Users/Boaz/Documents/CHL_RGB_INDEX_THESIS/PROJECT/Canvas_Example/Color_Transformed_Images'; % Path to your images
exportFolder = '/Users/Boaz/Documents/CHL_RGB_INDEX_THESIS/EXPORT/Canvas_Example_Export'; % Explicit path for the exported CSV

if ~isfolder(imgFolder)
    error('Image directory not found. Please verify the path is correct.');
end

% Detect files and filter out hidden ones
allFiles = dir(imgFolder);
isNotHidden = ~startsWith({allFiles.name}, "._");
validFiles = allFiles(isNotHidden & ~[allFiles.isdir]);

if isempty(validFiles)
    error('No files found in the directory.');
end

[~, ~, fileExt] = fileparts(validFiles(1).name);
extStr = upper(replace(fileExt, '.', '')); 

isTargetType = endsWith({validFiles.name}, fileExt, "IgnoreCase", true);
imageFiles = validFiles(isTargetType);

% Sort files chronologically by date/time
[~, sortIdx] = sort([imageFiles.datenum]);
imageFiles = imageFiles(sortIdx);

numImages = length(imageFiles);

% Create dedicated output folder
outFolderName = sprintf('%s_RGB_Data', extStr);
outFolderDir = fullfile(exportFolder, outFolderName);
if ~exist(outFolderDir, 'dir')
    mkdir(outFolderDir);
end

fprintf('\n=== INITIALIZATION ===\n');
fprintf('Detected %d valid %s files.\n', numImages, extStr);

% --- 2. CHECKPOINT LOADING & MASTER ROI ---
checkpointFile = fullfile(outFolderDir, sprintf('%s_checkpoint.mat', extStr));
load_checkpoint = false;

if exist(checkpointFile, 'file')
    fprintf('\n=== EXISTING PROGRESS FOUND ===\n');
    fprintf('[ 1 ] Resume processing (Start at next unmasked image)\n');
    fprintf('[ 2 ] Review/Refine from the beginning (Start at Image 1)\n');
    fprintf('[ 3 ] Jump to a specific image number to review\n');
    fprintf('[ 4 ] Restart completely (Erase previous progress)\n');
    
    action = input('Select an option [1]: ', 's');
    
    if strcmpi(action, '4')
        delete(checkpointFile);
        fprintf('Checkpoint deleted. Starting fresh.\n');
    else
        load_checkpoint = true;
        load(checkpointFile, 'saved_masks', 'saved_rects', 'last_used_rect', 'mean_R', 'mean_G', 'mean_B', 'nubIDs', 'filenames', 'rotations');
        
        resume_idx = find(cellfun(@isempty, saved_masks), 1);
        if isempty(resume_idx), resume_idx = numImages + 1; end
        
        if strcmpi(action, '2')
            i = 1;
        elseif strcmpi(action, '3')
            jump_val = input(sprintf('Enter image number (1 to %d): ', numImages));
            if isnumeric(jump_val) && jump_val >= 1 && jump_val <= numImages
                i = round(jump_val);
            else
                fprintf('Invalid input. Defaulting to resume.\n');
                i = resume_idx;
            end
        else
            i = resume_idx; % Default fallback is option 1
        end
    end
end

if ~load_checkpoint
    fprintf('\n=== PHASE 1: CORAL SEGMENTATION ===\n');
    firstImgPath = fullfile(imgFolder, imageFiles(1).name);
    firstImg = im2double(imread(firstImgPath));

    roiFig = figure('Name', 'Select Master ROI', 'WindowState', 'maximized');
    imshow(firstImg); 
    title('Draw a rectangle over the coral nub. Double-click to finish.');
    [~, global_crop_rect] = imcrop(roiFig); close(roiFig);
    if isempty(global_crop_rect), error('ROI selection cancelled.'); end
    
    % Initialize arrays
    mean_R = zeros(numImages, 1); mean_G = zeros(numImages, 1); mean_B = zeros(numImages, 1);
    filenames = strings(numImages, 1); nubIDs = strings(numImages, 1); rotations = strings(numImages, 1);
    saved_masks = cell(numImages, 1);
    saved_rects = cell(numImages, 1);
    last_used_rect = global_crop_rect;
    
    i = 1;
end

% --- 3. BATCH SEGMENTATION (WITH NAVIGATION & AUTO-RESUME) ---
if i <= numImages
    fig = figure('Name', 'Segmentation Review Monitor', 'Units', 'Normalized', 'OuterPosition', [0.05, 0.1, 0.9, 0.8]);
    active_thresh = []; 
end

while i <= numImages
    imgName = imageFiles(i).name; filenames(i) = string(imgName);
    currentFile = fullfile(imgFolder, imgName);
    
    % Parse Nub ID and Rotation
    name_no_ext = imgName(1:find(imgName=='.', 1, 'last')-1); 
    parts = split(name_no_ext, '_');
    
    % FIXED: Handle 'Transformed_' prefix
    if strcmpi(parts{1}, 'Transformed') && length(parts) >= 3
        colony_part = parts{2}; 
        nub_part = char(parts{3});
    elseif length(parts) >= 2
        colony_part = parts{1}; 
        nub_part = char(parts{2});
    else
        colony_part = "Unknown"; 
        nub_part = "Unknown";
    end
    
    % Extract rotation letter if present
    if ~strcmp(colony_part, "Unknown")
        if isletter(nub_part(end))
            nubIDs(i) = string(colony_part) + "_" + string(nub_part(1:end-1)); rotations(i) = string(nub_part(end));
        else
            nubIDs(i) = string(colony_part) + "_" + string(nub_part); rotations(i) = "A"; 
        end
    else
        nubIDs(i) = "Unknown"; rotations(i) = "Unknown";
    end

    img = im2double(imread(currentFile));
    
    if ~isempty(saved_rects{i})
        current_rect = saved_rects{i};
    else
        current_rect = last_used_rect;
    end
    
    roi_rgb = imcrop(img, current_rect); roi_gray = rgb2gray(roi_rgb);
    R_channel = double(roi_rgb(:,:,1)); G_channel = double(roi_rgb(:,:,2)); B_channel = double(roi_rgb(:,:,3));
    
    % Mask handling logic
    if ~isempty(saved_masks{i})
        clean_mask = saved_masks{i};
        if isempty(active_thresh)
            threshold_level = NaN; % Assign NaN so the title knows it was loaded from memory
        else
            threshold_level = active_thresh;
        end
    else
        if isempty(active_thresh)
            threshold_level = graythresh(roi_gray);
        else
            threshold_level = active_thresh;
        end
        binary_mask = imbinarize(roi_gray, threshold_level); 
        clean_mask = bwareaopen(binary_mask, 50); 
    end
    
    mask_accepted = false; 
    go_back = false;
    quit_early = false;
    
    while ~mask_accepted
        subplot(1,3,1); imshow(roi_rgb); title('Original');
        subplot(1,3,2); imshow(clean_mask); 
        
        % Dynamic mask title
        if isnan(threshold_level)
            title('Mask (Loaded from Memory)');
        elseif isempty(active_thresh)
            title(sprintf('Mask (Thresh: %.3f)', threshold_level));
        else
            title(sprintf('Mask (Thresh: %.3f - Locked)', active_thresh));
        end
        
        segmented_preview = roi_rgb; 
        segmented_preview(repmat(~clean_mask, [1 1 3])) = 0.5; 
        
        subplot(1,3,3); imshow(segmented_preview); title('Isolated Tissue');
        sgtitle(sprintf('Image %d/%d | Nub: %s | Rot: %s', i, numImages, nubIDs(i), rotations(i))); drawnow; 
        
        commandwindow; 
        fprintf('\n[ENTER] Accept | [ b ] Back | [ n ] Skip to Next Unmasked | [ r ] Redraw ROI | [ t ] Change threshold | [ e ] Erase | [ a ] Add | [ q ] Quit & Save\n');
        user_choice = input('Select an option: ', 's');
        
        if isempty(user_choice)
            mask_accepted = true;
            saved_masks{i} = clean_mask;
            saved_rects{i} = current_rect;
            last_used_rect = current_rect;
        elseif strcmpi(user_choice, 'q')
            fprintf('\nStopping early. Saving checkpoint...\n');
            mask_accepted = true;
            quit_early = true;
        elseif strcmpi(user_choice, 'b')
            mask_accepted = true;
            go_back = true;
        elseif strcmpi(user_choice, 'n')
            % Find the next unmasked image ahead of the current index
            next_unmasked = find(cellfun(@isempty, saved_masks));
            next_unmasked = next_unmasked(next_unmasked > i);
            if ~isempty(next_unmasked)
                mask_accepted = true;
                i = next_unmasked(1) - 1; % Subtract 1 because the main loop adds 1
            else
                fprintf('No unmasked images left ahead!\n');
            end
        elseif strcmpi(user_choice, 'r')
            tempFig = figure('Name', 'Redraw ROI for Current Image', 'WindowState', 'maximized');
            imshow(img);
            title('Draw a NEW rectangle over the coral nub. Double-click to finish.');
            [~, new_rect] = imcrop(tempFig); close(tempFig);
            
            if ~isempty(new_rect)
                current_rect = new_rect;
                roi_rgb = imcrop(img, current_rect); roi_gray = rgb2gray(roi_rgb);
                R_channel = double(roi_rgb(:,:,1)); G_channel = double(roi_rgb(:,:,2)); B_channel = double(roi_rgb(:,:,3));
                
                if isempty(active_thresh)
                    threshold_level = graythresh(roi_gray);
                else
                    threshold_level = active_thresh;
                end
                clean_mask = bwareaopen(imbinarize(roi_gray, threshold_level), 50); 
            end
        elseif strcmpi(user_choice, 't')
            new_thresh = input('Enter new threshold (0.0 - 1.0): ');
            if isnumeric(new_thresh) && ~isempty(new_thresh)
                active_thresh = new_thresh; 
                threshold_level = active_thresh; 
                clean_mask = bwareaopen(imbinarize(roi_gray, active_thresh), 50); 
            end
        elseif strcmpi(user_choice, 'e')
            roi_poly = drawpolygon('Color', 'r'); clean_mask(createMask(roi_poly)) = false; delete(roi_poly);
        elseif strcmpi(user_choice, 'a')
            roi_poly = drawpolygon('Color', 'g'); clean_mask(createMask(roi_poly)) = true; delete(roi_poly);
        end
    end 
    
    if quit_early
        save(checkpointFile, 'saved_masks', 'saved_rects', 'last_used_rect', 'mean_R', 'mean_G', 'mean_B', 'nubIDs', 'filenames', 'rotations');
        break; 
    elseif go_back
        i = max(1, i - 1); 
    else
        mean_R(i) = mean(R_channel(clean_mask)); 
        mean_G(i) = mean(G_channel(clean_mask)); 
        mean_B(i) = mean(B_channel(clean_mask));
        
        save(checkpointFile, 'saved_masks', 'saved_rects', 'last_used_rect', 'mean_R', 'mean_G', 'mean_B', 'nubIDs', 'filenames', 'rotations');
        
        i = i + 1; 
    end
end

if exist('fig', 'var') && isvalid(fig)
    close(fig); 
end

% --- 4. STATISTICS & EXPORT ---
fprintf('\n=== PHASE 2: STATISTICS & EXPORT ===\n');

completed_idx = find(~cellfun(@isempty, saved_masks));

if isempty(completed_idx)
    fprintf('No images processed yet. Exiting without saving CSV.\n');
    return;
end

c_nubIDs = nubIDs(completed_idx);
c_mean_R = mean_R(completed_idx);
c_mean_G = mean_G(completed_idx);
c_mean_B = mean_B(completed_idx);

uniqueNubs = unique(c_nubIDs); numNubs = length(uniqueNubs);

nub_R_mean = zeros(numNubs, 1); nub_R_std = zeros(numNubs, 1);
nub_G_mean = zeros(numNubs, 1); nub_G_std = zeros(numNubs, 1);
nub_B_mean = zeros(numNubs, 1); nub_B_std = zeros(numNubs, 1);
flagged_nubs = strings(numNubs, 1);

for k = 1:numNubs
    idx = (c_nubIDs == uniqueNubs(k)); 
    nub_R_mean(k) = mean(c_mean_R(idx)); nub_R_std(k) = std(c_mean_R(idx));
    nub_G_mean(k) = mean(c_mean_G(idx)); nub_G_std(k) = std(c_mean_G(idx));
    nub_B_mean(k) = mean(c_mean_B(idx)); nub_B_std(k) = std(c_mean_B(idx));
    
    cv_R = nub_R_std(k) / nub_R_mean(k); cv_G = nub_G_std(k) / nub_G_mean(k); cv_B = nub_B_std(k) / nub_B_mean(k);
    if max([cv_R, cv_G, cv_B]) > 0.10, flagged_nubs(k) = "FLAG: High Variance"; else, flagged_nubs(k) = "OK"; end
end

if strcmp(extStr, 'JPG') || strcmp(extStr, 'JPEG')
    nubStatsTable = table(uniqueNubs, ...
        round(nub_R_mean * 255), round(nub_G_mean * 255), round(nub_B_mean * 255), ...
        round(nub_R_std * 255), round(nub_G_std * 255), round(nub_B_std * 255), ...
        round(nub_R_mean * 65535), round(nub_G_mean * 65535), round(nub_B_mean * 65535), ...
        round(nub_R_std * 65535), round(nub_G_std * 65535), round(nub_B_std * 65535), flagged_nubs, ...
        'VariableNames', {'Nub_ID', 'MEAN_R_8bit', 'MEAN_G_8bit', 'MEAN_B_8bit', 'STD_R_8bit', 'STD_G_8bit', 'STD_B_8bit', ...
                          'MEAN_R_16bit', 'MEAN_G_16bit', 'MEAN_B_16bit', 'STD_R_16bit', 'STD_G_16bit', 'STD_B_16bit', 'Status_Flag'});
else
    nubStatsTable = table(uniqueNubs, ...
        round(nub_R_mean * 65535), round(nub_G_mean * 65535), round(nub_B_mean * 65535), ...
        round(nub_R_std * 65535), round(nub_G_std * 65535), round(nub_B_std * 65535), flagged_nubs, ...
        'VariableNames', {'Nub_ID', 'MEAN_R_16bit', 'MEAN_G_16bit', 'MEAN_B_16bit', 'STD_R_16bit', 'STD_G_16bit', 'STD_B_16bit', 'Status_Flag'});
end

timestamp = char(datetime('now', 'Format', 'yyyyMMdd_HHmmss'));
csvFileName = sprintf('%s_RGB_Data_%s.csv', extStr, timestamp);

writetable(nubStatsTable, fullfile(outFolderDir, csvFileName));
fprintf('\nPipeline complete! Data exported for %d images.\nSaved to: %s\n', length(completed_idx), fullfile(outFolderDir, csvFileName));