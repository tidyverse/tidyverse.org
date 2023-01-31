---
output: hugodown::hugo_document
slug: dplyr-1-1-0-joins
title: "dplyr 1.1.0: Joins"
date: 2023-01-31
author: Davis Vaughan
description: >
    In dplyr 1.1.0, joins have been greatly reworked, introducing: a new way to
    specify join columns, various new types of joins, and two new quality
    control arguments.
photo:
  url: https://unsplash.com/photos/Cecb0_8Hx-o
  author: Duy Pham
categories: [package] 
tags: [dplyr]
editor_options: 
  chunk_output_type: console
rmd_hash: 0b9bcb6ce2a59e18

---

[dplyr 1.1.0](https://dplyr.tidyverse.org/news/index.html#dplyr-110) is out now! This is post 1 of 4 detailing some of the new features in this release. In this post, we will discuss various new updates to dplyr's joins.

You can install it from CRAN with:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://rdrr.io/r/utils/install.packages.html'>install.packages</a></span><span class='o'>(</span><span class='s'>"dplyr"</span><span class='o'>)</span></span></code></pre>

</div>

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://dplyr.tidyverse.org'>dplyr</a></span><span class='o'>)</span></span></code></pre>

</div>

## `join_by()`

Consider the following two tables, `transactions` and `companies`. `transactions` tracks sales across various years for different companies, and `companies` connects the short company id to its actual company name - either Patagonia (a fellow B-Corp!) or RStudio.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>transactions</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://tibble.tidyverse.org/reference/tibble.html'>tibble</a></span><span class='o'>(</span></span>
<span>  company <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"A"</span>, <span class='s'>"A"</span>, <span class='s'>"B"</span>, <span class='s'>"B"</span><span class='o'>)</span>,</span>
<span>  year <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='m'>2019</span>, <span class='m'>2020</span>, <span class='m'>2021</span>, <span class='m'>2023</span><span class='o'>)</span>,</span>
<span>  revenue <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='m'>50</span>, <span class='m'>4</span>, <span class='m'>10</span>, <span class='m'>12</span><span class='o'>)</span></span>
<span><span class='o'>)</span></span>
<span><span class='nv'>transactions</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 4 × 3</span></span></span>
<span><span class='c'>#&gt;   company  year revenue</span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>   <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>   <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span> A        <span style='text-decoration: underline;'>2</span>019      50</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span> A        <span style='text-decoration: underline;'>2</span>020       4</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>3</span> B        <span style='text-decoration: underline;'>2</span>021      10</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>4</span> B        <span style='text-decoration: underline;'>2</span>023      12</span></span>
<span></span><span></span>
<span><span class='nv'>companies</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://tibble.tidyverse.org/reference/tibble.html'>tibble</a></span><span class='o'>(</span></span>
<span>  id <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"A"</span>, <span class='s'>"B"</span><span class='o'>)</span>,</span>
<span>  name <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"Patagonia"</span>, <span class='s'>"RStudio"</span><span class='o'>)</span></span>
<span><span class='o'>)</span></span>
<span><span class='nv'>companies</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 2 × 2</span></span></span>
<span><span class='c'>#&gt;   id    name     </span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>    </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span> A     Patagonia</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span> B     RStudio</span></span>
<span></span></code></pre>

</div>

To join these two tables together, we might use an inner join:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>transactions</span> <span class='o'>|&gt;</span> </span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/mutate-joins.html'>inner_join</a></span><span class='o'>(</span><span class='nv'>companies</span>, by <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span>company <span class='o'>=</span> <span class='s'>"id"</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 4 × 4</span></span></span>
<span><span class='c'>#&gt;   company  year revenue name     </span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>   <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>   <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>    </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span> A        <span style='text-decoration: underline;'>2</span>019      50 Patagonia</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span> A        <span style='text-decoration: underline;'>2</span>020       4 Patagonia</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>3</span> B        <span style='text-decoration: underline;'>2</span>021      10 RStudio  </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>4</span> B        <span style='text-decoration: underline;'>2</span>023      12 RStudio</span></span>
<span></span></code></pre>

</div>

