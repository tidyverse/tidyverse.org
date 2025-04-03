---
output: hugodown::hugo_document

slug: rsample-1-3-0
title: rsample 1.3.0
date: 2025-04-03
author: Hannah Frick
description: >
    This release brings more flexibilty to the grouping of bootstrap confidence 
    intervals. It also contains many contributions from the tidyverse developer 
    day.

photo:
  url: https://unsplash.com/photos/a-row-of-shelves-filled-with-lots-of-shoes-yZxBkDr73AM
  author: Erik Mclean

# one of: "deep-dive", "learn", "package", "programming", "roundup", or "other"
categories: [package] 
tags: [tidymodels, rsample]
rmd_hash: af7cff0d6c062422

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

We're thrilled to announce the release of [rsample](https://rsample.tidymodels.org/) 1.3.0. rsample makes it easy to create resamples for assessing model performance. It is part of the tidymodels framework, a collection of R packages for modeling and machine learning using tidyverse principles.

You can install it from CRAN with:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://rdrr.io/r/utils/install.packages.html'>install.packages</a></span><span class='o'>(</span><span class='s'>"rsample"</span><span class='o'>)</span></span></code></pre>

</div>

This blog post will walk you through the more flexible grouping for calculating bootstrap confidence intervals and highlight the contributions made by participants of the tidyverse developer day.

