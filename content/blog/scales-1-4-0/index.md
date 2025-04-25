---
output: hugodown::hugo_document

slug: scales-1-4-0
title: scales 1.4.0
date: 2025-04-23
author: Teun van den Brand
description: >
    The new 1.4.0 release of the scales package adds some colourful updates.
    Read about colour manipulation, palettes and new label functions.

photo:
  url: https://unsplash.com/photos/a-close-up-of-a-person-holding-a-paintbrush-Xrelr7cTYm4
  author: Jennie Razumnaya

# one of: "deep-dive", "learn", "package", "programming", "roundup", or "other"
categories: [package] 
tags: [scales]
rmd_hash: fcb4e0463345d0c6

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

We're stoked to announce the release of [scales](https://scales.r-lib.org/) 1.4.0. scales is a package that provides much of the scaling logic that is used in ggplot2 to a general framework, along with utility functions for e.g. formatting labels or creating colour palettes.

You can install it from CRAN with:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://rdrr.io/r/utils/install.packages.html'>install.packages</a></span><span class='o'>(</span><span class='s'>"scales"</span><span class='o'>)</span></span></code></pre>

</div>

This blog post will give an overview of the 1.4.0 release, which has some nifty upgrades for working with colours and labels.

You can see a full list of changes in the [release notes](https://scales.r-lib.org/news/index.html)

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://scales.r-lib.org'>scales</a></span><span class='o'>)</span></span></code></pre>

</div>

## Colour manipulation

The [`alpha()`](https://scales.r-lib.org/reference/alpha.html) and [`muted()`](https://scales.r-lib.org/reference/muted.html) functions have been part of scales for a long time. Back in the 1.1.0 release we swapped to [farver](https://farver.data-imaginist.com/) to power these functions. We felt it was appropriate to use this package for other common colour tasks, and so [`col_shift()`](https://scales.r-lib.org/reference/colour_manip.html), [`col_lighter()`](https://scales.r-lib.org/reference/colour_manip.html), [`col_darker()`](https://scales.r-lib.org/reference/colour_manip.html), [`col_saturate()`](https://scales.r-lib.org/reference/colour_manip.html) and [`col_mix()`](https://scales.r-lib.org/reference/col_mix.html) were born.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>my_colours</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"red"</span>, <span class='s'>"green"</span>, <span class='s'>"blue"</span><span class='o'>)</span></span>
<span></span>
<span><span class='nv'>m</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/cbind.html'>rbind</a></span><span class='o'>(</span></span>
<span>  original <span class='o'>=</span> <span class='nv'>my_colours</span>,</span>
<span>  shift    <span class='o'>=</span> <span class='nf'><a href='https://scales.r-lib.org/reference/colour_manip.html'>col_shift</a></span><span class='o'>(</span><span class='nv'>my_colours</span>, <span class='m'>90</span><span class='o'>)</span>,</span>
<span>  lighter  <span class='o'>=</span> <span class='nf'><a href='https://scales.r-lib.org/reference/colour_manip.html'>col_lighter</a></span><span class='o'>(</span><span class='nv'>my_colours</span>, <span class='m'>20</span><span class='o'>)</span>,</span>
<span>  darker   <span class='o'>=</span> <span class='nf'><a href='https://scales.r-lib.org/reference/colour_manip.html'>col_darker</a></span><span class='o'>(</span><span class='nv'>my_colours</span>, <span class='m'>20</span><span class='o'>)</span>,</span>
<span>  duller   <span class='o'>=</span> <span class='nf'><a href='https://scales.r-lib.org/reference/colour_manip.html'>col_saturate</a></span><span class='o'>(</span><span class='nv'>my_colours</span>, <span class='o'>-</span><span class='m'>50</span><span class='o'>)</span>,</span>
<span>  mixed    <span class='o'>=</span> <span class='nf'><a href='https://scales.r-lib.org/reference/col_mix.html'>col_mix</a></span><span class='o'>(</span><span class='nv'>my_colours</span>, <span class='s'>"orchid"</span><span class='o'>)</span></span>
<span><span class='o'>)</span></span>
<span></span>
<span><span class='nf'><a href='https://scales.r-lib.org/reference/show_col.html'>show_col</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/t.html'>t</a></span><span class='o'>(</span><span class='nv'>m</span><span class='o'>)</span>, ncol <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/nrow.html'>ncol</a></span><span class='o'>(</span><span class='nv'>m</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='nf'><a href='https://rdrr.io/r/graphics/text.html'>text</a></span><span class='o'>(</span>x <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/nrow.html'>ncol</a></span><span class='o'>(</span><span class='nv'>m</span><span class='o'>)</span> <span class='o'>+</span> <span class='m'>0.25</span>, y <span class='o'>=</span> <span class='o'>-</span><span class='o'>(</span><span class='m'>1</span><span class='o'>:</span><span class='nf'><a href='https://rdrr.io/r/base/nrow.html'>nrow</a></span><span class='o'>(</span><span class='nv'>m</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>+</span> <span class='m'>0.5</span>, <span class='nf'><a href='https://rdrr.io/r/base/colnames.html'>rownames</a></span><span class='o'>(</span><span class='nv'>m</span><span class='o'>)</span>, adj <span class='o'>=</span> <span class='m'>0</span><span class='o'>)</span></span>
</code></pre>
<img src="figs/unnamed-chunk-2-1.png" width="700px" style="display: block; margin: auto;" />

</div>

## Palettes

Palettes have also been reworked in this release to include some useful properties. Palettes now come in one of two classes: 'pal_discrete' or 'pal_continuous'.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>my_palette</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://scales.r-lib.org/reference/pal_manual.html'>manual_pal</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"palegreen"</span>, <span class='s'>"deepskyblue"</span>, <span class='s'>"magenta"</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='nf'><a href='https://rdrr.io/r/base/class.html'>class</a></span><span class='o'>(</span><span class='nv'>my_palette</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; [1] "pal_discrete" "scales_pal"   "function"</span></span>
<span></span></code></pre>

</div>

Having palettes as a class rather than as plain functions, allows us to store useful metadata about the palette which can be used downstream. In addition, most colour palette functions also allow the aforementioned colour manipulation functions to work on the palette output.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://scales.r-lib.org/reference/new_continuous_palette.html'>palette_type</a></span><span class='o'>(</span><span class='nv'>my_palette</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; [1] "colour"</span></span>
<span></span><span></span>
<span><span class='nf'><a href='https://scales.r-lib.org/reference/new_continuous_palette.html'>palette_nlevels</a></span><span class='o'>(</span><span class='nv'>my_palette</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; [1] 3</span></span>
<span></span><span></span>
<span><span class='nf'><a href='https://scales.r-lib.org/reference/colour_manip.html'>col_shift</a></span><span class='o'>(</span><span class='nv'>my_palette</span>, <span class='m'>180</span><span class='o'>)</span><span class='o'>(</span><span class='m'>3</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; [1] "#FFC3FF" "#E4A735" "#00B100"</span></span>
<span></span></code></pre>

</div>

With the new setup it is now possible to expand discrete palettes to continuous palettes with [`as_continuous_pal()`](https://scales.r-lib.org/reference/new_continuous_palette.html) or vise versa to chop up continuous palettes into discrete palettes with [`as_discrete_pal()`](https://scales.r-lib.org/reference/new_continuous_palette.html).

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://rdrr.io/r/graphics/plot.default.html'>plot</a></span><span class='o'>(</span><span class='nf'><a href='https://scales.r-lib.org/reference/new_continuous_palette.html'>as_continuous_pal</a></span><span class='o'>(</span><span class='nv'>my_palette</span><span class='o'>)</span><span class='o'>)</span></span>
</code></pre>
<img src="figs/unnamed-chunk-5-1.png" width="700px" style="display: block; margin: auto;" />

</div>

Another quality of life improvement for palettes, is that the 'scales' package now keeps track of some named palettes. By default, the collection of 'known' palettes is pre-populated with colour palettes from the grDevices, RColorBrewer and viridisLite packages.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://scales.r-lib.org/reference/new_continuous_palette.html'>as_discrete_pal</a></span><span class='o'>(</span><span class='s'>"Okabe-Ito"</span><span class='o'>)</span><span class='o'>(</span><span class='m'>8</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; [1] "#000000" "#E69F00" "#56B4E9" "#009E73" "#F0E442" "#0072B2" "#D55E00"</span></span>
<span><span class='c'>#&gt; [8] "#CC79A7"</span></span>
<span></span></code></pre>

</div>

### Providing palettes as package

For those that are interested in developing R packages with palettes, there are a few recommendations we make in `?palette-recommendations` to smoothly interface with the scales package.

If your palettes are vectors of colour values, we recommend simply exporting the naked vector.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='c'>#' @export</span></span>
<span><span class='nv'>aurora</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"palegreen"</span>, <span class='s'>"deepskyblue"</span>, <span class='s'>"magenta"</span><span class='o'>)</span></span></code></pre>

</div>

That way, they can easily be accessed and used in [`as_discrete_pal()`](https://scales.r-lib.org/reference/new_continuous_palette.html) and [`as_continuous_pal()`](https://scales.r-lib.org/reference/new_continuous_palette.html).

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://scales.r-lib.org/reference/new_continuous_palette.html'>as_continuous_pal</a></span><span class='o'>(</span><span class='nv'>aurora</span><span class='o'>)</span></span>
<span><span class='nf'><a href='https://scales.r-lib.org/reference/new_continuous_palette.html'>as_discrete_pal</a></span><span class='o'>(</span><span class='nv'>aurora</span><span class='o'>)</span></span></code></pre>

</div>

Alternatively, if you have functions that generate colours that is not predefined, we recommend wrapping the function in [`new_discrete_palette()`](https://scales.r-lib.org/reference/new_continuous_palette.html) and [`new_continuous_palette()`](https://scales.r-lib.org/reference/new_continuous_palette.html). For predefined palettes, you can also use [`pal_manual()`](https://scales.r-lib.org/reference/pal_manual.html) or [`pal_gradient_n()`](https://scales.r-lib.org/reference/pal_gradient_n.html).

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>pal_random</span> <span class='o'>&lt;-</span> <span class='kr'>function</span><span class='o'>(</span><span class='o'>)</span> <span class='o'>&#123;</span></span>
<span>  <span class='nv'>fun</span> <span class='o'>&lt;-</span> <span class='kr'>function</span><span class='o'>(</span><span class='nv'>n</span><span class='o'>)</span> <span class='o'>&#123;</span></span>
<span>    <span class='nf'><a href='https://rdrr.io/r/base/sample.html'>sample</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/grDevices/colors.html'>colours</a></span><span class='o'>(</span>distinct <span class='o'>=</span> <span class='kc'>TRUE</span><span class='o'>)</span>, size <span class='o'>=</span> <span class='nv'>n</span>, replace <span class='o'>=</span> <span class='kc'>TRUE</span><span class='o'>)</span></span>
<span>  <span class='o'>&#125;</span></span>
<span>  <span class='nf'><a href='https://scales.r-lib.org/reference/new_continuous_palette.html'>new_discrete_palette</a></span><span class='o'>(</span><span class='nv'>fun</span>, type <span class='o'>=</span> <span class='s'>"colour"</span>, nlevels <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/length.html'>length</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/grDevices/colors.html'>colours</a></span><span class='o'>(</span><span class='o'>)</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='o'>&#125;</span></span></code></pre>

</div>

Populating the metadata in [`new_discrete_palette()`](https://scales.r-lib.org/reference/new_continuous_palette.html)/[`new_continuous_palette()`](https://scales.r-lib.org/reference/new_continuous_palette.html) helps to make converting between palette types less painful.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://scales.r-lib.org/reference/new_continuous_palette.html'>as_continuous_pal</a></span><span class='o'>(</span><span class='nf'>pal_random</span><span class='o'>(</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='nf'><a href='https://scales.r-lib.org/reference/new_continuous_palette.html'>as_discrete_pal</a></span><span class='o'>(</span><span class='nf'>pal_random</span><span class='o'>(</span><span class='o'>)</span><span class='o'>)</span></span></code></pre>

</div>

## Labels

This release also provides improvements to labelling in the form of two new labelling functions and two new convenience functions for labels. In contrast to most of scales' label functions, these label functions are great for discrete input. First up is [`label_glue()`](https://scales.r-lib.org/reference/label_glue.html), which uses the string interpolation from the glue package to format your labels.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://scales.r-lib.org/reference/label_glue.html'>label_glue</a></span><span class='o'>(</span><span class='s'>"The &#123;x&#125; penguin"</span><span class='o'>)</span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"Gentoo"</span>, <span class='s'>"Chinstrap"</span>, <span class='s'>"Adelie"</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; The Gentoo penguin</span></span>
<span><span class='c'>#&gt; The Chinstrap penguin</span></span>
<span><span class='c'>#&gt; The Adelie penguin</span></span>
<span></span></code></pre>

</div>

The other labelling function, [`label_dictionary()`](https://scales.r-lib.org/reference/label_dictionary.html), is convenient when some variable you use consists of short-codes or abbreviations. You can provide [`label_dictionary()`](https://scales.r-lib.org/reference/label_dictionary.html) with a named vector that translates the values to prettier labels. If one or more of your values doesn't exist in the dictionary, they stay as-is by default.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>dict</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span></span>
<span>  diy <span class='o'>=</span> <span class='s'>"Do it yourself"</span>, eta <span class='o'>=</span> <span class='s'>"Estimated time of arrival"</span>,</span>
<span>  asap <span class='o'>=</span> <span class='s'>"As soon as possible"</span>, tldr <span class='o'>=</span> <span class='s'>"Too long; didn't read"</span></span>
<span><span class='o'>)</span></span>
<span><span class='nf'><a href='https://scales.r-lib.org/reference/label_dictionary.html'>label_dictionary</a></span><span class='o'>(</span><span class='nv'>dict</span><span class='o'>)</span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"diy"</span>, <span class='s'>"tldr"</span>, <span class='s'>"bff"</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; [1] "Do it yourself"        "Too long; didn't read" "bff"</span></span>
<span></span></code></pre>

</div>

[`compose_label()`](https://scales.r-lib.org/reference/compose_label.html) is a useful convenience function we've added which will help you to create custom labelling behaviour without needing to write a labelling function from scratch. Similar to [`compose_trans()`](https://scales.r-lib.org/reference/transform_compose.html), it allows you to chain together different labelling functions.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>screaming_flowers</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://scales.r-lib.org/reference/compose_label.html'>compose_label</a></span><span class='o'>(</span><span class='nf'><a href='https://scales.r-lib.org/reference/label_glue.html'>label_glue</a></span><span class='o'>(</span><span class='s'>"The &#123;x&#125; flower"</span><span class='o'>)</span>, <span class='nv'>toupper</span><span class='o'>)</span></span>
<span><span class='nf'>screaming_flowers</span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"daffodil"</span>, <span class='s'>"orchid"</span>, <span class='s'>"tulip"</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; THE DAFFODIL FLOWER</span></span>
<span><span class='c'>#&gt; THE ORCHID FLOWER</span></span>
<span><span class='c'>#&gt; THE TULIP FLOWER</span></span>
<span></span></code></pre>

</div>

Lastly, we haven't completely forgotton about numeric labels either. We have introduced the [`number_options()`](https://scales.r-lib.org/reference/number_options.html) functions to globally populate defaults for functions such as [`label_number()`](https://scales.r-lib.org/reference/label_number.html) and [`label_currency()`](https://scales.r-lib.org/reference/label_currency.html). This can be convenient if you produce statistical reports in non-English languages.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://scales.r-lib.org/reference/number_options.html'>number_options</a></span><span class='o'>(</span></span>
<span>  decimal.mark <span class='o'>=</span> <span class='s'>","</span>,</span>
<span>  big.mark <span class='o'>=</span> <span class='s'>"."</span>,</span>
<span>  style_negative <span class='o'>=</span> <span class='s'>"minus"</span>,</span>
<span>  currency.prefix <span class='o'>=</span> <span class='s'>""</span>,</span>
<span>  currency.suffix <span class='o'>=</span> <span class='s'>"€"</span>,</span>
<span>  currency.decimal.mark <span class='o'>=</span> <span class='s'>","</span>,</span>
<span>  currency.big.mark <span class='o'>=</span> <span class='s'>" "</span>,</span>
<span>  ordinal.rules <span class='o'>=</span> <span class='nf'><a href='https://scales.r-lib.org/reference/label_ordinal.html'>ordinal_french</a></span><span class='o'>(</span><span class='o'>)</span></span>
<span><span class='o'>)</span></span>
<span></span>
<span><span class='nf'><a href='https://scales.r-lib.org/reference/label_currency.html'>label_currency</a></span><span class='o'>(</span>accuracy <span class='o'>=</span> <span class='m'>0.01</span><span class='o'>)</span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='m'>0.1</span>, <span class='m'>10</span>, <span class='m'>1000000</span>, <span class='o'>-</span><span class='m'>1000</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; [1] "0,10€"         "10,00€"        "1 000 000,00€" "-1 000,00€"</span></span>
<span></span><span></span>
<span><span class='nf'><a href='https://scales.r-lib.org/reference/label_ordinal.html'>label_ordinal</a></span><span class='o'>(</span><span class='o'>)</span><span class='o'>(</span><span class='m'>1</span><span class='o'>:</span><span class='m'>4</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; [1] "1er" "2e"  "3e"  "4e"</span></span>
<span></span></code></pre>

</div>

## Acknowledgements

We'd like to thank all people who have contributed in some way, whether it was filing issues, participating in discussion or contributing to code and documentation:

[@Aariq](https://github.com/Aariq), [@Aehmlo](https://github.com/Aehmlo), [@Ali-Hudson](https://github.com/Ali-Hudson), [@cb12991](https://github.com/cb12991), [@colindouglas](https://github.com/colindouglas), [@d-morrison](https://github.com/d-morrison), [@davidhodge931](https://github.com/davidhodge931), [@EricMarcon](https://github.com/EricMarcon), [@kellijohnson-NOAA](https://github.com/kellijohnson-NOAA), [@kmcd39](https://github.com/kmcd39), [@lz1nwm](https://github.com/lz1nwm), [@mine-cetinkaya-rundel](https://github.com/mine-cetinkaya-rundel), [@mjskay](https://github.com/mjskay), [@Moohan](https://github.com/Moohan), [@muschellij2](https://github.com/muschellij2), [@ppreshant](https://github.com/ppreshant), [@rawktheuniversemon](https://github.com/rawktheuniversemon), [@rogiersbart](https://github.com/rogiersbart), [@SchmidtPaul](https://github.com/SchmidtPaul), [@teunbrand](https://github.com/teunbrand), and [@thomasp85](https://github.com/thomasp85).

