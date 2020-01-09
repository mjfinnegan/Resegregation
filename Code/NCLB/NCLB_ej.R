library(data.table)
library(readstata13)
setwd('~/Dropbox/Pkg Data/NCLB')

# main dataset for the us (school race data)
ejData <- readRDS('~/Dropbox/Pkg Data/SchoolData/public/ejData.rds')

# Next, scrape 0304, 0405 data
sy_0304_location <- 'NCLB/Clean/sy0304.rds'
if (!file.exists(sy_0304_location)){
  sy_0304 <- readstata13::read.dta13('~/Dropbox/Pkg Data/NCLB/national_2003.dta')
  saveRDS(sy_0304, file=sy_0304_location)
} else {
  l$sy_0304 <- readRDS(sy_0304_location)
}
sy_0405_location <- 'NCLB/Clean/sy0405.rds'
if (!file.exists(sy_0405_location)){
  sy_0405 <- readstata13::read.dta13('~/Dropbox/Pkg Data/NCLB/national_2004.dta')
  saveRDS(sy_0405, file=sy_0405_location)
} else {
  l$sy_0405 <- readRDS(sy_0405_location)
}

# First, scrape 2005-2016 data
source('NCLB_web_scrape.R')
l <- NCLB_web_scrape()

for (i_file in 1:length(l)){
  f_name <- names(l[i_file])
  col_names <- names(l[[i_file]])
  cat(f_name, col_names, sep='\n', file = paste0('NCLB/',f_name,'.txt'))
}

# Clean up the files to join to ejData
# Need common column names, school id field, etc.
dt_files <- data.table()
for(i_file in 1:length(l)){
  dt_file <- data.table(cols = names(l[[i_file]]))
  dt_file$cols_example <- unlist(l[[i_file]][1000,])
  dt_file$f_name <- names(l)[i_file]
  
  dt_files <- rbindlist(list(dt_files, dt_file), use.names = TRUE, fill=TRUE)
}
dt_files <- dt_files[, N:=.N, by=cols]
dt_files <- tidyr::spread(dt_files, f_name, cols_example, fill='')
dt_files <- dt_files[order(N, decreasing = TRUE)]
View(dt_files)
