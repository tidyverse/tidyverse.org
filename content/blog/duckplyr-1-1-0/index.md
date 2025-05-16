---
output: hugodown::hugo_document

slug: duckplyr-1-1-0
title: duckplyr fully joins the tidyverse!
date: 2025-05-16
author: Kirill Müller and Maëlle Salmon
description: >
    duckplyr 1.1.0 is on CRAN!
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
rmd_hash: 8e189242d8daf867

---

We're very chuffed to announce the release of [duckplyr](https://duckplyr.tidyverse.org) 1.1.0. This is a new dplyr backend powered by [DuckDB](https://duckdb.org/), a fast in-memory analytical database system[^1]. It joins the rank of dplyr backends together with [dtplyr](https://dtplyr.tidyverse.org) and [dbplyr](https://dbplyr.tidyverse.org). You can install it from CRAN with:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://rdrr.io/r/utils/install.packages.html'>install.packages</a></span><span class='o'>(</span><span class='s'>"duckplyr"</span><span class='o'>)</span></span></code></pre>

</div>

This article shows how duckplyr can be used instead of dplyr with data of different size for faster computation, interact with existing code, explain how you can help improve the package, and share a selection of further resources.

## A drop-in replacement for dplyr

Imagine you have to wrangle a huge dataset. Here we generate one using the [data generator from the TPC-H benchmark](https://duckdb.org/2024/04/02/duckplyr.html#benchmark-tpc-h-q1).

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>lineitem_tbl</span> <span class='o'>&lt;-</span> <span class='nf'>duckdb</span><span class='nf'>:::</span><span class='nf'>sql</span><span class='o'>(</span><span class='s'>"INSTALL tpch; LOAD tpch; CALL dbgen(sf=1); FROM lineitem;"</span><span class='o'>)</span></span>
<span><span class='nv'>lineitem_tbl</span> <span class='o'>&lt;-</span> <span class='nf'>tibble</span><span class='nf'>::</span><span class='nf'><a href='https://tibble.tidyverse.org/reference/as_tibble.html'>as_tibble</a></span><span class='o'>(</span><span class='nv'>lineitem_tbl</span><span class='o'>)</span></span>
<span><span class='nf'>dplyr</span><span class='nf'>::</span><span class='nf'><a href='https://pillar.r-lib.org/reference/glimpse.html'>glimpse</a></span><span class='o'>(</span><span class='nv'>lineitem_tbl</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; Rows: 6,001,215</span></span>
<span><span class='c'>#&gt; Columns: 16</span></span>
<span><span class='c'>#&gt; $ <span style='font-weight: bold;'>l_orderkey     </span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> 1<span style='color: #555555;'>, </span>1<span style='color: #555555;'>, </span>1<span style='color: #555555;'>, </span>1<span style='color: #555555;'>, </span>1<span style='color: #555555;'>, </span>1<span style='color: #555555;'>, </span>2<span style='color: #555555;'>, </span>3<span style='color: #555555;'>, </span>3<span style='color: #555555;'>, </span>3<span style='color: #555555;'>, </span>3<span style='color: #555555;'>, </span>3<span style='color: #555555;'>, </span>3<span style='color: #555555;'>, </span>4<span style='color: #555555;'>, </span>5<span style='color: #555555;'>, </span>5<span style='color: #555555;'>, </span>5<span style='color: #555555;'>, </span>6<span style='color: #555555;'>, </span>…</span></span>
<span><span class='c'>#&gt; $ <span style='font-weight: bold;'>l_partkey      </span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> 155190<span style='color: #555555;'>, </span>67310<span style='color: #555555;'>, </span>63700<span style='color: #555555;'>, </span>2132<span style='color: #555555;'>, </span>24027<span style='color: #555555;'>, </span>15635<span style='color: #555555;'>, </span>106170<span style='color: #555555;'>, </span>4297…</span></span>
<span><span class='c'>#&gt; $ <span style='font-weight: bold;'>l_suppkey      </span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> 7706<span style='color: #555555;'>, </span>7311<span style='color: #555555;'>, </span>3701<span style='color: #555555;'>, </span>4633<span style='color: #555555;'>, </span>1534<span style='color: #555555;'>, </span>638<span style='color: #555555;'>, </span>1191<span style='color: #555555;'>, </span>1798<span style='color: #555555;'>, </span>6540<span style='color: #555555;'>, </span>3…</span></span>
<span><span class='c'>#&gt; $ <span style='font-weight: bold;'>l_linenumber   </span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> 1<span style='color: #555555;'>, </span>2<span style='color: #555555;'>, </span>3<span style='color: #555555;'>, </span>4<span style='color: #555555;'>, </span>5<span style='color: #555555;'>, </span>6<span style='color: #555555;'>, </span>1<span style='color: #555555;'>, </span>1<span style='color: #555555;'>, </span>2<span style='color: #555555;'>, </span>3<span style='color: #555555;'>, </span>4<span style='color: #555555;'>, </span>5<span style='color: #555555;'>, </span>6<span style='color: #555555;'>, </span>1<span style='color: #555555;'>, </span>1<span style='color: #555555;'>, </span>2<span style='color: #555555;'>, </span>3<span style='color: #555555;'>, </span>1<span style='color: #555555;'>, </span>…</span></span>
<span><span class='c'>#&gt; $ <span style='font-weight: bold;'>l_quantity     </span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> 17<span style='color: #555555;'>, </span>36<span style='color: #555555;'>, </span>8<span style='color: #555555;'>, </span>28<span style='color: #555555;'>, </span>24<span style='color: #555555;'>, </span>32<span style='color: #555555;'>, </span>38<span style='color: #555555;'>, </span>45<span style='color: #555555;'>, </span>49<span style='color: #555555;'>, </span>27<span style='color: #555555;'>, </span>2<span style='color: #555555;'>, </span>28<span style='color: #555555;'>, </span>26<span style='color: #555555;'>, </span>30<span style='color: #555555;'>, </span>…</span></span>
<span><span class='c'>#&gt; $ <span style='font-weight: bold;'>l_extendedprice</span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> 21168.23<span style='color: #555555;'>, </span>45983.16<span style='color: #555555;'>, </span>13309.60<span style='color: #555555;'>, </span>28955.64<span style='color: #555555;'>, </span>22824.48<span style='color: #555555;'>, </span>4962…</span></span>
<span><span class='c'>#&gt; $ <span style='font-weight: bold;'>l_discount     </span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> 0.04<span style='color: #555555;'>, </span>0.09<span style='color: #555555;'>, </span>0.10<span style='color: #555555;'>, </span>0.09<span style='color: #555555;'>, </span>0.10<span style='color: #555555;'>, </span>0.07<span style='color: #555555;'>, </span>0.00<span style='color: #555555;'>, </span>0.06<span style='color: #555555;'>, </span>0.10<span style='color: #555555;'>, </span>…</span></span>
<span><span class='c'>#&gt; $ <span style='font-weight: bold;'>l_tax          </span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> 0.02<span style='color: #555555;'>, </span>0.06<span style='color: #555555;'>, </span>0.02<span style='color: #555555;'>, </span>0.06<span style='color: #555555;'>, </span>0.04<span style='color: #555555;'>, </span>0.02<span style='color: #555555;'>, </span>0.05<span style='color: #555555;'>, </span>0.00<span style='color: #555555;'>, </span>0.00<span style='color: #555555;'>, </span>…</span></span>
<span><span class='c'>#&gt; $ <span style='font-weight: bold;'>l_returnflag   </span> <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span> "N"<span style='color: #555555;'>, </span>"N"<span style='color: #555555;'>, </span>"N"<span style='color: #555555;'>, </span>"N"<span style='color: #555555;'>, </span>"N"<span style='color: #555555;'>, </span>"N"<span style='color: #555555;'>, </span>"N"<span style='color: #555555;'>, </span>"R"<span style='color: #555555;'>, </span>"R"<span style='color: #555555;'>, </span>"A"<span style='color: #555555;'>, </span>"A"<span style='color: #555555;'>,</span>…</span></span>
<span><span class='c'>#&gt; $ <span style='font-weight: bold;'>l_linestatus   </span> <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span> "O"<span style='color: #555555;'>, </span>"O"<span style='color: #555555;'>, </span>"O"<span style='color: #555555;'>, </span>"O"<span style='color: #555555;'>, </span>"O"<span style='color: #555555;'>, </span>"O"<span style='color: #555555;'>, </span>"O"<span style='color: #555555;'>, </span>"F"<span style='color: #555555;'>, </span>"F"<span style='color: #555555;'>, </span>"F"<span style='color: #555555;'>, </span>"F"<span style='color: #555555;'>,</span>…</span></span>
<span><span class='c'>#&gt; $ <span style='font-weight: bold;'>l_shipdate     </span> <span style='color: #555555; font-style: italic;'>&lt;date&gt;</span> 1996-03-13<span style='color: #555555;'>, </span>1996-04-12<span style='color: #555555;'>, </span>1996-01-29<span style='color: #555555;'>, </span>1996-04-21<span style='color: #555555;'>, </span>1996-…</span></span>
<span><span class='c'>#&gt; $ <span style='font-weight: bold;'>l_commitdate   </span> <span style='color: #555555; font-style: italic;'>&lt;date&gt;</span> 1996-02-12<span style='color: #555555;'>, </span>1996-02-28<span style='color: #555555;'>, </span>1996-03-05<span style='color: #555555;'>, </span>1996-03-30<span style='color: #555555;'>, </span>1996-…</span></span>
<span><span class='c'>#&gt; $ <span style='font-weight: bold;'>l_receiptdate  </span> <span style='color: #555555; font-style: italic;'>&lt;date&gt;</span> 1996-03-22<span style='color: #555555;'>, </span>1996-04-20<span style='color: #555555;'>, </span>1996-01-31<span style='color: #555555;'>, </span>1996-05-16<span style='color: #555555;'>, </span>1996-…</span></span>
<span><span class='c'>#&gt; $ <span style='font-weight: bold;'>l_shipinstruct </span> <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span> "DELIVER IN PERSON"<span style='color: #555555;'>, </span>"TAKE BACK RETURN"<span style='color: #555555;'>, </span>"TAKE BACK RE…</span></span>
<span><span class='c'>#&gt; $ <span style='font-weight: bold;'>l_shipmode     </span> <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span> "TRUCK"<span style='color: #555555;'>, </span>"MAIL"<span style='color: #555555;'>, </span>"REG AIR"<span style='color: #555555;'>, </span>"AIR"<span style='color: #555555;'>, </span>"FOB"<span style='color: #555555;'>, </span>"MAIL"<span style='color: #555555;'>, </span>"RAI…</span></span>
<span><span class='c'>#&gt; $ <span style='font-weight: bold;'>l_comment      </span> <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span> "to beans x-ray carefull"<span style='color: #555555;'>, </span>" according to the final fo…</span></span>
<span></span></code></pre>

</div>

We could transform the data using dplyr but we could also transform it using a tool that'll scale well to ever larger data: duckplyr. The duckplyr package is a *drop-in replacement for dplyr* that uses *DuckDB for speed*. You can simply *drop* duckplyr into your pipeline by loading it, then computations will be efficiently carried out by DuckDB.

Below, we express the standard "TPC-H benchmark query 1" in dplyr syntax, but execute it with duckplyr. We use a function because this code is reused throughout the article.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://conflicted.r-lib.org/'>conflicted</a></span><span class='o'>)</span></span>
<span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://duckplyr.tidyverse.org'>duckplyr</a></span><span class='o'>)</span></span>
<span><span class='c'>#&gt; Loading required package: dplyr</span></span>
<span></span><span><span class='c'>#&gt; <span style='color: #00BB00;'>✔</span> Overwriting <span style='color: #0000BB;'>dplyr</span> methods with <span style='color: #0000BB;'>duckplyr</span> methods.</span></span>
<span><span class='c'>#&gt; <span style='color: #00BBBB;'>ℹ</span> Turn off with `duckplyr::methods_restore()`.</span></span>
<span></span><span><span class='nf'><a href='https://conflicted.r-lib.org/reference/conflict_prefer.html'>conflict_prefer</a></span><span class='o'>(</span><span class='s'>"filter"</span>, <span class='s'>"dplyr"</span>, quiet <span class='o'>=</span> <span class='kc'>TRUE</span><span class='o'>)</span></span>
<span></span>
<span><span class='nv'>tpch_dplyr</span> <span class='o'>&lt;-</span> <span class='kr'>function</span><span class='o'>(</span><span class='nv'>lineitem</span><span class='o'>)</span> <span class='o'>&#123;</span></span>
<span>  <span class='nv'>lineitem</span> <span class='o'>|&gt;</span></span>
<span>    <span class='nf'><a href='https://dplyr.tidyverse.org/reference/filter.html'>filter</a></span><span class='o'>(</span><span class='nv'>l_shipdate</span> <span class='o'>&lt;=</span> <span class='o'>!</span><span class='o'>!</span><span class='nf'><a href='https://rdrr.io/r/base/as.Date.html'>as.Date</a></span><span class='o'>(</span><span class='s'>"1998-09-02"</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
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
<span>    <span class='nf'><a href='https://dplyr.tidyverse.org/reference/arrange.html'>arrange</a></span><span class='o'>(</span><span class='nv'>l_returnflag</span>, <span class='nv'>l_linestatus</span><span class='o'>)</span></span>
<span><span class='o'>&#125;</span></span>
<span></span>
<span><span class='nf'>tpch_dplyr</span><span class='o'>(</span><span class='nv'>lineitem_tbl</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 4 × 10</span></span></span>
<span><span class='c'>#&gt;   <span style='font-weight: bold;'>l_returnflag</span> <span style='font-weight: bold;'>l_linestatus</span>  <span style='font-weight: bold;'>sum_qty</span> <span style='font-weight: bold;'>sum_base_price</span> <span style='font-weight: bold;'>sum_disc_price</span>    <span style='font-weight: bold;'>sum_charge</span></span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>        <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>           <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>          <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>          <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>         <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span> A            F            37<span style='text-decoration: underline;'>734</span>107   <span style='text-decoration: underline;'>56</span>586<span style='text-decoration: underline;'>554</span>401.   <span style='text-decoration: underline;'>53</span>758<span style='text-decoration: underline;'>257</span>135.  <span style='text-decoration: underline;'>55</span>909<span style='text-decoration: underline;'>065</span>223.</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span> N            F              <span style='text-decoration: underline;'>991</span>417    <span style='text-decoration: underline;'>1</span>487<span style='text-decoration: underline;'>504</span>710.    <span style='text-decoration: underline;'>1</span>413<span style='text-decoration: underline;'>082</span>168.   <span style='text-decoration: underline;'>1</span>469<span style='text-decoration: underline;'>649</span>223.</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>3</span> N            O            74<span style='text-decoration: underline;'>476</span>040  <span style='text-decoration: underline;'>111</span>701<span style='text-decoration: underline;'>729</span>698.  <span style='text-decoration: underline;'>106</span>118<span style='text-decoration: underline;'>230</span>308. <span style='text-decoration: underline;'>110</span>367<span style='text-decoration: underline;'>043</span>872.</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>4</span> R            F            37<span style='text-decoration: underline;'>719</span>753   <span style='text-decoration: underline;'>56</span>568<span style='text-decoration: underline;'>041</span>381.   <span style='text-decoration: underline;'>53</span>741<span style='text-decoration: underline;'>292</span>685.  <span style='text-decoration: underline;'>55</span>889<span style='text-decoration: underline;'>619</span>120.</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># ℹ 4 more variables: </span><span style='color: #555555; font-weight: bold;'>avg_qty</span><span style='color: #555555;'> &lt;dbl&gt;, </span><span style='color: #555555; font-weight: bold;'>avg_price</span><span style='color: #555555;'> &lt;dbl&gt;, </span><span style='color: #555555; font-weight: bold;'>avg_disc</span><span style='color: #555555;'> &lt;dbl&gt;,</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>#   </span><span style='color: #555555; font-weight: bold;'>count_order</span><span style='color: #555555;'> &lt;int&gt;</span></span></span>
<span></span></code></pre>

</div>

Like with other dplyr backends like dtplyr and dbplyr, duckplyr allows you to get faster results without learning a different syntax. Unlike other dplyr backends, duckplyr does not require you to change existing code or learn specific idiosyncrasies. Not only is the syntax the same, the semantics are too!

Start using duckplyr today by attaching it and running your existing dplyr code. Many operations will be carried out with DuckDB, faster than with dplyr. The duckplyr package is fully compatible with dplyr: if an operation cannot be carried out with DuckDB, it is automatically outsourced to dplyr. Over time, we expect fewer and fewer fallbacks to dplyr to be needed.

## How to use duckplyr

To *replace* dplyr with duckplyr, you can:

-   Load duckplyr and then keep your pipeline as is. Calling [`library(duckplyr)`](https://duckplyr.tidyverse.org) overwrites dplyr methods, enabling duckplyr for the entire session no matter how data.frames are created. This is shown in the example above.

-   Create individual "duck frames" using *conversion functions* like [`duckdb_tibble()`](https://duckplyr.tidyverse.org/reference/duckdb_tibble.html) or [`as_duckdb_tibble()`](https://duckplyr.tidyverse.org/reference/duckdb_tibble.html), or *ingestion functions* like [`read_csv_duckdb()`](https://duckplyr.tidyverse.org/reference/read_csv_duckdb.html).

In both cases, the data manipulation pipeline uses the exact same syntax as a dplyr pipeline, with the exact same semantics. The duckplyr package performs the computation using DuckDB.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>out</span> <span class='o'>&lt;-</span> <span class='nv'>lineitem_tbl</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'>duckplyr</span><span class='nf'>::</span><span class='nf'><a href='https://duckplyr.tidyverse.org/reference/duckdb_tibble.html'>as_duckdb_tibble</a></span><span class='o'>(</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'>tpch_dplyr</span><span class='o'>(</span><span class='o'>)</span></span>
<span></span>
<span><span class='nv'>out</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A duckplyr data frame: 10 variables</span></span></span>
<span><span class='c'>#&gt;   <span style='font-weight: bold;'>l_returnflag</span> <span style='font-weight: bold;'>l_linestatus</span>  <span style='font-weight: bold;'>sum_qty</span> <span style='font-weight: bold;'>sum_base_price</span> <span style='font-weight: bold;'>sum_disc_price</span>    <span style='font-weight: bold;'>sum_charge</span></span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>        <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>           <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>          <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>          <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>         <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span> A            F            37<span style='text-decoration: underline;'>734</span>107   <span style='text-decoration: underline;'>56</span>586<span style='text-decoration: underline;'>554</span>401.   <span style='text-decoration: underline;'>53</span>758<span style='text-decoration: underline;'>257</span>135.  <span style='text-decoration: underline;'>55</span>909<span style='text-decoration: underline;'>065</span>223.</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span> N            F              <span style='text-decoration: underline;'>991</span>417    <span style='text-decoration: underline;'>1</span>487<span style='text-decoration: underline;'>504</span>710.    <span style='text-decoration: underline;'>1</span>413<span style='text-decoration: underline;'>082</span>168.   <span style='text-decoration: underline;'>1</span>469<span style='text-decoration: underline;'>649</span>223.</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>3</span> N            O            74<span style='text-decoration: underline;'>476</span>040  <span style='text-decoration: underline;'>111</span>701<span style='text-decoration: underline;'>729</span>698.  <span style='text-decoration: underline;'>106</span>118<span style='text-decoration: underline;'>230</span>308. <span style='text-decoration: underline;'>110</span>367<span style='text-decoration: underline;'>043</span>872.</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>4</span> R            F            37<span style='text-decoration: underline;'>719</span>753   <span style='text-decoration: underline;'>56</span>568<span style='text-decoration: underline;'>041</span>381.   <span style='text-decoration: underline;'>53</span>741<span style='text-decoration: underline;'>292</span>685.  <span style='text-decoration: underline;'>55</span>889<span style='text-decoration: underline;'>619</span>120.</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># ℹ 4 more variables: </span><span style='color: #555555; font-weight: bold;'>avg_qty</span><span style='color: #555555;'> &lt;dbl&gt;, </span><span style='color: #555555; font-weight: bold;'>avg_price</span><span style='color: #555555;'> &lt;dbl&gt;, </span><span style='color: #555555; font-weight: bold;'>avg_disc</span><span style='color: #555555;'> &lt;dbl&gt;,</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>#   </span><span style='color: #555555; font-weight: bold;'>count_order</span><span style='color: #555555;'> &lt;int&gt;</span></span></span>
<span></span></code></pre>

</div>

For programming, the resulting object is indistinguishable from a regular tibble, except for the additional class.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://rdrr.io/r/base/typeof.html'>typeof</a></span><span class='o'>(</span><span class='nv'>out</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; [1] "list"</span></span>
<span></span><span><span class='nf'><a href='https://rdrr.io/r/base/class.html'>class</a></span><span class='o'>(</span><span class='nv'>out</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; [1] "duckplyr_df" "tbl_df"      "tbl"         "data.frame"</span></span>
<span></span><span><span class='nv'>out</span><span class='o'>$</span><span class='nv'>count_order</span></span>
<span><span class='c'>#&gt; [1] 1478493   38854 2920374 1478870</span></span>
<span></span></code></pre>

</div>

The result could also be computed to a file.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>csv_file</span> <span class='o'>&lt;-</span> <span class='nf'>withr</span><span class='nf'>::</span><span class='nf'><a href='https://withr.r-lib.org/reference/with_tempfile.html'>local_tempfile</a></span><span class='o'>(</span><span class='o'>)</span></span>
<span><span class='nf'><a href='https://duckplyr.tidyverse.org/reference/compute_csv.html'>compute_csv</a></span><span class='o'>(</span><span class='nv'>out</span>, <span class='nv'>csv_file</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A duckplyr data frame: 10 variables</span></span></span>
<span><span class='c'>#&gt;   <span style='font-weight: bold;'>l_returnflag</span> <span style='font-weight: bold;'>l_linestatus</span>  <span style='font-weight: bold;'>sum_qty</span> <span style='font-weight: bold;'>sum_base_price</span> <span style='font-weight: bold;'>sum_disc_price</span>    <span style='font-weight: bold;'>sum_charge</span></span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>        <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>           <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>          <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>          <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>         <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span> A            F            37<span style='text-decoration: underline;'>734</span>107   <span style='text-decoration: underline;'>56</span>586<span style='text-decoration: underline;'>554</span>401.   <span style='text-decoration: underline;'>53</span>758<span style='text-decoration: underline;'>257</span>135.  <span style='text-decoration: underline;'>55</span>909<span style='text-decoration: underline;'>065</span>223.</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span> N            F              <span style='text-decoration: underline;'>991</span>417    <span style='text-decoration: underline;'>1</span>487<span style='text-decoration: underline;'>504</span>710.    <span style='text-decoration: underline;'>1</span>413<span style='text-decoration: underline;'>082</span>168.   <span style='text-decoration: underline;'>1</span>469<span style='text-decoration: underline;'>649</span>223.</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>3</span> N            O            74<span style='text-decoration: underline;'>476</span>040  <span style='text-decoration: underline;'>111</span>701<span style='text-decoration: underline;'>729</span>698.  <span style='text-decoration: underline;'>106</span>118<span style='text-decoration: underline;'>230</span>308. <span style='text-decoration: underline;'>110</span>367<span style='text-decoration: underline;'>043</span>872.</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>4</span> R            F            37<span style='text-decoration: underline;'>719</span>753   <span style='text-decoration: underline;'>56</span>568<span style='text-decoration: underline;'>041</span>381.   <span style='text-decoration: underline;'>53</span>741<span style='text-decoration: underline;'>292</span>685.  <span style='text-decoration: underline;'>55</span>889<span style='text-decoration: underline;'>619</span>120.</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># ℹ 4 more variables: </span><span style='color: #555555; font-weight: bold;'>avg_qty</span><span style='color: #555555;'> &lt;dbl&gt;, </span><span style='color: #555555; font-weight: bold;'>avg_price</span><span style='color: #555555;'> &lt;dbl&gt;, </span><span style='color: #555555; font-weight: bold;'>avg_disc</span><span style='color: #555555;'> &lt;dbl&gt;,</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>#   </span><span style='color: #555555; font-weight: bold;'>count_order</span><span style='color: #555555;'> &lt;dbl&gt;</span></span></span>
<span></span><span><span class='nf'>fs</span><span class='nf'>::</span><span class='nf'><a href='https://fs.r-lib.org/reference/file_info.html'>file_size</a></span><span class='o'>(</span><span class='nv'>csv_file</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; 644</span></span>
<span></span></code></pre>

</div>

Operations not yet supported by duckplyr are automatically outsourced to dplyr. For instance, filtering on grouped data is not supported yet, still it works thanks to the fallback mechanism. By default, the fallback is silent. Here, we make it visible by setting an environment variable.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://rdrr.io/r/base/Sys.setenv.html'>Sys.setenv</a></span><span class='o'>(</span>DUCKPLYR_FALLBACK_INFO <span class='o'>=</span> <span class='kc'>TRUE</span><span class='o'>)</span></span>
<span></span>
<span><span class='nv'>lineitem_tbl</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'>duckplyr</span><span class='nf'>::</span><span class='nf'><a href='https://duckplyr.tidyverse.org/reference/duckdb_tibble.html'>as_duckdb_tibble</a></span><span class='o'>(</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/filter.html'>filter</a></span><span class='o'>(</span><span class='nv'>l_quantity</span> <span class='o'>==</span> <span class='nf'><a href='https://rdrr.io/r/base/Extremes.html'>max</a></span><span class='o'>(</span><span class='nv'>l_quantity</span><span class='o'>)</span>, .by <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='nv'>l_returnflag</span>, <span class='nv'>l_linestatus</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; Cannot process duckplyr query with DuckDB, falling back to dplyr.</span></span>
<span><span class='c'>#&gt; <span style='color: #0000BB;'>ℹ</span> `filter(.by = ...)` not implemented, try `mutate(.by = ...)` followed by a simple `filter()`.</span></span>
<span></span><span><span class='c'>#&gt; <span style='color: #555555;'># A duckplyr data frame: 16 variables</span></span></span>
<span><span class='c'>#&gt;    <span style='font-weight: bold;'>l_orderkey</span> <span style='font-weight: bold;'>l_partkey</span> <span style='font-weight: bold;'>l_suppkey</span> <span style='font-weight: bold;'>l_linenumber</span> <span style='font-weight: bold;'>l_quantity</span> <span style='font-weight: bold;'>l_extendedprice</span></span></span>
<span><span class='c'>#&gt;         <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>     <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>     <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>        <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>      <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>           <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 1</span>          5     <span style='text-decoration: underline;'>37</span>531        35            3         50          <span style='text-decoration: underline;'>73</span>426.</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 2</span>        131     <span style='text-decoration: underline;'>44</span>255      <span style='text-decoration: underline;'>9</span>264            2         50          <span style='text-decoration: underline;'>59</span>962.</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 3</span>        199    <span style='text-decoration: underline;'>132</span>072      <span style='text-decoration: underline;'>9</span>612            1         50          <span style='text-decoration: underline;'>55</span>204.</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 4</span>        231    <span style='text-decoration: underline;'>198</span>124       644            3         50          <span style='text-decoration: underline;'>61</span>106 </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 5</span>        260    <span style='text-decoration: underline;'>155</span>887      <span style='text-decoration: underline;'>5</span>888            1         50          <span style='text-decoration: underline;'>97</span>144 </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 6</span>        263    <span style='text-decoration: underline;'>142</span>891       434            3         50          <span style='text-decoration: underline;'>96</span>694.</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 7</span>        323    <span style='text-decoration: underline;'>163</span>628      <span style='text-decoration: underline;'>1</span>177            1         50          <span style='text-decoration: underline;'>84</span>581 </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 8</span>        354     <span style='text-decoration: underline;'>58</span>125      <span style='text-decoration: underline;'>8</span>126            3         50          <span style='text-decoration: underline;'>54</span>156 </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 9</span>        484    <span style='text-decoration: underline;'>183</span>351      <span style='text-decoration: underline;'>5</span>870            3         50          <span style='text-decoration: underline;'>71</span>718.</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>10</span>        485    <span style='text-decoration: underline;'>149</span>523      <span style='text-decoration: underline;'>9</span>524            1         50          <span style='text-decoration: underline;'>78</span>626 </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># ℹ more rows</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># ℹ 10 more variables: </span><span style='color: #555555; font-weight: bold;'>l_discount</span><span style='color: #555555;'> &lt;dbl&gt;, </span><span style='color: #555555; font-weight: bold;'>l_tax</span><span style='color: #555555;'> &lt;dbl&gt;, </span><span style='color: #555555; font-weight: bold;'>l_returnflag</span><span style='color: #555555;'> &lt;chr&gt;,</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>#   </span><span style='color: #555555; font-weight: bold;'>l_linestatus</span><span style='color: #555555;'> &lt;chr&gt;, </span><span style='color: #555555; font-weight: bold;'>l_shipdate</span><span style='color: #555555;'> &lt;date&gt;, </span><span style='color: #555555; font-weight: bold;'>l_commitdate</span><span style='color: #555555;'> &lt;date&gt;,</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>#   </span><span style='color: #555555; font-weight: bold;'>l_receiptdate</span><span style='color: #555555;'> &lt;date&gt;, </span><span style='color: #555555; font-weight: bold;'>l_shipinstruct</span><span style='color: #555555;'> &lt;chr&gt;, </span><span style='color: #555555; font-weight: bold;'>l_shipmode</span><span style='color: #555555;'> &lt;chr&gt;,</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>#   </span><span style='color: #555555; font-weight: bold;'>l_comment</span><span style='color: #555555;'> &lt;chr&gt;</span></span></span>
<span></span></code></pre>

</div>

## Benchmark

duckplyr is often much faster than dplyr. The comparison below is done in a fresh R session where dplyr is attached but duckplyr is not.

``` r
# Restart R
library(dplyr)

tpch_dplyr <- function ...
```

We use `tpch_dplyr()` as defined above to run the query with dplyr. The function that runs it with duckplyr only wraps the input data in a duck frame and forwards it to the dplyr function. The [`collect()`](https://dplyr.tidyverse.org/reference/compute.html) at the end is required only for this benchmark to ensure fairness.[^2]

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>tpch_duckplyr</span> <span class='o'>&lt;-</span> <span class='kr'>function</span><span class='o'>(</span><span class='nv'>lineitem</span><span class='o'>)</span> <span class='o'>&#123;</span></span>
<span>  <span class='nv'>lineitem</span> <span class='o'>|&gt;</span></span>
<span>    <span class='nf'>duckplyr</span><span class='nf'>::</span><span class='nf'><a href='https://duckplyr.tidyverse.org/reference/duckdb_tibble.html'>as_duckdb_tibble</a></span><span class='o'>(</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>    <span class='nf'>tpch_dplyr</span><span class='o'>(</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>    <span class='nf'><a href='https://dplyr.tidyverse.org/reference/compute.html'>collect</a></span><span class='o'>(</span><span class='o'>)</span></span>
<span><span class='o'>&#125;</span></span></code></pre>

</div>

And now we compare the two:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'>bench</span><span class='nf'>::</span><span class='nf'><a href='https://bench.r-lib.org/reference/mark.html'>mark</a></span><span class='o'>(</span></span>
<span>  <span class='nf'>tpch_dplyr</span><span class='o'>(</span><span class='nv'>lineitem_tbl</span><span class='o'>)</span>,</span>
<span>  <span class='nf'>tpch_duckplyr</span><span class='o'>(</span><span class='nv'>lineitem_tbl</span><span class='o'>)</span>,</span>
<span>  check <span class='o'>=</span> <span class='o'>~</span> <span class='nf'><a href='https://rdrr.io/r/base/all.equal.html'>all.equal</a></span><span class='o'>(</span><span class='nv'>.x</span>, <span class='nv'>.y</span>, tolerance <span class='o'>=</span> <span class='m'>1e-10</span><span class='o'>)</span></span>
<span><span class='o'>)</span></span>
<span><span class='c'>#&gt; Warning: Some expressions had a GC in every iteration; so filtering is disabled.</span></span>
<span></span><span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 2 × 6</span></span></span>
<span><span class='c'>#&gt;   <span style='font-weight: bold;'>expression</span>                       <span style='font-weight: bold;'>min</span>   <span style='font-weight: bold;'>median</span> <span style='font-weight: bold;'>`itr/sec`</span> <span style='font-weight: bold;'>mem_alloc</span> <span style='font-weight: bold;'>`gc/sec`</span></span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;bch:expr&gt;</span>                  <span style='color: #555555; font-style: italic;'>&lt;bch:tm&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;bch:tm&gt;</span>     <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;bch:byt&gt;</span>    <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span> tpch_dplyr(lineitem_tbl)        1.1s     1.1s     0.913    1.25GB     2.74</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span> tpch_duckplyr(lineitem_tbl)  103.5ms  107.1ms     9.24   315.12KB     0</span></span>
<span></span></code></pre>

</div>

In this example, the pipeline run with duckplyr is clearly faster than the pipeline run with dplyr. It also appears to use much less memory, but this is misleading: DuckDB uses memory outside of R's memory management, so the memory usage is not visible to R.

## Data larger than memory

With datasets that approach or surpass the size of your machine's RAM, you want:

-   input data in an efficient format, like Parquet files, which duckplyr allows thanks to its ingestion functions like [`read_parquet_duckdb()`](https://duckplyr.tidyverse.org/reference/read_parquet_duckdb.html);
-   efficient computation, which duckplyr provides via DuckDB's holistic optimization, without having to adapt your code;
-   large results to not clutter your memory by dumping them to files using [`compute_parquet()`](https://duckplyr.tidyverse.org/reference/compute_parquet.html) or [`compute_csv()`](https://duckplyr.tidyverse.org/reference/compute_csv.html);
-   small results processed seamlessly with dplyr, using all verbs and functions.

This workflow is fully supported by duckplyr. See [`vignette("large")`](https://duckplyr.tidyverse.org/articles/large.html) for a walkthrough and more details.

For your existing dbplyr code, the new [`as_tbl()`](https://duckplyr.tidyverse.org/reference/as_tbl.html) function allows you to convert a duckplyr tibble to a dbplyr lazy table. This allows you to seamlessly interact with existing code that might use inline SQL or other dbplyr functionality. With [`as_duckdb_tibble()`](https://duckplyr.tidyverse.org/reference/duckdb_tibble.html), you can convert a dbplyr lazy table to a duckplyr tibble. Both operations work without intermediate materialization.

Another way to leverage the potential of DuckDB is the new `dd$` qualifier. Functions with this prefix will not be translated at all and passed through directly to DuckDB. For example:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://duckplyr.tidyverse.org/reference/duckdb_tibble.html'>duckdb_tibble</a></span><span class='o'>(</span>a <span class='o'>=</span> <span class='s'>"dbplyr"</span>, b <span class='o'>=</span> <span class='s'>"duckplyr"</span><span class='o'>)</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/mutate.html'>mutate</a></span><span class='o'>(</span>c <span class='o'>=</span> <span class='nv'>dd</span><span class='o'>$</span><span class='nf'>damerau_levenshtein</span><span class='o'>(</span><span class='nv'>a</span>, <span class='nv'>b</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A duckplyr data frame: 3 variables</span></span></span>
<span><span class='c'>#&gt;   <span style='font-weight: bold;'>a</span>      <span style='font-weight: bold;'>b</span>            <span style='font-weight: bold;'>c</span></span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>  <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>    <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span> dbplyr duckplyr     3</span></span>
<span></span></code></pre>

</div>

See the new [`vignette("duckdb")`](https://duckplyr.tidyverse.org/articles/duckdb.html) for more information on these features.

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

[^2]: If omitted, the results would be unchanged but the measurements would be wrong. The computation would then be triggered by the check. See `vignette("prudence")` for details.

