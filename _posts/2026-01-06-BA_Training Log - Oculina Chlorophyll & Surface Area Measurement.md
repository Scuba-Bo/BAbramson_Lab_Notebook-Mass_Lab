---
layout: post
title: "Training Log: Chlorophyll Measurement Protocol"
date: '2026-01-06'
categories: Protocols
tags: Chlorophyll,Lab Work,Training,Protocol
---

### Purpose:
Become familiarized with established scientific chlorophyll measurement methods via homogenization of tissue and subsequent optical density wavelength readings. This data serve as the ground truth data to compare the chlorophyll measuremnts garnered from imaging based RGB pixel data.

---

## 1. Airbrush Removal of Tissue & Algae
*(Performed January 5th 2026)*

1.  **Preparation:** Collect airbrush, gloves, 1 ml (1000 µl) pipette, 1 ml pipette tips (no filters), FSW (Filtered Seawater) in a graduated cylinder, distilled water, ice, frozen coral samples, tweezers, and 2ml Eppendorf tubes.
    * *Optional:* Collect parafilm if adding a tip to the airbrush for precision (this requires higher pressure).
2.  **Labeling:** Label a sufficient number of 2ml tubes with relevant sample info.
3.  **Setup:** Connect the airbrush to the pressurized air tube.
4.  **Initial FSW Addition:** Using a 1 ml pipette, add **2ml of FSW** to a bag with a coral sample in it.
    * **Crucial:** Keep track of *all* added volumes of FSW to make correct calculations later.
5.  **Airbrushing:** While the coral is ideally submerged in water, blast the frozen tissue with the airbrush to separate it from the skeleton.
6.  **Inspection:** Use tweezers to inspect the skeleton for remaining tissue. Once clean, remove the skeleton from the bag.
7.  **Collection:** The airbrush, if used very gently, can help slide remaining liquid off the sides of the bag into the pool at the bottom. Additionally, you can use another ml of FSW to wash the sides of the bag to pool the liquid at the bottom. If you add FSW, make sure to note this for later calculations.
8.  **Transfer:** Pipette the liquid from the bags into the 2 ml tubes and place on ice.
9.  **Cleaning:** Clean the airbrush with distilled water (submerge tip and wipe sides).
10. **Skeleton Bleaching:**
    * Place clean skeletons in **3% bleach (Sodium hypochlorite)** for at least an hour until white.
    * Rinse with distilled water.
    * Leave to dry (with labels) on the counter or in an oven at **50°C**.
    * This step can be done once you complete the other steps and leave the samples to incubate.

---

## 2. Homogenization
*(Performed January 5th 2026)*

1.  **Preparation:** Collect coral samples in 2ml Eppendorf tubes (on ice), a 600 ml glass beaker with distilled water, and paper towels.
2.  **Cleaning:** Ensure that the homogenizer is clean by taking it apart and inspecting the pieces. Clean the homogenizer tube with distilled water before starting by dunking the tube in the distilled water, running the machine for a few seconds (~½ power), then removing it and wiping it with a paper towel.
3.  **Process:** Gently homogenize (**1/4 power**) the coral samples directly in the tubes.
4.  **Cleaning (Between Samples):** Clean the homogenizer tube again as described in step 2.
5.  **Storage:** Any tubes not immediately centrifuged should be labeled and placed in the **-80°C freezer**.

---

## 3. Centrifuge & Incubate
*(Performed January 5th 2026)*

1.  **Preparation:** Collect 1 ml and 200 µl pipettes, a small glass waste beaker, aluminum foil, and a 50 ml Falcon tube with acetone.
2.  **Balancing:** Ensure all samples are weighted correctly. If unequal, add FSW (record the volume).
3.  **Centrifuge:** Run at **5000 rpm for 5 min at 4°C**.
4.  **Supernatant Removal:**
    * Carefully remove the supernatant liquid without disturbing the pellet.
    * Use a 1 ml pipette for surface liquid and a 200 µl pipette for precision near the pellet.
    * Pipette the supernatant waste into the small glass beaker and dispose of it responsibly.
5.  **Acetone Addition:**
    * Add **1 ml of 95-100% acetone** to the pellet.
    * *Caution:* Acetone easily leaks out of the pipette, so keep the tube close to the container of acetone and work quickly to avoid leakage.
6.  **Resuspension:** Vortex the tube to resuspend the pellet.
7.  **Light Protection:** Immediately wrap the tube in foil to block all light.
8.  **Incubation:** Incubate in the fridge at **4-8°C for 8-24 hours**.
    * *Critical:* Do not exceed 24 hours.
9.  **Cleanup:** Clean glassware with water and wire brushes (residual soap is sufficient).

---

## 4. Chlorophyll Analysis (96 Well Plate)
*(Performed January 6th 2026)*

1.  **Planning:** Prepare a "Well Plate Plan" schematic in Excel. Ensure that the way you load the samples corresponds to the schematic.
2.  **Preparation:** Collect 200 µl pipette, tips (no filter), and an acetone-compatible 96 well plate.
    * *Product Used:* **Greiner Bio-One Microplate 96 Chimney well** (Product Number: 655201).
3.  **Retrieval:** Remove incubated samples from the fridge.
4.  **Centrifuge:** Spin samples at **5000 rpm for 5 min at 4°C**.
5.  **Transport:** Bring your centrifuged samples, tools, and well plate near the area of the chlorophyll analysis machine. Walking long distances with a loaded 96 well plate is not advised and can mess up the samples.
6.  **Loading:** Prepare wells according to your schematic. Include blanks (e.g. 3 wells with 200 microliter blanks of 95-100% acetone, 3 wells with 200 microliters of sample A, 3 wells with 200 microliters of sample B, etc.).
7.  **Reading:**
    * Place plate in the **Biotek Synergy H1 Plate Reader**.
    * Align software with your schematic.
    * Check optical density at **630, 647, 664, and 697 nm**.
