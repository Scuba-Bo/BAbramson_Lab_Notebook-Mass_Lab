############## CHROMA  ###############
# Correlation analysis of chlorophyll to color channels
# (Outlier filtering removed for visualization of preliminary n=3 data)

# 0 Library ----
library(here)
library(tidyverse)
library(rstatix)
library(dplyr)
library(ggnewscale)
library(patchwork)
library(ggpmisc)
library(lmtest)
library(RColorBrewer)
library(ggtext)
library(ggh4x)
options(scipen=999)

# 1 Load Data ----
CHROMA <- read.csv(here("Input","MASTER_V2.csv"), check.names = FALSE)

# 1. Isolate RGB columns and scale to [0, 1] for conversion (16-bit RAW)
rgb_matrix <- as.matrix(CHROMA[, c("R", "G", "B")]) / 65535

# 2. Convert sRGB to CIELAB
lab_matrix <- convertColor(rgb_matrix, from = "sRGB", to = "Lab")

# 3. Append CIELAB to dataframe and calculate indices
CHROMA <- CHROMA %>%
  mutate(
    L_star = lab_matrix[, 1],
    a_star = lab_matrix[, 2],
    b_star = lab_matrix[, 3]
  ) %>% 
  mutate(across(c(1:3, 5), as.factor)) %>% 
  dplyr::mutate(
    Grayscale = round(0.299 * R + 0.587 * G + 0.114 * B, 2),
    r = R / (R + G + B),
    g = G / (R + G + B),
    b = B / (R + G + B),
    `R+G` = R + G,
    `R+B` = R + B,
    `R-G` = R - G,
    `R-B` = R - B,
    `R/G` = ifelse(G > 0, R / G, NA_real_),
    `G/R` = ifelse(R > 0, G / R, NA_real_),
    `(R-G)/(R+G)` = (R - G) / (R + G),
    `(R-B)/(R+B)` = (R - B) / (R + B),
    `(G-R)/(G+R)` = (G - R) / (G + R),
    `(G-B)/(G+B)` = (G - B) / (G + B),
    `R/(G+B)` = ifelse((G + B) > 0, R / (G + B), NA_real_),
    `(G-R)/(R+G-B)` = (G-R)/(R+G-B)
  )

# Transform df into long format
CHROMA_long <- CHROMA %>%
  ungroup() %>% 
  pivot_longer(cols = -c(Species_name, Species_ID, Bleaching, ID, exceptions, Chl_per_cm2),
               names_to = "Index", values_to = "Index_values") %>% 
  mutate(Index = factor(Index, levels = c("R", "G", "B", "r", "g", "b", "Grayscale", 
                                          "R+G", "R+B", "R-G", "R-B", "R/G", "G/R", 
                                          "(R-G)/(R+G)", "(R-B)/(R+B)", "(G-R)/(G+R)", 
                                          "(G-B)/(G+B)", "R/(G+B)", "(G-R)/(R+G-B)",
                                          "L_star", "a_star", "b_star"))) %>%
  # NEW: Rename species abbreviations to full genus names
  mutate(Species_name = case_when(
    Species_name == "Species_A" ~ "Acropora",
    Species_name == "Species_P" ~ "Pocillopora",
    Species_name == "Species_S" ~ "Stylophora",
    TRUE ~ Species_name # Keeps any other names exactly as they are
  ))

# 4 Chlorophyll - Index correlation ----

# DIRECT CALCULATION: Bypassing Cook's Distance completely to retain all data points
Chl_model_filtered <- CHROMA_long %>%
  drop_na(Chl_per_cm2, Index_values) %>%
  group_by(Index, Species_name, Bleaching) %>%
  nest() %>%
  mutate(
    n = map_int(data, nrow),
    model = map(data, ~ lm(Chl_per_cm2 ~ Index_values, data = .x)),
    smry  = map(model, summary),
    R_squared     = map_dbl(smry, ~ .x$r.squared),
    Adj_R_squared = map_dbl(smry, ~ .x$adj.r.squared),
    # NEW: Extract p-value from the model summary
    p_value       = map_dbl(smry, ~ pf(.x$fstatistic[1], .x$fstatistic[2], .x$fstatistic[3], lower.tail = FALSE))
  ) %>%
  ungroup()

## 4.3 Plot - R-square Chlorophyll  ----
Max_Chl_index <- Chl_model_filtered %>%
  group_by(Species_name, Bleaching) %>% 
  slice_max(order_by = abs(R_squared), n = 3) %>%
  group_by(Species_name, Bleaching) %>%
  mutate(Rank = dense_rank(desc(R_squared)),
         Bleaching = factor(Bleaching, levels = c("Preliminary"))) %>%
  ungroup() %>%
  mutate(ColorGroup = case_when(
    Rank == 1 ~ "Best",
    Rank == 2 ~ "Second",
    Rank == 3 ~ "Third",
    TRUE ~ "Others"
  )) %>% 
  mutate(ColorGroup = factor(ColorGroup, levels = c("Best", "Second","Third", "Others"))) %>%
  # NEW: Create a conditionally formatted label for p-values
  mutate(
    p_format = ifelse(p_value < 0.001, "< 0.001", sprintf("= %.3f", p_value)),
    full_label = sprintf("R² = %.2f, p %s", R_squared, p_format)
  )

