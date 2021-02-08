---
output: hugodown::hugo_document

slug: svglite-2-0-0
title: svglite 2.0.0
date: 2021-02-08
author: Thomas Lin Pedersen
description: >
    A 2-3 sentence description of the post that appears on the articles page.
    This can be omitted if it would just recapitulate the title.

photo:
  url: https://unsplash.com/photos/pVoEPpLw818
  author: Rodion Kutsaev

# one of: "deep-dive", "learn", "package", "programming", or "other"
categories: [package] 
tags: [graphic-device, svglite]
rmd_hash: 399efc5720845193

---

<!--
TODO:
* [x] Pick category and tags (see existing with `post_tags()`)
* [x] Find photo & update yaml metadata
* [x] Create `thumbnail-sq.jpg`; height and width should be equal
* [x] Create `thumbnail-wd.jpg`; width should be >5x height
* [x] `hugodown::tidy_thumbnail()`
* [ ] Add intro sentence
* [ ] `use_tidy_thanks()`
-->

We're extremely happy to announce the release of [svglite](https://svglite.r-lib.org) 2.0.0. svglite is a graphic device that is capable of creating SVG files from R graphics. SVG is a vector graphic format which means that it encodes the instructions for recreating a graphic in a scale-independent way. This is in contrast with raster graphics such as PNG (as can be produced with the graphic devices in [ragg](https://ragg.r-lib.org)) which encodes actual pixel values and will get grainy as you zoom in.

You can install the latest release of svglite from CRAN with:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://rdrr.io/r/utils/install.packages.html'>install.packages</a></span><span class='o'>(</span><span class='s'>"svglite"</span><span class='o'>)</span></code></pre>

</div>

Much time has passed since svglite had a major release and this blog post will go into detail with all the major changes. You can see a full list of changes in the [release notes](%7B%20github_release%20%7D).

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://svglite.r-lib.org'>svglite</a></span><span class='o'>)</span></code></pre>

</div>

Motivation for svglite
----------------------

As part of this release we have sharpened our personal motivation for creating and maintaining svglite in the face of the already existing [`svg()`](https://rdrr.io/r/grDevices/cairo.html) device provided by R. All of the changes that are part of this release somehows plays into these motivations and are thus grouped by it below.

### Speed

The defining feature at the inception of svglite was speed (as compared to [`svg()`](https://rdrr.io/r/grDevices/cairo.html)). At some point in the past this regressed quite considerably and this release not only brings it back to past glory, but improves further upon it. The combined effect of this is that you'll experience a 13x speed improvement (based on the speed test in the [readme](https://svglite.r-lib.org/index.html#speed)) using the new version over v1.2.3. svglite is now \~3x faster than using [`svg()`](https://rdrr.io/r/grDevices/cairo.html) based on the same benchmark:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://svglite.r-lib.org'>svglite</a></span><span class='o'>)</span>

<span class='nv'>x</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/stats/Uniform.html'>runif</a></span><span class='o'>(</span><span class='m'>1e3</span><span class='o'>)</span>
<span class='nv'>y</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/stats/Uniform.html'>runif</a></span><span class='o'>(</span><span class='m'>1e3</span><span class='o'>)</span>
<span class='nv'>tmp1</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/tempfile.html'>tempfile</a></span><span class='o'>(</span><span class='o'>)</span>
<span class='nv'>tmp2</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/tempfile.html'>tempfile</a></span><span class='o'>(</span><span class='o'>)</span>

<span class='nv'>svglite_test</span> <span class='o'>&lt;-</span> <span class='kr'>function</span><span class='o'>(</span><span class='o'>)</span> <span class='o'>&#123;</span>
  <span class='nf'><a href='https://svglite.r-lib.org/reference/svglite.html'>svglite</a></span><span class='o'>(</span><span class='nv'>tmp1</span><span class='o'>)</span>
  <span class='nf'><a href='https://rdrr.io/r/graphics/plot.default.html'>plot</a></span><span class='o'>(</span><span class='nv'>x</span>, <span class='nv'>y</span><span class='o'>)</span>
  <span class='nf'><a href='https://rdrr.io/r/grDevices/dev.html'>dev.off</a></span><span class='o'>(</span><span class='o'>)</span>
<span class='o'>&#125;</span>
<span class='nv'>svg_test</span> <span class='o'>&lt;-</span> <span class='kr'>function</span><span class='o'>(</span><span class='o'>)</span> <span class='o'>&#123;</span>
  <span class='nf'><a href='https://rdrr.io/r/grDevices/cairo.html'>svg</a></span><span class='o'>(</span><span class='nv'>tmp2</span>, onefile <span class='o'>=</span> <span class='kc'>TRUE</span><span class='o'>)</span>
  <span class='nf'><a href='https://rdrr.io/r/graphics/plot.default.html'>plot</a></span><span class='o'>(</span><span class='nv'>x</span>, <span class='nv'>y</span><span class='o'>)</span>
  <span class='nf'><a href='https://rdrr.io/r/grDevices/dev.html'>dev.off</a></span><span class='o'>(</span><span class='o'>)</span>
<span class='o'>&#125;</span>

<span class='nf'>bench</span><span class='nf'>::</span><span class='nf'><a href='https://rdrr.io/pkg/bench/man/mark.html'>mark</a></span><span class='o'>(</span><span class='nf'>svglite_test</span><span class='o'>(</span><span class='o'>)</span>, <span class='nf'>svg_test</span><span class='o'>(</span><span class='o'>)</span>, min_iterations <span class='o'>=</span> <span class='m'>250</span><span class='o'>)</span>
<span class='c'>#&gt; <span style='color: #555555;'># A tibble: 2 x 6</span></span>
<span class='c'>#&gt;   expression          min   median `itr/sec` mem_alloc `gc/sec`</span>
<span class='c'>#&gt;   <span style='color: #555555;font-style: italic;'>&lt;bch:expr&gt;</span><span>     </span><span style='color: #555555;font-style: italic;'>&lt;bch:tm&gt;</span><span> </span><span style='color: #555555;font-style: italic;'>&lt;bch:tm&gt;</span><span>     </span><span style='color: #555555;font-style: italic;'>&lt;dbl&gt;</span><span> </span><span style='color: #555555;font-style: italic;'>&lt;bch:byt&gt;</span><span>    </span><span style='color: #555555;font-style: italic;'>&lt;dbl&gt;</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>1</span><span> svglite_test()   3.29ms   4.16ms     222.      676KB    3.61 </span></span>
<span class='c'>#&gt; <span style='color: #555555;'>2</span><span> svg_test()      11.46ms  12.49ms      77.0     177KB    0.309</span></span></code></pre>

</div>

Speed is not the be-all-end-all of graphic devices but for a device based on a web-native file format it is quite important as it allows web servers based on e.g. shiny to stream dynamically created plots with low latency.

### File size

### Editability

### Font support

### Consistency

Acknowledgements
----------------

