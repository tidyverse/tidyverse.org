---
output: hugodown::hugo_document
slug: ggplot2-3-4-0-size-to-linewidth
title: Make your ggplot2 extension package understand the new linewidth aesthetic
date: 2022-08-24
author: Thomas Lin Pedersen
description: >
    The next release of ggplot2 will contain a number of internal improvements 
    and fixes long-time inconsistencies. One of these are the conflation of 
    point size and linewidth into the same aesthetic. This post will go into 
    detail with how you can make your extension package work well with the new
    linewidth aesthetic.
photo:
  url: https://unsplash.com/photos/GsZLXA4JPcM
  author: Ricardo Gomez Angel
# one of: "deep-dive", "learn", "package", "programming", "roundup", or "other"
categories: [deep-dive] 
tags: [ggplot2]
editor_options: 
  markdown: 
    wrap: 72
rmd_hash: 703cd186e4f4ea0b

---

We are hard at work finishing the next release of ggplot2. While this release is mostly about internal changes, there are a few quite user visible changes as well. One of these upends the idea that the `size` aesthetic is responsible for *both* the sizing of point/text and the width of lines. With the next release we will have a `linewidth` aesthetic to take care of the latter, while `size` will continue handling the former.

There are many excellent reasons for this change, all of which will have to wait until the release post to be discussed. This blog post is for those that maintain an extension package for ggplot2 and are left wondering how they should respond to this --- if that is you, please read on!

## The way it works

Before going into technicalities we'll describe how it is intended to work. We are well aware that we can't just make a change that would instantly break everyone's code. So, we have gone to great length to make old code work as before while gently coercing users into adopting the news paradigm. For example, take a look at this piece of old code:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://ggplot2.tidyverse.org'>ggplot2</a></span><span class='o'>)</span>

<span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggplot.html'>ggplot</a></span><span class='o'>(</span><span class='nv'>airquality</span><span class='o'>)</span> <span class='o'>+</span> 
  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/geom_path.html'>geom_line</a></span><span class='o'>(</span>
    <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/aes.html'>aes</a></span><span class='o'>(</span>x <span class='o'>=</span> <span class='nv'>Day</span>, y <span class='o'>=</span> <span class='nv'>Temp</span>, size <span class='o'>=</span> <span class='nv'>Wind</span>, group <span class='o'>=</span> <span class='nv'>Month</span><span class='o'>)</span>, 
    lineend <span class='o'>=</span> <span class='s'>"round"</span>
  <span class='o'>)</span>
<span class='c'>#&gt; <span style='color: #00BB00;'>size</span> aesthetic has been deprecated for use with lines as of ggplot2 3.4.0</span>
<span class='c'>#&gt; <span style='color: #00BBBB;'>ℹ</span> Please use <span style='color: #00BB00;'>linewidth</span> aesthetic instead</span>
<span class='c'>#&gt; <span style='color: #555555;'>This message is displayed once every 8 hours.</span></span>
</code></pre>
<img src="figs/unnamed-chunk-1-1.png" width="700px" style="display: block; margin: auto;" />

</div>

As you can see, ggplot2 detects the use of the `size` aesthetic and informs the user about the new `linewidth` aesthetic but otherwise proceeds as before, producing the expected plot. As expected, [`scale_size()`](https://ggplot2.tidyverse.org/reference/scale_size.html) also works in this situation:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggplot.html'>ggplot</a></span><span class='o'>(</span><span class='nv'>airquality</span><span class='o'>)</span> <span class='o'>+</span> 
  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/geom_path.html'>geom_line</a></span><span class='o'>(</span>
    <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/aes.html'>aes</a></span><span class='o'>(</span>x <span class='o'>=</span> <span class='nv'>Day</span>, y <span class='o'>=</span> <span class='nv'>Temp</span>, size <span class='o'>=</span> <span class='nv'>Wind</span>, group <span class='o'>=</span> <span class='nv'>Month</span><span class='o'>)</span>, 
    lineend <span class='o'>=</span> <span class='s'>"round"</span>
  <span class='o'>)</span> <span class='o'>+</span> 
  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/scale_size.html'>scale_size</a></span><span class='o'>(</span><span class='s'>"Windspeed (mph)"</span>, range <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='m'>0.5</span>, <span class='m'>3</span><span class='o'>)</span><span class='o'>)</span>
