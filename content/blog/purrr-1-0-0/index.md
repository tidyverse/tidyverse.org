---
output: hugodown::hugo_document

slug: purrr-1-0-0
title: purrr 1.0.0
date: 2022-11-10
author: Hadley Wickham
description: >
    purrr 1.0.0 brings a basket of updates to purrr. We deprecated a number of
    seldom used functions to hone in on the core purpose of purrr while 
    implemented a swath of new features including progress bars, improved 
    error reporting, and much much more!

photo:
  url: https://unsplash.com/photos/YCPkW_r_6uA
  author: Jari Hytönen

# one of: "deep-dive", "learn", "package", "programming", "roundup", or "other"
categories: [package] 
tags: [purrr]
rmd_hash: b31c6fa476b44c62

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

We're happy to announce the release of [purrr](http://purrr.tidyverse.org/) 1.0.0! purrr enhances R's functional programming toolkit by providing a complete and consistent set of tools for working with functions and vectors.

You can install it from CRAN with:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://rdrr.io/r/utils/install.packages.html'>install.packages</a></span><span class='o'>(</span><span class='s'>"purrr"</span><span class='o'>)</span></span></code></pre>

</div>

purrr is 7 years old, but it's finally made it to 1.0.0! This was an opportunity to really refine the core purrrpose of purrr, making it more purrrsimonious by moving a number of functions to purrrgatory. Hopefully these changes are not cat-istrophic.

