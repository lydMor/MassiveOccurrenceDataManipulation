rm(list=ls())

##############
#####  
##           2B) Creating a name key based on known accepted names ##
#####
##############

## NOTE: Here, I use POWO, but you can use ITIS, VertNet, or whatever other taxonomic/distribution database is common/accepted for your system.

## load libraries: 
library(taxize)
library(tidyverse)

## set your working directory: 
setwd("MassiveOccurrenceManipulation")
#A) read in your names dataset:
Species<- read.csv("Species_inDist.csv")

#B) read in your taxonomic reference (In this case, it's POWO, and it will also be used for final geog-res)
POWO_dist<- read.csv("POWO_archDist.csv")

#C) find out which species are not in your reference database: 
Need_res<- Species %>% filter(!(species %in% POWO_dist$taxon_name))

#D) create a dataframe of your already accepted names (we'll use this later): 
Acc_names<- anti_join(Species, Need_res)
Acc_names$Acc_name<- Acc_names$species

#E) work with your names that aren't in your reference: 
for (i in 1:nrow(Need_res)){
  query<- Need_res$species[i]
  x <- pow_search(sci_com = query)
  y<-x[["data"]]
  a<-paste(y$accepted[1])
  if(is.null(y)){
    Need_res$Acc_name[i]<-paste("NOTIN") 
  }
  else{
    if(a=="TRUE"){
      Need_res$Acc_name[i]<-paste(y$name[1])
    }
    if(a=="FALSE"){
      Need_res$Acc_name[i]<-paste(y$synonymOf$name[1])
      
    }
  }
}

#F) Combine this with your already accepted names: 
FullNameKey<- rbind(Acc_names, Need_res)

write.csv(FullNameKey, "NameKey.csv", row.names=F)





