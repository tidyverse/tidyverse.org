---
title: "Taking Control of Plot Scaling"
date: 2020-08-21
output: hugodown::hugo_document

description: > 
  Learn how to control scaling of the content in your plot when you render plots
  to different sizes.

# Authors. Comma separated list, e.g. `["Bob Smith", "David Jones"]`.
author: Thomas Lin Pedersen

# Tags and categories
# For example, use `tags = []` for no tags, or the form `tags = ["A Tag", "Another Tag"]` for one or more tags.
tags: ["graphics", "ragg"]
categories: ["learn"]

# For wide photo caption
photo:
  url: https://unsplash.com/photos/6GjHwABuci4
  author: Mikael Kristenson
rmd_hash: 796637bc41f5299d

---

Some time ago, while working on the new edition of the ggplot2 book, I asked out to the R twitterverse what part of using ggplot2 was the most incomprehensible for seasoned users. By a very large margin the most "popular" response revolved around making sure that output had the correct scaling of text, lines, etc.

The latest release of ragg contains a new functionality that will hopefully make this issue a thing of the past. Read on how to use it.

Some definitions
----------------

Before we delve into the problem we should clarify a few concepts related to graphics and sizing:

**Absolute size:** This is the physical dimensions of the graphic (or, more precisely, the intended physical dimensions). This is measured in centimeters or inches or another absolute length unit.

**Pixel size:** For raster output, the graphic is encoded as a matrix of color values. Each cell in the matrix is a pixel. The pixel size is the number of rows and columns in the matrix. Pixels does not have any inherent physical size.

**Resolution:** This number ties absolute and pixel size together. It is usually given in ppi (pixels per inch), though dpi (dots per inch) is used interchangeably. A resolution of 72 ppi means that an inch is considered 72 pixels long.

**Pointsize:** This is a measure tied to text sizing. When we set a font to size 12, it is given in points. While the actual size of a point has [varied throughout history](https://en.wikipedia.org/wiki/Point_(typography)#Varying_standards), the general consensus now is that 1pt = 1/72 inch (this is also adopted by R). Since points is an absolute unit, the resolution of the output will determine the number of pixels it correspond to.

The problem
-----------

With formalities out of the way, we can describe the problem more clearly. At its core, this is about ensuring the correct scaling of a plot as we develop it for varying absolute sizes.

When we develop a graphic we will generally sit in front of a computer and fine tune it while continuously getting previews on the screen. Once we are content with it we will save it to the correct absolute size required by wherever we intend to publish the plot. In the remainder of the text we will assume that we sit in front of a computer developing a plot that should end up on a poster.

This is the plot, and how it looks on a computer:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://rdrr.io/r/base/library.html'>library</a></span>(<span class='k'><a href='http://ggplot2.tidyverse.org'>ggplot2</a></span>)
<span class='nf'><a href='https://rdrr.io/r/base/library.html'>library</a></span>(<span class='k'><a href='https://ragg.r-lib.org'>ragg</a></span>)
<span class='nf'><a href='https://rdrr.io/r/base/library.html'>library</a></span>(<span class='k'><a href='https://allisonhorst.github.io/palmerpenguins'>palmerpenguins</a></span>)

<span class='c'># plot adapted from https://github.com/allisonhorst/palmerpenguins</span>
<span class='k'>p</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggplot.html'>ggplot</a></span>(<span class='nf'><a href='https://rdrr.io/r/stats/na.fail.html'>na.omit</a></span>(<span class='k'>penguins</span>), <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/aes.html'>aes</a></span>(x = <span class='k'>flipper_length_mm</span>, y = <span class='k'>body_mass_g</span>)) <span class='o'>+</span>
  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/geom_point.html'>geom_point</a></span>(
    <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/aes.html'>aes</a></span>(color = <span class='k'>species</span>, shape = <span class='k'>species</span>),
    size = <span class='m'>3</span>,
    alpha = <span class='m'>0.8</span>
  ) <span class='o'>+</span> 
  <span class='k'>ggforce</span>::<span class='nf'><a href='https://ggforce.data-imaginist.com/reference/geom_mark_ellipse.html'>geom_mark_ellipse</a></span>(
    <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/aes.html'>aes</a></span>(filter = <span class='k'>species</span> <span class='o'>==</span> <span class='s'>"Gentoo"</span>, 
        description = <span class='s'>"Gentoo penguins are generally bigger in size"</span>)
  ) <span class='o'>+</span> 
  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/labs.html'>labs</a></span>(x = <span class='s'>"Flipper Length [mm]"</span>, y = <span class='s'>"Body Mass [g]"</span>,  colour = <span class='s'>"Species"</span>, 
       shape = <span class='s'>"Species"</span>)

