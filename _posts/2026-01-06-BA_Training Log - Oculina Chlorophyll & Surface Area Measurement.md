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
Chlorophyll *a* concentrations were calculated according to the equation of Ritchie (2008):

Chl_a = -0.3319(A630) - 1.7485(A647) + 11.9442(A664) - 1.4306(A691)

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

### Preliminary Results
*Via lab protocols*

| Sample | Avg Chl/cm² |
| :--- | :--- |
| **Blank Acetone** | 0.1118543584 |
| **Sample 1** | 0.8963992973 |
| **Sample 4** | 0.2702277867 |


### Author: Boaz Abramson
### Laboratory: Mass Lab
### Last Edited: February 17th 2026