require(reshape)
require(dplyr)
require(raster)
require(ggplot2)


shanghai_NDVI_path<-"C:/Users/zy125/Box Sync/Postdoc/GAAP/GIS data/CRAES/sh_ndvi"

all_shanghai_NDVI <- list.files(shanghai_NDVI_path,
                              full.names = TRUE,
                              pattern = ".tif$")


all_shanghai_NDVI_stack<-stack(all_shanghai_NDVI)

all_shanghai_NDVI_df<-as.data.frame(all_shanghai_NDVI_stack, xy = TRUE) %>% melt(id.vars = c('x','y'))