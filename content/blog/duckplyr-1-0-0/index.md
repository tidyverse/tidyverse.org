---
output: hugodown::hugo_document

slug: duckplyr-1-0-0
title: duckplyr fully joins the tidyverse!
date: 2025-02-13
author: Kirill Müller and Maëlle Salmon
description: >
    duckplyr 1.0.0 is on CRAN and part of the tidyverse!
    A drop-in replacement for dplyr, powered by DuckDB for speed.
    It is the most dplyr-like of dplyr backends.

photo:
  url: https://www.pexels.com/photo/a-mallard-duck-on-water-6918877/
  author: Kiril Gruev

# one of: "deep-dive", "learn", "package", "programming", "roundup", or "other"
categories: [package]
tags:
  - duckplyr
  - dplyr
  - tidyverse
rmd_hash: 891ff8cbbb6b35e7

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

We're very chuffed to announce the release of [duckplyr](https://duckplyr.tidyverse.org) 1.0.0. duckplyr is a drop-in, fully compatible replacement for dplyr, powered by [DuckDB](https://duckdb.org/) for speed. It joins the rank of dplyr backends together with [dtplyr](https://dtplyr.tidyverse.org) and [dbplyr](https://dbplyr.tidyverse.org). You can use it instead of dplyr for data small or large.

<!-- FIXME:

We have many more dplyr backends, the two above are just from the tidyverse.
GitHub search: https://github.com/search?q=org%3Acran+%2FS3method%5B%28%5D%28mutate%7Csummarise%29+*%2C%2F&type=code
Do we need an "awesome dplyr" like https://github.com/krlmlr/awesome-vctrs/?

-->

You can install it from CRAN with:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://rdrr.io/r/utils/install.packages.html'>install.packages</a></span><span class='o'>(</span><span class='s'>"duckplyr"</span><span class='o'>)</span></span></code></pre>

</div>

In this article, we'll show how duckplyr can help you with data of different size, explain how you can help improve the package, and ... .

## A drop-in replacement for dplyr

