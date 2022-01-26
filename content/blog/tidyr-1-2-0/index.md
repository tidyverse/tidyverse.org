---
output: hugodown::hugo_document
slug: tidyr-1-2-0
title: tidyr 1.2.0
date: 2022-01-25
author: Davis Vaughan
description: >
    tidyr 1.2.0 includes a bunch of new features and bug fixes, particularly for pivoting, rectangling, and grid specific tools.
photo:
  url: https://unsplash.com/photos/Qv0d5LJCxgo
  author: Brina Blum
categories: [package] 
tags: []
editor_options: 
  chunk_output_type: console
rmd_hash: 493d96de6216c76e

---

We're chuffed to announce the release of [tidyr](https://tidyr.tidyverse.org) 1.2.0. tidyr provides a set of tools for transforming data frames to and from tidy data, where each variable is a column and each observation is a row. Tidy data is a convention for matching the semantics and structure of your data that makes using the rest of the tidyverse (and many other R packages) much easier.

You can install it from CRAN with:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://rdrr.io/r/utils/install.packages.html'>install.packages</a></span><span class='o'>(</span><span class='s'>"tidyr"</span><span class='o'>)</span></code></pre>

</div>

This blog post will go over the main new features, which include: four new arguments to [`pivot_wider()`](https://tidyr.tidyverse.org/reference/pivot_wider.html), the ability to unnest multiple columns at once in [`unnest_wider()`](https://tidyr.tidyverse.org/reference/hoist.html) and [`unnest_longer()`](https://tidyr.tidyverse.org/reference/hoist.html), an enhanced [`complete()`](https://tidyr.tidyverse.org/reference/complete.html) function, and some updates to our tools for handling missing values.

You can see a full list of changes in the [release notes](https://github.com/tidyverse/tidyr/blob/main/NEWS.md), where you'll also find details on the \~50 bugs that were fixed in this release!

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://tidyr.tidyverse.org'>tidyr</a></span><span class='o'>)</span>
<span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://dplyr.tidyverse.org'>dplyr</a></span>, warn.conflicts <span class='o'>=</span> <span class='kc'>FALSE</span><span class='o'>)</span></code></pre>

</div>

## New author

First off, we are very excited to welcome [Maximilian Girlich](https://github.com/mgirlich) as a new tidyr author in recognition of his significant and sustained contributions. In particular, he played a large part in speeding up a number of core functions, including: [`unchop()`](https://tidyr.tidyverse.org/reference/chop.html), [`unnest()`](https://tidyr.tidyverse.org/reference/nest.html), [`unnest_wider()`](https://tidyr.tidyverse.org/reference/hoist.html), and [`unnest_longer()`](https://tidyr.tidyverse.org/reference/hoist.html). Additionally, he provided proof-of-concept implementations for a few new features, like the `unused_fn` argument to [`pivot_wider()`](https://tidyr.tidyverse.org/reference/pivot_wider.html) discussed below.

## Pivoting

### Value expansion

[`pivot_wider()`](https://tidyr.tidyverse.org/reference/pivot_wider.html) has gained two new arguments related to the *expansion* of values. These arguments are similar to `drop = FALSE` from [`spread()`](https://tidyr.tidyverse.org/reference/spread.html), but are a bit more fine grained. As you'll see, these are mostly useful when you have factors in either `names_from` or `id_cols` and want to ensure that all of the factor levels are retained.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>weekdays</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"Mon"</span>, <span class='s'>"Tue"</span>, <span class='s'>"Wed"</span>, <span class='s'>"Thu"</span>, <span class='s'>"Fri"</span>, <span class='s'>"Sat"</span>, <span class='s'>"Sun"</span><span class='o'>)</span>

<span class='nv'>daily</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://tibble.tidyverse.org/reference/tibble.html'>tibble</a></span><span class='o'>(</span>
  day <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/factor.html'>factor</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"Tue"</span>, <span class='s'>"Thu"</span>, <span class='s'>"Fri"</span>, <span class='s'>"Mon"</span><span class='o'>)</span>, levels <span class='o'>=</span> <span class='nv'>weekdays</span><span class='o'>)</span>,
  value <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='m'>2</span>, <span class='m'>3</span>, <span class='m'>1</span>, <span class='m'>5</span><span class='o'>)</span>
<span class='o'>)</span>

<span class='nv'>daily</span>
<span class='c'>#&gt; <span style='color: #555555;'># A tibble: 4 × 2</span></span>
<span class='c'>#&gt;   day   value</span>
<span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;fct&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>1</span> Tue       2</span>
<span class='c'>#&gt; <span style='color: #555555;'>2</span> Thu       3</span>
<span class='c'>#&gt; <span style='color: #555555;'>3</span> Fri       1</span>
<span class='c'>#&gt; <span style='color: #555555;'>4</span> Mon       5</span></code></pre>

</div>

Imagine you'd like to pivot the values from `day` into columns, filling the cells with `value`. By default, [`pivot_wider()`](https://tidyr.tidyverse.org/reference/pivot_wider.html) only generates columns from the data that is actually there, and will retain the ordering that was present in the data.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://tidyr.tidyverse.org/reference/pivot_wider.html'>pivot_wider</a></span><span class='o'>(</span><span class='nv'>daily</span>, names_from <span class='o'>=</span> <span class='nv'>day</span>, values_from <span class='o'>=</span> <span class='nv'>value</span><span class='o'>)</span>
<span class='c'>#&gt; <span style='color: #555555;'># A tibble: 1 × 4</span></span>
<span class='c'>#&gt;     Tue   Thu   Fri   Mon</span>
<span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>1</span>     2     3     1     5</span></code></pre>

</div>

When you know the full set of possible values and have encoded them as factor levels (as we have done here), you might want to retain those levels in the pivot, even if there isn't any data. Additionally, it would probably be nice if they were sorted to match the levels found in the factor. The new `names_expand` argument handles both of these.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://tidyr.tidyverse.org/reference/pivot_wider.html'>pivot_wider</a></span><span class='o'>(</span><span class='nv'>daily</span>, names_from <span class='o'>=</span> <span class='nv'>day</span>, values_from <span class='o'>=</span> <span class='nv'>value</span>, names_expand <span class='o'>=</span> <span class='kc'>TRUE</span><span class='o'>)</span>
<span class='c'>#&gt; <span style='color: #555555;'># A tibble: 1 × 7</span></span>
<span class='c'>#&gt;     Mon   Tue   Wed   Thu   Fri   Sat   Sun</span>
<span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>1</span>     5     2    <span style='color: #BB0000;'>NA</span>     3     1    <span style='color: #BB0000;'>NA</span>    <span style='color: #BB0000;'>NA</span></span></code></pre>

</div>

A related problem can occur when there are implicit missing factor levels in the `id_cols`. When this happens, there are missing rows (rather than columns) that you'd like to explicitly represent. To demonstrate, we'll modify `daily` with a `type` column, and pivot on that instead, keeping `day` as an identifier column.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>daily</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://dplyr.tidyverse.org/reference/mutate.html'>mutate</a></span><span class='o'>(</span><span class='nv'>daily</span>, type <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"A"</span>, <span class='s'>"B"</span>, <span class='s'>"B"</span>, <span class='s'>"A"</span><span class='o'>)</span><span class='o'>)</span>
<span class='nv'>daily</span>
<span class='c'>#&gt; <span style='color: #555555;'># A tibble: 4 × 3</span></span>
<span class='c'>#&gt;   day   value type </span>
<span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;fct&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>1</span> Tue       2 A    </span>
<span class='c'>#&gt; <span style='color: #555555;'>2</span> Thu       3 B    </span>
<span class='c'>#&gt; <span style='color: #555555;'>3</span> Fri       1 B    </span>
<span class='c'>#&gt; <span style='color: #555555;'>4</span> Mon       5 A</span></code></pre>

</div>

In the pivot below, we are missing some rows corresponding to the missing factor levels of `day`. Again, by default [`pivot_wider()`](https://tidyr.tidyverse.org/reference/pivot_wider.html) will only use data that already exists in the `id_cols`.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://tidyr.tidyverse.org/reference/pivot_wider.html'>pivot_wider</a></span><span class='o'>(</span>
  <span class='nv'>daily</span>, 
  names_from <span class='o'>=</span> <span class='nv'>type</span>, 
  values_from <span class='o'>=</span> <span class='nv'>value</span>
<span class='o'>)</span>
<span class='c'>#&gt; <span style='color: #555555;'># A tibble: 4 × 3</span></span>
<span class='c'>#&gt;   day       A     B</span>
<span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;fct&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>1</span> Tue       2    <span style='color: #BB0000;'>NA</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>2</span> Thu      <span style='color: #BB0000;'>NA</span>     3</span>
<span class='c'>#&gt; <span style='color: #555555;'>3</span> Fri      <span style='color: #BB0000;'>NA</span>     1</span>
<span class='c'>#&gt; <span style='color: #555555;'>4</span> Mon       5    <span style='color: #BB0000;'>NA</span></span></code></pre>

</div>

To explicitly expand (and sort) these missing rows, we can use `id_expand`, which works much the same way as `names_expand`. We will also go ahead and fill the unrepresented values with zeros.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://tidyr.tidyverse.org/reference/pivot_wider.html'>pivot_wider</a></span><span class='o'>(</span>
  <span class='nv'>daily</span>, 
  id_expand <span class='o'>=</span> <span class='kc'>TRUE</span>,
  names_from <span class='o'>=</span> <span class='nv'>type</span>, 
  values_from <span class='o'>=</span> <span class='nv'>value</span>,
  values_fill <span class='o'>=</span> <span class='m'>0</span>
<span class='o'>)</span>
<span class='c'>#&gt; <span style='color: #555555;'># A tibble: 7 × 3</span></span>
<span class='c'>#&gt;   day       A     B</span>
<span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;fct&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>1</span> Mon       5     0</span>
<span class='c'>#&gt; <span style='color: #555555;'>2</span> Tue       2     0</span>
<span class='c'>#&gt; <span style='color: #555555;'>3</span> Wed       0     0</span>
<span class='c'>#&gt; <span style='color: #555555;'>4</span> Thu       0     3</span>
<span class='c'>#&gt; <span style='color: #555555;'>5</span> Fri       0     1</span>
<span class='c'>#&gt; <span style='color: #555555;'>6</span> Sat       0     0</span>
<span class='c'>#&gt; <span style='color: #555555;'>7</span> Sun       0     0</span></code></pre>

</div>

### Varying names

When you specify multiple `values_from` columns, the resulting column names that get generated from the combination of `names_from` values and `values_from` names default to varying the `names_from` values *fastest*. This means that all of the columns related to the first `values_from` column will be at the front, followed by the columns related to the second `values_from` column, and so on. For example, if we wanted to flatten `daily` all the way out to a single row by specifying `values_from = c(value, type)`, then we would end up with all the columns related to `value` followed by those related to `type`.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://tidyr.tidyverse.org/reference/pivot_wider.html'>pivot_wider</a></span><span class='o'>(</span>
  <span class='nv'>daily</span>,
  names_from <span class='o'>=</span> <span class='nv'>day</span>,
  values_from <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='nv'>value</span>, <span class='nv'>type</span><span class='o'>)</span>,
  names_expand <span class='o'>=</span> <span class='kc'>TRUE</span>
