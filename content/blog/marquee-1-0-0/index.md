---
output: hugodown::hugo_document

slug: marquee-1-0-0
title: marquee 1.0.0
date: 2024-05-07
author: Thomas Lin Pedersen
description: >
    The initial release brings markdown awareness to grid and ggplot2 to allow 
    for rich text formatting in R graphics.

photo:
  url: https://unsplash.com/photos/a-close-up-of-a-metal-grate-on-a-table-9jfpVAhGC1g
  author: Etienne Girardet

# one of: "deep-dive", "learn", "package", "programming", "roundup", or "other"
categories: [package] 
tags: [marquee, ggplot2]
rmd_hash: f090449d09909f87

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
* [-] [`usethis::use_tidy_thanks()`](https://usethis.r-lib.org/reference/use_tidy_thanks.html)
-->

I am super excited to announce the initial release of [marquee](https://marquee.r-lib.org), a markdown parser and renderer for R graphics that allows native rich text formatting of text in graphics created with grid (which includes ggplot2 and lattice).

The inception of this package goes all the way back to 2017

<blockquote class="twitter-tweet">
<p lang="en" dir="ltr">

May I present: Text wrapping of theme elements in <a href="https://twitter.com/hashtag/ggplot2?src=hash&amp;ref_src=twsrc%5Etfw">#ggplot2</a> with the new (experimental) element_textbox in <a href="https://twitter.com/hashtag/ggforce?src=hash&amp;ref_src=twsrc%5Etfw">#ggforce</a><a href="https://twitter.com/hashtag/rstats?src=hash&amp;ref_src=twsrc%5Etfw">#rstats</a> <a href="https://twitter.com/hashtag/dataviz?src=hash&amp;ref_src=twsrc%5Etfw">#dataviz</a> <a href="https://t.co/JJMLcuTBqx">pic.twitter.com/JJMLcuTBqx</a>

</p>

--- Thomas Lin Pedersen (@thomasp85) <a href="https://twitter.com/thomasp85/status/816967301014634497?ref_src=twsrc%5Etfw">January 5, 2017</a>

</blockquote>
<script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

(yeah...) where I developed an experimental feature for ggforce that allowed automatic text wrapping in [`element_text()`](https://ggplot2.tidyverse.org/reference/element.html). Years passed, slowly improving the text rendering capabilities in R until we are finally at a point in the toolchain where something like marquee can deliver on my initial plans.

If this has you intrigued you can install it from CRAN with:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://rdrr.io/r/utils/install.packages.html'>install.packages</a></span><span class='o'>(</span><span class='s'>"marquee"</span><span class='o'>)</span></span></code></pre>

</div>

This blog post will go through the features of marquee, along with discussing some of its current limitations, all of which are hopefully transient.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://marquee.r-lib.org'>marquee</a></span><span class='o'>)</span></span></code></pre>

</div>

## An example

Since the use of markdown is second-hand nature for most people at this point, there shouldn't be much surprise in what marquee is capable off, so let's start with an example to show the main use:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>md_text</span> <span class='o'>&lt;-</span> </span>
<span><span class='s'>"# Intro</span></span>
<span><span class='s'>markdown has been *quite* succesful in creating a unified way of specifying </span></span>
<span><span class='s'>_semantic_ rich text. While limited, it provides both &#123;.yellow readability&#125; and</span></span>
<span><span class='s'>just enough ~power~ features.</span></span>
<span><span class='s'></span></span>
<span><span class='s'>    text &lt;- \"markdown **text**\"</span></span>
<span><span class='s'>    marquee_grob(text)</span></span>
<span><span class='s'></span></span>
<span><span class='s'>It features, among others:</span></span>
<span><span class='s'></span></span>
<span><span class='s'>1. lists</span></span>
<span><span class='s'></span></span>
<span><span class='s'>2. code blocks</span></span>
<span><span class='s'></span></span>
<span><span class='s'>   * Indented lists</span></span>
<span><span class='s'>   </span></span>
<span><span class='s'>3. and more...</span></span>
<span><span class='s'>"</span></span>
<span></span>
<span><span class='nf'>grid</span><span class='nf'>::</span><span class='nf'><a href='https://rdrr.io/r/grid/grid.draw.html'>grid.draw</a></span><span class='o'>(</span><span class='nf'><a href='https://marquee.r-lib.org/reference/marquee_grob.html'>marquee_grob</a></span><span class='o'>(</span><span class='nv'>md_text</span><span class='o'>)</span><span class='o'>)</span></span>
</code></pre>
<img src="figs/unnamed-chunk-3-1.png" width="700px" style="display: block; margin: auto;" />

</div>

The above illustrates a couple of things. First and foremost, that markdown works in very unsurprising ways and you get what you type. In fact, the full CommonMark syntax is supported along with extensions for underline and strikethrough. Further, it shows that marquee provides its own extension for specifying custom span elements in the form of the `{.class <text>}` syntax. The renderer is clever in interpreting the class so that if it corresponds to a colour name, the colour is automatically applied to the text. Lastly, it shows that the default styling of markdown closely follows the look you've come to expect from markdown rendered to HTML.

## Use in ggplot2

The number of people using this directly in grid is probably small. It is more likely that you access the functionality of marquee through higher level functions. Marquee provides two such functions aimed at making it easy to use marquee in ggplot2. The aim is to eventually move these into ggplot2 proper, but while we are in the initial phase of development they will stay in this package.

### `geom_marquee()`

The first function is (obviously) a geom. It is intended as a stand-in replacement for both [`geom_text()`](https://ggplot2.tidyverse.org/reference/geom_text.html) and [`geom_label()`](https://ggplot2.tidyverse.org/reference/geom_text.html). As with [`marquee_grob()`](https://marquee.r-lib.org/reference/marquee_grob.html) it works very unsurprisingly:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://ggplot2.tidyverse.org'>ggplot2</a></span><span class='o'>)</span></span>
<span><span class='c'># Add styling around the first word</span></span>
<span><span class='nv'>red_bold_names</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/grep.html'>sub</a></span><span class='o'>(</span><span class='s'>"(\\w+)"</span>, <span class='s'>"&#123;.red **\\1**&#125;"</span>, <span class='nf'><a href='https://rdrr.io/r/base/colnames.html'>rownames</a></span><span class='o'>(</span><span class='nv'>mtcars</span><span class='o'>)</span><span class='o'>)</span></span>
<span></span>
<span><span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggplot.html'>ggplot</a></span><span class='o'>(</span><span class='nv'>mtcars</span><span class='o'>)</span> <span class='o'>+</span> </span>
<span>  <span class='nf'><a href='https://marquee.r-lib.org/reference/geom_marquee.html'>geom_marquee</a></span><span class='o'>(</span><span class='nf'><a href='https://ggplot2.tidyverse.org/reference/aes.html'>aes</a></span><span class='o'>(</span>x <span class='o'>=</span> <span class='nv'>mpg</span>, y <span class='o'>=</span> <span class='nv'>disp</span>, label <span class='o'>=</span> <span class='nv'>red_bold_names</span><span class='o'>)</span><span class='o'>)</span></span>
</code></pre>
<img src="figs/unnamed-chunk-4-1.png" width="700px" style="display: block; margin: auto;" />

</div>

Apart from standard, but markdown-aware, [`geom_text()`](https://ggplot2.tidyverse.org/reference/geom_text.html) behaviour, the geom also gains a `width` aesthetic that allows you to turn on automatic soft wrapping of the text. In addition to this it gains a `style` aesthetic to finely control the style (more about styling below)

### `element_marquee()`

The second obvious use for marquee in ggplot2 is in formatting text elements. [`element_marquee()`](https://marquee.r-lib.org/reference/element_marquee.html) is a replacement for [`element_text()`](https://ggplot2.tidyverse.org/reference/element.html) that does just that.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggplot.html'>ggplot</a></span><span class='o'>(</span><span class='nv'>mtcars</span><span class='o'>)</span> <span class='o'>+</span> </span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/geom_point.html'>geom_point</a></span><span class='o'>(</span><span class='nf'><a href='https://ggplot2.tidyverse.org/reference/aes.html'>aes</a></span><span class='o'>(</span>x <span class='o'>=</span> <span class='nv'>mpg</span>, y <span class='o'>=</span> <span class='nv'>disp</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>+</span> </span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/labs.html'>ggtitle</a></span><span class='o'>(</span><span class='nv'>md_text</span><span class='o'>)</span> <span class='o'>+</span> </span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/theme.html'>theme</a></span><span class='o'>(</span>plot.title <span class='o'>=</span> <span class='nf'><a href='https://marquee.r-lib.org/reference/element_marquee.html'>element_marquee</a></span><span class='o'>(</span>size <span class='o'>=</span> <span class='m'>8</span>, width <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/grid/unit.html'>unit</a></span><span class='o'>(</span><span class='m'>16</span>, <span class='s'>"cm"</span><span class='o'>)</span><span class='o'>)</span><span class='o'>)</span></span>
</code></pre>
<img src="figs/unnamed-chunk-5-1.png" width="700px" style="display: block; margin: auto;" />

</div>

## Styling

As alluded to above, marquee comes with a styling API that is reminiscent of CSS but completely its own. In some sense it takes the "simplicity over power" approach from markdown and applies it to styling.

In marquee, each element type (e.g. a code block) has its own style. This style can be incomplete in which case it inherits the remaining specifications from the parent element in the document. As an example, the `em` element has the following default style `style(italic = TRUE)`, that is, take whatever style is currently in effect but set the text to italic. This is basically how CSS works as well, but CSS allows so much more which clutters both the API and implementation if all you ever want to do is format rich text.

Apart from the direct inheritance of the marquee styling, it is also possible to use relative inheritance for numeric specifications (e.g. `lineheight = relative(2)` to double the current lineheight) or set sizes based on the current or root element font size (using [`em()`](https://marquee.r-lib.org/reference/style_helpers.html) and [`rem()`](https://marquee.r-lib.org/reference/style_helpers.html) respectively). Lastly, you can also mark a specification as "non-inheritable" using [`skip_inherit()`](https://marquee.r-lib.org/reference/style_helpers.html) in which case the inheritance moves up one level.

Marquee ships with a single style set ([`classic_style()`](https://marquee.r-lib.org/reference/classic_style.html)) and you can make your own, either by modifying this, or building your own from scratch. If you choose the latter route make sure that the base element is a complete style - everything beyond that is optional.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='c'># Create a style set with no styling beyond the base settings</span></span>
<span><span class='nv'>no_style</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://marquee.r-lib.org/reference/style_set.html'>style_set</a></span><span class='o'>(</span>base <span class='o'>=</span> <span class='nf'><a href='https://marquee.r-lib.org/reference/style.html'>base_style</a></span><span class='o'>(</span><span class='o'>)</span><span class='o'>)</span></span>
<span></span>
<span><span class='nf'>grid</span><span class='nf'>::</span><span class='nf'><a href='https://rdrr.io/r/grid/grid.draw.html'>grid.draw</a></span><span class='o'>(</span><span class='nf'><a href='https://marquee.r-lib.org/reference/marquee_grob.html'>marquee_grob</a></span><span class='o'>(</span><span class='nv'>md_text</span>, <span class='nv'>no_style</span><span class='o'>)</span><span class='o'>)</span></span>
</code></pre>
<img src="figs/unnamed-chunk-6-1.png" width="700px" style="display: block; margin: auto;" />

</div>

As we see, all discerning styling have been stripped from the rendering above. All, except for the custom coloured element. As discussed previously, marquee understand custom spans named after colours and doesn't require a specific styling of these to be provided. However, if you do provide a style, that takes precedence:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>confusing_style</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://marquee.r-lib.org/reference/classic_style.html'>classic_style</a></span><span class='o'>(</span><span class='o'>)</span> <span class='o'>|&gt;</span> </span>
<span>  <span class='nf'><a href='https://marquee.r-lib.org/reference/style_set.html'>modify_style</a></span><span class='o'>(</span><span class='s'>"yellow"</span>, <span class='nf'><a href='https://marquee.r-lib.org/reference/style.html'>style</a></span><span class='o'>(</span>color <span class='o'>=</span> <span class='s'>"red"</span><span class='o'>)</span><span class='o'>)</span></span>
<span></span>
<span><span class='nf'>grid</span><span class='nf'>::</span><span class='nf'><a href='https://rdrr.io/r/grid/grid.draw.html'>grid.draw</a></span><span class='o'>(</span><span class='nf'><a href='https://marquee.r-lib.org/reference/marquee_grob.html'>marquee_grob</a></span><span class='o'>(</span><span class='nv'>md_text</span>, <span class='nv'>confusing_style</span><span class='o'>)</span><span class='o'>)</span></span>
</code></pre>
<img src="figs/unnamed-chunk-7-1.png" width="700px" style="display: block; margin: auto;" />

</div>

## Images

Markdown (famously) supports adding images through the `![alt text](path/to/image)` syntax. Since marquee supports the full CommonMark spec, this is of course also supported. The only limitation is that the "alt text" is ignored since hovering tool-tips or screen-readers are not supported for the output types that marquee renders to.

If an image is placed on a line of its own it will be rendered to fit the line height of the line. If it is placed by itself on its own line it will span the width available:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>logo</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/system.file.html'>system.file</a></span><span class='o'>(</span><span class='s'>"help"</span>, <span class='s'>"figures"</span>, <span class='s'>"logo.png"</span>, package <span class='o'>=</span> <span class='s'>"marquee"</span><span class='o'>)</span></span>
<span><span class='nv'>header_img</span> <span class='o'>&lt;-</span> <span class='s'>"thumbnail-wd.jpg"</span></span>
<span></span>
<span><span class='nv'>md_img</span> <span class='o'>&lt;-</span> </span>
<span><span class='s'>"# About marquee ![](&#123;logo&#125;)</span></span>
<span><span class='s'></span></span>
<span><span class='s'>Both PNG (above), JPEG (below), and SVG (not shown) are supported</span></span>
<span><span class='s'></span></span>
<span><span class='s'>![](&#123;header_img&#125;)</span></span>
<span><span class='s'></span></span>
<span><span class='s'>The above image is treated like a block element</span></span>
<span><span class='s'>"</span></span>
<span></span>
<span><span class='nv'>md_img</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://marquee.r-lib.org/reference/marquee_glue.html'>marquee_glue</a></span><span class='o'>(</span><span class='nv'>md_img</span><span class='o'>)</span></span>
<span></span>
<span><span class='nf'>grid</span><span class='nf'>::</span><span class='nf'><a href='https://rdrr.io/r/grid/grid.draw.html'>grid.draw</a></span><span class='o'>(</span><span class='nf'><a href='https://marquee.r-lib.org/reference/marquee_grob.html'>marquee_grob</a></span><span class='o'>(</span><span class='nv'>md_img</span><span class='o'>)</span><span class='o'>)</span></span>
</code></pre>
<img src="figs/unnamed-chunk-8-1.png" width="700px" style="display: block; margin: auto;" />

</div>

Apart from showing support for images we also introduce a new function above, [`marquee_glue()`](https://marquee.r-lib.org/reference/marquee_glue.html). It is a function that works very much like [`glue::glue()`](https://glue.tidyverse.org/reference/glue.html) and performs text interpolation. However, this variant understands the custom span syntax of marquee so that these will not be treated as interpolation sites. Further, it turns off the `#` interpretation as a comment character as this interferes with the markdown header syntax.

All of the above is pretty standard markdown and since I prefixed this whole blog post with "full markdown support" it shouldn't come as a big surprise. However, marquee has one last trick up its sleeve: R graphics interpolation. Quite simply, if you, instead of providing a path to a file, provide the name of an R variable holding a graphic object, this will be included as an image. Here's how it works:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>plot</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggplot.html'>ggplot</a></span><span class='o'>(</span><span class='nv'>mtcars</span><span class='o'>)</span> <span class='o'>+</span> </span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/geom_point.html'>geom_point</a></span><span class='o'>(</span><span class='nf'><a href='https://ggplot2.tidyverse.org/reference/aes.html'>aes</a></span><span class='o'>(</span><span class='nv'>mpg</span>, <span class='nv'>disp</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>+</span> </span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/geom_point.html'>geom_point</a></span><span class='o'>(</span><span class='nf'><a href='https://ggplot2.tidyverse.org/reference/aes.html'>aes</a></span><span class='o'>(</span><span class='nv'>mpg</span>, <span class='nv'>disp</span><span class='o'>)</span>, <span class='nv'>mtcars</span><span class='o'>[</span><span class='m'>1</span>,<span class='o'>]</span>, colour <span class='o'>=</span> <span class='s'>"red"</span>, size <span class='o'>=</span> <span class='m'>3</span><span class='o'>)</span></span>
<span></span>
<span><span class='nv'>point</span> <span class='o'>&lt;-</span> <span class='nf'>grid</span><span class='nf'>::</span><span class='nf'><a href='https://rdrr.io/r/grid/grid.points.html'>pointsGrob</a></span><span class='o'>(</span>x <span class='o'>=</span> <span class='m'>0.5</span>, y <span class='o'>=</span> <span class='m'>0.5</span>, pch <span class='o'>=</span> <span class='m'>19</span>, gp <span class='o'>=</span> <span class='nf'>grid</span><span class='nf'>::</span><span class='nf'><a href='https://rdrr.io/r/grid/gpar.html'>gpar</a></span><span class='o'>(</span>col <span class='o'>=</span> <span class='s'>"red"</span><span class='o'>)</span><span class='o'>)</span></span>
<span></span>
<span><span class='nv'>md_plots</span> <span class='o'>&lt;-</span> </span>
<span><span class='s'>"# Plots</span></span>
<span><span class='s'>In the plot below, the red dot (![](point)) shows the Mazda RX4</span></span>
<span><span class='s'></span></span>
<span><span class='s'>![](plot)</span></span>
<span><span class='s'>"</span></span>
<span></span>
<span><span class='nf'>grid</span><span class='nf'>::</span><span class='nf'><a href='https://rdrr.io/r/grid/grid.draw.html'>grid.draw</a></span><span class='o'>(</span><span class='nf'><a href='https://marquee.r-lib.org/reference/marquee_grob.html'>marquee_grob</a></span><span class='o'>(</span><span class='nv'>md_plots</span><span class='o'>)</span><span class='o'>)</span></span>
</code></pre>
<img src="figs/unnamed-chunk-9-1.png" width="700px" style="display: block; margin: auto;" />

</div>

## Limitations

Marquee's biggest limitation is its reliance on very new features in the graphics engine. The rendering will *not* work on anything before R 4.3, but even then it requires the graphics device to support a range of new features, most importantly the new glyph specification introduced in R 4.3. While several graphics devices do support the required features, most notably those powered by Cairo as well as all devices in ragg, many do not. The default Windows graphics device continues to lag behind and the default on macOS, while supporting glyphs, can crash in some situations bringing the whole R session down with it (this is still being investigated). So we are in no doubt threading the frontier here. All of this is set to resolve itself (maybe except for the default Windows device) as time passes.

A limitation of great interest to me is the lack of support in svglite. svglite is build on a core idea of post-editability and thus wants all its text to be selectable and editable when opened in a capable program such as Adobe Illustrator. However, the graphics engine API that powers the new capabilities does not really allow this and I'm still figuring out how to reconcile it. It will eventually be solved though.

Lastly, while not really part of HTML syntax directly, many people rely on HTML inside markdown documents to solve layout and styling tasks that markdown doesn't support. The way it works is that markdown passes the HTML through unmodified and then the HTML is parsed by the HTML renderer (often the browser) used to display the rendered markdown document. This makes it seem like understanding HTML is part of markdown, while it's really not. The reason I'm going through all this explanation is to say that marquee has no understanding of HTML and will not render it as expected. While some HTML tags and CSS settings have clear counterparts in markdown and the marquee styling system it is much better to have a clear "no-support" over an arbitrary limited support. [`marquee_grob()`](https://marquee.r-lib.org/reference/marquee_grob.html)/[`marquee_parse()`](https://marquee.r-lib.org/reference/marquee_parse.html) have an argument (`ignore_html`) that controls whether HTML are outright removed from the output (default), or if it is included verbatim.

## Acknowledgements

Marquee is the latest in a stream of advancements when it comes to text rendering and font support in R. It builds on top of my work with [systemfonts](https://systemfonts.r-lib.org/index.html), [textshaping](https://github.com/r-lib/textshaping), and [ragg](https://ragg.r-lib.org/index.html), but also pays great debt to Paul Murrell's work on adding a new, more low level API for text rendering to grid and the graphics engine. Lastly, Claus Wilke's work on [gridtext](https://wilkelab.org/gridtext/) and [ggtext](https://wilkelab.org/ggtext/) showed the power and need for rich text support in R and filled a gap until the technical foundation for marquee was build out.

