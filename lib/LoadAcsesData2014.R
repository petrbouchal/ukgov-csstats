# Fn: load and clean ACSES data -------------------------------------------------

LoadAcsesData2014 <- function (file_name, location='ifg') {
  if(location=='home') {
    directory  <- macdatafolder
  } else if(location=='ifg') {
    directory  <- whmdatafolder
  } else {
    directory <- location
  }
  fullpath <- paste0(directory, file_name)
  dataset <- read.delim(fullpath, sep='\t')
  dataset$value[dataset$value=='#'] <- NA
  dataset$value[dataset$value=='..'] <- NA
  dataset$Organisation <- dataset$new1
  dataset$new1 <- NULL
  dataset$count <- as.numeric(as.character(dataset$value))
  dataset <- unique(dataset) # removes duplicate lines for DfE, DfID, Ofsted and GEO
  # remove duplicate line in DfE:
  dataset <- dataset[!(dataset$Organisation == 'Education, Department for' & dataset$Date == 2013),]
  dataset <- dataset[!(dataset$Organisation == 'Education, Department for' & dataset$Date == 2014),]
  dataset$value <- NULL
  dataset$flag <- NULL
  dataset$value.type <- NULL
  return(dataset)
}
