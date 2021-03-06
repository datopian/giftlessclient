#' Do a file upload using basic transfer adapter
#'
#' Gets the upload action from the upload specs and makes a PUT request to
#' upload the file to the server. After uploading the file it executes
#' a commit and verify action.
#'
#' @param file_path character. The path of the file to be uploaded.
#' @param upload_specs A list of upload specs returned by the batch call.
basic_upload <- function(file_path, upload_specs) {
  if(!'actions' %in% names(upload_specs)){
    print("No actions, file already exists")
    return
  }
  actions <- upload_specs$actions

  if('upload' %in% names(actions)){
    upload <- actions$upload
    body <- upload_file(file_path)
    resp <- PUT(upload$href, config = do.call(add_headers, upload$header), body = body)
    if (http_error(resp)) {
      parsed <- jsonlite::fromJSON(content(resp, "text"), simplifyVector = FALSE)
      stop(
        sprintf("Error when uploading file [%s]\n%s", status_code(resp), parsed$message),
        call. = FALSE
      )
    }
  }

  if('verify' %in% names(actions)){
    print('Sending verify action')
    verify <- actions$verify

    body <- list(oid = upload_specs$oid, size = upload_specs$size)

    resp <- POST(
      verify$href,
      do.call(add_headers,verify$header),
      body = body,
      encode = 'json'
    )
  }

}