<span class='k'>pngfile</span> <span class='o'>&lt;-</span> <span class='k'>fs</span>::<span class='nf'><a href='http://fs.r-lib.org/reference/path.html'>path</a></span>(<span class='k'>knitr</span>::<span class='nf'><a href='https://rdrr.io/pkg/knitr/man/fig_path.html'>fig_path</a></span>(),  <span class='s'>"basis.png"</span>)

<span class='c'># I'm explicitly calling the device functions so you can see the dimensions </span>
<span class='c'># used</span>
<span class='nf'><a href='https://ragg.r-lib.org/reference/agg_png.html'>agg_png</a></span>(<span class='k'>pngfile</span>, width = <span class='m'>20</span>, height = <span class='m'>12</span>, units = <span class='s'>"cm"</span>, res = <span class='m'>300</span>)
<span class='nf'><a href='https://rdrr.io/r/graphics/plot.default.html'>plot</a></span>(<span class='k'>p</span>)
<span class='nf'><a href='https://rdrr.io/r/base/invisible.html'>invisible</a></span>(<span class='nf'><a href='https://rdrr.io/r/grDevices/dev.html'>dev.off</a></span>())
<span class='k'>knitr</span>::<span class='nf'><a href='https://rdrr.io/pkg/knitr/man/include_graphics.html'>include_graphics</a></span>(<span class='k'>pngfile</span>)
</code></pre>
<img src="figs/unnamed-chunk-1-1/basis.png" width="" style="display: block; margin: auto;" />

</div>

This looks good, but remember we want to use this on a poster. A poster is usually observed at a farther distance than a computer screen, so in order to make it legible the plot should be bigger. How much bigger? Well, if we assume that we are watching our screen at 50 cm distance, and our poster is meant to be observed at 1.5 m distance, then our plot should be 3 times larger to take up the same amount of space in our vision:

![Schematic representation of the fact that size must increase by the same factor as distance to object in order to continue taking up the same amount of space in the vision](scaling.png)

With that in mind we quickly size up our plot:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='k'>pngfile</span> <span class='o'>&lt;-</span> <span class='k'>fs</span>::<span class='nf'><a href='http://fs.r-lib.org/reference/path.html'>path</a></span>(<span class='k'>knitr</span>::<span class='nf'><a href='https://rdrr.io/pkg/knitr/man/fig_path.html'>fig_path</a></span>(),  <span class='s'>"large_basis.png"</span>)
<span class='nf'><a href='https://ragg.r-lib.org/reference/agg_png.html'>agg_png</a></span>(<span class='k'>pngfile</span>, width = <span class='m'>60</span>, height = <span class='m'>36</span>, units = <span class='s'>"cm"</span>, res = <span class='m'>300</span>)
<span class='nf'><a href='https://rdrr.io/r/graphics/plot.default.html'>plot</a></span>(<span class='k'>p</span>)
<span class='nf'><a href='https://rdrr.io/r/base/invisible.html'>invisible</a></span>(<span class='nf'><a href='https://rdrr.io/r/grDevices/dev.html'>dev.off</a></span>())
<span class='k'>knitr</span>::<span class='nf'><a href='https://rdrr.io/pkg/knitr/man/include_graphics.html'>include_graphics</a></span>(<span class='k'>pngfile</span>)
</code></pre>
<img src="figs/unnamed-chunk-2-1/large_basis.png" width="" style="display: block; margin: auto;" />

