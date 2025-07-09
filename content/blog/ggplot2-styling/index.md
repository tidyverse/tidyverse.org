---
output: hugodown::md_document

slug: ggplot2-styling
title: ggplot2 styling
date: 2025-01-10
author: Teun van den Brand
description: >
    A 2-3 sentence description of the post that appears on the articles page.
    This can be omitted if it would just recapitulate the title.

photo:
  url: https://unsplash.com/photos/n6vS3xlnsCc
  author: Kelley Bozarth

# one of: "deep-dive", "learn", "package", "programming", "roundup", or "other"
categories: [package] 
tags: []
rmd_hash: 5874597988675a91

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

## So you want to style your plot?

Diligently, you have read, cleaned and modelled your data. You have carefully crafted a plot that lets your data speak its story. Now it is time to polish. Now it is time to let your visualisation shine.

We will set out to illuminate how to set the stylistic finishing touches on your visualisations made with the ggplot2 package. In ggplot2, the theme system is responsible for many non-data aspects of how your plot looks. It covers anything from panels, to axes, titles and legends. Here, we'll get started with digesting important parts of the theme system. We'll start with complete themes, get into theme elements followed by how these elements are used in various parts of the plot and finish off with some tips, including how to write your own theme functions. Before we begin discussing themes, let's make an example plot that can showcase many aspects.

<div class="highlight">