Chl_model_filtered %>%
  mutate(Species = paste(Species_name, Bleaching, sep = "_"),
         as.factor(Species),
         Bleaching = factor(Bleaching, levels = c("Preliminary"))) %>%
  ggplot( aes(x = Bleaching, y = fct_rev(Index),  fill = R_squared)) +
  geom_point(shape = 21, color = "black", alpha = 1, size = 10) +
  scale_fill_gradientn(colours = brewer.pal(9, "YlGn"), limits = c(0, 1), breaks = seq(0, 1, length.out = 5),
                       guide = guide_colorbar(order = 2, title.position = "top", barwidth = 20), 
                       name = expression("Correlation strength (R"^2*")" )) +
  labs(x = expression("Chlorophyll "~italic(a)~" density ("*mu*"g / cm"^2*")"), 
       y = "Color index") +
  new_scale(new_aes = "size") + new_scale( "fill") + new_scale("shape") +
  geom_point(data = Max_Chl_index, aes(fill= R_squared, size = R_squared, color = ColorGroup, shape = ColorGroup),
             alpha = 1, stroke = 5) +
  # MODIFIED: Use the new 'full_label' column we created above
  geom_text(data = Max_Chl_index, 
            aes(label = full_label, size = R_squared),
            hjust = -0.2, color = "black", size = 5) +  
  scale_size_continuous(range = c(10, 10), guide = "none", limits = c(0, 1),
                        name = expression("Correlation strength (R"^2*")" )) +
  scale_color_manual(values = c("Best" = "darkgoldenrod2", "Second" = "#969399FD", "Third" = "#A86B2FFE", "Others" = "black"),
                     guide = guide_legend(order = 5, title.position = "top", override.aes = list(size = 7)),
                     name = "Color index ranking") +
  scale_shape_manual(values = c("Best" = 25, "Second" = 23, "Third" = 22, "Others" = 3),
                     guide = guide_legend(order = 5, title.position = "top"),
                     name = "Color index ranking") +
  scale_fill_gradientn(colours = brewer.pal(9, "YlGn"), limits = c(0, 1), breaks = seq(0, 1, length.out = 5), guide = "none") +
  facet_grid(. ~ Species_name, scales = "free_x", space = "free_x") +
  theme_bw() +
  theme(strip.text.x = element_text(face = "italic", size = 30),
        strip.text.y = element_text(size = 18), panel.grid.minor.y = element_blank(),
        strip.background = element_blank(), axis.title = element_markdown(size = 30),
        axis.text = element_text(size = 22), legend.spacing.x = unit(2, "cm"),
        legend.key.size = unit(0.8, "cm"), axis.text.y = element_text(size = 22),
        legend.text = element_text(size = 20), legend.title = element_text(size = 25, hjust = 0.5),
        legend.position = "bottom")
### save ----
ggsave(here ("Output/CIE_Plots/Chl", "Chl_Index_Ranked.png"), dpi = 800, units = "cm", width = 45, height = 35)

## 4.4 Plot - Best 3 indices ----

# Plot generated directly from CHROMA_long 
CHROMA_long %>% 
  filter(Index %in%c("R", "R+G", "R+B")) %>% 
  mutate(Bleaching = factor(Bleaching, levels = c("Preliminary")),
         Index = factor(Index, levels = c("R", "R+G", "R+B"))) %>% 
  ggplot(aes(x = Index_values, y = Chl_per_cm2, grp.label = Index)) +
  geom_point(aes(fill= Index, shape= Index), size = 4, alpha = 0.85, color = "black")+
  scale_shape_manual(values = c("R" = 21, "R+G" = 24, "R+B" =22),
                     guide = guide_legend(title.position = "top"), name = "Color index")+ 
  scale_fill_manual(values = c("R" = "brown3", "R+G" = "#EFB143", "R+B" ="purple2"),
                    guide = guide_legend(title.position = "top"), name = "Color index") +
  scale_x_reverse(expand = expansion(mult = c(0.02, 0.02)))+
  labs(y = expression("Chlorophyll "~italic(a)~" density ("*mu*"g / cm"^2*")"),  
       x = "Color index value", title = "") +
  guides(fill = guide_legend(override.aes = list(size = 7), title.position = "top", title.hjust = 0.5, order = 1),  
         shape = guide_legend(title.position = "top", title.hjust = 0.5, order = 1)) +
  new_scale("fill") +
  geom_smooth(aes( fill= Index), method = "lm", formula = y ~ x, color = "black", fullrange = FALSE, se = TRUE, alpha = 0.15) +
  stat_poly_eq( aes(label = paste(after_stat(grp.label), "*\": \"*", after_stat(rr.label), "*\", \"*", after_stat(p.value.label), sep = "")),
                label.y = "top", label.x = "left", vstep = 0.1, formula = y ~ x, parse = TRUE, size = 6) +
  scale_fill_manual(values = c("R" = "brown3", "R+G" = "#EFB143", "R+B" ="purple2"), guide = "none") +
  guides(linetype = guide_legend(override.aes = list(size = 7), title.position = "top", title.hjust = 0.5, order = 2))+
  scale_y_continuous(limits = c(-2 ,NA), breaks = seq(0, 15, by = 3), expand = expansion(add = c(-1.4, 0.4))) +
  facet_grid2(Bleaching ~ Species_name, scales = "free") + 
  theme_bw() +
  theme(strip.text.x = element_text(face = "italic", size = 35), strip.text.y = element_text(size = 30),
        panel.grid.minor.y = element_blank(), strip.background = element_blank(),
        axis.title = element_text(size = 35), axis.text = element_text(size = 30),
        legend.text = element_text(size = 20), legend.title = element_text(size = 25, hjust = 0.5), legend.position = "bottom")

### save ----
ggsave(here ("Output/Plots/Chl", "Fig.S3.png"), dpi = 800, units = "cm", width = 55, height = 40)