This works great, but has always felt a little clunky. Specifying `c(company = "id")` is a little unnatural for new users, especially if they are used to "equivalence" in R being expressed with `==`. We've improved on this with a new helper, [`join_by()`](https://dplyr.tidyverse.org/reference/join_by.html), which takes expressions in a way that allows you to more naturally express this join:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://dplyr.tidyverse.org/reference/join_by.html'>join_by</a></span><span class='o'>(</span><span class='nv'>company</span> <span class='o'>==</span> <span class='nv'>id</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; Join By:</span></span>
<span><span class='c'>#&gt; - company == id</span></span>
<span></span></code></pre>

</div>

This *join specification* can be used as the `by` argument in any of the `*_join()` functions:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>transactions</span> <span class='o'>|&gt;</span> </span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/mutate-joins.html'>inner_join</a></span><span class='o'>(</span><span class='nv'>companies</span>, by <span class='o'>=</span> <span class='nf'><a href='https://dplyr.tidyverse.org/reference/join_by.html'>join_by</a></span><span class='o'>(</span><span class='nv'>company</span> <span class='o'>==</span> <span class='nv'>id</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 4 × 4</span></span></span>
<span><span class='c'>#&gt;   company  year revenue name     </span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>   <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>   <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>    </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span> A        <span style='text-decoration: underline;'>2</span>019      50 Patagonia</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span> A        <span style='text-decoration: underline;'>2</span>020       4 Patagonia</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>3</span> B        <span style='text-decoration: underline;'>2</span>021      10 RStudio  </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>4</span> B        <span style='text-decoration: underline;'>2</span>023      12 RStudio</span></span>
<span></span></code></pre>

</div>

This small quality of life improvement is just one of the many new features that come with [`join_by()`](https://dplyr.tidyverse.org/reference/join_by.html). We'll look at more of these next.

## Inequality joins

To make things a little more interesting, we'll add one more column to `companies`, and one more row:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>companies</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://tibble.tidyverse.org/reference/tibble.html'>tibble</a></span><span class='o'>(</span></span>
<span>  id <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"A"</span>, <span class='s'>"B"</span>, <span class='s'>"B"</span><span class='o'>)</span>,</span>
<span>  since <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='m'>1973</span>, <span class='m'>2009</span>, <span class='m'>2022</span><span class='o'>)</span>,</span>
<span>  name <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"Patagonia"</span>, <span class='s'>"RStudio"</span>, <span class='s'>"Posit"</span><span class='o'>)</span></span>
<span><span class='o'>)</span></span>
<span></span>
<span><span class='nv'>companies</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 3 × 3</span></span></span>
<span><span class='c'>#&gt;   id    since name     </span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>    </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span> A      <span style='text-decoration: underline;'>1</span>973 Patagonia</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span> B      <span style='text-decoration: underline;'>2</span>009 RStudio  </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>3</span> B      <span style='text-decoration: underline;'>2</span>022 Posit</span></span>
<span></span></code></pre>

</div>

This table now also tracks name changes that have happened over the course of a company's history. In 2022, we changed our name from RStudio to Posit, so we've tracked that as an additional row in our dataset. Note that both RStudio and Posit are given an `id` of `B`, which links back to the `transactions` table.

If we were to join these two tables together, ideally we'd bring over the name that was in effect when the transaction took place. For example, for the transaction in 2021, the company was still RStudio, so ideally we'd only match up against the RStudio row in `companies`. If we colored the expected matches, they'd look something like this:

![](img/ideal-join.png)

