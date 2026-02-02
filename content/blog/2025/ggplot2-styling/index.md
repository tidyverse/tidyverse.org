---
output: hugodown::md_document

slug: ggplot2-styling
title: ggplot2 styling
date: 2025-10-01
author: Teun van den Brand
description: >
    This post discusses one function in ggplot2: `theme()`. Find out about the glamour of graphics in this deep-dive article.

photo:
  url: https://www.pexels.com/photo/people-dressed-in-elaborate-costumes-for-venetian-masqueade-5932619
  author: Helena Jankovičová Kováčová

# one of: "deep-dive", "learn", "package", "programming", "roundup", or "other"
categories: [package] 
tags: []
rmd_hash: ebbc03cc3a02d813
html_dependencies:
- <link href="htmltools-fill-0.5.8.1/fill.css" rel="stylesheet" />
- <script src="htmlwidgets-1.6.4/htmlwidgets.js"></script>
- <script src="d3-bundle-5.16.0/d3-bundle.min.js"></script>
- <script src="d3-lasso-0.0.5/d3-lasso.min.js"></script>
- <script src="save-svg-as-png-1.4.17/save-svg-as-png.min.js"></script>
- <script src="flatbush-4.4.0/flatbush.min.js"></script>
- <link href="ggiraphjs-0.8.10/ggiraphjs.min.css" rel="stylesheet" />
- <script src="ggiraphjs-0.8.10/ggiraphjs.min.js"></script>
- <script src="girafe-binding-0.9.1/girafe.js"></script>

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

