---
output: hugodown::hugo_document

slug: purrr-1-0-0
title: purrr 1.0.0
date: 2022-12-20
author: Hadley Wickham
description: >
    purrr 1.0.0 brings a basket of updates. We deprecated a number of
    seldom used functions to hone in on the core purpose of purrr and 
    implemented a swath of new features including progress bars, improved 
    error reporting, and much much more!

photo:
  url: https://unsplash.com/photos/YCPkW_r_6uA
  author: Jari Hytönen

# one of: "deep-dive", "learn", "package", "programming", "roundup", or "other"
categories: [package] 
tags: [purrr]
rmd_hash: d6ea0a27deb42fc2

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

We're happy to announce the release of [purrr](http://purrr.tidyverse.org/) 1.0.0! purrr enhances R's functional programming toolkit by providing a complete and consistent set of tools for working with functions and vectors. In the words of ChatGPT:

> With purrr, you can easily "kitten" your functions together to perform complex operations, "paws" for a moment to debug and troubleshoot your code, while "feline" good about the elegant and readable code that you write. Whether you're a "cat"-egorical beginner or a seasoned functional programming "purr"-fessional, purrr has something to offer. So why not "pounce" on the opportunity to try it out and see how it can "meow"-velously improve your R coding experience?

You can install it from CRAN with:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://rdrr.io/r/utils/install.packages.html'>install.packages</a></span><span class='o'>(</span><span class='s'>"purrr"</span><span class='o'>)</span></span></code></pre>

</div>

purrr is 7 years old and it's finally made it to 1.0.0! This is a big release, adding some long-needed functionality (like progress bars!) as well as really refining the core purpose of purrr. In this post, we'll start with an overview of the breaking changes, then briefly review some documentation changes. Then we'll get to the good stuff: improvements to the `map` family, new [`keep_at()`](https://purrr.tidyverse.org/reference/keep_at.html) and [`discard_at()`](https://purrr.tidyverse.org/reference/keep_at.html) functions, and improvements to flattening and simplification. You can see a full list of changes in the [release notes](https://github.com/tidyverse/purrr/releases/tag/v1.0.0).

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://purrr.tidyverse.org/'>purrr</a></span><span class='o'>)</span></span></code></pre>

</div>

## Breaking changes

