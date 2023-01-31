---
output: hugodown::hugo_document
slug: dplyr-1-1-0-per-operation-grouping
title: "dplyr 1.1.0: Per-operation grouping"
date: 2023-02-01
author: Davis Vaughan
description: >
    dplyr now supports an experimental per-operation grouping syntax through a new argument
    named `.by`. This serves as an alternative to `group_by()`.
photo:
  url: https://www.pexels.com/photo/fruit-stand-375897/
  author: Clem Onojeghuo
categories: [package] 
tags: [dplyr]
editor_options: 
  chunk_output_type: console
rmd_hash: 3dc87e3095893e1f

---

Today we are going to look at one of the major new features in [dplyr 1.1.0](https://dplyr.tidyverse.org/news/index.html#dplyr-110), per-operation grouping with `.by`/`by`. This is an exciting alternative to [`group_by()`](https://dplyr.tidyverse.org/reference/group_by.html) that only applies grouping within a single dplyr verb.

You can install it from CRAN with:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://rdrr.io/r/utils/install.packages.html'>install.packages</a></span><span class='o'>(</span><span class='s'>"dplyr"</span><span class='o'>)</span></span></code></pre>

</div>

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://dplyr.tidyverse.org'>dplyr</a></span><span class='o'>)</span></span></code></pre>

</div>

## Persistent grouping with `group_by()`

In dplyr, grouping radically affects the computation of the verb that you use it with. Since the very beginning of dplyr, you've been able to perform grouped operations with [`group_by()`](https://dplyr.tidyverse.org/reference/group_by.html). This grouping is *persistent*, meaning that it typically sticks around in some form for more than one operation. For example, this `transactions` dataset tracks revenue brought in from various transactions across multiple companies. If we wanted to add a column for the total yearly revenue per company, we might do:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>transactions</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://tibble.tidyverse.org/reference/tibble.html'>tibble</a></span><span class='o'>(</span></span>
<span>  company <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"A"</span>, <span class='s'>"A"</span>, <span class='s'>"A"</span>, <span class='s'>"B"</span>, <span class='s'>"B"</span>, <span class='s'>"B"</span><span class='o'>)</span>,</span>
<span>  year <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='m'>2019</span>, <span class='m'>2019</span>, <span class='m'>2020</span>, <span class='m'>2021</span>, <span class='m'>2023</span>, <span class='m'>2023</span><span class='o'>)</span>,</span>
<span>  revenue <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='m'>20</span>, <span class='m'>50</span>, <span class='m'>4</span>, <span class='m'>10</span>, <span class='m'>12</span>, <span class='m'>18</span><span class='o'>)</span></span>
<span><span class='o'>)</span></span>
<span></span>
<span><span class='nv'>transactions</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 6 × 3</span></span></span>
<span><span class='c'>#&gt;   company  year revenue</span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>   <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>   <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span> A        <span style='text-decoration: underline;'>2</span>019      20</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span> A        <span style='text-decoration: underline;'>2</span>019      50</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>3</span> A        <span style='text-decoration: underline;'>2</span>020       4</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>4</span> B        <span style='text-decoration: underline;'>2</span>021      10</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>5</span> B        <span style='text-decoration: underline;'>2</span>023      12</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>6</span> B        <span style='text-decoration: underline;'>2</span>023      18</span></span>
<span></span></code></pre>