<span class='c'>#&gt; <span style='color: #00BB00;'>size</span> aesthetic has been deprecated for use with lines as of ggplot2 3.4.0</span>
<span class='c'>#&gt; <span style='color: #00BBBB;'>ℹ</span> Please use <span style='color: #00BB00;'>linewidth</span> aesthetic instead</span>
<span class='c'>#&gt; <span style='color: #555555;'>This message is displayed once every 8 hours.</span></span>
</code></pre>
<img src="figs/unnamed-chunk-2-1.png" width="700px" style="display: block; margin: auto;" />

</div>

but ultimately we of course wants users to migrate to the following code:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggplot.html'>ggplot</a></span><span class='o'>(</span><span class='nv'>airquality</span><span class='o'>)</span> <span class='o'>+</span> 
  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/geom_path.html'>geom_line</a></span><span class='o'>(</span>
    <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/aes.html'>aes</a></span><span class='o'>(</span>x <span class='o'>=</span> <span class='nv'>Day</span>, y <span class='o'>=</span> <span class='nv'>Temp</span>, linewidth <span class='o'>=</span> <span class='nv'>Wind</span>, group <span class='o'>=</span> <span class='nv'>Month</span><span class='o'>)</span>, 
    lineend <span class='o'>=</span> <span class='s'>"round"</span>
  <span class='o'>)</span> <span class='o'>+</span> 
  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/scale_linewidth.html'>scale_linewidth</a></span><span class='o'>(</span><span class='s'>"Windspeed (mph)"</span>, range <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='m'>0.5</span>, <span class='m'>3</span><span class='o'>)</span><span class='o'>)</span>
</code></pre>
<img src="figs/unnamed-chunk-3-1.png" width="700px" style="display: block; margin: auto;" />

</div>

> The last two plots are not equal because the `default` `linewidth` scale correctly use a linear transform instead of a square root transform

## How to adopt this

