rm(list=ls())

###########
####       
##         2) COMBINING YOUR CHUNKS AND GETTING A LIST OF INCLUDED SPECIES ##
#####
############

## this is pretty simple, all we need to do here is get a NEW raw dataset of partially cleaned records that need to be further resolved.

#A) Set your working directory (this is the sub directory that you put your chunks in): 
setwd("MassiveOccurrenceManipulation/BifParts")

#B) Load your libraries: 
library(tidyverse)

#B) Prepare your datframes:
Bifs<- list.files(pattern=".csv")
AllBifsD<- data.frame()

#C) combine your dataframes: 
for(i in 1:length(Bifs)){
  print(i)
  temp<- read.csv(Bifs[i])
  AllBifsD<-bind_rows(AllBifsD, temp)
}

#### here, you can save as an RData file, or as a .csv (RData files are more efficient than .csv's when working with large datasets)
save.image("Bifs_JOINED.RData")

#D) Get a list of all species in your dataset: (you'll need this for resolving taxonomy)
Species<- data.frame(species=unique(AllBifsD$species))
  #save it wherever you want: 
write.csv(Species, "Species_inDist.csv", row.names=F)


