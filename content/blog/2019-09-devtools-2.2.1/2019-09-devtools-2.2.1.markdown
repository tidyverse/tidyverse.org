---
title: devtools 2.2.1
date: 2019-09-26
slug: devtools-2-2-1
author: Jim Hester
categories: [package]
description: >
    Make package development easier by providing R functions that simplify and expedite common tasks.
photo:
  url: https://unsplash.com/photos/wEJK4q_YlNQ
  author: Hunter Haley
---

## Introduction

[devtools] 2.2.1 is now on CRAN!

devtools makes package development easier by providing R functions that
simplify and expedite common tasks. R Packages is a book based around this
workflow, which you can read online for free ([1st
edition](http://r-pkgs.had.co.nz/), in-progress [2nd
edition](https://r-pkgs.org/)).

Apart from the new features mentioned below this release also contains a number
of smaller changes and bug fixes. As always a complete list of all the changes
is available in the package
[Changelog](https://devtools.r-lib.org/news/index.html).

## New features

### `create()`

The `create()` function has been re-added to the package. This functions was
previously removed in favor of `usethis::create_package()` but it turns out the
RStudio IDE uses `devtools::create()` as part of its create new project dialog,
so removing the function would break this functionality in older versions of
RStudio. `create()` is however simply an alias for `usethis::create_package()`,
so you are free to use whichever you would prefer in your own use.

### `dev_sitrep()`

A new function `dev_sitrep()` can be used to get a "situation report" about
your development setup. This is important when working on your own packages,
but also to help people get up and running quickly during developer events such
as the [Tidyverse Dev Days](https://github.com/tidyverse/dev-day-2019). It
provides a series of checks that you have the latest versions of R, RStudio,
RTools and package dependencies, along with instructions on how to update them
if needed.

![dev_sitrep() output](/images/devtools-2.2.1/sitrep.png)


### ellipsis

The [ellipsis package](http://ellipsis.r-lib.org/) provides a function
`check_dots_used()` which ensures that all arguments specified in `...` have
been used. Devtools uses `...` to pass arguments down to base R functions such
as `install.packages()`. If the arguments are invalid, such as mis-typing a
argument name they would often be silently ignored rather than throwing an
error. Using ellipsis instead causes a full error to occur in these cases,
catching many more bugs when they happen. `check_dots_used()` is now used for
any devtools function taking `...`.

devtools 2.2.1 introduces a new option `devtools.ellipsis_action` to control
the behavior of ellipsis in devtools. Because there are some cases, like when a
given package is already installed, that devtools does not actually use any of
the arguments in `...`.

`devtools.ellipsis_action` takes one of the following arguments
  - `rlang::abort` - to emit an error if arguments are unused
  - `rlang::warn` - to emit a warning if arguments are unused
  - `rlang::inform` - to emit a message if arguments are unused
  - `rlang::signal` - to emit a message if arguments are unused

Using `rlang::signal` will produce no output unless the custom condition is
caught, so it is the best way to retain backwards compatibility with devtools
behavior prior to 2.2.0.

## Acknowledgements

We are of grateful to _all_ of the *29* people who contributed not just code, but also issues and comments for this release:
[&#x0040;amit0thesingularity](https://github.com/amit0thesingularity),
[&#x0040;bbimber](https://github.com/bbimber),
[&#x0040;Cervangirard](https://github.com/Cervangirard),
[&#x0040;dachosen1](https://github.com/dachosen1),
[&#x0040;DavisVaughan](https://github.com/DavisVaughan),
[&#x0040;deslaur](https://github.com/deslaur),
[&#x0040;djnavarro](https://github.com/djnavarro),
[&#x0040;DSLituiev](https://github.com/DSLituiev),
[&#x0040;DzLGasoline](https://github.com/DzLGasoline),
[&#x0040;f527](https://github.com/f527),
[&#x0040;hadley](https://github.com/hadley),
[&#x0040;hrbrmstr](https://github.com/hrbrmstr),
[&#x0040;IndrajeetPatil](https://github.com/IndrajeetPatil),
[&#x0040;jameslamb](https://github.com/jameslamb),
[&#x0040;jennybc](https://github.com/jennybc),
[&#x0040;jimhester](https://github.com/jimhester),
[&#x0040;jrowen](https://github.com/jrowen),
[&#x0040;k-doering-NOAA](https://github.com/k-doering-NOAA),
[&#x0040;mezerji1365](https://github.com/mezerji1365),
[&#x0040;MichaelChirico](https://github.com/MichaelChirico),
[&#x0040;neonira](https://github.com/neonira),
[&#x0040;njtierney](https://github.com/njtierney),
[&#x0040;p-rocha](https://github.com/p-rocha),
[&#x0040;programgirl](https://github.com/programgirl),
[&#x0040;realDongWang](https://github.com/realDongWang),
[&#x0040;RoundNose](https://github.com/RoundNose),
[&#x0040;rstub](https://github.com/rstub),
[&#x0040;tbates](https://github.com/tbates), and
[&#x0040;TomKellyGenetics](https://github.com/TomKellyGenetics)

[devtools]: https://devtools.r-lib.org
[R Packages]: http://r-pkgs.had.co.nz/