</div>

The plot above doesn't look physically larger, but that is because the webpage downscales it to make it fit. You can download each of the images and open them in a image editor to convince yourself that they are of different absolute size. The downscaling done by the webpage allows us to simulate how looking at our poster may feel like, and it is not pretty; everything seems super small and ineligible.

Why is that? Our plot is a mix of elements positioned and dimensioned based on both relative and absolute sizes. While the relative sizes expand along with the output size, the absolute sizes does not. The text is given in points which, as you recall, is an absolute dimension. The same is true for the element sizes in the scatterplot, the grid lines, etc. This means that as we scale up the output size, they remain the same size and will thus get smaller relative to the full image.

> The reverse can be a problem as well. If you render a plot to a smaller size than the one you've previewed you may find that text, margins, etc. take up all the available space.

Now, how should we go about correcting this?

Attempt 1: Use vector graphics
------------------------------

The discussion above is especially relevant to raster output since they don't resize gracefully and it is thus very important to get the correct dimensions and resolution when it is rendered. One way to resolve this is to not render to raster but use a vector graphic device such as [`pdf()`](https://rdrr.io/r/grDevices/pdf.html) or `svglite()`. With these you can simply render the graphic to a size where everything looks as it should and then resize the output to the physical size that you need. There are valid reasons to not want to use vector graphics, however. The look of the output may change depending on which program opens them. Custom fonts may not render correctly on other systems. Or you may have such a large amount of graphical elements that the vector graphic becomes unreasonably large and heavy to display. If none of this applies then using a vector graphic device is definitely a valid and reasonable solution. For the remainder of the post we assume that we want the output in a raster format such as png and explore how we may fix our scaling issues there.

Attempt 2: Theming
------------------

One approach to fixing this is by changing the theme settings of the plot, so that they work better for a larger size:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='k'>p1</span> <span class='o'>&lt;-</span> <span class='k'>p</span> <span class='o'>+</span> 
  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggtheme.html'>theme_gray</a></span>(base_size = <span class='m'>33</span>)
<span class='k'>pngfile</span> <span class='o'>&lt;-</span> <span class='k'>fs</span>::<span class='nf'><a href='http://fs.r-lib.org/reference/path.html'>path</a></span>(<span class='k'>knitr</span>::<span class='nf'><a href='https://rdrr.io/pkg/knitr/man/fig_path.html'>fig_path</a></span>(),  <span class='s'>"theming.png"</span>)
<span class='nf'><a href='https://ragg.r-lib.org/reference/agg_png.html'>agg_png</a></span>(<span class='k'>pngfile</span>, width = <span class='m'>60</span>, height = <span class='m'>36</span>, units = <span class='s'>"cm"</span>, res = <span class='m'>300</span>)
<span class='nf'><a href='https://rdrr.io/r/graphics/plot.default.html'>plot</a></span>(<span class='k'>p1</span>)
<span class='nf'><a href='https://rdrr.io/r/base/invisible.html'>invisible</a></span>(<span class='nf'><a href='https://rdrr.io/r/grDevices/dev.html'>dev.off</a></span>())
<span class='k'>knitr</span>::<span class='nf'><a href='https://rdrr.io/pkg/knitr/man/include_graphics.html'>include_graphics</a></span>(<span class='k'>pngfile</span>)
</code></pre>
<img src="figs/unnamed-chunk-3-1/theming.png" width="" style="display: block; margin: auto;" />

</div>

This approach got us surprisingly far. A lot of the theme elements of the plot is derived from the base size argument so many adapts. Not all though, as we can see the legend keys maintaining their relative small size. If you've been using a custom theme it may also be that you've overwritten some of the default sizes and will need to change that as well.

