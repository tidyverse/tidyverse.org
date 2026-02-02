---
output: hugodown::hugo_document

slug: nanoparquet-0-4-0
title: nanoparquet 0.4.0
date: 2025-01-28
author: Gábor Csárdi
description: >
    nanoparquet 0.4.0 comes with a new and much faster `read_parquet()`,
    configurable type mappings in `write_parquet()`, and a new
    `append_parquet()`.

photo:
  url: https://www.pexels.com/photo/person-running-in-the-hallway-796545/
  author: Michael Foster

# one of: "deep-dive", "learn", "package", "programming", "roundup", or "other"
categories: [package]
tags: [parquet]
rmd_hash: 9b54a2af59460367

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

We're thrilled to announce the release of [nanoparquet](https://nanoparquet.r-lib.org/) 0.4.0. nanoparquet is an R package that reads and writes Parquet files.

You can install it from CRAN with:

``` r
install.packages("nanoparquet")
```

This blog post will show the most important new features of nanoparquet 0.4.0: You can see a full list of changes in the [release notes](https://nanoparquet.r-lib.org/news/index.html#nanoparquet-040).

## Brand new `read_parquet()`

nanoparquet 0.4.0 comes with a completely rewritten Parquet reader. The new version has an architecture that is easier to embed into R, and facilitates fantastic new features, like [`append_parquet()`](https://nanoparquet.r-lib.org/reference/append_parquet.html) and the new `col_select` argument. (More to come!) The new reader is also much faster, see the "Benchmarks" chapter.

## Read a subset of columns

[`read_parquet()`](https://nanoparquet.r-lib.org/reference/read_parquet.html) now has a new argument called `col_select`, that lets you read a subset of the columns from the Parquet file. Unlike for row oriented file formats like CSV, this means that the reader never needs to touch the columns that are not needed for. The time required for reading a subset of columns is independent of how many more columns the Parquet file might have!

You can either use column indices or column names to specify the columns to read. Here is an example.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://github.com/r-lib/nanoparquet'>nanoparquet</a></span><span class='o'>)</span></span>
<span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://pillar.r-lib.org/'>pillar</a></span><span class='o'>)</span></span></code></pre>

</div>

This is the [`nycflights13::flights`](https://rdrr.io/pkg/nycflights13/man/flights.html) data set:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://nanoparquet.r-lib.org/reference/read_parquet.html'>read_parquet</a></span><span class='o'>(</span></span>
<span>  <span class='s'>"flights.parquet"</span>,</span>
<span>  col_select <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"dep_time"</span>, <span class='s'>"arr_time"</span>, <span class='s'>"carrier"</span><span class='o'>)</span></span>
<span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A data frame: 336,776 × 3</span></span></span>
<span><span class='c'>#&gt;    dep_time arr_time carrier</span></span>
<span><span class='c'>#&gt;       <span style='color: #555555; font-style: italic;'>&lt;int&gt;</span>    <span style='color: #555555; font-style: italic;'>&lt;int&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>  </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 1</span>      517      830 UA     </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 2</span>      533      850 UA     </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 3</span>      542      923 AA     </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 4</span>      544     <span style='text-decoration: underline;'>1</span>004 B6     </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 5</span>      554      812 DL     </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 6</span>      554      740 UA     </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 7</span>      555      913 B6     </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 8</span>      557      709 EV     </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 9</span>      557      838 B6     </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>10</span>      558      753 AA     </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># ℹ 336,766 more rows</span></span></span>
<span></span></code></pre>

</div>

Use [`read_parquet_schema()`](https://nanoparquet.r-lib.org/reference/read_parquet_schema.html) if you want to see the structure of the Parquet file first:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://nanoparquet.r-lib.org/reference/read_parquet_schema.html'>read_parquet_schema</a></span><span class='o'>(</span><span class='s'>"flights.parquet"</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A data frame: 20 × 12</span></span></span>
<span><span class='c'>#&gt;    file_name       name  r_type type  type_length repetition_type converted_type</span></span>
<span><span class='c'>#&gt;    <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>           <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>  <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>       <span style='color: #555555; font-style: italic;'>&lt;int&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>           <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>         </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 1</span> flights.parquet sche… <span style='color: #BB0000;'>NA</span>     <span style='color: #BB0000;'>NA</span>             <span style='color: #BB0000;'>NA</span> <span style='color: #BB0000;'>NA</span>              <span style='color: #BB0000;'>NA</span>            </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 2</span> flights.parquet year  integ… INT32          <span style='color: #BB0000;'>NA</span> REQUIRED        INT_32        </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 3</span> flights.parquet month integ… INT32          <span style='color: #BB0000;'>NA</span> REQUIRED        INT_32        </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 4</span> flights.parquet day   integ… INT32          <span style='color: #BB0000;'>NA</span> REQUIRED        INT_32        </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 5</span> flights.parquet dep_… integ… INT32          <span style='color: #BB0000;'>NA</span> OPTIONAL        INT_32        </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 6</span> flights.parquet sche… integ… INT32          <span style='color: #BB0000;'>NA</span> REQUIRED        INT_32        </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 7</span> flights.parquet dep_… double DOUB…          <span style='color: #BB0000;'>NA</span> OPTIONAL        <span style='color: #BB0000;'>NA</span>            </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 8</span> flights.parquet arr_… integ… INT32          <span style='color: #BB0000;'>NA</span> OPTIONAL        INT_32        </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 9</span> flights.parquet sche… integ… INT32          <span style='color: #BB0000;'>NA</span> REQUIRED        INT_32        </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>10</span> flights.parquet arr_… double DOUB…          <span style='color: #BB0000;'>NA</span> OPTIONAL        <span style='color: #BB0000;'>NA</span>            </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>11</span> flights.parquet carr… chara… BYTE…          <span style='color: #BB0000;'>NA</span> REQUIRED        UTF8          </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>12</span> flights.parquet flig… integ… INT32          <span style='color: #BB0000;'>NA</span> REQUIRED        INT_32        </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>13</span> flights.parquet tail… chara… BYTE…          <span style='color: #BB0000;'>NA</span> OPTIONAL        UTF8          </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>14</span> flights.parquet orig… chara… BYTE…          <span style='color: #BB0000;'>NA</span> REQUIRED        UTF8          </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>15</span> flights.parquet dest  chara… BYTE…          <span style='color: #BB0000;'>NA</span> REQUIRED        UTF8          </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>16</span> flights.parquet air_… double DOUB…          <span style='color: #BB0000;'>NA</span> OPTIONAL        <span style='color: #BB0000;'>NA</span>            </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>17</span> flights.parquet dist… double DOUB…          <span style='color: #BB0000;'>NA</span> REQUIRED        <span style='color: #BB0000;'>NA</span>            </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>18</span> flights.parquet hour  double DOUB…          <span style='color: #BB0000;'>NA</span> REQUIRED        <span style='color: #BB0000;'>NA</span>            </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>19</span> flights.parquet minu… double DOUB…          <span style='color: #BB0000;'>NA</span> REQUIRED        <span style='color: #BB0000;'>NA</span>            </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>20</span> flights.parquet time… POSIX… INT64          <span style='color: #BB0000;'>NA</span> REQUIRED        TIMESTAMP_MIC…</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># ℹ 5 more variables: logical_type &lt;I&lt;list&gt;&gt;, num_children &lt;int&gt;, scale &lt;int&gt;,</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>#   precision &lt;int&gt;, field_id &lt;int&gt;</span></span></span>
<span></span></code></pre>

</div>

The output of [`read_parquet_schema()`](https://nanoparquet.r-lib.org/reference/read_parquet_schema.html) also shows you the R type that nanoparquet will use for each column.

## Appending to Parquet files

The new [`append_parquet()`](https://nanoparquet.r-lib.org/reference/append_parquet.html) function makes it easy to append new data to a Parquet file, without first reading the whole file into memory. The schema of the file and the schema new data must match of course. Lets merge [`nycflights13::flights`](https://rdrr.io/pkg/nycflights13/man/flights.html) and [`nycflights23::flights`](https://moderndive.github.io/nycflights23/reference/flights.html):

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://rdrr.io/r/base/files.html'>file.copy</a></span><span class='o'>(</span><span class='s'>"flights.parquet"</span>, <span class='s'>"allflights.parquet"</span>, overwrite <span class='o'>=</span> <span class='kc'>TRUE</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; [1] TRUE</span></span>
<span></span><span><span class='nf'><a href='https://nanoparquet.r-lib.org/reference/append_parquet.html'>append_parquet</a></span><span class='o'>(</span><span class='nf'>nycflights23</span><span class='nf'>::</span><span class='nv'><a href='https://moderndive.github.io/nycflights23/reference/flights.html'>flights</a></span>, <span class='s'>"allflights.parquet"</span><span class='o'>)</span></span></code></pre>

</div>

[`read_parquet_info()`](https://nanoparquet.r-lib.org/reference/read_parquet_info.html) returns the most basic information about a Parquet file:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://nanoparquet.r-lib.org/reference/read_parquet_info.html'>read_parquet_info</a></span><span class='o'>(</span><span class='s'>"flights.parquet"</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A data frame: 1 × 7</span></span></span>
<span><span class='c'>#&gt;   file_name       num_cols num_rows num_row_groups file_size parquet_version</span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>              <span style='color: #555555; font-style: italic;'>&lt;int&gt;</span>    <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>          <span style='color: #555555; font-style: italic;'>&lt;int&gt;</span>     <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>           <span style='color: #555555; font-style: italic;'>&lt;int&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span> flights.parquet       19   <span style='text-decoration: underline;'>336</span>776              1   5<span style='text-decoration: underline;'>687</span>737               1</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># ℹ 1 more variable: created_by &lt;chr&gt;</span></span></span>
<span></span><span><span class='nf'><a href='https://nanoparquet.r-lib.org/reference/read_parquet_info.html'>read_parquet_info</a></span><span class='o'>(</span><span class='s'>"allflights.parquet"</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A data frame: 1 × 7</span></span></span>
<span><span class='c'>#&gt;   file_name          num_cols num_rows num_row_groups file_size parquet_version</span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>                 <span style='color: #555555; font-style: italic;'>&lt;int&gt;</span>    <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>          <span style='color: #555555; font-style: italic;'>&lt;int&gt;</span>     <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>           <span style='color: #555555; font-style: italic;'>&lt;int&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span> allflights.parquet       19   <span style='text-decoration: underline;'>772</span>128              1  13<span style='text-decoration: underline;'>490</span>997               1</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># ℹ 1 more variable: created_by &lt;chr&gt;</span></span></span>
<span></span></code></pre>

</div>

Note that you should probably still create a backup copy of the original file when using [`append_parquet()`](https://nanoparquet.r-lib.org/reference/append_parquet.html). If the appending process is interrupted by a power failure, then you might end up with an incomplete and invalid Parquet file.

## Schemas and type conversions

In nanoparquet 0.4.0 [`write_parquet()`](https://nanoparquet.r-lib.org/reference/write_parquet.html) takes a `schema` argument that can customize the R to Parquet type mappings. For example by default [`write_parquet()`](https://nanoparquet.r-lib.org/reference/write_parquet.html) writes an R character vector as a `STRING` Parquet type. If you'd like to write a certain character column as an `ENUM` type[^1] instead, you'll need to specify that in `schema`:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://nanoparquet.r-lib.org/reference/write_parquet.html'>write_parquet</a></span><span class='o'>(</span></span>
<span>  <span class='nf'>nycflights13</span><span class='nf'>::</span><span class='nv'><a href='https://rdrr.io/pkg/nycflights13/man/flights.html'>flights</a></span>,</span>
<span>  <span class='s'>"newflights.parquet"</span>,</span>
<span>  schema <span class='o'>=</span> <span class='nf'><a href='https://nanoparquet.r-lib.org/reference/parquet_schema.html'>parquet_schema</a></span><span class='o'>(</span>carrier <span class='o'>=</span> <span class='s'>"ENUM"</span><span class='o'>)</span></span>
<span><span class='o'>)</span></span>
<span><span class='nf'><a href='https://nanoparquet.r-lib.org/reference/read_parquet_schema.html'>read_parquet_schema</a></span><span class='o'>(</span><span class='s'>"newflights.parquet"</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A data frame: 20 × 12</span></span></span>
<span><span class='c'>#&gt;    file_name       name  r_type type  type_length repetition_type converted_type</span></span>
<span><span class='c'>#&gt;    <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>           <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>  <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>       <span style='color: #555555; font-style: italic;'>&lt;int&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>           <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>         </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 1</span> newflights.par… sche… <span style='color: #BB0000;'>NA</span>     <span style='color: #BB0000;'>NA</span>             <span style='color: #BB0000;'>NA</span> <span style='color: #BB0000;'>NA</span>              <span style='color: #BB0000;'>NA</span>            </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 2</span> newflights.par… year  integ… INT32          <span style='color: #BB0000;'>NA</span> REQUIRED        INT_32        </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 3</span> newflights.par… month integ… INT32          <span style='color: #BB0000;'>NA</span> REQUIRED        INT_32        </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 4</span> newflights.par… day   integ… INT32          <span style='color: #BB0000;'>NA</span> REQUIRED        INT_32        </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 5</span> newflights.par… dep_… integ… INT32          <span style='color: #BB0000;'>NA</span> OPTIONAL        INT_32        </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 6</span> newflights.par… sche… integ… INT32          <span style='color: #BB0000;'>NA</span> REQUIRED        INT_32        </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 7</span> newflights.par… dep_… double DOUB…          <span style='color: #BB0000;'>NA</span> OPTIONAL        <span style='color: #BB0000;'>NA</span>            </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 8</span> newflights.par… arr_… integ… INT32          <span style='color: #BB0000;'>NA</span> OPTIONAL        INT_32        </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 9</span> newflights.par… sche… integ… INT32          <span style='color: #BB0000;'>NA</span> REQUIRED        INT_32        </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>10</span> newflights.par… arr_… double DOUB…          <span style='color: #BB0000;'>NA</span> OPTIONAL        <span style='color: #BB0000;'>NA</span>            </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>11</span> newflights.par… carr… chara… BYTE…          <span style='color: #BB0000;'>NA</span> REQUIRED        ENUM          </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>12</span> newflights.par… flig… integ… INT32          <span style='color: #BB0000;'>NA</span> REQUIRED        INT_32        </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>13</span> newflights.par… tail… chara… BYTE…          <span style='color: #BB0000;'>NA</span> OPTIONAL        UTF8          </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>14</span> newflights.par… orig… chara… BYTE…          <span style='color: #BB0000;'>NA</span> REQUIRED        UTF8          </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>15</span> newflights.par… dest  chara… BYTE…          <span style='color: #BB0000;'>NA</span> REQUIRED        UTF8          </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>16</span> newflights.par… air_… double DOUB…          <span style='color: #BB0000;'>NA</span> OPTIONAL        <span style='color: #BB0000;'>NA</span>            </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>17</span> newflights.par… dist… double DOUB…          <span style='color: #BB0000;'>NA</span> REQUIRED        <span style='color: #BB0000;'>NA</span>            </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>18</span> newflights.par… hour  double DOUB…          <span style='color: #BB0000;'>NA</span> REQUIRED        <span style='color: #BB0000;'>NA</span>            </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>19</span> newflights.par… minu… double DOUB…          <span style='color: #BB0000;'>NA</span> REQUIRED        <span style='color: #BB0000;'>NA</span>            </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>20</span> newflights.par… time… POSIX… INT64          <span style='color: #BB0000;'>NA</span> REQUIRED        TIMESTAMP_MIC…</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># ℹ 5 more variables: logical_type &lt;I&lt;list&gt;&gt;, num_children &lt;int&gt;, scale &lt;int&gt;,</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>#   precision &lt;int&gt;, field_id &lt;int&gt;</span></span></span>
<span></span></code></pre>

</div>

Here we wrote the `carrier` column as `ENUM`, and left the other other columns to use the default type mappings.

See the [`?nanoparquet-types`](https://nanoparquet.r-lib.org/reference/nanoparquet-types.html#r-s-data-types) manual page for the possible type mappings (lots of new ones!) and also for the default ones.

## Encodings

It is now also possible to customize the encoding of each column in [`write_parquet()`](https://nanoparquet.r-lib.org/reference/write_parquet.html), via the `encoding` argument. By default [`write_parquet()`](https://nanoparquet.r-lib.org/reference/write_parquet.html) tries to choose a good encoding based on the type and the values of a column. E.g. it checks a small sample for repeated values to decide if it is worth using a dictionary encoding (`RLE_DICTIONARY`).

If [`write_parquet()`](https://nanoparquet.r-lib.org/reference/write_parquet.html) gets it wrong, use the `encoding` argument to force an encoding. The following forces the `PLAIN` encoding for all columns. This encoding is very fast to write, but creates a larger file. You can also specify different encodings for different columns, see the [`write_parquet()` manual page](https://nanoparquet.r-lib.org/reference/write_parquet.html).

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://nanoparquet.r-lib.org/reference/write_parquet.html'>write_parquet</a></span><span class='o'>(</span></span>
<span>  <span class='nf'>nycflights13</span><span class='nf'>::</span><span class='nv'><a href='https://rdrr.io/pkg/nycflights13/man/flights.html'>flights</a></span>,</span>
<span>  <span class='s'>"plainflights.parquet"</span>,</span>
<span>  encoding <span class='o'>=</span> <span class='s'>"PLAIN"</span></span>
<span><span class='o'>)</span></span>
<span><span class='nf'><a href='https://rdrr.io/r/base/file.info.html'>file.size</a></span><span class='o'>(</span><span class='s'>"flights.parquet"</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; [1] 5687737</span></span>
<span></span><span><span class='nf'><a href='https://rdrr.io/r/base/file.info.html'>file.size</a></span><span class='o'>(</span><span class='s'>"plainflights.parquet"</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; [1] 11954574</span></span>
<span></span></code></pre>

</div>

See more about the implemented encodings and how the defaults are selected in the [`parquet-encodings` manual page](https://nanoparquet.r-lib.org/reference/parquet-encodings.html).

## API changes

Some nanoparquet functions have new, better names in nanoparquet 0.4.0. In particular, all functions that read from a Parquet file have a `read_parquet` prefix now. The old functions still work, with a warning.

Also, the [`parquet_schema()`](https://nanoparquet.r-lib.org/reference/parquet_schema.html) function is now for creating a new Parquet schema from scratch, and not for inferring a schema from a data frame (use [`infer_parquet_schema()`](https://nanoparquet.r-lib.org/reference/infer_parquet_schema.html)) or for reading the schema from a Parquet file (use [`read_parquet_schema()`](https://nanoparquet.r-lib.org/reference/read_parquet_schema.html)). [`parquet_schema()`](https://nanoparquet.r-lib.org/reference/parquet_schema.html) falls back to the old behaviour when called with a file name, with a warning, so this is not a breaking change (yet), and old code still works.

See the complete list of API changes in the [Changelog](https://nanoparquet.r-lib.org/news/index.html).

## Benchmarks

We are very excited about the performance of the new Parquet reader, and the Parquet writer was always quite speedy, so we ran a simple benchmark.

We compared nanoparquet to the Parquet implementations in Apache Arrow and DuckDB, and also to CSV readers and writers, on a real data set, for samples of 330k, 6.7 million and 67.4 million rows (40MB, 800MB and 8GB in memory). For these data nanoparquet is indeed very competitive with both Arrow and DuckDB.

You can see the full results [on the website](https://nanoparquet.r-lib.org/articles/benchmarks.html).

## Other changes

Other important changes in nanoparquet 0.4.0 include:

-   [`write_parquet()`](https://nanoparquet.r-lib.org/reference/write_parquet.html) can now write multiple row groups. By default it puts at most 10 million rows in a single row group. (This is subject to <https://nanoparquet.r-lib.org/references/parquet_options.html> ) on how to change the default.

-   [`write_parquet()`](https://nanoparquet.r-lib.org/reference/write_parquet.html) now writes minimum and maximum statistics (by default) for most Parquet types. See the [`parquet_options()` manual page](https://nanoparquet.r-lib.org/reference/parquet_options.html) on how to turn this off, which will probably make the writer faster.

-   [`write_parquet()`](https://nanoparquet.r-lib.org/reference/write_parquet.html) can now write version 2 data pages. The default is still version 1, but it might change in the future.

-   New `compression_level` option to select the compression level manually.

-   [`read_parquet()`](https://nanoparquet.r-lib.org/reference/read_parquet.html) can now read from an R connection.

## Acknowledgements

[@alvarocombo](https://github.com/alvarocombo), [@D3SL](https://github.com/D3SL), [@gaborcsardi](https://github.com/gaborcsardi), and [@RealTYPICAL](https://github.com/RealTYPICAL).

[^1]: A Parquet `ENUM` type is very similar to a factor in R.

