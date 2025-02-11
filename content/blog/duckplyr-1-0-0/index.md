---
output: hugodown::hugo_document

slug: duckplyr-1-0-0
title: duckplyr fully joins the tidyverse!
date: 2025-02-11
author: Kirill Müller and Maëlle Salmon
description: >
    duckplyr 1.0.0 is on CRAN and part of the tidyverse! duckplyr is a drop-in
    replacement for dplyr, powered by DuckDB for speed.

photo:
  url: https://www.pexels.com/photo/a-mallard-duck-on-water-6918877/
  author: Kiril Gruev

# one of: "deep-dive", "learn", "package", "programming", "roundup", or "other"
categories: [package] 
tags:
  - duckplyr
  - dplyr
  - tidyverse
rmd_hash: f3be88797aeb81a3

---

<!--
TODO:
* [x] Look over / edit the post's title in the yaml
* [x] Edit (or delete) the description; note this appears in the Twitter card
* [x] Pick category and tags (see existing with [`hugodown::tidy_show_meta()`](https://rdrr.io/pkg/hugodown/man/use_tidy_post.html))
* [x] Find photo & update yaml metadata
* [ ] Create `thumbnail-sq.jpg`; height and width should be equal
* [ ] Create `thumbnail-wd.jpg`; width should be >5x height
* [ ] [`hugodown::use_tidy_thumbnails()`](https://rdrr.io/pkg/hugodown/man/use_tidy_post.html)
* [x] Add intro sentence, e.g. the standard tagline for the package
* [x] [`usethis::use_tidy_thanks()`](https://usethis.r-lib.org/reference/use_tidy_thanks.html)
-->

We're very chuffed to announce the release of [duckplyr](https://duckplyr.tidyverse.org) 1.0.0. duckplyr is a drop-in replacement for dplyr, powered by [DuckDB](https://duckdb.org/) for speed. It joins the rank of dplyr backends together with [dtplyr](https://dtplyr.tidyverse.org) and [dbplyr](https://dbplyr.tidyverse.org).

You can install it from CRAN with:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://rdrr.io/r/utils/install.packages.html'>install.packages</a></span><span class='o'>(</span><span class='s'>"duckplyr"</span><span class='o'>)</span></span></code></pre>

</div>

In this article, we'll introduce you to the basic concepts behind duckplyr, show how it can help you handle normal sized but also large data, and explain how you can help improve the package.

## A drop-in replacement for dplyr

The duckplyr package is a *drop-in replacement for dplyr* that uses *DuckDB for speed*. You can simply *drop* duckplyr into your pipeline by loading it, then computations will be efficiently carried out by DuckDB.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://conflicted.r-lib.org/'>conflicted</a></span><span class='o'>)</span></span>
<span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://duckplyr.tidyverse.org'>duckplyr</a></span><span class='o'>)</span></span>
<span><span class='c'>#&gt; Loading required package: dplyr</span></span>
<span></span><span><span class='c'>#&gt; </span></span>
<span><span class='c'>#&gt; Attaching package: 'dplyr'</span></span>
<span></span><span><span class='c'>#&gt; The following objects are masked from 'package:stats':</span></span>
<span><span class='c'>#&gt; </span></span>
<span><span class='c'>#&gt;     filter, lag</span></span>
<span></span><span><span class='c'>#&gt; The following objects are masked from 'package:base':</span></span>
<span><span class='c'>#&gt; </span></span>
<span><span class='c'>#&gt;     intersect, setdiff, setequal, union</span></span>
<span></span><span><span class='c'>#&gt; <span style='color: #00BB00;'>✔</span> Overwriting <span style='color: #0000BB;'>dplyr</span> methods with <span style='color: #0000BB;'>duckplyr</span> methods.</span></span>
<span><span class='c'>#&gt; <span style='color: #00BBBB;'>ℹ</span> Turn off with `duckplyr::methods_restore()`.</span></span>
<span></span><span><span class='nf'><a href='https://conflicted.r-lib.org/reference/conflict_prefer.html'>conflict_prefer</a></span><span class='o'>(</span><span class='s'>"filter"</span>, <span class='s'>"dplyr"</span>, quiet <span class='o'>=</span> <span class='kc'>TRUE</span><span class='o'>)</span></span>
<span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='s'><a href='https://github.com/hadley/babynames'>"babynames"</a></span><span class='o'>)</span></span>
<span></span>
<span></span>
<span><span class='nv'>out</span> <span class='o'>&lt;-</span> <span class='nv'>babynames</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/filter.html'>filter</a></span><span class='o'>(</span><span class='nv'>n</span> <span class='o'>&gt;</span> <span class='m'>1000</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/summarise.html'>summarize</a></span><span class='o'>(</span></span>
<span>    .by <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='nv'>sex</span>, <span class='nv'>year</span><span class='o'>)</span>,</span>
<span>    babies_n <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/sum.html'>sum</a></span><span class='o'>(</span><span class='nv'>n</span><span class='o'>)</span></span>
<span>  <span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/filter.html'>filter</a></span><span class='o'>(</span><span class='nv'>sex</span> <span class='o'>==</span> <span class='s'>"F"</span><span class='o'>)</span></span>
<span><span class='nf'><a href='https://rdrr.io/r/base/class.html'>class</a></span><span class='o'>(</span><span class='nv'>out</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; [1] "tbl_df"     "tbl"        "data.frame"</span></span>
<span></span></code></pre>

</div>

The very tagline of duckplyr, being a drop-in replacement for dplyr that uses DuckDB for speed, creates a tension:

-   When using dplyr, we are not used to explicitly collect results, we simply access them: the data.frames are "eager" by default. Adding a [`collect()`](https://dplyr.tidyverse.org/reference/compute.html) step by default would confuse users and make "drop-in replacement" an exaggeration. The collection of results, called materialization, has to be automatic by default. Therefore, *duckplyr needs eagerness*!

-   The whole advantage of using DuckDB under the hood is letting DuckDB optimize computations, like dtplyr does with data.table. *Therefore, duckplyr needs laziness*!

As a consequence, duckplyr is lazy on the inside for all DuckDB operations but eager on the outside, thanks to [ALTREP](https://duckdb.org/2024/04/02/duckplyr.html#eager-vs-lazy-materialization), a powerful R feature that among other things supports *deferred evaluation*.

> "ALTREP allows R objects to have different in-memory representations, and for custom code to be executed whenever those objects are accessed." Hannes Mühleisen.

If the duckplyr data.frame is accessed by...

-   duckplyr, then the operations continue to be lazy (until a call to `collect.duckplyr_df()` for instance).
-   not duckplyr (say, ggplot2, or [`nrow()`](https://rdrr.io/r/base/nrow.html)), then a special callback is executed, allowing materialization of the data frame.

Therefore, duckplyr can be both *lazy* (within itself) and *not lazy* (for the outside world).

Now, the default automatic materialization can be problematic if dealing with large data: what if the materialization eats up all memory? Therefore, the duckplyr package has a safeguard called `prudence` with three levels.

-   `"lavish"`: automatically materialize *regardless of size*,

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>out</span> <span class='o'>&lt;-</span> <span class='nv'>babynames</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://duckplyr.tidyverse.org/reference/duckdb_tibble.html'>duckdb_tibble</a></span><span class='o'>(</span>prudence <span class='o'>=</span> <span class='s'>"lavish"</span><span class='o'>)</span> <span class='o'>|&gt;</span> <span class='c'># default value of prudence :-)</span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/filter.html'>filter</a></span><span class='o'>(</span><span class='nv'>n</span> <span class='o'>&gt;</span> <span class='m'>1000</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/summarise.html'>summarize</a></span><span class='o'>(</span></span>
<span>    .by <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='nv'>sex</span>, <span class='nv'>year</span><span class='o'>)</span>,</span>
<span>    babies_n <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/sum.html'>sum</a></span><span class='o'>(</span><span class='nv'>n</span><span class='o'>)</span></span>
<span>  <span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/filter.html'>filter</a></span><span class='o'>(</span><span class='nv'>sex</span> <span class='o'>==</span> <span class='s'>"F"</span><span class='o'>)</span></span>
<span></span>
<span><span class='nf'><a href='https://rdrr.io/r/base/class.html'>class</a></span><span class='o'>(</span><span class='nv'>out</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; [1] "duckplyr_df" "tbl_df"      "tbl"         "data.frame"</span></span>
<span></span><span><span class='nf'><a href='https://rdrr.io/r/base/nrow.html'>nrow</a></span><span class='o'>(</span><span class='nv'>out</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; [1] 138</span></span>
<span></span></code></pre>

</div>

-   `"stingy"`: *never* automatically materialize,

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>stingy</span> <span class='o'>&lt;-</span> <span class='nv'>babynames</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://duckplyr.tidyverse.org/reference/duckdb_tibble.html'>duckdb_tibble</a></span><span class='o'>(</span>prudence <span class='o'>=</span> <span class='s'>"stingy"</span><span class='o'>)</span> <span class='o'>|&gt;</span> <span class='c'># like the famous duck Uncle Scrooge :-)</span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/filter.html'>filter</a></span><span class='o'>(</span><span class='nv'>n</span> <span class='o'>&gt;</span> <span class='m'>1500</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/summarise.html'>summarize</a></span><span class='o'>(</span></span>
<span>    .by <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='nv'>sex</span>, <span class='nv'>year</span><span class='o'>)</span>,</span>
<span>    babies_n <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/sum.html'>sum</a></span><span class='o'>(</span><span class='nv'>n</span><span class='o'>)</span></span>
<span>  <span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/filter.html'>filter</a></span><span class='o'>(</span><span class='nv'>sex</span> <span class='o'>==</span> <span class='s'>"F"</span><span class='o'>)</span></span>
<span></span>
<span><span class='nf'><a href='https://rdrr.io/r/base/class.html'>class</a></span><span class='o'>(</span><span class='nv'>stingy</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; [1] "duckplyr_df" "tbl_df"      "tbl"         "data.frame"</span></span>
<span></span><span><span class='nf'><a href='https://rdrr.io/r/base/nrow.html'>nrow</a></span><span class='o'>(</span><span class='nv'>stingy</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; [1] 138</span></span>
<span></span></code></pre>

</div>

-   `"thrifty"`: automatically materialize *up to a maximum size of 1 million cells*.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>thrifty</span> <span class='o'>&lt;-</span> <span class='nv'>babynames</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://duckplyr.tidyverse.org/reference/duckdb_tibble.html'>duckdb_tibble</a></span><span class='o'>(</span>prudence <span class='o'>=</span> <span class='s'>"stingy"</span><span class='o'>)</span> <span class='o'>|&gt;</span> </span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/filter.html'>filter</a></span><span class='o'>(</span><span class='nv'>n</span> <span class='o'>&gt;</span> <span class='m'>1000</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/summarise.html'>summarize</a></span><span class='o'>(</span></span>
<span>    .by <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='nv'>sex</span>, <span class='nv'>year</span><span class='o'>)</span>,</span>
<span>    babies_n <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/sum.html'>sum</a></span><span class='o'>(</span><span class='nv'>n</span><span class='o'>)</span></span>
<span>  <span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/filter.html'>filter</a></span><span class='o'>(</span><span class='nv'>sex</span> <span class='o'>==</span> <span class='s'>"F"</span><span class='o'>)</span></span>
<span></span>
<span><span class='nf'><a href='https://rdrr.io/r/base/class.html'>class</a></span><span class='o'>(</span><span class='nv'>thrifty</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; [1] "duckplyr_df" "tbl_df"      "tbl"         "data.frame"</span></span>
<span></span><span><span class='nf'><a href='https://rdrr.io/r/base/nrow.html'>nrow</a></span><span class='o'>(</span><span class='nv'>thrifty</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; [1] 138</span></span>
<span></span></code></pre>

</div>

By default, duckplyr data frames are *lavish*, but duckplyr data frames created from Parquet data (presumedly large) are *thrifty*.

## How to use duckplyr

To *replace* dplyr with duckplyr, you can either

-   load duckplyr and then keep your pipeline as is. Calling [`library(duckplyr)`](https://duckplyr.tidyverse.org) overwrites dplyr methods, enabling duckplyr for the entire session no matter how data.frames are created.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://conflicted.r-lib.org/'>conflicted</a></span><span class='o'>)</span></span>
<span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://duckplyr.tidyverse.org'>duckplyr</a></span><span class='o'>)</span></span>
<span><span class='nf'><a href='https://conflicted.r-lib.org/reference/conflict_prefer.html'>conflict_prefer</a></span><span class='o'>(</span><span class='s'>"filter"</span>, <span class='s'>"dplyr"</span>, quiet <span class='o'>=</span> <span class='kc'>TRUE</span><span class='o'>)</span></span></code></pre>

</div>

-   Create individual "duck frames" which allows you to control their automatic materialization parameters. To do so, you can use *conversion functions* like [`duckdb_tibble()`](https://duckplyr.tidyverse.org/reference/duckdb_tibble.html) or [`as_duckdb_tibble()`](https://duckplyr.tidyverse.org/reference/duckdb_tibble.html), or *ingestion functions* like [`read_csv_duckdb()`](https://duckplyr.tidyverse.org/reference/read_file_duckdb.html).

Then, the data manipulation pipeline uses the exact same syntax as a dplyr pipeline. The duckplyr package performs the computation using DuckDB.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='s'><a href='https://github.com/hadley/babynames'>"babynames"</a></span><span class='o'>)</span></span>
<span><span class='nv'>out</span> <span class='o'>&lt;-</span> <span class='nv'>babynames</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/filter.html'>filter</a></span><span class='o'>(</span><span class='nv'>n</span> <span class='o'>&gt;</span> <span class='m'>1000</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/summarise.html'>summarize</a></span><span class='o'>(</span></span>
<span>    .by <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='nv'>sex</span>, <span class='nv'>year</span><span class='o'>)</span>,</span>
<span>    babies_n <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/sum.html'>sum</a></span><span class='o'>(</span><span class='nv'>n</span><span class='o'>)</span></span>
<span>  <span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/filter.html'>filter</a></span><span class='o'>(</span><span class='nv'>sex</span> <span class='o'>==</span> <span class='s'>"F"</span><span class='o'>)</span></span></code></pre>

</div>

The result can finally be materialized to memory, or computed temporarily, or computed to a file.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='c'># to memory</span></span>
<span><span class='nv'>out</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 138 × 3</span></span></span>
<span><span class='c'>#&gt;    sex    year babies_n</span></span>
<span><span class='c'>#&gt;    <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>    <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 1</span> F      <span style='text-decoration: underline;'>1</span>992  1<span style='text-decoration: underline;'>226</span>792</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 2</span> F      <span style='text-decoration: underline;'>1</span>997  1<span style='text-decoration: underline;'>112</span>135</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 3</span> F      <span style='text-decoration: underline;'>2</span>002  1<span style='text-decoration: underline;'>089</span>406</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 4</span> F      <span style='text-decoration: underline;'>2</span>005  1<span style='text-decoration: underline;'>083</span>492</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 5</span> F      <span style='text-decoration: underline;'>2</span>012   <span style='text-decoration: underline;'>961</span>393</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 6</span> F      <span style='text-decoration: underline;'>1</span>902   <span style='text-decoration: underline;'>154</span>806</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 7</span> F      <span style='text-decoration: underline;'>1</span>907   <span style='text-decoration: underline;'>194</span>763</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 8</span> F      <span style='text-decoration: underline;'>1</span>917   <span style='text-decoration: underline;'>851</span>315</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 9</span> F      <span style='text-decoration: underline;'>1</span>924   <span style='text-decoration: underline;'>992</span>331</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>10</span> F      <span style='text-decoration: underline;'>1</span>938   <span style='text-decoration: underline;'>871</span>255</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># ℹ 128 more rows</span></span></span>
<span></span><span></span>
<span><span class='c'># to a file</span></span>
<span><span class='nv'>csv_file</span> <span class='o'>&lt;-</span> <span class='nf'>withr</span><span class='nf'>::</span><span class='nf'><a href='https://withr.r-lib.org/reference/with_tempfile.html'>local_tempfile</a></span><span class='o'>(</span><span class='o'>)</span></span>
<span><span class='nf'><a href='https://rdrr.io/r/base/file.info.html'>file.size</a></span><span class='o'>(</span><span class='nv'>csv_file</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; [1] NA</span></span>
<span></span><span><span class='nf'><a href='https://duckplyr.tidyverse.org/reference/compute_file.html'>compute_csv</a></span><span class='o'>(</span><span class='nv'>out</span>, <span class='nv'>csv_file</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A duckplyr data frame: 3 variables</span></span></span>
<span><span class='c'>#&gt;    sex    year babies_n</span></span>
<span><span class='c'>#&gt;    <span style='color: #555555; font-style: italic;'>&lt;lgl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>    <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 1</span> FALSE  <span style='text-decoration: underline;'>1</span>992  1<span style='text-decoration: underline;'>226</span>792</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 2</span> FALSE  <span style='text-decoration: underline;'>1</span>997  1<span style='text-decoration: underline;'>112</span>135</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 3</span> FALSE  <span style='text-decoration: underline;'>2</span>002  1<span style='text-decoration: underline;'>089</span>406</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 4</span> FALSE  <span style='text-decoration: underline;'>2</span>005  1<span style='text-decoration: underline;'>083</span>492</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 5</span> FALSE  <span style='text-decoration: underline;'>2</span>012   <span style='text-decoration: underline;'>961</span>393</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 6</span> FALSE  <span style='text-decoration: underline;'>1</span>902   <span style='text-decoration: underline;'>154</span>806</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 7</span> FALSE  <span style='text-decoration: underline;'>1</span>907   <span style='text-decoration: underline;'>194</span>763</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 8</span> FALSE  <span style='text-decoration: underline;'>1</span>917   <span style='text-decoration: underline;'>851</span>315</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 9</span> FALSE  <span style='text-decoration: underline;'>1</span>924   <span style='text-decoration: underline;'>992</span>331</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>10</span> FALSE  <span style='text-decoration: underline;'>1</span>938   <span style='text-decoration: underline;'>871</span>255</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># ℹ more rows</span></span></span>
<span></span><span><span class='nf'><a href='https://rdrr.io/r/base/file.info.html'>file.size</a></span><span class='o'>(</span><span class='nv'>csv_file</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; [1] 2560</span></span>
<span></span></code></pre>

</div>

When duckplyr itself does not support specific functionality, it falls back to dplyr. For instance, row names are not supported yet:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>mtcars</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/summarise.html'>summarize</a></span><span class='o'>(</span></span>
<span>    .by <span class='o'>=</span> <span class='nv'>cyl</span>,</span>
<span>    disp <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/mean.html'>mean</a></span><span class='o'>(</span><span class='nv'>disp</span>, na.rm <span class='o'>=</span> <span class='kc'>TRUE</span><span class='o'>)</span>,</span>
<span>    sd <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/stats/sd.html'>sd</a></span><span class='o'>(</span><span class='nv'>disp</span>, na.rm <span class='o'>=</span> <span class='kc'>TRUE</span><span class='o'>)</span></span>
<span>  <span class='o'>)</span></span>
<span><span class='c'>#&gt; Error processing duckplyr query with DuckDB, falling back to dplyr.</span></span>
<span><span class='c'>#&gt; <span style='font-weight: bold;'>Caused by error in `duckdb_rel_from_df()`:</span></span></span>
<span><span class='c'>#&gt; <span style='color: #BBBB00;'>!</span> Need data frame without row names to convert to relational, got</span></span>
<span><span class='c'>#&gt;   character row names.</span></span>
<span></span><span><span class='c'>#&gt;   cyl     disp sd</span></span>
<span><span class='c'>#&gt; 1   6 183.3143 NA</span></span>
<span><span class='c'>#&gt; 2   4 105.1364 NA</span></span>
<span><span class='c'>#&gt; 3   8 353.1000 NA</span></span>
<span></span></code></pre>

</div>

Current limitations are documented in a vignette. You can change the verbosity of fallbacks, refer to [`duckplyr::fallback_sitrep()`](https://duckplyr.tidyverse.org/reference/fallback.html).

### For large data

For large data, duckplyr is a worthy alternative to dtplyr and dbplyr.

With large datasets, you want:

-   input data in an efficient format, like Parquet files. Therefore you might input data using [`read_parquet_duckdb()`](https://duckplyr.tidyverse.org/reference/read_file_duckdb.html).
-   efficient computation, which duckplyr provides via DuckDB's holistic optimization, without your having to use another syntax than dplyr.
-   the output to not clutter all the memory. Therefore you can make use of these features:
    -   the `prudence` parameter, to disable automatic materialization completely or to disable automatic materialization up to a certain output size.
    -   computation to files using [`compute_parquet()`](https://duckplyr.tidyverse.org/reference/compute_file.html) or [`compute_csv()`](https://duckplyr.tidyverse.org/reference/compute_file.html).

A drawback of analyzing large data with duckplyr is that the limitations of duckplyr won't be compensated by fallbacks since fallbacks to dplyr necessitate putting data into memory. Therefore, if your pipeline encounters fallbacks, you might want to workaround them by converting the duck frame into a table through [`compute()`](https://dplyr.tidyverse.org/reference/compute.html) then running SQL code through the experimental [`read_sql_duckdb()`](https://duckplyr.tidyverse.org/reference/read_sql_duckdb.html) function.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>data</span> <span class='o'>&lt;-</span></span>
<span>  <span class='nf'><a href='https://duckplyr.tidyverse.org/reference/duckdb_tibble.html'>duckdb_tibble</a></span><span class='o'>(</span>a <span class='o'>=</span> <span class='m'>2</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/mutate.html'>mutate</a></span><span class='o'>(</span>b <span class='o'>=</span> <span class='m'>3</span><span class='o'>)</span></span>
<span></span>
<span><span class='nv'>computed_data</span> <span class='o'>&lt;-</span></span>
<span>  <span class='nv'>data</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/compute.html'>compute</a></span><span class='o'>(</span>name <span class='o'>=</span> <span class='s'>"computed_data"</span><span class='o'>)</span></span>
<span></span>
<span><span class='nv'>sql_data</span> <span class='o'>&lt;-</span></span>
<span>  <span class='nf'><a href='https://duckplyr.tidyverse.org/reference/read_sql_duckdb.html'>read_sql_duckdb</a></span><span class='o'>(</span><span class='s'>"SELECT *, a * b AS c FROM computed_data"</span><span class='o'>)</span></span>
<span></span>
<span><span class='nv'>sql_data</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A duckplyr data frame: 3 variables</span></span></span>
<span><span class='c'>#&gt;       a     b     c</span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span>     2     3     6</span></span>
<span></span></code></pre>

</div>

## Help us improve duckplyr!

Our goals for future development of duckplyr include:

-   Enabling users to provide custom translations of dplyr functionality;
-   Making it easier to contribute code to duckplyr.

You can already help though, in three main ways:

-   Please report any issue especially regarding unknown incompabilities. See [`vignette("limits")`](https://duckplyr.tidyverse.org/articles/limits.html).
-   Contribute to the codebase after reading duckplyr's [contributing guide](https://duckplyr.tidyverse.org/CONTRIBUTING.html).
-   Turn on telemetry to help us hear about the most frequent fallbacks so we can prioritize working on the corresponding missing dplyr translation. See [`vignette("telemetry")`](https://duckplyr.tidyverse.org/articles/telemetry.html) and the [`duckplyr::fallback_sitrep()`](https://duckplyr.tidyverse.org/reference/fallback.html) function.

## Acknowledgements

A big thanks to all 54 folks who filed issues, created PRs and generally helped to improve duckplyr!

[@adamschwing](https://github.com/adamschwing), [@andreranza](https://github.com/andreranza), [@apalacio9502](https://github.com/apalacio9502), [@apsteinmetz](https://github.com/apsteinmetz), [@barracuda156](https://github.com/barracuda156), [@beniaminogreen](https://github.com/beniaminogreen), [@bob-rietveld](https://github.com/bob-rietveld), [@brichards920](https://github.com/brichards920), [@cboettig](https://github.com/cboettig), [@davidjayjackson](https://github.com/davidjayjackson), [@DavisVaughan](https://github.com/DavisVaughan), [@Ed2uiz](https://github.com/Ed2uiz), [@eitsupi](https://github.com/eitsupi), [@era127](https://github.com/era127), [@etiennebacher](https://github.com/etiennebacher), [@eutwt](https://github.com/eutwt), [@fmichonneau](https://github.com/fmichonneau), [@github-actions\[bot\]](https://github.com/github-actions%5Bbot%5D), [@hadley](https://github.com/hadley), [@hannes](https://github.com/hannes), [@hawkfish](https://github.com/hawkfish), [@IndrajeetPatil](https://github.com/IndrajeetPatil), [@JanSulavik](https://github.com/JanSulavik), [@JavOrraca](https://github.com/JavOrraca), [@jeroen](https://github.com/jeroen), [@jhk0530](https://github.com/jhk0530), [@joakimlinde](https://github.com/joakimlinde), [@JosiahParry](https://github.com/JosiahParry), [@krlmlr](https://github.com/krlmlr), [@larry77](https://github.com/larry77), [@lnkuiper](https://github.com/lnkuiper), [@lorenzwalthert](https://github.com/lorenzwalthert), [@luisDVA](https://github.com/luisDVA), [@maelle](https://github.com/maelle), [@math-mcshane](https://github.com/math-mcshane), [@meersel](https://github.com/meersel), [@multimeric](https://github.com/multimeric), [@mytarmail](https://github.com/mytarmail), [@nicki-dese](https://github.com/nicki-dese), [@PMassicotte](https://github.com/PMassicotte), [@prasundutta87](https://github.com/prasundutta87), [@rafapereirabr](https://github.com/rafapereirabr), [@Robinlovelace](https://github.com/Robinlovelace), [@romainfrancois](https://github.com/romainfrancois), [@sparrow925](https://github.com/sparrow925), [@stefanlinner](https://github.com/stefanlinner), [@thomasp85](https://github.com/thomasp85), [@TimTaylor](https://github.com/TimTaylor), [@Tmonster](https://github.com/Tmonster), [@toppyy](https://github.com/toppyy), [@wibeasley](https://github.com/wibeasley), [@yjunechoe](https://github.com/yjunechoe), [@ywhcuhk](https://github.com/ywhcuhk), and [@zhjx19](https://github.com/zhjx19).

