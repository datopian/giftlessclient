#' Upload a file to LFS storage
#'
#' @param file_path character. The path of the file to be uploaded.
#' @param repo character. The name of repository where the dataset lives.
#' @param dataset character. The name of the dataset where the file is gonna
#' be uploaded.
#' @param token character. Authorization token.
#' @param transfers character vector. A vector containing the transfer methods
#' to be negotiated with the server.
#' @param headers named character vector. Values to be added to the headers of
#' the batch request to the LFS server.
#'
#' @return list with sha256 and size of the object
lfs_upload <- function(file_path, repo, dataset, token, transfers=c("multipart-basic", "basic"), headers = c()) {
  hash <- digest(file=file_path, algo='sha256')
  size <- file.size(file_path)
  object <- list(list(oid = hash, size = size))
  prefix <- paste0(repo, '/', dataset)

  resp <- batch(prefix, object, token, transfers, headers = headers)

  upload_specs <- resp$objects[[1]]
  if(!'actions' %in% names(upload_specs)){
    print("No actions, file already exists")
    return(list(sha256=hash, size=size))
  }

  transfer <- resp$transfer
  if (transfer == 'multipart-basic'){
    print("Initiating multipart-basic upload")
    multipart_upload(file_path, upload_specs)
  }

  if (transfer == 'basic'){
    print("Initiating basic upload")
    basic_upload(file_path, upload_specs)
  }

  return(list(sha256=hash, size=size))
}