</div>

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://ggplot2.tidyverse.org'>ggplot2</a></span><span class='o'>)</span></span>
<span></span>
<span><span class='nv'>p</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggplot.html'>ggplot</a></span><span class='o'>(</span><span class='nv'>mpg</span>, <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/aes.html'>aes</a></span><span class='o'>(</span><span class='nv'>displ</span>, <span class='nv'>hwy</span>, colour <span class='o'>=</span> <span class='nv'>cty</span>, shape <span class='o'>=</span> <span class='nv'>drv</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/geom_point.html'>geom_point</a></span><span class='o'>(</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/facet_grid.html'>facet_grid</a></span><span class='o'>(</span><span class='o'>~</span> <span class='nv'>year</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/labs.html'>labs</a></span><span class='o'>(</span></span>
<span>    title <span class='o'>=</span> <span class='s'>"Fuel efficiency"</span>,</span>
<span>    subtitle <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/paste.html'>paste0</a></span><span class='o'>(</span><span class='s'>"Described for "</span>, <span class='nf'><a href='https://rdrr.io/r/base/nrow.html'>nrow</a></span><span class='o'>(</span><span class='nv'>mpg</span><span class='o'>)</span>, <span class='s'>" cars from 1999 and 2008"</span><span class='o'>)</span>,</span>
<span>    caption <span class='o'>=</span> <span class='s'>"Source: U.S. Environmental Protection Agency"</span>,</span>
<span>    x <span class='o'>=</span> <span class='s'>"Engine Displacement"</span>,</span>
<span>    y <span class='o'>=</span> <span class='s'>"Highway miles per gallon"</span>,</span>
<span>    colour <span class='o'>=</span> <span class='s'>"City miles\nper gallon"</span>,</span>
<span>    shape <span class='o'>=</span> <span class='s'>"Drive train"</span></span>
<span>  <span class='o'>)</span></span>
<span></span>
<span><span class='nv'>p</span></span>
</code></pre>
<img src="figs/base_plot-1.png" width="700px" style="display: block; margin: auto;" />

</div>

## What is a theme?

In ggplot, a theme is a list of descriptions for various parts of the plot. It is where you can set the size of your titles, the colours of your panels, the thickness of your grid lines and placement of your legends.

Themes are declared using the [`theme()`](https://ggplot2.tidyverse.org/reference/theme.html) function, which populates these descriptions called 'theme elements'. Some of these elements have a predefined set of properties and can be set using the element functions, like [`element_text()`](https://ggplot2.tidyverse.org/reference/element.html). Other theme elements can take simpler values like strings, numbers or units.

Some pre-arranged collections of elements can be found in complete themes, like the iconic [`theme_gray()`](https://ggplot2.tidyverse.org/reference/ggtheme.html). These are convenient ways to quickly swap out the complete look of a plot.

## Complete themes

Let's start big and work our way through the more nitty-gritty aspects of theming plots. The most thorough way to change the styling of a single plot is to swap out the complete theme. You can do this simply by adding one of the `theme_*()` functions, like [`theme_minimal()`](https://ggplot2.tidyverse.org/reference/ggtheme.html).

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>p</span> <span class='o'>+</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggtheme.html'>theme_minimal</a></span><span class='o'>(</span><span class='o'>)</span></span>
</code></pre>
<img src="figs/example_complete-1.png" width="700px" style="display: block; margin: auto;" />

</div>

### Built-in themes

The base ggplot2 package already comes with a series of 9 built-in complete themes. For the sake of completeness about complete themes, they are displayed in the fold-out sections below. You can peruse them at your leisure to help you pick one you might like.

<p>
<details>
<summary>
<code>theme_grey()</code> (default)
</summary>

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>p</span> <span class='o'>+</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggtheme.html'>theme_grey</a></span><span class='o'>(</span><span class='o'>)</span></span>
</code></pre>
<img src="figs/complete_grey-1.png" width="700px" style="display: block; margin: auto;" />

</div>

</details>
</p>
<p>
<details>
<summary>
<code>theme_bw()</code>
</summary>

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>p</span> <span class='o'>+</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggtheme.html'>theme_bw</a></span><span class='o'>(</span><span class='o'>)</span></span>
</code></pre>
<img src="figs/complete_bw-1.png" width="700px" style="display: block; margin: auto;" />

</div>

</details>
</p>
<p>
<details>
<summary>
<code>theme_linedraw()</code>
</summary>

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>p</span> <span class='o'>+</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggtheme.html'>theme_linedraw</a></span><span class='o'>(</span><span class='o'>)</span></span>
</code></pre>
<img src="figs/complete_linedraw-1.png" width="700px" style="display: block; margin: auto;" />

</div>

</details>
</p>
<p>
<details>
<summary>
<code>theme_light()</code>
</summary>

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>p</span> <span class='o'>+</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggtheme.html'>theme_light</a></span><span class='o'>(</span><span class='o'>)</span></span>
</code></pre>
<img src="figs/complete_light-1.png" width="700px" style="display: block; margin: auto;" />

</div>

</details>
</p>
<p>
<details>
<summary>
<code>theme_dark()</code>
</summary>

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>p</span> <span class='o'>+</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggtheme.html'>theme_dark</a></span><span class='o'>(</span><span class='o'>)</span></span>
</code></pre>
<img src="figs/complete_dark-1.png" width="700px" style="display: block; margin: auto;" />

</div>

</details>
</p>
<p>
<details>
<summary>
<code>theme_minimal()</code>
</summary>

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>p</span> <span class='o'>+</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggtheme.html'>theme_minimal</a></span><span class='o'>(</span><span class='o'>)</span></span>
</code></pre>
<img src="figs/complete_minimal-1.png" width="700px" style="display: block; margin: auto;" />

</div>

</details>
</p>
<p>
<details>
<summary>
<code>theme_classic()</code>
</summary>

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>p</span> <span class='o'>+</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggtheme.html'>theme_classic</a></span><span class='o'>(</span><span class='o'>)</span></span>
</code></pre>
<img src="figs/complete_classic-1.png" width="700px" style="display: block; margin: auto;" />

</div>

</details>
</p>
<p>
<details>
<summary>
<code>theme_void()</code>
</summary>

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>p</span> <span class='o'>+</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggtheme.html'>theme_void</a></span><span class='o'>(</span><span class='o'>)</span></span>
</code></pre>
<img src="figs/complete_void-1.png" width="700px" style="display: block; margin: auto;" />

</div>

</details>
</p>
<p>
<details>
<summary>
<code>theme_test()</code>
</summary>

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>p</span> <span class='o'>+</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggtheme.html'>theme_test</a></span><span class='o'>(</span><span class='o'>)</span></span>
</code></pre>
<img src="figs/complete_test-1.png" width="700px" style="display: block; margin: auto;" />

</div>

</details>
</p>

### Additional themes

Some packages come with their own themes that you can add to your plots. For example the cowplot package has a theme that galvanises you to not use [labels that are too small](https://clauswilke.com/dataviz/small-axis-labels.html), and otherwise has a clean look.

<p>
<details>
<summary>
<code>cowplot::theme_cowplot()</code>
</summary>

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>p</span> <span class='o'>+</span> <span class='nf'>cowplot</span><span class='nf'>::</span><span class='nf'><a href='https://wilkelab.org/cowplot/reference/theme_cowplot.html'>theme_cowplot</a></span><span class='o'>(</span><span class='o'>)</span></span>
</code></pre>
<img src="figs/complete_cowplot-1.png" width="700px" style="display: block; margin: auto;" />

</div>

</details>
</p>

The ggthemes package hosts themes that reflect other popular venues of data visualisation, such as the economist or FiveThirtyEight.

<p>
<details>
<summary>
<code>ggthemes::theme_fivethirtyeight()</code>
</summary>

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>p</span> <span class='o'>+</span> <span class='nf'>ggthemes</span><span class='nf'>::</span><span class='nf'><a href='http://jrnold.github.io/ggthemes/reference/theme_fivethirtyeight.html'>theme_fivethirtyeight</a></span><span class='o'>(</span><span class='o'>)</span></span>
</code></pre>
<img src="figs/complete_ggthemes-1.png" width="700px" style="display: block; margin: auto;" />

</div>

</details>
</p>

If the moods strikes you for a more playful plot, you can use the tvthemes package to style your plot according to TV shows!

<p>
<details>
<summary>
<code>tvthemes::theme_simpsons()</code>
</summary>

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>p</span> <span class='o'>+</span> <span class='nf'>tvthemes</span><span class='nf'>::</span><span class='nf'><a href='https://rdrr.io/pkg/tvthemes/man/theme_simpsons.html'>theme_simpsons</a></span><span class='o'>(</span><span class='o'>)</span></span>
</code></pre>
<img src="figs/complete_tvthemes-1.png" width="700px" style="display: block; margin: auto;" />

</div>

</details>
</p>

Aside from these packages that live on CRAN, there are also non-CRAN packages that come with complete themes. You can visit the [extension gallery](https://exts.ggplot2.tidyverse.org/gallery/) and filter on the 'themes' tag to find more packages.

### Tweaking complete themes

The complete themes have arguments that affect multiple components across the plot. Perhaps the most well known is the `base_size` argument that globally controls the size of theme elements, ranging from the text sizes, to line widths, and ---since recently--- even point sizes.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>p</span> <span class='o'>+</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggtheme.html'>theme_bw</a></span><span class='o'>(</span>base_size <span class='o'>=</span> <span class='m'>8</span><span class='o'>)</span></span>
</code></pre>
<img src="figs/complete_base_size-1.png" width="700px" style="display: block; margin: auto;" />

</div>

A technique used to distinguish visual hierarchy is 'font pairing', meaning that you combine more than one font to convey visual hierarchy. In web design, it means displaying your headers different from your body text. In data visualisation, it can mean displaying your titles distinctly from labels. The most common pairing, and the default one baked into ggplot2, is to display titles larger than labels in the same typeface. Another popular choice is to use different weights, like 'bold' and 'plain'. It is now also easier to use different typefaces by pairing the `header_family` and the `base_family` fonts together. In the example below, we pair a serif font for headers and a sans-serif font for the rest.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>p</span> <span class='o'>+</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggtheme.html'>theme_bw</a></span><span class='o'>(</span>base_family <span class='o'>=</span> <span class='s'>"Roboto"</span>, header_family <span class='o'>=</span> <span class='s'>"Roboto Slab"</span><span class='o'>)</span></span>
</code></pre>
<img src="figs/complete_font_family-1.png" width="700px" style="display: block; margin: auto;" />

</div>

A recent addition to styling with complete themes are colour choices. The `ink` argument roughly amounts to the colour for all foreground elements, like text, lines and points. This is complemented by the `paper` argument, which affect background elements like the panels and plot background. Lastly, there is an `accent` argument which controls the display of a few specific layers, like [`geom_smooth()`](https://ggplot2.tidyverse.org/reference/geom_smooth.html) or [`geom_contour()`](https://ggplot2.tidyverse.org/reference/geom_contour.html). For some aspects of the plot, the `ink` and `paper` arguments are mixed to produce intermediate colours. As an example, when we use [`theme_bw()`](https://ggplot2.tidyverse.org/reference/ggtheme.html), the strip fill colour is a mix between the foreground and background to slightly lift this part from the background. The `ink` and `paper` arguments can also be used to quickly recolour a plot, or to convert a plot to 'dark mode' by using a light `ink` and dark `paper`.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>p</span> <span class='o'>+</span> </span>
<span>  <span class='c'># Turning off these aesthetics to prevent grouping</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/aes.html'>aes</a></span><span class='o'>(</span>shape <span class='o'>=</span> <span class='kc'>NULL</span>, colour <span class='o'>=</span> <span class='kc'>NULL</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/geom_smooth.html'>geom_smooth</a></span><span class='o'>(</span>method <span class='o'>=</span> <span class='s'>"lm"</span>, formula <span class='o'>=</span> <span class='nv'>y</span> <span class='o'>~</span> <span class='nv'>x</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggtheme.html'>theme_bw</a></span><span class='o'>(</span></span>
<span>    ink <span class='o'>=</span> <span class='s'>"#BBBBBB"</span>, </span>
<span>    paper <span class='o'>=</span> <span class='s'>"#333333"</span>, </span>
<span>    accent <span class='o'>=</span> <span class='s'>"red"</span></span>
<span>  <span class='o'>)</span></span>
</code></pre>
<img src="figs/complete_ink_paper-1.png" width="700px" style="display: block; margin: auto;" />

</div>

## Theme elements

Rather than swapping out complete themes in one fell swoop, themes can also be tweaked to various degrees. In ggplot2, themes are a collection of theme elements, where an element describes a property, or set of properties, for a part of the theme.

### Element functions

The documentation in `?theme()` will tell you what type of input each theme element will expect. Some theme elements just expect scalar values and not collections of properties. You can simply set these in the theme directly. For example, we all know that the golden ratio is the best ratio, so we can use it in our plot as follows:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>phi</span> <span class='o'>&lt;-</span> <span class='o'>(</span><span class='m'>1</span> <span class='o'>+</span> <span class='nf'><a href='https://rdrr.io/r/base/MathFun.html'>sqrt</a></span><span class='o'>(</span><span class='m'>5</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>/</span> <span class='m'>2</span></span>
<span><span class='nv'>p</span> <span class='o'>+</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/theme.html'>theme</a></span><span class='o'>(</span>aspect.ratio <span class='o'>=</span> <span class='nv'>phi</span><span class='o'>)</span></span>
</code></pre>
<img src="figs/aspect_ratio-1.png" width="700px" style="display: block; margin: auto;" />

</div>

In the cases where a cohesive set of properties serves as a theme element, ggplot2 has `element_*()` functions. One of the simpler elements is [`element_line()`](https://ggplot2.tidyverse.org/reference/element.html) and we can declare a new set of line properties as follows:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>red_line</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>element_line</a></span><span class='o'>(</span>colour <span class='o'>=</span> <span class='s'>"red"</span>, linewidth <span class='o'>=</span> <span class='m'>2</span><span class='o'>)</span></span>
<span><span class='nv'>red_line</span></span>
<span><span class='c'>#&gt; &lt;ggplot2::element_line&gt;</span></span>
<span><span class='c'>#&gt;  @ colour       : chr "red"</span></span>
<span><span class='c'>#&gt;  @ linewidth    : num 2</span></span>
<span><span class='c'>#&gt;  @ linetype     : NULL</span></span>
<span><span class='c'>#&gt;  @ lineend      : NULL</span></span>
<span><span class='c'>#&gt;  @ linejoin     : NULL</span></span>
<span><span class='c'>#&gt;  @ arrow        : logi FALSE</span></span>
<span><span class='c'>#&gt;  @ arrow.fill   : chr "red"</span></span>
<span><span class='c'>#&gt;  @ inherit.blank: logi FALSE</span></span>
<span></span></code></pre>

</div>

These elements can then be given to the [`theme()`](https://ggplot2.tidyverse.org/reference/theme.html) function to assign these properties to a specific part of the theme, like the `axis.line` in this example.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>p</span> <span class='o'>+</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/theme.html'>theme</a></span><span class='o'>(</span>axis.line <span class='o'>=</span> <span class='nv'>red_line</span><span class='o'>)</span></span>
</code></pre>
<img src="figs/red_axis-1.png" width="700px" style="display: block; margin: auto;" />

</div>

Below is an overview of elements and some common places where they are used:

<div class="highlight">

| Element             | Description                                       |
|:--------------------|:--------------------------------------------------|
| [`element_blank()`](https://ggplot2.tidyverse.org/reference/element.html)   | Indicator to skip drawing an element.             |
| [`element_line()`](https://ggplot2.tidyverse.org/reference/element.html)    | Used for axis lines, grid lines and tick marks.   |
| [`element_rect()`](https://ggplot2.tidyverse.org/reference/element.html)    | Used for (panel) backgrounds, borders and strips. |
| [`element_text()`](https://ggplot2.tidyverse.org/reference/element.html)    | Used for (sub)titles, labels, captions.           |
| [`element_geom()`](https://ggplot2.tidyverse.org/reference/element.html)    | Used to set default properties of layers.         |
| [`element_polygon()`](https://ggplot2.tidyverse.org/reference/element.html) | Not used, but provided for reasons of extension.  |
| [`element_point()`](https://ggplot2.tidyverse.org/reference/element.html)   | Not used, but provided for reasons of extension.  |

</div>

In addition to these elements in ggplot2, extension packages can also define custom elements. Generally speaking, these elements are variants of the elements listed above and often have slightly different properties and are rendered differently. For example [`ggtext::element_markdown()`](https://wilkelab.org/ggtext/reference/element_markdown.html) is a subclass of [`element_text()`](https://ggplot2.tidyverse.org/reference/element.html), but interprets the provided text as markdown. It applies some html tags like `<b>` for bold and `<i>` for italic when rendering the text. Another example is [`ggh4x::element_part_rect()`](https://teunbrand.github.io/ggh4x/reference/element_part_rect.html) that can draw a subset of rectangle borders.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>p</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/labs.html'>labs</a></span><span class='o'>(</span>title <span class='o'>=</span> <span class='s'>"&lt;b&gt;Fuel&lt;/b&gt; &lt;i&gt;efficiency&lt;/i&gt;"</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/theme.html'>theme</a></span><span class='o'>(</span></span>
<span>    plot.title <span class='o'>=</span> <span class='nf'>ggtext</span><span class='nf'>::</span><span class='nf'><a href='https://wilkelab.org/ggtext/reference/element_markdown.html'>element_markdown</a></span><span class='o'>(</span><span class='o'>)</span>,</span>
<span>    strip.background <span class='o'>=</span> <span class='nf'>ggh4x</span><span class='nf'>::</span><span class='nf'><a href='https://teunbrand.github.io/ggh4x/reference/element_part_rect.html'>element_part_rect</a></span><span class='o'>(</span>colour <span class='o'>=</span> <span class='s'>"black"</span>, side <span class='o'>=</span> <span class='s'>"b"</span><span class='o'>)</span></span>
<span>  <span class='o'>)</span></span>
</code></pre>
<img src="figs/element_markdown-1.png" width="700px" style="display: block; margin: auto;" />

</div>

### Hierarchy and inheritance

Most theme elements are hierarchical. At the root, they are broadly applicable and change large parts of the plot. At leaves, they are very specific and allow fine grained control. Travelling from roots to leaves, properties of theme elements are inherited from parent to child. Some inheritance is very direct, where leaves directly inherit from roots (for example `legend.text`). Other times, inheritance is more arduous, like for `axis.minor.ticks.y.left`: it inherits from `axis.ticks.y.left`, which inherits from `axis.ticks.y`, which inherits from `axis.ticks`, which finally inherits from `line`. Most often, elements only have a single parent, but there are exceptions so the inheritance of theme elements is not strictly a directed acyclic graph.

In the example below we set the root `text` element to red text. This is applied (almost) universally to all text in the plot. We also set the font of the leaf `legend.text` element. We see that not only has the legend text font changed, but it is red as well because of the root `text` element.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>p</span> <span class='o'>+</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/theme.html'>theme</a></span><span class='o'>(</span></span>
<span>  <span class='c'># A root element</span></span>
<span>  text <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>element_text</a></span><span class='o'>(</span>colour <span class='o'>=</span> <span class='s'>"red"</span><span class='o'>)</span>,</span>
<span>  <span class='c'># A leaf element</span></span>
<span>  legend.text <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>element_text</a></span><span class='o'>(</span>family <span class='o'>=</span> <span class='s'>"impact"</span><span class='o'>)</span></span>
<span><span class='o'>)</span></span>
</code></pre>
<img src="figs/root_leaves-1.png" width="700px" style="display: block; margin: auto;" />

</div>

However, the keen eye spots that the strip text and axis text are *not* red. This is because in the line of succession, an ancestor declared a different colour property for the text, which overrules the colour property descending from the root `text` element. In these specific cases, the deviating ancestors are `axis.text` and `strip.text`.

When we inspect the contents of a theme element, we may find that the elements are `NULL`. This is simply an indicator that this element will inherit from its ancestor *in toto*. Another possibility is that some properties of an element are `NULL`. A `NULL` property means that the property will be inherited from the parent. When we truly want to know what properties are taken to display a theme element, we can use the [`calc_element()`](https://ggplot2.tidyverse.org/reference/calc_element.html) function to resolve the inheritance and populate all the fields.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='c'># Will inherit entirely from parent</span></span>
<span><span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggtheme.html'>theme_gray</a></span><span class='o'>(</span><span class='o'>)</span><span class='o'>$</span><span class='nv'>axis.ticks.x.bottom</span></span>
<span><span class='c'>#&gt; NULL</span></span>
<span></span><span></span>
<span><span class='c'># The element is incomplete</span></span>
<span><span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggtheme.html'>theme_gray</a></span><span class='o'>(</span><span class='o'>)</span><span class='o'>$</span><span class='nv'>axis.ticks</span></span>
<span><span class='c'>#&gt; &lt;ggplot2::element_line&gt;</span></span>
<span><span class='c'>#&gt;  @ colour       : chr "#333333FF"</span></span>
<span><span class='c'>#&gt;  @ linewidth    : NULL</span></span>
<span><span class='c'>#&gt;  @ linetype     : NULL</span></span>
<span><span class='c'>#&gt;  @ lineend      : NULL</span></span>
<span><span class='c'>#&gt;  @ linejoin     : NULL</span></span>
<span><span class='c'>#&gt;  @ arrow        : logi FALSE</span></span>
<span><span class='c'>#&gt;  @ arrow.fill   : chr "#333333FF"</span></span>
<span><span class='c'>#&gt;  @ inherit.blank: logi TRUE</span></span>
<span></span><span></span>
<span><span class='c'># Proper way to access the properties of an element</span></span>
<span><span class='nf'><a href='https://ggplot2.tidyverse.org/reference/calc_element.html'>calc_element</a></span><span class='o'>(</span><span class='s'>"axis.ticks.x.bottom"</span>, <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggtheme.html'>theme_gray</a></span><span class='o'>(</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; &lt;ggplot2::element_line&gt;</span></span>
<span><span class='c'>#&gt;  @ colour       : chr "#333333FF"</span></span>
<span><span class='c'>#&gt;  @ linewidth    : num 0.5</span></span>
<span><span class='c'>#&gt;  @ linetype     : num 1</span></span>
<span><span class='c'>#&gt;  @ lineend      : chr "butt"</span></span>
<span><span class='c'>#&gt;  @ linejoin     : chr "round"</span></span>
<span><span class='c'>#&gt;  @ arrow        : logi FALSE</span></span>
<span><span class='c'>#&gt;  @ arrow.fill   : chr "#333333FF"</span></span>
<span><span class='c'>#&gt;  @ inherit.blank: logi TRUE</span></span>
<span></span></code></pre>

</div>

The [`?theme`](https://ggplot2.tidyverse.org/reference/theme.html) documentation often tells you how the elements inherit and [`calc_element()`](https://ggplot2.tidyverse.org/reference/calc_element.html) will resolve it for you. If, for some reason, you need programmatic access to the inheritance tree, you can use [`get_element_tree()`](https://ggplot2.tidyverse.org/reference/register_theme_elements.html). Let's say you want to find out exactly why theme inheritance is not a directed acyclic graph. The resulting object is the internal structure ggplot2 uses to resolve inheritance and has an `inherit` field for every element that discerns its direct parent.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>tree</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/register_theme_elements.html'>get_element_tree</a></span><span class='o'>(</span><span class='o'>)</span></span>
<span><span class='nv'>tree</span><span class='o'>$</span><span class='nv'>axis.line.x.bottom</span><span class='o'>$</span><span class='nv'>inherit</span></span>
<span><span class='c'>#&gt; [1] "axis.line.x"</span></span>
<span></span></code></pre>

</div>

## Anatomy of a theme

<div class="highlight">

</div>

The [`theme()`](https://ggplot2.tidyverse.org/reference/theme.html) function has a lot of arguments and can be a bit overwhelming to parse in one take. At the time of writing, it has 147 arguments and `...` is obfuscating additional optional. Because we like structure rather than chaos, let us try to digest the [`theme()`](https://ggplot2.tidyverse.org/reference/theme.html) function one bite at a time. Much of the theme has been divided over parts in the `theme_sub_*()` family of functions. This family are just simple shortcuts. For example the `theme_sub_axis(title)` argument, populates the `axis.title` element.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://ggplot2.tidyverse.org/reference/subtheme.html'>theme_sub_axis</a></span><span class='o'>(</span>title <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>element_blank</a></span><span class='o'>(</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; &lt;theme&gt; List of 1</span></span>
<span><span class='c'>#&gt;  $ axis.title: &lt;ggplot2::element_blank&gt;</span></span>
<span><span class='c'>#&gt;  @ complete: logi FALSE</span></span>
<span><span class='c'>#&gt;  @ validate: logi TRUE</span></span>
<span></span></code></pre>

</div>

If you're redefining a series of related settings, it can be beneficial to use the `theme_sub_*()`. One benefit is brevity. For example, if you want to tweak the left y-axis a lot, it can be terser to use `theme_sub_axis_left(title, text, ticks)` rather than `theme(axis.title.y.left, axis.text.y.left, axis.ticks.y.left)`. The second benefit is that it helps organising your theme, preserving a shred of sanity while hatching your plots.

### Whole plot

There are a series of mostly textual theme elements that mostly display outside the plot itself. Using the [`theme_sub_plot()`](https://ggplot2.tidyverse.org/reference/subtheme.html) function, we can omit the `plot` prefix in the settings. We can us it to control the background, as well as the titles, caption and tag text and their placement. In the plot below, we're tweaking these settings to show the scope. Note that the text (except for the tag) is now aligned across the plot as a whole, rather than aligned with the panels.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>p</span> <span class='o'>+</span> </span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/labs.html'>labs</a></span><span class='o'>(</span>tag <span class='o'>=</span> <span class='s'>"A"</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/subtheme.html'>theme_sub_plot</a></span><span class='o'>(</span></span>
<span>    <span class='c'># Adjust the background colour</span></span>
<span>    background <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>element_rect</a></span><span class='o'>(</span>fill <span class='o'>=</span> <span class='s'>"cornsilk"</span><span class='o'>)</span>,</span>
<span>    </span>
<span>    <span class='c'># Align title and subtitle to plot instead of panels</span></span>
<span>    title <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>element_text</a></span><span class='o'>(</span>hjust <span class='o'>=</span> <span class='m'>0</span><span class='o'>)</span>, <span class='c'># default,</span></span>
<span>    subtitle <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>element_text</a></span><span class='o'>(</span>colour <span class='o'>=</span> <span class='s'>"dodgerblue"</span><span class='o'>)</span>,</span>
<span>    title.position <span class='o'>=</span> <span class='s'>"plot"</span>, </span>
<span>    </span>
<span>    <span class='c'># Align caption to plot instead of panels</span></span>
<span>    caption <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>element_text</a></span><span class='o'>(</span>hjust <span class='o'>=</span> <span class='m'>1</span><span class='o'>)</span>, <span class='c'># default</span></span>
<span>    caption.position <span class='o'>=</span> <span class='s'>"plot"</span>,</span>
<span>    </span>
<span>    <span class='c'># Place the tag in the top right of the panels instead of top left of plot</span></span>
<span>    tag.position <span class='o'>=</span> <span class='s'>"topright"</span>,</span>
<span>    tag.location <span class='o'>=</span> <span class='s'>"panel"</span></span>
<span>  <span class='o'>)</span></span>
</code></pre>
<img src="figs/sub_plot-1.png" width="700px" style="display: block; margin: auto;" />

</div>

### Panels

An important aspect of the panels are the grid lines. The grid lines follow the major and minor breaks of the scale, which is also the major distinction in how they are displayed. The next distinction is whether the lines are horizontal and mark breaks vertically (`y`) or the lines are vertical and mark breaks horizontally (`x`).

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>p</span> <span class='o'>+</span> </span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/subtheme.html'>theme_sub_panel</a></span><span class='o'>(</span></span>
<span>    <span class='c'># Extra space between panels</span></span>
<span>    spacing.x <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/grid/unit.html'>unit</a></span><span class='o'>(</span><span class='m'>1</span>, <span class='s'>"cm"</span><span class='o'>)</span>,</span>
<span>    </span>
<span>    <span class='c'># Tweaking all the grid elements</span></span>
<span>    grid <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>element_line</a></span><span class='o'>(</span>colour <span class='o'>=</span> <span class='s'>"grey80"</span><span class='o'>)</span>,</span>
<span>    </span>
<span>    <span class='c'># Turning off the minor grid elements</span></span>
<span>    grid.minor <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>element_blank</a></span><span class='o'>(</span><span class='o'>)</span>,</span>
<span>    </span>
<span>    <span class='c'># Tweak the major x/y lines separately</span></span>
<span>    grid.major.x <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>element_line</a></span><span class='o'>(</span>linetype <span class='o'>=</span> <span class='s'>"dotted"</span><span class='o'>)</span>,</span>
<span>    grid.major.y <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>element_line</a></span><span class='o'>(</span>colour <span class='o'>=</span> <span class='s'>"white"</span><span class='o'>)</span></span>
<span>  <span class='o'>)</span></span>
</code></pre>
<img src="figs/sub_panel-1.png" width="700px" style="display: block; margin: auto;" />

</div>

Besides grid lines, also the border and the background are important for the panel styling. They can be confusing because they are similar, but not identical. Notably, the panel background is underneath the data (unless `ontop = TRUE`), while the panel border is on top of the panel. You can see this in the plot below, because the white grid lines are visible over the blue background, but not over the red border.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>p</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/subtheme.html'>theme_sub_panel</a></span><span class='o'>(</span></span>
<span>    background <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>element_rect</a></span><span class='o'>(</span>fill <span class='o'>=</span> <span class='s'>"cornsilk"</span>, colour <span class='o'>=</span> <span class='s'>"blue"</span>, linewidth <span class='o'>=</span> <span class='m'>6</span><span class='o'>)</span>,</span>
<span>    border     <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>element_rect</a></span><span class='o'>(</span>colour <span class='o'>=</span> <span class='s'>"red"</span>, linewidth <span class='o'>=</span> <span class='m'>3</span>, fill <span class='o'>=</span> <span class='s'>"black"</span><span class='o'>)</span>,</span>
<span>  <span class='o'>)</span></span>
</code></pre>
<img src="figs/sub_panel_border_background-1.png" width="700px" style="display: block; margin: auto;" />

</div>

Both the background and the border are clipped by the coordinate systems clipping setting, e.g. `coord_cartesian(clip)`. It should also be noted that any `fill` property set on the border is ignored. Moreover, the legend key background takes on the appearance of the panel background by default, which is why the 'Drive train' legend is affected too.

A recent improvement is also that we can set the panel size via the theme. The `panel.widths` and `panel.heights` arguments take a unit (vector) and set the panels to this size. If you are trying to coordinate panel sizes with [`ggsave()`](https://ggplot2.tidyverse.org/reference/ggsave.html), please mind that other plot components, like axes, titles and legends also take up additional space. If you have more than one panel in the vertical or horizontal direction, you can use a vector of units as demonstrated below for `widths`.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>p</span> <span class='o'>+</span> </span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/subtheme.html'>theme_sub_panel</a></span><span class='o'>(</span></span>
<span>    widths <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/grid/unit.html'>unit</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='m'>3</span>, <span class='m'>5</span><span class='o'>)</span>, <span class='s'>"cm"</span><span class='o'>)</span>,</span>
<span>    heights <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/grid/unit.html'>unit</a></span><span class='o'>(</span><span class='m'>4</span>, <span class='s'>"cm"</span><span class='o'>)</span></span>
<span>  <span class='o'>)</span></span>
</code></pre>
<img src="figs/sub_panel_size-1.png" width="700px" style="display: block; margin: auto;" />

</div>

It is also possible to set the total size of panels. In the example above we can use `widths = unit(c(3, 3), "cm")` to have each panel be 3 centimetres wide, separated by a gap determined by the `panel.spacing.x` setting. If we instead had used `widths = unit(6, "cm")` each panel would be smaller than 3 centimetres because the `panel.spacing.x` is included.

### Strips

The display text in strips is formatted by the `labeller` argument in the facets. Styling this piece of text can be done with the [`theme_sub_strip()`](https://ggplot2.tidyverse.org/reference/subtheme.html) function, which replaces the `strip` prefix in [`theme()`](https://ggplot2.tidyverse.org/reference/theme.html). Similar to axes, strips also have positional variants with `background.x` and `background.y` specifying the backgrounds for horizontal and vertical strips specifically.

The text even has specific `text.x.bottom`, `text.x.top`, `text.y.left` and `text.y.right` variants. This allows text on the left to be rotated 90&deg, while text on the right is rotated -90&deg, which gives the sense that the text faces the panels. Out of principle, you could force the `text.x.bottom` to be rotated 180° to achieve the same sense for horizontal text, but you may find out why readability trumps consistency.

Another important distinction is the `placement` option, which affects how strips are displayed when they clash with axes. This author personally thinks that `placement = "outside"` is the wiser choice 99% of the time. When strips are displayed outside of axes, the `switch.pad.grid`/`switch.pad.wrap` elements control the spacing.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='c'># We're including a labeller to showcase formatting</span></span>
<span><span class='nv'>my_labeller</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/as_labeller.html'>as_labeller</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span>`1999` <span class='o'>=</span> <span class='s'>"The Nineties"</span>, `2008` <span class='o'>=</span> <span class='s'>"The Noughties"</span>, </span>
<span>                             V <span class='o'>=</span> <span class='s'>"Vertical Strip"</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='nv'>p</span> <span class='o'>+</span> </span>
<span>  <span class='c'># Using a dummy strip for the vertical direction</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/facet_grid.html'>facet_grid</a></span><span class='o'>(</span><span class='s'>"V"</span> <span class='o'>~</span> <span class='nv'>year</span>, labeller <span class='o'>=</span> <span class='nv'>my_labeller</span>, switch <span class='o'>=</span> <span class='s'>"x"</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/subtheme.html'>theme_sub_strip</a></span><span class='o'>(</span></span>
<span>    <span class='c'># All strip backgrounds</span></span>
<span>    background <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>element_rect</a></span><span class='o'>(</span>fill <span class='o'>=</span> <span class='s'>"cornsilk"</span><span class='o'>)</span>,</span>
<span>    <span class='c'># Specifically the horizontal strips</span></span>
<span>    background.x <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>element_rect</a></span><span class='o'>(</span>colour <span class='o'>=</span> <span class='s'>"black"</span>, linewidth <span class='o'>=</span> <span class='m'>1</span><span class='o'>)</span>,</span>
<span>    <span class='c'># Tweak text, specifically for the bottom strip</span></span>
<span>    text.x.bottom <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>element_text</a></span><span class='o'>(</span>size <span class='o'>=</span> <span class='m'>16</span><span class='o'>)</span>,</span>
<span>    </span>
<span>    placement <span class='o'>=</span> <span class='s'>"outside"</span>,</span>
<span>    <span class='c'># Spacing in between axes and strips. Note that it doesn't affect the </span></span>
<span>    <span class='c'># vertical strip that doesn't have an axis.</span></span>
<span>    switch.pad.grid <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/grid/unit.html'>unit</a></span><span class='o'>(</span><span class='m'>1</span>, <span class='s'>"cm"</span><span class='o'>)</span>,</span>
<span>    clip <span class='o'>=</span> <span class='s'>"off"</span></span>
<span>  <span class='o'>)</span></span>
</code></pre>
<img src="figs/sub_strip-1.png" width="700px" style="display: block; margin: auto;" />

</div>

The `clip = "on"` setting is the default and causes the strip border to be flush with the panel borders. By turning the clipping off, the strip border bleeds out, but it also allows text to exceed the boundaries.

### Axes

Perhaps the most involved theme elements are the axis elements. They have the longest chain of inheritance of all elements and have variants for every side of the plot.

Let's start from the top and work our way down. The [`theme_sub_axis()`](https://ggplot2.tidyverse.org/reference/subtheme.html) function lets you tweak all the axes at once. Note that the axis line now appears in the left and bottom axes.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='c'># Turn on all lines</span></span>
<span><span class='nv'>p</span> <span class='o'>+</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/subtheme.html'>theme_sub_axis</a></span><span class='o'>(</span>line <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>element_line</a></span><span class='o'>(</span><span class='o'>)</span><span class='o'>)</span></span>
</code></pre>
<img src="figs/sub_axis-1.png" width="700px" style="display: block; margin: auto;" />

</div>

To control the directions separately, you can use the [`theme_sub_axis_x()`](https://ggplot2.tidyverse.org/reference/subtheme.html) and [`theme_sub_axis_y()`](https://ggplot2.tidyverse.org/reference/subtheme.html) functions.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>p</span> <span class='o'>+</span></span>
<span>  <span class='c'># Turn on horizontal line</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/subtheme.html'>theme_sub_axis_x</a></span><span class='o'>(</span>line <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>element_line</a></span><span class='o'>(</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='c'># Turn off ticks for vertical</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/subtheme.html'>theme_sub_axis_y</a></span><span class='o'>(</span>ticks <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>element_blank</a></span><span class='o'>(</span><span class='o'>)</span><span class='o'>)</span></span>
</code></pre>
<img src="figs/sub_axis_xy-1.png" width="700px" style="display: block; margin: auto;" />

</div>

If you are dealing with secondary axes, or you have placed your primary axes in unorthodox positions, you might find use in the even more granular `theme_sub_axis_*()` functions for the top, left, bottom and right positions.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>p</span> <span class='o'>+</span></span>
<span>  <span class='c'># Extra axes</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/guides.html'>guides</a></span><span class='o'>(</span>x.sec <span class='o'>=</span> <span class='s'>"axis"</span>, y.sec <span class='o'>=</span> <span class='s'>"axis"</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='c'># Turning off ticks</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/subtheme.html'>theme_sub_axis_bottom</a></span><span class='o'>(</span>ticks <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>element_blank</a></span><span class='o'>(</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='c'># Extra long, coloured ticks</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/subtheme.html'>theme_sub_axis_top</a></span><span class='o'>(</span></span>
<span>    ticks.length <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/grid/unit.html'>unit</a></span><span class='o'>(</span><span class='m'>5</span>, <span class='s'>"mm"</span><span class='o'>)</span>,</span>
<span>    ticks <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>element_line</a></span><span class='o'>(</span>colour <span class='o'>=</span> <span class='s'>"red"</span><span class='o'>)</span></span>
<span>  <span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='c'># Extra spacing</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/subtheme.html'>theme_sub_axis_left</a></span><span class='o'>(</span>text <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>element_text</a></span><span class='o'>(</span>margin <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>margin_auto</a></span><span class='o'>(</span><span class='m'>10</span><span class='o'>)</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='c'># Turning on the axis line</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/subtheme.html'>theme_sub_axis_right</a></span><span class='o'>(</span>line <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>element_line</a></span><span class='o'>(</span><span class='o'>)</span><span class='o'>)</span></span>
</code></pre>
<img src="figs/sub_axis_positions-1.png" width="700px" style="display: block; margin: auto;" />

</div>

In addition to being globally controlled by the theme, axes are guides that can also be locally controlled by their `guide_axis(theme)` argument. The same theme elements apply, but they are accessed from the local theme that masks the global theme. Note that besides from the colour changing, there is now also an axis line because the local [`theme_classic()`](https://ggplot2.tidyverse.org/reference/ggtheme.html) draws axis lines.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>red_axis</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/guide_axis.html'>guide_axis</a></span><span class='o'>(</span>theme <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggtheme.html'>theme_classic</a></span><span class='o'>(</span>ink <span class='o'>=</span> <span class='s'>"red"</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='nv'>p</span> <span class='o'>+</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/guides.html'>guides</a></span><span class='o'>(</span>x <span class='o'>=</span> <span class='nv'>red_axis</span><span class='o'>)</span></span>
</code></pre>
<img src="figs/axis_local_theme-1.png" width="700px" style="display: block; margin: auto;" />

</div>

### Legend

While the legend inheritance is typically straightforward, it can be a challenge to get these right. To chop this problem in smaller pieces, we can separate the so called 'guide box' from the legend guides themselves.

#### Guide box

The guide box is a container for guides and is responsible for the placement and arrangement of its contents.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>p</span> <span class='o'>+</span> </span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/subtheme.html'>theme_sub_legend</a></span><span class='o'>(</span></span>
<span>    <span class='c'># Showing the box</span></span>
<span>    box.background <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>element_rect</a></span><span class='o'>(</span>fill <span class='o'>=</span> <span class='s'>"cornsilk"</span><span class='o'>)</span>,</span>
<span>    </span>
<span>    <span class='c'># Put legends on the left</span></span>
<span>    position <span class='o'>=</span> <span class='s'>"left"</span>,</span>
<span>    </span>
<span>    <span class='c'># Arrange legends horizontally</span></span>
<span>    box <span class='o'>=</span> <span class='s'>"horizontal"</span>,</span>
<span>    </span>
<span>    <span class='c'># Align to legend box to top</span></span>
<span>    justification <span class='o'>=</span> <span class='s'>"top"</span>,</span>
<span>    <span class='c'># location = "plot",</span></span>
<span>    <span class='c'># But align legends within the box at the bottom</span></span>
<span>    box.just <span class='o'>=</span> <span class='s'>"bottom"</span>,</span>
<span>    </span>
<span>    <span class='c'># Spacings and margins</span></span>
<span>    box.margin <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>margin_auto</a></span><span class='o'>(</span><span class='m'>5</span><span class='o'>)</span>,</span>
<span>    box.spacing <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/grid/unit.html'>unit</a></span><span class='o'>(</span><span class='m'>1</span>, <span class='s'>"cm"</span><span class='o'>)</span></span>
<span>  <span class='o'>)</span></span>
</code></pre>
<img src="figs/sub_legend_guidebox-1.png" width="700px" style="display: block; margin: auto;" />

</div>

Legend boxes can be split up by manually specifying the `position` argument in guides. You cannot tweak every box setting for every position independently. However, the boxes can be justified individually.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>p</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/guides.html'>guides</a></span><span class='o'>(</span>shape <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/guide_legend.html'>guide_legend</a></span><span class='o'>(</span>position <span class='o'>=</span> <span class='s'>"left"</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/subtheme.html'>theme_sub_legend</a></span><span class='o'>(</span></span>
<span>    <span class='c'># Showing the boxes</span></span>
<span>    box.background <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>element_rect</a></span><span class='o'>(</span>fill <span class='o'>=</span> <span class='s'>"cornsilk"</span><span class='o'>)</span>,</span>
<span>    box.margin <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>margin_auto</a></span><span class='o'>(</span><span class='m'>5</span><span class='o'>)</span>,</span>
<span>    </span>
<span>    <span class='c'># Tweaking the justification per position</span></span>
<span>    justification.left <span class='o'>=</span> <span class='s'>"top"</span>,</span>
<span>    justification.right <span class='o'>=</span> <span class='s'>"bottom"</span></span>
<span>  <span class='o'>)</span></span>
</code></pre>
<img src="figs/sub_legend_guidebox_position-1.png" width="700px" style="display: block; margin: auto;" />

</div>

#### General legend guides

Moving on from guide boxes to the guides themselves; There are some theme settings that (almost) universally affect any guides, regardless of [`guide_legend()`](https://ggplot2.tidyverse.org/reference/guide_legend.html), [`guide_colourbar()`](https://ggplot2.tidyverse.org/reference/guide_colourbar.html), or [`guide_bins()`](https://ggplot2.tidyverse.org/reference/guide_bins.html). These settings pertain to the legend background, margins, labels and titles and their placement and key sizes.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>p</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/subtheme.html'>theme_sub_legend</a></span><span class='o'>(</span></span>
<span>    <span class='c'># Give guides a wider background</span></span>
<span>    background <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>element_rect</a></span><span class='o'>(</span>fill <span class='o'>=</span> <span class='s'>"cornsilk"</span><span class='o'>)</span>,</span>
<span>    margin <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>margin_auto</a></span><span class='o'>(</span><span class='m'>5</span>, unit <span class='o'>=</span> <span class='s'>"mm"</span><span class='o'>)</span>,</span>
<span>    </span>
<span>    <span class='c'># Display legend titles to the right of the guide</span></span>
<span>    title <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>element_text</a></span><span class='o'>(</span>angle <span class='o'>=</span> <span class='m'>270</span><span class='o'>)</span>,</span>
<span>    title.position <span class='o'>=</span> <span class='s'>"right"</span>,</span>
<span>    </span>
<span>    <span class='c'># Display red labels to the left of the keys</span></span>
<span>    text <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>element_text</a></span><span class='o'>(</span>colour <span class='o'>=</span> <span class='s'>"red"</span><span class='o'>)</span>,</span>
<span>    text.position <span class='o'>=</span> <span class='s'>"left"</span>,</span>
<span>    </span>
<span>    <span class='c'># Set smaller keys</span></span>
<span>    key.width <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/grid/unit.html'>unit</a></span><span class='o'>(</span><span class='m'>5</span>, <span class='s'>"mm"</span><span class='o'>)</span>,</span>
<span>    key.height <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/grid/unit.html'>unit</a></span><span class='o'>(</span><span class='m'>5</span>, <span class='s'>"mm"</span><span class='o'>)</span></span>
<span>  <span class='o'>)</span></span>
</code></pre>
<img src="figs/sub_legend_general-1.png" width="700px" style="display: block; margin: auto;" />

</div>

#### Legend guide

There are also settings that affect [`guide_legend()`](https://ggplot2.tidyverse.org/reference/guide_legend.html) but not [`guide_colourbar()`](https://ggplot2.tidyverse.org/reference/guide_colourbar.html). Most of these have to do with the arrangement of keys, like their spacing, justification or fill order (by row or column). The `legend.key.justification` setting only matters when the text size exceeds the key size. If we remove that setting from the plot below, the keys will fill up to fit the space.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>p</span> <span class='o'>+</span> </span>
<span>  <span class='c'># Set two columns and long label text</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/scale_shape.html'>scale_shape_discrete</a></span><span class='o'>(</span></span>
<span>    labels <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"4\nwheel\ndrive"</span>, <span class='s'>"front\nwheel\ndrive"</span>, <span class='s'>"rear\nwheel\ndrive"</span><span class='o'>)</span>,</span>
<span>    guide <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/guide_legend.html'>guide_legend</a></span><span class='o'>(</span>ncol <span class='o'>=</span> <span class='m'>2</span><span class='o'>)</span></span>
<span>  <span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/subtheme.html'>theme_sub_legend</a></span><span class='o'>(</span></span>
<span>    <span class='c'># Fill items in grid in a row-wise fashion</span></span>
<span>    byrow <span class='o'>=</span> <span class='kc'>TRUE</span>,</span>
<span>    <span class='c'># Increase spacing between keys</span></span>
<span>    key.spacing.y <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/grid/unit.html'>unit</a></span><span class='o'>(</span><span class='m'>5</span>, <span class='s'>"mm"</span><span class='o'>)</span>,</span>
<span>    key.spacing.x <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/grid/unit.html'>unit</a></span><span class='o'>(</span><span class='m'>5</span>, <span class='s'>"mm"</span><span class='o'>)</span>,</span>
<span>    <span class='c'># Top-align keys with text</span></span>
<span>    key.justification <span class='o'>=</span> <span class='s'>"top"</span></span>
<span>  <span class='o'>)</span></span>
</code></pre>
<img src="figs/sub_legend_legend-1.png" width="700px" style="display: block; margin: auto;" />

</div>

#### Colourbar guide

Likewise, there are also settings specific to [`guide_colourbar()`](https://ggplot2.tidyverse.org/reference/guide_colourbar.html). Generally, you can see it as a legend guide with a single elongated key. This elongation has special behaviour in that the default is 5 times the original key size. If you need to set the size directly without special behaviour, you can use the `guide_colourbar(theme)` argument. Aside from the special size behaviour, we can also set the colourbar frame and ticks.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>p</span> <span class='o'>+</span></span>
<span>  <span class='c'># Using a local guide theme to directly set the size</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/guides.html'>guides</a></span><span class='o'>(</span>colour <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/guide_colourbar.html'>guide_colourbar</a></span><span class='o'>(</span>theme <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/theme.html'>theme</a></span><span class='o'>(</span>legend.key.height <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/grid/unit.html'>unit</a></span><span class='o'>(</span><span class='m'>5</span>, <span class='s'>"cm"</span><span class='o'>)</span><span class='o'>)</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/subtheme.html'>theme_sub_legend</a></span><span class='o'>(</span></span>
<span>    frame <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>element_rect</a></span><span class='o'>(</span>colour <span class='o'>=</span> <span class='s'>"red"</span><span class='o'>)</span>,</span>
<span>    <span class='c'># Long blue ticks</span></span>
<span>    ticks <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>element_line</a></span><span class='o'>(</span>colour <span class='o'>=</span> <span class='s'>"blue"</span><span class='o'>)</span>,</span>
<span>    ticks.length <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/grid/unit.html'>unit</a></span><span class='o'>(</span><span class='o'>-</span><span class='m'>5</span>, <span class='s'>"mm"</span><span class='o'>)</span>,</span>
<span>    <span class='c'># Adapt margins to accommodate longer ticks</span></span>
<span>    text <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>element_text</a></span><span class='o'>(</span>margin <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>margin</a></span><span class='o'>(</span>l <span class='o'>=</span> <span class='m'>6</span>, unit <span class='o'>=</span> <span class='s'>"mm"</span><span class='o'>)</span><span class='o'>)</span>,</span>
<span>    margin <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>margin</a></span><span class='o'>(</span>l <span class='o'>=</span> <span class='m'>6</span>, unit <span class='o'>=</span> <span class='s'>"mm"</span><span class='o'>)</span></span>
<span>  <span class='o'>)</span></span>
</code></pre>
<img src="figs/sub_legend_colourbar-1.png" width="700px" style="display: block; margin: auto;" />

</div>

#### Binned legend

A binned legend acts as a hybrid between a typical legend guide and a colourbar. It depicts a discretised continuous (binned) legend, by properly displaying separate glyphs, but also displaying an axis with ticks at bin breaks.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>p</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/guides.html'>guides</a></span><span class='o'>(</span>colour <span class='o'>=</span> <span class='s'>"bins"</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/subtheme.html'>theme_sub_legend</a></span><span class='o'>(</span></span>
<span>    axis.line <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>element_line</a></span><span class='o'>(</span><span class='s'>"red"</span><span class='o'>)</span>,</span>
<span>    ticks <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>element_line</a></span><span class='o'>(</span><span class='s'>"blue"</span><span class='o'>)</span></span>
<span>  <span class='o'>)</span></span>
</code></pre>
<img src="figs/sub_legend_binned-1.png" width="700px" style="display: block; margin: auto;" />

</div>

### Layers

Since recently we can also set default choices for layer aesthetics via the theme. We briefly saw this foreshadowed in the 'tweaking complete themes' section. But you can have more granular control over layers as well, without affecting the entirety of the theme.

#### Introducing the 'geom' element

The new theme element powering all this is the `geom` argument. It takes the return value of the [`element_geom()`](https://ggplot2.tidyverse.org/reference/element.html) function to control the default graphical properties of layers.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>p</span> <span class='o'>+</span> </span>
<span>  <span class='c'># Turn off grouping</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/aes.html'>aes</a></span><span class='o'>(</span>colour <span class='o'>=</span> <span class='kc'>NULL</span>, shape <span class='o'>=</span> <span class='kc'>NULL</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/geom_smooth.html'>geom_smooth</a></span><span class='o'>(</span>formula <span class='o'>=</span> <span class='nv'>y</span> <span class='o'>~</span> <span class='nv'>x</span>, method <span class='o'>=</span> <span class='s'>"lm"</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/theme.html'>theme</a></span><span class='o'>(</span></span>
<span>    geom <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>element_geom</a></span><span class='o'>(</span></span>
<span>      ink <span class='o'>=</span> <span class='s'>"tomato"</span>,</span>
<span>      paper <span class='o'>=</span> <span class='s'>"dodgerblue"</span>,</span>
<span>      accent <span class='o'>=</span> <span class='s'>"forestgreen"</span></span>
<span>    <span class='o'>)</span></span>
<span>  <span class='o'>)</span></span>
</code></pre>
<img src="figs/layer_ink_paper-1.png" width="700px" style="display: block; margin: auto;" />

</div>

The [`element_geom()`](https://ggplot2.tidyverse.org/reference/element.html) function has a number of properties that we're about to describe. Just like other `element_*()` function, it returns an object with properties, most of which are `NULL` by default. These `NULL` properties will get filled in when the plot is built.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>element_geom</a></span><span class='o'>(</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; &lt;ggplot2::element_geom&gt;</span></span>
<span><span class='c'>#&gt;  @ ink        : NULL</span></span>
<span><span class='c'>#&gt;  @ paper      : NULL</span></span>
<span><span class='c'>#&gt;  @ accent     : NULL</span></span>
<span><span class='c'>#&gt;  @ linewidth  : NULL</span></span>
<span><span class='c'>#&gt;  @ borderwidth: NULL</span></span>
<span><span class='c'>#&gt;  @ linetype   : NULL</span></span>
<span><span class='c'>#&gt;  @ bordertype : NULL</span></span>
<span><span class='c'>#&gt;  @ family     : NULL</span></span>
<span><span class='c'>#&gt;  @ fontsize   : NULL</span></span>
<span><span class='c'>#&gt;  @ pointsize  : NULL</span></span>
<span><span class='c'>#&gt;  @ pointshape : NULL</span></span>
<span><span class='c'>#&gt;  @ colour     : NULL</span></span>
<span><span class='c'>#&gt;  @ fill       : NULL</span></span>
<span></span></code></pre>

</div>

##### Colours

There are 5 colour related settings. In the plot above, we've already met three of them.

-   `ink` is the foreground colour.
-   `paper` is the background colour. It is often used in a mixture with `ink` to dull the foreground and coordinate with the rest of the theme. You can see for example that the ribbon part of [`geom_smooth()`](https://ggplot2.tidyverse.org/reference/geom_smooth.html) is a bit purple-ish due to the mixture of reddish `ink` and bluish `paper`.
-   `accent` is a speciality colour pick that only a few geoms use as default. These are [`geom_contour()`](https://ggplot2.tidyverse.org/reference/geom_contour.html), [`geom_quantile()`](https://ggplot2.tidyverse.org/reference/geom_quantile.html) and [`geom_smooth()`](https://ggplot2.tidyverse.org/reference/geom_smooth.html).

The remaining two are well known to anyone who has worked with ggplot2 before: `colour` and `fill`. These two overrule any `ink`/`paper`/`accent` setting to directly set colour and fill without any mixing. For example, notice that the ribbon is a (semitransparent) purple, rather than a mixture with green paper.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://ggplot2.tidyverse.org/reference/get_last_plot.html'>last_plot</a></span><span class='o'>(</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/theme.html'>theme</a></span><span class='o'>(</span>geom <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>element_geom</a></span><span class='o'>(</span></span>
<span>    fill <span class='o'>=</span> <span class='s'>"purple"</span>,</span>
<span>    colour <span class='o'>=</span> <span class='s'>"orange"</span>,</span>
<span>    paper <span class='o'>=</span> <span class='s'>"green"</span> <span class='c'># Ignored</span></span>
<span>  <span class='o'>)</span><span class='o'>)</span></span>
</code></pre>
<img src="figs/layer_colour_fill-1.png" width="700px" style="display: block; margin: auto;" />

</div>

##### Lines

There are also 4 different line settings. You may already be familiar with `linewidth` and `linetype` setting how wide lines are, and how they are drawn respectively. Additionally, we're now also using `borderwidth` and `bordertype` to denote these settings for closed shapes that can be filled, like the rectangles below.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggplot.html'>ggplot</a></span><span class='o'>(</span><span class='nv'>faithful</span>, <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/aes.html'>aes</a></span><span class='o'>(</span><span class='nv'>eruptions</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/geom_histogram.html'>geom_histogram</a></span><span class='o'>(</span><span class='nf'><a href='https://ggplot2.tidyverse.org/reference/aes.html'>aes</a></span><span class='o'>(</span>y <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/aes_eval.html'>after_stat</a></span><span class='o'>(</span><span class='nv'>density</span><span class='o'>)</span><span class='o'>)</span>, bins <span class='o'>=</span> <span class='m'>30</span>, colour <span class='o'>=</span> <span class='s'>"black"</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/geom_path.html'>geom_line</a></span><span class='o'>(</span>stat <span class='o'>=</span> <span class='s'>"density"</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/theme.html'>theme</a></span><span class='o'>(</span></span>
<span>    geom <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>element_geom</a></span><span class='o'>(</span></span>
<span>      <span class='c'># Applies to the bars</span></span>
<span>      borderwidth <span class='o'>=</span> <span class='m'>0.5</span>,</span>
<span>      bordertype <span class='o'>=</span> <span class='s'>"dashed"</span>,</span>
<span>      <span class='c'># Applies to the line</span></span>
<span>      linewidth <span class='o'>=</span> <span class='m'>4</span>,</span>
<span>      linetype <span class='o'>=</span> <span class='s'>"solid"</span></span>
<span>    <span class='o'>)</span></span>
<span>  <span class='o'>)</span></span>
</code></pre>
<img src="figs/layer_borderline-1.png" width="700px" style="display: block; margin: auto;" />

</div>

##### Points and text

The four remaining settings pertains to text and points. Respectively `fontsize` and `pointsize` control the size. `pointshape` and `family` control the shape and font family.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggplot.html'>ggplot</a></span><span class='o'>(</span><span class='nv'>mtcars</span>, <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/aes.html'>aes</a></span><span class='o'>(</span><span class='nv'>mpg</span>, <span class='nv'>disp</span>, label <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/colnames.html'>rownames</a></span><span class='o'>(</span><span class='nv'>mtcars</span><span class='o'>)</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/geom_point.html'>geom_point</a></span><span class='o'>(</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/geom_text.html'>geom_label</a></span><span class='o'>(</span>nudge_x <span class='o'>=</span> <span class='m'>0.25</span>, hjust <span class='o'>=</span> <span class='m'>0</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/theme.html'>theme</a></span><span class='o'>(</span></span>
<span>    geom <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>element_geom</a></span><span class='o'>(</span></span>
<span>      <span class='c'># Point settings</span></span>
<span>      pointsize <span class='o'>=</span> <span class='m'>8</span>,</span>
<span>      pointshape <span class='o'>=</span> <span class='s'>"←"</span>,</span>
<span>      </span>
<span>      <span class='c'># Text settings</span></span>
<span>      fontsize <span class='o'>=</span> <span class='m'>8</span>,</span>
<span>      family <span class='o'>=</span> <span class='s'>"Ink Free"</span></span>
<span>    <span class='o'>)</span></span>
<span>  <span class='o'>)</span></span>
</code></pre>
<img src="figs/layer_pointtext-1.png" width="700px" style="display: block; margin: auto;" />

</div>

##### Micro-managing layers

Aside from globally affecting every layer via `theme(geom)`, you can also fine-tune the appearance of individual geometry types. Whereas we envision `element_geom(ink, paper)` as the global 'aura' of a plot, the `element_geom(colour, fill)` is intended for tailoring specific geom types. We can add theme elements for specific geoms by replacing the snake_case layer function name by dot.case argument name. This works for layers that have an equivalent Geom ggproto class, which is the case for all geoms in ggplot2.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggplot.html'>ggplot</a></span><span class='o'>(</span><span class='nv'>mpg</span>, <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/aes.html'>aes</a></span><span class='o'>(</span><span class='nv'>class</span>, <span class='nv'>displ</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/geom_boxplot.html'>geom_boxplot</a></span><span class='o'>(</span>outliers <span class='o'>=</span> <span class='kc'>FALSE</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/geom_jitter.html'>geom_jitter</a></span><span class='o'>(</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/theme.html'>theme</a></span><span class='o'>(</span></span>
<span>    geom.point   <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>element_geom</a></span><span class='o'>(</span>colour <span class='o'>=</span> <span class='s'>"dodgerblue"</span><span class='o'>)</span>,</span>
<span>    geom.boxplot <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>element_geom</a></span><span class='o'>(</span>fill <span class='o'>=</span> <span class='s'>"orchid"</span>, colour <span class='o'>=</span> <span class='s'>"turquoise"</span><span class='o'>)</span></span>
<span>  <span class='o'>)</span></span>
</code></pre>
<img src="figs/layer_granular-1.png" width="700px" style="display: block; margin: auto;" />

</div>

##### Macro-managing layers

There are now various options for how to change non-data parts of layers, and it can be a bit tricky to determine when you should use what option. Essentially, this is a 2-by-2 table covering the option of which layers to set (single, all) and when it is used (local, global).

-   If you want to change the look of a single layer in a single plot, you can just use the static (unmapped) aesthetics in a layer. For example: `geom_point(colour = "blue")`.

-   If you want to change the look of a single layer in all plots, you can use [`update_theme()`](https://ggplot2.tidyverse.org/reference/get_theme.html) to globally set a new (micro-managed) option. For example: `update_theme(geom.point = element_geom(colour = "blue"))`. You can also use the `element_geom(ink, paper)` settings but for single layers it may be more direct to use `element_geom(colour, fill)` instead. We no longer recommend, and even discourage (!) using [`update_geom_defaults()`](https://ggplot2.tidyverse.org/reference/update_defaults.html) for this purpose.

-   If you want to change the look of all layers in a single plot, you can use the `theme(geom)` argument and add it to a plot. For example: `theme(geom = element_geom(ink = "blue"))`.

-   If you want to change the look of all layers in all plots, you can also use [`update_theme()`](https://ggplot2.tidyverse.org/reference/get_theme.html) to globally set the `geom` option. For example: `update_theme(geom = element_geom(ink = "blue"))`. Alternatively, you can also coordinate the entire theme by using for example `set_theme(theme_gray(ink = "blue"))`.

##### Access from layers

Up to now, we've mostly described how to use the theme to instruct layers, but we can also instruct layers to lookup things from the theme too. Using the [`from_theme()`](https://ggplot2.tidyverse.org/reference/aes_eval.html) function in aesthetics allows you to use expressions with the variables present in [`element_geom()`](https://ggplot2.tidyverse.org/reference/element.html). For example, if you want to use a darker variant of the `accent` colour instead of `ink`, you might want to write your mapping as follows:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>p</span> <span class='o'>+</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/aes.html'>aes</a></span><span class='o'>(</span>colour <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/aes_eval.html'>from_theme</a></span><span class='o'>(</span><span class='nf'>scales</span><span class='nf'>::</span><span class='nf'><a href='https://scales.r-lib.org/reference/colour_manip.html'>col_darker</a></span><span class='o'>(</span><span class='nv'>accent</span>, <span class='m'>20</span><span class='o'>)</span><span class='o'>)</span><span class='o'>)</span></span>
</code></pre>
<img src="figs/layer_aesthetic-1.png" width="700px" style="display: block; margin: auto;" />

</div>

#### Palettes

In addition to controlling the default aesthetics from the theme, you can also control the default palettes from the theme. The palette theme settings all follow the following pattern, separated by dots: `palette`, aesthetic, type. The `type` can be either `continuous` or `discrete`. If you're using the default binned scale, it takes the continuous palette. For example, if we want to change the default `shape` and `colour` palettes, we can declare that as follows:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>p</span> <span class='o'>+</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/theme.html'>theme</a></span><span class='o'>(</span></span>
<span>  palette.shape.discrete <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"plus"</span>, <span class='s'>"triangle"</span>, <span class='s'>"diamond"</span><span class='o'>)</span>,</span>
<span>  palette.colour.continuous <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"maroon"</span>, <span class='s'>"hotpink"</span>, <span class='s'>"white"</span><span class='o'>)</span></span>
<span><span class='o'>)</span></span>
</code></pre>
<img src="figs/palettes-1.png" width="700px" style="display: block; margin: auto;" />

</div>

The values of these palette theme elements are passed down to [`scales::as_discrete_pal()`](https://scales.r-lib.org/reference/new_continuous_palette.html) and [`scales::as_continuous_pal()`](https://scales.r-lib.org/reference/new_continuous_palette.html) for discrete and continuous scales respectively.

### Theme elements in extensions

Aside from extensions providing whole, complete themes, extensions may also define new theme elements. You can sometimes see these in facets, coords or guide extensions. With these wide use-cases, we cannot really describe these as much as just acknowledge they exist. For example, the ggforce package has a zoom element that controls the appearance of zooming indicators.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>p</span> <span class='o'>+</span> <span class='nf'>ggforce</span><span class='nf'>::</span><span class='nf'><a href='https://ggforce.data-imaginist.com/reference/facet_zoom.html'>facet_zoom</a></span><span class='o'>(</span>ylim <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='m'>20</span>, <span class='m'>30</span><span class='o'>)</span>, xlim <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='m'>3</span>, <span class='m'>4</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/theme.html'>theme</a></span><span class='o'>(</span>zoom <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>element_rect</a></span><span class='o'>(</span>colour <span class='o'>=</span> <span class='s'>"red"</span>, linewidth <span class='o'>=</span> <span class='m'>0.2</span>, fill <span class='o'>=</span> <span class='kc'>NA</span><span class='o'>)</span><span class='o'>)</span></span>
</code></pre>
<img src="figs/extension_elements-1.png" width="700px" style="display: block; margin: auto;" />

</div>

If you are writing your own extension and need to compute a bespoke element from the theme, you can use [`register_theme_elements()`](https://ggplot2.tidyverse.org/reference/register_theme_elements.html) to ensure ggplot2 knows about your element and can use it in [`calc_element()`](https://ggplot2.tidyverse.org/reference/calc_element.html).

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='c'># A custom element comes up empty</span></span>
<span><span class='nf'><a href='https://ggplot2.tidyverse.org/reference/calc_element.html'>calc_element</a></span><span class='o'>(</span><span class='s'>"my_element"</span>, <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/complete_theme.html'>complete_theme</a></span><span class='o'>(</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; NULL</span></span>
<span></span><span></span>
<span><span class='c'># Register element</span></span>
<span><span class='nf'><a href='https://ggplot2.tidyverse.org/reference/register_theme_elements.html'>register_theme_elements</a></span><span class='o'>(</span></span>
<span>  my_element <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>element_rect</a></span><span class='o'>(</span><span class='o'>)</span>,</span>
<span>  element_tree <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span></span>
<span>    my_element <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/register_theme_elements.html'>el_def</a></span><span class='o'>(</span></span>
<span>      class <span class='o'>=</span> <span class='s'>"element_rect"</span>, <span class='c'># Must be a rect element</span></span>
<span>      inherit <span class='o'>=</span> <span class='s'>"rect"</span> <span class='c'># Get settings from theme(rect)</span></span>
<span>    <span class='o'>)</span></span>
<span>  <span class='o'>)</span></span>
<span><span class='o'>)</span></span>
<span></span>
<span><span class='c'># Now custom element can be computed</span></span>
<span><span class='nf'><a href='https://ggplot2.tidyverse.org/reference/calc_element.html'>calc_element</a></span><span class='o'>(</span><span class='s'>"my_element"</span>, <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/complete_theme.html'>complete_theme</a></span><span class='o'>(</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; &lt;ggplot2::element_rect&gt;</span></span>
<span><span class='c'>#&gt;  @ fill         : chr "white"</span></span>
<span><span class='c'>#&gt;  @ colour       : chr "black"</span></span>
<span><span class='c'>#&gt;  @ linewidth    : num 0.5</span></span>
<span><span class='c'>#&gt;  @ linetype     : num 1</span></span>
<span><span class='c'>#&gt;  @ linejoin     : chr "round"</span></span>
<span><span class='c'>#&gt;  @ inherit.blank: logi TRUE</span></span>
<span></span></code></pre>

</div>

## Writing your own theme

When you are writing your own theme there are a few things to keep in mind. A guiding principle is to write your themes such that it is robust to upstream changes. Not only can ggplot2 add, deprecate or reroute elements, also theme elements used by extensions should be accommodated.

#### 1. Use a function

First, this principle means that you should write your theme as a function. Writing your theme as a function ensures it can be rebuild. This is opposed to assigning a theme object to a variable in your package's namespace ---or heaven forbid--- save it as a file, If you assign your theme object to a variable in your namespace, the object will get compiled into your code and can cause build time warnings or errors if an element function or argument get updated.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>my_theme</span> <span class='o'>&lt;-</span> <span class='kr'>function</span><span class='o'>(</span><span class='nv'>...</span><span class='o'>)</span> <span class='o'>&#123;</span><span class='o'>&#125;</span></span></code></pre>

</div>

#### 2. Use a base theme

Secondly, it is good practise to start your own theme as a function that calls a complete theme function as its base. It ensures that when ggplot2 adds new elements that belong in complete themes, your theme also remains complete.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>my_theme</span> <span class='o'>&lt;-</span> <span class='kr'>function</span><span class='o'>(</span><span class='nv'>...</span><span class='o'>)</span> <span class='o'>&#123;</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggtheme.html'>theme_gray</a></span><span class='o'>(</span><span class='nv'>...</span><span class='o'>)</span></span>
<span><span class='o'>&#125;</span></span></code></pre>

</div>

### 3. Use `theme()` to add elements

Third, you should use [`theme()`](https://ggplot2.tidyverse.org/reference/theme.html) to add new elements to the base. While it is technically possible to assign additional elements by sub-assignment (`$<-`), we strong advice against this. Using [`theme()`](https://ggplot2.tidyverse.org/reference/theme.html) ensures that any deprecated arguments are redirected to an appropriate place.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='c'># Do *not* do the following!</span></span>
<span><span class='nv'>my_fragile_theme</span> <span class='o'>&lt;-</span> <span class='kr'>function</span><span class='o'>(</span><span class='nv'>...</span><span class='o'>)</span> <span class='o'>&#123;</span></span>
<span>  <span class='nv'>t</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggtheme.html'>theme_gray</a></span><span class='o'>(</span><span class='nv'>...</span><span class='o'>)</span></span>
<span>  <span class='nv'>t</span><span class='o'>$</span><span class='nv'>legend.text</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>element_text</a></span><span class='o'>(</span><span class='o'>)</span> <span class='c'># BAD</span></span>
<span>  <span class='nv'>t</span></span>
<span><span class='o'>&#125;</span></span></code></pre>

</div>

You can use `+ theme()` or `%+replace% theme()`, where `+` merges elements and `%+replace%` replaces elements by completely removing old settings. If you use `%+replace%` for a root element, like `text` or `line`, you should take care that every property has non-null values.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>my_theme</span> <span class='o'>&lt;-</span> <span class='kr'>function</span><span class='o'>(</span><span class='nv'>...</span><span class='o'>)</span> <span class='o'>&#123;</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggtheme.html'>theme_gray</a></span><span class='o'>(</span><span class='nv'>...</span><span class='o'>)</span> <span class='o'><a href='https://ggplot2.tidyverse.org/reference/get_theme.html'>%+replace%</a></span></span>
<span>    <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/theme.html'>theme</a></span><span class='o'>(</span></span>
<span>      <span class='c'># Because we're replacing, we should fully define root elements</span></span>
<span>      text <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>element_text</a></span><span class='o'>(</span></span>
<span>        family <span class='o'>=</span> <span class='s'>""</span>, face <span class='o'>=</span> <span class='s'>"plain"</span>, colour <span class='o'>=</span> <span class='s'>"red"</span>, size <span class='o'>=</span> <span class='m'>11</span>, </span>
<span>        hjust <span class='o'>=</span> <span class='m'>0.5</span>, vjust <span class='o'>=</span> <span class='m'>0.5</span>, angle <span class='o'>=</span> <span class='m'>0</span>, lineheight <span class='o'>=</span> <span class='m'>1</span>, margin <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>margin</a></span><span class='o'>(</span><span class='o'>)</span></span>
<span>      <span class='o'>)</span>,</span>
<span>      <span class='c'># Non-root elements can be partially defined</span></span>
<span>      legend.text <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>element_text</a></span><span class='o'>(</span>colour <span class='o'>=</span> <span class='s'>"blue"</span><span class='o'>)</span></span>
<span>    <span class='o'>)</span> <span class='o'>+</span></span>
<span>    <span class='c'># Here we're updating the root line element with `+`, instead of replacing it</span></span>
<span>    <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/theme.html'>theme</a></span><span class='o'>(</span>line <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>element_line</a></span><span class='o'>(</span>linetype <span class='o'>=</span> <span class='s'>"dotted"</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='o'>&#125;</span></span>
<span></span>
<span><span class='nv'>p</span> <span class='o'>+</span> <span class='nf'>my_theme</span><span class='o'>(</span><span class='o'>)</span></span>
</code></pre>
<img src="figs/theme_adding_parts-1.png" width="700px" style="display: block; margin: auto;" />

</div>

#### 4. Caching themes

We mentioned in 1. that you shouldn't assign a theme object to a variable in your namespace. However, you may want to reuse a theme without having to reconstruct it every time because you may never need to change arguments in your package. The solution we recommend for this use case, is to cache your theme when your package is loaded. It ensures that we observe all the formalities of building a theme, with all the protections this offers, but we need to do this only once per session.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='c'># Create a variable for your future theme</span></span>
<span><span class='nv'>cached_theme</span> <span class='o'>&lt;-</span> <span class='kc'>NULL</span></span>
<span></span>
<span><span class='c'># In your .onLoad function, construct the theme</span></span>
<span><span class='nv'>.onLoad</span> <span class='o'>&lt;-</span> <span class='kr'>function</span><span class='o'>(</span><span class='nv'>libname</span>, <span class='nv'>pkgname</span><span class='o'>)</span> <span class='o'>&#123;</span></span>
<span>  <span class='nv'>cached_theme</span> <span class='o'>&lt;&lt;-</span> <span class='nf'>my_theme</span><span class='o'>(</span><span class='o'>)</span></span>
<span><span class='o'>&#125;</span></span>
<span></span>
<span><span class='c'># In your package's functions, you can now use the cached theme</span></span>
<span><span class='nv'>my_plotting_function</span> <span class='o'>&lt;-</span> <span class='kr'>function</span><span class='o'>(</span><span class='o'>)</span> <span class='o'>&#123;</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggplot.html'>ggplot</a></span><span class='o'>(</span><span class='nv'>mpg</span>, <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/aes.html'>aes</a></span><span class='o'>(</span><span class='nv'>displ</span>, <span class='nv'>hwy</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>    <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/geom_point.html'>geom_point</a></span><span class='o'>(</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>    <span class='nv'>cached_theme</span></span>
<span><span class='o'>&#125;</span></span>
<span></span>
<span><span class='c'># Simulate loading</span></span>
<span><span class='nf'>.onLoad</span><span class='o'>(</span><span class='o'>)</span></span>
<span></span>
<span><span class='c'># Works!</span></span>
<span><span class='nf'>my_plotting_function</span><span class='o'>(</span><span class='o'>)</span></span>
</code></pre>
<img src="figs/theme_caching-1.png" width="700px" style="display: block; margin: auto;" />

</div>

## Tips and tricks

### Global theme

Are you also used to writing entire booklets of theme settings at every plot? Do your fingers tire of typing `panel.background = element_blank()` dozens of times in a script? Worry no more! Set your theme settings to permanent today by using the one-time offer of [`set_theme()`](https://ggplot2.tidyverse.org/reference/get_theme.html)!

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>my_theme</span> <span class='o'>&lt;-</span> <span class='kr'>function</span><span class='o'>(</span><span class='nv'>...</span><span class='o'>)</span> <span class='o'>&#123;</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggtheme.html'>theme_gray</a></span><span class='o'>(</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>    <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/theme.html'>theme</a></span><span class='o'>(</span></span>
<span>      panel.background <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>element_blank</a></span><span class='o'>(</span><span class='o'>)</span>,</span>
<span>      panel.grid <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>element_line</a></span><span class='o'>(</span>colour <span class='o'>=</span> <span class='s'>"grey95"</span><span class='o'>)</span>,</span>
<span>      palette.colour.continuous <span class='o'>=</span> <span class='s'>"viridis"</span></span>
<span>    <span class='o'>)</span></span>
<span><span class='o'>&#125;</span></span>
<span></span>
<span><span class='nf'><a href='https://ggplot2.tidyverse.org/reference/get_theme.html'>set_theme</a></span><span class='o'>(</span><span class='nf'>my_theme</span><span class='o'>(</span><span class='o'>)</span><span class='o'>)</span></span>
<span></span>
<span><span class='c'># Global goodness galore!</span></span>
<span><span class='nv'>p</span></span>
</code></pre>
<img src="figs/theme_set-1.png" width="700px" style="display: block; margin: auto;" />

</div>

To undo any globally set theme, you can use [`reset_theme_settings()`](https://ggplot2.tidyverse.org/reference/register_theme_elements.html).

### Fonts

Setting the typography of your plots is important and discussed more thoroughly in [this blog post](https://www.tidyverse.org/blog/2025/05/fonts-in-r/). Here we're simply giving the suggestion to use the [`systemfonts::require_font()`](https://systemfonts.r-lib.org/reference/require_font.html) when you are writing theme functions that include special fonts.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>my_theme</span> <span class='o'>&lt;-</span> <span class='kr'>function</span><span class='o'>(</span><span class='nv'>header_family</span> <span class='o'>=</span> <span class='s'>"Impact"</span>, <span class='nv'>...</span><span class='o'>)</span> <span class='o'>&#123;</span></span>
<span>  <span class='nf'>systemfonts</span><span class='nf'>::</span><span class='nf'><a href='https://systemfonts.r-lib.org/reference/require_font.html'>require_font</a></span><span class='o'>(</span><span class='nv'>header_family</span><span class='o'>)</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggtheme.html'>theme_gray</a></span><span class='o'>(</span>header_family <span class='o'>=</span> <span class='nv'>header_family</span>, <span class='nv'>...</span><span class='o'>)</span></span>
<span><span class='o'>&#125;</span></span>
<span></span>
<span><span class='nv'>p</span> <span class='o'>+</span> <span class='nf'>my_theme</span><span class='o'>(</span><span class='o'>)</span></span>
</code></pre>
<img src="figs/fonts-1.png" width="700px" style="display: block; margin: auto;" />

</div>

### Bundling theme settings

Not every theme needs to be a complete theme. You can write partial themes that bundle together related settings to achieve an effect you want. For example, here are some settings that left-aligns the title and legend at the top of a plot.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>upper_legend</span> <span class='o'>&lt;-</span> <span class='kr'>function</span><span class='o'>(</span><span class='o'>)</span> <span class='o'>&#123;</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/theme.html'>theme</a></span><span class='o'>(</span></span>
<span>    plot.title.position <span class='o'>=</span> <span class='s'>"plot"</span>,</span>
<span>    legend.location <span class='o'>=</span> <span class='s'>"plot"</span>,</span>
<span>    legend.position <span class='o'>=</span> <span class='s'>"top"</span>,</span>
<span>    legend.justification.top <span class='o'>=</span> <span class='s'>"left"</span>,</span>
<span>    legend.title.position <span class='o'>=</span> <span class='s'>"top"</span>,</span>
<span>    legend.margin <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>margin_part</a></span><span class='o'>(</span>l <span class='o'>=</span> <span class='m'>0</span><span class='o'>)</span></span>
<span>  <span class='o'>)</span></span>
<span><span class='o'>&#125;</span></span>
<span></span>
<span><span class='nv'>p</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/aes.html'>aes</a></span><span class='o'>(</span>colour <span class='o'>=</span> <span class='kc'>NULL</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'>upper_legend</span><span class='o'>(</span><span class='o'>)</span></span>
</code></pre>
<img src="figs/part_theme_upper_legend-1.png" width="700px" style="display: block; margin: auto;" />

</div>

Another example for bottom placement of colour bars:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>bottom_colourbar</span> <span class='o'>&lt;-</span> <span class='kr'>function</span><span class='o'>(</span><span class='o'>)</span> <span class='o'>&#123;</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/subtheme.html'>theme_sub_legend</a></span><span class='o'>(</span></span>
<span>    position <span class='o'>=</span> <span class='s'>"bottom"</span>,</span>
<span>    title.position <span class='o'>=</span> <span class='s'>"top"</span>,</span>
<span>    justification.bottom <span class='o'>=</span> <span class='s'>"left"</span>,</span>
<span>    <span class='c'># Stretch bar across width of panels</span></span>
<span>    key.width <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/grid/unit.html'>unit</a></span><span class='o'>(</span><span class='m'>1</span>, <span class='s'>"null"</span><span class='o'>)</span>, </span>
<span>    margin <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>margin_part</a></span><span class='o'>(</span>l <span class='o'>=</span> <span class='m'>0</span>, r <span class='o'>=</span> <span class='m'>0</span><span class='o'>)</span></span>
<span>  <span class='o'>)</span></span>
<span><span class='o'>&#125;</span></span>
<span></span>
<span><span class='nv'>p</span> <span class='o'>+</span> </span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/aes.html'>aes</a></span><span class='o'>(</span>shape <span class='o'>=</span> <span class='kc'>NULL</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'>bottom_colourbar</span><span class='o'>(</span><span class='o'>)</span></span>
</code></pre>
<img src="figs/part_theme_bottom_colourbar-1.png" width="700px" style="display: block; margin: auto;" />

</div>

If you don't mind venturing outside the grammar for a brisk stroll, you can also bundle theme settings together with other components. For example, in a bar chart you may wish to suppress vertical grid lines and not expand the y-axis at the bottom.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>barchart_settings</span> <span class='o'>&lt;-</span> <span class='kr'>function</span><span class='o'>(</span><span class='o'>)</span> <span class='o'>&#123;</span></span>
<span>  <span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span></span>
<span>    <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/theme.html'>theme</a></span><span class='o'>(</span>panel.grid.major.x <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>element_blank</a></span><span class='o'>(</span><span class='o'>)</span><span class='o'>)</span>,</span>
<span>    <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/coord_cartesian.html'>coord_cartesian</a></span><span class='o'>(</span>expand <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span>bottom <span class='o'>=</span> <span class='kc'>FALSE</span><span class='o'>)</span><span class='o'>)</span></span>
<span>  <span class='o'>)</span></span>
<span><span class='o'>&#125;</span></span>
<span></span>
<span><span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggplot.html'>ggplot</a></span><span class='o'>(</span><span class='nv'>mpg</span>, <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/aes.html'>aes</a></span><span class='o'>(</span><span class='nv'>class</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/geom_bar.html'>geom_bar</a></span><span class='o'>(</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'>barchart_settings</span><span class='o'>(</span><span class='o'>)</span></span>
</code></pre>
<img src="figs/part_theme_barchart-1.png" width="700px" style="display: block; margin: auto;" />

</div>

The point here is not to make an exhaustive list of all useful bundles, it is to highlight that it possible to create reusable chunks of theme.

### Pattern rectangles

Did you know that `element_rect(fill)` can be a grid pattern? You can use it to place images in the panel background, which can be neat for branding.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>pattern</span> <span class='o'>&lt;-</span> <span class='s'>"https://raw.githubusercontent.com/tidyverse/ggplot2/refs/heads/main/man/figures/logo.png"</span> <span class='o'>|&gt;</span> </span>
<span>  <span class='nf'>magick</span><span class='nf'>::</span><span class='nf'><a href='https://docs.ropensci.org/magick/reference/editing.html'>image_read</a></span><span class='o'>(</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'>grid</span><span class='nf'>::</span><span class='nf'><a href='https://rdrr.io/r/grid/grid.raster.html'>rasterGrob</a></span><span class='o'>(</span></span>
<span>    x <span class='o'>=</span> <span class='m'>0.8</span>, y <span class='o'>=</span> <span class='m'>0.8</span>,</span>
<span>    width <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/grid/unit.html'>unit</a></span><span class='o'>(</span><span class='m'>0.2</span>, <span class='s'>"snpc"</span><span class='o'>)</span>, </span>
<span>    height <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/grid/unit.html'>unit</a></span><span class='o'>(</span><span class='m'>0.23</span>, <span class='s'>"snpc"</span><span class='o'>)</span>, </span>
<span>  <span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'>grid</span><span class='nf'>::</span><span class='nf'><a href='https://rdrr.io/r/grid/patterns.html'>pattern</a></span><span class='o'>(</span>extend <span class='o'>=</span> <span class='s'>"none"</span><span class='o'>)</span></span>
<span></span>
<span><span class='nv'>p</span> <span class='o'>+</span> </span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/theme.html'>theme</a></span><span class='o'>(</span></span>
<span>    panel.background <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>element_rect</a></span><span class='o'>(</span>fill <span class='o'>=</span> <span class='nv'>pattern</span><span class='o'>)</span>,</span>
<span>    <span class='c'># legend.key inherits from panel background, so we tweak it</span></span>
<span>    legend.key <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>element_blank</a></span><span class='o'>(</span><span class='o'>)</span>,</span>
<span>    <span class='c'># make grid semitransparent to lay over pattern</span></span>
<span>    panel.grid <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>element_line</a></span><span class='o'>(</span>colour <span class='o'>=</span> <span class='nf'><a href='https://scales.r-lib.org/reference/alpha.html'>alpha</a></span><span class='o'>(</span><span class='s'>"black"</span>, <span class='m'>0.05</span><span class='o'>)</span><span class='o'>)</span></span>
<span>  <span class='o'>)</span></span>
</code></pre>
<img src="figs/pattern_fill-1.png" width="700px" style="display: block; margin: auto;" />

</div>

## Finally

This article has been light on advice on how you should or should not use themes. Mostly, this is to encourage experimentation. Don't be afraid to put in a personal twist. Make mistakes. Discover why a theme does or doesn't work for a plot. If you cannot be bothered, there are [extension packages](https://exts.ggplot2.tidyverse.org/gallery/) that offer plenty of options. The [tidytuesday](https://github.com/rfordatascience/tidytuesday) project has spawned a rich source of varied plotting code, including themes people use. If you like a tidytuesday plot, find the source code and see how the sausage is made. Find whatever theme works for you and your plots.

