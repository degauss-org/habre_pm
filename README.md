
<!-- README.md is generated from README.Rmd. Please edit that file -->

# habre_pm <a href='https://degauss.org'><img src='https://github.com/degauss-org/degauss_hex_logo/raw/main/PNG/degauss_hex.png' align='right' height='138.5' /></a>

[![](https://img.shields.io/github/v/release/degauss-org/habre_pm?color=469FC2&label=version&sort=semver)](https://github.com/degauss-org/habre_pm/releases)
[![container build
status](https://github.com/degauss-org/habre_pm/workflows/build-deploy-release/badge.svg)](https://github.com/degauss-org/habre_pm/actions/workflows/build-deploy-release.yaml)

## Using

If `my_address_file_geocoded.csv` is a file in the current working
directory with coordinate columns named `lat`, `lon`, (within the state
of California) `start_date`, and `end_date` then the [DeGAUSS
command](https://degauss.org/using_degauss.html#DeGAUSS_Commands):

``` sh
docker run --rm -v $PWD:/tmp ghcr.io/degauss-org/habre_pm:0.2.1 my_address_file_geocoded.csv
```

will produce `my_address_file_geocoded_habre_pm_0.2.1.csv` with added
columns:

- **`pm`**: time weighted average of weekly PM2.5
- **`sd`**: time weighted square root of average sum of squared weekly
  standard deviation

## Geomarker Methods

- Geocoded points are overlaid with weekly PM2.5 rasters corresponding
  to the input date range.
- For date ranges that span weeks, exposures are a time-weighted
  average.

#### Example code for time weighted average PM and SD

``` r
library(tidyverse)
library(dht)
library(sf)
```

**Read in data**

Here we will only use row 3 of our test file because it spans two
calendar weeks.

``` r
d <- read_csv('test/my_address_file_geocoded_habre_pm25_leo.csv', 
              col_types = cols(start_date = col_date(format = "%m/%d/%y"), 
                               end_date = col_date(format = "%m/%d/%y"))) |>
  slice(3) |>
  select(-prepm25, -prepm25_sd)
d
#> # A tibble: 1 × 6
#>      id   lat   lon start_date end_date   iweek
#>   <dbl> <dbl> <dbl> <date>     <date>     <dbl>
#> 1     3  35.2 -119. 2008-01-25 2008-01-31   413
```

**Expand start and end dates to daily**

``` r
d_daily <- dht::expand_dates(d, by = "day")
d_daily
#> # A tibble: 7 × 7
#>      id   lat   lon start_date end_date   iweek date      
#>   <dbl> <dbl> <dbl> <date>     <date>     <dbl> <date>    
#> 1     3  35.2 -119. 2008-01-25 2008-01-31   413 2008-01-25
#> 2     3  35.2 -119. 2008-01-25 2008-01-31   413 2008-01-26
#> 3     3  35.2 -119. 2008-01-25 2008-01-31   413 2008-01-27
#> 4     3  35.2 -119. 2008-01-25 2008-01-31   413 2008-01-28
#> 5     3  35.2 -119. 2008-01-25 2008-01-31   413 2008-01-29
#> 6     3  35.2 -119. 2008-01-25 2008-01-31   413 2008-01-30
#> 7     3  35.2 -119. 2008-01-25 2008-01-31   413 2008-01-31
```

**Read in date lookup / week index and expand start and end dates to
daily**

``` r
date_lookup <- 
  readr::read_csv("pm25_iweek_startdate.csv") |>
  dht::expand_dates(by = "day") 

date_lookup |>
  filter(iweek %in% 413:414)
#> # A tibble: 14 × 4
#>    iweek start_date end_date   date      
#>    <dbl> <date>     <date>     <date>    
#>  1   413 2008-01-21 2008-01-27 2008-01-21
#>  2   413 2008-01-21 2008-01-27 2008-01-22
#>  3   413 2008-01-21 2008-01-27 2008-01-23
#>  4   413 2008-01-21 2008-01-27 2008-01-24
#>  5   413 2008-01-21 2008-01-27 2008-01-25
#>  6   413 2008-01-21 2008-01-27 2008-01-26
#>  7   413 2008-01-21 2008-01-27 2008-01-27
#>  8   414 2008-01-28 2008-02-03 2008-01-28
#>  9   414 2008-01-28 2008-02-03 2008-01-29
#> 10   414 2008-01-28 2008-02-03 2008-01-30
#> 11   414 2008-01-28 2008-02-03 2008-01-31
#> 12   414 2008-01-28 2008-02-03 2008-02-01
#> 13   414 2008-01-28 2008-02-03 2008-02-02
#> 14   414 2008-01-28 2008-02-03 2008-02-03

date_lookup <- 
  date_lookup |>
  dplyr::select(week = iweek, date)
```

**Join week index to input data using date (daily)**

``` r
d_week <- d_daily |>
  dplyr::left_join(date_lookup, by = "date")

d_week
#> # A tibble: 7 × 8
#>      id   lat   lon start_date end_date   iweek date        week
#>   <dbl> <dbl> <dbl> <date>     <date>     <dbl> <date>     <dbl>
#> 1     3  35.2 -119. 2008-01-25 2008-01-31   413 2008-01-25   413
#> 2     3  35.2 -119. 2008-01-25 2008-01-31   413 2008-01-26   413
#> 3     3  35.2 -119. 2008-01-25 2008-01-31   413 2008-01-27   413
#> 4     3  35.2 -119. 2008-01-25 2008-01-31   413 2008-01-28   414
#> 5     3  35.2 -119. 2008-01-25 2008-01-31   413 2008-01-29   414
#> 6     3  35.2 -119. 2008-01-25 2008-01-31   413 2008-01-30   414
#> 7     3  35.2 -119. 2008-01-25 2008-01-31   413 2008-01-31   414
```

**Read in and join raster values**

``` r
r <- terra::rast("habre.tif")

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

d_out <- left_join(d_week, d_dedup, by = c("lat", "lon", "week")) 

d_out
#> # A tibble: 7 × 12
#>      id   lat   lon start_date end_date   iweek date        week layer_name_mean
#>   <dbl> <dbl> <dbl> <date>     <date>     <dbl> <date>     <dbl> <glue>         
#> 1     3  35.2 -119. 2008-01-25 2008-01-31   413 2008-01-25   413 week413_mean   
#> 2     3  35.2 -119. 2008-01-25 2008-01-31   413 2008-01-26   413 week413_mean   
#> 3     3  35.2 -119. 2008-01-25 2008-01-31   413 2008-01-27   413 week413_mean   
#> 4     3  35.2 -119. 2008-01-25 2008-01-31   413 2008-01-28   414 week414_mean   
#> 5     3  35.2 -119. 2008-01-25 2008-01-31   413 2008-01-29   414 week414_mean   
#> 6     3  35.2 -119. 2008-01-25 2008-01-31   413 2008-01-30   414 week414_mean   
#> 7     3  35.2 -119. 2008-01-25 2008-01-31   413 2008-01-31   414 week414_mean   
#> # ℹ 3 more variables: layer_name_sd <glue>, pm <dbl>, sd <dbl>

d_out <- d_out |>
  group_by(id) |>
  summarize(pm = round(sum(pm)/n(),2), 
            sd = round(sqrt((sum(sd^2))/n()),2))


d_out <- left_join(d, d_out, by = "id")
d_out
#> # A tibble: 1 × 8
#>      id   lat   lon start_date end_date   iweek    pm    sd
#>   <dbl> <dbl> <dbl> <date>     <date>     <dbl> <dbl> <dbl>
#> 1     3  35.2 -119. 2008-01-25 2008-01-31   413  3.76   2.2
```

## Geomarker Data

- PM2.5 rasters were created using a model developed by Rima Habre and
  Lianfa Li.

> Li L, Girguis M, Lurmann F, Pavlovic N, McClure C, Franklin M, Wu J,
> Oman LD, Breton C, Gilliland F, Habre R. Ensemble-based deep learning
> for estimating PM2. 5 over California with multisource big data
> including wildfire smoke. Environment international. 2020 Dec
> 1;145:106143. <https://doi.org/10.1016/j.envint.2020.106143>

- The raster stack used in this container is stored in S3 at
  [`s3://habre/habre.tif`](https://habre.s3-us-east-2.amazonaws.com/habre.tif)
- Individual rasters that make up the raster stack are stored at
  [`s3://habre/li_2020/`](https://habre.s3-us-east-2.amazonaws.com/li_2020/)

## DeGAUSS Details

For detailed documentation on DeGAUSS, including general usage and
installation, please see the [DeGAUSS homepage](https://degauss.org).
