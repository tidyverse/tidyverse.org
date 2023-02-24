---
output: hugodown::hugo_document

slug: dtplyr-1-3-0
title: dtplyr 1.3.0
date: 2023-02-21
author: Hadley Wickham
description: >
    dtplyr brings initial support for dplyr 1.1.0 features, new translations, 
    and a breaking change.

photo:
  url: https://unsplash.com/photos/uwI8R_FyLrI
  author: Neil Cooper

# one of: "deep-dive", "learn", "package", "programming", "roundup", or "other"
categories: [package] 
tags: [dplyr, dtplyr]
rmd_hash: 53da4f088eb5df37

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

We're thrilled to announce the release of [dtplyr](https://dtplyr.tidyverse.org) 1.3.0. dtplyr gives you the speed of [data.table](http://r-datatable.com/) with the syntax of dplyr; you write dplyr (and tidyr) code and dtplyr translates it to the data.table equivalent.

You can install it from CRAN with:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://rdrr.io/r/utils/install.packages.html'>install.packages</a></span><span class='o'>(</span><span class='s'>"dtplyr"</span><span class='o'>)</span></span></code></pre>

</div>

This blog post will give you an overview of the changes in this version: dtplyr no longer adds translations directly to data.tables, some dplyr 1.1.0 updates, and some performance improvements. As always, you can see a full list of changes in the [release notes](https://github.com/tidyverse/dtplyr/releases/tag/v1.3.0)

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://dtplyr.tidyverse.org'>dtplyr</a></span><span class='o'>)</span></span>
<span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://dplyr.tidyverse.org'>dplyr</a></span>, warn.conflicts <span class='o'>=</span> <span class='kc'>FALSE</span><span class='o'>)</span></span></code></pre>

</div>

## Breaking changes

In previous versions, dtplyr registered translations that kicked in whenever you used a data.table. This [caused problems](https://github.com/tidyverse/dtplyr/issues/312) because merely loading dtplyr could cause otherwise ok code to fail because dplyr and tidyr functions would now return `lazy_dt` objects instead of `data.table` objects. To avoid this problem, we have removed those S3 methods and now must explicitly opt-in to dtplyr translations by using [`lazy_dt()`](https://dtplyr.tidyverse.org/reference/lazy_dt.html).

## dplyr 1.1.0

This release brings support for dplyr 1.1.0's [per-operation grouping](https://www.tidyverse.org/blog/2023/02/dplyr-1-1-0-per-operation-grouping/) and [`pick()`](https://dplyr.tidyverse.org/reference/pick.html):

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>dt</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://dtplyr.tidyverse.org/reference/lazy_dt.html'>lazy_dt</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/data.frame.html'>data.frame</a></span><span class='o'>(</span>x <span class='o'>=</span> <span class='m'>1</span><span class='o'>:</span><span class='m'>10</span>, id <span class='o'>=</span> <span class='m'>1</span><span class='o'>:</span><span class='m'>2</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='nv'>dt</span> <span class='o'>|&gt;</span> </span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/summarise.html'>summarise</a></span><span class='o'>(</span>mean <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/mean.html'>mean</a></span><span class='o'>(</span><span class='nv'>x</span><span class='o'>)</span>, .by <span class='o'>=</span> <span class='nv'>id</span><span class='o'>)</span> <span class='o'>|&gt;</span> </span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/explain.html'>show_query</a></span><span class='o'>(</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; `_DT1`[, .(mean = mean(x)), keyby = .(id)]</span></span>
<span></span><span></span>
<span><span class='nv'>dt</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://dtplyr.tidyverse.org/reference/lazy_dt.html'>lazy_dt</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/data.frame.html'>data.frame</a></span><span class='o'>(</span>x <span class='o'>=</span> <span class='m'>1</span><span class='o'>:</span><span class='m'>10</span>, y <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/stats/Uniform.html'>runif</a></span><span class='o'>(</span><span class='m'>10</span><span class='o'>)</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='nv'>dt</span> <span class='o'>|&gt;</span> </span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/mutate.html'>mutate</a></span><span class='o'>(</span>row_sum <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/colSums.html'>rowSums</a></span><span class='o'>(</span><span class='nf'><a href='https://dplyr.tidyverse.org/reference/pick.html'>pick</a></span><span class='o'>(</span><span class='nv'>x</span><span class='o'>)</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>|&gt;</span> </span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/explain.html'>show_query</a></span><span class='o'>(</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; copy(`_DT2`)[, `:=`(row_sum = rowSums(data.table(x = x)))]</span></span>
<span></span></code></pre>

</div>

Per-operation grouping was one of the dplyr 1.1.0 features inspired by data.table, so it's neat to see it come full circle in this dtplyr release. Future releases will add support for other dplyr 1.1.0 features like the new [`join_by()`](https://www.tidyverse.org/blog/2023/01/dplyr-1-1-0-joins/#join_by) syntax and [`reframe()`](https://www.tidyverse.org/blog/2023/02/dplyr-1-1-0-pick-reframe-arrange/#reframe).

## Improved translations

dtplyr gains new translations for [`add_count()`](https://dplyr.tidyverse.org/reference/count.html) and `unite()`, and the ranking functions, [`min_rank()`](https://dplyr.tidyverse.org/reference/row_number.html), [`dense_rank()`](https://dplyr.tidyverse.org/reference/row_number.html), [`percent_rank()`](https://dplyr.tidyverse.org/reference/percent_rank.html), & [`cume_dist()`](https://dplyr.tidyverse.org/reference/percent_rank.html) are now mapped to their `data.table` equivalents:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>dt</span> <span class='o'>|&gt;</span> <span class='nf'><a href='https://dplyr.tidyverse.org/reference/count.html'>add_count</a></span><span class='o'>(</span><span class='o'>)</span> <span class='o'>|&gt;</span> <span class='nf'><a href='https://dplyr.tidyverse.org/reference/explain.html'>show_query</a></span><span class='o'>(</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; copy(`_DT2`)[, `:=`(n = .N)]</span></span>
<span></span><span></span>
<span><span class='nv'>dt</span> <span class='o'>|&gt;</span> <span class='nf'>tidyr</span><span class='nf'>::</span><span class='nf'><a href='https://tidyr.tidyverse.org/reference/unite.html'>unite</a></span><span class='o'>(</span><span class='s'>"z"</span>, <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='nv'>x</span>, <span class='nv'>y</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>|&gt;</span> <span class='nf'><a href='https://dplyr.tidyverse.org/reference/explain.html'>show_query</a></span><span class='o'>(</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; copy(`_DT2`)[, `:=`(z = paste(x, y, sep = "_"))][, `:=`(c("x", </span></span>
<span><span class='c'>#&gt; "y"), NULL)]</span></span>
<span></span><span></span>
<span><span class='nv'>dt</span> <span class='o'>|&gt;</span> <span class='nf'><a href='https://dplyr.tidyverse.org/reference/mutate.html'>mutate</a></span><span class='o'>(</span>r <span class='o'>=</span> <span class='nf'><a href='https://dplyr.tidyverse.org/reference/row_number.html'>min_rank</a></span><span class='o'>(</span><span class='nv'>x</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>|&gt;</span> <span class='nf'><a href='https://dplyr.tidyverse.org/reference/explain.html'>show_query</a></span><span class='o'>(</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; copy(`_DT2`)[, `:=`(r = frank(x, ties.method = "min", na.last = "keep"))]</span></span>
<span></span><span></span>
<span><span class='nv'>dt</span> <span class='o'>|&gt;</span> <span class='nf'><a href='https://dplyr.tidyverse.org/reference/mutate.html'>mutate</a></span><span class='o'>(</span>r <span class='o'>=</span> <span class='nf'><a href='https://dplyr.tidyverse.org/reference/row_number.html'>dense_rank</a></span><span class='o'>(</span><span class='nv'>x</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>|&gt;</span> <span class='nf'><a href='https://dplyr.tidyverse.org/reference/explain.html'>show_query</a></span><span class='o'>(</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; copy(`_DT2`)[, `:=`(r = frank(x, ties.method = "dense", na.last = "keep"))]</span></span>
<span></span></code></pre>

</div>

This release also includes three translation improvements that yield better performance. When data has previously been copied [`arrange()`](https://dplyr.tidyverse.org/reference/arrange.html) will use `setorder()` instead of [`order()`](https://rdrr.io/r/base/order.html) and [`select()`](https://dplyr.tidyverse.org/reference/select.html) will drop unwanted columns by reference (i.e. with `var := NULL`). And [`slice()`](https://dplyr.tidyverse.org/reference/slice.html) now uses an intermediate variable to reduce computation time of row selection.

## Acknowledgements

A massive thanks to [Mark Fairbanks](https://github.com/markfairbanks) who did most of the work for this release, ably aided by the other dtplyr maintainers [@eutwt](https://github.com/eutwt) and [Maximilian Girlich](https://github.com/mgirlich). And thanks to everyone else who helped make this release possible, whether it was with code, documentation, or insightful comments: [@abalter](https://github.com/abalter), [@akaviaLab](https://github.com/akaviaLab), [@camnesia](https://github.com/camnesia), [@caparks2](https://github.com/caparks2), [@DavisVaughan](https://github.com/DavisVaughan), [@eipi10](https://github.com/eipi10), [@hadley](https://github.com/hadley), [@jmbarbone](https://github.com/jmbarbone), [@johnF-moore](https://github.com/johnF-moore), [@lschneiderbauer](https://github.com/lschneiderbauer), and [@NicChr](https://github.com/NicChr).

