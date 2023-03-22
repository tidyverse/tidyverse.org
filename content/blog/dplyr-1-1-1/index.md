---
output: hugodown::hugo_document
slug: dplyr-1-1-1
title: dplyr 1.1.1
date: 2023-03-22
author: Davis Vaughan
description: >
    dplyr 1.1.1 is on CRAN! This patch release includes a number of performance regression fixes along with refinements to the multiple match join warnings that result in warnings being thrown much less often.
photo:
  url: https://unsplash.com/photos/jy8z4NBIYSQ
  author: Jon Tyson
categories: [package] 
tags: [dplyr, dplyr-1-1-0]
editor_options: 
  chunk_output_type: console
rmd_hash: b01f556beb3988a0

---

We're stoked to announce the release of [dplyr 1.1.1](https://dplyr.tidyverse.org/). We don't typically blog about patch releases, because they generally only fix bugs without significantly changing behavior, but this one includes two important updates:

-   Addressing various performance regressions
-   Refining the `multiple` match warning thrown by dplyr's joins

You can see a full list of changes in the [release notes](https://dplyr.tidyverse.org/news/index.html). To see the other blog posts in the dplyr 1.1.0 series, head [here](https://www.tidyverse.org/tags/dplyr-1-1-0/).

You can install dplyr 1.1.1 from CRAN with:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://rdrr.io/r/utils/install.packages.html'>install.packages</a></span><span class='o'>(</span><span class='s'>"dplyr"</span><span class='o'>)</span></span></code></pre>

</div>

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://dplyr.tidyverse.org'>dplyr</a></span><span class='o'>)</span></span></code></pre>

</div>

## Performance regressions

In the [1.1.0 post on vctrs](/blog/2023/02/dplyr-1-1-0-vctrs), we discussed that we've rewritten all of dplyr's vector functions on top of [vctrs](https://vctrs.r-lib.org/) for improved versatility. Unfortunately, we accidentally made two sets of functions much slower, especially when used on a data frame with many groups:

-   [`case_when()`](https://dplyr.tidyverse.org/reference/case_when.html) and [`if_else()`](https://dplyr.tidyverse.org/reference/if_else.html)

-   [`nth()`](https://dplyr.tidyverse.org/reference/nth.html), [`first()`](https://dplyr.tidyverse.org/reference/nth.html), and [`last()`](https://dplyr.tidyverse.org/reference/nth.html)

These performance issues have been addressed, and should be back to 1.0.10 level of performance. [`case_when()`](https://dplyr.tidyverse.org/reference/case_when.html) is still *slightly* slower than 1.0.10, but it isn't likely to be very noticeable, and we already have plans to improve this further in a future release.

## Revisiting multiple matches

In the [1.1.0 post on joins](/blog/2023/01/dplyr-1-1-0-joins), we discussed the new `multiple` argument that was added to [`left_join()`](https://dplyr.tidyverse.org/reference/mutate-joins.html) and friends, which had a built in safety check that warned when you performed a join where a row from `x` matched more than one row from `y`. The TLDR of the discussion below is that we've realized that this warning was being thrown in too many cases, so we've adjusted it in such a way that it now only catches the most dangerous type of join (a many-to-many join), meaning that you should see the warning *much* less often.

As a reminder, `multiple` determines what happens when a row from `x` matches more than one row from `y`. You can choose to return `"all"` of the matches, the `"first"` or `"last"` match, or `"any"` of the matches if you are just interested in detecting if there is at least one. `multiple` defaulted to a behavior similar to `"all"`, with the added side effect of throwing a warning if multiple matches were actually detected, like this:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>student</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://tibble.tidyverse.org/reference/tibble.html'>tibble</a></span><span class='o'>(</span></span>
<span>  student_id <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='m'>1</span>, <span class='m'>2</span>, <span class='m'>3</span><span class='o'>)</span>,</span>
<span>  transfer <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='kc'>FALSE</span>, <span class='kc'>TRUE</span>, <span class='kc'>TRUE</span><span class='o'>)</span>,</span>
<span>  initial_term <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"fall 2018"</span>, <span class='s'>"fall 2020"</span>, <span class='s'>"fall 2020"</span><span class='o'>)</span></span>
<span><span class='o'>)</span></span>
<span></span>
<span><span class='nv'>term</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://tibble.tidyverse.org/reference/tibble.html'>tibble</a></span><span class='o'>(</span></span>
<span>  student_id <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='m'>1</span>, <span class='m'>1</span>, <span class='m'>2</span>, <span class='m'>3</span>, <span class='m'>3</span>, <span class='m'>3</span><span class='o'>)</span>,</span>
<span>  term <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"fall 2018"</span>, <span class='s'>"spring 2019"</span>, <span class='s'>"fall 2020"</span>, <span class='s'>"fall 2020"</span>, <span class='s'>"spring 2021"</span>, <span class='s'>"fall 2021"</span><span class='o'>)</span>,</span>
<span>  course_load <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='m'>12</span>, <span class='m'>15</span>, <span class='m'>10</span>, <span class='m'>14</span>, <span class='m'>15</span>, <span class='m'>12</span><span class='o'>)</span></span>
<span><span class='o'>)</span></span></code></pre>