<span class='o'>)</span>
<span class='c'>#&gt; <span style='color: #555555;'># A tibble: 1 × 14</span></span>
<span class='c'>#&gt;   value_Mon value_Tue value_Wed value_Thu value_Fri value_Sat value_Sun type_Mon</span>
<span class='c'>#&gt;       <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>     <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>     <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>     <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>     <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>     <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>     <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>   </span>
<span class='c'>#&gt; <span style='color: #555555;'>1</span>         5         2        <span style='color: #BB0000;'>NA</span>         3         1        <span style='color: #BB0000;'>NA</span>        <span style='color: #BB0000;'>NA</span> A       </span>
<span class='c'>#&gt; <span style='color: #555555;'># … with 6 more variables: type_Tue &lt;chr&gt;, type_Wed &lt;chr&gt;, type_Thu &lt;chr&gt;,</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>#   type_Fri &lt;chr&gt;, type_Sat &lt;chr&gt;, type_Sun &lt;chr&gt;</span></span></code></pre>

</div>

Depending on your data, you might instead want to group all of the columns related to a particular `names_from` value together. In this example, that would mean grouping all of the columns related to Monday together, followed by Tuesday, Wednesday, etc. You can accomplish this with the new `names_vary` argument, which allows you to vary the `names_from` values *slowest*.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://tidyr.tidyverse.org/reference/pivot_wider.html'>pivot_wider</a></span><span class='o'>(</span>
  <span class='nv'>daily</span>,
  names_from <span class='o'>=</span> <span class='nv'>day</span>,
  values_from <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='nv'>value</span>, <span class='nv'>type</span><span class='o'>)</span>,
  names_expand <span class='o'>=</span> <span class='kc'>TRUE</span>,
  names_vary <span class='o'>=</span> <span class='s'>"slowest"</span>
