# ukgov-csstats
Analysis of ONS Civil Service Statistics data

This is a handover note for R code contained in this repo, which was used to produce some charts in [Whitehall Monitor 2014](www.instituteforgovernment.org.uk/our-work/whitehall-monitor). Beyond the code, it also serves as a how-to for the ONS Civil Service Statistics data. It's a description of what's where and how it fits together rather than a how-to.

Written by [@petrbouchal](http://github.com/petrbouchal) in January 2015.

## Structure

- there is a set of ```acses_*.R``` files for creating charts
- each of these files depends on a set of functions stored in `/lib`, which are loaded by calling the `./lib/lib_acses.R` file. These functions should only be loaded through or after `lib_acses.R` as they require variables defined there.
- they also depend on the ```pbtools``` R package, which contains some more generic custom functions, colour palettes, etc. The package is at [](https://github.com/petrbouchal/pbtools) and can be installed by `devtools::install_github('petrbouchal/pbtools')` (requires `devtools` to be installed)
- a set of shared parameters are set in `lib_acses.R` for setup (file paths) and easy reuse and consistency (fonts, image sizes - these can be overriden in individual charting scripts)
- various other packages are required, most importantly `plyr`, `dplyr`,`ggplot2`.
- it does not matter where the project (code files etc.) sit on the local drive as long as the internal paths remain valid
- there is also some code for
  - splicing new year's data onto last year's (acses_addYYYYdata.R): this should be easy to adapt for future years
  - building versions of the data with IfG classifications (`acses_build_data.R`): this may or may not work
  - running multiple chart scripts in one go (`ChartsProductionLine.R`): this may not work but should be possible to adapt if needed
  - transforming professions data (provided by request by the ONS) into long format (`ProfessionsReshape.R`). This can be done more straightforwardly using PowerQuery in Excel.

## Data

### Statistical data

- the data came directly from ONS's [Nomis](http://nomisweb.co.uk) interface.
  - The interface can only produce 100,000 cells at a time, so not all cross-tabs can be produced in one file. As a result, four files are saved, each containing multiple cross-tabs
  - The 'database' format option in the Nomis interface creates a long TSV file, which is what is stored and used here. TSV files *can* be opened in Excel (File > Open > Select 'All files' > in wizard, choose 'Tab' as separator.)
  - The files used by these scripts are splices of each year's files - so a long file with a 'Date' variable ranging from 2008 to 2014.
  - In January 2015, the last data was for CSS (ACSES) 2014.
- when needed, exclude the cross-tabs you don't need, only leaving the 'Total' category - i.e. if you don't care about gender, keep only `Gender=='Total'` etc. This is preferrable to e.g. summing 'Male' and 'Female' because in small cross-tabs rounding could distort the results
- data are loaded from the IfG P: drive - the path is specified in `lib_acses.R` in the `lib` directory. On a Mac machine, the path is different but also set in `lib_acses.R` (this was set up to automate switching between home and personal machine). 
- The structure of the relevant folder on the IfG P: drive therefore should not be changed, or the paths in the script need to be updated.

### Additional data

- Data with IfG organisation classifications resides in `/data-input`, as does some data on professions. `acses_orgs_fordatafrom2008to2014_managedbounds.csv` is the latest version of the organisation classification table. The path to this file is specified in `/lib/lib_acses.R`.

## Chart-creating scripts

- each of the `acses_*` files creates one or more graphics. The variables they analyse (gender, grade, age, department) are ordered alphabetically in the filenames to make them easier to read (DeGeGr rather than GeGrDe).
- they each go through a common set of steps
- they are at various degrees of completeness - those used for Whitehall Monitor 2014 will replicate perfectly.
- files ending in _overlapped will create two-sided tree/spaceship/building-shaped charts with two layers, one for each year.

**1. Loading data**

- uses `LoadAcsesData()`. This will also rename and remove some columns to make them more tractable. 

**2. Transforming data**

Relies heavily on [`dplyr`](http://github.com/hadley/dplyr).

Involves
- selecting the desired cross-tab
- adding departmental classification info. This also removes some duplicate rows (these result from some departmental groups contained in the data having the same number of staff as the one organisation contained in the group)
- making summaries (typically by year and department, and for eigher departmental groups or managed departments)
- making calculations (typically shares e.g. each grade as % of total)
- calculating the total for all managed departments if needed
- relabeling age bands, grades, etc. using the `Relabel*()` functions.
- sorting data so e.g. departments show up in the right order on the chart

**3. Creating charts**

- uses [`ggplot2`](http://github.com/hadley/ggplot2), a custom theme from `pbtools`

**4. Saving charts**

- uses `saveplot()` from `pbtools` - a wrapper for ggsave(). `?saveplot` for instructions.
- saves an image file, a data file, and a `gg` object into the relevant subfolders of `/charts-output`.