One thing missing is all the non-theme elements (i.e. things part of the layer). Because of this we'd have to redo the whole plot in order to get the desired result:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='k'>p1</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggplot.html'>ggplot</a></span>(<span class='nf'><a href='https://rdrr.io/r/stats/na.fail.html'>na.omit</a></span>(<span class='k'>penguins</span>), <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/aes.html'>aes</a></span>(x = <span class='k'>flipper_length_mm</span>, y = <span class='k'>body_mass_g</span>)) <span class='o'>+</span>
  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/geom_point.html'>geom_point</a></span>(
    <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/aes.html'>aes</a></span>(color = <span class='k'>species</span>, shape = <span class='k'>species</span>),
    size = <span class='m'>9</span>,
    alpha = <span class='m'>0.8</span>
  ) <span class='o'>+</span> 
  <span class='k'>ggforce</span>::<span class='nf'><a href='https://ggforce.data-imaginist.com/reference/geom_mark_ellipse.html'>geom_mark_ellipse</a></span>(
    <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/aes.html'>aes</a></span>(filter = <span class='k'>species</span> <span class='o'>==</span> <span class='s'>"Gentoo"</span>, 
        description = <span class='s'>"Gentoo penguins are generally bigger in size"</span>),
    size = <span class='m'>1.5</span>,
    label.fontsize = <span class='m'>36</span>
  ) <span class='o'>+</span> 
  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/labs.html'>labs</a></span>(x = <span class='s'>"Flipper Length [mm]"</span>, y = <span class='s'>"Body Mass [g]"</span>,  colour = <span class='s'>"Species"</span>, 
       shape = <span class='s'>"Species"</span>) <span class='o'>+</span> 
  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggtheme.html'>theme_gray</a></span>(base_size = <span class='m'>33</span>)
<span class='k'>pngfile</span> <span class='o'>&lt;-</span> <span class='k'>fs</span>::<span class='nf'><a href='http://fs.r-lib.org/reference/path.html'>path</a></span>(<span class='k'>knitr</span>::<span class='nf'><a href='https://rdrr.io/pkg/knitr/man/fig_path.html'>fig_path</a></span>(),  <span class='s'>"theming2.png"</span>)
<span class='nf'><a href='https://ragg.r-lib.org/reference/agg_png.html'>agg_png</a></span>(<span class='k'>pngfile</span>, width = <span class='m'>60</span>, height = <span class='m'>36</span>, units = <span class='s'>"cm"</span>, res = <span class='m'>300</span>)
<span class='nf'><a href='https://rdrr.io/r/graphics/plot.default.html'>plot</a></span>(<span class='k'>p1</span>)
<span class='nf'><a href='https://rdrr.io/r/base/invisible.html'>invisible</a></span>(<span class='nf'><a href='https://rdrr.io/r/grDevices/dev.html'>dev.off</a></span>())
<span class='k'>knitr</span>::<span class='nf'><a href='https://rdrr.io/pkg/knitr/man/include_graphics.html'>include_graphics</a></span>(<span class='k'>pngfile</span>)
</code></pre>
<img src="figs/unnamed-chunk-4-1/theming2.png" width="" style="display: block; margin: auto;" />

</div>

We can see that we are getting there, but the journey hasn't been pleasant. Especially for the last part it requires knowledge of all the different settings in a geom that encodes absolute sizes. For the mark geom we only fixed the ellipse line width and the text size, but there are many more settings that needs to be updated as well as is apparent from the weird look of the text box.

Another issue that arises is that if we need this plot at yet another different scale, we will need to change quite a lot of code in order to get there.

Attempt 3: Resolution scaling
-----------------------------

Since the resolution is the parameter that ties the pixel size and absolute size together it is possible to use it as a scaling factor, but it requires some non-obvious adjustments:

The first thing we need to do is convert our physical dimensions to pixel dimensions using our desired resolution. We want to end up with a 60x36cm plot at 300ppi. This gives us:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span>(<span class='m'>60</span>, <span class='m'>36</span>) <span class='o'>*</span>
  <span class='m'>0.3937</span> <span class='o'>*</span> <span class='c'># convert to inch</span>
  <span class='m'>300</span> <span class='c'># convert to pixels</span>
