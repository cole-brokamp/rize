#' dockerize a shiny application
#'
#' @param directory path to directory containing the shiny app (defaults to
#'   working directory)
#' @param re.automagic logical; force automagic to recreate dependencies file
#' @param app.name defaults to the basename of \code{directory}
#' @param view_app defaults to TRUE, run the Docker container to preview
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
shiny_dockerize <- function(directory = getwd(),
                            re.automagic = FALSE,
                            app.name = basename(directory),
                            view.app = FALSE) {
  # if no dependencies file, make one (force rescan with re.automagic)
  if (!file.exists(file.path(directory,'deps.yaml')) | re.automagic) {
    if (re.automagic) unlink(file.path(directory,'deps.yaml'))
    message('making deps.yaml dependency file with automagic...')
    automagic::make_deps_file(directory=directory)
  }
  # if no Dockerfile, make one
  if (!file.exists(file.path(directory,'Dockerfile'))) {
    cat('FROM colebrokamp/rize:latest',file='Dockerfile',append=FALSE)
  }
  # find docker installation
  docker_cmd <- find_docker_cmd()

  # build image
  message('building the docker image...')
  build_docker_app(app.name)

  # test view it
  if (view_app) {
    message('running container to view the app...')
    view_docker_app(app.name)
  }
}
