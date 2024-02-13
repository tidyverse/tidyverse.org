---
output: hugodown::hugo_document

slug: ggplot-3-5-0-guides
title: A guide to guides
date: 2023-12-20
author: Teun van den Brand
description: >
    The new 3.5.0 release of ggplot2 implements a new guide system. Read on
    to find out what is new.

photo:
  url: https://unsplash.com/photos/white-and-black-measuring-tape-9rSP3SRUYh4
  author: CHUTTERSNAP

# one of: "deep-dive", "learn", "package", "programming", "roundup", or "other"
categories: [package] 
tags: [ggplot2]
rmd_hash: bc015c1eb490b899

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

We're overjoyed to release [ggplot2](https://ggplot2.tidyverse.org) 3.5.0. This is the second blogpost outlining improvements to ggplot2's guide system, which underwent a large rewrite. Please find the [main post](#TODO:%20link) to read about other exciting changes.

Guides, like axes and legends, are visual representations of scales and allow observers to translate graphical properties of a plot into information. Guides were the last remaining system in ggplot2 that clung to the S3 system. The guide system have now been rewritten in ggproto, the object-oriented system that powers ggplot2's extension mechanism. Like geoms, stats, scales, facets and coords before it, guides officially become an extension point that lets developers implement their own guides. We will start off discussing the user-facing changes to guides and later veer into extension territory.

You can see a full list of changes in the [release notes](https://ggplot2.tidyverse.org/news/index.html).

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://ggplot2.tidyverse.org'>ggplot2</a></span><span class='o'>)</span></span>
<span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://patchwork.data-imaginist.com'>patchwork</a></span><span class='o'>)</span></span></code></pre>

</div>

<div class="highlight">

</div>

## General

One of the more visible user-facing changes is that guides no longer have style arguments. All of the style settings, like the 'frame' in colour bars or text positions, are controllable via the [`theme()`](https://ggplot2.tidyverse.org/reference/theme.html) function. This makes it easier to globally control the appearance of legends. To tweak the style of any individual guide, guides now have a `theme` argument that can set style elements. In the plot below, notice how the legend title settings affect both the colour bar and the legend, whereas the local options, like the red legend text, apply only to a single guide.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggplot.html'>ggplot</a></span><span class='o'>(</span><span class='nv'>mpg</span>, <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/aes.html'>aes</a></span><span class='o'>(</span><span class='nv'>displ</span>, <span class='nv'>hwy</span>, shape <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/factor.html'>factor</a></span><span class='o'>(</span><span class='nv'>cyl</span><span class='o'>)</span>, colour <span class='o'>=</span> <span class='nv'>cty</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/geom_point.html'>geom_point</a></span><span class='o'>(</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='c'># Styling individual guides</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/guides.html'>guides</a></span><span class='o'>(</span></span>
<span>    x <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/guide_axis.html'>guide_axis</a></span><span class='o'>(</span>theme <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/theme.html'>theme</a></span><span class='o'>(</span>axis.line <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>element_line</a></span><span class='o'>(</span><span class='o'>)</span><span class='o'>)</span><span class='o'>)</span>,</span>
<span>    shape <span class='o'>=</span> </span>
<span>      <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/guide_legend.html'>guide_legend</a></span><span class='o'>(</span>theme <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/theme.html'>theme</a></span><span class='o'>(</span>legend.text <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>element_text</a></span><span class='o'>(</span>colour <span class='o'>=</span> <span class='s'>"red"</span><span class='o'>)</span><span class='o'>)</span><span class='o'>)</span>,</span>
<span>    colour <span class='o'>=</span></span>
<span>      <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/guide_colourbar.html'>guide_colorbar</a></span><span class='o'>(</span>theme <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/theme.html'>theme</a></span><span class='o'>(</span>legend.frame <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>element_rect</a></span><span class='o'>(</span>colour <span class='o'>=</span> <span class='s'>"red"</span><span class='o'>)</span><span class='o'>)</span><span class='o'>)</span></span>
<span>  <span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='c'># Styling guides globally</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/theme.html'>theme</a></span><span class='o'>(</span></span>
<span>    legend.title.position <span class='o'>=</span> <span class='s'>"left"</span>,</span>
<span>    legend.title <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>element_text</a></span><span class='o'>(</span>angle <span class='o'>=</span> <span class='m'>90</span>, hjust <span class='o'>=</span> <span class='m'>0.5</span><span class='o'>)</span></span>
<span>  <span class='o'>)</span></span>
</code></pre>
<img src="figs/guide_theming-1.png" alt="Scatterplot of engine displacement versus highway miles per gallon. The bottom x-axis displays a line, whereas the y-axis does not. The legend indicating shapes for the number of cylinders has red text. The colour bar indicating city miles per gallon has a red rectangle around the bar. Both the legend and colour bar titles are rotated, centered and on the left of the guide." width="700px" style="display: block; margin: auto;" />

</div>

## Legends