8.  **Data:** Save the output spreadsheet and email it to yourself.

### Calculations
This formula considers the 200 ul volume in the well. The output of this formula will be chl-a(ug)/ 1 ml, so the output should be multiplied by the initial volume of FSW (e.g. 3 ml) to obtain total chl-a. Once you have total chl-a, you can divide by surface area to obtain chl-a ug/cm^2. 

Remember to subtract the average optical density of the blank (acetone) from the optical density measurements of the samples.

Chlorophyll *a* concentrations were calculated according to the equation of Ritchie (2008):

Chl-a = -0.3319(A630) - 1.7485(A647) + 11.9442(A664) - 1.4306(A691)


---

## 5. Surface Area Measurement (Foil Method)
*(Performed February 2nd 2026)*

1.  **Context:**At this stage, the chlorophyll measurement you have calculated relates to the entire sample’s live tissue surface area. To obtain a chlorophyll measurement ratio relating to surface area (Chl-a / cm<sup>2</sup>), we need to measure the surface area of the coral sample. Surface area can be measured via images in agisoft or with foil. Here, we will use the foil method. 

2. Cut at least 5 squares of foil at precise measurements (e.g., 1, 4, 16, 36, 64 cm<sup>2</sup>).
    * Aim for at least 2-3 of the squares to be below the surface area of your samples and 2-3 to have larger surface areas than your coral samples.
3. Weigh each square on an analytical scale.
    
4. Plot a linear regression (Weight vs. Area) to get the equation.
5. Cover the coral skeleton with new foil.
    * **Note:** Only cover the area where living tissue was present.
    * Trim excess foil.
4.  Weigh the foil masks of the coral samples.
5.  Use the linear regression equation to convert foil weight to surface area.
6.  Now, with both chlorophyll and surface area, you can calculate chlorophyll /area

#### Surface Area (Foil Method)

| Oculina Sample | Foil Mask Weight (g) | Calculated Surface Area (cm²) |
| :--- | :---: | :---: |
| **1** | 0.0383 | 8.212765957 |
| **4** | 0.0439 | 9.404255319 |

## Preliminary Results
*Via lab protocols*

### Optical Density Values

| Sample | Row | Well 1 | Well 2 | Well 3 | Wavelength (nm) |
| :--- | :---: | :---: | :---: | :---: | :---: |
| **Blank (acetone)** | A | 0.111 | 0.109 | 0.108 | 630 |
| | | 0.106 | 0.104 | 0.104 | 647 |
| | | 0.102 | 0.100 | 0.099 | 664 |
| | | 0.095 | 0.092 | 0.092 | 697 |
| **Sample 1** | B | 0.208 | 0.231 | 0.237 | 630 |
| | | 0.236 | 0.266 | 0.273 | 647 |
| | | 0.577 | 0.693 | 0.708 | 664 |
| | | 0.095 | 0.094 | 0.097 | 697 |
| **Sample 4** | C | 0.125 | 0.128 | 0.134 | 630 |
| | | 0.134 | 0.140 | 0.146 | 647 |
| | | 0.222 | 0.246 | 0.253 | 664 |
| | | 0.088 | 0.087 | 0.092 | 697 |

#### The average blank (acetone) optical density is subtracted from the sample's optical density for each wavelength.

### Calculated Values (Blank Subtracted)

| Sample | Well 1 | Well 2 | Well 3 | Wavelength (nm) |
| :--- | :---: | :---: | :---: | :---: |
| **Sample 1** | 0.09866666667 | 0.1216666667 | 0.1276666667 | 630 |
| | 0.1313333333 | 0.1613333333 | 0.1683333333 | 647 |
| | 0.4766666667 | 0.5926666667 | 0.6076666667 | 664 |
| | 0.002 | 0.001 | 0.004 | 697 |
| **Sample 4** | 0.01566666667 | 0.01866666667 | 0.02466666667 | 630 |
| | 0.02933333333 | 0.03533333333 | 0.04133333333 | 647 |
| | 0.1216666667 | 0.1456666667 | 0.1526666667 | 664 |
| | -0.005 | -0.006 | -0.001 | 697 |

##### In this case, sample four had a negative value at wavelength 697 after blank subtraction. Therefore, sample four is invalid and discarded.

### Chlorophyll-a Concentration (ug/ml) after Ritchie (2008) equation

| Sample | Well 1 | Well 2 | Well 3 |
| :--- | :---: | :---: | :---: |
| **Sample 1** | 5.493651933 | 6.835788433 | 7.000411533 |

##### Now, we multiply these values (ug Chl-a/ml) by the quantity of FSW added to obtain total Chl-a ug. In this case, 3 ml of FSW was used for sample 1. Therefore, we multiply by 3.

### Total Chl-a ug

| Sample | Well 1 | Well 2 | Well 3 | Average |
| :--- | :---: | :---: | :---: | :---: |
| **Sample 1** | 16.4809558 | 20.5073653 | 21.0012346 |**19.3298519** |


## Final Avg Chl-a/cm² Value
##### Now, with the average total Chl-a ug and the surface area, we calculate chl-a/cm².

19.3299 ug Chl-a / 8.21276595 cm² = 2.35 ug Chl/cm²

| Sample | Avg Chl-a/cm² |
| :--- | :--- |
| **Sample 1** | 2.35 ug |



### Author: Boaz Abramson
### Laboratory: Mass Lab
### Last Edited: February 23rd 2026