library(ggplot2)
library(sf)
library (ggmap)

##Load shapefile
wardsf <- st_read("Ward_Boundary_31_Districts.shp")


##Co-ordinates for Reference
##27.645790, 85.260560
##27.638291, 85.454331

##27.757555, 85.450970
##27.767829, 85.164955

##You would need to put in a real Google API Key here
register_google(key = "XXXXX")
wardsf <- st_transform(wardsf, 4326)

## Set the latitude and longitude boundaries for Google Map.
lat <- c(27.638291, 27.717829)
lon <- c(85.214955, 85.504331)

## Download the map from Google Maps
map_image <- get_map(location = c(lon = mean(lon), lat = mean(lat)), zoom = 12)

##Roadmap
map_image2 <- get_map(location = c(lon = mean(lon), lat = mean(lat)), zoom = 12, maptype = "roadmap")
maponroadmap<-ggmap(map_image2) +
  geom_sf(data = wardsf, inherit.aes = FALSE, fill = NA, color = 'black') +
  theme_minimal() +
  theme(axis.text = element_blank(),
        axis.ticks = element_blank(),
        axis.title = element_blank())

##Blank Roadmap
maponroadmapblank<-ggmap(map_image2) +
  theme_minimal() +
  theme(axis.text = element_blank(),
        axis.ticks = element_blank(),
        axis.title = element_blank())


ggsave("Wards On KTM Map.png", plot = maponroadmap, dpi = 300)
ggsave("KTM Map.png", plot = maponroadmapblank, dpi = 300)


  