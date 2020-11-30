#' Send a batch request to the LFS server
#'
#' @return Signed URL to
batch <- function(prefix, objects, token) {
  path <- paste0(prefix, '/objects/batch')
  url <- modify_url(get_lfs_server_url(), path = path)

  header <- add_headers(
    Accept = "application/vnd.git-lfs+json",
    `Content-Type` = "application/vnd.git-lfs+json",
    Authorization = paste('Bearer', token)
  )

  body <- list(
    operation = c("upload"),
    transfers = c("multipart-basic"),
    ref = list(name = "refs/heads/contrib"),
    objects = objects
    )
  body <- jsonlite::toJSON(body, auto_unbox = TRUE)

  resp <- POST(url, body = body, config = header, encode = 'json')

  parsed <- jsonlite::fromJSON(content(resp, "text"), simplifyVector = FALSE)

  if (http_error(resp)) {
    stop(
      sprintf("LFS Server API request failed [%s]\n%s", status_code(resp), parsed$message),
      call. = FALSE
    )
  }

  parsed

}