</div>

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='c'># Information about students attending a university.</span></span>
<span><span class='c'># One row per (student_id).</span></span>
<span><span class='nv'>student</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 3 × 3</span></span></span>
<span><span class='c'>#&gt;   student_id transfer initial_term</span></span>
<span><span class='c'>#&gt;        <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;lgl&gt;</span>    <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>       </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span>          1 FALSE    fall 2018   </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span>          2 TRUE     fall 2020   </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>3</span>          3 TRUE     fall 2020</span></span>
<span></span><span></span>
<span><span class='c'># Term specific information about each student.</span></span>
<span><span class='c'># One row per (student_id, term) combination.</span></span>
<span><span class='nv'>term</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 6 × 3</span></span></span>
<span><span class='c'>#&gt;   student_id term        course_load</span></span>
<span><span class='c'>#&gt;        <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>             <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span>          1 fall 2018            12</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span>          1 spring 2019          15</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>3</span>          2 fall 2020            10</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>4</span>          3 fall 2020            14</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>5</span>          3 spring 2021          15</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>6</span>          3 fall 2021            12</span></span>
<span></span></code></pre>

</div>

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>student</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/mutate-joins.html'>left_join</a></span><span class='o'>(</span><span class='nv'>term</span>, <span class='nf'><a href='https://dplyr.tidyverse.org/reference/join_by.html'>join_by</a></span><span class='o'>(</span><span class='nv'>student_id</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; Warning in left_join(student, term, join_by(student_id)): Each row in `x` is expected to match at most 1 row in `y`.</span></span>
<span><span class='c'>#&gt; i Row 1 of `x` matches multiple rows.</span></span>
<span><span class='c'>#&gt; i If multiple matches are expected, set `multiple = "all"` to silence this warning.</span></span>
<span><span class='c'>#&gt; # A tibble: 6 × 5</span></span>
<span><span class='c'>#&gt;   student_id transfer initial_term term        course_load</span></span>
<span><span class='c'>#&gt;        &lt;dbl&gt; &lt;lgl&gt;    &lt;chr&gt;        &lt;chr&gt;             &lt;dbl&gt;</span></span>
<span><span class='c'>#&gt; 1          1 FALSE    fall 2018    fall 2018            12</span></span>
<span><span class='c'>#&gt; 2          1 FALSE    fall 2018    spring 2019          15</span></span>
<span><span class='c'>#&gt; 3          2 TRUE     fall 2020    fall 2020            10</span></span>
<span><span class='c'>#&gt; 4          3 TRUE     fall 2020    fall 2020            14</span></span>
<span><span class='c'>#&gt; 5          3 TRUE     fall 2020    spring 2021          15</span></span>
<span><span class='c'>#&gt; 6          3 TRUE     fall 2020    fall 2021            12</span></span></code></pre>

</div>

To silence this warning, we encouraged you to set `multiple = "all"` to be explicit about the fact that you expected a row from `x` to match multiple rows in `y`.

The original motivation for this behavior comes from a two-part hypothesis of ours:

-   Users are often surprised when a join returns more rows than the left-hand table started with (in the above example, `student` has 3 rows but the join result has 6).

-   It is dangerous to allow joins that can result in a Cartesian explosion of the number of rows (i.e. `nrow(x) * nrow(y)`).

This hypothesis led us to automatically warn on two types of join relationships, one-to-many joins and many-to-many joins. If you aren't familiar with these terms, here is a quick rundown of the 4 types of join relationships (often discussed in a SQL context), which provide constraints on the number of allowed matches:

-   one-to-one:
    -   A row from `x` can match at most 1 row from `y`.
    -   A row from `y` can match at most 1 row from `x`.
-   one-to-many:
    -   A row from `x` can match any number of rows in `y`.
    -   A row from `y` can match at most 1 row from `x`.
