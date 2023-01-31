---
output: hugodown::hugo_document
slug: dplyr-1-1-0-pick-reframe-arrange
title: "dplyr 1.1.0: `pick()`, `reframe()`, and `arrange()`"
date: 2023-02-06
author: Davis Vaughan
description: >
    This final post contains a grab-bag of new features, including: `pick()` for column
    selection inside of data-masking functions, `reframe()` as the new home for
    `summarise()`'s multi-row behavior, and major performance improvements to `arrange()`.
photo:
  url: https://unsplash.com/photos/XgoHMMkE02I
  author: Priscilla Du Preez
categories: [package] 
tags: [dplyr, dplyr-1-1-0]
editor_options: 
  chunk_output_type: console
rmd_hash: 48cb8c07b83a3a5a

---

In this final [dplyr 1.1.0](https://dplyr.tidyverse.org/news/index.html#dplyr-110) post, we'll take a look at two new verbs, [`pick()`](https://dplyr.tidyverse.org/reference/pick.html) and [`reframe()`](https://dplyr.tidyverse.org/reference/reframe.html), along with some changes to [`arrange()`](https://dplyr.tidyverse.org/reference/arrange.html) that improve both reproducibility and performance. If you missed our previous posts, you should definitely go back and [check them out](https://www.tidyverse.org/tags/dplyr-1-1-0/)!

You can install it from CRAN with:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://rdrr.io/r/utils/install.packages.html'>install.packages</a></span><span class='o'>(</span><span class='s'>"dplyr"</span><span class='o'>)</span></span></code></pre>

</div>

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://dplyr.tidyverse.org'>dplyr</a></span><span class='o'>)</span></span>
<span><span class='nf'><a href='https://rdrr.io/r/base/Random.html'>set.seed</a></span><span class='o'>(</span><span class='m'>12345</span><span class='o'>)</span></span></code></pre>

</div>

## `pick()`

One thing we noticed after dplyr 1.0.0 was released is that many people like to use [`across()`](https://dplyr.tidyverse.org/reference/across.html) for its column selection features while working inside a data-masking function like [`mutate()`](https://dplyr.tidyverse.org/reference/mutate.html) or [`summarise()`](https://dplyr.tidyverse.org/reference/summarise.html). This is typically useful if you have a function that takes data frames as inputs, or if you need to compute features about a specific subset of columns.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>df</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://tibble.tidyverse.org/reference/tibble.html'>tibble</a></span><span class='o'>(</span></span>
<span>  x_1 <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='m'>1</span>, <span class='m'>3</span>, <span class='m'>2</span>, <span class='m'>1</span>, <span class='m'>2</span><span class='o'>)</span>, </span>
<span>  x_2 <span class='o'>=</span> <span class='m'>6</span><span class='o'>:</span><span class='m'>10</span>, </span>
<span>  w_4 <span class='o'>=</span> <span class='m'>11</span><span class='o'>:</span><span class='m'>15</span>, </span>
<span>  y_2 <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='m'>5</span>, <span class='m'>2</span>, <span class='m'>4</span>, <span class='m'>0</span>, <span class='m'>6</span><span class='o'>)</span></span>
<span><span class='o'>)</span></span>
<span></span>
<span><span class='nv'>df</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/summarise.html'>summarise</a></span><span class='o'>(</span></span>
<span>    n_x <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/nrow.html'>ncol</a></span><span class='o'>(</span><span class='nf'><a href='https://dplyr.tidyverse.org/reference/across.html'>across</a></span><span class='o'>(</span><span class='nf'><a href='https://tidyselect.r-lib.org/reference/starts_with.html'>starts_with</a></span><span class='o'>(</span><span class='s'>"x"</span><span class='o'>)</span><span class='o'>)</span><span class='o'>)</span>,</span>
<span>    n_y <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/nrow.html'>ncol</a></span><span class='o'>(</span><span class='nf'><a href='https://dplyr.tidyverse.org/reference/across.html'>across</a></span><span class='o'>(</span><span class='nf'><a href='https://tidyselect.r-lib.org/reference/starts_with.html'>starts_with</a></span><span class='o'>(</span><span class='s'>"y"</span><span class='o'>)</span><span class='o'>)</span><span class='o'>)</span></span>
<span>  <span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 1 × 2</span></span></span>
<span><span class='c'>#&gt;     n_x   n_y</span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;int&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;int&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span>     2     1</span></span>
<span></span></code></pre>

