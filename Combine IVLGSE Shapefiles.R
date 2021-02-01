###########################################
#### Combine States into one shapefile ####
###########################################

# Create list of directory names of the files we want to read
# Insert the path to your directory containing all the shapefiles in individual subdirectories 
setwd("~/INPUT")
AP <- readOGR("AP")
AR <- readOGR("AR")
AS <- readOGR("AS")
BR <- readOGR("BR")
CG <- readOGR("CG")
GA <- readOGR("GA")
GJ <- readOGR("GJ")
HP <- readOGR("HP")
HR <- readOGR("HR")
JH <- readOGR("JH")
JK <- readOGR("JK")
KA <- readOGR("KA")
KL <- readOGR("KL")
MH <- readOGR("MH") 
ML <- readOGR("ML")
MN <- readOGR("MN")
MP <- readOGR("MP")
MZ <- readOGR("MZ")
NL <- readOGR("NL")
OR <- readOGR("OR")
PB <- readOGR("PB")
RJ <- readOGR("RJ")
SK <- readOGR("SK")
TN <- readOGR("TN")
TR <- readOGR("TR")
UK <- readOGR("UK")
UP <- readOGR("UP")
UTERR <- readOGR("UTERR")
WB <- readOGR("WB")

# Combine into one shapefile
IVLGSE <- bind(AP, AR, AS, BR, CG, GA, GJ, HP, HR, JH, JK, KA, KL, MH, ML, MN,
               MP, MZ, NL, OR, PB, RJ, SK, TN, TR, UK, UP, UTERR, WB) %>%
  # Drop irrelevant variables
  subset(IVLGSE, select = c("SID", "DID", "DISTRICT", "DIST_CODE", "THSIL_CODE", "BLOCK_CODE", "SUB_DIST", "TID", 
                            "NAME", "TOWN_VILL", "WARD", "LEVEL", "TRU",
                            "TOT_P", "TOT_M", "TOT_F", "P_LIT", "M_LIT", "F_LIT", "P_ILL", "M_ILL", "F_ILL"))
# Save this shapefile
writeOGR(IVLGSE, dsn = "OUTPUT/IVLGSE_All_India", layer = "All_India_ivlgse", 
         driver = "ESRI Shapefile", overwrite_layer = TRUE)

