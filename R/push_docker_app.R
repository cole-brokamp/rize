#' push a docker image to AWS ECR
#'
#' @param app.name name of application (defaults to working directory)
#' @param repo name of Amazon EC2 container registry
#'
#' @export
#'
#' @details Amazon web services command line tools must be installed and configured for this to properly work
#'
push_docker_app <- function(app.name=basename(getwd()),repo='126952269818.dkr.ecr.us-east-1.amazonaws.com'){
  # login
  login_cmd <- system2('aws',c('ecr','get-login'),stdout=TRUE)
  login_cmd <- strsplit(login_cmd,' ')[[1]][-1]
  system2(find_docker_cmd(),c(login_cmd))
  # create repo
  system2('aws',c('ecr','create-repository','--repository-name',app.name))
  # tag app
  system2(find_docker_cmd(),c('tag',app.name,paste0(repo,'/',app.name)))
  # push it real good
  system2(find_docker_cmd(),c('push',paste0(repo,'/',app.name)))
}
