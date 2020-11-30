#' Do a multipart upload
#'
#' @return Giftless API token
multipart_upload <- function(file_path, upload_specs) {
  if(!'actions' %in% names(upload_specs)){
    print("No actions, file already exists")
    return
  }

  actions <- upload_specs$actions

  for (part in actions$parts) {
    print("Uploading part")
    upload_part(file_path, part$href, part$pos, part$size, part$want_diggest)
  }

  if('commit' %in% names(actions)){
    print('Sending commit action')
    commit <- actions$commit
    resp <- PUT(commit$href,
        config = do.call(add_headers, commit$header),
        body = commit$body,
        encode='char')

    parsed <- jsonlite::fromJSON(content(resp, "text"), simplifyVector = FALSE)

    if (http_error(resp)) {
      stop(
        sprintf("Error when executing commit action [%s]\n%s", status_code(resp), parsed$message),
        call. = FALSE
      )
    }
  }

  if('verify' %in% names(actions)){
    print('Sending commit action')
    verify <- actions$verify

    body <- list(
      oid = upload_specs$oid,
      size = upload_specs$size
    )

    resp <- POST(
      verify$href,
      do.call(add_headers,verify$header),
      body = body,
      encode = 'json'
      )
  }
}
