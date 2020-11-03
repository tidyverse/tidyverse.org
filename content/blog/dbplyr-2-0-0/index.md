---
output: hugodown::hugo_document

slug: dbplyr-2-0-0
title: dbplyr 2.0.0
date: 2020-11-03
author: Hadley Wickham
description: >
    dbplyr 2.0.0 brings dplyr 1.0.0 compatibility, numeric improvements
    to SQL translation (including new Amazon Redshift and SAP HANA 
    backends), and an improved system for extending dbplyr to work with
    other databases.
    
photo:
  url: https://unsplash.com/photos/r2A6WYI8YIg
  author: Shawn Ang

categories: [package] 
tags: [dbplyr, dplyr]
rmd_hash: 6955cf6d64811608

---

We're pleased to announce the release of [dbplyr](https://dbplyr.tidyverse.org/) 2.0.0. dbplyr is a database backend for [dplyr](https://dplyr.tidyverse.org/) that allows you to use a remote database as if it was a collection of local data frames: you write ordinary dplyr code and dbplyr translates it to SQL for you.

You can install it from CRAN with:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://rdrr.io/r/utils/install.packages.html'>install.packages</a></span><span class='o'>(</span><span class='s'>"dbplyr"</span><span class='o'>)</span>
</code></pre>

</div>

This blog post covers the major improvements in this version:

