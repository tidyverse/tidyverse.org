---
title: "tidyverse and r-lib: a year in review"
author: Mara Averick
date: '2018-12-14'
slug: tidyverse-and-r-lib-year-in-review
description: > 
  A look back on 2018 in the tidyverse and beyond.
categories:
  - other
photo:
  url: https://unsplash.com/photos/SshYpuf607g
  author: Aperture Vintage
---

*Hadley Wickham, Mara Averick, Jenny Bryan, Gábor Csárdi, Romain François, Alex Hayes, Lionel Henry, Jim Hester, Max Kuhn, Thomas Lin Pedersen, Davis Vaughan*

We added significant roster depth this year, with Davis Vaughan, Thomas Lin Pedersen, Alex Hayes, and Romain François all joining the squad.

## By the numbers

* **22** new packages on CRAN

* **54** packages with *major* releases

* **91** packages with releases this year

* **100+** talks and workshops

* **42** articles on [tidyverse.org](https://www.tidyverse.org/articles/)

After 6 years of development, [**pkgdown**](https://www.tidyverse.org/articles/2018/05/pkgdown-1-0-0/) had its initial release on CRAN. pkgdown is designed to make it quick and easy to build a website for your package, and has already been used to make sites for over 2500 packages. 

Several major tidyverse package releases have centered on the implementation of [**tidy evaluation**](https://tidyeval.tidyverse.org/). Notable among these was the 3.0.0 release of [**ggplot2**](https://www.tidyverse.org/articles/2018/07/ggplot2-3-0-0/), which has more than 2000 reverse dependencies. We continue to improve our tools for and skills with releases with large numbers of reverse dependencies.

[**devtools 2.0.0**](https://www.tidyverse.org/articles/2018/10/devtools-2-0-0/) split the functionality in devtools into a number of smaller packages which are simpler to develop, and also easier for other packages to depend on. Though devtools will remain the primary package with which developers interact, the functionality will come from its component packages (in what we’re calling a [conscious uncoupling](https://github.com/r-lib/devtools#conscious-uncoupling)).

The [**tidymodels**](https://github.com/tidymodels) collection is the home of several new modelling packages, which follow opinionated but reasonable [model implementation practices](https://tidymodels.github.io/model-implementation-principles/). This includes the [**parsnip**](https://tidymodels.github.io/parsnip/) package, which standardizes the interface for fitting models as well as their return values — separating model *specification* from model *implementation* ([more detail here](https://deploy-preview-236--tidyverse-org.netlify.com/articles/2018/11/parsnip-0-0-1/)). In effect, when using parsnip, you don’t have to remember each interface and its unique set of argument names to easily move between R packages.

## Consistency

Among the [tidyverse development principles](https://principles.tidyverse.org) is the goal of being [consistent](https://principles.tidyverse.org/unifying-principles.html#consistent). This has, perhaps, been most visible in our implementation of [tidy evaluation](https://tidyeval.tidyverse.org/) across tidyverse packages. The [**fs**](https://fs.r-lib.org/) r-lib package, first released at the beginning of the year, helps bring such consistency to file system operations. More recently, we’ve devised a consistent strategy for handling [name repair](https://principles.tidyverse.org/names-attribute.html) that can be used to make name-handling more predictable. [**vctrs**](https://vctrs.r-lib.org/), which recently had its first CRAN release, will allow us to bring [type- and size-stability](https://vctrs.r-lib.org/articles/stability.html) to user-facing functions; a major focus as we head into the next year.

## Tidyverse dev day

We hope that our first [**tidyverse developer day**](https://www.tidyverse.org/articles/2018/11/tidyverse-developer-day-2019/) (held after rstudio::conf) will help us continue to nurture regular contributors of all skill levels. We have 100 developers (50 general admission + 50 URM) signed!
