################################################
#### Overlay Pincodes Centroids with IVLGSE ####
################################################

# Read Shapefile
IVLGSE <- readOGR(dsn = "OUTPUT/IVLGSE_All_India", layer = "All_India_ivlgse")

# read pincodes
pincodes <- readOGR("INPUT/INDIA_PINCODES-master/india_pincodes.shp")

# calculate centroids
pincodes_centroids <- gCentroid(pincodes, byid = TRUE)
pincodes <- SpatialPointsDataFrame(pincodes_centroids, data.frame(pincodes@data$pincode), 
                                   proj4string = IVLGSE@proj4string)
# fix projection
pincodes <- spTransform(pincodes, crs(IVLGSE))

# overlay centroids and polygons
pt.in.poly <- over(pincodes, IVLGSE)
pincodes <- cbind(pincodes@data$pincodes.data.pincode, pt.in.poly)
pincodes <- rename(pincodes, c("pincodes@data$pincodes.data.pincode" = "pincode"))
pincodes <- subset(pincodes, select = c("pincode", "SID", "DID", "DISTRICT", "DIST_CODE", 
                                        "THSIL_CODE", "BLOCK_CODE", "SUB_DIST", "TID"))

# save file
write.csv(pincodes, "OUTPUT/Pincodes_with_IDs.csv")