<span class='c'>#&gt; [1] 7086.60 4251.96</span></code></pre>

</div>

We can now use these values directly in our device and change the resolution of the device to trick it into thinking that text etc should be rendered at a larger size

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='k'>pngfile</span> <span class='o'>&lt;-</span> <span class='k'>fs</span>::<span class='nf'><a href='http://fs.r-lib.org/reference/path.html'>path</a></span>(<span class='k'>knitr</span>::<span class='nf'><a href='https://rdrr.io/pkg/knitr/man/fig_path.html'>fig_path</a></span>(),  <span class='s'>"resolution.png"</span>)
<span class='nf'><a href='https://ragg.r-lib.org/reference/agg_png.html'>agg_png</a></span>(<span class='k'>pngfile</span>, width = <span class='m'>7087</span>, height = <span class='m'>4252</span>, units = <span class='s'>"px"</span>, res = <span class='m'>900</span>)
<span class='nf'><a href='https://rdrr.io/r/graphics/plot.default.html'>plot</a></span>(<span class='k'>p</span>)
<span class='nf'><a href='https://rdrr.io/r/base/invisible.html'>invisible</a></span>(<span class='nf'><a href='https://rdrr.io/r/grDevices/dev.html'>dev.off</a></span>())
<span class='k'>knitr</span>::<span class='nf'><a href='https://rdrr.io/pkg/knitr/man/include_graphics.html'>include_graphics</a></span>(<span class='k'>pngfile</span>)
</code></pre>
<img src="figs/unnamed-chunk-6-1/resolution.png" width="" style="display: block; margin: auto;" />

</div>

This actually works exactly as we hoped. We've gotten our huge version of the plot but with the same exact scaling of all graphic elements.

Depending on your temperament this may be a perfect solution. To me, I think the conversion from physical dimensions to pixels is tedious, and it has the added drawback that the dimensions of the plot is incorrectly encoded (it will appear as a 20\*12cm plot at 900ppi) which may impact how it is presented in different programs. In the end you may have to manually resize it to get the correct physical dimensions in the end.

The solution
------------

Seeing that there is no single perfect solution to fixing this with the tools at our disposal, I've added a new argument to the ragg devices called `scaling`. It's a multiplier that is applied to all absolute sizes, without interfering with the encoded dimensions of the output. Since we have increased the dimensions 3 times we set `scaling = 3` to make sure that the absolute sized elements are keeping their relative size.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='k'>pngfile</span> <span class='o'>&lt;-</span> <span class='k'>fs</span>::<span class='nf'><a href='http://fs.r-lib.org/reference/path.html'>path</a></span>(<span class='k'>knitr</span>::<span class='nf'><a href='https://rdrr.io/pkg/knitr/man/fig_path.html'>fig_path</a></span>(),  <span class='s'>"scaling.png"</span>)
<span class='nf'><a href='https://ragg.r-lib.org/reference/agg_png.html'>agg_png</a></span>(<span class='k'>pngfile</span>, width = <span class='m'>60</span>, height = <span class='m'>36</span>, units = <span class='s'>"cm"</span>, res = <span class='m'>300</span>, scaling = <span class='m'>3</span>)
<span class='nf'><a href='https://rdrr.io/r/graphics/plot.default.html'>plot</a></span>(<span class='k'>p</span>)
<span class='nf'><a href='https://rdrr.io/r/base/invisible.html'>invisible</a></span>(<span class='nf'><a href='https://rdrr.io/r/grDevices/dev.html'>dev.off</a></span>())
<span class='k'>knitr</span>::<span class='nf'><a href='https://rdrr.io/pkg/knitr/man/include_graphics.html'>include_graphics</a></span>(<span class='k'>pngfile</span>)
</code></pre>
<img src="figs/unnamed-chunk-7-1/scaling.png" width="" style="display: block; margin: auto;" />

