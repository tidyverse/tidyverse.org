---
output: hugodown::hugo_document

slug: ggplot2-3-5-0-legends
title: "ggplot2 3.5.0: Legends"
date: 2024-02-21
author: Teun van den Brand
description: >
    The 3.5.0 version of ggplot2 comes with an overhaul of the guide system.
    Read here what is new for legends.

photo:
  url: https://unsplash.com/photos/close-up-photo-of-black-camera-lens-hqCEQTc5gZA
  author: Markus Spiske

# one of: "deep-dive", "learn", "package", "programming", "roundup", or "other"
categories: [package] 
tags: [ggplot2, ggplot2-3-5-0]
rmd_hash: caf3965e0a608d20

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

We are pleased to release [ggplot2](https://ggplot2.tidyverse.org) 3.5.0. This is one blogpost among several outlining changes to legend guides. Please find the [main release post](/blog/2024/02/ggplot2-3-5-0/) to read about other changes.

Legends, alongside [axes](/blog/2024/02/ggplot2-3-5-0-axes/), are visual representations of scales and allow observes to translate graphical properties of a plot into information. To no surprise, legends in ggplot2 comprise the guides called [`guide_legend()`](https://ggplot2.tidyverse.org/reference/guide_legend.html), but also [`guide_colourbar()`](https://ggplot2.tidyverse.org/reference/guide_colourbar.html), [`guide_coloursteps()`](https://ggplot2.tidyverse.org/reference/guide_coloursteps.html) and [`guide_bins()`](https://ggplot2.tidyverse.org/reference/guide_bins.html).

## Styling

One of the more user-visible changes is that these guides no longer have styling options. Or at least, they have been soft-deprecated: they continue to work for now, but are scheduled for removal. Gone are the days where there were 4 possible ways to set the horizontal justification of legend text in 5 different functions. There is only one way to style guides now, and that is by using [`theme()`](https://ggplot2.tidyverse.org/reference/theme.html). The [`theme()`](https://ggplot2.tidyverse.org/reference/theme.html) function has new arguments to control the appearance of legends, which makes it easier to globally control the appearance of legends. For example: `theme(legend.frame)` replaces `guide_colourbar(frame.colour, frame.linewidth, frame.linetype)` and `theme(legend.axis.line)` replaces `guide_bins(axis, axis.colour, axis.linewidth, axis.arrow)`. To allow for tweaking the style of any individual guide, the guide functions now have a `theme` argument that can accept a theme specific to that guide.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://ggplot2.tidyverse.org'>ggplot2</a></span><span class='o'>)</span></span>
<span></span>
<span><span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggplot.html'>ggplot</a></span><span class='o'>(</span><span class='nv'>mpg</span>, <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/aes.html'>aes</a></span><span class='o'>(</span><span class='nv'>displ</span>, <span class='nv'>hwy</span>, shape <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/factor.html'>factor</a></span><span class='o'>(</span><span class='nv'>cyl</span><span class='o'>)</span>, colour <span class='o'>=</span> <span class='nv'>cty</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/geom_point.html'>geom_point</a></span><span class='o'>(</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='c'># Styling individual guides</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/guides.html'>guides</a></span><span class='o'>(</span></span>
<span>    shape  <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/guide_legend.html'>guide_legend</a></span><span class='o'>(</span>theme <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/theme.html'>theme</a></span><span class='o'>(</span>legend.text <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>element_text</a></span><span class='o'>(</span>colour <span class='o'>=</span> <span class='s'>"red"</span><span class='o'>)</span><span class='o'>)</span><span class='o'>)</span>,</span>
<span>    colour <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/guide_colourbar.html'>guide_colorbar</a></span><span class='o'>(</span>theme <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/theme.html'>theme</a></span><span class='o'>(</span>legend.frame <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>element_rect</a></span><span class='o'>(</span>colour <span class='o'>=</span> <span class='s'>"red"</span><span class='o'>)</span><span class='o'>)</span><span class='o'>)</span></span>
<span>  <span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='c'># Styling guides globally</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/theme.html'>theme</a></span><span class='o'>(</span></span>
<span>    legend.title.position <span class='o'>=</span> <span class='s'>"left"</span>,</span>
<span>    <span class='c'># Title justification is controlled by hjust/vjust in the element</span></span>
<span>    legend.title <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>element_text</a></span><span class='o'>(</span>angle <span class='o'>=</span> <span class='m'>90</span>, hjust <span class='o'>=</span> <span class='m'>0.5</span><span class='o'>)</span></span>
<span>  <span class='o'>)</span></span>
</code></pre>
<img src="figs/guide_theming-1.png" alt="Scatterplot of engine displacement versus highway miles per gallon. The legend indicating shapes for the number of cylinders has red text. The colour bar indicating city miles per gallon has a red rectangle around the bar. Both the legend and colour bar titles are rotated, centered and on the left of the guide." width="700px" style="display: block; margin: auto;" />

</div>

In the plot above, notice how the legend title settings affect both the colour bar and the legend, whereas the local options, like red legend text, only apply to a single guide.

## Awareness

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

## Placement

Legend positions are no longer restricted to just a single side of the plot. By setting the `position` argument of guides, you can tailor which guides appear where in the plot. Guides that do not have a position set, like the 'drv' shape legend below, follow the global theme's `legend.position` setting. If we suspend our belief in good data visualisation practice, we can showcase this as follows:

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

## Spacing and margins

In this release, the way spacing in legends work has been reworked.

-   The `legend.spacing{.x/.y}` theme setting is now used to space different guides apart. Previously, it was also used to space legend keys apart; that is no longer the case.
-   Spacing legend key-label pairs apart is now controlled by the `legend.key.spacing{.x/.y}` theme setting.
-   Spacing the labels from the keys is now controlled by the label element's `margin` argument.

Because the legend spacing and margin options can be a bit bewildering, a small overview is added below. One setting not included in the overview is `legend.spacing.x`, which only applies when `legend.box = "horizontal"`. Which exact text margin is relevant for spacing apart keys and labels, or titles and the rest of the guide, depends on the `legend.text.position` and `legend.title.position` theme elements.

<div class="highlight">

<img src="figs/spacing_overview-1.png" alt="Overview of legend spacing and margin options. Two abstract legends are placed above one another to the right of an area called 'plot'. Various arrows with labels point out different theme settings." width="700px" style="display: block; margin: auto;" />

</div>

When the titles and keys don't have explicit margins, appropriate margins are added automatically depending on the text or title position. However, if you override the margins, they will be interpreted literally.

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

## Stretching

Another experimental tweak to legends is that they can now have stretching keys (or bars). The option is still considered 'experimental' because there are some things that may go wrong. By setting the `legend.key{.height/.width}` theme argument as a `"null"` unit, legends can now expand to fill the available space.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>p</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggplot.html'>ggplot</a></span><span class='o'>(</span><span class='nv'>mpg</span>, <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/aes.html'>aes</a></span><span class='o'>(</span><span class='nv'>displ</span>, <span class='nv'>hwy</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/geom_point.html'>geom_point</a></span><span class='o'>(</span><span class='nf'><a href='https://ggplot2.tidyverse.org/reference/aes.html'>aes</a></span><span class='o'>(</span>colour <span class='o'>=</span> <span class='nv'>cty</span>, size <span class='o'>=</span> <span class='nv'>cyl</span><span class='o'>)</span>, shape <span class='o'>=</span> <span class='m'>21</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/theme.html'>theme</a></span><span class='o'>(</span>legend.key.height <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/grid/unit.html'>unit</a></span><span class='o'>(</span><span class='m'>1</span>, <span class='s'>"null"</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='nv'>p</span></span>
</code></pre>
<img src="figs/stretch_keys-1.png" alt="Scatterplot of engine displacement versus highway miles per gallon. There is a legend guide showing the point's size and a colour. Both the legend and the bar take up an approximately equal amount of space on the right-hand side of the panel." width="700px" style="display: block; margin: auto;" />

</div>

The term 'available space' is a tricky one. For starters, other legends placed in the same position take up space, as can be seen in the plot above. If your legend is the only legend in a position, more space is available and it stretches more. As you can see in the plot below, the legends are not aligned with the panel even when stretched. This is because the titles, margins and various spacings all take up space that is *not* available to stretch into.

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

## Other improvements

We welcome a new type of legend: [`guide_custom()`](https://ggplot2.tidyverse.org/reference/guide_custom.html). It can be used to add any graphical object (grob) to a plot, like [`annotation_custom()`](https://ggplot2.tidyverse.org/reference/annotation_custom.html). There are a few differences though: it is positioned just like a legend and adds titles and margins. In some sense, this guide is 'special', as it is the only guide that does not directly reflect a scale. The downside is that it cannot read properties from the plot, but the upside is that it is very flexible. Be careful when your grob does not have an absolute size, you should set the `width` and `height` arguments.

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
<span>      theme <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/theme.html'>theme</a></span><span class='o'>(</span>legend.title <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>element_text</a></span><span class='o'>(</span>hjust <span class='o'>=</span> <span class='m'>1</span><span class='o'>)</span><span class='o'>)</span>,</span>
<span>      order <span class='o'>=</span> <span class='m'>1</span></span>
<span>    <span class='o'>)</span>,</span>
<span>    colour <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/guide_legend.html'>guide_legend</a></span><span class='o'>(</span></span>
<span>      title <span class='o'>=</span> <span class='s'>"Another long title"</span>,</span>
<span>      theme <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/theme.html'>theme</a></span><span class='o'>(</span>legend.title <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>element_text</a></span><span class='o'>(</span>hjust <span class='o'>=</span> <span class='m'>0</span><span class='o'>)</span><span class='o'>)</span></span>
<span>    <span class='o'>)</span></span>
<span>  <span class='o'>)</span></span>
</code></pre>
<img src="figs/title_justification-1.png" alt="Scatterplot of engine displacement versus highway miles per gallon. The 'drv' variable has a legend that is left aligned, whereas the 'cyl' variable has a legend that is right-aligned." width="700px" style="display: block; margin: auto;" />

</div>

