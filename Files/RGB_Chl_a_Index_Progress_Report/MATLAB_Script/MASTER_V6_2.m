% The code in this pipeline was built using code from the following paper
% as the foundation:
%
% Akkaynak et al
% Use of commercial off-the-shelf (COTS) digital cameras for scientific data acquisition  
% and scene-specific color calibration, Journal of the Optical Society of America A, Vol. 
% 31, No.2, February 2014
% 
%
% ************************************************************************

% Master Pipeline: Batch Color Calibration & Coral Segmentation V6.2
clc; clear; close all force; warning off;

% --- 1. SETTINGS & DIRECTORIES ---
tiffFolder = '/Users/Boaz/Documents/CHL_RGB_INDEX_THESIS/PROJECT/19_7_26_TIF';

if ~isfolder(tiffFolder)
    error('Directory not found. Please verify the path is correct.');
end

% Strict file gathering: Ignores duplicates, Mac hidden files, and previous outputs
allFiles = dir(tiffFolder);
fileNames = string({allFiles.name});

isTiff = endsWith(fileNames, ".tif", "IgnoreCase", true);
isNotHidden = ~startsWith(fileNames, "._");
isNotTransformed = ~startsWith(fileNames, "Transformed_"); 

valid_idx = isTiff & isNotHidden & isNotTransformed;
imageFiles = allFiles(valid_idx);
numImages = length(imageFiles);

fprintf('\n=== INITIALIZATION ===\n');
fprintf('Detected %d valid raw TIFF files.\n', numImages);
if numImages == 0, error('No raw TIFF files found. Check your directory.'); end

% Load DGK Color Chart Data from the 2014 COTS Article
load DGKColorChart.mat 
XYZ = getChartXYZvalues(chart, colors); 

% Physical Chart Layout
numRows = 6; numCols = 3; numPatches = numRows * numCols; boxSize = 10; 

% --- MAPPING ALIGNMENT ---
% Realigns the camera's 6x3 extraction order to the struct's 3x6 layout
patch_mapping = [6, 5, 4, 3, 2, 1, 12, 11, 10, 9, 8, 7, 18, 17, 16, 15, 14, 13]; 
displayGamma = 1.5; 

% --- 2. OPTIONAL: SAVE TRANSFORMED IMAGES ---
saveTransformed = 'Yes';
if strcmp(saveTransformed, 'Yes')
    outFolder = fullfile(tiffFolder, 'Color_Transformed_Images');
    if ~exist(outFolder, 'dir'), mkdir(outFolder); end
end

% --- 3. CACHE INITIALIZATION ---
cacheFilename = fullfile(tiffFolder, 'Chart_Corners_Cache.mat');
if isfile(cacheFilename)
    fprintf('Loading coordinate cache...\n'); load(cacheFilename, 'cornerCache');
else
    cornerCache = containers.Map('KeyType', 'char', 'ValueType', 'any');
end
prev_cornerPoints = []; processed_flags = false(numImages, 1);
transformed_images = cell(numImages, 1);
filenames = strings(numImages, 1); nubIDs = strings(numImages, 1); rotations = strings(numImages, 1);

% --- PHASE 1: COLOR CHART MAPPING & TRANSFORMATION ---
fprintf('\n=== PHASE 1: COLOR CALIBRATION ===\n');