-   dplyr 1.0.0 compatibility so you can now use [`across()`](https://dplyr.tidyverse.org/reference/across.html), [`relocate()`](https://dplyr.tidyverse.org/reference/relocate.html), [`rename_with()`](https://dplyr.tidyverse.org/reference/rename.html), and more.

-   The major improvements to SQL translation.

-   A snazzy new logo from [Allison Horst](https://www.allisonhorst.com).

-   An improved extension system.

Please see the [release notes](https://github.com/tidyverse/dbplyr/releases/tag/v2.0.0) for a full list of changes.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://dbplyr.tidyverse.org/'>dbplyr</a></span><span class='o'>)</span>
<span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://dplyr.tidyverse.org'>dplyr</a></span>, warn.conflicts <span class='o'>=</span> <span class='kc'>FALSE</span><span class='o'>)</span>
</code></pre>

</div>

dplyr 1.0.0 compatibility
-------------------------

dbplyr now supports all relevant features added in dplyr 1.0.0:

-   [`across()`](https://dplyr.tidyverse.org/reference/across.html) is now translated into individual SQL statements.

    <div class="highlight">

    <pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>lf</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://dbplyr.tidyverse.org/reference/tbl_lazy.html'>lazy_frame</a></span><span class='o'>(</span>g <span class='o'>=</span> <span class='m'>1</span>, a <span class='o'>=</span> <span class='m'>1</span>, b <span class='o'>=</span> <span class='m'>2</span>, c <span class='o'>=</span> <span class='m'>3</span><span class='o'>)</span>
    <span class='nv'>lf</span> <span class='o'>%&gt;%</span> 
      <span class='nf'><a href='https://dplyr.tidyverse.org/reference/group_by.html'>group_by</a></span><span class='o'>(</span><span class='nv'>g</span><span class='o'>)</span> <span class='o'>%&gt;%</span> 
      <span class='nf'><a href='https://dplyr.tidyverse.org/reference/summarise.html'>summarise</a></span><span class='o'>(</span><span class='nf'><a href='https://dplyr.tidyverse.org/reference/across.html'>across</a></span><span class='o'>(</span><span class='nf'><a href='https://tidyselect.r-lib.org/reference/everything.html'>everything</a></span><span class='o'>(</span><span class='o'>)</span>, <span class='nv'>mean</span>, na.rm <span class='o'>=</span> <span class='kc'>TRUE</span><span class='o'>)</span><span class='o'>)</span>

    <span class='c'>#&gt; &lt;SQL&gt;</span>
    <span class='c'>#&gt; SELECT `g`, AVG(`g`) AS `g`, AVG(`a`) AS `a`, AVG(`b`) AS `b`, AVG(`c`) AS `c`</span>
    <span class='c'>#&gt; FROM `df`</span>
    <span class='c'>#&gt; GROUP BY `g`</span>
    </code></pre>

    </div>

-   [`rename()`](https://dplyr.tidyverse.org/reference/rename.html) and [`select()`](https://dplyr.tidyverse.org/reference/select.html) support dplyr 1.0.0 tidyselect syntax, apart from predicate functions which can't easily work on computed queries. You can now use [`rename_with()`](https://dplyr.tidyverse.org/reference/rename.html) to programmatically rename columns.

    <div class="highlight">

    <pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>lf</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://dbplyr.tidyverse.org/reference/tbl_lazy.html'>lazy_frame</a></span><span class='o'>(</span>x1 <span class='o'>=</span> <span class='m'>1</span>, x2 <span class='o'>=</span> <span class='m'>2</span>, x3 <span class='o'>=</span> <span class='m'>3</span>, y1 <span class='o'>=</span> <span class='m'>4</span>, y2 <span class='o'>=</span> <span class='m'>3</span><span class='o'>)</span>
    <span class='nv'>lf</span> <span class='o'>%&gt;%</span> <span class='nf'><a href='https://dplyr.tidyverse.org/reference/select.html'>select</a></span><span class='o'>(</span><span class='nf'><a href='https://tidyselect.r-lib.org/reference/starts_with.html'>starts_with</a></span><span class='o'>(</span><span class='s'>"x"</span><span class='o'>)</span> <span class='o'>&amp;</span> <span class='o'>!</span><span class='s'>"x3"</span><span class='o'>)</span>

    <span class='c'>#&gt; &lt;SQL&gt;</span>
    <span class='c'>#&gt; SELECT `x1`, `x2`</span>
    <span class='c'>#&gt; FROM `df`</span>

    <span class='nv'>lf</span> <span class='o'>%&gt;%</span> <span class='nf'><a href='https://dplyr.tidyverse.org/reference/select.html'>select</a></span><span class='o'>(</span><span class='nf'><a href='https://tidyselect.r-lib.org/reference/starts_with.html'>ends_with</a></span><span class='o'>(</span><span class='s'>"2"</span><span class='o'>)</span> <span class='o'>|</span> <span class='nf'><a href='https://tidyselect.r-lib.org/reference/starts_with.html'>ends_with</a></span><span class='o'>(</span><span class='s'>"3"</span><span class='o'>)</span><span class='o'>)</span>

    <span class='c'>#&gt; &lt;SQL&gt;</span>
    <span class='c'>#&gt; SELECT `x2`, `y2`, `x3`</span>
    <span class='c'>#&gt; FROM `df`</span>

    <span class='nv'>lf</span> <span class='o'>%&gt;%</span> <span class='nf'><a href='https://dplyr.tidyverse.org/reference/rename.html'>rename_with</a></span><span class='o'>(</span><span class='nv'>toupper</span><span class='o'>)</span>

    <span class='c'>#&gt; &lt;SQL&gt;</span>
    <span class='c'>#&gt; SELECT `x1` AS `X1`, `x2` AS `X2`, `x3` AS `X3`, `y1` AS `Y1`, `y2` AS `Y2`</span>
    <span class='c'>#&gt; FROM `df`</span>
    </code></pre>

    </div>

-   [`relocate()`](https://dplyr.tidyverse.org/reference/relocate.html) makes it easy to move columns around:

    <div class="highlight">

    <pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>lf</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://dbplyr.tidyverse.org/reference/tbl_lazy.html'>lazy_frame</a></span><span class='o'>(</span>x1 <span class='o'>=</span> <span class='m'>1</span>, x2 <span class='o'>=</span> <span class='m'>2</span>, y1 <span class='o'>=</span> <span class='m'>4</span>, y2 <span class='o'>=</span> <span class='m'>3</span><span class='o'>)</span>
    <span class='nv'>lf</span> <span class='o'>%&gt;%</span> <span class='nf'><a href='https://dplyr.tidyverse.org/reference/relocate.html'>relocate</a></span><span class='o'>(</span><span class='nf'><a href='https://tidyselect.r-lib.org/reference/starts_with.html'>starts_with</a></span><span class='o'>(</span><span class='s'>"y"</span><span class='o'>)</span><span class='o'>)</span>

    <span class='c'>#&gt; &lt;SQL&gt;</span>
    <span class='c'>#&gt; SELECT `y1`, `y2`, `x1`, `x2`</span>
    <span class='c'>#&gt; FROM `df`</span>
    </code></pre>

    </div>

-   [`slice_min()`](https://dplyr.tidyverse.org/reference/slice.html), [`slice_max()`](https://dplyr.tidyverse.org/reference/slice.html), and [`slice_sample()`](https://dplyr.tidyverse.org/reference/slice.html) are now supported, and [`slice_head()`](https://dplyr.tidyverse.org/reference/slice.html) and [`slice_tail()`](https://dplyr.tidyverse.org/reference/slice.html) throw informative error messages (since they don't make sense for databases).

    <div class="highlight">

    <pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>lf</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://dbplyr.tidyverse.org/reference/tbl_lazy.html'>lazy_frame</a></span><span class='o'>(</span>g <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/rep.html'>rep</a></span><span class='o'>(</span><span class='m'>1</span><span class='o'>:</span><span class='m'>2</span>, <span class='m'>5</span><span class='o'>)</span>, x <span class='o'>=</span> <span class='m'>1</span><span class='o'>:</span><span class='m'>10</span><span class='o'>)</span>
    <span class='nv'>lf</span> <span class='o'>%&gt;%</span> 
      <span class='nf'><a href='https://dplyr.tidyverse.org/reference/group_by.html'>group_by</a></span><span class='o'>(</span><span class='nv'>g</span><span class='o'>)</span> <span class='o'>%&gt;%</span> 
      <span class='nf'><a href='https://dplyr.tidyverse.org/reference/slice.html'>slice_min</a></span><span class='o'>(</span><span class='nv'>x</span>, prop <span class='o'>=</span> <span class='m'>0.5</span><span class='o'>)</span>

    <span class='c'>#&gt; &lt;SQL&gt;</span>
    <span class='c'>#&gt; SELECT `g`, `x`</span>
    <span class='c'>#&gt; FROM (SELECT `g`, `x`, CUME_DIST() OVER (PARTITION BY `g` ORDER BY `x`) AS `q01`</span>
    <span class='c'>#&gt; FROM `df`) `q01`</span>
    <span class='c'>#&gt; WHERE (`q01` &lt;= 0.5)</span>


    <span class='nv'>lf</span> <span class='o'>%&gt;%</span> 
      <span class='nf'><a href='https://dplyr.tidyverse.org/reference/group_by.html'>group_by</a></span><span class='o'>(</span><span class='nv'>g</span><span class='o'>)</span> <span class='o'>%&gt;%</span> 
      <span class='nf'><a href='https://dplyr.tidyverse.org/reference/slice.html'>slice_sample</a></span><span class='o'>(</span><span class='nv'>x</span>, n <span class='o'>=</span> <span class='m'>10</span>, with_ties <span class='o'>=</span> <span class='kc'>TRUE</span><span class='o'>)</span>

    <span class='c'>#&gt; &lt;SQL&gt;</span>
    <span class='c'>#&gt; SELECT `g`, `x`</span>
    <span class='c'>#&gt; FROM (SELECT `g`, `x`, ROW_NUMBER() OVER (PARTITION BY `g` ORDER BY random()) AS `q01`</span>
    <span class='c'>#&gt; FROM `df`) `q01`</span>
    <span class='c'>#&gt; WHERE (`q01` &lt;= 10)</span>
    </code></pre>

    </div>

    Note that these slices are translated to window functions, and because you can't use a window function directly inside a `WHERE` clause, they must be wrapped in a subquery.

SQL translation
---------------

The dbplyr documentation now does a much better job of providing the details of its SQL translation. Each backend and each major verb has a documentation page giving the basics of the translation. This will hopefully make it much easier to learn what is and isn't supported by dbplyr. Visit <https://dbplyr.tidyverse.org/reference/index.html> to see the new docs.

There were also many improvements to SQL generation. Here are a few of the most important:

-   Join functions gain a `na_matches` argument that allows you to control whether or not `NA` (`NULL`) values match other `NA` values. The default is `"never"`, which is the usual behaviour in databases. You can set `na_matches = "na"` to match R's usual join behaviour.

    <div class="highlight">

    <pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>df1</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://tibble.tidyverse.org/reference/tibble.html'>tibble</a></span><span class='o'>(</span>x <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='m'>1</span>, <span class='m'>2</span>, <span class='kc'>NA</span><span class='o'>)</span><span class='o'>)</span>
    <span class='nv'>df2</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://tibble.tidyverse.org/reference/tibble.html'>tibble</a></span><span class='o'>(</span>x <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='kc'>NA</span>, <span class='m'>1</span><span class='o'>)</span>, y <span class='o'>=</span> <span class='m'>1</span><span class='o'>:</span><span class='m'>2</span><span class='o'>)</span>
    <span class='nv'>df1</span> <span class='o'>%&gt;%</span> <span class='nf'><a href='https://dplyr.tidyverse.org/reference/mutate-joins.html'>inner_join</a></span><span class='o'>(</span><span class='nv'>df2</span>, by <span class='o'>=</span> <span class='s'>"x"</span><span class='o'>)</span>

    <span class='c'>#&gt; <span style='color: #949494;'># A tibble: 2 x 2</span></span>
    <span class='c'>#&gt;       <span style='font-weight: bold;'>x</span><span>     </span><span style='font-weight: bold;'>y</span></span>
    <span class='c'>#&gt;   <span style='color: #949494;font-style: italic;'>&lt;dbl&gt;</span><span> </span><span style='color: #949494;font-style: italic;'>&lt;int&gt;</span></span>
    <span class='c'>#&gt; <span style='color: #BCBCBC;'>1</span><span>     1     2</span></span>
    <span class='c'>#&gt; <span style='color: #BCBCBC;'>2</span><span>    </span><span style='color: #BB0000;'>NA</span><span>     1</span></span>


    <span class='nv'>db1</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://dbplyr.tidyverse.org/reference/memdb_frame.html'>memdb_frame</a></span><span class='o'>(</span>x <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='m'>1</span>, <span class='m'>2</span>, <span class='kc'>NA</span><span class='o'>)</span><span class='o'>)</span>
    <span class='nv'>db2</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://dbplyr.tidyverse.org/reference/memdb_frame.html'>memdb_frame</a></span><span class='o'>(</span>x <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='kc'>NA</span>, <span class='m'>1</span><span class='o'>)</span>, y <span class='o'>=</span> <span class='m'>1</span><span class='o'>:</span><span class='m'>2</span><span class='o'>)</span>
    <span class='nv'>db1</span> <span class='o'>%&gt;%</span> <span class='nf'><a href='https://dplyr.tidyverse.org/reference/mutate-joins.html'>inner_join</a></span><span class='o'>(</span><span class='nv'>db2</span>, by <span class='o'>=</span> <span class='s'>"x"</span><span class='o'>)</span>

    <span class='c'>#&gt; <span style='color: #949494;'># Source:   lazy query [?? x 2]</span></span>
    <span class='c'>#&gt; <span style='color: #949494;'># Database: sqlite 3.30.1 [:memory:]</span></span>
    <span class='c'>#&gt;       <span style='font-weight: bold;'>x</span><span>     </span><span style='font-weight: bold;'>y</span></span>
    <span class='c'>#&gt;   <span style='color: #949494;font-style: italic;'>&lt;dbl&gt;</span><span> </span><span style='color: #949494;font-style: italic;'>&lt;int&gt;</span></span>
    <span class='c'>#&gt; <span style='color: #BCBCBC;'>1</span><span>     1     2</span></span>


    <span class='nv'>db1</span> <span class='o'>%&gt;%</span> <span class='nf'><a href='https://dplyr.tidyverse.org/reference/mutate-joins.html'>inner_join</a></span><span class='o'>(</span><span class='nv'>db2</span>, by <span class='o'>=</span> <span class='s'>"x"</span>, na_matches <span class='o'>=</span> <span class='s'>"na"</span><span class='o'>)</span>

    <span class='c'>#&gt; <span style='color: #949494;'># Source:   lazy query [?? x 2]</span></span>
    <span class='c'>#&gt; <span style='color: #949494;'># Database: sqlite 3.30.1 [:memory:]</span></span>
    <span class='c'>#&gt;       <span style='font-weight: bold;'>x</span><span>     </span><span style='font-weight: bold;'>y</span></span>
    <span class='c'>#&gt;   <span style='color: #949494;font-style: italic;'>&lt;dbl&gt;</span><span> </span><span style='color: #949494;font-style: italic;'>&lt;int&gt;</span></span>
    <span class='c'>#&gt; <span style='color: #BCBCBC;'>1</span><span>    </span><span style='color: #BB0000;'>NA</span><span>     1</span></span>
    <span class='c'>#&gt; <span style='color: #BCBCBC;'>2</span><span>     1     2</span></span>
    </code></pre>

    </div>

    This translation is powered by the new [`sql_expr_matches()`](https://dbplyr.tidyverse.org/reference/db-sql.html) generic, because every database seems to have a slightly different way to express this idea. Learn more at <https://modern-sql.com/feature/is-distinct-from>.

    <div class="highlight">

    <pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>db1</span> <span class='o'>%&gt;%</span> <span class='nf'><a href='https://dplyr.tidyverse.org/reference/mutate-joins.html'>inner_join</a></span><span class='o'>(</span><span class='nv'>db2</span>, by <span class='o'>=</span> <span class='s'>"x"</span><span class='o'>)</span> <span class='o'>%&gt;%</span> <span class='nf'><a href='https://dplyr.tidyverse.org/reference/explain.html'>show_query</a></span><span class='o'>(</span><span class='o'>)</span>

    <span class='c'>#&gt; &lt;SQL&gt;</span>
    <span class='c'>#&gt; SELECT `LHS`.`x` AS `x`, `y`</span>
    <span class='c'>#&gt; FROM `dbplyr_001` AS `LHS`</span>
    <span class='c'>#&gt; INNER JOIN `dbplyr_002` AS `RHS`</span>
    <span class='c'>#&gt; ON (`LHS`.`x` = `RHS`.`x`)</span>

    <span class='nv'>db1</span> <span class='o'>%&gt;%</span> <span class='nf'><a href='https://dplyr.tidyverse.org/reference/mutate-joins.html'>inner_join</a></span><span class='o'>(</span><span class='nv'>db2</span>, by <span class='o'>=</span> <span class='s'>"x"</span>, na_matches <span class='o'>=</span> <span class='s'>"na"</span><span class='o'>)</span> <span class='o'>%&gt;%</span> <span class='nf'><a href='https://dplyr.tidyverse.org/reference/explain.html'>show_query</a></span><span class='o'>(</span><span class='o'>)</span>

    <span class='c'>#&gt; &lt;SQL&gt;</span>
    <span class='c'>#&gt; SELECT `LHS`.`x` AS `x`, `y`</span>
    <span class='c'>#&gt; FROM `dbplyr_001` AS `LHS`</span>
    <span class='c'>#&gt; INNER JOIN `dbplyr_002` AS `RHS`</span>
    <span class='c'>#&gt; ON (`LHS`.`x` IS `RHS`.`x`)</span>
    </code></pre>

    </div>

-   Subqueries no longer include an `ORDER BY` clause. This is not part of the formal SQL specification so has very limited support across databases. Now such queries generate a warning suggesting that you move your [`arrange()`](https://dplyr.tidyverse.org/reference/arrange.html) call later in the pipeline.

    <div class="highlight">

    <pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>lf</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://dbplyr.tidyverse.org/reference/tbl_lazy.html'>lazy_frame</a></span><span class='o'>(</span>g <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/rep.html'>rep</a></span><span class='o'>(</span><span class='m'>1</span><span class='o'>:</span><span class='m'>2</span>, each <span class='o'>=</span> <span class='m'>5</span><span class='o'>)</span>, x <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/sample.html'>sample</a></span><span class='o'>(</span><span class='m'>1</span><span class='o'>:</span><span class='m'>10</span><span class='o'>)</span><span class='o'>)</span>
    <span class='nv'>lf</span> <span class='o'>%&gt;%</span> 
      <span class='nf'><a href='https://dplyr.tidyverse.org/reference/group_by.html'>group_by</a></span><span class='o'>(</span><span class='nv'>g</span><span class='o'>)</span> <span class='o'>%&gt;%</span> 
      <span class='nf'><a href='https://dplyr.tidyverse.org/reference/summarise.html'>summarise</a></span><span class='o'>(</span>n <span class='o'>=</span> <span class='nf'><a href='https://dplyr.tidyverse.org/reference/context.html'>n</a></span><span class='o'>(</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>%&gt;%</span> 
      <span class='nf'><a href='https://dplyr.tidyverse.org/reference/arrange.html'>arrange</a></span><span class='o'>(</span><span class='nf'><a href='https://dplyr.tidyverse.org/reference/desc.html'>desc</a></span><span class='o'>(</span><span class='nv'>n</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>%&gt;%</span> 
      <span class='nf'><a href='https://dplyr.tidyverse.org/reference/filter.html'>filter</a></span><span class='o'>(</span><span class='nv'>n</span> <span class='o'>&gt;</span> <span class='m'>1</span><span class='o'>)</span>

    <span class='c'>#&gt; Warning: ORDER BY is ignored in subqueries without LIMIT</span>
    <span class='c'>#&gt; <span style='color: #0000BB;'>ℹ</span><span> Do you need to move arrange() later in the pipeline or use window_order() instead?</span></span>

    <span class='c'>#&gt; &lt;SQL&gt;</span>
    <span class='c'>#&gt; SELECT *</span>
    <span class='c'>#&gt; FROM (SELECT `g`, COUNT(*) AS `n`</span>
    <span class='c'>#&gt; FROM `df`</span>
    <span class='c'>#&gt; GROUP BY `g`) `q01`</span>
    <span class='c'>#&gt; WHERE (`n` &gt; 1.0)</span>
    </code></pre>

    </div>

    As the warning suggests, there's one exception: `ORDER BY` is still generated if a `LIMIT` is present. Across databases, this tends to change which rows are returned, but not necessarily their order.

    <div class="highlight">

    <pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>lf</span> <span class='o'>%&gt;%</span> 
      <span class='nf'><a href='https://dplyr.tidyverse.org/reference/group_by.html'>group_by</a></span><span class='o'>(</span><span class='nv'>g</span><span class='o'>)</span> <span class='o'>%&gt;%</span> 
      <span class='nf'><a href='https://dplyr.tidyverse.org/reference/summarise.html'>summarise</a></span><span class='o'>(</span>n <span class='o'>=</span> <span class='nf'><a href='https://dplyr.tidyverse.org/reference/context.html'>n</a></span><span class='o'>(</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>%&gt;%</span> 
      <span class='nf'><a href='https://dplyr.tidyverse.org/reference/arrange.html'>arrange</a></span><span class='o'>(</span><span class='nf'><a href='https://dplyr.tidyverse.org/reference/desc.html'>desc</a></span><span class='o'>(</span><span class='nv'>n</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>%&gt;%</span> 
      <span class='nf'><a href='https://rdrr.io/r/utils/head.html'>head</a></span><span class='o'>(</span><span class='m'>5</span><span class='o'>)</span> <span class='o'>%&gt;%</span> 
      <span class='nf'><a href='https://dplyr.tidyverse.org/reference/filter.html'>filter</a></span><span class='o'>(</span><span class='nv'>n</span> <span class='o'>&gt;</span> <span class='m'>1</span><span class='o'>)</span>

    <span class='c'>#&gt; &lt;SQL&gt;</span>
    <span class='c'>#&gt; SELECT *</span>
    <span class='c'>#&gt; FROM (SELECT `g`, COUNT(*) AS `n`</span>
    <span class='c'>#&gt; FROM `df`</span>
    <span class='c'>#&gt; GROUP BY `g`</span>
    <span class='c'>#&gt; ORDER BY `n` DESC</span>
    <span class='c'>#&gt; LIMIT 5) `q01`</span>
    <span class='c'>#&gt; WHERE (`n` &gt; 1.0)</span>
    </code></pre>

    </div>

-   dbplyr includes built-in backends for Redshift (which only differs from PostgreSQL in a few places) and SAP HANA. These require the development versions of RPostgres and odbc respectively.

    <div class="highlight">

    <pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>lf</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://dbplyr.tidyverse.org/reference/tbl_lazy.html'>lazy_frame</a></span><span class='o'>(</span>x <span class='o'>=</span> <span class='s'>"a"</span>, y <span class='o'>=</span> <span class='s'>"b"</span>, con <span class='o'>=</span> <span class='nf'><a href='https://dbplyr.tidyverse.org/reference/backend-redshift.html'>simulate_redshift</a></span><span class='o'>(</span><span class='o'>)</span><span class='o'>)</span>
    <span class='nv'>lf</span> <span class='o'>%&gt;%</span> <span class='nf'><a href='https://dplyr.tidyverse.org/reference/mutate.html'>mutate</a></span><span class='o'>(</span>z <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/paste.html'>paste0</a></span><span class='o'>(</span><span class='nv'>x</span>, <span class='nv'>y</span><span class='o'>)</span><span class='o'>)</span>

    <span class='c'>#&gt; &lt;SQL&gt;</span>
    <span class='c'>#&gt; SELECT `x`, `y`, `x` || `y` AS `z`</span>
    <span class='c'>#&gt; FROM `df`</span>
    </code></pre>

    </div>

There are a number of minor changes that affect the translation of individual functions. Here are a few of the most important:

-   All backends now translate [`n()`](https://dplyr.tidyverse.org/reference/context.html) to `count(*)` and support [`::`](https://rdrr.io/r/base/ns-dblcolon.html)

    <div class="highlight">

    <pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>lf</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://dbplyr.tidyverse.org/reference/tbl_lazy.html'>lazy_frame</a></span><span class='o'>(</span>x <span class='o'>=</span> <span class='m'>1</span><span class='o'>:</span><span class='m'>10</span><span class='o'>)</span>
    <span class='nv'>lf</span> <span class='o'>%&gt;%</span> <span class='nf'><a href='https://dplyr.tidyverse.org/reference/summarise.html'>summarise</a></span><span class='o'>(</span>n <span class='o'>=</span> <span class='nf'>dplyr</span><span class='nf'>::</span><span class='nf'><a href='https://dplyr.tidyverse.org/reference/context.html'>n</a></span><span class='o'>(</span><span class='o'>)</span><span class='o'>)</span>

    <span class='c'>#&gt; &lt;SQL&gt;</span>
    <span class='c'>#&gt; SELECT COUNT(*) AS `n`</span>
    <span class='c'>#&gt; FROM `df`</span>
    </code></pre>

    </div>

-   PostgreSQL gets translations for lubridate period functions:

    <div class="highlight">

    <pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>lf</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://dbplyr.tidyverse.org/reference/tbl_lazy.html'>lazy_frame</a></span><span class='o'>(</span>x <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/Sys.time.html'>Sys.Date</a></span><span class='o'>(</span><span class='o'>)</span>, con <span class='o'>=</span> <span class='nf'><a href='https://dbplyr.tidyverse.org/reference/backend-postgres.html'>simulate_postgres</a></span><span class='o'>(</span><span class='o'>)</span><span class='o'>)</span>
    <span class='nv'>lf</span> <span class='o'>%&gt;%</span>
      <span class='nf'><a href='https://dplyr.tidyverse.org/reference/mutate.html'>mutate</a></span><span class='o'>(</span>year <span class='o'>=</span> <span class='nv'>x</span> <span class='o'>+</span> <span class='nf'>years</span><span class='o'>(</span><span class='m'>1</span><span class='o'>)</span><span class='o'>)</span>

    <span class='c'>#&gt; &lt;SQL&gt;</span>
    <span class='c'>#&gt; SELECT `x`, `x` + CAST('1 years' AS INTERVAL) AS `year`</span>
    <span class='c'>#&gt; FROM `df`</span>
    </code></pre>

    </div>

-   Oracle assumes version 12c is available so we can use a simpler translation for [`head()`](https://rdrr.io/r/utils/head.html) that works in more places:

    <div class="highlight">

    <pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>lf</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://dbplyr.tidyverse.org/reference/tbl_lazy.html'>lazy_frame</a></span><span class='o'>(</span>x <span class='o'>=</span> <span class='m'>1</span>, con <span class='o'>=</span> <span class='nf'><a href='https://dbplyr.tidyverse.org/reference/backend-oracle.html'>simulate_oracle</a></span><span class='o'>(</span><span class='o'>)</span><span class='o'>)</span>
    <span class='nv'>lf</span> <span class='o'>%&gt;%</span> <span class='nf'><a href='https://rdrr.io/r/utils/head.html'>head</a></span><span class='o'>(</span><span class='m'>5</span><span class='o'>)</span>

    <span class='c'>#&gt; &lt;SQL&gt;</span>
    <span class='c'>#&gt; SELECT *</span>
    <span class='c'>#&gt; FROM (`df`) </span>
    <span class='c'>#&gt; FETCH FIRST 5 ROWS ONLY</span>
    </code></pre>

    </div>

New logo
--------

Thanks to the artistic talents of [Allison Horst](https://www.allisonhorst.com), dbplyr has a beautiful new logo:

<img src="dbplyr.png" width="250"/>

Extensibility
-------------

Finally, dbplyr introduces a number of new generics to help tease apart the currently overly complicated relationship with dplyr. This should make creating new backends much easier, but does require some changes from existing backends. These changes should be invisible to the end user and will play out slowly over the next 12 months. See `vignette("backend-2", package = "dbplyr")` for details.

Acknowledgements
----------------

A big thanks to everyone who helped with this release by reporting bugs, discussing issues, and contributing code! [@abalter](https://github.com/abalter), [@adhi-r](https://github.com/adhi-r), [@batpigandme](https://github.com/batpigandme), [@cmichaud92](https://github.com/cmichaud92), [@Daveyr](https://github.com/Daveyr), [@DavidPatShuiFong](https://github.com/DavidPatShuiFong), [@elbamos](https://github.com/elbamos), [@fh-jgutman](https://github.com/fh-jgutman), [@gregleleu](https://github.com/gregleleu), [@hadley](https://github.com/hadley), [@iangow](https://github.com/iangow), [@jkylearmstrong](https://github.com/jkylearmstrong), [@jonkeane](https://github.com/jonkeane), [@kmishra9](https://github.com/kmishra9), [@kohleth](https://github.com/kohleth), [@krlmlr](https://github.com/krlmlr), [@lorenzwalthert](https://github.com/lorenzwalthert), [@machow](https://github.com/machow), [@okhoma](https://github.com/okhoma), [@rjpat](https://github.com/rjpat), [@rlh1994](https://github.com/rlh1994), [@samssann](https://github.com/samssann), [@schradj](https://github.com/schradj), [@shosaco](https://github.com/shosaco), and [@stiberger](https://github.com/stiberger).