-   many-to-one:
    -   A row from `x` can match at most 1 row from `y`.
    -   A row from `y` can match any number of rows in `x`.
-   many-to-many:
    -   A row from `x` can match any number of rows in `y`.
    -   A row from `y` can match any number of rows in `x`.

After gathering some valuable [user feedback](https://github.com/tidyverse/dplyr/issues/6717) and conducting an [in depth analysis](https://github.com/tidyverse/dplyr/issues/6731) of these join relationships, we've determined that the only relationship style actually worth warning on is many-to-many, because that is the one that can result in a Cartesian explosion of rows. In retrospect, the one-to-many relationship is actually quite common, and is symmetrical with many-to-one, which we weren't warning on. You could actually exploit this fact by switching the above join around, which would silence the warning:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>term</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/mutate-joins.html'>left_join</a></span><span class='o'>(</span><span class='nv'>student</span>, <span class='nf'><a href='https://dplyr.tidyverse.org/reference/join_by.html'>join_by</a></span><span class='o'>(</span><span class='nv'>student_id</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 6 × 5</span></span></span>
<span><span class='c'>#&gt;   student_id term        course_load transfer initial_term</span></span>
<span><span class='c'>#&gt;        <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>             <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;lgl&gt;</span>    <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>       </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span>          1 fall 2018            12 FALSE    fall 2018   </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span>          1 spring 2019          15 FALSE    fall 2018   </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>3</span>          2 fall 2020            10 TRUE     fall 2020   </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>4</span>          3 fall 2020            14 TRUE     fall 2020   </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>5</span>          3 spring 2021          15 TRUE     fall 2020   </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>6</span>          3 fall 2021            12 TRUE     fall 2020</span></span>
<span></span></code></pre>

</div>

We still believe that new users are often surprised when a join returns more rows than they originally started with, but the many-to-one case of this is rarely a problem in practice. So, as of dplyr 1.1.1, we no longer warn on one-to-many relationships, which should drastically reduce the amount of warnings that you see.

### Many-to-many relationships

A many-to-many relationship is much harder to construct (which is good). In fact, a database system won't even let you create one of these "relationships" between two tables directly, instead requiring you to create a third bridge table that turns the many-to-many relationship into two one-to-many relationships. We can "accidentally" create one of these in R though:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>course</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://tibble.tidyverse.org/reference/tibble.html'>tibble</a></span><span class='o'>(</span></span>
<span>  student_id <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='m'>1</span>, <span class='m'>1</span>, <span class='m'>1</span>, <span class='m'>2</span>, <span class='m'>2</span>, <span class='m'>3</span>, <span class='m'>3</span>, <span class='m'>3</span>, <span class='m'>3</span><span class='o'>)</span>,</span>
<span>  instructor_id <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='m'>1</span>, <span class='m'>2</span>, <span class='m'>3</span>, <span class='m'>1</span>, <span class='m'>2</span>, <span class='m'>1</span>, <span class='m'>2</span>, <span class='m'>3</span>, <span class='m'>4</span><span class='o'>)</span>,</span>
<span>  course <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='m'>101</span>, <span class='m'>110</span>, <span class='m'>123</span>, <span class='m'>110</span>, <span class='m'>101</span>, <span class='m'>110</span>, <span class='m'>115</span>, <span class='m'>110</span>, <span class='m'>101</span><span class='o'>)</span>,</span>
<span>  term <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span></span>
<span>    <span class='s'>"fall 2018"</span>, <span class='s'>"fall 2018"</span>, <span class='s'>"spring 2019"</span>, <span class='s'>"fall 2020"</span>, <span class='s'>"fall 2020"</span>, </span>
<span>    <span class='s'>"fall 2020"</span>, <span class='s'>"fall 2020"</span>, <span class='s'>"spring 2021"</span>, <span class='s'>"fall 2021"</span></span>
<span>  <span class='o'>)</span>,</span>
<span>  grade <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"A"</span>, <span class='s'>"B"</span>, <span class='s'>"A"</span>, <span class='s'>"B"</span>, <span class='s'>"C"</span>, <span class='s'>"A"</span>, <span class='s'>"C"</span>, <span class='s'>"D"</span>, <span class='s'>"B"</span><span class='o'>)</span></span>
<span><span class='o'>)</span></span>
<span></span>
<span><span class='c'># Information about the courses each student took per semester.</span></span>
<span><span class='c'># One row per (student_id, course, term) combination.</span></span>
<span><span class='nv'>course</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 9 × 5</span></span></span>
<span><span class='c'>#&gt;   student_id instructor_id course term        grade</span></span>
<span><span class='c'>#&gt;        <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>         <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>  <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>       <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span>          1             1    101 fall 2018   A    </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span>          1             2    110 fall 2018   B    </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>3</span>          1             3    123 spring 2019 A    </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>4</span>          2             1    110 fall 2020   B    </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>5</span>          2             2    101 fall 2020   C    </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>6</span>          3             1    110 fall 2020   A    </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>7</span>          3             2    115 fall 2020   C    </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>8</span>          3             3    110 spring 2021 D    </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>9</span>          3             4    101 fall 2021   B</span></span>
<span></span></code></pre>

