# ---- Loading libraries ----
library("shiny")
library("shinydashboard")
library("tidyverse")
library("leaflet")
library("plotly")
library("DT")
library("fs")
library("wbstats")

source("utils.R", local = T)

downloadGithubData <- function() {
  download.file(
    url      = "https://github.com/daenuprobst/covid19-cases-switzerland/archive/master.zip",
    destfile = "data/covid19_data.zip"
  )

  data_path <- "covid19-cases-switzerland-master/"
  unzip(
    zipfile   = "data/covid19_data.zip",
    files     = paste0(data_path, c("covid_19_cases_switzerland_standard_format.csv",
      "demographics.csv")),
    exdir     = "data",
    junkpaths = T
  )
}


updateData <- function() {
  # Download data from Johns Hopkins (https://github.com/CSSEGISandData/COVID-19) if the data is older than 0.5h
  if (!dir_exists("data")) {
    dir.create('data')
    downloadGithubData()
  } else if ((!file.exists("data/covid19_data.zip")) || (as.double(Sys.time() - file_info("data/covid19_data.zip")$change_time, units = "hours") > 0.5)) {
    downloadGithubData()
  }
}

# Update with start of app
updateData()

# TODO: Still throws a warning but works for now
data_evolution <- read_csv("data/covid_19_cases_switzerland_standard_format.csv") %>%
  select(date, name_canton, abbreviation_canton, lat, long, total_currently_positive_cases, deaths) %>%
  mutate(date = as.Date(date)) %>%
  rename(
    canton         = abbreviation_canton,
    canton_name    = name_canton,
    positive_cases = total_currently_positive_cases,
    deceased       = deaths
  )

demographics <- read_csv("data/demographics.csv") %>%
  select(Canton, Population) %>%
  rename(canton = Canton, population = Population)

data_evolution <- data_evolution %>% left_join(demographics)
rm(demographics)

# Calculating new cases
data_evolution <- data_evolution %>%
  arrange(date) %>%
  group_by(canton, canton_name, population, lat, long) %>%
  fill(positive_cases, deceased) %>%
  replace_na(list(deceased = 0)) %>%
  mutate(
    active             = (positive_cases - deceased),
    positive_cases_new = positive_cases - lag(positive_cases, 1, default = 0),
    deceased_new       = deceased - lag(deceased, 1, default = 0),
    active_new         = active - lag(active, 1, default = 0)
  ) %>%
  ungroup()

# Get latest data
current_date <- max(data_evolution$date)
changed_date <- file_info("data/covid19_data.zip")$change_time

data_atDate <- function(inputDate) {
  data <- data_evolution %>%
    filter(date == inputDate)
  return(data)
}

data_latest <- data_atDate(max(data_evolution$date))

top5_cantons <- data_evolution %>%
  filter(date == current_date) %>%
  select(canton_name, active) %>%
  arrange(desc(active)) %>%
  top_n(5) %>%
  select(canton_name) %>%
  pull()
