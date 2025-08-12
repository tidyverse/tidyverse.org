---
output: hugodown::hugo_document

slug: ggplot2-4-0-0
title: ggplot2 4.0.0
date: 2025-07-09
author: Teun van den Brand
description: >
    A new major version of ggplot2 has been released on CRAN. Find out what is new here.

photo:
  url: https://unsplash.com/photos/selective-focus-photography-of-water-droplets-on-grasses--N_UwPdUs7E
  author: Jonas Weckschmied

# one of: "deep-dive", "learn", "package", "programming", "roundup", or "other"
categories: [package] 
tags: [ggplot2]
rmd_hash: d08d32b8c2596c50

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

We're tickled pink to announce the release of [ggplot2](https://ggplot2.tidyverse.org) 4.0.0. ggplot2 is a system for declaratively creating graphics, based on The Grammar of Graphics. You provide the data, tell ggplot2 how to map variables to aesthetics, what graphical primitives to use, and it takes care of the details.

The new version can be installed from CRAN using:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://rdrr.io/r/utils/install.packages.html'>install.packages</a></span><span class='o'>(</span><span class='s'>"ggplot2"</span><span class='o'>)</span></span></code></pre>

</div>

This is a substantial release meriting a new major version, and contains a series of changes from a rewrite of the object oriented system from S3 to S7, large new features to smaller quality of life improvements and bugfixes. It is also the 18th anniversary of ggplot2 which is cause for celebration! In this blog post, we will highlight the most salient new features that come with this release. You can see a full list of changes in the [release notes](https://ggplot2.tidyverse.org/news/index.html)

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://ggplot2.tidyverse.org'>ggplot2</a></span><span class='o'>)</span></span>
<span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://patchwork.data-imaginist.com'>patchwork</a></span><span class='o'>)</span></span></code></pre>

</div>

## Adopting S7

In ggplot2, we use major version increments to indicate that something at the core of the package has changed. In this release, we have replaced many of ggplot2's S3 objects with S7 objects. Like S3 and S4, S7 is also an object oriented system that uses classes, generics and methods. S7 is a newer system that aims to strike a good balance between the flexibility of S3 and formality of S4.

Mostly, this change shouldn't be very noticeable when you're just using ggplot2 for building regular plots. At best, you may notice that we're more strictly enforcing types for certain arguments. For example, most ludicrous input is now rejected right away. This is due to how properties in S7 work, which get validated when a new object is instantiated.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>element_text</a></span><span class='o'>(</span>hjust <span class='o'>=</span> <span class='s'>"foo"</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; Error: &lt;ggplot2::element_text&gt; object properties are invalid:</span></span>
<span><span class='c'>#&gt; - @hjust must be &lt;NULL&gt;, &lt;integer&gt;, or &lt;double&gt;, not &lt;character&gt;</span></span>
<span></span></code></pre>

</div>

However, it may require some adaptation on your end if you use ggplot2's innards in unusual ways. For extension builders, a major benefit of using S7 is that one can now use double dispatch. This is most important for the [`update_ggplot()`](https://ggplot2.tidyverse.org/reference/update_ggplot.html) function (the successor of [`ggplot_add()`](https://ggplot2.tidyverse.org/reference/update_ggplot.html)), which determines what happens when you `+` an object to a plot. Now with S7, you can control what happens not only for right-hand side objects (which is how it used to work in S3), but also for the left-hand side objects.

We have put various pieces of backwards compatibility in to not break many packages that assumed the S3 structures of ggplot2. For example, we still return the data property with `ggplot()$data`, whereas the S7 way of accessing this should be `ggplot()@data`. Expect these to be phased out over time in favour of S7. We are preparing another blog post to help migrating from S3 to S7 for ggplot2 related packages.

## Theme improvements

Themes in ggplot2 have long served the role of capturing any non-data aspects of styling plots. We have come to realise that the default look of layers, from what the default shape of points is to what the default colour palette is, are also not truly data-driven choices. The idea to put these defaults into themes has been around for a while and Dana Page Seidel did pioneering work implementing this as early as 2018. Now, years of waiting have come to fruition and we're proud to announce this new functionality.

### Ink and paper

The way layer defaults are now implemented differs slightly from typical aesthetics you know and love. Whereas layers aesthetics distinguish `colour` and `fill`, the theme defaults distinguish `ink` (foreground) and `paper` (background). A boxplot is unreadable without `colour`, but is perfectly interpretable without `fill`. In the boxplot case, the `ink` is thus clearly the `colour` whereas `paper` is the `fill`. In bar charts or histograms, the [proportional ink](https://clauswilke.com/dataviz/proportional-ink.html) principle prescribes that the `fill` aesthetic is considered foreground, and thus count as `ink`. To accommodate special cases, like lines in [`geom_smooth()`](https://ggplot2.tidyverse.org/reference/geom_smooth.html) or [`geom_contour()`](https://ggplot2.tidyverse.org/reference/geom_contour.html), we also added a third `accent` option. In short, the theme defaults have role-oriented settings that differ from the property-oriented settings in layers.

We've added these three options to all built-in complete themes. Not only propagate these automatically to the layer defaults, they are also used to style additional theme components. You may notice that the panel background colour is a blend between `paper` and `ink`, which is now how many elements are parametrised in complete themes.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggplot.html'>ggplot</a></span><span class='o'>(</span><span class='nv'>mpg</span>, <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/aes.html'>aes</a></span><span class='o'>(</span><span class='nv'>displ</span>, <span class='nv'>hwy</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/geom_point.html'>geom_point</a></span><span class='o'>(</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/geom_smooth.html'>geom_smooth</a></span><span class='o'>(</span>method <span class='o'>=</span> <span class='s'>"lm"</span>, formula <span class='o'>=</span> <span class='nv'>y</span> <span class='o'>~</span> <span class='nv'>x</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggtheme.html'>theme_gray</a></span><span class='o'>(</span>paper <span class='o'>=</span> <span class='s'>"cornsilk"</span>, ink <span class='o'>=</span> <span class='s'>"navy"</span>, accent <span class='o'>=</span> <span class='s'>"tomato"</span><span class='o'>)</span></span>
</code></pre>
<img src="figs/unnamed-chunk-3-1.png" width="700px" style="display: block; margin: auto;" />

</div>

If you're customising a theme, you can use the `theme(geom)` argument to set a collection of defaults. The new function [`element_geom()`](https://ggplot2.tidyverse.org/reference/element.html) can be used to set these properties. Additionally, if you want a layer to read the property from this theme element, you can use the [`from_theme()`](https://ggplot2.tidyverse.org/reference/aes_eval.html) function in the mapping to access these variables[^1].

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggplot.html'>ggplot</a></span><span class='o'>(</span><span class='nv'>mpg</span>, <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/aes.html'>aes</a></span><span class='o'>(</span><span class='nv'>class</span>, <span class='nv'>displ</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/geom_boxplot.html'>geom_boxplot</a></span><span class='o'>(</span><span class='nf'><a href='https://ggplot2.tidyverse.org/reference/aes.html'>aes</a></span><span class='o'>(</span>colour <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/aes_eval.html'>from_theme</a></span><span class='o'>(</span><span class='nv'>accent</span><span class='o'>)</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/theme.html'>theme</a></span><span class='o'>(</span></span>
<span>    geom <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>element_geom</a></span><span class='o'>(</span>accent <span class='o'>=</span> <span class='s'>"tomato"</span>, paper <span class='o'>=</span> <span class='s'>"cornsilk"</span><span class='o'>)</span></span>
<span>  <span class='o'>)</span></span>
</code></pre>
<img src="figs/unnamed-chunk-4-1.png" width="700px" style="display: block; margin: auto;" />

</div>

A second conceptual difference in [`element_geom()`](https://ggplot2.tidyverse.org/reference/element.html) pertains the the use of lines. In one role, like in a line graph, the line represents the data directly. In a second role, a line serves as separation between two units. For example, you can display countries as polygons and the line connecting the vertices separate out places that are inside a country versus places that are outside that country. These two roles are captured in a `linewidth` and `linetype` pair and a `borderwidth` and `bordertype` pair.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggplot.html'>ggplot</a></span><span class='o'>(</span><span class='nv'>faithful</span>, <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/aes.html'>aes</a></span><span class='o'>(</span><span class='nv'>waiting</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/geom_histogram.html'>geom_histogram</a></span><span class='o'>(</span>bins <span class='o'>=</span> <span class='m'>30</span>, colour <span class='o'>=</span> <span class='s'>"black"</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/geom_histogram.html'>geom_freqpoly</a></span><span class='o'>(</span>bins <span class='o'>=</span> <span class='m'>30</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/theme.html'>theme</a></span><span class='o'>(</span>geom <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>element_geom</a></span><span class='o'>(</span></span>
<span>    bordertype <span class='o'>=</span> <span class='s'>"dashed"</span>,</span>
<span>    borderwidth <span class='o'>=</span> <span class='m'>0.2</span>,</span>
<span>    linewidth <span class='o'>=</span> <span class='m'>2</span>,</span>
<span>    linetype <span class='o'>=</span> <span class='s'>"solid"</span></span>
<span>  <span class='o'>)</span><span class='o'>)</span></span>
</code></pre>
<img src="figs/unnamed-chunk-5-1.png" width="700px" style="display: block; margin: auto;" />

</div>

### Scales and palettes

In addition to the defaults for layers, default palettes are now also encapsulated in the theme. The relevant theme settings have the pattern `palette.{aesthetic}.{type}`, where `type` can be either discrete or continuous. This allows you to coordinate your colour palettes with the rest of the theme.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggplot.html'>ggplot</a></span><span class='o'>(</span><span class='nv'>mpg</span>, <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/aes.html'>aes</a></span><span class='o'>(</span><span class='nv'>displ</span>, <span class='nv'>hwy</span>, shape <span class='o'>=</span> <span class='nv'>drv</span>, colour <span class='o'>=</span> <span class='nv'>cty</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/geom_point.html'>geom_point</a></span><span class='o'>(</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/theme.html'>theme</a></span><span class='o'>(</span></span>
<span>    palette.colour.continuous <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"chartreuse"</span>, <span class='s'>"forestgreen"</span><span class='o'>)</span>,</span>
<span>    palette.shape.discrete <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"triangle"</span>, <span class='s'>"triangle open"</span>, <span class='s'>"triangle down open"</span><span class='o'>)</span></span>
<span>  <span class='o'>)</span></span>
</code></pre>
<img src="figs/unnamed-chunk-6-1.png" width="700px" style="display: block; margin: auto;" />

</div>

The way this works is that all defaults scales now have `palette = NULL` as their default. During plot building, any `NULL` palettes are replaced by those declared in the theme.

### Shortcuts

We like to introduce a new family of short cuts. Looking at code in the wild, we've come to realise that theme declarations are very often chaotic. The [`theme()`](https://ggplot2.tidyverse.org/reference/theme.html) functions has lots of arguments, long argument names (hello there, `axis.minor.ticks.length.x.bottom`!) and very little structure. To make themes a little bit more digestible, we've created the following helper functions:

-   [`theme_sub_axis()`](https://ggplot2.tidyverse.org/reference/subtheme.html)
    -   [`theme_sub_axis_x()`](https://ggplot2.tidyverse.org/reference/subtheme.html)
        -   [`theme_sub_axis_bottom()`](https://ggplot2.tidyverse.org/reference/subtheme.html)
        -   [`theme_sub_axis_top()`](https://ggplot2.tidyverse.org/reference/subtheme.html)
    -   [`theme_sub_axis_y()`](https://ggplot2.tidyverse.org/reference/subtheme.html)
        -   [`theme_sub_axis_left()`](https://ggplot2.tidyverse.org/reference/subtheme.html)
        -   [`theme_sub_axis_right()`](https://ggplot2.tidyverse.org/reference/subtheme.html)
-   [`theme_sub_legend()`](https://ggplot2.tidyverse.org/reference/subtheme.html)
-   [`theme_sub_panel()`](https://ggplot2.tidyverse.org/reference/subtheme.html)
-   [`theme_sub_plot()`](https://ggplot2.tidyverse.org/reference/subtheme.html)
-   [`theme_sub_strip()`](https://ggplot2.tidyverse.org/reference/subtheme.html)

These helper functions pass on their arguments to [`theme()`](https://ggplot2.tidyverse.org/reference/theme.html) after they've prepended a relevant prefix. For example, using `theme_sub_legend(justification)` will translate to `theme(legend.justification)`. When you have \>1 theme element to change in a cluster of settings, it quickly becomes less typing to enlist the relevant shortcut. As a bonus, your theme code will tend to self-organise and become somewhat more readable.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='c'># Tired, verbose, chaotic</span></span>
<span><span class='nf'><a href='https://ggplot2.tidyverse.org/reference/theme.html'>theme</a></span><span class='o'>(</span></span>
<span>  panel.widths <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/grid/unit.html'>unit</a></span><span class='o'>(</span><span class='m'>5</span>, <span class='s'>"cm"</span><span class='o'>)</span>,</span>
<span>  axis.ticks.x <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>element_line</a></span><span class='o'>(</span>colour <span class='o'>=</span> <span class='s'>"red"</span><span class='o'>)</span>,</span>
<span>  axis.ticks.length.x <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/grid/unit.html'>unit</a></span><span class='o'>(</span><span class='m'>5</span>, <span class='s'>"mm"</span><span class='o'>)</span>,</span>
<span>  panel.background <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>element_rect</a></span><span class='o'>(</span>fill <span class='o'>=</span> <span class='kc'>NA</span><span class='o'>)</span>,</span>
<span>  panel.spacing.x <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/grid/unit.html'>unit</a></span><span class='o'>(</span><span class='m'>5</span>, <span class='s'>"mm"</span><span class='o'>)</span></span>
<span><span class='o'>)</span></span>
<span></span>
<span><span class='c'># Wired, terse, orderly</span></span>
<span><span class='nf'><a href='https://ggplot2.tidyverse.org/reference/subtheme.html'>theme_sub_axis_x</a></span><span class='o'>(</span></span>
<span>  ticks <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>element_line</a></span><span class='o'>(</span>colour <span class='o'>=</span> <span class='s'>"red"</span><span class='o'>)</span>,</span>
<span>  ticks.length <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/grid/unit.html'>unit</a></span><span class='o'>(</span><span class='m'>5</span>, <span class='s'>"mm"</span><span class='o'>)</span></span>
<span><span class='o'>)</span> <span class='o'>+</span></span>
<span><span class='nf'><a href='https://ggplot2.tidyverse.org/reference/subtheme.html'>theme_sub_panel</a></span><span class='o'>(</span></span>
<span>  widths <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/grid/unit.html'>unit</a></span><span class='o'>(</span><span class='m'>5</span>, <span class='s'>"cm"</span><span class='o'>)</span>,</span>
<span>  spacing.x <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/grid/unit.html'>unit</a></span><span class='o'>(</span><span class='m'>5</span>, <span class='s'>"mm"</span><span class='o'>)</span>,</span>
<span>  background <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>element_rect</a></span><span class='o'>(</span>fill <span class='o'>=</span> <span class='kc'>NA</span><span class='o'>)</span></span>
<span><span class='o'>)</span></span></code></pre>

</div>

In addition to shortcuts for clusters of theme elements, we've also added a few variants to declare margins.

-   [`margin_auto()`](https://ggplot2.tidyverse.org/reference/element.html) sets the margins in a CSS-like fashion similar to the [`margin`](https://developer.mozilla.org/en-US/docs/Web/CSS/margin) and [`padding`](https://developer.mozilla.org/en-US/docs/Web/CSS/padding) property.
    -   `margin_auto(1)` sets all four sides at once. It expands to `margin(t = 1, r = 1, b = 1, l = 1)`.
    -   `margin_auto(1, 2)` sets horizontal and vertical sides. It expands to `margin(t = 1, r = 2, b = 1, l = 2)`.
    -   `margin_auto(1, 2, 3)` expands to `margin(t = 1, r = 2, b = 3, l = 2)`.
-   [`margin_part()`](https://ggplot2.tidyverse.org/reference/element.html) has `NA` units as default, which will get replaced when the theme gets resolved. It roughly equates to 'set some of the sides, keep others as they are'.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://ggplot2.tidyverse.org/reference/merge_element.html'>merge_element</a></span><span class='o'>(</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>margin_part</a></span><span class='o'>(</span>r <span class='o'>=</span> <span class='m'>20</span><span class='o'>)</span>, <span class='c'># child</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>margin_auto</a></span><span class='o'>(</span><span class='m'>10</span><span class='o'>)</span> <span class='c'># parent</span></span>
<span><span class='o'>)</span></span>
<span><span class='c'>#&gt; [1] 10points 20points 10points 10points</span></span>
<span></span></code></pre>

</div>

### New settings

To coordinate (non-text) margins and spacings in a theme, we've introduced `spacing` and `margins` as new root elements in the theme. Other spacings and margins at the leaf elements inherit from (scale with) these root elements. To facilitate the different spacings in ggplot2, unit elements can now use [`rel()`](https://ggplot2.tidyverse.org/reference/element.html) to modify the inherited value. For example the default `axis.ticks.length` is now `rel(0.5)`, making the y-axis ticks 0.5 cm in the plot below. If we set the `axis.ticks.length.x` to `rel(2)`, it will double the value coming from `axis.ticks.length`, not double the value of `spacing`.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>p</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggplot.html'>ggplot</a></span><span class='o'>(</span><span class='nv'>penguins</span>, <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/aes.html'>aes</a></span><span class='o'>(</span><span class='nv'>bill_dep</span>, <span class='nv'>bill_len</span>, colour <span class='o'>=</span> <span class='nv'>species</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/geom_point.html'>geom_point</a></span><span class='o'>(</span>na.rm <span class='o'>=</span> <span class='kc'>TRUE</span><span class='o'>)</span></span>
<span></span>
<span><span class='nv'>p</span> <span class='o'>+</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/theme.html'>theme</a></span><span class='o'>(</span></span>
<span>  spacing <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/grid/unit.html'>unit</a></span><span class='o'>(</span><span class='m'>1</span>, <span class='s'>"cm"</span><span class='o'>)</span>, </span>
<span>  margins <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>margin_auto</a></span><span class='o'>(</span><span class='m'>1</span>, unit <span class='o'>=</span> <span class='s'>"cm"</span><span class='o'>)</span>,</span>
<span>  axis.ticks.length.x <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>rel</a></span><span class='o'>(</span><span class='m'>2</span><span class='o'>)</span></span>
<span><span class='o'>)</span></span>
</code></pre>
<img src="figs/unnamed-chunk-9-1.png" width="700px" style="display: block; margin: auto;" />

</div>

We also made it easier to set plot sizes. Using the `panel.widths` and `panel.heights` arguments, you can control the sizes of the panels. This mechanism is distinct from using `ggsave(width, height)`, where the whole plot, including annotations such as axes and titles is included. There are two ways to use these arguments:

-   Give a vector of units: each one will be applied to a panel separately and the vector will be recycled to fit the number of panels.
-   Give a single unit: which sets the total panel area (including panel spacings and inner axes) to that size.

Naturally, if you only have a single panel, these approaches are identical. If you have multiple panels and you want to set individual panels all to the same size (as opposed to the total size), you can take advantage of the recycling and use a length 2 unit vector.

In the plots below, you can notice that the panels span a different width despite the units adding up to the same amount (9 cm). This is because the 'single unit' approach also includes the panel spacings, but not the 'separate units' approach.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>p1</span> <span class='o'>&lt;-</span> <span class='nv'>p</span> <span class='o'>+</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/facet_grid.html'>facet_grid</a></span><span class='o'>(</span><span class='o'>~</span> <span class='nv'>island</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/labs.html'>labs</a></span><span class='o'>(</span>title <span class='o'>=</span> <span class='s'>"Separate units (per panel)"</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='c'># Using the new shortcut for panels</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/subtheme.html'>theme_sub_panel</a></span><span class='o'>(</span></span>
<span>    widths <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/grid/unit.html'>unit</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='m'>2</span>, <span class='m'>3</span>, <span class='m'>4</span><span class='o'>)</span>, <span class='s'>"cm"</span><span class='o'>)</span>,</span>
<span>    heights <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/grid/unit.html'>unit</a></span><span class='o'>(</span><span class='m'>3</span>, <span class='s'>"cm"</span><span class='o'>)</span></span>
<span>  <span class='o'>)</span></span>
<span></span>
<span><span class='nv'>p2</span> <span class='o'>&lt;-</span> <span class='nv'>p</span> <span class='o'>+</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/facet_grid.html'>facet_grid</a></span><span class='o'>(</span><span class='o'>~</span> <span class='nv'>island</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/labs.html'>labs</a></span><span class='o'>(</span>title <span class='o'>=</span> <span class='s'>"Single unit (all panels)"</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/subtheme.html'>theme_sub_panel</a></span><span class='o'>(</span></span>
<span>    widths <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/grid/unit.html'>unit</a></span><span class='o'>(</span><span class='m'>9</span>, <span class='s'>"cm"</span><span class='o'>)</span>,</span>
<span>    heights <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/grid/unit.html'>unit</a></span><span class='o'>(</span><span class='m'>3</span>, <span class='s'>"cm"</span><span class='o'>)</span></span>
<span>  <span class='o'>)</span></span>
<span></span>
<span><span class='nv'>p1</span> <span class='o'>/</span> <span class='nv'>p2</span></span>
</code></pre>
<img src="figs/unnamed-chunk-10-1.png" width="700px" style="display: block; margin: auto;" />

</div>

## Labels

We have added new ways that a plot retrieves labels for your variables. It is an informal convention in several packages including gt, Hmisc, labelled and others to use the 'label' attribute to store human readable labels for vectors. Now ggplot2 joins this convention and uses the 'label' attribute as the default label for a variable if present.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='c'># The penguins dataset was incorporated into base R 4.5</span></span>
<span><span class='nv'>df</span> <span class='o'>&lt;-</span> <span class='nv'>penguins</span></span>
<span></span>
<span><span class='c'># Manually set label attributes.</span></span>
<span><span class='c'># Other packages may offer better tooling than this.</span></span>
<span><span class='nf'><a href='https://rdrr.io/r/base/attr.html'>attr</a></span><span class='o'>(</span><span class='nv'>df</span><span class='o'>$</span><span class='nv'>species</span>, <span class='s'>"label"</span><span class='o'>)</span> <span class='o'>&lt;-</span> <span class='s'>"Penguin Species"</span></span>
<span><span class='nf'><a href='https://rdrr.io/r/base/attr.html'>attr</a></span><span class='o'>(</span><span class='nv'>df</span><span class='o'>$</span><span class='nv'>bill_dep</span>, <span class='s'>"label"</span><span class='o'>)</span> <span class='o'>&lt;-</span> <span class='s'>"Bill depth (mm)"</span></span>
<span><span class='nf'><a href='https://rdrr.io/r/base/attr.html'>attr</a></span><span class='o'>(</span><span class='nv'>df</span><span class='o'>$</span><span class='nv'>bill_len</span>, <span class='s'>"label"</span><span class='o'>)</span> <span class='o'>&lt;-</span> <span class='s'>"Bill length (mm)"</span></span>
<span><span class='nf'><a href='https://rdrr.io/r/base/attr.html'>attr</a></span><span class='o'>(</span><span class='nv'>df</span><span class='o'>$</span><span class='nv'>body_mass</span>, <span class='s'>"label"</span><span class='o'>)</span> <span class='o'>&lt;-</span> <span class='s'>"Body mass (g)"</span></span>
<span></span>
<span><span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggplot.html'>ggplot</a></span><span class='o'>(</span><span class='nv'>df</span>, <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/aes.html'>aes</a></span><span class='o'>(</span><span class='nv'>bill_dep</span>, <span class='nv'>bill_len</span>, colour <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/MathFun.html'>sqrt</a></span><span class='o'>(</span><span class='nv'>body_mass</span><span class='o'>)</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/geom_point.html'>geom_point</a></span><span class='o'>(</span>na.rm <span class='o'>=</span> <span class='kc'>TRUE</span><span class='o'>)</span></span>
</code></pre>
<img src="figs/unnamed-chunk-11-1.png" width="700px" style="display: block; margin: auto;" />

</div>

It has also been entrenched in some workflows to use a 'data dictionary' or codebook. For labelling purposes these dictionaries often contain column metadata that include labels or descriptions for variables (columns) in the dataset. To make it easier to work with column labels, we added the `labs(dictionary)` argument. It takes a named vector of labels, that can easily be generated from a data dictionary by [`setNames()`](https://rdrr.io/r/stats/setNames.html) or [`dplyr::pull()`](https://dplyr.tidyverse.org/reference/pull.html).

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>dict</span> <span class='o'>&lt;-</span> <span class='nf'>tibble</span><span class='nf'>::</span><span class='nf'><a href='https://tibble.tidyverse.org/reference/tribble.html'>tribble</a></span><span class='o'>(</span></span>
<span>  <span class='o'>~</span><span class='nv'>var</span>,    <span class='o'>~</span><span class='nv'>label</span>,</span>
<span>  <span class='s'>"species"</span>,  <span class='s'>"Penguin Species"</span>,</span>
<span>  <span class='s'>"bill_dep"</span>, <span class='s'>"Bill depth (mm)"</span>,</span>
<span>  <span class='s'>"bill_len"</span>, <span class='s'>"Bill length (mm)"</span>,</span>
<span>  <span class='s'>"body_mass"</span>, <span class='s'>"Body mass (g)"</span></span>
<span><span class='o'>)</span></span>
<span></span>
<span><span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggplot.html'>ggplot</a></span><span class='o'>(</span><span class='nv'>penguins</span>, <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/aes.html'>aes</a></span><span class='o'>(</span><span class='nv'>bill_dep</span>, <span class='nv'>bill_len</span>, colour <span class='o'>=</span> <span class='nv'>body_mass</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/geom_point.html'>geom_point</a></span><span class='o'>(</span>na.rm <span class='o'>=</span> <span class='kc'>TRUE</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='c'># Or:</span></span>
<span>  <span class='c'># labs(dictionary = dplyr::pull(dict, label, name = var))</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/labs.html'>labs</a></span><span class='o'>(</span>dictionary <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/stats/setNames.html'>setNames</a></span><span class='o'>(</span><span class='nv'>dict</span><span class='o'>$</span><span class='nv'>label</span>, <span class='nv'>dict</span><span class='o'>$</span><span class='nv'>var</span><span class='o'>)</span><span class='o'>)</span></span>
</code></pre>
<img src="figs/unnamed-chunk-12-1.png" width="700px" style="display: block; margin: auto;" />

</div>

One benefit to the label attributes or data dictionary approaches is that it is linked to your variables, not aesthetics. This means you can easily rearrange your aesthetics for a different plot, without having to painstakingly reorient the labels towards the correct aesthetics.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://ggplot2.tidyverse.org/reference/get_last_plot.html'>last_plot</a></span><span class='o'>(</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/aes.html'>aes</a></span><span class='o'>(</span><span class='nv'>body_mass</span>, <span class='nv'>bill_len</span>, colour <span class='o'>=</span> <span class='nv'>species</span><span class='o'>)</span></span>
</code></pre>
<img src="figs/unnamed-chunk-13-1.png" width="700px" style="display: block; margin: auto;" />

</div>

There are a few caveats to these label attributes and data dictionary approaches though:

-   If the aesthetic is not a pure variable name the label is not used. You can see this in the `sqrt(body_mass)` in the first example, which does not use the 'Body mass (g)' label. We assume when a variable is adjusted in this way, this would need to be reflected in the label itself. It would therefore be inappropriate to use the label of the unadjusted variable. Use of the [`.data`-pronoun](https://ggplot2.tidyverse.org/articles/ggplot2-in-packages.html#using-aes-and-vars-in-a-package-function) counts as a pure variable name for labelling purposes.
-   Some attributes are more stable than others, and it is not ggplot2's responsibility to babysit attributes. For example using `head(<data.frame>)` will typically drop attributes from atomic columns, whereas `head(<tibble>)` will not.

In addition, we're also allowing to use functions in all the places you can declare labels. The [`labs()`](https://ggplot2.tidyverse.org/reference/labs.html) function, scale names and guide titles now accept functions that take in the labels generated by the lower hierarchies and return amended labels. It should be spelled out that the hierarchy from lowest priority to highest priority is the following:

1.  The expression given in [`aes()`](https://ggplot2.tidyverse.org/reference/aes.html).
2.  The label attribute of the column.
3.  The entry in `labs(dictionary)`.
4.  The entry in `labs(<aesthetic> = <label>)`.
5.  The `scale_*(name)` argument.
6.  The `guide_*(title)` argument.

We can see this hierarchy in action in the plot below: the function in the axis guide transforms the input from the [`labs()`](https://ggplot2.tidyverse.org/reference/labs.html) function.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggplot.html'>ggplot</a></span><span class='o'>(</span><span class='nv'>penguins</span>, <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/aes.html'>aes</a></span><span class='o'>(</span><span class='nv'>bill_dep</span>, <span class='nv'>bill_len</span>, colour <span class='o'>=</span> <span class='nv'>species</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/geom_point.html'>geom_point</a></span><span class='o'>(</span>na.rm <span class='o'>=</span> <span class='kc'>TRUE</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/scale_colour_discrete.html'>scale_colour_discrete</a></span><span class='o'>(</span>name <span class='o'>=</span> <span class='nv'>toupper</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/guides.html'>guides</a></span><span class='o'>(</span>x <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/guide_axis.html'>guide_axis</a></span><span class='o'>(</span>title <span class='o'>=</span> <span class='nf'>tools</span><span class='nf'>::</span><span class='nv'><a href='https://rdrr.io/r/tools/toTitleCase.html'>toTitleCase</a></span><span class='o'>)</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/labs.html'>labs</a></span><span class='o'>(</span></span>
<span>    y <span class='o'>=</span> \<span class='o'>(</span><span class='nv'>x</span><span class='o'>)</span> <span class='nf'><a href='https://rdrr.io/r/base/paste.html'>paste0</a></span><span class='o'>(</span><span class='nv'>x</span>, <span class='s'>" variable"</span><span class='o'>)</span>,</span>
<span>    x <span class='o'>=</span> <span class='s'>"the label for the x variable"</span></span>
<span>  <span class='o'>)</span></span>
</code></pre>
<img src="figs/unnamed-chunk-14-1.png" width="700px" style="display: block; margin: auto;" />

</div>

In addition to the [`labs()`](https://ggplot2.tidyverse.org/reference/labs.html)-labels, we also made labelling the levels of discrete scales easier. When the scale's `breaks` are named, the scale's labels will adopt the break's names by default. This already was the case in continuous scales but now discrete scales have parity. A nice benefit of specifying labels this way is that they are directly linked to the breaks, which prevents the common mistake of specifying the `labels` argument without also setting the `breaks` argument, which may accidentally mismatch labels.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggplot.html'>ggplot</a></span><span class='o'>(</span><span class='nv'>penguins</span>, <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/aes.html'>aes</a></span><span class='o'>(</span><span class='nv'>bill_dep</span>, <span class='nv'>bill_len</span>, colour <span class='o'>=</span> <span class='nv'>species</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/geom_point.html'>geom_point</a></span><span class='o'>(</span>na.rm <span class='o'>=</span> <span class='kc'>TRUE</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/scale_colour_discrete.html'>scale_colour_discrete</a></span><span class='o'>(</span></span>
<span>    breaks <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span></span>
<span>      <span class='s'>"Pygoscelis adeliae"</span>     <span class='o'>=</span> <span class='s'>"Adelie"</span>,</span>
<span>      <span class='s'>"Pygoscelis papua"</span>       <span class='o'>=</span> <span class='s'>"Gentoo"</span>,</span>
<span>      <span class='s'>"Pygoscelis antarcticus"</span> <span class='o'>=</span> <span class='s'>"Chinstrap"</span></span>
<span>    <span class='o'>)</span></span>
<span>  <span class='o'>)</span></span>
</code></pre>
<img src="figs/unnamed-chunk-15-1.png" width="700px" style="display: block; margin: auto;" />

</div>

## Discrete scales

In this release we have tried to improve the 'freedom' afforded by discrete position scales. Previously, discrete values were always mapped to an integer sequence starting at 1 going up to the number of levels. Instead, we wanted to allow for different mappings that deviated from that pattern. While it is a bit foreign for position scales, ggplot2 already had a mechanism to assign alternate values to the levels of a scale: palettes! You can now use the `palette` argument like you would for non-position scales. It makes it easier to indicate any grouping structure along the axis, like separating the orange juice (OJ) groups from the vitamin C (VC) groups in the plot below.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggplot.html'>ggplot</a></span><span class='o'>(</span><span class='nv'>ToothGrowth</span>, <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/aes.html'>aes</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/interaction.html'>interaction</a></span><span class='o'>(</span><span class='nv'>dose</span>, <span class='nv'>supp</span>, sep <span class='o'>=</span> <span class='s'>"\n"</span><span class='o'>)</span>, <span class='nv'>len</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/geom_boxplot.html'>geom_boxplot</a></span><span class='o'>(</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/scale_discrete.html'>scale_x_discrete</a></span><span class='o'>(</span></span>
<span>    palette <span class='o'>=</span> <span class='nf'>scales</span><span class='nf'>::</span><span class='nf'><a href='https://scales.r-lib.org/reference/pal_manual.html'>pal_manual</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='m'>1</span><span class='o'>:</span><span class='m'>3</span>, <span class='m'>5</span><span class='o'>:</span><span class='m'>7</span><span class='o'>)</span><span class='o'>)</span></span>
<span>  <span class='o'>)</span></span>
</code></pre>
<img src="figs/unnamed-chunk-16-1.png" width="700px" style="display: block; margin: auto;" />

</div>

A second improvement we made to the placement of discrete levels is that we give greater control over the continuous limits. The continuous limits of a discrete scale used to be an implementation detail that kept track of any 'additional space' layers were taking up, for example because they use a `width` parameter. Now, these can be declared directly, making it easier to synchronise limits across plots or even facets. In the plot below, we're using the `continuous.limits` argument to ensure that all the bars have the same width; regardless of how many levels the x scale has to accommodate.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>p1</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggplot.html'>ggplot</a></span><span class='o'>(</span><span class='nv'>mpg</span>, <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/aes.html'>aes</a></span><span class='o'>(</span><span class='nv'>class</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/geom_bar.html'>geom_bar</a></span><span class='o'>(</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/facet_wrap.html'>facet_wrap</a></span><span class='o'>(</span><span class='o'>~</span> <span class='nv'>drv</span>, ncol <span class='o'>=</span> <span class='m'>1</span>, scales <span class='o'>=</span> <span class='s'>"free_x"</span><span class='o'>)</span></span>
<span></span>
<span><span class='nv'>p2</span> <span class='o'>&lt;-</span> <span class='nv'>p1</span> <span class='o'>+</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/scale_discrete.html'>scale_x_discrete</a></span><span class='o'>(</span>continuous.limits <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='m'>1</span>, <span class='m'>5</span><span class='o'>)</span><span class='o'>)</span></span>
<span></span>
<span><span class='o'>(</span><span class='nv'>p1</span> <span class='o'>+</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/labs.html'>labs</a></span><span class='o'>(</span>title <span class='o'>=</span> <span class='s'>"Free limits"</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>|</span> </span>
<span><span class='o'>(</span><span class='nv'>p2</span> <span class='o'>+</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/labs.html'>labs</a></span><span class='o'>(</span>title <span class='o'>=</span> <span class='s'>"Fixed limits"</span><span class='o'>)</span><span class='o'>)</span></span>
</code></pre>
<img src="figs/unnamed-chunk-17-1.png" width="700px" style="display: block; margin: auto;" />

</div>

Also absent from discrete scales was the ability to set minor breaks. Admittedly, they are less useful than minor breaks in continuous scales. In contrast to discrete (major) `breaks`, `minor_breaks` uses numeric input instead, allowing you to fine-tune placement without being bound by the scale's levels. With a few of tweaks of the theme, you can conceivably use minor breaks to visually separate levels as an alternative to the centre-lines for major breaks.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>p1</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggplot.html'>ggplot</a></span><span class='o'>(</span><span class='nv'>mpg</span>, <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/aes.html'>aes</a></span><span class='o'>(</span><span class='nv'>drv</span>, <span class='nv'>hwy</span>, colour <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/factor.html'>factor</a></span><span class='o'>(</span><span class='nv'>year</span><span class='o'>)</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/geom_point.html'>geom_point</a></span><span class='o'>(</span>position <span class='o'>=</span> <span class='s'>"jitterdodge"</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/guides.html'>guides</a></span><span class='o'>(</span>colour <span class='o'>=</span> <span class='s'>"none"</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/scale_discrete.html'>scale_x_discrete</a></span><span class='o'>(</span></span>
<span>    minor_breaks <span class='o'>=</span> <span class='nf'>scales</span><span class='nf'>::</span><span class='nf'><a href='https://scales.r-lib.org/reference/breaks_width.html'>breaks_width</a></span><span class='o'>(</span><span class='m'>1</span>, offset <span class='o'>=</span> <span class='m'>0.5</span><span class='o'>)</span>,</span>
<span>    <span class='c'># To show that the minor axis ticks take on these values</span></span>
<span>    guide <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/guide_axis.html'>guide_axis</a></span><span class='o'>(</span>minor.ticks <span class='o'>=</span> <span class='kc'>TRUE</span><span class='o'>)</span></span>
<span>  <span class='o'>)</span></span>
<span></span>
<span><span class='nv'>p2</span> <span class='o'>&lt;-</span> <span class='nv'>p1</span> <span class='o'>+</span> </span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/theme.html'>theme</a></span><span class='o'>(</span>panel.grid.major.x <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>element_blank</a></span><span class='o'>(</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/subtheme.html'>theme_sub_axis_bottom</a></span><span class='o'>(</span>ticks <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>element_blank</a></span><span class='o'>(</span><span class='o'>)</span>, minor.ticks <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>element_line</a></span><span class='o'>(</span><span class='o'>)</span><span class='o'>)</span></span>
<span></span>
<span><span class='nv'>p1</span> <span class='o'>|</span> <span class='nv'>p2</span></span>
</code></pre>
<img src="figs/unnamed-chunk-18-1.png" width="700px" style="display: block; margin: auto;" />

</div>

Discrete position scales now also have access to secondary axes. In contrast to continuous scales, discrete scales don't support transformations. So instead of [`sec_axis()`](https://ggplot2.tidyverse.org/reference/sec_axis.html), it is recommended to use [`dup_axis()`](https://ggplot2.tidyverse.org/reference/sec_axis.html). To allow for arbitrary positions for `dup_axis(breaks)`, these can take numeric values or one of the discrete levels. They are not truly useful to for showing two aligned datasets of different scales, but they can serve as annotations. For example, they can display some summary statistics about the groups.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggplot.html'>ggplot</a></span><span class='o'>(</span><span class='nv'>mpg</span>, <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/aes.html'>aes</a></span><span class='o'>(</span><span class='nv'>class</span>, <span class='nv'>cty</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/geom_boxplot.html'>geom_boxplot</a></span><span class='o'>(</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/scale_discrete.html'>scale_x_discrete</a></span><span class='o'>(</span></span>
<span>    sec.axis <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/sec_axis.html'>dup_axis</a></span><span class='o'>(</span></span>
<span>      name <span class='o'>=</span> <span class='s'>"Counts"</span>,</span>
<span>      <span class='c'># You can use numeric input for breaks</span></span>
<span>      breaks <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/seq.html'>seq_len</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/length.html'>length</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/unique.html'>unique</a></span><span class='o'>(</span><span class='nv'>mpg</span><span class='o'>$</span><span class='nv'>class</span><span class='o'>)</span><span class='o'>)</span><span class='o'>)</span>,</span>
<span>      <span class='c'># Watch out for the order of `table()` and your levels!</span></span>
<span>      labels <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/paste.html'>paste0</a></span><span class='o'>(</span><span class='s'>"n = "</span>, <span class='nf'><a href='https://rdrr.io/r/base/table.html'>table</a></span><span class='o'>(</span><span class='nv'>mpg</span><span class='o'>$</span><span class='nv'>class</span><span class='o'>)</span><span class='o'>)</span></span>
<span>    <span class='o'>)</span></span>
<span>  <span class='o'>)</span></span>
</code></pre>
<img src="figs/unnamed-chunk-19-1.png" width="700px" style="display: block; margin: auto;" />

</div>

## Position aesthetics

Layers consist of three components: stats, geoms and positions. While stats and geoms have their own aesthetics, like `weight` or `linewidth`, the position adjustments did not. In this release, positions can also declare their own statistics. You can map data to these aesthetics like you would for geom or stat aesthetics.

In [`position_nudge()`](https://ggplot2.tidyverse.org/reference/position_nudge.html) for example, we now have the `nudge_x` and `nudge_y` parameters as aesthetics. [^2] Two benefits are that we can now use expressions in [`aes()`](https://ggplot2.tidyverse.org/reference/aes.html) to declare these and they are vectorised. We use that advantage in the plot below where we use [`sign()`](https://rdrr.io/r/base/sign.html) in a divergent bar chart to determine the left-right direction of the nudge.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='c'># Taken from:</span></span>
<span><span class='c'># https://ourworldindata.org/grapher/share-electricity-coal?tab=table&amp;tableFilter=continents</span></span>
<span><span class='nv'>coal</span> <span class='o'>&lt;-</span> <span class='nf'>tibble</span><span class='nf'>::</span><span class='nf'><a href='https://tibble.tidyverse.org/reference/tribble.html'>tribble</a></span><span class='o'>(</span></span>
<span>  <span class='o'>~</span><span class='nv'>continent</span>,  <span class='o'>~</span><span class='nv'>pct_1985</span>, <span class='o'>~</span><span class='nv'>pct_2024</span>,</span>
<span>  <span class='s'>"Africa"</span>,        <span class='m'>53.87</span>, <span class='m'>24.68</span>,</span>
<span>  <span class='s'>"Asia"</span>,          <span class='m'>32.60</span>, <span class='m'>51.19</span>,</span>
<span>  <span class='s'>"Europe"</span>,        <span class='m'>32.84</span>, <span class='m'>12.91</span>,</span>
<span>  <span class='s'>"North America"</span>, <span class='m'>48.93</span>, <span class='m'>13.79</span>,</span>
<span>  <span class='s'>"South America"</span>,  <span class='m'>2.91</span>,  <span class='m'>3.31</span>,</span>
<span>  <span class='s'>"Oceania"</span>,       <span class='m'>58.75</span>, <span class='m'>39.26</span></span>
<span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'>dplyr</span><span class='nf'>::</span><span class='nf'><a href='https://dplyr.tidyverse.org/reference/mutate.html'>mutate</a></span><span class='o'>(</span>pp_difference <span class='o'>=</span> <span class='nv'>pct_2024</span> <span class='o'>-</span> <span class='nv'>pct_1985</span><span class='o'>)</span></span>
<span></span>
<span><span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggplot.html'>ggplot</a></span><span class='o'>(</span><span class='nv'>coal</span>, <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/aes.html'>aes</a></span><span class='o'>(</span><span class='nv'>pp_difference</span>, <span class='nv'>continent</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/geom_bar.html'>geom_col</a></span><span class='o'>(</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/geom_text.html'>geom_text</a></span><span class='o'>(</span></span>
<span>    <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/aes.html'>aes</a></span><span class='o'>(</span>nudge_x <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/sign.html'>sign</a></span><span class='o'>(</span><span class='nv'>pp_difference</span><span class='o'>)</span> <span class='o'>*</span> <span class='m'>3</span>, </span>
<span>        label <span class='o'>=</span> <span class='nv'>pp_difference</span><span class='o'>)</span></span>
<span>  <span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/labs.html'>labs</a></span><span class='o'>(</span>x <span class='o'>=</span> <span class='s'>"Change in electricity generated by coal (pp)"</span><span class='o'>)</span></span>
</code></pre>
<img src="figs/unnamed-chunk-20-1.png" width="700px" style="display: block; margin: auto;" />

</div>

A second position adjustment that has gotten its own aesthetic is [`position_dodge()`](https://ggplot2.tidyverse.org/reference/position_dodge.html). In the plot below, we see for sports where we do not have records for both 'sex = "f"' and 'sex = "m"' only one box is drawn just beneath the centre line. This is true for 'water polo' where we have no records for 'f', but also netball and gymnastics where there are no records for 'm'. For sports where there are records for both sexes, the "f" is depicted beneath the centre line and "m" is depicted above the centre line. Depending on your aesthetic sensibilities, this inconsistency can be a major pain.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>sports</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"water polo"</span>, <span class='s'>"swimming"</span>, <span class='s'>"gymnastics"</span>, <span class='s'>"field"</span>, <span class='s'>"netball"</span><span class='o'>)</span></span>
<span><span class='nv'>p</span> <span class='o'>&lt;-</span> <span class='nf'>ggridges</span><span class='nf'>::</span><span class='nv'><a href='https://wilkelab.org/ggridges/reference/Aus_athletes.html'>Aus_athletes</a></span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'>dplyr</span><span class='nf'>::</span><span class='nf'><a href='https://dplyr.tidyverse.org/reference/filter.html'>filter</a></span><span class='o'>(</span><span class='nv'>sport</span> <span class='o'><a href='https://rdrr.io/r/base/match.html'>%in%</a></span> <span class='nv'>sports</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggplot.html'>ggplot</a></span><span class='o'>(</span><span class='nf'><a href='https://ggplot2.tidyverse.org/reference/aes.html'>aes</a></span><span class='o'>(</span><span class='nv'>height</span>, <span class='nv'>sport</span>, fill <span class='o'>=</span> <span class='nv'>sex</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/geom_boxplot.html'>geom_boxplot</a></span><span class='o'>(</span>position <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/position_dodge.html'>position_dodge</a></span><span class='o'>(</span>preserve <span class='o'>=</span> <span class='s'>"single"</span><span class='o'>)</span><span class='o'>)</span></span>
<span></span>
<span><span class='nv'>p</span></span>
</code></pre>
<img src="figs/unnamed-chunk-21-1.png" width="700px" style="display: block; margin: auto;" />

</div>

The origin of this inconsistency is that ggplot2 doesn't have an understanding of groups other than that *they exist*. It doesn't know that groups are formed by `fill` and what levels populate this aesthetic. To break ggplot2's ignorance, we now have the `order` aesthetic for [`position_dodge()`](https://ggplot2.tidyverse.org/reference/position_dodge.html).

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>p</span> <span class='o'>+</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/aes.html'>aes</a></span><span class='o'>(</span>order <span class='o'>=</span> <span class='nv'>sex</span><span class='o'>)</span></span>
</code></pre>
<img src="figs/unnamed-chunk-22-1.png" width="700px" style="display: block; margin: auto;" />

</div>

Using that aesthetic to the position adjustment soothes the soul by putting all the right groups in the right places.

## Facets

### Wrapping directions

The [`facet_wrap()`](https://ggplot2.tidyverse.org/reference/facet_wrap.html) function has had two arguments controlling the layout: `dir` which can be `"h"` or `"v"`, and `as.table` with can be `TRUE` or `FALSE`. Together, these gave a total of 4 layout options. Arguably there are 8 sensible options in total though, so we were missing out on the layout. To simplify having to juggle two arguments for 4 options, we're now just using one argument (`dir`) for 8 options. The new options are all two letter codes using combinations of `t` (top), `r` (right), `b` (bottom) and `l` (left). The combination will tell you where the first facet level will be. Both `br` and `rb` will start in the bottom-right with the first facet. Then the order will tell you about the filling direction, where starting with `b` will fill bottom-to-top and starting with `r` will fill right-to-left.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>p</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggplot.html'>ggplot</a></span><span class='o'>(</span><span class='nv'>mpg</span>, <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/aes.html'>aes</a></span><span class='o'>(</span><span class='nv'>displ</span>, <span class='nv'>hwy</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/geom_point.html'>geom_point</a></span><span class='o'>(</span><span class='o'>)</span></span>
<span></span>
<span><span class='nv'>p1</span> <span class='o'>&lt;-</span> <span class='nv'>p</span> <span class='o'>+</span> </span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/facet_wrap.html'>facet_wrap</a></span><span class='o'>(</span><span class='o'>~</span> <span class='nf'>vctrs</span><span class='nf'>::</span><span class='nf'><a href='https://vctrs.r-lib.org/reference/vec_group.html'>vec_group_id</a></span><span class='o'>(</span><span class='nv'>class</span><span class='o'>)</span>, dir <span class='o'>=</span> <span class='s'>"br"</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/labs.html'>labs</a></span><span class='o'>(</span>title <span class='o'>=</span> <span class='s'>"dir = 'br'"</span><span class='o'>)</span></span>
<span></span>
<span><span class='nv'>p2</span> <span class='o'>&lt;-</span> <span class='nv'>p</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/facet_wrap.html'>facet_wrap</a></span><span class='o'>(</span><span class='o'>~</span> <span class='nf'>vctrs</span><span class='nf'>::</span><span class='nf'><a href='https://vctrs.r-lib.org/reference/vec_group.html'>vec_group_id</a></span><span class='o'>(</span><span class='nv'>class</span><span class='o'>)</span>, dir <span class='o'>=</span> <span class='s'>"rb"</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/labs.html'>labs</a></span><span class='o'>(</span>title <span class='o'>=</span> <span class='s'>"dir = 'rb'"</span><span class='o'>)</span></span>
<span></span>
<span><span class='nv'>p1</span> <span class='o'>|</span> <span class='nv'>p2</span></span>
</code></pre>
<img src="figs/unnamed-chunk-23-1.png" width="700px" style="display: block; margin: auto;" />

</div>

To cover all 8 options, we list them here:

-   `"lt"`: start in the top-left, start filling left-to-right.
-   `"tl"`: start in the top-left, start filling top-to-bottom.
-   `"lb"`: start in the bottom-left, start filling left-to-right.
-   `"bl"`: start in the bottom-left, start filling bottom-to-top.
-   `"rt"`: start in the top-right, start filling right-to-left.
-   `"tr"`: start in the top-right, start filling top-to-bottom.
-   `"rb"`: start in the bottom-right, start filling right-to-left.
-   `"br"` start in the bottom-right, start filling bottom-to-top.

### Free space in wrapping

The `facet_grid(space)` argument can ensure that panels are allocated space in proportion to their data range. This works because all data within a row share a y-axis, and data within a column share an x-axis. Historically, this argument did not have an equivalent in [`facet_wrap()`](https://ggplot2.tidyverse.org/reference/facet_wrap.html) because axes aren't shared. We realised that there is a narrow circumstance in which each column has a consistent axis, and this is when there is only one row. The inverse also holds true for rows when there is only one column. In this release, we've added `facet_wrap(space)` that sets the panel sizes in these circumstances.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggplot.html'>ggplot</a></span><span class='o'>(</span><span class='nv'>penguins</span>, <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/aes.html'>aes</a></span><span class='o'>(</span><span class='nv'>bill_dep</span>, <span class='nv'>bill_len</span>, colour <span class='o'>=</span> <span class='nv'>species</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/geom_point.html'>geom_point</a></span><span class='o'>(</span>na.rm <span class='o'>=</span> <span class='kc'>TRUE</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/facet_wrap.html'>facet_wrap</a></span><span class='o'>(</span><span class='o'>~</span> <span class='nv'>island</span>, scales <span class='o'>=</span> <span class='s'>"free_x"</span>, space <span class='o'>=</span> <span class='s'>"free_x"</span><span class='o'>)</span></span>
</code></pre>
<img src="figs/unnamed-chunk-24-1.png" width="700px" style="display: block; margin: auto;" />

</div>

We can note that the Dream and Torgersen islands have a narrower panel because they don't have the Gentoo penguin with low bill depths.

### Layer layout

We've added the argument `layer(layout)`, which can be used to give instructions to facets on how to handle the data. Generally speaking, facets or custom layouts are free to interpret instructions as they see fit, so it is not set in stone. Nonetheless, we've come up with the following interpretations for [`facet_wrap()`](https://ggplot2.tidyverse.org/reference/facet_wrap.html) and [`facet_grid()`](https://ggplot2.tidyverse.org/reference/facet_grid.html).

-   `layout = NULL` (the default) uses the faceting variables to assign data to a panel.
-   `layout = "fixed"` repeats the data for every panel and ignores faceting variables.
-   `layout = <integer>` assigns to data to a specific panel.

In addition, specifically for [`facet_grid()`](https://ggplot2.tidyverse.org/reference/facet_grid.html) the following options also apply:

-   `layout = "fixed_cols"` pools data for every column and repeats it within the column's panels.
-   `layout = "fixed_rows"` pools data for every row and repeats it within the row's panels.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggplot.html'>ggplot</a></span><span class='o'>(</span><span class='nv'>penguins</span>, <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/aes.html'>aes</a></span><span class='o'>(</span><span class='nv'>bill_dep</span>, <span class='nv'>bill_len</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='c'># Repeat within every row</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/geom_point.html'>geom_point</a></span><span class='o'>(</span>na.rm <span class='o'>=</span> <span class='kc'>TRUE</span>, colour <span class='o'>=</span> <span class='s'>"grey"</span>, layout <span class='o'>=</span> <span class='s'>"fixed_rows"</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='c'># Use facetting variables (default)</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/geom_point.html'>geom_point</a></span><span class='o'>(</span>na.rm <span class='o'>=</span> <span class='kc'>TRUE</span>, layout <span class='o'>=</span> <span class='kc'>NULL</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='c'># Pick particular panel</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/annotate.html'>annotate</a></span><span class='o'>(</span></span>
<span>    <span class='s'>"text"</span>, x <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/AsIs.html'>I</a></span><span class='o'>(</span><span class='m'>0.5</span><span class='o'>)</span>, y <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/AsIs.html'>I</a></span><span class='o'>(</span><span class='m'>0.5</span><span class='o'>)</span>,</span>
<span>    label <span class='o'>=</span> <span class='s'>"Panel 6"</span>, layout <span class='o'>=</span> <span class='m'>6</span></span>
<span>  <span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/facet_grid.html'>facet_grid</a></span><span class='o'>(</span><span class='nv'>island</span> <span class='o'>~</span> <span class='nv'>species</span><span class='o'>)</span></span>
</code></pre>
<img src="figs/unnamed-chunk-25-1.png" width="700px" style="display: block; margin: auto;" />

</div>

In previous incarnations of ggplot2, people went through some acrobatics to get data to repeat across panels. With these new options, this should be a walk in the park.

## Styling updates

### Boxplots

In [`geom_boxplot()`](https://ggplot2.tidyverse.org/reference/geom_boxplot.html), you may have become accustomed to all the different options for styling outliers like `outlier.colour` or `outlier.shape`. Now, we're also enabling styling the different parts of the boxplot: the median line, the box, the whiskers and the staples. You can assign different colours, line type or line width to these parts of the boxplot.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggplot.html'>ggplot</a></span><span class='o'>(</span><span class='nv'>mpg</span>, <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/aes.html'>aes</a></span><span class='o'>(</span><span class='nv'>class</span>, <span class='nv'>hwy</span>, colour <span class='o'>=</span> <span class='nv'>class</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/geom_boxplot.html'>geom_boxplot</a></span><span class='o'>(</span></span>
<span>    whisker.linetype <span class='o'>=</span> <span class='s'>"dashed"</span>,</span>
<span>    box.colour <span class='o'>=</span> <span class='s'>"black"</span>,</span>
<span>    median.linewidth <span class='o'>=</span> <span class='m'>2</span>,</span>
<span>    staplewidth <span class='o'>=</span> <span class='m'>0.5</span>, <span class='c'># show staple</span></span>
<span>    staple.colour <span class='o'>=</span> <span class='s'>"grey50"</span></span>
<span>  <span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/guides.html'>guides</a></span><span class='o'>(</span>colour <span class='o'>=</span> <span class='s'>"none"</span><span class='o'>)</span></span>
</code></pre>
<img src="figs/unnamed-chunk-26-1.png" width="700px" style="display: block; margin: auto;" />

</div>

For consistency, [`geom_crossbar()`](https://ggplot2.tidyverse.org/reference/geom_linerange.html) has been given the same treatment, but uses the `middle.*` prefix where [`geom_boxplot()`](https://ggplot2.tidyverse.org/reference/geom_boxplot.html) uses the `median.*` prefix. Because `middle.linewidth` and `median.linewidth` have taken over the role of `fatten` and are aligned with other graphical properties, the `fatten` argument is now deprecated.

### Violin & quantiles

It has been an inconvenience for some time that the quantile computation in violin layers was computed on the density data rather than the input data. To make the quantile computation more faithful to the real data, we had to properly delegate the responsibilities to the correct parts of the layer. The stat part of the layer is now in charge of calculating quantiles of the input data via the `stat_ydensity(quantiles)` arguments. By default, the quantiles are the 25th, 50th and 75th percentiles and are always computed. Whether these quantiles are also displayed, is under the purview of the geom part of the layer. We've taken a similar approach as boxplots shown above, in that we now have `quantile.colour`, `quantile.linetype` and `quantile.linewidth` arguments to style the quantile lines. Previously, quantiles were not displayed by default. To mirror that behaviour, we've set `quantile.linetype = 0` (blank, no line) by default. This means that to turn on the display of quantiles, you have to set a non-blank line type.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggplot.html'>ggplot</a></span><span class='o'>(</span><span class='nv'>mpg</span>, <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/aes.html'>aes</a></span><span class='o'>(</span><span class='nv'>class</span>, <span class='nv'>hwy</span>, fill <span class='o'>=</span> <span class='nv'>class</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/geom_violin.html'>geom_violin</a></span><span class='o'>(</span></span>
<span>    quantiles <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='m'>0.1</span>, <span class='m'>0.9</span><span class='o'>)</span>,</span>
<span>    quantile.linetype <span class='o'>=</span> <span class='m'>1</span></span>
<span>  <span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/guides.html'>guides</a></span><span class='o'>(</span>fill <span class='o'>=</span> <span class='s'>"none"</span><span class='o'>)</span></span>
</code></pre>
<img src="figs/unnamed-chunk-27-1.png" width="700px" style="display: block; margin: auto;" />

</div>

### Labels

[`geom_label()`](https://ggplot2.tidyverse.org/reference/geom_text.html) also has new styling options. It now has a `linetype` and `linewidth` aesthetic, which can be mapped from the data. The `linewidth` aesthetic replaces the `label.size` argument, which used to determine the line width of the label border. In addition to the new aesthetics, [`geom_label()`](https://ggplot2.tidyverse.org/reference/geom_text.html) has two new arguments: `border.colour` and `text.colour` which set the colour for the border and text respectively. When these are set, it overrules the `colour` aesthetic for a part of the label. In the plot below, we fix the `text.colour` to black, so the `colour` aesthetic applies to the border, not the text.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggplot.html'>ggplot</a></span><span class='o'>(</span><span class='nv'>mtcars</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/aes.html'>aes</a></span><span class='o'>(</span></span>
<span>    <span class='nv'>wt</span>, <span class='nv'>mpg</span>,</span>
<span>    label <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/colnames.html'>rownames</a></span><span class='o'>(</span><span class='nv'>mtcars</span><span class='o'>)</span>,</span>
<span>    colour <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/factor.html'>factor</a></span><span class='o'>(</span><span class='nv'>cyl</span><span class='o'>)</span>,</span>
<span>    linetype <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/factor.html'>factor</a></span><span class='o'>(</span><span class='nv'>vs</span><span class='o'>)</span>,</span>
<span>    linewidth <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/factor.html'>factor</a></span><span class='o'>(</span><span class='nv'>am</span><span class='o'>)</span></span>
<span>  <span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/geom_text.html'>geom_label</a></span><span class='o'>(</span>text.colour <span class='o'>=</span> <span class='s'>"black"</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/scale_manual.html'>scale_linewidth_manual</a></span><span class='o'>(</span>values <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='m'>0.3</span>, <span class='m'>0.6</span><span class='o'>)</span><span class='o'>)</span></span>
</code></pre>
<img src="figs/unnamed-chunk-28-1.png" width="700px" style="display: block; margin: auto;" />

</div>

### Area and ribbons

Both [`geom_area()`](https://ggplot2.tidyverse.org/reference/geom_ribbon.html) and [`geom_ribbon()`](https://ggplot2.tidyverse.org/reference/geom_ribbon.html) now allow a varying `fill` aesthetic within a group. Such a fill is displayed as a gradient, and therefore requires R 4.1.0+ and a compatible graphics device.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggplot.html'>ggplot</a></span><span class='o'>(</span><span class='nv'>economics</span>, <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/aes.html'>aes</a></span><span class='o'>(</span><span class='nv'>date</span>, <span class='nv'>unemploy</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/geom_ribbon.html'>geom_area</a></span><span class='o'>(</span><span class='nf'><a href='https://ggplot2.tidyverse.org/reference/aes.html'>aes</a></span><span class='o'>(</span>fill <span class='o'>=</span> <span class='nv'>uempmed</span><span class='o'>)</span><span class='o'>)</span></span>
</code></pre>
<img src="figs/unnamed-chunk-29-1.png" width="700px" style="display: block; margin: auto;" />

</div>

## New stats

### Manual

Many ggplot extensions are based on stats, which allows you to perform arbitrary computations on data before handing it off the drawing functions. The new [`stat_manual()`](https://ggplot2.tidyverse.org/reference/stat_manual.html) aims to give you the same extension powers, but without doing the formal ritual of defining a class and constructor. You can provide it any function that both ingests and returns a data frame. It can create new aesthetics or modify pre-existing aesthetics as long as eventually the geom part of the layer has their required aesthetics. In the example below, we use [`stat_manual()`](https://ggplot2.tidyverse.org/reference/stat_manual.html) with a geom and a function, but also show you how to use a geom with `stat = "manual"`.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>make_centroids</span> <span class='o'>&lt;-</span> <span class='kr'>function</span><span class='o'>(</span><span class='nv'>df</span><span class='o'>)</span> <span class='o'>&#123;</span></span>
<span>  <span class='nf'><a href='https://rdrr.io/r/base/transform.html'>transform</a></span><span class='o'>(</span></span>
<span>    <span class='nv'>df</span>,</span>
<span>    xend <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/mean.html'>mean</a></span><span class='o'>(</span><span class='nv'>x</span>, na.rm <span class='o'>=</span> <span class='kc'>TRUE</span><span class='o'>)</span>,</span>
<span>    yend <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/mean.html'>mean</a></span><span class='o'>(</span><span class='nv'>y</span>, na.rm <span class='o'>=</span> <span class='kc'>TRUE</span><span class='o'>)</span></span>
<span>  <span class='o'>)</span></span>
<span><span class='o'>&#125;</span></span>
<span></span>
<span><span class='nv'>make_hull</span> <span class='o'>&lt;-</span> <span class='kr'>function</span><span class='o'>(</span><span class='nv'>df</span><span class='o'>)</span> <span class='o'>&#123;</span></span>
<span>  <span class='nv'>df</span> <span class='o'>&lt;-</span> <span class='nv'>df</span><span class='o'>[</span><span class='nf'><a href='https://rdrr.io/r/stats/complete.cases.html'>complete.cases</a></span><span class='o'>(</span><span class='nv'>df</span><span class='o'>)</span>, , drop <span class='o'>=</span> <span class='kc'>FALSE</span><span class='o'>]</span></span>
<span>  <span class='nv'>hull</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/grDevices/chull.html'>chull</a></span><span class='o'>(</span><span class='nv'>df</span><span class='o'>$</span><span class='nv'>x</span>, <span class='nv'>df</span><span class='o'>$</span><span class='nv'>y</span><span class='o'>)</span></span>
<span>  <span class='nv'>df</span><span class='o'>[</span><span class='nv'>hull</span>, , drop <span class='o'>=</span> <span class='kc'>FALSE</span><span class='o'>]</span></span>
<span><span class='o'>&#125;</span></span>
<span></span>
<span><span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggplot.html'>ggplot</a></span><span class='o'>(</span><span class='nv'>penguins</span>, <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/aes.html'>aes</a></span><span class='o'>(</span><span class='nv'>bill_len</span>, <span class='nv'>bill_dep</span>, colour <span class='o'>=</span> <span class='nv'>species</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>+</span> </span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/geom_point.html'>geom_point</a></span><span class='o'>(</span>na.rm <span class='o'>=</span> <span class='kc'>TRUE</span><span class='o'>)</span> <span class='o'>+</span> </span>
<span>  <span class='c'># As a stat, provide a geom</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/stat_manual.html'>stat_manual</a></span><span class='o'>(</span></span>
<span>    geom <span class='o'>=</span> <span class='s'>"segment"</span>, <span class='c'># function creates new xend/yend for segment</span></span>
<span>    fun <span class='o'>=</span> <span class='nv'>make_centroids</span>,</span>
<span>    linewidth <span class='o'>=</span> <span class='m'>0.2</span>,</span>
<span>    na.rm <span class='o'>=</span> <span class='kc'>TRUE</span></span>
<span>  <span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='c'># As a geom, provide the stat</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/geom_polygon.html'>geom_polygon</a></span><span class='o'>(</span></span>
<span>    stat <span class='o'>=</span> <span class='s'>"manual"</span>,</span>
<span>    fun <span class='o'>=</span> <span class='nv'>make_hull</span>,</span>
<span>    fill <span class='o'>=</span> <span class='kc'>NA</span>,</span>
<span>    linetype <span class='o'>=</span> <span class='s'>"dotted"</span></span>
<span>  <span class='o'>)</span></span>
</code></pre>
<img src="figs/unnamed-chunk-30-1.png" width="700px" style="display: block; margin: auto;" />

</div>

### Connection

It has come to our attention that generalisations of [`geom_step()`](https://ggplot2.tidyverse.org/reference/geom_path.html) have become commonplace in several extensions. Stairstep ribbons are used in Kaplan-Meier curves to indicate uncertainty. Stairstep area plots make for some great histograms. To this end, we're introducing [`stat_connect()`](https://ggplot2.tidyverse.org/reference/stat_connect.html), which can connect observations in a stairstep fashion without constraining a geom choice. In the plot, you can see it work on the `y`, `ymin` and `ymax` aesthetics indiscriminately with distinct geoms.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>eco</span> <span class='o'>&lt;-</span> <span class='nv'>economics</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'>dplyr</span><span class='nf'>::</span><span class='nf'><a href='https://dplyr.tidyverse.org/reference/mutate.html'>mutate</a></span><span class='o'>(</span>year <span class='o'>=</span> <span class='nf'>lubridate</span><span class='nf'>::</span><span class='nf'><a href='https://lubridate.tidyverse.org/reference/year.html'>year</a></span><span class='o'>(</span><span class='nv'>date</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'>dplyr</span><span class='nf'>::</span><span class='nf'><a href='https://dplyr.tidyverse.org/reference/summarise.html'>summarise</a></span><span class='o'>(</span></span>
<span>    min <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/Extremes.html'>min</a></span><span class='o'>(</span><span class='nv'>unemploy</span><span class='o'>)</span>,</span>
<span>    max <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/Extremes.html'>max</a></span><span class='o'>(</span><span class='nv'>unemploy</span><span class='o'>)</span>,</span>
<span>    mid <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/stats/median.html'>median</a></span><span class='o'>(</span><span class='nv'>unemploy</span><span class='o'>)</span>,</span>
<span>    .by <span class='o'>=</span> <span class='nv'>year</span></span>
<span>  <span class='o'>)</span></span>
<span></span>
<span><span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggplot.html'>ggplot</a></span><span class='o'>(</span><span class='nv'>eco</span>, <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/aes.html'>aes</a></span><span class='o'>(</span><span class='nv'>year</span>, y <span class='o'>=</span> <span class='nv'>mid</span>, ymin <span class='o'>=</span> <span class='nv'>min</span>, ymax <span class='o'>=</span> <span class='nv'>max</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/geom_path.html'>geom_line</a></span><span class='o'>(</span>stat <span class='o'>=</span> <span class='s'>"connect"</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/geom_ribbon.html'>geom_ribbon</a></span><span class='o'>(</span>stat <span class='o'>=</span> <span class='s'>"connect"</span>, alpha <span class='o'>=</span> <span class='m'>0.4</span><span class='o'>)</span></span>
</code></pre>
<img src="figs/unnamed-chunk-31-1.png" width="700px" style="display: block; margin: auto;" />

</div>

However, we aren't necessarily limited to stairstep connections. We can use a 2-column numeric matrix to sketch out other types of connections. For example if we use [`plogis()`](https://rdrr.io/r/stats/Logistic.html) to create a logistic transition, we can make 'bump chart'-like connections. Or you can use a zigzag pattern if silliness is your cup of tea.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>x</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/seq.html'>seq</a></span><span class='o'>(</span><span class='m'>0</span>, <span class='m'>1</span>, length.out <span class='o'>=</span> <span class='m'>20</span><span class='o'>)</span><span class='o'>[</span><span class='o'>-</span><span class='m'>1</span><span class='o'>]</span></span>
<span><span class='nv'>smooth</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/cbind.html'>cbind</a></span><span class='o'>(</span><span class='nv'>x</span>, <span class='nf'>scales</span><span class='nf'>::</span><span class='nf'><a href='https://scales.r-lib.org/reference/rescale.html'>rescale</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/stats/Logistic.html'>plogis</a></span><span class='o'>(</span><span class='nv'>x</span>, location <span class='o'>=</span> <span class='m'>0.5</span>, scale <span class='o'>=</span> <span class='m'>0.1</span><span class='o'>)</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='nv'>zigzag</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/cbind.html'>cbind</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='m'>0.4</span>, <span class='m'>0.6</span>, <span class='m'>1</span><span class='o'>)</span>, <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='m'>0.75</span>, <span class='m'>0.25</span>, <span class='m'>1</span><span class='o'>)</span><span class='o'>)</span></span>
<span></span>
<span><span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggplot.html'>ggplot</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/utils/head.html'>head</a></span><span class='o'>(</span><span class='nv'>eco</span>, <span class='m'>10</span><span class='o'>)</span>, <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/aes.html'>aes</a></span><span class='o'>(</span><span class='nv'>year</span>, y <span class='o'>=</span> <span class='nv'>mid</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/geom_point.html'>geom_point</a></span><span class='o'>(</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/stat_connect.html'>stat_connect</a></span><span class='o'>(</span><span class='nf'><a href='https://ggplot2.tidyverse.org/reference/aes.html'>aes</a></span><span class='o'>(</span>colour <span class='o'>=</span> <span class='s'>"smooth"</span><span class='o'>)</span>, connection <span class='o'>=</span> <span class='nv'>smooth</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/stat_connect.html'>stat_connect</a></span><span class='o'>(</span><span class='nf'><a href='https://ggplot2.tidyverse.org/reference/aes.html'>aes</a></span><span class='o'>(</span>colour <span class='o'>=</span> <span class='s'>"zigzag"</span><span class='o'>)</span>, connection <span class='o'>=</span> <span class='nv'>zigzag</span><span class='o'>)</span></span>
</code></pre>
<img src="figs/unnamed-chunk-32-1.png" width="700px" style="display: block; margin: auto;" />

</div>

## Coord reversal

It has been possible to use reverse transformations for scales to flip a plot direction. You could even use [`scales::transform_compose()`](https://scales.r-lib.org/reference/transform_compose.html) to do, for example, a reversed log<sub>10</sub> transformation to highlight the smallest p-values. However, the transformation approach has a few limitations, notably that discrete scales do not support transformations and not all coords obeyed transformed scales. You can't really combine `coord_sf() + scale_x_log10()` for example. To remedy this limitation, coords now have a `reverse` argument that can typically be `"none"`, `"x"`, `"y"` or `"xy"` that reverse some directions. If you are from the lands down under, you can now plot a map in your native orientation.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>world</span> <span class='o'>&lt;-</span> <span class='nf'>sf</span><span class='nf'>::</span><span class='nf'><a href='https://r-spatial.github.io/sf/reference/st_as_sf.html'>st_as_sf</a></span><span class='o'>(</span><span class='nf'>maps</span><span class='nf'>::</span><span class='nf'><a href='https://rdrr.io/pkg/maps/man/map.html'>map</a></span><span class='o'>(</span><span class='s'>'world'</span>, plot <span class='o'>=</span> <span class='kc'>FALSE</span>, fill <span class='o'>=</span> <span class='kc'>TRUE</span><span class='o'>)</span><span class='o'>)</span></span>
<span></span>
<span><span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggplot.html'>ggplot</a></span><span class='o'>(</span><span class='nv'>world</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggsf.html'>geom_sf</a></span><span class='o'>(</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggsf.html'>coord_sf</a></span><span class='o'>(</span>reverse <span class='o'>=</span> <span class='s'>"y"</span><span class='o'>)</span></span>
</code></pre>
<img src="figs/unnamed-chunk-33-1.png" width="700px" style="display: block; margin: auto;" />

</div>

In [`coord_radial()`](https://ggplot2.tidyverse.org/reference/coord_radial.html), the `reverse` argument replaces the `direction` argument that only worked for the theta-direction. Contrary to many coords, `coord_radial(reverse)` takes `"none"`, `"theta"`, `"r"` and `"thetar"` instead of the x/y directions.

## Goodies for extensions

### Layers

If you've ever written a `Geom` class, chances are that you've danced with [`grid::gpar()`](https://rdrr.io/r/grid/gpar.html) and frowned at the use of `.pt` and `.stroke` and whatnot. We've made a wrapper for [`grid::gpar()`](https://rdrr.io/r/grid/gpar.html) that applies the ggplot2 interpretation of settings and translates them to grid settings. For example, `linewidth` (or the `lwd` grid setting) is interpreted in millimetres in ggplot2, whereas grid expects them in points. The [`gg_par()`](https://ggplot2.tidyverse.org/reference/gg_par.html) function helps these translations, protects against `NA`s in line types and strokes, removes 0-length vectors, and has additional logic for point strokes.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://ggplot2.tidyverse.org/reference/gg_par.html'>gg_par</a></span><span class='o'>(</span>lwd <span class='o'>=</span> <span class='m'>5</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; $lwd</span></span>
<span><span class='c'>#&gt; [1] 14.22638</span></span>
<span></span><span><span class='nf'>grid</span><span class='nf'>::</span><span class='nf'><a href='https://rdrr.io/r/grid/grid.convert.html'>convertUnit</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/grid/unit.html'>unit</a></span><span class='o'>(</span><span class='m'>5</span>, <span class='s'>"mm"</span><span class='o'>)</span>, <span class='s'>"pt"</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; [1] 14.2263779527559points</span></span>
<span></span></code></pre>

</div>

For geom and stat extensions, the magic usually happens in the `Geom*` or `Stat*` classes and the constructor is simply boilerplate code used to populate a layer. To reduce the amount of boilerplate code, you can now use [`make_constructor()`](https://ggplot2.tidyverse.org/reference/make_constructor.html) on `Geom*` and `Stat*` classes. It produces a typical constructor function that adheres to several conventions, like exposing arguments to compute/drawing methods. To illustrate, notice how the following constructor for `GeomPath` includes arguments for `lineend` and `linejoin` automatically because they are arguments to the `GeomPath$draw_panel()` method.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>geom_foo</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/make_constructor.html'>make_constructor</a></span><span class='o'>(</span><span class='nv'>GeomPath</span>, position <span class='o'>=</span> <span class='s'>"stack"</span><span class='o'>)</span></span>
<span><span class='nf'><a href='https://rdrr.io/r/base/print.html'>print</a></span><span class='o'>(</span><span class='nv'>geom_foo</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; function (mapping = NULL, data = NULL, stat = "identity", position = "stack", </span></span>
<span><span class='c'>#&gt;     ..., arrow = NULL, arrow.fill = NULL, lineend = "butt", linejoin = "round", </span></span>
<span><span class='c'>#&gt;     linemitre = 10, na.rm = FALSE, show.legend = NA, inherit.aes = TRUE) </span></span>
<span><span class='c'>#&gt; &#123;</span></span>
<span><span class='c'>#&gt;     layer(mapping = mapping, data = data, geom = "path", stat = stat, </span></span>
<span><span class='c'>#&gt;         position = position, show.legend = show.legend, inherit.aes = inherit.aes, </span></span>
<span><span class='c'>#&gt;         params = list2(na.rm = na.rm, arrow = arrow, arrow.fill = arrow.fill, </span></span>
<span><span class='c'>#&gt;             lineend = lineend, linejoin = linejoin, linemitre = linemitre, </span></span>
<span><span class='c'>#&gt;             ...))</span></span>
<span><span class='c'>#&gt; &#125;</span></span>
<span><span class='c'>#&gt; &lt;environment: 0x000001fd14e4a118&gt;</span></span>
<span></span></code></pre>

</div>

In addition, you can now also use the `#' @aesthetics <Geom/Stat/Position>` roxygen tag to automatically populate an 'Aesthetics' section of your documentation. The code below;

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>GeomDummy</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggproto.html'>ggproto</a></span><span class='o'>(</span><span class='s'>"GeomDummy"</span>, <span class='nv'>Geom</span>, default_aes <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/aes.html'>aes</a></span><span class='o'>(</span>foo <span class='o'>=</span> <span class='s'>"bar"</span><span class='o'>)</span><span class='o'>)</span></span>
<span></span>
<span><span class='c'>#' &lt;rest of roxygen comments&gt;</span></span>
<span><span class='c'>#' @aesthetics GeomDummy</span></span>
<span><span class='nv'>geom_foo</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/make_constructor.html'>make_constructor</a></span><span class='o'>(</span><span class='nv'>GeomDummy</span><span class='o'>)</span></span></code></pre>

</div>

will generate the following .Rd code:

    \section{Aesthetics}{

    \code{geom_dummy()} understands the following aesthetics. Required aesthetics are displayed in bold and defaults are displayed for optional aesthetics:
    \tabular{rll}{
     • \tab \code{foo} \tab → \code{"bar"} \cr
     • \tab \code{\link[ggplot2:aes_group_order]{group}} \tab → inferred \cr
    }

    Learn more about setting these aesthetics in \code{vignette("ggplot2-specs")}.
    }

### Themes

To replicate how themes are handled internally, you can now use [`complete_theme()`](https://ggplot2.tidyverse.org/reference/complete_theme.html). It fills in all missing elements and performs typical checks.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>my_theme</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/theme.html'>theme</a></span><span class='o'>(</span>plot.background <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>element_rect</a></span><span class='o'>(</span>fill <span class='o'>=</span> <span class='kc'>NA</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='nf'><a href='https://rdrr.io/r/base/length.html'>length</a></span><span class='o'>(</span><span class='nv'>my_theme</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; [1] 1</span></span>
<span></span><span></span>
<span><span class='nv'>completed</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/complete_theme.html'>complete_theme</a></span><span class='o'>(</span><span class='nv'>my_theme</span><span class='o'>)</span></span>
<span><span class='nf'><a href='https://rdrr.io/r/base/length.html'>length</a></span><span class='o'>(</span><span class='nv'>completed</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; [1] 144</span></span>
<span></span><span></span>
<span><span class='c'># You should give rect elements to text settings</span></span>
<span><span class='nv'>completed</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/theme.html'>theme</a></span><span class='o'>(</span>legend.text <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>element_rect</a></span><span class='o'>(</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/complete_theme.html'>complete_theme</a></span><span class='o'>(</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #BBBB00; font-weight: bold;'>Error</span><span style='font-weight: bold;'> in `plot_theme()` at ggplot2/R/theme.R:649:3:</span></span></span>
<span><span class='c'>#&gt; <span style='color: #BBBB00;'>!</span> Can't merge the `legend.text` theme element.</span></span>
<span><span class='c'>#&gt; <span style='font-weight: bold;'>Caused by error in `method(merge_element, list(ggplot2::element, class_any))`:</span></span></span>
<span><span class='c'>#&gt; <span style='color: #BBBB00;'>!</span> Only elements of the same class can be merged.</span></span>
<span></span><span></span>
<span><span class='c'># Unknown elements</span></span>
<span><span class='nv'>completed</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/theme.html'>theme</a></span><span class='o'>(</span>foobar <span class='o'>=</span> <span class='m'>12</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/complete_theme.html'>complete_theme</a></span><span class='o'>(</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; Warning in plot_theme(list(theme = theme), default = default): The `foobar` theme element is not defined in the element hierarchy.</span></span>
<span></span></code></pre>

</div>

We're also introducing point and polygon theme elements. These aren't used in any of the base ggplot2 theme settings, but you can use them in extensions. The example below demonstrates registering new theme settings and that points and polygons follow inheritance and can be rendered.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='c'># Let's say your package 'my_pkg' registers custom point/polygon elements</span></span>
<span><span class='nf'><a href='https://ggplot2.tidyverse.org/reference/register_theme_elements.html'>register_theme_elements</a></span><span class='o'>(</span></span>
<span>  my_pkg_point <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>element_point</a></span><span class='o'>(</span>colour <span class='o'>=</span> <span class='s'>"red"</span><span class='o'>)</span>,</span>
<span>  my_pkg_polygon <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>element_polygon</a></span><span class='o'>(</span>fill <span class='o'>=</span> <span class='kc'>NA</span><span class='o'>)</span>,</span>
<span>  element_tree <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span></span>
<span>    my_pkg_point <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/register_theme_elements.html'>el_def</a></span><span class='o'>(</span><span class='nv'>element_point</span>, inherit <span class='o'>=</span> <span class='s'>"point"</span><span class='o'>)</span>,</span>
<span>    my_pkg_polygon <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/register_theme_elements.html'>el_def</a></span><span class='o'>(</span><span class='nv'>element_polygon</span>, inherit <span class='o'>=</span> <span class='s'>"polygon"</span><span class='o'>)</span></span>
<span>  <span class='o'>)</span></span>
<span><span class='o'>)</span></span>
<span></span>
<span><span class='c'># Which should inherit from the root point/polygon theme elements</span></span>
<span><span class='nv'>my_theme</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/theme.html'>theme</a></span><span class='o'>(</span></span>
<span>  point <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>element_point</a></span><span class='o'>(</span>shape <span class='o'>=</span> <span class='m'>17</span><span class='o'>)</span>,</span>
<span>  polygon <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>element_polygon</a></span><span class='o'>(</span>linetype <span class='o'>=</span> <span class='s'>"dotted"</span><span class='o'>)</span></span>
<span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/complete_theme.html'>complete_theme</a></span><span class='o'>(</span><span class='o'>)</span></span>
<span></span>
<span><span class='c'># Rendering your elements</span></span>
<span><span class='nv'>pts</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/calc_element.html'>calc_element</a></span><span class='o'>(</span><span class='s'>"my_pkg_point"</span>, <span class='nv'>my_theme</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element_grob.html'>element_grob</a></span><span class='o'>(</span></span>
<span>    x <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='m'>0.2</span>, <span class='m'>0.5</span>, <span class='m'>0.8</span><span class='o'>)</span>,</span>
<span>    y <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='m'>0.8</span>, <span class='m'>0.2</span>, <span class='m'>0.5</span><span class='o'>)</span></span>
<span>  <span class='o'>)</span></span>
<span><span class='nv'>poly</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/calc_element.html'>calc_element</a></span><span class='o'>(</span><span class='s'>"my_pkg_polygon"</span>, <span class='nv'>my_theme</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element_grob.html'>element_grob</a></span><span class='o'>(</span></span>
<span>    x <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='m'>0.1</span>, <span class='m'>0.5</span>, <span class='m'>0.9</span><span class='o'>)</span>,</span>
<span>    y <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='m'>0.9</span>, <span class='m'>0.1</span>, <span class='m'>0.5</span><span class='o'>)</span></span>
<span>  <span class='o'>)</span></span>
<span></span>
<span><span class='c'># Drawing the elements</span></span>
<span><span class='nf'>grid</span><span class='nf'>::</span><span class='nf'><a href='https://rdrr.io/r/grid/grid.newpage.html'>grid.newpage</a></span><span class='o'>(</span><span class='o'>)</span></span>
<span><span class='nf'>grid</span><span class='nf'>::</span><span class='nf'><a href='https://rdrr.io/r/grid/grid.draw.html'>grid.draw</a></span><span class='o'>(</span><span class='nv'>pts</span><span class='o'>)</span></span>
<span><span class='nf'>grid</span><span class='nf'>::</span><span class='nf'><a href='https://rdrr.io/r/grid/grid.draw.html'>grid.draw</a></span><span class='o'>(</span><span class='nv'>poly</span><span class='o'>)</span></span>
</code></pre>
<img src="figs/unnamed-chunk-38-1.png" width="700px" style="display: block; margin: auto;" />

</div>

## Acknowledgements

Thank you to all the people who contributed their issues, code and comments to this release: [@83221n4ndr34](https://github.com/83221n4ndr34), [@Abiologist](https://github.com/Abiologist), [@acebulsk](https://github.com/acebulsk), [@adisarid](https://github.com/adisarid), [@agila5](https://github.com/agila5), [@agmurray](https://github.com/agmurray), [@agneeshbarua](https://github.com/agneeshbarua), [@aijordan](https://github.com/aijordan), [@amarjitsinghchandhial](https://github.com/amarjitsinghchandhial), [@amkilpatrick](https://github.com/amkilpatrick), [@amongoodtx](https://github.com/amongoodtx), [@Andtise](https://github.com/Andtise), [@andybeet](https://github.com/andybeet), [@antoine4ucsd](https://github.com/antoine4ucsd), [@aphalo](https://github.com/aphalo), [@aravind-j](https://github.com/aravind-j), [@arcresu](https://github.com/arcresu), [@arnaudgallou](https://github.com/arnaudgallou), [@assaron](https://github.com/assaron), [@baderstine](https://github.com/baderstine), [@BajczA475](https://github.com/BajczA475), [@bakaburg1](https://github.com/bakaburg1), [@BegoniaCampos](https://github.com/BegoniaCampos), [@benjaminhlina](https://github.com/benjaminhlina), [@billdenney](https://github.com/billdenney), [@binkleym](https://github.com/binkleym), [@bkohrn](https://github.com/bkohrn), [@bnprks](https://github.com/bnprks), [@botanize](https://github.com/botanize), [@Breeze-Hu](https://github.com/Breeze-Hu), [@brianmsm](https://github.com/brianmsm), [@brunomioto](https://github.com/brunomioto), [@btupper](https://github.com/btupper), [@bwu62](https://github.com/bwu62), [@carljpearson](https://github.com/carljpearson), [@catalamarti](https://github.com/catalamarti), [@cbrnr](https://github.com/cbrnr), [@ccani007](https://github.com/ccani007), [@ccsarapas](https://github.com/ccsarapas), [@cgoo4](https://github.com/cgoo4), [@clauswilke](https://github.com/clauswilke), [@Close-your-eyes](https://github.com/Close-your-eyes), [@collinberke](https://github.com/collinberke), [@const-ae](https://github.com/const-ae), [@dafxy](https://github.com/dafxy), [@DanChaltiel](https://github.com/DanChaltiel), [@danli349](https://github.com/danli349), [@dansmith01](https://github.com/dansmith01), [@daorui](https://github.com/daorui), [@david-romano](https://github.com/david-romano), [@davidhodge931](https://github.com/davidhodge931), [@dinosquash](https://github.com/dinosquash), [@dominicroye](https://github.com/dominicroye), [@dsconnell](https://github.com/dsconnell), [@EA-Ammar](https://github.com/EA-Ammar), [@EBukin](https://github.com/EBukin), [@elgabbas](https://github.com/elgabbas), [@eliocamp](https://github.com/eliocamp), [@elipousson](https://github.com/elipousson), [@erinnacland](https://github.com/erinnacland), [@etiennebacher](https://github.com/etiennebacher), [@EvaMaeRey](https://github.com/EvaMaeRey), [@evanmascitti](https://github.com/evanmascitti), [@eyayaw](https://github.com/eyayaw), [@fabian-s](https://github.com/fabian-s), [@fkohrt](https://github.com/fkohrt), [@FloLecorvaisier](https://github.com/FloLecorvaisier), [@fmarotta](https://github.com/fmarotta), [@Fugwaaaa](https://github.com/Fugwaaaa), [@fwunschel](https://github.com/fwunschel), [@g-pacheco](https://github.com/g-pacheco), [@gaborcsardi](https://github.com/gaborcsardi), [@gregorp](https://github.com/gregorp), [@guqicun](https://github.com/guqicun), [@hadley](https://github.com/hadley), [@heinonmatti](https://github.com/heinonmatti), [@heor-robyoung](https://github.com/heor-robyoung), [@herry23xet](https://github.com/herry23xet), [@HMU-WH](https://github.com/HMU-WH), [@HRodenhizer](https://github.com/HRodenhizer), [@hsiaoyi0504](https://github.com/hsiaoyi0504), [@Hy4m](https://github.com/Hy4m), [@IndrajeetPatil](https://github.com/IndrajeetPatil), [@jack-davison](https://github.com/jack-davison), [@JacobBumgarner](https://github.com/JacobBumgarner), [@JakubKomarek](https://github.com/JakubKomarek), [@jansim](https://github.com/jansim), [@japhir](https://github.com/japhir), [@jbengler](https://github.com/jbengler), [@jdonland](https://github.com/jdonland), [@jeraldnoble](https://github.com/jeraldnoble), [@Jigyasu4indp](https://github.com/Jigyasu4indp), [@jiw181](https://github.com/jiw181), [@jmbuhr](https://github.com/jmbuhr), [@JMeyer31](https://github.com/JMeyer31), [@jmgirard](https://github.com/jmgirard), [@jnolis](https://github.com/jnolis), [@joaopedrosusselbertogna](https://github.com/joaopedrosusselbertogna), [@johow](https://github.com/johow), [@jonocarroll](https://github.com/jonocarroll), [@jpquast](https://github.com/jpquast), [@JStorey42](https://github.com/JStorey42), [@JThomasWatson](https://github.com/JThomasWatson), [@julianbarg](https://github.com/julianbarg), [@julou](https://github.com/julou), [@junjunlab](https://github.com/junjunlab), [@JWiley](https://github.com/JWiley), [@kauedesousa](https://github.com/kauedesousa), [@kdarras](https://github.com/kdarras), [@kevinushey](https://github.com/kevinushey), [@kevinwolz](https://github.com/kevinwolz), [@kieran-mace](https://github.com/kieran-mace), [@kkellysci](https://github.com/kkellysci), [@kobetst](https://github.com/kobetst), [@koheiw](https://github.com/koheiw), [@krlmlr](https://github.com/krlmlr), [@KryeKuzhinieri](https://github.com/KryeKuzhinieri), [@kylebutts](https://github.com/kylebutts), [@laurabrianna](https://github.com/laurabrianna), [@lbenz730](https://github.com/lbenz730), [@lcpmgh](https://github.com/lcpmgh), [@lgaborini](https://github.com/lgaborini), [@lgibson7](https://github.com/lgibson7), [@LGraz](https://github.com/LGraz), [@llrs](https://github.com/llrs), [@louis-heraut](https://github.com/louis-heraut), [@ltierney](https://github.com/ltierney), [@Lucielclr](https://github.com/Lucielclr), [@luhann](https://github.com/luhann), [@m-muecke](https://github.com/m-muecke), [@marcelglueck](https://github.com/marcelglueck), [@margaret-colville](https://github.com/margaret-colville), [@markus-schaffer](https://github.com/markus-schaffer), [@Maschette](https://github.com/Maschette), [@MathiasAmbuehl](https://github.com/MathiasAmbuehl), [@MathieuYeche](https://github.com/MathieuYeche), [@mattansb](https://github.com/mattansb), [@MauricioCely](https://github.com/MauricioCely), [@MaxAtoms](https://github.com/MaxAtoms), [@mcol](https://github.com/mcol), [@mfoos](https://github.com/mfoos), [@MichaelChirico](https://github.com/MichaelChirico), [@MichelineCampbell](https://github.com/MichelineCampbell), [@mikmart](https://github.com/mikmart), [@misea](https://github.com/misea), [@mjskay](https://github.com/mjskay), [@mkoohafkan](https://github.com/mkoohafkan), [@mlaparie](https://github.com/mlaparie), [@MLopez-Ibanez](https://github.com/MLopez-Ibanez), [@mluerig](https://github.com/mluerig), [@mohammad-numan](https://github.com/mohammad-numan), [@MoREpro](https://github.com/MoREpro), [@mtrsl](https://github.com/mtrsl), [@muschellij2](https://github.com/muschellij2), [@mzavattaro](https://github.com/mzavattaro), [@nicholasdavies](https://github.com/nicholasdavies), [@njspix](https://github.com/njspix), [@nmercadeb](https://github.com/nmercadeb), [@noejn2](https://github.com/noejn2), [@npearlmu](https://github.com/npearlmu), [@Olivia-Box-Power](https://github.com/Olivia-Box-Power), [@olivroy](https://github.com/olivroy), [@oracle5th](https://github.com/oracle5th), [@oskard95](https://github.com/oskard95), [@palderman](https://github.com/palderman), [@PanfengZhang](https://github.com/PanfengZhang), [@paulfajour](https://github.com/paulfajour), [@PCEBrunaLab](https://github.com/PCEBrunaLab), [@petrbouchal](https://github.com/petrbouchal), [@pgmj](https://github.com/pgmj), [@phispu](https://github.com/phispu), [@PietrH](https://github.com/PietrH), [@pn317](https://github.com/pn317), [@ppoyk](https://github.com/ppoyk), [@pradosj](https://github.com/pradosj), [@psoldath](https://github.com/psoldath), [@py9mrg](https://github.com/py9mrg), [@qli84](https://github.com/qli84), [@randyzwitch](https://github.com/randyzwitch), [@raphaludwig](https://github.com/raphaludwig), [@RaynorJim](https://github.com/RaynorJim), [@rdboyes](https://github.com/rdboyes), [@reechawong](https://github.com/reechawong), [@rempsyc](https://github.com/rempsyc), [@rfgoldberg](https://github.com/rfgoldberg), [@rikivillalba](https://github.com/rikivillalba), [@rishabh-mp3](https://github.com/rishabh-mp3), [@RodDalBen](https://github.com/RodDalBen), [@rogerssam](https://github.com/rogerssam), [@rsh52](https://github.com/rsh52), [@rwilson8](https://github.com/rwilson8), [@salim-b](https://github.com/salim-b), [@sambtalcott](https://github.com/sambtalcott), [@samuel-marsh](https://github.com/samuel-marsh), [@schloerke](https://github.com/schloerke), [@schmittrjp](https://github.com/schmittrjp), [@sierrajohnson](https://github.com/sierrajohnson), [@smouksassi](https://github.com/smouksassi), [@stitam](https://github.com/stitam), [@stragu](https://github.com/stragu), [@strengejacke](https://github.com/strengejacke), [@sunta3iouxos](https://github.com/sunta3iouxos), [@szkabel](https://github.com/szkabel), [@taozhou2020](https://github.com/taozhou2020), [@tdhock](https://github.com/tdhock), [@telenskyt](https://github.com/telenskyt), [@teunbrand](https://github.com/teunbrand), [@the-Hull](https://github.com/the-Hull), [@thgsponer](https://github.com/thgsponer), [@thomasp85](https://github.com/thomasp85), [@ThomasSoeiro](https://github.com/ThomasSoeiro), [@Tiggax](https://github.com/Tiggax), [@tikkss](https://github.com/tikkss), [@TimTaylor](https://github.com/TimTaylor), [@tombishop1](https://github.com/tombishop1), [@tommmmi](https://github.com/tommmmi), [@totajuliusd](https://github.com/totajuliusd), [@trafficfan](https://github.com/trafficfan), [@tungttnguyen](https://github.com/tungttnguyen), [@tvatter](https://github.com/tvatter), [@twest820](https://github.com/twest820), [@ujtwr](https://github.com/ujtwr), [@venpopov](https://github.com/venpopov), [@vgregoire1](https://github.com/vgregoire1), [@victorcat4](https://github.com/victorcat4), [@victorfeagins](https://github.com/victorfeagins), [@vivekJax](https://github.com/vivekJax), [@wbvguo](https://github.com/wbvguo), [@willgearty](https://github.com/willgearty), [@williamlai2](https://github.com/williamlai2), [@withr](https://github.com/withr), [@wvictor14](https://github.com/wvictor14), [@XdahaX](https://github.com/XdahaX), [@yjunechoe](https://github.com/yjunechoe), [@yoshidk6](https://github.com/yoshidk6), [@YUCHENG-ZHAO](https://github.com/YUCHENG-ZHAO), [@Yunuuuu](https://github.com/Yunuuuu), [@yutannihilation](https://github.com/yutannihilation), [@yzz32](https://github.com/yzz32), [@zhengxiaoUVic](https://github.com/zhengxiaoUVic), and [@zjwinn](https://github.com/zjwinn).

[^1]: Normally, [`aes()`](https://ggplot2.tidyverse.org/reference/aes.html) is strictly used to map data instead of setting a fixed property. We diverge from this API for pragmatic reasons, not theoretical ones.

[^2]: Aesthetics of the position adjustment are not be confused with position aesthetics. Position aesthetics like `x` and `y` are transformed by a scale, whereas aesthetics of the position adjustment like `nudge_x` and `nudge_y` are not (akin to `width` and `height`).