<span class='o'>)</span>
<span class='c'>#&gt; <span style='color: #555555;'># A tibble: 1 × 14</span></span>
<span class='c'>#&gt;   value_Mon type_Mon value_Tue type_Tue value_Wed type_Wed value_Thu type_Thu</span>
<span class='c'>#&gt;       <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>        <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>        <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>        <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>   </span>
<span class='c'>#&gt; <span style='color: #555555;'>1</span>         5 A                2 A               <span style='color: #BB0000;'>NA</span> <span style='color: #BB0000;'>NA</span>               3 B       </span>
<span class='c'>#&gt; <span style='color: #555555;'># … with 6 more variables: value_Fri &lt;dbl&gt;, type_Fri &lt;chr&gt;, value_Sat &lt;dbl&gt;,</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>#   type_Sat &lt;chr&gt;, value_Sun &lt;dbl&gt;, type_Sun &lt;chr&gt;</span></span></code></pre>

</div>

### Unused columns

Occasionally you'll find yourself in a situation where you have columns in your data that are unrelated to the pivoting process itself, but you'd still like to retain some information about them. Consider this data set that records values returned by various systems across multiple counties.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>readouts</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://tibble.tidyverse.org/reference/tibble.html'>tibble</a></span><span class='o'>(</span>
  county <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"Wake"</span>, <span class='s'>"Wake"</span>, <span class='s'>"Wake"</span>, <span class='s'>"Guilford"</span>, <span class='s'>"Guilford"</span><span class='o'>)</span>,
  date <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/as.Date.html'>as.Date</a></span><span class='o'>(</span><span class='s'>"2020-01-01"</span><span class='o'>)</span> <span class='o'>+</span> <span class='m'>0</span><span class='o'>:</span><span class='m'>2</span>, <span class='nf'><a href='https://rdrr.io/r/base/as.Date.html'>as.Date</a></span><span class='o'>(</span><span class='s'>"2020-01-03"</span><span class='o'>)</span> <span class='o'>+</span> <span class='m'>0</span><span class='o'>:</span><span class='m'>1</span><span class='o'>)</span>,
  system <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"A"</span>, <span class='s'>"B"</span>, <span class='s'>"C"</span>, <span class='s'>"A"</span>, <span class='s'>"C"</span><span class='o'>)</span>,
  value <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='m'>3.2</span>, <span class='m'>4</span>, <span class='m'>5.5</span>, <span class='m'>2</span>, <span class='m'>1.2</span><span class='o'>)</span>
<span class='o'>)</span>

<span class='nv'>readouts</span>
<span class='c'>#&gt; <span style='color: #555555;'># A tibble: 5 × 4</span></span>
<span class='c'>#&gt;   county   date       system value</span>
<span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>    <span style='color: #555555; font-style: italic;'>&lt;date&gt;</span>     <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>  <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>1</span> Wake     2020-01-01 A        3.2</span>
<span class='c'>#&gt; <span style='color: #555555;'>2</span> Wake     2020-01-02 B        4  </span>
<span class='c'>#&gt; <span style='color: #555555;'>3</span> Wake     2020-01-03 C        5.5</span>
<span class='c'>#&gt; <span style='color: #555555;'>4</span> Guilford 2020-01-03 A        2  </span>
<span class='c'>#&gt; <span style='color: #555555;'>5</span> Guilford 2020-01-04 C        1.2</span></code></pre>

</div>