We have been able to add this automatic translation in a quite non-intrusive way which means that you as a package developer don't need to do that much to adapt to the new naming. To show this I'll create a geom drawing circles and then update it to using linewidth instead:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>GeomCircle</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggproto.html'>ggproto</a></span><span class='o'>(</span><span class='s'>"GeomCircle"</span>, <span class='nv'>Geom</span>,
  draw_panel <span class='o'>=</span> <span class='kr'>function</span><span class='o'>(</span><span class='nv'>data</span>, <span class='nv'>panel_params</span>, <span class='nv'>coord</span><span class='o'>)</span> <span class='o'>&#123;</span>
    <span class='c'># Expand x, y, radius data to points along circle</span>
    <span class='nv'>circle_data</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/funprog.html'>Map</a></span><span class='o'>(</span><span class='kr'>function</span><span class='o'>(</span><span class='nv'>x</span>, <span class='nv'>y</span>, <span class='nv'>r</span><span class='o'>)</span> <span class='o'>&#123;</span>
      <span class='nv'>radians</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/seq.html'>seq</a></span><span class='o'>(</span><span class='m'>0</span>, <span class='m'>2</span><span class='o'>*</span><span class='nv'>pi</span>, length.out <span class='o'>=</span> <span class='m'>101</span><span class='o'>)</span><span class='o'>[</span><span class='o'>-</span><span class='m'>1</span><span class='o'>]</span>
      <span class='nf'><a href='https://rdrr.io/r/base/data.frame.html'>data.frame</a></span><span class='o'>(</span>
        x <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/Trig.html'>cos</a></span><span class='o'>(</span><span class='nv'>radians</span><span class='o'>)</span> <span class='o'>*</span> <span class='nv'>r</span> <span class='o'>+</span> <span class='nv'>x</span>,
        y <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/Trig.html'>sin</a></span><span class='o'>(</span><span class='nv'>radians</span><span class='o'>)</span> <span class='o'>*</span> <span class='nv'>r</span> <span class='o'>+</span> <span class='nv'>y</span>
      <span class='o'>)</span>
    <span class='o'>&#125;</span>, x <span class='o'>=</span> <span class='nv'>data</span><span class='o'>$</span><span class='nv'>x</span>, y <span class='o'>=</span> <span class='nv'>data</span><span class='o'>$</span><span class='nv'>y</span>, r <span class='o'>=</span> <span class='nv'>data</span><span class='o'>$</span><span class='nv'>radius</span><span class='o'>)</span>
    
    <span class='nv'>circle_data</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/do.call.html'>do.call</a></span><span class='o'>(</span><span class='nv'>rbind</span>, <span class='nv'>circle_data</span><span class='o'>)</span>
    
    <span class='c'># Transform to viewport coords</span>
    <span class='nv'>circle_data</span> <span class='o'>&lt;-</span> <span class='nv'>coord</span><span class='o'>$</span><span class='nf'>transform</span><span class='o'>(</span><span class='nv'>circle_data</span>, <span class='nv'>panel_params</span><span class='o'>)</span>
    
    <span class='c'># Draw as grob</span>
    <span class='nf'>grid</span><span class='nf'>::</span><span class='nf'><a href='https://rdrr.io/r/grid/grid.polygon.html'>polygonGrob</a></span><span class='o'>(</span>
      x <span class='o'>=</span> <span class='nv'>circle_data</span><span class='o'>$</span><span class='nv'>x</span>,
      y <span class='o'>=</span> <span class='nv'>circle_data</span><span class='o'>$</span><span class='nv'>y</span>,
      id.lengths <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/rep.html'>rep</a></span><span class='o'>(</span><span class='m'>100</span>, <span class='nf'><a href='https://rdrr.io/r/base/nrow.html'>nrow</a></span><span class='o'>(</span><span class='nv'>data</span><span class='o'>)</span><span class='o'>)</span>,
      default.units <span class='o'>=</span> <span class='s'>"native"</span>,
      gp <span class='o'>=</span> <span class='nf'>grid</span><span class='nf'>::</span><span class='nf'><a href='https://rdrr.io/r/grid/gpar.html'>gpar</a></span><span class='o'>(</span>
        col <span class='o'>=</span> <span class='nv'>data</span><span class='o'>$</span><span class='nv'>colour</span>,
        fill <span class='o'>=</span> <span class='nv'>data</span><span class='o'>$</span><span class='nv'>fill</span>,
        lwd <span class='o'>=</span> <span class='nv'>data</span><span class='o'>$</span><span class='nv'>size</span> <span class='o'>*</span> <span class='nv'>.pt</span>,
        lty <span class='o'>=</span> <span class='nv'>data</span><span class='o'>$</span><span class='nv'>linetype</span>
      <span class='o'>)</span>
    <span class='o'>)</span>
  <span class='o'>&#125;</span>,
  required_aes <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"x"</span>, <span class='s'>"y"</span>, <span class='s'>"radius"</span><span class='o'>)</span>,
  default_aes <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/aes.html'>aes</a></span><span class='o'>(</span>
    colour <span class='o'>=</span> <span class='s'>"black"</span>,
    fill <span class='o'>=</span> <span class='s'>"grey"</span>,
    size <span class='o'>=</span> <span class='m'>0.5</span>,
    linetype <span class='o'>=</span> <span class='m'>1</span>,
    alpha <span class='o'>=</span> <span class='kc'>NA</span>
  <span class='o'>)</span>,
  draw_key <span class='o'>=</span> <span class='nv'>draw_key_polygon</span>
<span class='o'>)</span>

<span class='nv'>geom_circle</span> <span class='o'>&lt;-</span> <span class='kr'>function</span><span class='o'>(</span><span class='nv'>mapping</span> <span class='o'>=</span> <span class='kc'>NULL</span>, <span class='nv'>data</span> <span class='o'>=</span> <span class='kc'>NULL</span>, <span class='nv'>stat</span> <span class='o'>=</span> <span class='s'>"identity"</span>, 
                        <span class='nv'>position</span> <span class='o'>=</span> <span class='s'>"identity"</span>, <span class='nv'>...</span>, <span class='nv'>na.rm</span> <span class='o'>=</span> <span class='kc'>FALSE</span>, 
                        <span class='nv'>show.legend</span> <span class='o'>=</span> <span class='kc'>NA</span>, <span class='nv'>inherit.aes</span> <span class='o'>=</span> <span class='kc'>TRUE</span><span class='o'>)</span> <span class='o'>&#123;</span>
  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/layer.html'>layer</a></span><span class='o'>(</span>
    data <span class='o'>=</span> <span class='nv'>data</span>,
    mapping <span class='o'>=</span> <span class='nv'>mapping</span>,
    stat <span class='o'>=</span> <span class='nv'>stat</span>,
    geom <span class='o'>=</span> <span class='nv'>GeomCircle</span>,
    position <span class='o'>=</span> <span class='nv'>position</span>,
    show.legend <span class='o'>=</span> <span class='nv'>show.legend</span>,
    inherit.aes <span class='o'>=</span> <span class='nv'>inherit.aes</span>,
    params <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span>
      na.rm <span class='o'>=</span> <span class='nv'>na.rm</span>,
      <span class='nv'>...</span>
    <span class='o'>)</span>
  <span class='o'>)</span>