You can see a full list of changes in the [release notes](https://rsample.tidymodels.org/news/index.html#rsample-130).

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://rsample.tidymodels.org'>rsample</a></span><span class='o'>)</span></span></code></pre>

</div>

## Flexible grouping for bootstrap intervals

Resampling allows you get an understanding of the variability of an estimate, e.g., a summary statistic of your data. If you want to lean on statistical theory and get confidence intervals for your estimate, you can reach for the bootstrap resampling scheme: calculating your summary statistic on the bootstrap samples enables you to calculate confidence intervals around your point estimate.

rsample contains a family of `int_*()` functions to calculate bootstrap confidence intervals of different flavors: percentile intervals, "BCa" intervals, and bootstrap-t intervals. If you want to dive into the technical details, Chapter 11 of [CASI](https://hastie.su.domains/CASI/) is a good place to start.

You can calculate the confidence intervals based on a grouping in your data. However, so far, rsample would only let you provide a single grouping variable. With this release, we are extending this functionality to allow a more flexible grouping.

The motivating application for us was to be able to calculate confidence intervals around multiple model performance metrics, including dynamic metrics for time-to-event models which depend on an evaluation time point. So in this case, the metric is one grouping variable and the evaluation time another. But let's pull back complexity for an example of how the new rsample functionality works!

We have a dataset with delivery times for orders containing one or more items. We'll do some data wrangling with it, so we are also loading dplyr.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://dplyr.tidyverse.org'>dplyr</a></span><span class='o'>)</span></span>
<span><span class='c'>#&gt; </span></span>
<span><span class='c'>#&gt; Attaching package: 'dplyr'</span></span>
<span></span><span><span class='c'>#&gt; The following objects are masked from 'package:stats':</span></span>
<span><span class='c'>#&gt; </span></span>
<span><span class='c'>#&gt;     filter, lag</span></span>
<span></span><span><span class='c'>#&gt; The following objects are masked from 'package:base':</span></span>
<span><span class='c'>#&gt; </span></span>
<span><span class='c'>#&gt;     intersect, setdiff, setequal, union</span></span>
<span></span><span><span class='nf'><a href='https://rdrr.io/r/utils/data.html'>data</a></span><span class='o'>(</span><span class='nv'>deliveries</span>, package <span class='o'>=</span> <span class='s'>"modeldata"</span><span class='o'>)</span></span>
<span></span>
<span><span class='nv'>deliveries</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 10,012 × 31</span></span></span>
<span><span class='c'>#&gt;    time_to_delivery  hour day   distance item_01 item_02 item_03 item_04 item_05</span></span>
<span><span class='c'>#&gt;               <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;fct&gt;</span>    <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>   <span style='color: #555555; font-style: italic;'>&lt;int&gt;</span>   <span style='color: #555555; font-style: italic;'>&lt;int&gt;</span>   <span style='color: #555555; font-style: italic;'>&lt;int&gt;</span>   <span style='color: #555555; font-style: italic;'>&lt;int&gt;</span>   <span style='color: #555555; font-style: italic;'>&lt;int&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 1</span>             16.1  11.9 Thu       3.15       0       0       2       0       0</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 2</span>             22.9  19.2 Tue       3.69       0       0       0       0       0</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 3</span>             30.3  18.4 Fri       2.06       0       0       0       0       1</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 4</span>             33.4  15.8 Thu       5.97       0       0       0       0       0</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 5</span>             27.2  19.6 Fri       2.52       0       0       0       1       0</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 6</span>             19.6  13.0 Sat       3.35       1       0       0       1       0</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 7</span>             22.1  15.5 Sun       2.46       0       0       1       1       0</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 8</span>             26.6  17.0 Thu       2.21       0       0       1       0       0</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 9</span>             30.8  16.7 Fri       2.62       0       0       0       0       0</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>10</span>             17.4  11.9 Sun       2.75       0       2       1       0       0</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># ℹ 10,002 more rows</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># ℹ 22 more variables: item_06 &lt;int&gt;, item_07 &lt;int&gt;, item_08 &lt;int&gt;,</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>#   item_09 &lt;int&gt;, item_10 &lt;int&gt;, item_11 &lt;int&gt;, item_12 &lt;int&gt;, item_13 &lt;int&gt;,</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>#   item_14 &lt;int&gt;, item_15 &lt;int&gt;, item_16 &lt;int&gt;, item_17 &lt;int&gt;, item_18 &lt;int&gt;,</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>#   item_19 &lt;int&gt;, item_20 &lt;int&gt;, item_21 &lt;int&gt;, item_22 &lt;int&gt;, item_23 &lt;int&gt;,</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>#   item_24 &lt;int&gt;, item_25 &lt;int&gt;, item_26 &lt;int&gt;, item_27 &lt;int&gt;</span></span></span>
<span></span></code></pre>

</div>

Instead of fitting a whole model here, we are calculating a straightforward summary statistic for how much delivery time increases if an item is included in the order. So the item is one grouping factor. As a second one, we are using whether the order was delivered on a weekday or a weekend. Let's start by making that weekend indicator and reshaping the data to make it easier to calculate our summary statistic.

Note that the name for the weekend indicator column, `.weekend`, starts with a dot. That is important as it is the convention to signal to rsample that this is an additional grouping variable.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>item_data</span> <span class='o'>&lt;-</span> <span class='nv'>deliveries</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/mutate.html'>mutate</a></span><span class='o'>(</span>.weekend <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/ifelse.html'>ifelse</a></span><span class='o'>(</span><span class='nv'>day</span> <span class='o'><a href='https://rdrr.io/r/base/match.html'>%in%</a></span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"Sat"</span>, <span class='s'>"Sun"</span><span class='o'>)</span>, <span class='s'>"weekend"</span>, <span class='s'>"weekday"</span><span class='o'>)</span><span class='o'>)</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/select.html'>select</a></span><span class='o'>(</span><span class='nv'>time_to_delivery</span>, <span class='nv'>.weekend</span>, <span class='nf'><a href='https://tidyselect.r-lib.org/reference/starts_with.html'>starts_with</a></span><span class='o'>(</span><span class='s'>"item"</span><span class='o'>)</span><span class='o'>)</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span></span>
<span>  <span class='nf'>tidyr</span><span class='nf'>::</span><span class='nf'><a href='https://tidyr.tidyverse.org/reference/pivot_longer.html'>pivot_longer</a></span><span class='o'>(</span><span class='nf'><a href='https://tidyselect.r-lib.org/reference/starts_with.html'>starts_with</a></span><span class='o'>(</span><span class='s'>"item"</span><span class='o'>)</span>, names_to <span class='o'>=</span> <span class='s'>"item"</span>, values_to <span class='o'>=</span> <span class='s'>"value"</span><span class='o'>)</span> </span></code></pre>