You might want to pivot this into a view containing one row per `county`, with the `system` types across the columns. You might do something like:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://tidyr.tidyverse.org/reference/pivot_wider.html'>pivot_wider</a></span><span class='o'>(</span>
  <span class='nv'>readouts</span>,
  id_cols <span class='o'>=</span> <span class='nv'>county</span>,
  names_from <span class='o'>=</span> <span class='nv'>system</span>,
  values_from <span class='o'>=</span> <span class='nv'>value</span>
<span class='o'>)</span>
<span class='c'>#&gt; <span style='color: #555555;'># A tibble: 2 × 4</span></span>
<span class='c'>#&gt;   county       A     B     C</span>
<span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>    <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>1</span> Wake       3.2     4   5.5</span>
<span class='c'>#&gt; <span style='color: #555555;'>2</span> Guilford   2      <span style='color: #BB0000;'>NA</span>   1.2</span></code></pre>

</div>

This worked, but in the process we've lost all of the information from the `date` column about when the values were recorded. To fix this, we can use the new `unused_fn` argument to retain a summary of the unused `date` column. In our case, we'll retain the most recent date a value was recorded across all systems.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://tidyr.tidyverse.org/reference/pivot_wider.html'>pivot_wider</a></span><span class='o'>(</span>
  <span class='nv'>readouts</span>,
  id_cols <span class='o'>=</span> <span class='nv'>county</span>,
  names_from <span class='o'>=</span> <span class='nv'>system</span>,
  values_from <span class='o'>=</span> <span class='nv'>value</span>,
  unused_fn <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span>date <span class='o'>=</span> <span class='nv'>max</span><span class='o'>)</span>
<span class='o'>)</span>
<span class='c'>#&gt; <span style='color: #555555;'># A tibble: 2 × 5</span></span>
<span class='c'>#&gt;   county       A     B     C date      </span>
<span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>    <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;date&gt;</span>    </span>
<span class='c'>#&gt; <span style='color: #555555;'>1</span> Wake       3.2     4   5.5 2020-01-03</span>
<span class='c'>#&gt; <span style='color: #555555;'>2</span> Guilford   2      <span style='color: #BB0000;'>NA</span>   1.2 2020-01-04</span></code></pre>

</div>

If you want to retain the unused columns but delay the summarization entirely, you can use [`list()`](https://rdrr.io/r/base/list.html) to wrap up the value into a list column.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://tidyr.tidyverse.org/reference/pivot_wider.html'>pivot_wider</a></span><span class='o'>(</span>
  <span class='nv'>readouts</span>,
  id_cols <span class='o'>=</span> <span class='nv'>county</span>,
  names_from <span class='o'>=</span> <span class='nv'>system</span>,
  values_from <span class='o'>=</span> <span class='nv'>value</span>,
  unused_fn <span class='o'>=</span> <span class='nv'>list</span>
<span class='o'>)</span>
<span class='c'>#&gt; <span style='color: #555555;'># A tibble: 2 × 5</span></span>
<span class='c'>#&gt;   county       A     B     C date      </span>
<span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>    <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;list&gt;</span>    </span>
<span class='c'>#&gt; <span style='color: #555555;'>1</span> Wake       3.2     4   5.5 <span style='color: #555555;'>&lt;date [3]&gt;</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>2</span> Guilford   2      <span style='color: #BB0000;'>NA</span>   1.2 <span style='color: #555555;'>&lt;date [2]&gt;</span></span></code></pre>

</div>

Note that for `unused_fn` to work, you must supply `id_cols` explicitly, as otherwise all of the remaining columns are assumed to be `id_cols`.

### More informative errors

We've improved on a number of the error messages throughout tidyr, but the error you get from [`pivot_wider()`](https://tidyr.tidyverse.org/reference/pivot_wider.html) when you encounter values that aren't uniquely identified is now especially nice. Let's "accidentally" add a duplicate row to `readouts`.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>readouts2</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://dplyr.tidyverse.org/reference/slice.html'>slice</a></span><span class='o'>(</span><span class='nv'>readouts</span>, <span class='nf'><a href='https://rdrr.io/r/base/seq.html'>seq_len</a></span><span class='o'>(</span><span class='nf'><a href='https://dplyr.tidyverse.org/reference/context.html'>n</a></span><span class='o'>(</span><span class='o'>)</span><span class='o'>)</span>, <span class='nf'><a href='https://dplyr.tidyverse.org/reference/context.html'>n</a></span><span class='o'>(</span><span class='o'>)</span><span class='o'>)</span> 
<span class='nv'>readouts2</span>
<span class='c'>#&gt; <span style='color: #555555;'># A tibble: 6 × 4</span></span>
<span class='c'>#&gt;   county   date       system value</span>
<span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>    <span style='color: #555555; font-style: italic;'>&lt;date&gt;</span>     <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>  <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>1</span> Wake     2020-01-01 A        3.2</span>
<span class='c'>#&gt; <span style='color: #555555;'>2</span> Wake     2020-01-02 B        4  </span>
<span class='c'>#&gt; <span style='color: #555555;'>3</span> Wake     2020-01-03 C        5.5</span>
<span class='c'>#&gt; <span style='color: #555555;'>4</span> Guilford 2020-01-03 A        2  </span>
<span class='c'>#&gt; <span style='color: #555555;'>5</span> Guilford 2020-01-04 C        1.2</span>
<span class='c'>#&gt; <span style='color: #555555;'>6</span> Guilford 2020-01-04 C        1.2</span></code></pre>

</div>

