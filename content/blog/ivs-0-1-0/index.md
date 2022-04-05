---
output: hugodown::hugo_document
slug: ivs-0-1-0
title: ivs 0.1.0
date: 2022-04-05
author: Davis Vaughan
description: >
    Introducing, ivs, a new package for working with interval vectors.
photo:
  url: https://unsplash.com/photos/EggOctO_VL4
  author: Tim Mossholder
categories: [package] 
tags: [ivs]
editor_options: 
  chunk_output_type: console
rmd_hash: bca9044bd0a23fa7

---

We're tickled pink to announce the first release of [ivs](https://davisvaughan.github.io/ivs/) (said, "eye-vees"), a package dedicated to working with intervals. It introduces a new vector type, the **i**nterval **v**ector, which is generally just referred to as an **iv** throughout the package.

You can install ivs from CRAN with:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://rdrr.io/r/utils/install.packages.html'>install.packages</a></span><span class='o'>(</span><span class='s'>"ivs"</span><span class='o'>)</span></code></pre>

</div>

ivs is loaded with tools for working with interval vectors. In particular, it provides utilities for:

-   Grouping / Merging overlapping intervals.

-   Splitting intervals on overlapping endpoints.

-   Determining how two ivs are related, i.e. does one interval precede, follow, or overlap another?

-   Applying set theoretical operations like intersection, union, and complement on two ivs.

The rest of this blog post will explore some of this functionality through a number of practical examples.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://github.com/DavisVaughan/ivs'>ivs</a></span><span class='o'>)</span>
<span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://clock.r-lib.org'>clock</a></span><span class='o'>)</span>
<span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://dplyr.tidyverse.org'>dplyr</a></span><span class='o'>)</span></code></pre>

</div>

## Creating an interval vector

Interval vectors are typically created from two parallel vectors representing the starts (inclusive) and ends (exclusive) of the intervals:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>starts</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='m'>1</span>, <span class='m'>5</span>, <span class='m'>10</span>, <span class='m'>3</span><span class='o'>)</span>
<span class='nv'>ends</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='m'>6</span>, <span class='m'>9</span>, <span class='m'>12</span>, <span class='m'>4</span><span class='o'>)</span>

<span class='nf'><a href='https://davisvaughan.github.io/ivs/reference/iv.html'>iv</a></span><span class='o'>(</span><span class='nv'>starts</span>, <span class='nv'>ends</span><span class='o'>)</span>
<span class='c'>#&gt; &lt;iv&lt;double&gt;[4]&gt;</span>
<span class='c'>#&gt; [1] [1, 6)   [5, 9)   [10, 12) [3, 4)</span></code></pre>

</div>

ivs is designed to play nicely with the tidyverse, and most of the time `start` and `end` will already be columns in an existing data frame.

ivs is also designed to be *generic*. It is built on top of [vctrs](https://vctrs.r-lib.org), which gives it the ability to use any comparable type as the start/end vectors.

This includes dates and date-times:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>starts</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/as.Date.html'>as.Date</a></span><span class='o'>(</span><span class='s'>"2019-01-01"</span><span class='o'>)</span> <span class='o'>+</span> <span class='m'>0</span><span class='o'>:</span><span class='m'>2</span>
<span class='nv'>ends</span> <span class='o'>&lt;-</span> <span class='nv'>starts</span> <span class='o'>+</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='m'>2</span>, <span class='m'>5</span>, <span class='m'>10</span><span class='o'>)</span>

<span class='nf'><a href='https://davisvaughan.github.io/ivs/reference/iv.html'>iv</a></span><span class='o'>(</span><span class='nv'>starts</span>, <span class='nv'>ends</span><span class='o'>)</span>
<span class='c'>#&gt; &lt;iv&lt;date&gt;[3]&gt;</span>
<span class='c'>#&gt; [1] [2019-01-01, 2019-01-03) [2019-01-02, 2019-01-07) [2019-01-03, 2019-01-13)</span></code></pre>

</div>