</div>

Next, we are making a small function that calculates the ratio of average delivery times with and without the item included in the order, as a estimate of how much a specific item in an order increases the delivery time.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>relative_increase</span> <span class='o'>&lt;-</span> <span class='kr'>function</span><span class='o'>(</span><span class='nv'>data</span><span class='o'>)</span> <span class='o'>&#123;</span></span>
<span>  <span class='nv'>data</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span></span>
<span>    <span class='nf'><a href='https://dplyr.tidyverse.org/reference/mutate.html'>mutate</a></span><span class='o'>(</span>includes_item <span class='o'>=</span> <span class='nv'>value</span> <span class='o'>&gt;</span> <span class='m'>0</span><span class='o'>)</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span></span>
<span>    <span class='nf'><a href='https://dplyr.tidyverse.org/reference/summarise.html'>summarize</a></span><span class='o'>(</span></span>
<span>      has <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/mean.html'>mean</a></span><span class='o'>(</span><span class='nv'>time_to_delivery</span><span class='o'>[</span><span class='nv'>includes_item</span><span class='o'>]</span><span class='o'>)</span>,</span>
<span>      has_not <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/mean.html'>mean</a></span><span class='o'>(</span><span class='nv'>time_to_delivery</span><span class='o'>[</span><span class='o'>!</span><span class='nv'>includes_item</span><span class='o'>]</span><span class='o'>)</span>,</span>
<span>      .by <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='nv'>item</span>, <span class='nv'>.weekend</span><span class='o'>)</span></span>
<span>    <span class='o'>)</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span></span>
<span>    <span class='nf'><a href='https://dplyr.tidyverse.org/reference/mutate.html'>mutate</a></span><span class='o'>(</span>estimate <span class='o'>=</span> <span class='nv'>has</span> <span class='o'>/</span> <span class='nv'>has_not</span><span class='o'>)</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span></span>
<span>    <span class='nf'><a href='https://dplyr.tidyverse.org/reference/select.html'>select</a></span><span class='o'>(</span>term <span class='o'>=</span> <span class='nv'>item</span>, <span class='nv'>.weekend</span>, <span class='nv'>estimate</span><span class='o'>)</span></span>
<span><span class='o'>&#125;</span></span></code></pre>

</div>

We can calculate that on our entire dataset.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'>relative_increase</span><span class='o'>(</span><span class='nv'>item_data</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 54 × 3</span></span></span>
<span><span class='c'>#&gt;    term    .weekend estimate</span></span>
<span><span class='c'>#&gt;    <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>   <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>       <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 1</span> item_01 weekday      1.07</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 2</span> item_02 weekday      1.02</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 3</span> item_03 weekday      1.02</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 4</span> item_04 weekday      1.00</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 5</span> item_05 weekday      1.00</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 6</span> item_06 weekday      1.01</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 7</span> item_07 weekday      1.03</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 8</span> item_08 weekday      1.01</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 9</span> item_09 weekday      1.01</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>10</span> item_10 weekday      1.06</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># ℹ 44 more rows</span></span></span>
<span></span></code></pre>

</div>

This is fine, but what we really want here is to get confidence intervals around these estimates!

