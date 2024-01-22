---
output: hugodown::hugo_document

slug: bigrquery-1-5-0
title: bigrquery 1.5.0
date: 2024-01-22
author: Hadley Wickham
description: >
    This release fixes a bunch of annoyances and catches up with 
    innovations in DBI and dbplyr.

photo:
  url: https://unsplash.com/photos/gr06IVY2YpM
  author: Aaron Santelices

# one of: "deep-dive", "learn", "package", "programming", "roundup", or "other"
categories: [package] 
tags: [bigrquery]
rmd_hash: 7f632572446a9f4a

---

<!--
TODO:
* [x] Look over / edit the post's title in the yaml
* [x] Edit (or delete) the description; note this appears in the Twitter card
* [x] Pick category and tags (see existing with [`hugodown::tidy_show_meta()`](https://rdrr.io/pkg/hugodown/man/use_tidy_post.html))
* [x] Find photo & update yaml metadata
* [x] Create `thumbnail-sq.jpg`; height and width should be equal
* [x] Create `thumbnail-wd.jpg`; width should be >5x height
* [x] [`hugodown::use_tidy_thumbnails()`](https://rdrr.io/pkg/hugodown/man/use_tidy_post.html)
* [x] Add intro sentence, e.g. the standard tagline for the package
* [x] [`usethis::use_tidy_thanks()`](https://usethis.r-lib.org/reference/use_tidy_thanks.html)
-->

We're stoked to announce the release of [bigrquery](http://bigrquery.r-dbi.org/) 1.4.2. bigrquery makes it easy to work with data stored in [Google BigQuery](https://developers.google.com/bigquery/), a hosted database for big data.

You can install it from CRAN with:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://rdrr.io/r/utils/install.packages.html'>install.packages</a></span><span class='o'>(</span><span class='s'>"bigquery"</span><span class='o'>)</span></span></code></pre>

</div>

This has been the first major update to bigrquery for a while, and is mostly about catching up with innovations elsewhere as well as squashing a bunch of smaller annoyances.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://bigrquery.r-dbi.org'>bigrquery</a></span><span class='o'>)</span></span></code></pre>

</div>

Here's a summary of the biggest changes:

-   bigrquery is now [MIT licensed](https://www.tidyverse.org/blog/2021/12/relicensing-packages/).

-   Deprecated functions (i.e. those not starting with `bq_`) have been removed. These have been superseded for a long time and were formally deprecated in bigrquery 1.3.0 (2020).

-   [`bq_table_download()`](https://bigrquery.r-dbi.org/reference/bq_table_download.html) now returns unknown fields as character vectors. In particular, this means that `BIGNUMERIC` and `JSON` columns are downloaded into R for you to process as you wish. [`bq_table_download()`](https://bigrquery.r-dbi.org/reference/bq_table_download.html) now uses the [clock package](https://clock.r-lib.org) to parse dates, leading to a considerable performance improvement and correct parsing for dates prior to 1970-01-01.

-   bigquery datasets and tables will now appear in the [RStudio connections pane](https://docs.posit.co/ide/user/ide/guide/data/data-connections.html) when connecting with [`DBI::dbConnect()`](https://dbi.r-dbi.org/reference/dbConnect.html).

-   `DBI::dbAppendTable(),` [`DBI::dbCreateTable()`](https://dbi.r-dbi.org/reference/dbCreateTable.html), and [`DBI::dbExecute()`](https://dbi.r-dbi.org/reference/dbExecute.html) are now supported, and [`DBI::dbGetQuery()`](https://dbi.r-dbi.org/reference/dbGetQuery.html)/[`DBI::dbSendQuery()`](https://dbi.r-dbi.org/reference/dbSendQuery.html) support parameterised queries via the `params` argument. [`DBI::dbReadTable()`](https://dbi.r-dbi.org/reference/dbReadTable.html), [`DBI::dbWriteTable()`](https://dbi.r-dbi.org/reference/dbWriteTable.html), [`DBI::dbExistsTable()`](https://dbi.r-dbi.org/reference/dbExistsTable.html), [`DBI::dbRemoveTable()`](https://dbi.r-dbi.org/reference/dbRemoveTable.html), and [`DBI::dbListFields()`](https://dbi.r-dbi.org/reference/dbListFields.html) now all work with [`DBI::Id()`](https://dbi.r-dbi.org/reference/Id.html).

-   bigrquery now uses 2nd edition of dbplyr interface and is compatible with dbplyr 2.4.0.

See the [release notes](https://github.com/r-dbi/bigrquery/releases/tag/v1.5.0) for a full list of changes.

## Acknowledgements

A big thanks to all 14 folks who helped make this release happen with questions, comments, and code: [@abalter](https://github.com/abalter), [@ablack3](https://github.com/ablack3), [@evanrollinsdrumline](https://github.com/evanrollinsdrumline), [@hadley](https://github.com/hadley), [@husseyd](https://github.com/husseyd), [@jacobmpeters](https://github.com/jacobmpeters), [@jennybc](https://github.com/jennybc), [@Kvit](https://github.com/Kvit), [@meztez](https://github.com/meztez), [@mgirlich](https://github.com/mgirlich), [@MichaelChirico](https://github.com/MichaelChirico), [@mjbroerman](https://github.com/mjbroerman), [@ncuriale](https://github.com/ncuriale), and [@rdavis120](https://github.com/rdavis120).