We will set out to illuminate how to set the stylistic finishing touches on your visualisations made with the ggplot2 package. The ggplot2 package has had a [recent release](https://www.tidyverse.org/blog/2025/09/ggplot2-4-0-0/) that included some relevant changes to styling plots. In ggplot2, the theme system is responsible for many non-data aspects of how your plot looks. It covers anything from panels, to axes, titles and legends. Here, we'll get started with digesting important parts of the theme system. We'll start with complete themes, get into theme elements followed by how these elements are used in various parts of the plot and finish off with some tips, including how to write your own theme functions. Before we begin discussing themes, let's make an example plot that can showcase many aspects.

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
<span><span class='nv'>p</span></span></code></pre>

</div>

<div class="highlight">

<div class="girafe html-widget html-fill-item" id="htmlwidget-d98064058d21aab41c73" style="width:700px;height:415.296px;"></div>
<script type="application/json" data-for="htmlwidget-d98064058d21aab41c73">{"x":{"html":"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<svg xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink' class='ggiraph-svg' role='graphics-document' id='svg_55735f3a_43be_433d_b895_216b1a6034dd' viewBox='0 0 504 311.47'>\n <style><![CDATA[.hover_theme_svg_55735f3a_43be_433d_b895_216b1a6034dd[theme-id = \"plot.caption\"] { fill:red; }.hover_theme_svg_55735f3a_43be_433d_b895_216b1a6034dd[theme-id = \"plot.title\"] { fill:red; }.hover_theme_svg_55735f3a_43be_433d_b895_216b1a6034dd[theme-id = \"legend.text\"] { fill:red; }.hover_theme_svg_55735f3a_43be_433d_b895_216b1a6034dd[theme-id = \"legend.ticks\"] { stroke:red; }.hover_theme_svg_55735f3a_43be_433d_b895_216b1a6034dd[theme-id = \"legend.frame<br>palette.colour.continuous\"] { stroke:red;fill:#FF888888; }.hover_theme_svg_55735f3a_43be_433d_b895_216b1a6034dd[theme-id = \"legend.box.background\"] { stroke:red;fill:#FFEEEE; }.hover_theme_svg_55735f3a_43be_433d_b895_216b1a6034dd[theme-id = \"axis.title.y.left\"] { fill:red; }.hover_theme_svg_55735f3a_43be_433d_b895_216b1a6034dd[theme-id = \"axis.ticks.y.left\"] { stroke:red; }.hover_theme_svg_55735f3a_43be_433d_b895_216b1a6034dd[theme-id = \"axis.text.y.left\"] { fill:red; }.hover_theme_svg_55735f3a_43be_433d_b895_216b1a6034dd[theme-id = \"legend.key\"] { stroke:red;fill:#FFCCCC; }.hover_theme_svg_55735f3a_43be_433d_b895_216b1a6034dd[theme-id = \"axis.title.x.bottom\"] { fill:red; }.hover_theme_svg_55735f3a_43be_433d_b895_216b1a6034dd[theme-id = \"panel.grid.major.x\"] { stroke:red; }.hover_data_svg_55735f3a_43be_433d_b895_216b1a6034dd[data-id = \"geom\"] { stroke:red;fill:red; }.hover_theme_svg_55735f3a_43be_433d_b895_216b1a6034dd[theme-id = \"plot.background\"] { stroke:red;fill:#FFEEEE; }.hover_theme_svg_55735f3a_43be_433d_b895_216b1a6034dd[theme-id = \"axis.ticks.x.bottom\"] { stroke:red; }.hover_theme_svg_55735f3a_43be_433d_b895_216b1a6034dd[theme-id = \"plot.subtitle\"] { fill:red; }.hover_theme_svg_55735f3a_43be_433d_b895_216b1a6034dd[theme-id = \"axis.line.x.bottom\"] { stroke:red; }.hover_theme_svg_55735f3a_43be_433d_b895_216b1a6034dd[theme-id = \"panel.background<br>panel.border\"] { stroke:red;fill:#FFCCCC; }.hover_theme_svg_55735f3a_43be_433d_b895_216b1a6034dd[theme-id = \"panel.grid.minor.y\"] { stroke:red; }.hover_theme_svg_55735f3a_43be_433d_b895_216b1a6034dd[theme-id = \"panel.grid.minor.x\"] { stroke:red; }.hover_theme_svg_55735f3a_43be_433d_b895_216b1a6034dd[theme-id = \"legend.background\"] { stroke:red;fill:#FFEEEE; }.hover_theme_svg_55735f3a_43be_433d_b895_216b1a6034dd[theme-id = \"strip.background.x\"] { stroke:red;fill:#FF8888; }.hover_theme_svg_55735f3a_43be_433d_b895_216b1a6034dd[theme-id = \"axis.text.x.bottom\"] { fill:red; }.hover_theme_svg_55735f3a_43be_433d_b895_216b1a6034dd[theme-id = \"panel.grid.major.y\"] { stroke:red; }.hover_theme_svg_55735f3a_43be_433d_b895_216b1a6034dd[theme-id = \"strip.text.x.top\"] { fill:red; }.hover_key_svg_55735f3a_43be_433d_b895_216b1a6034dd[key-id = \"shape\"] { stroke:red;fill:red; }.hover_theme_svg_55735f3a_43be_433d_b895_216b1a6034dd[theme-id = \"legend.title\"] { fill:red; }.hover_theme_svg_55735f3a_43be_433d_b895_216b1a6034dd[theme-id = \"axis.line.y.left\"] { stroke:red; }]]><\/style>\n <defs id='svg_55735f3a_43be_433d_b895_216b1a6034dd_defs'>\n  <clipPath id='svg_55735f3a_43be_433d_b895_216b1a6034dd_c1'>\n   <rect x='0' y='0' width='504' height='311.47'/>\n  <\/clipPath>\n  <clipPath id='svg_55735f3a_43be_433d_b895_216b1a6034dd_c2'>\n   <rect x='33.14' y='55.77' width='193.93' height='210.58'/>\n  <\/clipPath>\n  <clipPath id='svg_55735f3a_43be_433d_b895_216b1a6034dd_c3'>\n   <rect x='232.54' y='55.77' width='193.93' height='210.58'/>\n  <\/clipPath>\n  <clipPath id='svg_55735f3a_43be_433d_b895_216b1a6034dd_c4'>\n   <rect x='33.14' y='38.85' width='193.93' height='16.92'/>\n  <\/clipPath>\n  <clipPath id='svg_55735f3a_43be_433d_b895_216b1a6034dd_c5'>\n   <rect x='232.54' y='38.85' width='193.93' height='16.92'/>\n  <\/clipPath>\n <\/defs>\n <g id='svg_55735f3a_43be_433d_b895_216b1a6034dd_rootg' class='ggiraph-svg-rootg'>\n  <g clip-path='url(#svg_55735f3a_43be_433d_b895_216b1a6034dd_c1)'>\n   <rect x='0' y='0' width='504' height='311.47' fill='#FFFFFF' fill-opacity='1' stroke='#FFFFFF' stroke-opacity='1' stroke-width='0.75' stroke-linejoin='round' stroke-linecap='round' class='ggiraph-svg-bg'/>\n   <rect id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e1' x='0' y='0' width='504' height='311.47' fill='#FFFFFF' fill-opacity='1' stroke='#FFFFFF' stroke-opacity='1' stroke-width='1.07' stroke-linejoin='round' stroke-linecap='round' title='&amp;lt;code&amp;gt;plot.background&amp;lt;/code&amp;gt;' theme-id='plot.background'/>\n  <\/g>\n  <g clip-path='url(#svg_55735f3a_43be_433d_b895_216b1a6034dd_c2)'>\n   <rect id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e2' x='33.14' y='55.77' width='193.93' height='210.58' fill='#EBEBEB' fill-opacity='1' stroke='none' title='&amp;lt;code&amp;gt;panel.background&amp;lt;br&amp;gt;panel.border&amp;lt;/code&amp;gt;' theme-id='panel.background&lt;br&gt;panel.border'/>\n   <polyline id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e3' points='33.14,238.83 227.06,238.83' fill='none' stroke='#FFFFFF' stroke-opacity='1' stroke-width='0.53' stroke-linejoin='round' stroke-linecap='butt' title='&amp;lt;code&amp;gt;panel.grid.minor.y&amp;lt;/code&amp;gt;' theme-id='panel.grid.minor.y'/>\n   <polyline id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e4' points='33.14,179.00 227.06,179.00' fill='none' stroke='#FFFFFF' stroke-opacity='1' stroke-width='0.53' stroke-linejoin='round' stroke-linecap='butt' title='&amp;lt;code&amp;gt;panel.grid.minor.y&amp;lt;/code&amp;gt;' theme-id='panel.grid.minor.y'/>\n   <polyline id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e5' points='33.14,119.18 227.06,119.18' fill='none' stroke='#FFFFFF' stroke-opacity='1' stroke-width='0.53' stroke-linejoin='round' stroke-linecap='butt' title='&amp;lt;code&amp;gt;panel.grid.minor.y&amp;lt;/code&amp;gt;' theme-id='panel.grid.minor.y'/>\n   <polyline id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e6' points='33.14,59.36 227.06,59.36' fill='none' stroke='#FFFFFF' stroke-opacity='1' stroke-width='0.53' stroke-linejoin='round' stroke-linecap='butt' title='&amp;lt;code&amp;gt;panel.grid.minor.y&amp;lt;/code&amp;gt;' theme-id='panel.grid.minor.y'/>\n   <polyline id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e7' points='38.69,266.35 38.69,55.77' fill='none' stroke='#FFFFFF' stroke-opacity='1' stroke-width='0.53' stroke-linejoin='round' stroke-linecap='butt' title='&amp;lt;code&amp;gt;panel.grid.minor.x&amp;lt;/code&amp;gt;' theme-id='panel.grid.minor.x'/>\n   <polyline id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e8' points='71.34,266.35 71.34,55.77' fill='none' stroke='#FFFFFF' stroke-opacity='1' stroke-width='0.53' stroke-linejoin='round' stroke-linecap='butt' title='&amp;lt;code&amp;gt;panel.grid.minor.x&amp;lt;/code&amp;gt;' theme-id='panel.grid.minor.x'/>\n   <polyline id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e9' points='103.98,266.35 103.98,55.77' fill='none' stroke='#FFFFFF' stroke-opacity='1' stroke-width='0.53' stroke-linejoin='round' stroke-linecap='butt' title='&amp;lt;code&amp;gt;panel.grid.minor.x&amp;lt;/code&amp;gt;' theme-id='panel.grid.minor.x'/>\n   <polyline id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e10' points='136.63,266.35 136.63,55.77' fill='none' stroke='#FFFFFF' stroke-opacity='1' stroke-width='0.53' stroke-linejoin='round' stroke-linecap='butt' title='&amp;lt;code&amp;gt;panel.grid.minor.x&amp;lt;/code&amp;gt;' theme-id='panel.grid.minor.x'/>\n   <polyline id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e11' points='169.28,266.35 169.28,55.77' fill='none' stroke='#FFFFFF' stroke-opacity='1' stroke-width='0.53' stroke-linejoin='round' stroke-linecap='butt' title='&amp;lt;code&amp;gt;panel.grid.minor.x&amp;lt;/code&amp;gt;' theme-id='panel.grid.minor.x'/>\n   <polyline id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e12' points='201.93,266.35 201.93,55.77' fill='none' stroke='#FFFFFF' stroke-opacity='1' stroke-width='0.53' stroke-linejoin='round' stroke-linecap='butt' title='&amp;lt;code&amp;gt;panel.grid.minor.x&amp;lt;/code&amp;gt;' theme-id='panel.grid.minor.x'/>\n   <polyline id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e13' points='33.14,208.92 227.06,208.92' fill='none' stroke='#FFFFFF' stroke-opacity='1' stroke-width='1.07' stroke-linejoin='round' stroke-linecap='butt' title='&amp;lt;code&amp;gt;panel.grid.major.y&amp;lt;/code&amp;gt;' theme-id='panel.grid.major.y'/>\n   <polyline id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e14' points='33.14,149.09 227.06,149.09' fill='none' stroke='#FFFFFF' stroke-opacity='1' stroke-width='1.07' stroke-linejoin='round' stroke-linecap='butt' title='&amp;lt;code&amp;gt;panel.grid.major.y&amp;lt;/code&amp;gt;' theme-id='panel.grid.major.y'/>\n   <polyline id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e15' points='33.14,89.27 227.06,89.27' fill='none' stroke='#FFFFFF' stroke-opacity='1' stroke-width='1.07' stroke-linejoin='round' stroke-linecap='butt' title='&amp;lt;code&amp;gt;panel.grid.major.y&amp;lt;/code&amp;gt;' theme-id='panel.grid.major.y'/>\n   <polyline id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e16' points='55.01,266.35 55.01,55.77' fill='none' stroke='#FFFFFF' stroke-opacity='1' stroke-width='1.07' stroke-linejoin='round' stroke-linecap='butt' title='&amp;lt;code&amp;gt;panel.grid.major.x&amp;lt;/code&amp;gt;' theme-id='panel.grid.major.x'/>\n   <polyline id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e17' points='87.66,266.35 87.66,55.77' fill='none' stroke='#FFFFFF' stroke-opacity='1' stroke-width='1.07' stroke-linejoin='round' stroke-linecap='butt' title='&amp;lt;code&amp;gt;panel.grid.major.x&amp;lt;/code&amp;gt;' theme-id='panel.grid.major.x'/>\n   <polyline id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e18' points='120.31,266.35 120.31,55.77' fill='none' stroke='#FFFFFF' stroke-opacity='1' stroke-width='1.07' stroke-linejoin='round' stroke-linecap='butt' title='&amp;lt;code&amp;gt;panel.grid.major.x&amp;lt;/code&amp;gt;' theme-id='panel.grid.major.x'/>\n   <polyline id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e19' points='152.95,266.35 152.95,55.77' fill='none' stroke='#FFFFFF' stroke-opacity='1' stroke-width='1.07' stroke-linejoin='round' stroke-linecap='butt' title='&amp;lt;code&amp;gt;panel.grid.major.x&amp;lt;/code&amp;gt;' theme-id='panel.grid.major.x'/>\n   <polyline id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e20' points='185.60,266.35 185.60,55.77' fill='none' stroke='#FFFFFF' stroke-opacity='1' stroke-width='1.07' stroke-linejoin='round' stroke-linecap='butt' title='&amp;lt;code&amp;gt;panel.grid.major.x&amp;lt;/code&amp;gt;' theme-id='panel.grid.major.x'/>\n   <polyline id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e21' points='218.25,266.35 218.25,55.77' fill='none' stroke='#FFFFFF' stroke-opacity='1' stroke-width='1.07' stroke-linejoin='round' stroke-linecap='butt' title='&amp;lt;code&amp;gt;panel.grid.major.x&amp;lt;/code&amp;gt;' theme-id='panel.grid.major.x'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e22' points='48.48,152.04 51.11,156.60 45.85,156.60' fill='#29567D' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e23' points='48.48,152.04 51.11,156.60 45.85,156.60' fill='#306591' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e24' points='81.13,169.98 83.76,174.54 78.50,174.54' fill='#244C6F' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e25' points='81.13,169.98 83.76,174.54 78.50,174.54' fill='#29567D' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <circle id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e26' cx='48.48' cy='173.02' r='1.47pt' fill='#29567D' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <circle id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e27' cx='48.48' cy='179' r='1.47pt' fill='#244C6F' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <circle id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e28' cx='81.13' cy='179' r='1.47pt' fill='#214769' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <circle id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e29' cx='81.13' cy='179' r='1.47pt' fill='#265176' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <circle id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e30' cx='81.13' cy='184.99' r='1.47pt' fill='#214769' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e31' points='173.85,228.82 177.76,228.82 177.76,224.91 173.85,224.91' fill='#1C3D5C' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e32' points='173.85,174.98 177.76,174.98 177.76,171.07 173.85,171.07' fill='#244C6F' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e33' points='173.85,192.92 177.76,192.92 177.76,189.01 173.85,189.01' fill='#214769' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <circle id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e34' cx='175.81' cy='238.83' r='1.47pt' fill='#18344F' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <circle id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e35' cx='201.93' cy='226.86' r='1.47pt' fill='#1F4262' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e36' points='68.07,164.00 70.70,168.56 65.44,168.56' fill='#2B5B83' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e37' points='90.92,169.98 93.56,174.54 88.29,174.54' fill='#29567D' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e38' points='68.07,181.95 70.70,186.51 65.44,186.51' fill='#29567D' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e39' points='87.66,181.95 90.29,186.51 85.03,186.51' fill='#265176' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e40' points='97.45,193.91 100.09,198.47 94.82,198.47' fill='#244C6F' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e41' points='97.45,193.91 100.09,198.47 94.82,198.47' fill='#244C6F' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e42' points='113.78,193.91 116.41,198.47 111.14,198.47' fill='#214769' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e43' points='113.78,199.89 116.41,204.45 111.14,204.45' fill='#214769' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <circle id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e44' cx='117.04' cy='226.86' r='1.47pt' fill='#1C3D5C' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <circle id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e45' cx='117.04' cy='226.86' r='1.47pt' fill='#1F4262' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <circle id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e46' cx='159.48' cy='226.86' r='1.47pt' fill='#18344F' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <circle id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e47' cx='159.48' cy='238.83' r='1.47pt' fill='#18344F' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <circle id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e48' cx='117.04' cy='226.86' r='1.47pt' fill='#1C3D5C' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <circle id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e49' cx='159.48' cy='232.85' r='1.47pt' fill='#18344F' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <circle id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e50' cx='182.34' cy='238.83' r='1.47pt' fill='#18344F' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <circle id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e51' cx='159.48' cy='238.83' r='1.47pt' fill='#18344F' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <circle id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e52' cx='159.48' cy='232.85' r='1.47pt' fill='#18344F' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <circle id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e53' cx='182.34' cy='238.83' r='1.47pt' fill='#18344F' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e54' points='137.94,228.82 141.85,228.82 141.85,224.91 137.94,224.91' fill='#18344F' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e55' points='164.06,228.82 167.97,228.82 167.97,224.91 164.06,224.91' fill='#18344F' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <circle id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e56' cx='120.31' cy='226.86' r='1.47pt' fill='#1F4262' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <circle id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e57' cx='120.31' cy='214.9' r='1.47pt' fill='#214769' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <circle id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e58' cx='120.31' cy='226.86' r='1.47pt' fill='#1F4262' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <circle id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e59' cx='152.95' cy='226.86' r='1.47pt' fill='#1C3D5C' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <circle id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e60' cx='126.84' cy='226.86' r='1.47pt' fill='#1F4262' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <circle id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e61' cx='126.84' cy='226.86' r='1.47pt' fill='#1F4262' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <circle id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e62' cx='139.9' cy='232.85' r='1.47pt' fill='#1C3D5C' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <circle id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e63' cx='139.9' cy='232.85' r='1.47pt' fill='#1C3D5C' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <circle id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e64' cx='166.01' cy='238.83' r='1.47pt' fill='#18344F' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e65' points='111.82,174.98 115.73,174.98 115.73,171.07 111.82,171.07' fill='#29567D' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e66' points='111.82,180.96 115.73,180.96 115.73,177.05 111.82,177.05' fill='#29567D' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e67' points='137.94,204.89 141.85,204.89 141.85,200.98 137.94,200.98' fill='#214769' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e68' points='137.94,198.91 141.85,198.91 141.85,195.00 137.94,195.00' fill='#214769' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e69' points='41.95,128.11 44.59,132.67 39.32,132.67' fill='#438AC3' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e70' points='41.95,134.09 44.59,138.65 39.32,138.65' fill='#3875A6' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e71' points='41.95,134.09 44.59,138.65 39.32,138.65' fill='#3B7AAD' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e72' points='41.95,152.04 44.59,156.60 39.32,156.60' fill='#356F9F' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e73' points='41.95,134.09 44.59,138.65 39.32,138.65' fill='#3875A6' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e74' points='68.07,169.98 70.70,174.54 65.44,174.54' fill='#29567D' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e75' points='68.07,164.00 70.70,168.56 65.44,168.56' fill='#29567D' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e76' points='71.34,169.98 73.97,174.54 68.70,174.54' fill='#29567D' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e77' points='71.34,169.98 73.97,174.54 68.70,174.54' fill='#29567D' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e78' points='55.01,169.98 57.64,174.54 52.38,174.54' fill='#2B5B83' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e79' points='55.01,152.04 57.64,156.60 52.38,156.60' fill='#2B5B83' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <circle id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e80' cx='120.31' cy='208.92' r='1.47pt' fill='#214769' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <circle id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e81' cx='143.16' cy='226.86' r='1.47pt' fill='#1F4262' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <circle id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e82' cx='120.31' cy='238.83' r='1.47pt' fill='#18344F' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <circle id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e83' cx='139.9' cy='238.83' r='1.47pt' fill='#18344F' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e84' points='164.06,228.82 167.97,228.82 167.97,224.91 164.06,224.91' fill='#18344F' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e85' points='164.06,234.80 167.97,234.80 167.97,230.89 164.06,230.89' fill='#18344F' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <circle id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e86' cx='120.31' cy='226.86' r='1.47pt' fill='#1F4262' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <circle id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e87' cx='152.95' cy='226.86' r='1.47pt' fill='#1C3D5C' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e88' points='68.07,152.04 70.70,156.60 65.44,156.60' fill='#306591' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e89' points='68.07,164.00 70.70,168.56 65.44,168.56' fill='#2B5B83' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e90' points='87.66,169.98 90.29,174.54 85.03,174.54' fill='#29567D' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e91' points='87.66,175.96 90.29,180.52 85.03,180.52' fill='#2B5B83' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <circle id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e92' cx='97.45' cy='226.86' r='1.47pt' fill='#1F4262' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <circle id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e93' cx='97.45' cy='226.86' r='1.47pt' fill='#214769' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e94' points='90.92,169.98 93.56,174.54 88.29,174.54' fill='#29567D' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e95' points='113.78,169.98 116.41,174.54 111.14,174.54' fill='#244C6F' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e96' points='113.78,164.00 116.41,168.56 111.14,168.56' fill='#265176' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <circle id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e97' cx='71.34' cy='179' r='1.47pt' fill='#29567D' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <circle id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e98' cx='71.34' cy='184.99' r='1.47pt' fill='#29567D' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <circle id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e99' cx='61.54' cy='173.02' r='1.47pt' fill='#306591' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <circle id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e100' cx='61.54' cy='173.02' r='1.47pt' fill='#2B5B83' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <circle id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e101' cx='71.34' cy='173.02' r='1.47pt' fill='#2B5B83' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <circle id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e102' cx='71.34' cy='173.02' r='1.47pt' fill='#2B5B83' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <circle id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e103' cx='77.86' cy='208.92' r='1.47pt' fill='#214769' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <circle id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e104' cx='77.86' cy='208.92' r='1.47pt' fill='#244C6F' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <circle id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e105' cx='100.72' cy='214.9' r='1.47pt' fill='#214769' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <circle id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e106' cx='100.72' cy='226.86' r='1.47pt' fill='#214769' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e107' points='61.54,152.04 64.17,156.60 58.91,156.60' fill='#306591' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e108' points='61.54,164.00 64.17,168.56 58.91,168.56' fill='#306591' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e109' points='87.66,169.98 90.29,174.54 85.03,174.54' fill='#29567D' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e110' points='87.66,169.98 90.29,174.54 85.03,174.54' fill='#29567D' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e111' points='61.54,164.00 64.17,168.56 58.91,168.56' fill='#306591' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e112' points='61.54,152.04 64.17,156.60 58.91,156.60' fill='#306591' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e113' points='87.66,169.98 90.29,174.54 85.03,174.54' fill='#29567D' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e114' points='87.66,169.98 90.29,174.54 85.03,174.54' fill='#29567D' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e115' points='48.48,146.05 51.11,150.61 45.85,150.61' fill='#3875A6' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e116' points='48.48,128.11 51.11,132.67 45.85,132.67' fill='#3875A6' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e117' points='48.48,116.14 51.11,120.70 45.85,120.70' fill='#3D7FB4' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <circle id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e118' cx='143.16' cy='238.83' r='1.47pt' fill='#18344F' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <circle id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e119' cx='77.86' cy='208.92' r='1.47pt' fill='#214769' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <circle id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e120' cx='77.86' cy='208.92' r='1.47pt' fill='#244C6F' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <circle id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e121' cx='100.72' cy='226.86' r='1.47pt' fill='#214769' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <circle id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e122' cx='100.72' cy='214.9' r='1.47pt' fill='#214769' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e123' points='55.01,152.04 57.64,156.60 52.38,156.60' fill='#306591' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e124' points='55.01,169.98 57.64,174.54 52.38,174.54' fill='#2B5B83' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e125' points='81.13,181.95 83.76,186.51 78.50,186.51' fill='#265176' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e126' points='51.75,62.30 54.38,66.86 49.11,66.86' fill='#50A6E8' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e127' points='55.01,152.04 57.64,156.60 52.38,156.60' fill='#306591' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e128' points='55.01,169.98 57.64,174.54 52.38,174.54' fill='#2B5B83' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e129' points='81.13,187.93 83.76,192.49 78.50,192.49' fill='#244C6F' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e130' points='81.13,181.95 83.76,186.51 78.50,186.51' fill='#265176' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e131' points='51.75,62.30 54.38,66.86 49.11,66.86' fill='#56B1F7' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e132' points='51.75,80.25 54.38,84.81 49.11,84.81' fill='#458FCA' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e133' points='55.01,152.04 57.64,156.60 52.38,156.60' fill='#306591' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e134' points='55.01,169.98 57.64,174.54 52.38,174.54' fill='#2B5B83' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e135' points='48.48,152.04 51.11,156.60 45.85,156.60' fill='#306591' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e136' points='48.48,152.04 51.11,156.60 45.85,156.60' fill='#29567D' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e137' points='81.13,169.98 83.76,174.54 78.50,174.54' fill='#244C6F' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e138' points='81.13,169.98 83.76,174.54 78.50,174.54' fill='#29567D' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n  <\/g>\n  <g clip-path='url(#svg_55735f3a_43be_433d_b895_216b1a6034dd_c3)'>\n   <rect id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e139' x='232.54' y='55.77' width='193.93' height='210.58' fill='#EBEBEB' fill-opacity='1' stroke='none' title='&amp;lt;code&amp;gt;panel.background&amp;lt;br&amp;gt;panel.border&amp;lt;/code&amp;gt;' theme-id='panel.background&lt;br&gt;panel.border'/>\n   <polyline id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e140' points='232.54,238.83 426.47,238.83' fill='none' stroke='#FFFFFF' stroke-opacity='1' stroke-width='0.53' stroke-linejoin='round' stroke-linecap='butt' title='&amp;lt;code&amp;gt;panel.grid.minor.y&amp;lt;/code&amp;gt;' theme-id='panel.grid.minor.y'/>\n   <polyline id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e141' points='232.54,179.00 426.47,179.00' fill='none' stroke='#FFFFFF' stroke-opacity='1' stroke-width='0.53' stroke-linejoin='round' stroke-linecap='butt' title='&amp;lt;code&amp;gt;panel.grid.minor.y&amp;lt;/code&amp;gt;' theme-id='panel.grid.minor.y'/>\n   <polyline id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e142' points='232.54,119.18 426.47,119.18' fill='none' stroke='#FFFFFF' stroke-opacity='1' stroke-width='0.53' stroke-linejoin='round' stroke-linecap='butt' title='&amp;lt;code&amp;gt;panel.grid.minor.y&amp;lt;/code&amp;gt;' theme-id='panel.grid.minor.y'/>\n   <polyline id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e143' points='232.54,59.36 426.47,59.36' fill='none' stroke='#FFFFFF' stroke-opacity='1' stroke-width='0.53' stroke-linejoin='round' stroke-linecap='butt' title='&amp;lt;code&amp;gt;panel.grid.minor.y&amp;lt;/code&amp;gt;' theme-id='panel.grid.minor.y'/>\n   <polyline id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e144' points='238.09,266.35 238.09,55.77' fill='none' stroke='#FFFFFF' stroke-opacity='1' stroke-width='0.53' stroke-linejoin='round' stroke-linecap='butt' title='&amp;lt;code&amp;gt;panel.grid.minor.x&amp;lt;/code&amp;gt;' theme-id='panel.grid.minor.x'/>\n   <polyline id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e145' points='270.74,266.35 270.74,55.77' fill='none' stroke='#FFFFFF' stroke-opacity='1' stroke-width='0.53' stroke-linejoin='round' stroke-linecap='butt' title='&amp;lt;code&amp;gt;panel.grid.minor.x&amp;lt;/code&amp;gt;' theme-id='panel.grid.minor.x'/>\n   <polyline id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e146' points='303.39,266.35 303.39,55.77' fill='none' stroke='#FFFFFF' stroke-opacity='1' stroke-width='0.53' stroke-linejoin='round' stroke-linecap='butt' title='&amp;lt;code&amp;gt;panel.grid.minor.x&amp;lt;/code&amp;gt;' theme-id='panel.grid.minor.x'/>\n   <polyline id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e147' points='336.04,266.35 336.04,55.77' fill='none' stroke='#FFFFFF' stroke-opacity='1' stroke-width='0.53' stroke-linejoin='round' stroke-linecap='butt' title='&amp;lt;code&amp;gt;panel.grid.minor.x&amp;lt;/code&amp;gt;' theme-id='panel.grid.minor.x'/>\n   <polyline id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e148' points='368.68,266.35 368.68,55.77' fill='none' stroke='#FFFFFF' stroke-opacity='1' stroke-width='0.53' stroke-linejoin='round' stroke-linecap='butt' title='&amp;lt;code&amp;gt;panel.grid.minor.x&amp;lt;/code&amp;gt;' theme-id='panel.grid.minor.x'/>\n   <polyline id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e149' points='401.33,266.35 401.33,55.77' fill='none' stroke='#FFFFFF' stroke-opacity='1' stroke-width='0.53' stroke-linejoin='round' stroke-linecap='butt' title='&amp;lt;code&amp;gt;panel.grid.minor.x&amp;lt;/code&amp;gt;' theme-id='panel.grid.minor.x'/>\n   <polyline id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e150' points='232.54,208.92 426.47,208.92' fill='none' stroke='#FFFFFF' stroke-opacity='1' stroke-width='1.07' stroke-linejoin='round' stroke-linecap='butt' title='&amp;lt;code&amp;gt;panel.grid.major.y&amp;lt;/code&amp;gt;' theme-id='panel.grid.major.y'/>\n   <polyline id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e151' points='232.54,149.09 426.47,149.09' fill='none' stroke='#FFFFFF' stroke-opacity='1' stroke-width='1.07' stroke-linejoin='round' stroke-linecap='butt' title='&amp;lt;code&amp;gt;panel.grid.major.y&amp;lt;/code&amp;gt;' theme-id='panel.grid.major.y'/>\n   <polyline id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e152' points='232.54,89.27 426.47,89.27' fill='none' stroke='#FFFFFF' stroke-opacity='1' stroke-width='1.07' stroke-linejoin='round' stroke-linecap='butt' title='&amp;lt;code&amp;gt;panel.grid.major.y&amp;lt;/code&amp;gt;' theme-id='panel.grid.major.y'/>\n   <polyline id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e153' points='254.42,266.35 254.42,55.77' fill='none' stroke='#FFFFFF' stroke-opacity='1' stroke-width='1.07' stroke-linejoin='round' stroke-linecap='butt' title='&amp;lt;code&amp;gt;panel.grid.major.x&amp;lt;/code&amp;gt;' theme-id='panel.grid.major.x'/>\n   <polyline id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e154' points='287.06,266.35 287.06,55.77' fill='none' stroke='#FFFFFF' stroke-opacity='1' stroke-width='1.07' stroke-linejoin='round' stroke-linecap='butt' title='&amp;lt;code&amp;gt;panel.grid.major.x&amp;lt;/code&amp;gt;' theme-id='panel.grid.major.x'/>\n   <polyline id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e155' points='319.71,266.35 319.71,55.77' fill='none' stroke='#FFFFFF' stroke-opacity='1' stroke-width='1.07' stroke-linejoin='round' stroke-linecap='butt' title='&amp;lt;code&amp;gt;panel.grid.major.x&amp;lt;/code&amp;gt;' theme-id='panel.grid.major.x'/>\n   <polyline id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e156' points='352.36,266.35 352.36,55.77' fill='none' stroke='#FFFFFF' stroke-opacity='1' stroke-width='1.07' stroke-linejoin='round' stroke-linecap='butt' title='&amp;lt;code&amp;gt;panel.grid.major.x&amp;lt;/code&amp;gt;' theme-id='panel.grid.major.x'/>\n   <polyline id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e157' points='385.01,266.35 385.01,55.77' fill='none' stroke='#FFFFFF' stroke-opacity='1' stroke-width='1.07' stroke-linejoin='round' stroke-linecap='butt' title='&amp;lt;code&amp;gt;panel.grid.major.x&amp;lt;/code&amp;gt;' theme-id='panel.grid.major.x'/>\n   <polyline id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e158' points='417.65,266.35 417.65,55.77' fill='none' stroke='#FFFFFF' stroke-opacity='1' stroke-width='1.07' stroke-linejoin='round' stroke-linecap='butt' title='&amp;lt;code&amp;gt;panel.grid.major.x&amp;lt;/code&amp;gt;' theme-id='panel.grid.major.x'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e159' points='254.42,140.07 257.05,144.63 251.78,144.63' fill='#2E608A' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e160' points='254.42,146.05 257.05,150.61 251.78,150.61' fill='#306591' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e161' points='290.33,164.00 292.96,168.56 287.70,168.56' fill='#29567D' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <circle id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e162' cx='254.42' cy='161.06' r='1.47pt' fill='#2E608A' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <circle id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e163' cx='254.42' cy='167.04' r='1.47pt' fill='#2B5B83' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <circle id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e164' cx='290.33' cy='179' r='1.47pt' fill='#265176' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <circle id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e165' cx='290.33' cy='179' r='1.47pt' fill='#214769' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <circle id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e166' cx='290.33' cy='179' r='1.47pt' fill='#265176' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <circle id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e167' cx='326.24' cy='190.97' r='1.47pt' fill='#244C6F' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e168' points='360.20,210.87 364.11,210.87 364.11,206.96 360.20,206.96' fill='#1F4262' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e169' points='360.20,240.78 364.11,240.78 364.11,236.87 360.20,236.87' fill='#18344F' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e170' points='360.20,210.87 364.11,210.87 364.11,206.96 360.20,206.96' fill='#1F4262' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e171' points='383.05,228.82 386.96,228.82 386.96,224.91 383.05,224.91' fill='#1A3955' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e172' points='389.58,174.98 393.49,174.98 393.49,171.07 389.58,171.07' fill='#244C6F' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e173' points='389.58,180.96 393.49,180.96 393.49,177.05 389.58,177.05' fill='#214769' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e174' points='415.70,186.94 419.61,186.94 419.61,183.03 415.70,183.03' fill='#214769' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <circle id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e175' cx='362.15' cy='214.9' r='1.47pt' fill='#1F4262' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <circle id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e176' cx='362.15' cy='244.81' r='1.47pt' fill='#18344F' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e177' points='267.48,146.05 270.11,150.61 264.84,150.61' fill='#336A98' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e178' points='303.39,152.04 306.02,156.60 300.76,156.60' fill='#29567D' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e179' points='306.65,169.98 309.29,174.54 304.02,174.54' fill='#265176' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e180' points='296.86,181.95 299.49,186.51 294.23,186.51' fill='#265176' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e181' points='296.86,181.95 299.49,186.51 294.23,186.51' fill='#265176' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e182' points='296.86,223.82 299.49,228.38 294.23,228.38' fill='#18344F' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e183' points='313.18,187.93 315.82,192.49 310.55,192.49' fill='#244C6F' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e184' points='319.71,187.93 322.34,192.49 317.08,192.49' fill='#244C6F' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <circle id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e185' cx='309.92' cy='214.9' r='1.47pt' fill='#214769' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <circle id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e186' cx='309.92' cy='220.88' r='1.47pt' fill='#1F4262' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <circle id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e187' cx='342.57' cy='214.9' r='1.47pt' fill='#1F4262' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <circle id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e188' cx='342.57' cy='214.9' r='1.47pt' fill='#1F4262' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <circle id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e189' cx='342.57' cy='256.77' r='1.47pt' fill='#132B43' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <circle id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e190' cx='342.57' cy='226.86' r='1.47pt' fill='#1C3D5C' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <circle id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e191' cx='342.57' cy='256.77' r='1.47pt' fill='#132B43' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <circle id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e192' cx='342.57' cy='226.86' r='1.47pt' fill='#1C3D5C' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <circle id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e193' cx='375.21' cy='220.88' r='1.47pt' fill='#1C3D5C' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <circle id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e194' cx='342.57' cy='232.85' r='1.47pt' fill='#1A3955' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <circle id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e195' cx='342.57' cy='256.77' r='1.47pt' fill='#132B43' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <circle id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e196' cx='342.57' cy='226.86' r='1.47pt' fill='#1C3D5C' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <circle id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e197' cx='342.57' cy='226.86' r='1.47pt' fill='#1C3D5C' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <circle id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e198' cx='342.57' cy='232.85' r='1.47pt' fill='#1A3955' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <circle id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e199' cx='342.57' cy='256.77' r='1.47pt' fill='#132B43' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <circle id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e200' cx='375.21' cy='226.86' r='1.47pt' fill='#1C3D5C' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e201' points='363.46,222.84 367.37,222.84 367.37,218.93 363.46,218.93' fill='#1A3955' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <circle id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e202' cx='319.71' cy='214.9' r='1.47pt' fill='#1C3D5C' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <circle id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e203' cx='339.3' cy='214.9' r='1.47pt' fill='#1C3D5C' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <circle id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e204' cx='339.3' cy='226.86' r='1.47pt' fill='#1C3D5C' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <circle id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e205' cx='365.42' cy='226.86' r='1.47pt' fill='#1C3D5C' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e206' points='317.76,174.98 321.67,174.98 321.67,171.07 317.76,171.07' fill='#265176' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e207' points='317.76,186.94 321.67,186.94 321.67,183.03 317.76,183.03' fill='#244C6F' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e208' points='337.35,192.92 341.26,192.92 341.26,189.01 337.35,189.01' fill='#214769' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e209' points='337.35,198.91 341.26,198.91 341.26,195.00 337.35,195.00' fill='#214769' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e210' points='363.46,210.87 367.37,210.87 367.37,206.96 363.46,206.96' fill='#1F4262' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e211' points='247.89,122.12 250.52,126.68 245.25,126.68' fill='#3D7FB4' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e212' points='247.89,110.16 250.52,114.72 245.25,114.72' fill='#3B7AAD' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e213' points='247.89,110.16 250.52,114.72 245.25,114.72' fill='#3875A6' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e214' points='254.42,152.04 257.05,156.60 251.78,156.60' fill='#306591' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e215' points='267.48,146.05 270.11,150.61 264.84,150.61' fill='#306591' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e216' points='267.48,140.07 270.11,144.63 264.84,144.63' fill='#306591' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e217' points='296.86,158.02 299.49,162.58 294.23,162.58' fill='#2B5B83' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e218' points='254.42,158.02 257.05,162.58 251.78,162.58' fill='#2E608A' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e219' points='254.42,164.00 257.05,168.56 251.78,168.56' fill='#2E608A' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e220' points='277.27,181.95 279.90,186.51 274.64,186.51' fill='#265176' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e221' points='277.27,181.95 279.90,186.51 274.64,186.51' fill='#244C6F' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e222' points='277.27,181.95 279.90,186.51 274.64,186.51' fill='#265176' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <circle id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e223' cx='287.06' cy='196.95' r='1.47pt' fill='#265176' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <circle id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e224' cx='309.92' cy='214.9' r='1.47pt' fill='#214769' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <circle id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e225' cx='342.57' cy='256.77' r='1.47pt' fill='#132B43' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <circle id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e226' cx='342.57' cy='214.9' r='1.47pt' fill='#1F4262' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <circle id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e227' cx='375.21' cy='220.88' r='1.47pt' fill='#1C3D5C' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <circle id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e228' cx='388.27' cy='244.81' r='1.47pt' fill='#18344F' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <circle id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e229' cx='326.24' cy='220.88' r='1.47pt' fill='#1A3955' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <circle id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e230' cx='332.77' cy='220.88' r='1.47pt' fill='#1A3955' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e231' points='363.46,222.84 367.37,222.84 367.37,218.93 363.46,218.93' fill='#1A3955' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <circle id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e232' cx='319.71' cy='214.9' r='1.47pt' fill='#1C3D5C' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <circle id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e233' cx='339.3' cy='214.9' r='1.47pt' fill='#1C3D5C' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e234' points='270.74,140.07 273.37,144.63 268.11,144.63' fill='#356F9F' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e235' points='270.74,134.09 273.37,138.65 268.11,138.65' fill='#356F9F' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e236' points='303.39,164.00 306.02,168.56 300.76,168.56' fill='#2B5B83' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e237' points='303.39,169.98 306.02,174.54 300.76,174.54' fill='#2B5B83' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e238' points='303.39,175.96 306.02,180.52 300.76,180.52' fill='#2B5B83' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <circle id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e239' cx='319.71' cy='208.92' r='1.47pt' fill='#1F4262' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <circle id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e240' cx='371.95' cy='220.88' r='1.47pt' fill='#1A3955' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e241' points='313.18,158.02 315.82,162.58 310.55,162.58' fill='#29567D' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e242' points='362.15,175.96 364.79,180.52 359.52,180.52' fill='#244C6F' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <circle id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e243' cx='270.74' cy='167.04' r='1.47pt' fill='#2E608A' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <circle id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e244' cx='270.74' cy='179' r='1.47pt' fill='#2B5B83' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <circle id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e245' cx='270.74' cy='173.02' r='1.47pt' fill='#2E608A' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <circle id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e246' cx='270.74' cy='190.97' r='1.47pt' fill='#29567D' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <circle id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e247' cx='270.74' cy='179' r='1.47pt' fill='#2E608A' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <circle id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e248' cx='270.74' cy='167.04' r='1.47pt' fill='#2E608A' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <circle id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e249' cx='270.74' cy='179' r='1.47pt' fill='#2B5B83' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <circle id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e250' cx='270.74' cy='167.04' r='1.47pt' fill='#2E608A' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <circle id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e251' cx='319.71' cy='208.92' r='1.47pt' fill='#244C6F' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <circle id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e252' cx='342.57' cy='226.86' r='1.47pt' fill='#1F4262' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e253' points='267.48,140.07 270.11,144.63 264.84,144.63' fill='#306591' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e254' points='267.48,140.07 270.11,144.63 264.84,144.63' fill='#306591' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e255' points='303.39,158.02 306.02,162.58 300.76,162.58' fill='#2B5B83' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e256' points='267.48,140.07 270.11,144.63 264.84,144.63' fill='#306591' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e257' points='267.48,140.07 270.11,144.63 264.84,144.63' fill='#336A98' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e258' points='296.86,164.00 299.49,168.56 294.23,168.56' fill='#29567D' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e259' points='247.89,104.18 250.52,108.74 245.25,108.74' fill='#438AC3' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e260' points='247.89,116.14 250.52,120.70 245.25,120.70' fill='#3D7FB4' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <circle id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e261' cx='375.21' cy='220.88' r='1.47pt' fill='#1C3D5C' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <circle id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e262' cx='277.27' cy='196.95' r='1.47pt' fill='#265176' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <circle id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e263' cx='319.71' cy='220.88' r='1.47pt' fill='#214769' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <circle id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e264' cx='319.71' cy='208.92' r='1.47pt' fill='#244C6F' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e265' points='254.42,152.04 257.05,156.60 251.78,156.60' fill='#306591' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e266' points='254.42,152.04 257.05,156.60 251.78,156.60' fill='#336A98' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e267' points='254.42,152.04 257.05,156.60 251.78,156.60' fill='#336A98' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e268' points='254.42,152.04 257.05,156.60 251.78,156.60' fill='#306591' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e269' points='270.74,152.04 273.37,156.60 268.11,156.60' fill='#306591' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e270' points='270.74,152.04 273.37,156.60 268.11,156.60' fill='#306591' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e271' points='270.74,158.02 273.37,162.58 268.11,162.58' fill='#2E608A' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e272' points='270.74,152.04 273.37,156.60 268.11,156.60' fill='#2E608A' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e273' points='254.42,158.02 257.05,162.58 251.78,162.58' fill='#2B5B83' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e274' points='254.42,152.04 257.05,156.60 251.78,156.60' fill='#306591' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e275' points='306.65,169.98 309.29,174.54 304.02,174.54' fill='#265176' fill-opacity='1' stroke='none' data-id='geom' title='&amp;lt;code&amp;gt;geom&amp;lt;/code&amp;gt;'/>\n  <\/g>\n  <g clip-path='url(#svg_55735f3a_43be_433d_b895_216b1a6034dd_c4)'>\n   <rect id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e276' x='33.14' y='38.85' width='193.93' height='16.92' fill='#D9D9D9' fill-opacity='1' stroke='none' title='&amp;lt;code&amp;gt;strip.background.x&amp;lt;/code&amp;gt;' theme-id='strip.background.x'/>\n   <text id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e277' x='120.31' y='50.46' font-size='6.6pt' font-family='Arial' fill='#1A1A1A' fill-opacity='1' title='&amp;lt;code&amp;gt;strip.text.x.top&amp;lt;/code&amp;gt;' theme-id='strip.text.x.top'>1999<\/text>\n  <\/g>\n  <g clip-path='url(#svg_55735f3a_43be_433d_b895_216b1a6034dd_c5)'>\n   <rect id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e278' x='232.54' y='38.85' width='193.93' height='16.92' fill='#D9D9D9' fill-opacity='1' stroke='none' title='&amp;lt;code&amp;gt;strip.background.x&amp;lt;/code&amp;gt;' theme-id='strip.background.x'/>\n   <text id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e279' x='319.71' y='50.46' font-size='6.6pt' font-family='Arial' fill='#1A1A1A' fill-opacity='1' title='&amp;lt;code&amp;gt;strip.text.x.top&amp;lt;/code&amp;gt;' theme-id='strip.text.x.top'>2008<\/text>\n  <\/g>\n  <g clip-path='url(#svg_55735f3a_43be_433d_b895_216b1a6034dd_c1)'>\n   <polyline id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e280' points='33.14,266.35 227.06,266.35' fill='none' stroke='none' title='&amp;lt;code&amp;gt;axis.line.x.bottom&amp;lt;/code&amp;gt;' theme-id='axis.line.x.bottom'/>\n   <polyline id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e281' points='55.01,269.09 55.01,266.35' fill='none' stroke='#333333' stroke-opacity='1' stroke-width='1.07' stroke-linejoin='round' stroke-linecap='butt' title='&amp;lt;code&amp;gt;axis.ticks.x.bottom&amp;lt;/code&amp;gt;' theme-id='axis.ticks.x.bottom'/>\n   <polyline id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e282' points='87.66,269.09 87.66,266.35' fill='none' stroke='#333333' stroke-opacity='1' stroke-width='1.07' stroke-linejoin='round' stroke-linecap='butt' title='&amp;lt;code&amp;gt;axis.ticks.x.bottom&amp;lt;/code&amp;gt;' theme-id='axis.ticks.x.bottom'/>\n   <polyline id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e283' points='120.31,269.09 120.31,266.35' fill='none' stroke='#333333' stroke-opacity='1' stroke-width='1.07' stroke-linejoin='round' stroke-linecap='butt' title='&amp;lt;code&amp;gt;axis.ticks.x.bottom&amp;lt;/code&amp;gt;' theme-id='axis.ticks.x.bottom'/>\n   <polyline id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e284' points='152.95,269.09 152.95,266.35' fill='none' stroke='#333333' stroke-opacity='1' stroke-width='1.07' stroke-linejoin='round' stroke-linecap='butt' title='&amp;lt;code&amp;gt;axis.ticks.x.bottom&amp;lt;/code&amp;gt;' theme-id='axis.ticks.x.bottom'/>\n   <polyline id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e285' points='185.60,269.09 185.60,266.35' fill='none' stroke='#333333' stroke-opacity='1' stroke-width='1.07' stroke-linejoin='round' stroke-linecap='butt' title='&amp;lt;code&amp;gt;axis.ticks.x.bottom&amp;lt;/code&amp;gt;' theme-id='axis.ticks.x.bottom'/>\n   <polyline id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e286' points='218.25,269.09 218.25,266.35' fill='none' stroke='#333333' stroke-opacity='1' stroke-width='1.07' stroke-linejoin='round' stroke-linecap='butt' title='&amp;lt;code&amp;gt;axis.ticks.x.bottom&amp;lt;/code&amp;gt;' theme-id='axis.ticks.x.bottom'/>\n   <text id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e287' x='52.56' y='277.58' font-size='6.6pt' font-family='Arial' fill='#4D4D4D' fill-opacity='1' title='&amp;lt;code&amp;gt;axis.text.x.bottom&amp;lt;/code&amp;gt;' theme-id='axis.text.x.bottom'>2<\/text>\n   <text id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e288' x='85.21' y='277.58' font-size='6.6pt' font-family='Arial' fill='#4D4D4D' fill-opacity='1' title='&amp;lt;code&amp;gt;axis.text.x.bottom&amp;lt;/code&amp;gt;' theme-id='axis.text.x.bottom'>3<\/text>\n   <text id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e289' x='117.86' y='277.58' font-size='6.6pt' font-family='Arial' fill='#4D4D4D' fill-opacity='1' title='&amp;lt;code&amp;gt;axis.text.x.bottom&amp;lt;/code&amp;gt;' theme-id='axis.text.x.bottom'>4<\/text>\n   <text id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e290' x='150.51' y='277.58' font-size='6.6pt' font-family='Arial' fill='#4D4D4D' fill-opacity='1' title='&amp;lt;code&amp;gt;axis.text.x.bottom&amp;lt;/code&amp;gt;' theme-id='axis.text.x.bottom'>5<\/text>\n   <text id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e291' x='183.15' y='277.58' font-size='6.6pt' font-family='Arial' fill='#4D4D4D' fill-opacity='1' title='&amp;lt;code&amp;gt;axis.text.x.bottom&amp;lt;/code&amp;gt;' theme-id='axis.text.x.bottom'>6<\/text>\n   <text id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e292' x='215.8' y='277.58' font-size='6.6pt' font-family='Arial' fill='#4D4D4D' fill-opacity='1' title='&amp;lt;code&amp;gt;axis.text.x.bottom&amp;lt;/code&amp;gt;' theme-id='axis.text.x.bottom'>7<\/text>\n   <polyline id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e293' points='232.54,266.35 426.47,266.35' fill='none' stroke='none' title='&amp;lt;code&amp;gt;axis.line.x.bottom&amp;lt;/code&amp;gt;' theme-id='axis.line.x.bottom'/>\n   <polyline id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e294' points='254.42,269.09 254.42,266.35' fill='none' stroke='#333333' stroke-opacity='1' stroke-width='1.07' stroke-linejoin='round' stroke-linecap='butt' title='&amp;lt;code&amp;gt;axis.ticks.x.bottom&amp;lt;/code&amp;gt;' theme-id='axis.ticks.x.bottom'/>\n   <polyline id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e295' points='287.06,269.09 287.06,266.35' fill='none' stroke='#333333' stroke-opacity='1' stroke-width='1.07' stroke-linejoin='round' stroke-linecap='butt' title='&amp;lt;code&amp;gt;axis.ticks.x.bottom&amp;lt;/code&amp;gt;' theme-id='axis.ticks.x.bottom'/>\n   <polyline id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e296' points='319.71,269.09 319.71,266.35' fill='none' stroke='#333333' stroke-opacity='1' stroke-width='1.07' stroke-linejoin='round' stroke-linecap='butt' title='&amp;lt;code&amp;gt;axis.ticks.x.bottom&amp;lt;/code&amp;gt;' theme-id='axis.ticks.x.bottom'/>\n   <polyline id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e297' points='352.36,269.09 352.36,266.35' fill='none' stroke='#333333' stroke-opacity='1' stroke-width='1.07' stroke-linejoin='round' stroke-linecap='butt' title='&amp;lt;code&amp;gt;axis.ticks.x.bottom&amp;lt;/code&amp;gt;' theme-id='axis.ticks.x.bottom'/>\n   <polyline id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e298' points='385.01,269.09 385.01,266.35' fill='none' stroke='#333333' stroke-opacity='1' stroke-width='1.07' stroke-linejoin='round' stroke-linecap='butt' title='&amp;lt;code&amp;gt;axis.ticks.x.bottom&amp;lt;/code&amp;gt;' theme-id='axis.ticks.x.bottom'/>\n   <polyline id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e299' points='417.65,269.09 417.65,266.35' fill='none' stroke='#333333' stroke-opacity='1' stroke-width='1.07' stroke-linejoin='round' stroke-linecap='butt' title='&amp;lt;code&amp;gt;axis.ticks.x.bottom&amp;lt;/code&amp;gt;' theme-id='axis.ticks.x.bottom'/>\n   <text id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e300' x='251.97' y='277.58' font-size='6.6pt' font-family='Arial' fill='#4D4D4D' fill-opacity='1' title='&amp;lt;code&amp;gt;axis.text.x.bottom&amp;lt;/code&amp;gt;' theme-id='axis.text.x.bottom'>2<\/text>\n   <text id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e301' x='284.62' y='277.58' font-size='6.6pt' font-family='Arial' fill='#4D4D4D' fill-opacity='1' title='&amp;lt;code&amp;gt;axis.text.x.bottom&amp;lt;/code&amp;gt;' theme-id='axis.text.x.bottom'>3<\/text>\n   <text id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e302' x='317.26' y='277.58' font-size='6.6pt' font-family='Arial' fill='#4D4D4D' fill-opacity='1' title='&amp;lt;code&amp;gt;axis.text.x.bottom&amp;lt;/code&amp;gt;' theme-id='axis.text.x.bottom'>4<\/text>\n   <text id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e303' x='349.91' y='277.58' font-size='6.6pt' font-family='Arial' fill='#4D4D4D' fill-opacity='1' title='&amp;lt;code&amp;gt;axis.text.x.bottom&amp;lt;/code&amp;gt;' theme-id='axis.text.x.bottom'>5<\/text>\n   <text id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e304' x='382.56' y='277.58' font-size='6.6pt' font-family='Arial' fill='#4D4D4D' fill-opacity='1' title='&amp;lt;code&amp;gt;axis.text.x.bottom&amp;lt;/code&amp;gt;' theme-id='axis.text.x.bottom'>6<\/text>\n   <text id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e305' x='415.21' y='277.58' font-size='6.6pt' font-family='Arial' fill='#4D4D4D' fill-opacity='1' title='&amp;lt;code&amp;gt;axis.text.x.bottom&amp;lt;/code&amp;gt;' theme-id='axis.text.x.bottom'>7<\/text>\n   <polyline id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e306' points='33.14,266.35 33.14,55.77' fill='none' stroke='none' title='&amp;lt;code&amp;gt;axis.line.y.left&amp;lt;/code&amp;gt;' theme-id='axis.line.y.left'/>\n   <text id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e307' x='18.41' y='212.07' font-size='6.6pt' font-family='Arial' fill='#4D4D4D' fill-opacity='1' title='&amp;lt;code&amp;gt;axis.text.y.left&amp;lt;/code&amp;gt;' theme-id='axis.text.y.left'>20<\/text>\n   <text id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e308' x='18.41' y='152.24' font-size='6.6pt' font-family='Arial' fill='#4D4D4D' fill-opacity='1' title='&amp;lt;code&amp;gt;axis.text.y.left&amp;lt;/code&amp;gt;' theme-id='axis.text.y.left'>30<\/text>\n   <text id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e309' x='18.41' y='92.42' font-size='6.6pt' font-family='Arial' fill='#4D4D4D' fill-opacity='1' title='&amp;lt;code&amp;gt;axis.text.y.left&amp;lt;/code&amp;gt;' theme-id='axis.text.y.left'>40<\/text>\n   <polyline id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e310' points='30.40,208.92 33.14,208.92' fill='none' stroke='#333333' stroke-opacity='1' stroke-width='1.07' stroke-linejoin='round' stroke-linecap='butt' title='&amp;lt;code&amp;gt;axis.ticks.y.left&amp;lt;/code&amp;gt;' theme-id='axis.ticks.y.left'/>\n   <polyline id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e311' points='30.40,149.09 33.14,149.09' fill='none' stroke='#333333' stroke-opacity='1' stroke-width='1.07' stroke-linejoin='round' stroke-linecap='butt' title='&amp;lt;code&amp;gt;axis.ticks.y.left&amp;lt;/code&amp;gt;' theme-id='axis.ticks.y.left'/>\n   <polyline id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e312' points='30.40,89.27 33.14,89.27' fill='none' stroke='#333333' stroke-opacity='1' stroke-width='1.07' stroke-linejoin='round' stroke-linecap='butt' title='&amp;lt;code&amp;gt;axis.ticks.y.left&amp;lt;/code&amp;gt;' theme-id='axis.ticks.y.left'/>\n   <text id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e313' x='177.82' y='290.04' font-size='8.25pt' font-family='Arial' title='&amp;lt;code&amp;gt;axis.title.x.bottom&amp;lt;/code&amp;gt;' theme-id='axis.title.x.bottom'>Engine Displacement<\/text>\n   <text id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e314' transform='translate(13.36,222.21) rotate(-90.00)' font-size='8.25pt' font-family='Arial' title='&amp;lt;code&amp;gt;axis.title.y.left&amp;lt;/code&amp;gt;' theme-id='axis.title.y.left'>Highway miles per gallon<\/text>\n   <rect id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e315' x='437.43' y='53.88' width='61.09' height='214.35' fill='#FFFFFF' fill-opacity='1' stroke='none' title='&amp;lt;code&amp;gt;legend.box.background&amp;lt;/code&amp;gt;' theme-id='legend.box.background'/>\n   <rect id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e316' x='437.43' y='53.88' width='59.29' height='124.91' fill='#FFFFFF' fill-opacity='1' stroke='none' title='&amp;lt;code&amp;gt;legend.background&amp;lt;/code&amp;gt;' theme-id='legend.background'/>\n   <text id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e317' x='442.91' y='68.4' font-size='8.25pt' font-family='Arial' title='&amp;lt;code&amp;gt;legend.title&amp;lt;/code&amp;gt;' theme-id='legend.title'>City miles<\/text>\n   <text id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e318' x='442.91' y='80.28' font-size='8.25pt' font-family='Arial' title='&amp;lt;code&amp;gt;legend.title&amp;lt;/code&amp;gt;' theme-id='legend.title'>per gallon<\/text>\n   <image x='442.91' y='86.92' width='17.28' height='86.4' preserveAspectRatio='none' xlink:href='data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAEsCAYAAAACUNnVAAAAmElEQVQ4ja2UQRLDMAgDd3hk/tnX5agcknFaCoa0vnkMCEnGsL12GQhDYDpPwoDrpBFlRDWi/9Wu6AHC9FkLYLrzlhD3oJ3mDvRHRYy7IC8A7bCK8gpWKYDzeQVArDcDyD2YAnSofZvzaOA6Q7Oahp/dmRuVTQ0xU5TGP2o8Waool1obVuv1q8qP9xPvg633XlGLDtfIhNUBcBeA5ss0BXMAAAAASUVORK5CYII=' xmlns:xlink='http://www.w3.org/1999/xlink'/>\n   <rect id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e319' x='442.91' y='86.92' width='17.28' height='86.4' fill='none' stroke='none' title='&amp;lt;code&amp;gt;legend.frame&amp;lt;br&amp;gt;palette.colour.continuous&amp;lt;/code&amp;gt;' theme-id='legend.frame&lt;br&gt;palette.colour.continuous'/>\n   <polyline id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e320' points='456.73,169.86 460.19,169.86' fill='none' stroke='#FFFFFF' stroke-opacity='1' stroke-width='0.37' stroke-linejoin='round' stroke-linecap='butt' title='&amp;lt;code&amp;gt;legend.ticks&amp;lt;/code&amp;gt;' theme-id='legend.ticks'/>\n   <polyline id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e321' points='456.73,153.30 460.19,153.30' fill='none' stroke='#FFFFFF' stroke-opacity='1' stroke-width='0.37' stroke-linejoin='round' stroke-linecap='butt' title='&amp;lt;code&amp;gt;legend.ticks&amp;lt;/code&amp;gt;' theme-id='legend.ticks'/>\n   <polyline id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e322' points='456.73,136.74 460.19,136.74' fill='none' stroke='#FFFFFF' stroke-opacity='1' stroke-width='0.37' stroke-linejoin='round' stroke-linecap='butt' title='&amp;lt;code&amp;gt;legend.ticks&amp;lt;/code&amp;gt;' theme-id='legend.ticks'/>\n   <polyline id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e323' points='456.73,120.18 460.19,120.18' fill='none' stroke='#FFFFFF' stroke-opacity='1' stroke-width='0.37' stroke-linejoin='round' stroke-linecap='butt' title='&amp;lt;code&amp;gt;legend.ticks&amp;lt;/code&amp;gt;' theme-id='legend.ticks'/>\n   <polyline id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e324' points='456.73,103.62 460.19,103.62' fill='none' stroke='#FFFFFF' stroke-opacity='1' stroke-width='0.37' stroke-linejoin='round' stroke-linecap='butt' title='&amp;lt;code&amp;gt;legend.ticks&amp;lt;/code&amp;gt;' theme-id='legend.ticks'/>\n   <polyline id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e325' points='456.73,87.06 460.19,87.06' fill='none' stroke='#FFFFFF' stroke-opacity='1' stroke-width='0.37' stroke-linejoin='round' stroke-linecap='butt' title='&amp;lt;code&amp;gt;legend.ticks&amp;lt;/code&amp;gt;' theme-id='legend.ticks'/>\n   <polyline id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e326' points='446.36,169.86 442.91,169.86' fill='none' stroke='#FFFFFF' stroke-opacity='1' stroke-width='0.37' stroke-linejoin='round' stroke-linecap='butt' title='&amp;lt;code&amp;gt;legend.ticks&amp;lt;/code&amp;gt;' theme-id='legend.ticks'/>\n   <polyline id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e327' points='446.36,153.30 442.91,153.30' fill='none' stroke='#FFFFFF' stroke-opacity='1' stroke-width='0.37' stroke-linejoin='round' stroke-linecap='butt' title='&amp;lt;code&amp;gt;legend.ticks&amp;lt;/code&amp;gt;' theme-id='legend.ticks'/>\n   <polyline id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e328' points='446.36,136.74 442.91,136.74' fill='none' stroke='#FFFFFF' stroke-opacity='1' stroke-width='0.37' stroke-linejoin='round' stroke-linecap='butt' title='&amp;lt;code&amp;gt;legend.ticks&amp;lt;/code&amp;gt;' theme-id='legend.ticks'/>\n   <polyline id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e329' points='446.36,120.18 442.91,120.18' fill='none' stroke='#FFFFFF' stroke-opacity='1' stroke-width='0.37' stroke-linejoin='round' stroke-linecap='butt' title='&amp;lt;code&amp;gt;legend.ticks&amp;lt;/code&amp;gt;' theme-id='legend.ticks'/>\n   <polyline id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e330' points='446.36,103.62 442.91,103.62' fill='none' stroke='#FFFFFF' stroke-opacity='1' stroke-width='0.37' stroke-linejoin='round' stroke-linecap='butt' title='&amp;lt;code&amp;gt;legend.ticks&amp;lt;/code&amp;gt;' theme-id='legend.ticks'/>\n   <polyline id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e331' points='446.36,87.06 442.91,87.06' fill='none' stroke='#FFFFFF' stroke-opacity='1' stroke-width='0.37' stroke-linejoin='round' stroke-linecap='butt' title='&amp;lt;code&amp;gt;legend.ticks&amp;lt;/code&amp;gt;' theme-id='legend.ticks'/>\n   <text id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e332' x='465.67' y='173.01' font-size='6.6pt' font-family='Arial' title='&amp;lt;code&amp;gt;legend.text&amp;lt;/code&amp;gt;' theme-id='legend.text'>10<\/text>\n   <text id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e333' x='465.67' y='156.45' font-size='6.6pt' font-family='Arial' title='&amp;lt;code&amp;gt;legend.text&amp;lt;/code&amp;gt;' theme-id='legend.text'>15<\/text>\n   <text id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e334' x='465.67' y='139.89' font-size='6.6pt' font-family='Arial' title='&amp;lt;code&amp;gt;legend.text&amp;lt;/code&amp;gt;' theme-id='legend.text'>20<\/text>\n   <text id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e335' x='465.67' y='123.33' font-size='6.6pt' font-family='Arial' title='&amp;lt;code&amp;gt;legend.text&amp;lt;/code&amp;gt;' theme-id='legend.text'>25<\/text>\n   <text id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e336' x='465.67' y='106.77' font-size='6.6pt' font-family='Arial' title='&amp;lt;code&amp;gt;legend.text&amp;lt;/code&amp;gt;' theme-id='legend.text'>30<\/text>\n   <text id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e337' x='465.67' y='90.21' font-size='6.6pt' font-family='Arial' title='&amp;lt;code&amp;gt;legend.text&amp;lt;/code&amp;gt;' theme-id='legend.text'>35<\/text>\n   <rect id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e338' x='437.43' y='189.76' width='61.09' height='78.47' fill='#FFFFFF' fill-opacity='1' stroke='none' title='&amp;lt;code&amp;gt;legend.background&amp;lt;/code&amp;gt;' theme-id='legend.background'/>\n   <text id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e339' x='442.91' y='204.27' font-size='8.25pt' font-family='Arial' title='&amp;lt;code&amp;gt;legend.title&amp;lt;/code&amp;gt;' theme-id='legend.title'>Drive train<\/text>\n   <rect id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e340' x='442.91' y='210.91' width='17.28' height='17.28' fill='#EBEBEB' fill-opacity='1' stroke='none' title='&amp;lt;code&amp;gt;legend.key&amp;lt;/code&amp;gt;' theme-id='legend.key'/>\n   <circle id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e341' cx='451.55' cy='219.55' r='1.47pt' fill='#000000' fill-opacity='1' stroke='none' key-id='shape' title='&amp;lt;code&amp;gt;geom&amp;lt;br&amp;gt;palette.shape.discrete&amp;lt;/code&amp;gt;'/>\n   <rect id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e342' x='442.91' y='228.19' width='17.28' height='17.28' fill='#EBEBEB' fill-opacity='1' stroke='none' title='&amp;lt;code&amp;gt;legend.key&amp;lt;/code&amp;gt;' theme-id='legend.key'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e343' points='451.55,233.79 454.18,238.35 448.91,238.35' fill='#000000' fill-opacity='1' stroke='none' key-id='shape' title='&amp;lt;code&amp;gt;geom&amp;lt;br&amp;gt;palette.shape.discrete&amp;lt;/code&amp;gt;'/>\n   <rect id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e344' x='442.91' y='245.47' width='17.28' height='17.28' fill='#EBEBEB' fill-opacity='1' stroke='none' title='&amp;lt;code&amp;gt;legend.key&amp;lt;/code&amp;gt;' theme-id='legend.key'/>\n   <polygon id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e345' points='449.59,256.07 453.50,256.07 453.50,252.16 449.59,252.16' fill='#000000' fill-opacity='1' stroke='none' key-id='shape' title='&amp;lt;code&amp;gt;geom&amp;lt;br&amp;gt;palette.shape.discrete&amp;lt;/code&amp;gt;'/>\n   <text id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e346' x='465.67' y='222.7' font-size='6.6pt' font-family='Arial' title='&amp;lt;code&amp;gt;legend.text&amp;lt;/code&amp;gt;' theme-id='legend.text'>4<\/text>\n   <text id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e347' x='465.67' y='239.98' font-size='6.6pt' font-family='Arial' title='&amp;lt;code&amp;gt;legend.text&amp;lt;/code&amp;gt;' theme-id='legend.text'>f<\/text>\n   <text id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e348' x='465.67' y='257.26' font-size='6.6pt' font-family='Arial' title='&amp;lt;code&amp;gt;legend.text&amp;lt;/code&amp;gt;' theme-id='legend.text'>r<\/text>\n   <text id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e349' x='33.14' y='31.05' font-size='8.25pt' font-family='Arial' title='&amp;lt;code&amp;gt;plot.subtitle&amp;lt;/code&amp;gt;' theme-id='plot.subtitle'>Described for 234 cars from 1999 and 2008<\/text>\n   <text id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e350' x='33.14' y='14.93' font-size='9.9pt' font-family='Arial' title='&amp;lt;code&amp;gt;plot.title&amp;lt;/code&amp;gt;' theme-id='plot.title'>Fuel efficiency<\/text>\n   <text id='svg_55735f3a_43be_433d_b895_216b1a6034dd_e351' x='244.47' y='304.14' font-size='6.6pt' font-family='Arial' title='&amp;lt;code&amp;gt;plot.caption&amp;lt;/code&amp;gt;' theme-id='plot.caption'>Source: U.S. Environmental Protection Agency<\/text>\n  <\/g>\n <\/g>\n<\/svg>","js":null,"uid":"svg_55735f3a_43be_433d_b895_216b1a6034dd","ratio":1.618122977346278,"settings":{"tooltip":{"css":".tooltip_SVGID_ { color:black;background-color:#F9F9F9;padding:0.3em;border-radius:0.3em;border:solid grey;border-width:1px; ; position:absolute;pointer-events:none;z-index:999;}","placement":"doc","opacity":0.9,"offx":10,"offy":0,"use_cursor_pos":true,"use_fill":false,"use_stroke":false,"delay_over":200,"delay_out":500},"hover":{"css":".hover_data_SVGID_ { fill:orange;stroke:black;cursor:pointer; }\ntext.hover_data_SVGID_ { stroke:none;fill:orange; }\ncircle.hover_data_SVGID_ { fill:orange;stroke:black; }\nline.hover_data_SVGID_, polyline.hover_data_SVGID_ { fill:none;stroke:orange; }\nrect.hover_data_SVGID_, polygon.hover_data_SVGID_, path.hover_data_SVGID_ { fill:orange;stroke:none; }\nimage.hover_data_SVGID_ { stroke:orange; }","reactive":true,"nearest_distance":null},"hover_inv":{"css":""},"hover_key":{"css":".hover_key_SVGID_ { fill:orange;stroke:black;cursor:pointer; }\ntext.hover_key_SVGID_ { stroke:none;fill:orange; }\ncircle.hover_key_SVGID_ { fill:orange;stroke:black; }\nline.hover_key_SVGID_, polyline.hover_key_SVGID_ { fill:none;stroke:orange; }\nrect.hover_key_SVGID_, polygon.hover_key_SVGID_, path.hover_key_SVGID_ { fill:orange;stroke:none; }\nimage.hover_key_SVGID_ { stroke:orange; }","reactive":true},"hover_theme":{"css":".hover_theme_SVGID_ { fill:orange;stroke:black;cursor:pointer; }\ntext.hover_theme_SVGID_ { stroke:none;fill:orange; }\ncircle.hover_theme_SVGID_ { fill:orange;stroke:black; }\nline.hover_theme_SVGID_, polyline.hover_theme_SVGID_ { fill:none;stroke:orange; }\nrect.hover_theme_SVGID_, polygon.hover_theme_SVGID_, path.hover_theme_SVGID_ { fill:orange;stroke:none; }\nimage.hover_theme_SVGID_ { stroke:orange; }","reactive":true},"select":{"css":".select_data_SVGID_ { fill:red;stroke:black;cursor:pointer; }\ntext.select_data_SVGID_ { stroke:none;fill:red; }\ncircle.select_data_SVGID_ { fill:red;stroke:black; }\nline.select_data_SVGID_, polyline.select_data_SVGID_ { fill:none;stroke:red; }\nrect.select_data_SVGID_, polygon.select_data_SVGID_, path.select_data_SVGID_ { fill:red;stroke:none; }\nimage.select_data_SVGID_ { stroke:red; }","type":"multiple","only_shiny":true,"selected":[]},"select_inv":{"css":""},"select_key":{"css":".select_key_SVGID_ { fill:red;stroke:black;cursor:pointer; }\ntext.select_key_SVGID_ { stroke:none;fill:red; }\ncircle.select_key_SVGID_ { fill:red;stroke:black; }\nline.select_key_SVGID_, polyline.select_key_SVGID_ { fill:none;stroke:red; }\nrect.select_key_SVGID_, polygon.select_key_SVGID_, path.select_key_SVGID_ { fill:red;stroke:none; }\nimage.select_key_SVGID_ { stroke:red; }","type":"single","only_shiny":true,"selected":[]},"select_theme":{"css":".select_theme_SVGID_ { fill:red;stroke:black;cursor:pointer; }\ntext.select_theme_SVGID_ { stroke:none;fill:red; }\ncircle.select_theme_SVGID_ { fill:red;stroke:black; }\nline.select_theme_SVGID_, polyline.select_theme_SVGID_ { fill:none;stroke:red; }\nrect.select_theme_SVGID_, polygon.select_theme_SVGID_, path.select_theme_SVGID_ { fill:red;stroke:none; }\nimage.select_theme_SVGID_ { stroke:red; }","type":"single","only_shiny":true,"selected":[]},"zoom":{"min":1,"max":1,"duration":300},"toolbar":{"position":"topright","pngname":"diagram","tooltips":null,"fixed":false,"hidden":"saveaspng","delay_over":200,"delay_out":500},"sizing":{"rescale":true,"width":1}}},"evals":[],"jsHooks":[]}</script>

</div>

If you haven't already accidentally triggered it, feel free to hover your mouse over the plot above. Hovering will tell you what theme element you are pointing at.

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

In addition to these elements in ggplot2, extension packages can also define custom elements. Generally speaking, these elements are variants of the elements listed above and often have slightly different properties and are rendered differently. For example [`marquee::element_marquee()`](https://marquee.r-lib.org/reference/element_marquee.html) is a subclass of [`element_text()`](https://ggplot2.tidyverse.org/reference/element.html), but interprets the provided text as markdown. It applies some formatting like `**` for bold, or allows for custom spans like `{.red ...}`. Another example is [`ggh4x::element_part_rect()`](https://teunbrand.github.io/ggh4x/reference/element_part_rect.html) that can draw a subset of rectangle borders.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>p</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/labs.html'>labs</a></span><span class='o'>(</span>title <span class='o'>=</span> <span class='s'>"**Fuel** &#123;.red efficiency&#125;"</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/theme.html'>theme</a></span><span class='o'>(</span></span>
<span>    plot.title <span class='o'>=</span> <span class='nf'>marquee</span><span class='nf'>::</span><span class='nf'><a href='https://marquee.r-lib.org/reference/element_marquee.html'>element_marquee</a></span><span class='o'>(</span><span class='o'>)</span>,</span>
<span>    strip.background <span class='o'>=</span> <span class='nf'>ggh4x</span><span class='nf'>::</span><span class='nf'><a href='https://teunbrand.github.io/ggh4x/reference/element_part_rect.html'>element_part_rect</a></span><span class='o'>(</span>colour <span class='o'>=</span> <span class='s'>"black"</span>, side <span class='o'>=</span> <span class='s'>"b"</span><span class='o'>)</span></span>
<span>  <span class='o'>)</span></span>
</code></pre>
<img src="figs/element_marquee-1.png" width="700px" style="display: block; margin: auto;" />

</div>

### Hierarchy and inheritance

Most theme elements are hierarchical. At the root, they are broadly applicable and change large parts of the plot. At leaves, they are very specific and allow fine grained control. Travelling from roots to leaves, properties of theme elements are inherited from parent to child. Some inheritance is very direct, where leaves directly inherit from roots (for example `legend.text`). Other times, inheritance is more arduous, like for `axis.minor.ticks.y.left`: it inherits from `axis.ticks.y.left`, which inherits from `axis.ticks.y`, which inherits from `axis.ticks`, which finally inherits from `line`. Most often, elements only have a single parent, but there are subtle exceptions.

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

The [`?theme`](https://ggplot2.tidyverse.org/reference/theme.html) documentation often tells you how the elements inherit and [`calc_element()`](https://ggplot2.tidyverse.org/reference/calc_element.html) will resolve it for you. If, for some reason, you need programmatic access to the inheritance tree, you can use [`get_element_tree()`](https://ggplot2.tidyverse.org/reference/register_theme_elements.html). Let's say you want to find out exactly which elements have multiple parents. The resulting object is the internal structure ggplot2 uses to resolve inheritance and has an `inherit` field for every element that discerns its direct parent.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>tree</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/register_theme_elements.html'>get_element_tree</a></span><span class='o'>(</span><span class='o'>)</span></span>
<span><span class='nv'>tree</span><span class='o'>$</span><span class='nv'>axis.line.x.bottom</span><span class='o'>$</span><span class='nv'>inherit</span></span>
<span><span class='c'>#&gt; [1] "axis.line.x"</span></span>
<span></span></code></pre>

</div>

## Anatomy of a theme

<div class="highlight">

</div>

The [`theme()`](https://ggplot2.tidyverse.org/reference/theme.html) function has a lot of arguments and can be a bit overwhelming to parse in one take. At the time of writing, it has 147 arguments and `...` is obfuscating additional options. Because we like structure rather than chaos, let us try to digest the [`theme()`](https://ggplot2.tidyverse.org/reference/theme.html) function one bite at a time. Much of the theme has been divided over parts in the `theme_sub_*()` family of functions. This family are just simple shortcuts. For example the `theme_sub_axis(title)` argument, populates the `axis.title` element.

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

The text even has specific `text.x.bottom`, `text.x.top`, `text.y.left` and `text.y.right` variants. This allows text on the left to be rotated 90°, while text on the right is rotated -90°, which gives the sense that the text faces the panels. Out of principle, you could force the `text.x.bottom` to be rotated 180° to achieve the same sense for horizontal text, but you may find out why readability trumps consistency.

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

A trick you can pull to have legends eat up all the available real estate, is to give them `"null"`-unit size. Below, that trick stretches the colourbar across the full width of the plot.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>p</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/guides.html'>guides</a></span><span class='o'>(</span>colour <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/guide_colourbar.html'>guide_colourbar</a></span><span class='o'>(</span></span>
<span>    theme <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/subtheme.html'>theme_sub_legend</a></span><span class='o'>(</span></span>
<span>      key.width <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/grid/unit.html'>unit</a></span><span class='o'>(</span><span class='m'>1</span>, <span class='s'>"null"</span><span class='o'>)</span>,</span>
<span>      title.position <span class='o'>=</span> <span class='s'>"top"</span>,</span>
<span>      margin <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>margin_auto</a></span><span class='o'>(</span><span class='kc'>NA</span>, <span class='m'>0</span><span class='o'>)</span> <span class='c'># remove left/right margins</span></span>
<span>    <span class='o'>)</span>,</span>
<span>    position <span class='o'>=</span> <span class='s'>"bottom"</span></span>
<span>  <span class='o'>)</span><span class='o'>)</span></span>
</code></pre>
<img src="figs/stretchy_colourbar-1.png" width="700px" style="display: block; margin: auto;" />

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

Setting the typography of your plots is important and discussed more thoroughly in [this blog post](https://www.tidyverse.org/blog/2025/05/fonts-in-r/). Here we're simply giving the suggestion to use the [`systemfonts::require_font()`](https://systemfonts.r-lib.org/reference/require_font.html) when you are writing theme functions that include special fonts. It will not cover font behaviour for every graphics device, but it will for devices that use [systemfonts](https://systemfonts.r-lib.org/) for finding fonts, like [ragg](https://ragg.r-lib.org/) and [svglite](https://svglite.r-lib.org/).

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

