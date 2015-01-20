# source('./lib/load_packages.R') now done through pbtools

whmdatafolder <- 'P:/Research & Learning/Research/19. Transforming Whitehall/Whitehall Monitor/Data Sources/'

# Set location ------------------------------------------------------------
if(whatplatform()=='Darwin') {location='home'} else {location='ifg'}

# set parameters
if(!exists('batchproduce')) {batchproduce <- FALSE}
if(!batchproduce) {whitehallonly <- TRUE} # change here to produce WH or group charts

# Set parameters for saved chart ------------------------------------------
fontfamily='Calibri'
if(!batchproduce) { # don't override size & format variables if producing by batch
  ph=12
  pw=17.5
  plotformat <- 'png'
}

#font_import()
loadfonts(device='postscript',quiet=TRUE)
loadfonts(quiet=TRUE)
if(location=='ifg') {
  loadfonts(device='win',quiet=TRUE)
}

source('./lib/AddOrgData.R')
source('./lib/LoadAcsesData.R')
source('./lib/LoadAcsesData2014.R')
source('./lib/RelabelAgebands.R')
source('./lib/RelabelPaybands.R')
source('./lib/RelabelGrades.R')

yearlabels <- c('2008','2009','2010\nSR10 baseline','2011','2012','2013')

## THESE ARE NOW IN PBTOOLS:
# source('./lib/GetColorTable.R')
# source('./lib/TintShade.R')
# source('./lib/SavePlot.R')
# source('./lib/SortGroups.R')
# source('./lib/rgb2col.R')
