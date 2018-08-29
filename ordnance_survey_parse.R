require(sqldf) # using sqldf to filter while loading very large data sets
require(data.table)
require(sf) # new simplefeature data class, supercedes sp in many ways
require(osmdata) # for loading data from OSM, supercedes "overpass" package and "osmar"

setwd("/Users/kidwellj/gits/presentation-20180904-basr")

# Import filtered CSV, selecting only data
# Note: OS recently changed column names to remove underscores, dropping header simplifies this issue
pointx_201512 <- read.csv.sql("/Volumes/imac-storage1/GIS_data/Ordnance_Survey/PointX_Complete_2015_12/poi_2015_12_all06340459.csv", sql = "select * from file where V3 = '06340459'", header = FALSE, sep="|")
pointx_201806 <- read.csv.sql("/Volumes/imac-storage1/GIS_data/Ordnance_Survey/PointX_Complete_2018_06/poi.csv", sql = "select * from file where V3 = '06340459'", header = FALSE, sep="|")
# pointx_201409 <- read.csv.sql("/Volumes/imac-storage1/GIS_data/Ordnance_Survey/PointX_Complete_2014_09/Data/pointx_v2_National_Coverage_Sept14.txt", sql = "select * from file where V3 = '06340459'", header = FALSE, sep="|")
# pointx_201609 <- read.csv.sql("/Volumes/imac-storage1/GIS_data/Ordnance_Survey/PointX_Complete_2016_09/csv/pointx_v2_National_Coverage_Sept16.txt", sql = "select * from file where V3 = '06340459'", header = FALSE, sep="|")

# Filter out the distorting uncategorised category
plot(sort(table(pointx_201806$V26[pointx_201806$V26 !='"Not Identified (Christian)"'])))

# Calculate a descending sorted list of points by each denomination for 2015, and filter out distorting "not identified" category
denominationcounts_201512 <- (sort(table(pointx_201512$V26[pointx_201512$V26 !='Not Identified (Christian)']), decreasing = TRUE))
par(las=2) # make label text perpendicular to axis
par(mar=c(12,8,4,2)) # increase y-axis margin.
par(cex.axis=0.7)
par(cex.lab=1)
# Subset top 10 for plot
plot(denominationcounts_201512[1:15])

# Calculate a descending sorted list of points by each denomination for 2018, and filter out distorting "not identified" category
denominationcounts_201806 <- (sort(table(pointx_201806$V26[pointx_201806$V26 !='"Not Identified (Christian)"']), decreasing = TRUE))
par(las=2) # make label text perpendicular to axis
par(mar=c(12,8,4,2)) # increase y-axis margin.
par(cex.axis=0.7)
par(cex.lab=1)
# Subset top 10 for plot
plot(denominationcounts_201806[1:15])
denominationcounts_201806

# Get UK Admin polygons
if (dir.exists("data") == FALSE) {
  dir.create("data")}
download.file("https://borders.ukdataservice.ac.uk/ukborders/easy_download/prebuilt/shape/infuse_dist_lyr_2011_clipped.zip", destfile = "infuse_dist_lyr_2011_clipped.zip")
unzip("infuse_dist_lyr_2011_clipped.zip", exdir = "data")
admin_uk <- st_read(infuse_dist_lyr_2011_clipped)
fname <- system.file("data/infuse_dist_lyr_2011_clipped.shp", package="sf")
admin_uk <- st_read(fname)

# Make maps
# Define CRS for British National Grid
BNG = "+proj=tmerc +lat_0=49 +lon_0=-2 +k=0.9996012717 +x_0=400000 +y_0=-100000 +datum=OSGB36 +units=m +no_defs +ellps=airy +towgs84=446.448,-125.157,542.060,0.1502,0.2470,0.8421,-20.4894"
xy <- pointx_201806[,c(4,5)]
pointx_201806_map <- SpatialPointsDataFrame(coords = xy, data = pointx_201806,
                                            CRS("+proj=tmerc +lat_0=49 +lon_0=-2 +k=0.9996012717 +x_0=400000 +y_0=-100000 +datum=OSGB36 +units=m +no_defs +ellps=airy +towgs84=446.448,-125.157,542.060,0.1502,0.2470,0.8421,-20.4894"))

churches_ordnancesurvey_2018 <- st_read(pointx_201806)
sf("OS_pointX_2016_09-POW-UK_all-simplified.csv")
coordinates(churches_ordnancesurvey) <- c("FEATURE_EASTING", "FEATURE_NORTHING")
proj4string(churches_ordnancesurvey) <- proj4string(admin_uk)  # borrow BNG CRS from admin boundaries shapefile