For the purposes of this post, 'legend' will refer to all guides that are not axes. As the term 'legend' suggests, this includes [`guide_legend()`](https://ggplot2.tidyverse.org/reference/guide_legend.html) but also [`guide_colourbar()`](https://ggplot2.tidyverse.org/reference/guide_colourbar.html), [`guide_bins()`](https://ggplot2.tidyverse.org/reference/guide_bins.html) and [`guide_coloursteps()`](https://ggplot2.tidyverse.org/reference/guide_coloursteps.html). It explicitly excludes all types of axes.

### Position placement

Legend positions are no longer restricted to just a single side of the plot. By setting the `position` argument of guides, you can tailor which guides appears where in the plot. Guides that do not have a position set, like the 'drv' shape legend, follow the theme's `legend.position` setting.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>p</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggplot.html'>ggplot</a></span><span class='o'>(</span><span class='nv'>mpg</span>, <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/aes.html'>aes</a></span><span class='o'>(</span><span class='nv'>displ</span>, <span class='nv'>hwy</span>, shape <span class='o'>=</span> <span class='nv'>drv</span>, colour <span class='o'>=</span> <span class='nv'>cty</span>, size <span class='o'>=</span> <span class='nv'>year</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/geom_point.html'>geom_point</a></span><span class='o'>(</span><span class='nf'><a href='https://ggplot2.tidyverse.org/reference/aes.html'>aes</a></span><span class='o'>(</span>alpha <span class='o'>=</span> <span class='nv'>cyl</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/guides.html'>guides</a></span><span class='o'>(</span></span>
<span>    colour <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/guide_colourbar.html'>guide_colourbar</a></span><span class='o'>(</span>position <span class='o'>=</span> <span class='s'>"bottom"</span><span class='o'>)</span>,</span>
<span>    size   <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/guide_legend.html'>guide_legend</a></span><span class='o'>(</span>position <span class='o'>=</span> <span class='s'>"top"</span><span class='o'>)</span>,</span>
<span>    alpha  <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/guide_legend.html'>guide_legend</a></span><span class='o'>(</span>position <span class='o'>=</span> <span class='s'>"inside"</span><span class='o'>)</span></span>
<span>  <span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/theme.html'>theme</a></span><span class='o'>(</span>legend.position <span class='o'>=</span> <span class='s'>"left"</span><span class='o'>)</span></span>
<span><span class='nv'>p</span></span>
</code></pre>
<img src="figs/legend_positions-1.png" alt="A scatterplot showing engine displacement versus highway miles per gallon. It has four legend placed at the top, left, bottom of the panel and one inside the panel." width="700px" style="display: block; margin: auto;" />

</div>

In the plot above, the legend for the 'cyl' variable is in the middle of the plot. In previous versions of ggplot2, you could set the `legend.position` to a coordinate to control the placement. However, doing this would change the default legend position, which is not always desirable. To cover such cases, there is now a specialised `legend.position.inside` argument that controls the positioning of legends with `position = "inside"` regardless of whether the position was specified in the theme or in the guide.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>p</span> <span class='o'>+</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/theme.html'>theme</a></span><span class='o'>(</span>legend.position.inside <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='m'>0.7</span>, <span class='m'>0.7</span><span class='o'>)</span><span class='o'>)</span></span>
</code></pre>
<img src="figs/legend_inside-1.png" alt="The same plot as before, but the legend for the 'cyl' variable is to the top-right of the centre." width="700px" style="display: block; margin: auto;" />

</div>

The justification of legends is controllable by using the `legend.justification.{position}` theme setting. Moreover, the top and bottom guides can be aligned to the plot rather than the panel by setting the `legend.location` argument. The main reason behind this is that you can then align the legends with the plot's title. By default, when `plot.title.position = "plot"`, left legends are already aligned. For this reason, the top and bottom guides are prioritised for the `legend.location` setting. Moreover, it avoids overlapping of legends in the corners if the justifications would dictate it.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>p</span> <span class='o'>+</span> </span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/labs.html'>labs</a></span><span class='o'>(</span>title <span class='o'>=</span> <span class='s'>"Plot-aligned title"</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/theme.html'>theme</a></span><span class='o'>(</span></span>
<span>    legend.margin <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>margin</a></span><span class='o'>(</span><span class='m'>0</span>, <span class='m'>0</span>, <span class='m'>0</span>, <span class='m'>0</span><span class='o'>)</span>, <span class='c'># turned off for alignment</span></span>
<span>    legend.justification.top <span class='o'>=</span> <span class='s'>"left"</span>,</span>
<span>    legend.justification.left <span class='o'>=</span> <span class='s'>"top"</span>,</span>
<span>    legend.justification.bottom <span class='o'>=</span> <span class='s'>"right"</span>,</span>
<span>    legend.justification.inside <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='m'>1</span>, <span class='m'>1</span><span class='o'>)</span>,</span>
<span>    legend.location <span class='o'>=</span> <span class='s'>"plot"</span>,</span>
<span>    plot.title.position <span class='o'>=</span> <span class='s'>"plot"</span></span>
<span>  <span class='o'>)</span></span>
</code></pre>
<img src="figs/legend_alignments-1.png" alt="The same plot as before, but with a plot-aligned title and different alignments of the legends. The left and top legends are left-aligned with the title." width="700px" style="display: block; margin: auto;" />

</div>

### Awareness

Legends are now more aware what discrete variables should be placed in which keys. By default, they now only draw keys for the layer which contain the relevant value. This saves one having to hassle with the `guide_legend(override.aes)` argument to get the keys to display just right. In the plot below, notice how the points and line have separate keys.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>p</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggplot.html'>ggplot</a></span><span class='o'>(</span><span class='nv'>mpg</span>, <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/aes.html'>aes</a></span><span class='o'>(</span><span class='nv'>displ</span>, <span class='nv'>hwy</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/scale_manual.html'>scale_alpha_manual</a></span><span class='o'>(</span>values <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='m'>0.5</span>, <span class='m'>1</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='nv'>p</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/geom_point.html'>geom_point</a></span><span class='o'>(</span><span class='nf'><a href='https://ggplot2.tidyverse.org/reference/aes.html'>aes</a></span><span class='o'>(</span>colour <span class='o'>=</span> <span class='s'>"points"</span>, alpha <span class='o'>=</span> <span class='s'>"points"</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/geom_path.html'>geom_line</a></span><span class='o'>(</span></span>
<span>    <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/aes.html'>aes</a></span><span class='o'>(</span>colour <span class='o'>=</span> <span class='s'>"line"</span>, alpha <span class='o'>=</span> <span class='s'>"line"</span><span class='o'>)</span>,</span>
<span>    stat <span class='o'>=</span> <span class='s'>"smooth"</span>, formula <span class='o'>=</span> <span class='nv'>y</span> <span class='o'>~</span> <span class='nv'>x</span>, method <span class='o'>=</span> <span class='s'>"lm"</span></span>
<span>  <span class='o'>)</span></span>
</code></pre>
<img src="figs/legend_awareness-1.png" alt="A scatterplot with trendline showing engine displacement versus highway miles per gallon. There are two legends for colour and alpha. Both legends show points and lines separately." width="700px" style="display: block; margin: auto;" />

</div>

To revert back to the old behaviour, you can set the `show.legend = TRUE` option in the layers. Like before, the `show.legend` argument can still be set in an aesthetic-specific way. Setting it to `TRUE` means 'always show', `FALSE` means 'never show' and `NA` means 'show if found'.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>p</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/geom_point.html'>geom_point</a></span><span class='o'>(</span></span>
<span>    <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/aes.html'>aes</a></span><span class='o'>(</span>colour <span class='o'>=</span> <span class='s'>"points"</span>, alpha <span class='o'>=</span> <span class='s'>"points"</span><span class='o'>)</span>,</span>
<span>    show.legend <span class='o'>=</span> <span class='kc'>TRUE</span> <span class='c'># always show</span></span>
<span>  <span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/geom_path.html'>geom_line</a></span><span class='o'>(</span></span>
<span>    <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/aes.html'>aes</a></span><span class='o'>(</span>colour <span class='o'>=</span> <span class='s'>"line"</span>, alpha <span class='o'>=</span> <span class='s'>"line"</span><span class='o'>)</span>,</span>
<span>    stat <span class='o'>=</span> <span class='s'>"smooth"</span>, formula <span class='o'>=</span> <span class='nv'>y</span> <span class='o'>~</span> <span class='nv'>x</span>, method <span class='o'>=</span> <span class='s'>"lm"</span>,</span>
<span>    show.legend <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span>colour <span class='o'>=</span> <span class='kc'>NA</span>, alpha <span class='o'>=</span> <span class='kc'>TRUE</span><span class='o'>)</span> <span class='c'># always show in alpha</span></span>
<span>  <span class='o'>)</span></span>
</code></pre>
<img src="figs/show_key_setting-1.png" alt="The same plot as before, but every legend keys displays points. Lines are shown in every 'alpha' legend key, but only one 'colour' key." width="700px" style="display: block; margin: auto;" />

</div>

### Legend spacing

In this release, the way spacing in legends work has been reworked.

-   The `legend.spacing{.x/.y}` theme setting is now used to space different guides apart. Previously, it was also used to space legend keys apart; that is no longer the case.
-   Spacing legend key-label pairs apart is now controlled by the `legend.key.spacing{.x/.y}` theme setting.
-   Spacing the labels from the keys is now controlled by the label element's `margin` argument.

Because the legend spacing and margin options can be a bit bewildering, a small overview is added below. One setting not included in the overview is `legend.spacing.x`, which only applies when `legend.box = "horizontal"`. Which exact text margin is relevant for spacing apart keys and labels, or titles and the rest of the guide, depends on the `legend.text.position` and `legend.title.position` theme elements.

<div class="highlight">

<img src="figs/spacing_overview-1.png" alt="Overview of legend spacing and margin options. Two abstract legends are placed above one another to the right of an area called 'plot'. Various arrows with labels point out different theme settings." width="700px" style="display: block; margin: auto;" />

</div>

When the titles and keys don't have explicit margins, appropriate margins are added automatically depending on the position. However, if you override the margins, they will be interpreted literally.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggplot.html'>ggplot</a></span><span class='o'>(</span><span class='nv'>mpg</span>, <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/aes.html'>aes</a></span><span class='o'>(</span><span class='nv'>displ</span>, <span class='nv'>hwy</span>, colour <span class='o'>=</span> <span class='nv'>class</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/geom_point.html'>geom_point</a></span><span class='o'>(</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/guides.html'>guides</a></span><span class='o'>(</span>colour <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/guide_legend.html'>guide_legend</a></span><span class='o'>(</span>ncol <span class='o'>=</span> <span class='m'>2</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/theme.html'>theme</a></span><span class='o'>(</span></span>
<span>    legend.key.spacing.x <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/grid/unit.html'>unit</a></span><span class='o'>(</span><span class='m'>10</span>, <span class='s'>"pt"</span><span class='o'>)</span>,</span>
<span>    legend.key.spacing.y <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/grid/unit.html'>unit</a></span><span class='o'>(</span><span class='m'>20</span>, <span class='s'>"pt"</span><span class='o'>)</span>,</span>
<span>    legend.text <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>element_text</a></span><span class='o'>(</span>margin <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>margin</a></span><span class='o'>(</span>l <span class='o'>=</span> <span class='m'>0</span><span class='o'>)</span><span class='o'>)</span>,</span>
<span>    legend.title <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>element_text</a></span><span class='o'>(</span>margin <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>margin</a></span><span class='o'>(</span>b <span class='o'>=</span> <span class='m'>20</span><span class='o'>)</span><span class='o'>)</span></span>
<span>  <span class='o'>)</span></span>
</code></pre>
<img src="figs/legend_spacing-1.png" alt="A scatterplot showing engine displacement versus highway miles per gallon. The legend for the 'class' variable shows a key layout with two columns. Keys are widely spacing in the vertical direction and more narrowly in the horizontal direction. There is no space between the keys and their labels, but plenty of space between the legend and its title." width="700px" style="display: block; margin: auto;" />

</div>

For all intents and purposes, colour bar/step and bins guides are treated as legend guides with just a single key-label pair. While the `legend.key.spacing` setting does not apply due to it being one single key, the other spacings and margins do apply equally.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggplot.html'>ggplot</a></span><span class='o'>(</span><span class='nv'>mpg</span>, <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/aes.html'>aes</a></span><span class='o'>(</span><span class='nv'>displ</span>, <span class='nv'>hwy</span>, colour <span class='o'>=</span> <span class='nv'>cty</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/geom_point.html'>geom_point</a></span><span class='o'>(</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/theme.html'>theme</a></span><span class='o'>(</span></span>
<span>    legend.text  <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>element_text</a></span><span class='o'>(</span>margin <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>margin</a></span><span class='o'>(</span>l <span class='o'>=</span> <span class='m'>0</span><span class='o'>)</span><span class='o'>)</span>,</span>
<span>    legend.title <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>element_text</a></span><span class='o'>(</span>margin <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>margin</a></span><span class='o'>(</span>b <span class='o'>=</span> <span class='m'>20</span><span class='o'>)</span><span class='o'>)</span></span>
<span>  <span class='o'>)</span></span>
</code></pre>
<img src="figs/legend_spacing_bar-1.png" alt="The same plot as before, but with a colourbar indicating the 'cty' variable. Again, there is no space between the bar and the labels and ample space between the bar and the title." width="700px" style="display: block; margin: auto;" />

</div>

### Stretching

Another experimental tweak to legends, is that they can now have stretching keys (or bars). The option is still considered 'experimental' because there are some things that may go wrong. By setting the `legend.key{.height/.width}` theme argument as a `"null"` unit, legends can now expand to fill the available space.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>p</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggplot.html'>ggplot</a></span><span class='o'>(</span><span class='nv'>mpg</span>, <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/aes.html'>aes</a></span><span class='o'>(</span><span class='nv'>displ</span>, <span class='nv'>hwy</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/geom_point.html'>geom_point</a></span><span class='o'>(</span><span class='nf'><a href='https://ggplot2.tidyverse.org/reference/aes.html'>aes</a></span><span class='o'>(</span>colour <span class='o'>=</span> <span class='nv'>cty</span>, size <span class='o'>=</span> <span class='nv'>cyl</span><span class='o'>)</span>, shape <span class='o'>=</span> <span class='m'>21</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/theme.html'>theme</a></span><span class='o'>(</span>legend.key.height <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/grid/unit.html'>unit</a></span><span class='o'>(</span><span class='m'>1</span>, <span class='s'>"null"</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='nv'>p</span></span>
</code></pre>
<img src="figs/stretch_keys-1.png" alt="Scatterplot of engine displacement versus highway miles per gallon. There is a legend guide showing the point's size and a colour. Both the legend and the bar take up an approximately equal amount of space on the right-hand side of the panel." width="700px" style="display: block; margin: auto;" />

</div>

The term 'available space' is a tricky one. For starters, other legends placed in the same position take up space, as can be seen in the plot above. If your legend is the only legend in a position, more space is available and it stretches more. As you can see in the plot below, the legends are not aligned with the panel even when stretched. This is because the titles, margins and various spacings all take up space that is *not* available.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>p</span> <span class='o'>+</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/guides.html'>guides</a></span><span class='o'>(</span>colour <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/guide_colourbar.html'>guide_colourbar</a></span><span class='o'>(</span>position <span class='o'>=</span> <span class='s'>"left"</span><span class='o'>)</span><span class='o'>)</span></span>
</code></pre>
<img src="figs/isolated_stretch-1.png" alt="Same plot as before, but the colour bar is placed on the left. Both the colour bar and legend take up a lot of vertical space." width="700px" style="display: block; margin: auto;" />

</div>

On the other hand, if one position is packed with legends, the keys may shrink instead of stretch. The keys can become too small to show the aesthetics properly. You can see in the example below that the size legend becomes cut-off due to small keys and text is spaced too closely to comfortably read.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>p</span> <span class='o'>+</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/aes.html'>aes</a></span><span class='o'>(</span>fill <span class='o'>=</span> <span class='nv'>model</span><span class='o'>)</span></span>
</code></pre>
<img src="figs/shrinking_keys-1.png" alt="Same plot as before, but all legends are on the right, including a new legend for the 'model' variable. All legends have keys that are too small to read the text comfortably, and the points indicating size are clipped." width="700px" style="display: block; margin: auto;" />

</div>

Another issue that may come up is that the 'available space' might be 0. Because the plot itself is also space-filling, setting null-heights for top/bottom positions or null-widths for left/right positions means there is no available space. This may result in the keys or bars becoming invisible. For the plot below, recall that we've set the `legend.key.height` setting to a null unit.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>p</span> <span class='o'>+</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/theme.html'>theme</a></span><span class='o'>(</span>legend.position <span class='o'>=</span> <span class='s'>"top"</span><span class='o'>)</span></span>
</code></pre>
<img src="figs/disappearing_keys-1.png" alt="Still the same scatterplot but without the fill variable. Legends are placed at the top of the panel, but the bar and key backgrounds have disappeared. The text labels are still present." width="700px" style="display: block; margin: auto;" />

</div>

### Other improvements

We welcome a new type of legend: [`guide_custom()`](https://ggplot2.tidyverse.org/reference/guide_custom.html). It can be used to add any graphical object (grob) to a plot, like [`annotation_custom()`](https://ggplot2.tidyverse.org/reference/annotation_custom.html). There are a few differences though: it is positioned just like a legend and adds titles and margins. In some sense, this guide is 'special', as it is the only guide that does not directly reflect a scale. The downside is that it cannot read properties from the plot, but the upside is that it is very flexible. Be careful that if your grob does not have an absolute size, to set the `width` and `height` arguments.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>x</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='m'>0.5</span>, <span class='m'>1</span>, <span class='m'>1.5</span>, <span class='m'>1.2</span>, <span class='m'>1.5</span>, <span class='m'>1</span>, <span class='m'>0.5</span>, <span class='m'>0.8</span>, <span class='m'>1</span>, <span class='m'>1.15</span>, <span class='m'>2</span>, <span class='m'>1.15</span>, <span class='m'>1</span>, <span class='m'>0.85</span>, <span class='m'>0</span>, <span class='m'>0.85</span><span class='o'>)</span></span>
<span><span class='nv'>y</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='m'>1.5</span>, <span class='m'>1.2</span>, <span class='m'>1.5</span>, <span class='m'>1</span>, <span class='m'>0.5</span>, <span class='m'>0.8</span>, <span class='m'>0.5</span>, <span class='m'>1</span>, <span class='m'>2</span>, <span class='m'>1.15</span>, <span class='m'>1</span>, <span class='m'>0.85</span>, <span class='m'>0</span>, <span class='m'>0.85</span>, <span class='m'>1</span>, <span class='m'>1.15</span><span class='o'>)</span></span>
<span></span>
<span><span class='nv'>compass_rose</span> <span class='o'>&lt;-</span> <span class='nf'>grid</span><span class='nf'>::</span><span class='nf'><a href='https://rdrr.io/r/grid/grid.polygon.html'>polygonGrob</a></span><span class='o'>(</span></span>
<span>  x <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/grid/unit.html'>unit</a></span><span class='o'>(</span><span class='nv'>x</span>, <span class='s'>"cm"</span><span class='o'>)</span>, y <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/grid/unit.html'>unit</a></span><span class='o'>(</span><span class='nv'>y</span>, <span class='s'>"cm"</span><span class='o'>)</span>, id.lengths <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='m'>8</span>, <span class='m'>8</span><span class='o'>)</span>,</span>
<span>  gp <span class='o'>=</span> <span class='nf'>grid</span><span class='nf'>::</span><span class='nf'><a href='https://rdrr.io/r/grid/gpar.html'>gpar</a></span><span class='o'>(</span>fill <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"grey50"</span>, <span class='s'>"grey25"</span><span class='o'>)</span>, col <span class='o'>=</span> <span class='kc'>NA</span><span class='o'>)</span></span>
<span><span class='o'>)</span></span>
<span></span>
<span><span class='nv'>nc</span> <span class='o'>&lt;-</span> <span class='nf'>sf</span><span class='nf'>::</span><span class='nf'><a href='https://r-spatial.github.io/sf/reference/st_read.html'>st_read</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/system.file.html'>system.file</a></span><span class='o'>(</span><span class='s'>"shape/nc.shp"</span>, package <span class='o'>=</span> <span class='s'>"sf"</span><span class='o'>)</span>, quiet <span class='o'>=</span> <span class='kc'>TRUE</span><span class='o'>)</span></span>
<span><span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggplot.html'>ggplot</a></span><span class='o'>(</span><span class='nv'>nc</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggsf.html'>geom_sf</a></span><span class='o'>(</span><span class='nf'><a href='https://ggplot2.tidyverse.org/reference/aes.html'>aes</a></span><span class='o'>(</span>fill <span class='o'>=</span> <span class='nv'>AREA</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/guides.html'>guides</a></span><span class='o'>(</span>custom <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/guide_custom.html'>guide_custom</a></span><span class='o'>(</span><span class='nv'>compass_rose</span>, title <span class='o'>=</span> <span class='s'>"compass"</span><span class='o'>)</span><span class='o'>)</span></span>
</code></pre>
<img src="figs/custom_guide-1.png" alt="A map of the US state North Carolina, where fill colour indicates the area of counties. Underneath the colour bar for the fill, there is an eight-pointed star to the right of the panel with the title 'compass'." width="700px" style="display: block; margin: auto;" />

</div>

In previous version of ggplot2, when legend titles are wider than the legends, the guide-title alignment was always left aligned. Now, the justification setting of the legend text determines the alignment: 1 is right or top aligned and 0 is left or bottom aligned.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggplot.html'>ggplot</a></span><span class='o'>(</span><span class='nv'>mpg</span>, <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/aes.html'>aes</a></span><span class='o'>(</span><span class='nv'>displ</span>, <span class='nv'>hwy</span>, shape <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/factor.html'>factor</a></span><span class='o'>(</span><span class='nv'>cyl</span><span class='o'>)</span>, colour <span class='o'>=</span> <span class='nv'>drv</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/geom_point.html'>geom_point</a></span><span class='o'>(</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/guides.html'>guides</a></span><span class='o'>(</span></span>
<span>    shape <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/guide_legend.html'>guide_legend</a></span><span class='o'>(</span></span>
<span>      title <span class='o'>=</span> <span class='s'>"A title that is pretty long"</span>,</span>
<span>      theme <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/theme.html'>theme</a></span><span class='o'>(</span>legend.title <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>element_text</a></span><span class='o'>(</span>hjust <span class='o'>=</span> <span class='m'>1</span><span class='o'>)</span><span class='o'>)</span></span>
<span>    <span class='o'>)</span>,</span>
<span>    colour <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/guide_legend.html'>guide_legend</a></span><span class='o'>(</span></span>
<span>      title <span class='o'>=</span> <span class='s'>"Another long title"</span>,</span>
<span>      theme <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/theme.html'>theme</a></span><span class='o'>(</span>legend.title <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>element_text</a></span><span class='o'>(</span>hjust <span class='o'>=</span> <span class='m'>0</span><span class='o'>)</span><span class='o'>)</span></span>
<span>    <span class='o'>)</span></span>
<span>  <span class='o'>)</span></span>
</code></pre>
<img src="figs/title_justification-1.png" alt="Scatterplot of engine displacement versus highway miles per gallon. The 'drv' variable has a legend that is left aligned, whereas the 'cyl' variable has a legend that is right-aligned." width="700px" style="display: block; margin: auto;" />

</div>

## Axes

Axes refer to position guides that reflect x- and y-scales. In some non-Cartesian coordinate systems, they may reflect a theta or radius, a longitude or latitude. Classically, they display labelled tick marks at regular intervals. The most common axis, is the default [`guide_axis()`](https://ggplot2.tidyverse.org/reference/guide_axis.html).

### Improvements

A much requested expansion of axis capabilities is the ability to draw minor ticks. To draw minor ticks, you can use the `minor.ticks` argument of [`guide_axis()`](https://ggplot2.tidyverse.org/reference/guide_axis.html).

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>p</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggplot.html'>ggplot</a></span><span class='o'>(</span><span class='nv'>mpg</span>, <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/aes.html'>aes</a></span><span class='o'>(</span><span class='nv'>displ</span>, <span class='nv'>hwy</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>+</span></span>
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

### Logarithmic axes

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
<img src="figs/log_axes-1.png" alt="A line plot showing a negatively sloped line with a reversedlog10-transformation on the y-axis and inverse hyberbolic sine transformationon the x-axis. Large ticks appears at multiples of 10,medium ticks at multiples of 5 and small ticks at multiples of 1." width="700px" style="display: block; margin: auto;" />

</div>

The log-ticks axis supersedes the earlier [`annotation_logticks()`](https://ggplot2.tidyverse.org/reference/annotation_logticks.html) function. Because it is implemented as an axis, it has minimal fuss with the placement of labels and is immune to the clipping options in the coord. To mirror [`annotation_logticks()`](https://ggplot2.tidyverse.org/reference/annotation_logticks.html) more closely, you can set a negative tick length in the theme.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>p</span> <span class='o'>+</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/theme.html'>theme</a></span><span class='o'>(</span>axis.ticks.length <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/grid/unit.html'>unit</a></span><span class='o'>(</span><span class='o'>-</span><span class='m'>2.25</span>, <span class='s'>"pt"</span><span class='o'>)</span><span class='o'>)</span></span>
</code></pre>
<img src="figs/log_ticks_inward-1.png" alt="The same plot as above, but the tick marks now point inwards." width="700px" style="display: block; margin: auto;" />

</div>

Indirectly related to guides, [`facet_wrap()`](https://ggplot2.tidyverse.org/reference/facet_wrap.html) and [`facet_grid()`](https://ggplot2.tidyverse.org/reference/facet_grid.html) now have extended options for how axes should be displayed in between panels. Previously, axes in between panels were only displayed when using `facet_wrap(scales = "free")`. That is still the case, but there are more options available for [`facet_grid()`](https://ggplot2.tidyverse.org/reference/facet_grid.html) and fixed scales. Using the `axes = "all"` option, all axes are displayed, including those in between panels. Using `axes = "all_x"` or `"all_y"`, you can narrow down which axes are displayed. In addition, you can choose whether or not to display the labels of those axes with the `axis.labels` argument.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>p</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggplot.html'>ggplot</a></span><span class='o'>(</span><span class='nv'>mpg</span>, <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/aes.html'>aes</a></span><span class='o'>(</span><span class='nv'>displ</span>, <span class='nv'>hwy</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/geom_point.html'>geom_point</a></span><span class='o'>(</span><span class='o'>)</span></span>
<span></span>
<span><span class='nv'>p</span> <span class='o'>+</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/facet_grid.html'>facet_grid</a></span><span class='o'>(</span><span class='nv'>year</span> <span class='o'>~</span> <span class='nv'>drv</span>, axes <span class='o'>=</span> <span class='s'>"all"</span>, axis.labels <span class='o'>=</span> <span class='s'>"all_y"</span><span class='o'>)</span></span>
</code></pre>
<img src="figs/facet_axes_display-1.png" alt="A scatterplot facetted by the 'drv' and 'year' variables. The x-axes in between panels are shown as tick marks without labels. The y-axes in between panels are shown in full." width="700px" style="display: block; margin: auto;" />

</div>

### Theta axes

The next new axis guide is [`guide_axis_theta()`](https://ggplot2.tidyverse.org/reference/guide_axis_theta.html). It is a highly specialised axis for use in combination with the new [`coord_radial()`](https://ggplot2.tidyverse.org/reference/coord_polar.html). Instead of using `x`, `y`, `x.sec` and `y.sec` as one would for Cartesian coordinates, the axes are specified for the `r`, `r.sec`, `theta` and `theta.sec` guides. Because the theta guides are not linear and require different drawing logic, they are implemented as separate guides. They support many features of linear axes, such as capping and minor ticks, but lack dodging or text justification. When setting the `angle` argument, text is placed relative to the angle of the coordinates, as can be seen for the inner theta guide. The theta guides adhere to the `{setting}.theta` styling, and radial guides to the `{setting}.r` styling.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggplot.html'>ggplot</a></span><span class='o'>(</span><span class='nv'>mpg</span>, <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/aes.html'>aes</a></span><span class='o'>(</span><span class='nv'>displ</span>, <span class='nv'>hwy</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/geom_point.html'>geom_point</a></span><span class='o'>(</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/coord_polar.html'>coord_radial</a></span><span class='o'>(</span>start <span class='o'>=</span> <span class='m'>0.25</span> <span class='o'>*</span> <span class='nv'>pi</span>, end <span class='o'>=</span> <span class='m'>1.75</span> <span class='o'>*</span> <span class='nv'>pi</span>, inner.radius <span class='o'>=</span> <span class='m'>0.3</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/guides.html'>guides</a></span><span class='o'>(</span></span>
<span>    theta     <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/guide_axis_theta.html'>guide_axis_theta</a></span><span class='o'>(</span>cap <span class='o'>=</span> <span class='s'>"both"</span>, minor.ticks <span class='o'>=</span> <span class='kc'>TRUE</span><span class='o'>)</span>,</span>
<span>    theta.sec <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/guide_axis_theta.html'>guide_axis_theta</a></span><span class='o'>(</span>angle <span class='o'>=</span> <span class='m'>0</span><span class='o'>)</span>,</span>
<span>    r     <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/guide_axis.html'>guide_axis</a></span><span class='o'>(</span>cap <span class='o'>=</span> <span class='s'>"both"</span>, minor.ticks <span class='o'>=</span> <span class='kc'>TRUE</span><span class='o'>)</span>,</span>
<span>    r.sec <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/guide_axis.html'>guide_axis</a></span><span class='o'>(</span>angle <span class='o'>=</span> <span class='m'>0</span><span class='o'>)</span></span>
<span>  <span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/theme.html'>theme</a></span><span class='o'>(</span></span>
<span>    axis.line.theta <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>element_line</a></span><span class='o'>(</span>colour <span class='o'>=</span> <span class='s'>"blue"</span><span class='o'>)</span>,</span>
<span>    axis.line.r     <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>element_line</a></span><span class='o'>(</span>colour <span class='o'>=</span> <span class='s'>"red"</span><span class='o'>)</span></span>
<span>  <span class='o'>)</span></span>
</code></pre>
<img src="figs/theta_axis-1.png" alt="A scatterplot in horseshoe-shaped polar coordinates. The guides marking the angles are displayed in blue and the guides marking the radius are marked in red. The outer angle guide has been capped and has minor breaks, whereas the inner angle guide has rotated text. The same is true for the right and left guides respectively." width="700px" style="display: block; margin: auto;" />

</div>

### Stacked axes

The last new axis is technically not an axis, but a way to combine axes. [`guide_axis_stack()`](https://ggplot2.tidyverse.org/reference/guide_axis_stack.html) can take multiple other axes and combine them by placing them next to oneanother. The first axis is placed next to the panel and subsequent axes are placed further away from the panel. As mentioned [at the beginning](#general), every guide now has its own `theme` argument. This can be used to customise individual axes that are part of [`guide_axis_stack()`](https://ggplot2.tidyverse.org/reference/guide_axis_stack.html), or set common elements like the axis line in the plot below.

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

## Extending guides

Guides have been rewritten in the ggproto system of object oriented programming, like much of the other components of ggplot2. With this rewrite, guides are officially open for extensions and may be extended in much the same way geoms, stats, facets and coord can already.

Guides are closely related to scales and aesthetics, so an important part of guides is taken information from the scale and translating it to a graphic. The way guides typically carry information about a scale's breaks and labels is the `key` variable. You can glance at what the keys of a guide contain by using the [`get_guide_data()`](https://ggplot2.tidyverse.org/reference/get_guide_data.html) function. Typically, they carry the scale's mapped aesthetic, the hexadecimal colours in the example below, what those aesthetics represent in the `.value` column and how they should be labelled in the `.label` column.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>p</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggplot.html'>ggplot</a></span><span class='o'>(</span><span class='nv'>mpg</span>, <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/aes.html'>aes</a></span><span class='o'>(</span><span class='nv'>displ</span>, <span class='nv'>hwy</span>, colour <span class='o'>=</span> <span class='nv'>drv</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/geom_point.html'>geom_point</a></span><span class='o'>(</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/scale_colour_discrete.html'>scale_colour_discrete</a></span><span class='o'>(</span></span>
<span>    labels <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"4-wheel drive"</span>, <span class='s'>"front wheel drive"</span>, <span class='s'>"rear wheel drive"</span><span class='o'>)</span></span>
<span>  <span class='o'>)</span></span>
<span></span>
<span><span class='nf'><a href='https://ggplot2.tidyverse.org/reference/get_guide_data.html'>get_guide_data</a></span><span class='o'>(</span><span class='nv'>p</span>, <span class='s'>"colour"</span><span class='o'>)</span></span>
<span><span class='c'>#&gt;    colour .value            .label</span></span>
<span><span class='c'>#&gt; 1 #F8766D      4     4-wheel drive</span></span>
<span><span class='c'>#&gt; 2 #00BA38      f front wheel drive</span></span>
<span><span class='c'>#&gt; 3 #619CFF      r  rear wheel drive</span></span>
<span></span></code></pre>

</div>

Let's now make a first guide extension by adjusting the guide's key. Axes are most straightforward to extend because they are the least complicated. We'll make an axis that accepts custom values for the guide's `key`. We begin by making a custom ggproto class that inherits from the axis guide. An important extension point is the `extract_key()` method, which determines how break information is transferred from the scale to the guide. In our class, we reject the scale's reality and substitute our own.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>GuideKey</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggproto.html'>ggproto</a></span><span class='o'>(</span></span>
<span>  <span class='s'>"Guide"</span>, <span class='nv'>GuideAxis</span>,</span>
<span>  </span>
<span>  <span class='c'># Some parameters are required, so it is easiest to copy the base Guide's</span></span>
<span>  <span class='c'># parameters into our new parameters.</span></span>
<span>  <span class='c'># We add a new 'key' parameter for our own guide.</span></span>
<span>  params <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='nv'>GuideAxis</span><span class='o'>$</span><span class='nv'>params</span>, <span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span>key <span class='o'>=</span> <span class='kc'>NULL</span><span class='o'>)</span><span class='o'>)</span>,</span>
<span>  </span>
<span>  <span class='c'># It is important for guides to have a mapped aesthetic with the correct name</span></span>
<span>  extract_key <span class='o'>=</span> <span class='kr'>function</span><span class='o'>(</span><span class='nv'>scale</span>, <span class='nv'>aesthetic</span>, <span class='nv'>key</span>, <span class='nv'>...</span><span class='o'>)</span> <span class='o'>&#123;</span></span>
<span>    <span class='nv'>key</span><span class='o'>$</span><span class='nv'>aesthetic</span> <span class='o'>&lt;-</span> <span class='nv'>scale</span><span class='o'>$</span><span class='nf'>map</span><span class='o'>(</span><span class='nv'>key</span><span class='o'>$</span><span class='nv'>aesthetic</span><span class='o'>)</span></span>
<span>    <span class='nf'><a href='https://rdrr.io/r/base/names.html'>names</a></span><span class='o'>(</span><span class='nv'>key</span><span class='o'>)</span><span class='o'>[</span><span class='nf'><a href='https://rdrr.io/r/base/names.html'>names</a></span><span class='o'>(</span><span class='nv'>key</span><span class='o'>)</span> <span class='o'>==</span> <span class='s'>"aesthetic"</span><span class='o'>]</span> <span class='o'>&lt;-</span> <span class='nv'>aesthetic</span></span>
<span>    <span class='nv'>key</span></span>
<span>  <span class='o'>&#125;</span></span>
<span><span class='o'>)</span></span></code></pre>

</div>

Now we can make a guide constructor that creates a custom key to pass along on. The [`new_guide()`](https://ggplot2.tidyverse.org/reference/new_guide.html) functions instantiates a new guide with the given parameters. This function automatically rejects any parameters that are not in the class' `params` field, so it is important to declare these.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>guide_key</span> <span class='o'>&lt;-</span> <span class='kr'>function</span><span class='o'>(</span></span>
<span>  <span class='nv'>aesthetic</span>, <span class='nv'>value</span> <span class='o'>=</span> <span class='nv'>aesthetic</span>, <span class='nv'>label</span> <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/character.html'>as.character</a></span><span class='o'>(</span><span class='nv'>aesthetic</span><span class='o'>)</span>,</span>
<span>  <span class='nv'>...</span>,</span>
<span>  <span class='c'># Standard guide arguments</span></span>
<span>  <span class='nv'>theme</span> <span class='o'>=</span> <span class='kc'>NULL</span>, <span class='nv'>title</span> <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/waiver.html'>waiver</a></span><span class='o'>(</span><span class='o'>)</span>, <span class='nv'>order</span> <span class='o'>=</span> <span class='m'>0</span>, <span class='nv'>position</span> <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/waiver.html'>waiver</a></span><span class='o'>(</span><span class='o'>)</span></span>
<span><span class='o'>)</span> <span class='o'>&#123;</span></span>
<span>  </span>
<span>  <span class='nv'>key</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/data.frame.html'>data.frame</a></span><span class='o'>(</span><span class='nv'>aesthetic</span>, .value <span class='o'>=</span> <span class='nv'>value</span>, .label <span class='o'>=</span> <span class='nv'>label</span>, <span class='nv'>...</span><span class='o'>)</span></span>
<span>  </span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/new_guide.html'>new_guide</a></span><span class='o'>(</span></span>
<span>    <span class='c'># Arguments passed on to the GuideKey$params field</span></span>
<span>    key <span class='o'>=</span> <span class='nv'>key</span>, theme <span class='o'>=</span> <span class='nv'>theme</span>, title <span class='o'>=</span> <span class='nv'>title</span>, order <span class='o'>=</span> <span class='nv'>order</span>, position <span class='o'>=</span> <span class='nv'>position</span>,</span>
<span>    <span class='c'># Declare which aesthetics are supported</span></span>
<span>    available_aes <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"x"</span>, <span class='s'>"y"</span><span class='o'>)</span>,</span>
<span>    <span class='c'># Set the guide class</span></span>
<span>    super <span class='o'>=</span> <span class='nv'>GuideKey</span></span>
<span>  <span class='o'>)</span></span>
<span><span class='o'>&#125;</span></span></code></pre>

</div>

The key can now be used inside the [`guides()`](https://ggplot2.tidyverse.org/reference/guides.html) function or as the `guide` argument in a position scale.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggplot.html'>ggplot</a></span><span class='o'>(</span><span class='nv'>mpg</span>, <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/aes.html'>aes</a></span><span class='o'>(</span><span class='nv'>displ</span>, <span class='nv'>hwy</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/geom_point.html'>geom_point</a></span><span class='o'>(</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/scale_continuous.html'>scale_x_continuous</a></span><span class='o'>(</span></span>
<span>    guide <span class='o'>=</span> <span class='nf'>guide_key</span><span class='o'>(</span>aesthetic <span class='o'>=</span> <span class='m'>2</span><span class='o'>:</span><span class='m'>6</span> <span class='o'>+</span> <span class='m'>0.5</span><span class='o'>)</span></span>
<span>  <span class='o'>)</span></span>
</code></pre>
<img src="figs/key_example-1.png" alt="Scatterplot of engine displacement versus highway miles per gallon. The x-axis axis ticks are at 2.5, 3.5, 4.5, 5.5 and 6.5." width="700px" style="display: block; margin: auto;" />

</div>

If we are feeling more adventurous, we can also alter they way guides are drawn. The majority of drawing code is in the `Guide$build_*()` methods, which is all orchestrated by the `Guide$draw()` method. For derived guides, such as the custom key guide we're extending here, overriding a `Guide$build_*()` method should be sufficient. If you are writing a completely novel guide that does not resemble the structure of any existing guide, overriding the `Guide$draw()` method might be wise.

In this example, we are changing the way the labels are drawn, so we should edit the `Guide$build_labels()` method. We'll edit the method so that the labels are drawn with a `colour` set in the key. In addition to the `key` and `params` variable we've seen before, we now also have an `elements` variable, which is a list of precomputed theme elements. We can use the `elements$text` element to draw a graphical object (grob) in the style of axis text. Perhaps the most finicky thing about drawing guides is that a lot of settings depend on the guide's `position` parameter.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='c'># Same as before</span></span>
<span><span class='nv'>GuideKey</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggproto.html'>ggproto</a></span><span class='o'>(</span></span>
<span>  <span class='s'>"Guide"</span>, <span class='nv'>GuideAxis</span>,</span>
<span>  params <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='nv'>GuideAxis</span><span class='o'>$</span><span class='nv'>params</span>, <span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span>key <span class='o'>=</span> <span class='kc'>NULL</span><span class='o'>)</span><span class='o'>)</span>,</span>
<span>  extract_key <span class='o'>=</span> <span class='kr'>function</span><span class='o'>(</span><span class='nv'>scale</span>, <span class='nv'>aesthetic</span>, <span class='nv'>key</span>, <span class='nv'>...</span><span class='o'>)</span> <span class='o'>&#123;</span></span>
<span>    <span class='nv'>key</span><span class='o'>$</span><span class='nv'>aesthetic</span> <span class='o'>&lt;-</span> <span class='nv'>scale</span><span class='o'>$</span><span class='nf'>map</span><span class='o'>(</span><span class='nv'>key</span><span class='o'>$</span><span class='nv'>aesthetic</span><span class='o'>)</span></span>
<span>    <span class='nf'><a href='https://rdrr.io/r/base/names.html'>names</a></span><span class='o'>(</span><span class='nv'>key</span><span class='o'>)</span><span class='o'>[</span><span class='nf'><a href='https://rdrr.io/r/base/names.html'>names</a></span><span class='o'>(</span><span class='nv'>key</span><span class='o'>)</span> <span class='o'>==</span> <span class='s'>"aesthetic"</span><span class='o'>]</span> <span class='o'>&lt;-</span> <span class='nv'>aesthetic</span></span>
<span>    <span class='nv'>key</span></span>
<span>  <span class='o'>&#125;</span>,</span>
<span>  </span>
<span>  <span class='c'># New method to draw labels</span></span>
<span>  build_labels <span class='o'>=</span> <span class='kr'>function</span><span class='o'>(</span><span class='nv'>key</span>, <span class='nv'>elements</span>, <span class='nv'>params</span><span class='o'>)</span> <span class='o'>&#123;</span></span>
<span>    <span class='nv'>position</span> <span class='o'>&lt;-</span> <span class='nv'>params</span><span class='o'>$</span><span class='nv'>position</span></span>
<span>    <span class='c'># Downstream code expects a list of labels</span></span>
<span>    <span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span><span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element_grob.html'>element_grob</a></span><span class='o'>(</span></span>
<span>      <span class='nv'>elements</span><span class='o'>$</span><span class='nv'>text</span>,</span>
<span>      label <span class='o'>=</span> <span class='nv'>key</span><span class='o'>$</span><span class='nv'>.label</span>,</span>
<span>      x <span class='o'>=</span> <span class='kr'><a href='https://rdrr.io/r/base/switch.html'>switch</a></span><span class='o'>(</span><span class='nv'>position</span>, left <span class='o'>=</span> <span class='m'>1</span>, right <span class='o'>=</span> <span class='m'>0</span>, <span class='nv'>key</span><span class='o'>$</span><span class='nv'>x</span><span class='o'>)</span>,</span>
<span>      y <span class='o'>=</span> <span class='kr'><a href='https://rdrr.io/r/base/switch.html'>switch</a></span><span class='o'>(</span><span class='nv'>position</span>, top <span class='o'>=</span> <span class='m'>0</span>, bottom <span class='o'>=</span> <span class='m'>1</span>, <span class='nv'>key</span><span class='o'>$</span><span class='nv'>y</span><span class='o'>)</span>,</span>
<span>      margin_x <span class='o'>=</span> <span class='nv'>position</span> <span class='o'><a href='https://rdrr.io/r/base/match.html'>%in%</a></span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"left"</span>, <span class='s'>"right"</span><span class='o'>)</span>,</span>
<span>      margin_y <span class='o'>=</span> <span class='nv'>position</span> <span class='o'><a href='https://rdrr.io/r/base/match.html'>%in%</a></span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"top"</span>, <span class='s'>"bottom"</span><span class='o'>)</span>,</span>
<span>      colour <span class='o'>=</span> <span class='nv'>key</span><span class='o'>$</span><span class='nv'>colour</span></span>
<span>    <span class='o'>)</span><span class='o'>)</span></span>
<span>  <span class='o'>&#125;</span></span>
<span><span class='o'>)</span></span></code></pre>

