---
layout: post
title: "RGB/Chl-a Image Processing Breakdown"
date: '2026-11-11'
categories: Method Development
tags: Image Processing, Color Calibration, Segmentation, MATLAB, RGB, Chlorophyll-a
---

* Boaz Abramson - University of Haifa - Mass Lab & Color Lab
* **Supervisors:** Prof. Tali Mass & Prof. Derya Akkaynak
* **Date:** 11/11/26

## RGB/Chl-a Image Processing Breakdown

---

### 1. File Naming Scheme & DNG Conversion

1. **Prefix & Rotation Labeling:** Following RAW image collection (4 per coral nub sample), each image file was given a prefix label according to the nub ID and image rotation number. This is important, as this file naming scheme is integrated into the overall systematics of the image processing workflow.
   * *Example:* `A2_3B_MG_8948.CR2` represents *Acropora* colony 2 (`A2`), nub 3, second image/rotation (`3B`).
2. **RAW to DNG Conversion:** RAW images were converted to DNG files using Adobe DNG Converter (DNG 1.6 backward version, linear demesaiced, uncompressed, no lossy compression, no embedded original RAW file).
3. **DNG to TIF Conversion:** DNG images were converted to TIF using the `DNG2Tiff` script from the Underwater Colorimetry course (2025-2026).
   * *Mac Compatibility Note:* To ensure Mac compatibility, swap the `dng_validate` executable within the `/camera-pipeline-nonUI-master/dngOneExeSDK` pathway for the Mac version and change the system commands to use forward slashes (`/`).

---

### 2. Color Transformation

**Script:** `Master_V6_2_FixedVisual.m` (Built with the COTS article demo code; Akkaynak et al., 2014)

#### 2.1 Semi-automatic Patch Target Selection
* The script prompts the user to select the 4 corners of the DGK color chart (Top-Left/Black, Top-Right/Brown, Bottom-Right/Maroon, Bottom-Left/White). 
* This mask is saved and applied to subsequent images to save time, but for each image it must be reviewed and accepted.
* *Note:* The UI preview is contrast-stretched for visualization only. Because the grayscale patches are oversized, the user clicks the center of the black and white patches rather than their true outer edges. Target locations are saved to `Chart_Corners_Cache.mat` to bypass manual selection on re-runs.

#### 2.2 White Balancing
* Executed before deriving the color matrix via:
  
  `Iwb = whiteBalance(I, whiteMask, blackMask, 0.8)`

* 11x11 pixel bounding boxes (121 pixels total) are generated on Patch 1 (Black, `blackMask`) and Patch 6 (White, `whiteMask`). The RGB values from these patches are averaged.
* For each RGB channel, the mean of the black patch is subtracted across the entire image. Remaining intensities are linearly scaled so the white patch mean equals 0.8 (80% reflectance). This is done to avoid highlight clipping, but may need to be adjusted even further.

#### 2.3 RGB Extraction
* The script samples 11x11 pixel arrays (`patchPixels`) from the centers of all 18 patches on the white-balanced image (`Iwb`).
* Calculates the mean R, G, and B values for each patch to populate an 18x3 matrix (`RGB_extracted`).
* Because `RGB_extracted` extracts sequentially as 6 rows x 3 columns but the `DGKColorChart.mat` reference XYZ data is ordered as 3x6, the data is re-indexed using a permutation vector:
  
  `patch_mapping = [6, 5, 4, 3, 2, 1, 12, 11, 10, 9, 8, 7, 18, 17, 16, 15, 14, 13]`
  
  This aligns the camera RGB rows 1:1 with the reference XYZ rows as `RGB_mapped`.

#### 2.4 Linear Color Transformation Matrix (T) Derivation
* With 18 patches on the color chart, the system is overdetermined and it is necessary to implement an ordinary least squares (OLS) regression to find the line of best fit.
* The script computes the 3x3 linear color transformation matrix `T` mapping white-balanced camera RGB to CIE 1931 XYZ using the Moore-Penrose pseudoinverse (`pinv`), solving the overdetermined 18-patch system via ordinary least squares:

  `T = XYZ' * pinv(RGB_mapped)'`

* The script reshapes `Iwb` into a 2D pixel list of dimensions `(imgH * imgW) x 3`, applies the linear transformation `T`, and reshapes the output back into a 3D image array `Ixyz` (`imgH x imgW x 3`).

#### 2.5 ProPhoto RGB Conversion
* The script passes `Ixyz` into `XYZ2ProPhoto(Ixyz)` to transform the image from CIE XYZ into the ProPhoto RGB space (`Irgb`).
* Values are clamped (values `< 0` set to `0`; values `> 1` set to `1`).
* Finally, it exports the calibrated image as a TIFF (`Transformed_<imgName>`) into the `Color_Transformed_Images` directory within the original TIFF folder.

