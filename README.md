
# giftlessclient

<!-- badges: start -->
<!-- badges: end -->

A Git LFS client library implemented in R, compatible with the [Giftless Git LFS server](https://github.com/datopian/giftless).

## Installation

You can install `giftlessclient` from GitHub with:

``` r
devtools::install_github("datopian/giftlessclient")
```

## Example

To use `giftlessclient` you need to set up your lfs server URL in a environment variable:

``` r
Sys.setenv("LFS_SERVER_URL" = 'https://www.my-lfs-server.com')
```


#### Upload using multipart-basic transfer adapter

```r
file_path <- "~/Documents/large-file.bin"
repository <- "repository"
dataset <- "large-dataset"
authz_token <- "eyJ0eXAiOiJK.eyJleHAiOjE2.WOalwa58Wr7_q3zm"

resp <- lfs_upload(file_path, repository, dataset, authz_token, transfer=c('multipart-basic'))
```

* `file_path`: a readable, seekable file-like object
* `repository`, `dataset`: used to generate the prefix for the batch request in form `repository/dataset`
* `authz_token`: Bearer token required by the server


Returns two files attributes: `sha256` of the file and it's `size`
```
> resp
$sha256
[1] "06c2e256b425f0222db6f14386aa827135043a0645f98e734d3c5cb2999e883f"

$size
[1] "51"

>
```


#### Upload using basic transfer adapter

```r
file_path <- "~/Documents/my-small-csv.csv"
repository <- "repository"
dataset <- "small-dataset"
authz_token <- "eyJ0eXAiOiJK.eyJleHAiOjE2.WOalwa58Wr7_q3zm"

lfs_upload(file_path, repository, dataset, authz_token, transfer=c('basic'))

```

The `transfers` parameter is optional, and represents a list of supported transfer adapters by priority to negotiate with the server; Typically, there is no reason to provide this parameter.


#### Sending a batch request to the server

Send a [batch request](https://github.com/git-lfs/git-lfs/blob/master/docs/api/batch.md) to the LFS server:

```r
lfs_prefix <- 'organization/giftlessclient'
objects <- list(list(oid = '1231231', size = 12313))
authz_token <- "eyJ0eXAiOiJK.eyJleHAiOjE2.WOalwa58Wr7_q3zm"

batch(lfs_prefix, objects, authz_token, transfer = c('multipart-basic'))

```

* `lfs_prefix`: add to LFS server url e.g. if `lfs_prefix <- "abc"` and client was created with server url of `https://www.my-lfs-server.com` then batch request is made by POST to `https://www.my-lfs-server.com/abc/objects/batch`
* `objects`: a list of objects to upload. 
  * `oid`: String OID (`sha256`) of the LFS object.
  * `size`: Byte size of the LFS object. Must be at least zero.


## License

giftlessclient is free software distributed under the terms of the MIT license. See [LICENSE](LICENSE.md) for details.

giftlessclient is (c) 2020 Datopian / Viderum Inc.
