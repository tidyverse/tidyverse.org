---
output: hugodown::hugo_document

slug: scales-1-2-0
title: scales 1.2.0
date: 2022-04-12
author: Hadley Wickham
description: >
    scales 1.2.0 brings a number of small but useful improvements 
    to numeric labels.

photo:
  url: https://unsplash.com/photos/98MbUldcDJY
  author: Piret Ilver

# one of: "deep-dive", "learn", "package", "programming", "roundup", or "other"
categories: [package] 
tags: [ggplot2, scales]
rmd_hash: e2cae25e456cfd1d

---

<!--
TODO:
* [x] Look over / edit the post's title in the yaml
* [x] Edit (or delete) the description; note this appears in the Twitter card
* [x] Pick category and tags (see existing with [`hugodown::tidy_show_meta()`](https://rdrr.io/pkg/hugodown/man/use_tidy_post.html))
* [ ] Find photo & update yaml metadata
* [x] Create `thumbnail-sq.jpg`; height and width should be equal
* [x] Create `thumbnail-wd.jpg`; width should be >5x height
* [x] [`hugodown::use_tidy_thumbnails()`](https://rdrr.io/pkg/hugodown/man/use_tidy_post.html)
* [x] Add intro sentence, e.g. the standard tagline for the package
* [x] [`usethis::use_tidy_thanks()`](https://usethis.r-lib.org/reference/use_tidy_thanks.html)
-->

We're very pleased to announce the release of [scales](https://scales.r-lib.org) 1.2.0. The scales package provides much of the infrastructure that underlies ggplot2's scales, and using it allow you to customize the transformations, breaks, and labels used by ggplot2. You can install it from CRAN with:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://rdrr.io/r/utils/install.packages.html'>install.packages</a></span><span class='o'>(</span><span class='s'>"scales"</span><span class='o'>)</span></code></pre>

</div>

This blog post will show off a few new features for labeling numbers, log scales, and currencies. You can see a full list of changes in the [release notes](https://github.com/r-lib/scales/blob/main/NEWS.md).

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://ggplot2.tidyverse.org'>ggplot2</a></span><span class='o'>)</span>
<span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://scales.r-lib.org'>scales</a></span><span class='o'>)</span></code></pre>

</div>

## Numbers

[`label_number()`](https://scales.r-lib.org/reference/label_number.html) is the workhorse that powers ggplot2's formatting of numbers, including [`label_dollar()`](https://scales.r-lib.org/reference/label_dollar.html) and [`label_comma()`](https://scales.r-lib.org/reference/label_number.html). This release added a number of useful new features.

The most important is a new `scale_cut` argument that makes it possible to independently scales different parts of the range. This is useful for scales that span multiple orders of magnitude. Take the following two examples which don't get great labels by default:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>df1</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/data.frame.html'>data.frame</a></span><span class='o'>(</span>
  x <span class='o'>=</span> <span class='m'>10</span> <span class='o'>^</span> <span class='nf'><a href='https://rdrr.io/r/stats/Uniform.html'>runif</a></span><span class='o'>(</span><span class='m'>1000</span>, <span class='m'>2</span>, <span class='m'>9</span><span class='o'>)</span>,
  y <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/stats/Uniform.html'>runif</a></span><span class='o'>(</span><span class='m'>1000</span><span class='o'>)</span>
<span class='o'>)</span>
<span class='nv'>df2</span> <span class='o'>&lt;-</span> <span class='nv'>df1</span> |&gt; <span class='nf'>dplyr</span><span class='nf'>::</span><span class='nf'><a href='https://dplyr.tidyverse.org/reference/filter.html'>filter</a></span><span class='o'>(</span><span class='nv'>x</span> <span class='o'>&lt;=</span> <span class='m'>1.25</span> <span class='o'>*</span> <span class='m'>10</span><span class='o'>^</span><span class='m'>6</span><span class='o'>)</span>

<span class='nv'>plot1</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggplot.html'>ggplot</a></span><span class='o'>(</span><span class='nv'>df1</span>, <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/aes.html'>aes</a></span><span class='o'>(</span><span class='nv'>x</span>, <span class='nv'>y</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>+</span> 
  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/geom_point.html'>geom_point</a></span><span class='o'>(</span><span class='o'>)</span> <span class='o'>+</span>
  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/labs.html'>labs</a></span><span class='o'>(</span>x <span class='o'>=</span> <span class='kc'>NULL</span>, y <span class='o'>=</span> <span class='kc'>NULL</span><span class='o'>)</span>
<span class='nv'>plot1</span> <span class='o'>+</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/scale_continuous.html'>scale_x_log10</a></span><span class='o'>(</span><span class='o'>)</span>
</code></pre>
<img src="figs/unnamed-chunk-3-1.png" width="700px" style="display: block; margin: auto;" />
<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>plot2</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggplot.html'>ggplot</a></span><span class='o'>(</span><span class='nv'>df2</span>, <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/aes.html'>aes</a></span><span class='o'>(</span><span class='nv'>x</span>, <span class='nv'>y</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>+</span> 
  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/geom_point.html'>geom_point</a></span><span class='o'>(</span><span class='o'>)</span><span class='o'>+</span>
  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/labs.html'>labs</a></span><span class='o'>(</span>x <span class='o'>=</span> <span class='kc'>NULL</span>, y <span class='o'>=</span> <span class='kc'>NULL</span><span class='o'>)</span>
<span class='nv'>plot2</span>
</code></pre>
<img src="figs/unnamed-chunk-3-2.png" width="700px" style="display: block; margin: auto;" />

</div>

You can use [`cut_short_scale()`](https://scales.r-lib.org/reference/number.html) to show thousands with a K suffix, millions with a M suffix, and billions with a B suffix:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>plot1</span> <span class='o'>+</span>
  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/scale_continuous.html'>scale_x_log10</a></span><span class='o'>(</span>
    labels <span class='o'>=</span> <span class='nf'><a href='https://scales.r-lib.org/reference/label_number.html'>label_number</a></span><span class='o'>(</span>scale_cut <span class='o'>=</span> <span class='nf'><a href='https://scales.r-lib.org/reference/number.html'>cut_short_scale</a></span><span class='o'>(</span><span class='o'>)</span><span class='o'>)</span>
  <span class='o'>)</span>
</code></pre>
<img src="figs/unnamed-chunk-4-1.png" width="700px" style="display: block; margin: auto;" />
<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>plot2</span> <span class='o'>+</span>
  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/scale_continuous.html'>scale_x_continuous</a></span><span class='o'>(</span>
    labels <span class='o'>=</span> <span class='nf'><a href='https://scales.r-lib.org/reference/label_number.html'>label_number</a></span><span class='o'>(</span>scale_cut <span class='o'>=</span> <span class='nf'><a href='https://scales.r-lib.org/reference/number.html'>cut_short_scale</a></span><span class='o'>(</span><span class='o'>)</span><span class='o'>)</span>
  <span class='o'>)</span>
</code></pre>
<img src="figs/unnamed-chunk-4-2.png" width="700px" style="display: block; margin: auto;" />

</div>

(If your country uses 1 billion to mean 1 million million, then you can use [`cut_long_scale()`](https://scales.r-lib.org/reference/number.html) instead of [`cut_short_scale()`](https://scales.r-lib.org/reference/number.html).)

You can use [`cut_si()`](https://scales.r-lib.org/reference/number.html) for SI labels:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>plot1</span> <span class='o'>+</span> 
  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/scale_continuous.html'>scale_x_log10</a></span><span class='o'>(</span>
    labels <span class='o'>=</span> <span class='nf'><a href='https://scales.r-lib.org/reference/label_number.html'>label_number</a></span><span class='o'>(</span>scale_cut <span class='o'>=</span> <span class='nf'><a href='https://scales.r-lib.org/reference/number.html'>cut_si</a></span><span class='o'>(</span><span class='s'>"g"</span><span class='o'>)</span><span class='o'>)</span>
  <span class='o'>)</span>
</code></pre>
<img src="figs/unnamed-chunk-5-1.png" width="700px" style="display: block; margin: auto;" />
<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>plot2</span> <span class='o'>+</span> 
  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/scale_continuous.html'>scale_x_continuous</a></span><span class='o'>(</span>
    labels <span class='o'>=</span> <span class='nf'><a href='https://scales.r-lib.org/reference/label_number.html'>label_number</a></span><span class='o'>(</span>scale_cut <span class='o'>=</span> <span class='nf'><a href='https://scales.r-lib.org/reference/number.html'>cut_si</a></span><span class='o'>(</span><span class='s'>"Hz"</span><span class='o'>)</span><span class='o'>)</span>
  <span class='o'>)</span>
</code></pre>
<img src="figs/unnamed-chunk-5-2.png" width="700px" style="display: block; margin: auto;" />

</div>

This replaces [`label_number_si()`](https://scales.r-lib.org/reference/label_number_si.html) because it incorrectly used the [short scale abbreviations](https://en.wikipedia.org/wiki/Long_and_short_scales) instead of the correct [SI prefixes](https://en.wikipedia.org/wiki/Metric_prefix).

## Log labels

Another way to label logs scales Thanks to [David C Hall](https://github.com/davidchall) you can now use `scales::labels_log()` to display

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>plot1</span> <span class='o'>+</span>
  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/scale_continuous.html'>scale_x_log10</a></span><span class='o'>(</span>
    labels <span class='o'>=</span> <span class='nf'>scales</span><span class='nf'>::</span><span class='nf'><a href='https://scales.r-lib.org/reference/label_log.html'>label_log</a></span><span class='o'>(</span><span class='o'>)</span>
  <span class='o'>)</span>
</code></pre>
<img src="figs/unnamed-chunk-6-1.png" width="700px" style="display: block; margin: auto;" />

</div>

You can use the `base` argument if you need a different base for the a logarithm:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>plot1</span> <span class='o'>+</span> 
  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/scale_continuous.html'>scale_x_continuous</a></span><span class='o'>(</span>
    trans <span class='o'>=</span> <span class='nf'>scales</span><span class='nf'>::</span><span class='nf'><a href='https://scales.r-lib.org/reference/log_trans.html'>log_trans</a></span><span class='o'>(</span><span class='m'>2</span><span class='o'>)</span>, 
    labels <span class='o'>=</span> <span class='nf'>scales</span><span class='nf'>::</span><span class='nf'><a href='https://scales.r-lib.org/reference/label_log.html'>label_log</a></span><span class='o'>(</span><span class='m'>2</span><span class='o'>)</span>
  <span class='o'>)</span>
</code></pre>
<img src="figs/unnamed-chunk-7-1.png" width="700px" style="display: block; margin: auto;" />

</div>

## Currency

Finally, [`label_dollar()`](https://scales.r-lib.org/reference/label_dollar.html) recieves a couple of small improvements. The the `prefix` is now placed before negative sign, rather than before it, yielding (e.g) the correct `-$1` instead of `$-1`:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>df3</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/data.frame.html'>data.frame</a></span><span class='o'>(</span>
  date <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/as.Date.html'>as.Date</a></span><span class='o'>(</span><span class='s'>"2022-01-01"</span><span class='o'>)</span> <span class='o'>+</span> <span class='m'>1</span><span class='o'>:</span><span class='m'>1e3</span>,
  balance <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/cumsum.html'>cumsum</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/stats/Uniform.html'>runif</a></span><span class='o'>(</span><span class='m'>1e3</span>, <span class='o'>-</span><span class='m'>1e3</span>, <span class='m'>1e3</span><span class='o'>)</span><span class='o'>)</span>
<span class='o'>)</span>

<span class='nv'>plot3</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggplot.html'>ggplot</a></span><span class='o'>(</span><span class='nv'>df3</span>, <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/aes.html'>aes</a></span><span class='o'>(</span><span class='nv'>date</span>, <span class='nv'>balance</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>+</span> 
  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/geom_path.html'>geom_line</a></span><span class='o'>(</span><span class='o'>)</span> <span class='o'>+</span>
  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/labs.html'>labs</a></span><span class='o'>(</span>x <span class='o'>=</span> <span class='kc'>NULL</span>, y <span class='o'>=</span> <span class='kc'>NULL</span><span class='o'>)</span>
<span class='nv'>plot3</span>
</code></pre>
<img src="figs/unnamed-chunk-8-1.png" width="700px" style="display: block; margin: auto;" />

</div>

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>plot3</span> <span class='o'>+</span> 
  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/scale_continuous.html'>scale_y_continuous</a></span><span class='o'>(</span>
    labels <span class='o'>=</span> <span class='nf'><a href='https://scales.r-lib.org/reference/label_dollar.html'>label_dollar</a></span><span class='o'>(</span>scale_cut <span class='o'>=</span> <span class='nf'><a href='https://scales.r-lib.org/reference/number.html'>cut_short_scale</a></span><span class='o'>(</span><span class='o'>)</span><span class='o'>)</span>
  <span class='o'>)</span>
</code></pre>
<img src="figs/unnamed-chunk-9-1.png" width="700px" style="display: block; margin: auto;" />

</div>

It also longer uses its own `negative_parens` argument but instead inherits the new `style_negative` argument from [`label_number()`](https://scales.r-lib.org/reference/label_number.html):

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>plot3</span> <span class='o'>+</span> 
  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/scale_continuous.html'>scale_y_continuous</a></span><span class='o'>(</span>
    labels <span class='o'>=</span> <span class='nf'><a href='https://scales.r-lib.org/reference/label_dollar.html'>label_dollar</a></span><span class='o'>(</span>
      scale_cut <span class='o'>=</span> <span class='nf'><a href='https://scales.r-lib.org/reference/number.html'>cut_short_scale</a></span><span class='o'>(</span><span class='o'>)</span>, 
      style_negative <span class='o'>=</span> <span class='s'>"parens"</span>
    <span class='o'>)</span>
  <span class='o'>)</span>
</code></pre>
<img src="figs/unnamed-chunk-10-1.png" width="700px" style="display: block; margin: auto;" />

</div>

## Acknowledgements

A big thanks goes to [David C Hall](https://github.com/davidchall), who contributed to the majority of new features in this version. 40 others contributed by asking questions, identifying bugs, and suggesting patches: [@aalucaci](https://github.com/aalucaci), [@adamkemberling](https://github.com/adamkemberling), [@akonkel-aek](https://github.com/akonkel-aek), [@billdenney](https://github.com/billdenney), [@brunocarlin](https://github.com/brunocarlin), [@campbead](https://github.com/campbead), [@cawthm](https://github.com/cawthm), [@DanChaltiel](https://github.com/DanChaltiel), [@davidhodge931](https://github.com/davidhodge931), [@davidski](https://github.com/davidski), [@dkahle](https://github.com/dkahle), [@donboyd5](https://github.com/donboyd5), [@dpseidel](https://github.com/dpseidel), [@ds-jim](https://github.com/ds-jim), [@EBukin](https://github.com/EBukin), [@elong0527](https://github.com/elong0527), [@eutwt](https://github.com/eutwt), [@ewenme](https://github.com/ewenme), [@fontikar](https://github.com/fontikar), [@frederikziebell](https://github.com/frederikziebell), [@hadley](https://github.com/hadley), [@IndrajeetPatil](https://github.com/IndrajeetPatil), [@jennybc](https://github.com/jennybc), [@karawoo](https://github.com/karawoo), [@mfherman](https://github.com/mfherman), [@mikmart](https://github.com/mikmart), [@mine-cetinkaya-rundel](https://github.com/mine-cetinkaya-rundel), [@mjskay](https://github.com/mjskay), [@nicolaspayette](https://github.com/nicolaspayette), [@NunoSempere](https://github.com/NunoSempere), [@SimonDedman](https://github.com/SimonDedman), [@sjackman](https://github.com/sjackman), [@stragu](https://github.com/stragu), [@teunbrand](https://github.com/teunbrand), [@thomasp85](https://github.com/thomasp85), [@TonyLadson](https://github.com/TonyLadson), [@tuoheyd](https://github.com/tuoheyd), [@vinhtantran](https://github.com/vinhtantran), [@vsocrates](https://github.com/vsocrates), and [@yutannihilation](https://github.com/yutannihilation).

