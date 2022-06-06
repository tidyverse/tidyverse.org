---
output: hugodown::hugo_document

slug: dbplyr-2-2-0
title: dbplyr 2.2.0
date: 2022-06-06
author: Hadley Wickham
description: >
    This release brings improvements to SQL translation, a new
    way of getting local data into the database, and support for
    dplyr's family of row modification functions.

photo:
  url: https://unsplash.com/photos/lRoX0shwjUQ
  author: Jan Antonin Kolar

# one of: "deep-dive", "learn", "package", "programming", "roundup", or "other"
categories: [package] 
tags: [dplyr, dbplyr]
rmd_hash: 1a6cf774591580bf

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

We're chuffed to announce the release of [dbplyr](https://dbplyr.tidyverse.org) 2.2.0. dbplyr is a database backend for dplyr that allows you to use a remote database as if it was a collection of local data frames: you write ordinary dplyr code and dbplyr translates it to SQL for you.

You can install it from CRAN with:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://rdrr.io/r/utils/install.packages.html'>install.packages</a></span><span class='o'>(</span><span class='s'>"dbplyr"</span><span class='o'>)</span></code></pre>

</div>

This blog post will discuss some of the biggest improvements to SQL translations, introduce [`copy_inline()`](https://dbplyr.tidyverse.org/reference/copy_inline.html), and discuss support for dplyr's `rows_` functions. You can see a full list of changes in the [release notes](https://github.com/tidyverse/dbplyr/releases/tag/v2.2.0).

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://dbplyr.tidyverse.org/'>dbplyr</a></span><span class='o'>)</span>
<span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://dplyr.tidyverse.org'>dplyr</a></span>, warn.conflicts <span class='o'>=</span> <span class='kc'>FALSE</span><span class='o'>)</span></code></pre>

</div>

## SQL improvements

This release brings with it a host of useful improvements to SQL generation. Firstly, dbplyr uses `*` where possible. This is particularly nice when you have a table with many names:

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
  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/mutate.html'>mutate</a></span><span class='o'>(</span>x2 <span class='o'>=</span> <span class='nv'>x</span> <span class='o'>+</span> <span class='m'>1</span>, x3 <span class='o'>=</span> <span class='nv'>x2</span> <span class='o'>+</span> <span class='m'>1</span><span class='o'>)</span>
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
  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/mutate.html'>mutate</a></span><span class='o'>(</span>x2 <span class='o'>=</span> <span class='nv'>x</span> <span class='o'>+</span> <span class='m'>1</span>, x3 <span class='o'>=</span> <span class='nv'>x2</span> <span class='o'>+</span> <span class='m'>1</span><span class='o'>)</span> |&gt; 
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

[`copy_inline()`](https://dbplyr.tidyverse.org/reference/copy_inline.html) provides a new way to get data out of R and into the database by embedding the data directly in the query. This is a natural complement to [`copy_to()`](https://dplyr.tidyverse.org/reference/copy_to.html) which writes data to a temporary table. [`copy_inline()`](https://dbplyr.tidyverse.org/reference/copy_inline.html) is faster for small datasets and is particularly useful when you don't have the permissions needed to create temporary tables. Here's a very simple example of what the generated SQL will look like for PostgreSQL

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>df</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/data.frame.html'>data.frame</a></span><span class='o'>(</span>x <span class='o'>=</span> <span class='m'>1</span><span class='o'>:</span><span class='m'>5</span>, y <span class='o'>=</span> <span class='nv'>letters</span><span class='o'>[</span><span class='m'>1</span><span class='o'>:</span><span class='m'>5</span><span class='o'>]</span><span class='o'>)</span>
<span class='nf'><a href='https://dplyr.tidyverse.org/reference/explain.html'>show_query</a></span><span class='o'>(</span><span class='nf'><a href='https://dbplyr.tidyverse.org/reference/copy_inline.html'>copy_inline</a></span><span class='o'>(</span><span class='nf'><a href='https://dbplyr.tidyverse.org/reference/backend-postgres.html'>simulate_postgres</a></span><span class='o'>(</span><span class='o'>)</span>, <span class='nv'>df</span><span class='o'>)</span><span class='o'>)</span>
<span class='c'>#&gt; &lt;SQL&gt;</span>
<span class='c'>#&gt; <span style='color: #0000BB;'>SELECT</span> CAST(`x` AS INTEGER)<span style='color: #0000BB;'> AS </span>`x`, CAST(`y` AS TEXT)<span style='color: #0000BB;'> AS </span>`y`</span>
<span class='c'>#&gt; <span style='color: #0000BB;'>FROM</span> (  <span style='color: #0000BB;'>VALUES</span> (1, 'a'), (2, 'b'), (3, 'c'), (4, 'd'), (5, 'e')) AS drvd(`x`, `y`)</span></code></pre>

</div>

## Row modification

dplyr 1.0.0 added a family of [row modification](https://www.tidyverse.org/blog/2020/05/dplyr-1-0-0-last-minute-additions/#row-mutation) functions: [`rows_insert()`](https://dplyr.tidyverse.org/reference/rows.html), [`rows_append()`](https://dplyr.tidyverse.org/reference/rows.html), [`rows_update()`](https://dplyr.tidyverse.org/reference/rows.html), [`rows_patch()`](https://dplyr.tidyverse.org/reference/rows.html), [`rows_upsert()`](https://dplyr.tidyverse.org/reference/rows.html), and [`rows_delete()`](https://dplyr.tidyverse.org/reference/rows.html). These functions were inspired by SQL and are now supported by dbplyr.

The primary purpose of these functions is to modify the underlying tables. Because that purpose is dangerous, you'll need to deliberate opt-in to modification by setting `in_place = TRUE`. Use the default behaviour, `in_place = FALSE`, to simulate what the result will be.

With `in_place = FALSE`, [`rows_insert()`](https://dplyr.tidyverse.org/reference/rows.html) and [`rows_append()`](https://dplyr.tidyverse.org/reference/rows.html) performs an `INSERT`, [`rows_update()`](https://dplyr.tidyverse.org/reference/rows.html) and `rows_path()` perform an `UPDATE`, and [`rows_delete()`](https://dplyr.tidyverse.org/reference/rows.html) performs a `DELETE.`

## Acknowledgements

Most of the work in this release was done by dbplyr author [@mgirlich](https://github.com/mgirlich): thanks for all your continued hard work!

And a big thanks to all 77 other contributors who's comments, code, and discussion helped make a better package: [@001ben](https://github.com/001ben), [@1beb](https://github.com/1beb), [@Ada-Nick](https://github.com/Ada-Nick), [@admivsn](https://github.com/admivsn), [@alex-m-ffm](https://github.com/alex-m-ffm), [@andreassoteriadesmoj](https://github.com/andreassoteriadesmoj), [@andyquinterom](https://github.com/andyquinterom), [@apalacio10](https://github.com/apalacio10), [@apalacio9502](https://github.com/apalacio9502), [@aris-hastings](https://github.com/aris-hastings), [@asimumba](https://github.com/asimumba), [@ben1787](https://github.com/ben1787), [@boshek](https://github.com/boshek), [@caljnj](https://github.com/caljnj), [@carlganz](https://github.com/carlganz), [@CLRafaelR](https://github.com/CLRafaelR), [@coponhub](https://github.com/coponhub), [@cslewis04](https://github.com/cslewis04), [@dbaston](https://github.com/dbaston), [@dpprdan](https://github.com/dpprdan), [@DrFabach](https://github.com/DrFabach), [@EarlGlynn](https://github.com/EarlGlynn), [@edonnachie](https://github.com/edonnachie), [@eipi10](https://github.com/eipi10), [@eitsupi](https://github.com/eitsupi), [@fh-afrachioni](https://github.com/fh-afrachioni), [@fh-kpikhart](https://github.com/fh-kpikhart), [@ggpinto](https://github.com/ggpinto), [@GuillaumePressiat](https://github.com/GuillaumePressiat), [@hadley](https://github.com/hadley), [@HarlanH](https://github.com/HarlanH), [@hdplsa](https://github.com/hdplsa), [@iangow](https://github.com/iangow), [@James-G-Hill](https://github.com/James-G-Hill), [@jennybc](https://github.com/jennybc), [@jiaqizhu-learning](https://github.com/jiaqizhu-learning), [@jonkeane](https://github.com/jonkeane), [@jsspurgeon](https://github.com/jsspurgeon), [@julieinsan](https://github.com/julieinsan), [@k6adams](https://github.com/k6adams), [@kelnerrr](https://github.com/kelnerrr), [@kmishra9](https://github.com/kmishra9), [@krlmlr](https://github.com/krlmlr), [@Leprechault](https://github.com/Leprechault), [@Liudvikas-vinted](https://github.com/Liudvikas-vinted), [@LukasWallrich](https://github.com/LukasWallrich), [@m-sostero](https://github.com/m-sostero), [@maelle](https://github.com/maelle), [@mattcane](https://github.com/mattcane), [@mfherman](https://github.com/mfherman), [@mkoohafkan](https://github.com/mkoohafkan), [@Mosk915](https://github.com/Mosk915), [@nassuphis](https://github.com/nassuphis), [@nirski](https://github.com/nirski), [@nviets](https://github.com/nviets), [@overmar](https://github.com/overmar), [@p-schaefer](https://github.com/p-schaefer), [@plogacev](https://github.com/plogacev), [@randy3k](https://github.com/randy3k), [@recleev](https://github.com/recleev), [@rmcd1024](https://github.com/rmcd1024), [@rsund](https://github.com/rsund), [@rvomm](https://github.com/rvomm), [@samssann](https://github.com/samssann), [@sfirke](https://github.com/sfirke), [@Sir-Chibi](https://github.com/Sir-Chibi), [@sitendug](https://github.com/sitendug), [@somatusag](https://github.com/somatusag), [@stephenashton-dhsc](https://github.com/stephenashton-dhsc), [@swnydick](https://github.com/swnydick), [@thothal](https://github.com/thothal), [@torbjorn](https://github.com/torbjorn), [@tsengj](https://github.com/tsengj), [@vspinu](https://github.com/vspinu), [@Waftmaster](https://github.com/Waftmaster), [@williamlai2](https://github.com/williamlai2), and [@yitao-li](https://github.com/yitao-li).

