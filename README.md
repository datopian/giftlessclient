
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
Sys.setenv("LFS_SERVER_URL" = 'http://www.my-lfs-server.com')
```

### Upload using multipart-basic transfer adapter

```r
file_path <- "~/Documents/large-file.bin"
repository <- "repository"
dataset <- "large-dataset"
authz_token <- "eyJ0eXAiOiJK.eyJleHAiOjE2.WOalwa58Wr7_q3zm"

lfs_upload(file_path, repository, dataset, authz_token, transfer=c('multipart-basic'))

```

### Upload using basic transfer adapter

```r
file_path <- "~/Documents/my-small-csv.csv"
repository <- "repository"
dataset <- "small-dataset"
authz_token <- "eyJ0eXAiOiJK.eyJleHAiOjE2.WOalwa58Wr7_q3zm"

lfs_upload(file_path, repository, dataset, authz_token, transfer=c('basic'))

```

The `transfers` parameter is optional, and represents a list of supported transfer adapters by priority to negotiate with the server; Typically, there is no reason to provide this parameter.

## License

giftlessclient is free software distributed under the terms of the MIT license. See [LICENSE](LICENSE.md) for details.

giftlessclient is (c) 2020 Datopian / Viderum Inc.
