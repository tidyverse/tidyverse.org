---
output: hugodown::hugo_document

slug: nanoparquet-0-3-0
title: nanoparquet 0.3.0
date: 2024-06-20
author: Gábor Csárdi
description: >
    Nanoparquet is a new R package that can read and write (flat) Parquet
    files. This post covers its features and limitations.

photo:
  url: https://www.pexels.com/photo/clock-between-columns-20134435/
  author: Marina Zvada

# one of: "deep-dive", "learn", "package", "programming", "roundup", or "other"
categories: [package]
tags: [parquet]
rmd_hash: 015376a439d4504e

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
* [x] ~~[`usethis::use_tidy_thanks()`](https://usethis.r-lib.org/reference/use_tidy_thanks.html)~~
-->

We're extremely pleased to announce the release of [nanoparquet](https://r-lib.github.io/nanoparquet/) 0.3.0. nanoparquet is a new R package that reads Parquet files into data frames, and writes data frames to Parquet files.

You can install it from CRAN with:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://rdrr.io/r/utils/install.packages.html'>install.packages</a></span><span class='o'>(</span><span class='s'>"nanoparquet"</span><span class='o'>)</span></span></code></pre>

</div>

This blog post will cover the features and limitations of nanoparquet, and also our future plans.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://github.com/r-lib/nanoparquet'>nanoparquet</a></span><span class='o'>)</span></span></code></pre>

</div>

## What is Parquet?

Parquet is a file format for storing data on disk. It is specifically designed for large data sets, read-heavy workloads and data analysis. The most important features of Parquet are:

-   **Columnar**. Data is stored column-wise, so whole columns (or large chunks of columns) are easy to read quickly. Columnar storage allows better compression, fast operations on a subset of columns, and easy ways of removing columns or adding new columns to a data file.

-   **Binary**. A Parquet file is not a text file. Each Parquet data type is stored in a well-defined binary storage format, leaving no ambiguity about how fields are persed.

-   **Rich types**. Parquet supports a small set of *low level* data types with well specified storage formats and encodings. On top of the low level types, it implemented several higher level logical types, like UTF-8 strings, time stamps, JSON strings, ENUM types (factors), etc.

-   **Well supported**. At this point Parquet is well supported across modern languages like R, Python, Rust, Java, Go, etc. In particular, Apache Arrow handles Parquet files very well, and has bindings to many languages. DuckDB is a very portable tool that reads and writes Parquet files, or even opens a set of Parquet files as a database.

-   **Performant**. Parquet columns may use various encodings and compression to ensure that the data files are kept as small as possible. When running an analytical query on the subset of the data, the Parquet format makes it easy to skip the columns and/or rows that are irrelevant.

-   **Concurrency built in**. A Parquet file can be divided into row groups. Parquet readers can read, uncompress and decode row groups in parallel. Parquet writes can encode and compress row groups in parallel. Even a single column may be divided into multiple pages, that can be (un)compressed, encode and decode in parallel.

-   **Missing values**. Support for missing values is built into the Parquet format.

## Why we created nanoparquet?

Although Parquet is well supported by modern languages, today the complexity of the Parquet format often outweighs its benefits for smaller data sets. Many tools that support Parquet are typically used for larger, out of memory data sets, so there is a perception that Parquet is only for big data. These tools typically take longer to compile or install, and often seem too heavy for in-memory data analysis.

With nanoparquet, we wanted to have a smaller tool that has no dependencies and is easy to install. Our goal is to facilitate the adoption of Parquet for smaller data sets, especially for teams that share data between multiple environments, e.g. R, Python, Java, etc.

## nanoparquet Features

These are some of the nanoparquet features that we are most excited about.

-   **Lightweight**. nanoparquet has no package or system dependencies other than a C++-11 compiler. It compiles in about 30 seconds into an R package that is less than a megabyte in size.

-   **Reads many Parquet files**. [`nanoparquet::read_parquet()`](https://r-lib.github.io/nanoparquet/reference/read_parquet.html) supports reading most Parquet files. In particular, in supports all Parquet encodings and at the time of writing it supports three compression codecs: Snappy, Gzip and Zstd. Make sure you read "Limitations" below.

-   **Writes many R data types**. [`nanoparquet::write_parquet()`](https://r-lib.github.io/nanoparquet/reference/write_parquet.html) supports writing most R data frames. In particular, missing values are handled properly, factor columns are kept as factors, and temporal types are encoded correctly. Make sure you read "Limitations" below.

-   **Type mappings**. nanoparquet has a well defined set of [type mapping rules](https://r-lib.github.io/nanoparquet/reference/nanoparquet-types.html). Use the [`parquet_column_types()`](https://r-lib.github.io/nanoparquet/dev/reference/parquet_column_types.html) function to see how [`read_parquet()`](https://r-lib.github.io/nanoparquet/reference/read_parquet.html) and [`write_parquet()`](https://r-lib.github.io/nanoparquet/reference/write_parquet.html) maps Parquet and R types for a file or a data frame.

-   **Metadata queries**. nanoparquet has a [number of functions](https://r-lib.github.io/nanoparquet/dev/reference/index.html#extract-parquet-metadata) that allow you to query the metadata and schema without reading in the full dataset.

## Examples

### Reading a Parquet file

The nanoparquet R package contains an example Parquet file. We are going to use it to demonstrate how the package works.

If the pillar package is loaded, then nanoparquet data frames are pretty-printed.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://github.com/r-lib/nanoparquet'>nanoparquet</a></span><span class='o'>)</span></span>
<span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://pillar.r-lib.org/'>pillar</a></span><span class='o'>)</span></span>
<span><span class='nv'>udf</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/system.file.html'>system.file</a></span><span class='o'>(</span><span class='s'>"extdata/userdata1.parquet"</span>, package <span class='o'>=</span> <span class='s'>"nanoparquet"</span><span class='o'>)</span></span></code></pre>

</div>

Before actually reading the file, let's look up some metadata about it, and also how its columns will be mapped to R types:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://r-lib.github.io/nanoparquet/reference/parquet_info.html'>parquet_info</a></span><span class='o'>(</span><span class='nv'>udf</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A data frame: 1 × 7</span></span></span>
<span><span class='c'>#&gt;   file_name           num_cols num_rows num_row_groups file_size parquet_version</span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>                  <span style='color: #555555; font-style: italic;'>&lt;int&gt;</span>    <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>          <span style='color: #555555; font-style: italic;'>&lt;int&gt;</span>     <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>           <span style='color: #555555; font-style: italic;'>&lt;int&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span> /Users/gaborcsardi…       13     <span style='text-decoration: underline;'>1</span>000              1     <span style='text-decoration: underline;'>73</span>217               1</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># ℹ 1 more variable: created_by &lt;chr&gt;</span></span></span>
<span></span></code></pre>

</div>

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://r-lib.github.io/nanoparquet/reference/parquet_column_types.html'>parquet_column_types</a></span><span class='o'>(</span><span class='nv'>udf</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A data frame: 13 × 6</span></span></span>
<span><span class='c'>#&gt;    file_name        name  type  r_type repetition_type logical_type             </span></span>
<span><span class='c'>#&gt;  <span style='color: #555555;'>*</span> <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>            <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>  <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>           <span style='color: #555555; font-style: italic;'>&lt;I&lt;list&gt;&gt;</span>                </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 1</span> /Users/gaborcsa… regi… INT64 POSIX… REQUIRED        <span style='color: #555555;'>&lt;TIMESTAMP(TRUE, micros)&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 2</span> /Users/gaborcsa… id    INT32 integ… REQUIRED        <span style='color: #555555;'>&lt;INT(32, TRUE)&gt;</span>          </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 3</span> /Users/gaborcsa… firs… BYTE… chara… OPTIONAL        <span style='color: #555555;'>&lt;STRING&gt;</span>                 </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 4</span> /Users/gaborcsa… last… BYTE… chara… REQUIRED        <span style='color: #555555;'>&lt;STRING&gt;</span>                 </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 5</span> /Users/gaborcsa… email BYTE… chara… OPTIONAL        <span style='color: #555555;'>&lt;STRING&gt;</span>                 </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 6</span> /Users/gaborcsa… gend… BYTE… factor OPTIONAL        <span style='color: #555555;'>&lt;STRING&gt;</span>                 </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 7</span> /Users/gaborcsa… ip_a… BYTE… chara… REQUIRED        <span style='color: #555555;'>&lt;STRING&gt;</span>                 </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 8</span> /Users/gaborcsa… cc    BYTE… chara… OPTIONAL        <span style='color: #555555;'>&lt;STRING&gt;</span>                 </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 9</span> /Users/gaborcsa… coun… BYTE… chara… REQUIRED        <span style='color: #555555;'>&lt;STRING&gt;</span>                 </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>10</span> /Users/gaborcsa… birt… INT32 Date   OPTIONAL        <span style='color: #555555;'>&lt;DATE&gt;</span>                   </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>11</span> /Users/gaborcsa… sala… DOUB… double OPTIONAL        <span style='color: #555555;'>&lt;NULL&gt;</span>                   </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>12</span> /Users/gaborcsa… title BYTE… chara… OPTIONAL        <span style='color: #555555;'>&lt;STRING&gt;</span>                 </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>13</span> /Users/gaborcsa… comm… BYTE… chara… OPTIONAL        <span style='color: #555555;'>&lt;STRING&gt;</span></span></span>
<span></span></code></pre>

</div>

For every Parquet column we see its low level Parquet data type in `type`, e.g. `INT64` or `BYTE_ARRAY`. `r_type` the R type that [`read_parquet()`](https://r-lib.github.io/nanoparquet/reference/read_parquet.html) will create for that column. If `repetition_type` is `REQUIRED`, then that column cannot contain missing values. `OPTIONAL` columns may have missing values. `logical_type` is the higher level Parquet data type.

E.g. the first column is an UTC (because of the `TRUE`) timestamp, in microseconds. It is stored as a 64 bit integer in the file, and it will be converted to a `POSIXct` object by [`read_parquet()`](https://r-lib.github.io/nanoparquet/reference/read_parquet.html).

To actually read the file into a data frame, call [`read_parquet()`](https://r-lib.github.io/nanoparquet/reference/read_parquet.html):

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>ud1</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://r-lib.github.io/nanoparquet/reference/read_parquet.html'>read_parquet</a></span><span class='o'>(</span><span class='nv'>udf</span><span class='o'>)</span></span>
<span><span class='nv'>ud1</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A data frame: 1,000 × 13</span></span></span>
<span><span class='c'>#&gt;    registration           id first_name last_name email  gender ip_address cc   </span></span>
<span><span class='c'>#&gt;    <span style='color: #555555; font-style: italic;'>&lt;dttm&gt;</span>              <span style='color: #555555; font-style: italic;'>&lt;int&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>      <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>     <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>  <span style='color: #555555; font-style: italic;'>&lt;fct&gt;</span>  <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>      <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 1</span> 2016-02-03 <span style='color: #555555;'>07:55:29</span>     1 Amanda     Jordan    ajord… Female 1.197.201… 6759…</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 2</span> 2016-02-03 <span style='color: #555555;'>17:04:03</span>     2 Albert     Freeman   afree… Male   218.111.1… <span style='color: #BB0000;'>NA</span>   </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 3</span> 2016-02-03 <span style='color: #555555;'>01:09:31</span>     3 Evelyn     Morgan    emorg… Female 7.161.136… 6767…</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 4</span> 2016-02-03 <span style='color: #555555;'>00:36:21</span>     4 Denise     Riley     drile… Female 140.35.10… 3576…</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 5</span> 2016-02-03 <span style='color: #555555;'>05:05:31</span>     5 Carlos     Burns     cburn… <span style='color: #BB0000;'>NA</span>     169.113.2… 5602…</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 6</span> 2016-02-03 <span style='color: #555555;'>07:22:34</span>     6 Kathryn    White     kwhit… Female 195.131.8… 3583…</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 7</span> 2016-02-03 <span style='color: #555555;'>08:33:08</span>     7 Samuel     Holmes    sholm… Male   232.234.8… 3582…</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 8</span> 2016-02-03 <span style='color: #555555;'>06:47:06</span>     8 Harry      Howell    hhowe… Male   91.235.51… <span style='color: #BB0000;'>NA</span>   </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 9</span> 2016-02-03 <span style='color: #555555;'>03:52:53</span>     9 Jose       Foster    jfost… Male   132.31.53… <span style='color: #BB0000;'>NA</span>   </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>10</span> 2016-02-03 <span style='color: #555555;'>18:29:47</span>    10 Emily      Stewart   estew… Female 143.28.25… 3574…</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># ℹ 990 more rows</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># ℹ 5 more variables: country &lt;chr&gt;, birthdate &lt;date&gt;, salary &lt;dbl&gt;,</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>#   title &lt;chr&gt;, comments &lt;chr&gt;</span></span></span>
<span></span></code></pre>

</div>

### Writing a Parquet file

To show [`write_parquet()`](https://r-lib.github.io/nanoparquet/reference/write_parquet.html), we'll use the `flights` data in the nycflights13 package:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://github.com/hadley/nycflights13'>nycflights13</a></span><span class='o'>)</span></span>
<span><span class='nv'>flights</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 336,776 × 19</span></span></span>
<span><span class='c'>#&gt;     year month   day dep_time sched_dep_time dep_delay arr_time sched_arr_time</span></span>
<span><span class='c'>#&gt;    <span style='color: #555555; font-style: italic;'>&lt;int&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;int&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;int&gt;</span>    <span style='color: #555555; font-style: italic;'>&lt;int&gt;</span>          <span style='color: #555555; font-style: italic;'>&lt;int&gt;</span>     <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>    <span style='color: #555555; font-style: italic;'>&lt;int&gt;</span>          <span style='color: #555555; font-style: italic;'>&lt;int&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 1</span>  <span style='text-decoration: underline;'>2</span>013     1     1      517            515         2      830            819</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 2</span>  <span style='text-decoration: underline;'>2</span>013     1     1      533            529         4      850            830</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 3</span>  <span style='text-decoration: underline;'>2</span>013     1     1      542            540         2      923            850</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 4</span>  <span style='text-decoration: underline;'>2</span>013     1     1      544            545        -<span style='color: #BB0000;'>1</span>     <span style='text-decoration: underline;'>1</span>004           <span style='text-decoration: underline;'>1</span>022</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 5</span>  <span style='text-decoration: underline;'>2</span>013     1     1      554            600        -<span style='color: #BB0000;'>6</span>      812            837</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 6</span>  <span style='text-decoration: underline;'>2</span>013     1     1      554            558        -<span style='color: #BB0000;'>4</span>      740            728</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 7</span>  <span style='text-decoration: underline;'>2</span>013     1     1      555            600        -<span style='color: #BB0000;'>5</span>      913            854</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 8</span>  <span style='text-decoration: underline;'>2</span>013     1     1      557            600        -<span style='color: #BB0000;'>3</span>      709            723</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 9</span>  <span style='text-decoration: underline;'>2</span>013     1     1      557            600        -<span style='color: #BB0000;'>3</span>      838            846</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>10</span>  <span style='text-decoration: underline;'>2</span>013     1     1      558            600        -<span style='color: #BB0000;'>2</span>      753            745</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># ℹ 336,766 more rows</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># ℹ 11 more variables: arr_delay &lt;dbl&gt;, carrier &lt;chr&gt;, flight &lt;int&gt;,</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>#   tailnum &lt;chr&gt;, origin &lt;chr&gt;, dest &lt;chr&gt;, air_time &lt;dbl&gt;, distance &lt;dbl&gt;,</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>#   hour &lt;dbl&gt;, minute &lt;dbl&gt;, time_hour &lt;dttm&gt;</span></span></span>
<span></span></code></pre>

</div>

First we check how columns of `flights` will be mapped to Parquet types:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://r-lib.github.io/nanoparquet/reference/parquet_column_types.html'>parquet_column_types</a></span><span class='o'>(</span><span class='nv'>flights</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A data frame: 19 × 6</span></span></span>
<span><span class='c'>#&gt;    file_name name         type  r_type repetition_type logical_type             </span></span>
<span><span class='c'>#&gt;    <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>     <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>        <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>  <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>           <span style='color: #555555; font-style: italic;'>&lt;I&lt;list&gt;&gt;</span>                </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 1</span> <span style='color: #BB0000;'>NA</span>        year         INT32 integ… REQUIRED        <span style='color: #555555;'>&lt;INT(32, TRUE)&gt;</span>          </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 2</span> <span style='color: #BB0000;'>NA</span>        month        INT32 integ… REQUIRED        <span style='color: #555555;'>&lt;INT(32, TRUE)&gt;</span>          </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 3</span> <span style='color: #BB0000;'>NA</span>        day          INT32 integ… REQUIRED        <span style='color: #555555;'>&lt;INT(32, TRUE)&gt;</span>          </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 4</span> <span style='color: #BB0000;'>NA</span>        dep_time     INT32 integ… OPTIONAL        <span style='color: #555555;'>&lt;INT(32, TRUE)&gt;</span>          </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 5</span> <span style='color: #BB0000;'>NA</span>        sched_dep_t… INT32 integ… REQUIRED        <span style='color: #555555;'>&lt;INT(32, TRUE)&gt;</span>          </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 6</span> <span style='color: #BB0000;'>NA</span>        dep_delay    DOUB… double OPTIONAL        <span style='color: #555555;'>&lt;NULL&gt;</span>                   </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 7</span> <span style='color: #BB0000;'>NA</span>        arr_time     INT32 integ… OPTIONAL        <span style='color: #555555;'>&lt;INT(32, TRUE)&gt;</span>          </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 8</span> <span style='color: #BB0000;'>NA</span>        sched_arr_t… INT32 integ… REQUIRED        <span style='color: #555555;'>&lt;INT(32, TRUE)&gt;</span>          </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 9</span> <span style='color: #BB0000;'>NA</span>        arr_delay    DOUB… double OPTIONAL        <span style='color: #555555;'>&lt;NULL&gt;</span>                   </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>10</span> <span style='color: #BB0000;'>NA</span>        carrier      BYTE… chara… REQUIRED        <span style='color: #555555;'>&lt;STRING&gt;</span>                 </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>11</span> <span style='color: #BB0000;'>NA</span>        flight       INT32 integ… REQUIRED        <span style='color: #555555;'>&lt;INT(32, TRUE)&gt;</span>          </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>12</span> <span style='color: #BB0000;'>NA</span>        tailnum      BYTE… chara… OPTIONAL        <span style='color: #555555;'>&lt;STRING&gt;</span>                 </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>13</span> <span style='color: #BB0000;'>NA</span>        origin       BYTE… chara… REQUIRED        <span style='color: #555555;'>&lt;STRING&gt;</span>                 </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>14</span> <span style='color: #BB0000;'>NA</span>        dest         BYTE… chara… REQUIRED        <span style='color: #555555;'>&lt;STRING&gt;</span>                 </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>15</span> <span style='color: #BB0000;'>NA</span>        air_time     DOUB… double OPTIONAL        <span style='color: #555555;'>&lt;NULL&gt;</span>                   </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>16</span> <span style='color: #BB0000;'>NA</span>        distance     DOUB… double REQUIRED        <span style='color: #555555;'>&lt;NULL&gt;</span>                   </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>17</span> <span style='color: #BB0000;'>NA</span>        hour         DOUB… double REQUIRED        <span style='color: #555555;'>&lt;NULL&gt;</span>                   </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>18</span> <span style='color: #BB0000;'>NA</span>        minute       DOUB… double REQUIRED        <span style='color: #555555;'>&lt;NULL&gt;</span>                   </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>19</span> <span style='color: #BB0000;'>NA</span>        time_hour    INT64 POSIX… REQUIRED        <span style='color: #555555;'>&lt;TIMESTAMP(TRUE, micros)&gt;</span></span></span>
<span></span></code></pre>

</div>

This looks fine, so we go ahead and write out the file. By default it will be Snappy-compressed, and many columns will be dictionary encoded.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://r-lib.github.io/nanoparquet/reference/write_parquet.html'>write_parquet</a></span><span class='o'>(</span><span class='nv'>flights</span>, <span class='s'>"flights.parquet"</span><span class='o'>)</span></span></code></pre>

</div>

### Parquet metadata

Use [`parquet_schema()`](https://r-lib.github.io/nanoparquet/reference/parquet_schema.html) to see the schema of a Parquet file. The schema also includes "internal" parquet columns. Every Parquet file is a tree where columns may be part of an "internal" column. nanoparquet currently only supports flat files, that consist of a single internal root column and all other columns are leaf columns and are children of the root:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://r-lib.github.io/nanoparquet/reference/parquet_schema.html'>parquet_schema</a></span><span class='o'>(</span><span class='s'>"flights.parquet"</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A data frame: 20 × 11</span></span></span>
<span><span class='c'>#&gt;    file_name       name         type  type_length repetition_type converted_type</span></span>
<span><span class='c'>#&gt;    <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>           <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>        <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>       <span style='color: #555555; font-style: italic;'>&lt;int&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>           <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>         </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 1</span> flights.parquet schema       <span style='color: #BB0000;'>NA</span>             <span style='color: #BB0000;'>NA</span> <span style='color: #BB0000;'>NA</span>              <span style='color: #BB0000;'>NA</span>            </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 2</span> flights.parquet year         INT32          <span style='color: #BB0000;'>NA</span> REQUIRED        INT_32        </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 3</span> flights.parquet month        INT32          <span style='color: #BB0000;'>NA</span> REQUIRED        INT_32        </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 4</span> flights.parquet day          INT32          <span style='color: #BB0000;'>NA</span> REQUIRED        INT_32        </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 5</span> flights.parquet dep_time     INT32          <span style='color: #BB0000;'>NA</span> OPTIONAL        INT_32        </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 6</span> flights.parquet sched_dep_t… INT32          <span style='color: #BB0000;'>NA</span> REQUIRED        INT_32        </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 7</span> flights.parquet dep_delay    DOUB…          <span style='color: #BB0000;'>NA</span> OPTIONAL        <span style='color: #BB0000;'>NA</span>            </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 8</span> flights.parquet arr_time     INT32          <span style='color: #BB0000;'>NA</span> OPTIONAL        INT_32        </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 9</span> flights.parquet sched_arr_t… INT32          <span style='color: #BB0000;'>NA</span> REQUIRED        INT_32        </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>10</span> flights.parquet arr_delay    DOUB…          <span style='color: #BB0000;'>NA</span> OPTIONAL        <span style='color: #BB0000;'>NA</span>            </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>11</span> flights.parquet carrier      BYTE…          <span style='color: #BB0000;'>NA</span> REQUIRED        UTF8          </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>12</span> flights.parquet flight       INT32          <span style='color: #BB0000;'>NA</span> REQUIRED        INT_32        </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>13</span> flights.parquet tailnum      BYTE…          <span style='color: #BB0000;'>NA</span> OPTIONAL        UTF8          </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>14</span> flights.parquet origin       BYTE…          <span style='color: #BB0000;'>NA</span> REQUIRED        UTF8          </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>15</span> flights.parquet dest         BYTE…          <span style='color: #BB0000;'>NA</span> REQUIRED        UTF8          </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>16</span> flights.parquet air_time     DOUB…          <span style='color: #BB0000;'>NA</span> OPTIONAL        <span style='color: #BB0000;'>NA</span>            </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>17</span> flights.parquet distance     DOUB…          <span style='color: #BB0000;'>NA</span> REQUIRED        <span style='color: #BB0000;'>NA</span>            </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>18</span> flights.parquet hour         DOUB…          <span style='color: #BB0000;'>NA</span> REQUIRED        <span style='color: #BB0000;'>NA</span>            </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>19</span> flights.parquet minute       DOUB…          <span style='color: #BB0000;'>NA</span> REQUIRED        <span style='color: #BB0000;'>NA</span>            </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>20</span> flights.parquet time_hour    INT64          <span style='color: #BB0000;'>NA</span> REQUIRED        TIMESTAMP_MIC…</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># ℹ 5 more variables: logical_type &lt;I&lt;list&gt;&gt;, num_children &lt;int&gt;, scale &lt;int&gt;,</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>#   precision &lt;int&gt;, field_id &lt;int&gt;</span></span></span>
<span></span></code></pre>

</div>

To see more information about a Parquet file, use [`parquet_metadata()`](https://r-lib.github.io/nanoparquet/reference/parquet_metadata.html):

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://r-lib.github.io/nanoparquet/reference/parquet_metadata.html'>parquet_metadata</a></span><span class='o'>(</span><span class='s'>"flights.parquet"</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; $file_meta_data</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A data frame: 1 × 5</span></span></span>
<span><span class='c'>#&gt;   file_name       version num_rows key_value_metadata created_by                </span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>             <span style='color: #555555; font-style: italic;'>&lt;int&gt;</span>    <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;I&lt;list&gt;&gt;</span>          <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>                     </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span> flights.parquet       1   <span style='text-decoration: underline;'>336</span>776 <span style='color: #555555;'>&lt;tbl [1 × 2]&gt;</span>      https://github.com/gaborc…</span></span>
<span><span class='c'>#&gt; </span></span>
<span><span class='c'>#&gt; $schema</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A data frame: 20 × 11</span></span></span>
<span><span class='c'>#&gt;    file_name       name         type  type_length repetition_type converted_type</span></span>
<span><span class='c'>#&gt;    <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>           <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>        <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>       <span style='color: #555555; font-style: italic;'>&lt;int&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>           <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>         </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 1</span> flights.parquet schema       <span style='color: #BB0000;'>NA</span>             <span style='color: #BB0000;'>NA</span> <span style='color: #BB0000;'>NA</span>              <span style='color: #BB0000;'>NA</span>            </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 2</span> flights.parquet year         INT32          <span style='color: #BB0000;'>NA</span> REQUIRED        INT_32        </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 3</span> flights.parquet month        INT32          <span style='color: #BB0000;'>NA</span> REQUIRED        INT_32        </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 4</span> flights.parquet day          INT32          <span style='color: #BB0000;'>NA</span> REQUIRED        INT_32        </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 5</span> flights.parquet dep_time     INT32          <span style='color: #BB0000;'>NA</span> OPTIONAL        INT_32        </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 6</span> flights.parquet sched_dep_t… INT32          <span style='color: #BB0000;'>NA</span> REQUIRED        INT_32        </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 7</span> flights.parquet dep_delay    DOUB…          <span style='color: #BB0000;'>NA</span> OPTIONAL        <span style='color: #BB0000;'>NA</span>            </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 8</span> flights.parquet arr_time     INT32          <span style='color: #BB0000;'>NA</span> OPTIONAL        INT_32        </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 9</span> flights.parquet sched_arr_t… INT32          <span style='color: #BB0000;'>NA</span> REQUIRED        INT_32        </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>10</span> flights.parquet arr_delay    DOUB…          <span style='color: #BB0000;'>NA</span> OPTIONAL        <span style='color: #BB0000;'>NA</span>            </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>11</span> flights.parquet carrier      BYTE…          <span style='color: #BB0000;'>NA</span> REQUIRED        UTF8          </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>12</span> flights.parquet flight       INT32          <span style='color: #BB0000;'>NA</span> REQUIRED        INT_32        </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>13</span> flights.parquet tailnum      BYTE…          <span style='color: #BB0000;'>NA</span> OPTIONAL        UTF8          </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>14</span> flights.parquet origin       BYTE…          <span style='color: #BB0000;'>NA</span> REQUIRED        UTF8          </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>15</span> flights.parquet dest         BYTE…          <span style='color: #BB0000;'>NA</span> REQUIRED        UTF8          </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>16</span> flights.parquet air_time     DOUB…          <span style='color: #BB0000;'>NA</span> OPTIONAL        <span style='color: #BB0000;'>NA</span>            </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>17</span> flights.parquet distance     DOUB…          <span style='color: #BB0000;'>NA</span> REQUIRED        <span style='color: #BB0000;'>NA</span>            </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>18</span> flights.parquet hour         DOUB…          <span style='color: #BB0000;'>NA</span> REQUIRED        <span style='color: #BB0000;'>NA</span>            </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>19</span> flights.parquet minute       DOUB…          <span style='color: #BB0000;'>NA</span> REQUIRED        <span style='color: #BB0000;'>NA</span>            </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>20</span> flights.parquet time_hour    INT64          <span style='color: #BB0000;'>NA</span> REQUIRED        TIMESTAMP_MIC…</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># ℹ 5 more variables: logical_type &lt;I&lt;list&gt;&gt;, num_children &lt;int&gt;, scale &lt;int&gt;,</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>#   precision &lt;int&gt;, field_id &lt;int&gt;</span></span></span>
<span><span class='c'>#&gt; </span></span>
<span><span class='c'>#&gt; $row_groups</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A data frame: 1 × 7</span></span></span>
<span><span class='c'>#&gt;   file_name        id total_byte_size num_rows file_offset total_compressed_size</span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>         <span style='color: #555555; font-style: italic;'>&lt;int&gt;</span>           <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>    <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>       <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>                 <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span> flights.parq…     0         5<span style='text-decoration: underline;'>732</span>430   <span style='text-decoration: underline;'>336</span>776          <span style='color: #BB0000;'>NA</span>                    <span style='color: #BB0000;'>NA</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># ℹ 1 more variable: ordinal &lt;int&gt;</span></span></span>
<span><span class='c'>#&gt; </span></span>
<span><span class='c'>#&gt; $column_chunks</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A data frame: 19 × 19</span></span></span>
<span><span class='c'>#&gt;    file_name       row_group column file_path file_offset offset_index_offset</span></span>
<span><span class='c'>#&gt;    <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>               <span style='color: #555555; font-style: italic;'>&lt;int&gt;</span>  <span style='color: #555555; font-style: italic;'>&lt;int&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>           <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>               <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 1</span> flights.parquet         0      0 <span style='color: #BB0000;'>NA</span>                 23                  <span style='color: #BB0000;'>NA</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 2</span> flights.parquet         0      1 <span style='color: #BB0000;'>NA</span>                111                  <span style='color: #BB0000;'>NA</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 3</span> flights.parquet         0      2 <span style='color: #BB0000;'>NA</span>                323                  <span style='color: #BB0000;'>NA</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 4</span> flights.parquet         0      3 <span style='color: #BB0000;'>NA</span>               <span style='text-decoration: underline;'>6</span>738                  <span style='color: #BB0000;'>NA</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 5</span> flights.parquet         0      4 <span style='color: #BB0000;'>NA</span>             <span style='text-decoration: underline;'>468</span>008                  <span style='color: #BB0000;'>NA</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 6</span> flights.parquet         0      5 <span style='color: #BB0000;'>NA</span>             <span style='text-decoration: underline;'>893</span>557                  <span style='color: #BB0000;'>NA</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 7</span> flights.parquet         0      6 <span style='color: #BB0000;'>NA</span>            1<span style='text-decoration: underline;'>312</span>660                  <span style='color: #BB0000;'>NA</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 8</span> flights.parquet         0      7 <span style='color: #BB0000;'>NA</span>            1<span style='text-decoration: underline;'>771</span>896                  <span style='color: #BB0000;'>NA</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 9</span> flights.parquet         0      8 <span style='color: #BB0000;'>NA</span>            2<span style='text-decoration: underline;'>237</span>931                  <span style='color: #BB0000;'>NA</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>10</span> flights.parquet         0      9 <span style='color: #BB0000;'>NA</span>            2<span style='text-decoration: underline;'>653</span>250                  <span style='color: #BB0000;'>NA</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>11</span> flights.parquet         0     10 <span style='color: #BB0000;'>NA</span>            2<span style='text-decoration: underline;'>847</span>249                  <span style='color: #BB0000;'>NA</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>12</span> flights.parquet         0     11 <span style='color: #BB0000;'>NA</span>            3<span style='text-decoration: underline;'>374</span>563                  <span style='color: #BB0000;'>NA</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>13</span> flights.parquet         0     12 <span style='color: #BB0000;'>NA</span>            3<span style='text-decoration: underline;'>877</span>832                  <span style='color: #BB0000;'>NA</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>14</span> flights.parquet         0     13 <span style='color: #BB0000;'>NA</span>            3<span style='text-decoration: underline;'>966</span>418                  <span style='color: #BB0000;'>NA</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>15</span> flights.parquet         0     14 <span style='color: #BB0000;'>NA</span>            4<span style='text-decoration: underline;'>264</span>662                  <span style='color: #BB0000;'>NA</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>16</span> flights.parquet         0     15 <span style='color: #BB0000;'>NA</span>            4<span style='text-decoration: underline;'>639</span>410                  <span style='color: #BB0000;'>NA</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>17</span> flights.parquet         0     16 <span style='color: #BB0000;'>NA</span>            4<span style='text-decoration: underline;'>976</span>781                  <span style='color: #BB0000;'>NA</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>18</span> flights.parquet         0     17 <span style='color: #BB0000;'>NA</span>            5<span style='text-decoration: underline;'>120</span>936                  <span style='color: #BB0000;'>NA</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>19</span> flights.parquet         0     18 <span style='color: #BB0000;'>NA</span>            5<span style='text-decoration: underline;'>427</span>022                  <span style='color: #BB0000;'>NA</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># ℹ 13 more variables: offset_index_length &lt;int&gt;, column_index_offset &lt;dbl&gt;,</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>#   column_index_length &lt;int&gt;, type &lt;chr&gt;, encodings &lt;I&lt;list&gt;&gt;,</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>#   path_in_schema &lt;I&lt;list&gt;&gt;, codec &lt;chr&gt;, num_values &lt;dbl&gt;,</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>#   total_uncompressed_size &lt;dbl&gt;, total_compressed_size &lt;dbl&gt;,</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>#   data_page_offset &lt;dbl&gt;, index_page_offset &lt;dbl&gt;,</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>#   dictionary_page_offset &lt;dbl&gt;</span></span></span>
<span></span></code></pre>

</div>

The output will include the schema, as above, but also data about the row groups ([`write_parquet()`](https://r-lib.github.io/nanoparquet/reference/write_parquet.html) always writes a single row group currently), and column chunks. There is one column chunk per column in each row group.

The columns chunk information also tells you whether a column chunk is dictionary encoded, its encoding, its size, etc.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>cc</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://r-lib.github.io/nanoparquet/reference/parquet_metadata.html'>parquet_metadata</a></span><span class='o'>(</span><span class='s'>"flights.parquet"</span><span class='o'>)</span><span class='o'>$</span><span class='nv'>column_chunks</span></span>
<span><span class='nv'>cc</span><span class='o'>[</span>, <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"column"</span>, <span class='s'>"encodings"</span>, <span class='s'>"dictionary_page_offset"</span><span class='o'>)</span><span class='o'>]</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A data frame: 19 × 3</span></span></span>
<span><span class='c'>#&gt;    column encodings dictionary_page_offset</span></span>
<span><span class='c'>#&gt;     <span style='color: #555555; font-style: italic;'>&lt;int&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;I&lt;list&gt;&gt;</span>                  <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 1</span>      0 <span style='color: #555555;'>&lt;chr [3]&gt;</span>                      4</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 2</span>      1 <span style='color: #555555;'>&lt;chr [3]&gt;</span>                     48</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 3</span>      2 <span style='color: #555555;'>&lt;chr [3]&gt;</span>                    181</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 4</span>      3 <span style='color: #555555;'>&lt;chr [3]&gt;</span>                   <span style='text-decoration: underline;'>1</span>445</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 5</span>      4 <span style='color: #555555;'>&lt;chr [3]&gt;</span>                 <span style='text-decoration: underline;'>463</span>903</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 6</span>      5 <span style='color: #555555;'>&lt;chr [3]&gt;</span>                 <span style='text-decoration: underline;'>891</span>412</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 7</span>      6 <span style='color: #555555;'>&lt;chr [3]&gt;</span>                1<span style='text-decoration: underline;'>306</span>995</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 8</span>      7 <span style='color: #555555;'>&lt;chr [3]&gt;</span>                1<span style='text-decoration: underline;'>767</span>223</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 9</span>      8 <span style='color: #555555;'>&lt;chr [3]&gt;</span>                2<span style='text-decoration: underline;'>235</span>594</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>10</span>      9 <span style='color: #555555;'>&lt;chr [3]&gt;</span>                2<span style='text-decoration: underline;'>653</span>154</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>11</span>     10 <span style='color: #555555;'>&lt;chr [3]&gt;</span>                2<span style='text-decoration: underline;'>831</span>850</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>12</span>     11 <span style='color: #555555;'>&lt;chr [3]&gt;</span>                3<span style='text-decoration: underline;'>352</span>496</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>13</span>     12 <span style='color: #555555;'>&lt;chr [3]&gt;</span>                3<span style='text-decoration: underline;'>877</span>796</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>14</span>     13 <span style='color: #555555;'>&lt;chr [3]&gt;</span>                3<span style='text-decoration: underline;'>965</span>856</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>15</span>     14 <span style='color: #555555;'>&lt;chr [3]&gt;</span>                4<span style='text-decoration: underline;'>262</span>597</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>16</span>     15 <span style='color: #555555;'>&lt;chr [3]&gt;</span>                4<span style='text-decoration: underline;'>638</span>461</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>17</span>     16 <span style='color: #555555;'>&lt;chr [3]&gt;</span>                4<span style='text-decoration: underline;'>976</span>675</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>18</span>     17 <span style='color: #555555;'>&lt;chr [3]&gt;</span>                5<span style='text-decoration: underline;'>120</span>660</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>19</span>     18 <span style='color: #555555;'>&lt;chr [3]&gt;</span>                5<span style='text-decoration: underline;'>379</span>476</span></span>
<span></span></code></pre>

</div>

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>cc</span><span class='o'>[[</span><span class='s'>"encodings"</span><span class='o'>]</span><span class='o'>]</span><span class='o'>[</span><span class='m'>1</span><span class='o'>:</span><span class='m'>3</span><span class='o'>]</span></span>
<span><span class='c'>#&gt; [[1]]</span></span>
<span><span class='c'>#&gt; [1] "PLAIN"          "RLE"            "RLE_DICTIONARY"</span></span>
<span><span class='c'>#&gt; </span></span>
<span><span class='c'>#&gt; [[2]]</span></span>
<span><span class='c'>#&gt; [1] "PLAIN"          "RLE"            "RLE_DICTIONARY"</span></span>
<span><span class='c'>#&gt; </span></span>
<span><span class='c'>#&gt; [[3]]</span></span>
<span><span class='c'>#&gt; [1] "PLAIN"          "RLE"            "RLE_DICTIONARY"</span></span>
<span></span></code></pre>

</div>

## Limitations

nanoparquet 0.3.0 has a number of limitations.

-   **Only flat tables**. [`read_parquet()`](https://r-lib.github.io/nanoparquet/reference/read_parquet.html) can only read flat tables, i.e. Parquet files without nested columns. (Technically all Parquet files are nested, and nanoparquet supports exactly one level of nesting: a single meta column that contains all other columns.) Similarly, [`write_parquet()`](https://r-lib.github.io/nanoparquet/reference/write_parquet.html) will not write list columns.

-   **Unsupported Parquet types**. [`read_parquet()`](https://r-lib.github.io/nanoparquet/reference/read_parquet.html) reads some Parquet types as raw vectors of a list column currently, e.g. `FLOAT16`, `INTERVAL`. See [the manual](https://r-lib.github.io/nanoparquet/reference/nanoparquet-types.html) for details.

-   **No encryption**. Encrypted Parquet files are not supported.

-   **Missing compression codecs**. `LZO`, `BROTLI` and `LZ4` compression is not yet supported.

-   **No statistics**. nanoparquet does not read or write statistics, e.g. minimum and maximum values from and to Parquet files.

-   **No checksums**. nanoparquet does not check or write checksums currently.

-   **No Bloom filters**. nanoparquet does not currently support reading or writing Bloom filters from or to Parquet files.

-   **May be slow for large files**. Being single-threaded and not fully optimized, nanoparquet is probably not suited well for large data sets. It should be fine for a couple of gigabytes. It may be fine if all the data fits into memory comfortably.

-   **Single row group**. [`write_parquet()`](https://r-lib.github.io/nanoparquet/reference/write_parquet.html) always creates a single row group, which is not optimal for large files.

-   **Automatic encoding**. It is currently not possible to choose encodings in [`write_parquet()`](https://r-lib.github.io/nanoparquet/reference/write_parquet.html) manually.

We are planning on solving these limitations, while keeping nanoparquet as lean as possible. In particular, if you find a Parquet file that nanoparquet cannot read, please report an issue in our [issue tracker](https://github.com/r-lib/nanoparquet/issues)!

## Other tools for Parquet files

If you run into some of these limitations, chances are you are dealing with a larget data set, and you will probably benefit from using tools geared towards larger Parquet files. Luckily you have several options.

### In R

#### Apache Arrow

You can usually install the `arrow` package from CRAN. Note, however, that some CRAN builds are suboptimal at the time of writing, e.g. the macOS builds lack Parquet support and it is best to install arrow from [R-universe](https://apache.r-universe.dev/arrow) on these platforms.

Call [`arrow::read_parquet()`](https://arrow.apache.org/docs/r/reference/read_parquet.html) to read Parquet files, and [`arrow::write_parquet()`](https://arrow.apache.org/docs/r/reference/write_parquet.html) to write them. You can also use [`arrow::open_dataset()`](https://arrow.apache.org/docs/r/reference/open_dataset.html) to open (one or more) Parquet files and perform queries on them without loading all data into memory.

#### DuckDB

DuckDB is an excellent tool that handles Parquet files seemlessly. You can install the duckdb R package from CRAN.

To read a Parquet file into an R data frame with DuckDB, call

``` r
df <- duckdb:::sql("FROM 'file.parquet'")
```

Alternatively, you can open (one or more) Parquet files and query them as a DuckDB database, potentially without reading all data into memory at once.

Here is an example that shows how to put an R data frame into a (temporary) DuckDB database, and how to export it to Parquet:

``` r
drv <- duckdb::duckdb()
con <- DBI::dbConnect(drv)
on.exit(DBI::dbDisconnect(con), add = TRUE)
DBI::dbWriteTable(con, "mtcars", mtcars)

DBI::dbExecute(con, DBI::sqlInterpolate(con,
  "COPY mtcars TO ?filename (FORMAT 'parquet', COMPRESSION 'snappy')",
  filename = 'mtcars.parquet'
))
```

### In Python

There are at least three good options to handle Parquet files in Python. Just like for R, the first two are [Apache Arrow](https://arrow.apache.org/docs/python/index.html) and [DuckDB](https://duckdb.org/docs/api/python/overview.html). You can also try the [fastparquet](https://pypi.org/project/fastparquet/) Python package for a potentially lighter solution.

## Acknowledgements

nanoparquet would not exist without the work of Hannes Mühleisen on [miniparquet](https://github.com/hannes/miniparquet), which had similar goals, but it is discontinued now. nanoparquet is a fork of miniparquet.

nanoparquet also contains code and test Parquet files from DuckDB, Apache Parquet, Apache Arrow, Apache Thrift, it contains libraries from Google, Facebook, etc. see the [COPYRIGHTS file](https://github.com/r-lib/nanoparquet/blob/main/inst/COPYRIGHTS) in the repository for the full details.

