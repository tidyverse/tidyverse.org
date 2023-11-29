---
output: hugodown::hugo_document

slug: scales-1-3-0
title: scales 1.3.0
date: 2023-11-27
author: Thomas Lin Pedersen
description: >
    scales 1.3.0 is a minor release focusing on streamlining the API and gradual
    improvements of the existing utilities

photo:
  url: https://unsplash.com/photos/gold-and-silver-round-frame-magnifying-glass-j06gLuKK0GM
  author: Elena Mozhvilo

# one of: "deep-dive", "learn", "package", "programming", "roundup", or "other"
categories: [package] 
tags: [scales]
rmd_hash: 4165ea691aaa6163

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

We're delighted to announce the release of [scales](https://scales.r-lib.org) 1.3.0. scales is a packages that extracts much of the scaling logic that is used in ggplot2 to a general framework, along with utility functions for e.g. formatting labels or creating color palettes.

You can install it from CRAN with:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://rdrr.io/r/utils/install.packages.html'>install.packages</a></span><span class='o'>(</span><span class='s'>"scales"</span><span class='o'>)</span>
</code></pre>

</div>

This blog post will give a quick overview of the 1.3.0 release, which is mainly an upkeep release but does contain a few interesting tidbits.

You can see a full list of changes in the [release notes](https://scales.r-lib.org/news/index.html)

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://scales.r-lib.org'>scales</a></span><span class='o'>)</span>
<span class='nf'><a href='https://rdrr.io/r/base/Random.html'>set.seed</a></span><span class='o'>(</span><span class='m'>1</span><span class='o'>)</span>
</code></pre>

</div>

## Proper support for difftime objects

While scales had rudimentary support for objects from the hms package, I did not support the more common base R difftime objects. This is now rectified with the introduction of [`label_timespan()`](https://scales.r-lib.org/reference/label_date.html), [`breaks_timespan()`](https://scales.r-lib.org/reference/breaks_timespan.html), and [`transform_timespan()`](https://scales.r-lib.org/reference/transform_timespan.html). While the labels and breaks function can be used on their own, all the behavior is encapsulated in the timespan transform object which is kin to [`transform_hms()`](https://scales.r-lib.org/reference/transform_timespan.html).

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://ggplot2.tidyverse.org'>ggplot2</a></span><span class='o'>)</span>

<span class='nv'>events</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/data.frame.html'>data.frame</a></span><span class='o'>(</span>
  time <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/difftime.html'>as.difftime</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/stats/Uniform.html'>runif</a></span><span class='o'>(</span><span class='m'>30</span>, max <span class='o'>=</span> <span class='m'>200</span><span class='o'>)</span>, units <span class='o'>=</span> <span class='s'>"secs"</span><span class='o'>)</span>,
  magnitude <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/stats/Normal.html'>rnorm</a></span><span class='o'>(</span><span class='m'>30</span><span class='o'>)</span> <span class='o'>+</span> <span class='m'>2</span>
<span class='o'>)</span>

<span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggplot.html'>ggplot</a></span><span class='o'>(</span><span class='nv'>events</span><span class='o'>)</span> <span class='o'>+</span> 
  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/geom_point.html'>geom_point</a></span><span class='o'>(</span>
    <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/aes.html'>aes</a></span><span class='o'>(</span><span class='nv'>time</span>, y <span class='o'>=</span> <span class='m'>0</span>, size <span class='o'>=</span> <span class='nv'>magnitude</span><span class='o'>)</span>, 
    position <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/position_jitter.html'>position_jitter</a></span><span class='o'>(</span>width <span class='o'>=</span> <span class='m'>0</span><span class='o'>)</span>
  <span class='o'>)</span> <span class='o'>+</span> 
  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/scale_continuous.html'>scale_x_continuous</a></span><span class='o'>(</span>trans <span class='o'>=</span> <span class='nf'><a href='https://scales.r-lib.org/reference/transform_timespan.html'>transform_timespan</a></span><span class='o'>(</span><span class='o'>)</span><span class='o'>)</span>

</code></pre>
<img src="figs/unnamed-chunk-2-1.png" width="700px" style="display: block; margin: auto;" />

</div>

As we can see the timespan transform automatically picks the unit of the difftime object. Further it identifies that for this range, adding breaks for minutes makes most sense.

If we had recorded time as hours rather than seconds, we can see how that affects the labelling:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>events</span><span class='o'>$</span><span class='nv'>time</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/difftime.html'>as.difftime</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/stats/Uniform.html'>runif</a></span><span class='o'>(</span><span class='m'>30</span>, max <span class='o'>=</span> <span class='m'>200</span><span class='o'>)</span>, units <span class='o'>=</span> <span class='s'>"hours"</span><span class='o'>)</span>
<span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggplot.html'>ggplot</a></span><span class='o'>(</span><span class='nv'>events</span><span class='o'>)</span> <span class='o'>+</span> 
  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/geom_point.html'>geom_point</a></span><span class='o'>(</span>
    <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/aes.html'>aes</a></span><span class='o'>(</span><span class='nv'>time</span>, y <span class='o'>=</span> <span class='m'>0</span>, size <span class='o'>=</span> <span class='nv'>magnitude</span><span class='o'>)</span>, 
    position <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/position_jitter.html'>position_jitter</a></span><span class='o'>(</span>width <span class='o'>=</span> <span class='m'>0</span><span class='o'>)</span>
  <span class='o'>)</span> <span class='o'>+</span> 
  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/scale_continuous.html'>scale_x_continuous</a></span><span class='o'>(</span>trans <span class='o'>=</span> <span class='nf'><a href='https://scales.r-lib.org/reference/transform_timespan.html'>transform_timespan</a></span><span class='o'>(</span><span class='o'>)</span><span class='o'>)</span>

