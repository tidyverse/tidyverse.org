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
rmd_hash: b5a425fc132f9f15

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

We're very chuffed to announce the release of [duckplyr](https://duckplyr.tidyverse.org) 1.0.0. This is a new dplyr backend powered by [DuckDB](https://duckdb.org/), a fast in-memory analytical database system[^1]. It joins the rank of dplyr backends together with [dtplyr](https://dtplyr.tidyverse.org) and [dbplyr](https://dbplyr.tidyverse.org). You can use it instead of dplyr for data small or large.

<!-- FIXME:

We have many more dplyr backends, the two above are just from the tidyverse.
GitHub search: https://github.com/search?q=org%3Acran+%2FS3method%5B%28%5D%28mutate%7Csummarise%29+*%2C%2F&type=code
Do we need an "awesome dplyr" like https://github.com/krlmlr/awesome-vctrs/?

-->

You can install it from CRAN with:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://rdrr.io/r/utils/install.packages.html'>install.packages</a></span><span class='o'>(</span><span class='s'>"duckplyr"</span><span class='o'>)</span></span></code></pre>

</div>

This article shows how duckplyr can be used instead of dplyr with data of different size, explain how you can help improve the package, and share a selection of other resources.

## A drop-in replacement for dplyr

Imagine you have to wrangle a huge dataset. Here we generate one using the [data generator from the TPC-H benchmark](https://duckdb.org/2024/04/02/duckplyr.html#benchmark-tpc-h-q1).

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>lineitem</span> <span class='o'>&lt;-</span> <span class='nf'>duckdb</span><span class='nf'>:::</span><span class='nf'>sql</span><span class='o'>(</span><span class='s'>"INSTALL tpch; LOAD tpch; CALL dbgen(sf=1); FROM lineitem;"</span><span class='o'>)</span></span>
<span><span class='nv'>lineitem</span> <span class='o'>&lt;-</span> <span class='nf'>tibble</span><span class='nf'>::</span><span class='nf'><a href='https://tibble.tidyverse.org/reference/as_tibble.html'>as_tibble</a></span><span class='o'>(</span><span class='nv'>lineitem</span><span class='o'>)</span></span>
<span><span class='nf'>dplyr</span><span class='nf'>::</span><span class='nf'><a href='https://pillar.r-lib.org/reference/glimpse.html'>glimpse</a></span><span class='o'>(</span><span class='nv'>lineitem</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; Rows: 6,001,215</span></span>
<span><span class='c'>#&gt; Columns: 16</span></span>
<span><span class='c'>#&gt; $ l_orderkey      <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> 1, 1, 1, 1, 1, 1, 2, 3, 3, 3, 3, 3, 3, 4, 5, 5, 5, 6, …</span></span>
<span><span class='c'>#&gt; $ l_partkey       <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> 155190, 67310, 63700, 2132, 24027, 15635, 106170, 4297…</span></span>
<span><span class='c'>#&gt; $ l_suppkey       <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> 7706, 7311, 3701, 4633, 1534, 638, 1191, 1798, 6540, 3…</span></span>
<span><span class='c'>#&gt; $ l_linenumber    <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> 1, 2, 3, 4, 5, 6, 1, 1, 2, 3, 4, 5, 6, 1, 1, 2, 3, 1, …</span></span>
<span><span class='c'>#&gt; $ l_quantity      <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> 17, 36, 8, 28, 24, 32, 38, 45, 49, 27, 2, 28, 26, 30, …</span></span>
<span><span class='c'>#&gt; $ l_extendedprice <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> 21168.23, 45983.16, 13309.60, 28955.64, 22824.48, 4962…</span></span>
<span><span class='c'>#&gt; $ l_discount      <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> 0.04, 0.09, 0.10, 0.09, 0.10, 0.07, 0.00, 0.06, 0.10, …</span></span>
<span><span class='c'>#&gt; $ l_tax           <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> 0.02, 0.06, 0.02, 0.06, 0.04, 0.02, 0.05, 0.00, 0.00, …</span></span>
<span><span class='c'>#&gt; $ l_returnflag    <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span> "N", "N", "N", "N", "N", "N", "N", "R", "R", "A", "A",…</span></span>
<span><span class='c'>#&gt; $ l_linestatus    <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span> "O", "O", "O", "O", "O", "O", "O", "F", "F", "F", "F",…</span></span>
<span><span class='c'>#&gt; $ l_shipdate      <span style='color: #555555; font-style: italic;'>&lt;date&gt;</span> 1996-03-13, 1996-04-12, 1996-01-29, 1996-04-21, 1996-…</span></span>
<span><span class='c'>#&gt; $ l_commitdate    <span style='color: #555555; font-style: italic;'>&lt;date&gt;</span> 1996-02-12, 1996-02-28, 1996-03-05, 1996-03-30, 1996-…</span></span>
<span><span class='c'>#&gt; $ l_receiptdate   <span style='color: #555555; font-style: italic;'>&lt;date&gt;</span> 1996-03-22, 1996-04-20, 1996-01-31, 1996-05-16, 1996-…</span></span>
<span><span class='c'>#&gt; $ l_shipinstruct  <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span> "DELIVER IN PERSON", "TAKE BACK RETURN", "TAKE BACK RE…</span></span>
<span><span class='c'>#&gt; $ l_shipmode      <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span> "TRUCK", "MAIL", "REG AIR", "AIR", "FOB", "MAIL", "RAI…</span></span>
<span><span class='c'>#&gt; $ l_comment       <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span> "to beans x-ray carefull", " according to the final fo…</span></span>
<span></span></code></pre>

</div>

We could transform the data using dplyr but we could also transform it using a tool that'll scale well to ever larger data: duckplyr. The duckplyr package is a *drop-in replacement for dplyr* that uses *DuckDB for speed*. You can simply *drop* duckplyr into your pipeline by loading it, then computations will be efficiently carried out by DuckDB.

Below, we express the standard "TPC-H benchmark query 1" in dplyr syntax, but execute it with duckplyr.

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
<span><span class='nv'>out</span> <span class='o'>&lt;-</span> <span class='nv'>lineitem</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/select.html'>select</a></span><span class='o'>(</span><span class='nv'>l_shipdate</span>, <span class='nv'>l_returnflag</span>, <span class='nv'>l_linestatus</span>, <span class='nv'>l_quantity</span>, <span class='nv'>l_extendedprice</span>, <span class='nv'>l_discount</span>, <span class='nv'>l_tax</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/filter.html'>filter</a></span><span class='o'>(</span><span class='nv'>l_shipdate</span> <span class='o'>&lt;=</span> <span class='o'>!</span><span class='o'>!</span><span class='nf'><a href='https://rdrr.io/r/base/as.Date.html'>as.Date</a></span><span class='o'>(</span><span class='s'>"1998-09-02"</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/select.html'>select</a></span><span class='o'>(</span><span class='nv'>l_returnflag</span>, <span class='nv'>l_linestatus</span>, <span class='nv'>l_quantity</span>, <span class='nv'>l_extendedprice</span>, <span class='nv'>l_discount</span>, <span class='nv'>l_tax</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/summarise.html'>summarise</a></span><span class='o'>(</span></span>
<span>    sum_qty <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/sum.html'>sum</a></span><span class='o'>(</span><span class='nv'>l_quantity</span><span class='o'>)</span>,</span>
<span>    sum_base_price <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/sum.html'>sum</a></span><span class='o'>(</span><span class='nv'>l_extendedprice</span><span class='o'>)</span>,</span>
<span>    sum_disc_price <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/sum.html'>sum</a></span><span class='o'>(</span><span class='nv'>l_extendedprice</span> <span class='o'>*</span> <span class='o'>(</span><span class='m'>1</span> <span class='o'>-</span> <span class='nv'>l_discount</span><span class='o'>)</span><span class='o'>)</span>,</span>
<span>    sum_charge <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/sum.html'>sum</a></span><span class='o'>(</span><span class='nv'>l_extendedprice</span> <span class='o'>*</span> <span class='o'>(</span><span class='m'>1</span> <span class='o'>-</span> <span class='nv'>l_discount</span><span class='o'>)</span> <span class='o'>*</span> <span class='o'>(</span><span class='m'>1</span> <span class='o'>+</span> <span class='nv'>l_tax</span><span class='o'>)</span><span class='o'>)</span>,</span>
<span>    avg_qty <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/mean.html'>mean</a></span><span class='o'>(</span><span class='nv'>l_quantity</span><span class='o'>)</span>,</span>
<span>    avg_price <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/mean.html'>mean</a></span><span class='o'>(</span><span class='nv'>l_extendedprice</span><span class='o'>)</span>,</span>
<span>    avg_disc <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/mean.html'>mean</a></span><span class='o'>(</span><span class='nv'>l_discount</span><span class='o'>)</span>,</span>
<span>    count_order <span class='o'>=</span> <span class='nf'><a href='https://dplyr.tidyverse.org/reference/context.html'>n</a></span><span class='o'>(</span><span class='o'>)</span>,</span>
<span>    .by <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='nv'>l_returnflag</span>, <span class='nv'>l_linestatus</span><span class='o'>)</span></span>
<span>  <span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/arrange.html'>arrange</a></span><span class='o'>(</span><span class='nv'>l_returnflag</span>, <span class='nv'>l_linestatus</span><span class='o'>)</span></span>
<span><span class='nv'>out</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 4 × 10</span></span></span>
<span><span class='c'>#&gt;   l_returnflag l_linestatus  sum_qty sum_base_price sum_disc_price    sum_charge</span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>        <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>           <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>          <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>          <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>         <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span> A            F            37<span style='text-decoration: underline;'>734</span>107   <span style='text-decoration: underline;'>56</span>586<span style='text-decoration: underline;'>554</span>401.   <span style='text-decoration: underline;'>53</span>758<span style='text-decoration: underline;'>257</span>135.  <span style='text-decoration: underline;'>55</span>909<span style='text-decoration: underline;'>065</span>223.</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span> N            F              <span style='text-decoration: underline;'>991</span>417    <span style='text-decoration: underline;'>1</span>487<span style='text-decoration: underline;'>504</span>710.    <span style='text-decoration: underline;'>1</span>413<span style='text-decoration: underline;'>082</span>168.   <span style='text-decoration: underline;'>1</span>469<span style='text-decoration: underline;'>649</span>223.</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>3</span> N            O            74<span style='text-decoration: underline;'>476</span>040  <span style='text-decoration: underline;'>111</span>701<span style='text-decoration: underline;'>729</span>698.  <span style='text-decoration: underline;'>106</span>118<span style='text-decoration: underline;'>230</span>308. <span style='text-decoration: underline;'>110</span>367<span style='text-decoration: underline;'>043</span>872.</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>4</span> R            F            37<span style='text-decoration: underline;'>719</span>753   <span style='text-decoration: underline;'>56</span>568<span style='text-decoration: underline;'>041</span>381.   <span style='text-decoration: underline;'>53</span>741<span style='text-decoration: underline;'>292</span>685.  <span style='text-decoration: underline;'>55</span>889<span style='text-decoration: underline;'>619</span>120.</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># ℹ 4 more variables: avg_qty &lt;dbl&gt;, avg_price &lt;dbl&gt;, avg_disc &lt;dbl&gt;,</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>#   count_order &lt;int&gt;</span></span></span>
<span></span></code></pre>

</div>

Like with other dplyr backends like dtplyr and dbplyr, duckplyr allows you to get faster results without learning a different syntax. Unlike other dplyr backends, duckplyr does not require you to change existing code or learn specific idiosyncracies. Not only is the syntax the same, the semantics are too!

The duckplyr package is fully compatible with dplyr: if an operation cannot be carried out with DuckDB, it is automatically outsourced to dplyr. Over time, we expect fewer and fewer fallbacks to dplyr to be needed.

## How to use duckplyr

To *replace* dplyr with duckplyr, you can:

-   Load duckplyr and then keep your pipeline as is. Calling [`library(duckplyr)`](https://duckplyr.tidyverse.org) overwrites dplyr methods, enabling duckplyr for the entire session no matter how data.frames are created. This is shown in the example above.

-   Create individual "duck frames" using *conversion functions* like [`duckdb_tibble()`](https://duckplyr.tidyverse.org/reference/duckdb_tibble.html) or [`as_duckdb_tibble()`](https://duckplyr.tidyverse.org/reference/duckdb_tibble.html), or *ingestion functions* like [`read_csv_duckdb()`](https://duckplyr.tidyverse.org/reference/read_file_duckdb.html).

Then, the data manipulation pipeline uses the exact same syntax as a dplyr pipeline. The duckplyr package performs the computation using DuckDB.

*We only need the chunk below because we had loaded duckplyr in a previous example.*

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='c'># Undo the effect of library(duckplyr)</span></span>
<span><span class='nf'><a href='https://duckplyr.tidyverse.org/reference/methods_overwrite.html'>methods_restore</a></span><span class='o'>(</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #00BBBB;'>ℹ</span> Restoring <span style='color: #0000BB;'>dplyr</span> methods.</span></span>
<span></span></code></pre>

</div>

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>out</span> <span class='o'>&lt;-</span> <span class='nv'>lineitem</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'>duckplyr</span><span class='nf'>::</span><span class='nf'><a href='https://duckplyr.tidyverse.org/reference/duckdb_tibble.html'>as_duckdb_tibble</a></span><span class='o'>(</span><span class='o'>)</span> <span class='o'>|&gt;</span> <span class='c'># this is the only change :-)</span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/select.html'>select</a></span><span class='o'>(</span><span class='nv'>l_shipdate</span>, <span class='nv'>l_returnflag</span>, <span class='nv'>l_linestatus</span>, <span class='nv'>l_quantity</span>, <span class='nv'>l_extendedprice</span>, <span class='nv'>l_discount</span>, <span class='nv'>l_tax</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/filter.html'>filter</a></span><span class='o'>(</span><span class='nv'>l_shipdate</span> <span class='o'>&lt;=</span> <span class='o'>!</span><span class='o'>!</span><span class='nf'><a href='https://rdrr.io/r/base/as.Date.html'>as.Date</a></span><span class='o'>(</span><span class='s'>"1998-09-02"</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/select.html'>select</a></span><span class='o'>(</span><span class='nv'>l_returnflag</span>, <span class='nv'>l_linestatus</span>, <span class='nv'>l_quantity</span>, <span class='nv'>l_extendedprice</span>, <span class='nv'>l_discount</span>, <span class='nv'>l_tax</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/summarise.html'>summarise</a></span><span class='o'>(</span></span>
<span>    sum_qty <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/sum.html'>sum</a></span><span class='o'>(</span><span class='nv'>l_quantity</span><span class='o'>)</span>,</span>
<span>    sum_base_price <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/sum.html'>sum</a></span><span class='o'>(</span><span class='nv'>l_extendedprice</span><span class='o'>)</span>,</span>
<span>    sum_disc_price <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/sum.html'>sum</a></span><span class='o'>(</span><span class='nv'>l_extendedprice</span> <span class='o'>*</span> <span class='o'>(</span><span class='m'>1</span> <span class='o'>-</span> <span class='nv'>l_discount</span><span class='o'>)</span><span class='o'>)</span>,</span>
<span>    sum_charge <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/sum.html'>sum</a></span><span class='o'>(</span><span class='nv'>l_extendedprice</span> <span class='o'>*</span> <span class='o'>(</span><span class='m'>1</span> <span class='o'>-</span> <span class='nv'>l_discount</span><span class='o'>)</span> <span class='o'>*</span> <span class='o'>(</span><span class='m'>1</span> <span class='o'>+</span> <span class='nv'>l_tax</span><span class='o'>)</span><span class='o'>)</span>,</span>
<span>    avg_qty <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/mean.html'>mean</a></span><span class='o'>(</span><span class='nv'>l_quantity</span><span class='o'>)</span>,</span>
<span>    avg_price <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/mean.html'>mean</a></span><span class='o'>(</span><span class='nv'>l_extendedprice</span><span class='o'>)</span>,</span>
<span>    avg_disc <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/mean.html'>mean</a></span><span class='o'>(</span><span class='nv'>l_discount</span><span class='o'>)</span>,</span>
<span>    count_order <span class='o'>=</span> <span class='nf'><a href='https://dplyr.tidyverse.org/reference/context.html'>n</a></span><span class='o'>(</span><span class='o'>)</span>,</span>
<span>    .by <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='nv'>l_returnflag</span>, <span class='nv'>l_linestatus</span><span class='o'>)</span></span>
<span>  <span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/arrange.html'>arrange</a></span><span class='o'>(</span><span class='nv'>l_returnflag</span>, <span class='nv'>l_linestatus</span><span class='o'>)</span></span></code></pre>

</div>

For programming, the resulting object is indistinguishable from a regular tibble, except for the additional class.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://rdrr.io/r/base/typeof.html'>typeof</a></span><span class='o'>(</span><span class='nv'>out</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; [1] "list"</span></span>
<span></span><span><span class='nf'><a href='https://rdrr.io/r/base/class.html'>class</a></span><span class='o'>(</span><span class='nv'>out</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; [1] "duckplyr_df" "tbl_df"      "tbl"         "data.frame"</span></span>
<span></span><span><span class='nv'>out</span><span class='o'>$</span><span class='nv'>year</span><span class='o'>[</span><span class='m'>1</span><span class='o'>:</span><span class='m'>3</span><span class='o'>]</span></span>
<span><span class='c'>#&gt; Warning: Unknown or uninitialised column: `year`.</span></span>
<span></span><span><span class='c'>#&gt; NULL</span></span>
<span></span></code></pre>

</div>

The result could also be computed to a file.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='c'># to a file</span></span>
<span><span class='nv'>csv_file</span> <span class='o'>&lt;-</span> <span class='nf'>withr</span><span class='nf'>::</span><span class='nf'><a href='https://withr.r-lib.org/reference/with_tempfile.html'>local_tempfile</a></span><span class='o'>(</span><span class='o'>)</span></span>
<span><span class='nf'><a href='https://duckplyr.tidyverse.org/reference/compute_file.html'>compute_csv</a></span><span class='o'>(</span><span class='nv'>out</span>, <span class='nv'>csv_file</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A duckplyr data frame: 10 variables</span></span></span>
<span><span class='c'>#&gt;   l_returnflag l_linestatus  sum_qty sum_base_price sum_disc_price    sum_charge</span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>        <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>           <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>          <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>          <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>         <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span> A            F            37<span style='text-decoration: underline;'>734</span>107   <span style='text-decoration: underline;'>56</span>586<span style='text-decoration: underline;'>554</span>401.   <span style='text-decoration: underline;'>53</span>758<span style='text-decoration: underline;'>257</span>135.  <span style='text-decoration: underline;'>55</span>909<span style='text-decoration: underline;'>065</span>223.</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span> N            F              <span style='text-decoration: underline;'>991</span>417    <span style='text-decoration: underline;'>1</span>487<span style='text-decoration: underline;'>504</span>710.    <span style='text-decoration: underline;'>1</span>413<span style='text-decoration: underline;'>082</span>168.   <span style='text-decoration: underline;'>1</span>469<span style='text-decoration: underline;'>649</span>223.</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>3</span> N            O            74<span style='text-decoration: underline;'>476</span>040  <span style='text-decoration: underline;'>111</span>701<span style='text-decoration: underline;'>729</span>698.  <span style='text-decoration: underline;'>106</span>118<span style='text-decoration: underline;'>230</span>308. <span style='text-decoration: underline;'>110</span>367<span style='text-decoration: underline;'>043</span>872.</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>4</span> R            F            37<span style='text-decoration: underline;'>719</span>753   <span style='text-decoration: underline;'>56</span>568<span style='text-decoration: underline;'>041</span>381.   <span style='text-decoration: underline;'>53</span>741<span style='text-decoration: underline;'>292</span>685.  <span style='text-decoration: underline;'>55</span>889<span style='text-decoration: underline;'>619</span>120.</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># ℹ 4 more variables: avg_qty &lt;dbl&gt;, avg_price &lt;dbl&gt;, avg_disc &lt;dbl&gt;,</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>#   count_order &lt;dbl&gt;</span></span></span>
<span></span><span><span class='nf'>fs</span><span class='nf'>::</span><span class='nf'><a href='https://fs.r-lib.org/reference/file_info.html'>file_size</a></span><span class='o'>(</span><span class='nv'>csv_file</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; 652</span></span>
<span></span></code></pre>

</div>

Operations not yet supported by duckplyr are automatically outsourced to dplyr. For instance, filtering on grouped data is not supported yet, still it works thanks to the fallback mechanism.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>lineitem</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'>duckplyr</span><span class='nf'>::</span><span class='nf'><a href='https://duckplyr.tidyverse.org/reference/duckdb_tibble.html'>as_duckdb_tibble</a></span><span class='o'>(</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/select.html'>select</a></span><span class='o'>(</span><span class='nv'>l_shipdate</span>, <span class='nv'>l_returnflag</span>, <span class='nv'>l_linestatus</span>, <span class='nv'>l_quantity</span>, <span class='nv'>l_extendedprice</span>, <span class='nv'>l_discount</span>, <span class='nv'>l_tax</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/filter.html'>filter</a></span><span class='o'>(</span><span class='nv'>l_quantity</span> <span class='o'>==</span> <span class='nf'><a href='https://rdrr.io/r/base/Extremes.html'>max</a></span><span class='o'>(</span><span class='nv'>l_quantity</span><span class='o'>)</span>, .by <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='nv'>l_returnflag</span>, <span class='nv'>l_linestatus</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; Cannot process duckplyr query with DuckDB, falling back to dplyr.</span></span>
<span><span class='c'>#&gt; <span style='color: #0000BB;'>ℹ</span> &#123;.code filter(by = ...)&#125; not implemented, try &#123;.code mutate(by = ...)&#125; followed by a simple &#123;.code filter()&#125;.</span></span>
<span></span><span><span class='c'>#&gt; <span style='color: #555555;'># A duckplyr data frame: 7 variables</span></span></span>
<span><span class='c'>#&gt;    l_shipdate l_returnflag l_linestatus l_quantity l_extendedprice l_discount</span></span>
<span><span class='c'>#&gt;    <span style='color: #555555; font-style: italic;'>&lt;date&gt;</span>     <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>        <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>             <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>           <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>      <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 1</span> 1994-08-08 A            F                    50          <span style='text-decoration: underline;'>73</span>426.       0.08</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 2</span> 1994-09-17 A            F                    50          <span style='text-decoration: underline;'>59</span>962.       0.02</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 3</span> 1996-06-12 N            O                    50          <span style='text-decoration: underline;'>55</span>204.       0.02</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 4</span> 1994-12-11 A            F                    50          <span style='text-decoration: underline;'>61</span>106        0.09</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 5</span> 1997-03-24 N            O                    50          <span style='text-decoration: underline;'>97</span>144        0.07</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 6</span> 1994-08-18 R            F                    50          <span style='text-decoration: underline;'>96</span>694.       0.06</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 7</span> 1994-04-20 A            F                    50          <span style='text-decoration: underline;'>84</span>581        0.05</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 8</span> 1996-03-21 N            O                    50          <span style='text-decoration: underline;'>54</span>156        0.08</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 9</span> 1997-01-24 N            O                    50          <span style='text-decoration: underline;'>71</span>718.       0.06</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>10</span> 1997-03-28 N            O                    50          <span style='text-decoration: underline;'>78</span>626        0.01</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># ℹ more rows</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># ℹ 1 more variable: l_tax &lt;dbl&gt;</span></span></span>
<span></span></code></pre>

</div>

Using duckplyr is faster than using dplyr. Below we compare the same pipeline, "TPC-H benchmark query 1", with dplyr and duckplyr.

Here is the function that runs the pipeline with dplyr.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>tpch_dplyr</span> <span class='o'>&lt;-</span> <span class='kr'>function</span><span class='o'>(</span><span class='nv'>lineitem</span><span class='o'>)</span> <span class='o'>&#123;</span></span>
<span>  <span class='nv'>lineitem</span> <span class='o'>|&gt;</span></span>
<span>    <span class='nf'><a href='https://dplyr.tidyverse.org/reference/select.html'>select</a></span><span class='o'>(</span><span class='nv'>l_shipdate</span>, <span class='nv'>l_returnflag</span>, <span class='nv'>l_linestatus</span>, <span class='nv'>l_quantity</span>, <span class='nv'>l_extendedprice</span>, <span class='nv'>l_discount</span>, <span class='nv'>l_tax</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>    <span class='nf'><a href='https://dplyr.tidyverse.org/reference/filter.html'>filter</a></span><span class='o'>(</span><span class='nv'>l_shipdate</span> <span class='o'>&lt;=</span> <span class='o'>!</span><span class='o'>!</span><span class='nf'><a href='https://rdrr.io/r/base/as.Date.html'>as.Date</a></span><span class='o'>(</span><span class='s'>"1998-09-02"</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>    <span class='nf'><a href='https://dplyr.tidyverse.org/reference/select.html'>select</a></span><span class='o'>(</span><span class='nv'>l_returnflag</span>, <span class='nv'>l_linestatus</span>, <span class='nv'>l_quantity</span>, <span class='nv'>l_extendedprice</span>, <span class='nv'>l_discount</span>, <span class='nv'>l_tax</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>    <span class='nf'><a href='https://dplyr.tidyverse.org/reference/summarise.html'>summarise</a></span><span class='o'>(</span></span>
<span>      sum_qty <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/sum.html'>sum</a></span><span class='o'>(</span><span class='nv'>l_quantity</span><span class='o'>)</span>,</span>
<span>      sum_base_price <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/sum.html'>sum</a></span><span class='o'>(</span><span class='nv'>l_extendedprice</span><span class='o'>)</span>,</span>
<span>      sum_disc_price <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/sum.html'>sum</a></span><span class='o'>(</span><span class='nv'>l_extendedprice</span> <span class='o'>*</span> <span class='o'>(</span><span class='m'>1</span> <span class='o'>-</span> <span class='nv'>l_discount</span><span class='o'>)</span><span class='o'>)</span>,</span>
<span>      sum_charge <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/sum.html'>sum</a></span><span class='o'>(</span><span class='nv'>l_extendedprice</span> <span class='o'>*</span> <span class='o'>(</span><span class='m'>1</span> <span class='o'>-</span> <span class='nv'>l_discount</span><span class='o'>)</span> <span class='o'>*</span> <span class='o'>(</span><span class='m'>1</span> <span class='o'>+</span> <span class='nv'>l_tax</span><span class='o'>)</span><span class='o'>)</span>,</span>
<span>      avg_qty <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/mean.html'>mean</a></span><span class='o'>(</span><span class='nv'>l_quantity</span><span class='o'>)</span>,</span>
<span>      avg_price <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/mean.html'>mean</a></span><span class='o'>(</span><span class='nv'>l_extendedprice</span><span class='o'>)</span>,</span>
<span>      avg_disc <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/mean.html'>mean</a></span><span class='o'>(</span><span class='nv'>l_discount</span><span class='o'>)</span>,</span>
<span>      count_order <span class='o'>=</span> <span class='nf'><a href='https://dplyr.tidyverse.org/reference/context.html'>n</a></span><span class='o'>(</span><span class='o'>)</span>,</span>
<span>      .by <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='nv'>l_returnflag</span>, <span class='nv'>l_linestatus</span><span class='o'>)</span></span>
<span>    <span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>    <span class='nf'><a href='https://dplyr.tidyverse.org/reference/arrange.html'>arrange</a></span><span class='o'>(</span><span class='nv'>l_returnflag</span>, <span class='nv'>l_linestatus</span><span class='o'>)</span> </span>
<span><span class='o'>&#125;</span></span></code></pre>

</div>

Here is the function that runs it with duckplyr. The only differences are the lines [`duckplyr::as_duckdb_tibble()`](https://duckplyr.tidyverse.org/reference/duckdb_tibble.html) and [`collect()`](https://dplyr.tidyverse.org/reference/compute.html) (for ensuring materialization otherwise the comparison isn't fair).

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>tpch_duckplyr</span> <span class='o'>&lt;-</span> <span class='kr'>function</span><span class='o'>(</span><span class='nv'>lineitem</span><span class='o'>)</span> <span class='o'>&#123;</span></span>
<span>  <span class='nv'>lineitem</span> <span class='o'>|&gt;</span></span>
<span>    <span class='nf'>duckplyr</span><span class='nf'>::</span><span class='nf'><a href='https://duckplyr.tidyverse.org/reference/duckdb_tibble.html'>as_duckdb_tibble</a></span><span class='o'>(</span><span class='o'>)</span> <span class='o'>|&gt;</span> <span class='c'># difference 1/2</span></span>
<span>    <span class='nf'><a href='https://dplyr.tidyverse.org/reference/select.html'>select</a></span><span class='o'>(</span><span class='nv'>l_shipdate</span>, <span class='nv'>l_returnflag</span>, <span class='nv'>l_linestatus</span>, <span class='nv'>l_quantity</span>, <span class='nv'>l_extendedprice</span>, <span class='nv'>l_discount</span>, <span class='nv'>l_tax</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>    <span class='nf'><a href='https://dplyr.tidyverse.org/reference/filter.html'>filter</a></span><span class='o'>(</span><span class='nv'>l_shipdate</span> <span class='o'>&lt;=</span> <span class='o'>!</span><span class='o'>!</span><span class='nf'><a href='https://rdrr.io/r/base/as.Date.html'>as.Date</a></span><span class='o'>(</span><span class='s'>"1998-09-02"</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>    <span class='nf'><a href='https://dplyr.tidyverse.org/reference/select.html'>select</a></span><span class='o'>(</span><span class='nv'>l_returnflag</span>, <span class='nv'>l_linestatus</span>, <span class='nv'>l_quantity</span>, <span class='nv'>l_extendedprice</span>, <span class='nv'>l_discount</span>, <span class='nv'>l_tax</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>    <span class='nf'><a href='https://dplyr.tidyverse.org/reference/summarise.html'>summarise</a></span><span class='o'>(</span></span>
<span>      sum_qty <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/sum.html'>sum</a></span><span class='o'>(</span><span class='nv'>l_quantity</span><span class='o'>)</span>,</span>
<span>      sum_base_price <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/sum.html'>sum</a></span><span class='o'>(</span><span class='nv'>l_extendedprice</span><span class='o'>)</span>,</span>
<span>      sum_disc_price <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/sum.html'>sum</a></span><span class='o'>(</span><span class='nv'>l_extendedprice</span> <span class='o'>*</span> <span class='o'>(</span><span class='m'>1</span> <span class='o'>-</span> <span class='nv'>l_discount</span><span class='o'>)</span><span class='o'>)</span>,</span>
<span>      sum_charge <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/sum.html'>sum</a></span><span class='o'>(</span><span class='nv'>l_extendedprice</span> <span class='o'>*</span> <span class='o'>(</span><span class='m'>1</span> <span class='o'>-</span> <span class='nv'>l_discount</span><span class='o'>)</span> <span class='o'>*</span> <span class='o'>(</span><span class='m'>1</span> <span class='o'>+</span> <span class='nv'>l_tax</span><span class='o'>)</span><span class='o'>)</span>,</span>
<span>      avg_qty <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/mean.html'>mean</a></span><span class='o'>(</span><span class='nv'>l_quantity</span><span class='o'>)</span>,</span>
<span>      avg_price <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/mean.html'>mean</a></span><span class='o'>(</span><span class='nv'>l_extendedprice</span><span class='o'>)</span>,</span>
<span>      avg_disc <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/mean.html'>mean</a></span><span class='o'>(</span><span class='nv'>l_discount</span><span class='o'>)</span>,</span>
<span>      count_order <span class='o'>=</span> <span class='nf'><a href='https://dplyr.tidyverse.org/reference/context.html'>n</a></span><span class='o'>(</span><span class='o'>)</span>,</span>
<span>      .by <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='nv'>l_returnflag</span>, <span class='nv'>l_linestatus</span><span class='o'>)</span></span>
<span>    <span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>    <span class='nf'><a href='https://dplyr.tidyverse.org/reference/arrange.html'>arrange</a></span><span class='o'>(</span><span class='nv'>l_returnflag</span>, <span class='nv'>l_linestatus</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>    <span class='nf'><a href='https://dplyr.tidyverse.org/reference/compute.html'>collect</a></span><span class='o'>(</span><span class='o'>)</span> <span class='c'># difference 2/2</span></span>
<span><span class='o'>&#125;</span></span></code></pre>

</div>

And now we compare the two:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'>bench</span><span class='nf'>::</span><span class='nf'><a href='https://bench.r-lib.org/reference/mark.html'>mark</a></span><span class='o'>(</span></span>
<span>  <span class='nf'>tpch_dplyr</span><span class='o'>(</span><span class='nv'>lineitem</span><span class='o'>)</span>,</span>
<span>  <span class='nf'>tpch_duckplyr</span><span class='o'>(</span><span class='nv'>lineitem</span><span class='o'>)</span>,</span>
<span>  check <span class='o'>=</span> <span class='o'>~</span> <span class='nf'><a href='https://rdrr.io/r/base/all.equal.html'>all.equal</a></span><span class='o'>(</span><span class='nv'>.x</span>, <span class='nv'>.y</span>, tolerance <span class='o'>=</span> <span class='m'>1e-10</span><span class='o'>)</span></span>
<span><span class='o'>)</span></span>
<span><span class='c'>#&gt; Warning: Some expressions had a GC in every iteration; so filtering is disabled.</span></span>
<span></span><span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 2 × 6</span></span></span>
<span><span class='c'>#&gt;   expression                   min   median `itr/sec` mem_alloc `gc/sec`</span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;bch:expr&gt;</span>              <span style='color: #555555; font-style: italic;'>&lt;bch:tm&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;bch:tm&gt;</span>     <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;bch:byt&gt;</span>    <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span> tpch_dplyr(lineitem)       891ms    891ms      1.12   878.6MB     1.12</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span> tpch_duckplyr(lineitem)    270ms    271ms      3.69    94.2KB     0</span></span>
<span></span></code></pre>

</div>

In this benchmark, the pipeline run with duckplyr is clearly faster than the pipeline run with dplyr. Start using duckplyr today by attaching it and running your existing dplyr code. Many operations will be carried out with DuckDB, faster than with dplyr.

## Data larger than memory

For data larger than memory, duckplyr is a legitimate alternative to dtplyr and dbplyr.

With datasets that approach or surpass the size of your machine's RAM, you want:

-   input data in an efficient format, like Parquet files, which duckplyr allows thanks to its ingestion functions like [`read_parquet_duckdb()`](https://duckplyr.tidyverse.org/reference/read_file_duckdb.html).
-   efficient computation, which duckplyr provides via DuckDB's holistic optimization, without your having to adapt your code.
-   the output to not clutter all the memory, which duckplyr supports through two features:
    -   computation to files using [`compute_parquet()`](https://duckplyr.tidyverse.org/reference/compute_file.html) or [`compute_csv()`](https://duckplyr.tidyverse.org/reference/compute_file.html).
    -   the control of automatic materialization (collection of results into memory). You can disable automatic materialization completely or, as a compromise, disable it up to a certain output size. See [`vignette("prudence")`](https://duckplyr.tidyverse.org/articles/prudence.html) for details.

This workflow is fully supported by duckplyr. See [`vignette("large")`](https://duckplyr.tidyverse.org/articles/large.html) for a walkthrough and more details.

## Help us improve duckplyr!

Our goals for future development of duckplyr include:

-   Enabling users to provide [custom translations](https://github.com/tidyverse/duckplyr/issues/158) of dplyr functionality;
-   Making it easier to contribute code to duckplyr;
-   Supporting more dplyr and tidyr functionality natively in DuckDB.

You can help!

-   Please report any issues, especially regarding unknown incompabilities. See [`vignette("limits")`](https://duckplyr.tidyverse.org/articles/limits.html).
-   Contribute to the codebase after reading duckplyr's [contributing guide](https://duckplyr.tidyverse.org/CONTRIBUTING.html).
-   Turn on telemetry to help us hear about the most frequent fallbacks so we can prioritize working on the corresponding missing dplyr translation. See [`vignette("telemetry")`](https://duckplyr.tidyverse.org/articles/telemetry.html) and the [`duckplyr::fallback_sitrep()`](https://duckplyr.tidyverse.org/reference/fallback.html) function.

## Additional resources

Eager to learn more about duckplyr -- beside by trying it out yourself? The pkgdown website of duckplyr features several [articles](https://duckplyr.tidyverse.org/articles/). Furthermore, the blog post ["duckplyr: dplyr Powered by DuckDB"](https://duckdb.org/2024/04/02/duckplyr.html) by Hannes Mühleisen provides some context on duckplyr including its inner workings, as also seen in a [section](https://blog.r-hub.io/2025/02/13/lazy-meanings/#duckplyr-lazy-evaluation-and-prudence) of the R-hub blog post ["Lazy introduction to laziness in R"](https://blog.r-hub.io/2025/02/13/lazy-meanings/) by Maëlle Salmon, Athanasia Mo Mowinckel and Hannah Frick.

## Acknowledgements

A big thanks to all folks who filed issues, created PRs and generally helped to improve duckplyr and its workhorse [duckdb](https://r.duckdb.org/)!

[@adamschwing](https://github.com/adamschwing), [@alejandrohagan](https://github.com/alejandrohagan), [@andreranza](https://github.com/andreranza), [@apalacio9502](https://github.com/apalacio9502), [@apsteinmetz](https://github.com/apsteinmetz), [@barracuda156](https://github.com/barracuda156), [@beniaminogreen](https://github.com/beniaminogreen), [@bob-rietveld](https://github.com/bob-rietveld), [@brichards920](https://github.com/brichards920), [@cboettig](https://github.com/cboettig), [@davidjayjackson](https://github.com/davidjayjackson), [@DavisVaughan](https://github.com/DavisVaughan), [@Ed2uiz](https://github.com/Ed2uiz), [@eitsupi](https://github.com/eitsupi), [@era127](https://github.com/era127), [@etiennebacher](https://github.com/etiennebacher), [@eutwt](https://github.com/eutwt), [@fmichonneau](https://github.com/fmichonneau), [@hadley](https://github.com/hadley), [@hannes](https://github.com/hannes), [@hawkfish](https://github.com/hawkfish), [@IndrajeetPatil](https://github.com/IndrajeetPatil), [@JanSulavik](https://github.com/JanSulavik), [@JavOrraca](https://github.com/JavOrraca), [@jeroen](https://github.com/jeroen), [@jhk0530](https://github.com/jhk0530), [@joakimlinde](https://github.com/joakimlinde), [@JosiahParry](https://github.com/JosiahParry), [@kevbaer](https://github.com/kevbaer), [@larry77](https://github.com/larry77), [@lnkuiper](https://github.com/lnkuiper), [@lorenzwalthert](https://github.com/lorenzwalthert), [@lschneiderbauer](https://github.com/lschneiderbauer), [@luisDVA](https://github.com/luisDVA), [@math-mcshane](https://github.com/math-mcshane), [@meersel](https://github.com/meersel), [@multimeric](https://github.com/multimeric), [@mytarmail](https://github.com/mytarmail), [@nicki-dese](https://github.com/nicki-dese), [@PMassicotte](https://github.com/PMassicotte), [@prasundutta87](https://github.com/prasundutta87), [@rafapereirabr](https://github.com/rafapereirabr), [@Robinlovelace](https://github.com/Robinlovelace), [@romainfrancois](https://github.com/romainfrancois), [@sparrow925](https://github.com/sparrow925), [@stefanlinner](https://github.com/stefanlinner), [@szarnyasg](https://github.com/szarnyasg), [@thomasp85](https://github.com/thomasp85), [@TimTaylor](https://github.com/TimTaylor), [@Tmonster](https://github.com/Tmonster), [@toppyy](https://github.com/toppyy), [@wibeasley](https://github.com/wibeasley), [@yjunechoe](https://github.com/yjunechoe), [@ywhcuhk](https://github.com/ywhcuhk), [@zhjx19](https://github.com/zhjx19), [@ablack3](https://github.com/ablack3), [@actuarial-lonewolf](https://github.com/actuarial-lonewolf), [@ajdamico](https://github.com/ajdamico), [@amirmazmi](https://github.com/amirmazmi), [@anderson461123](https://github.com/anderson461123), [@andrewGhazi](https://github.com/andrewGhazi), [@Antonov548](https://github.com/Antonov548), [@appiehappie999](https://github.com/appiehappie999), [@ArthurAndrews](https://github.com/ArthurAndrews), [@arthurgailes](https://github.com/arthurgailes), [@babaknaimi](https://github.com/babaknaimi), [@bcaradima](https://github.com/bcaradima), [@bdforbes](https://github.com/bdforbes), [@bergest](https://github.com/bergest), [@bill-ash](https://github.com/bill-ash), [@BorgeJorge](https://github.com/BorgeJorge), [@brianmsm](https://github.com/brianmsm), [@chainsawriot](https://github.com/chainsawriot), [@ckarnes](https://github.com/ckarnes), [@clementlefevre](https://github.com/clementlefevre), [@cregouby](https://github.com/cregouby), [@cy-james-lee](https://github.com/cy-james-lee), [@daranzolin](https://github.com/daranzolin), [@david-cortes](https://github.com/david-cortes), [@DavZim](https://github.com/DavZim), [@denis-or](https://github.com/denis-or), [@developertest1234](https://github.com/developertest1234), [@dicorynia](https://github.com/dicorynia), [@dsolito](https://github.com/dsolito), [@e-kotov](https://github.com/e-kotov), [@EAVWing](https://github.com/EAVWing), [@eddelbuettel](https://github.com/eddelbuettel), [@edward-burn](https://github.com/edward-burn), [@elefeint](https://github.com/elefeint), [@eli-daniels](https://github.com/eli-daniels), [@elysabethpc](https://github.com/elysabethpc), [@erikvona](https://github.com/erikvona), [@florisvdh](https://github.com/florisvdh), [@gaborcsardi](https://github.com/gaborcsardi), [@ggrothendieck](https://github.com/ggrothendieck), [@hdmm3](https://github.com/hdmm3), [@hope-data-science](https://github.com/hope-data-science), [@IoannaNika](https://github.com/IoannaNika), [@jabrown-aepenergy](https://github.com/jabrown-aepenergy), [@JamesLMacAulay](https://github.com/JamesLMacAulay), [@jangorecki](https://github.com/jangorecki), [@javierlenzi](https://github.com/javierlenzi), [@Joe-Heffer-Shef](https://github.com/Joe-Heffer-Shef), [@kalibera](https://github.com/kalibera), [@lboller-pwbm](https://github.com/lboller-pwbm), [@lgaborini](https://github.com/lgaborini), [@m-muecke](https://github.com/m-muecke), [@meztez](https://github.com/meztez), [@mgirlich](https://github.com/mgirlich), [@mtmorgan](https://github.com/mtmorgan), [@nassuphis](https://github.com/nassuphis), [@nbc](https://github.com/nbc), [@olivroy](https://github.com/olivroy), [@pdet](https://github.com/pdet), [@phdjsep](https://github.com/phdjsep), [@pierre-lamarche](https://github.com/pierre-lamarche), [@r2evans](https://github.com/r2evans), [@ran-codes](https://github.com/ran-codes), [@rplsmn](https://github.com/rplsmn), [@Saarialho](https://github.com/Saarialho), [@SimonCoulombe](https://github.com/SimonCoulombe), [@tau31](https://github.com/tau31), [@thohan88](https://github.com/thohan88), [@ThomasSoeiro](https://github.com/ThomasSoeiro), [@timothygmitchell](https://github.com/timothygmitchell), [@vincentarelbundock](https://github.com/vincentarelbundock), [@VincentGuyader](https://github.com/VincentGuyader), [@wlangera](https://github.com/wlangera), [@xbasics](https://github.com/xbasics), [@xiaodaigh](https://github.com/xiaodaigh), [@xtimbeau](https://github.com/xtimbeau), [@yng-me](https://github.com/yng-me), [@Yousuf28](https://github.com/Yousuf28), [@yutannihilation](https://github.com/yutannihilation), and [@zcatav](https://github.com/zcatav)

Special thanks to Joe Thorley ([@joethorley](https://github.com/joethorley)) for help with choosing the right words.

[^1]: If you haven't heard about it, you can watch [Hannes Mühleisen's keynote at posit::conf(2024)](https://www.youtube.com/watch?v=GELhdezYmP0&feature=youtu.be).

