---
title: "Taking Control of Plot Scaling"
date: 2020-06-24
output: hugodown::hugo_document

description: > 
  Learn how to control scaling of the content in your plot when you render plots
  to different sizes.

# Authors. Comma separated list, e.g. `["Bob Smith", "David Jones"]`.
authors: ["Thomas Lin Pedersen"]

# Tags and categories
# For example, use `tags = []` for no tags, or the form `tags = ["A Tag", "Another Tag"]` for one or more tags.
tags: ["graphics", "ragg"]
categories: ["learn"]

# For wide photo caption
photo:
  url: https://unsplash.com/photos/6GjHwABuci4
  author: Mikael Kristenson
rmd_hash: ac9d9d863793ffe9

---

Some time ago, while working on the new edition of the ggplot2 book, I asked out to the R twitterverse what part of using ggplot2 was the most incomprehensible for seasoned users. By a very large margin the most "popular" response revolved around making sure that output had the correct scaling of text, lines, etc.

The latest release of ragg contains a new functionality that will hopefully make this issue a thing of the past. Read on how to use it.

The problem
-----------

The issue, if you are blissfully unaware, revolves around ensuring that dimensions in your graphic is tied to the resolution of the final plot. This means that it is quite difficult to increase the resolution of a plot while maintaining the same look of the plot. The issue is related to increasing the resolution of your screen, which, in olden days, resulted in almost comically small text and UI elements:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='c'># Let us create an example plot</span>
<span class='nf'><a href='https://rdrr.io/r/base/library.html'>library</a></span>(<span class='k'><a href='http://ggplot2.tidyverse.org'>ggplot2</a></span>)
<span class='nf'><a href='https://rdrr.io/r/base/library.html'>library</a></span>(<span class='k'><a href='https://ragg.r-lib.org'>ragg</a></span>)

<span class='k'>p</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggplot.html'>ggplot</a></span>(<span class='k'>mtcars</span>) <span class='o'>+</span> 
  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/geom_point.html'>geom_point</a></span>(<span class='nf'><a href='https://ggplot2.tidyverse.org/reference/aes.html'>aes</a></span>(<span class='k'>disp</span>, <span class='k'>mpg</span>)) <span class='o'>+</span> 
  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/geom_smooth.html'>geom_smooth</a></span>(<span class='nf'><a href='https://ggplot2.tidyverse.org/reference/aes.html'>aes</a></span>(<span class='k'>disp</span>, <span class='k'>mpg</span>))

<span class='k'>pngfile</span> <span class='o'>&lt;-</span> <span class='k'>fs</span>::<span class='nf'><a href='http://fs.r-lib.org/reference/path.html'>path</a></span>(<span class='k'>knitr</span>::<span class='nf'><a href='https://rdrr.io/pkg/knitr/man/fig_path.html'>fig_path</a></span>(),  <span class='s'>"low_res.png"</span>)

<span class='nf'><a href='https://ragg.r-lib.org/reference/agg_png.html'>agg_png</a></span>(<span class='k'>pngfile</span>, width = <span class='m'>15</span>, height = <span class='m'>9</span>, units = <span class='s'>"cm"</span>, res = <span class='m'>72</span>)
<span class='nf'><a href='https://rdrr.io/r/graphics/plot.default.html'>plot</a></span>(<span class='k'>p</span>)
<span class='nf'><a href='https://rdrr.io/r/base/invisible.html'>invisible</a></span>(<span class='nf'><a href='https://rdrr.io/r/grDevices/dev.html'>dev.off</a></span>())
<span class='k'>knitr</span>::<span class='nf'><a href='https://rdrr.io/pkg/knitr/man/include_graphics.html'>include_graphics</a></span>(<span class='k'>pngfile</span>)
</code></pre>
<img src="figs/unnamed-chunk-1-1/low_res.png" width="700px" style="display: block; margin: auto;" />

</div>

