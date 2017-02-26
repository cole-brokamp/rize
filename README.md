# rize

[![](https://images.microbadger.com/badges/image/colebrokamp/rize.svg)](https://microbadger.com/images/colebrokamp/rize)
[![](https://images.microbadger.com/badges/version/colebrokamp/rize.svg)](https://hub.docker.com/r/colebrokamp/rize/)
[![DOI](https://zenodo.org/badge/82612564.svg)](https://zenodo.org/badge/latestdoi/82612564)

> A robust method to automagically docke**rize** your R Shiny Application

## Dockerize Your Shiny App

Within the working directory of a shiny application, run in R:

`rize::shiny_dockerize()`

This function takes the following steps to build, test, and view a dockerized shiny application:

1. Make a dependencies file if one does not already exist using the `automagic` R package
2. Create a simple Dockerfile that relies on the `colebrokamp/rize` Docker image
3. Find a valid docker executable with `find_docker_cmd`
4. Build the docker image with `build_docker_app`
5. `view_docker_app`: starts the app in a container and opens in RStudio Viewer or browser

`shiny_dockerize()` tries to be intelligent by not requiring any arguments; for example, the name (and location) of the shiny application is assumed to be the current working directory. However, customization such as using a different shiny server configuration file, installing other R packages and system libraries, using google analytics, and other docker specific options are possible if using the other functions available in the package. It is also possible to push the image to [AWS ECR](https://aws.amazon.com/ecr/) using `push_docker_app`.

## How It Works

Several things happen when this base image is used to generate a dockerized shiny application by using `ONBUILD` commands in the Dockerfile for `colebrokamp/rize`.

**Application Code/Data**: The contents of the entire build context (i.e. the working directory) are copied to `/srv/shiny-server/app/`. Note that *all* the contents of the working directory are copied to the Docker daemon. To speed up the build time, keep only files necessary for the Shiny app alongside the Dockerfile in the working directory.

**Installing Necessary R Packages**: [`automagic`](www.github.com/cole-brokamp/automagic) creates a dependencies file by parsing the code in the app directory and installs the same versions of these packages that are present in your local R library when building the Docker image so that no other customization should be necessary. This prevents the user from having to create Dockerfiles or worry about R package dependencies inside the docker image.

**Shiny Server Configuration**: By default, a simple `shiny-server.conf` is installed at `/etc/shiny-server/shiny-server.conf`. This tells shiny to only serve one application (`/srv/shiny-server/app`) instead of hosting the entire directory. To use a custom configuration file, include a file in the app directory called `shiny-server.conf`. If this file is present, it will be copied to `/etc/shiny-server/shiny-server.conf` instead of downloading and using the example configuration file. See more details on server configuration [here](http://docs.rstudio.com/shiny-server/#server-management).

## Install

Install with `remotes::install_github('cole-brokamp/rize')`.   

Make sure that a valid docker installation is available on your machine. This package has only been tested with the docker executable, *not* with Docker Toolbox.
