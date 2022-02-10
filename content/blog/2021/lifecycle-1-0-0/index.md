---
output: hugodown::hugo_document

slug: lifecycle-1-0-0
title: lifecycle 1.0.0
date: 2021-02-15
author: Hadley Wickham
description: >
    The lifecycle package documentation received a major overhaul
    based on what I learned preparing for my rstudio::global
    keynote.

photo:
  url: https://unsplash.com/photos/VMKBFR6r_jg
  author: Suzanne D. Williams

categories: [package] 
tags: [tidyverse]
rmd_hash: dda8a225f4fd027d

---

We're exceedingly happy to announce the release of [lifecycle](http://lifecycle.r-lib.org/) 1.0.0. The tidyverse team uses the lifecycle package to manage the lifecycle of functions and features within the tidyverse, letting you know what's still experimental and what we're moving away from in the future.

If you're new to the lifecycle package, the best place to start is my [rstudio::global() talk](https://rstudio.com/resources/rstudioglobal-2021/maintaining-the-house-the-tidyverse-built/):

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

Or if you'd prefer to read about it, the lifecycle package now contains three vignettes:

-   [`vignette("stages")`](https://lifecycle.r-lib.org/articles/stages.html) describes the lifecycle stages so you know what it means for a function to be experimental, stable, deprecated, or superseded.

-   [`vignette("manage")`](https://lifecycle.r-lib.org/articles/manage.html) shows you how to manage lifecycle changes in functions that you use.

-   [`vignette("communicate")`](https://lifecycle.r-lib.org/articles/communicate.html) shows you how to communicate lifecycle changes in the functions you write. This documents exactly the process we follow when (e.g.) we deprecate a function.

This release of the lifecycle 1.0.0 package includes a few other minor improvements, which you can read about in the [release notes](https://github.com/r-lib/lifecycle/releases/tag/v1.0.0).

## Acknowledgements

A big thanks to all contributors: [@batpigandme](https://github.com/batpigandme), [@bergsmat](https://github.com/bergsmat), [@Bisaloo](https://github.com/Bisaloo), [@colearendt](https://github.com/colearendt), [@DanChaltiel](https://github.com/DanChaltiel), [@dpprdan](https://github.com/dpprdan), [@florianm](https://github.com/florianm), [@gowerc](https://github.com/gowerc), [@hadley](https://github.com/hadley), [@HenrikBengtsson](https://github.com/HenrikBengtsson), [@jarauh](https://github.com/jarauh), [@jennybc](https://github.com/jennybc), [@joethorley](https://github.com/joethorley), [@jpritikin](https://github.com/jpritikin), [@k-doering-NOAA](https://github.com/k-doering-NOAA), [@KapLDN](https://github.com/KapLDN), [@krlmlr](https://github.com/krlmlr), [@lionel-](https://github.com/lionel-), [@mkirzon](https://github.com/mkirzon), [@Robinlovelace](https://github.com/Robinlovelace), [@romainfrancois](https://github.com/romainfrancois), [@salim-b](https://github.com/salim-b), [@sigmasigmaiota](https://github.com/sigmasigmaiota), [@wlandau](https://github.com/wlandau), [@yonicd](https://github.com/yonicd), and [@yutannihilation](https://github.com/yutannihilation).