</div>

As can be seen, the new argument makes it very easy to reclaim the look of the plot after resizing. Hopefully this will remove a good deal of the pain related to generating plots for papers, posters, presentations, etc. You do have to remember to use the same scaling setting for all plots for them to have the same sizing, but apart from that it makes it very easy to fine tune the look for the medium your creating it for.

Remember that the scaling factor of `3` was simply chosen to fit our presumed viewing distance and should not be repeated without thought. Another example would be to create a small version of the plot, e.g. for a thumbnail on a webpage. While there is no harm in manually scaling down a raster image, you may find that especially text is more readable when rendered to the desired size directly. To show this off we'll make a half-sized version of our plot as well. To spruce it up we'll use [`ggsave()`](https://ggplot2.tidyverse.org/reference/ggsave.html) instead of calling the ragg device directly. Let's see how it looks without using scaling first:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='k'>pngfile</span> <span class='o'>&lt;-</span> <span class='k'>fs</span>::<span class='nf'><a href='http://fs.r-lib.org/reference/path.html'>path</a></span>(<span class='k'>knitr</span>::<span class='nf'><a href='https://rdrr.io/pkg/knitr/man/fig_path.html'>fig_path</a></span>(),  <span class='s'>"small"</span>)
<span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggsave.html'>ggsave</a></span>(
  <span class='k'>pngfile</span>, 
  <span class='k'>p</span>, 
  device = <span class='k'>agg_png</span>, 
  width = <span class='m'>10</span>, height = <span class='m'>6</span>, units = <span class='s'>"cm"</span>, res = <span class='m'>300</span>
)
<span class='k'>knitr</span>::<span class='nf'><a href='https://rdrr.io/pkg/knitr/man/include_graphics.html'>include_graphics</a></span>(<span class='k'>pngfile</span>)
</code></pre>
<img src="figs/unnamed-chunk-8-1/small" width="50%" style="display: block; margin: auto;" />

</div>

As we can see, everything feels oversized for the plot, and the margins takes up way too much relative space. Using `scaling` we quickly resolve this:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='k'>pngfile</span> <span class='o'>&lt;-</span> <span class='k'>fs</span>::<span class='nf'><a href='http://fs.r-lib.org/reference/path.html'>path</a></span>(<span class='k'>knitr</span>::<span class='nf'><a href='https://rdrr.io/pkg/knitr/man/fig_path.html'>fig_path</a></span>(),  <span class='s'>"downscaling.png"</span>)
<span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggsave.html'>ggsave</a></span>(
  <span class='k'>pngfile</span>, 
  <span class='k'>p</span>, 
  device = <span class='k'>agg_png</span>, 
  width = <span class='m'>10</span>, height = <span class='m'>6</span>, units = <span class='s'>"cm"</span>, res = <span class='m'>300</span>,
  scaling = <span class='m'>0.5</span>
)
<span class='k'>knitr</span>::<span class='nf'><a href='https://rdrr.io/pkg/knitr/man/include_graphics.html'>include_graphics</a></span>(<span class='k'>pngfile</span>)
</code></pre>
<img src="figs/unnamed-chunk-9-1/downscaling.png" width="50%" style="display: block; margin: auto;" />

</div>

Addendum
--------

-   Preparing graphics for the web presents an additional hurdle. The HTML specification assumes a screen resolution of 96ppi since that was the predominant screen resolution at the time. Modern monitors have a much higher resolution but the assumption is still in effect (though operating systems may mitigate it). This is the reason why plots may look slightly smaller when rendered through Shiny, blogdown, or hugodown. Simply set the resolution to 96ppi and use pixel dimensions for the output to make sure it has the correct scaling.
-   Rendering images with RMarkdown requires some care as well since chunk options both take an output dimension in inches as well as a scaling factor for how big the rendered image should appear in the document. [R for Data Science](https://r4ds.had.co.nz/graphics-for-communication.html#figure-sizing) has some additional information on this

