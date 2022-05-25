---
output: hugodown::hugo_document

slug: dbplyr-2-2-0
title: dbplyr 2.2.0
date: 2022-05-20
author: Hadley Wickham
description: >
    A 2-3 sentence description of the post that appears on the articles page.
    This can be omitted if it would just recapitulate the title.

photo:
  url: https://unsplash.com/photos/n6vS3xlnsCc
  author: Kelley Bozarth

# one of: "deep-dive", "learn", "package", "programming", "roundup", or "other"
categories: [package] 
tags: [dplyr, dbplyr]
rmd_hash: 7357fa08d6a9a56b

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

We're chuffed to announce the release of [dbplyr](https://dbplyr.tidyverse.org) 2.2.0. dbplyr is a database backend for dplyr that allows you to use a remote database as if it was a collection of local data frames: you write ordinary dplyr code and dbplyr translates it to SQL for you.

You can install it from CRAN with:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://rdrr.io/r/utils/install.packages.html'>install.packages</a></span><span class='o'>(</span><span class='s'>"dbplyr"</span><span class='o'>)</span></code></pre>

</div>

This blog post will discuss some of the biggest improvements to SQL translations introduce [`copy_inline()`](https://dbplyr.tidyverse.org/reference/copy_inline.html), and discuss support for dplyr's `row_` functions. You can see a full list of changes in the [release notes](https://github.com/tidyverse/dbplyr/releases/tag/v2.2.0).

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://dbplyr.tidyverse.org/'>dbplyr</a></span><span class='o'>)</span>
<span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://dplyr.tidyverse.org'>dplyr</a></span>, warn.conflicts <span class='o'>=</span> <span class='kc'>FALSE</span><span class='o'>)</span></code></pre>

</div>

## SQL improvements

This release brings with it a host of useful improvements to SQL generation. Firstly, where possible dbplyr now uses `*` rather than listing every column individually. This is particularly nice when you have a table with many names:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>lf</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://dbplyr.tidyverse.org/reference/tbl_lazy.html'>lazy_frame</a></span><span class='o'>(</span><span class='o'>!</span><span class='o'>!</span><span class='o'>!</span><span class='nf'><a href='https://rdrr.io/r/stats/setNames.html'>setNames</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/list.html'>as.list</a></span><span class='o'>(</span><span class='m'>1</span><span class='o'>:</span><span class='m'>26</span><span class='o'>)</span>, <span class='nv'>letters</span><span class='o'>)</span><span class='o'>)</span>
<span class='nv'>lf</span>
<span class='c'>#&gt; &lt;SQL&gt;</span>
<span class='c'>#&gt; <span style='color: #0000BB;'>SELECT</span> *</span>
<span class='c'>#&gt; <span style='color: #0000BB;'>FROM</span> `df`</span></code></pre>

</div>

If you're familiar with dbplyr's old SQL output, you'll also notice that the output receives some basic syntax highlighting and much improved line breaks and indenting.

The use of `*` is particularly nice when you have a subquery. Previously the generated SQL would have repeated the column names `a` to `z` twice, once for each subquery.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>lf</span> |&gt; 
  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/mutate.html'>mutate</a></span><span class='o'>(</span>x2 <span class='o'>=</span> <span class='nv'>x</span> <span class='o'>+</span> <span class='m'>1</span><span class='o'>)</span> |&gt; 
  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/mutate.html'>mutate</a></span><span class='o'>(</span>x3 <span class='o'>=</span> <span class='nv'>x2</span> <span class='o'>+</span> <span class='m'>1</span><span class='o'>)</span>
<span class='c'>#&gt; &lt;SQL&gt;</span>
<span class='c'>#&gt; <span style='color: #0000BB;'>SELECT</span> *, `x2` + 1.0<span style='color: #0000BB;'> AS </span>`x3`</span>
<span class='c'>#&gt; <span style='color: #0000BB;'>FROM</span> (</span>
<span class='c'>#&gt;   <span style='color: #0000BB;'>SELECT</span> *, `x` + 1.0<span style='color: #0000BB;'> AS </span>`x2`</span>
<span class='c'>#&gt;   <span style='color: #0000BB;'>FROM</span> `df`</span>
<span class='c'>#&gt; ) `q01`</span></code></pre>

</div>

[`show_query()`](https://dplyr.tidyverse.org/reference/explain.html), [`compute()`](https://dplyr.tidyverse.org/reference/compute.html) and [`collect()`](https://dplyr.tidyverse.org/reference/compute.html) have experimental support for common table expressions (CTEs), available by setting `cte = TRUE` argument. CTEs are the database equivalent of the pipe; they allow you to write subqueries in the order in which they're evaluated, rather than the opposite.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>lf</span> |&gt; 
  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/mutate.html'>mutate</a></span><span class='o'>(</span>x2 <span class='o'>=</span> <span class='nv'>x</span> <span class='o'>+</span> <span class='m'>1</span><span class='o'>)</span> |&gt; 
  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/mutate.html'>mutate</a></span><span class='o'>(</span>x3 <span class='o'>=</span> <span class='nv'>x2</span> <span class='o'>+</span> <span class='m'>1</span><span class='o'>)</span> |&gt; 
  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/explain.html'>show_query</a></span><span class='o'>(</span>cte <span class='o'>=</span> <span class='kc'>TRUE</span><span class='o'>)</span>
<span class='c'>#&gt; &lt;SQL&gt;</span>
<span class='c'>#&gt; <span style='color: #0000BB;'>WITH </span>`q01`<span style='color: #0000BB;'> AS</span> (</span>
<span class='c'>#&gt;   <span style='color: #0000BB;'>SELECT</span> *, `x` + 1.0<span style='color: #0000BB;'> AS </span>`x2`</span>
<span class='c'>#&gt;   <span style='color: #0000BB;'>FROM</span> `df`</span>
<span class='c'>#&gt; )</span>
<span class='c'>#&gt; <span style='color: #0000BB;'>SELECT</span> *, `x2` + 1.0<span style='color: #0000BB;'> AS </span>`x3`</span>
<span class='c'>#&gt; <span style='color: #0000BB;'>FROM</span> `q01`</span></code></pre>

</div>

We've also added support for translating [`cut()`](https://rdrr.io/r/base/cut.html): this is a very useful base R function that's fiddly to express in SQL:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>lf</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://dbplyr.tidyverse.org/reference/tbl_lazy.html'>lazy_frame</a></span><span class='o'>(</span>x <span class='o'>=</span> <span class='m'>1</span><span class='o'>)</span>

<span class='nf'><a href='https://dbplyr.tidyverse.org/reference/translate_sql.html'>translate_sql</a></span><span class='o'>(</span>
  <span class='nf'><a href='https://rdrr.io/r/base/cut.html'>cut</a></span><span class='o'>(</span><span class='nv'>x</span>, <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='m'>0</span>, <span class='m'>25</span>, <span class='m'>50</span>, <span class='m'>100</span><span class='o'>)</span><span class='o'>)</span>
<span class='o'>)</span>
<span class='c'>#&gt; &lt;SQL&gt; CASE</span>
<span class='c'>#&gt; WHEN (`x` &lt;= 0.0) THEN NULL</span>
<span class='c'>#&gt; WHEN (`x` &lt;= 25.0) THEN '(0,25]'</span>
<span class='c'>#&gt; WHEN (`x` &lt;= 50.0) THEN '(25,50]'</span>
<span class='c'>#&gt; WHEN (`x` &lt;= 100.0) THEN '(50,100]'</span>
<span class='c'>#&gt; WHEN (`x` &gt; 100.0) THEN NULL</span>
<span class='c'>#&gt; END</span>
  
<span class='c'># Can provide custom labels</span>
<span class='nf'><a href='https://dbplyr.tidyverse.org/reference/translate_sql.html'>translate_sql</a></span><span class='o'>(</span>
  <span class='nf'><a href='https://rdrr.io/r/base/cut.html'>cut</a></span><span class='o'>(</span><span class='nv'>x</span>, <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='m'>0</span>, <span class='m'>25</span>, <span class='m'>50</span>, <span class='m'>100</span><span class='o'>)</span>, labels <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"small"</span>, <span class='s'>"medium"</span>, <span class='s'>"large"</span><span class='o'>)</span><span class='o'>)</span>
