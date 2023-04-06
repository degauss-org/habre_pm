#!/usr/local/bin/Rscript

dht::greeting()

## load libraries without messages or warnings
withr::with_message_sink("/dev/null", library(dplyr))
withr::with_message_sink("/dev/null", library(tidyr))
withr::with_message_sink("/dev/null", library(sf))
withr::with_message_sink("/dev/null", library(terra))
withr::with_message_sink("/dev/null", library(lubridate))
withr::with_message_sink("/dev/null", library(dht))
withr::with_message_sink("/dev/null", library(readr))

doc <- "
      Usage:
      entrypoint.R <filename>
      "

opt <- docopt::docopt(doc)

## for interactive testing
## opt <- docopt::docopt(doc, args = 'test/my_address_file_geocoded.csv')

message("reading input file...")
d <- dht::read_lat_lon_csv(opt$filename, nest_df = F, sf = F)

dht::check_for_column(d, "lat", d$lat)
dht::check_for_column(d, "lon", d$lon)
dht::check_for_column(d, "start_date", d$start_date)
dht::check_for_column(d, "end_date", d$end_date)


d$start_date <- dht::check_dates(d$start_date)
d$end_date <- dht::check_dates(d$end_date)
dht::check_end_after_start_date(d$start_date, d$end_date)

# read in tif and date lookup
r <- terra::rast("/app/habre.tif")

date_lookup <- readr::read_csv("/app/pm25_iweek_startdate.csv") |>
  dht::expand_dates(by = "day") |>
  dplyr::select(week = iweek, date)

# expand dates
d_daily <- dht::expand_dates(d, by = "day")

# join to get week number
d_week <- d_daily |>
  dplyr::left_join(date_lookup, by = "date")

d_dedup <- d_week |>
  select(lat, lon, week) |>
  group_by(lat, lon, week) |>
  filter(!duplicated(lat, lon, week)) |>
  mutate(layer_name_mean = glue::glue("week{week}_mean"), 
         layer_name_sd = glue::glue("week{week}_std")) 

d_for_extract <- d_dedup |>
  st_as_sf(coords = c("lon", "lat"), crs = 4326) |>
  st_transform(st_crs(r)) |>
  terra::vect()

d_pm <- terra::extract(r,
                       d_for_extract,
                       layer = "layer_name_mean") 

d_sd <- terra::extract(r,
                       d_for_extract,
                       layer = "layer_name_sd")

d_dedup <- d_dedup |>
  ungroup() |>
  mutate(pm = d_pm$value,
         sd = d_sd$value)

d_out <- left_join(d_week, d_dedup, by = c("lat", "lon", "week")) |>
  group_by(.row) |>
  summarize(pm = round(sum(pm)/n(),2), 
            sd = round(sqrt((sum(sd^2))/n()),2))

d_out <- left_join(d, d_out, by = ".row") |>
  select(-.row)

## merge back on .row after unnesting .rows into .row
dht::write_geomarker_file(d = d_out, filename = opt$filename)
