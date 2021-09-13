# RDP5_RBDP_Rgrapher
A small R program designed to take in Recombination Breakpoint Distribution Plot data output by RDP5 and make attractive figures.

The program takes RDP5 Recombination Breakpoint Distribution Plot data and converts it into more legible graphs, fit for use in journal article figures, using the 99% (or 95%) confidence intervals.

# "How to" guide
### Initial setup
1. Clone/Download the code
2. Open up the project called `ShadingBetweenTheLines.Rproj` in R Studio (or similar IDE)
3. Double click `MainFile.R` in the built in explorer
4. Allow R Studio to install required libaries and packages (yellow popup)

### What data to use as input
* RDP5 Beta version 5.16 and higher is required. Download RDP here: http://web.cbio.uct.ac.za/~darren/rdp.html, or get the hidden, most updated version here: http://web.cbio.uct.ac.za/~darren/mysetup.exe 
* Within RDP5 >5.16, create a Breakpoint Distribution Plot and export the data by right-clicking the graph and hitting "Save CSV"
* RDBP_Grapher uses the following data - move it into the root directory of RDBP_Grapher: Breakpoint Distribution Data, ORFCoords and BreakpointPositions.

### Data cleaning
Some data will require minor modification, here we guide you through the steps:
1. Open your Breakpoint Distribution Data (this will be the one without either csvORFCoords or csvBreakpointPositions appended)
   1. Add a new column in G, titled `Bottom`
   2. Use the following formula, applied to all cells with contents to the left: `=MIN(B2:F2)`
   3. Modify both position one, and the final position of the dataset to have 0 values in all but their "Position in alignment" field (Like so, for both the first and last positions: https://i.imgur.com/CN1JOtl.png)
   4. Save and exit
 2. Open your ORFPositions file
   1. Look carefully at the Gene Symbol column and purge duplicates. Be careful, as you need to take the smallest Start position and the largest Stop position for each unique Gene Symbol. Keep the formatting (leave gapless).
  
## Data in R
### Data import
There are just a few more things we need to modify or tweak, depending on the dataset. 
1. In the `MainFile.R`, look under the `#Importing the data` comment
   1. Modify the name of each of the 3 CSV files, according to your own data. In the example it is using Sarbecovirus or Nobecovirus. (Change the green text)
   2. Double check that you changed breakpointData, geneMap and breakpointDotPos to now read your own data.

### Data Modifiers
* virusName: Output title used both on top of the graph, and underneath on the X axis.
* taxID: TaxID according to NCBI (https://www.ncbi.nlm.nih.gov/taxonomy).

## More Modifiers
* fontSizeForGeneMap: How big must the text be in the gene map? Remember that when exporting, the text does not scale linearly compared to the preview image.
* fontSizeMultiplier: How much would you like to multiply the font size by
* breakPointLineLength: How long should the breakpoint lines be (minimum of 1)

### Optional Modifiers
There are many optional modifiers, but they require a bit more digging through the code. If you want something gone, simply comment it out and re-run.
A few notable optional modifiers include:
* The ability to remove titles (and spacing for them)
* Changing the height of the gene 
* Individual font size modification
* Changing to 95% upper and lower confidence intervals
* Color changes
* Theme modding

## Running the Code
* Press `CTRL + A` (to select all)
* Press `CTRL + ENTER` (to run selected code)

# Saving the graph
* To save the graph, click on Export -> Save as PDF
* If you save as a PNG, the image will likely be jagged
Settings:
1. PDF Size: 30 x 8 (but will depend on your own use case, so mess around with it)
2. Portrait
3. Pick a directory
4. Pick a File Name
5. Save

## Example
![Rplot02-1](https://user-images.githubusercontent.com/33641372/133134684-d496a618-418f-435e-a2b8-5f4989a57b09.jpg)

## Missing features
* Better randomisation to avoid overlapping gene maps (currently, you may need to generate a figure a couple of times to get the output you want where no gene maps overlap).

# Supplementary data and information
This project was created as a part of my Masters Thesis in Bioinformatics with the University of Cape Town, specifically to improve the quality of my figures.

# References (Check out RDP5)
Martin DP, Murrell B, Golden M, Khoosal A, & Muhire B (2015) RDP4: Detection and analysis of recombination patterns in virus genomes. Virus Evolution 1: vev003 doi: 10.1093/ve/vev003

## Special Thanks
Thanks to Darren Martin for his continued support in upkeeping RDP5 and general guidance

Thanks to Rentia Lourens for her contribution in the layering of geom_polygons

Thanks to Steyn de Klerk (@staindk) for his contribution in geneMapHeight automation