</div>

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='c'># Forgetting to join by both `student_id` and `term`!</span></span>
<span><span class='nv'>term</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/mutate-joins.html'>left_join</a></span><span class='o'>(</span><span class='nv'>course</span>, by <span class='o'>=</span> <span class='nf'><a href='https://dplyr.tidyverse.org/reference/join_by.html'>join_by</a></span><span class='o'>(</span><span class='nv'>student_id</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; Warning in left_join(term, course, by = join_by(student_id)): Detected an unexpected many-to-many relationship between `x` and `y`.</span></span>
<span><span class='c'>#&gt; <span style='color: #00BBBB;'>ℹ</span> Row 1 of `x` matches multiple rows in `y`.</span></span>
<span><span class='c'>#&gt; <span style='color: #00BBBB;'>ℹ</span> Row 1 of `y` matches multiple rows in `x`.</span></span>
<span><span class='c'>#&gt; <span style='color: #00BBBB;'>ℹ</span> If a many-to-many relationship is expected, set `relationship =</span></span>
<span><span class='c'>#&gt;   "many-to-many"` to silence this warning.</span></span>
<span></span><span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 20 × 7</span></span></span>
<span><span class='c'>#&gt;    student_id term.x      course_load instructor_id course term.y      grade</span></span>
<span><span class='c'>#&gt;         <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>             <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>         <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>  <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>       <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 1</span>          1 fall 2018            12             1    101 fall 2018   A    </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 2</span>          1 fall 2018            12             2    110 fall 2018   B    </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 3</span>          1 fall 2018            12             3    123 spring 2019 A    </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 4</span>          1 spring 2019          15             1    101 fall 2018   A    </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 5</span>          1 spring 2019          15             2    110 fall 2018   B    </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 6</span>          1 spring 2019          15             3    123 spring 2019 A    </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 7</span>          2 fall 2020            10             1    110 fall 2020   B    </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 8</span>          2 fall 2020            10             2    101 fall 2020   C    </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 9</span>          3 fall 2020            14             1    110 fall 2020   A    </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>10</span>          3 fall 2020            14             2    115 fall 2020   C    </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>11</span>          3 fall 2020            14             3    110 spring 2021 D    </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>12</span>          3 fall 2020            14             4    101 fall 2021   B    </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>13</span>          3 spring 2021          15             1    110 fall 2020   A    </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>14</span>          3 spring 2021          15             2    115 fall 2020   C    </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>15</span>          3 spring 2021          15             3    110 spring 2021 D    </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>16</span>          3 spring 2021          15             4    101 fall 2021   B    </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>17</span>          3 fall 2021            12             1    110 fall 2020   A    </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>18</span>          3 fall 2021            12             2    115 fall 2020   C    </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>19</span>          3 fall 2021            12             3    110 spring 2021 D    </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>20</span>          3 fall 2021            12             4    101 fall 2021   B</span></span>
<span></span></code></pre>

</div>

In the example above, we've forgotten to include the `term` column when joining these two tables together, which accidentally results in a small explosion of rows (we end up with 20 rows, more than in either original input, but not quite the maximum possible amount, which is a whopping 54 rows!). Luckily, dplyr warns us that at least one row in each table matches more than one row in the opposite table - a sign that something isn't right. At this point we can do one of two things:

