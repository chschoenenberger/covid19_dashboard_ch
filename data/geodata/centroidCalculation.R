library(sf)
library(tidyverse)

cantons <- read_sf("data/geodata/swissBOUNDARIES3D_1_3_TLM_KANTONSGEBIET.shp",
  layer = "swissBOUNDARIES3D_1_3_TLM_KANTONSGEBIET", as_tibble = T) %>%
  filter(KT_TEIL %in% c("0", "1")) %>%
  select(NAME, EINWOHNERZ, geometry) %>%
  st_transform("+proj=longlat +datum=WGS84") %>%
  st_centroid() %>%
  cbind(st_coordinates(.)) %>%
  st_set_geometry(NULL)

liechtenstein <- st_read("data/geodata/swissBOUNDARIES3D_1_3_TLM_LANDESGEBIET.shp",
  layer = "swissBOUNDARIES3D_1_3_TLM_LANDESGEBIET", as_tibble = T) %>%
  filter(NAME == "Liechtenstein") %>%
  select(NAME, EINWOHNERZ, geometry) %>%
  st_transform("+proj=longlat +datum=WGS84") %>%
  st_centroid() %>%
  cbind(st_coordinates(.)) %>%
  st_set_geometry(NULL)

abbr <- data.frame(
  name                       = c("Aargau", "Appenzell Innerrhoden", "Appenzell Ausserrhoden", "Bern", "Basel-Landschaft", "Basel-Stadt",
    "Fribourg", "Genève", "Glarus", "Graubünden", "Jura", "Luzern", "Neuchâtel", "Nidwalden", "Obwalden", "St. Gallen",
    "Schaffhausen", "Solothurn", "Schwyz", "Thurgau", "Ticino", "Uri", "Vaud", "Valais", "Zug", "Zürich", "Liechtenstein"),
  abbreviation_canton_and_fl = c("AG", "AI", "AR", "BE", "BL", "BS", "FR", "GE", "GL", "GR", "JU", "LU", "NE",
    "NW", "OW", "SG", "SH", "SO", "SZ", "TG", "TI", "UR", "VD", "VS", "ZG", "ZH", "FL")
)

demographics <- bind_rows(cantons, liechtenstein) %>%
  rename(
    name       = NAME,
    population = EINWOHNERZ,
    long       = X,
    lat        = Y
  ) %>%
  full_join(abbr) %>%
  select(name, abbreviation_canton_and_fl, population, lat, long) %>%
  write_csv(., 'data/demographics.csv')