The duckplyr package is a *drop-in replacement for dplyr* that uses *DuckDB for speed*. You can simply *drop* duckplyr into your pipeline by loading it, then computations will be efficiently carried out by DuckDB. DuckDB is a fast in-memory analytical database system[^1].

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
<span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://github.com/hadley/babynames'>babynames</a></span><span class='o'>)</span></span>
<span></span>
<span><span class='nv'>out</span> <span class='o'>&lt;-</span> <span class='nv'>babynames</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/mutate.html'>mutate</a></span><span class='o'>(</span>prevalence <span class='o'>=</span> <span class='nf'><a href='https://dplyr.tidyverse.org/reference/if_else.html'>if_else</a></span><span class='o'>(</span><span class='nv'>prop</span> <span class='o'>&gt;=</span> <span class='m'>0.01</span>, <span class='s'>"frequent"</span>, <span class='s'>"rare"</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/summarise.html'>summarize</a></span><span class='o'>(</span></span>
<span>    .by <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='nv'>sex</span>, <span class='nv'>year</span>, <span class='nv'>prevalence</span><span class='o'>)</span>,</span>
<span>    babies_n <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/sum.html'>sum</a></span><span class='o'>(</span><span class='nv'>n</span><span class='o'>)</span></span>
<span>  <span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/filter.html'>filter</a></span><span class='o'>(</span><span class='nv'>sex</span> <span class='o'>==</span> <span class='s'>"F"</span><span class='o'>)</span></span>
<span><span class='nf'><a href='https://rdrr.io/r/base/class.html'>class</a></span><span class='o'>(</span><span class='nv'>out</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; [1] "tbl_df"     "tbl"        "data.frame"</span></span>
<span></span><span><span class='nv'>out</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 274 × 4</span></span></span>
<span><span class='c'>#&gt;    sex    year prevalence babies_n</span></span>
<span><span class='c'>#&gt;    <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>         <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 1</span> F      <span style='text-decoration: underline;'>1</span>987 frequent     <span style='text-decoration: underline;'>297</span>108</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 2</span> F      <span style='text-decoration: underline;'>1</span>989 rare        1<span style='text-decoration: underline;'>532</span>468</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 3</span> F      <span style='text-decoration: underline;'>1</span>990 rare        1<span style='text-decoration: underline;'>615</span>554</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 4</span> F      <span style='text-decoration: underline;'>1</span>994 frequent     <span style='text-decoration: underline;'>152</span>385</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 5</span> F      <span style='text-decoration: underline;'>1</span>997 rare        1<span style='text-decoration: underline;'>591</span>568</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 6</span> F      <span style='text-decoration: underline;'>2</span>010 frequent      <span style='text-decoration: underline;'>43</span>544</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 7</span> F      <span style='text-decoration: underline;'>1</span>880 frequent      <span style='text-decoration: underline;'>32</span>206</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 8</span> F      <span style='text-decoration: underline;'>1</span>881 frequent      <span style='text-decoration: underline;'>30</span>102</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 9</span> F      <span style='text-decoration: underline;'>1</span>883 frequent      <span style='text-decoration: underline;'>36</span>753</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>10</span> F      <span style='text-decoration: underline;'>1</span>884 frequent      <span style='text-decoration: underline;'>41</span>902</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># ℹ 264 more rows</span></span></span>
<span></span></code></pre>

</div>

Like with other dplyr backends like dtplyr and dbplyr, duckplyr allows you to get faster results. Unlike other dplyr backends, duckplyr does not require you to learn a different syntax.

The duckplyr package is fully compatible with dplyr: if an operation cannot be carried out with DuckDB, it is automatically outsourced to dplyr. Over time, we expect fewer and fewer fallbacks to dplyr to be needed.

## How to use duckplyr

To *replace* dplyr with duckplyr, you can:

-   Load duckplyr and then keep your pipeline as is. Calling [`library(duckplyr)`](https://duckplyr.tidyverse.org) overwrites dplyr methods, enabling duckplyr for the entire session no matter how data.frames are created. This is shown in the example above.

-   Create individual "duck frames" using *conversion functions* like [`duckdb_tibble()`](https://duckplyr.tidyverse.org/reference/duckdb_tibble.html) or [`as_duckdb_tibble()`](https://duckplyr.tidyverse.org/reference/duckdb_tibble.html), or *ingestion functions* like [`read_csv_duckdb()`](https://duckplyr.tidyverse.org/reference/read_file_duckdb.html).

Then, the data manipulation pipeline uses the exact same syntax as a dplyr pipeline. The duckplyr package performs the computation using DuckDB.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='c'># Undo the effect of library(duckplyr)</span></span>
<span><span class='nf'><a href='https://duckplyr.tidyverse.org/reference/methods_overwrite.html'>methods_restore</a></span><span class='o'>(</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #00BBBB;'>ℹ</span> Restoring <span style='color: #0000BB;'>dplyr</span> methods.</span></span>
<span></span><span></span>
<span><span class='nv'>out</span> <span class='o'>&lt;-</span> <span class='nv'>babynames</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://duckplyr.tidyverse.org/reference/duckdb_tibble.html'>as_duckdb_tibble</a></span><span class='o'>(</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/mutate.html'>mutate</a></span><span class='o'>(</span>prevalence <span class='o'>=</span> <span class='nf'><a href='https://dplyr.tidyverse.org/reference/if_else.html'>if_else</a></span><span class='o'>(</span><span class='nv'>prop</span> <span class='o'>&gt;=</span> <span class='m'>0.01</span>, <span class='s'>"frequent"</span>, <span class='s'>"rare"</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/summarise.html'>summarize</a></span><span class='o'>(</span></span>
<span>    .by <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='nv'>sex</span>, <span class='nv'>year</span>, <span class='nv'>prevalence</span><span class='o'>)</span>,</span>
<span>    babies_n <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/sum.html'>sum</a></span><span class='o'>(</span><span class='nv'>n</span><span class='o'>)</span></span>
<span>  <span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/filter.html'>filter</a></span><span class='o'>(</span><span class='nv'>sex</span> <span class='o'>==</span> <span class='s'>"F"</span><span class='o'>)</span></span>
<span><span class='nf'><a href='https://rdrr.io/r/base/class.html'>class</a></span><span class='o'>(</span><span class='nv'>out</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; [1] "duckplyr_df" "tbl_df"      "tbl"         "data.frame"</span></span>
<span></span></code></pre>

</div>

In both cases, printing the result only shows the first few rows, as with dbplyr.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>out</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A duckplyr data frame: 4 variables</span></span></span>
<span><span class='c'>#&gt;    sex    year prevalence babies_n</span></span>
<span><span class='c'>#&gt;    <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>         <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 1</span> F      <span style='text-decoration: underline;'>1</span>987 frequent     <span style='text-decoration: underline;'>297</span>108</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 2</span> F      <span style='text-decoration: underline;'>1</span>989 rare        1<span style='text-decoration: underline;'>532</span>468</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 3</span> F      <span style='text-decoration: underline;'>1</span>990 rare        1<span style='text-decoration: underline;'>615</span>554</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 4</span> F      <span style='text-decoration: underline;'>1</span>994 frequent     <span style='text-decoration: underline;'>152</span>385</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 5</span> F      <span style='text-decoration: underline;'>1</span>997 rare        1<span style='text-decoration: underline;'>591</span>568</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 6</span> F      <span style='text-decoration: underline;'>2</span>010 frequent      <span style='text-decoration: underline;'>43</span>544</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 7</span> F      <span style='text-decoration: underline;'>1</span>880 frequent      <span style='text-decoration: underline;'>32</span>206</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 8</span> F      <span style='text-decoration: underline;'>1</span>881 frequent      <span style='text-decoration: underline;'>30</span>102</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 9</span> F      <span style='text-decoration: underline;'>1</span>883 frequent      <span style='text-decoration: underline;'>36</span>753</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>10</span> F      <span style='text-decoration: underline;'>1</span>884 frequent      <span style='text-decoration: underline;'>41</span>902</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># ℹ more rows</span></span></span>
<span></span></code></pre>

</div>

The result can finally be materialized to memory, or computed temporarily, or computed to a file.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='c'># to memory</span></span>
<span><span class='nf'><a href='https://rdrr.io/r/base/nrow.html'>nrow</a></span><span class='o'>(</span><span class='nv'>out</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; [1] 274</span></span>
<span></span><span><span class='c'># or for instance collect(out)</span></span>
<span></span>
<span><span class='c'># to a file</span></span>
<span><span class='nv'>csv_file</span> <span class='o'>&lt;-</span> <span class='nf'>withr</span><span class='nf'>::</span><span class='nf'><a href='https://withr.r-lib.org/reference/with_tempfile.html'>local_tempfile</a></span><span class='o'>(</span><span class='o'>)</span></span>
<span><span class='nf'><a href='https://duckplyr.tidyverse.org/reference/compute_file.html'>compute_csv</a></span><span class='o'>(</span><span class='nv'>out</span>, <span class='nv'>csv_file</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A duckplyr data frame: 4 variables</span></span></span>
<span><span class='c'>#&gt;    sex    year prevalence babies_n</span></span>
<span><span class='c'>#&gt;    <span style='color: #555555; font-style: italic;'>&lt;lgl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>         <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 1</span> FALSE  <span style='text-decoration: underline;'>1</span>988 frequent     <span style='text-decoration: underline;'>327</span>539</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 2</span> FALSE  <span style='text-decoration: underline;'>1</span>991 frequent     <span style='text-decoration: underline;'>259</span>551</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 3</span> FALSE  <span style='text-decoration: underline;'>1</span>995 frequent     <span style='text-decoration: underline;'>142</span>363</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 4</span> FALSE  <span style='text-decoration: underline;'>1</span>996 frequent     <span style='text-decoration: underline;'>114</span>606</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 5</span> FALSE  <span style='text-decoration: underline;'>2</span>003 rare        1<span style='text-decoration: underline;'>757</span>361</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 6</span> FALSE  <span style='text-decoration: underline;'>2</span>006 frequent      <span style='text-decoration: underline;'>21</span>400</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 7</span> FALSE  <span style='text-decoration: underline;'>2</span>007 rare        1<span style='text-decoration: underline;'>920</span>619</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 8</span> FALSE  <span style='text-decoration: underline;'>2</span>008 rare        1<span style='text-decoration: underline;'>888</span>607</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 9</span> FALSE  <span style='text-decoration: underline;'>2</span>009 rare        1<span style='text-decoration: underline;'>812</span>301</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>10</span> FALSE  <span style='text-decoration: underline;'>2</span>011 frequent      <span style='text-decoration: underline;'>41</span>738</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># ℹ more rows</span></span></span>
<span></span><span><span class='nf'>fs</span><span class='nf'>::</span><span class='nf'><a href='https://fs.r-lib.org/reference/file_info.html'>file_size</a></span><span class='o'>(</span><span class='nv'>csv_file</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; 6.73K</span></span>
<span></span></code></pre>

</div>

When duckplyr itself does not support specific functionality, it falls back to dplyr. For instance, filtering on grouped data is not supported yet, still it works thanks to the fallback mechanism.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>babynames</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/filter.html'>filter</a></span><span class='o'>(</span><span class='nv'>n</span> <span class='o'>&gt;</span> <span class='m'>10000</span>, .by <span class='o'>=</span> <span class='s'>"name"</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 5,844 × 5</span></span></span>
<span><span class='c'>#&gt;     year sex   name      n   prop</span></span>
<span><span class='c'>#&gt;    <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;int&gt;</span>  <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 1</span>  <span style='text-decoration: underline;'>1</span>888 F     Mary  <span style='text-decoration: underline;'>11</span>754 0.062<span style='text-decoration: underline;'>0</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 2</span>  <span style='text-decoration: underline;'>1</span>889 F     Mary  <span style='text-decoration: underline;'>11</span>648 0.061<span style='text-decoration: underline;'>6</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 3</span>  <span style='text-decoration: underline;'>1</span>890 F     Mary  <span style='text-decoration: underline;'>12</span>078 0.059<span style='text-decoration: underline;'>9</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 4</span>  <span style='text-decoration: underline;'>1</span>891 F     Mary  <span style='text-decoration: underline;'>11</span>703 0.059<span style='text-decoration: underline;'>5</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 5</span>  <span style='text-decoration: underline;'>1</span>892 F     Mary  <span style='text-decoration: underline;'>13</span>172 0.058<span style='text-decoration: underline;'>6</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 6</span>  <span style='text-decoration: underline;'>1</span>893 F     Mary  <span style='text-decoration: underline;'>12</span>784 0.056<span style='text-decoration: underline;'>8</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 7</span>  <span style='text-decoration: underline;'>1</span>894 F     Mary  <span style='text-decoration: underline;'>13</span>151 0.055<span style='text-decoration: underline;'>7</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 8</span>  <span style='text-decoration: underline;'>1</span>895 F     Mary  <span style='text-decoration: underline;'>13</span>446 0.054<span style='text-decoration: underline;'>4</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 9</span>  <span style='text-decoration: underline;'>1</span>896 F     Mary  <span style='text-decoration: underline;'>13</span>811 0.054<span style='text-decoration: underline;'>8</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>10</span>  <span style='text-decoration: underline;'>1</span>897 F     Mary  <span style='text-decoration: underline;'>13</span>413 0.054<span style='text-decoration: underline;'>0</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># ℹ 5,834 more rows</span></span></span>
<span></span></code></pre>

</div>

For performance reasons, the output order of the result is not guaranteed to be stable. If you need a stable order, you can use [`arrange()`](https://dplyr.tidyverse.org/reference/arrange.html) or force output order stability by setting an environment variable. This and other limitations are documented in [`vignette("limits")`](https://duckplyr.tidyverse.org/articles/limits.html).

## Large data

For large data, duckplyr is a legitimate alternative to dtplyr and dbplyr.

With large datasets, you want:

-   input data in an efficient format, like Parquet files, which duckplyr allows thanks to its ingestion functions like [`read_parquet_duckdb()`](https://duckplyr.tidyverse.org/reference/read_file_duckdb.html).
-   efficient computation, which duckplyr provides via DuckDB's holistic optimization, without your having to use another syntax than dplyr.
-   the output to not clutter all the memory, which duckplyr supports through two features:
    -   computation to files using [`compute_parquet()`](https://duckplyr.tidyverse.org/reference/compute_file.html) or [`compute_csv()`](https://duckplyr.tidyverse.org/reference/compute_file.html).
    -   the control of automatic materialization (collection of results into memory). You can disable automatic materialization completely or, as a compromise, disable it up to a certain output size. See [`vignette("prudence")`](https://duckplyr.tidyverse.org/articles/prudence.html) for details.

See [`vignette("large")`](https://duckplyr.tidyverse.org/articles/large.html) for a walkthrough and more details.

A drawback of analyzing large data with duckplyr is that the limitations of duckplyr won't be compensated by fallbacks, since fallbacks to dplyr necessitate putting data into memory. Therefore, if your pipeline encounters fallbacks, you might want to work around them by converting the duck frame into a table through [`compute()`](https://dplyr.tidyverse.org/reference/compute.html) then running SQL code through the experimental [`read_sql_duckdb()`](https://duckplyr.tidyverse.org/reference/read_sql_duckdb.html) function. Again, over time, we expect more native support for dplyr functionality.

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

-   Enabling users to provide [custom translations](https://github.com/tidyverse/duckplyr/issues/158) of dplyr functionality;
-   Making it easier to contribute code to duckplyr;
-   Supporting more dplyr and tidyr functionality natively in DuckDB.

You can help!

-   Please report any issues, especially regarding unknown incompabilities. See [`vignette("limits")`](https://duckplyr.tidyverse.org/articles/limits.html).
-   Contribute to the codebase after reading duckplyr's [contributing guide](https://duckplyr.tidyverse.org/CONTRIBUTING.html).
-   Turn on telemetry to help us hear about the most frequent fallbacks so we can prioritize working on the corresponding missing dplyr translation. See [`vignette("telemetry")`](https://duckplyr.tidyverse.org/articles/telemetry.html) and the [`duckplyr::fallback_sitrep()`](https://duckplyr.tidyverse.org/reference/fallback.html) function.

## Acknowledgements and additional resources

A big thanks to all folks who filed issues, created PRs and generally helped to improve duckplyr!

<!-- FIXME: Can we use_tidy_thanks also for the duckdb repo?, and perhaps merge the two? -->

[@adamschwing](https://github.com/adamschwing), [@andreranza](https://github.com/andreranza), [@apalacio9502](https://github.com/apalacio9502), [@apsteinmetz](https://github.com/apsteinmetz), [@barracuda156](https://github.com/barracuda156), [@beniaminogreen](https://github.com/beniaminogreen), [@bob-rietveld](https://github.com/bob-rietveld), [@brichards920](https://github.com/brichards920), [@cboettig](https://github.com/cboettig), [@davidjayjackson](https://github.com/davidjayjackson), [@DavisVaughan](https://github.com/DavisVaughan), [@Ed2uiz](https://github.com/Ed2uiz), [@eitsupi](https://github.com/eitsupi), [@era127](https://github.com/era127), [@etiennebacher](https://github.com/etiennebacher), [@eutwt](https://github.com/eutwt), [@fmichonneau](https://github.com/fmichonneau), [@hadley](https://github.com/hadley), [@hannes](https://github.com/hannes), [@hawkfish](https://github.com/hawkfish), [@IndrajeetPatil](https://github.com/IndrajeetPatil), [@JanSulavik](https://github.com/JanSulavik), [@JavOrraca](https://github.com/JavOrraca), [@jeroen](https://github.com/jeroen), [@jhk0530](https://github.com/jhk0530), [@joakimlinde](https://github.com/joakimlinde), [@JosiahParry](https://github.com/JosiahParry), [@larry77](https://github.com/larry77), [@lnkuiper](https://github.com/lnkuiper), [@lorenzwalthert](https://github.com/lorenzwalthert), [@luisDVA](https://github.com/luisDVA), [@maelle](https://github.com/maelle), [@math-mcshane](https://github.com/math-mcshane), [@meersel](https://github.com/meersel), [@multimeric](https://github.com/multimeric), [@mytarmail](https://github.com/mytarmail), [@nicki-dese](https://github.com/nicki-dese), [@PMassicotte](https://github.com/PMassicotte), [@prasundutta87](https://github.com/prasundutta87), [@rafapereirabr](https://github.com/rafapereirabr), [@Robinlovelace](https://github.com/Robinlovelace), [@romainfrancois](https://github.com/romainfrancois), [@sparrow925](https://github.com/sparrow925), [@stefanlinner](https://github.com/stefanlinner), [@thomasp85](https://github.com/thomasp85), [@TimTaylor](https://github.com/TimTaylor), [@Tmonster](https://github.com/Tmonster), [@toppyy](https://github.com/toppyy), [@wibeasley](https://github.com/wibeasley), [@yjunechoe](https://github.com/yjunechoe), [@ywhcuhk](https://github.com/ywhcuhk), and [@zhjx19](https://github.com/zhjx19).

Special thanks to Joe Thorley ([@joethorley](https://github.com/joethorley)) for help with choosing the right words.

Eager to learn more about duckplyr -- beside by trying it out yourself? The pkgdown website of duckplyr features several [articles](https://duckplyr.tidyverse.org/articles/). Furthermore, the blog post ["duckplyr: dplyr Powered by DuckDB"](https://duckdb.org/2024/04/02/duckplyr.html) by Hannes Mühleisen provides some context on duckplyr including its inner workings, as also seen in a [section](https://blog.r-hub.io/2025/02/13/lazy-meanings/#duckplyr-lazy-evaluation-and-prudence) of the R-hub blog post ["Lazy introduction to laziness in R"](https://blog.r-hub.io/2025/02/13/lazy-meanings/) by Maëlle Salmon, Athanasia Mo Mowinckel and Hannah Frick.

[^1]: If you haven't heard about it, you can watch [Hannes Mühleisen's keynote at posit::conf(2024)](https://www.youtube.com/watch?v=GELhdezYmP0&feature=youtu.be).