<span class='o'>)</span>
<span class='c'>#&gt; &lt;SQL&gt; CASE</span>
<span class='c'>#&gt; WHEN (`x` &lt;= 0.0) THEN NULL</span>
<span class='c'>#&gt; WHEN (`x` &lt;= 25.0) THEN 'small'</span>
<span class='c'>#&gt; WHEN (`x` &lt;= 50.0) THEN 'medium'</span>
<span class='c'>#&gt; WHEN (`x` &lt;= 100.0) THEN 'large'</span>
<span class='c'>#&gt; WHEN (`x` &gt; 100.0) THEN NULL</span>
<span class='c'>#&gt; END</span>

<span class='c'># And use Inf/-Inf bounds</span>
<span class='nf'><a href='https://dbplyr.tidyverse.org/reference/translate_sql.html'>translate_sql</a></span><span class='o'>(</span>
  <span class='nf'><a href='https://rdrr.io/r/base/cut.html'>cut</a></span><span class='o'>(</span>
    <span class='nv'>x</span>, 
    breaks <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='o'>-</span><span class='kc'>Inf</span>, <span class='m'>25</span>, <span class='m'>50</span>, <span class='kc'>Inf</span><span class='o'>)</span>, 
    labels <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"small"</span>, <span class='s'>"medium"</span>, <span class='s'>"large"</span><span class='o'>)</span>
  <span class='o'>)</span>
