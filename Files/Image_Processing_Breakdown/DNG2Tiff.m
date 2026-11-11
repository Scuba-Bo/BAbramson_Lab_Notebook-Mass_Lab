%% Step 1 : DNG to TIF
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                % 
%   The goal is to take RAW camera data and produce two types of          %
%   viewable images:                                                      % 
%          1) TIFF files      (linear)                                            %
%          2) Compressed PNG files    (non-linear)                                    %

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Instructions:                                                         %
%   Change 'yourpath...' to the appropriate path on your computer that    %
%   contains the Git repo.                                                %
%                                                                         %
%   Do NOT include the subfolders (\dng, \tiff, etc.) here—they are built %
%   automatically with fullfile below.                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all; close all; clc;

% Example to 'YourPath...' :
% 'C:\Users\colorlab\Documents\GitHub\UWC_2025_Student_Repository\UW_Student_Repository\Underwater-colorimetry-main'
Path_to_your_repository = '/Users/Boaz/Documents/CHL_RGB_INDEX_THESIS/PROJECT';
addpath(genpath(Path_to_your_repository))
dngPath = fullfile(Path_to_your_repository, '/Ace_Pro_DNG_26_10_26');           % Folder containing .dng files
tiffSavePath = fullfile(Path_to_your_repository, '/Ace_Pro_TIF_26_10_26');     % Output folder for .tif files
CompresedPngPath = fullfile(Path_to_your_repository, '/Ace_Pro_CPNG_26_10_26'); % Output folder for compressed PNG files
stage = 4;
non_UI_path = '/camera-pipeline-nonUI-master';
cd(fullfile(Path_to_your_repository, non_UI_path))

% Convert all .dng files to linear .tif files                           
dng2tiff(dngPath, tiffSavePath, stage);

% Convert the .tif to compressed PNGs  
tiff2png(CompresedPngPath, tiffSavePath);
