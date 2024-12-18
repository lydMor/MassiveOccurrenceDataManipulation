# MassiveOccurrenceDataManipulation
Throughout my PhD, I've used these scripts to manimpulate and analyze a millions-long occurrence dataset for all vascular plants globally. (DOI: GBIF.org (11 January 2023) GBIF Occurrence Download https://doi.org/10.15468/dl.qu4f2t). The Darwin Core Archive file associate with this dataset is over 200 GB, making data cleaning, cross referencing, and analysis more complicated. Here, I outline the steps I took to make the data cleaning, verification, and analysis manageable. With multiple R scripts, I work through: 
1) Breaking large datasets into smaller, workable chunks to retrieve relevant information
2) validating and cleaning any taxonomic issues
3) combining those chunks into a unified dataset for cleaning and cross referencing with available accepted geographic distributions (in my case, Plants of the World Online - POWO)
4) reducing lat-long coordinates to a gridded occurrence matrix of desired resolution

   ** NOTE: Here, i provide all code I've used to maniplute my massive dataset, but in order to create workable and easily reproducible examples, I've replaced the original raw data with a smaller subset available for download so that everyone can run these scripts and see how they work with real data, without needing access to a supercomputer. 