<span class='o'>)</span>
<span class='c'>#&gt; &lt;SQL&gt; CASE</span>
<span class='c'>#&gt; WHEN (`x` &lt;= 25.0) THEN 'small'</span>
<span class='c'>#&gt; WHEN (`x` &lt;= 50.0) THEN 'medium'</span>
<span class='c'>#&gt; WHEN (`x` &gt; 50.0) THEN 'large'</span>
<span class='c'>#&gt; END</span></code></pre>

</div>

There are also a whole host of minor translation improvements which you can read about in the [release notes](https://github.com/tidyverse/dbplyr/releases/tag/v2.2.0).

## `copy_inline()`

[`copy_inline()`](https://dbplyr.tidyverse.org/reference/copy_inline.html) provides a new way to get data out of R and into the database by embedding the data directly in the query. This is a natural complement to [`copy_to()`](https://dplyr.tidyverse.org/reference/copy_to.html) which writes data to a table temporary table. [`copy_inline()`](https://dbplyr.tidyverse.org/reference/copy_inline.html) is useful when you don't have the ability to create temporary tables and it's typically faster for small datasets.

As shown below, the SQL it generates is a bit of a mouthful but it should work on a very wide range of databases. As far we can tell, all three steps are necessary: we need to provide the data, then name each column, then ensure that the types are correct.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>df</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/data.frame.html'>data.frame</a></span><span class='o'>(</span>x <span class='o'>=</span> <span class='m'>1</span><span class='o'>:</span><span class='m'>5</span>, y <span class='o'>=</span> <span class='nv'>letters</span><span class='o'>[</span><span class='m'>1</span><span class='o'>:</span><span class='m'>5</span><span class='o'>]</span><span class='o'>)</span>
<span class='nf'><a href='https://dplyr.tidyverse.org/reference/explain.html'>show_query</a></span><span class='o'>(</span><span class='nf'><a href='https://dbplyr.tidyverse.org/reference/copy_inline.html'>copy_inline</a></span><span class='o'>(</span><span class='nf'><a href='https://dbplyr.tidyverse.org/reference/backend-postgres.html'>simulate_postgres</a></span><span class='o'>(</span><span class='o'>)</span>, <span class='nv'>df</span><span class='o'>)</span><span class='o'>)</span>
<span class='c'>#&gt; &lt;SQL&gt;</span>
<span class='c'>#&gt; <span style='color: #0000BB;'>SELECT</span> CAST(`x` AS INTEGER)<span style='color: #0000BB;'> AS </span>`x`, CAST(`y` AS TEXT)<span style='color: #0000BB;'> AS </span>`y`</span>
<span class='c'>#&gt; <span style='color: #0000BB;'>FROM</span> (</span>
<span class='c'>#&gt;   (</span>
<span class='c'>#&gt;     <span style='color: #0000BB;'>SELECT</span> NULL<span style='color: #0000BB;'> AS </span>`x`, NULL<span style='color: #0000BB;'> AS </span>`y`</span>
<span class='c'>#&gt;     <span style='color: #0000BB;'>WHERE</span> (0 = 1)</span>
<span class='c'>#&gt;   )</span>
<span class='c'>#&gt;   <span style='color: #0000BB;'>UNION ALL</span></span>
<span class='c'>#&gt;   (<span style='color: #0000BB;'>VALUES</span> (1, 'a'), (2, 'b'), (3, 'c'), (4, 'd'), (5, 'e'))</span>
<span class='c'>#&gt; ) `values_table`</span></code></pre>

</div>

## Row modification

dplyr 1.0.0 added a family of [row modification](https://www.tidyverse.org/blog/2020/05/dplyr-1-0-0-last-minute-additions/#row-mutation) functions, [`rows_insert()`](https://dplyr.tidyverse.org/reference/rows.html), [`rows_append()`](https://dplyr.tidyverse.org/reference/rows.html), [`rows_update()`](https://dplyr.tidyverse.org/reference/rows.html), [`rows_patch()`](https://dplyr.tidyverse.org/reference/rows.html), [`rows_upsert()`](https://dplyr.tidyverse.org/reference/rows.html), and [`rows_delete()`](https://dplyr.tidyverse.org/reference/rows.html). These were inspired by SQL and are now supported by dbplyr.

The primary purpose of these functions is to modify the underlying tables, but that purpose is potential dangerous so you'll need to deliberate opt-in to modification by setting `in_place = TRUE`. You can use the default behaviour, `in_place = FALSE`, to simulate what the result will be.

With `in_place = FALSE`, [`rows_insert()`](https://dplyr.tidyverse.org/reference/rows.html) and [`rows_append()`](https://dplyr.tidyverse.org/reference/rows.html) performs an `INSERT`, [`rows_update()`](https://dplyr.tidyverse.org/reference/rows.html) and `rows_path()` perform an `UPDATE`, and [`rows_delete()`](https://dplyr.tidyverse.org/reference/rows.html) performs a `DELETE.`

## Acknowledgements

