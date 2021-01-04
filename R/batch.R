#' Send a batch request to the LFS server
#'
#' @return Signed URL to
batch <- function(prefix, objects, token, transfers) {
  path <- paste0(prefix, '/objects/batch')
  url <- modify_url(get_lfs_server_url(), path = path)

  header <- add_headers(
    Accept = "application/vnd.git-lfs+json",
    `Content-Type` = "application/vnd.git-lfs+json",
    Authorization = paste('Bearer', token)
  )
  body <- list(
    operation = c("upload"),
    transfers = transfers,
    ref = list(name = "refs/heads/master"),
    objects = objects
    )

  resp <- POST(url, body = body, config = header, encode = 'json')
  parsed <- parse_response(resp)

  if (http_error(resp)) {
    stop(
      sprintf("LFS Server API request failed [%s]\n%s", status_code(resp), parsed$message),
      call. = FALSE
    )
  }

  parsed

}
