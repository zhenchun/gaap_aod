for(year in 2015) {
  # Read HDF files list from AOD directory
  setwd(file.path(aod_dir, year))
  
  files = list.files(pattern = "MCD19A2.*\\.hdf$", recursive = TRUE) # note that MAIACTAOT is for TERRA data and MAIACAAOT is for AQUA data
  
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
    write.csv(r, paste0(substr(f,1,42),"csv"))
    
  }
  
  
  
  
  
  
  

}