How can we do this? We can try the same join from before, but we won't like the results:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>faulty</span> <span class='o'>&lt;-</span> <span class='nv'>transactions</span> <span class='o'>|&gt;</span> </span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/mutate-joins.html'>inner_join</a></span><span class='o'>(</span><span class='nv'>companies</span>, by <span class='o'>=</span> <span class='nf'><a href='https://dplyr.tidyverse.org/reference/join_by.html'>join_by</a></span><span class='o'>(</span><span class='nv'>company</span> <span class='o'>==</span> <span class='nv'>id</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; Warning in inner_join(transactions, companies, by = join_by(company == id)): Each row in `x` is expected to match at most 1 row in `y`.</span></span>
<span><span class='c'>#&gt; <span style='color: #00BBBB;'>ℹ</span> Row 3 of `x` matches multiple rows.</span></span>
<span><span class='c'>#&gt; <span style='color: #00BBBB;'>ℹ</span> If multiple matches are expected, set `multiple = "all"` to silence this</span></span>
<span><span class='c'>#&gt;   warning.</span></span>
<span></span><span></span>
<span><span class='nv'>faulty</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 6 × 5</span></span></span>
<span><span class='c'>#&gt;   company  year revenue since name     </span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>   <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>   <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>    </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span> A        <span style='text-decoration: underline;'>2</span>019      50  <span style='text-decoration: underline;'>1</span>973 Patagonia</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span> A        <span style='text-decoration: underline;'>2</span>020       4  <span style='text-decoration: underline;'>1</span>973 Patagonia</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>3</span> B        <span style='text-decoration: underline;'>2</span>021      10  <span style='text-decoration: underline;'>2</span>009 RStudio  </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>4</span> B        <span style='text-decoration: underline;'>2</span>021      10  <span style='text-decoration: underline;'>2</span>022 Posit    </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>5</span> B        <span style='text-decoration: underline;'>2</span>023      12  <span style='text-decoration: underline;'>2</span>009 RStudio  </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>6</span> B        <span style='text-decoration: underline;'>2</span>023      12  <span style='text-decoration: underline;'>2</span>022 Posit</span></span>
<span></span></code></pre>

</div>

Company `A` matches correctly, but since we only joined on the company id, we get *multiple matches* for each of company `B`'s transactions and end up with more rows than we started with. This is a problem, as we were expecting a 1:1 match for each row in `transactions`. Multiple matches in equality joins like this one are typically unexpected -- in fact, many people don't even know this is possible even though it is technically default SQL behavior -- so we've also added a new warning to alert you when this happens. If multiple matches are expected, explicitly set `multiple = "all"` to silence this warning. This also serves as a code "sign post" for future readers of your code to let them know that this is a join that is expected to increase the number of rows in the data. If multiple matches *aren't* expected, you can also set `multiple = "error"` to immediately halt the analysis. We expect this will be useful as a quality control check for production code where you might rerun analyses with new data on a rolling basis.

To actually fix this issue, we'll need to expand our join specification to include another condition. Let's zoom in to just 2021:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://dplyr.tidyverse.org/reference/filter.html'>filter</a></span><span class='o'>(</span><span class='nv'>faulty</span>, <span class='nv'>company</span> <span class='o'>==</span> <span class='s'>"B"</span>, <span class='nv'>year</span> <span class='o'>==</span> <span class='m'>2021</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 2 × 5</span></span></span>
<span><span class='c'>#&gt;   company  year revenue since name   </span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>   <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>   <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>  </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span> B        <span style='text-decoration: underline;'>2</span>021      10  <span style='text-decoration: underline;'>2</span>009 RStudio</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span> B        <span style='text-decoration: underline;'>2</span>021      10  <span style='text-decoration: underline;'>2</span>022 Posit</span></span>
<span></span></code></pre>

</div>

We want to retain the match with RStudio, but not with Posit (because the name hasn't changed yet). One way to express this is by using the `year` and `since` columns to state that you only want a match if the transaction `year` occurred *after* a name change:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='c'># `year[i] &gt;= since`?</span></span>
<span><span class='m'>2021</span> <span class='o'>&gt;=</span> <span class='m'>2009</span></span>
<span><span class='c'>#&gt; [1] TRUE</span></span>
<span></span><span><span class='m'>2021</span> <span class='o'>&gt;=</span> <span class='m'>2022</span></span>
<span><span class='c'>#&gt; [1] FALSE</span></span>
<span></span></code></pre>

</div>

Because [`join_by()`](https://dplyr.tidyverse.org/reference/join_by.html) accepts expressions, we can express this inequality directly inside the join specification:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://dplyr.tidyverse.org/reference/join_by.html'>join_by</a></span><span class='o'>(</span><span class='nv'>company</span> <span class='o'>==</span> <span class='nv'>id</span>, <span class='nv'>year</span> <span class='o'>&gt;=</span> <span class='nv'>since</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; Join By:</span></span>
<span><span class='c'>#&gt; - company == id</span></span>
<span><span class='c'>#&gt; - year &gt;= since</span></span>
<span></span></code></pre>

</div>

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>transactions</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/mutate-joins.html'>inner_join</a></span><span class='o'>(</span><span class='nv'>companies</span>, <span class='nf'><a href='https://dplyr.tidyverse.org/reference/join_by.html'>join_by</a></span><span class='o'>(</span><span class='nv'>company</span> <span class='o'>==</span> <span class='nv'>id</span>, <span class='nv'>year</span> <span class='o'>&gt;=</span> <span class='nv'>since</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 5 × 5</span></span></span>
<span><span class='c'>#&gt;   company  year revenue since name     </span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>   <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>   <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>    </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span> A        <span style='text-decoration: underline;'>2</span>019      50  <span style='text-decoration: underline;'>1</span>973 Patagonia</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span> A        <span style='text-decoration: underline;'>2</span>020       4  <span style='text-decoration: underline;'>1</span>973 Patagonia</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>3</span> B        <span style='text-decoration: underline;'>2</span>021      10  <span style='text-decoration: underline;'>2</span>009 RStudio  </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>4</span> B        <span style='text-decoration: underline;'>2</span>023      12  <span style='text-decoration: underline;'>2</span>009 RStudio  </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>5</span> B        <span style='text-decoration: underline;'>2</span>023      12  <span style='text-decoration: underline;'>2</span>022 Posit</span></span>
<span></span></code></pre>

</div>

This eliminated the 2021 match to Posit, as expected! This type of join is known as an *inequality join*, i.e. it involves at least one join expression containing one of the following inequality conditions: `>=`, `>`, `<=`, or `<`.

However, we still have 2 matches corresponding to the 2023 year. In this case, we only wanted the match to Posit. We can understand why we are still getting multiple matches here by running the same row-by-row analysis as before:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='c'># `year[i] &gt;= since`? Both are true!</span></span>
<span><span class='m'>2023</span> <span class='o'>&gt;=</span> <span class='m'>2009</span></span>
<span><span class='c'>#&gt; [1] TRUE</span></span>
<span></span><span><span class='m'>2023</span> <span class='o'>&gt;=</span> <span class='m'>2022</span></span>
<span><span class='c'>#&gt; [1] TRUE</span></span>
<span></span></code></pre>

</div>

To remove the last problematic match of the 2023 transaction to the RStudio name, we'll need to refine our join specification one more time.

## Rolling joins

Inequality conditions like `year >= since` are powerful, but since the condition is only bounded on one side it is common for them to return a large number of matches. Since multiple matches are the typical case with inequality joins, we don't get a warning like with the equality join, but we clearly still haven't gotten the join right. As a reminder, here are where we still have too many matches:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>transactions</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/mutate-joins.html'>inner_join</a></span><span class='o'>(</span><span class='nv'>companies</span>, <span class='nf'><a href='https://dplyr.tidyverse.org/reference/join_by.html'>join_by</a></span><span class='o'>(</span><span class='nv'>company</span> <span class='o'>==</span> <span class='nv'>id</span>, <span class='nv'>year</span> <span class='o'>&gt;=</span> <span class='nv'>since</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/filter.html'>filter</a></span><span class='o'>(</span><span class='nv'>company</span> <span class='o'>==</span> <span class='s'>"B"</span>, <span class='nv'>year</span> <span class='o'>==</span> <span class='m'>2023</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 2 × 5</span></span></span>
<span><span class='c'>#&gt;   company  year revenue since name   </span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>   <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>   <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>  </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span> B        <span style='text-decoration: underline;'>2</span>023      12  <span style='text-decoration: underline;'>2</span>009 RStudio</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span> B        <span style='text-decoration: underline;'>2</span>023      12  <span style='text-decoration: underline;'>2</span>022 Posit</span></span>
<span></span></code></pre>

</div>

We need a way to filter down the matches returned from `year >= since` to only the most recent name change. In other words, we prefer the Posit match over the RStudio match because 2022 is *closer* to the transaction year of 2023 than 2009 is. We can express this in [`join_by()`](https://dplyr.tidyverse.org/reference/join_by.html) by using a helper named `closest()`.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>transactions</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/mutate-joins.html'>inner_join</a></span><span class='o'>(</span><span class='nv'>companies</span>, <span class='nf'><a href='https://dplyr.tidyverse.org/reference/join_by.html'>join_by</a></span><span class='o'>(</span><span class='nv'>company</span> <span class='o'>==</span> <span class='nv'>id</span>, <span class='nf'>closest</span><span class='o'>(</span><span class='nv'>year</span> <span class='o'>&gt;=</span> <span class='nv'>since</span><span class='o'>)</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 4 × 5</span></span></span>
<span><span class='c'>#&gt;   company  year revenue since name     </span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>   <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>   <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>    </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span> A        <span style='text-decoration: underline;'>2</span>019      50  <span style='text-decoration: underline;'>1</span>973 Patagonia</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span> A        <span style='text-decoration: underline;'>2</span>020       4  <span style='text-decoration: underline;'>1</span>973 Patagonia</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>3</span> B        <span style='text-decoration: underline;'>2</span>021      10  <span style='text-decoration: underline;'>2</span>009 RStudio  </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>4</span> B        <span style='text-decoration: underline;'>2</span>023      12  <span style='text-decoration: underline;'>2</span>022 Posit</span></span>
<span></span></code></pre>

</div>

`closest(year >= since)` finds all of the matches in `since` for a particular `year`, and then filters them down to only the closest match to that `year`. This is known as a *rolling join*, because in this case it *rolls* the most recent name change forward to match up with the transaction. Rolling joins were popularized by data.table, and are related to `ASOF` joins supported by some SQL flavors.

## `unmatched` rows

I mentioned earlier that we expected a 1:1 match between `transactions` and `companies`. We saw that `multiple` can help protect us from having too many matches, but what about not having enough? Consider what happens if we add a new company to `transactions` without a corresponding match in `companies`.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>transactions</span> <span class='o'>&lt;-</span> <span class='nv'>transactions</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'>tibble</span><span class='nf'>::</span><span class='nf'><a href='https://tibble.tidyverse.org/reference/add_row.html'>add_row</a></span><span class='o'>(</span>company <span class='o'>=</span> <span class='s'>"C"</span>, year <span class='o'>=</span> <span class='m'>2023</span>, revenue <span class='o'>=</span> <span class='m'>15</span><span class='o'>)</span></span>
<span></span>
<span><span class='nv'>transactions</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 5 × 3</span></span></span>
<span><span class='c'>#&gt;   company  year revenue</span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>   <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>   <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span> A        <span style='text-decoration: underline;'>2</span>019      50</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span> A        <span style='text-decoration: underline;'>2</span>020       4</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>3</span> B        <span style='text-decoration: underline;'>2</span>021      10</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>4</span> B        <span style='text-decoration: underline;'>2</span>023      12</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>5</span> C        <span style='text-decoration: underline;'>2</span>023      15</span></span>
<span></span></code></pre>

</div>

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>transactions</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/mutate-joins.html'>inner_join</a></span><span class='o'>(</span></span>
<span>    <span class='nv'>companies</span>, </span>
<span>    <span class='nf'><a href='https://dplyr.tidyverse.org/reference/join_by.html'>join_by</a></span><span class='o'>(</span><span class='nv'>company</span> <span class='o'>==</span> <span class='nv'>id</span>, <span class='nf'>closest</span><span class='o'>(</span><span class='nv'>year</span> <span class='o'>&gt;=</span> <span class='nv'>since</span><span class='o'>)</span><span class='o'>)</span></span>
<span>  <span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 4 × 5</span></span></span>
<span><span class='c'>#&gt;   company  year revenue since name     </span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>   <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>   <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>    </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span> A        <span style='text-decoration: underline;'>2</span>019      50  <span style='text-decoration: underline;'>1</span>973 Patagonia</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span> A        <span style='text-decoration: underline;'>2</span>020       4  <span style='text-decoration: underline;'>1</span>973 Patagonia</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>3</span> B        <span style='text-decoration: underline;'>2</span>021      10  <span style='text-decoration: underline;'>2</span>009 RStudio  </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>4</span> B        <span style='text-decoration: underline;'>2</span>023      12  <span style='text-decoration: underline;'>2</span>022 Posit</span></span>
<span></span></code></pre>

</div>

We've accidentally lost the `C` row! If you don't expect any unmatched rows, you can now catch this problem automatically by using our other new quality control argument, `unmatched`:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>transactions</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/mutate-joins.html'>inner_join</a></span><span class='o'>(</span></span>
<span>    <span class='nv'>companies</span>, </span>
<span>    <span class='nf'><a href='https://dplyr.tidyverse.org/reference/join_by.html'>join_by</a></span><span class='o'>(</span><span class='nv'>company</span> <span class='o'>==</span> <span class='nv'>id</span>, <span class='nf'>closest</span><span class='o'>(</span><span class='nv'>year</span> <span class='o'>&gt;=</span> <span class='nv'>since</span><span class='o'>)</span><span class='o'>)</span>,</span>
<span>    unmatched <span class='o'>=</span> <span class='s'>"error"</span></span>
<span>  <span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #BBBB00; font-weight: bold;'>Error</span><span style='font-weight: bold;'> in `inner_join()`:</span></span></span>
<span><span class='c'>#&gt; <span style='color: #BBBB00;'>!</span> Each row of `x` must have a match in `y`.</span></span>
<span><span class='c'>#&gt; <span style='color: #00BBBB;'>ℹ</span> Row 5 of `x` does not have a match.</span></span>
<span></span></code></pre>

</div>

If you've been questioning why I've been using an [`inner_join()`](https://dplyr.tidyverse.org/reference/mutate-joins.html) over a [`left_join()`](https://dplyr.tidyverse.org/reference/mutate-joins.html) this whole time, `unmatched` is why. We could use a [`left_join()`](https://dplyr.tidyverse.org/reference/mutate-joins.html):

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>transactions</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/mutate-joins.html'>left_join</a></span><span class='o'>(</span></span>
<span>    <span class='nv'>companies</span>, </span>
<span>    <span class='nf'><a href='https://dplyr.tidyverse.org/reference/join_by.html'>join_by</a></span><span class='o'>(</span><span class='nv'>company</span> <span class='o'>==</span> <span class='nv'>id</span>, <span class='nf'>closest</span><span class='o'>(</span><span class='nv'>year</span> <span class='o'>&gt;=</span> <span class='nv'>since</span><span class='o'>)</span><span class='o'>)</span>,</span>
<span>    unmatched <span class='o'>=</span> <span class='s'>"error"</span></span>
<span>  <span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 5 × 5</span></span></span>
<span><span class='c'>#&gt;   company  year revenue since name     </span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>   <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>   <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>    </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span> A        <span style='text-decoration: underline;'>2</span>019      50  <span style='text-decoration: underline;'>1</span>973 Patagonia</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span> A        <span style='text-decoration: underline;'>2</span>020       4  <span style='text-decoration: underline;'>1</span>973 Patagonia</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>3</span> B        <span style='text-decoration: underline;'>2</span>021      10  <span style='text-decoration: underline;'>2</span>009 RStudio  </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>4</span> B        <span style='text-decoration: underline;'>2</span>023      12  <span style='text-decoration: underline;'>2</span>022 Posit    </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>5</span> C        <span style='text-decoration: underline;'>2</span>023      15    <span style='color: #BB0000;'>NA</span> <span style='color: #BB0000;'>NA</span></span></span>
<span></span></code></pre>

</div>

But you'll notice that we don't get an error here. `unmatched` will only error if the input that has the potential to drop rows has an unmatched row. The reason you'd use a [`left_join()`](https://dplyr.tidyverse.org/reference/mutate-joins.html) is to ensure that rows from `x` are always retained, so it wouldn't make sense to error when rows from `x` are also unmatched. If `y` had unmatched rows instead, *then* it would have errored because those rows would otherwise be lost from the join. In an [`inner_join()`](https://dplyr.tidyverse.org/reference/mutate-joins.html), both inputs can potentially drop rows, so `unmatched = "error"` checks for unmatched rows in both inputs.