</div>

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>transactions</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/group_by.html'>group_by</a></span><span class='o'>(</span><span class='nv'>company</span>, <span class='nv'>year</span><span class='o'>)</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/mutate.html'>mutate</a></span><span class='o'>(</span>total <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/sum.html'>sum</a></span><span class='o'>(</span><span class='nv'>revenue</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 6 × 4</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># Groups:   company, year [4]</span></span></span>
<span><span class='c'>#&gt;   company  year revenue total</span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>   <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>   <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span> A        <span style='text-decoration: underline;'>2</span>019      20    70</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span> A        <span style='text-decoration: underline;'>2</span>019      50    70</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>3</span> A        <span style='text-decoration: underline;'>2</span>020       4     4</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>4</span> B        <span style='text-decoration: underline;'>2</span>021      10    10</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>5</span> B        <span style='text-decoration: underline;'>2</span>023      12    30</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>6</span> B        <span style='text-decoration: underline;'>2</span>023      18    30</span></span>
<span></span></code></pre>

</div>

Notice that the result is still grouped by both `company` and `year`. This is sometimes useful if you need to compute additional grouped results (with the exact same grouping columns) in a follow up operation, but often many people follow this [`mutate()`](https://dplyr.tidyverse.org/reference/mutate.html) with an [`ungroup()`](https://dplyr.tidyverse.org/reference/group_by.html).

Similarly, if we just wanted the total revenue in a summary table, we would have used [`summarise()`](https://dplyr.tidyverse.org/reference/summarise.html), which peels off 1 layer of grouping by default:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>transactions</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/group_by.html'>group_by</a></span><span class='o'>(</span><span class='nv'>company</span>, <span class='nv'>year</span><span class='o'>)</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/summarise.html'>summarise</a></span><span class='o'>(</span>total <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/sum.html'>sum</a></span><span class='o'>(</span><span class='nv'>revenue</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; `summarise()` has grouped output by 'company'. You can override using the</span></span>
<span><span class='c'>#&gt; `.groups` argument.</span></span>
<span></span><span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 4 × 3</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># Groups:   company [2]</span></span></span>
<span><span class='c'>#&gt;   company  year total</span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>   <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span> A        <span style='text-decoration: underline;'>2</span>019    70</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span> A        <span style='text-decoration: underline;'>2</span>020     4</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>3</span> B        <span style='text-decoration: underline;'>2</span>021    10</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>4</span> B        <span style='text-decoration: underline;'>2</span>023    30</span></span>
<span></span></code></pre>

</div>

## Per-operation grouping with `.by`/`by`

In dplyr 1.1.0, we've introduced an alternative to [`group_by()`](https://dplyr.tidyverse.org/reference/group_by.html) known as `.by` that allow for *per-operation* grouping instead:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>transactions</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/mutate.html'>mutate</a></span><span class='o'>(</span>total <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/sum.html'>sum</a></span><span class='o'>(</span><span class='nv'>revenue</span><span class='o'>)</span>, .by <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='nv'>company</span>, <span class='nv'>year</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 6 × 4</span></span></span>
<span><span class='c'>#&gt;   company  year revenue total</span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>   <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>   <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span> A        <span style='text-decoration: underline;'>2</span>019      20    70</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span> A        <span style='text-decoration: underline;'>2</span>019      50    70</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>3</span> A        <span style='text-decoration: underline;'>2</span>020       4     4</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>4</span> B        <span style='text-decoration: underline;'>2</span>021      10    10</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>5</span> B        <span style='text-decoration: underline;'>2</span>023      12    30</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>6</span> B        <span style='text-decoration: underline;'>2</span>023      18    30</span></span>
<span></span><span></span>
<span><span class='nv'>transactions</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/summarise.html'>summarise</a></span><span class='o'>(</span>total <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/sum.html'>sum</a></span><span class='o'>(</span><span class='nv'>revenue</span><span class='o'>)</span>, .by <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='nv'>company</span>, <span class='nv'>year</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 4 × 3</span></span></span>
<span><span class='c'>#&gt;   company  year total</span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>   <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span> A        <span style='text-decoration: underline;'>2</span>019    70</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span> A        <span style='text-decoration: underline;'>2</span>020     4</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>3</span> B        <span style='text-decoration: underline;'>2</span>021    10</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>4</span> B        <span style='text-decoration: underline;'>2</span>023    30</span></span>
<span></span></code></pre>

</div>

There are a few things about `.by` worth noting:

-   The result is always ungrouped. With `.by`, you never need to remember to call [`ungroup()`](https://dplyr.tidyverse.org/reference/group_by.html).

-   We use tidy-select to group by multiple columns.

One of the things we like about `.by` is that it allows you to place the grouping specification alongside the code that actually uses it, rather than in a separate [`group_by()`](https://dplyr.tidyverse.org/reference/group_by.html) line. This idea was actually inspired by data.table's grouping syntax, which looks like:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>transactions</span><span class='o'>[</span>, <span class='nf'>.</span><span class='o'>(</span>total <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/sum.html'>sum</a></span><span class='o'>(</span><span class='nv'>revenue</span><span class='o'>)</span><span class='o'>)</span>, by <span class='o'>=</span> <span class='nf'>.</span><span class='o'>(</span><span class='nv'>company</span>, <span class='nv'>year</span><span class='o'>)</span><span class='o'>]</span></span></code></pre>

</div>

### `.by` or `by`?

As you begin to use per-operation grouping in dplyr, you'll likely notice that some verbs use `.by` and others use `by`, for example:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>transactions</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/slice.html'>slice_max</a></span><span class='o'>(</span><span class='nv'>revenue</span>, n <span class='o'>=</span> <span class='m'>2</span>, by <span class='o'>=</span> <span class='nv'>company</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 4 × 3</span></span></span>
<span><span class='c'>#&gt;   company  year revenue</span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>   <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>   <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span> A        <span style='text-decoration: underline;'>2</span>019      50</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span> A        <span style='text-decoration: underline;'>2</span>019      20</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>3</span> B        <span style='text-decoration: underline;'>2</span>023      18</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>4</span> B        <span style='text-decoration: underline;'>2</span>023      12</span></span>
<span></span></code></pre>

</div>

This is purely a technical difference resulting from the fact that some verbs consistently use a `.` prefix for their arguments, and others don't. Most dplyr verbs use `.by`, and we've tried to ensure that the cases that are most likely to result in typos instead generate an informative error:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='c'># Uses `by` to be consistent with `n` and `prop`</span></span>
<span><span class='nv'>transactions</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/slice.html'>slice_max</a></span><span class='o'>(</span><span class='nv'>revenue</span>, n <span class='o'>=</span> <span class='m'>2</span>, .by <span class='o'>=</span> <span class='nv'>company</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #BBBB00; font-weight: bold;'>Error</span><span style='font-weight: bold;'> in `slice_max()`:</span></span></span>
<span><span class='c'>#&gt; <span style='color: #BBBB00;'>!</span> Can't specify an argument named `.by` in this verb.</span></span>
<span><span class='c'>#&gt; <span style='color: #00BBBB;'>ℹ</span> Did you mean to use `by` instead?</span></span>
<span></span><span></span>
<span><span class='c'># Uses `.by` to be consistent with `.preserve`</span></span>
<span><span class='nv'>transactions</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/slice.html'>slice</a></span><span class='o'>(</span><span class='nv'>revenue</span>, by <span class='o'>=</span> <span class='nv'>company</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #BBBB00; font-weight: bold;'>Error</span><span style='font-weight: bold;'> in `slice()`:</span></span></span>
<span><span class='c'>#&gt; <span style='color: #BBBB00;'>!</span> Can't specify an argument named `by` in this verb.</span></span>
<span><span class='c'>#&gt; <span style='color: #00BBBB;'>ℹ</span> Did you mean to use `.by` instead?</span></span>
<span></span></code></pre>

</div>

### Translating from `group_by()`

You shouldn't feel pressured to translate existing code using [`group_by()`](https://dplyr.tidyverse.org/reference/group_by.html) to use `.by` instead. [`group_by()`](https://dplyr.tidyverse.org/reference/group_by.html) definitely won't ever disappear, and is not currently being superseded.

That said, if you do want to start using `.by`, there are a few differences from [`group_by()`](https://dplyr.tidyverse.org/reference/group_by.html) to be aware of.

-   `.by` always returns an ungrouped data frame. This is one of the main reasons to use `.by`, but is worth keeping in mind if you have existing code that takes advantage of the persistent grouping from [`group_by()`](https://dplyr.tidyverse.org/reference/group_by.html).

-   `.by` uses tidy-selection. [`group_by()`](https://dplyr.tidyverse.org/reference/group_by.html), on the other hand, works more like [`mutate()`](https://dplyr.tidyverse.org/reference/mutate.html) in that it allows you to create grouping columns on the fly, i.e. `df %>% group_by(month = floor_date(date, "month"))`. With `.by`, you must create your grouping columns ahead of time. An added benefit of `.by`'s usage of tidy-selection is that you can supply an external character vector of grouping variables using `.by = all_of(groups_vec)`.

-   `.by` doesn't sort grouping keys. [`group_by()`](https://dplyr.tidyverse.org/reference/group_by.html) always sorts keys in ascending order, which affects the results of verbs like [`summarise()`](https://dplyr.tidyverse.org/reference/summarise.html).

The last point might seem strange, but consider what would happen if we preferred our transactions data in order by descending year.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>transactions2</span> <span class='o'>&lt;-</span> <span class='nv'>transactions</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/arrange.html'>arrange</a></span><span class='o'>(</span><span class='nv'>company</span>, <span class='nf'><a href='https://dplyr.tidyverse.org/reference/desc.html'>desc</a></span><span class='o'>(</span><span class='nv'>year</span><span class='o'>)</span><span class='o'>)</span></span>
<span></span>
<span><span class='nv'>transactions2</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 6 × 3</span></span></span>
<span><span class='c'>#&gt;   company  year revenue</span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>   <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>   <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span> A        <span style='text-decoration: underline;'>2</span>020       4</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span> A        <span style='text-decoration: underline;'>2</span>019      20</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>3</span> A        <span style='text-decoration: underline;'>2</span>019      50</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>4</span> B        <span style='text-decoration: underline;'>2</span>023      12</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>5</span> B        <span style='text-decoration: underline;'>2</span>023      18</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>6</span> B        <span style='text-decoration: underline;'>2</span>021      10</span></span>
<span></span></code></pre>

</div>

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='c'># Note that `group_by()` re-ordered</span></span>
<span><span class='nv'>transactions2</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/group_by.html'>group_by</a></span><span class='o'>(</span><span class='nv'>company</span>, <span class='nv'>year</span><span class='o'>)</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/summarise.html'>summarise</a></span><span class='o'>(</span>total <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/sum.html'>sum</a></span><span class='o'>(</span><span class='nv'>revenue</span><span class='o'>)</span>, .groups <span class='o'>=</span> <span class='s'>"drop"</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 4 × 3</span></span></span>
<span><span class='c'>#&gt;   company  year total</span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>   <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span> A        <span style='text-decoration: underline;'>2</span>019    70</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span> A        <span style='text-decoration: underline;'>2</span>020     4</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>3</span> B        <span style='text-decoration: underline;'>2</span>021    10</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>4</span> B        <span style='text-decoration: underline;'>2</span>023    30</span></span>
<span></span><span></span>
<span><span class='c'># But `.by` used whatever order was already there</span></span>
<span><span class='nv'>transactions2</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/summarise.html'>summarise</a></span><span class='o'>(</span>total <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/sum.html'>sum</a></span><span class='o'>(</span><span class='nv'>revenue</span><span class='o'>)</span>, .by <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='nv'>company</span>, <span class='nv'>year</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 4 × 3</span></span></span>
<span><span class='c'>#&gt;   company  year total</span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>   <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span> A        <span style='text-decoration: underline;'>2</span>020     4</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span> A        <span style='text-decoration: underline;'>2</span>019    70</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>3</span> B        <span style='text-decoration: underline;'>2</span>023    30</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>4</span> B        <span style='text-decoration: underline;'>2</span>021    10</span></span>
<span></span></code></pre>

</div>

Notice that `.by` doesn't re-sort the grouping keys. Instead, the previous call to [`arrange()`](https://dplyr.tidyverse.org/reference/arrange.html) is "respected" in the summary (this is also useful in combination with the new `.locale` argument to [`arrange()`](https://dplyr.tidyverse.org/reference/arrange.html)).

## `nest(.by = )`

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://tidyr.tidyverse.org'>tidyr</a></span><span class='o'>)</span></span></code></pre>

</div>

The idea behind `.by` turns out to be useful in contexts outside of dplyr. In [tidyr 1.3.0](https://www.tidyverse.org/blog/2023/01/tidyr-1-3-0/#nestby), [`nest()`](https://tidyr.tidyverse.org/reference/nest.html) gained a `.by` argument, allowing you to specify the columns you want to nest *by* rather than the columns that appear in the nested results, which often makes for more natural calls to [`nest()`](https://tidyr.tidyverse.org/reference/nest.html).

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='c'># Specify what to nest by</span></span>
<span><span class='nv'>transactions</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span></span>
<span>  <span class='nf'><a href='https://tidyr.tidyverse.org/reference/nest.html'>nest</a></span><span class='o'>(</span>.by <span class='o'>=</span> <span class='nv'>company</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 2 × 2</span></span></span>
<span><span class='c'>#&gt;   company data            </span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>   <span style='color: #555555; font-style: italic;'>&lt;list&gt;</span>          </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span> A       <span style='color: #555555;'>&lt;tibble [3 × 2]&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span> B       <span style='color: #555555;'>&lt;tibble [3 × 2]&gt;</span></span></span>
<span></span><span></span>
<span><span class='c'># Specify what to nest</span></span>
<span><span class='nv'>transactions</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span></span>
<span>  <span class='nf'><a href='https://tidyr.tidyverse.org/reference/nest.html'>nest</a></span><span class='o'>(</span>data <span class='o'>=</span> <span class='o'>-</span><span class='nv'>company</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 2 × 2</span></span></span>
<span><span class='c'>#&gt;   company data            </span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>   <span style='color: #555555; font-style: italic;'>&lt;list&gt;</span>          </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span> A       <span style='color: #555555;'>&lt;tibble [3 × 2]&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span> B       <span style='color: #555555;'>&lt;tibble [3 × 2]&gt;</span></span></span>
<span></span><span></span>
<span><span class='c'># Specify both, allowing you to drop `year` along the way</span></span>
<span><span class='nv'>transactions</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span></span>
<span>  <span class='nf'><a href='https://tidyr.tidyverse.org/reference/nest.html'>nest</a></span><span class='o'>(</span>data <span class='o'>=</span> <span class='nv'>revenue</span>, .by <span class='o'>=</span> <span class='nv'>company</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 2 × 2</span></span></span>
<span><span class='c'>#&gt;   company data            </span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>   <span style='color: #555555; font-style: italic;'>&lt;list&gt;</span>          </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span> A       <span style='color: #555555;'>&lt;tibble [3 × 1]&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span> B       <span style='color: #555555;'>&lt;tibble [3 × 1]&gt;</span></span></span>
<span></span></code></pre>

</div>

We currently have 3 different nesting variants in the tidyverse: [`tidyr::nest()`](https://tidyr.tidyverse.org/reference/nest.html), [`dplyr::group_nest()`](https://dplyr.tidyverse.org/reference/group_nest.html), and [`dplyr::nest_by()`](https://dplyr.tidyverse.org/reference/nest_by.html). Because the tidyr variant is now the most flexible of all of these, and because [`unnest()`](https://tidyr.tidyverse.org/reference/unnest.html) also lives in tidyr, we are likely to deprecate the two experimental dplyr options in the future.