</code></pre>
<img src="figs/unnamed-chunk-3-1.png" width="700px" style="display: block; margin: auto;" />

</div>

## API brush-up

scales has gone through a number of touch-ups on its API, such as revamping the labels functions to all start with `label_`. This release we continue (and hopefully conclude) the touch-ups by using a common prefix for the transformation utilities (`transform_`) and palettes (`pal_`). We have also rename [`label_dollar()`](https://scales.r-lib.org/reference/dollar_format.html) to [`label_currency()`](https://scales.r-lib.org/reference/label_currency.html) to make it clear that this can be used for any type of currency, not just dollars (US or otherwise). All the old functions have been kept around with no plan of deprecation but we advise you to update your code to use the new names.

## More transformation power

This release also includes some other updates to the transformations. They have received a fair amount of bug fixes and a new built-in transformation type has joined the group: [`transform_asinh()`](https://scales.r-lib.org/reference/transform_asinh.html), the inverse hyperbolic sine transformation, can be used much like log transformations, but it also supports negative values.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://rdrr.io/r/graphics/plot.default.html'>plot</a></span><span class='o'>(</span><span class='nf'><a href='https://scales.r-lib.org/reference/transform_asinh.html'>transform_asinh</a></span><span class='o'>(</span><span class='o'>)</span>, xlim <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='o'>-</span><span class='m'>100</span>, <span class='m'>100</span><span class='o'>)</span><span class='o'>)</span>
<span class='nf'><a href='https://rdrr.io/r/graphics/lines.html'>lines</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/seq.html'>seq</a></span><span class='o'>(</span><span class='o'>-</span><span class='m'>100</span>, <span class='m'>100</span><span class='o'>)</span>, <span class='nf'><a href='https://scales.r-lib.org/reference/transform_log.html'>transform_log</a></span><span class='o'>(</span><span class='o'>)</span><span class='o'>$</span><span class='nf'>transform</span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/seq.html'>seq</a></span><span class='o'>(</span><span class='o'>-</span><span class='m'>100</span>, <span class='m'>100</span><span class='o'>)</span><span class='o'>)</span>, col <span class='o'>=</span> <span class='s'>"red"</span><span class='o'>)</span>
<span class='nf'><a href='https://rdrr.io/r/graphics/text.html'>text</a></span><span class='o'>(</span><span class='m'>50</span>, <span class='m'>3</span>, label <span class='o'>=</span> <span class='s'>"log-transform"</span>, col <span class='o'>=</span> <span class='s'>"red"</span>, adj <span class='o'>=</span> <span class='m'>0</span><span class='o'>)</span>

</code></pre>
<img src="figs/unnamed-chunk-4-1.png" width="700px" style="display: block; margin: auto;" />

</div>

Transformation objects can now also (optionally) record the derivatives and inverse derivative which makes it possible to properly correct density estimations of transformed values.

## Fixes to range training in discrete scales

The training of discrete ranges has seen a few changes that hopefully makes it more predictable what happens when you train a range based on factors or character vectors. When training based on factors the ordering of the range will follow the order of the levels in the factor as they are encountered. New values will be appended to the end of the range. For character vectors the range will always stay sorted alphanumerically. Mixing of character and factors during training will lead to undefined ordering. This has always been the advertised behavior but it was not applied consistently up until now. As a result you may see the occational reordering of e.g. legends in ggplot2 after upgrading scales.

## Acknowledgements

[@AndreeWarby](https://github.com/AndreeWarby), [@ari-nz](https://github.com/ari-nz), [@BioinformaNicks](https://github.com/BioinformaNicks), [@bwiernik](https://github.com/bwiernik), [@ccsarapas](https://github.com/ccsarapas), [@CMKnott](https://github.com/CMKnott), [@DanChaltiel](https://github.com/DanChaltiel), [@davidhodge931](https://github.com/davidhodge931), [@DavisVaughan](https://github.com/DavisVaughan), [@dmurdoch](https://github.com/dmurdoch), [@EricMarcon](https://github.com/EricMarcon), [@Generalized](https://github.com/Generalized), [@hadley](https://github.com/hadley), [@JJHelly](https://github.com/JJHelly), [@joshuaylevy](https://github.com/joshuaylevy), [@jzadra](https://github.com/jzadra), [@kuriwaki](https://github.com/kuriwaki), [@larmarange](https://github.com/larmarange), [@laurejo1](https://github.com/laurejo1), [@lz1nwm](https://github.com/lz1nwm), [@MikkoVihtakari](https://github.com/MikkoVihtakari), [@mjskay](https://github.com/mjskay), [@pearsonca](https://github.com/pearsonca), [@Saadi4469](https://github.com/Saadi4469), [@teunbrand](https://github.com/teunbrand), [@thomasp85](https://github.com/thomasp85), and [@zeehio](https://github.com/zeehio).

