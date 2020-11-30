#' Upload a file to LFS storage
#'
#' @return Giftless API token
upload <- function(file_path, repo, dataset, token) {
  hash <- digest(file=file_path, algo='sha256')
  size <- file.size(file_path)

  object <- list(list(oid = hash, size = size))

  prefix <- paste0(repo, '/', dataset)

  resp <- batch(prefix, object, token)
  upload_specs <- resp$objects[[1]]

  multipart_upload(file_path, upload_specs)
}