Pivoting on `system` warns us that the values from `value` are not uniquely identified.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://tidyr.tidyverse.org/reference/pivot_wider.html'>pivot_wider</a></span><span class='o'>(</span>
  <span class='nv'>readouts2</span>,
  id_cols <span class='o'>=</span> <span class='nv'>county</span>,
  names_from <span class='o'>=</span> <span class='nv'>system</span>,
  values_from <span class='o'>=</span> <span class='nv'>value</span>
<span class='o'>)</span>
<span class='c'>#&gt; Warning: Values from `value` are not uniquely identified; output will contain list-cols.</span>
<span class='c'>#&gt; * Use `values_fn = list` to suppress this warning.</span>
<span class='c'>#&gt; * Use `values_fn = &#123;summary_fun&#125;` to summarise duplicates.</span>
<span class='c'>#&gt; * Use the following dplyr code to identify duplicates.</span>
<span class='c'>#&gt;   &#123;data&#125; %&gt;%</span>
<span class='c'>#&gt;     dplyr::group_by(county, system) %&gt;%</span>
<span class='c'>#&gt;     dplyr::summarise(n = dplyr::n(), .groups = "drop") %&gt;%</span>
<span class='c'>#&gt;     dplyr::filter(n &gt; 1L)</span>
<span class='c'>#&gt; <span style='color: #555555;'># A tibble: 2 × 4</span></span>
<span class='c'>#&gt;   county   A         B         C        </span>
<span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>    <span style='color: #555555; font-style: italic;'>&lt;list&gt;</span>    <span style='color: #555555; font-style: italic;'>&lt;list&gt;</span>    <span style='color: #555555; font-style: italic;'>&lt;list&gt;</span>   </span>
<span class='c'>#&gt; <span style='color: #555555;'>1</span> Wake     <span style='color: #555555;'>&lt;dbl [1]&gt;</span> <span style='color: #555555;'>&lt;dbl [1]&gt;</span> <span style='color: #555555;'>&lt;dbl [1]&gt;</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>2</span> Guilford <span style='color: #555555;'>&lt;dbl [1]&gt;</span> <span style='color: #555555;'>&lt;NULL&gt;</span>    <span style='color: #555555;'>&lt;dbl [2]&gt;</span></span></code></pre>

</div>

This provides us with a number of options, but the last one is particularly useful if we weren't expecting duplicates. This prints out a block of dplyr code that you can use to quickly identify duplication issues. Replacing `{data}` with `readouts2`, we get:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>readouts2</span> <span class='o'><a href='https://tidyr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span>
  <span class='nf'>dplyr</span><span class='nf'>::</span><span class='nf'><a href='https://dplyr.tidyverse.org/reference/group_by.html'>group_by</a></span><span class='o'>(</span><span class='nv'>county</span>, <span class='nv'>system</span><span class='o'>)</span> <span class='o'><a href='https://tidyr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span>
  <span class='nf'>dplyr</span><span class='nf'>::</span><span class='nf'><a href='https://dplyr.tidyverse.org/reference/summarise.html'>summarise</a></span><span class='o'>(</span>n <span class='o'>=</span> <span class='nf'>dplyr</span><span class='nf'>::</span><span class='nf'><a href='https://dplyr.tidyverse.org/reference/context.html'>n</a></span><span class='o'>(</span><span class='o'>)</span>, .groups <span class='o'>=</span> <span class='s'>"drop"</span><span class='o'>)</span> <span class='o'><a href='https://tidyr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span>
  <span class='nf'>dplyr</span><span class='nf'>::</span><span class='nf'><a href='https://dplyr.tidyverse.org/reference/filter.html'>filter</a></span><span class='o'>(</span><span class='nv'>n</span> <span class='o'>&gt;</span> <span class='m'>1L</span><span class='o'>)</span> 
<span class='c'>#&gt; <span style='color: #555555;'># A tibble: 1 × 3</span></span>
<span class='c'>#&gt;   county   system     n</span>
<span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>    <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>  <span style='color: #555555; font-style: italic;'>&lt;int&gt;</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>1</span> Guilford C          2</span></code></pre>

</div>

## (Un)nesting