<span class='o'>&#125;</span></code></pre>

</div>

As a sanity check, let us check that this actually works:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>random_points</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/data.frame.html'>data.frame</a></span><span class='o'>(</span>
  x <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/stats/Uniform.html'>runif</a></span><span class='o'>(</span><span class='m'>20</span><span class='o'>)</span>,
  y <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/stats/Uniform.html'>runif</a></span><span class='o'>(</span><span class='m'>20</span><span class='o'>)</span>,
  radius <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/stats/Uniform.html'>runif</a></span><span class='o'>(</span><span class='m'>20</span>, max <span class='o'>=</span> <span class='m'>0.1</span><span class='o'>)</span>,
  value <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/stats/Uniform.html'>runif</a></span><span class='o'>(</span><span class='m'>20</span><span class='o'>)</span>
<span class='o'>)</span>

<span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggplot.html'>ggplot</a></span><span class='o'>(</span><span class='nv'>random_points</span><span class='o'>)</span> <span class='o'>+</span> 
  <span class='nf'>geom_circle</span><span class='o'>(</span><span class='nf'><a href='https://ggplot2.tidyverse.org/reference/aes.html'>aes</a></span><span class='o'>(</span>x <span class='o'>=</span> <span class='nv'>x</span>, y <span class='o'>=</span> <span class='nv'>y</span>, radius <span class='o'>=</span> <span class='nv'>radius</span>, size <span class='o'>=</span> <span class='nv'>value</span><span class='o'>)</span><span class='o'>)</span>
</code></pre>
<img src="figs/unnamed-chunk-5-1.png" width="700px" style="display: block; margin: auto;" />

</div>

It seems to work as intended. As can be seen from the code above, the `size` aesthetics is not used much and is passed directly into `polygonGrob()`. It follows that updating the code to using linewidth is not a huge operation.

> There is nothing preventing you from keeping the code as is --- it will continue to work as always. However, your users may begin to feel a disconnect with the style as they adapt to the new `linewidth` aesthetic so it is highly recommended to make the proposed changes

### The fix

