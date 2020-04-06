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
    url      = "https://raw.githubusercontent.com/openZH/covid_19/master/COVID19_Fallzahlen_CH_total.csv",
    destfile = "data/COVID19_Fallzahlen_CH_total.csv"
  )
}

updateData <- function() {
  # Download data from Johns Hopkins (https://github.com/CSSEGISandData/COVID-19) if the data is older than 0.5h
  if (!dir_exists("data")) {
    dir.create('data')
    downloadGithubData()
  } else if ((!file.exists("data/covid19_data.zip")) || (as.double(Sys.time() - file_info("data/COVID19_Fallzahlen_CH_total.csv")$birth_time, units = "hours") > 0.5)) {
    downloadGithubData()
  }
}

# Update with start of app
updateData()
demographics <- read_csv("data/demographics.csv")

data_evolution <- read_csv("data/COVID19_Fallzahlen_CH_total.csv") %>%
  select(-time, -source) %>%
  mutate(ncumul_tested = as.numeric(replace(ncumul_tested, ncumul_tested == ">900", 900))) %>%
  full_join(demographics) %>%
  mutate(date = as.Date(date)) %>%
  rename(
    canton         = abbreviation_canton_and_fl,
    positive_cases = ncumul_conf,
    deceased       = ncumul_deceased
  ) %>%
  # Make sure all dates are available for all cantons
  pivot_longer(names_to = "var", cols = c(ncumul_tested, positive_cases, ncumul_hosp, ncumul_ICU, ncumul_vent, ncumul_released, deceased)) %>%
  pivot_wider(id_cols = c(canton, name, population, lat, long, var), names_from = date, values_from = value)

# Recreate old format
data_evolution <- data_evolution %>%
  pivot_longer(names_to = "date", cols = c(7:ncol(data_evolution))) %>%
  pivot_wider(id_cols = c(canton, name, population, lat, long, date), names_from = var, values_from = value) %>%
  mutate(date = as.Date(date))

# Calculating new cases
data_evolution <- data_evolution %>%
  arrange(date) %>%
  group_by(canton, name, population, lat, long) %>%
  fill(ncumul_tested, positive_cases, ncumul_hosp, ncumul_ICU, ncumul_vent, ncumul_released, deceased) %>%
  replace_na(list(deceased = 0, positive_cases = 0, ncumul_released = 0)) %>%
  mutate(
    recovered          = lag(positive_cases, 14, default = 0) - deceased,
    recovered          = ifelse(recovered > 0, recovered, 0),
    recovered          = ifelse(ncumul_released > recovered, ncumul_released, recovered),
    active             = (positive_cases - deceased - recovered),
    positive_cases_new = positive_cases - lag(positive_cases, 1, default = 0),
    recovered_new      = recovered - lag(recovered, 1, default = 0),
    deceased_new       = deceased - lag(deceased, 1, default = 0),
    active_new         = active - lag(active, 1, default = 0)
  ) %>%
  ungroup()

# Get latest data
current_date <- max(data_evolution$date, na.rm = T)
changed_date <- file_info("data/COVID19_Fallzahlen_CH_total.csv")$birth_time

data_atDate <- function(inputDate) {
  data <- data_evolution %>%
    filter(date == inputDate)
  return(data)
}

data_latest <- data_atDate(current_date)

top5_cantons <- data_evolution %>%
  filter(date == current_date) %>%
  select(name, active) %>%
  arrange(desc(active)) %>%
  top_n(5) %>%
  select(name) %>%
  pull()
