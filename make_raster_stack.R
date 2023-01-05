library(terra)

# weeks 410 to 931
rast_files <- c(glue::glue("s3://habre/li_2020/week{410:931}_mean.tif"), 
                glue::glue("s3://habre/li_2020/week{410:931}_std.tif"))

rast_files <- s3::s3_get_files(rast_files)
r <- terra::rast(rast_files$file_path)
r <- round(r, digits = 2) # original 4 files: 7.7 MB to 4.2 MB
terra::writeRaster(r, "habre.tif", overwrite = TRUE)

fs::dir_delete("s3_downloads")
