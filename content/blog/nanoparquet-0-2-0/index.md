---
output: hugodown::hugo_document

slug: nanoparquet-0-2-0
title: nanoparquet 0 2 0
date: 2024-05-30
author: Gábor Csárdi
description: >
    A 2-3 sentence description of the post that appears on the articles page.
    This can be omitted if it would just recapitulate the title.

photo:
  url: https://www.pexels.com/photo/clock-between-columns-20134435/
  author: Marina Zvada

# one of: "deep-dive", "learn", "package", "programming", "roundup", or "other"
categories: [package] 
tags: []
rmd_hash: f4fc5a820a07b0d3

---

<!--
TODO:
* [ ] Look over / edit the post's title in the yaml
* [ ] Edit (or delete) the description; note this appears in the Twitter card
* [ ] Pick category and tags (see existing with [`hugodown::tidy_show_meta()`](https://rdrr.io/pkg/hugodown/man/use_tidy_post.html))
* [ ] Find photo & update yaml metadata
* [ ] Create `thumbnail-sq.jpg`; height and width should be equal
* [ ] Create `thumbnail-wd.jpg`; width should be >5x height
* [ ] [`hugodown::use_tidy_thumbnails()`](https://rdrr.io/pkg/hugodown/man/use_tidy_post.html)
* [ ] Add intro sentence, e.g. the standard tagline for the package
* [ ] [`usethis::use_tidy_thanks()`](https://usethis.r-lib.org/reference/use_tidy_thanks.html)
-->

We're extremely pleased to announce the release of [nanoparquet](https://r-lib.github.io/nanoparquet/) 0.2.0. nanoparquet is ...

You can install it from CRAN with:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://rdrr.io/r/utils/install.packages.html'>install.packages</a></span><span class='o'>(</span><span class='s'>"nanoparquet"</span><span class='o'>)</span></span></code></pre>

</div>

This blog post will ...

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://github.com/r-lib/nanoparquet'>nanoparquet</a></span><span class='o'>)</span></span></code></pre>

</div>

## What is Parquet?

<!--
- [ ] columnar
- [ ] binary
- [ ] rich types
- [ ] well supported
- [ ] performant
-->

## Why we created nanoparquet?

<!--
- [ ] encourage Parquet use for smaller data sets
- [ ] problems with other formats
-->

## Features

<!--
- [ ] lightweight
- [ ] common subset
- [ ] read and write
- [ ] support R's types well
- [ ] type maps
-->

## Limitations

<!--
- [ ] no nesting
- [ ] some types are not supported
- [ ] only Snappy compression
- [ ] no encryption
- [ ] slow-ish for large data sets
-->

Will fix soon: <!--
- [ ] single row group
- [ ] no statistics, no checksum
- [ ] PLAIN encoding results larger files
-->

## Other tools for Parquet files

### In R

#### Apache Arrow

#### DuckDB

#### Othere (?): Spark? Impala?

### In Python

#### Apache Arrow

#### DuckDB + pandas

#### fastparquet

## Acknowledgements

<!--
- [ ] Hannes & DuckDB
- [ ] Arrow
- [ ] Google
-->

