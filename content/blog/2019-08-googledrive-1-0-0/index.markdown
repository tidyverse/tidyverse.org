---
title: googledrive v1.0.0
slug: googledrive-1-0-0
author: Jenny Bryan
description: >
  googledrive v1.0.0 is on CRAN.
date: '2019-08-20'
categories: [package]
tags:
  - googledrive
  - tidyverse
photo:
  url: https://unsplash.com/photos/8EzNkvLQosk
  author: Maarten van den Heuvel
---



## Introduction

We're jazzed to announce the release of googledrive v1.0.0 (<https://googledrive.tidyverse.org>).

googledrive wraps the [Drive REST API v3](https://developers.google.com/drive/). The most common file operations are implemented in high-level functions designed for ease of use. You can find, list, create, trash, delete, rename, move, copy, browse, download, share and publish Drive files, including those on Team Drives.

Install googledrive with:


```r
install.packages("googledrive")
```

The release of version 1.0.0 marks two events:

  * The overall design of googledrive has survived ~2 years on CRAN, with very little need for change. The interface and feature set are fairly stable. googledrive facilitated around 7 million requests to the Drive API in the past month. But also ...
  * There are changes in the auth interface that are not backwards compatible.
  
There is also new functionality that makes it less likely you'll create multiple files with the same name, without actually meaning to.

## Auth from gargle

googledrive's auth functionality now comes from the [gargle package](https://gargle.r-lib.org), which provides R infrastructure to work with Google APIs, in general. We've just [blogged about gargle's initial release](https://www.tidyverse.org/articles/2019/08/gargle-hello-world/), so check out that post for more details.

We're adopting gargle for auth in several other packages, such as [bigrquery](https://bigrquery.r-dbi.org) (>= v1.2.0), [gmailr](https://gmailr.r-lib.org)  (>= v1.0.0 *coming soon to CRAN*), and [googlesheets4](https://googlesheets4.tidyverse.org) (currently GitHub-only, successor of googlesheets). This makes new token flows available in these packages, such as [Application Default Credentials](https://www.jhanley.com/google-cloud-application-default-credentials/), and makes auth less idiosyncratic.

### Auth changes the typical user will notice

If you've always let googledrive guide you through auth, here is the one change you will notice:

> OAuth2 tokens are now cached at the user level, by default, instead of in `.httr-oauth` in the current project. We will ask if it's OK to create a new folder to hold your OAuth tokens. We recommend that you delete any vestigial `.httr-oauth` files lying around your googledrive projects and re-authorize googledrive, i.e. get a new token, stored in the new way.

The new strategy makes it harder to accidentally push your tokens to the cloud, easier to use multiple Google identities, and easier to share tokens across projects and packages.

Overall, googledrive has gotten more careful about getting your permission to use a cached token. See the gargle vignette [Non-interactive auth](https://gargle.r-lib.org/articles/non-interactive-auth.html) to learn how to prevent attempts to interact with you, especially the section ["I just want my `.Rmd` to render"](https://gargle.r-lib.org/articles/non-interactive-auth.html#i-just-want-my--rmd-to-render).

googledrive also uses a new OAuth "app", owned by a verified Google Cloud Project entitled "Tidyverse API Packages", which is the project name you will see on the OAuth consent screen. See our new [Privacy Policy](https://www.tidyverse.org/google_privacy_policy/) for details.

For more advanced users who call `drive_auth()` directly or who configure auth settings, such as their own OAuth app or API key, see the [changelog](https://googledrive.tidyverse.org/news/index.html#googledrive-1-0-0) for more details.

## Preventing name clashes

Google Drive doesn't impose a 1-to-1 relationship between files and filepaths, the way your local file system does. Therefore, when working via the Drive API (instead of in the browser), it's fairly easy to create multiple Drive files with the same name or filepath, without actually meaning to. This is perfectly valid on Drive, which identifies file by ID, but can be confusing and undesirable for humans. Very few people actually want this:

<img src="/images/googledrive/je-suis-unique.png" width="60%" />

googledrive v1.0.0 offers some new ways to prevent writing more than one file to the same filepath.

All functions that create a new item or rename/move an existing item have gained an `overwrite` argument:

  - `drive_create()` *this function is new in v1.0.0*
  - `drive_cp()`
  - `drive_mkdir()`
  - `drive_mv()`
  - `drive_rename()`
  - `drive_upload()`

The default of `overwrite = NA` corresponds to the existing behaviour, which does not consider pre-existing files at all. `overwrite = TRUE` requests to move a pre-existing file at the target filepath to the trash, prior to creating the new item. If 2 or more files are found, an error is thrown, because it's not clear which one(s) to trash. `overwrite = FALSE` means the new item will only be created if there is no pre-existing file at that filepath. Existence checks based on filepath (or name) can be expensive. This is why the default is `overwrite = NA`, in addition to backwards compatibility.

`drive_put()` is a new convenience wrapper that figures out whether to call `drive_upload()` or `drive_update()`.

Sometimes you have a file you will repeatedly send to Drive, i.e. the first time you run an analysis, you create the file and, when you re-run it, you update the file. Previously this was hard to express with googledrive.

`drive_put()` is useful here and refers to the HTTP verb `PUT`: create the thing if it doesn't exist or, if it does, replace its contents. A good explanation of `PUT` is [RESTful API Design — PUT vs PATCH](https://medium.com/backticks-tildes/restful-api-design-put-vs-patch-4a061aa3ed0b).

In pseudo-code, here's the basic idea of `drive_put()`:

``` r
target_filepath <- <determined from arguments `path`, `name`, and `media`>
hits <- <get all Drive files at target_filepath>
if (no hits) {
 drive_upload(media, path, name, type, ..., verbose)
} else if (exactly 1 hit) {
 drive_update(hit, media, ..., verbose)
} else {
 ERROR
}
```

## Shared workflows 

The shared use of gargle allows us to create centralized articles for several workflows that can be tricky for useRs:

  * [Non-interactive auth](https://gargle.r-lib.org/articles/non-interactive-auth.html)
  * [Auth when using R in the browser](https://gargle.r-lib.org/articles/auth-from-web.html)
  * [Managing tokens securely](https://gargle.r-lib.org/articles/articles/managing-tokens-securely.html)
  * [How to get your own API credentials](https://gargle.r-lib.org/articles/get-api-credentials.html)
  
## Thanks!

Thank you to the **41** people who contributed issues, code, and comments to this release:

[&#x0040;abeburnett](https://github.com/abeburnett), [&#x0040;admahood](https://github.com/admahood), [&#x0040;alexpghayes](https://github.com/alexpghayes), [&#x0040;arendsee](https://github.com/arendsee), [&#x0040;batpigandme](https://github.com/batpigandme), [&#x0040;benmarwick](https://github.com/benmarwick), [&#x0040;Chanajit](https://github.com/Chanajit), [&#x0040;cowlumbus](https://github.com/cowlumbus), [&#x0040;ctlamb](https://github.com/ctlamb), [&#x0040;DavidGarciaEstaun](https://github.com/DavidGarciaEstaun), [&#x0040;dgplaco](https://github.com/dgplaco), [&#x0040;Diego-MX](https://github.com/Diego-MX), [&#x0040;dsdaveh](https://github.com/dsdaveh), [&#x0040;eeenilsson](https://github.com/eeenilsson), [&#x0040;efh0888](https://github.com/efh0888), [&#x0040;giocomai](https://github.com/giocomai), [&#x0040;grabear](https://github.com/grabear), [&#x0040;hwsamuel](https://github.com/hwsamuel), [&#x0040;ianmcook](https://github.com/ianmcook), [&#x0040;jarodmeng](https://github.com/jarodmeng), [&#x0040;jennybc](https://github.com/jennybc), [&#x0040;jimhester](https://github.com/jimhester), [&#x0040;lohancock](https://github.com/lohancock), [&#x0040;lotard](https://github.com/lotard), [&#x0040;LucyMcGowan](https://github.com/LucyMcGowan), [&#x0040;lukaskawerau](https://github.com/lukaskawerau), [&#x0040;MariaMetriplica](https://github.com/MariaMetriplica), [&#x0040;Martin-Jung](https://github.com/Martin-Jung), [&#x0040;medewitt](https://github.com/medewitt), [&#x0040;njudd](https://github.com/njudd), [&#x0040;philmikejones](https://github.com/philmikejones), [&#x0040;prokulski](https://github.com/prokulski), [&#x0040;RNA-Ninja](https://github.com/RNA-Ninja), [&#x0040;romunov](https://github.com/romunov), [&#x0040;sanjmeh](https://github.com/sanjmeh), [&#x0040;Serenthia](https://github.com/Serenthia), [&#x0040;shawzhifei](https://github.com/shawzhifei), [&#x0040;stapial](https://github.com/stapial), [&#x0040;svenhalvorson](https://github.com/svenhalvorson), [&#x0040;tarunparmar](https://github.com/tarunparmar), and [&#x0040;tsmith64](https://github.com/tsmith64)
