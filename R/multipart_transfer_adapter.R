#' Do a file upload using basic transfer adapter
#'
#' Gets the upload action from the upload specs and makes a PUT request to the
#' server for each part specified. After uploading all the parts it executes
#' a commit and verify action.
#'
#' @param file_path character. The path of the file to be uploaded.
#' @param upload_specs A list of upload specs returned by the batch call.
multipart_upload <- function(file_path, upload_specs) {
  actions <- upload_specs$actions

  parts_length <- length(actions$parts)
  for (i in 1:parts_length) {
    part <- actions$parts[[i]]
    print(sprintf("Uploading part %i of %i.", i, parts_length))
    upload_part(file_path, part$href, part$pos, part$size, part$want_digest)
  }

  if('commit' %in% names(actions)){
    print('Sending commit action')
    commit <- actions$commit
    resp <- PUT(
        commit$href,
        config = do.call(add_headers, commit$header),
        body = commit$body,
        encode='raw'
        )

    if (http_error(resp)) {
      parsed <- parse_response(resp)
      stop(
        sprintf("Error when executing commit action [%s]\n%s", status_code(resp), parsed$message),
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

    if (http_error(resp)) {
      parsed <- parse_response(resp)
      stop(
        sprintf("Error when executing verify action [%s]\n%s", status_code(resp), parsed$message),
        call. = FALSE
      )
    }
  }
}
