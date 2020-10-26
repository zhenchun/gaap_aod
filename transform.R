


myloc = "C:/Users/zy125/Box Sync/Postdoc/GAAP/GIS data/aod_2015" # working directory
hdfs1 = list.files(getwd(), pattern="hdf$") # HDF file list
gtiffs1 = gsub("hdf","tif",hdfs1) # out out GeoTIFF file list
frm.srs = "+proj=sinu +lon_0=0 +x_0=0 +y_0=0 +a=6371007.181 +b=6371007.181 +units=m +no_defs" # original HDF SRS
to.srs = "+proj=longlat +datum=WGS84 +no_defs" # desired GeoTIFF SRS
s.nodata = -3000 # HDF nodata value
d.nodata = -3000 # GeoTIFF nodata value
# lyr is the HDF layer you want to extract. In this example it is "1" to 
# signify the first layer in the HDF file i.e. NDVI
# execute the function
projHDF2GTiff(loc = myloc, hdfs = hdfs1, gtiffs = gtiffs1, lyr = 1, fromSRS = frm.srs, toSRS = to.srs,
              srcnodata = s.nodata, dstnodata = d.nodata)
rm(myloc,hdfs1,gtiffs1,frm.srs,to.srs,s.nodata,d.nodata) # remove variables to save memory