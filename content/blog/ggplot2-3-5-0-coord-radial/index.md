---
output: hugodown::hugo_document

slug: ggplot2-3-5-0-coord-radial
title: "ggplot2 3.5.0: Introducing: coord_radial()"
date: 2024-02-21
author: Teun van den Brand
description: >
    Introducing a new polar coordinate system that supersedes the old 
    `coord_polar()`. Read on about the new `coord_radial()`.

photo:
  url: https://unsplash.com/photos/ferris-wheel-beside-body-of-water-under-blue-sky-during-daytime-IWOo59NUXBk
  author: Ismail Merad

# one of: "deep-dive", "learn", "package", "programming", "roundup", or "other"
categories: [package] 
tags: [ggplot2, ggplot2-3-5-0]
rmd_hash: 6c7a50d8a17df96b

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

We are happy to announce the release of [ggplot2](https://ggplot2.tidyverse.org) 3.5.0. This is one blogpost among several outlining a new polar coordinate system. Please find the [main release post](/blog/2024/02/ggplot2-3-5-0/) to read about other exciting changes.

Polar coordinates are a good reminder of the flexibility of the Grammar of Graphics: pie charts are just bar charts with polar coordinates. While the tried and tested [`coord_polar()`](https://ggplot2.tidyverse.org/reference/coord_polar.html) has served well in the past to fulfill your pie chart needs, we felt it was due some modernisation. We realised we could not adapt [`coord_polar()`](https://ggplot2.tidyverse.org/reference/coord_polar.html) to fit with the [new guide system](/blog/2024/02/ggplot2-3-5-0/#guide-rewrite) without severely breaking existing plots, so [`coord_radial()`](https://ggplot2.tidyverse.org/reference/coord_polar.html) was born to give a facelift to the polar coordinate system in ggplot2.

Relative to [`coord_polar()`](https://ggplot2.tidyverse.org/reference/coord_polar.html), [`coord_radial()`](https://ggplot2.tidyverse.org/reference/coord_polar.html) can:

1.  Draw circle sectors instead of only full circles.
2.  Avoid data vanishing in the centre of the plot.
3.  Adjust text angles on the fly.
4.  Use the new guide system.

## An updated look

The first noticeable contrast with [`coord_polar()`](https://ggplot2.tidyverse.org/reference/coord_polar.html), is that [`coord_radial()`](https://ggplot2.tidyverse.org/reference/coord_polar.html) is not particularly suited to building pie charts. Instead, it uses the scale expansion conventions like [`coord_cartesian()`](https://ggplot2.tidyverse.org/reference/coord_cartesian.html). This makes sense for most chart types, but not pie charts. Nonetheless, you can use the `expand = FALSE` setting to use [`coord_radial()`](https://ggplot2.tidyverse.org/reference/coord_polar.html) for pie charts.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://ggplot2.tidyverse.org'>ggplot2</a></span><span class='o'>)</span></span>
<span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://patchwork.data-imaginist.com'>patchwork</a></span><span class='o'>)</span></span>
<span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://scales.r-lib.org'>scales</a></span><span class='o'>)</span></span>
<span></span>
<span><span class='nv'>pie</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggplot.html'>ggplot</a></span><span class='o'>(</span><span class='nv'>mtcars</span>, <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/aes.html'>aes</a></span><span class='o'>(</span>y <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/factor.html'>factor</a></span><span class='o'>(</span><span class='m'>1</span><span class='o'>)</span>, fill <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/factor.html'>factor</a></span><span class='o'>(</span><span class='nv'>cyl</span><span class='o'>)</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/geom_bar.html'>geom_bar</a></span><span class='o'>(</span>width <span class='o'>=</span> <span class='m'>1</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/scale_discrete.html'>scale_y_discrete</a></span><span class='o'>(</span>guide <span class='o'>=</span> <span class='s'>"none"</span>, name <span class='o'>=</span> <span class='kc'>NULL</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/guides.html'>guides</a></span><span class='o'>(</span>fill <span class='o'>=</span> <span class='s'>"none"</span><span class='o'>)</span></span>
<span><span class='nv'>default</span>   <span class='o'>&lt;-</span> <span class='nv'>pie</span> <span class='o'>+</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/coord_polar.html'>coord_radial</a></span><span class='o'>(</span><span class='o'>)</span> <span class='o'>+</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/labs.html'>ggtitle</a></span><span class='o'>(</span><span class='s'>"default"</span><span class='o'>)</span></span>
<span><span class='nv'>no_expand</span> <span class='o'>&lt;-</span> <span class='nv'>pie</span> <span class='o'>+</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/coord_polar.html'>coord_radial</a></span><span class='o'>(</span>expand <span class='o'>=</span> <span class='kc'>FALSE</span><span class='o'>)</span> <span class='o'>+</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/labs.html'>ggtitle</a></span><span class='o'>(</span><span class='s'>"expand = FALSE"</span><span class='o'>)</span></span>
<span><span class='nv'>polar</span>     <span class='o'>&lt;-</span> <span class='nv'>pie</span> <span class='o'>+</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/coord_polar.html'>coord_polar</a></span><span class='o'>(</span><span class='o'>)</span> <span class='o'>+</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/labs.html'>ggtitle</a></span><span class='o'>(</span><span class='s'>"coord_polar()"</span><span class='o'>)</span></span>
<span></span>
<span><span class='nv'>default</span> <span class='o'>|</span> <span class='nv'>no_expand</span> <span class='o'>|</span> <span class='nv'>polar</span></span>
</code></pre>
<img src="figs/compare_polar-1.png" alt="Three pie charts showing the proportion of each cylinder number. The first has a gap in the middle and at the top with a grey circle in the background and is titled 'default'. The second is titled 'expand = FALSE' and shows a full pie chart with tick marks labelling the angle positions. The last plot is a full pie chart with a gray rectangular background without tick marks and a white line around the pie." width="700px" style="display: block; margin: auto;" />

</div>

Some visual differences stand out in the plots above. In [`coord_radial()`](https://ggplot2.tidyverse.org/reference/coord_polar.html), the panel background covers the data area of the plot, not a rectangle. It also does not have a grid-line encircling the plot and instead uses tick marks to indicate values along the theta (angle) coordinate. You may also notice that [`coord_polar()`](https://ggplot2.tidyverse.org/reference/coord_polar.html) still draws the radius axis, despite instructions to use `guide = "none"`. That is the integration with the guide system that birthed [`coord_radial()`](https://ggplot2.tidyverse.org/reference/coord_polar.html).

## Partial polar plots

Another important difference is that [`coord_radial()`](https://ggplot2.tidyverse.org/reference/coord_polar.html) does not necessarily need to display a full circle. By setting the `start` and `end` arguments separately, you can now make a partial polar plot. This makes it much easier to make semi- or quarter-circle plots.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>p</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggplot.html'>ggplot</a></span><span class='o'>(</span><span class='nv'>mpg</span>, <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/aes.html'>aes</a></span><span class='o'>(</span><span class='nv'>displ</span>, <span class='nv'>hwy</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/geom_point.html'>geom_point</a></span><span class='o'>(</span><span class='o'>)</span></span>
<span></span>
<span><span class='nv'>half</span> <span class='o'>&lt;-</span> <span class='nv'>p</span> <span class='o'>+</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/coord_polar.html'>coord_radial</a></span><span class='o'>(</span>start <span class='o'>=</span> <span class='o'>-</span><span class='m'>0.5</span> <span class='o'>*</span> <span class='nv'>pi</span>, end <span class='o'>=</span> <span class='m'>0.5</span> <span class='o'>*</span> <span class='nv'>pi</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/labs.html'>ggtitle</a></span><span class='o'>(</span><span class='s'>"−0.5π to +0.5π"</span><span class='o'>)</span></span>
<span><span class='nv'>quarter</span> <span class='o'>&lt;-</span> <span class='nv'>p</span> <span class='o'>+</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/coord_polar.html'>coord_radial</a></span><span class='o'>(</span>start <span class='o'>=</span> <span class='m'>0</span>, end <span class='o'>=</span> <span class='m'>0.5</span> <span class='o'>*</span> <span class='nv'>pi</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/labs.html'>ggtitle</a></span><span class='o'>(</span><span class='s'>"0 to +0.5π"</span><span class='o'>)</span></span>
<span><span class='nv'>half</span> <span class='o'>|</span> <span class='nv'>quarter</span></span>
</code></pre>
<img src="figs/partial_polar-1.png" alt="Two polar scatterplots of the 'mpg' dataset. The left plot is shaped like as a semicircle and the right plot as a quarter circle." width="700px" style="display: block; margin: auto;" />

</div>

## Donuts

It was already possible to turn a pie-chart into a donut-chart with [`coord_polar()`](https://ggplot2.tidyverse.org/reference/coord_polar.html). This is made even easier in [`coord_radial()`](https://ggplot2.tidyverse.org/reference/coord_polar.html) by setting the `inner.radius` argument to make a donut hole. For most plots, this avoids crowding data points in the center of the plot: points with a widely different `theta` coordinate but similarly small `r` coordinate are placed further apart.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>p</span> <span class='o'>+</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/coord_polar.html'>coord_radial</a></span><span class='o'>(</span>inner.radius <span class='o'>=</span> <span class='m'>0.3</span>, r_axis_inside <span class='o'>=</span> <span class='kc'>TRUE</span><span class='o'>)</span></span>
</code></pre>
<img src="figs/open_radial_plot-1.png" alt="A donut-shaped scatterplot of the 'mpg' dataset." width="700px" style="display: block; margin: auto;" />

</div>

## Text annotations

A grievance we noticed about polar coordinates, is that it was cumbersome to rotate text annotations along with the `theta` coordinate. Calculating the correct angles for labels is pretty involved and usually changes from plot to plot depending on how many items need to be displayed. To remove some of this hassle [`coord_radial()`](https://ggplot2.tidyverse.org/reference/coord_polar.html) has a `rotate_angle` switch, that will line up the text's `angle` aesthetic with the theta coordinate. For text angles of 0 degrees, this will place text in a tangent orientation to the circle and for angles of 90 degrees, this places text along the radius, as in the plot below.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggplot.html'>ggplot</a></span><span class='o'>(</span><span class='nv'>mtcars</span>, <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/aes.html'>aes</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/seq.html'>seq_along</a></span><span class='o'>(</span><span class='nv'>mpg</span><span class='o'>)</span>, <span class='nv'>mpg</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/geom_bar.html'>geom_col</a></span><span class='o'>(</span>width <span class='o'>=</span> <span class='m'>1</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/geom_text.html'>geom_text</a></span><span class='o'>(</span></span>
<span>    <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/aes.html'>aes</a></span><span class='o'>(</span>y <span class='o'>=</span> <span class='m'>32</span>, label <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/colnames.html'>rownames</a></span><span class='o'>(</span><span class='nv'>mtcars</span><span class='o'>)</span><span class='o'>)</span>,</span>
<span>    angle <span class='o'>=</span> <span class='m'>90</span>, hjust <span class='o'>=</span> <span class='m'>1</span></span>
<span>  <span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/coord_polar.html'>coord_radial</a></span><span class='o'>(</span>rotate_angle <span class='o'>=</span> <span class='kc'>TRUE</span>, expand <span class='o'>=</span> <span class='kc'>FALSE</span><span class='o'>)</span></span>
</code></pre>
<img src="figs/text_angles-1.png" alt="A wind rose plot showing miles per gallon for different cars. The car names skirt the outer edge of the plot and are oriented towards the centre." width="700px" style="display: block; margin: auto;" />

</div>

## Axes

Because the logic of drawing axes for polar coordinates is not the same as when axes are perfectly vertical or horizontal, we used the new guide system to build an axis specific to [`coord_radial()`](https://ggplot2.tidyverse.org/reference/coord_polar.html): the [`guide_axis_theta()`](https://ggplot2.tidyverse.org/reference/guide_axis_theta.html) axis. Guides for [`coord_radial()`](https://ggplot2.tidyverse.org/reference/coord_polar.html) can be set using `theta` and `r` name in the [`guides()`](https://ggplot2.tidyverse.org/reference/guides.html) function. While the `r` axis can be the regular [`guide_axis()`](https://ggplot2.tidyverse.org/reference/guide_axis.html), the `theta` axis uses the highly specialised [`guide_axis_theta()`](https://ggplot2.tidyverse.org/reference/guide_axis_theta.html). The theta axis shares many features with typical axes, like setting the text angle or the new `minor.ticks` and `cap` settings. More on these settings in the [axis blog](/blog/2024/02/ggplot2-3-5-0-axes/). As seen in previous plots, the default is to place text horizontally. One neat trick we've put into [`coord_radial()`](https://ggplot2.tidyverse.org/reference/coord_polar.html) is that we can set a *relative* text angle in the guides, such as in the plot below.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggplot.html'>ggplot</a></span><span class='o'>(</span><span class='nv'>mpg</span>, <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/aes.html'>aes</a></span><span class='o'>(</span><span class='nv'>class</span>, <span class='nv'>displ</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/geom_boxplot.html'>geom_boxplot</a></span><span class='o'>(</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/coord_polar.html'>coord_radial</a></span><span class='o'>(</span>start <span class='o'>=</span> <span class='m'>0.25</span> <span class='o'>*</span> <span class='nv'>pi</span>, end <span class='o'>=</span> <span class='m'>1.75</span> <span class='o'>*</span> <span class='nv'>pi</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/guides.html'>guides</a></span><span class='o'>(</span></span>
<span>    theta <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/guide_axis_theta.html'>guide_axis_theta</a></span><span class='o'>(</span>angle <span class='o'>=</span> <span class='m'>0</span><span class='o'>)</span>,</span>
<span>    r     <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/guide_axis.html'>guide_axis</a></span><span class='o'>(</span>angle <span class='o'>=</span> <span class='m'>0</span><span class='o'>)</span></span>
<span>  <span class='o'>)</span></span>
</code></pre>
<img src="figs/axis_angles-1.png" alt="Boxplot of the 'mpg' dataset displayed in partial polar coordinates. The theta labels are placed tangential to the circle. The radius labels line up with the tick mark direction." width="700px" style="display: block; margin: auto;" />

</div>

The theme elements to style these axes have the `theta` or `r` position indication, so to change the the axis line, you use the `axis.line.theta` and `axis.line.r` arguments. The theme settings can also be used to set the *absolute* angle of text.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggplot.html'>ggplot</a></span><span class='o'>(</span><span class='nv'>mpg</span>, <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/aes.html'>aes</a></span><span class='o'>(</span><span class='nv'>class</span>, <span class='nv'>displ</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/geom_boxplot.html'>geom_boxplot</a></span><span class='o'>(</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/coord_polar.html'>coord_radial</a></span><span class='o'>(</span>start <span class='o'>=</span> <span class='m'>0.25</span> <span class='o'>*</span> <span class='nv'>pi</span>, end <span class='o'>=</span> <span class='m'>1.75</span> <span class='o'>*</span> <span class='nv'>pi</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/theme.html'>theme</a></span><span class='o'>(</span></span>
<span>    axis.line.theta <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>element_line</a></span><span class='o'>(</span>colour <span class='o'>=</span> <span class='s'>"red"</span><span class='o'>)</span>,</span>
<span>    axis.text.theta <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>element_text</a></span><span class='o'>(</span>angle <span class='o'>=</span> <span class='m'>90</span><span class='o'>)</span>,</span>
<span>    axis.text.r     <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>element_text</a></span><span class='o'>(</span>colour <span class='o'>=</span> <span class='s'>"blue"</span><span class='o'>)</span></span>
<span>  <span class='o'>)</span></span>
</code></pre>
<img src="figs/axis_styling-1.png" alt="Boxplot of the 'mpg' dataset displayed in partial polar coordinates. The theta labels are placed vertically and a red line traces the outer circle. The radius labels are displayed in blue." width="700px" style="display: block; margin: auto;" />

</div>

Lastly, there can also be secondary axes. We anticipate that this is practically never needed, as grid lines follow the primary axes and without them, it is very hard to read from axes in polar coordinates. However, if there is some reason for using secondary axes on polar coordinates, you can use the `theta.sec` and `r.sec` names in the [`guides()`](https://ggplot2.tidyverse.org/reference/guides.html) function to control the guides. Please note that a secondary theta axis is entirely useless when `inner.radius = 0` (the default). There are no separate theme options for secondary r/theta axes, but to style them separately from the primary axes, you can use the `theme` argument in the guide instead.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggplot.html'>ggplot</a></span><span class='o'>(</span><span class='nv'>pressure</span>, <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/aes.html'>aes</a></span><span class='o'>(</span><span class='nv'>temperature</span>, <span class='nv'>pressure</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/geom_path.html'>geom_line</a></span><span class='o'>(</span>colour <span class='o'>=</span> <span class='s'>"blue"</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/scale_continuous.html'>scale_x_continuous</a></span><span class='o'>(</span></span>
<span>    labels <span class='o'>=</span> <span class='nf'><a href='https://scales.r-lib.org/reference/label_number.html'>label_number</a></span><span class='o'>(</span>suffix <span class='o'>=</span> <span class='s'>"°C"</span><span class='o'>)</span>,</span>
<span>    sec.axis <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/sec_axis.html'>sec_axis</a></span><span class='o'>(</span><span class='o'>~</span> <span class='nv'>.x</span> <span class='o'>*</span> <span class='m'>9</span><span class='o'>/</span><span class='m'>5</span> <span class='o'>+</span> <span class='m'>35</span>, labels <span class='o'>=</span> <span class='nf'><a href='https://scales.r-lib.org/reference/label_number.html'>label_number</a></span><span class='o'>(</span>suffix <span class='o'>=</span> <span class='s'>"°F"</span><span class='o'>)</span><span class='o'>)</span></span>
<span>  <span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/scale_continuous.html'>scale_y_continuous</a></span><span class='o'>(</span></span>
<span>    labels <span class='o'>=</span> <span class='nf'><a href='https://scales.r-lib.org/reference/label_number.html'>label_number</a></span><span class='o'>(</span>suffix <span class='o'>=</span> <span class='s'>" mmHg"</span><span class='o'>)</span>,</span>
<span>    sec.axis <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/sec_axis.html'>sec_axis</a></span><span class='o'>(</span><span class='o'>~</span> <span class='nv'>.x</span> <span class='o'>*</span> <span class='m'>0.133322</span>, labels <span class='o'>=</span> <span class='nf'><a href='https://scales.r-lib.org/reference/label_number.html'>label_number</a></span><span class='o'>(</span>suffix <span class='o'>=</span> <span class='s'>" kPa"</span><span class='o'>)</span><span class='o'>)</span></span>
<span>  <span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/guides.html'>guides</a></span><span class='o'>(</span></span>
<span>    theta.sec <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/guide_axis_theta.html'>guide_axis_theta</a></span><span class='o'>(</span>theme <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/theme.html'>theme</a></span><span class='o'>(</span>axis.line.theta <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>element_line</a></span><span class='o'>(</span><span class='o'>)</span><span class='o'>)</span><span class='o'>)</span>,</span>
<span>    r.sec <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/guide_axis.html'>guide_axis</a></span><span class='o'>(</span>theme <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/theme.html'>theme</a></span><span class='o'>(</span>axis.text.r <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>element_text</a></span><span class='o'>(</span>colour <span class='o'>=</span> <span class='s'>"red"</span><span class='o'>)</span><span class='o'>)</span><span class='o'>)</span></span>
<span>  <span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/coord_polar.html'>coord_radial</a></span><span class='o'>(</span></span>
<span>    start <span class='o'>=</span> <span class='m'>0.25</span> <span class='o'>*</span> <span class='nv'>pi</span>, end <span class='o'>=</span> <span class='m'>1.75</span> <span class='o'>*</span> <span class='nv'>pi</span>,</span>
<span>    inner.radius <span class='o'>=</span> <span class='m'>0.3</span></span>
<span>  <span class='o'>)</span></span>
</code></pre>
<img src="figs/secondary_axes-1.png" alt="A lineplot of the 'pressure' dataset in partial polar coordinates that is shaped like a donut with a bite taken out on top. The primary, outer theta axis displays temperature in degrees Celcius. The secondary, inner theta axis displays temperature in degrees Fahrenheit and has an axis line. The primary radius axis on the right displays pressure in millimetres of mercury. The secondary radius axis on the left displays pressure in kilo-Pascals in red text." width="700px" style="display: block; margin: auto;" />

</div>

