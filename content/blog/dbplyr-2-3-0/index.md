---
output: hugodown::hugo_document

slug: dbplyr-2-3-0
title: dbplyr 2.3.0
date: 2023-01-16
author: Hadley Wickham
description: >
    dbplyr 2.3.0 brings improvements to SQL generation, improved error messages,
    a handful of new translations, and a bunch of backend specific improvements.

photo:
  url: https://unsplash.com/photos/05HLFQu8bFw
  author: Viktor Talashuk 

# one of: "deep-dive", "learn", "package", "programming", "roundup", or "other"
categories: [package] 
tags: [dplyr, dbplyr]
rmd_hash: 21883fbdd40cd91a

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
* [ ] [`usethis::use_tidy_thanks()`](https://usethis.r-lib.org/reference/use_tidy_thanks.html)
-->

We're chuffed to announce the release of [dbplyr](http://dbplyr.tidyverse.org/) 2.3.0. dbplyr is a database backend for dplyr that allows you to use a remote database as if it was a collection of local data frames: you write ordinary dplyr code and dbplyr translates it to SQL for you.

You can install it from CRAN with:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://rdrr.io/r/utils/install.packages.html'>install.packages</a></span><span class='o'>(</span><span class='s'>"&#123;package&#125;"</span><span class='o'>)</span></span></code></pre>

</div>

This blog post will highlight some of the most important new features: eliminating subqueries for many verb combinations, better errors, and a handful of new translations. As usual, this release comes with a large number of improvements to translations for individual backends. See the full list in the [release notes](%7B%20github_release%20%7D)

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://dbplyr.tidyverse.org/'>dbplyr</a></span><span class='o'>)</span></span>
<span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://dplyr.tidyverse.org'>dplyr</a></span>, warn.conflicts <span class='o'>=</span> <span class='kc'>FALSE</span><span class='o'>)</span></span></code></pre>

</div>

## SQL optimisation

dbplyr now produces fewer subqueries resulting in shorter, more readable, and, in some cases, faster SQL. Queries use `SELECT *` even after a join, where possible and the following combination of verbs now avoids subqueries much of the time:

-   `*_join()` + [`select()`](https://dplyr.tidyverse.org/reference/select.html) and [`select()`](https://dplyr.tidyverse.org/reference/select.html) + `*_join()`.
-   [`mutate()`](https://dplyr.tidyverse.org/reference/mutate.html) + [`filter()`](https://dplyr.tidyverse.org/reference/filter.html) and [`filter()`](https://dplyr.tidyverse.org/reference/filter.html) + [`filter()`](https://dplyr.tidyverse.org/reference/filter.html)
-   [`distinct()`](https://dplyr.tidyverse.org/reference/distinct.html).
-   [`summarise()`](https://dplyr.tidyverse.org/reference/summarise.html) + [`filter()`](https://dplyr.tidyverse.org/reference/filter.html) now translates to `HAVING`.
-   `left/inner_join()` + `left/inner_join()`.

Here are a couple of examples of queries that are now much more compact:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>lf1</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://dbplyr.tidyverse.org/reference/tbl_lazy.html'>lazy_frame</a></span><span class='o'>(</span>x <span class='o'>=</span> <span class='m'>1</span>, a <span class='o'>=</span> <span class='s'>"a"</span>, .name <span class='o'>=</span> <span class='s'>"lf1"</span><span class='o'>)</span></span>
<span><span class='nv'>lf2</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://dbplyr.tidyverse.org/reference/tbl_lazy.html'>lazy_frame</a></span><span class='o'>(</span>x <span class='o'>=</span> <span class='m'>1</span>, b <span class='o'>=</span> <span class='s'>"b"</span>, .name <span class='o'>=</span> <span class='s'>"lf2"</span><span class='o'>)</span></span>
<span><span class='nv'>lf3</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://dbplyr.tidyverse.org/reference/tbl_lazy.html'>lazy_frame</a></span><span class='o'>(</span>x <span class='o'>=</span> <span class='m'>1</span>, c <span class='o'>=</span> <span class='s'>"c"</span>, .name <span class='o'>=</span> <span class='s'>"lf3"</span><span class='o'>)</span></span>
<span></span>
<span><span class='nv'>lf1</span> <span class='o'>|&gt;</span> </span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/mutate-joins.html'>left_join</a></span><span class='o'>(</span><span class='nv'>lf2</span>, by <span class='o'>=</span> <span class='s'>"x"</span><span class='o'>)</span> <span class='o'>|&gt;</span> </span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/mutate-joins.html'>left_join</a></span><span class='o'>(</span><span class='nv'>lf3</span>, by <span class='o'>=</span> <span class='s'>"x"</span><span class='o'>)</span> <span class='o'>|&gt;</span> </span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/select.html'>select</a></span><span class='o'>(</span><span class='nv'>b</span>, <span class='nv'>c</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; &lt;SQL&gt;</span></span>
<span><span class='c'>#&gt; <span style='color: #0000BB;'>SELECT</span> `b`, `c`</span></span>
<span><span class='c'>#&gt; <span style='color: #0000BB;'>FROM</span> `lf1`</span></span>
<span><span class='c'>#&gt; <span style='color: #0000BB;'>LEFT JOIN</span> `lf2`</span></span>
<span><span class='c'>#&gt;   <span style='color: #0000BB;'>ON</span> (`lf1`.`x` = `lf2`.`x`)</span></span>
<span><span class='c'>#&gt; <span style='color: #0000BB;'>LEFT JOIN</span> `lf3`</span></span>
<span><span class='c'>#&gt;   <span style='color: #0000BB;'>ON</span> (`lf1`.`x` = `lf3`.`x`)</span></span>
<span></span><span></span>
<span><span class='nv'>lf1</span> <span class='o'>|&gt;</span> </span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/group_by.html'>group_by</a></span><span class='o'>(</span><span class='nv'>x</span><span class='o'>)</span> <span class='o'>|&gt;</span> </span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/summarise.html'>summarise</a></span><span class='o'>(</span>a <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/mean.html'>mean</a></span><span class='o'>(</span><span class='nv'>a</span>, na.rm <span class='o'>=</span> <span class='kc'>TRUE</span><span class='o'>)</span>, n <span class='o'>=</span> <span class='nf'><a href='https://dplyr.tidyverse.org/reference/context.html'>n</a></span><span class='o'>(</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>|&gt;</span> </span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/filter.html'>filter</a></span><span class='o'>(</span><span class='nv'>n</span> <span class='o'>&gt;</span> <span class='m'>5</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; &lt;SQL&gt;</span></span>
<span><span class='c'>#&gt; <span style='color: #0000BB;'>SELECT</span> `x`, AVG(`a`)<span style='color: #0000BB;'> AS </span>`a`, COUNT(*)<span style='color: #0000BB;'> AS </span>`n`</span></span>
<span><span class='c'>#&gt; <span style='color: #0000BB;'>FROM</span> `lf1`</span></span>
<span><span class='c'>#&gt; <span style='color: #0000BB;'>GROUP BY</span> `x`</span></span>
<span><span class='c'>#&gt; <span style='color: #0000BB;'>HAVING</span> (COUNT(*) &gt; 5.0)</span></span>
<span></span></code></pre>

</div>

(As ususal in these blog posts, I'm using [`lazy_frame()`](https://dbplyr.tidyverse.org/reference/tbl_lazy.html) to focus on the SQL generation, without having to set up a dummy database.)

## Improved errors

Variables that aren't found in either the data or in the environment now produce an error:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>lf</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://dbplyr.tidyverse.org/reference/tbl_lazy.html'>lazy_frame</a></span><span class='o'>(</span>x <span class='o'>=</span> <span class='m'>1</span>,y <span class='o'>=</span> <span class='m'>2</span><span class='o'>)</span></span>
<span></span>
<span><span class='nv'>lf</span> <span class='o'>|&gt;</span> <span class='nf'><a href='https://dplyr.tidyverse.org/reference/mutate.html'>mutate</a></span><span class='o'>(</span>x <span class='o'>=</span> <span class='nv'>z</span> <span class='o'>+</span> <span class='m'>1</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #BBBB00; font-weight: bold;'>Error</span><span style='font-weight: bold;'> in `mutate()`:</span></span></span>
<span><span class='c'>#&gt; <span style='color: #BBBB00;'>!</span> Problem while computing `x = z + 1`</span></span>
<span><span class='c'>#&gt; <span style='font-weight: bold;'>Caused by error:</span></span></span>
<span><span class='c'>#&gt; <span style='color: #BBBB00;'>!</span> Object `z` not found.</span></span>
<span></span></code></pre>

</div>

(Previously they were silently translated to SQL variables.)

We've also generally reviewed the error messages to ensure they show more clearly where the error happened:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>lf</span> <span class='o'>|&gt;</span> <span class='nf'><a href='https://dplyr.tidyverse.org/reference/mutate.html'>mutate</a></span><span class='o'>(</span>x <span class='o'>=</span> <span class='nv'>y</span> <span class='o'><a href='https://rdrr.io/r/base/Arithmetic.html'>%/%</a></span> <span class='m'>1</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #BBBB00; font-weight: bold;'>Error</span><span style='font-weight: bold;'> in `purrr::pmap()` at </span><a href='file:///Users/hadleywickham/Documents/dplyr/dbplyr/R/lazy-select-query.R'><span style='font-weight: bold;'>dbplyr/R/lazy-select-query.R:282:2</span></a><span style='font-weight: bold;'>:</span></span></span>
<span><span class='c'>#&gt; <span style='color: #00BBBB;'>ℹ</span> In index: 1.</span></span>
<span><span class='c'>#&gt; <span style='color: #00BBBB;'>ℹ</span> With name: x.</span></span>
<span><span class='c'>#&gt; <span style='font-weight: bold;'>Caused by error in `y %/% 1`:</span></span></span>
<span><span class='c'>#&gt; <span style='color: #BBBB00;'>!</span> %/% is not available in this SQL variant</span></span>
<span></span><span></span>
<span><span class='nv'>lf</span> <span class='o'>|&gt;</span> <span class='nf'><a href='https://dplyr.tidyverse.org/reference/mutate.html'>mutate</a></span><span class='o'>(</span><span class='nf'><a href='https://dplyr.tidyverse.org/reference/across.html'>across</a></span><span class='o'>(</span><span class='nv'>x</span><span class='o'>:</span><span class='nv'>y</span>, <span class='s'>"a"</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #BBBB00; font-weight: bold;'>Error</span><span style='font-weight: bold;'> in `mutate()`:</span></span></span>
<span><span class='c'>#&gt; <span style='color: #BBBB00;'>!</span> Problem while computing `..1 = across(x:y, "a")`</span></span>
<span><span class='c'>#&gt; <span style='font-weight: bold;'>Caused by error in `across()`:</span></span></span>
<span><span class='c'>#&gt; <span style='color: #BBBB00;'>!</span> `.fns` must be a NULL, a function, formula, or list</span></span>
<span></span></code></pre>

</div>

## New translations

[`stringr::str_like()`](https://stringr.tidyverse.org/reference/str_like.html) (new in stringr 1.5.0) is translated to `LIKE`:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>lf1</span> <span class='o'>|&gt;</span> </span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/filter.html'>filter</a></span><span class='o'>(</span><span class='nf'>stringr</span><span class='nf'>::</span><span class='nf'><a href='https://stringr.tidyverse.org/reference/str_like.html'>str_like</a></span><span class='o'>(</span><span class='nv'>a</span>, <span class='s'>"abc"</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; &lt;SQL&gt;</span></span>
<span><span class='c'>#&gt; <span style='color: #0000BB;'>SELECT</span> *</span></span>
<span><span class='c'>#&gt; <span style='color: #0000BB;'>FROM</span> `lf1`</span></span>
<span><span class='c'>#&gt; <span style='color: #0000BB;'>WHERE</span> (`a` LIKE 'abc')</span></span>
<span></span></code></pre>

</div>

dbplyr 2.3.0 is also supports features coming in [dplyr 1.1.0](https://www.tidyverse.org/blog/2022/11/dplyr-1-1-0-is-coming-soon/):

-   The `.by` argument is supported as alternative to [`group_by()`](https://dplyr.tidyverse.org/reference/group_by.html).
-   Passing `...` to [`across()`](https://dplyr.tidyverse.org/reference/across.html) is deprecated because the evaluation timing of `...` is ambiguous.
-   New `pick()` and `case_match()` functions are translated.
-   [`case_when()`](https://dplyr.tidyverse.org/reference/case_when.html) now supports the `.default` argument.

This version does not support the new `join_by()` syntax, but we're working on it and will release an update after dplyr 1.1.0 is out.

## Acknowledgements

The vast majority of this release (particularly the SQL optimisations) are from [Maximilian Girlich](https://github.com/mgirlich); thanks so much for continued work on this package.

We'd also like to thank all 74 contributors who help in someway, whether it was filing issues or contributing code and documentation: [@a4sberg](https://github.com/a4sberg), [@ablack3](https://github.com/ablack3), [@akgold](https://github.com/akgold), [@aleighbrown](https://github.com/aleighbrown), [@andreassoteriadesmoj](https://github.com/andreassoteriadesmoj), [@apalacio9502](https://github.com/apalacio9502), [@baileych](https://github.com/baileych), [@barnesparker](https://github.com/barnesparker), [@bhuvanesh1707](https://github.com/bhuvanesh1707), [@bkraft4257](https://github.com/bkraft4257), [@bobbymc0](https://github.com/bobbymc0), [@brian-law-rstudio](https://github.com/brian-law-rstudio), [@bthe](https://github.com/bthe), [@But2ene](https://github.com/But2ene), [@capitantyler](https://github.com/capitantyler), [@carlganz](https://github.com/carlganz), [@cboettig](https://github.com/cboettig), [@chwpearse](https://github.com/chwpearse), [@copernican](https://github.com/copernican), [@DSLituiev](https://github.com/DSLituiev), [@ehudtr7](https://github.com/ehudtr7), [@eitsupi](https://github.com/eitsupi), [@ejneer](https://github.com/ejneer), [@eutwt](https://github.com/eutwt), [@ewright-vcan](https://github.com/ewright-vcan), [@fabkury](https://github.com/fabkury), [@fh-afrachioni](https://github.com/fh-afrachioni), [@fh-mthomson](https://github.com/fh-mthomson), [@filipemsc](https://github.com/filipemsc), [@gadenbuie](https://github.com/gadenbuie), [@gbouzill](https://github.com/gbouzill), [@giocomai](https://github.com/giocomai), [@hadley](https://github.com/hadley), [@hershelm](https://github.com/hershelm), [@iangow](https://github.com/iangow), [@iMissile](https://github.com/iMissile), [@IndrajeetPatil](https://github.com/IndrajeetPatil), [@j-wester](https://github.com/j-wester), [@Janlow](https://github.com/Janlow), [@jasonmhoule](https://github.com/jasonmhoule), [@jensmassberg](https://github.com/jensmassberg), [@jmbarbone](https://github.com/jmbarbone), [@joe-rodd](https://github.com/joe-rodd), [@kongdd](https://github.com/kongdd), [@krlmlr](https://github.com/krlmlr), [@lschneiderbauer](https://github.com/lschneiderbauer), [@machow](https://github.com/machow), [@mgarbuzov](https://github.com/mgarbuzov), [@mgirlich](https://github.com/mgirlich), [@MichaelChirico](https://github.com/MichaelChirico), [@moodymudskipper](https://github.com/moodymudskipper), [@multimeric](https://github.com/multimeric), [@namarkus](https://github.com/namarkus), [@noamross](https://github.com/noamross), [@NZambranoc](https://github.com/NZambranoc), [@oriolarques](https://github.com/oriolarques), [@overmar](https://github.com/overmar), [@owenjonesuob](https://github.com/owenjonesuob), [@p-schaefer](https://github.com/p-schaefer), [@rohitg33](https://github.com/rohitg33), [@rowrowrowyourboat](https://github.com/rowrowrowyourboat), [@rsund](https://github.com/rsund), [@samssann](https://github.com/samssann), [@samterfa](https://github.com/samterfa), [@schradj](https://github.com/schradj), [@scvail195](https://github.com/scvail195), [@slhck](https://github.com/slhck), [@splaisan](https://github.com/splaisan), [@stephenashton-dhsc](https://github.com/stephenashton-dhsc), [@ThomasMorland](https://github.com/ThomasMorland), [@thothal](https://github.com/thothal), [@viswaduttp](https://github.com/viswaduttp), [@XoliloX](https://github.com/XoliloX), and [@yuhenghuang](https://github.com/yuhenghuang).