for i = 1:numImages
    imgName = imageFiles(i).name; filenames(i) = string(imgName);
    currentFile = fullfile(tiffFolder, imgName);
    
    % Parse Nub ID and Rotation
    name_no_ext = imgName(1:end-4); parts = split(name_no_ext, '_');
    if length(parts) >= 2
        colony_part = parts{1}; nub_part = char(parts{2});
        if isletter(nub_part(end))
            nubIDs(i) = string(colony_part) + "_" + string(nub_part(1:end-1)); rotations(i) = string(nub_part(end));
        else
            nubIDs(i) = string(colony_part) + "_" + string(nub_part); rotations(i) = "A"; 
        end
    else
        nubIDs(i) = "Unknown"; rotations(i) = "Unknown";
    end

    I = im2double(imread(currentFile)); [imgH, imgW, ~] = size(I);
    
    % --- BATCH UI LOOP ---
    if isKey(cornerCache, imgName)
        cornerPoints = cornerCache(imgName); prev_cornerPoints = cornerPoints; processed_flags(i) = true;
        fprintf('[CACHED] %s: Corners loaded.\n', imgName);
    else
        validImage = false;
        while ~validImage
            f1 = figure(1); clf; imshow(imadjust(I, stretchlim(I), [])); 
            title(sprintf('Image %d/%d: Inspect Chart', i, numImages), 'FontSize', 14);
            set(gcf, 'Units', 'Normalized', 'OuterPosition', [0 0.1 0.5 0.8]);
            
            if ~isempty(prev_cornerPoints)
                w_patch = 100; h_patch = 100; w_total = numCols * w_patch; h_total = numRows * h_patch;
                fixedPoints  = [0, 0;  w_total, 0;  w_total, h_total;  0, h_total];
                tform = fitgeotrans(fixedPoints, prev_cornerPoints, 'projective');
                [X_cols, Y_rows] = meshgrid((0:numCols-1)*w_patch + w_patch/2, (0:numRows-1)*h_patch + h_patch/2);
                tempCenters = transformPointsForward(tform, [X_cols(:), Y_rows(:)]);
                
                hold on; plot(tempCenters(:,1), tempCenters(:,2), 'g+', 'MarkerSize', 10, 'LineWidth', 2);
                for p_idx = 1:numPatches
                    text(tempCenters(p_idx,1)+15, tempCenters(p_idx,2), num2str(p_idx), 'Color', 'g', 'FontSize', 12, 'FontWeight', 'bold');
                end
                title(sprintf('Image %d: Accept Previous Mask?', i), 'FontSize', 14);
                
                fprintf('\n--- Image %d: %s ---\n', i, imgName);
                commandwindow; 
                user_choice = input('Type ''y'' to ACCEPT previous mask, ''n'' for MANUAL, or ''s'' to SKIP: ', 's');
                if strcmpi(user_choice, 'y') || isempty(user_choice)
                    cornerPoints = prev_cornerPoints; validImage = true; processed_flags(i) = true;
                    cornerCache(imgName) = cornerPoints; save(cacheFilename, 'cornerCache'); break; 
                elseif strcmpi(user_choice, 's')
                    fprintf('Skipping Image %d...\n', i); break;
                end
                clf(f1); imshow(imadjust(I, stretchlim(I), []));
            else
                fprintf('\n--- Image %d: %s (NEW) ---\n', i, imgName);
                commandwindow; 
                user_choice = input('Press ENTER to process manually, or ''s'' to SKIP: ', 's');
                if strcmpi(user_choice, 's'), break; end
            end
            
            cornerNames = {'Top-Left', 'Top-Right', 'Bottom-Right', 'Bottom-Left'}; cornerPoints = zeros(4, 2);
            for k = 1:4
                title(sprintf('Zoom to %s corner, then press ENTER', cornerNames{k}), 'Color', 'k'); zoom on; pause; 
                title(sprintf('Click %s corner NOW', cornerNames{k}), 'Color', 'r', 'FontWeight', 'bold'); zoom off;
                [xk, yk] = ginput(1); cornerPoints(k, :) = [xk, yk];
                hold on; plot(xk, yk, 'ro', 'LineWidth', 2, 'MarkerSize', 10);
                text(xk+15, yk, num2str(k), 'Color', 'y', 'FontSize', 14, 'FontWeight', 'bold'); drawnow;
            end
            
            w_patch = 100; h_patch = 100; w_total = numCols * w_patch; h_total = numRows * h_patch;
            fixedPoints  = [0, 0;  w_total, 0;  w_total, h_total;  0, h_total];
            tform = fitgeotrans(fixedPoints, cornerPoints, 'projective');
            [X_cols, Y_rows] = meshgrid((0:numCols-1)*w_patch + w_patch/2, (0:numRows-1)*h_patch + h_patch/2);
            tempCenters = transformPointsForward(tform, [X_cols(:), Y_rows(:)]);
            
            f2 = figure(2); clf; imshow(imadjust(I, stretchlim(I), [])); hold on;
            plot(tempCenters(:,1), tempCenters(:,2), 'g+', 'MarkerSize', 10, 'LineWidth', 2);
            for p_idx = 1:numPatches
                text(tempCenters(p_idx,1)+15, tempCenters(p_idx,2), num2str(p_idx), 'Color', 'g', 'FontSize', 12, 'FontWeight', 'bold');
            end
            title('Validation: Check if patch centers (green +) are correct', 'FontSize', 14);
            
            commandwindow; 
            confirm_choice = input('Type ''y'' to ACCEPT, ''r'' to RETRY, or ''s'' to SKIP: ', 's');
            if strcmpi(confirm_choice, 'y') || isempty(confirm_choice)
                validImage = true; processed_flags(i) = true;
                cornerCache(imgName) = cornerPoints; save(cacheFilename, 'cornerCache'); prev_cornerPoints = cornerPoints; 
            elseif strcmpi(confirm_choice, 's')
                break;
            end
            if exist('f2', 'var') && isgraphics(f2), close(f2); end
        end
    end
    
    if processed_flags(i)
        w_patch = 100; h_patch = 100; w_total = numCols * w_patch; h_total = numRows * h_patch;
        fixedPoints  = [0, 0;  w_total, 0;  w_total, h_total;  0, h_total];
        tform = fitgeotrans(fixedPoints, cornerPoints, 'projective');
        [X_cols, Y_rows] = meshgrid((0:numCols-1)*w_patch + w_patch/2, (0:numRows-1)*h_patch + h_patch/2);
        imageCenters = transformPointsForward(tform, [X_cols(:), Y_rows(:)]);
        
        % --- 2014 COTS BUNDLE WHITE BALANCE INTEGRATION ---
        black_idx = 1; % Extraction index for Black (Top-Left)
        white_idx = 6; % Extraction index for White (Bottom-Left)
        
        whiteMask = false(imgH, imgW);
        blackMask = false(imgH, imgW);
        
        % Generate Black Mask
        cx = round(imageCenters(black_idx, 1)); cy = round(imageCenters(black_idx, 2));
        r_start = max(1, cy - floor(boxSize/2)); r_end = min(imgH, cy + floor(boxSize/2));
        c_start = max(1, cx - floor(boxSize/2)); c_end = min(imgW, cx + floor(boxSize/2));
        blackMask(r_start:r_end, c_start:c_end) = true;
        
        % Generate White Mask
        cx = round(imageCenters(white_idx, 1)); cy = round(imageCenters(white_idx, 2));
        r_start = max(1, cy - floor(boxSize/2)); r_end = min(imgH, cy + floor(boxSize/2));
        c_start = max(1, cx - floor(boxSize/2)); c_end = min(imgW, cx + floor(boxSize/2));
        whiteMask(r_start:r_end, c_start:c_end) = true;
        
        % Apply Akkaynak White Balance
        Iwb = whiteBalance(I, whiteMask, blackMask, 0.8);
        
        % Extract RGB from the *White Balanced* image
        RGB_extracted = zeros(numPatches, 3);
        for p = 1:numPatches
            cx = round(imageCenters(p, 1)); cy = round(imageCenters(p, 2));
            r_start = max(1, cy - floor(boxSize/2)); r_end = min(imgH, cy + floor(boxSize/2));
            c_start = max(1, cx - floor(boxSize/2)); c_end = min(imgW, cx + floor(boxSize/2));
            
            patchPixels = Iwb(r_start:r_end, c_start:c_end, :); 
            RGB_extracted(p, :) = squeeze(mean(mean(patchPixels, 1), 2));
        end
        
        % Reorder RGB values to match the XYZ struct order
        RGB_mapped = RGB_extracted(patch_mapping, :);
        
        % Derive T Matrix and Transform the White Balanced Image
        T = XYZ' * pinv(RGB_mapped)';
        Ixyz = reshape((T*reshape(Iwb,[imgH*imgW 3])')',[imgH imgW 3]); 
        Irgb = XYZ2ProPhoto(Ixyz); 
        
        Irgb(Irgb < 0) = 0; Irgb(Irgb > 1) = 1; 
        transformed_images{i} = Irgb;
        
        if strcmp(saveTransformed, 'Yes')
            imwrite(Irgb, fullfile(outFolder, ['Transformed_' imgName]));
        end
        fprintf('Calibrated: %s\n', imgName);
    end
end
if exist('f1', 'var') && isgraphics(f1), close(f1); end

% --- PHASE 2: BATCH CORAL SEGMENTATION ---
fprintf('\n=== PHASE 2: CORAL SEGMENTATION ===\n');

valid_idx = find(processed_flags);
if isempty(valid_idx), error('No images were calibrated. Aborting.'); end

firstImg = transformed_images{valid_idx(1)};
displayFirstImg = imadjust(firstImg, stretchlim(firstImg), [], displayGamma);
roiFig = figure('Name', 'Select Master ROI', 'WindowState', 'maximized');
imshow(displayFirstImg); title('Draw a rectangle over the coral nub. Double-click to finish.');
[~, crop_rect] = imcrop(roiFig); close(roiFig);
if isempty(crop_rect), error('ROI selection cancelled.'); end

mean_R = zeros(numImages, 1); mean_G = zeros(numImages, 1); mean_B = zeros(numImages, 1);
fig = figure('Name', 'Segmentation Review Monitor', 'Units', 'Normalized', 'OuterPosition', [0.05, 0.1, 0.9, 0.8]);

for idx = 1:length(valid_idx)
    i = valid_idx(idx); img = transformed_images{i};
    roi_rgb = imcrop(img, crop_rect); roi_gray = rgb2gray(roi_rgb);
    R_channel = double(roi_rgb(:,:,1)); G_channel = double(roi_rgb(:,:,2)); B_channel = double(roi_rgb(:,:,3));
    display_rgb = imadjust(roi_rgb, stretchlim(roi_rgb), [], displayGamma);
    
    threshold_level = graythresh(roi_gray);
    binary_mask = imbinarize(roi_gray, threshold_level); clean_mask = bwareaopen(binary_mask, 50); 
    mask_accepted = false; 
    
    while ~mask_accepted
        subplot(1,3,1); imshow(display_rgb); title('Original');
        subplot(1,3,2); imshow(clean_mask); title('Mask');
        
        segmented_preview = display_rgb; 
        segmented_preview(repmat(~clean_mask, [1 1 3])) = 0.5; 
        
        subplot(1,3,3); imshow(segmented_preview); title('Isolated Tissue');
        sgtitle(sprintf('Image %d/%d | Nub: %s | Rot: %s', i, numImages, nubIDs(i), rotations(i))); drawnow; 
        
        commandwindow; 
        fprintf('\n[ENTER] Accept | [ r ] Redraw ROI | [ t ] Change threshold | [ e ] Erase | [ a ] Add\n');
        user_choice = input('Select an option: ', 's');
        if isempty(user_choice)
            mask_accepted = true;
        elseif strcmpi(user_choice, 'r')
            tempFig = figure('Name', 'Redraw ROI for Current Image', 'WindowState', 'maximized');
            imshow(imadjust(img, stretchlim(img), [], displayGamma)); 
            title('Draw a NEW rectangle over the coral nub. Double-click to finish.');
            [~, new_rect] = imcrop(tempFig); close(tempFig);
            
            if ~isempty(new_rect)
                crop_rect = new_rect;
                roi_rgb = imcrop(img, crop_rect); roi_gray = rgb2gray(roi_rgb);
                R_channel = double(roi_rgb(:,:,1)); G_channel = double(roi_rgb(:,:,2)); B_channel = double(roi_rgb(:,:,3));
                display_rgb = imadjust(roi_rgb, stretchlim(roi_rgb), [], displayGamma);
                
                threshold_level = graythresh(roi_gray);
                binary_mask = imbinarize(roi_gray, threshold_level); clean_mask = bwareaopen(binary_mask, 50); 
            end
        elseif strcmpi(user_choice, 't')
            new_thresh = input('Enter new threshold (0.0 - 1.0): ');
            if isnumeric(new_thresh), clean_mask = bwareaopen(imbinarize(roi_gray, new_thresh), 50); end
        elseif strcmpi(user_choice, 'e')
            roi_poly = drawpolygon(); clean_mask(createMask(roi_poly)) = false; delete(roi_poly);
        elseif strcmpi(user_choice, 'a')
            roi_poly = drawpolygon(); clean_mask(createMask(roi_poly)) = true; delete(roi_poly);
        end
    end 
    mean_R(i) = mean(R_channel(clean_mask)); mean_G(i) = mean(G_channel(clean_mask)); mean_B(i) = mean(B_channel(clean_mask));
end
close(fig); 

% --- PHASE 3: AGGREGATION & FLAGGING ---
fprintf('\n=== PHASE 3: STATISTICS & EXPORT ===\n');

valid_nubIDs = nubIDs(processed_flags); uniqueNubs = unique(valid_nubIDs); numNubs = length(uniqueNubs);

nub_R_mean = zeros(numNubs, 1); nub_R_std = zeros(numNubs, 1);
nub_G_mean = zeros(numNubs, 1); nub_G_std = zeros(numNubs, 1);
nub_B_mean = zeros(numNubs, 1); nub_B_std = zeros(numNubs, 1);
flagged_nubs = strings(numNubs, 1);

for k = 1:numNubs
    idx = (nubIDs == uniqueNubs(k) & processed_flags); 
    nub_R_mean(k) = mean(mean_R(idx)); nub_R_std(k) = std(mean_R(idx));
    nub_G_mean(k) = mean(mean_G(idx)); nub_G_std(k) = std(mean_G(idx));
    nub_B_mean(k) = mean(mean_B(idx)); nub_B_std(k) = std(mean_B(idx));
    
    cv_R = nub_R_std(k) / nub_R_mean(k); cv_G = nub_G_std(k) / nub_G_mean(k); cv_B = nub_B_std(k) / nub_B_mean(k);
    if max([cv_R, cv_G, cv_B]) > 0.10, flagged_nubs(k) = "FLAG: High Variance"; else, flagged_nubs(k) = "OK"; end
end

% Export the raw values converted to true 16-bit integers
nubStatsTable = table(uniqueNubs, ...
    round(nub_R_mean * 65535), round(nub_G_mean * 65535), round(nub_B_mean * 65535), ...
    round(nub_R_std * 65535), round(nub_G_std * 65535), round(nub_B_std * 65535), flagged_nubs, ...
    'VariableNames', {'Nub_ID', 'MEAN_R_16bit', 'MEAN_G_16bit', 'MEAN_B_16bit', 'STD_R_16bit', 'STD_G_16bit', 'STD_B_16bit', 'Status_Flag'});

saveDir = tiffFolder; 
writetable(nubStatsTable, fullfile(saveDir, 'Nub_RGB_Stats.csv'));
fprintf('\nPipeline complete! Data saved to:\n %s\n', saveDir);