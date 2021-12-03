---
output: hugodown::hugo_document

slug: dtplyr-1-2-0
title: dtplyr 1.2.0
date: 2021-12-03
author: Hadley Wickham
description: >
    dtplyr 1.2.0 adds three new authors, a bunch of tidyr translations,
    new join translations, and many minor translation improvements.
    
photo:
  url: https://unsplash.com/photos/uRQlCmfOCRg
  author: Zdeněk Macháček

# one of: "deep-dive", "learn", "package", "programming", "roundup", or "other"
categories: [package] 
tags: [dplyr]
rmd_hash: 3680bbbf3ab6f7d0

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

We're thrilled to announce that [dtplyr](https://dtplyr.tidyverse.org) 1.0.0 is now on CRAN. dtplyr gives you the speed of [data.table](http://r-datatable.com/) with the syntax of dplyr; you write dplyr (and tidyr) code and dtplyr translates it to the data.table equivalent.

You can install dtplyr from CRAN with:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://rdrr.io/r/utils/install.packages.html'>install.packages</a></span><span class='o'>(</span><span class='s'>"dtplyr"</span><span class='o'>)</span></code></pre>

</div>

I'll discuss three major changes in this blog post:

-   New authors
-   New tidyr translations
-   Improvements to join translations

There are also over 20 minor improvements to the quality of translations; you can see a full list in the [release notes](https://github.com/tidyverse/dtplyr/blob/main/NEWS.md).

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://dtplyr.tidyverse.org'>dtplyr</a></span><span class='o'>)</span>

<span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://dplyr.tidyverse.org'>dplyr</a></span>, warn.conflicts <span class='o'>=</span> <span class='kc'>FALSE</span><span class='o'>)</span>
<span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://tidyr.tidyverse.org'>tidyr</a></span><span class='o'>)</span></code></pre>

</div>

## New authors

The biggest news in this release is the addition of three new [authors](https://github.com/tidyverse/tidyups/blob/main/004-governance.md#authors): [Mark Fairbanks](https://github.com/markfairbanks), [Maximilian Girlich](https://github.com/mgirlich), and [Ryan Dickerson](https://github.com/eutwt) are now dtplyr authors in recognition of their significant and sustained contributions. In fact, they implemented the bulk of the improvements in this release!

## tidyr translations

dtplyr gains translations for many more tidyr verbs including [`complete()`](https://tidyr.tidyverse.org/reference/complete.html), [`drop_na()`](https://tidyr.tidyverse.org/reference/drop_na.html), [`expand()`](https://tidyr.tidyverse.org/reference/expand.html), [`fill()`](https://tidyr.tidyverse.org/reference/fill.html), [`nest()`](https://tidyr.tidyverse.org/reference/nest.html), [`pivot_longer()`](https://tidyr.tidyverse.org/reference/pivot_longer.html), [`replace_na()`](https://tidyr.tidyverse.org/reference/replace_na.html), and [`separate()`](https://tidyr.tidyverse.org/reference/separate.html). A few examples are shown below:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>dt</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://dtplyr.tidyverse.org/reference/lazy_dt.html'>lazy_dt</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/data.frame.html'>data.frame</a></span><span class='o'>(</span>x <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='kc'>NA</span>, <span class='s'>"x.y"</span>, <span class='s'>"x.z"</span>, <span class='s'>"y.z"</span><span class='o'>)</span><span class='o'>)</span><span class='o'>)</span>
<span class='nv'>dt</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span> 
  <span class='nf'><a href='https://tidyr.tidyverse.org/reference/separate.html'>separate</a></span><span class='o'>(</span><span class='nv'>x</span>, <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"A"</span>, <span class='s'>"B"</span><span class='o'>)</span>, sep <span class='o'>=</span> <span class='s'>"\\."</span>, remove <span class='o'>=</span> <span class='kc'>FALSE</span><span class='o'>)</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span> 
  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/explain.html'>show_query</a></span><span class='o'>(</span><span class='o'>)</span>
<span class='c'>#&gt; copy(`_DT1`)[, `:=`(c("A", "B"), tstrsplit(x, split = "\\."))]</span>

<span class='nv'>dt</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://dtplyr.tidyverse.org/reference/lazy_dt.html'>lazy_dt</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/data.frame.html'>data.frame</a></span><span class='o'>(</span>x <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='m'>1</span>, <span class='kc'>NA</span>, <span class='kc'>NA</span>, <span class='m'>2</span>, <span class='kc'>NA</span><span class='o'>)</span><span class='o'>)</span><span class='o'>)</span>
<span class='nv'>dt</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span> 
  <span class='nf'><a href='https://tidyr.tidyverse.org/reference/fill.html'>fill</a></span><span class='o'>(</span><span class='nv'>x</span><span class='o'>)</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span> 
  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/explain.html'>show_query</a></span><span class='o'>(</span><span class='o'>)</span>
<span class='c'>#&gt; copy(`_DT2`)[, `:=`(x = nafill(x, "locf"))]</span>

<span class='nv'>dt</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span> 
  <span class='nf'><a href='https://tidyr.tidyverse.org/reference/replace_na.html'>replace_na</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span>x <span class='o'>=</span> <span class='m'>99</span><span class='o'>)</span><span class='o'>)</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span> 
  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/explain.html'>show_query</a></span><span class='o'>(</span><span class='o'>)</span>
