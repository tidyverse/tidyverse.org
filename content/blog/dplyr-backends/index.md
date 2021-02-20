---
output: hugodown::hugo_document

slug: dplyr-backends
title: "dplyr backends: multidplyr 0.1.0, dtplyr 1.1.0, dbplyr 2.1.0"
date: 2021-02-22
author: Hadley Wickham
description: >
    We've recently released a bunch of improvements to dplyr backends.
    multidplyr, which allows you to spread work across multiple cores, is
    now on CRAN. dtplyr adds translations for dplyr 1.0.0 and fixes many
    bugs. dbplyr 2.1.0 adds translations for many tidyr verbs, gains an 
    author, and has improved `across()` translations. 

photo:
  url: https://unsplash.com/photos/jVYnBn3M9R0
  author: Charles Deluvio

# one of: "deep-dive", "learn", "package", "programming", or "other"
categories: [package] 
tags: [dplyr]
rmd_hash: 4cba63de72849be3

---

<!--
TODO:
* [ ] [`usethis::use_tidy_thanks()`](https://usethis.r-lib.org/reference/use_tidy_thanks.html)
-->

One of my favourite things about dplyr is that it decouples the expression of data manipulation from its computation. That makes it possible to take basically the same dplyr code and execute it in radically different ways by using a different backend. This blog post covers a passel of updates to the dplyr backends that we maintain:

-   [multidplyr](https://multidplyr.tidyverse.org/) spreads computation over multiple cores.

-   [dtplyr](https://dtplyr.tidyverse.org/) translates your dplyr code to the wonderfully fast [data.table](https://r-datatable.com/) package.

-   [dbplyr](https://dbplyr.tidyverse.org/) translates your dplyr code to SQL so it can be executed in a database.

You can install them all in one fell sweep with:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://rdrr.io/r/utils/install.packages.html'>install.packages</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"multidplyr"</span>, <span class='s'>"dtplyr"</span>, <span class='s'>"dbplyr"</span><span class='o'>)</span><span class='o'>)</span></code></pre>

</div>

To use any of the backends, you need to start by loading dplyr.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://dplyr.tidyverse.org'>dplyr</a></span>, warn.conflicts <span class='o'>=</span> <span class='kc'>FALSE</span><span class='o'>)</span></code></pre>

</div>

## multidplyr 0.1.0

[multidplyr](https://multidplyr.tidyverse.org) creates multiple R processes and spreads computation out across all of them. This provides a simple way to take advantage of multiple cores in your computer. To use it, start by creating a cluster of R processes:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://github.com/tidyverse/multidplyr'>multidplyr</a></span><span class='o'>)</span>
<span class='nv'>cluster</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/pkg/multidplyr/man/new_cluster.html'>new_cluster</a></span><span class='o'>(</span><span class='m'>4</span><span class='o'>)</span></code></pre>

</div>

Then spread data across those processes using [`partition()`](https://rdrr.io/pkg/multidplyr/man/partition.html):

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>flight_dest</span> <span class='o'>&lt;-</span> <span class='nf'>nycflights13</span><span class='nf'>::</span><span class='nv'><a href='https://rdrr.io/pkg/nycflights13/man/flights.html'>flights</a></span> <span class='o'>%&gt;%</span> 
  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/group_by.html'>group_by</a></span><span class='o'>(</span><span class='nv'>dest</span><span class='o'>)</span> <span class='o'>%&gt;%</span> 
  <span class='nf'><a href='https://rdrr.io/pkg/multidplyr/man/partition.html'>partition</a></span><span class='o'>(</span><span class='nv'>cluster</span><span class='o'>)</span>
<span class='nv'>flight_dest</span>
<span class='c'>#&gt; Source: party_df [336,776 x 19]</span>
<span class='c'>#&gt; Groups: dest</span>
<span class='c'>#&gt; Shards: 4 [81,594--86,548 rows]</span>
<span class='c'>#&gt; </span>
<span class='c'>#&gt;    <span style='font-weight: bold;'>year</span><span> </span><span style='font-weight: bold;'>month</span><span>   </span><span style='font-weight: bold;'>day</span><span> </span><span style='font-weight: bold;'>dep_time</span><span> </span><span style='font-weight: bold;'>sched_dep_time</span><span> </span><span style='font-weight: bold;'>dep_delay</span><span> </span><span style='font-weight: bold;'>arr_time</span><span> </span><span style='font-weight: bold;'>sched_arr_time</span></span>
<span class='c'>#&gt;   <span style='color: #555555;font-style: italic;'>&lt;int&gt;</span><span> </span><span style='color: #555555;font-style: italic;'>&lt;int&gt;</span><span> </span><span style='color: #555555;font-style: italic;'>&lt;int&gt;</span><span>    </span><span style='color: #555555;font-style: italic;'>&lt;int&gt;</span><span>          </span><span style='color: #555555;font-style: italic;'>&lt;int&gt;</span><span>     </span><span style='color: #555555;font-style: italic;'>&lt;dbl&gt;</span><span>    </span><span style='color: #555555;font-style: italic;'>&lt;int&gt;</span><span>          </span><span style='color: #555555;font-style: italic;'>&lt;int&gt;</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>1</span><span>  </span><span style='text-decoration: underline;'>2</span><span>013     1     1      544            545        -</span><span style='color: #BB0000;'>1</span><span>     </span><span style='text-decoration: underline;'>1</span><span>004           </span><span style='text-decoration: underline;'>1</span><span>022</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>2</span><span>  </span><span style='text-decoration: underline;'>2</span><span>013     1     1      558            600        -</span><span style='color: #BB0000;'>2</span><span>      923            937</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>3</span><span>  </span><span style='text-decoration: underline;'>2</span><span>013     1     1      559            600        -</span><span style='color: #BB0000;'>1</span><span>      854            902</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>4</span><span>  </span><span style='text-decoration: underline;'>2</span><span>013     1     1      602            610        -</span><span style='color: #BB0000;'>8</span><span>      812            820</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>5</span><span>  </span><span style='text-decoration: underline;'>2</span><span>013     1     1      602            605        -</span><span style='color: #BB0000;'>3</span><span>      821            805</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>6</span><span>  </span><span style='text-decoration: underline;'>2</span><span>013     1     1      611            600        11      945            931</span></span>
<span class='c'>#&gt; <span style='color: #555555;'># … with 336,770 more rows, and 11 more variables: </span><span style='color: #555555;font-weight: bold;'>arr_delay</span><span style='color: #555555;'> </span><span style='color: #555555;font-style: italic;'>&lt;dbl&gt;</span><span style='color: #555555;'>,</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>#   </span><span style='color: #555555;font-weight: bold;'>carrier</span><span style='color: #555555;'> </span><span style='color: #555555;font-style: italic;'>&lt;chr&gt;</span><span style='color: #555555;'>, </span><span style='color: #555555;font-weight: bold;'>flight</span><span style='color: #555555;'> </span><span style='color: #555555;font-style: italic;'>&lt;int&gt;</span><span style='color: #555555;'>, </span><span style='color: #555555;font-weight: bold;'>tailnum</span><span style='color: #555555;'> </span><span style='color: #555555;font-style: italic;'>&lt;chr&gt;</span><span style='color: #555555;'>, </span><span style='color: #555555;font-weight: bold;'>origin</span><span style='color: #555555;'> </span><span style='color: #555555;font-style: italic;'>&lt;chr&gt;</span><span style='color: #555555;'>, </span><span style='color: #555555;font-weight: bold;'>dest</span><span style='color: #555555;'> </span><span style='color: #555555;font-style: italic;'>&lt;chr&gt;</span><span style='color: #555555;'>,</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>#   </span><span style='color: #555555;font-weight: bold;'>air_time</span><span style='color: #555555;'> </span><span style='color: #555555;font-style: italic;'>&lt;dbl&gt;</span><span style='color: #555555;'>, </span><span style='color: #555555;font-weight: bold;'>distance</span><span style='color: #555555;'> </span><span style='color: #555555;font-style: italic;'>&lt;dbl&gt;</span><span style='color: #555555;'>, </span><span style='color: #555555;font-weight: bold;'>hour</span><span style='color: #555555;'> </span><span style='color: #555555;font-style: italic;'>&lt;dbl&gt;</span><span style='color: #555555;'>, </span><span style='color: #555555;font-weight: bold;'>minute</span><span style='color: #555555;'> </span><span style='color: #555555;font-style: italic;'>&lt;dbl&gt;</span><span style='color: #555555;'>, </span><span style='color: #555555;font-weight: bold;'>time_hour</span><span style='color: #555555;'> </span><span style='color: #555555;font-style: italic;'>&lt;dttm&gt;</span></span></code></pre>

</div>

The data is now spread across four "shards" each consisting of around 80,000 rows. I grouped the data before partitioning because this ensures that all the observations in one group end up on the same worker.

You can work with this `party_df` as if it was a data frame, but any work will be spread out across all the processes (which your operating system will usually allocate to different cores). Once you're being expensive computation, you can bring the results back to the current session with [`collect()`](https://dplyr.tidyverse.org/reference/compute.html). Learn more in [`vignette("multidplyr")`](https://cran.rstudio.com/web/packages/multidplyr/vignettes/multidplyr.html).

multidplyr is a good fit for problems where the bottleneck is complex non-dplyr computation (e.g. fitting models). There's some overhead initial partitioning the data and then transferring the commands to each worker, so it's not a magic bullet. multidplyr is still quite young, but please try it out and [report any problems](https://github.com/tidyverse/multidplyr/issues) that you experience.

## dtplyr 1.1.0

[dtplyr](https://dtplyr.tidyverse.org) translates dplyr pipelines into the equivalent [data.table](http://r-datatable.com/) code. data.table is incredibly fast, so this often yields performance improvements. To use it start by creating a [`lazy_dt()`](https://rdrr.io/pkg/dtplyr/man/lazy_dt.html) object which records your dplyr actions:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://github.com/tidyverse/dtplyr'>dtplyr</a></span><span class='o'>)</span>
<span class='nv'>dt</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/pkg/dtplyr/man/lazy_dt.html'>lazy_dt</a></span><span class='o'>(</span><span class='nv'>mtcars</span><span class='o'>)</span>

<span class='nv'>cyl_summary</span> <span class='o'>&lt;-</span> <span class='nv'>dt</span> <span class='o'>%&gt;%</span> 
  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/group_by.html'>group_by</a></span><span class='o'>(</span><span class='nv'>cyl</span><span class='o'>)</span> <span class='o'>%&gt;%</span> 
  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/summarise.html'>summarise</a></span><span class='o'>(</span><span class='nf'><a href='https://dplyr.tidyverse.org/reference/across.html'>across</a></span><span class='o'>(</span><span class='nv'>disp</span><span class='o'>:</span><span class='nv'>wt</span>, <span class='nv'>mean</span><span class='o'>)</span><span class='o'>)</span></code></pre>

</div>

You can see the translation with [`show_query()`](https://dplyr.tidyverse.org/reference/explain.html) or execute the data table code by converting back to a data frame, data table, or tibble:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>cyl_summary</span> <span class='o'>%&gt;%</span> <span class='nf'><a href='https://dplyr.tidyverse.org/reference/explain.html'>show_query</a></span><span class='o'>(</span><span class='o'>)</span>
<span class='c'>#&gt; `_DT1`[, .(disp = mean(disp), hp = mean(hp), drat = mean(drat), </span>
<span class='c'>#&gt;     wt = mean(wt)), keyby = .(cyl)]</span>

<span class='nv'>cyl_summary</span> <span class='o'>%&gt;%</span> <span class='nf'><a href='https://tibble.tidyverse.org/reference/as_tibble.html'>as_tibble</a></span><span class='o'>(</span><span class='o'>)</span>
<span class='c'>#&gt; <span style='color: #555555;'># A tibble: 3 x 5</span></span>
<span class='c'>#&gt;     <span style='font-weight: bold;'>cyl</span><span>  </span><span style='font-weight: bold;'>disp</span><span>    </span><span style='font-weight: bold;'>hp</span><span>  </span><span style='font-weight: bold;'>drat</span><span>    </span><span style='font-weight: bold;'>wt</span></span>
<span class='c'>#&gt;   <span style='color: #555555;font-style: italic;'>&lt;dbl&gt;</span><span> </span><span style='color: #555555;font-style: italic;'>&lt;dbl&gt;</span><span> </span><span style='color: #555555;font-style: italic;'>&lt;dbl&gt;</span><span> </span><span style='color: #555555;font-style: italic;'>&lt;dbl&gt;</span><span> </span><span style='color: #555555;font-style: italic;'>&lt;dbl&gt;</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>1</span><span>     4  105.  82.6  4.07  2.29</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>2</span><span>     6  183. 122.   3.59  3.12</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>3</span><span>     8  353. 209.   3.23  4.00</span></span></code></pre>

</div>

The big news in this release is dtplyr can now translate all features that arrived in [dplyr 1.0.0](https://www.tidyverse.org/blog/2020/06/dplyr-1-0-0/). This includes:

-   [`across()`](https://dplyr.tidyverse.org/reference/across.html), [`if_any()`](https://dplyr.tidyverse.org/reference/across.html), and [`if_all()`](https://dplyr.tidyverse.org/reference/across.html). Unfortunately `where()` is not currently supported is `where()` because I don't know how to figure out the column types without executing the data table code.

    <div class="highlight">

    <pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>dt</span> <span class='o'>%&gt;%</span> 
      <span class='nf'><a href='https://dplyr.tidyverse.org/reference/filter.html'>filter</a></span><span class='o'>(</span><span class='nf'><a href='https://dplyr.tidyverse.org/reference/across.html'>if_any</a></span><span class='o'>(</span><span class='nv'>cyl</span><span class='o'>:</span><span class='nv'>wt</span>, <span class='nv'>is.na</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>%&gt;%</span> 
      <span class='nf'><a href='https://dplyr.tidyverse.org/reference/explain.html'>show_query</a></span><span class='o'>(</span><span class='o'>)</span>
    <span class='c'>#&gt; `_DT1`[is.na(cyl) | is.na(disp) | is.na(hp) | is.na(drat) | is.na(wt)]</span></code></pre>

    </div>

-   [`relocate()`](https://dplyr.tidyverse.org/reference/relocate.html), which is translated to the `j` argument of `[.data.table`:

    <div class="highlight">

    <pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>dt</span> <span class='o'>%&gt;%</span> 
      <span class='nf'><a href='https://dplyr.tidyverse.org/reference/relocate.html'>relocate</a></span><span class='o'>(</span><span class='nv'>carb</span>, .before <span class='o'>=</span> <span class='nv'>mpg</span><span class='o'>)</span> <span class='o'>%&gt;%</span> 
      <span class='nf'><a href='https://dplyr.tidyverse.org/reference/explain.html'>show_query</a></span><span class='o'>(</span><span class='o'>)</span>
    <span class='c'>#&gt; `_DT1`[, .(carb, mpg, cyl, disp, hp, drat, wt, qsec, vs, am, </span>
    <span class='c'>#&gt;     gear)]</span></code></pre>

    </div>

-   [`rename_with()`](https://dplyr.tidyverse.org/reference/rename.html), which is translated to [`setnames()`](https://Rdatatable.gitlab.io/data.table/reference/setattr.html):

    <div class="highlight">

    <pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>dt</span> <span class='o'>%&gt;%</span> 
      <span class='nf'><a href='https://dplyr.tidyverse.org/reference/rename.html'>rename_with</a></span><span class='o'>(</span><span class='nv'>toupper</span><span class='o'>)</span> <span class='o'>%&gt;%</span> 
      <span class='nf'><a href='https://dplyr.tidyverse.org/reference/explain.html'>show_query</a></span><span class='o'>(</span><span class='o'>)</span>
    <span class='c'>#&gt; setnames(copy(`_DT1`), toupper)</span></code></pre>

    </div>

-   [`slice_min()`](https://dplyr.tidyverse.org/reference/slice.html), [`slice_max()`](https://dplyr.tidyverse.org/reference/slice.html), [`slice_head()`](https://dplyr.tidyverse.org/reference/slice.html), [`slice_tail()`](https://dplyr.tidyverse.org/reference/slice.html), and [`slice_sample()`](https://dplyr.tidyverse.org/reference/slice.html) which are translated to various `i` and `j` expressions:

    <div class="highlight">

    <pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>dt</span> <span class='o'>%&gt;%</span> <span class='nf'><a href='https://dplyr.tidyverse.org/reference/group_by.html'>group_by</a></span><span class='o'>(</span><span class='nv'>cyl</span><span class='o'>)</span> <span class='o'>%&gt;%</span> <span class='nf'><a href='https://dplyr.tidyverse.org/reference/slice.html'>slice_sample</a></span><span class='o'>(</span>n <span class='o'>=</span> <span class='m'>5</span><span class='o'>)</span> <span class='o'>%&gt;%</span> <span class='nf'><a href='https://dplyr.tidyverse.org/reference/explain.html'>show_query</a></span><span class='o'>(</span><span class='o'>)</span>
    <span class='c'>#&gt; `_DT1`[`_DT1`[, .I[sample.int(.N, min(5L, .N))], by = .(cyl)]$V1]</span>
    <span class='nv'>dt</span> <span class='o'>%&gt;%</span> <span class='nf'><a href='https://dplyr.tidyverse.org/reference/group_by.html'>group_by</a></span><span class='o'>(</span><span class='nv'>cyl</span><span class='o'>)</span> <span class='o'>%&gt;%</span> <span class='nf'><a href='https://dplyr.tidyverse.org/reference/slice.html'>slice_head</a></span><span class='o'>(</span>n <span class='o'>=</span> <span class='m'>1</span><span class='o'>)</span> <span class='o'>%&gt;%</span> <span class='nf'><a href='https://dplyr.tidyverse.org/reference/explain.html'>show_query</a></span><span class='o'>(</span><span class='o'>)</span>
    <span class='c'>#&gt; `_DT1`[, head(.SD, 1L), keyby = .(cyl)]</span>
    <span class='nv'>dt</span> <span class='o'>%&gt;%</span> <span class='nf'><a href='https://dplyr.tidyverse.org/reference/group_by.html'>group_by</a></span><span class='o'>(</span><span class='nv'>cyl</span><span class='o'>)</span> <span class='o'>%&gt;%</span> <span class='nf'><a href='https://dplyr.tidyverse.org/reference/slice.html'>slice_min</a></span><span class='o'>(</span><span class='nv'>mpg</span>, n <span class='o'>=</span> <span class='m'>1</span><span class='o'>)</span> <span class='o'>%&gt;%</span> <span class='nf'><a href='https://dplyr.tidyverse.org/reference/explain.html'>show_query</a></span><span class='o'>(</span><span class='o'>)</span>
    <span class='c'>#&gt; `_DT1`[, .SD[order(mpg)][frankv(mpg, ties.method = "min", na.last = "keep") &lt;= </span>
    <span class='c'>#&gt;     1L], keyby = .(cyl)]</span></code></pre>

    </div>

Thanks to [Mark Fairbanks](https://github.com/markfairbanks), dtplyr has also gained it's first translation of a tidyr function: `pivot_wider()`, which is translated to [`dcast()`](https://Rdatatable.gitlab.io/data.table/reference/dcast.data.table.html). You can expect more tidyr translations in the next release!

I also took this as an opportunity to thoroughly refresh the documentation so that all translated verbs now have [their own help pages](https://dtplyr.tidyverse.org/reference/index.html) that briefly describes how the translation works. You can read about the other minor improvements and bug fixes in the [release notes](https://github.com/tidyverse/dtplyr/releases/tag/v1.1.0).

## dbplyr 2.1.0

[dbplyr](https://dbplyr.tidyverse.org) translates dplyr pipelines to their SQL equivalents. If you're new to using dplyr and SQL together, I highly recommend Ireve Steve's rstudio::global() talk [\"The dynamic duo: SQL and R](https://rstudio.com/resources/rstudioglobal-2021/the-dynamic-duo-sql-and-r/). It discusses why you might want to use dbplyr to generate SQL *and* why you should still learn SQL.

The biggest change to this release is the addition of many translations for tidyr verbs like [`pivot_longer()`](https://dbplyr.tidyverse.org/reference/pivot_longer.tbl_lazy.html), [`pivot_wider()`](https://dbplyr.tidyverse.org/reference/pivot_wider.tbl_lazy.html), [`complete()`](https://dbplyr.tidyverse.org/reference/complete.tbl_lazy.html), and [`replace_na()`](https://dbplyr.tidyverse.org/reference/replace_na.tbl_lazy.html). These were contributed by [Maximilian Girlich](https://github.com/mgirlich), and in recognition of his sustained and substantial contributions to the package, he has been added as a package author.

This release also includes major improvements to [`across()`](https://dplyr.tidyverse.org/reference/across.html) translation, including translation of formulas (like dtplyr, [`across()`](https://dplyr.tidyverse.org/reference/across.html) can't currently use `where()`, because I don't know of a way to figure out the column types without executing the query). The release also includes a bunch of other minor translation improvements and bug fixes, which you can read about in the [release notes](https://github.com/tidyverse/dbplyr/releases/tag/v2.1.0).

## Acknowledgements

A big thanks to all of the contributors who helped make these releases possible:

-   dbplyr: [@abalter](https://github.com/abalter), [@Alternikaner](https://github.com/Alternikaner), [@andrew-schulman](https://github.com/andrew-schulman), [@andyquinterom](https://github.com/andyquinterom), [@awong234](https://github.com/awong234), [@ben1787](https://github.com/ben1787), [@bersbersbers](https://github.com/bersbersbers), [@bwcastillo](https://github.com/bwcastillo), [@chris-billingham](https://github.com/chris-billingham), [@coponhub](https://github.com/coponhub), [@DavidPatShuiFong](https://github.com/DavidPatShuiFong), [@dcaud](https://github.com/dcaud), [@dpprdan](https://github.com/dpprdan), [@dstoeckel](https://github.com/dstoeckel), [@elicit-bergmann](https://github.com/elicit-bergmann), [@hadley](https://github.com/hadley), [@hdplsa](https://github.com/hdplsa), [@iangow](https://github.com/iangow), [@Janlow](https://github.com/Janlow), [@LukasTang](https://github.com/LukasTang), [@McWraith](https://github.com/McWraith), [@mfherman](https://github.com/mfherman), [@mgirlich](https://github.com/mgirlich), [@mr-c](https://github.com/mr-c), [@mszefler](https://github.com/mszefler), [@N1h1l1sT](https://github.com/N1h1l1sT), [@nathaneastwood](https://github.com/nathaneastwood), [@nlneas1](https://github.com/nlneas1), [@okhoma](https://github.com/okhoma), [@pachamaltese](https://github.com/pachamaltese), [@peterdutey](https://github.com/peterdutey), [@pgramme](https://github.com/pgramme), [@robchallen](https://github.com/robchallen), [@shearer](https://github.com/shearer), [@sheepworrier](https://github.com/sheepworrier), [@shosaco](https://github.com/shosaco), [@spirosparaskevasFBB](https://github.com/spirosparaskevasFBB), [@tonyk7440](https://github.com/tonyk7440), [@TuomoNieminen](https://github.com/TuomoNieminen), [@yitao-li](https://github.com/yitao-li), and [@yiugn](https://github.com/yiugn)

-   dtplyr: [@AdrienMtgn](https://github.com/AdrienMtgn), [@batpigandme](https://github.com/batpigandme), [@boerjames](https://github.com/boerjames), [@cassiel74](https://github.com/cassiel74), [@dan-reznik](https://github.com/dan-reznik), [@ds-jim](https://github.com/ds-jim), [@edavidaja](https://github.com/edavidaja), [@edgararuiz-zz](https://github.com/edgararuiz-zz), [@engineerchange](https://github.com/engineerchange), [@fkgruber](https://github.com/fkgruber), [@gmonaie](https://github.com/gmonaie), [@hadley](https://github.com/hadley), [@hope-data-science](https://github.com/hope-data-science), [@jasonopolis](https://github.com/jasonopolis), [@jimhester](https://github.com/jimhester), [@JohnMount](https://github.com/JohnMount), [@larspijnappel](https://github.com/larspijnappel), [@lbenz-mdsol](https://github.com/lbenz-mdsol), [@markfairbanks](https://github.com/markfairbanks), [@MichaelChirico](https://github.com/MichaelChirico), [@Mitschka](https://github.com/Mitschka), [@myoung3](https://github.com/myoung3), [@nigeljmckernan](https://github.com/nigeljmckernan), [@PMassicotte](https://github.com/PMassicotte), [@pnacht](https://github.com/pnacht), [@psanker](https://github.com/psanker), [@rossellhayes](https://github.com/rossellhayes), [@RudolfCardinal](https://github.com/RudolfCardinal), [@sbashevkin](https://github.com/sbashevkin), [@ShixiangWang](https://github.com/ShixiangWang), [@skiamu](https://github.com/skiamu), [@smingerson](https://github.com/smingerson), [@sonoshah](https://github.com/sonoshah), [@tingjhenjiang](https://github.com/tingjhenjiang), [@tylerferguson](https://github.com/tylerferguson), [@TysonStanley](https://github.com/TysonStanley), [@yiugn](https://github.com/yiugn), and [@ykaeber](https://github.com/ykaeber).

-   multidplyr: [@12tafran](https://github.com/12tafran), [@adviksh](https://github.com/adviksh), [@ahoho](https://github.com/ahoho), [@baldeagle](https://github.com/baldeagle), [@borisveytsman](https://github.com/borisveytsman), [@brianmsm](https://github.com/brianmsm), [@ChiWPak](https://github.com/ChiWPak), [@cluelessgumshoe](https://github.com/cluelessgumshoe), [@CorradoLanera](https://github.com/CorradoLanera), [@cscheid](https://github.com/cscheid), [@cwaldock1](https://github.com/cwaldock1), [@damiaan](https://github.com/damiaan), [@david-awam-jansen](https://github.com/david-awam-jansen), [@dewoller](https://github.com/dewoller), [@donaldRwilliams](https://github.com/donaldRwilliams), [@dzhang32](https://github.com/dzhang32), [@eliferden](https://github.com/eliferden), [@FvD](https://github.com/FvD), [@GegznaV](https://github.com/GegznaV), [@germanium](https://github.com/germanium), [@ghost](https://github.com/ghost), [@guokai8](https://github.com/guokai8), [@hadley](https://github.com/hadley), [@huisaddison](https://github.com/huisaddison), [@iago-pssjd](https://github.com/iago-pssjd), [@impactanalysts](https://github.com/impactanalysts), [@isaac-florence](https://github.com/isaac-florence), [@javadba](https://github.com/javadba), [@jiho](https://github.com/jiho), [@JosiahParry](https://github.com/JosiahParry), [@julou](https://github.com/julou), [@kartiksubbarao](https://github.com/kartiksubbarao), [@kyp0717](https://github.com/kyp0717), [@lucazav](https://github.com/lucazav), [@MarioClueless](https://github.com/MarioClueless), [@Maschette](https://github.com/Maschette), [@McChickenNuggets](https://github.com/McChickenNuggets), [@miho87](https://github.com/miho87), [@njudd](https://github.com/njudd), [@philiporlando](https://github.com/philiporlando), [@picarus](https://github.com/picarus), [@samkhan1](https://github.com/samkhan1), [@SGMStalin](https://github.com/SGMStalin), [@stanstrup](https://github.com/stanstrup), [@taqtiqa-mark](https://github.com/taqtiqa-mark), [@tmstauss](https://github.com/tmstauss), [@tsengj](https://github.com/tsengj), [@wibeasley](https://github.com/wibeasley), [@willtudorevans](https://github.com/willtudorevans), and [@zhengjiji456](https://github.com/zhengjiji456).