There are a few things you need to do to update the old code but they are all pretty benign. The changes are commented in the code below and will also be discussed afterwards

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>GeomCircle</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggproto.html'>ggproto</a></span><span class='o'>(</span><span class='s'>"GeomCircle"</span>, <span class='nv'>Geom</span>,
  draw_panel <span class='o'>=</span> <span class='kr'>function</span><span class='o'>(</span><span class='nv'>data</span>, <span class='nv'>panel_params</span>, <span class='nv'>coord</span><span class='o'>)</span> <span class='o'>&#123;</span>
    <span class='c'># Expand x, y, radius data to points along circle</span>
    <span class='nv'>circle_data</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/funprog.html'>Map</a></span><span class='o'>(</span><span class='kr'>function</span><span class='o'>(</span><span class='nv'>x</span>, <span class='nv'>y</span>, <span class='nv'>r</span><span class='o'>)</span> <span class='o'>&#123;</span>
      <span class='nv'>radians</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/seq.html'>seq</a></span><span class='o'>(</span><span class='m'>0</span>, <span class='m'>2</span><span class='o'>*</span><span class='nv'>pi</span>, length.out <span class='o'>=</span> <span class='m'>101</span><span class='o'>)</span><span class='o'>[</span><span class='o'>-</span><span class='m'>1</span><span class='o'>]</span>
      <span class='nf'><a href='https://rdrr.io/r/base/data.frame.html'>data.frame</a></span><span class='o'>(</span>
        x <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/Trig.html'>cos</a></span><span class='o'>(</span><span class='nv'>radians</span><span class='o'>)</span> <span class='o'>*</span> <span class='nv'>r</span> <span class='o'>+</span> <span class='nv'>x</span>,
        y <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/Trig.html'>sin</a></span><span class='o'>(</span><span class='nv'>radians</span><span class='o'>)</span> <span class='o'>*</span> <span class='nv'>r</span> <span class='o'>+</span> <span class='nv'>y</span>
      <span class='o'>)</span>
    <span class='o'>&#125;</span>, x <span class='o'>=</span> <span class='nv'>data</span><span class='o'>$</span><span class='nv'>x</span>, y <span class='o'>=</span> <span class='nv'>data</span><span class='o'>$</span><span class='nv'>y</span>, r <span class='o'>=</span> <span class='nv'>data</span><span class='o'>$</span><span class='nv'>radius</span><span class='o'>)</span>
    
    <span class='nv'>circle_data</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/do.call.html'>do.call</a></span><span class='o'>(</span><span class='nv'>rbind</span>, <span class='nv'>circle_data</span><span class='o'>)</span>
    
    <span class='c'># Transform to viewport coords</span>
    <span class='nv'>circle_data</span> <span class='o'>&lt;-</span> <span class='nv'>coord</span><span class='o'>$</span><span class='nf'>transform</span><span class='o'>(</span><span class='nv'>circle_data</span>, <span class='nv'>panel_params</span><span class='o'>)</span>
    
    <span class='c'># Draw as grob</span>
    <span class='nf'>grid</span><span class='nf'>::</span><span class='nf'><a href='https://rdrr.io/r/grid/grid.polygon.html'>polygonGrob</a></span><span class='o'>(</span>
      x <span class='o'>=</span> <span class='nv'>circle_data</span><span class='o'>$</span><span class='nv'>x</span>,
      y <span class='o'>=</span> <span class='nv'>circle_data</span><span class='o'>$</span><span class='nv'>y</span>,
      id.lengths <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/rep.html'>rep</a></span><span class='o'>(</span><span class='m'>100</span>, <span class='nf'><a href='https://rdrr.io/r/base/nrow.html'>nrow</a></span><span class='o'>(</span><span class='nv'>data</span><span class='o'>)</span><span class='o'>)</span>,
      default.units <span class='o'>=</span> <span class='s'>"native"</span>,
      gp <span class='o'>=</span> <span class='nf'>grid</span><span class='nf'>::</span><span class='nf'><a href='https://rdrr.io/r/grid/gpar.html'>gpar</a></span><span class='o'>(</span>
        col <span class='o'>=</span> <span class='nv'>data</span><span class='o'>$</span><span class='nv'>colour</span>,
        fill <span class='o'>=</span> <span class='nv'>data</span><span class='o'>$</span><span class='nv'>fill</span>,
        <span class='c'># Use linewidth or fall back to size in old ggplot2 versions</span>
        lwd <span class='o'>=</span> <span class='o'>(</span><span class='nv'>data</span><span class='o'>$</span><span class='nv'>linewidth</span> <span class='o'><a href='https://rlang.r-lib.org/reference/op-null-default.html'>%||%</a></span> <span class='nv'>data</span><span class='o'>$</span><span class='nv'>size</span><span class='o'>)</span> <span class='o'>*</span> <span class='nv'>.pt</span>,
        lty <span class='o'>=</span> <span class='nv'>data</span><span class='o'>$</span><span class='nv'>linetype</span>
      <span class='o'>)</span>
    <span class='o'>)</span>
  <span class='o'>&#125;</span>,
  required_aes <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"x"</span>, <span class='s'>"y"</span>, <span class='s'>"radius"</span><span class='o'>)</span>,
  default_aes <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/aes.html'>aes</a></span><span class='o'>(</span>
    colour <span class='o'>=</span> <span class='s'>"black"</span>,
    fill <span class='o'>=</span> <span class='s'>"grey"</span>,
    <span class='c'># Switch size to linewidth</span>
    linewidth <span class='o'>=</span> <span class='m'>0.5</span>,
    linetype <span class='o'>=</span> <span class='m'>1</span>,
    alpha <span class='o'>=</span> <span class='kc'>NA</span>
  <span class='o'>)</span>,
  draw_key <span class='o'>=</span> <span class='nv'>draw_key_polygon</span>,
  <span class='c'># To allow using size in ggplot2 &lt; 3.4.0</span>
  non_missing_aes <span class='o'>=</span> <span class='s'>"size"</span>,
  
  <span class='c'># Tell ggplot2 to perform automatic renaming</span>
  rename_size <span class='o'>=</span> <span class='kc'>TRUE</span>
<span class='o'>)</span></code></pre>

</div>

As we can see above, we need two changes and two additions to our implementation. First (but last in the code), we add `rename_size = TRUE` to our geom implementation. This instructs ggplot2 that this layer has a `size` aesthetic that should be converted automatically with a deprecation warning. Setting this to `TRUE` allows you to rest assured that as far as your code goes you can expect to have a `linewidth` aesthetic. Second, we updates the `default_aes` to use `linewidth` instead of `size`. Third, wherever we use `size` in our geom logic we instead use `linewidth %||% size`. The reason for the fallback is that if your package is used together with an older version of ggplot2 the `rename_size = TRUE` line has no effect and you need to fall back to `size` if that is what the user has specified. Fourth, we add `size` to the `non_missing_aes` field. As with the last point, this is only relevant for use with older versions of ggplot2 as it instructs the geom to not warn when `size` is used.