</div>

Because we are incorporating the `...` argument to `guide_key()` in the key, adding a `colour` column to the key is straightforward. We can check that are guide looks correct in the different positions around the panel.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggplot.html'>ggplot</a></span><span class='o'>(</span><span class='nv'>mpg</span>, <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/aes.html'>aes</a></span><span class='o'>(</span><span class='nv'>displ</span>, <span class='nv'>hwy</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/geom_point.html'>geom_point</a></span><span class='o'>(</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/guides.html'>guides</a></span><span class='o'>(</span></span>
<span>    x <span class='o'>=</span> <span class='nf'>guide_key</span><span class='o'>(</span></span>
<span>      aesthetic <span class='o'>=</span> <span class='m'>2</span><span class='o'>:</span><span class='m'>6</span> <span class='o'>+</span> <span class='m'>0.5</span>,</span>
<span>      colour <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"red"</span>, <span class='s'>"grey"</span>, <span class='s'>"red"</span>, <span class='s'>"grey"</span>, <span class='s'>"red"</span><span class='o'>)</span></span>
<span>    <span class='o'>)</span>,</span>
<span>    x.sec <span class='o'>=</span> <span class='nf'>guide_key</span><span class='o'>(</span></span>
<span>      aesthetic <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='m'>2</span>, <span class='m'>4</span>, <span class='m'>6</span><span class='o'>)</span>, </span>
<span>      colour <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"tomato"</span>, <span class='s'>"limegreen"</span>, <span class='s'>"dodgerblue"</span><span class='o'>)</span></span>
<span>    <span class='o'>)</span></span>
<span>  <span class='o'>)</span></span>
</code></pre>
<img src="figs/key_example_2-1.png" alt="Scatterplot of engine displacement versus highway miles per gallon. There are two x-axes at the bottom and top of the plot. The bottom has labels alternating in red and gray, and the top has red, green and blue labels." width="700px" style="display: block; margin: auto;" />

