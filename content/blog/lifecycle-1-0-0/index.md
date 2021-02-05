---
output: hugodown::hugo_document

slug: lifecycle-1-0-0
title: lifecycle 1 0 0
date: 2021-02-04
author: Hadley Wickham
description: >
    The lifecycle package documentation received a major overhaul
    based on what I learned preparing for my rstudio::global
    keynote.

photo:
  url: https://unsplash.com/photos/VMKBFR6r_jg
  author: Suzanne D. Williams

categories: [package] 
tags: [r-lib]
rmd_hash: 10612cc14105f21b

---

<!--
TODO:
* [ ] Pick category and tags (see existing with [`hugodown::tidy_show_meta()`](https://rdrr.io/pkg/hugodown/man/use_tidy_post.html))
* [ ] Find photo & update yaml metadata
* [ ] Add intro sentence
* [ ] [`usethis::use_tidy_thanks()`](https://usethis.r-lib.org/reference/use_tidy_thanks.html)
-->

We're exceedingly happy to announce the release of [lifecycle](http://lifecycle.r-lib.org/) 1.0.0. lifecycle is the package that we use to manage the lifecycle of functions and features within the tidyverse, and was the topic of my [rstudio::global() talk](https://rstudio.com/resources/rstudioglobal-2021/maintaining-the-house-the-tidyverse-built/):

<script src="https://fast.wistia.com/embed/medias/f7ph68edqb.jsonp" async></script>
<script src="https://fast.wistia.com/assets/external/E-v1.js" async></script>

<div class="wistia_responsive_padding" style="padding:56.25% 0 0 0;position:relative;">

<div class="wistia_responsive_wrapper" style="height:100%;left:0;position:absolute;top:0;width:100%;">

<div class="wistia_embed wistia_async_f7ph68edqb videoFoam=true" style="height:100%;position:relative;width:100%">

<div class="wistia_swatch" style="height:100%;left:0;opacity:0;overflow:hidden;position:absolute;top:0;transition:opacity 200ms;width:100%;">

<img src="https://fast.wistia.com/embed/medias/f7ph68edqb/swatch" style="filter:blur(5px);height:100%;object-fit:contain;width:100%;" alt="" aria-hidden="true" onload="this.parentNode.style.opacity=1;" />

</div>

</div>

</div>

</div>

While it's certainly possible for you to adopt the principles of the tidyverse lifecycle for your own package, most will experience the lifecycle

## Acknowledgements

