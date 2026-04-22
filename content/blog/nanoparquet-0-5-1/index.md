---
output: hugodown::hugo_document

slug: nanoparquet-0-5-1
title: nanoparquet 0.5.1
date: 2026-04-22
author: Gábor Csárdi
description: >
    nanoparquet 0.5.1 (and 0.5.0) bring lots of bug fixes and some new
    features: reading and writing of list columns, bit64::integer64 and
    blob::blob support and the ability to write a parquet file to the
    standard output.

photo:
  url: https://pixabay.com/photos/chocolate-box-square-brown-white-7892542/
  author: ykaiavu

# one of: "deep-dive", "learn", "package", "programming", "roundup", or "other"
categories: [package]
tags: [package, parquet]
rmd_hash: e50fda8aab20dfa8

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

We're very chuffed to announce the release of [nanoparquet](https://nanoparquet.r-lib.org/) 0.5.1 (and 0.5.0). nanoparquet is a small, self-sufficient R package for reading and writing Parquet files.

You can install it from CRAN with:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://rdrr.io/r/utils/install.packages.html'>install.packages</a></span><span class='o'>(</span><span class='s'>"nanoparquet"</span><span class='o'>)</span></span></code></pre>

</div>

This blog post will go over some of the improvements in nanoparquet 0.5.0 and 0.5.1.

