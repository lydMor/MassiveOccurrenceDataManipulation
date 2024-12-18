rm(list=ls())

############
#####
##        3) FINAL GEOGRAPHIC RESOLUTION OF YOUR MASSIVE DATASET   ##
#####
###########

#A) load your libraries and set your working directory:
library(raster)
library(tidyverse)
library(rgdal)
library(maptools)
setwd("MassiveOccurenceManipulation")

#B) Laod your datasets: 
    #partially cleaned raw distribution data: (located in your sub-directory of chunks)
load("Bifs_JOINED.RData")
    # name key: 
namekey<- read.csv("NameKey.csv")
    # Accepted geographic distributions (taxonomic reference database with taxon names and states/countries)
POW_justDist<- read.csv("POWO_archDist.csv")
    # a shapefile with an associated CRS that is identical to your reference: 
## set your CRS: 
wgs1984 <- CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs")

## read in the shapefile of your ref dataset: 
tdwg<- readShapeSpatial("tdwg.shp")
crs(tdwg)<- wgs1984


#### NOTE: here, we'll be working and saving in chunks, which is important when you have a massive dataset that might tap a memory limit part of the way through a script.


#C) combine your distribution data with your name key (the name of your dist data comes from script 2A): 
Bifs_Names<- full_join(AllBifsD, namekey)
## free up some space: 
rm(bifs, AllBifsD, namekey)
gc()
## save this: 
save.image("AllDist_WithPOWOnamesInfo.RData")

#D) Get rid of any records that can't be verified via your reference: 
Bifs_onlyPowo<- Bifs_Names %>% dplyr::filter(!(Acc_name=="NOTIN"))
rm(Bifs_Names)
gc()
## save this: 
save.image("OnlyPowoNames_FullDist_unclean_FIXED.RData")

#E) Extract the localities of your taxonomically resolved coordinate data: 

  ## get rid of NAs in your dist data: (just double make sure)
Dist4<- Bifs_onlyPowo %>% dplyr::filter(!(is.na(decimalLongitude)))

### now make an spdf and get your countries: 
reproTemp <- Dist4[, c("decimalLongitude", "decimalLatitude")] %>% SpatialPoints(proj4string = wgs1984) 
pointsSPDFTemp <- SpatialPointsDataFrame(coords=reproTemp, data=Dist4)
crs(pointsSPDFTemp)<-crs(tdwg)

## get your points distributed over your shapefile: 
SPDF_dist<- over(pointsSPDFTemp, tdwg)

## add the data from pointsSPDFTemp
SPDF_dist$Acc_name<-pointsSPDFTemp@data$Acc_name
SPDF_dist$lat<- pointsSPDFTemp@data$decimalLatitude
SPDF_dist$lon<- pointsSPDFTemp@data$decimalLongitude
SPDF_dist$species<- pointsSPDFTemp@data$species
SPDF_dist$occID<- pointsSPDFTemp@data$gbifID

## make sure this matches the POWO data names: 
SPDF_dist<- SPDF_dist %>% dplyr::select(Acc_name, LEVEL3_COD, lon, lat,occID)
names(SPDF_dist)[2]<- "area_code_l3"

### save this: 
save.image("DistData_POWOnamesONLY_ready4Inner.RData")

#F) Cross reference with your taxonomic database to get your FINAL CLEAN DATASET:

# get the taxonomic reference data in the correct format: 
          ## here, you can choose what parameters you want. In my case, I wanted only native species with real locations
POWO_Spec<- POW_justDist %>% dplyr::filter(introduced==0 & extinct==0 & location_doubtful==0) %>% distinct(taxon_name, area_code_l3)
POWO_Spec<- POWO_Spec %>% dplyr::select(taxon_name, area_code_l3)
names(POWO_Spec)[1]<-"Acc_name"

# now join with the GBIF dist data: (inner join is weird sometimes, so this one works more reliably)
        # this keeps only the distribution data that also appears in your reference dataset.
Bif_PBasic<- merge(SPDF_dist, POWO_Spec, all=FALSE)




#G) these steps are optional, but here we can get information about missingness on both ends: 

## figure out what is missing (how much of POWO isn't in your new dataset)
Misssing_Powo<- anti_join(POWO_Spec, Bif_PBasic)

### figure out what is missing (How much of GBIF isn't in your new dataset)
Missing_GBIF<- anti_join(SPDF_dist, Bif_PBasic)


# save your workspace. 
##### depending on how much you have, you might want to anly save the final occurrence dataframe:
## full save: 
save.image("FullyResolvedDist_Basic.RData")

## only occurrence dataframe: 
rm(list=setdiff(ls(), "Bif_PBasic"))
save.image("FullyResolvedDist_Basic.RData")