We may feel the the relative sizing in the plot is spot on here, but the resolution is horrible (after all 72 dpi is not something anyone wants to look at in this day and age). We can readily fix this by increasing the resolution:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='k'>pngfile</span> <span class='o'>&lt;-</span> <span class='k'>fs</span>::<span class='nf'><a href='http://fs.r-lib.org/reference/path.html'>path</a></span>(<span class='k'>knitr</span>::<span class='nf'><a href='https://rdrr.io/pkg/knitr/man/fig_path.html'>fig_path</a></span>(),  <span class='s'>"high_res.png"</span>)
<span class='nf'><a href='https://ragg.r-lib.org/reference/agg_png.html'>agg_png</a></span>(<span class='k'>pngfile</span>, width = <span class='m'>15</span>, height = <span class='m'>9</span>, units = <span class='s'>"cm"</span>, res = <span class='m'>300</span>)
<span class='nf'><a href='https://rdrr.io/r/graphics/plot.default.html'>plot</a></span>(<span class='k'>p</span>)
<span class='nf'><a href='https://rdrr.io/r/base/invisible.html'>invisible</a></span>(<span class='nf'><a href='https://rdrr.io/r/grDevices/dev.html'>dev.off</a></span>())
<span class='k'>knitr</span>::<span class='nf'><a href='https://rdrr.io/pkg/knitr/man/include_graphics.html'>include_graphics</a></span>(<span class='k'>pngfile</span>)
</code></pre>
<img src="figs/unnamed-chunk-2-1/high_res.png" width="700px" style="display: block; margin: auto;" />

</div>

So far, so good. Now, I want to create a poster with this plot. For the poster I'll need a larger size because it is meant to be read at a distance. For simplicity we'll make the plot twice as big in both dimensions

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='k'>pngfile</span> <span class='o'>&lt;-</span> <span class='k'>fs</span>::<span class='nf'><a href='http://fs.r-lib.org/reference/path.html'>path</a></span>(<span class='k'>knitr</span>::<span class='nf'><a href='https://rdrr.io/pkg/knitr/man/fig_path.html'>fig_path</a></span>(),  <span class='s'>"big_size.png"</span>)
<span class='nf'><a href='https://ragg.r-lib.org/reference/agg_png.html'>agg_png</a></span>(<span class='k'>pngfile</span>, width = <span class='m'>30</span>, height = <span class='m'>18</span>, units = <span class='s'>"cm"</span>, res = <span class='m'>300</span>)
<span class='nf'><a href='https://rdrr.io/r/graphics/plot.default.html'>plot</a></span>(<span class='k'>p</span>)
<span class='nf'><a href='https://rdrr.io/r/base/invisible.html'>invisible</a></span>(<span class='nf'><a href='https://rdrr.io/r/grDevices/dev.html'>dev.off</a></span>())
<span class='k'>knitr</span>::<span class='nf'><a href='https://rdrr.io/pkg/knitr/man/include_graphics.html'>include_graphics</a></span>(<span class='k'>pngfile</span>)
</code></pre>
<img src="figs/unnamed-chunk-3-1/big_size.png" width="700px" style="display: block; margin: auto;" />

</div>

The size of the plot has increased but the absolute size of text, lines, margins, etc. has stayed the same. The end result is that the relative size of these elements has decreased. This was not what we wanted.

A related issue is rendering a plot to a fixed pixel size. Here the `res` argument is rather arbitrary as it relates the physical size to the pixel dimensions, and we haven't provided a physical size at all:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='k'>pngfile</span> <span class='o'>&lt;-</span> <span class='k'>fs</span>::<span class='nf'><a href='http://fs.r-lib.org/reference/path.html'>path</a></span>(<span class='k'>knitr</span>::<span class='nf'><a href='https://rdrr.io/pkg/knitr/man/fig_path.html'>fig_path</a></span>(),  <span class='s'>"pixel_size.png"</span>)
<span class='nf'><a href='https://ragg.r-lib.org/reference/agg_png.html'>agg_png</a></span>(<span class='k'>pngfile</span>, width = <span class='m'>2000</span>, height = <span class='m'>1200</span>, units = <span class='s'>"px"</span>)
<span class='nf'><a href='https://rdrr.io/r/graphics/plot.default.html'>plot</a></span>(<span class='k'>p</span>)
<span class='nf'><a href='https://rdrr.io/r/base/invisible.html'>invisible</a></span>(<span class='nf'><a href='https://rdrr.io/r/grDevices/dev.html'>dev.off</a></span>())
<span class='k'>knitr</span>::<span class='nf'><a href='https://rdrr.io/pkg/knitr/man/include_graphics.html'>include_graphics</a></span>(<span class='k'>pngfile</span>)
</code></pre>
<img src="figs/unnamed-chunk-4-1/pixel_size.png" width="700px" style="display: block; margin: auto;" />

