---
output: hugodown::hugo_document

slug: stringr-1-5-0
title: stringr 1.5.0
date: 2022-11-05
author: Hadley Wickham
description: >
    It's been a long three years but a new version of stringr is now on
    CRAN! This release includes a bunch of small but useful new functions
    and some increased consistency with the rest of the tidyverse.

photo:
  url: https://unsplash.com/photos/XGqS569rdgk
  author: Amie Bell

# one of: "deep-dive", "learn", "package", "programming", "roundup", or "other"
categories: [package] 
tags: [stringr, tidyverse]
rmd_hash: 5ed2b64d6a2c75c3

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
* [ ] Update release link
-->

We're chuffed to announce the release of [stringr](https://stringr.tidyverse.org) 1.5.0. stringr provides a cohesive set of functions designed to make working with strings as easy as possible.

You can install it from CRAN with:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://rdrr.io/r/utils/install.packages.html'>install.packages</a></span><span class='o'>(</span><span class='s'>"stringr"</span><span class='o'>)</span></span></code></pre>

</div>

This blog post will give you an overview of the biggest changes (you can get a detailed list of all changes from the [release notes](https://stringr.tidyverse.org/news/index.html)). Firstly, we need to update you on some (small) breaking changes we've made to make stringr more consistent with the rest of the tidyverse. Then, we'll give a quick overview of improvements to documentation and stringr's new license. Lastly, we'll finish off by diving into a few of the many small, but useful, functions that we've accumulated in the three and half years since the last release.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://stringr.tidyverse.org'>stringr</a></span><span class='o'>)</span></span></code></pre>

</div>

## Breaking changes

Lets start with the important stuff: the breaking changes. We've tried to keep these small and we don't believe they'll affect much code in the wild (they only affected \~20 of the \~1,600 packages that use stringr). But we're believe they're important to make as a consistent set of rules makes the tidyverse as a whole more predictable and easier to learn.

### Recycling rules

stringr functions now consistently implement the tidyverse recycling rules[^1], which are stricter than the previous rules in two ways. Firstly, we no longer recycle shorter vectors that are an integer multiple of longer vectors:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://stringr.tidyverse.org/reference/str_detect.html'>str_detect</a></span><span class='o'>(</span><span class='nv'>letters</span>, <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"x"</span>, <span class='s'>"y"</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #BBBB00; font-weight: bold;'>Error</span><span style='font-weight: bold;'> in `str_detect()`:</span></span></span>
<span><span class='c'>#&gt; <span style='color: #BBBB00;'>!</span> Can't recycle `string` (size 26) to match `pattern` (size 2).</span></span>
<span></span></code></pre>

</div>

Secondly, a 0-length vector no longer implies a 0-length output. Instead it's recycled using the usual rules:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://stringr.tidyverse.org/reference/str_detect.html'>str_detect</a></span><span class='o'>(</span><span class='nv'>letters</span>, <span class='nf'><a href='https://rdrr.io/r/base/character.html'>character</a></span><span class='o'>(</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #BBBB00; font-weight: bold;'>Error</span><span style='font-weight: bold;'> in `str_detect()`:</span></span></span>
<span><span class='c'>#&gt; <span style='color: #BBBB00;'>!</span> Can't recycle `string` (size 26) to match `pattern` (size 0).</span></span>
<span></span><span><span class='nf'><a href='https://stringr.tidyverse.org/reference/str_detect.html'>str_detect</a></span><span class='o'>(</span><span class='s'>"x"</span>, <span class='nf'><a href='https://rdrr.io/r/base/character.html'>character</a></span><span class='o'>(</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; logical(0)</span></span>
<span></span></code></pre>

</div>

Neither of these situations occurs very commonly in data analysis, so this change primarily brings consistency with the rest of the tidyverse without affecting much existing code.

Finally, stringr functions are generally a little stricter because we require the inputs to be vectors of some type. Again, this is unlikely to affect your data analysis code and will result in a clearer error if you accidentally pass in something weird:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://stringr.tidyverse.org/reference/str_detect.html'>str_detect</a></span><span class='o'>(</span><span class='nv'>mean</span>, <span class='s'>"x"</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #BBBB00; font-weight: bold;'>Error</span><span style='font-weight: bold;'> in `str_detect()`:</span></span></span>
<span><span class='c'>#&gt; <span style='color: #BBBB00;'>!</span> `string` must be a vector, not a function.</span></span>
<span></span></code></pre>

</div>

### Empty patterns

In many stringr functions, `""` will match or split on every character. This is motivated by base R's [`strsplit()`](https://rdrr.io/r/base/strsplit.html):

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://rdrr.io/r/base/strsplit.html'>strsplit</a></span><span class='o'>(</span><span class='s'>"abc"</span>, <span class='s'>""</span><span class='o'>)</span><span class='o'>[[</span><span class='m'>1</span><span class='o'>]</span><span class='o'>]</span></span>
<span><span class='c'>#&gt; [1] "a" "b" "c"</span></span>
<span></span><span><span class='nf'><a href='https://stringr.tidyverse.org/reference/str_split.html'>str_split</a></span><span class='o'>(</span><span class='s'>"abc"</span>, <span class='s'>""</span><span class='o'>)</span><span class='o'>[[</span><span class='m'>1</span><span class='o'>]</span><span class='o'>]</span></span>
<span><span class='c'>#&gt; [1] "a" "b" "c"</span></span>
<span></span></code></pre>

</div>

When creating stringr (over 13 years ago!), I took this idea and ran with it, implementing similar support in every function where it might possibly work. But I missed an important problem with [`str_detect()`](https://stringr.tidyverse.org/reference/str_detect.html).

What should `str_detect(X, "")` return? You can argue two ways:

-   To be consistent with [`str_split()`](https://stringr.tidyverse.org/reference/str_split.html), it should return `TRUE` whenever there are characters to match, i.e. `x != ""`.
-   It's common to build up a set of possible matches by doing `str_flatten(matches, "|")`. What should this match if `matches` is empty? Ideally it would match nothing implying that `str_detect(x, "")` should be equivalent to `x == ""`.

This inconsistency potentially leads to some subtle bugs, so use of `""` in [`str_detect()`](https://stringr.tidyverse.org/reference/str_detect.html) (and a few other related functions) is now an error:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://stringr.tidyverse.org/reference/str_detect.html'>str_detect</a></span><span class='o'>(</span><span class='nv'>letters</span>, <span class='s'>""</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #BBBB00; font-weight: bold;'>Error</span><span style='font-weight: bold;'> in `str_detect()`:</span></span></span>
<span><span class='c'>#&gt; <span style='color: #BBBB00;'>!</span> `pattern` can't be the empty string (`""`).</span></span>
<span></span></code></pre>

</div>

## Documentation and licensing

Now that we've got the breaking changes out of the way we can focus on the new stuff 😃. Most importantly, there's a new vignette that provides some advice if you're transition from (or to) base R's string functions: [`vignette("from-base", package = "stringr")`](https://stringr.tidyverse.org/articles/from-base.html). It was written by [Sara Stoudt](https://sastoudt.github.io) during the 2019 Tidyverse developer day, and has finally made it to the released version!

We've also spent a bunch of time reviewing the documentation, particularly the topic titles and descriptions. They're now more informative and less duplicative, hopefully make it easier to find the function that you're looking for. See the complete list of functions in the [reference index](https://stringr.tidyverse.org/reference/index.html).

Finally, stringr is now officially [re-licensed as MIT](https://www.tidyverse.org/blog/2021/12/relicensing-packages/).

## New features

The biggest improvement is to [`str_view()`](https://stringr.tidyverse.org/reference/str_view.html) which has gained a bunch of new features, including using the [cli](https://cli.r-lib.org/) package so it can work in more places. We also have a grab bag of new functions that fill in small functionality gaps.

### `str_view()`

[`str_view()`](https://stringr.tidyverse.org/reference/str_view.html) uses ANSI colouring rather than an HTML widget. This means it works in more places and requires fewer dependencies. [`str_view()`](https://stringr.tidyverse.org/reference/str_view.html) now:

-   Displays strings with special characters:

    <div class="highlight">

    <pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>x</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"\\"</span>, <span class='s'>"\"\nabcdef\n\""</span><span class='o'>)</span></span>
    <span><span class='nv'>x</span></span>
    <span><span class='c'>#&gt; [1] "\\"             "\"\nabcdef\n\""</span></span>
    <span></span><span></span>
    <span><span class='nf'><a href='https://stringr.tidyverse.org/reference/str_view.html'>str_view</a></span><span class='o'>(</span><span class='nv'>x</span><span class='o'>)</span></span>
    <span><span class='c'>#&gt; <span style='color: #555555;'>[1] │</span> \</span></span>
    <span><span class='c'>#&gt; <span style='color: #555555;'>[2] │</span> "</span></span>
    <span><span class='c'>#&gt;     <span style='color: #555555;'>│</span> abcdef</span></span>
    <span><span class='c'>#&gt;     <span style='color: #555555;'>│</span> "</span></span>
    <span></span></code></pre>

    </div>

-   Highlights unusual whitespace characters:

    <div class="highlight">

    <pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://stringr.tidyverse.org/reference/str_view.html'>str_view</a></span><span class='o'>(</span><span class='s'>"\t"</span><span class='o'>)</span></span>
    <span><span class='c'>#&gt; <span style='color: #555555;'>[1] │</span> <span style='color: #00BBBB;'>&#123;\t&#125;</span></span></span>
    <span></span></code></pre>

    </div>

-   By default, only shows matching strings:

    <div class="highlight">

    <pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://stringr.tidyverse.org/reference/str_view.html'>str_view</a></span><span class='o'>(</span><span class='nv'>fruit</span>, <span class='s'>"(.)\\1"</span><span class='o'>)</span></span>
    <span><span class='c'>#&gt; <span style='color: #555555;'> [1] │</span> a<span style='color: #00BBBB;'>&lt;pp&gt;</span>le</span></span>
    <span><span class='c'>#&gt; <span style='color: #555555;'> [5] │</span> be<span style='color: #00BBBB;'>&lt;ll&gt;</span> pe<span style='color: #00BBBB;'>&lt;pp&gt;</span>er</span></span>
    <span><span class='c'>#&gt; <span style='color: #555555;'> [6] │</span> bilbe<span style='color: #00BBBB;'>&lt;rr&gt;</span>y</span></span>
    <span><span class='c'>#&gt; <span style='color: #555555;'> [7] │</span> blackbe<span style='color: #00BBBB;'>&lt;rr&gt;</span>y</span></span>
    <span><span class='c'>#&gt; <span style='color: #555555;'> [8] │</span> blackcu<span style='color: #00BBBB;'>&lt;rr&gt;</span>ant</span></span>
    <span><span class='c'>#&gt; <span style='color: #555555;'> [9] │</span> bl<span style='color: #00BBBB;'>&lt;oo&gt;</span>d orange</span></span>
    <span><span class='c'>#&gt; <span style='color: #555555;'>[10] │</span> bluebe<span style='color: #00BBBB;'>&lt;rr&gt;</span>y</span></span>
    <span><span class='c'>#&gt; <span style='color: #555555;'>[11] │</span> boysenbe<span style='color: #00BBBB;'>&lt;rr&gt;</span>y</span></span>
    <span><span class='c'>#&gt; <span style='color: #555555;'>[16] │</span> che<span style='color: #00BBBB;'>&lt;rr&gt;</span>y</span></span>
    <span><span class='c'>#&gt; <span style='color: #555555;'>[17] │</span> chili pe<span style='color: #00BBBB;'>&lt;pp&gt;</span>er</span></span>
    <span><span class='c'>#&gt; <span style='color: #555555;'>[19] │</span> cloudbe<span style='color: #00BBBB;'>&lt;rr&gt;</span>y</span></span>
    <span><span class='c'>#&gt; <span style='color: #555555;'>[21] │</span> cranbe<span style='color: #00BBBB;'>&lt;rr&gt;</span>y</span></span>
    <span><span class='c'>#&gt; <span style='color: #555555;'>[23] │</span> cu<span style='color: #00BBBB;'>&lt;rr&gt;</span>ant</span></span>
    <span><span class='c'>#&gt; <span style='color: #555555;'>[28] │</span> e<span style='color: #00BBBB;'>&lt;gg&gt;</span>plant</span></span>
    <span><span class='c'>#&gt; <span style='color: #555555;'>[29] │</span> elderbe<span style='color: #00BBBB;'>&lt;rr&gt;</span>y</span></span>
    <span><span class='c'>#&gt; <span style='color: #555555;'>[32] │</span> goji be<span style='color: #00BBBB;'>&lt;rr&gt;</span>y</span></span>
    <span><span class='c'>#&gt; <span style='color: #555555;'>[33] │</span> g<span style='color: #00BBBB;'>&lt;oo&gt;</span>sebe<span style='color: #00BBBB;'>&lt;rr&gt;</span>y</span></span>
    <span><span class='c'>#&gt; <span style='color: #555555;'>[38] │</span> hucklebe<span style='color: #00BBBB;'>&lt;rr&gt;</span>y</span></span>
    <span><span class='c'>#&gt; <span style='color: #555555;'>[47] │</span> lych<span style='color: #00BBBB;'>&lt;ee&gt;</span></span></span>
    <span><span class='c'>#&gt; <span style='color: #555555;'>[50] │</span> mulbe<span style='color: #00BBBB;'>&lt;rr&gt;</span>y</span></span>
    <span><span class='c'>#&gt; ... and 9 more</span></span>
    <span></span></code></pre>

    </div>

    (This makes [`str_view_all()`](https://stringr.tidyverse.org/reference/str_view.html) redundant and hence deprecated.)

### Comparing strings

There are three new functions related to comparing strings:

-   [`str_equal()`](https://stringr.tidyverse.org/reference/str_equal.html) compares two character vectors using Unicode rules, optionally ignoring case:

    <div class="highlight">

    <pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://stringr.tidyverse.org/reference/str_equal.html'>str_equal</a></span><span class='o'>(</span><span class='s'>"a"</span>, <span class='s'>"A"</span><span class='o'>)</span></span>
    <span><span class='c'>#&gt; [1] FALSE</span></span>
    <span></span><span><span class='nf'><a href='https://stringr.tidyverse.org/reference/str_equal.html'>str_equal</a></span><span class='o'>(</span><span class='s'>"a"</span>, <span class='s'>"A"</span>, ignore_case <span class='o'>=</span> <span class='kc'>TRUE</span><span class='o'>)</span></span>
    <span><span class='c'>#&gt; [1] TRUE</span></span>
    <span></span></code></pre>

    </div>

-   [`str_rank()`](https://stringr.tidyverse.org/reference/str_order.html) completes the set of order/rank/sort functions:

    <div class="highlight">

    <pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://stringr.tidyverse.org/reference/str_order.html'>str_rank</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"a"</span>, <span class='s'>"c"</span>, <span class='s'>"b"</span>, <span class='s'>"b"</span><span class='o'>)</span><span class='o'>)</span></span>
    <span><span class='c'>#&gt; [1] 1 4 2 2</span></span>
    <span></span><span><span class='c'># compare to:</span></span>
    <span><span class='nf'><a href='https://stringr.tidyverse.org/reference/str_order.html'>str_order</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"a"</span>, <span class='s'>"c"</span>, <span class='s'>"b"</span>, <span class='s'>"b"</span><span class='o'>)</span><span class='o'>)</span></span>
    <span><span class='c'>#&gt; [1] 1 3 4 2</span></span>
    <span></span></code></pre>

    </div>

-   [`str_unique()`](https://stringr.tidyverse.org/reference/str_unique.html) returns unique values, optionally ignoring case:

    <div class="highlight">

    <pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://stringr.tidyverse.org/reference/str_unique.html'>str_unique</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"a"</span>, <span class='s'>"a"</span>, <span class='s'>"A"</span><span class='o'>)</span><span class='o'>)</span></span>
    <span><span class='c'>#&gt; [1] "a" "A"</span></span>
    <span></span><span><span class='nf'><a href='https://stringr.tidyverse.org/reference/str_unique.html'>str_unique</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"a"</span>, <span class='s'>"a"</span>, <span class='s'>"A"</span><span class='o'>)</span>, ignore_case <span class='o'>=</span> <span class='kc'>TRUE</span><span class='o'>)</span></span>
    <span><span class='c'>#&gt; [1] "a"</span></span>
    <span></span></code></pre>

    </div>

### Splitting

[`str_split()`](https://stringr.tidyverse.org/reference/str_split.html) gains two useful variants:

-   [`str_split_1()`](https://stringr.tidyverse.org/reference/str_split.html) is tailored for the special case of splitting up a single string. It returns a character vector, not a list, and errors if you try and give it multiple values:

    <div class="highlight">

    <pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://stringr.tidyverse.org/reference/str_split.html'>str_split_1</a></span><span class='o'>(</span><span class='s'>"x-y-z"</span>, <span class='s'>"-"</span><span class='o'>)</span></span>
    <span><span class='c'>#&gt; [1] "x" "y" "z"</span></span>
    <span></span><span><span class='nf'><a href='https://stringr.tidyverse.org/reference/str_split.html'>str_split_1</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"x-y"</span>, <span class='s'>"a-b-c"</span><span class='o'>)</span>, <span class='s'>"-"</span><span class='o'>)</span></span>
    <span><span class='c'>#&gt; <span style='color: #BBBB00; font-weight: bold;'>Error</span><span style='font-weight: bold;'> in `str_split_1()`:</span></span></span>
    <span><span class='c'>#&gt; <span style='color: #BBBB00;'>!</span> `string` must be a single string, not a character vector.</span></span>
    <span></span></code></pre>

    </div>

    It's a shortcut for the common pattern of `unlist(str_split(x, " "))`.

-   [`str_split_i()`](https://stringr.tidyverse.org/reference/str_split.html) extracts a single piece from the split string:

    <div class="highlight">

    <pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>x</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"a-b-c"</span>, <span class='s'>"d-e"</span>, <span class='s'>"f-g-h-i"</span><span class='o'>)</span></span>
    <span><span class='nf'><a href='https://stringr.tidyverse.org/reference/str_split.html'>str_split_i</a></span><span class='o'>(</span><span class='nv'>x</span>, <span class='s'>"-"</span>, <span class='m'>2</span><span class='o'>)</span></span>
    <span><span class='c'>#&gt; [1] "b" "e" "g"</span></span>
    <span></span><span></span>
    <span><span class='nf'><a href='https://stringr.tidyverse.org/reference/str_split.html'>str_split_i</a></span><span class='o'>(</span><span class='nv'>x</span>, <span class='s'>"-"</span>, <span class='m'>4</span><span class='o'>)</span></span>
    <span><span class='c'>#&gt; [1] NA  NA  "i"</span></span>
    <span></span><span></span>
    <span><span class='nf'><a href='https://stringr.tidyverse.org/reference/str_split.html'>str_split_i</a></span><span class='o'>(</span><span class='nv'>x</span>, <span class='s'>"-"</span>, <span class='o'>-</span><span class='m'>1</span><span class='o'>)</span></span>
    <span><span class='c'>#&gt; [1] "c" "e" "i"</span></span>
    <span></span></code></pre>

    </div>

### Miscellaneous

-   [`str_escape()`](https://stringr.tidyverse.org/reference/str_escape.html) escapes regular expression metacharacters, providing an alternative to [`fixed()`](https://stringr.tidyverse.org/reference/modifiers.html) if you want to compose a pattern from user supplied strings:

    <div class="highlight">

    <pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://stringr.tidyverse.org/reference/str_view.html'>str_view</a></span><span class='o'>(</span><span class='s'>"[hello]"</span>, <span class='nf'><a href='https://stringr.tidyverse.org/reference/str_escape.html'>str_escape</a></span><span class='o'>(</span><span class='s'>"[]"</span><span class='o'>)</span><span class='o'>)</span></span></code></pre>

    </div>

-   [`str_extract()`](https://stringr.tidyverse.org/reference/str_extract.html) can now extract a capturing group instead of the complete match:

    <div class="highlight">

    <pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>x</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"Chapter 1"</span>, <span class='s'>"Section 2.3"</span>, <span class='s'>"Chapter 3"</span>, <span class='s'>"Section 4.1.1"</span><span class='o'>)</span></span>
    <span><span class='nf'><a href='https://stringr.tidyverse.org/reference/str_extract.html'>str_extract</a></span><span class='o'>(</span><span class='nv'>x</span>, <span class='s'>"([A-Za-z]+) ([0-9.]+)"</span>, group <span class='o'>=</span> <span class='m'>1</span><span class='o'>)</span></span>
    <span><span class='c'>#&gt; [1] "Chapter" "Section" "Chapter" "Section"</span></span>
    <span></span><span><span class='nf'><a href='https://stringr.tidyverse.org/reference/str_extract.html'>str_extract</a></span><span class='o'>(</span><span class='nv'>x</span>, <span class='s'>"([A-Za-z]+) ([0-9.]+)"</span>, group <span class='o'>=</span> <span class='m'>2</span><span class='o'>)</span></span>
    <span><span class='c'>#&gt; [1] "1"     "2.3"   "3"     "4.1.1"</span></span>
    <span></span></code></pre>

    </div>

-   [`str_flatten()`](https://stringr.tidyverse.org/reference/str_flatten.html) gains a `last` argument which is used to power the new [`str_flatten_comma()`](https://stringr.tidyverse.org/reference/str_flatten.html):

    <div class="highlight">

    <pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://stringr.tidyverse.org/reference/str_flatten.html'>str_flatten_comma</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"cats"</span>, <span class='s'>"dogs"</span>, <span class='s'>"mice"</span><span class='o'>)</span><span class='o'>)</span></span>
    <span><span class='c'>#&gt; [1] "cats, dogs, mice"</span></span>
    <span></span><span><span class='nf'><a href='https://stringr.tidyverse.org/reference/str_flatten.html'>str_flatten_comma</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"cats"</span>, <span class='s'>"dogs"</span>, <span class='s'>"mice"</span><span class='o'>)</span>, last <span class='o'>=</span> <span class='s'>" and "</span><span class='o'>)</span></span>
    <span><span class='c'>#&gt; [1] "cats, dogs and mice"</span></span>
    <span></span><span><span class='nf'><a href='https://stringr.tidyverse.org/reference/str_flatten.html'>str_flatten_comma</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"cats"</span>, <span class='s'>"dogs"</span>, <span class='s'>"mice"</span><span class='o'>)</span>, last <span class='o'>=</span> <span class='s'>", and "</span><span class='o'>)</span></span>
    <span><span class='c'>#&gt; [1] "cats, dogs, and mice"</span></span>
    <span></span><span></span>
    <span><span class='c'># correctly handles the two element case with the Oxford comma</span></span>
    <span><span class='nf'><a href='https://stringr.tidyverse.org/reference/str_flatten.html'>str_flatten_comma</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"cats"</span>, <span class='s'>"dogs"</span><span class='o'>)</span>, last <span class='o'>=</span> <span class='s'>", and "</span><span class='o'>)</span></span>
    <span><span class='c'>#&gt; [1] "cats and dogs"</span></span>
    <span></span></code></pre>

    </div>

-   [`str_like()`](https://stringr.tidyverse.org/reference/str_like.html) works like [`str_detect()`](https://stringr.tidyverse.org/reference/str_detect.html) but uses SQL's LIKE syntax:

    <div class="highlight">

    <pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>fruit</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"apple"</span>, <span class='s'>"banana"</span>, <span class='s'>"pear"</span>, <span class='s'>"pineapple"</span><span class='o'>)</span></span>
    <span><span class='nv'>fruit</span><span class='o'>[</span><span class='nf'><a href='https://stringr.tidyverse.org/reference/str_like.html'>str_like</a></span><span class='o'>(</span><span class='nv'>fruit</span>, <span class='s'>"%apple"</span><span class='o'>)</span><span class='o'>]</span></span>
    <span><span class='c'>#&gt; [1] "apple"     "pineapple"</span></span>
    <span></span><span><span class='nv'>fruit</span><span class='o'>[</span><span class='nf'><a href='https://stringr.tidyverse.org/reference/str_like.html'>str_like</a></span><span class='o'>(</span><span class='nv'>fruit</span>, <span class='s'>"p__r"</span><span class='o'>)</span><span class='o'>]</span></span>
    <span><span class='c'>#&gt; [1] "pear"</span></span>
    <span></span></code></pre>

    </div>

## Acknowledgements

A big thanks to all 114 folks who contributed to this release through pull requests and issues! [@aaronrudkin](https://github.com/aaronrudkin), [@adisarid](https://github.com/adisarid), [@AleSR13](https://github.com/AleSR13), [@anfederico](https://github.com/anfederico), [@AR1337](https://github.com/AR1337), [@arisp99](https://github.com/arisp99), [@avila](https://github.com/avila), [@balthasars](https://github.com/balthasars), [@batpigandme](https://github.com/batpigandme), [@bbarros50](https://github.com/bbarros50), [@bbo2adwuff](https://github.com/bbo2adwuff), [@bensenmansen](https://github.com/bensenmansen), [@bfgray3](https://github.com/bfgray3), [@Bisaloo](https://github.com/Bisaloo), [@bonmac](https://github.com/bonmac), [@botan](https://github.com/botan), [@bshor](https://github.com/bshor), [@carlganz](https://github.com/carlganz), [@chintanp](https://github.com/chintanp), [@chrimaho](https://github.com/chrimaho), [@chris2b5](https://github.com/chris2b5), [@clemenshug](https://github.com/clemenshug), [@courtiol](https://github.com/courtiol), [@dachosen1](https://github.com/dachosen1), [@dan-reznik](https://github.com/dan-reznik), [@datawookie](https://github.com/datawookie), [@david-romano](https://github.com/david-romano), [@DavisVaughan](https://github.com/DavisVaughan), [@dbarrows](https://github.com/dbarrows), [@deann88](https://github.com/deann88), [@denrou](https://github.com/denrou), [@deschen1](https://github.com/deschen1), [@dsg38](https://github.com/dsg38), [@dtburk](https://github.com/dtburk), [@elbersb](https://github.com/elbersb), [@geotheory](https://github.com/geotheory), [@ghost](https://github.com/ghost), [@GrimTrigger88](https://github.com/GrimTrigger88), [@hadley](https://github.com/hadley), [@iago-pssjd](https://github.com/iago-pssjd), [@IndigoJay](https://github.com/IndigoJay), [@jashapiro](https://github.com/jashapiro), [@JBGruber](https://github.com/JBGruber), [@jennybc](https://github.com/jennybc), [@jimhester](https://github.com/jimhester), [@jjesusfilho](https://github.com/jjesusfilho), [@jmbarbone](https://github.com/jmbarbone), [@joethorley](https://github.com/joethorley), [@jonas-hag](https://github.com/jonas-hag), [@jonthegeek](https://github.com/jonthegeek), [@joshyam-k](https://github.com/joshyam-k), [@jpeacock29](https://github.com/jpeacock29), [@jzadra](https://github.com/jzadra), [@KasperThystrup](https://github.com/KasperThystrup), [@kendonB](https://github.com/kendonB), [@kieran-mace](https://github.com/kieran-mace), [@kiernann](https://github.com/kiernann), [@Kodiologist](https://github.com/Kodiologist), [@leej3](https://github.com/leej3), [@leowill01](https://github.com/leowill01), [@LimaRAF](https://github.com/LimaRAF), [@lmwang9527](https://github.com/lmwang9527), [@Ludsfer](https://github.com/Ludsfer), [@lz01](https://github.com/lz01), [@Marcade80](https://github.com/Marcade80), [@Mashin6](https://github.com/Mashin6), [@MattCowgill](https://github.com/MattCowgill), [@maxheld83](https://github.com/maxheld83), [@mgirlich](https://github.com/mgirlich), [@MichaelChirico](https://github.com/MichaelChirico), [@michaelweylandt](https://github.com/michaelweylandt), [@mikeaalv](https://github.com/mikeaalv), [@misea](https://github.com/misea), [@mitchelloharawild](https://github.com/mitchelloharawild), [@mkvasnicka](https://github.com/mkvasnicka), [@mrcaseb](https://github.com/mrcaseb), [@mtnbikerjoshua](https://github.com/mtnbikerjoshua), [@mwip](https://github.com/mwip), [@nachovoss](https://github.com/nachovoss), [@neonira](https://github.com/neonira), [@Nischal-Karki-ATW](https://github.com/Nischal-Karki-ATW), [@oliverbeagley](https://github.com/oliverbeagley), [@orgadish](https://github.com/orgadish), [@pachadotdev](https://github.com/pachadotdev), [@PathosEthosLogos](https://github.com/PathosEthosLogos), [@pdelboca](https://github.com/pdelboca), [@petermeissner](https://github.com/petermeissner), [@phargarten2](https://github.com/phargarten2), [@programLyrique](https://github.com/programLyrique), [@psads-git](https://github.com/psads-git), [@psychelzh](https://github.com/psychelzh), [@PursuitOfDataScience](https://github.com/PursuitOfDataScience), [@richardjtelford](https://github.com/richardjtelford), [@richelbilderbeek](https://github.com/richelbilderbeek), [@rjpat](https://github.com/rjpat), [@romatik](https://github.com/romatik), [@rressler](https://github.com/rressler), [@rwbaer](https://github.com/rwbaer), [@salim-b](https://github.com/salim-b), [@sammo3182](https://github.com/sammo3182), [@sastoudt](https://github.com/sastoudt), [@SchmidtPaul](https://github.com/SchmidtPaul), [@seasmith](https://github.com/seasmith), [@selesnow](https://github.com/selesnow), [@slee981](https://github.com/slee981), [@Tal1987](https://github.com/Tal1987), [@tanzatanza](https://github.com/tanzatanza), [@THChan11](https://github.com/THChan11), [@travis-leith](https://github.com/travis-leith), [@vladtarko](https://github.com/vladtarko), [@wdenton](https://github.com/wdenton), [@wurli](https://github.com/wurli), [@Yingjie4Science](https://github.com/Yingjie4Science), and [@zeehio](https://github.com/zeehio).

[^1]: You might wonder why we developed our own set of recycling rules for the tidyverse instead of using the base R rules. That's because, unfortunately, there isn't a consistent set of rules used by base R, but a [suite of variations](https://vctrs.r-lib.org/articles/type-size.html#appendix-recycling-in-base-r).

