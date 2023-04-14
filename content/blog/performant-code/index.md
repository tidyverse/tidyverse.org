---
output: hugodown::hugo_document

slug: performant-packages
title: Writing performant code with tidy tools
date: 2023-04-20
author: Simon Couch
description: >
    When performance becomes an issue for code using tidy interfaces, switching 
    to the backend tools used by tidy developers can offer substantial speedups.
photo:
  url: https://unsplash.com/photos/9Q8PqfeYkMk
  author: Matt Walsh

categories: [programming] 
tags: [package, vctrs]
rmd_hash: 0ffb8d9febf606f4

---

The tidyverse packages provide safe, powerful, and expressive interfaces to solve data science problems. Behind the scenes of the tidyverse is a set of lower-level tools that its developers use to build these interfaces. While these lower-level approaches are often more performant than their tidy analogues, their interfaces are often less readable and safe. For most use cases in interactive data analysis, the advantages of tidyverse interfaces far outweigh the drawback in computational speed. When speed becomes an issue, such as in package code used in computationally intensive settings, transitioning tidy code to use these lower-level interfaces in their backend can offer substantial increases in computational performance.

This post will outline alternatives to tools I love from packages like dplyr and tidyr that I use to speed up computational bottlenecks. These recommendations come from my experiences developing the [tidymodels](https://www.tidymodels.org/) packages, a collection of packages for modeling and machine learning using tidyverse principles. As such, I've included a number of "worked examples" with each proposed alternative, showing how the tidymodels team has used these same tricks to [speed up our code](https://www.simonpcouch.com/blog/speedups-2023/) quite a bit. Before I do that, though, let's make friends with some new R packages.

## Tools of the trade

First, loading the tidyverse:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://tidyverse.tidyverse.org'>tidyverse</a></span><span class='o'>)</span></span></code></pre>

</div>

The most important tools to help you understand what's slowing your code down have little to do with the tidyverse at all!

### profvis

The profvis package is an R package for collecting and visualizing profiling data.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://rstudio.github.io/profvis/'>profvis</a></span><span class='o'>)</span></span></code></pre>

</div>

Profiling is the process of determining how long different portions of a chunk of code take to run. For example, in this next function `slow_function()`, it's somewhat straightforward to tell how long different portions of the following code run for if you know what [`pause()`](https://rdrr.io/pkg/profvis/man/pause.html) does. ([`pause()`](https://rdrr.io/pkg/profvis/man/pause.html) is a function from the profvis package that just chills out for the specified amount of time. For example, `pause(1)` will wait for 1 second before finishing running.)

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>step_1</span> <span class='o'>&lt;-</span> <span class='kr'>function</span><span class='o'>(</span><span class='o'>)</span> <span class='o'>&#123;</span></span>
<span>  <span class='nf'><a href='https://rdrr.io/pkg/profvis/man/pause.html'>pause</a></span><span class='o'>(</span><span class='m'>1</span><span class='o'>)</span></span>
<span><span class='o'>&#125;</span></span>
<span></span>
<span><span class='nv'>step_2</span> <span class='o'>&lt;-</span> <span class='kr'>function</span><span class='o'>(</span><span class='o'>)</span> <span class='o'>&#123;</span></span>
<span>  <span class='nf'><a href='https://rdrr.io/pkg/profvis/man/pause.html'>pause</a></span><span class='o'>(</span><span class='m'>2</span><span class='o'>)</span></span>
<span><span class='o'>&#125;</span></span>
<span></span>
<span><span class='nv'>slow_function</span> <span class='o'>&lt;-</span> <span class='kr'>function</span><span class='o'>(</span><span class='o'>)</span> <span class='o'>&#123;</span></span>
<span>  <span class='nf'>step_1</span><span class='o'>(</span><span class='o'>)</span></span>
<span>  </span>
<span>  <span class='nf'>step_2</span><span class='o'>(</span><span class='o'>)</span></span>
<span>  </span>
<span>  <span class='kr'><a href='https://rdrr.io/r/base/function.html'>return</a></span><span class='o'>(</span><span class='kc'>TRUE</span><span class='o'>)</span></span>
<span><span class='o'>&#125;</span></span></code></pre>

</div>

Profiling tools would help us see that `step_1()` takes one second, while `step_2()` takes two. In practice, this is usually much harder to intuit visually. To profile code with profvis, use the [`profvis()`](https://rdrr.io/pkg/profvis/man/profvis.html) function:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>result</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/pkg/profvis/man/profvis.html'>profvis</a></span><span class='o'>(</span><span class='nf'>slow_function</span><span class='o'>(</span><span class='o'>)</span><span class='o'>)</span></span></code></pre>

</div>

Printing the `result`ing object out will visualize the time different calls within `slow_function()` took:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>result</span></span></code></pre>

</div>

![A screenshot of profvis output. A stack of grey bars sit atop a timeline that ranges from zero to three seconds. The bottom rectangle of the stack is labeled "slow_function" and stretches across the whole timeline. Two rectangles labeled "step_1" and "step_2" lie on top of the bottom rectangle, where the first stretches one-third of the way across the timeline and the second covers the remaining two-thirds.](slow-function-profvis.png)

This output shows that, inside of `slow_function()`, `step_1()` took about a third of the total time and `step_2()` took two-thirds. All of the time in both of those functions was due to calling [`pause()`](https://rdrr.io/pkg/profvis/man/pause.html).

Profiling should be your first line of defense against slow-running code. Often, profiling will surface slowdowns in unexpected places, and solutions to address those slowdowns may have little to do with usage of tidy tools. To learn more about profiling, the [Measuring performance](https://adv-r.hadley.nz/perf-measure.html) chapter in Hadley Wickham's book [Advanced R](https://adv-r.hadley.nz/index.html) is a great place to start.

### bench

profvis is a powerful tool to surface code slowdowns. Often, though, it may not be immediately clear how to *fix* that slowdown. The bench package allows users to quickly test out how long different approaches to solving a problem take.

For example, say we want to take the sum of the numbers in a list, but we've identified via profiling that this operation is slowing our code down:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>numbers</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/list.html'>as.list</a></span><span class='o'>(</span><span class='m'>1</span><span class='o'>:</span><span class='m'>5</span><span class='o'>)</span></span>
<span></span>
<span><span class='nv'>numbers</span></span>
<span><span class='c'>#&gt; [[1]]</span></span>
<span><span class='c'>#&gt; [1] 1</span></span>
<span><span class='c'>#&gt; </span></span>
<span><span class='c'>#&gt; [[2]]</span></span>
<span><span class='c'>#&gt; [1] 2</span></span>
<span><span class='c'>#&gt; </span></span>
<span><span class='c'>#&gt; [[3]]</span></span>
<span><span class='c'>#&gt; [1] 3</span></span>
<span><span class='c'>#&gt; </span></span>
<span><span class='c'>#&gt; [[4]]</span></span>
<span><span class='c'>#&gt; [1] 4</span></span>
<span><span class='c'>#&gt; </span></span>
<span><span class='c'>#&gt; [[5]]</span></span>
<span><span class='c'>#&gt; [1] 5</span></span>
<span></span></code></pre>

</div>

One approach could be using the [`Reduce()`](https://rdrr.io/r/base/funprog.html) function:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://rdrr.io/r/base/funprog.html'>Reduce</a></span><span class='o'>(</span><span class='nv'>sum</span>, <span class='nv'>numbers</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; [1] 15</span></span>
<span></span></code></pre>

</div>

Another could involve converting to a vector with [`unlist()`](https://rdrr.io/r/base/unlist.html) and then using [`sum()`](https://rdrr.io/r/base/sum.html):

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://rdrr.io/r/base/sum.html'>sum</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/unlist.html'>unlist</a></span><span class='o'>(</span><span class='nv'>numbers</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; [1] 15</span></span>
<span></span></code></pre>

</div>

You may have some other ideas of how to solve this problem! How do we figure out which one is fastest, though? The [`bench::mark()`](http://bench.r-lib.org/reference/mark.html) function from bench takes in different proposals to solve the same problem and returns a tibble with information about how long they took (among other things.)

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>res</span> <span class='o'>&lt;-</span></span>
<span>  <span class='nf'>bench</span><span class='nf'>::</span><span class='nf'><a href='http://bench.r-lib.org/reference/mark.html'>mark</a></span><span class='o'>(</span></span>
<span>    approach_1 <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/funprog.html'>Reduce</a></span><span class='o'>(</span><span class='nv'>sum</span>, <span class='nv'>numbers</span><span class='o'>)</span>,</span>
<span>    approach_2 <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/sum.html'>sum</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/unlist.html'>unlist</a></span><span class='o'>(</span><span class='nv'>numbers</span><span class='o'>)</span><span class='o'>)</span></span>
<span>  <span class='o'>)</span></span>
<span></span>
<span><span class='nv'>res</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span> <span class='nf'><a href='https://dplyr.tidyverse.org/reference/select.html'>select</a></span><span class='o'>(</span><span class='nv'>expression</span>, <span class='nv'>median</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 2 × 2</span></span></span>
<span><span class='c'>#&gt;   expression   median</span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;bch:expr&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;bch:tm&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span> approach_1    2.3µs</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span> approach_2    492ns</span></span>
<span></span></code></pre>

</div>

The other nice part about [`bench::mark()`](http://bench.r-lib.org/reference/mark.html) is that it will check that each approach gives the same output, so that you don't mistakenly compare apples and oranges.

There are two important lessons to take in from this output:

-   The `sum(unlist())` approach was wicked fast compared to [`Reduce()`](https://rdrr.io/r/base/funprog.html).
-   Both of these expressions were fast. Even the slower of the two took 2.3µs---to put that in perspective, that expression could complete 435540 iterations in a second! Keeping this bigger picture in mind is always important when benchmarking; if code runs fast enough to not be an issue in practical situations, then it need not be optimized in favor of less readable or safe code.

The results of little experiments like this one can be surprising at first. Over time, though, you will develop intuition for the fastest way to solve problems you commonly solve, and will write fast code the first time around!

In this case, using [`Reduce()`](https://rdrr.io/r/base/funprog.html) means calling [`sum()`](https://rdrr.io/r/base/sum.html) many times, approximately once for each element of the list, and while [`sum()`](https://rdrr.io/r/base/sum.html) isn't particularly slow, calling an R function many times tends to have non-negligible overhead. With the `sum(unlist())` approach, there are only 2 R function calls---one for [`unlist()`](https://rdrr.io/r/base/unlist.html) and one for [`sum()`](https://rdrr.io/r/base/sum.html)---which both immediately drop into C code.

### vctrs

The problems I commonly solve---and possibly you as well, as a reader of this post---often involve lots of dplyr and tidyr. When profiling the tidymodels packages, I've come across many places where calls to dplyr and tidyr took more time than I'd like them to, but had a lot to learn about how to speed up those operations. *Enter the vctrs package!*

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://vctrs.r-lib.org/'>vctrs</a></span><span class='o'>)</span></span></code></pre>

</div>

If you use dplyr and tidyr like I do, turns out you're also a vctrs user! dplyr and tidyr rely on vctrs to handle all sorts of elementary operations behind the scenes, and the package is a core part of a tidy developer's toolkit. Taken together with some functions from the tibble package, these tools provide a super efficient, albeit bare-bones, alternative interface to common data manipulation tasks like [`filter()`](https://dplyr.tidyverse.org/reference/filter.html)ing and [`select()`](https://dplyr.tidyverse.org/reference/select.html)ing.

## Rewriting tidy code

For every performance improvement I make by rewriting dplyr and tidyr code to instead use vctrs and tibble, I make probably two or three simpler optimizations. [Tool-agnostic practices](https://adv-r.hadley.nz/perf-improve.html) such as reducing duplicated computations, implementing early returns where possible, and using vectorized implementations will likely take you far when optimizing R code. Profiling is your ground truth! When profiling indicates that otherwise well-factored code is slowed by tidy interfaces, though, all is not lost.

We'll demonstrate different ways to speed up tidy code using a version of the base R data frame `mtcars` converted to a tibble:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>mtcars_tbl</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://tibble.tidyverse.org/reference/as_tibble.html'>as_tibble</a></span><span class='o'>(</span><span class='nv'>mtcars</span>, rownames <span class='o'>=</span> <span class='s'>"make_model"</span><span class='o'>)</span></span>
<span></span>
<span><span class='nv'>mtcars_tbl</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 32 × 12</span></span></span>
<span><span class='c'>#&gt;    make_model    mpg   cyl  disp    hp  drat    wt  qsec    vs    am  gear  carb</span></span>
<span><span class='c'>#&gt;    <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>       <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 1</span> Mazda RX4    21       6  160    110  3.9   2.62  16.5     0     1     4     4</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 2</span> Mazda RX4 …  21       6  160    110  3.9   2.88  17.0     0     1     4     4</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 3</span> Datsun 710   22.8     4  108     93  3.85  2.32  18.6     1     1     4     1</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 4</span> Hornet 4 D…  21.4     6  258    110  3.08  3.22  19.4     1     0     3     1</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 5</span> Hornet Spo…  18.7     8  360    175  3.15  3.44  17.0     0     0     3     2</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 6</span> Valiant      18.1     6  225    105  2.76  3.46  20.2     1     0     3     1</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 7</span> Duster 360   14.3     8  360    245  3.21  3.57  15.8     0     0     3     4</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 8</span> Merc 240D    24.4     4  147.    62  3.69  3.19  20       1     0     4     2</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 9</span> Merc 230     22.8     4  141.    95  3.92  3.15  22.9     1     0     4     2</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>10</span> Merc 280     19.2     6  168.   123  3.92  3.44  18.3     1     0     4     4</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># ℹ 22 more rows</span></span></span>
<span></span></code></pre>

</div>

### One-for-one replacements

Many of the core functions in dplyr have alternatives in vctrs and tibble that can be quickly transitioned. There are a couple considerations associated with each, though, and some of them make piping a bit more awkward---most of the time, when I switch these out, I remove the pipe `%>%` as well.

#### `filter()`

The dplyr code:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>mtcars_tbl</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/filter.html'>filter</a></span><span class='o'>(</span><span class='nv'>hp</span> <span class='o'>&gt;</span> <span class='m'>100</span><span class='o'>)</span></span></code></pre>

</div>

...can be replaced by:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://vctrs.r-lib.org/reference/vec_slice.html'>vec_slice</a></span><span class='o'>(</span><span class='nv'>mtcars_tbl</span>, <span class='nv'>mtcars_tbl</span><span class='o'>$</span><span class='nv'>hp</span> <span class='o'>&gt;</span> <span class='m'>100</span><span class='o'>)</span></span></code></pre>

</div>

Note that the second argument that determines which rows to keep requires you to actually pass the column `mtcars_tbl$hp` rather than its reference `hp`. If you feel cozier with square brackets, you can also use `[.tbl_df`:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>mtcars_tbl</span><span class='o'>[</span><span class='nv'>mtcars_tbl</span><span class='o'>$</span><span class='nv'>hp</span> <span class='o'>&gt;</span> <span class='m'>100</span>, <span class='o'>]</span></span></code></pre>

</div>

`[.tbl_df` is the [method for subsetting with a single square bracket when applied to tibbles](https://tibble.tidyverse.org/reference/subsetting.html). Tibbles have their own methods for extracting and replacing subsets of data frames. They generally behave similarly to the analogous methods for `data.frame`s, but have small differences to improve consistency and safety.

The benchmarks for these different approaches are:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>res</span> <span class='o'>&lt;-</span></span>
<span>  <span class='nf'>bench</span><span class='nf'>::</span><span class='nf'><a href='http://bench.r-lib.org/reference/mark.html'>mark</a></span><span class='o'>(</span></span>
<span>    dplyr <span class='o'>=</span> <span class='nf'><a href='https://dplyr.tidyverse.org/reference/filter.html'>filter</a></span><span class='o'>(</span><span class='nv'>mtcars_tbl</span>, <span class='nv'>hp</span> <span class='o'>&gt;</span> <span class='m'>100</span><span class='o'>)</span>,</span>
<span>    vctrs <span class='o'>=</span> <span class='nf'><a href='https://vctrs.r-lib.org/reference/vec_slice.html'>vec_slice</a></span><span class='o'>(</span><span class='nv'>mtcars_tbl</span>, <span class='nv'>mtcars_tbl</span><span class='o'>$</span><span class='nv'>hp</span> <span class='o'>&gt;</span> <span class='m'>100</span><span class='o'>)</span>,</span>
<span>    `[.tbl_df` <span class='o'>=</span> <span class='nv'>mtcars_tbl</span><span class='o'>[</span><span class='nv'>mtcars_tbl</span><span class='o'>$</span><span class='nv'>hp</span> <span class='o'>&gt;</span> <span class='m'>100</span>, <span class='o'>]</span></span>
<span>  <span class='o'>)</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span></span>
<span>    <span class='nf'><a href='https://dplyr.tidyverse.org/reference/select.html'>select</a></span><span class='o'>(</span><span class='nv'>expression</span>, <span class='nv'>median</span><span class='o'>)</span></span>
<span></span>
<span><span class='nv'>res</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 3 × 2</span></span></span>
<span><span class='c'>#&gt;   expression   median</span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;bch:expr&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;bch:tm&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span> dplyr      291.02µs</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span> vctrs        4.63µs</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>3</span> [.tbl_df    23.86µs</span></span>
<span></span></code></pre>

</div>

The bigger picture of benchmarking is worth re-iterating here. While the `filter()` approach was by far the slowest expression of the three, it still only took 291µs---able to complete 3436 iterations in a second. If I'm interactively analyzing data, I won't even notice the difference in evaluation time between these expressions, let alone care about it; the benefits of expressiveness and safety that `filter()` provide far outweigh the drawback of this slowdown. If `filter()` is called 3436 times in the backend of a machine learning pipeline, though, these alternatives may be worth transitioning to.

Some examples of changes like this made to tidymodels packages: [tidymodels/parsnip#935](https://github.com/tidymodels/parsnip/pull/935), [tidymodels/parsnip#933](https://github.com/tidymodels/parsnip/pull/933), [tidymodels/parsnip#901](https://github.com/tidymodels/parsnip/pull/901).

#### `mutate()`

The dplyr code:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>mtcars_tbl</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://dplyr.tidyverse.org/reference/mutate.html'>mutate</a></span><span class='o'>(</span><span class='nv'>mtcars_tbl</span>, year <span class='o'>=</span> <span class='m'>1974L</span><span class='o'>)</span></span></code></pre>

</div>

...can be replaced by:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>mtcars_tbl</span><span class='o'>$</span><span class='nv'>year</span> <span class='o'>&lt;-</span> <span class='m'>1974L</span></span></code></pre>

</div>

...with benchmarks:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'>bench</span><span class='nf'>::</span><span class='nf'><a href='http://bench.r-lib.org/reference/mark.html'>mark</a></span><span class='o'>(</span></span>
<span>  dplyr <span class='o'>=</span> <span class='nf'><a href='https://dplyr.tidyverse.org/reference/mutate.html'>mutate</a></span><span class='o'>(</span><span class='nv'>mtcars_tbl</span>, year <span class='o'>=</span> <span class='m'>1974L</span><span class='o'>)</span>,</span>
<span>  `$&lt;-.tbl_df` <span class='o'>=</span> <span class='o'>&#123;</span><span class='nv'>mtcars_tbl</span><span class='o'>$</span><span class='nv'>year</span> <span class='o'>&lt;-</span> <span class='m'>1974L</span>; <span class='nv'>mtcars_tbl</span><span class='o'>&#125;</span></span>
<span><span class='o'>)</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/select.html'>select</a></span><span class='o'>(</span><span class='nv'>expression</span>, <span class='nv'>median</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 2 × 2</span></span></span>
<span><span class='c'>#&gt;   expression   median</span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;bch:expr&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;bch:tm&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span> dplyr       303.7µs</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span> $&lt;-.tbl_df   13.2µs</span></span>
<span></span></code></pre>

</div>

By default, both `mutate()` and `$<-.tbl_df` append the new column at the right-most position. The `.before` and `.after` arguments to `mutate()` are a really nice interface to adjust that behavior, and I miss it often when using `$<-.tbl_df`. In those cases, `select()` and its alternatives (see next section!) can be helpful.

Some examples of changes like this made to tidymodels packages: [tidymodels/parsnip#933](https://github.com/tidymodels/parsnip/pull/933), [tidymodels/parsnip#921](https://github.com/tidymodels/parsnip/pull/921), and [tidymodels/parsnip#901](https://github.com/tidymodels/parsnip/pull/901).

#### `select()`

The dplyr code:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://dplyr.tidyverse.org/reference/select.html'>select</a></span><span class='o'>(</span><span class='nv'>mtcars_tbl</span>, <span class='nv'>hp</span><span class='o'>)</span></span></code></pre>

</div>

...can be replaced by:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>mtcars_tbl</span><span class='o'>[</span><span class='s'>"hp"</span><span class='o'>]</span></span></code></pre>

</div>

...with benchmarks:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'>bench</span><span class='nf'>::</span><span class='nf'><a href='http://bench.r-lib.org/reference/mark.html'>mark</a></span><span class='o'>(</span></span>
<span>  dplyr <span class='o'>=</span> <span class='nf'><a href='https://dplyr.tidyverse.org/reference/select.html'>select</a></span><span class='o'>(</span><span class='nv'>mtcars_tbl</span>, <span class='nv'>hp</span><span class='o'>)</span>,</span>
<span>  `[.tbl_df` <span class='o'>=</span> <span class='nv'>mtcars_tbl</span><span class='o'>[</span><span class='s'>"hp"</span><span class='o'>]</span></span>
<span><span class='o'>)</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/select.html'>select</a></span><span class='o'>(</span><span class='nv'>expression</span>, <span class='nv'>median</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 2 × 2</span></span></span>
<span><span class='c'>#&gt;   expression   median</span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;bch:expr&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;bch:tm&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span> dplyr       450.3µs</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span> [.tbl_df     8.12µs</span></span>
<span></span></code></pre>

</div>

Of course, the nice part about `select()`, and something we make use of in tidymodels quite a bit, is tidyselect. I've often found that we lean heavily on selecting via external vectors, i.e. character vectors, i.e. things that can be inputted to `[.tbl_df` directly. That is:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>cols</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"hp"</span>, <span class='s'>"wt"</span><span class='o'>)</span></span>
<span></span>
<span><span class='nf'>bench</span><span class='nf'>::</span><span class='nf'><a href='http://bench.r-lib.org/reference/mark.html'>mark</a></span><span class='o'>(</span></span>
<span>  dplyr <span class='o'>=</span> <span class='nf'><a href='https://dplyr.tidyverse.org/reference/select.html'>select</a></span><span class='o'>(</span><span class='nv'>mtcars_tbl</span>, <span class='nf'><a href='https://tidyselect.r-lib.org/reference/all_of.html'>all_of</a></span><span class='o'>(</span><span class='nv'>cols</span><span class='o'>)</span><span class='o'>)</span>,</span>
<span>  `[.tbl_df` <span class='o'>=</span> <span class='nv'>mtcars_tbl</span><span class='o'>[</span><span class='nv'>cols</span><span class='o'>]</span></span>
<span><span class='o'>)</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span> </span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/select.html'>select</a></span><span class='o'>(</span><span class='nv'>expression</span>, <span class='nv'>median</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 2 × 2</span></span></span>
<span><span class='c'>#&gt;   expression   median</span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;bch:expr&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;bch:tm&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span> dplyr       455.9µs</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span> [.tbl_df      8.4µs</span></span>
<span></span></code></pre>

</div>

Note that `[.tbl_df` always sets `drop = FALSE`.

`[.tbl_df` can also be used as an alternative interface to `select()` or `relocate()` with a `.before` or `.after` argument. For instance, to place that column `year` we made in the last section as the second column, we could write:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>left_cols</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"make_model"</span>, <span class='s'>"year"</span><span class='o'>)</span></span>
<span></span>
<span><span class='nv'>mtcars_tbl</span><span class='o'>[</span></span>
<span>  <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='nv'>left_cols</span>, </span>
<span>    <span class='nf'><a href='https://generics.r-lib.org/reference/setops.html'>setdiff</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/colnames.html'>colnames</a></span><span class='o'>(</span><span class='nv'>mtcars_tbl</span><span class='o'>)</span>, <span class='nv'>left_cols</span><span class='o'>)</span></span>
<span>  <span class='o'>)</span></span>
<span><span class='o'>]</span></span></code></pre>

</div>

No, thanks, but it is a good bit faster than tidyselect-based alternatives:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'>bench</span><span class='nf'>::</span><span class='nf'><a href='http://bench.r-lib.org/reference/mark.html'>mark</a></span><span class='o'>(</span></span>
<span>  mutate <span class='o'>=</span> <span class='nf'><a href='https://dplyr.tidyverse.org/reference/mutate.html'>mutate</a></span><span class='o'>(</span><span class='nv'>mtcars_tbl</span>, year <span class='o'>=</span> <span class='m'>1974L</span>, .after <span class='o'>=</span> <span class='nv'>make_model</span><span class='o'>)</span>,</span>
<span>  relocate <span class='o'>=</span> <span class='nf'><a href='https://dplyr.tidyverse.org/reference/relocate.html'>relocate</a></span><span class='o'>(</span><span class='nv'>mtcars_tbl</span>, <span class='nv'>year</span>, .after <span class='o'>=</span> <span class='nv'>make_model</span><span class='o'>)</span>,</span>
<span>  `[.tbl_df` <span class='o'>=</span> </span>
<span>      <span class='nv'>mtcars_tbl</span><span class='o'>[</span></span>
<span>        <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='nv'>left_cols</span>, </span>
<span>          <span class='nf'><a href='https://rdrr.io/r/base/colnames.html'>colnames</a></span><span class='o'>(</span><span class='nv'>mtcars_tbl</span><span class='o'>[</span><span class='o'>!</span><span class='nf'><a href='https://rdrr.io/r/base/colnames.html'>colnames</a></span><span class='o'>(</span><span class='nv'>mtcars_tbl</span><span class='o'>)</span> <span class='o'><a href='https://rdrr.io/r/base/match.html'>%in%</a></span> <span class='nv'>left_cols</span><span class='o'>]</span><span class='o'>)</span></span>
<span>        <span class='o'>)</span></span>
<span>      <span class='o'>]</span>,</span>
<span>  check <span class='o'>=</span> <span class='kc'>FALSE</span></span>
<span><span class='o'>)</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span> </span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/select.html'>select</a></span><span class='o'>(</span><span class='nv'>expression</span>, <span class='nv'>median</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 3 × 2</span></span></span>
<span><span class='c'>#&gt;   expression   median</span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;bch:expr&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;bch:tm&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span> mutate       1.13ms</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span> relocate   689.23µs</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>3</span> [.tbl_df    19.35µs</span></span>
<span></span></code></pre>

</div>

Some examples of changes like this made to tidymodels packages: [tidymodels/parsnip#935](https://github.com/tidymodels/parsnip/pull/935), [tidymodels/parsnip#933](https://github.com/tidymodels/parsnip/pull/933), [tidymodels/parsnip#921](https://github.com/tidymodels/parsnip/pull/921), and [tidymodels/tune#635](https://github.com/tidymodels/tune/pull/635).

#### `pull()`

The dplyr code:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://dplyr.tidyverse.org/reference/pull.html'>pull</a></span><span class='o'>(</span><span class='nv'>mtcars_tbl</span>, <span class='nv'>hp</span><span class='o'>)</span></span></code></pre>

</div>

...can be replaced by:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>mtcars_tbl</span><span class='o'>$</span><span class='nv'>hp</span></span></code></pre>

</div>

...or:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>mtcars_tbl</span><span class='o'>[[</span><span class='s'>"hp"</span><span class='o'>]</span><span class='o'>]</span></span></code></pre>

</div>

Note that, for tibbles, `$` will raise a warning if the subsetted column doesn't exist, while `[[` will silently return `NULL`.

With benchmarks:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'>bench</span><span class='nf'>::</span><span class='nf'><a href='http://bench.r-lib.org/reference/mark.html'>mark</a></span><span class='o'>(</span></span>
<span>  dplyr <span class='o'>=</span> <span class='nf'><a href='https://dplyr.tidyverse.org/reference/pull.html'>pull</a></span><span class='o'>(</span><span class='nv'>mtcars_tbl</span>, <span class='nv'>hp</span><span class='o'>)</span>,</span>
<span>  `$.tbl_df` <span class='o'>=</span> <span class='nv'>mtcars_tbl</span><span class='o'>$</span><span class='nv'>hp</span>,</span>
<span>  `[[.tbl_df` <span class='o'>=</span> <span class='nv'>mtcars_tbl</span><span class='o'>[[</span><span class='s'>"hp"</span><span class='o'>]</span><span class='o'>]</span></span>
<span><span class='o'>)</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/select.html'>select</a></span><span class='o'>(</span><span class='nv'>expression</span>, <span class='nv'>median</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 3 × 2</span></span></span>
<span><span class='c'>#&gt;   expression   median</span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;bch:expr&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;bch:tm&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span> dplyr          91µs</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span> $.tbl_df      615ns</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>3</span> [[.tbl_df     2.3µs</span></span>
<span></span></code></pre>

</div>

Some examples of changes like this made to tidymodels packages: [tidymodels/parsnip#935](https://github.com/tidymodels/parsnip/pull/935) and [tidymodels/tune#635](https://github.com/tidymodels/tune/pull/635).

#### `bind_*()`

`bind_rows()` and `bind_cols()` can be substituted for `vec_rbind()` and `vec_cbind()`, respectively. First, row-binding:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'>bench</span><span class='nf'>::</span><span class='nf'><a href='http://bench.r-lib.org/reference/mark.html'>mark</a></span><span class='o'>(</span></span>
<span>  dplyr <span class='o'>=</span> <span class='nf'><a href='https://dplyr.tidyverse.org/reference/bind_rows.html'>bind_rows</a></span><span class='o'>(</span><span class='nv'>mtcars_tbl</span>, <span class='nv'>mtcars_tbl</span><span class='o'>)</span>,</span>
<span>  vctrs <span class='o'>=</span> <span class='nf'><a href='https://vctrs.r-lib.org/reference/vec_bind.html'>vec_rbind</a></span><span class='o'>(</span><span class='nv'>mtcars_tbl</span>, <span class='nv'>mtcars_tbl</span><span class='o'>)</span></span>
<span><span class='o'>)</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/select.html'>select</a></span><span class='o'>(</span><span class='nv'>expression</span>, <span class='nv'>median</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 2 × 2</span></span></span>
<span><span class='c'>#&gt;   expression   median</span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;bch:expr&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;bch:tm&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span> dplyr        44.2µs</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span> vctrs        14.4µs</span></span>
<span></span></code></pre>

</div>

As for column-binding:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>tbl</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://tibble.tidyverse.org/reference/tibble.html'>tibble</a></span><span class='o'>(</span>year <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/rep.html'>rep</a></span><span class='o'>(</span><span class='m'>1974L</span>, <span class='nf'><a href='https://rdrr.io/r/base/nrow.html'>nrow</a></span><span class='o'>(</span><span class='nv'>mtcars_tbl</span><span class='o'>)</span><span class='o'>)</span><span class='o'>)</span></span>
<span></span>
<span><span class='nf'>bench</span><span class='nf'>::</span><span class='nf'><a href='http://bench.r-lib.org/reference/mark.html'>mark</a></span><span class='o'>(</span></span>
<span>  dplyr <span class='o'>=</span> <span class='nf'><a href='https://dplyr.tidyverse.org/reference/bind_cols.html'>bind_cols</a></span><span class='o'>(</span><span class='nv'>mtcars_tbl</span>, <span class='nv'>tbl</span><span class='o'>)</span>,</span>
<span>  vctrs <span class='o'>=</span> <span class='nf'><a href='https://vctrs.r-lib.org/reference/vec_bind.html'>vec_cbind</a></span><span class='o'>(</span><span class='nv'>mtcars_tbl</span>, <span class='nv'>tbl</span><span class='o'>)</span></span>
<span><span class='o'>)</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/select.html'>select</a></span><span class='o'>(</span><span class='nv'>expression</span>, <span class='nv'>median</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 2 × 2</span></span></span>
<span><span class='c'>#&gt;   expression   median</span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;bch:expr&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;bch:tm&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span> dplyr        61.3µs</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span> vctrs        26.6µs</span></span>
<span></span></code></pre>

</div>

Some examples of changes like this made to tidymodels packages: [tidymodels/tune#636](https://github.com/tidymodels/tune/pull/636).

#### Grouping

In general, the introduction of groups makes these substitutions much trickier. In those cases, it's likely best to weigh (via profiling) how significant the slowdown is and, if it's not too bad, opt not to make any changes. For code that relies on `group_by()` and sees heavy traffic, see `vctrs::list_unchop()`, `vctrs::vec_chop()`, and `vctrs::vec_rep_each()`.

### Tibbles

Tibbles are great, and I don't want to interface with any other data frame-y thing. Some notes:

-   `as_tibble()` on a tibble is not "free":

    <div class="highlight">

    <pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'>bench</span><span class='nf'>::</span><span class='nf'><a href='http://bench.r-lib.org/reference/mark.html'>mark</a></span><span class='o'>(</span></span>
     <span>  on_tbl_df <span class='o'>=</span> <span class='nf'><a href='https://tibble.tidyverse.org/reference/as_tibble.html'>as_tibble</a></span><span class='o'>(</span><span class='nv'>mtcars_tbl</span><span class='o'>)</span>,</span>
     <span>  on_data.frame <span class='o'>=</span> <span class='nf'><a href='https://tibble.tidyverse.org/reference/as_tibble.html'>as_tibble</a></span><span class='o'>(</span><span class='nv'>mtcars</span>, rownames <span class='o'>=</span> <span class='s'>"make_model"</span><span class='o'>)</span></span>
     <span><span class='o'>)</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span> </span>
     <span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/select.html'>select</a></span><span class='o'>(</span><span class='nv'>expression</span>, <span class='nv'>median</span><span class='o'>)</span></span>
     <span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 2 × 2</span></span></span>
     <span><span class='c'>#&gt;   expression      median</span></span>
     <span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;bch:expr&gt;</span>    <span style='color: #555555; font-style: italic;'>&lt;bch:tm&gt;</span></span></span>
     <span><span class='c'>#&gt; <span style='color: #555555;'>1</span> on_tbl_df       51.3µs</span></span>
     <span><span class='c'>#&gt; <span style='color: #555555;'>2</span> on_data.frame  244.5µs</span></span>
     <span></span></code></pre>

    </div>

-   Building a tibble from scratch using `tibble()` actually takes quite a while as well. `tibble()` handles vector recycling and name checking, builds columns sequentially, all that good stuff. If you need that, use `tibble()`, but if you're building a tibble from well-understood inputs, use `new_tibble()`, which minimizes validation checks. For a middle ground between `tibble()` and `new_tibble(list())` in terms of both performance and safety, use the `df_list()` function from the vctrs package in place of `list()`.

    <div class="highlight">

    <pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'>bench</span><span class='nf'>::</span><span class='nf'><a href='http://bench.r-lib.org/reference/mark.html'>mark</a></span><span class='o'>(</span></span>
     <span>  tibble <span class='o'>=</span> <span class='nf'><a href='https://tibble.tidyverse.org/reference/tibble.html'>tibble</a></span><span class='o'>(</span>a <span class='o'>=</span> <span class='m'>1</span><span class='o'>:</span><span class='m'>2</span>, b <span class='o'>=</span> <span class='m'>3</span><span class='o'>:</span><span class='m'>4</span><span class='o'>)</span>,</span>
     <span>  new_tibble_df_list <span class='o'>=</span> <span class='nf'><a href='https://tibble.tidyverse.org/reference/new_tibble.html'>new_tibble</a></span><span class='o'>(</span><span class='nf'><a href='https://vctrs.r-lib.org/reference/df_list.html'>df_list</a></span><span class='o'>(</span>a <span class='o'>=</span> <span class='m'>1</span><span class='o'>:</span><span class='m'>2</span>, b <span class='o'>=</span> <span class='m'>3</span><span class='o'>:</span><span class='m'>4</span><span class='o'>)</span>, nrow <span class='o'>=</span> <span class='m'>2</span><span class='o'>)</span>,</span>
     <span>  new_tibble_list <span class='o'>=</span> <span class='nf'><a href='https://tibble.tidyverse.org/reference/new_tibble.html'>new_tibble</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span>a <span class='o'>=</span> <span class='m'>1</span><span class='o'>:</span><span class='m'>2</span>, b <span class='o'>=</span> <span class='m'>3</span><span class='o'>:</span><span class='m'>4</span><span class='o'>)</span>, nrow <span class='o'>=</span> <span class='m'>2</span><span class='o'>)</span></span>
     <span><span class='o'>)</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span> </span>
     <span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/select.html'>select</a></span><span class='o'>(</span><span class='nv'>expression</span>, <span class='nv'>median</span><span class='o'>)</span></span>
     <span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 3 × 2</span></span></span>
     <span><span class='c'>#&gt;   expression           median</span></span>
     <span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;bch:expr&gt;</span>         <span style='color: #555555; font-style: italic;'>&lt;bch:tm&gt;</span></span></span>
     <span><span class='c'>#&gt; <span style='color: #555555;'>1</span> tibble             170.07µs</span></span>
     <span><span class='c'>#&gt; <span style='color: #555555;'>2</span> new_tibble_df_list  16.97µs</span></span>
     <span><span class='c'>#&gt; <span style='color: #555555;'>3</span> new_tibble_list      5.08µs</span></span>
     <span></span></code></pre>

    </div>

Note that `new_tibble()` *will not check the lengths of its inputs.* Carry out simple recycling yourself, and be sure to use the `nrow` argument to get basic length checks.

Some examples of changes like this made to tidymodels packages: [tidymodels/parsnip#945](https://github.com/tidymodels/parsnip/pull/932), [tidymodels/parsnip#934](https://github.com/tidymodels/parsnip/pull/934), [tidymodels/parsnip#929](https://github.com/tidymodels/parsnip/pull/929), [tidymodels/parsnip#923](https://github.com/tidymodels/parsnip/pull/923), [tidymodels/parsnip#902](https://github.com/tidymodels/parsnip/pull/902), [tidymodels/dials#277](https://github.com/tidymodels/dials/pull/277), and [tidymodels/tune#637](https://github.com/tidymodels/tune/pull/637).

### Becoming join-critical

Two truths:

-   dplyr joins are a remarkably safe and powerful way to synthesize data sources.

-   One ought to ask themselves "does this really need to be a join?" when combining data sources in package code.

Some ways to intuit about join efficiency:

-   If this join happens multiple times, is it possible to express it as one join and then subset it when needed? i.e. if a join happens inside of a loop but the elements of the join are not indices of the loop, it's likely possible to pull that join outside of the loop and then `vec_slice()` its results inside of the loop.

-   Am I using the complete outputted join result or just a portion? If I end up only making use of column names, or values in one column, or pairings between two columns, I may be able to instead use `$.tbl_df` or `[.tbl_df`.

As an example, imagine we have another tibble that tells us additional information about the `make_model`s that I've driven:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>my_cars</span> <span class='o'>&lt;-</span> </span>
<span>  <span class='nf'><a href='https://tibble.tidyverse.org/reference/tibble.html'>tibble</a></span><span class='o'>(</span></span>
<span>    make_model <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"Honda Civic"</span>, <span class='s'>"Subaru Forester"</span><span class='o'>)</span>,</span>
<span>    color <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"Grey"</span>, <span class='s'>"White"</span><span class='o'>)</span></span>
<span>  <span class='o'>)</span></span>
<span></span>
<span><span class='nv'>my_cars</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 2 × 2</span></span></span>
<span><span class='c'>#&gt;   make_model      color</span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>           <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span> Honda Civic     Grey </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span> Subaru Forester White</span></span>
<span></span></code></pre>

</div>

I *could* use a join to subset down to cars in `mtcars_tbl` and add this information on the cars I've driven:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://dplyr.tidyverse.org/reference/mutate-joins.html'>inner_join</a></span><span class='o'>(</span><span class='nv'>mtcars_tbl</span>, <span class='nv'>my_cars</span>, <span class='s'>"make_model"</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 1 × 13</span></span></span>
<span><span class='c'>#&gt;   make_model    mpg   cyl  disp    hp  drat    wt  qsec    vs    am  gear  carb</span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>       <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span> Honda Civic  30.4     4  75.7    52  4.93  1.62  18.5     1     1     4     2</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># ℹ 1 more variable: color &lt;chr&gt;</span></span></span>
<span></span></code></pre>

</div>

Another way to express this, though, if I can safely assume that each of my cars would have only one or zero matches in `mtcars_tbl`, is to find entries in `mtcars_tbl$make_model` that match entries in `my_cars$make_model`, subset down to those matches, and then bind columns:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>supplement_my_cars</span> <span class='o'>&lt;-</span> <span class='kr'>function</span><span class='o'>(</span><span class='o'>)</span> <span class='o'>&#123;</span></span>
<span>  <span class='c'># locate matches, assuming only 0 or 1 matches possible</span></span>
<span>  <span class='nv'>loc</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://vctrs.r-lib.org/reference/vec_match.html'>vec_match</a></span><span class='o'>(</span><span class='nv'>my_cars</span><span class='o'>$</span><span class='nv'>make_model</span>, <span class='nv'>mtcars_tbl</span><span class='o'>$</span><span class='nv'>make_model</span><span class='o'>)</span></span>
<span>  </span>
<span>  <span class='c'># keep only the matches</span></span>
<span>  <span class='nv'>loc_mine</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/which.html'>which</a></span><span class='o'>(</span><span class='o'>!</span><span class='nf'><a href='https://rdrr.io/r/base/NA.html'>is.na</a></span><span class='o'>(</span><span class='nv'>loc</span><span class='o'>)</span><span class='o'>)</span></span>
<span>  <span class='nv'>loc_mtcars</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://vctrs.r-lib.org/reference/vec_slice.html'>vec_slice</a></span><span class='o'>(</span><span class='nv'>loc</span>, <span class='o'>!</span><span class='nf'><a href='https://rdrr.io/r/base/NA.html'>is.na</a></span><span class='o'>(</span><span class='nv'>loc</span><span class='o'>)</span><span class='o'>)</span></span>
<span>  </span>
<span>  <span class='c'># drop duplicated join column</span></span>
<span>  <span class='nv'>my_cars_join</span> <span class='o'>&lt;-</span> <span class='nv'>my_cars</span><span class='o'>[</span><span class='nf'><a href='https://generics.r-lib.org/reference/setops.html'>setdiff</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/names.html'>names</a></span><span class='o'>(</span><span class='nv'>my_cars</span><span class='o'>)</span>, <span class='s'>"make_model"</span><span class='o'>)</span><span class='o'>]</span></span>
<span></span>
<span>  <span class='nf'><a href='https://vctrs.r-lib.org/reference/vec_bind.html'>vec_cbind</a></span><span class='o'>(</span></span>
<span>    <span class='nf'><a href='https://vctrs.r-lib.org/reference/vec_slice.html'>vec_slice</a></span><span class='o'>(</span><span class='nv'>mtcars_tbl</span>, <span class='nv'>loc_mtcars</span><span class='o'>)</span>,</span>
<span>    <span class='nf'><a href='https://vctrs.r-lib.org/reference/vec_slice.html'>vec_slice</a></span><span class='o'>(</span><span class='nv'>my_cars_join</span>, <span class='nv'>loc_mine</span><span class='o'>)</span></span>
<span>  <span class='o'>)</span></span>
<span><span class='o'>&#125;</span></span>
<span></span>
<span><span class='nf'>supplement_my_cars</span><span class='o'>(</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 1 × 13</span></span></span>
<span><span class='c'>#&gt;   make_model    mpg   cyl  disp    hp  drat    wt  qsec    vs    am  gear  carb</span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>       <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span> Honda Civic  30.4     4  75.7    52  4.93  1.62  18.5     1     1     4     2</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># ℹ 1 more variable: color &lt;chr&gt;</span></span></span>
<span></span></code></pre>

</div>

This is indeed quite a bit faster:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'>bench</span><span class='nf'>::</span><span class='nf'><a href='http://bench.r-lib.org/reference/mark.html'>mark</a></span><span class='o'>(</span></span>
<span>  inner_join <span class='o'>=</span> <span class='nf'><a href='https://dplyr.tidyverse.org/reference/mutate-joins.html'>inner_join</a></span><span class='o'>(</span><span class='nv'>mtcars_tbl</span>, <span class='nv'>my_cars</span>, <span class='s'>"make_model"</span><span class='o'>)</span>,</span>
<span>  manual <span class='o'>=</span> <span class='nf'>supplement_my_cars</span><span class='o'>(</span><span class='o'>)</span></span>
<span><span class='o'>)</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/select.html'>select</a></span><span class='o'>(</span><span class='nv'>expression</span>, <span class='nv'>median</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 2 × 2</span></span></span>
<span><span class='c'>#&gt;   expression   median</span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;bch:expr&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;bch:tm&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span> inner_join  464.8µs</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span> manual       51.3µs</span></span>
<span></span></code></pre>

</div>

At the same time, if this problem were even a little bit more complex, e.g. if there were possibly multiple matching `make_models` in `mtcars_tbl` or if I wanted to keep all rows in `mtcars_tbl` regardless of whether I had driven the car, then expressing this join with more bare-bones operations quickly becomes less readable and more error-prone. In those cases, too, joins in dplyr have a relatively small amount of overhead when compared to the vctrs backends underlying them. So, optimize carefully!

Some examples of writing out joins in tidymodels packages: [tidymodels/parsnip#932](https://github.com/tidymodels/parsnip/pull/932), [tidymodels/parsnip#931](https://github.com/tidymodels/parsnip/pull/931), [tidymodels/parsnip#921](https://github.com/tidymodels/parsnip/pull/921), and [tidymodels/recipes#1121](https://github.com/tidymodels/recipes/pull/1121).

### `nest()`

`nest()`s are subject to similar considerations as joins. When they allow for expressive or principled user interfaces, use them, but manipulate them sparingly in backends. Writing out `nest()` calls *can* result in substantial speedups, though, and the process is not quite as gnarly as writing out a join. For code that relies on `nest()`s and sees heavy traffic, rewriting with vctrs may be worth the effort.

For example, consider nesting `mtcars_tbl` by `cyl`:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://tidyr.tidyverse.org/reference/nest.html'>nest</a></span><span class='o'>(</span><span class='nv'>mtcars_tbl</span>, .by <span class='o'>=</span> <span class='nv'>cyl</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 3 × 2</span></span></span>
<span><span class='c'>#&gt;     cyl data              </span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;list&gt;</span>            </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span>     6 <span style='color: #555555;'>&lt;tibble [7 × 11]&gt;</span> </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span>     4 <span style='color: #555555;'>&lt;tibble [11 × 11]&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>3</span>     8 <span style='color: #555555;'>&lt;tibble [14 × 11]&gt;</span></span></span>
<span></span></code></pre>

</div>

For some basic nests, like nesting by values in one column, `vec_split()` can do the trick.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>res</span> <span class='o'>&lt;-</span> </span>
<span>  <span class='nf'><a href='https://vctrs.r-lib.org/reference/vec_split.html'>vec_split</a></span><span class='o'>(</span></span>
<span>    x <span class='o'>=</span> <span class='nv'>mtcars_tbl</span><span class='o'>[</span><span class='o'>!</span><span class='nf'><a href='https://rdrr.io/r/base/colnames.html'>colnames</a></span><span class='o'>(</span><span class='nv'>mtcars_tbl</span><span class='o'>)</span> <span class='o'>==</span> <span class='s'>"cyl"</span><span class='o'>]</span>,</span>
<span>    by <span class='o'>=</span> <span class='nv'>mtcars_tbl</span><span class='o'>$</span><span class='nv'>cyl</span></span>
<span>  <span class='o'>)</span></span>
<span></span>
<span><span class='nf'><a href='https://tibble.tidyverse.org/reference/new_tibble.html'>new_tibble</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span>cyl <span class='o'>=</span> <span class='nv'>res</span><span class='o'>$</span><span class='nv'>key</span>, data <span class='o'>=</span> <span class='nv'>res</span><span class='o'>$</span><span class='nv'>val</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 3 × 2</span></span></span>
<span><span class='c'>#&gt;     cyl data              </span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;list&gt;</span>            </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span>     6 <span style='color: #555555;'>&lt;tibble [7 × 11]&gt;</span> </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span>     4 <span style='color: #555555;'>&lt;tibble [11 × 11]&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>3</span>     8 <span style='color: #555555;'>&lt;tibble [14 × 11]&gt;</span></span></span>
<span></span></code></pre>

</div>

The performance improvement in these situations can be quite substantial:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'>bench</span><span class='nf'>::</span><span class='nf'><a href='http://bench.r-lib.org/reference/mark.html'>mark</a></span><span class='o'>(</span></span>
<span>  nest <span class='o'>=</span> <span class='nf'><a href='https://tidyr.tidyverse.org/reference/nest.html'>nest</a></span><span class='o'>(</span><span class='nv'>mtcars_tbl</span>, .by <span class='o'>=</span> <span class='nv'>cyl</span><span class='o'>)</span>,</span>
<span>  vctrs <span class='o'>=</span> <span class='o'>&#123;</span></span>
<span>    <span class='nv'>res</span> <span class='o'>&lt;-</span></span>
<span>      <span class='nf'><a href='https://vctrs.r-lib.org/reference/vec_split.html'>vec_split</a></span><span class='o'>(</span></span>
<span>        x <span class='o'>=</span> <span class='nv'>mtcars_tbl</span><span class='o'>[</span><span class='o'>!</span><span class='nf'><a href='https://rdrr.io/r/base/colnames.html'>colnames</a></span><span class='o'>(</span><span class='nv'>mtcars_tbl</span><span class='o'>)</span> <span class='o'>==</span> <span class='s'>"cyl"</span><span class='o'>]</span>,</span>
<span>        by <span class='o'>=</span> <span class='nv'>mtcars_tbl</span><span class='o'>$</span><span class='nv'>cyl</span></span>
<span>      <span class='o'>)</span></span>
<span>    <span class='nf'><a href='https://tibble.tidyverse.org/reference/new_tibble.html'>new_tibble</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span>cyl <span class='o'>=</span> <span class='nv'>res</span><span class='o'>$</span><span class='nv'>key</span>, data <span class='o'>=</span> <span class='nv'>res</span><span class='o'>$</span><span class='nv'>val</span><span class='o'>)</span><span class='o'>)</span></span>
<span>  <span class='o'>&#125;</span></span>
<span><span class='o'>)</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/select.html'>select</a></span><span class='o'>(</span><span class='nv'>expression</span>, <span class='nv'>median</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 2 × 2</span></span></span>
<span><span class='c'>#&gt;   expression   median</span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;bch:expr&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;bch:tm&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span> nest         1.69ms</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span> vctrs       23.45µs</span></span>
<span></span></code></pre>

</div>

More complex nests require a good bit of facility with the vctrs package. `vec_split()`, `list_unchop()`, and `vec_chop()` are all good places to start, and these examples of writing out nests in tidymodels packages make use of other vctrs patterns: [tidymodels/tune#657](https://github.com/tidymodels/tune/pull/657), [tidymodels/tune#657](https://github.com/tidymodels/tune/pull/656), [tidymodels/tune#640](https://github.com/tidymodels/tune/pull/640), and [tidymodels/recipes#1121](https://github.com/tidymodels/recipes/pull/1121).

### Combining strings

The glue package is super helpful for writing expressive and correct strings with data, though it is quite a bit slower than `paste0()`. At the same time, `paste0()` has some tricky recycling behavior. For a middle ground in terms of both performance and safety, this short wrapper has been quite helpful:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>vec_paste0</span> <span class='o'>&lt;-</span> <span class='kr'>function</span> <span class='o'>(</span><span class='nv'>...</span><span class='o'>)</span> <span class='o'>&#123;</span></span>
<span>  <span class='nv'>args</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://vctrs.r-lib.org/reference/vec_recycle.html'>vec_recycle_common</a></span><span class='o'>(</span><span class='nv'>...</span><span class='o'>)</span></span>
<span>  <span class='nf'><a href='https://rlang.r-lib.org/reference/exec.html'>exec</a></span><span class='o'>(</span><span class='nv'>paste0</span>, <span class='o'>!</span><span class='o'>!</span><span class='o'>!</span><span class='nv'>args</span><span class='o'>)</span></span>
<span><span class='o'>&#125;</span></span></code></pre>

</div>

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>name</span> <span class='o'>&lt;-</span> <span class='s'>"Simon"</span></span>
<span></span>
<span><span class='nf'>bench</span><span class='nf'>::</span><span class='nf'><a href='http://bench.r-lib.org/reference/mark.html'>mark</a></span><span class='o'>(</span></span>
<span>  glue <span class='o'>=</span> <span class='nf'>glue</span><span class='nf'>::</span><span class='nf'><a href='https://glue.tidyverse.org/reference/glue.html'>glue</a></span><span class='o'>(</span><span class='s'>"My name is &#123;name&#125;."</span><span class='o'>)</span>,</span>
<span>  vec_paste0 <span class='o'>=</span> <span class='nf'>vec_paste0</span><span class='o'>(</span><span class='s'>"My name is "</span>, <span class='nv'>name</span>, <span class='s'>"."</span><span class='o'>)</span>,</span>
<span>  paste0 <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/paste.html'>paste0</a></span><span class='o'>(</span><span class='s'>"My name is "</span>, <span class='nv'>name</span>, <span class='s'>"."</span><span class='o'>)</span>,</span>
<span>  check <span class='o'>=</span> <span class='kc'>FALSE</span></span>
<span><span class='o'>)</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span> </span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/select.html'>select</a></span><span class='o'>(</span><span class='nv'>expression</span>, <span class='nv'>median</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 3 × 2</span></span></span>
<span><span class='c'>#&gt;   expression   median</span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;bch:expr&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;bch:tm&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span> glue        39.48µs</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span> vec_paste0   3.94µs</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>3</span> paste0     861.01ns</span></span>
<span></span></code></pre>

</div>

My rule of thumb is to use `glue()` for errors, when the function will stop executing anyway. For simple pastes that are intended to be called repeatedly, use `vec_paste0()`. There's a lot of gray area in between those two contexts---intuit (or profile) as you will.

## Wrapping up

This post contains a number of tricks that offer especially performant alternatives to interfaces from dplyr and tidyr. Making use of these backend tools is certainly a trade-off; what is gained in computational performance is also offset by a decline in readability and safety, so developers ought to consider carefully when optimizations are worth the effort and risk.

Thanks to Davis Vaughan for the guidance in getting started with vctrs. Also, thanks to both Davis Vaughan and Lionel Henry for their efforts in helping the tidymodels team address the bottlenecks that have been surfaced by our work on optimizations in tidyverse packages.

