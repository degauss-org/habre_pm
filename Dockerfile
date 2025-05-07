FROM rocker/r-ver:4.2.2

# DeGAUSS container metadata
ENV degauss_name="habre_pm"
ENV degauss_version="0.2.2"
ENV degauss_description="weekly pm2.5 for California (Habre)"

# add OCI labels based on environment variables too
LABEL "org.degauss.name"="${degauss_name}"
LABEL "org.degauss.version"="${degauss_version}"
LABEL "org.degauss.description"="${degauss_description}"

RUN R --quiet -e "install.packages('renv')"

WORKDIR /app

RUN apt-get update \
    && apt-get install -yqq --no-install-recommends \
    libgdal-dev \
    libgeos-dev \
    libudunits2-dev \
    libproj-dev \
    && apt-get clean

COPY renv.lock .

RUN R --quiet -e "renv::restore(repos = c(CRAN = 'https://packagemanager.posit.co/cran/__linux__/jammy/latest'))"

ADD https://github.com/degauss-org/habre_pm/releases/download/0.2.1/habre.tif habre.tif
COPY pm25_iweek_startdate.csv .
COPY entrypoint.R .

WORKDIR /tmp

ENTRYPOINT ["/app/entrypoint.R"]