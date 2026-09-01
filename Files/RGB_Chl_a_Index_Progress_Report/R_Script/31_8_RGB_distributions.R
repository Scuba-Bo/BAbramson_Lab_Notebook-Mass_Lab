# Load required libraries
library(ggplot2)
library(dplyr)
library(gridExtra)
library(here) 

# 1. Load the formatted data
data <- read.csv(here("Input","MASTER_V2.csv"), check.names = FALSE)

# 2. Filter out missing RGB values AND rename species
data_clean <- data %>% 
  filter(!is.na(R) & !is.na(G) & !is.na(B)) %>%
  mutate(Species_name = case_when(
    Species_name == "Species_A" ~ "Acropora",
    Species_name == "Species_P" ~ "Pocillopora",
    Species_name == "Species_S" ~ "Stylophora",
    TRUE ~ Species_name
  ))

# NEW: Calculate the global maximum across all RGB channels for a unified y-axis limit
max_intensity <- max(c(data_clean$R, data_clean$G, data_clean$B), na.rm = TRUE)

# Define a clean, common theme
plot_theme <- theme_minimal() +
  theme(
    plot.title = element_text(hjust = 0.5, face = "bold"),
    legend.position = "none",
    panel.grid.major.x = element_blank(),
    axis.text.x = element_text(face = "italic", size = 12), 
    axis.title.x = element_blank() 
  )

# 3. Red Channel Plot
p_red <- ggplot(data_clean, aes(x = Species_name, y = R, fill = Species_name)) +
  geom_boxplot(alpha = 0.6, outlier.shape = NA) +
  geom_jitter(color = "darkred", width = 0.15, alpha = 0.7, size = 2) +
  scale_fill_manual(values = c("lightcoral", "indianred", "firebrick")) +
  scale_y_continuous(limits = c(0, max_intensity)) + # MODIFIED: Set fixed y-axis limit
  labs(title = "Red Intensity", y = "16-bit Intensity", x = NULL) + 
  plot_theme

# 4. Green Channel Plot
p_green <- ggplot(data_clean, aes(x = Species_name, y = G, fill = Species_name)) +
  geom_boxplot(alpha = 0.6, outlier.shape = NA) +
  geom_jitter(color = "darkgreen", width = 0.15, alpha = 0.7, size = 2) +
  scale_fill_manual(values = c("lightgreen", "mediumseagreen", "forestgreen")) +
  scale_y_continuous(limits = c(0, max_intensity)) + # MODIFIED: Set fixed y-axis limit
  labs(title = "Green Intensity", y = "", x = NULL) +
  plot_theme

# 5. Blue Channel Plot
p_blue <- ggplot(data_clean, aes(x = Species_name, y = B, fill = Species_name)) +
  geom_boxplot(alpha = 0.6, outlier.shape = NA) +
  geom_jitter(color = "darkblue", width = 0.15, alpha = 0.7, size = 2) +
  scale_fill_manual(values = c("lightblue", "dodgerblue", "royalblue")) +
  scale_y_continuous(limits = c(0, max_intensity)) + # MODIFIED: Set fixed y-axis limit
  labs(title = "Blue Intensity", y = "", x = NULL) +
  plot_theme

# 6. Arrange side-by-side and display
grid.arrange(p_red, p_green, p_blue, ncol = 3)

# 7. (Optional) Save the combined plot to a high-res PNG
g <- arrangeGrob(p_red, p_green, p_blue, ncol = 3)
ggsave("Species_RGB_Distributions.png", g, width = 12, height = 4, dpi = 300)
