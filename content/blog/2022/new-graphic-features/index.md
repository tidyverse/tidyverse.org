---
output: hugodown::hugo_document

slug: new-graphic-features
title: ragg, svglite, and the new graphics features
date: 2022-02-25
author: Thomas Lin Pedersen
description: >
    The graphics engine in R is continually improving, and the ragg and svglite graphic devices 
    follow along in supporting them. This blog post outlines what is now possible, and what
    might come in the future.

photo:
  url: https://versum.xyz/token/versum/15341
  author: Thomas Lin Pedersen

# one of: "deep-dive", "learn", "package", "programming", "roundup", or "other"
categories: [deep-dive] 
tags: [ragg, svglite, ggplot2, graphics]
rmd_hash: 53331b185ae8ccc7

---

<!--
TODO:
* [ ] Look over / edit the post's title in the yaml
* [ ] Edit (or delete) the description; note this appears in the Twitter card
* [ ] Pick category and tags (see existing with [`hugodown::tidy_show_meta()`](https://rdrr.io/pkg/hugodown/man/use_tidy_post.html))
* [ ] Find photo & update yaml metadata
* [ ] Create `thumbnail-sq.jpg`; height and width should be equal
* [ ] Create `thumbnail-wd.jpg`; width should be >5x height
* [ ] [`hugodown::use_tidy_thumbnails()`](https://rdrr.io/pkg/hugodown/man/use_tidy_post.html)
* [ ] Add intro sentence, e.g. the standard tagline for the package
* [ ] [`usethis::use_tidy_thanks()`](https://usethis.r-lib.org/reference/use_tidy_thanks.html)
-->

The release of [ragg 1.2](https://ragg.r-lib.org) and [svglite 2.1](https://svglite.r-lib.org) brought support for some exciting new graphics engine features, including gradients and patterns, which were [added in R 4.1](https://developer.r-project.org/Blog/public/2020/07/15/new-features-in-the-r-graphics-engine/) by Paul Murrell from R Core. This post will dive into these new features, as well as discuss what the future might hold for the R graphics engine.

If you want to follow along on your own computer, you can install the latest versions of ragg and svglite from CRAN

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://rdrr.io/r/utils/install.packages.html'>install.packages</a></span><span class='o'>(</span><span class='s'>"ragg"</span><span class='o'>)</span>
<span class='nf'><a href='https://rdrr.io/r/utils/install.packages.html'>install.packages</a></span><span class='o'>(</span><span class='s'>"svglite"</span><span class='o'>)</span></code></pre>

</div>

This post will rarely make any specific call-outs to ragg or svglite, as these are simply the packages that facilitate what is now possible with R graphics.

## What is the graphics engine?

You might wonder what is meant by the *R graphics engine*. It's pretty deep in the R graphics stack, so as a user, you are unlikely to ever engage with it directly. But, since I somehow caught your attention, we might as well indulge in the finer points of the graphics implementation.

While you may mainly be familiar with ggplot2 and perhaps a variety of graphics devices (e.g. [`pdf()`](https://rdrr.io/r/grDevices/pdf.html) or [`png()`](https://rdrr.io/r/grDevices/png.html)), they sit at opposite ends of a fairly elaborate graphics pipeline. ggplot2 is a high(er) level plotting package that allows you to express your data-visualization intent through a structured grammar. Graphics devices such as ragg and svglite are low-level packages that translate simple graphics instructions into a given file format. In between these two poles we have a two additional abstractions that helps translate between the extremes. In very broad terms, the R graphic stack looks like this:

![An overview of the different steps in the R graphics pipeline. A graphics package is build on top of a graphic system. All graphic systems calls into the same shared graphics engine which then relay graphic instructions to the active graphic device.](pipeline.png "graphics pipeline")

### Graphic systems

R currently sports two different systems, one colloquially known as *base* graphics (implemented in the graphics package), and one called *grid* graphics (implemented in the grid package). If you call [`plot()`](https://rdrr.io/r/graphics/plot.default.html) you are most likely to end up using the base graphics system, while grid is used as the basis for e.g. ggplot2. The two systems are largely silos, though effort has been made to allow users to embed base graphics into grid graphics. In RStudio we are mainly invested in the grid graphics system since it powers ggplot2, but by and large, this is all an implementation detail that the user shouldn't care too much about. There might come other graphic systems in the future, and other ways of drawing things on screen or to files also exist outside of the R graphics pipeline (e.g. rgl which allows you to create 3D graphics using an OpenGL/WebGL interface).

### The graphics engine

What unites base and grid graphics and sets them apart from e.g. rgl is that they both call into the same low-level C API provided by R, the **graphics engine**. The graphics engine is responsible for communicating with the graphics devices while also providing selected utility functionality common for both base and grid graphics. It is because of this abstraction that creating graphics in R is largely decoupled from how it is outputted, be it on screen, in a file, or directly to a printer.

While it sounds nice and neat when it is all laid out like this, the current structure and division has grown out over many years, and the boundaries between the graphic systems, the graphics engine, and the graphic devices are blurry. Still, the design is much more mature than what we see in other languages, and as graphics/data-viz developers in R we are pretty spoiled compared to our peers in other languages --- perhaps without really knowing it.

## A fragmented future

With the division of responsibility described above, there are many points in the pipeline that may impose limitations in functionality. The graphic system might not provide the higher-level API to use functionality in the graphics engine, or a graphic device might not provide support for instructions coming in from the graphics engine. While this has mainly been a hypothetical situation prior to R 4.1, it is now the new reality. The new features in the graphics engine were implemented along with high-level support in grid, and low-level support in the pdf device along with the cairo-based devices. This leaves base plot in the dark, and also excludes a range of built-in devices, including the default devices on Windows and macOS. At this point, where high-level support from e.g. ggplot2 is still not present, it might not be a big problem, as you will probably use these features quite deliberately and know their limitations in support. In the future, however, this could lead to surprises.

As users, this fragmentation is most apparent in the choice of graphic device. After all, you don't expect the graphic system to be capable of something outside of its API, simply because new features were announced for the graphics device. However, if a graphic device lacks support it will simply not use the new features, and you may end up surprised at what it renders.

When it comes to graphic systems, you can expect that grid will be the first (perhaps only) system that ends up supporting new features in the graphics engine. Part of the reason for that is that the grid API is more powerful in general, and, as new and more complex graphic powers are exposed, it can be easiest to make them fit into the most expressive API. This is definitely the case for the latest batch of new features, but I also expect it to be the case going forward. Just because a functionality is exposed in grid, doesn't mean that it can easily be handled in e.g. ggplot2. I'll address what the new features may mean for the future of ggplot2 at the end of the post.

For graphic *devices* the water is more muddled. Not all devices are under active development, and such devices are unlikely to add support for new features. Further, it may be that a graphics device writes to a format, or uses a library that does not support a new feature provided by the graphics engine. The bottom line is that we can expect an increased fragmentation of the graphics devices in R in terms of which will be up to spec with the latest graphics engine features. It appears that the cairo-based devices along with the pdf device from grDevices can be expected to stay current. On our end, we will do our best to make sure that our graphic-device packages (currently ragg and svglite) will stay on top of any new additions to the graphics engine.

## The new features

OK, so we've talked a lot about some new features without ever going into detail about what they are. If you've never felt constrained by the capabilities of the graphics in R, you may be forgiven for thinking that this is all a big fuss over nothing. You may be right, but new capabilities will often allow the ecosystem to evolve in new and unexpected ways to the benefit of all.

### Gradients

While gradients have been a part of R graphics for a while, they have always relied on some hack - most often cutting the line or polygon in smaller bits and coloring these with color sampled from a gradient. However, now gradients are supported at the device level, meaning that the pixel color is calculated based on a gradient function. This means that the gradient is pixel-perfect at any resolution, and if you are writing to vector format (e.g. svg), you can reduce the file size by not having to write the coordinates for a chopped-up polygon to support the gradient. For now, the functionality is limited to fills. So, if you want to draw a gradient line, you still have to cut it up into small segments.

Gradients can be created with the [`linearGradient()`](https://rdrr.io/r/grid/patterns.html) and [`radialGradient()`](https://rdrr.io/r/grid/patterns.html) which can be assigned to the fill of a grob:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'>grid</span><span class='o'>)</span>
<span class='nf'><a href='https://rdrr.io/r/grid/grid.circle.html'>grid.circle</a></span><span class='o'>(</span>
  gp <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/grid/gpar.html'>gpar</a></span><span class='o'>(</span>
    fill <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/grid/patterns.html'>linearGradient</a></span><span class='o'>(</span>
      <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"firebrick"</span>, <span class='s'>"steelblue"</span>, <span class='s'>"forestgreen"</span><span class='o'>)</span>,
      stops <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='m'>0</span>, <span class='m'>0.7</span>, <span class='m'>1</span><span class='o'>)</span>
    <span class='o'>)</span>,
    col <span class='o'>=</span> <span class='kc'>NA</span>
  <span class='o'>)</span>
<span class='o'>)</span>
</code></pre>
<img src="figs/unnamed-chunk-3-1.png" width="700px" style="display: block; margin: auto;" />

</div>

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://rdrr.io/r/grid/grid.circle.html'>grid.circle</a></span><span class='o'>(</span>
  gp <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/grid/gpar.html'>gpar</a></span><span class='o'>(</span>
    fill <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/grid/patterns.html'>radialGradient</a></span><span class='o'>(</span>
      <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"white"</span>, <span class='s'>"steelblue"</span><span class='o'>)</span>,
      cx1 <span class='o'>=</span> <span class='m'>0.8</span>,
      cy1 <span class='o'>=</span> <span class='m'>0.8</span>
    <span class='o'>)</span>,
    col <span class='o'>=</span> <span class='kc'>NA</span>
  <span class='o'>)</span>
<span class='o'>)</span>
</code></pre>
<img src="figs/unnamed-chunk-4-1.png" width="700px" style="display: block; margin: auto;" />

</div>

At the basic level, both of the constructors takes a vector of colors. Optionally, you can provide a vector of stops that define where along the span of the gradient each color is placed. Each gradient type also lets you specify where in the graphic the gradient runs between. For a linear gradient, you provide the x and y position of the start and end of the gradient. For a radial gradient, you provide the center and radius of the start and end circle. Lastly, you can also tell it how it should behave outside of the given range using the `extend` argument:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://rdrr.io/r/grid/grid.circle.html'>grid.circle</a></span><span class='o'>(</span>
  gp <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/grid/gpar.html'>gpar</a></span><span class='o'>(</span>
    fill <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/grid/patterns.html'>linearGradient</a></span><span class='o'>(</span>
      <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"firebrick"</span>, <span class='s'>"steelblue"</span><span class='o'>)</span>,
      x1 <span class='o'>=</span> <span class='m'>0</span>, y1 <span class='o'>=</span> <span class='m'>0</span>, x2 <span class='o'>=</span> <span class='m'>0.5</span>, y2 <span class='o'>=</span> <span class='m'>0</span>,
      extend <span class='o'>=</span> <span class='s'>"repeat"</span>
    <span class='o'>)</span>,
    col <span class='o'>=</span> <span class='kc'>NA</span>
  <span class='o'>)</span>
