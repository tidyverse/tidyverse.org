---
output: hugodown::hugo_document

slug: dplyr-1-2-0
title: dplyr 1.2.0
date: 2026-02-03
author: Davis Vaughan
description: >
    dplyr 1.2.0 fills in some important gaps in dplyr's API: we've added a new complement to `filter()` focused on dropping rows, and we've expanded the `case_when()` family with three new recoding and replacing functions!

photo:
  url: https://unsplash.com/photos/eksqjXTLpak
  author: Nathan Dumlao

categories: [package]
tags: [dplyr]

editor:
  markdown:
    wrap: sentence
    canonical: true

editor_options:
  chunk_output_type: console
rmd_hash: 06bbf8dc5b53c664

---

[dplyr 1.2.0](https://dplyr.tidyverse.org) is out now! This large release of dplyr comes with two sets of exciting features:

-   [`filter_out()`](https://dplyr.tidyverse.org/reference/filter.html), the missing complement to [`filter()`](https://dplyr.tidyverse.org/reference/filter.html), and accompanying [`when_any()`](https://dplyr.tidyverse.org/reference/when-any-all.html) and [`when_all()`](https://dplyr.tidyverse.org/reference/when-any-all.html) helpers.

-   [`recode_values()`](https://dplyr.tidyverse.org/reference/recode-and-replace-values.html), [`replace_values()`](https://dplyr.tidyverse.org/reference/recode-and-replace-values.html), and [`replace_when()`](https://dplyr.tidyverse.org/reference/case-and-replace-when.html), three new functions that join [`case_when()`](https://dplyr.tidyverse.org/reference/case-and-replace-when.html) to create a cohesive family of powerful tools for recoding and replacing.

Both of these sets of features are backed by successful *tidyups*, the tidyverse's community facing proposal process ([filtering](https://github.com/tidyverse/tidyups/pull/30), [recoding](https://github.com/tidyverse/tidyups/pull/29)). We really enjoyed having the community weigh in on these features!

You can install dplyr 1.2.0 from CRAN with:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://rdrr.io/r/utils/install.packages.html'>install.packages</a></span><span class='o'>(</span><span class='s'>"dplyr"</span><span class='o'>)</span></span></code></pre>

</div>

You can see a full list of changes in the [release notes](https://github.com/tidyverse/dplyr/releases/tag/v1.2.0).

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://dplyr.tidyverse.org'>dplyr</a></span><span class='o'>)</span></span></code></pre>

</div>

## Expanding the `filter()` family

[`filter()`](https://dplyr.tidyverse.org/reference/filter.html) has been a core dplyr verb since the very beginning, but over the years we've isolated a few key issues with it:

-   The name [`filter()`](https://dplyr.tidyverse.org/reference/filter.html) is ambiguous, are you keeping or dropping rows? i.e., are you filtering *for* rows or filtering *out* rows?

-   [`filter()`](https://dplyr.tidyverse.org/reference/filter.html) is optimized for the case of *keeping* rows, but you are just as likely to try and use it for *dropping* rows. Using [`filter()`](https://dplyr.tidyverse.org/reference/filter.html) to drop rows quickly forces you to confront complex boolean logic and explicitly handle missing values, which is difficult to teach, error prone to write, and hard to understand when you come back to it in the future.

-   [`filter()`](https://dplyr.tidyverse.org/reference/filter.html) combines comma separated conditions with `&` because this covers the majority of the cases. But if you'd like to combine conditions with `|`, then you have to introduce parentheses around your conditions and combine them into one large condition separated by `|`, reducing readability.

In the next few sections, we'll motivate these issues and discuss how some new features in dplyr can simplify things dramatically!

### Filtering...out!

Take a look at this `patients` data. Our task with this data is:

> *Filter out* rows where the patient is deceased *and* the year was before 2012.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>patients</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://tibble.tidyverse.org/reference/tibble.html'>tibble</a></span><span class='o'>(</span></span>
<span>  name <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"Anne"</span>, <span class='s'>"Mark"</span>, <span class='s'>"Sarah"</span>, <span class='s'>"Davis"</span>, <span class='s'>"Max"</span>, <span class='s'>"Derek"</span>, <span class='s'>"Tina"</span><span class='o'>)</span>,</span>
<span>  deceased <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='kc'>FALSE</span>, <span class='kc'>TRUE</span>, <span class='kc'>NA</span>, <span class='kc'>TRUE</span>, <span class='kc'>NA</span>, <span class='kc'>FALSE</span>, <span class='kc'>TRUE</span><span class='o'>)</span>,</span>
<span>  date <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='m'>2005</span>, <span class='m'>2010</span>, <span class='kc'>NA</span>, <span class='m'>2020</span>, <span class='m'>2010</span>, <span class='kc'>NA</span>, <span class='kc'>NA</span><span class='o'>)</span></span>
<span><span class='o'>)</span></span>
<span></span>
<span><span class='nv'>patients</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 7 × 3</span></span></span>
<span><span class='c'>#&gt;   name  deceased  date</span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;lgl&gt;</span>    <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span> Anne  FALSE     <span style='text-decoration: underline;'>2</span>005</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span> Mark  TRUE      <span style='text-decoration: underline;'>2</span>010</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>3</span> Sarah <span style='color: #BB0000;'>NA</span>          <span style='color: #BB0000;'>NA</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>4</span> Davis TRUE      <span style='text-decoration: underline;'>2</span>020</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>5</span> Max   <span style='color: #BB0000;'>NA</span>        <span style='text-decoration: underline;'>2</span>010</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>6</span> Derek FALSE       <span style='color: #BB0000;'>NA</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>7</span> Tina  TRUE        <span style='color: #BB0000;'>NA</span></span></span>
<span></span></code></pre>

</div>

With [`filter()`](https://dplyr.tidyverse.org/reference/filter.html), you'd probably start by translating "patient is deceased and the year was before 2012" into `deceased & date < 2012`, and then inverting that with `!(<expression>)` to drop rows:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>patients</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/filter.html'>filter</a></span><span class='o'>(</span><span class='o'>!</span><span class='o'>(</span><span class='nv'>deceased</span> <span class='o'>&amp;</span> <span class='nv'>date</span> <span class='o'>&lt;</span> <span class='m'>2012</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 3 × 3</span></span></span>
<span><span class='c'>#&gt;   name  deceased  date</span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;lgl&gt;</span>    <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span> Anne  FALSE     <span style='text-decoration: underline;'>2</span>005</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span> Davis TRUE      <span style='text-decoration: underline;'>2</span>020</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>3</span> Derek FALSE       <span style='color: #BB0000;'>NA</span></span></span>
<span></span></code></pre>

</div>

That seems to have worked, let's use an [`anti_join()`](https://dplyr.tidyverse.org/reference/filter-joins.html) to check with rows have been dropped from `patients`:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='c'># These rows were dropped</span></span>
<span><span class='nf'><a href='https://dplyr.tidyverse.org/reference/filter-joins.html'>anti_join</a></span><span class='o'>(</span></span>
<span>  <span class='nv'>patients</span>,</span>
<span>  <span class='nv'>patients</span> <span class='o'>|&gt;</span> <span class='nf'><a href='https://dplyr.tidyverse.org/reference/filter.html'>filter</a></span><span class='o'>(</span><span class='o'>!</span><span class='o'>(</span><span class='nv'>deceased</span> <span class='o'>&amp;</span> <span class='nv'>date</span> <span class='o'>&lt;</span> <span class='m'>2012</span><span class='o'>)</span><span class='o'>)</span>,</span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/join_by.html'>join_by</a></span><span class='o'>(</span><span class='nv'>name</span>, <span class='nv'>deceased</span>, <span class='nv'>date</span><span class='o'>)</span></span>
<span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 4 × 3</span></span></span>
<span><span class='c'>#&gt;   name  deceased  date</span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;lgl&gt;</span>    <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span> Mark  TRUE      <span style='text-decoration: underline;'>2</span>010</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span> Sarah <span style='color: #BB0000;'>NA</span>          <span style='color: #BB0000;'>NA</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>3</span> Max   <span style='color: #BB0000;'>NA</span>        <span style='text-decoration: underline;'>2</span>010</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>4</span> Tina  TRUE        <span style='color: #BB0000;'>NA</span></span></span>
<span></span></code></pre>

</div>

This is subtly wrong! We only wanted to drop rows where we *know* that the patient was deceased before 2012. If a missing value is present, we *don't* want to drop that row because we aren't sure about the condition. In this case, we were hoping to only drop `Mark`! It seems like [`filter()`](https://dplyr.tidyverse.org/reference/filter.html) has unexpectedly *dropped more rows than we expected*.

Here's what a technically correct [`filter()`](https://dplyr.tidyverse.org/reference/filter.html) call might look like:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>patients</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/filter.html'>filter</a></span><span class='o'>(</span></span>
<span>    <span class='o'>!</span><span class='o'>(</span><span class='o'>(</span><span class='nv'>deceased</span> <span class='o'>&amp;</span> <span class='o'>!</span><span class='nf'><a href='https://rdrr.io/r/base/NA.html'>is.na</a></span><span class='o'>(</span><span class='nv'>deceased</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>&amp;</span></span>
<span>      <span class='o'>(</span><span class='nv'>date</span> <span class='o'>&lt;</span> <span class='m'>2012</span> <span class='o'>&amp;</span> <span class='o'>!</span><span class='nf'><a href='https://rdrr.io/r/base/NA.html'>is.na</a></span><span class='o'>(</span><span class='nv'>date</span><span class='o'>)</span><span class='o'>)</span><span class='o'>)</span></span>
<span>  <span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 6 × 3</span></span></span>
<span><span class='c'>#&gt;   name  deceased  date</span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;lgl&gt;</span>    <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span> Anne  FALSE     <span style='text-decoration: underline;'>2</span>005</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span> Sarah <span style='color: #BB0000;'>NA</span>          <span style='color: #BB0000;'>NA</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>3</span> Davis TRUE      <span style='text-decoration: underline;'>2</span>020</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>4</span> Max   <span style='color: #BB0000;'>NA</span>        <span style='text-decoration: underline;'>2</span>010</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>5</span> Derek FALSE       <span style='color: #BB0000;'>NA</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>6</span> Tina  TRUE        <span style='color: #BB0000;'>NA</span></span></span>
<span></span></code></pre>

</div>

That's horrible! You'll likely look back on this in a year wondering what you were even trying to do here.

This phenomenon is rather confusing, but is due to the fact that [`filter()`](https://dplyr.tidyverse.org/reference/filter.html) is designed around the idea that you're going to tell it which rows to *keep*. With that design in mind, dropping `NA`s makes sense, i.e. if you don't *know* that you want to keep that row (because an `NA` is ambiguous), then you probably don't want to keep it.

This works well until you try to use [`filter()`](https://dplyr.tidyverse.org/reference/filter.html) as a way to *filter out* rows, at which point this behavior works against you. At this point, most people (reasonably!) reach for `& !is.na()` and you end up with the mess from above.

We took a close look at many examples like this one, and eventually realized that the core issue is:

-   [`filter()`](https://dplyr.tidyverse.org/reference/filter.html) is designed around supplying which rows to *keep*
-   We are missing a verb designed around supplying which rows to *drop*

[`filter_out()`](https://dplyr.tidyverse.org/reference/filter.html) fills that gap:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>patients</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/filter.html'>filter_out</a></span><span class='o'>(</span><span class='nv'>deceased</span>, <span class='nv'>date</span> <span class='o'>&lt;</span> <span class='m'>2012</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 6 × 3</span></span></span>
<span><span class='c'>#&gt;   name  deceased  date</span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;lgl&gt;</span>    <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span> Anne  FALSE     <span style='text-decoration: underline;'>2</span>005</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span> Sarah <span style='color: #BB0000;'>NA</span>          <span style='color: #BB0000;'>NA</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>3</span> Davis TRUE      <span style='text-decoration: underline;'>2</span>020</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>4</span> Max   <span style='color: #BB0000;'>NA</span>        <span style='text-decoration: underline;'>2</span>010</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>5</span> Derek FALSE       <span style='color: #BB0000;'>NA</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>6</span> Tina  TRUE        <span style='color: #BB0000;'>NA</span></span></span>
<span></span></code></pre>

</div>

Just like with [`filter()`](https://dplyr.tidyverse.org/reference/filter.html), [`filter_out()`](https://dplyr.tidyverse.org/reference/filter.html) treats `NA` values as `FALSE`. The difference is that [`filter_out()`](https://dplyr.tidyverse.org/reference/filter.html) expects that you are going to tell it which rows to *drop* (rather than which rows to keep), so the default behavior of treating `NA` like `FALSE` works *with you* rather than *against you*. It's also much easier to understand when you look back on it a year from now!

In general, our advice is that if you find yourself using "negative" operators like `!=` or `!` or reaching for the `!is.na()` pattern to manually handle missing values, try reaching for [`filter_out()`](https://dplyr.tidyverse.org/reference/filter.html) instead.

Personally, I've always been pretty jealous of Stata here because they had both [`keep if` and `drop if`](https://www.stata.com/manuals/ddrop.pdf), allowing them to write `drop if deceased & date < 2012`. In my first job, I translated a bunch of Stata code over to R and still remember being frustrated by `NA` handling every time I had to translate a `drop if` to a [`filter()`](https://dplyr.tidyverse.org/reference/filter.html). With [`filter_out()`](https://dplyr.tidyverse.org/reference/filter.html), it feels like I can finally let go of a long term grudge I've held over the past 6 years 🙂.

### Combining with `OR` rather than `AND`

So far, we've talked a lot about *dropping* rows, but dplyr 1.2.0 also has a new feature to help with *keeping* rows using conditions combined with `|` - [`when_any()`](https://dplyr.tidyverse.org/reference/when-any-all.html).

Our goal here is:

> *Filter for* rows where "US" and "CA" have a score between 200-300, *or* rows where "PR" and "RU" have a score between 100-200.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>countries</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://tibble.tidyverse.org/reference/tibble.html'>tibble</a></span><span class='o'>(</span></span>
<span>  name <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"US"</span>, <span class='s'>"CA"</span>, <span class='s'>"PR"</span>, <span class='s'>"RU"</span>, <span class='s'>"US"</span>, <span class='kc'>NA</span>, <span class='s'>"CA"</span>, <span class='s'>"PR"</span><span class='o'>)</span>,</span>
<span>  score <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='m'>200</span>, <span class='m'>100</span>, <span class='m'>150</span>, <span class='kc'>NA</span>, <span class='m'>50</span>, <span class='m'>100</span>, <span class='m'>300</span>, <span class='m'>250</span><span class='o'>)</span></span>
<span><span class='o'>)</span></span>
<span></span>
<span><span class='nv'>countries</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 8 × 2</span></span></span>
<span><span class='c'>#&gt;   name  score</span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span> US      200</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span> CA      100</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>3</span> PR      150</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>4</span> RU       <span style='color: #BB0000;'>NA</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>5</span> US       50</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>6</span> <span style='color: #BB0000;'>NA</span>      100</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>7</span> CA      300</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>8</span> PR      250</span></span>
<span></span></code></pre>

</div>

Here's a [`filter()`](https://dplyr.tidyverse.org/reference/filter.html) solution, note how we lose the ability to specify comma separated conditions, and in the process we've introduced 3 operators, `&`, `|`, and `()`, decreasing readability and increasing the mental gymnastics required to understand it:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>countries</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/filter.html'>filter</a></span><span class='o'>(</span></span>
<span>    <span class='o'>(</span><span class='nv'>name</span> <span class='o'><a href='https://rdrr.io/r/base/match.html'>%in%</a></span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"US"</span>, <span class='s'>"CA"</span><span class='o'>)</span> <span class='o'>&amp;</span> <span class='nf'><a href='https://dplyr.tidyverse.org/reference/between.html'>between</a></span><span class='o'>(</span><span class='nv'>score</span>, <span class='m'>200</span>, <span class='m'>300</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>|</span></span>
<span>      <span class='o'>(</span><span class='nv'>name</span> <span class='o'><a href='https://rdrr.io/r/base/match.html'>%in%</a></span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"PR"</span>, <span class='s'>"RU"</span><span class='o'>)</span> <span class='o'>&amp;</span> <span class='nf'><a href='https://dplyr.tidyverse.org/reference/between.html'>between</a></span><span class='o'>(</span><span class='nv'>score</span>, <span class='m'>100</span>, <span class='m'>200</span><span class='o'>)</span><span class='o'>)</span></span>
<span>  <span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 3 × 2</span></span></span>
<span><span class='c'>#&gt;   name  score</span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span> US      200</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span> PR      150</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>3</span> CA      300</span></span>
<span></span></code></pre>

</div>

With [`when_any()`](https://dplyr.tidyverse.org/reference/when-any-all.html), you specify comma separated conditions like you're used to, but they get combined with `|` rather than `&`. This allows us to reduce the amount of operators introduced down to just `&`, and it remains very readable:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>countries</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/filter.html'>filter</a></span><span class='o'>(</span><span class='nf'><a href='https://dplyr.tidyverse.org/reference/when-any-all.html'>when_any</a></span><span class='o'>(</span></span>
<span>    <span class='nv'>name</span> <span class='o'><a href='https://rdrr.io/r/base/match.html'>%in%</a></span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"US"</span>, <span class='s'>"CA"</span><span class='o'>)</span> <span class='o'>&amp;</span> <span class='nf'><a href='https://dplyr.tidyverse.org/reference/between.html'>between</a></span><span class='o'>(</span><span class='nv'>score</span>, <span class='m'>200</span>, <span class='m'>300</span><span class='o'>)</span>,</span>
<span>    <span class='nv'>name</span> <span class='o'><a href='https://rdrr.io/r/base/match.html'>%in%</a></span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"PR"</span>, <span class='s'>"RU"</span><span class='o'>)</span> <span class='o'>&amp;</span> <span class='nf'><a href='https://dplyr.tidyverse.org/reference/between.html'>between</a></span><span class='o'>(</span><span class='nv'>score</span>, <span class='m'>100</span>, <span class='m'>200</span><span class='o'>)</span></span>
<span>  <span class='o'>)</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 3 × 2</span></span></span>
<span><span class='c'>#&gt;   name  score</span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span> US      200</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span> PR      150</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>3</span> CA      300</span></span>
<span></span></code></pre>

</div>

[`when_any()`](https://dplyr.tidyverse.org/reference/when-any-all.html) and its counterpart [`when_all()`](https://dplyr.tidyverse.org/reference/when-any-all.html) aren't restricted to [`filter()`](https://dplyr.tidyverse.org/reference/filter.html). They are normal vector functions that can be used anywhere. And if you're a package author, you might be interested in [`vctrs::vec_pany()`](https://vctrs.r-lib.org/reference/parallel-operators.html) and [`vctrs::vec_pall()`](https://vctrs.r-lib.org/reference/parallel-operators.html), the underlying low dependency functions that power the dplyr variants.

## Reaching recoding nirvana

Over the years, we've experimented with various ways of recoding columns and replacing values within them, including:

-   [`plyr::mapvalues()`](https://rdrr.io/pkg/plyr/man/mapvalues.html)
-   [`plyr::revalue()`](https://rdrr.io/pkg/plyr/man/revalue.html)
-   [`dplyr::recode()`](https://dplyr.tidyverse.org/reference/recode.html)
-   [`dplyr::case_when()`](https://dplyr.tidyverse.org/reference/case-and-replace-when.html)

Despite all of our improvements, it's felt like there have always been holes in our solutions. Most recently, this came to the forefront in a post about [recoding using a lookup table](https://www.linkedin.com/posts/libbyheeren_rstats-activity-7343291858275487744-XlPl?utm_source=share&utm_medium=member_desktop&rcm=ACoAAAy7IywB2qfaREGGoCca5XkthJ2hLjru6ts), which is almost impossible to do with [`case_when()`](https://dplyr.tidyverse.org/reference/case-and-replace-when.html), and had people resorting to confusing solutions using the superseded [`dplyr::recode()`](https://dplyr.tidyverse.org/reference/recode.html) combined with `!!!` to splice in a lookup table.

After seeing this, we took a step back and were finally able to isolate the issues with our current solutions. The result of our [analysis](https://github.com/tidyverse/tidyups/pull/29) is three new functions that join [`case_when()`](https://dplyr.tidyverse.org/reference/case-and-replace-when.html) to form a powerful recoding and replacing family.

It'll be helpful to define exactly what we mean by recoding vs replacing:

-   *Recoding* a column creates an entirely new column using values from an existing column. The new column may have a different type from the original column.

-   *Replacing* values within a column partially updates an existing column with new values. The result has the same type as the original column.

The family of functions can be summarized by the following table:

|                           | **Recoding**      | **Replacing**      |
|---------------------------|-------------------|--------------------|
| **Match with conditions** | [`case_when()`](https://dplyr.tidyverse.org/reference/case-and-replace-when.html)     | [`replace_when()`](https://dplyr.tidyverse.org/reference/case-and-replace-when.html)   |
| **Match with values**     | [`recode_values()`](https://dplyr.tidyverse.org/reference/recode-and-replace-values.html) | [`replace_values()`](https://dplyr.tidyverse.org/reference/recode-and-replace-values.html) |

We've written a [new vignette](https://dplyr.tidyverse.org/articles/recoding-replacing.html) that expands on all of these from first principles, and in the next few sections we'll look at some examples.

### `recode_values()`

The goal of the post from above was to recode a numeric column of [Likert scale](https://en.wikipedia.org/wiki/Likert_scale) scores into their string counterparts.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>likert</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://tibble.tidyverse.org/reference/tibble.html'>tibble</a></span><span class='o'>(</span></span>
<span>  score <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='m'>1</span>, <span class='m'>2</span>, <span class='m'>3</span>, <span class='m'>4</span>, <span class='m'>5</span>, <span class='m'>2</span>, <span class='m'>3</span>, <span class='m'>1</span>, <span class='m'>4</span><span class='o'>)</span></span>
<span><span class='o'>)</span></span></code></pre>

</div>

We could certainly try [`case_when()`](https://dplyr.tidyverse.org/reference/case-and-replace-when.html):

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>likert</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/mutate.html'>mutate</a></span><span class='o'>(</span></span>
<span>    category <span class='o'>=</span> <span class='nf'><a href='https://dplyr.tidyverse.org/reference/case-and-replace-when.html'>case_when</a></span><span class='o'>(</span></span>
<span>      <span class='nv'>score</span> <span class='o'>==</span> <span class='m'>1</span> <span class='o'>~</span> <span class='s'>"Strongly disagree"</span>,</span>
<span>      <span class='nv'>score</span> <span class='o'>==</span> <span class='m'>2</span> <span class='o'>~</span> <span class='s'>"Disagree"</span>,</span>
<span>      <span class='nv'>score</span> <span class='o'>==</span> <span class='m'>3</span> <span class='o'>~</span> <span class='s'>"Neutral"</span>,</span>
<span>      <span class='nv'>score</span> <span class='o'>==</span> <span class='m'>4</span> <span class='o'>~</span> <span class='s'>"Agree"</span>,</span>
<span>      <span class='nv'>score</span> <span class='o'>==</span> <span class='m'>5</span> <span class='o'>~</span> <span class='s'>"Strongly agree"</span></span>
<span>    <span class='o'>)</span></span>
<span>  <span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 9 × 2</span></span></span>
<span><span class='c'>#&gt;   score category         </span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>            </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span>     1 Strongly disagree</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span>     2 Disagree         </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>3</span>     3 Neutral          </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>4</span>     4 Agree            </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>5</span>     5 Strongly agree   </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>6</span>     2 Disagree         </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>7</span>     3 Neutral          </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>8</span>     1 Strongly disagree</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>9</span>     4 Agree</span></span>
<span></span></code></pre>

</div>

But `score ==` is repeated so many times! When you find yourself using `==` in this way, recognize that what you're really doing is matching on the *values* of a single column. In cases like these, you'll want to switch to [`recode_values()`](https://dplyr.tidyverse.org/reference/recode-and-replace-values.html). Rather than taking logical vectors, [`recode_values()`](https://dplyr.tidyverse.org/reference/recode-and-replace-values.html) takes *values* on the left-hand side to match against a single input that you'll provide as the first argument.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>likert</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/mutate.html'>mutate</a></span><span class='o'>(</span></span>
<span>    category <span class='o'>=</span> <span class='nv'>score</span> <span class='o'>|&gt;</span></span>
<span>      <span class='nf'><a href='https://dplyr.tidyverse.org/reference/recode-and-replace-values.html'>recode_values</a></span><span class='o'>(</span></span>
<span>        <span class='m'>1</span> <span class='o'>~</span> <span class='s'>"Strongly disagree"</span>,</span>
<span>        <span class='m'>2</span> <span class='o'>~</span> <span class='s'>"Disagree"</span>,</span>
<span>        <span class='m'>3</span> <span class='o'>~</span> <span class='s'>"Neutral"</span>,</span>
<span>        <span class='m'>4</span> <span class='o'>~</span> <span class='s'>"Agree"</span>,</span>
<span>        <span class='m'>5</span> <span class='o'>~</span> <span class='s'>"Strongly agree"</span></span>
<span>      <span class='o'>)</span></span>
<span>  <span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 9 × 2</span></span></span>
<span><span class='c'>#&gt;   score category         </span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>            </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span>     1 Strongly disagree</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span>     2 Disagree         </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>3</span>     3 Neutral          </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>4</span>     4 Agree            </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>5</span>     5 Strongly agree   </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>6</span>     2 Disagree         </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>7</span>     3 Neutral          </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>8</span>     1 Strongly disagree</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>9</span>     4 Agree</span></span>
<span></span></code></pre>

</div>

This removes all of the repetition, allowing you to focus on the mapping. And it should feel pretty familiar! This is the same formula interface of [`case_when()`](https://dplyr.tidyverse.org/reference/case-and-replace-when.html).

If you squint, the mapping should look roughly like a lookup table between the numeric value and the Likert encoding. One of the novel features of [`recode_values()`](https://dplyr.tidyverse.org/reference/recode-and-replace-values.html) is that it has an alternate interface that allows you to make this lookup table more explicit. Using a [`tribble()`](https://tibble.tidyverse.org/reference/tribble.html), we can extract out the lookup table into its own standalone data frame.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>lookup</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://tibble.tidyverse.org/reference/tribble.html'>tribble</a></span><span class='o'>(</span></span>
<span>  <span class='o'>~</span><span class='nv'>from</span> , <span class='o'>~</span><span class='nv'>to</span>                 ,</span>
<span>      <span class='m'>1</span> , <span class='s'>"Strongly disagree"</span> ,</span>
<span>      <span class='m'>2</span> , <span class='s'>"Disagree"</span>          ,</span>
<span>      <span class='m'>3</span> , <span class='s'>"Neutral"</span>           ,</span>
<span>      <span class='m'>4</span> , <span class='s'>"Agree"</span>             ,</span>
<span>      <span class='m'>5</span> , <span class='s'>"Strongly agree"</span>    ,</span>
<span><span class='o'>)</span></span></code></pre>

</div>

We can then utilize the alternative `from` and `to` arguments of [`recode_values()`](https://dplyr.tidyverse.org/reference/recode-and-replace-values.html) rather than supplying formulas to specify how the values should be recoded:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>likert</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/mutate.html'>mutate</a></span><span class='o'>(</span>category <span class='o'>=</span> <span class='nf'><a href='https://dplyr.tidyverse.org/reference/recode-and-replace-values.html'>recode_values</a></span><span class='o'>(</span><span class='nv'>score</span>, from <span class='o'>=</span> <span class='nv'>lookup</span><span class='o'>$</span><span class='nv'>from</span>, to <span class='o'>=</span> <span class='nv'>lookup</span><span class='o'>$</span><span class='nv'>to</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 9 × 2</span></span></span>
<span><span class='c'>#&gt;   score category         </span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>            </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span>     1 Strongly disagree</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span>     2 Disagree         </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>3</span>     3 Neutral          </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>4</span>     4 Agree            </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>5</span>     5 Strongly agree   </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>6</span>     2 Disagree         </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>7</span>     3 Neutral          </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>8</span>     1 Strongly disagree</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>9</span>     4 Agree</span></span>
<span></span></code></pre>

</div>

Lifting the lookup table out to the top of the file is particularly nice when you have a long pipe chain. The details of the mapping get some room to breathe, and in the pipe chain you can focus on the actual data manipulations.

It's also very common for your `lookup` table to exist in a CSV file that you have to read in separately. In that case, you can replace the [`tribble()`](https://tibble.tidyverse.org/reference/tribble.html) call with:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>lookup</span> <span class='o'>&lt;-</span> <span class='nf'>readr</span><span class='nf'>::</span><span class='nf'><a href='https://readr.tidyverse.org/reference/read_delim.html'>read_csv</a></span><span class='o'>(</span><span class='s'>"lookup.csv"</span><span class='o'>)</span></span></code></pre>

</div>

Then everything else works the same.

### Unmatched cases

If you are confident that you've captured every case during the recoding process, you can now supply `unmatched = "error"` as an alternative to `default`. [`recode_values()`](https://dplyr.tidyverse.org/reference/recode-and-replace-values.html) will error if that assertion doesn't hold. This is great for defensive programming!

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='c'># Notice the `0` that we don't have a mapping for!</span></span>
<span><span class='nv'>likert</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://tibble.tidyverse.org/reference/tibble.html'>tibble</a></span><span class='o'>(</span></span>
<span>  score <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='m'>0</span>, <span class='m'>1</span>, <span class='m'>2</span>, <span class='m'>2</span>, <span class='m'>4</span>, <span class='m'>5</span>, <span class='m'>2</span>, <span class='m'>3</span>, <span class='m'>1</span>, <span class='m'>4</span><span class='o'>)</span></span>
<span><span class='o'>)</span></span>
<span></span>
<span><span class='nv'>likert</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/mutate.html'>mutate</a></span><span class='o'>(</span></span>
<span>    score <span class='o'>=</span> <span class='nv'>score</span> <span class='o'>|&gt;</span></span>
<span>      <span class='nf'><a href='https://dplyr.tidyverse.org/reference/recode-and-replace-values.html'>recode_values</a></span><span class='o'>(</span></span>
<span>        from <span class='o'>=</span> <span class='nv'>lookup</span><span class='o'>$</span><span class='nv'>from</span>,</span>
<span>        to <span class='o'>=</span> <span class='nv'>lookup</span><span class='o'>$</span><span class='nv'>to</span>,</span>
<span>        unmatched <span class='o'>=</span> <span class='s'>"error"</span></span>
<span>      <span class='o'>)</span></span>
<span>  <span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #BBBB00; font-weight: bold;'>Error</span><span style='font-weight: bold;'> in `mutate()`:</span></span></span>
<span><span class='c'>#&gt; <span style='color: #00BBBB;'>ℹ</span> In argument: `score = recode_values(score, from = lookup$from, to = lookup$to, unmatched = "error")`.</span></span>
<span><span class='c'>#&gt; <span style='font-weight: bold;'>Caused by error in `recode_values()`:</span></span></span>
<span><span class='c'>#&gt; <span style='color: #BBBB00;'>!</span> Each location must be matched.</span></span>
<span><span class='c'>#&gt; <span style='color: #BB0000;'>✖</span> Location 1 is unmatched.</span></span>
<span></span></code></pre>

</div>

Note that missing values must be explicitly handled when setting `unmatched = "error"`, even if that's just setting `NA ~ NA`, otherwise they will trigger the unmatched error. This forces you to explicitly opt in to expecting missing values.

Similar to [`recode_values()`](https://dplyr.tidyverse.org/reference/recode-and-replace-values.html), [`case_when()`](https://dplyr.tidyverse.org/reference/case-and-replace-when.html) has also gained the `.unmatched` argument.

### `replace_values()`

Out of all of the new things introduced in dplyr 1.2.0, I think I'm most excited about [`replace_values()`](https://dplyr.tidyverse.org/reference/recode-and-replace-values.html).

While [`recode_values()`](https://dplyr.tidyverse.org/reference/recode-and-replace-values.html) is great for creating an entirely new column (possibly with a new type), if you just need to replace a few rows of an existing column, then [`replace_values()`](https://dplyr.tidyverse.org/reference/recode-and-replace-values.html) is the best tool for the job!

Imagine we'd like to collapse some, but not all, of these school names into common buckets:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>schools</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://tibble.tidyverse.org/reference/tibble.html'>tibble</a></span><span class='o'>(</span></span>
<span>  name <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span></span>
<span>    <span class='s'>"UNC"</span>,</span>
<span>    <span class='s'>"Chapel Hill"</span>,</span>
<span>    <span class='kc'>NA</span>,</span>
<span>    <span class='s'>"Duke"</span>,</span>
<span>    <span class='s'>"Duke University"</span>,</span>
<span>    <span class='s'>"UNC"</span>,</span>
<span>    <span class='s'>"NC State"</span>,</span>
<span>    <span class='s'>"ECU"</span></span>
<span>  <span class='o'>)</span></span>
<span><span class='o'>)</span></span></code></pre>

</div>

We could use [`case_when()`](https://dplyr.tidyverse.org/reference/case-and-replace-when.html) or [`recode_values()`](https://dplyr.tidyverse.org/reference/recode-and-replace-values.html):

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>schools</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/mutate.html'>mutate</a></span><span class='o'>(</span></span>
<span>    name <span class='o'>=</span> <span class='nf'><a href='https://dplyr.tidyverse.org/reference/case-and-replace-when.html'>case_when</a></span><span class='o'>(</span></span>
<span>      <span class='nv'>name</span> <span class='o'><a href='https://rdrr.io/r/base/match.html'>%in%</a></span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"UNC"</span>, <span class='s'>"Chapel Hill"</span><span class='o'>)</span> <span class='o'>~</span> <span class='s'>"UNC Chapel Hill"</span>,</span>
<span>      <span class='nv'>name</span> <span class='o'><a href='https://rdrr.io/r/base/match.html'>%in%</a></span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"Duke"</span>, <span class='s'>"Duke University"</span><span class='o'>)</span> <span class='o'>~</span> <span class='s'>"Duke"</span>,</span>
<span>      .default <span class='o'>=</span> <span class='nv'>name</span></span>
<span>    <span class='o'>)</span></span>
<span>  <span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 8 × 1</span></span></span>
<span><span class='c'>#&gt;   name           </span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>          </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span> UNC Chapel Hill</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span> UNC Chapel Hill</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>3</span> <span style='color: #BB0000;'>NA</span>             </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>4</span> Duke           </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>5</span> Duke           </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>6</span> UNC Chapel Hill</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>7</span> NC State       </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>8</span> ECU</span></span>
<span></span><span></span>
<span><span class='nv'>schools</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/mutate.html'>mutate</a></span><span class='o'>(</span></span>
<span>    name <span class='o'>=</span> <span class='nf'><a href='https://dplyr.tidyverse.org/reference/recode-and-replace-values.html'>recode_values</a></span><span class='o'>(</span></span>
<span>      <span class='nv'>name</span>,</span>
<span>      <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"UNC"</span>, <span class='s'>"Chapel Hill"</span><span class='o'>)</span> <span class='o'>~</span> <span class='s'>"UNC Chapel Hill"</span>,</span>
<span>      <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"Duke"</span>, <span class='s'>"Duke University"</span><span class='o'>)</span> <span class='o'>~</span> <span class='s'>"Duke"</span>,</span>
<span>      default <span class='o'>=</span> <span class='nv'>name</span></span>
<span>    <span class='o'>)</span></span>
<span>  <span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 8 × 1</span></span></span>
<span><span class='c'>#&gt;   name           </span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>          </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span> UNC Chapel Hill</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span> UNC Chapel Hill</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>3</span> <span style='color: #BB0000;'>NA</span>             </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>4</span> Duke           </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>5</span> Duke           </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>6</span> UNC Chapel Hill</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>7</span> NC State       </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>8</span> ECU</span></span>
<span></span></code></pre>

</div>

But this "partial update" operation is so common that it really deserves its own name that doesn't require you to specify `default` and is type stable on the input. For that, we have [`replace_values()`](https://dplyr.tidyverse.org/reference/recode-and-replace-values.html):

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>schools</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/mutate.html'>mutate</a></span><span class='o'>(</span></span>
<span>    name <span class='o'>=</span> <span class='nv'>name</span> <span class='o'>|&gt;</span></span>
<span>      <span class='nf'><a href='https://dplyr.tidyverse.org/reference/recode-and-replace-values.html'>replace_values</a></span><span class='o'>(</span></span>
<span>        <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"UNC"</span>, <span class='s'>"Chapel Hill"</span><span class='o'>)</span> <span class='o'>~</span> <span class='s'>"UNC Chapel Hill"</span>,</span>
<span>        <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"Duke"</span>, <span class='s'>"Duke University"</span><span class='o'>)</span> <span class='o'>~</span> <span class='s'>"Duke"</span></span>
<span>      <span class='o'>)</span></span>
<span>  <span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 8 × 1</span></span></span>
<span><span class='c'>#&gt;   name           </span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>          </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span> UNC Chapel Hill</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span> UNC Chapel Hill</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>3</span> <span style='color: #BB0000;'>NA</span>             </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>4</span> Duke           </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>5</span> Duke           </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>6</span> UNC Chapel Hill</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>7</span> NC State       </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>8</span> ECU</span></span>
<span></span></code></pre>

</div>

Notice how pipe friendly [`replace_values()`](https://dplyr.tidyverse.org/reference/recode-and-replace-values.html) is! The first input is your "primary" input, and you can expect the output to have the same type and size as that input.

Like [`recode_values()`](https://dplyr.tidyverse.org/reference/recode-and-replace-values.html), [`replace_values()`](https://dplyr.tidyverse.org/reference/recode-and-replace-values.html) has an alternative `from` and `to` API that works well with lookup tables and allows you to move your mapping out of the pipe chain:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>lookup</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://tibble.tidyverse.org/reference/tribble.html'>tribble</a></span><span class='o'>(</span></span>
<span>  <span class='o'>~</span><span class='nv'>from</span>             , <span class='o'>~</span><span class='nv'>to</span>               ,</span>
<span>  <span class='s'>"UNC"</span>             , <span class='s'>"UNC Chapel Hill"</span> ,</span>
<span>  <span class='s'>"Chapel Hill"</span>     , <span class='s'>"UNC Chapel Hill"</span> ,</span>
<span>  <span class='s'>"Duke"</span>            , <span class='s'>"Duke"</span>            ,</span>
<span>  <span class='s'>"Duke University"</span> , <span class='s'>"Duke"</span>            ,</span>
<span><span class='o'>)</span></span>
<span></span>
<span><span class='nv'>schools</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/mutate.html'>mutate</a></span><span class='o'>(</span>name <span class='o'>=</span> <span class='nf'><a href='https://dplyr.tidyverse.org/reference/recode-and-replace-values.html'>replace_values</a></span><span class='o'>(</span><span class='nv'>name</span>, from <span class='o'>=</span> <span class='nv'>lookup</span><span class='o'>$</span><span class='nv'>from</span>, to <span class='o'>=</span> <span class='nv'>lookup</span><span class='o'>$</span><span class='nv'>to</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 8 × 1</span></span></span>
<span><span class='c'>#&gt;   name           </span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>          </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span> UNC Chapel Hill</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span> UNC Chapel Hill</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>3</span> <span style='color: #BB0000;'>NA</span>             </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>4</span> Duke           </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>5</span> Duke           </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>6</span> UNC Chapel Hill</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>7</span> NC State       </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>8</span> ECU</span></span>
<span></span></code></pre>

</div>

An extremely neat feature of the `from` and `to` API is that they also take *lists* of vectors that describe the mapping, which has been designed to work elegantly with the fact that [`tribble()`](https://tibble.tidyverse.org/reference/tribble.html) can create list columns, allowing you to further collapse this lookup table:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='c'># Condensed lookup table with a `many:1` mapping per row</span></span>
<span><span class='nv'>lookup</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://tibble.tidyverse.org/reference/tribble.html'>tribble</a></span><span class='o'>(</span></span>
<span>  <span class='o'>~</span><span class='nv'>from</span>                        , <span class='o'>~</span><span class='nv'>to</span>               ,</span>
<span>  <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"UNC"</span>, <span class='s'>"Chapel Hill"</span><span class='o'>)</span>      , <span class='s'>"UNC Chapel Hill"</span> ,</span>
<span>  <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"Duke"</span>, <span class='s'>"Duke University"</span><span class='o'>)</span> , <span class='s'>"Duke"</span>            ,</span>
<span><span class='o'>)</span></span>
<span></span>
<span><span class='c'># Note that `from` is a list column</span></span>
<span><span class='nv'>lookup</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 2 × 2</span></span></span>
<span><span class='c'>#&gt;   from      to             </span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;list&gt;</span>    <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>          </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span> <span style='color: #555555;'>&lt;chr [2]&gt;</span> UNC Chapel Hill</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span> <span style='color: #555555;'>&lt;chr [2]&gt;</span> Duke</span></span>
<span></span><span></span>
<span><span class='nv'>lookup</span><span class='o'>$</span><span class='nv'>from</span></span>
<span><span class='c'>#&gt; [[1]]</span></span>
<span><span class='c'>#&gt; [1] "UNC"         "Chapel Hill"</span></span>
<span><span class='c'>#&gt; </span></span>
<span><span class='c'>#&gt; [[2]]</span></span>
<span><span class='c'>#&gt; [1] "Duke"            "Duke University"</span></span>
<span></span><span></span>
<span><span class='c'># Works the same as before</span></span>
<span><span class='nv'>schools</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/mutate.html'>mutate</a></span><span class='o'>(</span>name <span class='o'>=</span> <span class='nf'><a href='https://dplyr.tidyverse.org/reference/recode-and-replace-values.html'>replace_values</a></span><span class='o'>(</span><span class='nv'>name</span>, from <span class='o'>=</span> <span class='nv'>lookup</span><span class='o'>$</span><span class='nv'>from</span>, to <span class='o'>=</span> <span class='nv'>lookup</span><span class='o'>$</span><span class='nv'>to</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 8 × 1</span></span></span>
<span><span class='c'>#&gt;   name           </span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>          </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span> UNC Chapel Hill</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span> UNC Chapel Hill</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>3</span> <span style='color: #BB0000;'>NA</span>             </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>4</span> Duke           </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>5</span> Duke           </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>6</span> UNC Chapel Hill</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>7</span> NC State       </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>8</span> ECU</span></span>
<span></span></code></pre>

</div>

The formula interface of [`replace_values()`](https://dplyr.tidyverse.org/reference/recode-and-replace-values.html) is a bit of a Swiss Army knife for all manner of scenarios where you might have previously reached for [`dplyr::coalesce()`](https://dplyr.tidyverse.org/reference/coalesce.html), [`dplyr::na_if()`](https://dplyr.tidyverse.org/reference/na_if.html), or [`tidyr::replace_na()`](https://tidyr.tidyverse.org/reference/replace_na.html):

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>state</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"NC"</span>, <span class='s'>"NY"</span>, <span class='s'>"CA"</span>, <span class='kc'>NA</span>, <span class='s'>"NY"</span>, <span class='s'>"Unknown"</span>, <span class='kc'>NA</span><span class='o'>)</span></span>
<span></span>
<span><span class='c'># Replace missing values with a constant</span></span>
<span><span class='nf'><a href='https://dplyr.tidyverse.org/reference/recode-and-replace-values.html'>replace_values</a></span><span class='o'>(</span><span class='nv'>state</span>, <span class='kc'>NA</span> <span class='o'>~</span> <span class='s'>"Unknown"</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; [1] "NC"      "NY"      "CA"      "Unknown" "NY"      "Unknown" "Unknown"</span></span>
<span></span><span></span>
<span><span class='c'># Replace missing values with the corresponding value from another column</span></span>
<span><span class='nv'>region</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"South"</span>, <span class='s'>"North"</span>, <span class='s'>"West"</span>, <span class='s'>"East"</span>, <span class='s'>"North"</span>, <span class='s'>"Unknown"</span>, <span class='s'>"West"</span><span class='o'>)</span></span>
<span><span class='nf'><a href='https://dplyr.tidyverse.org/reference/recode-and-replace-values.html'>replace_values</a></span><span class='o'>(</span><span class='nv'>state</span>, <span class='kc'>NA</span> <span class='o'>~</span> <span class='nv'>region</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; [1] "NC"      "NY"      "CA"      "East"    "NY"      "Unknown" "West"</span></span>
<span></span><span></span>
<span><span class='c'># Replace problematic values with a missing value</span></span>
<span><span class='nf'><a href='https://dplyr.tidyverse.org/reference/recode-and-replace-values.html'>replace_values</a></span><span class='o'>(</span><span class='nv'>state</span>, <span class='s'>"Unknown"</span> <span class='o'>~</span> <span class='kc'>NA</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; [1] "NC" "NY" "CA" NA   "NY" NA   NA</span></span>
<span></span><span></span>
<span><span class='c'># Standardize multiple issues at once</span></span>
<span><span class='nf'><a href='https://dplyr.tidyverse.org/reference/recode-and-replace-values.html'>replace_values</a></span><span class='o'>(</span><span class='nv'>state</span>, <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='kc'>NA</span>, <span class='s'>"Unknown"</span><span class='o'>)</span> <span class='o'>~</span> <span class='s'>"&lt;missing&gt;"</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; [1] "NC"        "NY"        "CA"        "&lt;missing&gt;" "NY"        "&lt;missing&gt;"</span></span>
<span><span class='c'>#&gt; [7] "&lt;missing&gt;"</span></span>
<span></span></code></pre>

</div>

We also think it better expresses intent than [`if_else()`](https://dplyr.tidyverse.org/reference/if_else.html) or [`case_when()`](https://dplyr.tidyverse.org/reference/case-and-replace-when.html) when performing a partial update:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='c'># - Type stable on `x`</span></span>
<span><span class='c'># - Intent of "partially updating" `state` is clear</span></span>
<span><span class='c'># - Pipe friendly</span></span>
<span><span class='nv'>state</span> <span class='o'>|&gt;</span> <span class='nf'><a href='https://dplyr.tidyverse.org/reference/recode-and-replace-values.html'>replace_values</a></span><span class='o'>(</span><span class='kc'>NA</span> <span class='o'>~</span> <span class='s'>"Unknown"</span><span class='o'>)</span></span>
<span></span>
<span><span class='c'># Historically this has been "the way" to do a partial update,</span></span>
<span><span class='c'># but it's odd that the "primary" input is at the end!</span></span>
<span><span class='nf'><a href='https://dplyr.tidyverse.org/reference/if_else.html'>if_else</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/NA.html'>is.na</a></span><span class='o'>(</span><span class='nv'>state</span><span class='o'>)</span>, <span class='s'>"Unknown"</span>, <span class='nv'>state</span><span class='o'>)</span></span>
<span><span class='nf'><a href='https://dplyr.tidyverse.org/reference/case-and-replace-when.html'>case_when</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/NA.html'>is.na</a></span><span class='o'>(</span><span class='nv'>state</span><span class='o'>)</span> <span class='o'>~</span> <span class='s'>"Unknown"</span>, .default <span class='o'>=</span> <span class='nv'>state</span><span class='o'>)</span></span></code></pre>

</div>

If you're a package author, you'll probably also be interested in [`vctrs::vec_recode_values()`](https://vctrs.r-lib.org/reference/vec-recode-and-replace.html) and [`vctrs::vec_replace_values()`](https://vctrs.r-lib.org/reference/vec-recode-and-replace.html), which are low dependency functions that power the dplyr variants.

### What about `case_match()`?

We've soft-deprecated [`case_match()`](https://dplyr.tidyverse.org/reference/case_match.html) in favor of [`recode_values()`](https://dplyr.tidyverse.org/reference/recode-and-replace-values.html), which is a drop in replacement.

[`case_match()`](https://dplyr.tidyverse.org/reference/case_match.html) was an incremental step towards this recoding family, but:

-   It has a pretty confusing name compared with [`recode_values()`](https://dplyr.tidyverse.org/reference/recode-and-replace-values.html).
-   It lacked a way to work with lookup tables, like `from` and `to`.
-   It lacks a replacement variant, like [`replace_values()`](https://dplyr.tidyverse.org/reference/recode-and-replace-values.html).

Rather than keeping [`case_match()`](https://dplyr.tidyverse.org/reference/case_match.html) around indefinitely, we've decided to initiate the process of its removal since it was only introduced in dplyr 1.1.0.

## Deprecations

dplyr 1.2.0 advances the lifecycle stage of many deprecated functions. These deprecations have been in the works for many years now, due to our slow and very deliberate deprecation process via the [lifecycle package](https://lifecycle.r-lib.org/). We'll cover the highlights, and you can find the full list [here](https://github.com/tidyverse/dplyr/releases/tag/v1.2.0).

For any packages that we broke via these deprecations, we provided a pull request (or at least an issue, for complex cases) and some advance warning. We semi-automated some of this process using Claude Code, which you can read about [here](https://blog.davisvaughan.com/posts/2026-01-09-claude-200-pull-requests/).

-   All underscored verbs have moved from deprecated to defunct, such as [`mutate_()`](https://dplyr.tidyverse.org/reference/defunct-lazyeval.html) and [`arrange_()`](https://dplyr.tidyverse.org/reference/defunct-lazyeval.html). These have been deprecated since dplyr 0.7.0 back in 2017 (yes, 2017!!). Use the non-underscored versions, see [`vignette("programming")`](https://dplyr.tidyverse.org/articles/programming.html) for details.

-   [`mutate_each()`](https://dplyr.tidyverse.org/reference/defunct-each.html) and [`summarise_each()`](https://dplyr.tidyverse.org/reference/defunct-each.html) have moved from deprecated to defunct. These were also deprecated in dplyr 0.7.0. Use [`mutate()`](https://dplyr.tidyverse.org/reference/mutate.html) and [`summarise()`](https://dplyr.tidyverse.org/reference/summarise.html) with [`across()`](https://dplyr.tidyverse.org/reference/across.html) instead.

-   Returning more or less than 1 row per group in [`summarise()`](https://dplyr.tidyverse.org/reference/summarise.html) has moved from deprecated to defunct. This was deprecated in dplyr 1.1.0 in 2023 after we realized that this was an unsafe feature for [`summarise()`](https://dplyr.tidyverse.org/reference/summarise.html), which you should always expect to return exactly 1 row per group. [`reframe()`](https://dplyr.tidyverse.org/reference/reframe.html) is a drop in replacement when you need this.

-   In [`case_when()`](https://dplyr.tidyverse.org/reference/case-and-replace-when.html), supplying all size 1 LHS inputs along with a size \>1 RHS input is now soft-deprecated. This is an improper usage of [`case_when()`](https://dplyr.tidyverse.org/reference/case-and-replace-when.html) that should instead be a series of if statements, like:

    ``` r
    # Scalars!
    code <- 1L
    flavor <- "vanilla"

    # Improper usage:
    case_when(
      code == 1L && flavor == "chocolate" ~ x,
      code == 1L && flavor == "vanilla" ~ y,
      code == 2L && flavor == "vanilla" ~ z,
      .default = default
    )

    # Recommended:
    if (code == 1L && flavor == "chocolate") {
      x
    } else if (code == 1L && flavor == "vanilla") {
      y
    } else if (code == 2L && flavor == "vanilla") {
      z
    } else {
      default
    }
    ```

    The recycling behavior that allows this style of [`case_when()`](https://dplyr.tidyverse.org/reference/case-and-replace-when.html) to work is unsafe, and can result in silent bugs that we'd like to guard against with an error in the future. See [this issue](https://github.com/tidyverse/dplyr/issues/7082) for context.

-   The `dplyr.legacy_locale` global option is soft-deprecated. If you used this to affect the ordering of [`arrange()`](https://dplyr.tidyverse.org/reference/arrange.html), use `arrange(.locale =)` instead. If you used this to affect the ordering of `group_by() |> summarise()`, follow up with an additional call to `arrange(.locale =)` instead.

-   [`if_else()`](https://dplyr.tidyverse.org/reference/if_else.html) no longer allows `condition` to be a logical array. It must be a logical vector with no `dim` attribute.

-   We've removed a number of previously defunct functions, shrinking the footprint of dplyr's API:

    -   `id()`
    -   `failwith()`
    -   `select_vars()` and `select_vars_()`
    -   `rename_vars()` and `rename_vars_()`
    -   `select_var()`
    -   `current_vars()`
    -   `bench_tbls()`, `compare_tbls()`, `compare_tbls2()`, `eval_tbls()`, and `eval_tbls2()`
    -   `location()` and `changes()`

## Acknowledgements

We'd like to thank all 177 contributors who help in someway, whether it was filing issues or contributing code and documentation: [@abalter](https://github.com/abalter), [@abichat](https://github.com/abichat), [@adupaix](https://github.com/adupaix), [@AlexBainton](https://github.com/AlexBainton), [@alexmcsw](https://github.com/alexmcsw), [@AltfunsMA](https://github.com/AltfunsMA), [@AmeliaMN](https://github.com/AmeliaMN), [@antdurrant](https://github.com/antdurrant), [@AnthonyEbert](https://github.com/AnthonyEbert), [@apalacio9502](https://github.com/apalacio9502), [@apeterson91](https://github.com/apeterson91), [@arnaudgallou](https://github.com/arnaudgallou), [@awpsoras](https://github.com/awpsoras), [@bakaburg1](https://github.com/bakaburg1), [@barnabasharris](https://github.com/barnabasharris), [@BHII-KSC](https://github.com/BHII-KSC), [@bholtemeyer](https://github.com/bholtemeyer), [@billdenney](https://github.com/billdenney), [@bounlu](https://github.com/bounlu), [@brendensm](https://github.com/brendensm), [@bridroberts1](https://github.com/bridroberts1), [@brookslogan](https://github.com/brookslogan), [@catalamarti](https://github.com/catalamarti), [@cboettig](https://github.com/cboettig), [@cbrnr](https://github.com/cbrnr), [@ccani007](https://github.com/ccani007), [@charliejhadley](https://github.com/charliejhadley), [@ChrisHIV](https://github.com/ChrisHIV), [@ChristianRohde](https://github.com/ChristianRohde), [@cobac](https://github.com/cobac), [@conig](https://github.com/conig), [@const-ae](https://github.com/const-ae), [@Copilot](https://github.com/Copilot), [@d-morrison](https://github.com/d-morrison), [@DanChaltiel](https://github.com/DanChaltiel), [@daniel-simeone](https://github.com/daniel-simeone), [@DanielBraddock](https://github.com/DanielBraddock), [@david-romano](https://github.com/david-romano), [@davidrsch](https://github.com/davidrsch), [@davidss101](https://github.com/davidss101), [@DavisVaughan](https://github.com/DavisVaughan), [@dcaud](https://github.com/dcaud), [@deschen1](https://github.com/deschen1), [@DesiQuintans](https://github.com/DesiQuintans), [@devster31](https://github.com/devster31), [@dkutner](https://github.com/dkutner), [@dmuenz](https://github.com/dmuenz), [@ds-jim](https://github.com/ds-jim), [@eitsupi](https://github.com/eitsupi), [@EmilHvitfeldt](https://github.com/EmilHvitfeldt), [@etiennebacher](https://github.com/etiennebacher), [@eutwt](https://github.com/eutwt), [@EvertonTLima](https://github.com/EvertonTLima), [@ferreirafm](https://github.com/ferreirafm), [@gaborcsardi](https://github.com/gaborcsardi), [@GabryS3](https://github.com/GabryS3), [@Gastonia02](https://github.com/Gastonia02), [@GBarnsley](https://github.com/GBarnsley), [@gevro](https://github.com/gevro), [@ggrothendieck](https://github.com/ggrothendieck), [@GischD](https://github.com/GischD), [@gks281263](https://github.com/gks281263), [@gracehartley](https://github.com/gracehartley), [@graphdr](https://github.com/graphdr), [@hadley](https://github.com/hadley), [@heliconone](https://github.com/heliconone), [@Hzanib](https://github.com/Hzanib), [@ilovemane](https://github.com/ilovemane), [@ja-ortiz-uniandes](https://github.com/ja-ortiz-uniandes), [@jack-davison](https://github.com/jack-davison), [@james-kilgour](https://github.com/james-kilgour), [@JamesHWade](https://github.com/JamesHWade), [@jaymicro](https://github.com/jaymicro), [@JBrandenburg02](https://github.com/JBrandenburg02), [@jc-usda](https://github.com/jc-usda), [@jennybc](https://github.com/jennybc), [@jeroenjanssens](https://github.com/jeroenjanssens), [@jestover](https://github.com/jestover), [@jl5000](https://github.com/jl5000), [@jmbarbone](https://github.com/jmbarbone), [@john-b-edwards](https://github.com/john-b-edwards), [@jordanmross](https://github.com/jordanmross), [@joshua-theisen](https://github.com/joshua-theisen), [@jrwinget](https://github.com/jrwinget), [@juliaapolonio](https://github.com/juliaapolonio), [@jxu](https://github.com/jxu), [@KaiAragaki](https://github.com/KaiAragaki), [@kiki830621](https://github.com/kiki830621), [@KittJonathan](https://github.com/KittJonathan), [@kleinerChemiker](https://github.com/kleinerChemiker), [@kletts](https://github.com/kletts), [@krlmlr](https://github.com/krlmlr), [@ks8997](https://github.com/ks8997), [@kylebutts](https://github.com/kylebutts), [@larsentom](https://github.com/larsentom), [@latot](https://github.com/latot), [@lboller-pwbm](https://github.com/lboller-pwbm), [@lionel-](https://github.com/lionel-), [@Longfei2](https://github.com/Longfei2), [@lschneiderbauer](https://github.com/lschneiderbauer), [@LukasTang](https://github.com/LukasTang), [@lukebandy](https://github.com/lukebandy), [@maciekbanas](https://github.com/maciekbanas), [@maelle](https://github.com/maelle), [@marcuslehr](https://github.com/marcuslehr), [@Mark-AP](https://github.com/Mark-AP), [@markwestcott34](https://github.com/markwestcott34), [@maskegger](https://github.com/maskegger), [@matiasandina](https://github.com/matiasandina), [@matthewjnield](https://github.com/matthewjnield), [@mbcann01](https://github.com/mbcann01), [@Meghansaha](https://github.com/Meghansaha), [@metanoid](https://github.com/metanoid), [@MichaelChirico](https://github.com/MichaelChirico), [@MikeJohnPage](https://github.com/MikeJohnPage), [@MilesMcBain](https://github.com/MilesMcBain), [@mine-cetinkaya-rundel](https://github.com/mine-cetinkaya-rundel), [@MohsenSoltanifar](https://github.com/MohsenSoltanifar), [@moodymudskipper](https://github.com/moodymudskipper), [@Moohan](https://github.com/Moohan), [@mp8](https://github.com/mp8), [@mpsturbo](https://github.com/mpsturbo), [@mr-c](https://github.com/mr-c), [@muschellij2](https://github.com/muschellij2), [@musvaage](https://github.com/musvaage), [@Mzhuk7](https://github.com/Mzhuk7), [@nalimilan](https://github.com/nalimilan), [@nathanhaigh](https://github.com/nathanhaigh), [@nirguk](https://github.com/nirguk), [@nmercadeb](https://github.com/nmercadeb), [@olivermagnanimous](https://github.com/olivermagnanimous), [@olivroy](https://github.com/olivroy), [@orgadish](https://github.com/orgadish), [@pangchaoran](https://github.com/pangchaoran), [@paschatz](https://github.com/paschatz), [@prubin73](https://github.com/prubin73), [@PStaus](https://github.com/PStaus), [@psychelzh](https://github.com/psychelzh), [@py9mrg](https://github.com/py9mrg), [@Raesu](https://github.com/Raesu), [@randyzwitch](https://github.com/randyzwitch), [@Raoul-Kima](https://github.com/Raoul-Kima), [@ReedMerrill](https://github.com/ReedMerrill), [@RodDalBen](https://github.com/RodDalBen), [@RodrigoZepeda](https://github.com/RodrigoZepeda), [@rossholmberg](https://github.com/rossholmberg), [@RoyalTS](https://github.com/RoyalTS), [@ryandward](https://github.com/ryandward), [@sbanville-delfi](https://github.com/sbanville-delfi), [@ScientiaFelis](https://github.com/ScientiaFelis), [@shirdekel](https://github.com/shirdekel), [@slager](https://github.com/slager), [@sschooler](https://github.com/sschooler), [@steffen-stell](https://github.com/steffen-stell), [@szimmer](https://github.com/szimmer), [@TheClownBongo](https://github.com/TheClownBongo), [@thomasjwood](https://github.com/thomasjwood), [@TimTaylor](https://github.com/TimTaylor), [@tlyons253](https://github.com/tlyons253), [@tomalrussell](https://github.com/tomalrussell), [@tomwagstaff-opml](https://github.com/tomwagstaff-opml), [@torfason](https://github.com/torfason), [@Tyrrx](https://github.com/Tyrrx), [@Unaimend](https://github.com/Unaimend), [@VisruthSK](https://github.com/VisruthSK), [@vorpalvorpal](https://github.com/vorpalvorpal), [@walkerjameschris](https://github.com/walkerjameschris), [@wbvguo](https://github.com/wbvguo), [@wbzyl](https://github.com/wbzyl), [@wkumler](https://github.com/wkumler), [@yaboody](https://github.com/yaboody), [@yjunechoe](https://github.com/yjunechoe), [@ynsec37](https://github.com/ynsec37), [@ywhcuhk](https://github.com/ywhcuhk), [@ZHBHSMILE](https://github.com/ZHBHSMILE), [@zhjx19](https://github.com/zhjx19), and [@ZIBOWANGKANGYU](https://github.com/ZIBOWANGKANGYU).

