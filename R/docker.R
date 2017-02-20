#' find the docker executable
#'
#' @return character string that is location of the docker executable
#' @export
#'
find_docker_cmd <- function() {
  docker_cmd <- Sys.which('docker')
  if (length(docker_cmd) == 0) stop(paste('\n','Docker command not found. ','\n',
                                          'Please install docker: ','\n',
                                          'https://www.docker.com/products/overview#/install_the_platform'))
  docker_check <- suppressWarnings(system2(docker_cmd,'ps',stderr=TRUE,stdout=TRUE))
  if(!is.null(attr(docker_check,'status'))) stop(paste0('Cannot connect to the Docker daemon. ',
                                                        'Is the docker daemon running on this host?'))
  return(docker_cmd)
}

#' build docker application
#'
#' @param app.name name of application to make (defaults to working directory)
#'
#' @export
#'
build_docker_app <- function(app.name=basename(getwd())) {
  docker_cmd <- find_docker_cmd()
  system2(docker_cmd,c('build','-t',app.name,'.'))
}

#' find docker image
#'
#' @param repo image name
#' @param tag image tag (defaults to 'latest')
#'
#' @export
#'
find_docker_image <- function(repo,tag='latest') {
  docker_cmd <- find_docker_cmd()
  repo_tag <- paste(repo,tag,sep=':')
  image_id <- system2(docker_cmd,args=c('images','-q',repo_tag),stdout=TRUE)
  error_message <- paste('\n','Docker image',repo_tag,'not found locally.','\n',
                         'Please pull the image from a shell using:','\n',
                         'docker pull',repo_tag)
  if (length(image_id) == 0) stop(error_message,call.=FALSE)
  return(image_id[1])
}

#' run and view a dockerized shiny app
#'
#' @param app.name name of application to make (defaults to working directory)
#'
#' @export
#'
view_docker_app <- function(app.name=basename(getwd())){
  image_id <- find_docker_image(app.name)
  system2(find_docker_cmd(),c('run',paste0('--name=',app.name),
                              '--rm',
                              '-p 3838:3838 ',
                              image_id),
          wait=FALSE)
  Sys.sleep(5) # wait for container to start
  message("Press [enter] to stop and delete container:")
  viewer <- getOption('viewer')
  if (!is.null(viewer)){
    viewer('http://localhost:3838')
  } else{
    utils::browseURL('http://localhost:3838')
  }
  line <- readline()
  on.exit({
    message('removing container...')
    system2(find_docker_cmd(),c('stop',app.name))
  })
}