<span class='o'>)</span>
</code></pre>
<img src="figs/unnamed-chunk-5-1.png" width="700px" style="display: block; margin: auto;" />

</div>

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://rdrr.io/r/grid/grid.circle.html'>grid.circle</a></span><span class='o'>(</span>
  gp <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/grid/gpar.html'>gpar</a></span><span class='o'>(</span>
    fill <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/grid/patterns.html'>linearGradient</a></span><span class='o'>(</span>
      <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"firebrick"</span>, <span class='s'>"steelblue"</span><span class='o'>)</span>,
      x1 <span class='o'>=</span> <span class='m'>0</span>, y1 <span class='o'>=</span> <span class='m'>0</span>, x2 <span class='o'>=</span> <span class='m'>0.5</span>, y2 <span class='o'>=</span> <span class='m'>0</span>,
      extend <span class='o'>=</span> <span class='s'>"pad"</span>
    <span class='o'>)</span>,
    col <span class='o'>=</span> <span class='kc'>NA</span>
  <span class='o'>)</span>
<span class='o'>)</span>
</code></pre>
<img src="figs/unnamed-chunk-6-1.png" width="700px" style="display: block; margin: auto;" />

</div>

One thing to note is that the extent of the gradient is given relative to the bounding box of the grob being drawn. We could move the circle above around and the gradient would follow along with it.

