#' Send a batch request to the LFS server
#'
#' @param prefix character. The lfs prefix in the form organization/repo
#' @param objects list. A list of objects containing oid and size for each one.
#' @param token character. An authorization token.
#' @param transfers character vector. A vector containing the transfer methods
#' to be negotiated with the server.
#' @param headers named character vector. Values to be added to the headers of
#' the batch request to the LFS server..
#'
#' @return List with upload specifications for the given objects
batch <- function(prefix, objects, token, transfers, headers = c()) {
  batch_path <- paste0(prefix, '/objects/batch')
  url <- paste(get_lfs_server_url(), batch_path, sep = '/')

  header <- add_headers(
    Accept = "application/vnd.git-lfs+json",
    `Content-Type` = "application/vnd.git-lfs+json",
    Authorization = paste('Bearer', token),
    .headers = headers
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
