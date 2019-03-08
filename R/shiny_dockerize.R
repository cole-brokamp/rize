#' dockerize a shiny application
#'
#' @param directory path to directory containing the shiny app (defaults to
#'   working directory)
#' @param re.automagic logical; force automagic to recreate dependencies file
#' @param app.name defaults to the basename of \code{directory}
#' @param base Dockerfile template to use, use NULL to create one-line Dockerfile for customisation
#' @param build Should the image try to be built
#' @param launch Should the image be launched immediately
#'
#' @details This is a wrapper function that uses automagic package to build,
#'   test, and view a dockerized shiny application. See
#'   \code{\link{push_docker_app}} to push the image to an Amazon EC2 container
#'   registry.
#'
#' @seealso \code{\link{find_docker_cmd}}, \code{\link{build_docker_app}}, \code{\link{view_docker_app}}
#'
#' @export
#'
shiny_dockerize <- function(directory=getwd(),re.automagic=FALSE,
                            app.name=basename(directory), build = TRUE, launch = TRUE,
                            base = system.file('rize','rize-Dockerfile', package = 'rize')) {
  # if no dependencies file, make one (force rescan with re.automagic)
  if (!file.exists(file.path(directory,'deps.yaml')) | re.automagic) {
    if (re.automagic) unlink(file.path(directory,'deps.yaml'))
    message('making deps.yaml dependency file with automagic...')
    automagic::make_deps_file(directory=directory)
  }
  # if no Dockerfile, make one
  if (!file.exists(file.path(directory,'Dockerfile'))) {
    if(is.null(base)){
      cat('FROM colebrokamp/rize:latest', file=file.path(directory,'Dockerfile'),
          append=FALSE)
    } else {
      file.copy(base, file.path(directory,'Dockerfile'))
    }

  }
  # find docker installation
  docker_cmd <- find_docker_cmd()

  # build image
  if(build){
  message('building the docker image...')
  build_docker_app(app.name)
  }

  # test view it
  if(launch){
  message('running container to view the app...')
  view_docker_app(app.name)
  }

}