[`unnest_longer()`](https://tidyr.tidyverse.org/reference/hoist.html) and [`unnest_wider()`](https://tidyr.tidyverse.org/reference/hoist.html) have both gained the ability to unnest multiple columns at once. This is particularly useful with [`unnest_longer()`](https://tidyr.tidyverse.org/reference/hoist.html), where sequential unnesting would instead result in a Cartesian product, which isn't typically desired.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>df</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://tibble.tidyverse.org/reference/tibble.html'>tibble</a></span><span class='o'>(</span>x <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span><span class='m'>1</span>, <span class='m'>1</span><span class='o'>:</span><span class='m'>2</span><span class='o'>)</span>, y <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span><span class='m'>1</span>, <span class='m'>1</span><span class='o'>:</span><span class='m'>2</span><span class='o'>)</span><span class='o'>)</span>
<span class='nv'>df</span>
<span class='c'>#&gt; <span style='color: #555555;'># A tibble: 2 × 2</span></span>
<span class='c'>#&gt;   x         y        </span>
<span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;list&gt;</span>    <span style='color: #555555; font-style: italic;'>&lt;list&gt;</span>   </span>
<span class='c'>#&gt; <span style='color: #555555;'>1</span> <span style='color: #555555;'>&lt;dbl [1]&gt;</span> <span style='color: #555555;'>&lt;dbl [1]&gt;</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>2</span> <span style='color: #555555;'>&lt;int [2]&gt;</span> <span style='color: #555555;'>&lt;int [2]&gt;</span></span></code></pre>

</div>

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='c'># Sequential unnesting</span>
<span class='nv'>df</span> <span class='o'><a href='https://tidyr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span>
  <span class='nf'><a href='https://tidyr.tidyverse.org/reference/hoist.html'>unnest_longer</a></span><span class='o'>(</span><span class='nv'>x</span><span class='o'>)</span> <span class='o'><a href='https://tidyr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span>
  <span class='nf'><a href='https://tidyr.tidyverse.org/reference/hoist.html'>unnest_longer</a></span><span class='o'>(</span><span class='nv'>y</span><span class='o'>)</span>
<span class='c'>#&gt; <span style='color: #555555;'># A tibble: 5 × 2</span></span>
<span class='c'>#&gt;       x     y</span>
<span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>1</span>     1     1</span>
<span class='c'>#&gt; <span style='color: #555555;'>2</span>     1     1</span>
<span class='c'>#&gt; <span style='color: #555555;'>3</span>     1     2</span>
<span class='c'>#&gt; <span style='color: #555555;'>4</span>     2     1</span>
<span class='c'>#&gt; <span style='color: #555555;'>5</span>     2     2</span>

<span class='c'># Joint unnesting</span>
<span class='nf'><a href='https://tidyr.tidyverse.org/reference/hoist.html'>unnest_longer</a></span><span class='o'>(</span><span class='nv'>df</span>, <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='nv'>x</span>, <span class='nv'>y</span><span class='o'>)</span><span class='o'>)</span>
<span class='c'>#&gt; <span style='color: #555555;'># A tibble: 3 × 2</span></span>
<span class='c'>#&gt;       x     y</span>
<span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>1</span>     1     1</span>
<span class='c'>#&gt; <span style='color: #555555;'>2</span>     1     1</span>
<span class='c'>#&gt; <span style='color: #555555;'>3</span>     2     2</span></code></pre>

</div>

## Grids

When [`complete()`](https://tidyr.tidyverse.org/reference/complete.html)-ing a data frame, it's often useful to immediately fill the newly generated missing values with a value that better represents their intention. For example, with the `daily` data we could complete on the `day` factor column and insert zeros for `value` in any row that wasn't previously represented.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>daily</span>
<span class='c'>#&gt; <span style='color: #555555;'># A tibble: 4 × 3</span></span>
<span class='c'>#&gt;   day   value type </span>
<span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;fct&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>1</span> Tue       2 A    </span>
<span class='c'>#&gt; <span style='color: #555555;'>2</span> Thu       3 B    </span>
<span class='c'>#&gt; <span style='color: #555555;'>3</span> Fri       1 B    </span>
<span class='c'>#&gt; <span style='color: #555555;'>4</span> Mon       5 A</span>

<span class='nf'><a href='https://tidyr.tidyverse.org/reference/complete.html'>complete</a></span><span class='o'>(</span><span class='nv'>daily</span>, <span class='nv'>day</span>, fill <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span>value <span class='o'>=</span> <span class='m'>0</span><span class='o'>)</span><span class='o'>)</span>
<span class='c'>#&gt; <span style='color: #555555;'># A tibble: 7 × 3</span></span>
<span class='c'>#&gt;   day   value type </span>
<span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;fct&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>1</span> Mon       5 A    </span>
<span class='c'>#&gt; <span style='color: #555555;'>2</span> Tue       2 A    </span>
<span class='c'>#&gt; <span style='color: #555555;'>3</span> Wed       0 <span style='color: #BB0000;'>NA</span>   </span>
<span class='c'>#&gt; <span style='color: #555555;'>4</span> Thu       3 B    </span>
<span class='c'>#&gt; <span style='color: #555555;'>5</span> Fri       1 B    </span>
<span class='c'>#&gt; <span style='color: #555555;'>6</span> Sat       0 <span style='color: #BB0000;'>NA</span>   </span>
<span class='c'>#&gt; <span style='color: #555555;'>7</span> Sun       0 <span style='color: #BB0000;'>NA</span></span></code></pre>

</div>

But what if there were already missing values before completing? By default, [`complete()`](https://tidyr.tidyverse.org/reference/complete.html) will still fill those *explicit* missing values too.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>daily2</span> <span class='o'>&lt;-</span> <span class='nv'>daily</span>
<span class='nv'>daily2</span><span class='o'>$</span><span class='nv'>value</span><span class='o'>[</span><span class='nf'><a href='https://rdrr.io/r/base/nrow.html'>nrow</a></span><span class='o'>(</span><span class='nv'>daily2</span><span class='o'>)</span><span class='o'>]</span> <span class='o'>&lt;-</span> <span class='kc'>NA</span>
<span class='nv'>daily2</span>
<span class='c'>#&gt; <span style='color: #555555;'># A tibble: 4 × 3</span></span>
<span class='c'>#&gt;   day   value type </span>
<span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;fct&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>1</span> Tue       2 A    </span>
<span class='c'>#&gt; <span style='color: #555555;'>2</span> Thu       3 B    </span>
<span class='c'>#&gt; <span style='color: #555555;'>3</span> Fri       1 B    </span>
<span class='c'>#&gt; <span style='color: #555555;'>4</span> Mon      <span style='color: #BB0000;'>NA</span> A</span>

<span class='nf'><a href='https://tidyr.tidyverse.org/reference/complete.html'>complete</a></span><span class='o'>(</span><span class='nv'>daily2</span>, <span class='nv'>day</span>, fill <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span>value <span class='o'>=</span> <span class='m'>0</span><span class='o'>)</span><span class='o'>)</span>
<span class='c'>#&gt; <span style='color: #555555;'># A tibble: 7 × 3</span></span>
<span class='c'>#&gt;   day   value type </span>
<span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;fct&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>1</span> Mon       0 A    </span>
<span class='c'>#&gt; <span style='color: #555555;'>2</span> Tue       2 A    </span>
<span class='c'>#&gt; <span style='color: #555555;'>3</span> Wed       0 <span style='color: #BB0000;'>NA</span>   </span>
<span class='c'>#&gt; <span style='color: #555555;'>4</span> Thu       3 B    </span>
<span class='c'>#&gt; <span style='color: #555555;'>5</span> Fri       1 B    </span>
<span class='c'>#&gt; <span style='color: #555555;'>6</span> Sat       0 <span style='color: #BB0000;'>NA</span>   </span>
<span class='c'>#&gt; <span style='color: #555555;'>7</span> Sun       0 <span style='color: #BB0000;'>NA</span></span></code></pre>

