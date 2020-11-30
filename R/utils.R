#' Get the Giftless API url from the CKANR_DEFAULT_URL environment variable
#'
#' @return Base url for Giftless API requests
get_lfs_server_url <- function() {
  url <- Sys.getenv("LFS_SERVER_URL")
  if (identical(url, "")){
    stop("Environment variable LFS_SERVER_URL is not set.", call. = FALSE)
  }
  url
}

#' Uploads a file part to a signed_url given size and initial file offset.
upload_part <- function(file_path, href, pos, size, want_digest){
  con <- file(file_path, 'rb')
  on.exit(close(con))
  seek(con, where = pos)
  data <- readBin(con, raw(), n = size)
  PUT(href, body = data, encode = 'raw')
}