### Patterns

Like gradients, patterns are a new type of fill made possible in grid through the new features in the graphic engine. Patterns are crazy powerful in that they can be *any* grob you can imagine. The grob itself can consist of other grobs and these grobs could have patterned fill as well (or gradient fills for that matter).

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>gradient_rec</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/grid/grid.rect.html'>rectGrob</a></span><span class='o'>(</span>
  width <span class='o'>=</span> <span class='m'>0.1</span>, 
  height <span class='o'>=</span> <span class='m'>0.1</span>, 
  gp <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/grid/gpar.html'>gpar</a></span><span class='o'>(</span>fill <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/grid/patterns.html'>linearGradient</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"firebrick"</span>, <span class='s'>"steelblue"</span><span class='o'>)</span><span class='o'>)</span><span class='o'>)</span>
<span class='o'>)</span>
<span class='nf'><a href='https://rdrr.io/r/grid/grid.draw.html'>grid.draw</a></span><span class='o'>(</span><span class='nv'>gradient_rec</span><span class='o'>)</span>
</code></pre>
<img src="figs/unnamed-chunk-7-1.png" width="700px" style="display: block; margin: auto;" />

</div>

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://rdrr.io/r/grid/grid.circle.html'>grid.circle</a></span><span class='o'>(</span>
  gp <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/grid/gpar.html'>gpar</a></span><span class='o'>(</span>fill <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/grid/patterns.html'>pattern</a></span><span class='o'>(</span><span class='nv'>gradient_rec</span>, width <span class='o'>=</span> <span class='m'>0.15</span>, height <span class='o'>=</span> <span class='m'>0.15</span>, extend <span class='o'>=</span> <span class='s'>"reflect"</span><span class='o'>)</span><span class='o'>)</span>