</div>

To avoid this, you can now retain pre-existing explicit missing values with the new `explicit` argument:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://tidyr.tidyverse.org/reference/complete.html'>complete</a></span><span class='o'>(</span><span class='nv'>daily2</span>, <span class='nv'>day</span>, fill <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span>value <span class='o'>=</span> <span class='m'>0</span><span class='o'>)</span>, explicit <span class='o'>=</span> <span class='kc'>FALSE</span><span class='o'>)</span>
<span class='c'>#&gt; <span style='color: #555555;'># A tibble: 7 × 3</span></span>
<span class='c'>#&gt;   day   value type </span>
<span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;fct&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>1</span> Mon      <span style='color: #BB0000;'>NA</span> A    </span>
<span class='c'>#&gt; <span style='color: #555555;'>2</span> Tue       2 A    </span>
<span class='c'>#&gt; <span style='color: #555555;'>3</span> Wed       0 <span style='color: #BB0000;'>NA</span>   </span>
<span class='c'>#&gt; <span style='color: #555555;'>4</span> Thu       3 B    </span>
<span class='c'>#&gt; <span style='color: #555555;'>5</span> Fri       1 B    </span>
<span class='c'>#&gt; <span style='color: #555555;'>6</span> Sat       0 <span style='color: #BB0000;'>NA</span>   </span>
<span class='c'>#&gt; <span style='color: #555555;'>7</span> Sun       0 <span style='color: #BB0000;'>NA</span></span></code></pre>

</div>

## Missing values

