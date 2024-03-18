library(sf)
library(dplyr)
library(ggplot2)

## Read in Shapefile, WVS data, rename WVS to something easy
shape<-st_read("CTYUA_Dec_2019_UGCB_in_the_UK.shp")
load("WVS_Cross-National_Wave_7_rData_v5_0.rdata")
df <- `WVS_Cross-National_Wave_7_v5_0`

## Filter and select specific columns (country, lat/lon, question)
filtered_df <- df %>%
  filter(C_COW_ALPHA == "UKG") %>%
  select(O1_LONGITUDE, O2_LATITUDE, Q195, N_REGION_ISO)

## Filter entries to remove NAs etc
filtered_df <- filtered_df %>%
  filter(Q195 >= 1 & Q195 <= 10)

## Create spatial points from the dataframe (remove missing values too)
coordinates_df <- filtered_df %>%
  filter(!is.na(O1_LONGITUDE) & !is.na(O2_LATITUDE)) %>%
  st_as_sf(coords = c("O1_LONGITUDE", "O2_LATITUDE"), crs = 4326)

## Make survey data coords a SF, match CRS systems
filtered_df_sf <- st_as_sf(coordinates_df, coords = c("O1_LONGITUDE", "O2_LATITUDE"), crs = st_crs(shape), agr = "constant")
crs_coord <- st_crs(filtered_df_sf)
crs_shape <- st_crs(shape)
if (crs_coord != crs_shape) {
  filtered_df_sf <- st_transform(filtered_df_sf, crs_shape)
}

## Perform spatial join
joined_data <- st_join(filtered_df_sf, shape, join = st_within)

## Calculate mean Q195 values for each polygon
mean_values <- joined_data %>%
  group_by(ctyua19cd) %>%
  summarise(mean_Q195 = mean(Q195, na.rm = TRUE))

## Adding the mean Q195 values back to the shapefile data, joining by county
shape_with_means <- shape %>%
  st_join(mean_values, by = "ctyua19cd") 

## Step 6: Plot the map
ggplot(data = shape_with_means) +
  geom_sf(aes(fill = mean_Q195)) +
  scale_fill_viridis_c() + # This uses the viridis color scale, easier for colourblind people
  labs(fill = "Level of approval", caption="Data from WVS.  Grey areas indicate no data available") +
  theme_minimal() +
  ggtitle("Approval of Capital Punishment")

