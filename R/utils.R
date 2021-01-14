#' Get the Giftless API url from the LFS_SERVER_URL environment variable
#'
#' @return Full URL for Giftless API requests
get_lfs_server_url <- function() {
  url <- Sys.getenv("LFS_SERVER_URL")
  if (identical(url, "")){
    stop("Environment variable LFS_SERVER_URL is not set.", call. = FALSE)
  }
  url
}

#' Uploads a file part
#'
#' Uploads a file part to a signed_url given size and initial position. This
#' method will read a chunk of the file using readBin. If want_digest is set it
#' will also calculate the digest and send it as a part of the header (only
#' MD5 is supported)
#'
#' @param file_path character. string naming a file
#' @param href character. A signed URL to upload the file to
#' @param pos numeric. A file position (relative to the origin specified by
#' origin), or NA.
#' @param size numeric. The (maximal) number of records to be read.
#' @param want_diggest character. A string specifying the digest algorithm to
#' use. (Currently only contentMD5 is supported)
upload_part <- function(file_path, href, pos, size, want_digest=NULL){
  con <- file(file_path, 'rb')
  on.exit(close(con))
  seek(con, where = pos)
  data <- readBin(con, raw(), n = size)

  headers <- add_headers()
  if(!is.null(want_digest)){
    part_digest <- calculate_want_digest(data, want_digest)
    headers <- add_headers(`Content-MD5` = part_digest)
  }

  resp <- PUT(href, config = headers, body = data, encode = 'raw')
  if(http_error(resp)){
    stop("Unexpected reply from server for upload.")
  }
}

#' Calculates a digest for the uploading part
#'
#' @param data raw object.
#' @param want_diggest character. A string specifying the digest algorithm to
#' use. (Currently only contentMD5 is supported)
#'
#' @returns caracter. The digest string: for contentMD5 it returns a base64
#' encoded digest.
calculate_want_digest <- function(data, want_digest){
  if(want_digest == 'contentMD5'){
    md5 <- digest(data, algo = 'md5', serialize = FALSE, raw=TRUE)
    encoded_digest <- openssl::base64_encode(md5)
    return(encoded_digest)
  } else {
    stop(paste(want_digest, "method for want_digest is not supported."), call. = FALSE)
  }
}

#' Parse the content of the LFS server response
#'
#'@param resp response object.
#'
#'@returns A parsed response.
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

#' Wrapper for R's file.size(...) function
#'
#' This is a workaround for situations where R returns a scientific notation
#' value.
#'
#'@param file_path character. string naming a file
#'
#'@returns A character with the size in KB of the file
file_size <- function(file_path){
  format(file.size(file_path), scientific = FALSE)
}
