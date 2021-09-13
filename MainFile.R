# loading libraries and downloading packages
library(ggplot2)
library(RCurl)
library(gridExtra)
library(plyr)
library(tidyverse)
library(readxl)
library(ggfittext)
# library(grid)
# library(viridis)

# If you do not have these installed, remove the comment hash and install them.
# install.packages("viridis")
# install.packages("ggfittext")

# Importing the data
breakpointData <-read.csv("example_files/Sarbecovirus.csv")
geneMap <- read.csv("example_files/Sarbecovirus.csvORFCoords.csv")
breakpointDotPos <- read.csv("example_files/Sarbecovirus.csvBreakpointPositions.csv")

# Modifiers (Edit here, as well as the above data for input!)
spikeOrFullLength <- "" # Leave this if you are not using coronavirus data
virusName <- "Sarbecovirus"
taxId <- "694014"
# Rec (sarbecovirus 1.75*8 and 1.95) ()
yAxisEnable <- FALSE # Leave this modifier alone!

# More modifiers
fontSizeForGeneMap <- 6 # How big must the text be in the gene map?
fontSizeMultiplier <- 2 # How much would you like to times the font size by?
breakPointLineLength <- 1.2 # How long should the breakpoint lines be? (value greater than 1)


# Program code: for those who know what they're doing:

# Making life easier by using default settings for the csv files
posInAlignment <- breakpointData$Position.in.alignment
rbn <- breakpointData$Recombination.breakpoint.number..200nt.win.
upper <- breakpointData$Upper.99..CI
lower <- breakpointData$Lower.99..CI
# This bottom needs to be manually added in the speadsheet (I could add code for this but that's a lot of effort for something that is simple in excel)
bottom <- breakpointData$Bottom

# Getting the definite highest number and adding 10% to move it a bit away
highestGene <- max(lower,rbn, upper)
highestGeneVal <- highestGene*1.1

geneMapIndividualHeight <- (highestGene *0.1) # How thick should the individual maps be?
geneMapHeight <- geneMapIndividualHeight *4 # Size of potential random gaps

# The main graph, ordered correctly to show hot and cold recombination breakpoint positions.
p <- ggplot() +
  
  geom_polygon(data = breakpointData, aes(posInAlignment, rbn), fill = "#E85E5D", alpha=I(0.85)) +
  geom_polygon(data = breakpointData, aes(posInAlignment, upper), fill = "#C2DBD5", alpha=I(1)) +
  geom_polygon(data = breakpointData, aes(posInAlignment, lower), fill = "#5F6AB1", alpha=I(0.85)) +
  geom_polygon(data = breakpointData, aes(posInAlignment, bottom), fill = "white") +
  geom_line(data = breakpointData, aes(posInAlignment, upper), color = "#87B4A9") +
  geom_line(data = breakpointData, aes(posInAlignment, lower), color = "#87B4A9") +
  geom_line(data = breakpointData, aes(posInAlignment, rbn), size = 1.05, color = "black")

# Data Frame 1
geneMapDataFrame <-data.frame(geneMap$Gene.symbol, geneMap$Start, geneMap$Stop)
# geneMapDataFrame

# Function for generating a random number (between two numbers)
RANDBETWEEN <-
  function(bottom,top, number = 1) {
    (runif(number,min = bottom, max = top))
  }

# Data Frame 2
df2 <- data.frame(
  xMinimum = geneMapDataFrame$geneMap.Stop,
  xMaximum = geneMapDataFrame$geneMap.Start,
  allNames = geneMapDataFrame$geneMap.Gene.symbol,
  randomOne = round(RANDBETWEEN((highestGeneVal),(highestGeneVal+geneMapHeight),nrow(geneMapDataFrame))/(geneMapIndividualHeight))*(geneMapIndividualHeight)
)

# Data Frame 3 (for bpps)
df3 <- data.frame(
  bppXMin = breakpointDotPos$Breakpoint.position
)

# Adjusting the look of the graphs
mytheme = list(
  theme_classic()+
    theme(panel.background = element_blank(),strip.background = element_rect(colour=NA, fill=NA),panel.border = element_rect(fill = NA, color = "black"),
          legend.title = element_blank(),legend.position="bottom", strip.text = element_text(face="italic", size=20 * fontSizeMultiplier),
          axis.text=element_text(size = 15 * fontSizeMultiplier),axis.title.y = element_text(size = 10* fontSizeMultiplier),axis.title.x = element_text(size = 10* fontSizeMultiplier),plot.title = element_text(face = "bold", hjust = 0.5,size=20* fontSizeMultiplier)) +
    theme(axis.ticks.length=unit(0.5,"cm")), # This is for the length of "whiskers" on ggplot
  theme(
  # axis.title.x=element_blank(),
  # axis.title.y=element_blank(),
  # axis.text.x = element_blank(), # TOGGLE COMMENT ENABLE HERE TO MAKE X COORDINATES SHOW OR NOT
),
expand_limits(x=33300, y=0), # adding white space to the graph

  theme(
  panel.grid = element_blank(),
        panel.border = element_blank())
  )

  
# theme(plot.caption = element_text(vjust = -3, hjust = 1, size=(12*fontSizeMultiplier)))
  


# Gene Mapping (the color modification now lies here, as it caused problems when within the data frame)
p + geom_rect(data=df2, aes(xmin = xMinimum, xmax = xMaximum, ymin = randomOne, ymax = randomOne + geneMapIndividualHeight), fill = "#085F63", alpha = 0.7, color = "black") + 
  geom_text(data=df2, aes(x = (xMinimum), y = randomOne + (geneMapIndividualHeight/2), label= toupper(allNames)), size=fontSizeForGeneMap, fontface = "bold", hjust = 1, color = "black") +
  # Breakpoint Pos Mapping
  geom_rect(data=df3, aes(xmin = bppXMin, xmax = (bppXMin+1), ymin = (highestGeneVal+geneMapHeight+(geneMapIndividualHeight+geneMapIndividualHeight)), ymax = ((highestGeneVal+(geneMapIndividualHeight)+(geneMapHeight+(geneMapIndividualHeight/2))))), alpha = 0.7, color = NA, fill = "black" ) +
  # Titles
  ggtitle(paste0(virusName, " [TaxID: ", taxId, "] ", spikeOrFullLength)) + # Toggle this comment to allow for title generation
   xlab(paste0("Nucleotide position in the " , virusName, " genome alignment ", spikeOrFullLength)) + 
   ylab("Recombination breakpoint number \n (200nt window)") +
   # labs(caption = "Bottitletest") +
  mytheme +
  scale_x_continuous(expand = c(0,0)) +
  scale_y_continuous(expand = c(0,0),labels = function(x) paste0("0",x)) # Toggle these if there must be no leading 0
 # scale_y_continuous(expand = c(0,0)) 

print("You have successfully printed the graph. If you got warnings do not worry!")

