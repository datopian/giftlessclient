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
upload_part <- function(file_path, href, pos, size, want_digest=NULL){
  con <- file(file_path, 'rb')
  on.exit(close(con))
  seek(con, where = pos)
  data <- readBin(con, raw(), n = size)

  headers <- add_headers()
  if(!is.null(want_digest)){
    part_digest <- calculate_want_digest(data, want_digest)
    print(part_digest)
    headers <- add_headers(`Content-MD5` = part_digest)
  }

  resp <- PUT(href, config = headers, body = data, encode = 'raw')
  if(http_error(resp)){
    stop("Unexpected reply from server for upload.")
  }
}

#' Calculates a digest for the uploading part
#'
calculate_want_digest <- function(data, want_digest){
  if(want_digest == 'contentMD5'){
    md5 <- digest(data, algo = 'md5', serialize = FALSE, raw=TRUE)
    encoded_digest <- openssl::base64_encode(md5)
    return(encoded_digest)
  } else {
    stop(paste(want_diggest, "method for want_diggest is not supported."), call. = FALSE)
  }
}

#' Parse response given the return type of the API
#'
parse_response <- function(resp){
  if(http_type(resp) == "application/vnd.git-lfs+json") {
    parsed <- jsonlite::fromJSON(content(resp, "text"), simplifyVector = FALSE)
    return(parsed)
  }

  # Azure API returns an xml response for some errors that we need to parse
  if(http_type(resp) == "application/xml" && http_error(resp)){
    resp_content <- xml2::as_list(content(resp))
    parsed <- list(
      code = resp_content$Error$Code,
      message = resp_content$Error$Message
    )
    return(parsed)
  }

  stop("Couldn't parse response data from the API.", call. = FALSE)
}
