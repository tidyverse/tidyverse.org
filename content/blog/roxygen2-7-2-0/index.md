---
output: hugodown::hugo_document

slug: roxygen2-7-2-0
title: roxygen2 7.2.0
date: 2022-05-13
author: Hadley Wickham
description: >
    roxygen2 7.2.0 brings improvements to `NAMESPACE` generation, 
    better multiparameter argument inheritance, and improved warnings.
photo:
  url: https://unsplash.com/photos/hpTH5b6mo2s
  author: ian dooley

# one of: "deep-dive", "learn", "package", "programming", "roundup", or "other"
categories: [package] 
tags: [roxygen2, devtools]
rmd_hash: 178135f071c45cd7

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

We're tickled pink to announce the release of [roxygen2](https://roxygen2.r-lib.org) 7.2.0. roxygen2 allows you to write specially formatted R comments that generate R documentation files (`man/*.Rd`) and the `NAMESPACE` file. roxygen2 is used by over 9,000 CRAN packages.

You can install it from CRAN with:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://rdrr.io/r/utils/install.packages.html'>install.packages</a></span><span class='o'>(</span><span class='s'>"roxygen2"</span><span class='o'>)</span></code></pre>

</div>

There are five big improvements in this release:

-   The `NAMESPACE` roclet now preserves all existing non-import directives during its first pass. This will generally eliminate the pair of `"NAMESPACE has changed"` messages and should reduce the chances that you end up with a sufficiently broken `NAMESPACE` that you can't re-load and re-document your package.

-   `@inheritParams` now only inherits exact multi-parameter matches. For example take `my_plot()` below:

    <div class="highlight">

    <pre class='chroma'><code class='language-r' data-lang='r'><span class='c'>#' @param width,height The dimensions in inches</span>
    <span class='nv'>my_plot</span> <span class='o'>&lt;-</span> <span class='kr'>function</span><span class='o'>(</span><span class='nv'>x</span>, <span class='nv'>width</span>, <span class='nv'>height</span><span class='o'>)</span> <span class='o'>&#123;</span>

    <span class='o'>&#125;</span></code></pre>

    </div>

    Previously, `width` and `height` were inherited individually, so this roxygen2 block:

    <div class="highlight">

    <pre class='chroma'><code class='language-r' data-lang='r'><span class='c'>#' @inheritParams my_plot</span>
    <span class='nv'>your_plot</span> <span class='o'>&lt;-</span> <span class='kr'>function</span><span class='o'>(</span><span class='nv'>x</span>, <span class='nv'>y</span>, <span class='nv'>width</span>, <span class='nv'>height</span><span class='o'>)</span> <span class='o'>&#123;</span>

    <span class='o'>&#125;</span> </code></pre>

    </div>

    Would be equivalent to:

    <div class="highlight">

    <pre class='chroma'><code class='language-r' data-lang='r'><span class='c'>#' @param width The dimensions in inches</span>
    <span class='c'>#' @param height The dimensions in inches</span>
    <span class='nv'>your_plot</span> <span class='o'>&lt;-</span> <span class='kr'>function</span><span class='o'>(</span><span class='nv'>x</span>, <span class='nv'>y</span>, <span class='nv'>width</span>, <span class='nv'>height</span><span class='o'>)</span> <span class='o'>&#123;</span>

    <span class='o'>&#125;</span> </code></pre>

    </div>

    Now, multi-parameter arguments will be inherited as a whole. This could potentially break your documentation if you (e.g.) only had one of `width` and `height` in your function. But we've only seen this problem a few places in the tidyverse, it was easily fixed, and inherited arguments are generally much improved.

-   We've done a thorough review of all warning messages to make them more informative and actionable. We've also fixed a number of bugs that led to invalid Rd files or pointed you to the wrong place.

    If you have a daily build of RStudio, warnings now include a clickable link that takes you directly to the problem. This technology is under active development across the IDE and the [cli](https://cli.r-lib.org) package and you can expect to see more of it in the future.

You can see a full list of changes in the [release notes](https://github.com/r-lib/roxygen2/blob/main/NEWS.md).

## Acknowledgements

A big thanks to everyone who contributed to this release through their issues, pull requests, and discussions! [@AlexisDerumigny](https://github.com/AlexisDerumigny), [@BenWiseman](https://github.com/BenWiseman), [@billdenney](https://github.com/billdenney), [@bobjansen](https://github.com/bobjansen), [@brry](https://github.com/brry), [@cderv](https://github.com/cderv), [@cjyetman](https://github.com/cjyetman), [@courtiol](https://github.com/courtiol), [@DanChaltiel](https://github.com/DanChaltiel), [@danielvartan](https://github.com/danielvartan), [@DarioS](https://github.com/DarioS), [@DavisVaughan](https://github.com/DavisVaughan), [@dieghernan](https://github.com/dieghernan), [@dmurdoch](https://github.com/dmurdoch), [@dwachsmuth](https://github.com/dwachsmuth), [@flrd](https://github.com/flrd), [@gaborcsardi](https://github.com/gaborcsardi), [@hadley](https://github.com/hadley), [@IndrajeetPatil](https://github.com/IndrajeetPatil), [@JantekM](https://github.com/JantekM), [@jennybc](https://github.com/jennybc), [@karoliskoncevicius](https://github.com/karoliskoncevicius), [@kongdd](https://github.com/kongdd), [@kpagacz](https://github.com/kpagacz), [@lionel-](https://github.com/lionel-), [@lorenzwalthert](https://github.com/lorenzwalthert), [@maelle](https://github.com/maelle), [@malcolmbarrett](https://github.com/malcolmbarrett), [@mbojan](https://github.com/mbojan), [@MichaelChirico](https://github.com/MichaelChirico), [@mine-cetinkaya-rundel](https://github.com/mine-cetinkaya-rundel), [@MislavSag](https://github.com/MislavSag), [@mschilli87](https://github.com/mschilli87), [@Nelson-Gon](https://github.com/Nelson-Gon), [@netique](https://github.com/netique), [@pnacht](https://github.com/pnacht), [@ramiromagno](https://github.com/ramiromagno), [@romainfrancois](https://github.com/romainfrancois), [@saicharanp18](https://github.com/saicharanp18), [@simonsays1980](https://github.com/simonsays1980), [@ThierryO](https://github.com/ThierryO), [@wch](https://github.com/wch), [@wurli](https://github.com/wurli), and [@yogat3ch](https://github.com/yogat3ch).