We've used the 1.0.0 release as an opportunity to really refine the core purpose of purrr: facilitating functional programming in R. We've been more aggressive with deprecations and breaking changes than usual, because a 1.0.0 release signals that purrr is now [stable](https://lifecycle.r-lib.org/articles/stages.html#stable), making it our last opportunity for major changes.

These changes will break some existing code, but we've done our best to make it affect as little code as possible. Out of the \~1400 CRAN packages that user purrr, only \~40 were negatively affected, and I [made pull requests](https://github.com/tidyverse/purrr/issues/969) to fix them all. Making these fixes helped give me confidence that, though we're deprecating quite a few functions and changing a few special cases, it shouldn't affect too much code in the wild.

There are four important changes that you should be aware of:

-   [`pluck()`](https://purrr.tidyverse.org/reference/pluck.html) behaves differently when extracting 0-length vectors.
-   The [`map()`](https://purrr.tidyverse.org/reference/map.html) family uses the tidyverse rules for coercion and recycling.
-   All functions that modify lists handle `NULL` consistently.
-   We've deprecated functions that aren't related to the core purpose of purrr.

### `pluck()` and zero-length vectors

Previously, [`pluck()`](https://purrr.tidyverse.org/reference/pluck.html) replaced 0-length vectors with the value of `default`. Now `default` is only used for `NULL`s and absent elements:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>x</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span>y <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span>a <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/character.html'>character</a></span><span class='o'>(</span><span class='o'>)</span>, b <span class='o'>=</span> <span class='kc'>NULL</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='nv'>x</span> <span class='o'>|&gt;</span> <span class='nf'><a href='https://purrr.tidyverse.org/reference/pluck.html'>pluck</a></span><span class='o'>(</span><span class='s'>"y"</span>, <span class='s'>"a"</span>, .default <span class='o'>=</span> <span class='kc'>NA</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; character(0)</span></span>
<span></span><span><span class='nv'>x</span> <span class='o'>|&gt;</span> <span class='nf'><a href='https://purrr.tidyverse.org/reference/pluck.html'>pluck</a></span><span class='o'>(</span><span class='s'>"y"</span>, <span class='s'>"b"</span>, .default <span class='o'>=</span> <span class='kc'>NA</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; [1] NA</span></span>
<span></span><span><span class='nv'>x</span> <span class='o'>|&gt;</span> <span class='nf'><a href='https://purrr.tidyverse.org/reference/pluck.html'>pluck</a></span><span class='o'>(</span><span class='s'>"y"</span>, <span class='s'>"c"</span>, .default <span class='o'>=</span> <span class='kc'>NA</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; [1] NA</span></span>
<span></span></code></pre>

</div>

This also influences the map family because using an integer vector, character vector, or list instead of a function automatically calls [`pluck()`](https://purrr.tidyverse.org/reference/pluck.html):

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>x</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span><span class='m'>1</span><span class='o'>)</span>, <span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span><span class='o'>)</span>, <span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span><span class='kc'>NULL</span><span class='o'>)</span>, <span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/character.html'>character</a></span><span class='o'>(</span><span class='o'>)</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='nv'>x</span> <span class='o'>|&gt;</span> <span class='nf'><a href='https://purrr.tidyverse.org/reference/map.html'>map</a></span><span class='o'>(</span><span class='m'>1</span>, .default <span class='o'>=</span> <span class='m'>0</span><span class='o'>)</span> <span class='o'>|&gt;</span> <span class='nf'><a href='https://rdrr.io/r/utils/str.html'>str</a></span><span class='o'>(</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; List of 4</span></span>
<span><span class='c'>#&gt;  $ : num 1</span></span>
<span><span class='c'>#&gt;  $ : num 0</span></span>
<span><span class='c'>#&gt;  $ : num 0</span></span>
<span><span class='c'>#&gt;  $ : chr(0)</span></span>
<span></span></code></pre>

</div>

We made this change because it makes purrr more consistent with the rest of the tidyverse and it looks like it was a bug in the original implementation of the function.

### Tidyverse consistency

We've tweaked the map family of functions to be more consistent with general tidyverse coercion and recycling rules, as implemented by the [vctrs](https://vctrs.r-lib.org) package. [`map_lgl()`](https://purrr.tidyverse.org/reference/map.html), [`map_int()`](https://purrr.tidyverse.org/reference/map.html), [`map_int()`](https://purrr.tidyverse.org/reference/map.html), and [`map_dbl()`](https://purrr.tidyverse.org/reference/map.html) now follow the same [coercion rules](https://vctrs.r-lib.org/articles/type-size.html#coercing-to-common-type) as vctrs. In particular:

-   `map_chr(TRUE, identity)`, `map_chr(0L, identity)`, and `map_chr(1.5, identity)` have been deprecated because we believe that converting a logical/integer/double to a character vector is potentially dangerous and should require an explicit coercion.

    <div class="highlight">

    <pre class='chroma'><code class='language-r' data-lang='r'><span><span class='c'># previously you could write</span></span>
    <span><span class='nf'><a href='https://purrr.tidyverse.org/reference/map.html'>map_chr</a></span><span class='o'>(</span><span class='m'>1</span><span class='o'>:</span><span class='m'>4</span>, \<span class='o'>(</span><span class='nv'>x</span><span class='o'>)</span> <span class='nv'>x</span> <span class='o'>+</span> <span class='m'>1</span><span class='o'>)</span></span>
    <span><span class='c'>#&gt; Warning: Automatic coercion from double to character was deprecated in purrr 1.0.0.</span></span>
    <span><span class='c'>#&gt; <span style='color: #00BBBB;'>ℹ</span> Please use an explicit call to `as.character()` within `map_chr()` instead.</span></span>
    <span></span><span><span class='c'>#&gt; [1] "2.000000" "3.000000" "4.000000" "5.000000"</span></span>
    <span></span><span></span>
    <span><span class='c'># now you need something like this:</span></span>
    <span><span class='nf'><a href='https://purrr.tidyverse.org/reference/map.html'>map_chr</a></span><span class='o'>(</span><span class='m'>1</span><span class='o'>:</span><span class='m'>4</span>, \<span class='o'>(</span><span class='nv'>x</span><span class='o'>)</span> <span class='nf'><a href='https://rdrr.io/r/base/character.html'>as.character</a></span><span class='o'>(</span><span class='nv'>x</span> <span class='o'>+</span> <span class='m'>1</span><span class='o'>)</span><span class='o'>)</span></span>
    <span><span class='c'>#&gt; [1] "2" "3" "4" "5"</span></span>
    <span></span></code></pre>

    </div>

-   [`map_int()`](https://purrr.tidyverse.org/reference/map.html) requires that the numeric results be close to integers, rather than silently truncating to integers. Compare these two examples:

    <div class="highlight">

    <pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://purrr.tidyverse.org/reference/map.html'>map_int</a></span><span class='o'>(</span><span class='m'>1</span><span class='o'>:</span><span class='m'>3</span>, \<span class='o'>(</span><span class='nv'>x</span><span class='o'>)</span> <span class='nv'>x</span> <span class='o'>/</span> <span class='m'>2</span><span class='o'>)</span></span>
    <span><span class='c'>#&gt; <span style='color: #BBBB00; font-weight: bold;'>Error</span><span style='font-weight: bold;'> in `map_int()`:</span></span></span>
    <span><span class='c'>#&gt; <span style='color: #00BBBB;'>ℹ</span> In index: 1.</span></span>
    <span><span class='c'>#&gt; <span style='font-weight: bold;'>Caused by error:</span></span></span>
    <span><span class='c'>#&gt; <span style='color: #BBBB00;'>!</span> Can't coerce from a double vector to an integer vector.</span></span>
    <span></span><span></span>
    <span><span class='nf'><a href='https://purrr.tidyverse.org/reference/map.html'>map_int</a></span><span class='o'>(</span><span class='m'>1</span><span class='o'>:</span><span class='m'>3</span>, \<span class='o'>(</span><span class='nv'>x</span><span class='o'>)</span> <span class='nv'>x</span> <span class='o'>*</span> <span class='m'>2</span><span class='o'>)</span></span>
    <span><span class='c'>#&gt; [1] 2 4 6</span></span>
    <span></span></code></pre>

    </div>

[`map2()`](https://purrr.tidyverse.org/reference/map2.html), [`modify2()`](https://purrr.tidyverse.org/reference/modify.html), and [`pmap()`](https://purrr.tidyverse.org/reference/pmap.html) use tidyverse recycling rules, which mean that vectors of length 1 are recycled to any size but all other vectors must have the same length. This has two major changes:

-   Previously, the presence of a zero-length input generated a zero-length output. Now it's recycled using the same rules:

    <div class="highlight">

    <pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://purrr.tidyverse.org/reference/map2.html'>map2</a></span><span class='o'>(</span><span class='m'>1</span><span class='o'>:</span><span class='m'>2</span>, <span class='nf'><a href='https://rdrr.io/r/base/character.html'>character</a></span><span class='o'>(</span><span class='o'>)</span>, <span class='nv'>paste</span><span class='o'>)</span></span>
    <span><span class='c'>#&gt; <span style='color: #BBBB00; font-weight: bold;'>Error</span><span style='font-weight: bold;'> in `map2()`:</span></span></span>
    <span><span class='c'>#&gt; <span style='color: #BBBB00;'>!</span> Can't recycle `.x` (size 2) to match `.y` (size 0).</span></span>
    <span></span><span></span>
    <span><span class='c'># Works because length-1 vector gets recycled to length-0</span></span>
    <span><span class='nf'><a href='https://purrr.tidyverse.org/reference/map2.html'>map2</a></span><span class='o'>(</span><span class='m'>1</span>, <span class='nf'><a href='https://rdrr.io/r/base/character.html'>character</a></span><span class='o'>(</span><span class='o'>)</span>, <span class='nv'>paste</span><span class='o'>)</span></span>
    <span><span class='c'>#&gt; list()</span></span>
    <span></span></code></pre>

    </div>

-   And now must explicitly recycle vectors that aren't length 1:

    <div class="highlight">

    <pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://purrr.tidyverse.org/reference/map2.html'>map2_int</a></span><span class='o'>(</span><span class='m'>1</span><span class='o'>:</span><span class='m'>4</span>, <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='m'>10</span>, <span class='m'>20</span><span class='o'>)</span>, <span class='nv'>`+`</span><span class='o'>)</span></span>
    <span><span class='c'>#&gt; <span style='color: #BBBB00; font-weight: bold;'>Error</span><span style='font-weight: bold;'> in `map2_int()`:</span></span></span>
    <span><span class='c'>#&gt; <span style='color: #BBBB00;'>!</span> Can't recycle `.x` (size 4) to match `.y` (size 2).</span></span>
    <span></span><span></span>
    <span><span class='nf'><a href='https://purrr.tidyverse.org/reference/map2.html'>map2_int</a></span><span class='o'>(</span><span class='m'>1</span><span class='o'>:</span><span class='m'>4</span>, <span class='nf'><a href='https://rdrr.io/r/base/rep.html'>rep</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='m'>10</span>, <span class='m'>20</span><span class='o'>)</span>, <span class='m'>2</span><span class='o'>)</span>, <span class='nv'>`+`</span><span class='o'>)</span></span>
    <span><span class='c'>#&gt; [1] 11 22 13 24</span></span>
    <span></span></code></pre>

    </div>

### Assigning `NULL`

purrr has a number of functions that modify a list: `pluck<-()`, [`assign_in()`](https://purrr.tidyverse.org/reference/modify_in.html), [`modify()`](https://purrr.tidyverse.org/reference/modify.html), [`modify2()`](https://purrr.tidyverse.org/reference/modify.html), [`modify_if()`](https://purrr.tidyverse.org/reference/modify.html), [`modify_at()`](https://purrr.tidyverse.org/reference/modify.html), and [`list_modify()`](https://purrr.tidyverse.org/reference/list_assign.html). Previously, these functions had inconsistent behaviour when you attempted to modify an element with `NULL`: some functions would delete that element, and some would set it to `NULL`. That inconsistency arose because base R handles `NULL` in different ways depending on whether or not use you `$`/`[[` or `[`:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>x1</span> <span class='o'>&lt;-</span> <span class='nv'>x2</span> <span class='o'>&lt;-</span> <span class='nv'>x3</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span>a <span class='o'>=</span> <span class='m'>1</span>, b <span class='o'>=</span> <span class='m'>2</span><span class='o'>)</span></span>
<span></span>
<span><span class='nv'>x1</span><span class='o'>$</span><span class='nv'>a</span> <span class='o'>&lt;-</span> <span class='kc'>NULL</span></span>
<span><span class='nf'><a href='https://rdrr.io/r/utils/str.html'>str</a></span><span class='o'>(</span><span class='nv'>x1</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; List of 1</span></span>
<span><span class='c'>#&gt;  $ b: num 2</span></span>
<span></span><span></span>
<span><span class='nv'>x2</span><span class='o'>[</span><span class='s'>"a"</span><span class='o'>]</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span><span class='kc'>NULL</span><span class='o'>)</span></span>
<span><span class='nf'><a href='https://rdrr.io/r/utils/str.html'>str</a></span><span class='o'>(</span><span class='nv'>x2</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; List of 2</span></span>
<span><span class='c'>#&gt;  $ a: NULL</span></span>
<span><span class='c'>#&gt;  $ b: num 2</span></span>
<span></span></code></pre>

</div>

Now functions that edit a list will create an element containing `NULL`:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>x3</span> <span class='o'>|&gt;</span> </span>
<span>  <span class='nf'><a href='https://purrr.tidyverse.org/reference/list_assign.html'>list_modify</a></span><span class='o'>(</span>a <span class='o'>=</span> <span class='kc'>NULL</span><span class='o'>)</span> <span class='o'>|&gt;</span> </span>
<span>  <span class='nf'><a href='https://rdrr.io/r/utils/str.html'>str</a></span><span class='o'>(</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; List of 2</span></span>
<span><span class='c'>#&gt;  $ a: NULL</span></span>
<span><span class='c'>#&gt;  $ b: num 2</span></span>
<span></span><span></span>
<span><span class='nv'>x3</span> <span class='o'>|&gt;</span> </span>
<span>  <span class='nf'><a href='https://purrr.tidyverse.org/reference/modify.html'>modify_at</a></span><span class='o'>(</span><span class='s'>"b"</span>, \<span class='o'>(</span><span class='nv'>x</span><span class='o'>)</span> <span class='kc'>NULL</span><span class='o'>)</span> <span class='o'>|&gt;</span> </span>
<span>  <span class='nf'><a href='https://rdrr.io/r/utils/str.html'>str</a></span><span class='o'>(</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; List of 2</span></span>
<span><span class='c'>#&gt;  $ a: num 1</span></span>
<span><span class='c'>#&gt;  $ b: NULL</span></span>
<span></span></code></pre>

</div>

If you want to delete the element, you can use the special [`zap()`](https://rlang.r-lib.org/reference/zap.html) sentinel:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>x3</span> <span class='o'>|&gt;</span> </span>
<span>  <span class='nf'><a href='https://purrr.tidyverse.org/reference/list_assign.html'>list_modify</a></span><span class='o'>(</span>a <span class='o'>=</span> <span class='nf'><a href='https://rlang.r-lib.org/reference/zap.html'>zap</a></span><span class='o'>(</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>|&gt;</span> </span>
<span>  <span class='nf'><a href='https://rdrr.io/r/utils/str.html'>str</a></span><span class='o'>(</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; List of 1</span></span>
<span><span class='c'>#&gt;  $ b: num 2</span></span>
<span></span></code></pre>

</div>

[`zap()`](https://rlang.r-lib.org/reference/zap.html) does not work in `modify*()` because those functions are designed to always return the same top-level structure as the input.

### Core purpose refinements

We have **deprecated** a number of functions to keep purrr focused on its core purpose: facilitating functional programming in R. Deprecation means that the functions will continue to work, but you'll be warned once every 8 hours if you use them. In several years time, we'll release an update which causes the warnings to occur on every time you use them, and a few years after that they'll be transformed to throwing errors.

-   [`cross()`](https://purrr.tidyverse.org/reference/cross.html) and all its variants have been deprecated because they're slow and buggy, and a better approach already exists in [`tidyr::expand_grid()`](https://tidyr.tidyverse.org/reference/expand_grid.html).

-   [`update_list()`](https://purrr.tidyverse.org/reference/update_list.html), [`rerun()`](https://purrr.tidyverse.org/reference/rerun.html), and the use of tidyselect with [`map_at()`](https://purrr.tidyverse.org/reference/map_if.html) and friends have been deprecated because we no longer believe that non-standard evaluation is a good fit for purrr.

-   The `lift_*` family of functions has been superseded because they promote a style of function manipulation that is not commonly used in R.

-   [`prepend()`](https://purrr.tidyverse.org/reference/prepend.html), [`rdunif()`](https://purrr.tidyverse.org/reference/rdunif.html), [`rbernoulli()`](https://purrr.tidyverse.org/reference/rbernoulli.html), [`when()`](https://purrr.tidyverse.org/reference/when.html), and [`list_along()`](https://purrr.tidyverse.org/reference/along.html) have been deprecated because they're not directly related to functional programming.

-   `splice()` has been deprecated because we no longer believe that automatic splicing makes for good UI and there are other ways to achieve the same result.

Consult the documentation for the alternatives that we now recommend.

Deprecating these functions makes purrr easier to maintain because it reduces the surface area for bugs and issues, and it makes purrr easier to learn because there's a clearer common thread that ties together all functions.

## Documentation

As you've seen in the code above, we are moving from magrittr's pipe (`%>%`) to the base pipe (`|>`) and from formula syntax (`~ .x + 1`) to R's new anonymous function short hand (`\(x) x + 1`). We believe that it's better to use these new base tools because they work everywhere: the base pipe doesn't require that you load magrittr and the new function shorthand works everywhere, not just in purrr functions. Additionally, being able to specify the argument name for the anonymous function can often lead to clearer code.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='c'># Previously we wrote</span></span>
<span><span class='m'>1</span><span class='o'>:</span><span class='m'>10</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span></span>
<span>  <span class='nf'><a href='https://purrr.tidyverse.org/reference/map.html'>map</a></span><span class='o'>(</span><span class='o'>~</span> <span class='nf'><a href='https://rdrr.io/r/stats/Normal.html'>rnorm</a></span><span class='o'>(</span><span class='m'>10</span>, <span class='nv'>.x</span><span class='o'>)</span><span class='o'>)</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span></span>
<span>  <span class='nf'><a href='https://purrr.tidyverse.org/reference/map.html'>map_dbl</a></span><span class='o'>(</span><span class='nv'>mean</span><span class='o'>)</span></span>
<span><span class='c'>#&gt;  [1]  0.5586355  1.8213041  2.8764412  4.1521664  5.1160393  6.1271905</span></span>
<span><span class='c'>#&gt;  [7]  6.9109806  8.2808301  9.2373940 10.6269104</span></span>
<span></span><span></span>
<span><span class='c'># Now we recommend</span></span>
<span><span class='m'>1</span><span class='o'>:</span><span class='m'>10</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://purrr.tidyverse.org/reference/map.html'>map</a></span><span class='o'>(</span>\<span class='o'>(</span><span class='nv'>mu</span><span class='o'>)</span> <span class='nf'><a href='https://rdrr.io/r/stats/Normal.html'>rnorm</a></span><span class='o'>(</span><span class='m'>10</span>, <span class='nv'>mu</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://purrr.tidyverse.org/reference/map.html'>map_dbl</a></span><span class='o'>(</span><span class='nv'>mean</span><span class='o'>)</span> </span>
<span><span class='c'>#&gt;  [1]  0.4638639  2.0966712  3.4441928  3.7806185  5.3373228  6.1854820</span></span>
<span><span class='c'>#&gt;  [7]  6.5873300  8.3116138  9.4824697 10.4590034</span></span>
<span></span></code></pre>

</div>

We also recommend using an anonymous function instead of passing additional arguments to map. This avoids a certain class of moderately esoteric argument matching woes and, we believe, is generally easier to read.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>mu</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='m'>1</span>, <span class='m'>10</span>, <span class='m'>100</span><span class='o'>)</span></span>
<span></span>
<span><span class='c'># Previously we wrote</span></span>
<span><span class='nv'>mu</span> <span class='o'>|&gt;</span> <span class='nf'><a href='https://purrr.tidyverse.org/reference/map.html'>map_dbl</a></span><span class='o'>(</span><span class='nv'>rnorm</span>, n <span class='o'>=</span> <span class='m'>1</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; [1]  0.5706199 11.3604613 99.9291426</span></span>
<span></span><span></span>
<span><span class='c'># Now we recommend</span></span>
<span><span class='nv'>mu</span> <span class='o'>|&gt;</span> <span class='nf'><a href='https://purrr.tidyverse.org/reference/map.html'>map_dbl</a></span><span class='o'>(</span>\<span class='o'>(</span><span class='nv'>mu</span><span class='o'>)</span> <span class='nf'><a href='https://rdrr.io/r/stats/Normal.html'>rnorm</a></span><span class='o'>(</span><span class='m'>1</span>, mean <span class='o'>=</span> <span class='nv'>mu</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; [1]   0.7278463   7.5533200 100.0654866</span></span>
<span></span></code></pre>

</div>

Due to the [tidyverse R dependency policy](https://www.tidyverse.org/blog/2019/04/r-version-support/), purrr works in R 3.5, 3.6, 4.0, 4.1, and 4.2, but the base pipe and anonymous function syntax are only available in R 4.0 and later. So the examples are automatically disabled on R 3.5 and 3.6 to allow purrr to continue to pass `R CMD check`.

## Mapping

With that out of the way, we can now talk about the exciting new features in purrr 1.0.0. We'll start with the map family of functions which have three big new features:

-   Progress bars.
-   Better errors.
-   A new family member: [`map_vec()`](https://purrr.tidyverse.org/reference/map.html).

These are described in the following sections.

### Progress bars

The map family can now produce a progress bar. This is very useful for long running jobs:

<div class="highlight">

<img src="figs//progress.svg" width="700px" style="display: block; margin: auto;" />

</div>

(For interactive use, the progress bar uses some simple heuristics so that it doesn't show up for very simple jobs.)

In most cases, we expect that `.progress = TRUE` is enough, but if you're wrapping [`map()`](https://purrr.tidyverse.org/reference/map.html) in another function, you might want to set `.progress` to a string that identifies the progress bar:

<div class="highlight">

<img src="figs//named-progress.svg" width="700px" style="display: block; margin: auto;" />

</div>

### Better errors

If there's an error in the function you're mapping, [`map()`](https://purrr.tidyverse.org/reference/map.html) and friends now tell you which element caused the problem:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>x</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/sample.html'>sample</a></span><span class='o'>(</span><span class='m'>1</span><span class='o'>:</span><span class='m'>500</span><span class='o'>)</span></span>
<span><span class='nv'>x</span> <span class='o'>|&gt;</span> <span class='nf'><a href='https://purrr.tidyverse.org/reference/map.html'>map</a></span><span class='o'>(</span>\<span class='o'>(</span><span class='nv'>x</span><span class='o'>)</span> <span class='kr'>if</span> <span class='o'>(</span><span class='nv'>x</span> <span class='o'>==</span> <span class='m'>1</span><span class='o'>)</span> <span class='kr'><a href='https://rdrr.io/r/base/stop.html'>stop</a></span><span class='o'>(</span><span class='s'>"Error!"</span><span class='o'>)</span> <span class='kr'>else</span> <span class='m'>10</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #BBBB00; font-weight: bold;'>Error</span><span style='font-weight: bold;'> in `map()`:</span></span></span>
<span><span class='c'>#&gt; <span style='color: #00BBBB;'>ℹ</span> In index: 51.</span></span>
<span><span class='c'>#&gt; <span style='font-weight: bold;'>Caused by error in `.f()`:</span></span></span>
<span><span class='c'>#&gt; <span style='color: #BBBB00;'>!</span> Error!</span></span>
<span></span></code></pre>

</div>

We hope that this makes your debugging life just a little bit easier! (Don't forget about [`safely()`](https://purrr.tidyverse.org/reference/safely.html) and [`possibly()`](https://purrr.tidyverse.org/reference/possibly.html) if you expect failures and want to either ignore or capture them.)

We have also generally reviewed the error messages throughout purrr in order to make them more actionable. If you hit a confusing error message, please let us know!

### New `map_vec()`

We've added [`map_vec()`](https://purrr.tidyverse.org/reference/map.html) (along with [`map2_vec()`](https://purrr.tidyverse.org/reference/map2.html), and [`pmap_vec()`](https://purrr.tidyverse.org/reference/pmap.html)) to handle more types of vectors. [`map_vec()`](https://purrr.tidyverse.org/reference/map.html) extends [`map_lgl()`](https://purrr.tidyverse.org/reference/map.html), [`map_int()`](https://purrr.tidyverse.org/reference/map.html), [`map_dbl()`](https://purrr.tidyverse.org/reference/map.html), and [`map_chr()`](https://purrr.tidyverse.org/reference/map.html) to arbitrary types of vectors, like dates, factors, and date-times:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='m'>1</span><span class='o'>:</span><span class='m'>3</span> <span class='o'>|&gt;</span> <span class='nf'><a href='https://purrr.tidyverse.org/reference/map.html'>map_vec</a></span><span class='o'>(</span>\<span class='o'>(</span><span class='nv'>i</span><span class='o'>)</span> <span class='nf'><a href='https://rdrr.io/r/base/factor.html'>factor</a></span><span class='o'>(</span><span class='nv'>letters</span><span class='o'>[</span><span class='nv'>i</span><span class='o'>]</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; [1] a b c</span></span>
<span><span class='c'>#&gt; Levels: a b c</span></span>
<span></span><span><span class='m'>1</span><span class='o'>:</span><span class='m'>3</span> <span class='o'>|&gt;</span> <span class='nf'><a href='https://purrr.tidyverse.org/reference/map.html'>map_vec</a></span><span class='o'>(</span>\<span class='o'>(</span><span class='nv'>i</span><span class='o'>)</span> <span class='nf'><a href='https://rdrr.io/r/base/factor.html'>factor</a></span><span class='o'>(</span><span class='nv'>letters</span><span class='o'>[</span><span class='nv'>i</span><span class='o'>]</span>, levels <span class='o'>=</span> <span class='nv'>letters</span><span class='o'>[</span><span class='m'>4</span><span class='o'>:</span><span class='m'>1</span><span class='o'>]</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; [1] a b c</span></span>
<span><span class='c'>#&gt; Levels: d c b a</span></span>
<span></span><span></span>
<span><span class='m'>1</span><span class='o'>:</span><span class='m'>3</span> <span class='o'>|&gt;</span> <span class='nf'><a href='https://purrr.tidyverse.org/reference/map.html'>map_vec</a></span><span class='o'>(</span>\<span class='o'>(</span><span class='nv'>i</span><span class='o'>)</span> <span class='nf'><a href='https://rdrr.io/r/base/as.Date.html'>as.Date</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/ISOdatetime.html'>ISOdate</a></span><span class='o'>(</span><span class='nv'>i</span> <span class='o'>+</span> <span class='m'>2022</span>, <span class='m'>10</span>, <span class='m'>5</span><span class='o'>)</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; [1] "2023-10-05" "2024-10-05" "2025-10-05"</span></span>
<span></span><span><span class='m'>1</span><span class='o'>:</span><span class='m'>3</span> <span class='o'>|&gt;</span> <span class='nf'><a href='https://purrr.tidyverse.org/reference/map.html'>map_vec</a></span><span class='o'>(</span>\<span class='o'>(</span><span class='nv'>i</span><span class='o'>)</span> <span class='nf'><a href='https://rdrr.io/r/base/ISOdatetime.html'>ISOdate</a></span><span class='o'>(</span><span class='nv'>i</span> <span class='o'>+</span> <span class='m'>2022</span>, <span class='m'>10</span>, <span class='m'>5</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; [1] "2023-10-05 12:00:00 GMT" "2024-10-05 12:00:00 GMT"</span></span>
<span><span class='c'>#&gt; [3] "2025-10-05 12:00:00 GMT"</span></span>
<span></span></code></pre>

</div>

[`map_vec()`](https://purrr.tidyverse.org/reference/map.html) exists somewhat in the middle of base R's [`sapply()`](https://rdrr.io/r/base/lapply.html) and [`vapply()`](https://rdrr.io/r/base/lapply.html). Unlike [`sapply()`](https://rdrr.io/r/base/lapply.html) it will always return a simpler vector, erroring if there's no common type:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span><span class='s'>"a"</span>, <span class='m'>1</span><span class='o'>)</span> <span class='o'>|&gt;</span> <span class='nf'><a href='https://purrr.tidyverse.org/reference/map.html'>map_vec</a></span><span class='o'>(</span><span class='nv'>identity</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #BBBB00; font-weight: bold;'>Error</span><span style='font-weight: bold;'> in `map_vec()`:</span></span></span>
<span><span class='c'>#&gt; <span style='color: #BBBB00;'>!</span> Can't combine `&lt;list&gt;[[1]]` &lt;character&gt; and `&lt;list&gt;[[2]]` &lt;double&gt;.</span></span>
<span></span></code></pre>

</div>

If you want to require a certain type of output, supply `.ptype`, making [`map_vec()`](https://purrr.tidyverse.org/reference/map.html) behave more like [`vapply()`](https://rdrr.io/r/base/lapply.html). `ptype` is short for prototype, and should be a vector that exemplifies the type of output you expect.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>x</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span><span class='s'>"a"</span>, <span class='s'>"b"</span><span class='o'>)</span> </span>
<span><span class='nv'>x</span> <span class='o'>|&gt;</span> <span class='nf'><a href='https://purrr.tidyverse.org/reference/map.html'>map_vec</a></span><span class='o'>(</span><span class='nv'>identity</span>, .ptype <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/character.html'>character</a></span><span class='o'>(</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; [1] "a" "b"</span></span>
<span></span><span></span>
<span><span class='c'># will error if the result can't be automatically coerced</span></span>
<span><span class='c'># to the specified ptype</span></span>
<span><span class='nv'>x</span> <span class='o'>|&gt;</span> <span class='nf'><a href='https://purrr.tidyverse.org/reference/map.html'>map_vec</a></span><span class='o'>(</span><span class='nv'>identity</span>, .ptype <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/integer.html'>integer</a></span><span class='o'>(</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #BBBB00; font-weight: bold;'>Error</span><span style='font-weight: bold;'> in `map_vec()`:</span></span></span>
<span><span class='c'>#&gt; <span style='color: #BBBB00;'>!</span> Can't convert `&lt;list&gt;[[1]]` &lt;character&gt; to &lt;integer&gt;.</span></span>
<span></span></code></pre>

</div>

We don't expect you to know or memorise the [rules that vctrs uses for coercion](https://vctrs.r-lib.org/reference/faq-compatibility-types.html); our hope is that they'll become second nature as we steadily ensure that every tidyverse function follows the same rules.

## `keep_at()` and `discard_at()`

purrr has gained a new pair of functions, [`keep_at()`](https://purrr.tidyverse.org/reference/keep_at.html) and [`discard_at()`](https://purrr.tidyverse.org/reference/keep_at.html), that work like [`keep()`](https://purrr.tidyverse.org/reference/keep.html) and [`discard()`](https://purrr.tidyverse.org/reference/keep.html) but operate on names rather than values:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>x</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span>a <span class='o'>=</span> <span class='m'>1</span>, b <span class='o'>=</span> <span class='m'>2</span>, c <span class='o'>=</span> <span class='m'>3</span>, D <span class='o'>=</span> <span class='m'>4</span>, E <span class='o'>=</span> <span class='m'>5</span><span class='o'>)</span></span>
<span></span>
<span><span class='nv'>x</span> <span class='o'>|&gt;</span> </span>
<span>  <span class='nf'><a href='https://purrr.tidyverse.org/reference/keep_at.html'>keep_at</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"a"</span>, <span class='s'>"b"</span>, <span class='s'>"c"</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>|&gt;</span> </span>
<span>  <span class='nf'><a href='https://rdrr.io/r/utils/str.html'>str</a></span><span class='o'>(</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; List of 3</span></span>
<span><span class='c'>#&gt;  $ a: num 1</span></span>
<span><span class='c'>#&gt;  $ b: num 2</span></span>
<span><span class='c'>#&gt;  $ c: num 3</span></span>
<span></span><span></span>
<span><span class='nv'>x</span> <span class='o'>|&gt;</span> </span>
<span>  <span class='nf'><a href='https://purrr.tidyverse.org/reference/keep_at.html'>discard_at</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"a"</span>, <span class='s'>"b"</span>, <span class='s'>"c"</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>|&gt;</span> </span>
<span>  <span class='nf'><a href='https://rdrr.io/r/utils/str.html'>str</a></span><span class='o'>(</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; List of 2</span></span>
<span><span class='c'>#&gt;  $ D: num 4</span></span>
<span><span class='c'>#&gt;  $ E: num 5</span></span>
<span></span></code></pre>

</div>

Alternatively, you can supply a function that is called with the names of the elements and should return a logical vector describing which elements to keep/discard:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>is_lower_case</span> <span class='o'>&lt;-</span> <span class='kr'>function</span><span class='o'>(</span><span class='nv'>x</span><span class='o'>)</span> <span class='nv'>x</span> <span class='o'>==</span> <span class='nf'><a href='https://rdrr.io/r/base/chartr.html'>tolower</a></span><span class='o'>(</span><span class='nv'>x</span><span class='o'>)</span></span>
<span></span>
<span><span class='nv'>x</span> <span class='o'>|&gt;</span> <span class='nf'><a href='https://purrr.tidyverse.org/reference/keep_at.html'>keep_at</a></span><span class='o'>(</span><span class='nv'>is_lower_case</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; $a</span></span>
<span><span class='c'>#&gt; [1] 1</span></span>
<span><span class='c'>#&gt; </span></span>
<span><span class='c'>#&gt; $b</span></span>
<span><span class='c'>#&gt; [1] 2</span></span>
<span><span class='c'>#&gt; </span></span>
<span><span class='c'>#&gt; $c</span></span>
<span><span class='c'>#&gt; [1] 3</span></span>
<span></span></code></pre>

</div>

You can now also pass such a function to all other `_at()` functions:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>x</span> <span class='o'>|&gt;</span> </span>
<span>  <span class='nf'><a href='https://purrr.tidyverse.org/reference/modify.html'>modify_at</a></span><span class='o'>(</span><span class='nv'>is_lower_case</span>, \<span class='o'>(</span><span class='nv'>x</span><span class='o'>)</span> <span class='nv'>x</span> <span class='o'>*</span> <span class='m'>100</span><span class='o'>)</span> <span class='o'>|&gt;</span> </span>
<span>  <span class='nf'><a href='https://rdrr.io/r/utils/str.html'>str</a></span><span class='o'>(</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; List of 5</span></span>
<span><span class='c'>#&gt;  $ a: num 100</span></span>
<span><span class='c'>#&gt;  $ b: num 200</span></span>
<span><span class='c'>#&gt;  $ c: num 300</span></span>
<span><span class='c'>#&gt;  $ D: num 4</span></span>
<span><span class='c'>#&gt;  $ E: num 5</span></span>
<span></span></code></pre>

</div>

## Flattening and simplification

Last, but not least, we've reworked the family of functions that flatten and simplify lists. These caused us a lot of confusion internally because folks (and different packages) used the same words to mean different things. Now there are three main functions that share a common prefix that makes it clear that they all operate on lists:

-   [`list_flatten()`](https://purrr.tidyverse.org/reference/list_flatten.html) removes a single level of hierarchy from a list; the output is always a list.
-   [`list_simplify()`](https://purrr.tidyverse.org/reference/list_simplify.html) reduces a list to a homogeneous vector; the output is always the same length as the input.
-   [`list_c()`](https://purrr.tidyverse.org/reference/list_c.html), [`list_cbind()`](https://purrr.tidyverse.org/reference/list_c.html), and [`list_rbind()`](https://purrr.tidyverse.org/reference/list_c.html) concatenate the elements of a list to produce a vector or data frame. There are no constraints on the output.

These functions have lead us to **supersede** a number of functions. This means that they are not going away but we no longer recommend them, and they will receive only critical bug fixes.

-   `flatten()` has been superseded by [`list_flatten()`](https://purrr.tidyverse.org/reference/list_flatten.html).
-   `flatten_lgl()`, `flatten_int()`, `flatten_dbl()`, and `flatten_chr()` have been superseded by [`list_c()`](https://purrr.tidyverse.org/reference/list_c.html).
-   [`flatten_dfr()`](https://purrr.tidyverse.org/reference/flatten.html) and [`flatten_dfc()`](https://purrr.tidyverse.org/reference/flatten.html) have been superseded by [`list_rbind()`](https://purrr.tidyverse.org/reference/list_c.html) and [`list_cbind()`](https://purrr.tidyverse.org/reference/list_c.html) respectively. [`flatten_dfr()`](https://purrr.tidyverse.org/reference/flatten.html) had some particularly puzzling edge cases when the inputs would be flattened into columns.
-   [`map_dfc()`](https://purrr.tidyverse.org/reference/map_dfr.html) and [`map_dfr()`](https://purrr.tidyverse.org/reference/map_dfr.html) (and their `map2` and `pmap` variants) have been superseded in favour of using the appropriate map function along with [`list_rbind()`](https://purrr.tidyverse.org/reference/list_c.html) or [`list_cbind()`](https://purrr.tidyverse.org/reference/list_c.html).
-   [`simplify()`](https://purrr.tidyverse.org/reference/as_vector.html), [`simplify_all()`](https://purrr.tidyverse.org/reference/as_vector.html), and [`as_vector()`](https://purrr.tidyverse.org/reference/as_vector.html) have been superseded in favour of [`list_simplify()`](https://purrr.tidyverse.org/reference/list_simplify.html).

### Flattening

[`list_flatten()`](https://purrr.tidyverse.org/reference/list_flatten.html) removes one layer of hierarchy from a list. In other words, if any of the children of the list are themselves lists, the contents of those lists are inlined into the parent:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>x</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span><span class='m'>1</span>, <span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span><span class='m'>2</span>, <span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span><span class='m'>3</span>, <span class='m'>4</span><span class='o'>)</span>, <span class='m'>5</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='nv'>x</span> <span class='o'>|&gt;</span> <span class='nf'><a href='https://rdrr.io/r/utils/str.html'>str</a></span><span class='o'>(</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; List of 2</span></span>
<span><span class='c'>#&gt;  $ : num 1</span></span>
<span><span class='c'>#&gt;  $ :List of 3</span></span>
<span><span class='c'>#&gt;   ..$ : num 2</span></span>
<span><span class='c'>#&gt;   ..$ :List of 2</span></span>
<span><span class='c'>#&gt;   .. ..$ : num 3</span></span>
<span><span class='c'>#&gt;   .. ..$ : num 4</span></span>
<span><span class='c'>#&gt;   ..$ : num 5</span></span>
<span></span><span><span class='nv'>x</span> <span class='o'>|&gt;</span> <span class='nf'><a href='https://purrr.tidyverse.org/reference/list_flatten.html'>list_flatten</a></span><span class='o'>(</span><span class='o'>)</span> <span class='o'>|&gt;</span> <span class='nf'><a href='https://rdrr.io/r/utils/str.html'>str</a></span><span class='o'>(</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; List of 4</span></span>
<span><span class='c'>#&gt;  $ : num 1</span></span>
<span><span class='c'>#&gt;  $ : num 2</span></span>
<span><span class='c'>#&gt;  $ :List of 2</span></span>
<span><span class='c'>#&gt;   ..$ : num 3</span></span>
<span><span class='c'>#&gt;   ..$ : num 4</span></span>
<span><span class='c'>#&gt;  $ : num 5</span></span>
<span></span><span><span class='nv'>x</span> <span class='o'>|&gt;</span> <span class='nf'><a href='https://purrr.tidyverse.org/reference/list_flatten.html'>list_flatten</a></span><span class='o'>(</span><span class='o'>)</span> <span class='o'>|&gt;</span> <span class='nf'><a href='https://purrr.tidyverse.org/reference/list_flatten.html'>list_flatten</a></span><span class='o'>(</span><span class='o'>)</span> <span class='o'>|&gt;</span> <span class='nf'><a href='https://rdrr.io/r/utils/str.html'>str</a></span><span class='o'>(</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; List of 5</span></span>
<span><span class='c'>#&gt;  $ : num 1</span></span>
<span><span class='c'>#&gt;  $ : num 2</span></span>
<span><span class='c'>#&gt;  $ : num 3</span></span>
<span><span class='c'>#&gt;  $ : num 4</span></span>
<span><span class='c'>#&gt;  $ : num 5</span></span>
<span></span></code></pre>

</div>

[`list_flatten()`](https://purrr.tidyverse.org/reference/list_flatten.html) always returns a list; once a list is as flat as it can get (i.e. none of its children contain lists), it leaves the input unchanged.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>x</span> <span class='o'>|&gt;</span> <span class='nf'><a href='https://purrr.tidyverse.org/reference/list_flatten.html'>list_flatten</a></span><span class='o'>(</span><span class='o'>)</span> <span class='o'>|&gt;</span> <span class='nf'><a href='https://purrr.tidyverse.org/reference/list_flatten.html'>list_flatten</a></span><span class='o'>(</span><span class='o'>)</span> <span class='o'>|&gt;</span> <span class='nf'><a href='https://purrr.tidyverse.org/reference/list_flatten.html'>list_flatten</a></span><span class='o'>(</span><span class='o'>)</span> <span class='o'>|&gt;</span> <span class='nf'><a href='https://rdrr.io/r/utils/str.html'>str</a></span><span class='o'>(</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; List of 5</span></span>
<span><span class='c'>#&gt;  $ : num 1</span></span>
<span><span class='c'>#&gt;  $ : num 2</span></span>
<span><span class='c'>#&gt;  $ : num 3</span></span>
<span><span class='c'>#&gt;  $ : num 4</span></span>
<span><span class='c'>#&gt;  $ : num 5</span></span>
<span></span></code></pre>

</div>

### Simplification

[`list_simplify()`](https://purrr.tidyverse.org/reference/list_simplify.html) maintains the length of the input, but produces a simpler type:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span><span class='m'>1</span>, <span class='m'>2</span>, <span class='m'>3</span><span class='o'>)</span> <span class='o'>|&gt;</span> <span class='nf'><a href='https://purrr.tidyverse.org/reference/list_simplify.html'>list_simplify</a></span><span class='o'>(</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; [1] 1 2 3</span></span>
<span></span><span><span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span><span class='s'>"a"</span>, <span class='s'>"b"</span>, <span class='s'>"c"</span><span class='o'>)</span> <span class='o'>|&gt;</span> <span class='nf'><a href='https://purrr.tidyverse.org/reference/list_simplify.html'>list_simplify</a></span><span class='o'>(</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; [1] "a" "b" "c"</span></span>
<span></span></code></pre>

</div>

Because the length must stay the same, it will only succeed if every element has length 1:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://purrr.tidyverse.org/reference/list_simplify.html'>list_simplify</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span><span class='m'>1</span>, <span class='m'>2</span>, <span class='m'>3</span><span class='o'>:</span><span class='m'>4</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #BBBB00; font-weight: bold;'>Error</span><span style='font-weight: bold;'> in `list_simplify()`:</span></span></span>
<span><span class='c'>#&gt; <span style='color: #BBBB00;'>!</span> `x[[3]]` must have size 1, not size 2.</span></span>
<span></span><span><span class='nf'><a href='https://purrr.tidyverse.org/reference/list_simplify.html'>list_simplify</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span><span class='m'>1</span>, <span class='m'>2</span>, <span class='nf'><a href='https://rdrr.io/r/base/integer.html'>integer</a></span><span class='o'>(</span><span class='o'>)</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #BBBB00; font-weight: bold;'>Error</span><span style='font-weight: bold;'> in `list_simplify()`:</span></span></span>
<span><span class='c'>#&gt; <span style='color: #BBBB00;'>!</span> `x[[3]]` must have size 1, not size 0.</span></span>
<span></span></code></pre>

</div>

Because the result must be a simpler vector, all the components must be compatible:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://purrr.tidyverse.org/reference/list_simplify.html'>list_simplify</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span><span class='m'>1</span>, <span class='m'>2</span>, <span class='s'>"a"</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #BBBB00; font-weight: bold;'>Error</span><span style='font-weight: bold;'> in `list_simplify()`:</span></span></span>
<span><span class='c'>#&gt; <span style='color: #BBBB00;'>!</span> Can't combine `&lt;list&gt;[[1]]` &lt;double&gt; and `&lt;list&gt;[[3]]` &lt;character&gt;.</span></span>
<span></span></code></pre>

</div>

If you need to simplify if it's possible, but otherwise leave the input unchanged, use `strict = FALSE`:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://purrr.tidyverse.org/reference/list_simplify.html'>list_simplify</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span><span class='m'>1</span>, <span class='m'>2</span>, <span class='s'>"a"</span><span class='o'>)</span>, strict <span class='o'>=</span> <span class='kc'>FALSE</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; [[1]]</span></span>
<span><span class='c'>#&gt; [1] 1</span></span>
<span><span class='c'>#&gt; </span></span>
<span><span class='c'>#&gt; [[2]]</span></span>
<span><span class='c'>#&gt; [1] 2</span></span>
<span><span class='c'>#&gt; </span></span>
<span><span class='c'>#&gt; [[3]]</span></span>
<span><span class='c'>#&gt; [1] "a"</span></span>
<span></span></code></pre>

</div>

If you want to be specific about the type you want, [`list_simplify()`](https://purrr.tidyverse.org/reference/list_simplify.html) can take the same prototype argument as [`map_vec()`](https://purrr.tidyverse.org/reference/map.html):

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span><span class='m'>1</span>, <span class='m'>2</span>, <span class='m'>3</span><span class='o'>)</span> <span class='o'>|&gt;</span> <span class='nf'><a href='https://purrr.tidyverse.org/reference/list_simplify.html'>list_simplify</a></span><span class='o'>(</span>ptype <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/integer.html'>integer</a></span><span class='o'>(</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; [1] 1 2 3</span></span>
<span></span><span></span>
<span><span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span><span class='m'>1</span>, <span class='m'>2</span>, <span class='m'>3</span><span class='o'>)</span> <span class='o'>|&gt;</span> <span class='nf'><a href='https://purrr.tidyverse.org/reference/list_simplify.html'>list_simplify</a></span><span class='o'>(</span>ptype <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/factor.html'>factor</a></span><span class='o'>(</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #BBBB00; font-weight: bold;'>Error</span><span style='font-weight: bold;'> in `list_simplify()`:</span></span></span>
<span><span class='c'>#&gt; <span style='color: #BBBB00;'>!</span> Can't convert `&lt;list&gt;[[1]]` &lt;double&gt; to &lt;factor&lt;&gt;&gt;.</span></span>
<span></span></code></pre>

</div>

### Concatenation

[`list_c()`](https://purrr.tidyverse.org/reference/list_c.html), [`list_cbind()`](https://purrr.tidyverse.org/reference/list_c.html), and [`list_rbind()`](https://purrr.tidyverse.org/reference/list_c.html) concatenate all elements together in a similar way to using `do.call(c)` or `do.call(rbind)`[^1] . Unlike [`list_simplify()`](https://purrr.tidyverse.org/reference/list_simplify.html), this allows the elements to be different lengths:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span><span class='m'>1</span>, <span class='m'>2</span>, <span class='m'>3</span><span class='o'>)</span> <span class='o'>|&gt;</span> <span class='nf'><a href='https://purrr.tidyverse.org/reference/list_c.html'>list_c</a></span><span class='o'>(</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; [1] 1 2 3</span></span>
<span></span><span><span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span><span class='m'>1</span>, <span class='m'>2</span>, <span class='m'>3</span><span class='o'>:</span><span class='m'>4</span>, <span class='nf'><a href='https://rdrr.io/r/base/integer.html'>integer</a></span><span class='o'>(</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>|&gt;</span> <span class='nf'><a href='https://purrr.tidyverse.org/reference/list_c.html'>list_c</a></span><span class='o'>(</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; [1] 1 2 3 4</span></span>
<span></span></code></pre>

</div>

The downside of this flexibility is that these functions break the connection between the input and the output. This reveals that [`map_dfr()`](https://purrr.tidyverse.org/reference/map_dfr.html) and [`map_dfc()`](https://purrr.tidyverse.org/reference/map_dfr.html) don't really belong to the map family because they don't maintain a 1-to-1 mapping between input and output: there's reliable no way to associate a row in the output with an element in an input.

For this reason, [`map_dfr()`](https://purrr.tidyverse.org/reference/map_dfr.html) and [`map_dfc()`](https://purrr.tidyverse.org/reference/map_dfr.html) (and the `map2` and `pmap`) variants are superseded and we recommend switching to an explicit call to [`list_rbind()`](https://purrr.tidyverse.org/reference/list_c.html) or [`list_cbind()`](https://purrr.tidyverse.org/reference/list_c.html) instead:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>paths</span> <span class='o'>|&gt;</span> <span class='nf'><a href='https://purrr.tidyverse.org/reference/map_dfr.html'>map_dfr</a></span><span class='o'>(</span><span class='nv'>read_csv</span>, .id <span class='o'>=</span> <span class='s'>"path"</span><span class='o'>)</span></span>
<span><span class='c'># now</span></span>
<span><span class='nv'>paths</span> <span class='o'>|&gt;</span> </span>
<span>  <span class='nf'><a href='https://purrr.tidyverse.org/reference/map.html'>map</a></span><span class='o'>(</span><span class='nv'>read_csv</span><span class='o'>)</span> <span class='o'>|&gt;</span> </span>
<span>  <span class='nf'><a href='https://purrr.tidyverse.org/reference/list_c.html'>list_rbind</a></span><span class='o'>(</span>names_to <span class='o'>=</span> <span class='s'>"path"</span><span class='o'>)</span></span></code></pre>

</div>

This new behaviour also affects to [`accumulate()`](https://purrr.tidyverse.org/reference/accumulate.html) and [`accumulate2()`](https://purrr.tidyverse.org/reference/accumulate.html), which previously had an idiosyncratic approach to simplification.

### `list_assign()`

There's one other new function that isn't directly related to flattening and friends, but shares the `list_` prefix: [`list_assign()`](https://purrr.tidyverse.org/reference/list_assign.html). [`list_assign()`](https://purrr.tidyverse.org/reference/list_assign.html) is similar to [`list_modify()`](https://purrr.tidyverse.org/reference/list_assign.html) but it doesn't work recursively. This is a mildly confusing feature of [`list_modify()`](https://purrr.tidyverse.org/reference/list_assign.html) that it's easy to miss in the documentation.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span>x <span class='o'>=</span> <span class='m'>1</span>, y <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span>a <span class='o'>=</span> <span class='m'>1</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>|&gt;</span> </span>
<span>  <span class='nf'><a href='https://purrr.tidyverse.org/reference/list_assign.html'>list_modify</a></span><span class='o'>(</span>y <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span>b <span class='o'>=</span> <span class='m'>1</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>|&gt;</span> </span>
<span>  <span class='nf'><a href='https://rdrr.io/r/utils/str.html'>str</a></span><span class='o'>(</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; List of 2</span></span>
<span><span class='c'>#&gt;  $ x: num 1</span></span>
<span><span class='c'>#&gt;  $ y:List of 2</span></span>
<span><span class='c'>#&gt;   ..$ a: num 1</span></span>
<span><span class='c'>#&gt;   ..$ b: num 1</span></span>
<span></span></code></pre>

</div>

[`list_assign()`](https://purrr.tidyverse.org/reference/list_assign.html) doesn't recurse into sublists making it a bit easier to reason about:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span>x <span class='o'>=</span> <span class='m'>1</span>, y <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span>a <span class='o'>=</span> <span class='m'>1</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>|&gt;</span> </span>
<span>  <span class='nf'><a href='https://purrr.tidyverse.org/reference/list_assign.html'>list_assign</a></span><span class='o'>(</span>y <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span>b <span class='o'>=</span> <span class='m'>2</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>|&gt;</span> </span>
<span>  <span class='nf'><a href='https://rdrr.io/r/utils/str.html'>str</a></span><span class='o'>(</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; List of 2</span></span>
<span><span class='c'>#&gt;  $ x: num 1</span></span>
<span><span class='c'>#&gt;  $ y:List of 1</span></span>
<span><span class='c'>#&gt;   ..$ b: num 2</span></span>
<span></span></code></pre>

</div>

## Acknowledgements

A massive thanks to all 162 contributors who have helped make purrr 1.0.0 happen! [@adamroyjones](https://github.com/adamroyjones), [@afoltzm](https://github.com/afoltzm), [@agilebean](https://github.com/agilebean), [@ahjames11](https://github.com/ahjames11), [@AHoerner](https://github.com/AHoerner), [@alberto-dellera](https://github.com/alberto-dellera), [@alex-gable](https://github.com/alex-gable), [@AliciaSchep](https://github.com/AliciaSchep), [@ArtemSokolov](https://github.com/ArtemSokolov), [@AshesITR](https://github.com/AshesITR), [@asmlgkj](https://github.com/asmlgkj), [@aubryvetepi](https://github.com/aubryvetepi), [@balwierz](https://github.com/balwierz), [@bastianilso](https://github.com/bastianilso), [@batpigandme](https://github.com/batpigandme), [@bebersb](https://github.com/bebersb), [@behrman](https://github.com/behrman), [@benjaminschwetz](https://github.com/benjaminschwetz), [@billdenney](https://github.com/billdenney), [@Breza](https://github.com/Breza), [@brunj7](https://github.com/brunj7), [@BrunoGrandePhD](https://github.com/BrunoGrandePhD), [@CGMossa](https://github.com/CGMossa), [@cgoo4](https://github.com/cgoo4), [@chsafouane](https://github.com/chsafouane), [@chumbleycode](https://github.com/chumbleycode), [@ColinFay](https://github.com/ColinFay), [@CorradoLanera](https://github.com/CorradoLanera), [@CPRyan](https://github.com/CPRyan), [@czeildi](https://github.com/czeildi), [@dan-reznik](https://github.com/dan-reznik), [@DanChaltiel](https://github.com/DanChaltiel), [@datawookie](https://github.com/datawookie), [@dave-lovell](https://github.com/dave-lovell), [@davidsjoberg](https://github.com/davidsjoberg), [@DavisVaughan](https://github.com/DavisVaughan), [@deann88](https://github.com/deann88), [@dfalbel](https://github.com/dfalbel), [@dhslone](https://github.com/dhslone), [@dlependorf](https://github.com/dlependorf), [@dllazarov](https://github.com/dllazarov), [@dpprdan](https://github.com/dpprdan), [@dracodoc](https://github.com/dracodoc), [@echasnovski](https://github.com/echasnovski), [@edo91](https://github.com/edo91), [@edoardo-oliveri-sdg](https://github.com/edoardo-oliveri-sdg), [@erictleung](https://github.com/erictleung), [@eyayaw](https://github.com/eyayaw), [@felixhell2004](https://github.com/felixhell2004), [@florianm](https://github.com/florianm), [@florisvdh](https://github.com/florisvdh), [@flying-sheep](https://github.com/flying-sheep), [@fpinter](https://github.com/fpinter), [@frankzhang21](https://github.com/frankzhang21), [@gaborcsardi](https://github.com/gaborcsardi), [@GarrettMooney](https://github.com/GarrettMooney), [@gdurif](https://github.com/gdurif), [@ge-li](https://github.com/ge-li), [@ggrothendieck](https://github.com/ggrothendieck), [@grayskripko](https://github.com/grayskripko), [@gregleleu](https://github.com/gregleleu), [@gregorp](https://github.com/gregorp), [@hadley](https://github.com/hadley), [@hendrikvanb](https://github.com/hendrikvanb), [@holgerbrandl](https://github.com/holgerbrandl), [@hriebl](https://github.com/hriebl), [@hsloot](https://github.com/hsloot), [@huftis](https://github.com/huftis), [@iago-pssjd](https://github.com/iago-pssjd), [@iamnicogomez](https://github.com/iamnicogomez), [@IndrajeetPatil](https://github.com/IndrajeetPatil), [@irudnyts](https://github.com/irudnyts), [@izahn](https://github.com/izahn), [@jameslairdsmith](https://github.com/jameslairdsmith), [@jedwards24](https://github.com/jedwards24), [@jemus42](https://github.com/jemus42), [@jennybc](https://github.com/jennybc), [@jhrcook](https://github.com/jhrcook), [@jimhester](https://github.com/jimhester), [@jimjam-slam](https://github.com/jimjam-slam), [@jnolis](https://github.com/jnolis), [@joelgombin](https://github.com/joelgombin), [@jonathan-g](https://github.com/jonathan-g), [@jpmarindiaz](https://github.com/jpmarindiaz), [@jxu](https://github.com/jxu), [@jzadra](https://github.com/jzadra), [@karchjd](https://github.com/karchjd), [@karjamatti](https://github.com/karjamatti), [@kbzsl](https://github.com/kbzsl), [@krlmlr](https://github.com/krlmlr), [@lahvak](https://github.com/lahvak), [@lambdamoses](https://github.com/lambdamoses), [@lasuk](https://github.com/lasuk), [@lionel-](https://github.com/lionel-), [@lorenzwalthert](https://github.com/lorenzwalthert), [@LukasWallrich](https://github.com/LukasWallrich), [@LukaszDerylo](https://github.com/LukaszDerylo), [@malcolmbarrett](https://github.com/malcolmbarrett), [@MarceloRTonon](https://github.com/MarceloRTonon), [@mattwarkentin](https://github.com/mattwarkentin), [@maxheld83](https://github.com/maxheld83), [@Maximilian-Stefan-Ernst](https://github.com/Maximilian-Stefan-Ernst), [@mccroweyclinton-EPA](https://github.com/mccroweyclinton-EPA), [@medewitt](https://github.com/medewitt), [@meowcat](https://github.com/meowcat), [@mgirlich](https://github.com/mgirlich), [@mine-cetinkaya-rundel](https://github.com/mine-cetinkaya-rundel), [@mitchelloharawild](https://github.com/mitchelloharawild), [@mkoohafkan](https://github.com/mkoohafkan), [@mlane3](https://github.com/mlane3), [@mmuurr](https://github.com/mmuurr), [@moodymudskipper](https://github.com/moodymudskipper), [@mpettis](https://github.com/mpettis), [@nealrichardson](https://github.com/nealrichardson), [@Nelson-Gon](https://github.com/Nelson-Gon), [@neuwirthe](https://github.com/neuwirthe), [@njtierney](https://github.com/njtierney), [@oduilln](https://github.com/oduilln), [@papageorgiou](https://github.com/papageorgiou), [@pat-s](https://github.com/pat-s), [@paulponcet](https://github.com/paulponcet), [@petyaracz](https://github.com/petyaracz), [@phargarten2](https://github.com/phargarten2), [@philiporlando](https://github.com/philiporlando), [@q-w-a](https://github.com/q-w-a), [@QuLogic](https://github.com/QuLogic), [@ramiromagno](https://github.com/ramiromagno), [@rcorty](https://github.com/rcorty), [@reisner](https://github.com/reisner), [@Rekyt](https://github.com/Rekyt), [@roboes](https://github.com/roboes), [@romainfrancois](https://github.com/romainfrancois), [@rorynolan](https://github.com/rorynolan), [@salim-b](https://github.com/salim-b), [@sar8421](https://github.com/sar8421), [@ScoobyQ](https://github.com/ScoobyQ), [@sda030](https://github.com/sda030), [@sgschreiber](https://github.com/sgschreiber), [@sheffe](https://github.com/sheffe), [@Shians](https://github.com/Shians), [@ShixiangWang](https://github.com/ShixiangWang), [@shosaco](https://github.com/shosaco), [@siavash-babaei](https://github.com/siavash-babaei), [@stephenashton-dhsc](https://github.com/stephenashton-dhsc), [@stschiff](https://github.com/stschiff), [@surdina](https://github.com/surdina), [@tdawry](https://github.com/tdawry), [@thebioengineer](https://github.com/thebioengineer), [@TimTaylor](https://github.com/TimTaylor), [@TimTeaFan](https://github.com/TimTeaFan), [@tomjemmett](https://github.com/tomjemmett), [@torbjorn](https://github.com/torbjorn), [@tvatter](https://github.com/tvatter), [@TylerGrantSmith](https://github.com/TylerGrantSmith), [@vorpalvorpal](https://github.com/vorpalvorpal), [@vspinu](https://github.com/vspinu), [@wch](https://github.com/wch), [@werkstattcodes](https://github.com/werkstattcodes), [@williamlai2](https://github.com/williamlai2), [@yogat3ch](https://github.com/yogat3ch), [@yutannihilation](https://github.com/yutannihilation), and [@zeehio](https://github.com/zeehio).

[^1]: But if they used the tidyverse coercion rules.