<span class='o'>)</span>
</code></pre>
<img src="figs/unnamed-chunk-8-1.png" width="700px" style="display: block; margin: auto;" />

</div>

Understanding the sizing of the grob used for the pattern can take some getting used to. Basically, the pattern is drawn relative to the grob. The `width` and `height` arguments in the [`pattern()`](https://rdrr.io/r/grid/patterns.html) call is then used to define a region of the grob that will be used as a pattern. Thus, you cannot scale the pattern grob using the `width` and `height` arguments in [`pattern()`](https://rdrr.io/r/grid/patterns.html). This can be seen below

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://rdrr.io/r/grid/grid.circle.html'>grid.circle</a></span><span class='o'>(</span>
  gp <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/grid/gpar.html'>gpar</a></span><span class='o'>(</span>fill <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/grid/patterns.html'>pattern</a></span><span class='o'>(</span><span class='nv'>gradient_rec</span>, width <span class='o'>=</span> <span class='m'>0.35</span>, height <span class='o'>=</span> <span class='m'>0.35</span>, extend <span class='o'>=</span> <span class='s'>"reflect"</span><span class='o'>)</span><span class='o'>)</span>
<span class='o'>)</span>
</code></pre>
<img src="figs/unnamed-chunk-9-1.png" width="700px" style="display: block; margin: auto;" />

</div>

As we see, we are just defining a larger (empty) region from our rect grob, effectively adding more space between each rectangle, rather than creating larger rectangles. This also means that the pattern scales with the grob:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>pat</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/grid/patterns.html'>pattern</a></span><span class='o'>(</span>
  <span class='nv'>gradient_rec</span>, 
  width <span class='o'>=</span> <span class='m'>0.15</span>, 
  height <span class='o'>=</span> <span class='m'>0.15</span>, 
  extend <span class='o'>=</span> <span class='s'>"reflect"</span>
<span class='o'>)</span>
<span class='nf'><a href='https://rdrr.io/r/grid/grid.circle.html'>grid.circle</a></span><span class='o'>(</span>
  x <span class='o'>=</span> <span class='m'>0.25</span>, r <span class='o'>=</span> <span class='m'>0.25</span>,
  gp <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/grid/gpar.html'>gpar</a></span><span class='o'>(</span>fill <span class='o'>=</span> <span class='nv'>pat</span><span class='o'>)</span>
<span class='o'>)</span>
<span class='nf'><a href='https://rdrr.io/r/grid/grid.circle.html'>grid.circle</a></span><span class='o'>(</span>
  x <span class='o'>=</span> <span class='m'>0.75</span>, r <span class='o'>=</span> <span class='m'>0.5</span>,
  gp <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/grid/gpar.html'>gpar</a></span><span class='o'>(</span>fill <span class='o'>=</span> <span class='nv'>pat</span><span class='o'>)</span>
<span class='o'>)</span>
</code></pre>
<img src="figs/unnamed-chunk-10-1.png" width="700px" style="display: block; margin: auto;" />