So let's make bootstrap samples and calculate our statistic on those.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://rdrr.io/r/base/Random.html'>set.seed</a></span><span class='o'>(</span><span class='m'>1</span><span class='o'>)</span></span>
<span><span class='nv'>item_bootstrap</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rsample.tidymodels.org/reference/bootstraps.html'>bootstraps</a></span><span class='o'>(</span><span class='nv'>item_data</span>, times <span class='o'>=</span> <span class='m'>1000</span><span class='o'>)</span></span>
<span></span>
<span><span class='nv'>item_stats</span> <span class='o'>&lt;-</span></span>
<span>  <span class='nv'>item_bootstrap</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/mutate.html'>mutate</a></span><span class='o'>(</span>stats <span class='o'>=</span> <span class='nf'>purrr</span><span class='nf'>::</span><span class='nf'><a href='https://purrr.tidyverse.org/reference/map.html'>map</a></span><span class='o'>(</span><span class='nv'>splits</span>, <span class='o'>~</span> <span class='nf'><a href='https://rsample.tidymodels.org/reference/as.data.frame.rsplit.html'>analysis</a></span><span class='o'>(</span><span class='nv'>.x</span><span class='o'>)</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span> <span class='nf'>relative_increase</span><span class='o'>(</span><span class='o'>)</span><span class='o'>)</span><span class='o'>)</span></span></code></pre>

</div>