-   Look into the new `relationship` argument that the warning mentions (we'll discuss this below)

-   Look at our join to see if we made a mistake

Of course, in this case we've messed up, and adding `term` into the by expression results in the correct (and silent) join:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>term</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/mutate-joins.html'>left_join</a></span><span class='o'>(</span><span class='nv'>course</span>, by <span class='o'>=</span> <span class='nf'><a href='https://dplyr.tidyverse.org/reference/join_by.html'>join_by</a></span><span class='o'>(</span><span class='nv'>student_id</span>, <span class='nv'>term</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 9 × 6</span></span></span>
<span><span class='c'>#&gt;   student_id term        course_load instructor_id course grade</span></span>
<span><span class='c'>#&gt;        <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>             <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>         <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>  <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span>          1 fall 2018            12             1    101 A    </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span>          1 fall 2018            12             2    110 B    </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>3</span>          1 spring 2019          15             3    123 A    </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>4</span>          2 fall 2020            10             1    110 B    </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>5</span>          2 fall 2020            10             2    101 C    </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>6</span>          3 fall 2020            14             1    110 A    </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>7</span>          3 fall 2020            14             2    115 C    </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>8</span>          3 spring 2021          15             3    110 D    </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>9</span>          3 fall 2021            12             4    101 B</span></span>
<span></span></code></pre>

</div>

### Join `relationship`s

To adjust the joins to only warn on many-to-many relationships, we've done two things:

-   `multiple` now defaults to `"all"`, and is now focused solely on limiting the matches returned if multiple are detected, rather than also optionally warning/erroring.

-   We've added a new `relationship` argument.

The `relationship` argument allows you to explicitly specify the expected join relationship between the keys of `x` and `y` using the exact options we listed above: `"one-to-one"`, `"one-to-many"`, `"many-to-one"`, and `"many-to-many"`. If the constraints of the relationship you choose are violated, an error is thrown. For example, we could use this to require that the `student` + `term` join contains a one-to-many relationship between the two tables:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>student</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/mutate-joins.html'>left_join</a></span><span class='o'>(</span><span class='nv'>term</span>, <span class='nf'><a href='https://dplyr.tidyverse.org/reference/join_by.html'>join_by</a></span><span class='o'>(</span><span class='nv'>student_id</span><span class='o'>)</span>, relationship <span class='o'>=</span> <span class='s'>"one-to-many"</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 6 × 5</span></span></span>
<span><span class='c'>#&gt;   student_id transfer initial_term term        course_load</span></span>
<span><span class='c'>#&gt;        <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;lgl&gt;</span>    <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>        <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>             <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span>          1 FALSE    fall 2018    fall 2018            12</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span>          1 FALSE    fall 2018    spring 2019          15</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>3</span>          2 TRUE     fall 2020    fall 2020            10</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>4</span>          3 TRUE     fall 2020    fall 2020            14</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>5</span>          3 TRUE     fall 2020    spring 2021          15</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>6</span>          3 TRUE     fall 2020    fall 2021            12</span></span>
<span></span></code></pre>

</div>

Let's violate this by adding a duplicate row in `student`:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>student_bad</span> <span class='o'>&lt;-</span> <span class='nv'>student</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'>tibble</span><span class='nf'>::</span><span class='nf'><a href='https://tibble.tidyverse.org/reference/add_row.html'>add_row</a></span><span class='o'>(</span></span>
<span>    student_id <span class='o'>=</span> <span class='m'>1</span>, </span>
<span>    transfer <span class='o'>=</span> <span class='kc'>FALSE</span>, </span>
<span>    initial_term <span class='o'>=</span> <span class='s'>"fall 2019"</span>, </span>
<span>    .after <span class='o'>=</span> <span class='m'>1</span></span>
<span>  <span class='o'>)</span></span>
<span></span>
<span><span class='nv'>student_bad</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 4 × 3</span></span></span>
<span><span class='c'>#&gt;   student_id transfer initial_term</span></span>
<span><span class='c'>#&gt;        <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;lgl&gt;</span>    <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>       </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span>          1 FALSE    fall 2018   </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span>          1 FALSE    fall 2019   </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>3</span>          2 TRUE     fall 2020   </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>4</span>          3 TRUE     fall 2020</span></span>
<span></span></code></pre>

</div>

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>student_bad</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/mutate-joins.html'>left_join</a></span><span class='o'>(</span><span class='nv'>term</span>, <span class='nf'><a href='https://dplyr.tidyverse.org/reference/join_by.html'>join_by</a></span><span class='o'>(</span><span class='nv'>student_id</span><span class='o'>)</span>, relationship <span class='o'>=</span> <span class='s'>"one-to-many"</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #BBBB00; font-weight: bold;'>Error</span><span style='font-weight: bold;'> in `left_join()`:</span></span></span>
<span><span class='c'>#&gt; <span style='color: #BBBB00;'>!</span> Each row in `y` must match at most 1 row in `x`.</span></span>
<span><span class='c'>#&gt; <span style='color: #00BBBB;'>ℹ</span> Row 1 of `y` matches multiple rows in `x`.</span></span>
<span></span></code></pre>

</div>

The default value of `relationship` doesn't add any constraints, but for equality joins it will check to see if a many-to-many relationship exists, and will warn if one occurs (like with the `term` + `course` join from above). As mentioned before, this is quite hard to do, and often means you have a mistake in your join call or in the data itself. If you really do want to perform a join with this kind of relationship, to silence the warning you can explicitly specify `relationship = "many-to-many"`.

One last thing to note is that `relationship` doesn't handle the case of an *unmatched* row. For that, you should use the `unmatched` argument that was also added in 1.1.0. The combination of `relationship` and `unmatched` provides a complete set of tools for adding production level quality control checks to your joins.

## Acknowledgements

The examples used in this blog post were adapted from [@eipi10](https://github.com/eipi10) in [this issue](https://github.com/tidyverse/dplyr/issues/6717).

We'd like to thank all 66 contributors who help in someway, whether it was filing issues or contributing code and documentation: [@alexhallam](https://github.com/alexhallam), [@ammar-gla](https://github.com/ammar-gla), [@arnaudgallou](https://github.com/arnaudgallou), [@ArthurAndrews](https://github.com/ArthurAndrews), [@AuburnEagle-578](https://github.com/AuburnEagle-578), [@batpigandme](https://github.com/batpigandme), [@billdenney](https://github.com/billdenney), [@Bisaloo](https://github.com/Bisaloo), [@bitplane](https://github.com/bitplane), [@chrarnold](https://github.com/chrarnold), [@D5n9sMatrix](https://github.com/D5n9sMatrix), [@daattali](https://github.com/daattali), [@DanChaltiel](https://github.com/DanChaltiel), [@DavisVaughan](https://github.com/DavisVaughan), [@dieghernan](https://github.com/dieghernan), [@dkutner](https://github.com/dkutner), [@eipi10](https://github.com/eipi10), [@eitsupi](https://github.com/eitsupi), [@emilBeBri](https://github.com/emilBeBri), [@fawda123](https://github.com/fawda123), [@fedassembly](https://github.com/fedassembly), [@fkohrt](https://github.com/fkohrt), [@gavinsimpson](https://github.com/gavinsimpson), [@geogale](https://github.com/geogale), [@ggrothendieck](https://github.com/ggrothendieck), [@hadley](https://github.com/hadley), [@hope-data-science](https://github.com/hope-data-science), [@jaganmn](https://github.com/jaganmn), [@jakub-jedrusiak](https://github.com/jakub-jedrusiak), [@JorisChau](https://github.com/JorisChau), [@krlmlr](https://github.com/krlmlr), [@krprasangdas](https://github.com/krprasangdas), [@larry77](https://github.com/larry77), [@lionel-](https://github.com/lionel-), [@lschneiderbauer](https://github.com/lschneiderbauer), [@LukasWallrich](https://github.com/LukasWallrich), [@maellecoursonnais](https://github.com/maellecoursonnais), [@manhnguyen48](https://github.com/manhnguyen48), [@mattansb](https://github.com/mattansb), [@mgirlich](https://github.com/mgirlich), [@mhaynam](https://github.com/mhaynam), [@MichaelChirico](https://github.com/MichaelChirico), [@mine-cetinkaya-rundel](https://github.com/mine-cetinkaya-rundel), [@mkoohafkan](https://github.com/mkoohafkan), [@moodymudskipper](https://github.com/moodymudskipper), [@Moohan](https://github.com/Moohan), [@msgoussi](https://github.com/msgoussi), [@multimeric](https://github.com/multimeric), [@osheen1](https://github.com/osheen1), [@Pozdniakov](https://github.com/Pozdniakov), [@psychelzh](https://github.com/psychelzh), [@pur80a](https://github.com/pur80a), [@robayo](https://github.com/robayo), [@rszulkin](https://github.com/rszulkin), [@salim-b](https://github.com/salim-b), [@sda030](https://github.com/sda030), [@sfirke](https://github.com/sfirke), [@shannonpileggi](https://github.com/shannonpileggi), [@stephLH](https://github.com/stephLH), [@szabgab](https://github.com/szabgab), [@tjebo](https://github.com/tjebo), [@Torvaney](https://github.com/Torvaney), [@twest820](https://github.com/twest820), [@vanillajonathan](https://github.com/vanillajonathan), [@warnes](https://github.com/warnes), and [@zknitter](https://github.com/zknitter).