</div>

[`across()`](https://dplyr.tidyverse.org/reference/across.html) is intended to apply a function to each of these columns, rather than just select them, which is why its name doesn't feel natural for this operation. In dplyr 1.1.0 we've introduced [`pick()`](https://dplyr.tidyverse.org/reference/pick.html), a specialized column selection variant with a more natural name:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>df</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/summarise.html'>summarise</a></span><span class='o'>(</span></span>
<span>    n_x <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/nrow.html'>ncol</a></span><span class='o'>(</span><span class='nf'><a href='https://dplyr.tidyverse.org/reference/pick.html'>pick</a></span><span class='o'>(</span><span class='nf'><a href='https://tidyselect.r-lib.org/reference/starts_with.html'>starts_with</a></span><span class='o'>(</span><span class='s'>"x"</span><span class='o'>)</span><span class='o'>)</span><span class='o'>)</span>,</span>
<span>    n_y <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/nrow.html'>ncol</a></span><span class='o'>(</span><span class='nf'><a href='https://dplyr.tidyverse.org/reference/pick.html'>pick</a></span><span class='o'>(</span><span class='nf'><a href='https://tidyselect.r-lib.org/reference/starts_with.html'>starts_with</a></span><span class='o'>(</span><span class='s'>"y"</span><span class='o'>)</span><span class='o'>)</span><span class='o'>)</span></span>
<span>  <span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 1 × 2</span></span></span>
<span><span class='c'>#&gt;     n_x   n_y</span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;int&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;int&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span>     2     1</span></span>
<span></span></code></pre>

</div>

[`pick()`](https://dplyr.tidyverse.org/reference/pick.html) is particularly useful in combination with ranking functions like [`dense_rank()`](https://dplyr.tidyverse.org/reference/row_number.html), which have been upgraded in 1.1.0 to take data frames as inputs, serving as a way to jointly rank by multiple columns at once.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>df</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/mutate.html'>mutate</a></span><span class='o'>(</span></span>
<span>    rank1 <span class='o'>=</span> <span class='nf'><a href='https://dplyr.tidyverse.org/reference/row_number.html'>dense_rank</a></span><span class='o'>(</span><span class='nv'>x_1</span><span class='o'>)</span>, </span>
<span>    rank2 <span class='o'>=</span> <span class='nf'><a href='https://dplyr.tidyverse.org/reference/row_number.html'>dense_rank</a></span><span class='o'>(</span><span class='nf'><a href='https://dplyr.tidyverse.org/reference/pick.html'>pick</a></span><span class='o'>(</span><span class='nv'>x_1</span>, <span class='nv'>y_2</span><span class='o'>)</span><span class='o'>)</span> <span class='c'># Using `y_2` to break ties in `x_1`</span></span>
<span>  <span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 5 × 6</span></span></span>
<span><span class='c'>#&gt;     x_1   x_2   w_4   y_2 rank1 rank2</span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;int&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;int&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;int&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;int&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span>     1     6    11     5     1     2</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span>     3     7    12     2     3     5</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>3</span>     2     8    13     4     2     3</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>4</span>     1     9    14     0     1     1</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>5</span>     2    10    15     6     2     4</span></span>
<span></span></code></pre>

</div>

We haven't deprecated using [`across()`](https://dplyr.tidyverse.org/reference/across.html) without supplying `.fns` yet, but we plan to in the future now that [`pick()`](https://dplyr.tidyverse.org/reference/pick.html) exists as a better alternative.

## `reframe()`

As we mentioned in the [coming soon](https://www.tidyverse.org/blog/2022/11/dplyr-1-1-0-is-coming-soon/) blog post, in dplyr 1.1.0 we've decided to walk back the change we introduced to [`summarise()`](https://dplyr.tidyverse.org/reference/summarise.html) in dplyr 1.0.0 that allowed it to return per-group results of any length, rather than results of length 1. We think that the idea of multi-row results is extremely powerful, as it serves as a flexible way to apply arbitrary operations to each group, but we've realized that [`summarise()`](https://dplyr.tidyverse.org/reference/summarise.html) wasn't the best home for it because it increases the chance for users to run into silent recycling bugs (thanks to [Kirill Müller](https://github.com/tidyverse/dplyr/issues/6382) and [David Robinson](https://twitter.com/drob/status/1563198515626770432?s=20&t=iTFWSCPNOGWalIrpXHx2qg) for bringing this to our attention).

As an example, here we're computing the mean and standard deviation of `x`, grouped by `g`. Unfortunately, I accidentally forgot to use `sd(x)` and instead just typed `x`. Because of how [tidyverse recycling rules](https://vctrs.r-lib.org/reference/vector_recycling_rules.html) work, the multi-row behavior silently recycled the size 1 mean values instead of erroring, so rather than 2 rows, we end up with 5.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>df</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://tibble.tidyverse.org/reference/tibble.html'>tibble</a></span><span class='o'>(</span></span>
<span>  g <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='m'>1</span>, <span class='m'>1</span>, <span class='m'>1</span>, <span class='m'>2</span>, <span class='m'>2</span><span class='o'>)</span>,</span>
<span>  x <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='m'>4</span>, <span class='m'>3</span>, <span class='m'>6</span>, <span class='m'>2</span>, <span class='m'>8</span><span class='o'>)</span>,</span>
<span>  y <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='m'>5</span>, <span class='m'>1</span>, <span class='m'>2</span>, <span class='m'>8</span>, <span class='m'>9</span><span class='o'>)</span></span>
<span><span class='o'>)</span></span>
<span></span>
<span><span class='nv'>df</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 5 × 3</span></span></span>
<span><span class='c'>#&gt;       g     x     y</span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span>     1     4     5</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span>     1     3     1</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>3</span>     1     6     2</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>4</span>     2     2     8</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>5</span>     2     8     9</span></span>
<span></span></code></pre>