You can see a full list of changes in the release notes [here](https://github.com/r-lib/nanoparquet/releases/tag/v0.5.0) and [here](https://github.com/r-lib/nanoparquet/releases/tag/v0.5.1).

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://github.com/r-lib/nanoparquet'>nanoparquet</a></span><span class='o'>)</span></span></code></pre>

</div>

## List columns

Parquet has a `LIST` type for columns whose values are variable-length sequences of scalars. nanoparquet 0.5.0 adds support for reading and writing such columns.

> **Note:** for now nanoparquet supports one level of nesting: each element of a list column must be an atomic vector of a single type, not a list of lists. All elements in a column must have the same scalar type.

To write a list column, put a regular R list into your data frame. Each element must be an atomic vector (integer, double, or character), `NULL` for a missing list, or an empty vector for an empty list. `NA` values inside an element vector encode missing elements.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>df</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/data.frame.html'>data.frame</a></span><span class='o'>(</span>id <span class='o'>=</span> <span class='m'>1</span><span class='o'>:</span><span class='m'>4</span><span class='o'>)</span></span>
<span><span class='nv'>df</span><span class='o'>$</span><span class='nv'>scores</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='m'>80L</span>, <span class='m'>95L</span>, <span class='m'>70L</span><span class='o'>)</span>, <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='m'>100L</span><span class='o'>)</span>, <span class='kc'>NULL</span>, <span class='nf'><a href='https://rdrr.io/r/base/integer.html'>integer</a></span><span class='o'>(</span><span class='m'>0</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='nf'><a href='https://nanoparquet.r-lib.org/reference/write_parquet.html'>write_parquet</a></span><span class='o'>(</span><span class='nv'>df</span>, <span class='nv'>tmp</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/tempfile.html'>tempfile</a></span><span class='o'>(</span>fileext <span class='o'>=</span> <span class='s'>".parquet"</span><span class='o'>)</span><span class='o'>)</span></span></code></pre>

</div>

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://nanoparquet.r-lib.org/reference/read_parquet_schema.html'>read_parquet_schema</a></span><span class='o'>(</span><span class='nv'>tmp</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A data frame: 5 × 14</span></span></span>
<span><span class='c'>#&gt;   file_name  r_col name  r_type type  type_length repetition_type converted_type</span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>      <span style='color: #555555; font-style: italic;'>&lt;int&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>  <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>       <span style='color: #555555; font-style: italic;'>&lt;int&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>           <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>         </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span> /var/fold…    <span style='color: #BB0000;'>NA</span> sche… <span style='color: #BB0000;'>NA</span>     <span style='color: #BB0000;'>NA</span>             <span style='color: #BB0000;'>NA</span> <span style='color: #BB0000;'>NA</span>              <span style='color: #BB0000;'>NA</span>            </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span> /var/fold…     1 id    integ… INT32          <span style='color: #BB0000;'>NA</span> REQUIRED        INT_32        </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>3</span> /var/fold…     2 scor… list(… <span style='color: #BB0000;'>NA</span>             <span style='color: #BB0000;'>NA</span> OPTIONAL        LIST          </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>4</span> /var/fold…     2 list  <span style='color: #BB0000;'>NA</span>     <span style='color: #BB0000;'>NA</span>             <span style='color: #BB0000;'>NA</span> REPEATED        <span style='color: #BB0000;'>NA</span>            </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>5</span> /var/fold…     2 elem… <span style='color: #BB0000;'>NA</span>     INT32          <span style='color: #BB0000;'>NA</span> OPTIONAL        INT_32        </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># ℹ 6 more variables: logical_type &lt;I&lt;list&gt;&gt;, num_children &lt;int&gt;, scale &lt;int&gt;,</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>#   precision &lt;int&gt;, field_id &lt;int&gt;, children &lt;list&gt;</span></span></span>
<span></span></code></pre>

</div>

[`read_parquet()`](https://nanoparquet.r-lib.org/reference/read_parquet.html) reads `LIST` columns back as R list columns:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://rdrr.io/r/base/as.data.frame.html'>as.data.frame</a></span><span class='o'>(</span><span class='nf'><a href='https://nanoparquet.r-lib.org/reference/read_parquet.html'>read_parquet</a></span><span class='o'>(</span><span class='nv'>tmp</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='c'>#&gt;   id     scores</span></span>
<span><span class='c'>#&gt; 1  1 80, 95, 70</span></span>
<span><span class='c'>#&gt; 2  2        100</span></span>
<span><span class='c'>#&gt; 3  3       NULL</span></span>
<span><span class='c'>#&gt; 4  4</span></span>
<span></span></code></pre>

</div>

[`infer_parquet_schema()`](https://nanoparquet.r-lib.org/reference/infer_parquet_schema.html) shows how nanoparquet maps each column to a Parquet type. For list columns, the `r_type` shows e.g. `list(integer)`:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://nanoparquet.r-lib.org/reference/infer_parquet_schema.html'>infer_parquet_schema</a></span><span class='o'>(</span><span class='nv'>df</span><span class='o'>)</span><span class='o'>[</span><span class='m'>2</span><span class='o'>:</span><span class='m'>7</span><span class='o'>]</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A data frame: 4 × 6</span></span></span>
<span><span class='c'>#&gt;   r_col name    r_type        type  type_length repetition_type</span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;int&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>   <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>         <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>       <span style='color: #555555; font-style: italic;'>&lt;int&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>          </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span>     1 id      integer       INT32          <span style='color: #BB0000;'>NA</span> REQUIRED       </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span>     2 scores  list(integer) <span style='color: #BB0000;'>NA</span>             <span style='color: #BB0000;'>NA</span> OPTIONAL       </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>3</span>     2 list    <span style='color: #BB0000;'>NA</span>            <span style='color: #BB0000;'>NA</span>             <span style='color: #BB0000;'>NA</span> REPEATED       </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>4</span>     2 element <span style='color: #BB0000;'>NA</span>            INT32          <span style='color: #BB0000;'>NA</span> OPTIONAL</span></span>
<span></span></code></pre>

</div>

A `LIST` column occupies three rows in the schema: the outer list node, a repeated group node, and the leaf element node.

When you need to specify the element type explicitly, you can use [`parquet_schema()`](https://nanoparquet.r-lib.org/reference/parquet_schema.html):

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>schema</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://nanoparquet.r-lib.org/reference/parquet_schema.html'>parquet_schema</a></span><span class='o'>(</span></span>
<span>  id     <span class='o'>=</span> <span class='s'>"INT32"</span>,</span>
<span>  scores <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span><span class='s'>"LIST"</span>, element <span class='o'>=</span> <span class='s'>"INT32"</span><span class='o'>)</span></span>
<span><span class='o'>)</span></span>
<span><span class='nf'><a href='https://nanoparquet.r-lib.org/reference/write_parquet.html'>write_parquet</a></span><span class='o'>(</span><span class='nv'>df</span>, <span class='nv'>tmp2</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/tempfile.html'>tempfile</a></span><span class='o'>(</span>fileext <span class='o'>=</span> <span class='s'>".parquet"</span><span class='o'>)</span>, schema <span class='o'>=</span> <span class='nv'>schema</span><span class='o'>)</span></span></code></pre>

</div>

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://nanoparquet.r-lib.org/reference/read_parquet_schema.html'>read_parquet_schema</a></span><span class='o'>(</span><span class='nv'>tmp2</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A data frame: 5 × 14</span></span></span>
<span><span class='c'>#&gt;   file_name  r_col name  r_type type  type_length repetition_type converted_type</span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>      <span style='color: #555555; font-style: italic;'>&lt;int&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>  <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>       <span style='color: #555555; font-style: italic;'>&lt;int&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>           <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>         </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span> /var/fold…    <span style='color: #BB0000;'>NA</span> sche… <span style='color: #BB0000;'>NA</span>     <span style='color: #BB0000;'>NA</span>             <span style='color: #BB0000;'>NA</span> <span style='color: #BB0000;'>NA</span>              <span style='color: #BB0000;'>NA</span>            </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span> /var/fold…     1 id    integ… INT32          <span style='color: #BB0000;'>NA</span> REQUIRED        <span style='color: #BB0000;'>NA</span>            </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>3</span> /var/fold…     2 scor… list(… <span style='color: #BB0000;'>NA</span>             <span style='color: #BB0000;'>NA</span> OPTIONAL        LIST          </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>4</span> /var/fold…     2 list  <span style='color: #BB0000;'>NA</span>     <span style='color: #BB0000;'>NA</span>             <span style='color: #BB0000;'>NA</span> REPEATED        <span style='color: #BB0000;'>NA</span>            </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>5</span> /var/fold…     2 elem… <span style='color: #BB0000;'>NA</span>     INT32          <span style='color: #BB0000;'>NA</span> OPTIONAL        INT_32        </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># ℹ 6 more variables: logical_type &lt;I&lt;list&gt;&gt;, num_children &lt;int&gt;, scale &lt;int&gt;,</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>#   precision &lt;int&gt;, field_id &lt;int&gt;, children &lt;list&gt;</span></span></span>
<span></span></code></pre>

</div>

## New types

### `bit64::integer64`

Parquet's `INT64` type holds 64-bit integers. R's native `integer` is only 32 bits, so nanoparquet has mapped `INT64` to `double` by default. nanoparquet 0.5.1 adds support for [`bit64::integer64`](https://rdrr.io/pkg/bit64/man/bit64-package.html), which gives you true 64-bit integer arithmetic in R.

[`write_parquet()`](https://nanoparquet.r-lib.org/reference/write_parquet.html) now writes [`bit64::integer64`](https://rdrr.io/pkg/bit64/man/bit64-package.html) columns as `INT64`:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://github.com/r-lib/bit64'>bit64</a></span><span class='o'>)</span></span>
<span><span class='nv'>df2</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/data.frame.html'>data.frame</a></span><span class='o'>(</span>id <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/pkg/bit64/man/as.integer64.character.html'>as.integer64</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='m'>1e18</span>, <span class='m'>2e18</span>, <span class='m'>3e18</span><span class='o'>)</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='nf'><a href='https://nanoparquet.r-lib.org/reference/write_parquet.html'>write_parquet</a></span><span class='o'>(</span><span class='nv'>df2</span>, <span class='nv'>tmp3</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/tempfile.html'>tempfile</a></span><span class='o'>(</span>fileext <span class='o'>=</span> <span class='s'>".parquet"</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='nf'><a href='https://nanoparquet.r-lib.org/reference/read_parquet_schema.html'>read_parquet_schema</a></span><span class='o'>(</span><span class='nv'>tmp3</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A data frame: 2 × 14</span></span></span>
<span><span class='c'>#&gt;   file_name  r_col name  r_type type  type_length repetition_type converted_type</span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>      <span style='color: #555555; font-style: italic;'>&lt;int&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>  <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>       <span style='color: #555555; font-style: italic;'>&lt;int&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>           <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>         </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span> /var/fold…    <span style='color: #BB0000;'>NA</span> sche… <span style='color: #BB0000;'>NA</span>     <span style='color: #BB0000;'>NA</span>             <span style='color: #BB0000;'>NA</span> <span style='color: #BB0000;'>NA</span>              <span style='color: #BB0000;'>NA</span>            </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span> /var/fold…     1 id    double INT64          <span style='color: #BB0000;'>NA</span> REQUIRED        INT_64        </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># ℹ 6 more variables: logical_type &lt;I&lt;list&gt;&gt;, num_children &lt;int&gt;, scale &lt;int&gt;,</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>#   precision &lt;int&gt;, field_id &lt;int&gt;, children &lt;list&gt;</span></span></span>
<span></span></code></pre>

</div>

To read `INT64` columns back as [`bit64::integer64`](https://rdrr.io/pkg/bit64/man/bit64-package.html) instead of the default `double`, use the `read_int64_type` option. The bit64 package must be installed; if it isn't, nanoparquet throws a clear error.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://nanoparquet.r-lib.org/reference/read_parquet.html'>read_parquet</a></span><span class='o'>(</span><span class='nv'>tmp3</span>, options <span class='o'>=</span> <span class='nf'><a href='https://nanoparquet.r-lib.org/reference/parquet_options.html'>parquet_options</a></span><span class='o'>(</span>read_int64_type <span class='o'>=</span> <span class='s'>"integer64"</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A data frame: 3 × 1</span></span></span>
<span><span class='c'>#&gt;        id</span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;int64&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span>    0<span style='color: #555555;'>e</span>18</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span>    2<span style='color: #555555;'>e</span>18</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>3</span>    3<span style='color: #555555;'>e</span>18</span></span>
<span></span></code></pre>

</div>

### `blob::blob`

[`read_parquet()`](https://nanoparquet.r-lib.org/reference/read_parquet.html) previously returned raw `BYTE_ARRAY` and `FIXED_LEN_BYTE_ARRAY` columns (i.e. those without a string, UUID, or decimal annotation) as plain lists of raw vectors. They are now returned as [`blob::blob`](https://blob.tidyverse.org/reference/blob.html) objects, which print more neatly and come with the full set of blob helpers. [`write_parquet()`](https://nanoparquet.r-lib.org/reference/write_parquet.html) now also accepts [`blob::blob`](https://blob.tidyverse.org/reference/blob.html) columns, so round-tripping binary data is straightforward:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://blob.tidyverse.org'>blob</a></span><span class='o'>)</span></span>
<span><span class='nv'>df3</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/data.frame.html'>data.frame</a></span><span class='o'>(</span>id <span class='o'>=</span> <span class='m'>1</span><span class='o'>:</span><span class='m'>3</span><span class='o'>)</span></span>
<span><span class='nv'>df3</span><span class='o'>$</span><span class='nv'>payload</span> <span class='o'>&lt;-</span> <span class='nf'>blob</span><span class='nf'>::</span><span class='nf'><a href='https://blob.tidyverse.org/reference/blob.html'>blob</a></span><span class='o'>(</span></span>
<span>  <span class='nf'><a href='https://rdrr.io/r/base/rawConversion.html'>charToRaw</a></span><span class='o'>(</span><span class='s'>"hello"</span><span class='o'>)</span>,</span>
<span>  <span class='nf'><a href='https://rdrr.io/r/base/rawConversion.html'>charToRaw</a></span><span class='o'>(</span><span class='s'>"world"</span><span class='o'>)</span>,</span>
<span>  <span class='nf'><a href='https://rdrr.io/r/base/rawConversion.html'>charToRaw</a></span><span class='o'>(</span><span class='s'>"!"</span><span class='o'>)</span></span>
<span><span class='o'>)</span></span>
<span><span class='nf'><a href='https://nanoparquet.r-lib.org/reference/write_parquet.html'>write_parquet</a></span><span class='o'>(</span><span class='nv'>df3</span>, <span class='nv'>tmp4</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/tempfile.html'>tempfile</a></span><span class='o'>(</span>fileext <span class='o'>=</span> <span class='s'>".parquet"</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='nf'><a href='https://rdrr.io/r/base/as.data.frame.html'>as.data.frame</a></span><span class='o'>(</span><span class='nf'><a href='https://nanoparquet.r-lib.org/reference/read_parquet.html'>read_parquet</a></span><span class='o'>(</span><span class='nv'>tmp4</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='c'>#&gt;   id   payload</span></span>
<span><span class='c'>#&gt; 1  1 blob[5 B]</span></span>
<span><span class='c'>#&gt; 2  2 blob[5 B]</span></span>
<span><span class='c'>#&gt; 3  3 blob[1 B]</span></span>
<span></span></code></pre>

</div>

## nanoparquet as a filter

In Unix, a *filter* is a program that reads from standard input and writes to standard output, making it a composable building block in shell pipelines. [`write_parquet()`](https://nanoparquet.r-lib.org/reference/write_parquet.html) now supports writing to standard output via `file = ":stdout:"`:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://nanoparquet.r-lib.org/reference/write_parquet.html'>write_parquet</a></span><span class='o'>(</span><span class='nv'>mtcars</span>, <span class='s'>":stdout:"</span><span class='o'>)</span></span></code></pre>

</div>

The most common use case is from the command line:

``` sh
Rscript --quiet -e 'nanoparquet::write_parquet(mtcars, ":stdout:")' > mtcars.parquet
```

You can build this into a data pipeline. For example, to convert a CSV to Parquet, and then process Parquet with another tool in one shot, without an intermediate `.parquet` file on the disk, you can do:

``` sh
cat data.csv |
  Rscript --quiet -e '
    df <- read.csv(file("stdin"))
    nanoparquet::write_parquet(df, ":stdout:")
  ' | another-parquet-tool
```

Since nanoparquet 0.4.0, [`read_parquet()`](https://nanoparquet.r-lib.org/reference/read_parquet.html) can also read from an R connection, so you can pipe Parquet data *in* as well:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>url</span> <span class='o'>&lt;-</span> <span class='s'>"https://raw.githubusercontent.com/r-lib/nanoparquet/main/inst/extdata/userdata1.parquet"</span></span>
<span><span class='nv'>con</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/connections.html'>pipe</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/paste.html'>paste</a></span><span class='o'>(</span><span class='s'>"curl --silent"</span>, <span class='nv'>url</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='nv'>df</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://nanoparquet.r-lib.org/reference/read_parquet.html'>read_parquet</a></span><span class='o'>(</span><span class='nv'>con</span><span class='o'>)</span></span></code></pre>

</div>

## Acknowledgements

We thank all contributors to nanoparquet so far, for opening issues, submitting pull requests, and providing feedback: [@Aariq](https://github.com/Aariq), [@alvarocombo](https://github.com/alvarocombo), [@apalacio9502](https://github.com/apalacio9502), [@atsyplenkov](https://github.com/atsyplenkov), [@cboettig](https://github.com/cboettig), [@ChandlerLutz](https://github.com/ChandlerLutz), [@cmrnp](https://github.com/cmrnp), [@D3SL](https://github.com/D3SL), [@damonbayer](https://github.com/damonbayer), [@DavideMessinaARS](https://github.com/DavideMessinaARS), [@eitsupi](https://github.com/eitsupi), [@gksmyth](https://github.com/gksmyth), [@hadley](https://github.com/hadley), [@jack-davison](https://github.com/jack-davison), [@jeroenjanssens](https://github.com/jeroenjanssens), [@lbm364dl](https://github.com/lbm364dl), [@lschneiderbauer](https://github.com/lschneiderbauer), [@mrcaseb](https://github.com/mrcaseb), [@pmarks](https://github.com/pmarks), [@PMassicotte](https://github.com/PMassicotte), [@r2evans](https://github.com/r2evans), [@RealTYPICAL](https://github.com/RealTYPICAL), [@tanho63](https://github.com/tanho63), [@thisisnic](https://github.com/thisisnic), [@torfason](https://github.com/torfason), [@TurnaevEvgeny](https://github.com/TurnaevEvgeny), [@Upipa](https://github.com/Upipa), [@vankesteren](https://github.com/vankesteren), [@vincentarelbundock](https://github.com/vincentarelbundock), [@wlandau](https://github.com/wlandau), [@YipengUva](https://github.com/YipengUva), and [@yutannihilation](https://github.com/yutannihilation).

