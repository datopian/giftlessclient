#' Do a multipart upload
#'
#' @return Giftless API token
multipart_upload <- function(file_path, upload_specs) {
  actions <- upload_specs$actions

  for (part in actions$parts) {
    print("Uploading part")
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
  }
}
