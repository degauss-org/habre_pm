# habre_pm <a href='https://degauss.org'><img src='https://github.com/degauss-org/degauss_hex_logo/raw/main/PNG/degauss_hex.png' align='right' height='138.5' /></a>

[![](https://img.shields.io/github/v/release/degauss-org/habre_pm?color=469FC2&label=version&sort=semver)](https://github.com/degauss-org/habre_pm/releases)
[![container build status](https://github.com/degauss-org/habre_pm/workflows/build-deploy-release/badge.svg)](https://github.com/degauss-org/habre_pm/actions/workflows/build-deploy-release.yaml)

## Using

If `my_address_file_geocoded.csv` is a file in the current working directory with coordinate columns named `lat`, `lon`, (within the state of California) `start_date`, and `end_date` then the [DeGAUSS command](https://degauss.org/using_degauss.html#DeGAUSS_Commands):

```sh
docker run --rm -v $PWD:/tmp ghcr.io/degauss-org/habre_pm:0.2.0 my_address_file_geocoded.csv
```

will produce `my_address_file_geocoded_habre_pm_0.2.0.csv` with added columns:

- **`pm`**: time weighted average of weekly PM2.5
- **`sd`**: standard deviation

## Geomarker Methods

- Geocoded points are overlaid with weekly PM2.5 rasters corresponding to the input date range.
- For date ranges that span weeks, exposures are a time-weighted average. 

## Geomarker Data

- PM2.5 rasters were created using a model developed by Rima Habre and Lianfa Li. 

> Li L, Girguis M, Lurmann F, Pavlovic N, McClure C, Franklin M, Wu J, Oman LD, Breton C, Gilliland F, Habre R. Ensemble-based deep learning for estimating PM2. 5 over California with multisource big data including wildfire smoke. Environment international. 2020 Dec 1;145:106143. https://doi.org/10.1016/j.envint.2020.106143

- The raster stack used in this container is stored in S3 at [`s3://habre/habre.tif`](https://habre.s3-us-east-2.amazonaws.com/habre.tif)
- Individual rasters that make up the raster stack are stored at [`s3://habre/li_2020/`](https://habre.s3-us-east-2.amazonaws.com/li_2020/)

## DeGAUSS Details

For detailed documentation on DeGAUSS, including general usage and installation, please see the [DeGAUSS homepage](https://degauss.org).