</div>

You can reclaim eligibility by increasing the `res` argument, but this is a quite non-obvious solution and one that requires a lot of trial and error.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='k'>pngfile</span> <span class='o'>&lt;-</span> <span class='k'>fs</span>::<span class='nf'><a href='http://fs.r-lib.org/reference/path.html'>path</a></span>(<span class='k'>knitr</span>::<span class='nf'><a href='https://rdrr.io/pkg/knitr/man/fig_path.html'>fig_path</a></span>(),  <span class='s'>"pixel_size_legible.png"</span>)
<span class='nf'><a href='https://ragg.r-lib.org/reference/agg_png.html'>agg_png</a></span>(<span class='k'>pngfile</span>, width = <span class='m'>2000</span>, height = <span class='m'>1200</span>, units = <span class='s'>"px"</span>, res = <span class='m'>600</span>)
<span class='nf'><a href='https://rdrr.io/r/graphics/plot.default.html'>plot</a></span>(<span class='k'>p</span>)
<span class='nf'><a href='https://rdrr.io/r/base/invisible.html'>invisible</a></span>(<span class='nf'><a href='https://rdrr.io/r/grDevices/dev.html'>dev.off</a></span>())
<span class='k'>knitr</span>::<span class='nf'><a href='https://rdrr.io/pkg/knitr/man/include_graphics.html'>include_graphics</a></span>(<span class='k'>pngfile</span>)
</code></pre>
<img src="figs/unnamed-chunk-5-1/pixel_size_legible.png" width="700px" style="display: block; margin: auto;" />

</div>

The solution
------------

I came into this issue, thinking that it was simply a matter of educating users on how the different arguments interact, but I had to quickly reevaluate that stance. Basically, there is no solution that works across all the different ways of specifying image dimensions. Specifically, when the outputs needs to be a specific absolute size and resolution, the only resolution is to change theming of the plot object so text, size, margins, etc are increased.

Because of this I've added a new argument to all devices in ragg that lets you control the scaling of the output. It is interpreted as a multiplier that is applied to all absolute sizing in the plot, without affecting the encoded resolution of the plot. Let us use it to get the desired plot for our poster. We doubled each dimension for the poster version, so we need to set `scaling = 2` to maintain the look of the plot:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='k'>pngfile</span> <span class='o'>&lt;-</span> <span class='k'>fs</span>::<span class='nf'><a href='http://fs.r-lib.org/reference/path.html'>path</a></span>(<span class='k'>knitr</span>::<span class='nf'><a href='https://rdrr.io/pkg/knitr/man/fig_path.html'>fig_path</a></span>(),  <span class='s'>"big_size_correct.png"</span>)
<span class='nf'><a href='https://ragg.r-lib.org/reference/agg_png.html'>agg_png</a></span>(<span class='k'>pngfile</span>, width = <span class='m'>30</span>, height = <span class='m'>18</span>, units = <span class='s'>"cm"</span>, res = <span class='m'>300</span>, scaling = <span class='m'>2</span>)
<span class='nf'><a href='https://rdrr.io/r/graphics/plot.default.html'>plot</a></span>(<span class='k'>p</span>)
<span class='nf'><a href='https://rdrr.io/r/base/invisible.html'>invisible</a></span>(<span class='nf'><a href='https://rdrr.io/r/grDevices/dev.html'>dev.off</a></span>())
<span class='k'>knitr</span>::<span class='nf'><a href='https://rdrr.io/pkg/knitr/man/include_graphics.html'>include_graphics</a></span>(<span class='k'>pngfile</span>)
</code></pre>
<img src="figs/unnamed-chunk-6-1/big_size_correct.png" width="700px" style="display: block; margin: auto;" />

</div>

As can be seen, the new argument makes it very easy to reclaim the look of the plot after resizing. Hopefully this will remove a good deal of the pain related to generating plots for papers, posters, presentations, etc.