Let's try out the new implementation:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggplot.html'>ggplot</a></span><span class='o'>(</span><span class='nv'>random_points</span><span class='o'>)</span> <span class='o'>+</span> 
  <span class='nf'>geom_circle</span><span class='o'>(</span><span class='nf'><a href='https://ggplot2.tidyverse.org/reference/aes.html'>aes</a></span><span class='o'>(</span>x <span class='o'>=</span> <span class='nv'>x</span>, y <span class='o'>=</span> <span class='nv'>y</span>, radius <span class='o'>=</span> <span class='nv'>radius</span>, size <span class='o'>=</span> <span class='nv'>value</span><span class='o'>)</span><span class='o'>)</span>
<span class='c'>#&gt; <span style='color: #00BB00;'>size</span> aesthetic has been deprecated for use with lines as of ggplot2 3.4.0</span>
<span class='c'>#&gt; <span style='color: #00BBBB;'>ℹ</span> Please use <span style='color: #00BB00;'>linewidth</span> aesthetic instead</span>
<span class='c'>#&gt; <span style='color: #555555;'>This message is displayed once every 8 hours.</span></span>
</code></pre>
<img src="figs/unnamed-chunk-7-1.png" width="700px" style="display: block; margin: auto;" />

</div>

We see that we get the deprecation warning we know and that everything also renders as expected. Using the new naming also works, picks up the linear `linewidth` scale, and doesn't have a warning.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggplot.html'>ggplot</a></span><span class='o'>(</span><span class='nv'>random_points</span><span class='o'>)</span> <span class='o'>+</span> 
  <span class='nf'>geom_circle</span><span class='o'>(</span><span class='nf'><a href='https://ggplot2.tidyverse.org/reference/aes.html'>aes</a></span><span class='o'>(</span>x <span class='o'>=</span> <span class='nv'>x</span>, y <span class='o'>=</span> <span class='nv'>y</span>, radius <span class='o'>=</span> <span class='nv'>radius</span>, linewidth <span class='o'>=</span> <span class='nv'>value</span><span class='o'>)</span><span class='o'>)</span>
</code></pre>
<img src="figs/unnamed-chunk-8-1.png" width="700px" style="display: block; margin: auto;" />

</div>

The legend looks a bit wonky, but that is because the polygon key function caps the linewidth at a certain size relative to the size of the key. We can see that it works fine using a lower range:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://ggplot2.tidyverse.org/reference/last_plot.html'>last_plot</a></span><span class='o'>(</span><span class='o'>)</span> <span class='o'>+</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/scale_linewidth.html'>scale_linewidth</a></span><span class='o'>(</span>range <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='m'>0.1</span>, <span class='m'>2</span><span class='o'>)</span><span class='o'>)</span>
</code></pre>
<img src="figs/unnamed-chunk-9-1.png" width="700px" style="display: block; margin: auto;" />

</div>

## FAQ

*I'm creating a geom as a subclass of one of the ggplot2 geoms that now uses `linewidth` --- what should I do?*

If your geom inherits from e.g. [`geom_polygon()`](https://ggplot2.tidyverse.org/reference/geom_polygon.html) which in the next version will begin using `linewidth` all you have to do is to update your code to refer to `linetype` instead of `size` if it uses that anywhere. Your geom will already inherit the correct `rename_size` value.

*I'm creating a stat --- should I do anything?*

Probably not. The only exception is if you set `size` in `default_aes` to a calculated value and the expectance is that the geom used with the stat will change to using `linewidth`. In such situations you should change the `default_aes` setting to use `linewidth` instead. We haven't had any such situations in the ggplot2 code base so the chance of this being relevant is pretty low.

*I'm creating a geom that uses `size` for both point sizing and line width --- how should I proceed?*

If you have a geom where `size` doubles for both point sizes and linewidth (an example from ggplot2 is [`geom_pointrange()`](https://ggplot2.tidyverse.org/reference/geom_linerange.html)) you shouldn't set `rename_size = TRUE` since `size` remains a valid aesthetic. However, you should add `linewidth` to `default_aes` and use this wherever in your code `size` was used for linewidth scaling before. Do note that this is a breaking change for your users since the same piece of code may no longer produce the same output.

