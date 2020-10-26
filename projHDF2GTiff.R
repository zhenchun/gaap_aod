projHDF2GTiff = function(loc, hdfs, gtiffs, lyr, fromSRS, toSRS){ 
  if("gdalUtils" %in% rownames(installed.packages()) == FALSE){
    install.packages("gdalUtils", repos="http://r-forge.r-project.org")
    require(gdalUtils)
  } # install and load the gdalUtils package. 
  setwd(loc) # set the working directory to where the data is
  suppressWarnings(dir.create(paste(loc,"Projected",sep="/"))) # create a directory to store projected files
  for (i in 1:length(hdfs)){ 
    gdal_translate(hdfs[i],gtiffs[i],sd_index=lyr) # extract the specified HDF layer and save it as a Geotiff
    gdalwarp(gtiffs[i],paste(loc,"Projected",gtiffs[i],sep="/"),s_srs=fromSRS,t_srs=toSRS,srcnodata=-3000,dstnodata=-3000,overwrite = T) # project geotiffs
    unlink(gtiffs[i]) # delete unprojected geotiffs to save space
  }
}