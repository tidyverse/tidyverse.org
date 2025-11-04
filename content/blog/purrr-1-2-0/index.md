---
output: hugodown::hugo_document

slug: purrr-1-2-0
title: purrr 1.2.0
date: 2025-10-27
author: Hadley Wickham
description: >
    This release tightens up the package by removing long-deprecated functions, 
    making `map_chr()` and predicate functions more type-safe, and requiring a
    newer version of carrier to make `in_parallel()` use easier. It also 
    includes performance improvements to `every()`, `some()`, and `none()`, 
    as well as a new getting started vignette.

photo:
  url: https://unsplash.com/photos/orange-tabby-kitten-in-grasses-RCfi7vgJjUY
  author: Andriyko Podilnyk

# one of: "deep-dive", "learn", "package", "programming", "roundup", or "other"
categories: [package] 
tags: [purrr]
rmd_hash: a2f46f5b87a03e7e

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
* [ ] [`usethis::use_tidy_thanks()`](https://usethis.r-lib.org/reference/use_tidy_thanks.html)
-->

We're thrilled to announce the release of purrr 1.2.0! purrr enhances R's functional programming toolkit with a complete and consistent set of tools for working with functions and vectors.

You can install it from CRAN with:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://rdrr.io/r/utils/install.packages.html'>install.packages</a></span><span class='o'>(</span><span class='s'>"purrr"</span><span class='o'>)</span></span></code></pre>

</div>

Overall, this is a pretty unexciting release since it primarily focusses on removing long-deprecated functions. It does, however, include a couple of small performance improvements to predicate functions and a brand new getting started vignette. We also require a newer version of the carrier package for [`in_parallel()`](https://purrr.tidyverse.org/reference/in_parallel.html) so that it's easier to use. You can see a full list of changes in the [release notes](https://github.com/tidyverse/purrr/releases/tag/v1.2.0).

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://purrr.tidyverse.org/'>purrr</a></span><span class='o'>)</span></span></code></pre>

</div>

## Lifecycle changes

-   All functions and arguments that were deprecated in purrr 0.3.0 have now been removed after being deprecated for over 5 years. These include:

    -   `%@%`
    -   `accumulate_right()`
    -   `at_depth()`
    -   `cross_d()`
    -   `cross_n()`
    -   `reduce2_right()`
    -   `reduce_right()`

-   All functions that were soft-deprecated in purrr 1.0.0 are now fully deprecated. They will continue to work but will generate a deprecation warning, and will be removed in a future release. This includes:

    -   `invoke_*()` functions
    -   `lift_*()` functions  
    -   `cross*()` functions (use [`tidyr::expand_grid()`](https://tidyr.tidyverse.org/reference/expand_grid.html) instead)
    -   [`prepend()`](https://purrr.tidyverse.org/reference/prepend.html)
    -   `splice()`
    -   [`rbernoulli()`](https://purrr.tidyverse.org/reference/rbernoulli.html)
    -   [`rdunif()`](https://purrr.tidyverse.org/reference/rdunif.html)
    -   [`when()`](https://purrr.tidyverse.org/reference/when.html)
    -   [`update_list()`](https://purrr.tidyverse.org/reference/update_list.html)
    -   `*_raw()` functions
    -   [`vec_depth()`](https://purrr.tidyverse.org/reference/pluck_depth.html)

    These deprecations help keep purrr focused on its core purpose: facilitating functional programming in R.

-   [`map_chr()`](https://purrr.tidyverse.org/reference/map.html) no longer automatically coerces logical, integer, or double values to strings. Previously, this coercion happened silently, which could mask bugs in your code. Of the four CRAN packages that required fixes due to this change, two of them (50%) were bugs.

-   The predicate functions [`every()`](https://purrr.tidyverse.org/reference/every.html), [`some()`](https://purrr.tidyverse.org/reference/every.html), and [`none()`](https://purrr.tidyverse.org/reference/every.html) now require that the predicate function `.p` returns a logical scalar: `TRUE`, `FALSE`, or `NA`. Previously, `NA` values of other types (like `NA_integer_` or `NA_character_`) were allowed.

## Minor improvements

Apart from all the breaking changes, there were a couple of small improvements:

-   [`every()`](https://purrr.tidyverse.org/reference/every.html), [`some()`](https://purrr.tidyverse.org/reference/every.html), and [`none()`](https://purrr.tidyverse.org/reference/every.html) have been optimized and are now significantly faster. They're now as fast as or faster than the equivalent `any(map_lgl())` or `all(map_lgl())` calls, making them the preferred choice for checking predicates across lists.

-   purrr (finally) has a "getting started" vignette at `vignette("purrr")`.

## Easier `in_parallel()`

In purrr 1.1.0, we introduced [`in_parallel()`](https://purrr.tidyverse.org/reference/in_parallel.html) for [parallel processing](https://tidyverse.org/blog/2025/07/purrr-1-1-0-parallel/) and we've had great feedback from the community so far. But it was clear that we hadn't made it easy enough to include helper functions or other variables required by your map functions. We've updated this behaviour in carrier 0.3.0, which is now required by purrr. Now the following (in your global environment) will work as you expect:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>fn</span> <span class='o'>&lt;-</span> <span class='kr'>function</span><span class='o'>(</span><span class='nv'>x</span><span class='o'>)</span> <span class='nf'>helper_fn</span><span class='o'>(</span><span class='nv'>x</span><span class='o'>)</span> <span class='o'>*</span> <span class='m'>2</span></span>
<span><span class='nv'>helper_fn</span> <span class='o'>&lt;-</span> <span class='kr'>function</span><span class='o'>(</span><span class='nv'>x</span><span class='o'>)</span> <span class='nv'>x</span> <span class='o'>+</span> <span class='m'>1</span></span>
<span><span class='m'>1</span><span class='o'>:</span><span class='m'>5</span> <span class='o'>|&gt;</span> <span class='nf'><a href='https://purrr.tidyverse.org/reference/map.html'>map</a></span><span class='o'>(</span><span class='nf'><a href='https://purrr.tidyverse.org/reference/in_parallel.html'>in_parallel</a></span><span class='o'>(</span>\<span class='o'>(</span><span class='nv'>x</span><span class='o'>)</span> <span class='nf'>fn</span><span class='o'>(</span><span class='nv'>x</span><span class='o'>)</span>, fn <span class='o'>=</span> <span class='nv'>fn</span>, helper_fn <span class='o'>=</span> <span class='nv'>helper_fn</span><span class='o'>)</span><span class='o'>)</span></span></code></pre>

</div>

Whereas previously, `fn()` would have been unable to find `helper_fn()`, this is solved by all functions passed to [`in_parallel()`](https://purrr.tidyverse.org/reference/in_parallel.html) now sharing the same environment.

## Acknowledgements

We'd like to thank everyone who contributed to this release by filing issues and submitting pull requests. Your feedback and contributions help make purrr better for everyone! [@feinleib](https://github.com/feinleib), [@filipemsc](https://github.com/filipemsc), [@fwimp](https://github.com/fwimp), [@hadley](https://github.com/hadley), [@its-gazza](https://github.com/its-gazza), [@jcolt45](https://github.com/jcolt45), [@jeroenjanssens](https://github.com/jeroenjanssens), [@jrwinget](https://github.com/jrwinget), [@khusmann](https://github.com/khusmann), [@luisDVA](https://github.com/luisDVA), [@MarkPaulin](https://github.com/MarkPaulin), [@Meghansaha](https://github.com/Meghansaha), [@mtcarsalot](https://github.com/mtcarsalot), [@og2293](https://github.com/og2293), [@padpadpadpad](https://github.com/padpadpadpad), [@PMassicotte](https://github.com/PMassicotte), [@shikokuchuo](https://github.com/shikokuchuo), [@steffen-stell](https://github.com/steffen-stell), and [@wahalulu](https://github.com/wahalulu).

