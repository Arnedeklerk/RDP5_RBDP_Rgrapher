# Load necessary libraries
library(ggplot2)
library(RCurl)
library(gridExtra)
library(tidyverse)
library(readxl)
library(ggfittext)
library(scales)

# Importing data
breakpointData <- read.csv("example_files/Sarbecovirus.csv")
geneMap <- read.csv("example_files/Sarbecovirus.csvORFCoords.csv")
breakpointDotPos <- read.csv("example_files/Sarbecovirus.csvBreakpointPositions.csv")

# Modifiers
virusName <- "Sarbecovirus"
taxId <- "694014"
fontSizeForGeneMap <- 6
fontSizeMultiplier <- 2
breakPointLineLength <- 1.2
enableOmbreEffect <- TRUE  # Toggle this to enable or disable the ombre gradient

# Extract required data
posInAlignment <- breakpointData$Position.in.alignment
rbn <- breakpointData$Recombination.breakpoint.number..200nt.win.
upper <- breakpointData$Upper.99..CI
lower <- breakpointData$Lower.99..CI
bottom <- breakpointData$Bottom

# Define plot height constraints
highestGene <- max(lower, rbn, upper)
highestGeneVal <- highestGene * 1.1
geneMapIndividualHeight <- highestGene * 0.1
geneMapHeight <- geneMapIndividualHeight * 4

# Convert gene map to dataframe
geneMapDataFrame <- geneMap %>%
  select(Gene.symbol, Start, Stop) %>%
  arrange(Start)

# Function to assign non-overlapping positions for gene labels above the main peak
assign_gene_positions <- function(df, min_height, step) {
  df <- df %>% arrange(Start)
  df$yPosition <- NA
  used_positions <- c()
  
  for (i in seq_len(nrow(df))) {
    proposed_y <- min_height
    while (proposed_y %in% used_positions) {
      proposed_y <- proposed_y + step
    }
    df$yPosition[i] <- proposed_y
    used_positions <- c(used_positions, proposed_y)
  }
  
  return(df)
}

# Place genes above the highest recombination peak but below breakpoints
geneLabelBase <- highestGeneVal * 1.05  # Just above the peak
geneSpacing <- geneMapIndividualHeight  # Consistent spacing
geneMapDataFrame <- assign_gene_positions(geneMapDataFrame, geneLabelBase, geneSpacing)

# Apply ombre effect if enabled, otherwise use a single color
if (enableOmbreEffect) {
  ombreColors <- colorRampPalette(c("#043F3D", "#085F63", "#0B7F89", "#13A3A9", "#17C6C9"))(nrow(geneMapDataFrame))
  geneMapDataFrame$color <- ombreColors
} else {
  geneMapDataFrame$color <- "#085F63"
}

# Data frame for breakpoint positions
df3 <- data.frame(
  bppXMin = breakpointDotPos$Breakpoint.position
)

# Define ggplot theme
mytheme <- theme_classic() +
  theme(
    panel.background = element_blank(),
    strip.background = element_rect(colour = NA, fill = NA),
    panel.border = element_rect(fill = NA, color = "black"),  # Only include once
    legend.title = element_blank(),
    legend.position = "bottom",
    strip.text = element_text(face = "italic", size = 20 * fontSizeMultiplier),
    axis.text = element_text(size = 15 * fontSizeMultiplier),
    axis.title.y = element_text(size = 10 * fontSizeMultiplier),
    axis.title.x = element_text(size = 10 * fontSizeMultiplier),
    plot.title = element_text(face = "bold", hjust = 0.5, size = 20 * fontSizeMultiplier),
    axis.ticks.length = unit(0.5, "cm"),
    panel.grid = element_blank()
  )

# Generate plot
p <- ggplot() +
  geom_polygon(data = breakpointData, aes(posInAlignment, rbn), fill = "#E85E5D", alpha = 0.85) +
  geom_polygon(data = breakpointData, aes(posInAlignment, upper), fill = "#C2DBD5", alpha = 1) +
  geom_polygon(data = breakpointData, aes(posInAlignment, lower), fill = "#5F6AB1", alpha = 0.85) +
  geom_polygon(data = breakpointData, aes(posInAlignment, bottom), fill = "white") +
  geom_line(data = breakpointData, aes(posInAlignment, upper), color = "#87B4A9") +
  geom_line(data = breakpointData, aes(posInAlignment, lower), color = "#87B4A9") +
  geom_line(data = breakpointData, aes(posInAlignment, rbn), linewidth = 1.05, color = "black") +
  
  # Gene rectangles with ombre colors
  geom_rect(data = geneMapDataFrame, aes(
    xmin = Stop, xmax = Start, ymin = yPosition, ymax = yPosition + geneMapIndividualHeight, 
    fill = color
  ), alpha = 0.7, color = "black") +

  # Apply fill color gradient
  scale_fill_identity() +
  
  # Gene labels
  geom_text(data = geneMapDataFrame, aes(
    x = Stop, y = yPosition + (geneMapIndividualHeight / 2), label = toupper(Gene.symbol)
  ), size = fontSizeForGeneMap, fontface = "bold", hjust = 1, color = "black") +
  
  # Breakpoint positions
  geom_rect(data = df3, aes(xmin = bppXMin, xmax = bppXMin + 1, 
                            ymin = max(geneMapDataFrame$yPosition) + (geneMapIndividualHeight * 1.5), 
                            ymax = max(geneMapDataFrame$yPosition) + (geneMapIndividualHeight * 2.5)),
            alpha = 0.7, fill = "black") +
  
  # Titles and labels
  ggtitle(paste0(virusName, " [TaxID: ", taxId, "]")) +
  xlab(paste0("Nucleotide position in the ", virusName, " genome alignment")) +
  ylab("Recombination breakpoint number \n (200nt window)") +
  mytheme +
  scale_x_continuous(expand = c(0, 0)) +
  scale_y_continuous(expand = c(0, 0))

print(p)
print("Graph generated successfully without overlapping gene names.")