</div>

If you feel like trying out extending guides yourself, here are some exercises to consider:

-   Extend `guide_key()` to also pass on `family`, `face` and `size` aesthetics from the key to the labels.
-   Override the `GuideKey$build_ticks()` method to also pass on `colour` and `linewidth` settings to the tick marks. Looking at `Guide$build_ticks()` is a good starting point.
-   Compare `GuideKey$extract_key()` to `Guide$extract_key()`. What steps have been skimmed over in the example?

## Acknowledgements

A heartfelt thank you to all the people who have contributed their thoughts and code to the 3.5.0 release of ggplot2!

[@aarongraybill](https://github.com/aarongraybill), [@aphalo](https://github.com/aphalo), [@ashgreat](https://github.com/ashgreat), [@banbh](https://github.com/banbh), [@benimwolfspelz](https://github.com/benimwolfspelz), [@ccsarapas](https://github.com/ccsarapas), [@danielneilson](https://github.com/danielneilson), [@danli349](https://github.com/danli349), [@davidhodge931](https://github.com/davidhodge931), [@dieghernan](https://github.com/dieghernan), [@edent](https://github.com/edent), [@eliocamp](https://github.com/eliocamp), [@f2il-kieranmace](https://github.com/f2il-kieranmace), [@garyzhubc](https://github.com/garyzhubc), [@Generalized](https://github.com/Generalized), [@giadasp](https://github.com/giadasp), [@jan-glx](https://github.com/jan-glx), [@jimjam-slam](https://github.com/jimjam-slam), [@jtlandis](https://github.com/jtlandis), [@jttoivon](https://github.com/jttoivon), [@klin333](https://github.com/klin333), [@krlmlr](https://github.com/krlmlr), [@manjumc1975](https://github.com/manjumc1975), [@math-mcshane](https://github.com/math-mcshane), [@matthewjnield](https://github.com/matthewjnield), [@mjskay](https://github.com/mjskay), [@olivroy](https://github.com/olivroy), [@paulatn240](https://github.com/paulatn240), [@retodomax](https://github.com/retodomax), [@Rong-Zh](https://github.com/Rong-Zh), [@steveharoz](https://github.com/steveharoz), [@tbates](https://github.com/tbates), [@teunbrand](https://github.com/teunbrand), [@thomasp85](https://github.com/thomasp85), [@tjebo](https://github.com/tjebo), [@vnijs](https://github.com/vnijs), [@warnes](https://github.com/warnes), [@wbvguo](https://github.com/wbvguo), [@willgearty](https://github.com/willgearty), [@Yunuuuu](https://github.com/Yunuuuu), and [@yuw444](https://github.com/yuw444).