the `integer64` type from [bit64](https://cran.r-project.org/web/packages/bit64/index.html):

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>start</span> <span class='o'>&lt;-</span> <span class='nf'>bit64</span><span class='nf'>::</span><span class='nf'><a href='https://rdrr.io/pkg/bit64/man/as.integer64.character.html'>as.integer64</a></span><span class='o'>(</span><span class='s'>"900000000000"</span><span class='o'>)</span>
<span class='nv'>end</span> <span class='o'>&lt;-</span> <span class='nv'>start</span> <span class='o'>+</span> <span class='m'>1234</span>

<span class='nf'><a href='https://davisvaughan.github.io/ivs/reference/iv.html'>iv</a></span><span class='o'>(</span><span class='nv'>start</span>, <span class='nv'>end</span><span class='o'>)</span>
<span class='c'>#&gt; &lt;iv&lt;integer64&gt;[1]&gt;</span>
<span class='c'>#&gt; [1] [900000000000, 900000001234)</span></code></pre>

</div>

or the `year_month_day` type from [clock](https://clock.r-lib.org):

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>start</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://clock.r-lib.org/reference/year_month_day.html'>year_month_day</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='m'>2019</span>, <span class='m'>2020</span><span class='o'>)</span>, <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='m'>1</span>, <span class='m'>3</span><span class='o'>)</span><span class='o'>)</span>
<span class='nv'>end</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://clock.r-lib.org/reference/year_month_day.html'>year_month_day</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='m'>2020</span>, <span class='m'>2020</span><span class='o'>)</span>, <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='m'>2</span>, <span class='m'>6</span><span class='o'>)</span><span class='o'>)</span>

<span class='nf'><a href='https://davisvaughan.github.io/ivs/reference/iv.html'>iv</a></span><span class='o'>(</span><span class='nv'>start</span>, <span class='nv'>end</span><span class='o'>)</span>
<span class='c'>#&gt; &lt;iv&lt;year_month_day&lt;month&gt;&gt;[2]&gt;</span>
<span class='c'>#&gt; [1] [2019-01, 2020-02) [2020-03, 2020-06)</span></code></pre>

</div>

Interval vectors are always composed of right-open intervals, and the intervals must be strictly increasing. I say more on the practical reasons for this [in the Getting Started vignette](https://davisvaughan.github.io/ivs/articles/ivs.html#structure) if you are interested in learning more.

## Grouping by overlaps

One of the most compelling reasons to use ivs is that it tries to make identifying and merging overlaps within a single interval vector as easy as possible.

Imagine you work for AWS (Amazon Web Services) and you have a database that tracks costs racked up by users that are utilizing your services. The date ranges below represent the intervals over which the cost was accrued, and the intervals don't overlap for a given `(user, service)` pair.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>costs</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://tibble.tidyverse.org/reference/tribble.html'>tribble</a></span><span class='o'>(</span>
  <span class='o'>~</span><span class='nv'>user</span>, <span class='o'>~</span><span class='nv'>service</span>, <span class='o'>~</span><span class='nv'>from</span>, <span class='o'>~</span><span class='nv'>to</span>, <span class='o'>~</span><span class='nv'>cost</span>,
  <span class='m'>1L</span>, <span class='s'>"a"</span>, <span class='s'>"2019-01-01"</span>, <span class='s'>"2019-01-05"</span>, <span class='m'>200.5</span>,
  <span class='m'>1L</span>, <span class='s'>"a"</span>, <span class='s'>"2019-01-12"</span>, <span class='s'>"2019-01-13"</span>, <span class='m'>15.6</span>,
  <span class='m'>1L</span>, <span class='s'>"b"</span>, <span class='s'>"2019-01-03"</span>, <span class='s'>"2019-01-10"</span>, <span class='m'>500.3</span>,
  <span class='m'>2L</span>, <span class='s'>"a"</span>, <span class='s'>"2019-01-02"</span>, <span class='s'>"2019-01-03"</span>, <span class='m'>25.6</span>,
  <span class='m'>2L</span>, <span class='s'>"b"</span>, <span class='s'>"2019-01-01"</span>, <span class='s'>"2019-01-06"</span>, <span class='m'>217.3</span>,
  <span class='m'>2L</span>, <span class='s'>"c"</span>, <span class='s'>"2019-01-03"</span>, <span class='s'>"2019-01-04"</span>, <span class='m'>30</span>,
  <span class='m'>2L</span>, <span class='s'>"c"</span>, <span class='s'>"2019-01-05"</span>, <span class='s'>"2019-01-07"</span>, <span class='m'>66.2</span>
<span class='o'>)</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span>
  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/mutate.html'>mutate</a></span><span class='o'>(</span>
    from <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/as.Date.html'>as.Date</a></span><span class='o'>(</span><span class='nv'>from</span><span class='o'>)</span>,
    to <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/as.Date.html'>as.Date</a></span><span class='o'>(</span><span class='nv'>to</span><span class='o'>)</span>
  <span class='o'>)</span>

<span class='nv'>costs</span>
<span class='c'>#&gt; <span style='color: #555555;'># A tibble: 7 × 5</span></span>
<span class='c'>#&gt;    user service from       to          cost</span>
<span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;int&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>   <span style='color: #555555; font-style: italic;'>&lt;date&gt;</span>     <span style='color: #555555; font-style: italic;'>&lt;date&gt;</span>     <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>1</span>     1 a       2019-01-01 2019-01-05 200. </span>
<span class='c'>#&gt; <span style='color: #555555;'>2</span>     1 a       2019-01-12 2019-01-13  15.6</span>
<span class='c'>#&gt; <span style='color: #555555;'>3</span>     1 b       2019-01-03 2019-01-10 500. </span>
<span class='c'>#&gt; <span style='color: #555555;'>4</span>     2 a       2019-01-02 2019-01-03  25.6</span>
<span class='c'>#&gt; <span style='color: #555555;'>5</span>     2 b       2019-01-01 2019-01-06 217. </span>
<span class='c'>#&gt; <span style='color: #555555;'>6</span>     2 c       2019-01-03 2019-01-04  30  </span>
<span class='c'>#&gt; <span style='color: #555555;'>7</span>     2 c       2019-01-05 2019-01-07  66.2</span></code></pre>

</div>

You might be interested in identifying the contiguous blocks of time that a particular service was in use, regardless of who was using it. To solve this problem, we will first convert our `from/to` dates into a true interval vector using [`iv()`](https://davisvaughan.github.io/ivs/reference/iv.html).

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>costs</span> <span class='o'>&lt;-</span> <span class='nv'>costs</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span>
  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/mutate.html'>mutate</a></span><span class='o'>(</span>
    interval <span class='o'>=</span> <span class='nf'><a href='https://davisvaughan.github.io/ivs/reference/iv.html'>iv</a></span><span class='o'>(</span><span class='nv'>from</span>, <span class='nv'>to</span><span class='o'>)</span>, 
    .keep <span class='o'>=</span> <span class='s'>"unused"</span>
  <span class='o'>)</span>

<span class='nv'>costs</span>
<span class='c'>#&gt; <span style='color: #555555;'># A tibble: 7 × 4</span></span>
<span class='c'>#&gt;    user service  cost                 interval</span>
<span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;int&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>   <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>               <span style='color: #555555; font-style: italic;'>&lt;iv&lt;date&gt;&gt;</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>1</span>     1 a       200.  [2019-01-01, 2019-01-05)</span>
<span class='c'>#&gt; <span style='color: #555555;'>2</span>     1 a        15.6 [2019-01-12, 2019-01-13)</span>
<span class='c'>#&gt; <span style='color: #555555;'>3</span>     1 b       500.  [2019-01-03, 2019-01-10)</span>
<span class='c'>#&gt; <span style='color: #555555;'>4</span>     2 a        25.6 [2019-01-02, 2019-01-03)</span>
<span class='c'>#&gt; <span style='color: #555555;'>5</span>     2 b       217.  [2019-01-01, 2019-01-06)</span>
<span class='c'>#&gt; <span style='color: #555555;'>6</span>     2 c        30   [2019-01-03, 2019-01-04)</span>
<span class='c'>#&gt; <span style='color: #555555;'>7</span>     2 c        66.2 [2019-01-05, 2019-01-07)</span></code></pre>

</div>

Next, we'll use [`iv_groups()`](https://davisvaughan.github.io/ivs/reference/iv-groups.html) on the `interval` column to merge together all of the overlapping intervals. It returns the intervals that remain after all of the overlaps have been merged. Since we want to do this on a per-service basis, we'll group by `service`.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>services</span> <span class='o'>&lt;-</span> <span class='nv'>costs</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span>
  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/group_by.html'>group_by</a></span><span class='o'>(</span><span class='nv'>service</span><span class='o'>)</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span>
  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/summarise.html'>summarise</a></span><span class='o'>(</span>interval <span class='o'>=</span> <span class='nf'><a href='https://davisvaughan.github.io/ivs/reference/iv-groups.html'>iv_groups</a></span><span class='o'>(</span><span class='nv'>interval</span><span class='o'>)</span>, .groups <span class='o'>=</span> <span class='s'>"keep"</span><span class='o'>)</span>

<span class='c'># Note how this merged the two overlapping `service == "b"` intervals</span>
<span class='c'># of [2019-01-03, 2019-01-10) and [2019-01-01, 2019-01-06) into one</span>
<span class='c'># wider interval of [2019-01-01, 2019-01-10)</span>
<span class='nv'>services</span> 
<span class='c'>#&gt; <span style='color: #555555;'># A tibble: 5 × 2</span></span>
<span class='c'>#&gt; <span style='color: #555555;'># Groups:   service [3]</span></span>
<span class='c'>#&gt;   service                 interval</span>
<span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>                 <span style='color: #555555; font-style: italic;'>&lt;iv&lt;date&gt;&gt;</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>1</span> a       [2019-01-01, 2019-01-05)</span>
<span class='c'>#&gt; <span style='color: #555555;'>2</span> a       [2019-01-12, 2019-01-13)</span>
<span class='c'>#&gt; <span style='color: #555555;'>3</span> b       [2019-01-01, 2019-01-10)</span>
<span class='c'>#&gt; <span style='color: #555555;'>4</span> c       [2019-01-03, 2019-01-04)</span>
<span class='c'>#&gt; <span style='color: #555555;'>5</span> c       [2019-01-05, 2019-01-07)</span></code></pre>

</div>

Note that we used [`summarise()`](https://dplyr.tidyverse.org/reference/summarise.html) here rather than [`mutate()`](https://dplyr.tidyverse.org/reference/mutate.html). [`iv_groups()`](https://davisvaughan.github.io/ivs/reference/iv-groups.html) will return a new interval vector that is *shorter* than the original input, so we can't use [`mutate()`](https://dplyr.tidyverse.org/reference/mutate.html). Instead, we are taking advantage of the relatively new feature of [`summarise()`](https://dplyr.tidyverse.org/reference/summarise.html) which allows you to return a per-group result with length \>1.

You also might be interested in the intervals corresponding to when a service *wasn't* being used. I'm getting ahead of myself a little bit, but you could use one of the set operation functions, [`iv_complement()`](https://davisvaughan.github.io/ivs/reference/iv-sets.html), for this. We'll provide (optional) lower and upper bounds for the universe over which to take the complement.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>lower</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/as.Date.html'>as.Date</a></span><span class='o'>(</span><span class='s'>"2019-01-01"</span><span class='o'>)</span>
<span class='nv'>upper</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/as.Date.html'>as.Date</a></span><span class='o'>(</span><span class='s'>"2019-01-15"</span><span class='o'>)</span>

<span class='nv'>services</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span>
  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/summarise.html'>summarise</a></span><span class='o'>(</span>
    not_in_use <span class='o'>=</span> <span class='nf'><a href='https://davisvaughan.github.io/ivs/reference/iv-sets.html'>iv_complement</a></span><span class='o'>(</span><span class='nv'>interval</span>, lower <span class='o'>=</span> <span class='nv'>lower</span>, upper <span class='o'>=</span> <span class='nv'>upper</span><span class='o'>)</span>,
    .groups <span class='o'>=</span> <span class='s'>"drop"</span>
  <span class='o'>)</span>
<span class='c'>#&gt; <span style='color: #555555;'># A tibble: 6 × 2</span></span>
<span class='c'>#&gt;   service               not_in_use</span>
<span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>                 <span style='color: #555555; font-style: italic;'>&lt;iv&lt;date&gt;&gt;</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>1</span> a       [2019-01-05, 2019-01-12)</span>
<span class='c'>#&gt; <span style='color: #555555;'>2</span> a       [2019-01-13, 2019-01-15)</span>
<span class='c'>#&gt; <span style='color: #555555;'>3</span> b       [2019-01-10, 2019-01-15)</span>
<span class='c'>#&gt; <span style='color: #555555;'>4</span> c       [2019-01-01, 2019-01-03)</span>
<span class='c'>#&gt; <span style='color: #555555;'>5</span> c       [2019-01-04, 2019-01-05)</span>
<span class='c'>#&gt; <span style='color: #555555;'>6</span> c       [2019-01-07, 2019-01-15)</span></code></pre>

</div>

Let's go back to `costs` and answer one more question. Let's say you don't care about `service` anymore, and you just want to aggregate the costs over any contiguous date range for a particular `user`. For example, user `1` used service `a` and `b` simultaneously, so you'd like to combine those costs into a single larger interval.

We can try to use [`iv_groups()`](https://davisvaughan.github.io/ivs/reference/iv-groups.html) here, but this isn't quite what we need because it doesn't give us a chance to aggregate the costs:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>costs</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span>
  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/group_by.html'>group_by</a></span><span class='o'>(</span><span class='nv'>user</span><span class='o'>)</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span>
  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/summarise.html'>summarise</a></span><span class='o'>(</span>interval <span class='o'>=</span> <span class='nf'><a href='https://davisvaughan.github.io/ivs/reference/iv-groups.html'>iv_groups</a></span><span class='o'>(</span><span class='nv'>interval</span><span class='o'>)</span>, .groups <span class='o'>=</span> <span class='s'>"drop"</span><span class='o'>)</span>
<span class='c'>#&gt; <span style='color: #555555;'># A tibble: 3 × 2</span></span>
<span class='c'>#&gt;    user                 interval</span>
<span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;int&gt;</span>               <span style='color: #555555; font-style: italic;'>&lt;iv&lt;date&gt;&gt;</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>1</span>     1 [2019-01-01, 2019-01-10)</span>
<span class='c'>#&gt; <span style='color: #555555;'>2</span>     1 [2019-01-12, 2019-01-13)</span>
<span class='c'>#&gt; <span style='color: #555555;'>3</span>     2 [2019-01-01, 2019-01-07)</span></code></pre>

</div>

Instead, we'll use [`iv_identify_group()`](https://davisvaughan.github.io/ivs/reference/iv-groups.html). This returns a new interval vector that has the same length as the old one, and identifies which of the 3 groups returned above that the original interval falls in.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>users</span> <span class='o'>&lt;-</span> <span class='nv'>costs</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span>
  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/select.html'>select</a></span><span class='o'>(</span><span class='o'>-</span><span class='nv'>service</span><span class='o'>)</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span>
  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/group_by.html'>group_by</a></span><span class='o'>(</span><span class='nv'>user</span><span class='o'>)</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span>
  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/mutate.html'>mutate</a></span><span class='o'>(</span>group <span class='o'>=</span> <span class='nf'><a href='https://davisvaughan.github.io/ivs/reference/iv-groups.html'>iv_identify_group</a></span><span class='o'>(</span><span class='nv'>interval</span><span class='o'>)</span><span class='o'>)</span>

<span class='nv'>users</span>
<span class='c'>#&gt; <span style='color: #555555;'># A tibble: 7 × 4</span></span>
<span class='c'>#&gt; <span style='color: #555555;'># Groups:   user [2]</span></span>
<span class='c'>#&gt;    user  cost                 interval                    group</span>
<span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;int&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>               <span style='color: #555555; font-style: italic;'>&lt;iv&lt;date&gt;&gt;</span>               <span style='color: #555555; font-style: italic;'>&lt;iv&lt;date&gt;&gt;</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>1</span>     1 200.  [2019-01-01, 2019-01-05) [2019-01-01, 2019-01-10)</span>
<span class='c'>#&gt; <span style='color: #555555;'>2</span>     1  15.6 [2019-01-12, 2019-01-13) [2019-01-12, 2019-01-13)</span>
<span class='c'>#&gt; <span style='color: #555555;'>3</span>     1 500.  [2019-01-03, 2019-01-10) [2019-01-01, 2019-01-10)</span>
<span class='c'>#&gt; <span style='color: #555555;'>4</span>     2  25.6 [2019-01-02, 2019-01-03) [2019-01-01, 2019-01-07)</span>
<span class='c'>#&gt; <span style='color: #555555;'>5</span>     2 217.  [2019-01-01, 2019-01-06) [2019-01-01, 2019-01-07)</span>
<span class='c'>#&gt; <span style='color: #555555;'>6</span>     2  30   [2019-01-03, 2019-01-04) [2019-01-01, 2019-01-07)</span>
<span class='c'>#&gt; <span style='color: #555555;'>7</span>     2  66.2 [2019-01-05, 2019-01-07) [2019-01-01, 2019-01-07)</span></code></pre>

</div>

This gives us something we can group on so we can [`sum()`](https://rdrr.io/r/base/sum.html) up the costs:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>users</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span>
  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/group_by.html'>group_by</a></span><span class='o'>(</span><span class='nv'>user</span>, <span class='nv'>group</span><span class='o'>)</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span>
  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/summarise.html'>summarise</a></span><span class='o'>(</span>cost <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/sum.html'>sum</a></span><span class='o'>(</span><span class='nv'>cost</span><span class='o'>)</span>, .groups <span class='o'>=</span> <span class='s'>"drop"</span><span class='o'>)</span>
<span class='c'>#&gt; <span style='color: #555555;'># A tibble: 3 × 3</span></span>
<span class='c'>#&gt;    user                    group  cost</span>
<span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;int&gt;</span>               <span style='color: #555555; font-style: italic;'>&lt;iv&lt;date&gt;&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>1</span>     1 [2019-01-01, 2019-01-10) 701. </span>
<span class='c'>#&gt; <span style='color: #555555;'>2</span>     1 [2019-01-12, 2019-01-13)  15.6</span>
<span class='c'>#&gt; <span style='color: #555555;'>3</span>     2 [2019-01-01, 2019-01-07) 339.</span></code></pre>

</div>

## Locating overlaps

While [`iv_groups()`](https://davisvaughan.github.io/ivs/reference/iv-groups.html) is useful for working with overlaps in a single interval vector, you might also find yourself in a situation where you need to identify relationships between multiple vectors. This might be between two interval vectors (where you are detecting if one overlaps another in some way) or between a regular vector and an interval vector (where you want to know if the elements of the vector lie between any of the intervals).

For example, you might want to locate where these two interval vectors overlap:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='c'># iv_pairs() is a useful way to create small ivs from individual intervals</span>
<span class='nv'>needles</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://davisvaughan.github.io/ivs/reference/iv.html'>iv_pairs</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='m'>1</span>, <span class='m'>5</span><span class='o'>)</span>, <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='m'>3</span>, <span class='m'>7</span><span class='o'>)</span>, <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='m'>10</span>, <span class='m'>12</span><span class='o'>)</span><span class='o'>)</span>
<span class='nv'>needles</span>
<span class='c'>#&gt; &lt;iv&lt;double&gt;[3]&gt;</span>
<span class='c'>#&gt; [1] [1, 5)   [3, 7)   [10, 12)</span>

<span class='nv'>haystack</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://davisvaughan.github.io/ivs/reference/iv.html'>iv_pairs</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='m'>0</span>, <span class='m'>6</span><span class='o'>)</span>, <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='m'>13</span>, <span class='m'>15</span><span class='o'>)</span>, <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='m'>0</span>, <span class='m'>2</span><span class='o'>)</span>, <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='m'>7</span>, <span class='m'>8</span><span class='o'>)</span>, <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='m'>4</span>, <span class='m'>5</span><span class='o'>)</span><span class='o'>)</span>
<span class='nv'>haystack</span>
<span class='c'>#&gt; &lt;iv&lt;double&gt;[5]&gt;</span>
<span class='c'>#&gt; [1] [0, 6)   [13, 15) [0, 2)   [7, 8)   [4, 5)</span></code></pre>

</div>

Ideally you'd like to be notified of the fact that `[1, 5)` from `needles` overlaps with `[0, 6)`, `[0, 2)` and `[4, 5)` from `haystack`. [`iv_locate_overlaps()`](https://davisvaughan.github.io/ivs/reference/relation-locate.html) allows you to do exactly this, and returns a data frame of the locations where the two interval vectors overlap.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>locations</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://davisvaughan.github.io/ivs/reference/relation-locate.html'>iv_locate_overlaps</a></span><span class='o'>(</span><span class='nv'>needles</span>, <span class='nv'>haystack</span><span class='o'>)</span>
<span class='nv'>locations</span>
<span class='c'>#&gt;   needles haystack</span>
<span class='c'>#&gt; 1       1        1</span>
<span class='c'>#&gt; 2       1        3</span>
<span class='c'>#&gt; 3       1        5</span>
<span class='c'>#&gt; 4       2        1</span>
<span class='c'>#&gt; 5       2        5</span>
<span class='c'>#&gt; 6       3       NA</span></code></pre>

</div>

You can hand this data frame off to [`iv_align()`](https://davisvaughan.github.io/ivs/reference/iv_align.html), along with the original inputs, and it will join them together based on their overlapping locations:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://davisvaughan.github.io/ivs/reference/iv_align.html'>iv_align</a></span><span class='o'>(</span><span class='nv'>needles</span>, <span class='nv'>haystack</span>, locations <span class='o'>=</span> <span class='nv'>locations</span><span class='o'>)</span>
<span class='c'>#&gt;    needles haystack</span>
<span class='c'>#&gt; 1   [1, 5)   [0, 6)</span>
<span class='c'>#&gt; 2   [1, 5)   [0, 2)</span>
<span class='c'>#&gt; 3   [1, 5)   [4, 5)</span>
<span class='c'>#&gt; 4   [3, 7)   [0, 6)</span>
<span class='c'>#&gt; 5   [3, 7)   [4, 5)</span>
<span class='c'>#&gt; 6 [10, 12) [NA, NA)</span></code></pre>

</div>

You'll notice that `[10, 12)` from `needles` didn't overlap with anything from `haystack`, so it was aligned with a missing interval.

[`iv_locate_overlaps()`](https://davisvaughan.github.io/ivs/reference/relation-locate.html) has a number of options to tweak the type of overlap you are looking for. For example, you can change the `type` from its default value of `"any"` overlap to instead restrict it to cases where `needles` is `"within"` the `haystack` intervals, or to cases where it `"contains"` them. You can also change what happens when there is `no_match`, like with `[10, 12)` from above. If you don't want to see unmatched needles in the result, you can `"drop"` them:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>locations</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://davisvaughan.github.io/ivs/reference/relation-locate.html'>iv_locate_overlaps</a></span><span class='o'>(</span><span class='nv'>needles</span>, <span class='nv'>haystack</span>, no_match <span class='o'>=</span> <span class='s'>"drop"</span><span class='o'>)</span>
<span class='nf'><a href='https://davisvaughan.github.io/ivs/reference/iv_align.html'>iv_align</a></span><span class='o'>(</span><span class='nv'>needles</span>, <span class='nv'>haystack</span>, locations <span class='o'>=</span> <span class='nv'>locations</span><span class='o'>)</span>
<span class='c'>#&gt;   needles haystack</span>
<span class='c'>#&gt; 1  [1, 5)   [0, 6)</span>
<span class='c'>#&gt; 2  [1, 5)   [0, 2)</span>
<span class='c'>#&gt; 3  [1, 5)   [4, 5)</span>
<span class='c'>#&gt; 4  [3, 7)   [0, 6)</span>
<span class='c'>#&gt; 5  [3, 7)   [4, 5)</span></code></pre>

</div>

Other related functionality includes:

-   [`iv_locate_precedes()`](https://davisvaughan.github.io/ivs/reference/relation-locate.html) and [`iv_locate_follows()`](https://davisvaughan.github.io/ivs/reference/relation-locate.html) to determine where one iv precedes or follows another.

-   [`iv_locate_between()`](https://davisvaughan.github.io/ivs/reference/iv_locate_between.html) to determine if elements of a vector fall *between* the intervals in an iv.

-   [`iv_overlaps()`](https://davisvaughan.github.io/ivs/reference/relation-detect.html) which works like [`iv_locate_overlaps()`](https://davisvaughan.github.io/ivs/reference/relation-locate.html) but just returns a logical vector detecting if there were any overlapping intervals at all.

## Counting overlaps

Sometimes you just need the counts of the number of overlaps rather than the actual locations of them. For example, say your business has a subscription service and you'd like to compute a rolling monthly count of the total number of currently active subscriptions (i.e. in January 2019, how many subscriptions were active?). Customers are only allowed to have one subscription active at once, but they may cancel it and reactivate it at any time. If a customer was active at any point during the month, then they are counted in that month.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>enrollments</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://tibble.tidyverse.org/reference/tribble.html'>tribble</a></span><span class='o'>(</span>
  <span class='o'>~</span><span class='nv'>name</span>,      <span class='o'>~</span><span class='nv'>start</span>,          <span class='o'>~</span><span class='nv'>end</span>,
  <span class='s'>"Amy"</span>,      <span class='s'>"1, Jan, 2017"</span>,  <span class='s'>"30, Jul, 2018"</span>,
  <span class='s'>"Franklin"</span>, <span class='s'>"1, Jan, 2017"</span>,  <span class='s'>"19, Feb, 2017"</span>,
  <span class='s'>"Franklin"</span>, <span class='s'>"5, Jun, 2017"</span>,  <span class='s'>"4, Feb, 2018"</span>,
  <span class='s'>"Franklin"</span>, <span class='s'>"21, Oct, 2018"</span>, <span class='s'>"9, Mar, 2019"</span>,
  <span class='s'>"Samir"</span>,    <span class='s'>"1, Jan, 2017"</span>,  <span class='s'>"4, Feb, 2017"</span>,
  <span class='s'>"Samir"</span>,    <span class='s'>"5, Apr, 2017"</span>,  <span class='s'>"12, Jun, 2018"</span>
<span class='o'>)</span>

<span class='c'># Parse these into "day" precision year-month-day objects</span>
<span class='nv'>enrollments</span> <span class='o'>&lt;-</span> <span class='nv'>enrollments</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span>
  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/mutate.html'>mutate</a></span><span class='o'>(</span>
    start <span class='o'>=</span> <span class='nf'><a href='https://clock.r-lib.org/reference/year_month_day_parse.html'>year_month_day_parse</a></span><span class='o'>(</span><span class='nv'>start</span>, format <span class='o'>=</span> <span class='s'>"%d, %b, %Y"</span><span class='o'>)</span>,
    end <span class='o'>=</span> <span class='nf'><a href='https://clock.r-lib.org/reference/year_month_day_parse.html'>year_month_day_parse</a></span><span class='o'>(</span><span class='nv'>end</span>, format <span class='o'>=</span> <span class='s'>"%d, %b, %Y"</span><span class='o'>)</span>,
  <span class='o'>)</span>

<span class='nv'>enrollments</span>
<span class='c'>#&gt; <span style='color: #555555;'># A tibble: 6 × 3</span></span>
<span class='c'>#&gt;   name     start      end       </span>
<span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>    <span style='color: #555555; font-style: italic;'>&lt;ymd&lt;day&gt;&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;ymd&lt;day&gt;&gt;</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>1</span> Amy      2017-01-01 2018-07-30</span>
<span class='c'>#&gt; <span style='color: #555555;'>2</span> Franklin 2017-01-01 2017-02-19</span>
<span class='c'>#&gt; <span style='color: #555555;'>3</span> Franklin 2017-06-05 2018-02-04</span>
<span class='c'>#&gt; <span style='color: #555555;'>4</span> Franklin 2018-10-21 2019-03-09</span>
<span class='c'>#&gt; <span style='color: #555555;'>5</span> Samir    2017-01-01 2017-02-04</span>
<span class='c'>#&gt; <span style='color: #555555;'>6</span> Samir    2017-04-05 2018-06-12</span></code></pre>

</div>

Even though we have day precision information, we only actually need month precision intervals to answer this question. We'll use [`calendar_narrow()`](https://clock.r-lib.org/reference/calendar_narrow.html) from clock to convert our `"day"` precision dates to `"month"` precision ones to reflect this. We'll also add 1 month to the `end` intervals to reflect the fact that the end month is open (remember, ivs are half-open).

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>enrollments</span> <span class='o'>&lt;-</span> <span class='nv'>enrollments</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span>
  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/mutate.html'>mutate</a></span><span class='o'>(</span>
    start <span class='o'>=</span> <span class='nf'><a href='https://clock.r-lib.org/reference/calendar_narrow.html'>calendar_narrow</a></span><span class='o'>(</span><span class='nv'>start</span>, <span class='s'>"month"</span><span class='o'>)</span>,
    end <span class='o'>=</span> <span class='nf'><a href='https://clock.r-lib.org/reference/calendar_narrow.html'>calendar_narrow</a></span><span class='o'>(</span><span class='nv'>end</span>, <span class='s'>"month"</span><span class='o'>)</span> <span class='o'>+</span> <span class='m'>1L</span>
  <span class='o'>)</span>

<span class='nv'>enrollments</span>
<span class='c'>#&gt; <span style='color: #555555;'># A tibble: 6 × 3</span></span>
<span class='c'>#&gt;   name     start        end         </span>
<span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>    <span style='color: #555555; font-style: italic;'>&lt;ymd&lt;month&gt;&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;ymd&lt;month&gt;&gt;</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>1</span> Amy      2017-01      2018-08     </span>
<span class='c'>#&gt; <span style='color: #555555;'>2</span> Franklin 2017-01      2017-03     </span>
<span class='c'>#&gt; <span style='color: #555555;'>3</span> Franklin 2017-06      2018-03     </span>
<span class='c'>#&gt; <span style='color: #555555;'>4</span> Franklin 2018-10      2019-04     </span>
<span class='c'>#&gt; <span style='color: #555555;'>5</span> Samir    2017-01      2017-03     </span>
<span class='c'>#&gt; <span style='color: #555555;'>6</span> Samir    2017-04      2018-07</span>

<span class='nv'>enrollments</span> <span class='o'>&lt;-</span> <span class='nv'>enrollments</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span>
  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/mutate.html'>mutate</a></span><span class='o'>(</span>active <span class='o'>=</span> <span class='nf'><a href='https://davisvaughan.github.io/ivs/reference/iv.html'>iv</a></span><span class='o'>(</span><span class='nv'>start</span>, <span class='nv'>end</span><span class='o'>)</span>, .keep <span class='o'>=</span> <span class='s'>"unused"</span><span class='o'>)</span>

<span class='nv'>enrollments</span>
<span class='c'>#&gt; <span style='color: #555555;'># A tibble: 6 × 2</span></span>
<span class='c'>#&gt;   name                 active</span>
<span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>      <span style='color: #555555; font-style: italic;'>&lt;iv&lt;ymd&lt;month&gt;&gt;&gt;</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>1</span> Amy      [2017-01, 2018-08)</span>
<span class='c'>#&gt; <span style='color: #555555;'>2</span> Franklin [2017-01, 2017-03)</span>
<span class='c'>#&gt; <span style='color: #555555;'>3</span> Franklin [2017-06, 2018-03)</span>
<span class='c'>#&gt; <span style='color: #555555;'>4</span> Franklin [2018-10, 2019-04)</span>
<span class='c'>#&gt; <span style='color: #555555;'>5</span> Samir    [2017-01, 2017-03)</span>
<span class='c'>#&gt; <span style='color: #555555;'>6</span> Samir    [2017-04, 2018-07)</span></code></pre>

</div>

To answer this question, we are going to need to create a sequential vector of months that span the entire range of intervals. This starts at the smallest `start` and goes to the largest `end`. Because the `end` is half-open, there won't be any hits for that month, so we won't include it.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>bounds</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/range.html'>range</a></span><span class='o'>(</span><span class='nv'>enrollments</span><span class='o'>$</span><span class='nv'>active</span><span class='o'>)</span>
<span class='nv'>lower</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://davisvaughan.github.io/ivs/reference/iv-accessors.html'>iv_start</a></span><span class='o'>(</span><span class='nv'>bounds</span><span class='o'>[[</span><span class='m'>1</span><span class='o'>]</span><span class='o'>]</span><span class='o'>)</span>
<span class='nv'>upper</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://davisvaughan.github.io/ivs/reference/iv-accessors.html'>iv_end</a></span><span class='o'>(</span><span class='nv'>bounds</span><span class='o'>[[</span><span class='m'>2</span><span class='o'>]</span><span class='o'>]</span><span class='o'>)</span> <span class='o'>-</span> <span class='m'>1L</span>

<span class='nv'>months</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://tibble.tidyverse.org/reference/tibble.html'>tibble</a></span><span class='o'>(</span>month <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/seq.html'>seq</a></span><span class='o'>(</span><span class='nv'>lower</span>, <span class='nv'>upper</span>, by <span class='o'>=</span> <span class='m'>1</span><span class='o'>)</span><span class='o'>)</span>

<span class='nv'>months</span>
<span class='c'>#&gt; <span style='color: #555555;'># A tibble: 27 × 1</span></span>
<span class='c'>#&gt;    month       </span>
<span class='c'>#&gt;    <span style='color: #555555; font-style: italic;'>&lt;ymd&lt;month&gt;&gt;</span></span>
<span class='c'>#&gt; <span style='color: #555555;'> 1</span> 2017-01     </span>
<span class='c'>#&gt; <span style='color: #555555;'> 2</span> 2017-02     </span>
<span class='c'>#&gt; <span style='color: #555555;'> 3</span> 2017-03     </span>
<span class='c'>#&gt; <span style='color: #555555;'> 4</span> 2017-04     </span>
<span class='c'>#&gt; <span style='color: #555555;'> 5</span> 2017-05     </span>
<span class='c'>#&gt; <span style='color: #555555;'> 6</span> 2017-06     </span>
<span class='c'>#&gt; <span style='color: #555555;'> 7</span> 2017-07     </span>
<span class='c'>#&gt; <span style='color: #555555;'> 8</span> 2017-08     </span>
<span class='c'>#&gt; <span style='color: #555555;'> 9</span> 2017-09     </span>
<span class='c'>#&gt; <span style='color: #555555;'>10</span> 2017-10     </span>
<span class='c'>#&gt; <span style='color: #555555;'># … with 17 more rows</span></span></code></pre>

</div>

To finish up, we need to add a column to `months` to represent the number of subscriptions that were active in that month. To do this we can use [`iv_count_between()`](https://davisvaughan.github.io/ivs/reference/iv_count_between.html), which returns an integer vector corresponding to the number of times the `i`-th month fell between any of the intervals in the active subscription interval vector.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>months</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span>
  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/mutate.html'>mutate</a></span><span class='o'>(</span>count <span class='o'>=</span> <span class='nf'><a href='https://davisvaughan.github.io/ivs/reference/iv_count_between.html'>iv_count_between</a></span><span class='o'>(</span><span class='nv'>month</span>, <span class='nv'>enrollments</span><span class='o'>$</span><span class='nv'>active</span><span class='o'>)</span><span class='o'>)</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span>
  <span class='nf'><a href='https://rdrr.io/r/base/print.html'>print</a></span><span class='o'>(</span>n <span class='o'>=</span> <span class='kc'>Inf</span><span class='o'>)</span>
<span class='c'>#&gt; <span style='color: #555555;'># A tibble: 27 × 2</span></span>
<span class='c'>#&gt;    month        count</span>
<span class='c'>#&gt;    <span style='color: #555555; font-style: italic;'>&lt;ymd&lt;month&gt;&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;int&gt;</span></span>
<span class='c'>#&gt; <span style='color: #555555;'> 1</span> 2017-01          3</span>
<span class='c'>#&gt; <span style='color: #555555;'> 2</span> 2017-02          3</span>
<span class='c'>#&gt; <span style='color: #555555;'> 3</span> 2017-03          1</span>
<span class='c'>#&gt; <span style='color: #555555;'> 4</span> 2017-04          2</span>
<span class='c'>#&gt; <span style='color: #555555;'> 5</span> 2017-05          2</span>
<span class='c'>#&gt; <span style='color: #555555;'> 6</span> 2017-06          3</span>
<span class='c'>#&gt; <span style='color: #555555;'> 7</span> 2017-07          3</span>
<span class='c'>#&gt; <span style='color: #555555;'> 8</span> 2017-08          3</span>
<span class='c'>#&gt; <span style='color: #555555;'> 9</span> 2017-09          3</span>
<span class='c'>#&gt; <span style='color: #555555;'>10</span> 2017-10          3</span>
<span class='c'>#&gt; <span style='color: #555555;'>11</span> 2017-11          3</span>
<span class='c'>#&gt; <span style='color: #555555;'>12</span> 2017-12          3</span>
<span class='c'>#&gt; <span style='color: #555555;'>13</span> 2018-01          3</span>
<span class='c'>#&gt; <span style='color: #555555;'>14</span> 2018-02          3</span>
<span class='c'>#&gt; <span style='color: #555555;'>15</span> 2018-03          2</span>
<span class='c'>#&gt; <span style='color: #555555;'>16</span> 2018-04          2</span>
<span class='c'>#&gt; <span style='color: #555555;'>17</span> 2018-05          2</span>
<span class='c'>#&gt; <span style='color: #555555;'>18</span> 2018-06          2</span>
<span class='c'>#&gt; <span style='color: #555555;'>19</span> 2018-07          1</span>
<span class='c'>#&gt; <span style='color: #555555;'>20</span> 2018-08          0</span>
<span class='c'>#&gt; <span style='color: #555555;'>21</span> 2018-09          0</span>
<span class='c'>#&gt; <span style='color: #555555;'>22</span> 2018-10          1</span>
<span class='c'>#&gt; <span style='color: #555555;'>23</span> 2018-11          1</span>
<span class='c'>#&gt; <span style='color: #555555;'>24</span> 2018-12          1</span>
<span class='c'>#&gt; <span style='color: #555555;'>25</span> 2019-01          1</span>
<span class='c'>#&gt; <span style='color: #555555;'>26</span> 2019-02          1</span>
<span class='c'>#&gt; <span style='color: #555555;'>27</span> 2019-03          1</span></code></pre>

</div>

Also available are [`iv_count_overlaps()`](https://davisvaughan.github.io/ivs/reference/relation-count.html), [`iv_count_precedes()`](https://davisvaughan.github.io/ivs/reference/relation-count.html), and [`iv_count_follows()`](https://davisvaughan.github.io/ivs/reference/relation-count.html) for counting relationships between two ivs.

## Set operations

There are a number of set theoretical operations that you can use on ivs. These are:

-   [`iv_complement()`](https://davisvaughan.github.io/ivs/reference/iv-sets.html)

-   [`iv_union()`](https://davisvaughan.github.io/ivs/reference/iv-sets.html)

-   [`iv_intersect()`](https://davisvaughan.github.io/ivs/reference/iv-sets.html)

-   [`iv_difference()`](https://davisvaughan.github.io/ivs/reference/iv-sets.html)

-   [`iv_symmetric_difference()`](https://davisvaughan.github.io/ivs/reference/iv-sets.html)

[`iv_complement()`](https://davisvaughan.github.io/ivs/reference/iv-sets.html) works on a single iv, while all the others work on two ivs at a time. The easiest way to think about these functions is to imagine [`iv_groups()`](https://davisvaughan.github.io/ivs/reference/iv-groups.html) being called on each of the inputs first (to reduce them down to their minimal form) before applying the operation.

[`iv_complement()`](https://davisvaughan.github.io/ivs/reference/iv-sets.html) computes the set complement of the intervals in a single iv.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>x</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://davisvaughan.github.io/ivs/reference/iv.html'>iv_pairs</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='m'>1</span>, <span class='m'>3</span><span class='o'>)</span>, <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='m'>2</span>, <span class='m'>5</span><span class='o'>)</span>, <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='m'>10</span>, <span class='m'>12</span><span class='o'>)</span>, <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='m'>13</span>, <span class='m'>15</span><span class='o'>)</span><span class='o'>)</span>
<span class='nv'>x</span>
<span class='c'>#&gt; &lt;iv&lt;double&gt;[4]&gt;</span>
<span class='c'>#&gt; [1] [1, 3)   [2, 5)   [10, 12) [13, 15)</span>

<span class='nf'><a href='https://davisvaughan.github.io/ivs/reference/iv-sets.html'>iv_complement</a></span><span class='o'>(</span><span class='nv'>x</span><span class='o'>)</span>
<span class='c'>#&gt; &lt;iv&lt;double&gt;[2]&gt;</span>
<span class='c'>#&gt; [1] [5, 10)  [12, 13)</span></code></pre>

</div>

By default, [`iv_complement()`](https://davisvaughan.github.io/ivs/reference/iv-sets.html) uses the smallest/largest values of its input as the bounds to compute the complement over, but, as we showed back in the [`iv_groups()`](https://davisvaughan.github.io/ivs/reference/iv-groups.html) section, you can supply bounds explicitly with `lower` and `upper`:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://davisvaughan.github.io/ivs/reference/iv-sets.html'>iv_complement</a></span><span class='o'>(</span><span class='nv'>x</span>, lower <span class='o'>=</span> <span class='m'>0</span>, upper <span class='o'>=</span> <span class='kc'>Inf</span><span class='o'>)</span>
<span class='c'>#&gt; &lt;iv&lt;double&gt;[4]&gt;</span>
<span class='c'>#&gt; [1] [0, 1)    [5, 10)   [12, 13)  [15, Inf)</span></code></pre>

</div>

[`iv_union()`](https://davisvaughan.github.io/ivs/reference/iv-sets.html) takes the union of two ivs. It answers the question, "Which intervals are in `x` or `y`?"

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>y</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://davisvaughan.github.io/ivs/reference/iv.html'>iv_pairs</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='o'>-</span><span class='m'>5</span>, <span class='m'>0</span><span class='o'>)</span>, <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='m'>1</span>, <span class='m'>4</span><span class='o'>)</span>, <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='m'>8</span>, <span class='m'>10</span><span class='o'>)</span>, <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='m'>15</span>, <span class='m'>16</span><span class='o'>)</span><span class='o'>)</span>

<span class='nv'>x</span>
<span class='c'>#&gt; &lt;iv&lt;double&gt;[4]&gt;</span>
<span class='c'>#&gt; [1] [1, 3)   [2, 5)   [10, 12) [13, 15)</span>
<span class='nv'>y</span>
<span class='c'>#&gt; &lt;iv&lt;double&gt;[4]&gt;</span>
<span class='c'>#&gt; [1] [-5, 0)  [1, 4)   [8, 10)  [15, 16)</span>

<span class='nf'><a href='https://davisvaughan.github.io/ivs/reference/iv-sets.html'>iv_union</a></span><span class='o'>(</span><span class='nv'>x</span>, <span class='nv'>y</span><span class='o'>)</span>
<span class='c'>#&gt; &lt;iv&lt;double&gt;[4]&gt;</span>
<span class='c'>#&gt; [1] [-5, 0)  [1, 5)   [8, 12)  [13, 16)</span></code></pre>

</div>

[`iv_intersect()`](https://davisvaughan.github.io/ivs/reference/iv-sets.html) takes the intersection of two ivs. It answers the question, "Which intervals are in `x` and `y`?"

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://davisvaughan.github.io/ivs/reference/iv-sets.html'>iv_intersect</a></span><span class='o'>(</span><span class='nv'>x</span>, <span class='nv'>y</span><span class='o'>)</span>
<span class='c'>#&gt; &lt;iv&lt;double&gt;[1]&gt;</span>
<span class='c'>#&gt; [1] [1, 4)</span></code></pre>

</div>

[`iv_difference()`](https://davisvaughan.github.io/ivs/reference/iv-sets.html) takes the asymmetrical difference of two ivs. It answers the question, "Which intervals are in `x` but not `y`?"

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://davisvaughan.github.io/ivs/reference/iv-sets.html'>iv_difference</a></span><span class='o'>(</span><span class='nv'>x</span>, <span class='nv'>y</span><span class='o'>)</span>
<span class='c'>#&gt; &lt;iv&lt;double&gt;[3]&gt;</span>
<span class='c'>#&gt; [1] [4, 5)   [10, 12) [13, 15)</span></code></pre>

</div>

## Inspiration

ivs was inspired by quite a few places!

-   [IRanges](https://github.com/Bioconductor/IRanges) is a Bioconductor package that served as the biggest inspiration for this package. It is mainly focused on integer intervals for use with genomics, and uses S4 in a way that unfortunately means that their interval objects can't currently be used as columns in a tibble, but is otherwise a really impressive package.

-   [Maintaining Knowledge about Temporal Intervals](https://cse.unl.edu/~choueiry/Documents/Allen-CACM1983.pdf) is a paper by James Allen that a number of these functions are based on. It is also a great primer on integer algebra.

-   [data.table](https://github.com/Rdatatable/data.table) contains a function named `foverlaps()` for detecting different types of overlaps. It was also inspired by [`IRanges::findOverlaps()`](https://rdrr.io/pkg/IRanges/man/findOverlaps-methods.html). They also have support for non-equi joins, which can also accomplish some of this.

