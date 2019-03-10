FROM rocker/shiny

MAINTAINER "Cole Brokamp" cole.brokamp@gmail.com

RUN echo "options(repos = c(CRAN = 'https://cran.rstudio.com/'), prompt='R > ', download.file.method = 'libcurl')" > /.Rprofile

RUN R -e "install.packages('automagic')"

## ON BUILD

ONBUILD RUN mkdir /srv/shiny-server/app
ONBUILD COPY . /srv/shiny-server/app

# create config for use in rize R package
ONBUILD RUN echo "run_as shiny; \
		     server { \
  		       listen 3838; \
  		       location / { \
    		         app_dir /srv/shiny-server/app; \
    		         directory_index off; \
    		         log_dir /var/log/shiny-server; \
  		       } \
		     }" > /etc/shiny-server/shiny-server.conf

# if config file exists, then add it, overwriting the sample file
ONBUILD RUN if [ -f /srv/shiny-server/app/shiny-server.conf ]; \
               then (>&2 echo "Using config file inside app directory") \
               && cp /srv/shiny-server/app/shiny-server.conf /etc/shiny-server/shiny-server.conf; \
               fi

# install necessary R packages
ONBUILD RUN R -e "setwd('/srv/shiny-server/app'); automagic::automagic()"

# start it
ONBUILD CMD exec shiny-server >> /var/log/shiny-server.log 2>&1