</div>

In order to ensure the same scale of pattern is used across separate grobs, be sure to use absolute units when defining the pattern grob as well as the region:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>gradient_rec</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/grid/grid.rect.html'>rectGrob</a></span><span class='o'>(</span>
  width <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/grid/unit.html'>unit</a></span><span class='o'>(</span><span class='m'>1</span>, <span class='s'>"cm"</span><span class='o'>)</span>, 
  height <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/grid/unit.html'>unit</a></span><span class='o'>(</span><span class='m'>1</span>, <span class='s'>"cm"</span><span class='o'>)</span>, 
  gp <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/grid/gpar.html'>gpar</a></span><span class='o'>(</span>fill <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/grid/patterns.html'>linearGradient</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"firebrick"</span>, <span class='s'>"steelblue"</span><span class='o'>)</span><span class='o'>)</span><span class='o'>)</span>
<span class='o'>)</span>
<span class='nv'>pat</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/grid/patterns.html'>pattern</a></span><span class='o'>(</span>
  <span class='nv'>gradient_rec</span>, 
  width <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/grid/unit.html'>unit</a></span><span class='o'>(</span><span class='m'>1.5</span>, <span class='s'>"cm"</span><span class='o'>)</span>, 
  height <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/grid/unit.html'>unit</a></span><span class='o'>(</span><span class='m'>1.5</span>, <span class='s'>"cm"</span><span class='o'>)</span>, 
  extend <span class='o'>=</span> <span class='s'>"reflect"</span>
<span class='o'>)</span>
<span class='nf'><a href='https://rdrr.io/r/grid/grid.circle.html'>grid.circle</a></span><span class='o'>(</span>
  x <span class='o'>=</span> <span class='m'>0.25</span>, r <span class='o'>=</span> <span class='m'>0.25</span>,
  gp <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/grid/gpar.html'>gpar</a></span><span class='o'>(</span>fill <span class='o'>=</span> <span class='nv'>pat</span><span class='o'>)</span>
<span class='o'>)</span>
<span class='nf'><a href='https://rdrr.io/r/grid/grid.circle.html'>grid.circle</a></span><span class='o'>(</span>
  x <span class='o'>=</span> <span class='m'>0.75</span>, r <span class='o'>=</span> <span class='m'>0.5</span>,
  gp <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/grid/gpar.html'>gpar</a></span><span class='o'>(</span>fill <span class='o'>=</span> <span class='nv'>pat</span><span class='o'>)</span>
<span class='o'>)</span>
</code></pre>
<img src="figs/unnamed-chunk-11-1.png" width="700px" style="display: block; margin: auto;" />

</div>

As you can see, patterns can take some getting used to, but this is mainly because the API covers such a large span of functionality in terms of sizing, etc.

### Arbitrary clipping paths

Clipping is an integral part of graphics. You set up a region in your canvas and only this region will get drawn to. Up until now, the graphics engine has supported clipping, but only of rectangular, axis-aligned regions. Now, however, any grob can be used to define a clipping region. This is done at the viewport level, where the `clip` argument now can take a grob in addition to the standard `"on"`/`"off"` values.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>clip_path</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/grid/grid.text.html'>textGrob</a></span><span class='o'>(</span><span class='s'>"Clipping"</span>, gp <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/grid/gpar.html'>gpar</a></span><span class='o'>(</span>fontface <span class='o'>=</span> <span class='s'>"bold"</span>, fontsize <span class='o'>=</span> <span class='m'>100</span><span class='o'>)</span><span class='o'>)</span>
<span class='nf'><a href='https://rdrr.io/r/grid/grid.points.html'>grid.points</a></span><span class='o'>(</span>
  x <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/stats/Uniform.html'>runif</a></span><span class='o'>(</span><span class='m'>5000</span><span class='o'>)</span>, 
  y <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/stats/Uniform.html'>runif</a></span><span class='o'>(</span><span class='m'>5000</span><span class='o'>)</span>, 
  default.units <span class='o'>=</span> <span class='s'>'npc'</span>,
  vp <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/grid/viewport.html'>viewport</a></span><span class='o'>(</span>clip <span class='o'>=</span> <span class='nv'>clip_path</span><span class='o'>)</span>
<span class='o'>)</span>
</code></pre>
<img src="figs/unnamed-chunk-12-1.png" width="700px" style="display: block; margin: auto;" />

