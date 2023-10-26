---
output: hugodown::hugo_document

slug: dbplyr-2-4-0
title: dbplyr 2.4.0
date: 2023-10-26
author: Hadley Wickham
description: >
    dbplyr 2.4.0 brings improvements to SQL generation, better control over the
    generated SQL, some new translations, and a bunch of backend specific improvements.

photo:
  url: https://unsplash.com/photos/AJqaubLEaN4
  author: Parker Hilton

# one of: "deep-dive", "learn", "package", "programming", "roundup", or "other"
categories: [package] 
tags: [dplyr, dbplyr]
rmd_hash: aeeed6ebb47070fa

---

<!--
* also include something about dbplyr 2.3.1?
  * support for [`join_by()`](https://dplyr.tidyverse.org/reference/join_by.html)
  * many bugs introduced in 2.3.0 fixed

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

We're chuffed to announce the release of [dbplyr](http://dbplyr.tidyverse.org/) 2.4.0. dbplyr is a database backend for dplyr that allows you to use a remote database as if it was a collection of local data frames: you write ordinary dplyr code and dbplyr translates it to SQL for you.

You can install it from CRAN with:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://rdrr.io/r/utils/install.packages.html'>install.packages</a></span><span class='o'>(</span><span class='s'>"dbplyr"</span><span class='o'>)</span></span></code></pre>

</div>

This blog post will highlight some of the most important new features: eliminating subqueries when using multiple unions in a row, getting more control on the generated SQL, and a handful of new translations. As usual, release comes with a large number of improvements to translations for individual backends; see the full list in the [release notes](https://github.com/tidyverse/dbplyr/releases/tag/v2.4.0)

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://dbplyr.tidyverse.org/'>dbplyr</a></span><span class='o'>)</span></span>
<span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://dplyr.tidyverse.org'>dplyr</a></span>, warn.conflicts <span class='o'>=</span> <span class='kc'>FALSE</span><span class='o'>)</span></span></code></pre>

</div>

## SQL optimisation

dbplyr now produces fewer subqueries when combining tables with [`union()`](https://generics.r-lib.org/reference/setops.html) and [`union_all()`](https://dplyr.tidyverse.org/reference/setops.html) resulting in shorter, more readable, and, in some cases, faster SQL.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>lf1</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://dbplyr.tidyverse.org/reference/tbl_lazy.html'>lazy_frame</a></span><span class='o'>(</span>x <span class='o'>=</span> <span class='m'>1</span>, y <span class='o'>=</span> <span class='s'>"a"</span>, .name <span class='o'>=</span> <span class='s'>"lf1"</span><span class='o'>)</span></span>
<span><span class='nv'>lf2</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://dbplyr.tidyverse.org/reference/tbl_lazy.html'>lazy_frame</a></span><span class='o'>(</span>x <span class='o'>=</span> <span class='m'>1</span>, y <span class='o'>=</span> <span class='s'>"b"</span>, .name <span class='o'>=</span> <span class='s'>"lf2"</span><span class='o'>)</span></span>
<span><span class='nv'>lf3</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://dbplyr.tidyverse.org/reference/tbl_lazy.html'>lazy_frame</a></span><span class='o'>(</span>x <span class='o'>=</span> <span class='m'>1</span>, z <span class='o'>=</span> <span class='s'>"c"</span>, .name <span class='o'>=</span> <span class='s'>"lf3"</span><span class='o'>)</span></span>
<span></span>
<span><span class='nv'>lf1</span> <span class='o'>|&gt;</span> </span>
<span>  <span class='nf'><a href='https://generics.r-lib.org/reference/setops.html'>union</a></span><span class='o'>(</span><span class='nv'>lf2</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://generics.r-lib.org/reference/setops.html'>union</a></span><span class='o'>(</span><span class='nv'>lf3</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; &lt;SQL&gt;</span></span>
<span><span class='c'>#&gt; <span style='color: #0000BB;'>SELECT</span> `lf1`.*, NULL<span style='color: #0000BB;'> AS </span>`z`</span></span>
<span><span class='c'>#&gt; <span style='color: #0000BB;'>FROM</span> `lf1`</span></span>
<span><span class='c'>#&gt; </span></span>
<span><span class='c'>#&gt; <span style='color: #0000BB;'>UNION</span></span></span>
<span><span class='c'>#&gt; </span></span>
<span><span class='c'>#&gt; <span style='color: #0000BB;'>SELECT</span> `lf2`.*, NULL<span style='color: #0000BB;'> AS </span>`z`</span></span>
<span><span class='c'>#&gt; <span style='color: #0000BB;'>FROM</span> `lf2`</span></span>
<span><span class='c'>#&gt; </span></span>
<span><span class='c'>#&gt; <span style='color: #0000BB;'>UNION</span></span></span>
<span><span class='c'>#&gt; </span></span>
<span><span class='c'>#&gt; <span style='color: #0000BB;'>SELECT</span> `x`, NULL<span style='color: #0000BB;'> AS </span>`y`, `z`</span></span>
<span><span class='c'>#&gt; <span style='color: #0000BB;'>FROM</span> `lf3`</span></span>
<span></span></code></pre>

</div>

(As usual in these blog posts, I'm using [`lazy_frame()`](https://dbplyr.tidyverse.org/reference/tbl_lazy.html) to focus on the SQL generation, without having to set up a dummy database.)

Similarly, a `semi/anti_join()` on a filtered table now avoids a subquery:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>lf1</span> <span class='o'>|&gt;</span> </span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/filter-joins.html'>semi_join</a></span><span class='o'>(</span><span class='nv'>lf3</span> <span class='o'>|&gt;</span> <span class='nf'><a href='https://dplyr.tidyverse.org/reference/filter.html'>filter</a></span><span class='o'>(</span><span class='nv'>z</span> <span class='o'>==</span> <span class='s'>"c"</span><span class='o'>)</span>, <span class='nf'><a href='https://dplyr.tidyverse.org/reference/join_by.html'>join_by</a></span><span class='o'>(</span><span class='nv'>x</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; &lt;SQL&gt;</span></span>
<span><span class='c'>#&gt; <span style='color: #0000BB;'>SELECT</span> `lf1`.*</span></span>
<span><span class='c'>#&gt; <span style='color: #0000BB;'>FROM</span> `lf1`</span></span>
<span><span class='c'>#&gt; WHERE EXISTS (</span></span>
<span><span class='c'>#&gt;   <span style='color: #0000BB;'>SELECT 1 FROM</span> `lf3`</span></span>
<span><span class='c'>#&gt;   <span style='color: #0000BB;'>WHERE</span> (`lf1`.`x` = `lf3`.`x`)<span style='color: #0000BB;'> AND</span> (`lf3`.`z` = 'c')</span></span>
<span><span class='c'>#&gt; )</span></span>
<span></span></code></pre>

</div>

## SQL generation

The new argument `sql_options` for [`show_query()`](https://dplyr.tidyverse.org/reference/explain.html) and [`remote_query()`](https://dbplyr.tidyverse.org/reference/remote_name.html) gives you more control on the generated SQL.

-   By default dbplyr uses `*` to select all columns of a table, but with `use_star = FALSE` all columns are selected explicitly:

    <div class="highlight">

    <pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>lf3</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://dbplyr.tidyverse.org/reference/tbl_lazy.html'>lazy_frame</a></span><span class='o'>(</span>x <span class='o'>=</span> <span class='m'>1</span>, y <span class='o'>=</span> <span class='m'>2</span>, z <span class='o'>=</span> <span class='m'>3</span>, .name <span class='o'>=</span> <span class='s'>"lf3"</span><span class='o'>)</span></span>
    <span><span class='nv'>lf3</span> <span class='o'>|&gt;</span> </span>
    <span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/mutate.html'>mutate</a></span><span class='o'>(</span>a <span class='o'>=</span> <span class='m'>4</span><span class='o'>)</span></span>
    <span><span class='c'>#&gt; &lt;SQL&gt;</span></span>
    <span><span class='c'>#&gt; <span style='color: #0000BB;'>SELECT</span> `lf3`.*, 4.0<span style='color: #0000BB;'> AS </span>`a`</span></span>
    <span><span class='c'>#&gt; <span style='color: #0000BB;'>FROM</span> `lf3`</span></span>
    <span></span><span></span>
    <span><span class='nv'>lf3</span> <span class='o'>|&gt;</span> </span>
    <span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/mutate.html'>mutate</a></span><span class='o'>(</span>a <span class='o'>=</span> <span class='m'>4</span><span class='o'>)</span> <span class='o'>|&gt;</span> </span>
    <span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/explain.html'>show_query</a></span><span class='o'>(</span>sql_options <span class='o'>=</span> <span class='nf'><a href='https://dbplyr.tidyverse.org/reference/sql_options.html'>sql_options</a></span><span class='o'>(</span>use_star <span class='o'>=</span> <span class='kc'>FALSE</span><span class='o'>)</span><span class='o'>)</span></span>
    <span><span class='c'>#&gt; &lt;SQL&gt;</span></span>
    <span><span class='c'>#&gt; <span style='color: #0000BB;'>SELECT</span> `x`, `y`, `z`, 4.0<span style='color: #0000BB;'> AS </span>`a`</span></span>
    <span><span class='c'>#&gt; <span style='color: #0000BB;'>FROM</span> `lf3`</span></span>
    <span></span></code></pre>

    </div>

-   If you prefer common table expressions (CTE) over subqueries use `cte = TRUE`:

    <div class="highlight">

    <pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>nested_query</span> <span class='o'>&lt;-</span> <span class='nv'>lf3</span> <span class='o'>|&gt;</span> </span>
    <span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/mutate.html'>mutate</a></span><span class='o'>(</span>z <span class='o'>=</span> <span class='nv'>z</span> <span class='o'>+</span> <span class='m'>1</span><span class='o'>)</span> <span class='o'>|&gt;</span> </span>
    <span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/mutate-joins.html'>left_join</a></span><span class='o'>(</span><span class='nv'>lf2</span>, by <span class='o'>=</span> <span class='nf'><a href='https://dplyr.tidyverse.org/reference/join_by.html'>join_by</a></span><span class='o'>(</span><span class='nv'>x</span>, <span class='nv'>y</span><span class='o'>)</span><span class='o'>)</span></span>
    <span><span class='nv'>nested_query</span></span>
    <span><span class='c'>#&gt; &lt;SQL&gt;</span></span>
    <span><span class='c'>#&gt; <span style='color: #0000BB;'>SELECT</span> `LHS`.*</span></span>
    <span><span class='c'>#&gt; <span style='color: #0000BB;'>FROM</span> (</span></span>
    <span><span class='c'>#&gt;   <span style='color: #0000BB;'>SELECT</span> `x`, `y`, `z` + 1.0<span style='color: #0000BB;'> AS </span>`z`</span></span>
    <span><span class='c'>#&gt;   <span style='color: #0000BB;'>FROM</span> `lf3`</span></span>
    <span><span class='c'>#&gt; )<span style='color: #0000BB;'> AS </span>`LHS`</span></span>
    <span><span class='c'>#&gt; <span style='color: #0000BB;'>LEFT JOIN</span> `lf2`</span></span>
    <span><span class='c'>#&gt;   <span style='color: #0000BB;'>ON</span> (`LHS`.`x` = `lf2`.`x`<span style='color: #0000BB;'> AND</span> `LHS`.`y` = `lf2`.`y`)</span></span>
    <span></span><span></span>
    <span><span class='nv'>nested_query</span> <span class='o'>|&gt;</span> </span>
    <span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/explain.html'>show_query</a></span><span class='o'>(</span>sql_options <span class='o'>=</span> <span class='nf'><a href='https://dbplyr.tidyverse.org/reference/sql_options.html'>sql_options</a></span><span class='o'>(</span>cte <span class='o'>=</span> <span class='kc'>TRUE</span><span class='o'>)</span><span class='o'>)</span></span>
    <span><span class='c'>#&gt; &lt;SQL&gt;</span></span>
    <span><span class='c'>#&gt; <span style='color: #0000BB;'>WITH</span> `q01` <span style='color: #0000BB;'>AS</span> (</span></span>
    <span><span class='c'>#&gt;   <span style='color: #0000BB;'>SELECT</span> `x`, `y`, `z` + 1.0<span style='color: #0000BB;'> AS </span>`z`</span></span>
    <span><span class='c'>#&gt;   <span style='color: #0000BB;'>FROM</span> `lf3`</span></span>
    <span><span class='c'>#&gt; )</span></span>
    <span><span class='c'>#&gt; <span style='color: #0000BB;'>SELECT</span> `LHS`.*</span></span>
    <span><span class='c'>#&gt; <span style='color: #0000BB;'>FROM</span> `q01`<span style='color: #0000BB;'> AS </span>`LHS`</span></span>
    <span><span class='c'>#&gt; <span style='color: #0000BB;'>LEFT JOIN</span> `lf2`</span></span>
    <span><span class='c'>#&gt;   <span style='color: #0000BB;'>ON</span> (`LHS`.`x` = `lf2`.`x`<span style='color: #0000BB;'> AND</span> `LHS`.`y` = `lf2`.`y`)</span></span>
    <span></span></code></pre>

    </div>

-   And if you want that all columns in a join are qualified with the table name and not only the ambiguous ones use `qualify_all_columns = TRUE`:

    <div class="highlight">

    <pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>qualify_columns</span> <span class='o'>&lt;-</span> <span class='nv'>lf2</span> <span class='o'>|&gt;</span> </span>
    <span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/mutate-joins.html'>left_join</a></span><span class='o'>(</span><span class='nv'>lf3</span>, by <span class='o'>=</span> <span class='nf'><a href='https://dplyr.tidyverse.org/reference/join_by.html'>join_by</a></span><span class='o'>(</span><span class='nv'>x</span>, <span class='nv'>y</span><span class='o'>)</span><span class='o'>)</span></span>
    <span></span>
    <span><span class='nv'>qualify_columns</span></span>
    <span><span class='c'>#&gt; &lt;SQL&gt;</span></span>
    <span><span class='c'>#&gt; <span style='color: #0000BB;'>SELECT</span> `lf2`.*, `z`</span></span>
    <span><span class='c'>#&gt; <span style='color: #0000BB;'>FROM</span> `lf2`</span></span>
    <span><span class='c'>#&gt; <span style='color: #0000BB;'>LEFT JOIN</span> `lf3`</span></span>
    <span><span class='c'>#&gt;   <span style='color: #0000BB;'>ON</span> (`lf2`.`x` = `lf3`.`x`<span style='color: #0000BB;'> AND</span> `lf2`.`y` = `lf3`.`y`)</span></span>
    <span></span><span></span>
    <span><span class='nv'>qualify_columns</span> <span class='o'>|&gt;</span> </span>
    <span>   <span class='nf'><a href='https://dplyr.tidyverse.org/reference/explain.html'>show_query</a></span><span class='o'>(</span>sql_options <span class='o'>=</span> <span class='nf'><a href='https://dbplyr.tidyverse.org/reference/sql_options.html'>sql_options</a></span><span class='o'>(</span>qualify_all_columns <span class='o'>=</span> <span class='kc'>TRUE</span><span class='o'>)</span><span class='o'>)</span></span>
    <span><span class='c'>#&gt; &lt;SQL&gt;</span></span>
    <span><span class='c'>#&gt; <span style='color: #0000BB;'>SELECT</span> `lf2`.*, `lf3`.`z`<span style='color: #0000BB;'> AS </span>`z`</span></span>
    <span><span class='c'>#&gt; <span style='color: #0000BB;'>FROM</span> `lf2`</span></span>
    <span><span class='c'>#&gt; <span style='color: #0000BB;'>LEFT JOIN</span> `lf3`</span></span>
    <span><span class='c'>#&gt;   <span style='color: #0000BB;'>ON</span> (`lf2`.`x` = `lf3`.`x`<span style='color: #0000BB;'> AND</span> `lf2`.`y` = `lf3`.`y`)</span></span>
    <span></span></code></pre>

    </div>

## New translations

`str_detect()`, `str_starts()` and `str_ends()` with fixed patterns are translated to `INSTR()`:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>lf1</span> <span class='o'>|&gt;</span> </span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/filter.html'>filter</a></span><span class='o'>(</span></span>
<span>    <span class='nf'>stringr</span><span class='nf'>::</span><span class='nf'><a href='https://stringr.tidyverse.org/reference/str_detect.html'>str_detect</a></span><span class='o'>(</span><span class='nv'>x</span>, <span class='nf'>stringr</span><span class='nf'>::</span><span class='nf'><a href='https://stringr.tidyverse.org/reference/modifiers.html'>fixed</a></span><span class='o'>(</span><span class='s'>"abc"</span><span class='o'>)</span><span class='o'>)</span>,</span>
<span>    <span class='nf'>stringr</span><span class='nf'>::</span><span class='nf'><a href='https://stringr.tidyverse.org/reference/str_starts.html'>str_starts</a></span><span class='o'>(</span><span class='nv'>x</span>, <span class='nf'>stringr</span><span class='nf'>::</span><span class='nf'><a href='https://stringr.tidyverse.org/reference/modifiers.html'>fixed</a></span><span class='o'>(</span><span class='s'>"a"</span><span class='o'>)</span><span class='o'>)</span></span>
<span>  <span class='o'>)</span></span>
<span><span class='c'>#&gt; &lt;SQL&gt;</span></span>
<span><span class='c'>#&gt; <span style='color: #0000BB;'>SELECT</span> `lf1`.*</span></span>
<span><span class='c'>#&gt; <span style='color: #0000BB;'>FROM</span> `lf1`</span></span>
<span><span class='c'>#&gt; <span style='color: #0000BB;'>WHERE</span> (INSTR(`x`, 'abc') &gt; 0)<span style='color: #0000BB;'> AND</span> (INSTR(`x`, 'a') = 1)</span></span>
<span></span></code></pre>

</div>

And [`nzchar()`](https://rdrr.io/r/base/nchar.html) and [`runif()`](https://rdrr.io/r/stats/Uniform.html) are now translated to their SQL equivalents:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>lf1</span> <span class='o'>|&gt;</span> </span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/filter.html'>filter</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/nchar.html'>nzchar</a></span><span class='o'>(</span><span class='nv'>x</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>|&gt;</span> </span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/mutate.html'>mutate</a></span><span class='o'>(</span>z <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/stats/Uniform.html'>runif</a></span><span class='o'>(</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; &lt;SQL&gt;</span></span>
<span><span class='c'>#&gt; <span style='color: #0000BB;'>SELECT</span> `lf1`.*, RANDOM()<span style='color: #0000BB;'> AS </span>`z`</span></span>
<span><span class='c'>#&gt; <span style='color: #0000BB;'>FROM</span> `lf1`</span></span>
<span><span class='c'>#&gt; <span style='color: #0000BB;'>WHERE</span> (((`x` IS NULL) OR `x` != ''))</span></span>
<span></span></code></pre>

</div>

## Acknowledgements

The vast majority of this release (particularly the SQL optimisations) are from [Maximilian Girlich](https://github.com/mgirlich); thanks so much for continued work on this package! And a big thanks go to the 84 other folks who helped out by filing issues and contributing code: [@abalter](https://github.com/abalter), [@ablack3](https://github.com/ablack3), [@andreassoteriadesmoj](https://github.com/andreassoteriadesmoj), [@apalacio9502](https://github.com/apalacio9502), [@avsdev-cw](https://github.com/avsdev-cw), [@bairdj](https://github.com/bairdj), [@bastistician](https://github.com/bastistician), [@brownj31](https://github.com/brownj31), [@But2ene](https://github.com/But2ene), [@carlganz](https://github.com/carlganz), [@catalamarti](https://github.com/catalamarti), [@CEH-SLU](https://github.com/CEH-SLU), [@chriscardillo](https://github.com/chriscardillo), [@DavisVaughan](https://github.com/DavisVaughan), [@DaZaM82](https://github.com/DaZaM82), [@donour](https://github.com/donour), [@edgararuiz](https://github.com/edgararuiz), [@eduardszoecs](https://github.com/eduardszoecs), [@eipi10](https://github.com/eipi10), [@ejneer](https://github.com/ejneer), [@erikvona](https://github.com/erikvona), [@fh-afrachioni](https://github.com/fh-afrachioni), [@fh-mthomson](https://github.com/fh-mthomson), [@gui-salome](https://github.com/gui-salome), [@hadley](https://github.com/hadley), [@halpo](https://github.com/halpo), [@homer3018](https://github.com/homer3018), [@iangow](https://github.com/iangow), [@jdlom](https://github.com/jdlom), [@jennal-datacenter](https://github.com/jennal-datacenter), [@JeremyPasco](https://github.com/JeremyPasco), [@jiemakel](https://github.com/jiemakel), [@jingydz](https://github.com/jingydz), [@johnbaums](https://github.com/johnbaums), [@joshseiv](https://github.com/joshseiv), [@jrandall](https://github.com/jrandall), [@khkk378](https://github.com/khkk378), [@kmishra9](https://github.com/kmishra9), [@kongdd](https://github.com/kongdd), [@krlmlr](https://github.com/krlmlr), [@krprasangdas](https://github.com/krprasangdas), [@KRRLP-PL](https://github.com/KRRLP-PL), [@lentinj](https://github.com/lentinj), [@lgaborini](https://github.com/lgaborini), [@lhabegger](https://github.com/lhabegger), [@lorenzolightsgdwarf](https://github.com/lorenzolightsgdwarf), [@lschneiderbauer](https://github.com/lschneiderbauer), [@marianschmidt](https://github.com/marianschmidt), [@matthewjnield](https://github.com/matthewjnield), [@mgirlich](https://github.com/mgirlich), [@MichaelChirico](https://github.com/MichaelChirico), [@misea](https://github.com/misea), [@mjbroerman](https://github.com/mjbroerman), [@moodymudskipper](https://github.com/moodymudskipper), [@multimeric](https://github.com/multimeric), [@nannerhammix](https://github.com/nannerhammix), [@nikolasharing](https://github.com/nikolasharing), [@nviets](https://github.com/nviets), [@nviraj](https://github.com/nviraj), [@oobd](https://github.com/oobd), [@pboesu](https://github.com/pboesu), [@pepijn-devries](https://github.com/pepijn-devries), [@rbcavanaugh](https://github.com/rbcavanaugh), [@rcepka](https://github.com/rcepka), [@robertkck](https://github.com/robertkck), [@samssann](https://github.com/samssann), [@SayfSaid](https://github.com/SayfSaid), [@scottporter](https://github.com/scottporter), [@shearerpmm](https://github.com/shearerpmm), [@srikanthtist](https://github.com/srikanthtist), [@stemangiola](https://github.com/stemangiola), [@stephenashton-dhsc](https://github.com/stephenashton-dhsc), [@stevepowell99](https://github.com/stevepowell99), [@TBlackmore](https://github.com/TBlackmore), [@thomashulst](https://github.com/thomashulst), [@thothal](https://github.com/thothal), [@tilo-aok](https://github.com/tilo-aok), [@tisseuil](https://github.com/tisseuil), [@tonyk7440](https://github.com/tonyk7440), [@TSchiefer](https://github.com/TSchiefer), [@Tsemharb](https://github.com/Tsemharb), [@tuge98](https://github.com/tuge98), [@vadim-cherepanov](https://github.com/vadim-cherepanov), and [@wdenton](https://github.com/wdenton).

