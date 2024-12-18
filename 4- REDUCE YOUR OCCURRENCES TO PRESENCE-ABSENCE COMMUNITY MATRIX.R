rm(list=ls())

###########
#####
##           4) GRIDDING YOUR DATA: ##
#####
###########

#A) load your libraries and set your working directory: 


library(terra)
library(sf)
library(epm)
library(tidyverse)
library(raster)

setwd("MassiveOccurrenceManipulation")

load("BifRes.POWOspecBasic.RData")


#A) create a simplified dataframe for gridding
Cells<- Bif_PBasic %>% dplyr::select(Acc_name, lon, lat)
    ## optional: Remove things you don't need to free up memory: 
#rm(Bif_PBasic, Misssing_Powo, rasts1)
#gc()

names(Cells)[1]<-"taxon"

#B) set up an equal area projection: 
EAproj <-  CRS("+proj=cea +lon_0=0 +lat_ts=30 +x_0=0 +y_0=0 +datum=WGS84 +ellps=WGS84 +units=m +no_defs")

#C) Make a sf object and project it correctly
Sp_space2<- st_as_sf(Cells[, c('taxon', 'lon', 'lat')], coords = c('lon', 'lat'), crs = 4326)

## OPTIONAL: remove the thing you don't need and free up some space: 
#rm(Cells)
#gc()

#D) Transform your sf object to an equal area projection object: 
Sp_check<- st_transform(Sp_space2, crs=EAproj)

## OPTIONAL remove things you don't need to free up some space: 
rm(Sp_space2)
gc()

#E) Create a presence-absence grid for your distribution data of desired resolution: 
GRID<-createEPMgrid(Sp_check, resolution = 325000, cellType = 'hex')

## save the grid: 

write.epmGrid(GRID,"EPM_Hybs")

rm(Sp_check)
gc()

#F) get centroids and species present to create a grid-referenced community matrix: 
    #creates community matrix
community <- epmToPhyloComm(GRID, sites = 'all')
community <- as.data.frame(community)
    # gets lat long coordinates of cell centroid (sites), which you may need for downstream analyses.
centroids <- coordsFromEpmGrid(GRID, "all")
centroids <- as.data.frame(centroids)
centroids$site <- rownames(community)

### save this workspace: 

rm(GRID)
gc()

save.image("Comm_Centroids.RData")

