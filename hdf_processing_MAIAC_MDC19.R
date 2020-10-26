## Install packages
## install.packages("gdalUtils")
## install.packages("raster")
## install.packages("rgdal")
## install.packages("rgeos")
## install.packages("plyr")
## install.packages("magrittr")
## install.packages("sp")
## install.packages("ncdf4")
## install.packages("reshape2")
## install.packages("foreach")
## install.packages("parallel")
## install.packages("doParallel")
## install.packages("mapview")
## install.packages("velox")
## install.packages("sf")

###########################################################
## Part a.1- working with hdf files on Windows ############
###########################################################

suppressMessages(library(gdalUtils))
suppressMessages(library(raster))
suppressMessages(library(rgdal)) 
suppressMessages(library(rgeos))
## Warning: package 'rgeos' was built under R version 3.4.4
suppressMessages(library(plyr))
suppressMessages(library(magrittr))
suppressMessages(library(sp))
suppressMessages(library(mapview))

# If you do not have it installed, you will probably get an error message and won't be able to read hdf files
# gdal_setInstallation()
# x <- getOption("gdalUtils_gdalPath")

# x[[1]]$path ## Look where GDAL is installed
# df <- x[[1]]$drivers # Table of all installed drivers

# Set your working directory
setwd("C:/Users/zy125/Box Sync/Postdoc/GAAP/GIS data/aod_2015")

###########################################################################

# For more information about the MAIAC AOD product and the different layers of each subdatasets, go to:

# https://lpdaac.usgs.gov/node/1265
# https://ladsweb.modaps.eosdis.nasa.gov/missions-and-measurements/products/maiac/MCD19A2/


################# Test on one HDF file ####################################

# Get a list of sds names
# sds <- get_subdatasets("MCD19A2.A2018183.h13v11.006.2018186225614.hdf")  # Returns subdataset names 
# 
# # R wrapper for gdal_translate - converts from hdf to tiff file
# gdal_translate(sds[1], "test.tif")
# 
# # Load the multi-layer raster into R
# r = brick("test.tif") 
# plot(r)
# mapview(r)

###########################################################################


# This function is useful if you are running the code on Windows




read_hdf = function(file, n) {
  sds = get_subdatasets(file)
  f = tempfile(fileext = ".tif") # the tiff file is saved as a temporary file
  gdal_translate(sds[n], f, a_srs="EPSG:4326")
  brick(f) # the ouptut is a multi-layer raster file
}



aod_dir = "C:/Users/zy125/Box Sync/Postdoc/GAAP/GIS data/aod_2015"





for(year in 2015) {
  # Read HDF files list from AOD directory
  setwd(file.path(aod_dir, year))
  
  files = list.files(pattern = "MCD19A2.*\\.hdf$", recursive = TRUE) # note that MAIACTAOT is for TERRA data and MAIACAAOT is for AQUA data
  
  result = list()
  
  for(f in files) {
    
    # Read data
    sds = get_subdatasets(f)
    
    # Choose which subdatasets you want to retrieve from the hdf file
    Optical_Depth_047 = read_hdf(f, grep("grid1km:Optical_Depth_047", sds))
    Optical_Depth_055 = read_hdf(f, grep("grid1km:Optical_Depth_055", sds))
    AOT_Uncertainty = read_hdf(f, grep("grid1km:AOD_Uncertainty", sds))
    AOT_QA = read_hdf(f, grep("grid1km:AOD_QA", sds))
    RelAZ=read_hdf(f, grep("grid5km:RelAZ", sds))
    RelAZ=disaggregate(RelAZ, fact = 5)
    
    # Create a different name for each layer 
    names(Optical_Depth_047) = paste0("Optical_Depth_047.", letters[1:nlayers(Optical_Depth_047)])
    names(Optical_Depth_055) = paste0("Optical_Depth_055.", letters[1:nlayers(Optical_Depth_055)])
    names(AOT_Uncertainty) = paste0("AOT_Uncertainty.", letters[1:nlayers(AOT_Uncertainty)])
    names(AOT_QA) = paste0("AOT_QA.", letters[1:nlayers(AOT_QA)])
    names(RelAZ) = paste0("RelAZ.", letters[1:nlayers(RelAZ)])
    
    
    # Stack all the raster together
    r = stack(Optical_Depth_047, Optical_Depth_055, AOT_Uncertainty, AOT_QA, RelAZ)
    r = as.data.frame(r, xy=TRUE)
    
    # Add filename
    r$date =
      f %>%
      strsplit("\\.") %>%
      sapply("[", 2) %>%
      substr(2, 8) %>%
      as.Date(format = "%Y%j")
    
    # Combine results
    result[[f]] = r
    
  }
  
  result = do.call(plyr::rbind.fill, result)
  setwd(file.path(aod_dir))
  saveRDS(result, sprintf("MAIACAOD_Sao_Paolo_%s.rds", year)) # Save each year separatly
}

head(result)