<span class='c'>#&gt; copy(`_DT2`)[, `:=`(x = fcoalesce(x, 99))]</span>

<span class='nv'>dt</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://dtplyr.tidyverse.org/reference/lazy_dt.html'>lazy_dt</a></span><span class='o'>(</span><span class='nv'>relig_income</span><span class='o'>)</span>
<span class='nv'>dt</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span>
  <span class='nf'><a href='https://tidyr.tidyverse.org/reference/pivot_longer.html'>pivot_longer</a></span><span class='o'>(</span><span class='o'>!</span><span class='nv'>religion</span>, names_to <span class='o'>=</span> <span class='s'>"income"</span>, values_to <span class='o'>=</span> <span class='s'>"count"</span><span class='o'>)</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span> 
  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/explain.html'>show_query</a></span><span class='o'>(</span><span class='o'>)</span>
<span class='c'>#&gt; melt(`_DT3`, measure.vars = c("&lt;$10k", "$10-20k", "$20-30k", </span>
<span class='c'>#&gt; "$30-40k", "$40-50k", "$50-75k", "$75-100k", "$100-150k", "&gt;150k", </span>
<span class='c'>#&gt; "Don't know/refused"), variable.name = "income", value.name = "count", </span>
<span class='c'>#&gt;     variable.factor = FALSE)</span></code></pre>

</div>

## Improvements to joins