The three core missing values functions, [`drop_na()`](https://tidyr.tidyverse.org/reference/drop_na.html), [`replace_na()`](https://tidyr.tidyverse.org/reference/replace_na.html), and [`fill()`](https://tidyr.tidyverse.org/reference/fill.html), have all been updated to utilize [vctrs](https://vctrs.r-lib.org). This allows them to work properly with a wider variety of types, and makes them safer to use with some of the existing types that they already supported.

As an example, [`fill()`](https://tidyr.tidyverse.org/reference/fill.html) now works properly with the Period types from [lubridate](https://lubridate.tidyverse.org):

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://lubridate.tidyverse.org'>lubridate</a></span>, warn.conflicts <span class='o'>=</span> <span class='kc'>FALSE</span><span class='o'>)</span>

<span class='nv'>df</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://tibble.tidyverse.org/reference/tibble.html'>tibble</a></span><span class='o'>(</span>x <span class='o'>=</span> <span class='nf'><a href='https://lubridate.tidyverse.org/reference/period.html'>seconds</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='m'>1</span>, <span class='m'>2</span>, <span class='kc'>NA</span>, <span class='m'>4</span>, <span class='kc'>NA</span><span class='o'>)</span><span class='o'>)</span><span class='o'>)</span>

<span class='nf'><a href='https://tidyr.tidyverse.org/reference/fill.html'>fill</a></span><span class='o'>(</span><span class='nv'>df</span>, <span class='nv'>x</span>, .direction <span class='o'>=</span> <span class='s'>"down"</span><span class='o'>)</span>
<span class='c'>#&gt; <span style='color: #555555;'># A tibble: 5 × 1</span></span>
<span class='c'>#&gt;   x       </span>
<span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;Period&gt;</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>1</span> 1S      </span>
<span class='c'>#&gt; <span style='color: #555555;'>2</span> 2S      </span>
<span class='c'>#&gt; <span style='color: #555555;'>3</span> 2S      </span>
<span class='c'>#&gt; <span style='color: #555555;'>4</span> 4S      </span>
<span class='c'>#&gt; <span style='color: #555555;'>5</span> 4S</span></code></pre>

</div>

And it now treats `NaN` like any other missing value:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>df</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://tibble.tidyverse.org/reference/tibble.html'>tibble</a></span><span class='o'>(</span>x <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='kc'>NaN</span>, <span class='m'>2</span>, <span class='kc'>NA</span>, <span class='m'>3</span><span class='o'>)</span><span class='o'>)</span>

<span class='nf'><a href='https://tidyr.tidyverse.org/reference/fill.html'>fill</a></span><span class='o'>(</span><span class='nv'>df</span>, <span class='nv'>x</span>, .direction <span class='o'>=</span> <span class='s'>"up"</span><span class='o'>)</span>
<span class='c'>#&gt; <span style='color: #555555;'># A tibble: 4 × 1</span></span>
<span class='c'>#&gt;       x</span>
<span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>1</span>     2</span>
<span class='c'>#&gt; <span style='color: #555555;'>2</span>     2</span>
<span class='c'>#&gt; <span style='color: #555555;'>3</span>     3</span>
<span class='c'>#&gt; <span style='color: #555555;'>4</span>     3</span></code></pre>

</div>

The most drastic improvement in safety comes to [`replace_na()`](https://tidyr.tidyverse.org/reference/replace_na.html). Previously, this relied on `[<-` to replace missing values with a replacement value, which is much laxer than vctrs in terms of what the replacement value can be. This resulted in the possibility for your column type to change depending on what your replacement value was.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='c'># Notice that this is an integer column</span>
<span class='nv'>df</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://tibble.tidyverse.org/reference/tibble.html'>tibble</a></span><span class='o'>(</span>x <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='m'>1L</span>, <span class='kc'>NA</span>, <span class='m'>3L</span><span class='o'>)</span><span class='o'>)</span>
<span class='nv'>df</span>
<span class='c'>#&gt; <span style='color: #555555;'># A tibble: 3 × 1</span></span>
<span class='c'>#&gt;       x</span>
<span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;int&gt;</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>1</span>     1</span>
<span class='c'>#&gt; <span style='color: #555555;'>2</span>    <span style='color: #BB0000;'>NA</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>3</span>     3</span></code></pre>

</div>

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='c'># Previous behavior without vctrs:</span>

<span class='c'># Integer column changed to character column</span>
<span class='nf'><a href='https://tidyr.tidyverse.org/reference/replace_na.html'>replace_na</a></span><span class='o'>(</span><span class='nv'>df</span>, <span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span>x <span class='o'>=</span> <span class='s'>"missing"</span><span class='o'>)</span><span class='o'>)</span>
<span class='c'>#&gt; # A tibble: 3 × 1</span>
<span class='c'>#&gt;   x      </span>
<span class='c'>#&gt;   &lt;chr&gt;  </span>
<span class='c'>#&gt; 1 1      </span>
<span class='c'>#&gt; 2 missing</span>
<span class='c'>#&gt; 3 3</span>

<span class='c'># Integer column changed to double column</span>
<span class='nf'><a href='https://tidyr.tidyverse.org/reference/replace_na.html'>replace_na</a></span><span class='o'>(</span><span class='nv'>df</span>, <span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span>x <span class='o'>=</span> <span class='m'>1</span><span class='o'>)</span><span class='o'>)</span>
<span class='c'>#&gt; # A tibble: 3 × 1</span>
<span class='c'>#&gt;       x</span>
<span class='c'>#&gt;   &lt;dbl&gt;</span>
<span class='c'>#&gt; 1     1</span>
<span class='c'>#&gt; 2     1</span>
<span class='c'>#&gt; 3     3</span></code></pre>

</div>

With vctrs, we now ensure that the replacement value is always cast to the type of the column you are replacing in. This ensures that the column types remain the same before and after you replace any missing values.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='c'># New behavior with vctrs:</span>

<span class='c'># Error, because "missing" can't be converted to an integer</span>
<span class='nf'><a href='https://tidyr.tidyverse.org/reference/replace_na.html'>replace_na</a></span><span class='o'>(</span><span class='nv'>df</span>, <span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span>x <span class='o'>=</span> <span class='s'>"missing"</span><span class='o'>)</span><span class='o'>)</span>
<span class='c'>#&gt; Error: Can't convert `replace$x` &lt;character&gt; to match type of `data$x` &lt;integer&gt;.</span>

<span class='c'># Integer column type is retained, and the double value of `1` is</span>
<span class='c'># converted to an integer replacement value of `1L`</span>
<span class='nf'><a href='https://tidyr.tidyverse.org/reference/replace_na.html'>replace_na</a></span><span class='o'>(</span><span class='nv'>df</span>, <span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span>x <span class='o'>=</span> <span class='m'>1</span><span class='o'>)</span><span class='o'>)</span>
<span class='c'>#&gt; <span style='color: #555555;'># A tibble: 3 × 1</span></span>
<span class='c'>#&gt;       x</span>
<span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;int&gt;</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>1</span>     1</span>
<span class='c'>#&gt; <span style='color: #555555;'>2</span>     1</span>
<span class='c'>#&gt; <span style='color: #555555;'>3</span>     3</span></code></pre>

</div>

## Acknowledgements

Thanks to the 25 people who contributed to this version of tidyr by discussing ideas and suggesting new features! [@aliaamiri](https://github.com/aliaamiri), [@allenbaron](https://github.com/allenbaron), [@bersbersbers](https://github.com/bersbersbers), [@cjburgess](https://github.com/cjburgess), [@DanChaltiel](https://github.com/DanChaltiel), [@edzer](https://github.com/edzer), [@eshom](https://github.com/eshom), [@gaborcsardi](https://github.com/gaborcsardi), [@gergness](https://github.com/gergness), [@ggrothendieck](https://github.com/ggrothendieck), [@iago-pssjd](https://github.com/iago-pssjd), [@issactoast](https://github.com/issactoast), [@joiharalds](https://github.com/joiharalds), [@LuiNov](https://github.com/LuiNov), [@LukasWallrich](https://github.com/LukasWallrich), [@mgirlich](https://github.com/mgirlich), [@MichaelChirico](https://github.com/MichaelChirico), [@NFA](https://github.com/NFA), [@olehost](https://github.com/olehost), [@psads-git](https://github.com/psads-git), [@psychelzh](https://github.com/psychelzh), [@ramiromagno](https://github.com/ramiromagno), [@romainfrancois](https://github.com/romainfrancois), [@TimTaylor](https://github.com/TimTaylor), and [@xiangpin](https://github.com/xiangpin).