Now we have everything we need to calculate the confidence intervals, stashed into the tibbles in the `stats` column: an `estimate`, a `term` (the primary grouping variable), and our additional grouping variable `.weekend`, starting with a dot. What's left to do is call one of the `int_*()` functions and specify which column contains the statistics. Here, we'll calculate percentile intervals with [`int_pctl()`](https://rsample.tidymodels.org/reference/int_pctl.html).

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>item_ci</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rsample.tidymodels.org/reference/int_pctl.html'>int_pctl</a></span><span class='o'>(</span><span class='nv'>item_stats</span>, statistics <span class='o'>=</span> <span class='nv'>stats</span>, alpha <span class='o'>=</span> <span class='m'>0.1</span><span class='o'>)</span></span>
<span><span class='nv'>item_ci</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 27 × 6</span></span></span>
<span><span class='c'>#&gt;    term    .lower .estimate .upper .alpha .method   </span></span>
<span><span class='c'>#&gt;    <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>    <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>     <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>  <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>  <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>     </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 1</span> item_01  1.04       1.07   1.10    0.1 percentile</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 2</span> item_02  0.999      1.02   1.03    0.1 percentile</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 3</span> item_03  0.974      1.01   1.03    0.1 percentile</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 4</span> item_04  0.991      1.01   1.03    0.1 percentile</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 5</span> item_05  0.984      1.00   1.02    0.1 percentile</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 6</span> item_06  0.996      1.02   1.05    0.1 percentile</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 7</span> item_07  0.992      1.02   1.04    0.1 percentile</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 8</span> item_08  0.993      1.01   1.03    0.1 percentile</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 9</span> item_09  0.996      1.01   1.03    0.1 percentile</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>10</span> item_10  1.04       1.06   1.09    0.1 percentile</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># ℹ 17 more rows</span></span></span>
<span></span></code></pre>

</div>

## Tidyverse developer day

At the tidyverse developer day after posit::conf, rsample got a lot of love in form of contributions by various community members. People improved documentation and examples, move deprecations along, tightened checks to support good practice, and upgraded errors and warnings, both in style and content. None of these changes are flashy new features but all of them are essential to rsample working well!

So for example, leave-one-out (LOO) cross-validation is not a great choice of resampling scheme in most situations. From [Tidy modeling with R](https://www.tmwr.org/resampling#leave-one-out-cross-validation):

> For anything but pathologically small samples, LOO is computationally excessive, and it may not have good statistical properties.

It was possible, however, to create implicit LOO samples by using [`vfold_cv()`](https://rsample.tidymodels.org/reference/vfold_cv.html) with the number of folds set to the number of rows in the data. With a dev day contribution, this now errors:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://rsample.tidymodels.org/reference/vfold_cv.html'>vfold_cv</a></span><span class='o'>(</span><span class='nv'>mtcars</span>, v <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/nrow.html'>nrow</a></span><span class='o'>(</span><span class='nv'>mtcars</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; #  32-fold cross-validation </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 32 × 2</span></span></span>
<span><span class='c'>#&gt;    splits         id    </span></span>
<span><span class='c'>#&gt;    <span style='color: #555555; font-style: italic;'>&lt;list&gt;</span>         <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span> </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 1</span> <span style='color: #555555;'>&lt;split [31/1]&gt;</span> Fold01</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 2</span> <span style='color: #555555;'>&lt;split [31/1]&gt;</span> Fold02</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 3</span> <span style='color: #555555;'>&lt;split [31/1]&gt;</span> Fold03</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 4</span> <span style='color: #555555;'>&lt;split [31/1]&gt;</span> Fold04</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 5</span> <span style='color: #555555;'>&lt;split [31/1]&gt;</span> Fold05</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 6</span> <span style='color: #555555;'>&lt;split [31/1]&gt;</span> Fold06</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 7</span> <span style='color: #555555;'>&lt;split [31/1]&gt;</span> Fold07</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 8</span> <span style='color: #555555;'>&lt;split [31/1]&gt;</span> Fold08</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 9</span> <span style='color: #555555;'>&lt;split [31/1]&gt;</span> Fold09</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>10</span> <span style='color: #555555;'>&lt;split [31/1]&gt;</span> Fold10</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># ℹ 22 more rows</span></span></span>
<span></span></code></pre>

</div>

This is to make users pause and consider if this a good choice for their dataset. If you require LOO, you can still use [`loo_cv()`](https://rsample.tidymodels.org/reference/loo_cv.html).

Error messages in general have been a focus of ours across various tidymodels packages, rsample is no exception. We opened a bunch of issues to tackle all of rsample - and all got closed! Some of these changes are purely internal, upgrading manual formatting to let the cli package do the work. While the error message in most cases doesn't *look* different, it's a great deal more consistency in formatting.

For some error messages, the additional functionality in cli makes it easy to improve readability. This error message used to be one block of text, now it comes as three bullet points.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://rsample.tidymodels.org/reference/permutations.html'>permutations</a></span><span class='o'>(</span><span class='nv'>mtcars</span>, <span class='nf'><a href='https://tidyselect.r-lib.org/reference/everything.html'>everything</a></span><span class='o'>(</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #BBBB00; font-weight: bold;'>Error</span><span style='font-weight: bold;'> in `permutations()`:</span></span></span>
<span><span class='c'>#&gt; <span style='color: #BBBB00;'>!</span> You have selected all columns to permute. This effectively reorders the rows in the original data without changing the data structure. Please select fewer columns to permute.</span></span>
<span></span></code></pre>

</div>

Changes like these are super helpful to users and developers alike. A big thank you to all the contributors!

## Acknowledgements

Many thanks to all the people who contributed to rsample since the last release!

[@agmurray](https://github.com/agmurray), [@brshallo](https://github.com/brshallo), [@ccani007](https://github.com/ccani007), [@dicook](https://github.com/dicook), [@Dpananos](https://github.com/Dpananos), [@EmilHvitfeldt](https://github.com/EmilHvitfeldt), [@gaborcsardi](https://github.com/gaborcsardi), [@gregor-fausto](https://github.com/gregor-fausto), [@hfrick](https://github.com/hfrick), [@JamesHWade](https://github.com/JamesHWade), [@jttoivon](https://github.com/jttoivon), [@krz](https://github.com/krz), [@laurabrianna](https://github.com/laurabrianna), [@malcolmbarrett](https://github.com/malcolmbarrett), [@MatthieuStigler](https://github.com/MatthieuStigler), [@msberends](https://github.com/msberends), [@nmercadeb](https://github.com/nmercadeb), [@PriKalra](https://github.com/PriKalra), [@seb09](https://github.com/seb09), [@simonpcouch](https://github.com/simonpcouch), [@topepo](https://github.com/topepo), [@ZWael](https://github.com/ZWael), and [@zz77zz](https://github.com/zz77zz).