</div>

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>df</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/summarise.html'>summarise</a></span><span class='o'>(</span></span>
<span>    x_average <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/mean.html'>mean</a></span><span class='o'>(</span><span class='nv'>x</span><span class='o'>)</span>,</span>
<span>    x_sd <span class='o'>=</span> <span class='nv'>x</span>, <span class='c'># Oops</span></span>
<span>    .by <span class='o'>=</span> <span class='nv'>g</span></span>
<span>  <span class='o'>)</span></span>
<span><span class='c'>#&gt; Warning: Returning more (or less) than 1 row per `summarise()` group was deprecated in</span></span>
<span><span class='c'>#&gt; dplyr 1.1.0.</span></span>
<span><span class='c'>#&gt; <span style='color: #00BBBB;'>ℹ</span> Please use `reframe()` instead.</span></span>
<span><span class='c'>#&gt; <span style='color: #00BBBB;'>ℹ</span> When switching from `summarise()` to `reframe()`, remember that `reframe()`</span></span>
<span><span class='c'>#&gt;   always returns an ungrouped data frame and adjust accordingly.</span></span>
<span></span><span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 5 × 3</span></span></span>
<span><span class='c'>#&gt;       g x_average  x_sd</span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>     <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span>     1      4.33     4</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span>     1      4.33     3</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>3</span>     1      4.33     6</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>4</span>     2      5        2</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>5</span>     2      5        8</span></span>
<span></span></code></pre>

</div>