</div>

Clipping is not only possible with single grobs. By combining grobs in a gList, you can making the clipping region arbitrarily complex:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>circle</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/grid/grid.circle.html'>circleGrob</a></span><span class='o'>(</span>x <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='m'>0.2</span>, <span class='m'>0.8</span><span class='o'>)</span>, r <span class='o'>=</span> <span class='m'>0.3</span><span class='o'>)</span>
<span class='nv'>rect</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/grid/grid.rect.html'>rectGrob</a></span><span class='o'>(</span>
  width <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/grid/unit.html'>unit</a></span><span class='o'>(</span><span class='m'>0.7</span>, <span class='s'>'snpc'</span><span class='o'>)</span>, 
  height <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/grid/unit.html'>unit</a></span><span class='o'>(</span><span class='m'>0.7</span>, <span class='s'>'snpc'</span><span class='o'>)</span>, 
  vp <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/grid/viewport.html'>viewport</a></span><span class='o'>(</span>angle <span class='o'>=</span> <span class='m'>45</span><span class='o'>)</span>
<span class='o'>)</span>
<span class='nv'>clip_path</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/grid/grid.grob.html'>gTree</a></span><span class='o'>(</span>children <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/grid/grid.grob.html'>gList</a></span><span class='o'>(</span><span class='nv'>circle</span>, <span class='nv'>rect</span><span class='o'>)</span><span class='o'>)</span>
<span class='nf'><a href='https://rdrr.io/r/grid/grid.points.html'>grid.points</a></span><span class='o'>(</span>
  x <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/stats/Uniform.html'>runif</a></span><span class='o'>(</span><span class='m'>5000</span><span class='o'>)</span>, 
  y <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/stats/Uniform.html'>runif</a></span><span class='o'>(</span><span class='m'>5000</span><span class='o'>)</span>, 
  default.units <span class='o'>=</span> <span class='s'>'npc'</span>,
  vp <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/grid/viewport.html'>viewport</a></span><span class='o'>(</span>clip <span class='o'>=</span> <span class='nv'>clip_path</span><span class='o'>)</span>
<span class='o'>)</span>
</code></pre>
<img src="figs/unnamed-chunk-13-1.png" width="700px" style="display: block; margin: auto;" />

</div>

The examples above seems quite contrived and decoupled from data visualization, but there are of course real world usages, e.g. clipping a 2D density estimate to the shape of a country or clipping data points inside a circular canvas for polar plots.

The user interface for clipping paths is easy enough to understand, but it should be noted that there may be slight differences between devices as to which grob types can be used. Most notably, the use of text grobs for defining clipping paths is not something that will work for every device (but does work in ragg).

### Alpha masks

The last feature added to the graphics engine in this round is the ability of viewports to have an alpha mask assigned. When a mask is present, the grobs being drawn will apply the opacity of the mask. Note that this is different than a luminosity mask, which uses the lightness of the mask as the alpha value. A mask can be any grob you want, or a collection of multiples:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>circle</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/grid/grid.circle.html'>circleGrob</a></span><span class='o'>(</span>
  x <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='m'>0.2</span>, <span class='m'>0.8</span><span class='o'>)</span>, 
  r <span class='o'>=</span> <span class='m'>0.3</span>
<span class='o'>)</span>
<span class='nv'>rect</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/grid/grid.rect.html'>rectGrob</a></span><span class='o'>(</span>
  width <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/grid/unit.html'>unit</a></span><span class='o'>(</span><span class='m'>0.7</span>, <span class='s'>'snpc'</span><span class='o'>)</span>, 
  height <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/grid/unit.html'>unit</a></span><span class='o'>(</span><span class='m'>0.7</span>, <span class='s'>'snpc'</span><span class='o'>)</span>, 
  vp <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/grid/viewport.html'>viewport</a></span><span class='o'>(</span>angle <span class='o'>=</span> <span class='m'>45</span><span class='o'>)</span>
