#' Upload a file to LFS storage
#'
#' @return Giftless API token
lfs_upload <- function(file_path, repo, dataset, token, transfers=c("multipart-basic", "basic")) {
  hash <- digest(file=file_path, algo='sha256')
  size <- file.size(file_path)
  object <- list(list(oid = hash, size = size))
  prefix <- paste0(repo, '/', dataset)

  resp <- batch(prefix, object, token, transfers)

  upload_specs <- resp$objects[[1]]
  transfer <- transfers[1]
  if (transfer == 'multipart-basic'){
    print("Initiating multipart-basic upload")
    multipart_upload(file_path, upload_specs)
  }

  if (transfer == 'basic'){
    print("Initiating basic upload")
    basic_upload(file_path, upload_specs)
  }
}