---

### 3. Image Segmentation

While the `Master_V6_2_FixedVisual.m` script also includes a segmentation section, it is outdated. Instead, the updated `Basic_Segmentation_V6.m` script is used. The updated script allows the user to save their work, quit, and return at a later time, which is essential when working with a large dataset (348 images per format). In the future, this will all be consolidated into one clean workflow.

#### 3.1 Directory Setup
The user chooses the input folder with the images and the export folder for the `.csv` file.

#### 3.2 Checkpoint Scan
The script scans the output folder for an existing `<EXT>_checkpoint.mat` file containing saved cell arrays and vectors (`saved_masks`, `saved_rects`, `nubIDs`, etc.). If found, an interactive console menu allows the operator to:
1. `[ 1 ]` Resume processing automatically at the first unmasked image.
2. `[ 2 ]` Review or refine masks sequentially starting from Image 1.
3. `[ 3 ]` Jump directly to a specific image index for targeted inspection.
4. `[ 4 ]` Delete the checkpoint file and initialize a fresh segmentation run.

#### 3.3 Master ROI & Semi-Automated Otsu Binarization
On a fresh run, the user draws a master bounding box (`last_used_rect`) over the coral nub. The calibrated ROI is cropped, converted to grayscale, and evaluated via Otsu's method (`threshold_level = graythresh(roi_gray)`) to generate a baseline threshold separating tissue from background. Usually, this needs manual adjustment.

#### 3.4 Interactive Segmentation Quality Control
Renders a 3-panel inspection display showing:
1. The `roi_rgb` crop
2. The binary `clean_mask` (annotated with the threshold value)
3. An isolated tissue preview where background pixels (`~clean_mask`) are masked to neutral gray (`0.5`).

The operator validates or refines the segmentation using eight keyboard controls:

| Key Control | Action | Function |
| :--- | :--- | :--- |
| `[ENTER]` | Accept | Commits mask, updates saved data, and advances to next image. |
| `[b]` / `[n]` | Back / Skip | Go back one image or skip ahead to the next unmasked image. |
| `[r]` | Redraw ROI | Opens full image to draw a new bounding box ROI. |
| `[t]` | Change & Lock Threshold | Prompts operator to select new threshold (0 - 1.0), locked for subsequent images until changed. |
| `[e]` / `[a]` | Erase / Add | Activates interactive freehand polygon tool for manual pixel erasure (red) or addition (green). |
| `[q]` | Quit & Save | Saves work to checkpoint file and exits gracefully. |

#### 3.5 Coral Tissue RGB Averaging & Export
* After accepting a mask, the script calculates the mean R, G, and B channel values of each individual image and saves them to `<EXT>_checkpoint.mat` before advancing to the next image.
* Upon finishing the session, the script calculates the average RGB, standard deviation, and coefficient of variation across the four images of each nub.
* If the coefficient of variation exceeds 10%, it is flagged for **"High Variance"**.
* All values are exported in a time-stamped `.csv` file to the export folder. The `.csv` file also indicates whether the input files were `JPG`, `RAW`, or `CAL` (calibrated TIFF).

---

### Supplemental: Future Adjustments

Key pipeline improvements planned for future versions:

1. **Full Patch Sampling:** Currently, the script samples 11x11 pixels (121 pixels) per patch. Future iterations will sample each color patch across its full surface area.
2. **Segment Anything Implementation:** Transitioning from Otsu binarization and manual polygon edits to a Segment Anything Model (SAM) approach to enhance segmentation consistency.
3. **Integrated Sanity Checks:** Incorporating comprehensive automated quality control and validation sanity checks directly into the processing pipeline.

---

### Reference & MATLAB Scripts
* **Foundational Paper & COTS Demo Code:**
  Akkaynak, D., Treibitz, T., Shron, B., & Gurfil, P. (2014). *Use of commercial off-the-shelf (COTS) digital cameras for scientific data acquisition and scene-specific color calibration*. Journal of the Optical Society of America A, Vol. 31, No. 2, February 2014.

#### Pipeline MATLAB Scripts
* [`DNG2Tiff.m`](../Files/Image_Processing_Breakdown/DNG2Tiff.m) – Converts linear demesaiced DNG files to 16-bit TIF format.
* [`Master_V6_2_FixedVisual.m`](../Files/Image_Processing_Breakdown/Master_V6_2_FixedVisual.m) – Performs semi-automatic patch selection, white balancing, RGB extraction, linear color matrix derivation (`T`), and ProPhoto RGB conversion.
* [`Basic_Segmentation_V6.m`](../Files/Image_Processing_Breakdown/Basic_Segmentation_V6.m) – Semi-automated segmentation checkpointing, Otsu thresholding, interactive keyboard mask editing, and tissue RGB extraction.