The join functions have been overhauled: [`inner_join()`](https://dplyr.tidyverse.org/reference/mutate-joins.html), [`left_join()`](https://dplyr.tidyverse.org/reference/mutate-joins.html), and [`right_join()`](https://dplyr.tidyverse.org/reference/mutate-joins.html) now all produce a call to `[`, rather than to [`merge()`](https://rdrr.io/r/base/merge.html):

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>dt1</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://dtplyr.tidyverse.org/reference/lazy_dt.html'>lazy_dt</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/data.frame.html'>data.frame</a></span><span class='o'>(</span>x <span class='o'>=</span> <span class='m'>1</span><span class='o'>:</span><span class='m'>3</span><span class='o'>)</span><span class='o'>)</span>
<span class='nv'>dt2</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://dtplyr.tidyverse.org/reference/lazy_dt.html'>lazy_dt</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/data.frame.html'>data.frame</a></span><span class='o'>(</span>x <span class='o'>=</span> <span class='m'>2</span><span class='o'>:</span><span class='m'>3</span>, y <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"a"</span>, <span class='s'>"b"</span><span class='o'>)</span><span class='o'>)</span><span class='o'>)</span>

<span class='nv'>dt1</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span> <span class='nf'><a href='https://dplyr.tidyverse.org/reference/mutate-joins.html'>inner_join</a></span><span class='o'>(</span><span class='nv'>dt2</span>, by <span class='o'>=</span> <span class='s'>"x"</span><span class='o'>)</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span> <span class='nf'><a href='https://dplyr.tidyverse.org/reference/explain.html'>show_query</a></span><span class='o'>(</span><span class='o'>)</span>
<span class='c'>#&gt; `_DT4`[`_DT5`, on = .(x), nomatch = NULL, allow.cartesian = TRUE]</span>
<span class='nv'>dt1</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span> <span class='nf'><a href='https://dplyr.tidyverse.org/reference/mutate-joins.html'>left_join</a></span><span class='o'>(</span><span class='nv'>dt2</span>, by <span class='o'>=</span> <span class='s'>"x"</span><span class='o'>)</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span> <span class='nf'><a href='https://dplyr.tidyverse.org/reference/explain.html'>show_query</a></span><span class='o'>(</span><span class='o'>)</span>
<span class='c'>#&gt; `_DT5`[`_DT4`, on = .(x), allow.cartesian = TRUE]</span>
<span class='nv'>dt2</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span> <span class='nf'><a href='https://dplyr.tidyverse.org/reference/mutate-joins.html'>right_join</a></span><span class='o'>(</span><span class='nv'>dt1</span>, by <span class='o'>=</span> <span class='s'>"x"</span><span class='o'>)</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span> <span class='nf'><a href='https://dplyr.tidyverse.org/reference/explain.html'>show_query</a></span><span class='o'>(</span><span class='o'>)</span>
<span class='c'>#&gt; `_DT5`[`_DT4`, on = .(x), allow.cartesian = TRUE]</span></code></pre>

</div>

This can make the translation a little longer for simple joins, but it greatly simplifies the underlying code. This simplification has made it easier to more closely match dplyr behaviour for column order, handling named `by` specifications, Cartesian joins with `by = character()`, and managing duplicated variable names.

## Acknowledgements

As always, tidyverse packages wouldn't be possible with the community, so a big thanks goes out to all 35 folks who helped to make this release a reality: [@akr-source](https://github.com/akr-source), [@batpigandme](https://github.com/batpigandme), [@bguillod](https://github.com/bguillod), [@cgoo4](https://github.com/cgoo4), [@chenx2018](https://github.com/chenx2018), [@D-Se](https://github.com/D-Se), [@eutwt](https://github.com/eutwt), [@hadley](https://github.com/hadley), [@jatherrien](https://github.com/jatherrien), [@jdmoralva](https://github.com/jdmoralva), [@jennybc](https://github.com/jennybc), [@jtlandis](https://github.com/jtlandis), [@kmishra9](https://github.com/kmishra9), [@lutzgruber](https://github.com/lutzgruber), [@lutzgruber-quantco](https://github.com/lutzgruber-quantco), [@markfairbanks](https://github.com/markfairbanks), [@mgirlich](https://github.com/mgirlich), [@mrcaseb](https://github.com/mrcaseb), [@nassuphis](https://github.com/nassuphis), [@nigeljmckernan](https://github.com/nigeljmckernan), [@NZambranoc](https://github.com/NZambranoc), [@PMassicotte](https://github.com/PMassicotte), [@psads-git](https://github.com/psads-git), [@quid-agis](https://github.com/quid-agis), [@romainfrancois](https://github.com/romainfrancois), [@roni-fultheim](https://github.com/roni-fultheim), [@samlipworth](https://github.com/samlipworth), [@sanjmeh](https://github.com/sanjmeh), [@sbashevkin](https://github.com/sbashevkin), [@StatsGary](https://github.com/StatsGary), [@torema-ed](https://github.com/torema-ed), [@verajosemanuel](https://github.com/verajosemanuel), [@Waldi73](https://github.com/Waldi73), [@wurli](https://github.com/wurli), and [@yiugn](https://github.com/yiugn).

