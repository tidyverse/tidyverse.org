---
output: hugodown::hugo_document
slug: dplyr-1-1-0-is-coming-soon
title: dplyr 1.1.0 is coming soon
date: 2022-11-28
author: Davis Vaughan
description: >
    dplyr 1.1.0 is coming soon! This post introduces some of the exciting new
    features coming in 1.1.0, and includes a call-for-feedback as we finalize
    the release.
photo:
  url: https://unsplash.com/photos/aId-xYRTlEc
  author: Markus Winkler
categories: [package] 
tags: [dplyr, dplyr-1-1-0]
editor_options: 
  chunk_output_type: console
rmd_hash: 8285893513da160d

---

[dplyr](https://dplyr.tidyverse.org/dev/) 1.1.0 is coming soon! We haven't started the official release process yet (where we inform maintainers), but that will start in the next few weeks, and then dplyr 1.1.0 is likely to be submitted to CRAN in late January 2023.

This is an exciting release for dplyr, incorporating a number of features that have been in flight for years, including:

-   An inline alternative to [`group_by()`](https://dplyr.tidyverse.org/reference/group_by.html) that implements temporary grouping

-   New join types, such as non-equi joins

-   [`arrange()`](https://dplyr.tidyverse.org/reference/arrange.html) improvements with character vectors

-   [`reframe()`](https://dplyr.tidyverse.org/reference/reframe.html), a generalization of [`summarise()`](https://dplyr.tidyverse.org/reference/summarise.html)

This pre-release blog post will discuss these new features in more detail. By releasing this post before 1.1.0 is sent to CRAN, we're hoping to get your feedback to catch any potential problems that we've missed! If you do find a bug, or have general feedback about the new features, we welcome discussion on the [dplyr issues page](https://github.com/tidyverse/dplyr/issues).

You can see a full list of changes in the [release notes](https://dplyr.tidyverse.org/dev/news/index.html). There are many additional improvements that couldn't fit in a single blog post!

dplyr 1.1.0 is not on CRAN yet, but you can install the development version from GitHub with:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'>pak</span><span class='nf'>::</span><span class='nf'><a href='http://pak.r-lib.org/reference/pak.html'>pak</a></span><span class='o'>(</span><span class='s'>"tidyverse/dplyr"</span><span class='o'>)</span></span></code></pre>

</div>

The development version is mostly stable, but is still subject to minor changes before the official release. We don't encourage relying on it for production usage, but we would love for you to try out these new features.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://dplyr.tidyverse.org'>dplyr</a></span><span class='o'>)</span></span>
<span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://clock.r-lib.org'>clock</a></span><span class='o'>)</span></span>
<span><span class='nf'><a href='https://rdrr.io/r/base/Random.html'>set.seed</a></span><span class='o'>(</span><span class='m'>12345</span><span class='o'>)</span></span></code></pre>

</div>

## Temporary grouping with `.by`

Verbs that work "by group," such as [`mutate()`](https://dplyr.tidyverse.org/reference/mutate.html), [`summarise()`](https://dplyr.tidyverse.org/reference/summarise.html), [`filter()`](https://dplyr.tidyverse.org/reference/filter.html), and [`slice()`](https://dplyr.tidyverse.org/reference/slice.html), have gained an experimental new argument, `.by`, which allows for inline and temporary grouping. Grouping radically affects the computation of the dplyr verb you use it with, and one of the goals of `.by` is to allow you to place that grouping specification alongside the code that actually uses it. As an added benefit, with `.by` you no longer need to remember to [`ungroup()`](https://dplyr.tidyverse.org/reference/group_by.html) after [`summarise()`](https://dplyr.tidyverse.org/reference/summarise.html), and [`summarise()`](https://dplyr.tidyverse.org/reference/summarise.html) won't ever message you about how it's handling the groups!

This feature was inspired by [data.table](https://cran.r-project.org/package=data.table), which has always used per-operation grouping.

We'll explore `.by` with this `expenses` dataset, containing various `cost`s tracked across `id` and `region`.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>expenses</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://tibble.tidyverse.org/reference/tibble.html'>tibble</a></span><span class='o'>(</span></span>
<span>  id <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='m'>1</span>, <span class='m'>2</span>, <span class='m'>1</span>, <span class='m'>3</span>, <span class='m'>1</span>, <span class='m'>2</span>, <span class='m'>3</span><span class='o'>)</span>,</span>
<span>  region <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"A"</span>, <span class='s'>"A"</span>, <span class='s'>"A"</span>, <span class='s'>"B"</span>, <span class='s'>"B"</span>, <span class='s'>"A"</span>, <span class='s'>"A"</span><span class='o'>)</span>,</span>
<span>  cost <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='m'>25</span>, <span class='m'>20</span>, <span class='m'>19</span>, <span class='m'>12</span>, <span class='m'>9</span>, <span class='m'>6</span>, <span class='m'>6</span><span class='o'>)</span></span>
<span><span class='o'>)</span></span>
<span><span class='nv'>expenses</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 7 × 3</span></span></span>
<span><span class='c'>#&gt;      id region  cost</span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>  <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span>     1 A         25</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span>     2 A         20</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>3</span>     1 A         19</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>4</span>     3 B         12</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>5</span>     1 B          9</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>6</span>     2 A          6</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>7</span>     3 A          6</span></span>
<span></span></code></pre>

</div>

If I were to ask you to compute the average `cost` per `region`, you'd probably write something like:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>expenses</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/group_by.html'>group_by</a></span><span class='o'>(</span><span class='nv'>region</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/summarise.html'>summarise</a></span><span class='o'>(</span>cost <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/mean.html'>mean</a></span><span class='o'>(</span><span class='nv'>cost</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 2 × 2</span></span></span>
<span><span class='c'>#&gt;   region  cost</span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>  <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span> A       15.2</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span> B       10.5</span></span>
<span></span></code></pre>

</div>

With `.by`, you can now write:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>expenses</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/summarise.html'>summarise</a></span><span class='o'>(</span>cost <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/mean.html'>mean</a></span><span class='o'>(</span><span class='nv'>cost</span><span class='o'>)</span>, .by <span class='o'>=</span> <span class='nv'>region</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 2 × 2</span></span></span>
<span><span class='c'>#&gt;   region  cost</span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>  <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span> A       15.2</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span> B       10.5</span></span>
<span></span></code></pre>

</div>

These two particular results look the same, but the behavior of `.by` diverges from [`group_by()`](https://dplyr.tidyverse.org/reference/group_by.html) when multiple group columns are involved:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>expenses</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/group_by.html'>group_by</a></span><span class='o'>(</span><span class='nv'>id</span>, <span class='nv'>region</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/summarise.html'>summarise</a></span><span class='o'>(</span>cost <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/mean.html'>mean</a></span><span class='o'>(</span><span class='nv'>cost</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; `summarise()` has grouped output by 'id'. You can override using the `.groups`</span></span>
<span><span class='c'>#&gt; argument.</span></span>
<span></span><span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 5 × 3</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># Groups:   id [3]</span></span></span>
<span><span class='c'>#&gt;      id region  cost</span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>  <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span>     1 A         22</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span>     1 B          9</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>3</span>     2 A         13</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>4</span>     3 A          6</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>5</span>     3 B         12</span></span>
<span></span></code></pre>

</div>

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>expenses</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/summarise.html'>summarise</a></span><span class='o'>(</span>cost <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/mean.html'>mean</a></span><span class='o'>(</span><span class='nv'>cost</span><span class='o'>)</span>, .by <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='nv'>id</span>, <span class='nv'>region</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 5 × 3</span></span></span>
<span><span class='c'>#&gt;      id region  cost</span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>  <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span>     1 A         22</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span>     2 A         13</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>3</span>     3 B         12</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>4</span>     1 B          9</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>5</span>     3 A          6</span></span>
<span></span></code></pre>

</div>

Usage of `.by` always results in an ungrouped data frame, regardless of the number of group columns involved.

You might also recognize that these results aren't returned in exactly the same order. [`group_by()`](https://dplyr.tidyverse.org/reference/group_by.html) always sorts the grouping keys in ascending order, but `.by` retains the original ordering found in the data. If you need ordered summaries with `.by`, we recommend calling [`arrange()`](https://dplyr.tidyverse.org/reference/arrange.html) explicitly before or after summarizing.

While here we've focused on using `.by` with [`summarise()`](https://dplyr.tidyverse.org/reference/summarise.html), it also works with other verbs, like [`mutate()`](https://dplyr.tidyverse.org/reference/mutate.html) and [`slice()`](https://dplyr.tidyverse.org/reference/slice.html):

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>expenses</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/mutate.html'>mutate</a></span><span class='o'>(</span>mean <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/mean.html'>mean</a></span><span class='o'>(</span><span class='nv'>cost</span><span class='o'>)</span>, .by <span class='o'>=</span> <span class='nv'>region</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 7 × 4</span></span></span>
<span><span class='c'>#&gt;      id region  cost  mean</span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>  <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span>     1 A         25  15.2</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span>     2 A         20  15.2</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>3</span>     1 A         19  15.2</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>4</span>     3 B         12  10.5</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>5</span>     1 B          9  10.5</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>6</span>     2 A          6  15.2</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>7</span>     3 A          6  15.2</span></span>
<span></span><span></span>
<span><span class='nv'>expenses</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/slice.html'>slice</a></span><span class='o'>(</span><span class='m'>2</span>, .by <span class='o'>=</span> <span class='nv'>region</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 2 × 3</span></span></span>
<span><span class='c'>#&gt;      id region  cost</span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>  <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span>     2 A         20</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span>     1 B          9</span></span>
<span></span></code></pre>

</div>

[`group_by()`](https://dplyr.tidyverse.org/reference/group_by.html) won't ever disappear, but we are having a lot of fun writing new code with `.by`, and we think you will too.

## Join improvements

All of the join functions in dplyr, such as [`left_join()`](https://dplyr.tidyverse.org/reference/mutate-joins.html), now accept a flexible join specification created through the new [`join_by()`](https://dplyr.tidyverse.org/reference/join_by.html) helper. [`join_by()`](https://dplyr.tidyverse.org/reference/join_by.html) allows you to specify your join conditions as expressions rather than as named character vectors.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://dplyr.tidyverse.org/reference/join_by.html'>join_by</a></span><span class='o'>(</span><span class='nv'>x_id</span> <span class='o'>==</span> <span class='nv'>y_id</span>, <span class='nv'>region</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; Join By:</span></span>
<span><span class='c'>#&gt; - x_id == y_id</span></span>
<span><span class='c'>#&gt; - region</span></span>
<span></span></code></pre>

</div>

This join specification matches `x_id` in the left-hand data frame with `y_id` in the right-hand one, and also matches between a commonly named `region` column, computing the following equi-join:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>df1</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://tibble.tidyverse.org/reference/tibble.html'>tibble</a></span><span class='o'>(</span>x_id <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='m'>1</span>, <span class='m'>2</span>, <span class='m'>2</span><span class='o'>)</span>, region <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"A"</span>, <span class='s'>"B"</span>, <span class='s'>"A"</span><span class='o'>)</span>, x <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='m'>5</span>, <span class='m'>10</span>, <span class='m'>4</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='nv'>df2</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://tibble.tidyverse.org/reference/tibble.html'>tibble</a></span><span class='o'>(</span>y_id <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='m'>2</span>, <span class='m'>1</span>, <span class='m'>2</span><span class='o'>)</span>, region <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"A"</span>, <span class='s'>"A"</span>, <span class='s'>"C"</span><span class='o'>)</span>, y <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='m'>12</span>, <span class='m'>8</span>, <span class='m'>7</span><span class='o'>)</span><span class='o'>)</span></span>
<span></span>
<span><span class='nv'>df1</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 3 × 3</span></span></span>
<span><span class='c'>#&gt;    x_id region     x</span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>  <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span>     1 A          5</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span>     2 B         10</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>3</span>     2 A          4</span></span>
<span></span><span></span>
<span><span class='nv'>df2</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 3 × 3</span></span></span>
<span><span class='c'>#&gt;    y_id region     y</span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>  <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span>     2 A         12</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span>     1 A          8</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>3</span>     2 C          7</span></span>
<span></span><span></span>
<span><span class='nv'>df1</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/mutate-joins.html'>left_join</a></span><span class='o'>(</span><span class='nv'>df2</span>, <span class='nf'><a href='https://dplyr.tidyverse.org/reference/join_by.html'>join_by</a></span><span class='o'>(</span><span class='nv'>x_id</span> <span class='o'>==</span> <span class='nv'>y_id</span>, <span class='nv'>region</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 3 × 4</span></span></span>
<span><span class='c'>#&gt;    x_id region     x     y</span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>  <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span>     1 A          5     8</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span>     2 B         10    <span style='color: #BB0000;'>NA</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>3</span>     2 A          4    12</span></span>
<span></span></code></pre>

</div>

### Non-equi joins

Allowing expressions in [`join_by()`](https://dplyr.tidyverse.org/reference/join_by.html) opens up a whole new world of joins in dplyr known as *non-equi joins*. As the name somewhat implies, these are joins that involve binary conditions other than equality. There are 4 particularly useful types of non-equi joins:

-   **Cross joins** match every pair of rows and were already supported in dplyr.

-   **Inequality joins** match using `>`, `>=`, `<`, or `<=` instead of `==`.

-   **Rolling joins** are based on inequality joins, but only find the closest match.

-   **Overlap joins** are also based on inequality joins, but are specialized for working with ranges.

Non-equi joins were requested back in 2016, and were the highest requested dplyr feature at the time they were finally implemented, with over [147 thumbs up](https://github.com/tidyverse/dplyr/issues/2240)! data.table has had support for non-equi joins for many years, and their implementation greatly inspired the one used in dplyr.

To demonstrate the different types of non-equi joins, imagine that you are in charge of the party planning committee for your office. Unfortunately, you only get to have one party per quarter, but it is your job to ensure that every employee is assigned to a single party. Upper management has provided the following 4 party dates:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>parties</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://tibble.tidyverse.org/reference/tibble.html'>tibble</a></span><span class='o'>(</span></span>
<span>  q <span class='o'>=</span> <span class='m'>1</span><span class='o'>:</span><span class='m'>4</span>,</span>
<span>  party <span class='o'>=</span> <span class='nf'><a href='https://clock.r-lib.org/reference/date_parse.html'>date_parse</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"2022-01-10"</span>, <span class='s'>"2022-04-04"</span>, <span class='s'>"2022-07-11"</span>, <span class='s'>"2022-10-03"</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='o'>)</span></span>
<span></span>
<span><span class='nv'>parties</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 4 × 2</span></span></span>
<span><span class='c'>#&gt;       q party     </span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;int&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;date&gt;</span>    </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span>     1 2022-01-10</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span>     2 2022-04-04</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>3</span>     3 2022-07-11</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>4</span>     4 2022-10-03</span></span>
<span></span></code></pre>

</div>

With this set of employees:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>employees</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://tibble.tidyverse.org/reference/tibble.html'>tibble</a></span><span class='o'>(</span></span>
<span>  name <span class='o'>=</span> <span class='nf'>wakefield</span><span class='nf'>::</span><span class='nf'><a href='https://rdrr.io/pkg/wakefield/man/name.html'>name</a></span><span class='o'>(</span><span class='m'>100</span><span class='o'>)</span>,</span>
<span>  birthday <span class='o'>=</span> <span class='nf'><a href='https://clock.r-lib.org/reference/date_parse.html'>date_parse</a></span><span class='o'>(</span><span class='s'>"2022-01-01"</span><span class='o'>)</span> <span class='o'>+</span> <span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/sample.html'>sample</a></span><span class='o'>(</span><span class='m'>365</span>, <span class='m'>100</span>, replace <span class='o'>=</span> <span class='kc'>TRUE</span><span class='o'>)</span> <span class='o'>-</span> <span class='m'>1</span><span class='o'>)</span></span>
<span><span class='o'>)</span></span>
<span></span>
<span><span class='nv'>employees</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 100 × 2</span></span></span>
<span><span class='c'>#&gt;    name       birthday  </span></span>
<span><span class='c'>#&gt;    <span style='color: #555555; font-style: italic;'>&lt;variable&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;date&gt;</span>    </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 1</span> Seager     2022-08-26</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 2</span> Nathion    2022-10-04</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 3</span> Sametra    2022-06-13</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 4</span> Netty      2022-05-12</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 5</span> Yalissa    2022-05-28</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 6</span> Mirai      2022-08-20</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 7</span> Toyoko     2022-08-23</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 8</span> Earlene    2022-04-21</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 9</span> Abbegayle  2022-01-27</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>10</span> Valyssa    2022-03-06</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># … with 90 more rows</span></span></span>
<span></span></code></pre>

</div>

One way to start approaching this problem is to look for the party that happened directly before each birthday. You can do this with an inequality join:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>employees</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/mutate-joins.html'>left_join</a></span><span class='o'>(</span><span class='nv'>parties</span>, <span class='nf'><a href='https://dplyr.tidyverse.org/reference/join_by.html'>join_by</a></span><span class='o'>(</span><span class='nv'>birthday</span> <span class='o'>&gt;=</span> <span class='nv'>party</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 251 × 4</span></span></span>
<span><span class='c'>#&gt;    name       birthday       q party     </span></span>
<span><span class='c'>#&gt;    <span style='color: #555555; font-style: italic;'>&lt;variable&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;date&gt;</span>     <span style='color: #555555; font-style: italic;'>&lt;int&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;date&gt;</span>    </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 1</span> Seager     2022-08-26     1 2022-01-10</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 2</span> Seager     2022-08-26     2 2022-04-04</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 3</span> Seager     2022-08-26     3 2022-07-11</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 4</span> Nathion    2022-10-04     1 2022-01-10</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 5</span> Nathion    2022-10-04     2 2022-04-04</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 6</span> Nathion    2022-10-04     3 2022-07-11</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 7</span> Nathion    2022-10-04     4 2022-10-03</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 8</span> Sametra    2022-06-13     1 2022-01-10</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 9</span> Sametra    2022-06-13     2 2022-04-04</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>10</span> Netty      2022-05-12     1 2022-01-10</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># … with 241 more rows</span></span></span>
<span></span></code></pre>

</div>

This looks like a good start, but we've assigned people with birthdays later in the year to multiple parties. We can restrict this to only the party that is *closest* to the employee's birthday by using a rolling join. Rolling joins are activated by wrapping an inequality in `closest()`.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>closest</span> <span class='o'>&lt;-</span> <span class='nv'>employees</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/mutate-joins.html'>left_join</a></span><span class='o'>(</span><span class='nv'>parties</span>, <span class='nf'><a href='https://dplyr.tidyverse.org/reference/join_by.html'>join_by</a></span><span class='o'>(</span><span class='nf'>closest</span><span class='o'>(</span><span class='nv'>birthday</span> <span class='o'>&gt;=</span> <span class='nv'>party</span><span class='o'>)</span><span class='o'>)</span><span class='o'>)</span></span>
<span></span>
<span><span class='nv'>closest</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 100 × 4</span></span></span>
<span><span class='c'>#&gt;    name       birthday       q party     </span></span>
<span><span class='c'>#&gt;    <span style='color: #555555; font-style: italic;'>&lt;variable&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;date&gt;</span>     <span style='color: #555555; font-style: italic;'>&lt;int&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;date&gt;</span>    </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 1</span> Seager     2022-08-26     3 2022-07-11</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 2</span> Nathion    2022-10-04     4 2022-10-03</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 3</span> Sametra    2022-06-13     2 2022-04-04</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 4</span> Netty      2022-05-12     2 2022-04-04</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 5</span> Yalissa    2022-05-28     2 2022-04-04</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 6</span> Mirai      2022-08-20     3 2022-07-11</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 7</span> Toyoko     2022-08-23     3 2022-07-11</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 8</span> Earlene    2022-04-21     2 2022-04-04</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 9</span> Abbegayle  2022-01-27     1 2022-01-10</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>10</span> Valyssa    2022-03-06     1 2022-01-10</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># … with 90 more rows</span></span></span>
<span></span></code></pre>

</div>

This is close to what we want, but isn't *quite* right. It turns out that poor Della hasn't been assigned to a party.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://dplyr.tidyverse.org/reference/filter.html'>filter</a></span><span class='o'>(</span><span class='nv'>closest</span>, <span class='nf'><a href='https://rdrr.io/r/base/NA.html'>is.na</a></span><span class='o'>(</span><span class='nv'>party</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 1 × 4</span></span></span>
<span><span class='c'>#&gt;   name       birthday       q party </span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;variable&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;date&gt;</span>     <span style='color: #555555; font-style: italic;'>&lt;int&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;date&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span> Della      2022-01-06    <span style='color: #BB0000;'>NA</span> <span style='color: #BB0000;'>NA</span></span></span>
<span></span></code></pre>

</div>

This is because their birthday occurred before the first party date, `2022-01-10`, so there wasn't any "previous party" to match them to. It's a little easier to fix this if we are explicit about the quarter start/end dates that form the ranges to look for matches in:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='c'># Some helpers from &#123;clock&#125;</span></span>
<span><span class='nv'>quarter_start</span> <span class='o'>&lt;-</span> <span class='kr'>function</span><span class='o'>(</span><span class='nv'>x</span><span class='o'>)</span> <span class='o'>&#123;</span></span>
<span>  <span class='nv'>x</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://clock.r-lib.org/reference/as_year_quarter_day.html'>as_year_quarter_day</a></span><span class='o'>(</span><span class='nv'>x</span><span class='o'>)</span></span>
<span>  <span class='nv'>x</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://clock.r-lib.org/reference/calendar-boundary.html'>calendar_start</a></span><span class='o'>(</span><span class='nv'>x</span>, <span class='s'>"quarter"</span><span class='o'>)</span></span>
<span>  <span class='nf'><a href='https://clock.r-lib.org/reference/as_date.html'>as_date</a></span><span class='o'>(</span><span class='nv'>x</span><span class='o'>)</span></span>
<span><span class='o'>&#125;</span></span>
<span><span class='nv'>quarter_end</span> <span class='o'>&lt;-</span> <span class='kr'>function</span><span class='o'>(</span><span class='nv'>x</span><span class='o'>)</span> <span class='o'>&#123;</span></span>
<span>  <span class='nv'>x</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://clock.r-lib.org/reference/as_year_quarter_day.html'>as_year_quarter_day</a></span><span class='o'>(</span><span class='nv'>x</span><span class='o'>)</span></span>
<span>  <span class='nv'>x</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://clock.r-lib.org/reference/calendar-boundary.html'>calendar_end</a></span><span class='o'>(</span><span class='nv'>x</span>, <span class='s'>"quarter"</span><span class='o'>)</span></span>
<span>  <span class='nf'><a href='https://rdrr.io/r/base/as.Date.html'>as.Date</a></span><span class='o'>(</span><span class='nv'>x</span><span class='o'>)</span></span>
<span><span class='o'>&#125;</span></span>
<span></span>
<span><span class='nv'>parties</span> <span class='o'>&lt;-</span> <span class='nv'>parties</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/mutate.html'>mutate</a></span><span class='o'>(</span>start <span class='o'>=</span> <span class='nf'>quarter_start</span><span class='o'>(</span><span class='nv'>party</span><span class='o'>)</span>, end <span class='o'>=</span> <span class='nf'>quarter_end</span><span class='o'>(</span><span class='nv'>party</span><span class='o'>)</span><span class='o'>)</span></span>
<span></span>
<span><span class='nv'>parties</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 4 × 4</span></span></span>
<span><span class='c'>#&gt;       q party      start      end       </span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;int&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;date&gt;</span>     <span style='color: #555555; font-style: italic;'>&lt;date&gt;</span>     <span style='color: #555555; font-style: italic;'>&lt;date&gt;</span>    </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span>     1 2022-01-10 2022-01-01 2022-03-31</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span>     2 2022-04-04 2022-04-01 2022-06-30</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>3</span>     3 2022-07-11 2022-07-01 2022-09-30</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>4</span>     4 2022-10-03 2022-10-01 2022-12-31</span></span>
<span></span></code></pre>

</div>

Now that we have 4 distinct *ranges* of dates to work with, we'll use an overlap join to figure out which range each birthday fell [`between()`](https://dplyr.tidyverse.org/reference/between.html). Since we know that each birthday should be matched to exactly one party, we'll also take this chance to set `multiple`, a new argument to the join functions that allows you to optionally `"error"` if a birthday is matched to multiple parties.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>employees</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/mutate-joins.html'>left_join</a></span><span class='o'>(</span></span>
<span>    <span class='nv'>parties</span>, </span>
<span>    <span class='nf'><a href='https://dplyr.tidyverse.org/reference/join_by.html'>join_by</a></span><span class='o'>(</span><span class='nf'><a href='https://dplyr.tidyverse.org/reference/between.html'>between</a></span><span class='o'>(</span><span class='nv'>birthday</span>, <span class='nv'>start</span>, <span class='nv'>end</span><span class='o'>)</span><span class='o'>)</span>,</span>
<span>    multiple <span class='o'>=</span> <span class='s'>"error"</span></span>
<span>  <span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 100 × 6</span></span></span>
<span><span class='c'>#&gt;    name       birthday       q party      start      end       </span></span>
<span><span class='c'>#&gt;    <span style='color: #555555; font-style: italic;'>&lt;variable&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;date&gt;</span>     <span style='color: #555555; font-style: italic;'>&lt;int&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;date&gt;</span>     <span style='color: #555555; font-style: italic;'>&lt;date&gt;</span>     <span style='color: #555555; font-style: italic;'>&lt;date&gt;</span>    </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 1</span> Seager     2022-08-26     3 2022-07-11 2022-07-01 2022-09-30</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 2</span> Nathion    2022-10-04     4 2022-10-03 2022-10-01 2022-12-31</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 3</span> Sametra    2022-06-13     2 2022-04-04 2022-04-01 2022-06-30</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 4</span> Netty      2022-05-12     2 2022-04-04 2022-04-01 2022-06-30</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 5</span> Yalissa    2022-05-28     2 2022-04-04 2022-04-01 2022-06-30</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 6</span> Mirai      2022-08-20     3 2022-07-11 2022-07-01 2022-09-30</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 7</span> Toyoko     2022-08-23     3 2022-07-11 2022-07-01 2022-09-30</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 8</span> Earlene    2022-04-21     2 2022-04-04 2022-04-01 2022-06-30</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 9</span> Abbegayle  2022-01-27     1 2022-01-10 2022-01-01 2022-03-31</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>10</span> Valyssa    2022-03-06     1 2022-01-10 2022-01-01 2022-03-31</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># … with 90 more rows</span></span></span>
<span></span></code></pre>

</div>

We consider `multiple` to be an important "quality control" argument to help you enforce constraints on the join procedure.

### Multiple matches

Speaking of `multiple`, we've also given this argument an important default. When doing data analysis with equi-joins, it is often surprising when a join returns more rows than were present in the left-hand side table.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>df1</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 3 × 3</span></span></span>
<span><span class='c'>#&gt;    x_id region     x</span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>  <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span>     1 A          5</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span>     2 B         10</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>3</span>     2 A          4</span></span>
<span></span><span></span>
<span><span class='nv'>df2</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://tibble.tidyverse.org/reference/tibble.html'>tibble</a></span><span class='o'>(</span>y_id <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='m'>1</span>, <span class='m'>2</span>, <span class='m'>1</span>, <span class='m'>2</span><span class='o'>)</span>, region <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"A"</span>, <span class='s'>"B"</span>, <span class='s'>"A"</span>, <span class='s'>"A"</span><span class='o'>)</span>, y <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='m'>9</span>, <span class='m'>10</span>, <span class='m'>12</span>, <span class='m'>4</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='nv'>df2</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 4 × 3</span></span></span>
<span><span class='c'>#&gt;    y_id region     y</span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>  <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span>     1 A          9</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span>     2 B         10</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>3</span>     1 A         12</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>4</span>     2 A          4</span></span>
<span></span><span></span>
<span><span class='nv'>df1</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/mutate-joins.html'>left_join</a></span><span class='o'>(</span><span class='nv'>df2</span>, <span class='nf'><a href='https://dplyr.tidyverse.org/reference/join_by.html'>join_by</a></span><span class='o'>(</span><span class='nv'>x_id</span> <span class='o'>==</span> <span class='nv'>y_id</span>, <span class='nv'>region</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; Warning in left_join(df1, df2, join_by(x_id == y_id, region)): Each row in `x` is expected to match at most 1 row in `y`.</span></span>
<span><span class='c'>#&gt; <span style='color: #00BBBB;'>ℹ</span> Row 1 of `x` matches multiple rows.</span></span>
<span><span class='c'>#&gt; <span style='color: #00BBBB;'>ℹ</span> If multiple matches are expected, set `multiple = "all"` to silence this</span></span>
<span><span class='c'>#&gt;   warning.</span></span>
<span></span><span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 4 × 4</span></span></span>
<span><span class='c'>#&gt;    x_id region     x     y</span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>  <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span>     1 A          5     9</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span>     1 A          5    12</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>3</span>     2 B         10    10</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>4</span>     2 A          4     4</span></span>
<span></span></code></pre>

</div>

In this case, row 1 of `df1` matched both rows `1` and `3` of `df2`, so the output has 4 rows rather than `df1`'s 3. While this is standard SQL behavior, community feedback has shown that many people don't expect this, and a number of people were horrified to learn that this was even possible! Because of this, we've made this case a warning by default, which you can silence with `multiple = "all"`.

## `arrange()` improvements with character vectors

[`arrange()`](https://dplyr.tidyverse.org/reference/arrange.html) now uses a new custom backend for generating the ordering. This generally improves performance, but it is especially apparent with character vectors.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='c'># 10,000 random strings, sampled up to 1,000,000 rows</span></span>
<span><span class='nv'>dictionary</span> <span class='o'>&lt;-</span> <span class='nf'>stringi</span><span class='nf'>::</span><span class='nf'><a href='https://rdrr.io/pkg/stringi/man/stri_rand_strings.html'>stri_rand_strings</a></span><span class='o'>(</span><span class='m'>10000</span>, length <span class='o'>=</span> <span class='m'>10</span>, pattern <span class='o'>=</span> <span class='s'>"[a-z]"</span><span class='o'>)</span></span>
<span><span class='nv'>str</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://tibble.tidyverse.org/reference/tibble.html'>tibble</a></span><span class='o'>(</span>x <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/sample.html'>sample</a></span><span class='o'>(</span><span class='nv'>dictionary</span>, size <span class='o'>=</span> <span class='m'>1e6</span>, replace <span class='o'>=</span> <span class='kc'>TRUE</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='nv'>str</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 1,000,000 × 1</span></span></span>
<span><span class='c'>#&gt;    x         </span></span>
<span><span class='c'>#&gt;    <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>     </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 1</span> btjgpowbav</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 2</span> jrddujrxwt</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 3</span> ofgkybvsoo</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 4</span> dzyxfvwktu</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 5</span> qobgfmkgof</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 6</span> rmzjvtnpbf</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 7</span> jxrqgxouqg</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 8</span> empcmhnlqq</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 9</span> nwfgauiurp</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>10</span> hdswclaxys</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># … with 999,990 more rows</span></span></span>
<span></span></code></pre>

</div>

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='c'># dplyr 1.0.10</span></span>
<span><span class='nf'>bench</span><span class='nf'>::</span><span class='nf'><a href='http://bench.r-lib.org/reference/mark.html'>mark</a></span><span class='o'>(</span><span class='nf'><a href='https://dplyr.tidyverse.org/reference/arrange.html'>arrange</a></span><span class='o'>(</span><span class='nv'>str</span>, <span class='nv'>x</span><span class='o'>)</span>, iterations <span class='o'>=</span> <span class='m'>100</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; # A tibble: 1 × 6</span></span>
<span><span class='c'>#&gt;   expression          min   median `itr/sec` mem_alloc `gc/sec`</span></span>
<span><span class='c'>#&gt;   &lt;bch:expr&gt;     &lt;bch:tm&gt; &lt;bch:tm&gt;     &lt;dbl&gt; &lt;bch:byt&gt;    &lt;dbl&gt;</span></span>
<span><span class='c'>#&gt; 1 arrange(str, x)   4.38s    4.89s     0.204    12.7MB    0.148</span></span>
<span></span>
<span><span class='c'># dplyr 1.1.0</span></span>
<span><span class='nf'>bench</span><span class='nf'>::</span><span class='nf'><a href='http://bench.r-lib.org/reference/mark.html'>mark</a></span><span class='o'>(</span><span class='nf'><a href='https://dplyr.tidyverse.org/reference/arrange.html'>arrange</a></span><span class='o'>(</span><span class='nv'>str</span>, <span class='nv'>x</span><span class='o'>)</span>, iterations <span class='o'>=</span> <span class='m'>100</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; # A tibble: 1 × 6</span></span>
<span><span class='c'>#&gt;   expression          min   median `itr/sec` mem_alloc `gc/sec`</span></span>
<span><span class='c'>#&gt;   &lt;bch:expr&gt;     &lt;bch:tm&gt; &lt;bch:tm&gt;     &lt;dbl&gt; &lt;bch:byt&gt;    &lt;dbl&gt;</span></span>
<span><span class='c'>#&gt; 1 arrange(str, x)  42.3ms   46.6ms      20.8    22.4MB     46.0</span></span></code></pre>

</div>

For those keeping score, that is a 100x improvement! Now, I'll be honest, I'm being a bit tricky here. The new backend for [`arrange()`](https://dplyr.tidyverse.org/reference/arrange.html) comes with a meaningful change in behavior - it now sorts character strings in the C locale by default, rather than in the much slower system locale (American English, for me). We made this change for two main reasons:

-   Much faster performance by default, because it can use {vctrs} radix sort (inspired by data.table)

-   Improved reproducibility across R sessions, where different computers might use different system locales

For English users, we expect this change to have fairly minimal impact. The largest difference in ordering between the C and American English locales has to do with capitalization. In the C locale, uppercase letters are always placed before *any* lowercase letters. In the American English locale, uppercase letters are placed directly after their lowercase equivalent.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>df</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://tibble.tidyverse.org/reference/tibble.html'>tibble</a></span><span class='o'>(</span>x <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"a"</span>, <span class='s'>"B"</span>, <span class='s'>"A"</span>, <span class='s'>"b"</span><span class='o'>)</span><span class='o'>)</span></span>
<span></span>
<span><span class='nf'><a href='https://dplyr.tidyverse.org/reference/arrange.html'>arrange</a></span><span class='o'>(</span><span class='nv'>df</span>, <span class='nv'>x</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 4 × 1</span></span></span>
<span><span class='c'>#&gt;   x    </span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span> A    </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span> B    </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>3</span> a    </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>4</span> b</span></span>
<span></span></code></pre>

</div>

If you do need to order with a specific locale, you can specify the new `.locale` argument, which takes a locale identifier string, just like [`stringr::str_sort()`](https://stringr.tidyverse.org/reference/str_order.html).

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://dplyr.tidyverse.org/reference/arrange.html'>arrange</a></span><span class='o'>(</span><span class='nv'>df</span>, <span class='nv'>x</span>, .locale <span class='o'>=</span> <span class='s'>"en"</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 4 × 1</span></span></span>
<span><span class='c'>#&gt;   x    </span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span> a    </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span> A    </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>3</span> b    </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>4</span> B</span></span>
<span></span></code></pre>

</div>

To use this optional `.locale` feature, you must have the stringi package installed, but you likely already do because it is installed with the tidyverse by default.

It is also worth noting that using `.locale` is still much faster than relying on the system locale.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='c'># Compare with ~5 seconds above with dplyr 1.0.10</span></span>
<span></span>
<span><span class='nf'>bench</span><span class='nf'>::</span><span class='nf'><a href='http://bench.r-lib.org/reference/mark.html'>mark</a></span><span class='o'>(</span><span class='nf'><a href='https://dplyr.tidyverse.org/reference/arrange.html'>arrange</a></span><span class='o'>(</span><span class='nv'>str</span>, <span class='nv'>x</span>, .locale <span class='o'>=</span> <span class='s'>"en"</span><span class='o'>)</span>, iterations <span class='o'>=</span> <span class='m'>100</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; # A tibble: 1 × 6</span></span>
<span><span class='c'>#&gt;   expression                           min median `itr/sec` mem_alloc</span></span>
<span><span class='c'>#&gt;   &lt;bch:expr&gt;                      &lt;bch:tm&gt; &lt;bch:&gt;     &lt;dbl&gt; &lt;bch:byt&gt;</span></span>
<span><span class='c'>#&gt; 1 arrange(str, x, .locale = "en")    377ms  430ms      2.21    27.9MB</span></span>
<span><span class='c'>#&gt; # … with 1 more variable: `gc/sec` &lt;dbl&gt;</span></span></code></pre>

</div>

For non-English Latin script languages, such as Spanish, you may see more of a change, as characters such as `ñ` are ordered after `z` rather than before `n` in the C locale:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>df</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://tibble.tidyverse.org/reference/tibble.html'>tibble</a></span><span class='o'>(</span>x <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"\u00F1"</span>, <span class='s'>"n"</span>, <span class='s'>"z"</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='nv'>df</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 3 × 1</span></span></span>
<span><span class='c'>#&gt;   x    </span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span> ñ    </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span> n    </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>3</span> z</span></span>
<span></span><span></span>
<span><span class='nf'><a href='https://dplyr.tidyverse.org/reference/arrange.html'>arrange</a></span><span class='o'>(</span><span class='nv'>df</span>, <span class='nv'>x</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 3 × 1</span></span></span>
<span><span class='c'>#&gt;   x    </span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span> n    </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span> z    </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>3</span> ñ</span></span>
<span></span><span></span>
<span><span class='nf'><a href='https://dplyr.tidyverse.org/reference/arrange.html'>arrange</a></span><span class='o'>(</span><span class='nv'>df</span>, <span class='nv'>x</span>, .locale <span class='o'>=</span> <span class='s'>"es"</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 3 × 1</span></span></span>
<span><span class='c'>#&gt;   x    </span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span> n    </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span> ñ    </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>3</span> z</span></span>
<span></span></code></pre>

</div>

We are optimistic that this change is an overall net positive. We anticipate that many users use [`arrange()`](https://dplyr.tidyverse.org/reference/arrange.html) to simply group similar looking observations together, and we expect that the main places you'll need to care about localized ordering are the few places when you are generating human readable output, such as a table or a chart, at which point you might consider using `.locale`.

If you are having trouble converting an existing script over to the new behavior, you can set the temporary global option `options(dplyr.legacy_locale = TRUE)`, which will revert to the pre-1.1.0 behavior of using the system locale. We expect to remove this option in a future release.

To learn more low-level details about this change, you can read our [tidyup](https://github.com/tidyverse/tidyups/blob/main/003-dplyr-radix-ordering.md).

## `reframe()`, a generalization of `summarise()`

In dplyr 1.0.0, we introduced a powerful new feature: [`summarise()`](https://dplyr.tidyverse.org/reference/summarise.html) could return per-group results of any length, rather than just length 1. For example:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>table</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"a"</span>, <span class='s'>"b"</span>, <span class='s'>"d"</span>, <span class='s'>"f"</span><span class='o'>)</span></span>
<span></span>
<span><span class='nv'>df</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://tibble.tidyverse.org/reference/tibble.html'>tibble</a></span><span class='o'>(</span></span>
<span>  g <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='m'>1</span>, <span class='m'>1</span>, <span class='m'>1</span>, <span class='m'>2</span>, <span class='m'>2</span>, <span class='m'>2</span>, <span class='m'>2</span><span class='o'>)</span>,</span>
<span>  x <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"e"</span>, <span class='s'>"a"</span>, <span class='s'>"b"</span>, <span class='s'>"c"</span>, <span class='s'>"f"</span>, <span class='s'>"d"</span>, <span class='s'>"a"</span><span class='o'>)</span></span>
<span><span class='o'>)</span></span>
<span></span>
<span><span class='nv'>df</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/summarise.html'>summarise</a></span><span class='o'>(</span>x <span class='o'>=</span> <span class='nf'><a href='https://generics.r-lib.org/reference/setops.html'>intersect</a></span><span class='o'>(</span><span class='nv'>x</span>, <span class='nv'>table</span><span class='o'>)</span>, .by <span class='o'>=</span> <span class='nv'>g</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 5 × 2</span></span></span>
<span><span class='c'>#&gt;       g x    </span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span>     1 a    </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span>     1 b    </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>3</span>     2 f    </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>4</span>     2 d    </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>5</span>     2 a</span></span>
<span></span></code></pre>

</div>

While extremely powerful, community feedback has raised the valid concern that allowing [`summarise()`](https://dplyr.tidyverse.org/reference/summarise.html) to return any number of rows per group:

-   Increases the chance for accidental bugs

-   Is against the spirit of a "summary," which implies 1 row per group

-   Makes translation to dbplyr very difficult

We agree! In response to this, we've decided to walk back that change to [`summarise()`](https://dplyr.tidyverse.org/reference/summarise.html), which will now throw a warning when either 0 or \>1 rows are returned per group:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>df</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/summarise.html'>summarise</a></span><span class='o'>(</span>x <span class='o'>=</span> <span class='nf'><a href='https://generics.r-lib.org/reference/setops.html'>intersect</a></span><span class='o'>(</span><span class='nv'>x</span>, <span class='nv'>table</span><span class='o'>)</span>, .by <span class='o'>=</span> <span class='nv'>g</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; Warning: Returning more (or less) than 1 row per `summarise()` group was deprecated in</span></span>
<span><span class='c'>#&gt; dplyr 1.1.0.</span></span>
<span><span class='c'>#&gt; <span style='color: #00BBBB;'>ℹ</span> Please use `reframe()` instead.</span></span>
<span><span class='c'>#&gt; <span style='color: #00BBBB;'>ℹ</span> When switching from `summarise()` to `reframe()`, remember that `reframe()`</span></span>
<span><span class='c'>#&gt;   always returns an ungrouped data frame and adjust accordingly.</span></span>
<span></span><span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 5 × 2</span></span></span>
<span><span class='c'>#&gt;       g x    </span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span>     1 a    </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span>     1 b    </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>3</span>     2 f    </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>4</span>     2 d    </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>5</span>     2 a</span></span>
<span></span></code></pre>

</div>

That said, we still believe that this is a powerful tool, so we've moved these features to a new verb, [`reframe()`](https://dplyr.tidyverse.org/reference/reframe.html). Think of [`reframe()`](https://dplyr.tidyverse.org/reference/reframe.html) as a generic tool for "doing something to each group," with no restrictions on the number of rows returned per group.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>df</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/reframe.html'>reframe</a></span><span class='o'>(</span>x <span class='o'>=</span> <span class='nf'><a href='https://generics.r-lib.org/reference/setops.html'>intersect</a></span><span class='o'>(</span><span class='nv'>x</span>, <span class='nv'>table</span><span class='o'>)</span>, .by <span class='o'>=</span> <span class='nv'>g</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 5 × 2</span></span></span>
<span><span class='c'>#&gt;       g x    </span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span>     1 a    </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span>     1 b    </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>3</span>     2 f    </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>4</span>     2 d    </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>5</span>     2 a</span></span>
<span></span></code></pre>

</div>

One big difference between [`summarise()`](https://dplyr.tidyverse.org/reference/summarise.html) and [`reframe()`](https://dplyr.tidyverse.org/reference/reframe.html) is that [`reframe()`](https://dplyr.tidyverse.org/reference/reframe.html) always returns an ungrouped data frame, even if the input was a grouped data frame with multiple group columns. This simplifies [`reframe()`](https://dplyr.tidyverse.org/reference/reframe.html) immensely, as it doesn't need to inherit the `.groups` argument of [`summarise()`](https://dplyr.tidyverse.org/reference/summarise.html), and never emits any messages.

We expect that you'll continue to use [`summarise()`](https://dplyr.tidyverse.org/reference/summarise.html) much more often than [`reframe()`](https://dplyr.tidyverse.org/reference/reframe.html), but if you ever find yourself applying a function to each group that returns an arbitrary number of rows, [`reframe()`](https://dplyr.tidyverse.org/reference/reframe.html) should be your go-to tool!

[`reframe()`](https://dplyr.tidyverse.org/reference/reframe.html) is one of the places we could use your feedback! We aren't completely confident about this function name yet, so if you have any feedback about it or suggestions for an alternate one, please leave a comment on this [issue](https://github.com/tidyverse/dplyr/issues/6565).