[`summarise()`](https://dplyr.tidyverse.org/reference/summarise.html) now throws a warning when any group returns a result that isn't length 1. We expect to upgrade this to an error in the future to revert [`summarise()`](https://dplyr.tidyverse.org/reference/summarise.html) back to its "safe" behavior of requiring 1 row per group.

[`summarise()`](https://dplyr.tidyverse.org/reference/summarise.html) also wasn't the best name for a function with this feature, as the name itself implies one row per group. After [gathering some feedback](https://github.com/tidyverse/dplyr/issues/6565), we've settled on a new verb with a more appropriate name, [`reframe()`](https://dplyr.tidyverse.org/reference/reframe.html). We think of [`reframe()`](https://dplyr.tidyverse.org/reference/reframe.html) as a way to "do something" to each group, with no restrictions on the number of rows returned per group. The name has a nice connection to the tibble functions [`tibble::enframe()`](https://tibble.tidyverse.org/reference/enframe.html) and [`tibble::deframe()`](https://tibble.tidyverse.org/reference/enframe.html), which are used for converting vectors to data frames and vice versa:

-   `enframe()`: Takes a vector, returns a data frame

-   `deframe()`: Takes a data frame, returns a vector

-   [`reframe()`](https://dplyr.tidyverse.org/reference/reframe.html): Takes a data frame, returns a data frame

One nice application of [`reframe()`](https://dplyr.tidyverse.org/reference/reframe.html) is computing quantiles at various probability thresholds. It's particularly nice if we wrap [`quantile()`](https://rdrr.io/r/stats/quantile.html) into a helper that returns a data frame, which [`reframe()`](https://dplyr.tidyverse.org/reference/reframe.html) then automatically unpacks.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>quantile_df</span> <span class='o'>&lt;-</span> <span class='kr'>function</span><span class='o'>(</span><span class='nv'>x</span>, <span class='nv'>probs</span> <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='m'>0.25</span>, <span class='m'>0.5</span>, <span class='m'>0.75</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>&#123;</span></span>
<span>  <span class='nf'><a href='https://tibble.tidyverse.org/reference/tibble.html'>tibble</a></span><span class='o'>(</span></span>
<span>    value <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/stats/quantile.html'>quantile</a></span><span class='o'>(</span><span class='nv'>x</span>, <span class='nv'>probs</span>, na.rm <span class='o'>=</span> <span class='kc'>TRUE</span><span class='o'>)</span>,</span>
<span>    prob <span class='o'>=</span> <span class='nv'>probs</span></span>
<span>  <span class='o'>)</span></span>
<span><span class='o'>&#125;</span></span></code></pre>

</div>

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>df</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/reframe.html'>reframe</a></span><span class='o'>(</span><span class='nf'>quantile_df</span><span class='o'>(</span><span class='nv'>x</span><span class='o'>)</span>, .by <span class='o'>=</span> <span class='nv'>g</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 6 × 3</span></span></span>
<span><span class='c'>#&gt;       g value  prob</span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span>     1   3.5  0.25</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span>     1   4    0.5 </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>3</span>     1   5    0.75</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>4</span>     2   3.5  0.25</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>5</span>     2   5    0.5 </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>6</span>     2   6.5  0.75</span></span>
<span></span></code></pre>

</div>

This also works well if you want to apply it to multiple columns using [`across()`](https://dplyr.tidyverse.org/reference/across.html):

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>df</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/reframe.html'>reframe</a></span><span class='o'>(</span><span class='nf'><a href='https://dplyr.tidyverse.org/reference/across.html'>across</a></span><span class='o'>(</span><span class='nv'>x</span><span class='o'>:</span><span class='nv'>y</span>, <span class='nv'>quantile_df</span><span class='o'>)</span>, .by <span class='o'>=</span> <span class='nv'>g</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 6 × 3</span></span></span>
<span><span class='c'>#&gt;       g x$value $prob y$value $prob</span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>   <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>   <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span>     1     3.5  0.25    1.5   0.25</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span>     1     4    0.5     2     0.5 </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>3</span>     1     5    0.75    3.5   0.75</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>4</span>     2     3.5  0.25    8.25  0.25</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>5</span>     2     5    0.5     8.5   0.5 </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>6</span>     2     6.5  0.75    8.75  0.75</span></span>
<span></span></code></pre>

</div>

Because `quantile_df()` returns a tibble, we end up with [*packed*](https://tidyr.tidyverse.org/reference/pack.html) data frame columns. You'll often want to unpack these into their individual columns, and [`across()`](https://dplyr.tidyverse.org/reference/across.html) has gained a new `.unpack` argument in 1.1.0 that helps you do exactly that:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>df</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/reframe.html'>reframe</a></span><span class='o'>(</span><span class='nf'><a href='https://dplyr.tidyverse.org/reference/across.html'>across</a></span><span class='o'>(</span><span class='nv'>x</span><span class='o'>:</span><span class='nv'>y</span>, <span class='nv'>quantile_df</span>, .unpack <span class='o'>=</span> <span class='kc'>TRUE</span><span class='o'>)</span>, .by <span class='o'>=</span> <span class='nv'>g</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 6 × 5</span></span></span>
<span><span class='c'>#&gt;       g x_value x_prob y_value y_prob</span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>   <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>  <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>   <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>  <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span>     1     3.5   0.25    1.5    0.25</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span>     1     4     0.5     2      0.5 </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>3</span>     1     5     0.75    3.5    0.75</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>4</span>     2     3.5   0.25    8.25   0.25</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>5</span>     2     5     0.5     8.5    0.5 </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>6</span>     2     6.5   0.75    8.75   0.75</span></span>
<span></span></code></pre>

</div>

We expect that seeing [`reframe()`](https://dplyr.tidyverse.org/reference/reframe.html) in a colleague's code will serve as an extremely clear signal that something "special" is happening, because they've made a conscious decision to opt-into the 1% case of returning multiple rows per group.

## `arrange()`

We also mentioned in the [coming soon](https://www.tidyverse.org/blog/2022/11/dplyr-1-1-0-is-coming-soon/) post that [`arrange()`](https://dplyr.tidyverse.org/reference/arrange.html) has undergone two user-facing changes:

-   When sorting character vectors, the C locale is now the default, rather than the system locale

-   A new `.locale` argument, powered by stringi, allows you to explicitly request an alternative locale using a stringi locale identifier (like `"en"` for English, or `"fr"` for French)

These changes were made for two reasons:

-   Much faster performance by default, due to usage of a custom radix sort algorithm inspired by [data.table](https://cran.r-project.org/web/packages/data.table/index.html)'s `forder()`

-   Improved reproducibility across R sessions, where different computers might use different system locales and different operating systems have different ways to specify the same system locale

If you use [`arrange()`](https://dplyr.tidyverse.org/reference/arrange.html) for the purpose of grouping similar values together (and don't care much about the specific locale that it uses to do so), then you'll likely see performance improvements of up to 100x in dplyr 1.1.0. If you do care about the locale and supply `.locale`, you should still see improvements of up to 10x.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='c'># 10,000 random strings, sampled up to 1,000,000 rows</span></span>
<span><span class='nv'>dictionary</span> <span class='o'>&lt;-</span> <span class='nf'>stringi</span><span class='nf'>::</span><span class='nf'><a href='https://rdrr.io/pkg/stringi/man/stri_rand_strings.html'>stri_rand_strings</a></span><span class='o'>(</span><span class='m'>10000</span>, length <span class='o'>=</span> <span class='m'>10</span>, pattern <span class='o'>=</span> <span class='s'>"[a-z]"</span><span class='o'>)</span></span>
<span><span class='nv'>str</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://tibble.tidyverse.org/reference/tibble.html'>tibble</a></span><span class='o'>(</span>x <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/sample.html'>sample</a></span><span class='o'>(</span><span class='nv'>dictionary</span>, size <span class='o'>=</span> <span class='m'>1e6</span>, replace <span class='o'>=</span> <span class='kc'>TRUE</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='nv'>str</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 1,000,000 × 1</span></span></span>
<span><span class='c'>#&gt;    x         </span></span>
<span><span class='c'>#&gt;    <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>     </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 1</span> slpqkdtpyr</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 2</span> xtoucpndhc</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 3</span> vsvfoqcyqm</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 4</span> gnbpkwcmse</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 5</span> xutzdqxpsi</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 6</span> gkolsrndrz</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 7</span> mitqahkkou</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 8</span> eehfrrimhd</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 9</span> ymxxjczjsv</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>10</span> svpvizfxwe</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># … with 999,990 more rows</span></span></span>
<span></span></code></pre>

</div>

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='c'># dplyr 1.0.10 (American English system locale)</span></span>
<span><span class='nf'>bench</span><span class='nf'>::</span><span class='nf'><a href='http://bench.r-lib.org/reference/mark.html'>mark</a></span><span class='o'>(</span><span class='nf'><a href='https://dplyr.tidyverse.org/reference/arrange.html'>arrange</a></span><span class='o'>(</span><span class='nv'>str</span>, <span class='nv'>x</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; # A tibble: 1 × 6</span></span>
<span><span class='c'>#&gt;   expression          min   median `itr/sec` mem_alloc `gc/sec`</span></span>
<span><span class='c'>#&gt;   &lt;bch:expr&gt;     &lt;bch:tm&gt; &lt;bch:tm&gt;     &lt;dbl&gt; &lt;bch:byt&gt;    &lt;dbl&gt;</span></span>
<span><span class='c'>#&gt; 1 arrange(str, x)   4.38s    4.89s     0.204    12.7MB    0.148</span></span>
<span></span>
<span><span class='c'># dplyr 1.1.0 (C locale default, 100x faster)</span></span>
<span><span class='nf'>bench</span><span class='nf'>::</span><span class='nf'><a href='http://bench.r-lib.org/reference/mark.html'>mark</a></span><span class='o'>(</span><span class='nf'><a href='https://dplyr.tidyverse.org/reference/arrange.html'>arrange</a></span><span class='o'>(</span><span class='nv'>str</span>, <span class='nv'>x</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; # A tibble: 1 × 6</span></span>
<span><span class='c'>#&gt;   expression          min   median `itr/sec` mem_alloc `gc/sec`</span></span>
<span><span class='c'>#&gt;   &lt;bch:expr&gt;     &lt;bch:tm&gt; &lt;bch:tm&gt;     &lt;dbl&gt; &lt;bch:byt&gt;    &lt;dbl&gt;</span></span>
<span><span class='c'>#&gt; 1 arrange(str, x)  42.3ms   46.6ms      20.8    22.4MB     46.0</span></span>
<span></span>
<span><span class='c'># dplyr 1.1.0 (American English `.locale`, 10x faster)</span></span>
<span><span class='nf'>bench</span><span class='nf'>::</span><span class='nf'><a href='http://bench.r-lib.org/reference/mark.html'>mark</a></span><span class='o'>(</span><span class='nf'><a href='https://dplyr.tidyverse.org/reference/arrange.html'>arrange</a></span><span class='o'>(</span><span class='nv'>str</span>, <span class='nv'>x</span>, .locale <span class='o'>=</span> <span class='s'>"en"</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; # A tibble: 1 × 6</span></span>
<span><span class='c'>#&gt;   expression                           min median `itr/sec` mem_alloc</span></span>
<span><span class='c'>#&gt;   &lt;bch:expr&gt;                      &lt;bch:tm&gt; &lt;bch:&gt;     &lt;dbl&gt; &lt;bch:byt&gt;</span></span>
<span><span class='c'>#&gt; 1 arrange(str, x, .locale = "en")    377ms  430ms      2.21    27.9MB</span></span>
<span><span class='c'>#&gt; # … with 1 more variable: `gc/sec` &lt;dbl&gt;</span></span></code></pre>

</div>

We are hopeful that switching to a C locale default will have a relatively small amount of impact in exchange for much faster performance. To read more about the exact differences between the C locale and locales like American English or Spanish, see the [coming soon](https://www.tidyverse.org/blog/2022/11/dplyr-1-1-0-is-coming-soon/#arrange-improvements-with-character-vectors) post or our detailed [tidyup](https://github.com/tidyverse/tidyups/blob/main/003-dplyr-radix-ordering.md). If you are having trouble converting an existing script over to the new behavior, you can set the temporary global option `options(dplyr.legacy_locale = TRUE)`, which will revert to the pre-1.1.0 behavior of using the system locale. We expect to remove this option in a future release.