In this post, we'll start with an overview of the breaking changes in this release. We'll then briefly review some documentation changes, before moving on to the big new stuff: refinements to the map functions (including progress bars!), new [`keep_at()`](https://purrr.tidyverse.org/reference/keep_at.html) and [`discard_at()`](https://purrr.tidyverse.org/reference/keep_at.html), and changes to flattening and simplification.

One small note: in alignment our 2021 policy [purrr has been re-licensed](https://www.tidyverse.org/blog/2021/12/relicensing-packages/) with the MIT license.

You can see a full list of changes in the [release notes](%7B%20github_release%20%7D)

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://purrr.tidyverse.org/'>purrr</a></span><span class='o'>)</span></span></code></pre>

</div>

## Breaking changes

First the bad stuff: we've made some changes to the way purrr operates. We've been a bit more aggressive than usual here because A 1.0.0 release is an opportunity to make some bigger changes to the package to ensure it's on firm footing for the next 10 years. Nevertheless, we don't anticipate too many impacts on user code. As part of our new policy, I made pull requests to all [CRAN packages that broke](https://github.com/tidyverse/purrr/issues/969) (except for the 1 that wasn't on GitHub). Out of \~1,400 dependencies only \~40 had problems. I've found making these PRs very empathy building and I'm getting much faster at parachuting into a random package that I have no idea what it does and fixing the problems. This act also gave me confidence that while we're deprecating quite a few functions and changing a few special cases, it shouldn't affect too much code in the wild.

### pluck and zero-length vectors

Previously, [`pluck()`](https://purrr.tidyverse.org/reference/pluck.html) would replace 0-length vectors with the value of `default`. Now only `NULL` and absent elements will be replaced with `default`:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>x</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span>y <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span>a <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/character.html'>character</a></span><span class='o'>(</span><span class='o'>)</span>, b <span class='o'>=</span> <span class='kc'>NULL</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='nv'>x</span> <span class='o'>|&gt;</span> <span class='nf'><a href='https://purrr.tidyverse.org/reference/pluck.html'>pluck</a></span><span class='o'>(</span><span class='s'>"y"</span>, <span class='s'>"a"</span>, .default <span class='o'>=</span> <span class='kc'>NA</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; character(0)</span></span><span><span class='nv'>x</span> <span class='o'>|&gt;</span> <span class='nf'><a href='https://purrr.tidyverse.org/reference/pluck.html'>pluck</a></span><span class='o'>(</span><span class='s'>"y"</span>, <span class='s'>"b"</span>, .default <span class='o'>=</span> <span class='kc'>NA</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; [1] NA</span></span><span><span class='nv'>x</span> <span class='o'>|&gt;</span> <span class='nf'><a href='https://purrr.tidyverse.org/reference/pluck.html'>pluck</a></span><span class='o'>(</span><span class='s'>"y"</span>, <span class='s'>"c"</span>, .default <span class='o'>=</span> <span class='kc'>NA</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; [1] NA</span></span></code></pre>

</div>

This also influences the map family because using an integer vector, character vector, or list automatically calls [`pluck()`](https://purrr.tidyverse.org/reference/pluck.html):

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>x</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span><span class='m'>1</span><span class='o'>)</span>, <span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span><span class='o'>)</span>, <span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span><span class='kc'>NULL</span><span class='o'>)</span>, <span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/character.html'>character</a></span><span class='o'>(</span><span class='o'>)</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='nv'>x</span> <span class='o'>|&gt;</span> <span class='nf'><a href='https://purrr.tidyverse.org/reference/map.html'>map</a></span><span class='o'>(</span><span class='m'>1</span>, .default <span class='o'>=</span> <span class='m'>0</span><span class='o'>)</span> <span class='o'>|&gt;</span> <span class='nf'><a href='https://rdrr.io/r/utils/str.html'>str</a></span><span class='o'>(</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; List of 4</span></span>
<span><span class='c'>#&gt;  $ : num 1</span></span>
<span><span class='c'>#&gt;  $ : num 0</span></span>
<span><span class='c'>#&gt;  $ : num 0</span></span>
<span><span class='c'>#&gt;  $ : chr(0)</span></span></code></pre>

</div>

We made this change because it makes purrr more consistent with the rest of the tidyverse which distinguishes zero-length vectors from `NULL`s, and it looks like it was a bug in the original implementation of the function.

### Tidyverse consistency

We've tweak the map family of functions to be more consistent with general tidyverse recycling and coercion rules, as implemented by the vctrs package. [`map_lgl()`](https://purrr.tidyverse.org/reference/map.html), [`map_int()`](https://purrr.tidyverse.org/reference/map.html), [`map_int()`](https://purrr.tidyverse.org/reference/map.html), and [`map_dbl()`](https://purrr.tidyverse.org/reference/map.html) now follow the same coercion rules as vctrs. This means that:

-   `map_chr(TRUE, identity)`, `map_chr(0L, identity)`, and `map_chr(1L, identity)` are deprecated because we believe that converting a logical/integer/double to a character vector is potentially dangerous and should require an explicit coercion.

    <div class="highlight">

    <pre class='chroma'><code class='language-r' data-lang='r'><span><span class='c'># previously you could write</span></span>
    <span><span class='nf'><a href='https://purrr.tidyverse.org/reference/map.html'>map_chr</a></span><span class='o'>(</span><span class='m'>1</span><span class='o'>:</span><span class='m'>4</span>, \<span class='o'>(</span><span class='nv'>x</span><span class='o'>)</span> <span class='nv'>x</span> <span class='o'>+</span> <span class='m'>1</span><span class='o'>)</span></span>
    <span><span class='c'>#&gt; Warning: Automatic coercion from double to character was deprecated in purrr 1.0.0.</span></span>
    <span><span class='c'>#&gt; <span style='color: #00BBBB;'>ℹ</span> Please use an explicit call to `as.character()` within `map_chr()` instead.</span></span><span><span class='c'>#&gt; [1] "2.000000" "3.000000" "4.000000" "5.000000"</span></span><span></span>
    <span><span class='c'># now you need something like this:</span></span>
    <span><span class='nf'><a href='https://purrr.tidyverse.org/reference/map.html'>map_chr</a></span><span class='o'>(</span><span class='m'>1</span><span class='o'>:</span><span class='m'>4</span>, \<span class='o'>(</span><span class='nv'>x</span><span class='o'>)</span> <span class='nf'><a href='https://rdrr.io/r/base/character.html'>as.character</a></span><span class='o'>(</span><span class='nv'>x</span> <span class='o'>+</span> <span class='m'>1</span><span class='o'>)</span><span class='o'>)</span></span>
    <span><span class='c'>#&gt; [1] "2" "3" "4" "5"</span></span></code></pre>

    </div>

-   [`map_int()`](https://purrr.tidyverse.org/reference/map.html) requires that the numeric results be close to integers, rather than silently truncating to integers. Compare these two examples:

    <div class="highlight">

    <pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://purrr.tidyverse.org/reference/map.html'>map_int</a></span><span class='o'>(</span><span class='m'>1</span><span class='o'>:</span><span class='m'>3</span>, \<span class='o'>(</span><span class='nv'>x</span><span class='o'>)</span> <span class='nv'>x</span> <span class='o'>/</span> <span class='m'>2</span><span class='o'>)</span></span>
    <span><span class='c'>#&gt; <span style='color: #BBBB00; font-weight: bold;'>Error</span><span style='font-weight: bold;'> in `map_int()`:</span></span></span>
    <span><span class='c'>#&gt; <span style='color: #00BBBB;'>ℹ</span> In index: 1.</span></span>
    <span><span class='c'>#&gt; <span style='font-weight: bold;'>Caused by error:</span></span></span>
    <span><span class='c'>#&gt; <span style='color: #BBBB00;'>!</span> Can't coerce from a double vector to an integer vector.</span></span><span></span>
    <span><span class='nf'><a href='https://purrr.tidyverse.org/reference/map.html'>map_int</a></span><span class='o'>(</span><span class='m'>1</span><span class='o'>:</span><span class='m'>3</span>, \<span class='o'>(</span><span class='nv'>x</span><span class='o'>)</span> <span class='nv'>x</span> <span class='o'>*</span> <span class='m'>2</span><span class='o'>)</span></span>
    <span><span class='c'>#&gt; [1] 2 4 6</span></span></code></pre>

    </div>

[`map2()`](https://purrr.tidyverse.org/reference/map2.html), [`modify2()`](https://purrr.tidyverse.org/reference/modify.html), and [`pmap()`](https://purrr.tidyverse.org/reference/pmap.html) use tidyverse recycling rules where vectors of length 1 are recycled to any size but all others must have the same length. This has two major changes:

-   Previously, the presence of a zero-length input generated a zero-length output. Now its recycled using the same rules:

    <div class="highlight">

    <pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://purrr.tidyverse.org/reference/map2.html'>map2</a></span><span class='o'>(</span><span class='m'>1</span><span class='o'>:</span><span class='m'>2</span>, <span class='nf'><a href='https://rdrr.io/r/base/character.html'>character</a></span><span class='o'>(</span><span class='o'>)</span>, <span class='nv'>paste</span><span class='o'>)</span></span>
    <span><span class='c'>#&gt; <span style='color: #BBBB00; font-weight: bold;'>Error</span><span style='font-weight: bold;'> in `map2()`:</span></span></span>
    <span><span class='c'>#&gt; <span style='color: #BBBB00;'>!</span> Can't recycle `.x` (size 2) to match `.y` (size 0).</span></span><span></span>
    <span><span class='c'># Works because length-1 vector gets recycled to length-0</span></span>
    <span><span class='nf'><a href='https://purrr.tidyverse.org/reference/map2.html'>map2</a></span><span class='o'>(</span><span class='m'>1</span>, <span class='nf'><a href='https://rdrr.io/r/base/character.html'>character</a></span><span class='o'>(</span><span class='o'>)</span>, <span class='nv'>paste</span><span class='o'>)</span></span>
    <span><span class='c'>#&gt; list()</span></span></code></pre>

    </div>

-   And now must explicitly recycle vectors that aren't length 1:

    <div class="highlight">

    <pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://purrr.tidyverse.org/reference/map2.html'>map2_int</a></span><span class='o'>(</span><span class='m'>1</span><span class='o'>:</span><span class='m'>4</span>, <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='m'>10</span>, <span class='m'>20</span><span class='o'>)</span>, <span class='nv'>`+`</span><span class='o'>)</span></span>
    <span><span class='c'>#&gt; <span style='color: #BBBB00; font-weight: bold;'>Error</span><span style='font-weight: bold;'> in `map2_int()`:</span></span></span>
    <span><span class='c'>#&gt; <span style='color: #BBBB00;'>!</span> Can't recycle `.x` (size 4) to match `.y` (size 2).</span></span><span></span>
    <span><span class='nf'><a href='https://purrr.tidyverse.org/reference/map2.html'>map2_int</a></span><span class='o'>(</span><span class='m'>1</span><span class='o'>:</span><span class='m'>4</span>, <span class='nf'><a href='https://rdrr.io/r/base/rep.html'>rep</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='m'>10</span>, <span class='m'>20</span><span class='o'>)</span>, <span class='m'>2</span><span class='o'>)</span>, <span class='nv'>`+`</span><span class='o'>)</span></span>
    <span><span class='c'>#&gt; [1] 11 22 13 24</span></span></code></pre>

    </div>

### Assigning `NULL`

There are a number of purrr functions that allow you to modify a list in someway: `pluck<-`, [`assign_in()`](https://purrr.tidyverse.org/reference/modify_in.html), [`modify()`](https://purrr.tidyverse.org/reference/modify.html), [`modify2()`](https://purrr.tidyverse.org/reference/modify.html), [`modify_if()`](https://purrr.tidyverse.org/reference/modify.html), [`modify_if()`](https://purrr.tidyverse.org/reference/modify.html), and [`list_modify()`](https://purrr.tidyverse.org/reference/list_update.html). Previously these functions had inconsistent behaviour when you attempted to modify an element with `NULL`: some functions would delete that element, and some would set it to `NULL`. That inconsistency arose because base R handles `NULL` in different ways depending on whether or not use you `$`/`[[` or `[`:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>x1</span> <span class='o'>&lt;-</span> <span class='nv'>x2</span> <span class='o'>&lt;-</span> <span class='nv'>x3</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span>a <span class='o'>=</span> <span class='m'>1</span>, b <span class='o'>=</span> <span class='m'>2</span><span class='o'>)</span></span>
<span></span>
<span><span class='nv'>x1</span><span class='o'>$</span><span class='nv'>a</span> <span class='o'>&lt;-</span> <span class='kc'>NULL</span></span>
<span><span class='nf'><a href='https://rdrr.io/r/utils/str.html'>str</a></span><span class='o'>(</span><span class='nv'>x1</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; List of 1</span></span>
<span><span class='c'>#&gt;  $ b: num 2</span></span><span></span>
<span><span class='nv'>x2</span><span class='o'>[</span><span class='s'>"a"</span><span class='o'>]</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span><span class='kc'>NULL</span><span class='o'>)</span></span>
<span><span class='nf'><a href='https://rdrr.io/r/utils/str.html'>str</a></span><span class='o'>(</span><span class='nv'>x2</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; List of 2</span></span>
<span><span class='c'>#&gt;  $ a: NULL</span></span>
<span><span class='c'>#&gt;  $ b: num 2</span></span></code></pre>

</div>

That difference accidentally causes different purrr functions to handle `NULL` differently. Now all list modifying functions will create an element containing `NULL`:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>x3</span> <span class='o'>|&gt;</span> </span>
<span>  <span class='nf'><a href='https://purrr.tidyverse.org/reference/list_update.html'>list_modify</a></span><span class='o'>(</span>a <span class='o'>=</span> <span class='kc'>NULL</span><span class='o'>)</span> <span class='o'>|&gt;</span> </span>
<span>  <span class='nf'><a href='https://rdrr.io/r/utils/str.html'>str</a></span><span class='o'>(</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; List of 2</span></span>
<span><span class='c'>#&gt;  $ a: NULL</span></span>
<span><span class='c'>#&gt;  $ b: num 2</span></span><span></span>
<span><span class='nv'>x3</span> <span class='o'>|&gt;</span> </span>
<span>  <span class='nf'><a href='https://purrr.tidyverse.org/reference/modify.html'>modify_at</a></span><span class='o'>(</span><span class='s'>"b"</span>, \<span class='o'>(</span><span class='nv'>x</span><span class='o'>)</span> <span class='kc'>NULL</span><span class='o'>)</span> <span class='o'>|&gt;</span> </span>
<span>  <span class='nf'><a href='https://rdrr.io/r/utils/str.html'>str</a></span><span class='o'>(</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; List of 2</span></span>
<span><span class='c'>#&gt;  $ a: num 1</span></span>
<span><span class='c'>#&gt;  $ b: NULL</span></span></code></pre>

</div>

If you want to delete the element, you'll need to use the special [`zap()`](https://rlang.r-lib.org/reference/zap.html) sentinel:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>x3</span> <span class='o'>|&gt;</span> </span>
<span>  <span class='nf'><a href='https://purrr.tidyverse.org/reference/list_update.html'>list_modify</a></span><span class='o'>(</span>a <span class='o'>=</span> <span class='nf'><a href='https://rlang.r-lib.org/reference/zap.html'>zap</a></span><span class='o'>(</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>|&gt;</span> </span>
<span>  <span class='nf'><a href='https://rdrr.io/r/utils/str.html'>str</a></span><span class='o'>(</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; List of 1</span></span>
<span><span class='c'>#&gt;  $ b: num 2</span></span></code></pre>

</div>

[`zap()`](https://rlang.r-lib.org/reference/zap.html) does not work in [`modify()`](https://purrr.tidyverse.org/reference/modify.html) and friends because they are designed to always return the same top-level structure as the input.

### Core purpose refinements

As well as changing the behaviour of some functions, we've deprecated a number of functions have been deprecated to keep purrr focused on its core purpose: facilitating functional programming in R. Deprecating these functions makes purrr easier to maintain because it reduces the surface area for bugs and issues, and it makes purrr easier to learn because there's a clearer common thread that ties together all functions.

-   [`cross()`](https://purrr.tidyverse.org/reference/cross.html) and all its variants have been deprecated because they're slow and buggy, and a better approach already exists in [`tidyr::expand_grid()`](https://tidyr.tidyverse.org/reference/expand_grid.html).

-   [`update_list()`](https://purrr.tidyverse.org/reference/update_list.html), [`rerun()`](https://purrr.tidyverse.org/reference/rerun.html), and the use of tidyselect with [`map_at()`](https://purrr.tidyverse.org/reference/map_if.html) and friends have been deprecated because we no longer believe that non-standard evaluation is a good fit for purrr.

-   The `lift_*` family of functions has been deprecated because they rely on a style of function manipulation that is uncommon in R.

-   [`prepend()`](https://purrr.tidyverse.org/reference/prepend.html), [`rdunif()`](https://purrr.tidyverse.org/reference/rdunif.html), [`rbernoulli()`](https://purrr.tidyverse.org/reference/rbernoulli.html), [`when()`](https://purrr.tidyverse.org/reference/when.html), and [`list_along()`](https://purrr.tidyverse.org/reference/along.html) have all been deprecated because they don't align with the core purpose of purrr.

-   `splice()` was deprecated because we no longer believe that automatic splicing makes for good UI and there are other ways to achieve the same result.

Consult the documentation for the alternatives that we now recommend.

Deprecation means that the functions will continue to work, you'll get warned once every 8 hours if you use them. In several years time, we'll release an update which causes the warnings to occur on every time you use them, and a few years after that they'll transformed to throwing errors.

## Documentation

As you've seen in the code above, we are gradually moving to the base pipe (`|>`) instead of magrittr's pipe (`|>`) and R's anonymous function short hand (`\(x) x + 1`) instead of formula syntax (`~ .x + 1`). We believe that it's better to use the new base equivalents because they work everywhere: the base pipe doesn't requite that you load magrittr and the new function shorthand works everywhere, not just in purrr functions. Additionally, being able to specify the argument name for the anonymous function can often lead to clearer code.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='c'># Previously we wrote</span></span>
<span><span class='m'>1</span><span class='o'>:</span><span class='m'>10</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span></span>
<span>  <span class='nf'><a href='https://purrr.tidyverse.org/reference/map.html'>map</a></span><span class='o'>(</span><span class='o'>~</span> <span class='nf'><a href='https://rdrr.io/r/stats/Normal.html'>rnorm</a></span><span class='o'>(</span><span class='m'>10</span>, <span class='nv'>.x</span><span class='o'>)</span><span class='o'>)</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span></span>
<span>  <span class='nf'><a href='https://purrr.tidyverse.org/reference/map.html'>map_dbl</a></span><span class='o'>(</span><span class='nv'>mean</span><span class='o'>)</span></span>
<span><span class='c'>#&gt;  [1] 1.254891 2.431736 3.090187 3.756923 5.048522 6.120181 7.079650 7.713926</span></span>
<span><span class='c'>#&gt;  [9] 8.846344 9.834186</span></span><span></span>
<span><span class='c'># Now we recommend</span></span>
<span><span class='m'>1</span><span class='o'>:</span><span class='m'>10</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://purrr.tidyverse.org/reference/map.html'>map</a></span><span class='o'>(</span>\<span class='o'>(</span><span class='nv'>mu</span><span class='o'>)</span> <span class='nf'><a href='https://rdrr.io/r/stats/Normal.html'>rnorm</a></span><span class='o'>(</span><span class='m'>10</span>, <span class='nv'>mu</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://purrr.tidyverse.org/reference/map.html'>map_dbl</a></span><span class='o'>(</span><span class='nv'>mean</span><span class='o'>)</span> </span>
<span><span class='c'>#&gt;  [1]  1.501113  2.122597  3.219413  3.779042  5.054406  6.295067  7.270990</span></span>
<span><span class='c'>#&gt;  [8]  7.885040  8.912869 10.319867</span></span></code></pre>

</div>

Note, that due to the [tidyverse R dependency policy](https://www.tidyverse.org/blog/2019/04/r-version-support/), purrr works in R 3.5, 3.6, 4.0, 4.1, and 4.2, but the base pipe and anonymous function syntax are only available in R 4.0 and later. To allow purrr to continue to pass `R CMD check`, the examples are automatically disabled in older versions of R.

## Mapping

The map functions have received a major overhaul with three big new features:

-   Progress bar.
-   Better errors.
-   New [`map_vec()`](https://purrr.tidyverse.org/reference/map.html).

These are described in the following sections.

### Progress bars

The map family of function can now produce a progress bar. This is very useful for long running jobs:

<div class="highlight">

<img src="figs//progress.svg" width="700px" style="display: block; margin: auto;" />

</div>

(For interactive use, the progress bar uses some simple heuristics so that it doesn't show up for very simple jobs.)

In most cases, we expect that `.progress = TRUE` will give you a decent progress bar. But if you're wrapping the [`map()`](https://purrr.tidyverse.org/reference/map.html) in a function, you might want to set it to a string that 's used to identify the progress bar:

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
<span><span class='c'>#&gt; <span style='color: #BBBB00;'>!</span> Error!</span></span></code></pre>

</div>

We hope that this makes your debugging life just a little bit easier! (Don't forget about [`safely()`](https://purrr.tidyverse.org/reference/safely.html) and [`possibly()`](https://purrr.tidyverse.org/reference/possibly.html) if you expect failures and want to either ignore or capture them.)

We have also generally reviewed the error messages throughout purrr in order to make them more actionable. If you hit a confusing error message, please let us know!

### New `map_vec()`

We've added [`map_vec()`](https://purrr.tidyverse.org/reference/map.html) (along with [`map2_vec()`](https://purrr.tidyverse.org/reference/map2.html), and [`pmap_vec()`](https://purrr.tidyverse.org/reference/pmap.html)) to handle more types of vector. [`map_vec()`](https://purrr.tidyverse.org/reference/map.html) extend [`map_lgl()`](https://purrr.tidyverse.org/reference/map.html), [`map_int()`](https://purrr.tidyverse.org/reference/map.html), [`map_dbl()`](https://purrr.tidyverse.org/reference/map.html), and [`map_chr()`](https://purrr.tidyverse.org/reference/map.html) to make it easier to work with dates, factors, date-times and more:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='m'>1</span><span class='o'>:</span><span class='m'>3</span> <span class='o'>|&gt;</span> <span class='nf'><a href='https://purrr.tidyverse.org/reference/map.html'>map_vec</a></span><span class='o'>(</span>\<span class='o'>(</span><span class='nv'>i</span><span class='o'>)</span> <span class='nf'><a href='https://rdrr.io/r/base/factor.html'>factor</a></span><span class='o'>(</span><span class='nv'>letters</span><span class='o'>[</span><span class='nv'>i</span><span class='o'>]</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; [1] a b c</span></span>
<span><span class='c'>#&gt; Levels: a b c</span></span><span><span class='m'>1</span><span class='o'>:</span><span class='m'>3</span> <span class='o'>|&gt;</span> <span class='nf'><a href='https://purrr.tidyverse.org/reference/map.html'>map_vec</a></span><span class='o'>(</span>\<span class='o'>(</span><span class='nv'>i</span><span class='o'>)</span> <span class='nf'><a href='https://rdrr.io/r/base/factor.html'>factor</a></span><span class='o'>(</span><span class='nv'>letters</span><span class='o'>[</span><span class='nv'>i</span><span class='o'>]</span>, levels <span class='o'>=</span> <span class='nv'>letters</span><span class='o'>[</span><span class='m'>4</span><span class='o'>:</span><span class='m'>1</span><span class='o'>]</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; [1] a b c</span></span>
<span><span class='c'>#&gt; Levels: d c b a</span></span><span></span>
<span><span class='m'>1</span><span class='o'>:</span><span class='m'>3</span> <span class='o'>|&gt;</span> <span class='nf'><a href='https://purrr.tidyverse.org/reference/map.html'>map_vec</a></span><span class='o'>(</span>\<span class='o'>(</span><span class='nv'>i</span><span class='o'>)</span> <span class='nf'><a href='https://rdrr.io/r/base/as.Date.html'>as.Date</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/ISOdatetime.html'>ISOdate</a></span><span class='o'>(</span><span class='nv'>i</span> <span class='o'>+</span> <span class='m'>2022</span>, <span class='m'>10</span>, <span class='m'>5</span><span class='o'>)</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; [1] "2023-10-05" "2024-10-05" "2025-10-05"</span></span><span><span class='m'>1</span><span class='o'>:</span><span class='m'>3</span> <span class='o'>|&gt;</span> <span class='nf'><a href='https://purrr.tidyverse.org/reference/map.html'>map_vec</a></span><span class='o'>(</span>\<span class='o'>(</span><span class='nv'>i</span><span class='o'>)</span> <span class='nf'><a href='https://rdrr.io/r/base/ISOdatetime.html'>ISOdate</a></span><span class='o'>(</span><span class='nv'>i</span> <span class='o'>+</span> <span class='m'>2022</span>, <span class='m'>10</span>, <span class='m'>5</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; [1] "2023-10-05 12:00:00 GMT" "2024-10-05 12:00:00 GMT"</span></span>
<span><span class='c'>#&gt; [3] "2025-10-05 12:00:00 GMT"</span></span></code></pre>

</div>

[`map_vec()`](https://purrr.tidyverse.org/reference/map.html) exists somewhat in the middle of base R's [`sapply()`](https://rdrr.io/r/base/lapply.html) and [`vapply()`](https://rdrr.io/r/base/lapply.html). Unlike [`sapply()`](https://rdrr.io/r/base/lapply.html) it will always return a simpler vector, erroring if there's no common type.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span><span class='s'>"a"</span>, <span class='m'>1</span><span class='o'>)</span> <span class='o'>|&gt;</span> <span class='nf'><a href='https://purrr.tidyverse.org/reference/map.html'>map_vec</a></span><span class='o'>(</span><span class='nv'>identity</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #BBBB00; font-weight: bold;'>Error</span><span style='font-weight: bold;'> in `map_vec()`:</span></span></span>
<span><span class='c'>#&gt; <span style='color: #BBBB00;'>!</span> Can't combine `&lt;list&gt;[[1]]` &lt;character&gt; and `&lt;list&gt;[[2]]` &lt;double&gt;.</span></span></code></pre>

</div>

If you want to require a certain type of output, supply `.ptype`, making [`map_vec()`](https://purrr.tidyverse.org/reference/map.html) behaviour more like [`vapply()`](https://rdrr.io/r/base/lapply.html) (but supporting more types). `ptype` is short for prototype, and should be a vector that exemplifies the type of output you expect.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>x</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span><span class='s'>"a"</span>, <span class='s'>"b"</span><span class='o'>)</span> </span>
<span><span class='nv'>x</span> <span class='o'>|&gt;</span> <span class='nf'><a href='https://purrr.tidyverse.org/reference/map.html'>map_vec</a></span><span class='o'>(</span><span class='nv'>identity</span>, .ptype <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/character.html'>character</a></span><span class='o'>(</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; [1] "a" "b"</span></span><span></span>
<span><span class='c'># map_vec() will error if the result isn't compatible with ptye</span></span>
<span><span class='nv'>x</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span><span class='m'>1</span>, <span class='m'>2</span><span class='o'>)</span> </span>
<span><span class='nv'>x</span> <span class='o'>|&gt;</span> <span class='nf'><a href='https://purrr.tidyverse.org/reference/map.html'>map_vec</a></span><span class='o'>(</span><span class='nv'>identity</span>, .ptype <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/character.html'>character</a></span><span class='o'>(</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #BBBB00; font-weight: bold;'>Error</span><span style='font-weight: bold;'> in `map_vec()`:</span></span></span>
<span><span class='c'>#&gt; <span style='color: #BBBB00;'>!</span> Can't convert `&lt;list&gt;[[1]]` &lt;double&gt; to &lt;character&gt;.</span></span></code></pre>

</div>

We don't expect you to know or memorise the [rules that vctrs uses for coercion](https://vctrs.r-lib.org/reference/faq-compatibility-types.html) our hope is that as we slowly ensure that every tidyverse function follows the same rules that these will be become second nature.

## `keep_at()` and `discard_at()`

purrr has gained a new pair of functions [`keep_at()`](https://purrr.tidyverse.org/reference/keep_at.html) and [`discard_at()`](https://purrr.tidyverse.org/reference/keep_at.html): they work similarly to [`keep()`](https://purrr.tidyverse.org/reference/keep.html) and [`discard()`](https://purrr.tidyverse.org/reference/keep.html) but operate on names rather than values:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>x</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span>a <span class='o'>=</span> <span class='m'>1</span>, b <span class='o'>=</span> <span class='m'>2</span>, c <span class='o'>=</span> <span class='m'>3</span>, D <span class='o'>=</span> <span class='m'>4</span>, E <span class='o'>=</span> <span class='m'>5</span><span class='o'>)</span></span>
<span></span>
<span><span class='nv'>x</span> <span class='o'>|&gt;</span> </span>
<span>  <span class='nf'><a href='https://purrr.tidyverse.org/reference/keep_at.html'>keep_at</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"a"</span>, <span class='s'>"b"</span>, <span class='s'>"c"</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>|&gt;</span> </span>
<span>  <span class='nf'><a href='https://rdrr.io/r/utils/str.html'>str</a></span><span class='o'>(</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; List of 3</span></span>
<span><span class='c'>#&gt;  $ a: num 1</span></span>
<span><span class='c'>#&gt;  $ b: num 2</span></span>
<span><span class='c'>#&gt;  $ c: num 3</span></span><span></span>
<span><span class='nv'>x</span> <span class='o'>|&gt;</span> </span>
<span>  <span class='nf'><a href='https://purrr.tidyverse.org/reference/keep_at.html'>discard_at</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"a"</span>, <span class='s'>"b"</span>, <span class='s'>"c"</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>|&gt;</span> </span>
<span>  <span class='nf'><a href='https://rdrr.io/r/utils/str.html'>str</a></span><span class='o'>(</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; List of 2</span></span>
<span><span class='c'>#&gt;  $ D: num 4</span></span>
<span><span class='c'>#&gt;  $ E: num 5</span></span></code></pre>

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
<span><span class='c'>#&gt; [1] 3</span></span></code></pre>

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
<span><span class='c'>#&gt;  $ E: num 5</span></span></code></pre>

</div>

This should mostly make up for the fact they can no longer take tidyselect specifications via `vars()`.

## Flattening and simplification

We've revised the functions related the flattening and simplification of lists. These were inconsistent across the tidyverse and caused us a lot of confusion internally because folks used the same words to mean different things. We've also given these functions a common prefix to make it more clear that they all operate on lists. Additionally, [`flatten_dfr()`](https://purrr.tidyverse.org/reference/flatten.html) had some particularly puzzling edge cases when the inputs would be flattened into columns, rather than rows.

-   `flatten()` has been superseded by [`list_flatten()`](https://purrr.tidyverse.org/reference/list_flatten.html).
-   `flatten_lgl()`, `flatten_int()`, `flatten_dbl()`, and `flatten_chr()` have been superseded by [`list_c()`](https://purrr.tidyverse.org/reference/list_c.html).
-   [`flatten_dfr()`](https://purrr.tidyverse.org/reference/flatten.html) and [`flatten_dfc()`](https://purrr.tidyverse.org/reference/flatten.html) have been superseded by [`list_rbind()`](https://purrr.tidyverse.org/reference/list_c.html) and [`list_cbind()`](https://purrr.tidyverse.org/reference/list_c.html) respectively.
-   [`map_dfc()`](https://purrr.tidyverse.org/reference/map_dfr.html) and [`map_dfr()`](https://purrr.tidyverse.org/reference/map_dfr.html) (and their `map2` and `pmap` variants) have been superseded in favour of using the appropriate map function along with [`list_rbind()`](https://purrr.tidyverse.org/reference/list_c.html) or [`list_cbind()`](https://purrr.tidyverse.org/reference/list_c.html).
-   [`simplify()`](https://purrr.tidyverse.org/reference/as_vector.html), [`simplify_all()`](https://purrr.tidyverse.org/reference/as_vector.html), and [`as_vector()`](https://purrr.tidyverse.org/reference/as_vector.html) have been superseded in favour of [`list_simplify()`](https://purrr.tidyverse.org/reference/list_simplify.html).
-   [`transpose()`](https://purrr.tidyverse.org/reference/transpose.html) has been superseded in favour of [`list_transpose()`](https://purrr.tidyverse.org/reference/list_transpose.html) (#875). It has built-in simplification.

We realise that these functions are used widely in practice so they are superseded: this means that they are not going away but we no longer recommend them, and they will receive only critical bug fixes.

INSERT SOME TABLE

### Flattening

Firstly, we have [`list_flatten()`](https://purrr.tidyverse.org/reference/list_flatten.html) which removes one layer of hierarchy from a list. In other words, if any of the children of a list are themselves lists, the contents of those lists are inlined into the parent:

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
<span><span class='c'>#&gt;   ..$ : num 5</span></span><span><span class='nv'>x</span> <span class='o'>|&gt;</span> <span class='nf'><a href='https://purrr.tidyverse.org/reference/list_flatten.html'>list_flatten</a></span><span class='o'>(</span><span class='o'>)</span> <span class='o'>|&gt;</span> <span class='nf'><a href='https://rdrr.io/r/utils/str.html'>str</a></span><span class='o'>(</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; List of 4</span></span>
<span><span class='c'>#&gt;  $ : num 1</span></span>
<span><span class='c'>#&gt;  $ : num 2</span></span>
<span><span class='c'>#&gt;  $ :List of 2</span></span>
<span><span class='c'>#&gt;   ..$ : num 3</span></span>
<span><span class='c'>#&gt;   ..$ : num 4</span></span>
<span><span class='c'>#&gt;  $ : num 5</span></span><span><span class='nv'>x</span> <span class='o'>|&gt;</span> <span class='nf'><a href='https://purrr.tidyverse.org/reference/list_flatten.html'>list_flatten</a></span><span class='o'>(</span><span class='o'>)</span> <span class='o'>|&gt;</span> <span class='nf'><a href='https://purrr.tidyverse.org/reference/list_flatten.html'>list_flatten</a></span><span class='o'>(</span><span class='o'>)</span> <span class='o'>|&gt;</span> <span class='nf'><a href='https://rdrr.io/r/utils/str.html'>str</a></span><span class='o'>(</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; List of 5</span></span>
<span><span class='c'>#&gt;  $ : num 1</span></span>
<span><span class='c'>#&gt;  $ : num 2</span></span>
<span><span class='c'>#&gt;  $ : num 3</span></span>
<span><span class='c'>#&gt;  $ : num 4</span></span>
<span><span class='c'>#&gt;  $ : num 5</span></span></code></pre>

</div>

[`list_flatten()`](https://purrr.tidyverse.org/reference/list_flatten.html) always returns a list; once a list is as flat as it can get (i.e. none of its children contain lists), it leaves the input unchanged.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>x</span> <span class='o'>|&gt;</span> <span class='nf'><a href='https://purrr.tidyverse.org/reference/list_flatten.html'>list_flatten</a></span><span class='o'>(</span><span class='o'>)</span> <span class='o'>|&gt;</span> <span class='nf'><a href='https://purrr.tidyverse.org/reference/list_flatten.html'>list_flatten</a></span><span class='o'>(</span><span class='o'>)</span> <span class='o'>|&gt;</span> <span class='nf'><a href='https://purrr.tidyverse.org/reference/list_flatten.html'>list_flatten</a></span><span class='o'>(</span><span class='o'>)</span> <span class='o'>|&gt;</span> <span class='nf'><a href='https://rdrr.io/r/utils/str.html'>str</a></span><span class='o'>(</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; List of 5</span></span>
<span><span class='c'>#&gt;  $ : num 1</span></span>
<span><span class='c'>#&gt;  $ : num 2</span></span>
<span><span class='c'>#&gt;  $ : num 3</span></span>
<span><span class='c'>#&gt;  $ : num 4</span></span>
<span><span class='c'>#&gt;  $ : num 5</span></span></code></pre>

</div>

### Simplification

[`list_simplify()`](https://purrr.tidyverse.org/reference/list_simplify.html) maintains the length, but produces a simpler type:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span><span class='m'>1</span>, <span class='m'>2</span>, <span class='m'>3</span><span class='o'>)</span> <span class='o'>|&gt;</span> <span class='nf'><a href='https://purrr.tidyverse.org/reference/list_simplify.html'>list_simplify</a></span><span class='o'>(</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; [1] 1 2 3</span></span><span><span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span><span class='s'>"a"</span>, <span class='s'>"b"</span>, <span class='s'>"c"</span><span class='o'>)</span> <span class='o'>|&gt;</span> <span class='nf'><a href='https://purrr.tidyverse.org/reference/list_simplify.html'>list_simplify</a></span><span class='o'>(</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; [1] "a" "b" "c"</span></span></code></pre>

</div>

Because the length must stay the same, it will only succeed if every element has length 1:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://purrr.tidyverse.org/reference/list_simplify.html'>list_simplify</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span><span class='m'>1</span>, <span class='m'>2</span>, <span class='m'>3</span><span class='o'>:</span><span class='m'>4</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #BBBB00; font-weight: bold;'>Error</span><span style='font-weight: bold;'> in `list_simplify()`:</span></span></span>
<span><span class='c'>#&gt; <span style='color: #BBBB00;'>!</span> `x[[3]]` must have size 1, not size 2.</span></span><span><span class='nf'><a href='https://purrr.tidyverse.org/reference/list_simplify.html'>list_simplify</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span><span class='m'>1</span>, <span class='m'>2</span>, <span class='nf'><a href='https://rdrr.io/r/base/integer.html'>integer</a></span><span class='o'>(</span><span class='o'>)</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #BBBB00; font-weight: bold;'>Error</span><span style='font-weight: bold;'> in `list_simplify()`:</span></span></span>
<span><span class='c'>#&gt; <span style='color: #BBBB00;'>!</span> `x[[3]]` must have size 1, not size 0.</span></span></code></pre>

</div>

Because the result must be a simpler vector, all the components must be compatible:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://purrr.tidyverse.org/reference/list_simplify.html'>list_simplify</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span><span class='m'>1</span>, <span class='m'>2</span>, <span class='s'>"a"</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #BBBB00; font-weight: bold;'>Error</span><span style='font-weight: bold;'> in `list_simplify()`:</span></span></span>
<span><span class='c'>#&gt; <span style='color: #BBBB00;'>!</span> Can't combine `&lt;list&gt;[[1]]` &lt;double&gt; and `&lt;list&gt;[[3]]` &lt;character&gt;.</span></span></code></pre>

</div>

If you need to simplify if possible, set `strict = FALSE`:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://purrr.tidyverse.org/reference/list_simplify.html'>list_simplify</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span><span class='m'>1</span>, <span class='m'>2</span>, <span class='s'>"a"</span><span class='o'>)</span>, strict <span class='o'>=</span> <span class='kc'>FALSE</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; [[1]]</span></span>
<span><span class='c'>#&gt; [1] 1</span></span>
<span><span class='c'>#&gt; </span></span>
<span><span class='c'>#&gt; [[2]]</span></span>
<span><span class='c'>#&gt; [1] 2</span></span>
<span><span class='c'>#&gt; </span></span>
<span><span class='c'>#&gt; [[3]]</span></span>
<span><span class='c'>#&gt; [1] "a"</span></span></code></pre>

</div>

If you want to be specific the type you want, [`list_simplify()`](https://purrr.tidyverse.org/reference/list_simplify.html) can take the same prototype argument as [`map_vec()`](https://purrr.tidyverse.org/reference/map.html):

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span><span class='m'>1</span>, <span class='m'>2</span>, <span class='m'>3</span><span class='o'>)</span> <span class='o'>|&gt;</span> <span class='nf'><a href='https://purrr.tidyverse.org/reference/list_simplify.html'>list_simplify</a></span><span class='o'>(</span>ptype <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/integer.html'>integer</a></span><span class='o'>(</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; [1] 1 2 3</span></span><span><span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span><span class='m'>1</span>, <span class='m'>2</span>, <span class='m'>3</span><span class='o'>)</span> <span class='o'>|&gt;</span> <span class='nf'><a href='https://purrr.tidyverse.org/reference/list_simplify.html'>list_simplify</a></span><span class='o'>(</span>ptype <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/factor.html'>factor</a></span><span class='o'>(</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #BBBB00; font-weight: bold;'>Error</span><span style='font-weight: bold;'> in `list_simplify()`:</span></span></span>
<span><span class='c'>#&gt; <span style='color: #BBBB00;'>!</span> Can't convert `&lt;list&gt;[[1]]` &lt;double&gt; to &lt;factor&lt;&gt;&gt;.</span></span></code></pre>

</div>

### Concatenation

If you don't want to fix either the type or the length of the list, you might want to concatenate all the pieces together. There are three functions depending on whether you want to concatenate a vector, or a data frame by rows or by columns. This is similar to using `do.call(c)` or `do.call(rbind)` but uses vctrs coercion rules

So unlike `list_simplfy()` the elements can be different lengths:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span><span class='m'>1</span>, <span class='m'>2</span>, <span class='m'>3</span><span class='o'>)</span> <span class='o'>|&gt;</span> <span class='nf'><a href='https://purrr.tidyverse.org/reference/list_c.html'>list_c</a></span><span class='o'>(</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; [1] 1 2 3</span></span><span><span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span><span class='m'>1</span>, <span class='m'>2</span>, <span class='m'>3</span><span class='o'>:</span><span class='m'>4</span>, <span class='nf'><a href='https://rdrr.io/r/base/integer.html'>integer</a></span><span class='o'>(</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>|&gt;</span> <span class='nf'><a href='https://purrr.tidyverse.org/reference/list_c.html'>list_c</a></span><span class='o'>(</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; [1] 1 2 3 4</span></span></code></pre>

</div>

But they still must have compatible types:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span><span class='m'>1</span>, <span class='m'>2</span>, <span class='s'>"a"</span><span class='o'>)</span> <span class='o'>|&gt;</span> <span class='nf'><a href='https://purrr.tidyverse.org/reference/list_c.html'>list_c</a></span><span class='o'>(</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #BBBB00; font-weight: bold;'>Error</span><span style='font-weight: bold;'> in `list_c()`:</span></span></span>
<span><span class='c'>#&gt; <span style='color: #BBBB00;'>!</span> Can't combine `x[[1]]` &lt;double&gt; and `x[[3]]` &lt;character&gt;.</span></span></code></pre>

</div>

This makes it clear that [`map_dfr()`](https://purrr.tidyverse.org/reference/map_dfr.html) and [`map_dfc()`](https://purrr.tidyverse.org/reference/map_dfr.html) don't really belong to the map family because they don't maintain a 1-to-1 mapping between input and output: there's reliable no way to associate a row in the output with an element in an input. For this reason, [`map_dfr()`](https://purrr.tidyverse.org/reference/map_dfr.html) and [`map_dfc()`](https://purrr.tidyverse.org/reference/map_dfr.html) (and the `map2` and `pmap`) variants are superseded and we recommend switching to an explicit call to [`list_rbind()`](https://purrr.tidyverse.org/reference/list_c.html) or [`list_cbind()`](https://purrr.tidyverse.org/reference/list_c.html) instead:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>paths</span> <span class='o'>|&gt;</span> <span class='nf'><a href='https://purrr.tidyverse.org/reference/map_dfr.html'>map_dfr</a></span><span class='o'>(</span><span class='nv'>read_csv</span>, .id <span class='o'>=</span> <span class='s'>"path"</span><span class='o'>)</span></span>
<span><span class='c'># now</span></span>
<span><span class='nv'>paths</span> <span class='o'>|&gt;</span> </span>
<span>  <span class='nf'><a href='https://purrr.tidyverse.org/reference/map.html'>map</a></span><span class='o'>(</span><span class='nv'>read_csv</span><span class='o'>)</span> <span class='o'>|&gt;</span> </span>
<span>  <span class='nf'><a href='https://purrr.tidyverse.org/reference/list_c.html'>list_rbind</a></span><span class='o'>(</span>names_to <span class='o'>=</span> <span class='s'>"path"</span><span class='o'>)</span></span></code></pre>

</div>

This new behaviour has some follow on consequences to [`accumulate()`](https://purrr.tidyverse.org/reference/accumulate.html) and [`accumulate2()`](https://purrr.tidyverse.org/reference/accumulate.html) which previously had an idiosyncratic approach to simplification. Also added a new [`list_transpose()`](https://purrr.tidyverse.org/reference/list_transpose.html) which works similarly to [`transpose()`](https://purrr.tidyverse.org/reference/transpose.html) but again has consistent simplification mechanism.

### `list_update()` functions

There's one other functions not directly related to flattening and friends, but shares the new `list_` prefix so are worth mentioning here: [`list_update()`](https://purrr.tidyverse.org/reference/list_update.html)  
New [`list_update()`](https://purrr.tidyverse.org/reference/list_update.html) is similar to [`list_modify()`](https://purrr.tidyverse.org/reference/list_update.html) but it doesn't work recursively (this is a mildly confusing feature of [`list_modify()`](https://purrr.tidyverse.org/reference/list_update.html) that many folks didn't know about)

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span>x <span class='o'>=</span> <span class='m'>1</span><span class='o'>)</span> <span class='o'>|&gt;</span> </span>
<span>  <span class='nf'><a href='https://purrr.tidyverse.org/reference/list_update.html'>list_update</a></span><span class='o'>(</span>y <span class='o'>=</span> <span class='m'>2</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://rdrr.io/r/utils/str.html'>str</a></span><span class='o'>(</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; List of 2</span></span>
<span><span class='c'>#&gt;  $ x: num 1</span></span>
<span><span class='c'>#&gt;  $ y: num 2</span></span></code></pre>

</div>

Here's a quick comparison of [`list_update()`](https://purrr.tidyverse.org/reference/list_update.html) vs [`list_modify()`](https://purrr.tidyverse.org/reference/list_update.html): when there's a list on the left-hand side and the right-hand side, [`list_modify()`](https://purrr.tidyverse.org/reference/list_update.html) will recurse down. This is sometimes useful if you want to change a value deep inside a list.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span>x <span class='o'>=</span> <span class='m'>1</span>, y <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span>a <span class='o'>=</span> <span class='m'>1</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>|&gt;</span> </span>
<span>  <span class='nf'><a href='https://purrr.tidyverse.org/reference/list_update.html'>list_update</a></span><span class='o'>(</span>y <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span>b <span class='o'>=</span> <span class='m'>2</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>|&gt;</span> </span>
<span>  <span class='nf'><a href='https://rdrr.io/r/utils/str.html'>str</a></span><span class='o'>(</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; List of 2</span></span>
<span><span class='c'>#&gt;  $ x: num 1</span></span>
<span><span class='c'>#&gt;  $ y:List of 1</span></span>
<span><span class='c'>#&gt;   ..$ b: num 2</span></span><span></span>
<span><span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span>x <span class='o'>=</span> <span class='m'>1</span>, y <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span>a <span class='o'>=</span> <span class='m'>1</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>|&gt;</span> </span>
<span>  <span class='nf'><a href='https://purrr.tidyverse.org/reference/list_update.html'>list_modify</a></span><span class='o'>(</span>y <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span>b <span class='o'>=</span> <span class='m'>1</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>|&gt;</span> </span>
<span>  <span class='nf'><a href='https://rdrr.io/r/utils/str.html'>str</a></span><span class='o'>(</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; List of 2</span></span>
<span><span class='c'>#&gt;  $ x: num 1</span></span>
<span><span class='c'>#&gt;  $ y:List of 2</span></span>
<span><span class='c'>#&gt;   ..$ a: num 1</span></span>
<span><span class='c'>#&gt;   ..$ b: num 1</span></span></code></pre>

</div>

In purrr 1.0.0, [`list_modify()`](https://purrr.tidyverse.org/reference/list_update.html) also gains the ability to control

## Acknowledgements

