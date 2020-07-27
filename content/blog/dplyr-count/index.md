---
output: hugodown::hugo_document

slug: dplyr-count
title: dplyr 1.0.1 and the `count()` function
date: 2020-07-27
author: Hadley Wickham
description: >
    dplyr 1.0.1 is out now — the main change is that `dplyr::count()` now
    never automatically weights.
photo:
  url: https://unsplash.com/photos/xvkSnspiETA
  author: David Carboni

# one of: "deep-dive", "learn", "package", "programming", or "other"
categories: [package] 
tags: [dplyr]
rmd_hash: 5d3b9c03ed2408b0

---

We're chuffed to announce the release of [dplyr](http://dplyr.tidyverse.org/) 1.0.1. This is minor release with a [few small fixes](XXXXXXXXXXx) and one bigger change that I want to discuss here. You can install it from CRAN with:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://rdrr.io/r/utils/install.packages.html'>install.packages</a></span>(<span class='s'>"{package}"</span>)</code></pre>

</div>

The main change in this version of dplyr is that [`count()`](https://dplyr.tidyverse.org/reference/count.html) no longer automatically weights if there is a column called `n` in the input:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://rdrr.io/r/base/library.html'>library</a></span>(<span class='k'><a href='https://dplyr.tidyverse.org'>dplyr</a></span>, warn.conflicts = <span class='kc'>FALSE</span>)

<span class='k'>df</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://tibble.tidyverse.org/reference/tribble.html'>tribble</a></span>(
  <span class='o'>~</span><span class='k'>name</span>,    <span class='o'>~</span><span class='k'>flower</span>, <span class='o'>~</span><span class='k'>n</span>,
  <span class='s'>"Cory"</span>,   <span class='s'>"Daffodil"</span>, <span class='m'>5</span>,
  <span class='s'>"Cory"</span>,   <span class='s'>"Rose"</span>,     <span class='m'>3</span>,
  <span class='s'>"Enzo"</span>,   <span class='s'>"Rose"</span>,    <span class='m'>12</span>,
  <span class='s'>"Stella"</span>, <span class='s'>"Daffodil"</span>, <span class='m'>5</span>
)

<span class='k'>df</span> <span class='o'>%&gt;%</span> <span class='nf'><a href='https://dplyr.tidyverse.org/reference/count.html'>count</a></span>(<span class='k'>flower</span>)
<span class='c'>#&gt; <span style='color: #949494;'># A tibble: 2 x 2</span></span>
<span class='c'>#&gt;   <span style='font-weight: bold;'>flower</span><span>       </span><span style='font-weight: bold;'>n</span></span>
<span class='c'>#&gt;   <span style='color: #949494;font-style: italic;'>&lt;chr&gt;</span><span>    </span><span style='color: #949494;font-style: italic;'>&lt;int&gt;</span></span>
<span class='c'>#&gt; <span style='color: #BCBCBC;'>1</span><span> Daffodil     2</span></span>
<span class='c'>#&gt; <span style='color: #BCBCBC;'>2</span><span> Rose         2</span></span></code></pre>

</div>

If you want to weight by an existing variable, you must explicitly supply it:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='k'>df</span> <span class='o'>%&gt;%</span> <span class='nf'><a href='https://dplyr.tidyverse.org/reference/count.html'>count</a></span>(<span class='k'>flower</span>, wt = <span class='k'>n</span>)
<span class='c'>#&gt; <span style='color: #949494;'># A tibble: 2 x 2</span></span>
<span class='c'>#&gt;   <span style='font-weight: bold;'>flower</span><span>       </span><span style='font-weight: bold;'>n</span></span>
<span class='c'>#&gt;   <span style='color: #949494;font-style: italic;'>&lt;chr&gt;</span><span>    </span><span style='color: #949494;font-style: italic;'>&lt;dbl&gt;</span></span>
<span class='c'>#&gt; <span style='color: #BCBCBC;'>1</span><span> Daffodil    10</span></span>
<span class='c'>#&gt; <span style='color: #BCBCBC;'>2</span><span> Rose        15</span></span></code></pre>

</div>

Unfortunately dplyr 1.0.0 introduced automatic weight because of my faulty memory. Historically, in dplyr 0.8.0 and earlier, [`tally()`](https://dplyr.tidyverse.org/reference/count.html) automatically weighted and [`count()`](https://dplyr.tidyverse.org/reference/count.html) did not, but this behaviour was [accidentally changed](https://github.com/tidyverse/dplyr/pull/4408) in dplyr 0.8.2 so that neither automatically weighted. This shouldn't have happened in a patch release but we missed the behaviour change in that PR. Since 0.8.2 is almost a year old, and the automatically weighting behaviour was confusing to many people anyway, we've removed it from both [`count()`](https://dplyr.tidyverse.org/reference/count.html) and [`tally()`](https://dplyr.tidyverse.org/reference/count.html).