<span class='o'>)</span>
<span class='nv'>mask</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/grid/grid.grob.html'>gTree</a></span><span class='o'>(</span>children <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/grid/grid.grob.html'>gList</a></span><span class='o'>(</span><span class='nv'>circle</span>, <span class='nv'>rect</span><span class='o'>)</span>, gp <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/grid/gpar.html'>gpar</a></span><span class='o'>(</span>fill <span class='o'>=</span> <span class='s'>"#00000066"</span>, col <span class='o'>=</span> <span class='kc'>NA</span><span class='o'>)</span><span class='o'>)</span>
<span class='nf'><a href='https://rdrr.io/r/grid/grid.rect.html'>grid.rect</a></span><span class='o'>(</span>
  x <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='m'>0.25</span>, <span class='m'>0.25</span>, <span class='m'>0.75</span>, <span class='m'>0.75</span><span class='o'>)</span>, 
  y <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='m'>0.25</span>, <span class='m'>0.75</span>, <span class='m'>0.75</span>, <span class='m'>0.25</span><span class='o'>)</span>, 
  width <span class='o'>=</span> <span class='m'>0.5</span>,
  height <span class='o'>=</span> <span class='m'>0.5</span>,
  gp <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/grid/gpar.html'>gpar</a></span><span class='o'>(</span>fill <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"steelblue"</span>, <span class='s'>"firebrick"</span><span class='o'>)</span><span class='o'>)</span>,
  vp <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/grid/viewport.html'>viewport</a></span><span class='o'>(</span>mask <span class='o'>=</span> <span class='nv'>mask</span><span class='o'>)</span>
<span class='o'>)</span>
</code></pre>
<img src="figs/unnamed-chunk-14-1.png" width="700px" style="display: block; margin: auto;" />

</div>

As we see above, the areas in the mask where nothing is drawn have an opacity of 0, meaning that whatever is being drawn by the rectangle grob in these areas will be invisible. We also see that opacity is compounded by overlaying shapes as the areas covered both by the circle and the square in the mask has a higher opacity.

## Future features

It is, of course, dangerous to promise what the future brings. However, I do know of a few features adjacent to what has been discussed above that might make sense to know about.

When it comes to clipping paths, there is currently a lack of way to describe how multiple shapes are combined, since the fill rule is implicitly "winding" and you have no control over the direction the graphic device trace circles and rectangles. Work is already being done to let you control this from grid, so it will become easier to e.g. punch out holes in a clipping path by overlaying two grobs.

As noted in the discussion about masks, only alpha masks are currently possible. However, producing an exact transparency through compounded shapes can be tough because of the way opacity combines. In the future there will also be support for luminosity masks and this should greatly improve the user experience of this feature in my opinion.

Still, the main takeaway from all of the above is that the graphic engine is once again a living breathing code-base with big user-facing features on the horizon.

## The ggplot2 implications

While ggplot2 uses grid underneath it's grammar API, these features are generally not directly available in ggplot2. This is because most of these features are not directly applicable to the current API. Both gradients and patterns are obvious candidates for extensions of the ggplot2 API. But, for now, the grid API doesn't support a vector of patterns/gradients. Once this limitation is removed (it is in the works), we will need to figure out how scaling of these more flexible fill types should work. The starting point is, of course, to allow mapping from one data-value to a predefined pattern/gradient, but it would be interesting to think about how to map data-values to features of the pattern/gradient, e.g. have the gradient defined by two or more columns that all maps to different colors. Some of this work and exploration is already happening in [ggpattern](https://coolbutuseless.github.io/package/ggpattern), which could form the basis of future ggplot2 support.

As for path clipping, we could imagine that geoms could take a clipping grob, but it is not obvious how this grob should be constructed in a manner consistent with the grammar. The same goes for masks. Maybe most of this work should be relegated to [ggfx](https://ggfx.data-imaginist.com) which has an extended API that seems better suited to masks and arbitrary clipping.

## Acknowledgement

I'd like to extend a huge thanks to Paul Murrell for continuing to support and improve the graphics API in R, and for his willingness to answer questions during the implementation of the new features in ragg and svglite. The new graphics engine features were joint work with Paul Murrell, partly sponsored by RStudio.

