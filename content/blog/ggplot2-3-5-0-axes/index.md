---
output: hugodown::hugo_document

slug: ggplot2-3-5-0-axes
title: "ggplot2 3.5.0: Axes"
date: 2024-02-21
author: Teun van den Brand
description: >
    The 3.5.0 version of ggplot2 comes with an overhaul of the guide system.
    Read here what is new for axes.

photo:
  url: https://unsplash.com/photos/white-and-black-measuring-tape-9rSP3SRUYh4
  author: CHUTTERSNAP

# one of: "deep-dive", "learn", "package", "programming", "roundup", or "other"
categories: [package] 
tags: [ggplot2, ggplot2-3-5-0]
rmd_hash: dbe10bd1a6655360

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
* [ ] Add intro sentence, e.g. the standard tagline for the package
* [ ] [`usethis::use_tidy_thanks()`](https://usethis.r-lib.org/reference/use_tidy_thanks.html)
-->

We are pleased to release [ggplot2](https://ggplot2.tidyverse.org) 3.5.0. This is one blogpost among several outlining changes to axes. Please find the [main release post](/blog/2024/02/ggplot2-3-5-0/) to read about other changes.

Axes, alongside [legends](/blog/2024/02/ggplot2-3-5-0-legends/), are visual representations of scales and allow observes to translate graphical properties of a plot into information. The innards of axes, like other guides, underwent a major overhaul with the guide system rewrite. Axes specifically are guides for positions and classically display labelled tick marks. In Cartesian coordinates, these are the x- and y-positions, but in non-Cartesian systems may reflect a theta, radius, longitude or latitude. In ggplot2, an axis is usually represented by the [`guide_axis()`](https://ggplot2.tidyverse.org/reference/guide_axis.html) function.

<div class="highlight">

</div>

## Minor ticks

A much requested expansion of axis capabilities is the ability to draw minor ticks. To draw minor ticks, you can use the `minor.ticks` argument of [`guide_axis()`](https://ggplot2.tidyverse.org/reference/guide_axis.html).

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://ggplot2.tidyverse.org'>ggplot2</a></span><span class='o'>)</span></span>
<span></span>
<span><span class='nv'>p</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggplot.html'>ggplot</a></span><span class='o'>(</span><span class='nv'>mpg</span>, <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/aes.html'>aes</a></span><span class='o'>(</span><span class='nv'>displ</span>, <span class='nv'>hwy</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/geom_point.html'>geom_point</a></span><span class='o'>(</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/guides.html'>guides</a></span><span class='o'>(</span></span>
<span>    x <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/guide_axis.html'>guide_axis</a></span><span class='o'>(</span>minor.ticks <span class='o'>=</span> <span class='kc'>TRUE</span><span class='o'>)</span>,</span>
<span>    y <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/guide_axis.html'>guide_axis</a></span><span class='o'>(</span>minor.ticks <span class='o'>=</span> <span class='kc'>TRUE</span><span class='o'>)</span></span>
<span>  <span class='o'>)</span></span>
<span><span class='nv'>p</span></span>
</code></pre>
<img src="figs/minor_ticks-1.png" alt="Scatterplot of engine displacement versus highway miles per gallon. Both the x and y axes have smaller ticks in between normal ticks." width="700px" style="display: block; margin: auto;" />

</div>

The minor ticks are unlabelled ticks and follow the `minor_breaks` provided to the scale. Their length is determined by the `axis.minor.ticks.length` and their positional children. The rest of their appearance is inherited from the major ticks, as can be seen in the plot below where the minor ticks on the y-axis are also blue. To tweak their style separately from the major ticks, the `axis.minor.ticks.{x.bottom/x.top/y.left/y.right}` setting can be used. Please note that there is *no* `axis.minor.ticks` setting without the position suffixes, as they inherit from the major ticks.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>p</span> <span class='o'>+</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/scale_continuous.html'>scale_x_continuous</a></span><span class='o'>(</span>minor_breaks <span class='o'>=</span> <span class='nf'>scales</span><span class='nf'>::</span><span class='nf'><a href='https://scales.r-lib.org/reference/breaks_width.html'>breaks_width</a></span><span class='o'>(</span><span class='m'>0.2</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/theme.html'>theme</a></span><span class='o'>(</span></span>
<span>    axis.ticks.length <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/grid/unit.html'>unit</a></span><span class='o'>(</span><span class='m'>5</span>, <span class='s'>"pt"</span><span class='o'>)</span>,</span>
<span>    axis.minor.ticks.length <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>rel</a></span><span class='o'>(</span><span class='m'>0.5</span><span class='o'>)</span>,</span>
<span>    axis.minor.ticks.x.bottom <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>element_line</a></span><span class='o'>(</span>colour <span class='o'>=</span> <span class='s'>'red'</span><span class='o'>)</span>,</span>
<span>    axis.ticks.y <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>element_line</a></span><span class='o'>(</span>colour <span class='o'>=</span> <span class='s'>"blue"</span><span class='o'>)</span></span>
<span>  <span class='o'>)</span></span>
</code></pre>
<img src="figs/minor_ticks_theming-1.png" alt="Scatterplot of engine displacement versus highway miles per gallon. The y-axis has blue larger and smaller tick marks, whereas the x-axis has the larger ticks in black and the smaller ticks in red. The x-axis has 4 smaller ticks in between large ones and the smaller ticks are half the size of larger ticks." width="700px" style="display: block; margin: auto;" />

</div>

## Capping

Axes can now also be 'capped' at the upper and lower end. We hesitate to call this improvement 'new', as it has been a part of base R plotting since time immemorial. When axes are capped, the axis line will not be drawn up to the panel edge, but up to the first and last breaks. Unsurprisingly, this only affects plots where the axis line is not blank.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggplot.html'>ggplot</a></span><span class='o'>(</span><span class='nv'>mpg</span>, <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/aes.html'>aes</a></span><span class='o'>(</span><span class='nv'>displ</span>, <span class='nv'>hwy</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/geom_point.html'>geom_point</a></span><span class='o'>(</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/guides.html'>guides</a></span><span class='o'>(</span></span>
<span>    x <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/guide_axis.html'>guide_axis</a></span><span class='o'>(</span>cap <span class='o'>=</span> <span class='s'>"both"</span><span class='o'>)</span>, <span class='c'># Cap both ends</span></span>
<span>    y <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/guide_axis.html'>guide_axis</a></span><span class='o'>(</span>cap <span class='o'>=</span> <span class='s'>"upper"</span><span class='o'>)</span> <span class='c'># Cap the upper end</span></span>
<span>  <span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/theme.html'>theme</a></span><span class='o'>(</span>axis.line <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>element_line</a></span><span class='o'>(</span><span class='o'>)</span><span class='o'>)</span></span>
</code></pre>
<img src="figs/capped_axes-1.png" alt="Scatterplot of engine displacement versus highway miles per gallon. The y-axis line starts at the bottom of the panel and continues to the top break. The x-axis line starts at the most left break and ends at the most right break." width="700px" style="display: block; margin: auto;" />

</div>

## Logarithmic axes

A new axis for displaying logarithmic (and related) scales has been added: [`guide_axis_logticks()`](https://ggplot2.tidyverse.org/reference/guide_axis_logticks.html). This axis draws three types of tick marks at log10-spaced positions. The ticks positions are placed in the original, untransformed data-space, so the axis plays well with scale- and coord-transformations. To accommodate a series of logarithmic-like transformations, such as [`scales::transform_pseudo_log()`](https://scales.r-lib.org/reference/transform_log.html) or [`scales::transform_asinh()`](https://scales.r-lib.org/reference/transform_asinh.html), scales that include 0 in their limits have the ticks mirrored around 0.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>r</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/seq.html'>seq</a></span><span class='o'>(</span><span class='m'>0.001</span>, <span class='m'>0.999</span>, length.out <span class='o'>=</span> <span class='m'>100</span><span class='o'>)</span></span>
<span><span class='nv'>df</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/data.frame.html'>data.frame</a></span><span class='o'>(</span></span>
<span>  x <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/stats/Cauchy.html'>qcauchy</a></span><span class='o'>(</span><span class='nv'>r</span><span class='o'>)</span>,</span>
<span>  y <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/stats/Lognormal.html'>qlnorm</a></span><span class='o'>(</span><span class='nv'>r</span><span class='o'>)</span></span>
<span><span class='o'>)</span></span>
<span></span>
<span><span class='nv'>p</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggplot.html'>ggplot</a></span><span class='o'>(</span><span class='nv'>df</span>, <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/aes.html'>aes</a></span><span class='o'>(</span><span class='nv'>x</span>, <span class='nv'>y</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/geom_path.html'>geom_line</a></span><span class='o'>(</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/coord_trans.html'>coord_trans</a></span><span class='o'>(</span>y <span class='o'>=</span> <span class='s'>"reverse"</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/scale_continuous.html'>scale_y_continuous</a></span><span class='o'>(</span></span>
<span>    transform <span class='o'>=</span> <span class='s'>"log10"</span>,</span>
<span>    breaks <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='m'>0.1</span>, <span class='m'>1</span>, <span class='m'>10</span><span class='o'>)</span>,</span>
<span>    guide <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/guide_axis_logticks.html'>guide_axis_logticks</a></span><span class='o'>(</span>long <span class='o'>=</span> <span class='m'>2</span>, mid <span class='o'>=</span> <span class='m'>1</span>, short <span class='o'>=</span> <span class='m'>0.5</span><span class='o'>)</span></span>
<span>  <span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/scale_continuous.html'>scale_x_continuous</a></span><span class='o'>(</span></span>
<span>    transform <span class='o'>=</span> <span class='s'>"asinh"</span>,</span>
<span>    breaks <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='o'>-</span><span class='m'>100</span>, <span class='o'>-</span><span class='m'>10</span>, <span class='o'>-</span><span class='m'>1</span>, <span class='m'>0</span>, <span class='m'>1</span>, <span class='m'>10</span>, <span class='m'>100</span><span class='o'>)</span>,</span>
<span>    guide <span class='o'>=</span> <span class='s'>"axis_logticks"</span></span>
<span>  <span class='o'>)</span></span>
<span><span class='nv'>p</span></span>
</code></pre>
<img src="figs/log_axes-1.png" alt="A line plot showing a negatively sloped line with a reversed log10-transformation on the y-axis and inverse hyberbolic sine transformation on the x-axis. Large ticks appears at multiples of 10, medium ticks at multiples of 5 and small ticks at multiples of 1." width="700px" style="display: block; margin: auto;" />

</div>

The log-ticks axis supersedes the earlier [`annotation_logticks()`](https://ggplot2.tidyverse.org/reference/annotation_logticks.html) function. Because it is implemented as an axis, it has minimal fuss with the placement of labels and is immune to the clipping options in the coord. To mirror [`annotation_logticks()`](https://ggplot2.tidyverse.org/reference/annotation_logticks.html) more closely, you can set a negative tick length in the theme.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>p</span> <span class='o'>+</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/theme.html'>theme</a></span><span class='o'>(</span>axis.ticks.length <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/grid/unit.html'>unit</a></span><span class='o'>(</span><span class='o'>-</span><span class='m'>2.25</span>, <span class='s'>"pt"</span><span class='o'>)</span><span class='o'>)</span></span>
</code></pre>
<img src="figs/log_ticks_inward-1.png" alt="The same plot as above, but the tick marks now point inwards." width="700px" style="display: block; margin: auto;" />

</div>

## Stacked axes

The last new axis is technically not an axis, but a way to combine axis. [`guide_axis_stack()`](https://ggplot2.tidyverse.org/reference/guide_axis_stack.html) can take multiple other axes and combine them by placing them next to oneanother. On its own, the usefulness of stacking axes is pretty limited. However, when extensions start defining custom position guides, it is an easy way to mix-and-match axes from different extensions. The first axis is placed next to the panel and subsequent axes are placed further away from the panel. Axes, like legends, have acquired a `theme` argument that can be used to customise the display of individual axes.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggplot.html'>ggplot</a></span><span class='o'>(</span><span class='nv'>mpg</span>, <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/aes.html'>aes</a></span><span class='o'>(</span><span class='nv'>displ</span>, <span class='nv'>hwy</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/geom_point.html'>geom_point</a></span><span class='o'>(</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/guides.html'>guides</a></span><span class='o'>(</span>x <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/guide_axis_stack.html'>guide_axis_stack</a></span><span class='o'>(</span></span>
<span>    <span class='c'># Typical axis</span></span>
<span>    <span class='s'>"axis"</span>,</span>
<span>    <span class='c'># Inverted ticks with no text</span></span>
<span>    <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/guide_axis.html'>guide_axis</a></span><span class='o'>(</span>theme <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/theme.html'>theme</a></span><span class='o'>(</span></span>
<span>      axis.ticks.length.x <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>rel</a></span><span class='o'>(</span><span class='o'>-</span><span class='m'>1</span><span class='o'>)</span>, </span>
<span>      axis.text <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>element_blank</a></span><span class='o'>(</span><span class='o'>)</span></span>
<span>    <span class='o'>)</span><span class='o'>)</span>,</span>
<span>    <span class='c'># Just the line</span></span>
<span>    <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/guide_axis.html'>guide_axis</a></span><span class='o'>(</span>theme <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/theme.html'>theme</a></span><span class='o'>(</span></span>
<span>      axis.ticks <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>element_blank</a></span><span class='o'>(</span><span class='o'>)</span>, </span>
<span>      axis.text  <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>element_blank</a></span><span class='o'>(</span><span class='o'>)</span></span>
<span>    <span class='o'>)</span><span class='o'>)</span>,</span>
<span>    theme <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/theme.html'>theme</a></span><span class='o'>(</span>axis.line <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>element_line</a></span><span class='o'>(</span><span class='o'>)</span><span class='o'>)</span></span>
<span>  <span class='o'>)</span><span class='o'>)</span></span>
</code></pre>
<img src="figs/stack_axis-1.png" alt="Scatterplot of engine displacement versus highway miles per gallon. The x-axis resembles railroad tracks with labels in the middle and an additional line beneath." width="700px" style="display: block; margin: auto;" />

</div>

## Display in facets

More of an indirect improvement to axes, is the ability of facets to tweak the appearance of inner axes when scales are fixed. This facilitates requirements in some journals that every panel should have labelled axes. [`facet_wrap()`](https://ggplot2.tidyverse.org/reference/facet_wrap.html) and [`facet_grid()`](https://ggplot2.tidyverse.org/reference/facet_grid.html) would previously only display axes in between panels when `scales = "free"` was set. This is still the case, but there are more options available for [`facet_grid()`](https://ggplot2.tidyverse.org/reference/facet_grid.html) and fixed scales. Using the `axes = "all"` option, all axes are displayed, including those in between panels. When using `axes = "all_x"` or `axes = "all_y"`, you can narrow down which axes are displayed.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>p</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggplot.html'>ggplot</a></span><span class='o'>(</span><span class='nv'>mpg</span>, <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/aes.html'>aes</a></span><span class='o'>(</span><span class='nv'>displ</span>, <span class='nv'>hwy</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/geom_point.html'>geom_point</a></span><span class='o'>(</span><span class='o'>)</span></span>
<span></span>
<span><span class='nv'>p</span> <span class='o'>+</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/facet_grid.html'>facet_grid</a></span><span class='o'>(</span><span class='nv'>year</span> <span class='o'>~</span> <span class='nv'>drv</span>, axes <span class='o'>=</span> <span class='s'>"all_y"</span><span class='o'>)</span></span>
</code></pre>
<img src="figs/facet_axes_display-1.png" alt="A scatterplot facetted by the 'drv' and 'year' variables. The x-axes appear only at the bottom panels, whereas y-axes are displayed for every panel." width="700px" style="display: block; margin: auto;" />

</div>

In addition, you can choose to selectively suppress labels and only show ticks marks by using the `axis.labels` argument.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>p</span> <span class='o'>+</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/facet_grid.html'>facet_grid</a></span><span class='o'>(</span><span class='nv'>year</span> <span class='o'>~</span> <span class='nv'>drv</span>, axes <span class='o'>=</span> <span class='s'>"all"</span>, axis.labels <span class='o'>=</span> <span class='s'>"all_y"</span><span class='o'>)</span></span>
</code></pre>
<img src="figs/facet_axes_label_display-1.png" alt="A scatterplot facetted by the 'drv' and 'year' variables. The x-axes appear in full only at the bottom panels, and as tick marks in the first row of panels. The y-axes are displayed in full at every panel." width="700px" style="display: block; margin: auto;" />

</div>

That wraps up the visible changes to axes for this post. To read about general changes, see the [main post](/blog/2024/02/ggplot2-3-5-0/). The changes to legends are covered in a [separate post](/blog/2024/02/ggplot2-3-5-0-legends/) and for the new polar coordinate system (and their axes) see the [last post](/blog/2024/02/ggplot2-3-5-0-coord-radial/).

