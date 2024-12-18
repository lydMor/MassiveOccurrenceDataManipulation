rm(list=ls())

##################
########
##            1) CHUNKING YOUR DATASET with fread ##
#######
##################

#A) Set your working directory (here, your wd should include your raw occurrences and all scripts.)
setwd("MassiveOccurrenceManipulation")

#B) load your libraries
library(data.table)
library(tidyverse)
library(CoordinateCleaner)


#C) Create a dataframe with a sequence of numbers: 

Nums= seq(1, 30024, by=10000) #seq(1, total number of records, how big you want the chunks to be)
## this gives us 15 chunked datasets of 10000 records each. 
#D) create your header list: (this is from your raw file)
headers = names(fread("Raw_dist.csv", nrows=1))

#E) Loop over your chunke datasets: Here, we'll select which variables we want and do the first stage of cleaning with CoordinateCleaner. 
# becasue coordinate cleaner doesn't depend on accurate taxonomy, we can do it within the chunks to save some time down the road.
for(i in 1:length(Nums)){
  print(i)
  query<-paste(i)
  
  # specify where you want to start (skip) and how many rows you want to read (nrows = by in your Nums vector)
  Temp<- fread("Dist_Raw.csv", skip = Nums[7], nrows=10000)
  setnames(Temp, old=1:length(headers), new = headers)
    #Here, choose which information you want to keep. you can filter to only find specific species names, specific dates, etc.
  Temp<- Temp %>% dplyr::select(decimalLatitude, decimalLongitude, species, gbifID) %>% na.omit()
  wut<- nrow(Temp)
  
  if(wut > 0){
    # do CoordinateCleaner:
    dup1DF <- cc_dupl(Temp, lon = "decimalLongitude", lat = "decimalLatitude", species = "species")
    #inst_DF <- cc_inst(dup1DF, lon = "decimalLongitude", lat = "decimalLatitude", species = "species")
    capDF <- cc_cap(dup1DF, lon = "decimalLongitude", lat = "decimalLatitude", species = "species")
    cenDF <- cc_cen(capDF, lon = "decimalLongitude", lat = "decimalLatitude", species = "species")
    eqDF <- cc_equ(cenDF, lon = "decimalLongitude", lat = "decimalLatitude")
    valDF <- cc_val(eqDF, lon = "decimalLongitude", lat = "decimalLatitude")
    zeroDF <- cc_zero(valDF, lon = "decimalLongitude", lat = "decimalLatitude")
    gbifDF <- cc_gbif(valDF, lon = "decimalLongitude", lat = "decimalLatitude")
    
    #write out your data: (you will have created a sub-directory called "BifParts" within your main directory)
    write.csv(gbifDF, paste("BifParts/GBIF_Nums", query, ".csv", sep=""), row.names=F)
  }
}
