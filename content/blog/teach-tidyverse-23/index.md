---
output: hugodown::hugo_document
slug: teach-tidyverse-23
title: Teaching the tidyverse in 2023
date: 2023-08-07
author: Mine Çetinkaya-Rundel
description: >
    Recommendations for teaching the tidyverse in 2023, summarizing 
    package updates most relevant for teaching data science with the 
    tidyverse, particularly to new learners.
photo:
  url: https://unsplash.com/photos/ScoYEG5LEgc
  author: Scott Evans
# one of: "deep-dive", "learn", "package", "programming", "roundup", or "other"
categories: [learn] 
tags: [tidyverse, teaching]
editor_options: 
  chunk_output_type: console
rmd_hash: 5fb786a1f1eaa247

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
* [ ] [`usethis::use_tidy_thanks()`](https://usethis.r-lib.org/reference/use_tidy_thanks.html) -- not applicable
-->

Another year, another roundup of tidyverse updates, through the lens of an educator. As with previous [teaching the tidyverse posts](/blog/2021/08/teach-tidyverse-2021/), much of what is discussed in this blog post has already been covered in package update posts, however the goal of this roundup is to summarize the highlights that are most relevant to teaching data science with the tidyverse, particularly to new learners.

Specifically, I'll discuss:

-   [Resource refresh](#sec-resource-refresh)
-   [Nine core packages in tidyverse 2.0.0](#sec-nine-core-packages-in-tidyverse-2.0.0)
-   [Conflict resolution in the tidyverse](sec-conflict-resolution)
-   [Improved and expanded `*_join()` functionality](#sec-improved-and-expanded-join-functionality)
-   [Per operation grouping](#sec-per-operation-grouping)
-   [Quality of life improvements to `case_when()` and `if_else()`](#sec-quality-of-life-improvements-to-case_when-and-if_else)
-   [New syntax for separating columns](#sec-new-syntax-for-separating-columns)
-   [New argument for line geoms: linewidth](#sec-new-argument-for-line-geoms-linewidth)
-   [Other highlights](#sec-other-highlights)

And different from previous posts on this topic, this one comes with a video! If you'd like a live demo of the code examples, and a few more additional tips along the way, you can watch the video below.

<center>
<iframe width="560" height="315" src="https://www.youtube.com/embed/KsBBRHAgAhM" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" allowfullscreen></iframe>
</center>

Throughout this blog post you'll encounter some code chunks with the comment `previously`, indicating what you used to do in the tidyverse. Often these will be coupled with chunks with the comment `now, optionally`, indicating what you *can* now do with the tidyverse. And rarely, they will be coupled with chunks with the comment `now`, indicating what you *should* do instead now with the tidyverse.

Let's get started with the obligatory...

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://tidyverse.tidyverse.org'>tidyverse</a></span><span class='o'>)</span></span>
<span><span class='c'>#&gt; ── <span style='font-weight: bold;'>Attaching core tidyverse packages</span> ──────────────────────── tidyverse 2.0.0 ──</span></span>
<span><span class='c'>#&gt; <span style='color: #00BB00;'>✔</span> <span style='color: #0000BB;'>dplyr    </span> 1.1.2     <span style='color: #00BB00;'>✔</span> <span style='color: #0000BB;'>readr    </span> 2.1.4</span></span>
<span><span class='c'>#&gt; <span style='color: #00BB00;'>✔</span> <span style='color: #0000BB;'>forcats  </span> 1.0.0     <span style='color: #00BB00;'>✔</span> <span style='color: #0000BB;'>stringr  </span> 1.5.0</span></span>
<span><span class='c'>#&gt; <span style='color: #00BB00;'>✔</span> <span style='color: #0000BB;'>ggplot2  </span> 3.4.2     <span style='color: #00BB00;'>✔</span> <span style='color: #0000BB;'>tibble   </span> 3.2.1</span></span>
<span><span class='c'>#&gt; <span style='color: #00BB00;'>✔</span> <span style='color: #0000BB;'>lubridate</span> 1.9.2     <span style='color: #00BB00;'>✔</span> <span style='color: #0000BB;'>tidyr    </span> 1.3.0</span></span>
<span><span class='c'>#&gt; <span style='color: #00BB00;'>✔</span> <span style='color: #0000BB;'>purrr    </span> 1.0.1     </span></span>
<span><span class='c'>#&gt; ── <span style='font-weight: bold;'>Conflicts</span> ────────────────────────────────────────── tidyverse_conflicts() ──</span></span>
<span><span class='c'>#&gt; <span style='color: #BB0000;'>✖</span> <span style='color: #0000BB;'>dplyr</span>::<span style='color: #00BB00;'>filter()</span> masks <span style='color: #0000BB;'>stats</span>::filter()</span></span>
<span><span class='c'>#&gt; <span style='color: #BB0000;'>✖</span> <span style='color: #0000BB;'>dplyr</span>::<span style='color: #00BB00;'>lag()</span>    masks <span style='color: #0000BB;'>stats</span>::lag()</span></span>
<span><span class='c'>#&gt; <span style='color: #00BBBB;'>ℹ</span> Use the conflicted package (<span style='color: #0000BB; font-style: italic;'>&lt;http://conflicted.r-lib.org/&gt;</span>) to force all conflicts to become errors</span></span>
<span></span></code></pre>

</div>

And, let's also load the [palmerpenguins](https://allisonhorst.github.io/palmerpenguins/) package that we will use in examples.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://allisonhorst.github.io/palmerpenguins/'>palmerpenguins</a></span><span class='o'>)</span></span></code></pre>

</div>

## Resource refresh

R for Data Science, 2nd Edition is out! [This blog post](blog/2023/07/r4ds-2e/) (and the [book's preface](https://r4ds.hadley.nz/preface-2e.html)) outlines updates since the first edition. Updates to the book served as the motivation for many of the changes mentioned in the remainder of this post as as well as on the Tidyverse blog over the last year. Now that the book is out, you can expect the pace of change to slow down again for a while, which means plenty of time for phasing these changes into your teaching materials.

One change in the 2nd Edition that will most likely affect almost all of your teaching materials is the use of the native R pipe (`|>`) instead of the magrittr pipe (`%>%`). If you're not familiar with the similarities and differences between these operators, I recommend reading [this comparison blog post](https://www.tidyverse.org/blog/2023/04/base-vs-magrittr-pipe/). And I strongly recommend making this update since it will allow students to perform piped operations with any R function, and hence allow them to keep their data pipeline workflows regardless of whether the next package they learn is from the tidyverse (or package that uses tidyverse principles) or not.

## Nine core packages in tidyverse 2.0.0

The main update in tidyverse 2.0.0, which was released in March 2023, is that it [lubridate](https://lubridate.tidyverse.org/) is now a core tidyverse package. The lubridate package that makes it easier to do the things R does with date-times, is now a core tidyverse package. So, while many of your scripts in the past may have started with

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='c'># previously</span></span>
<span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://tidyverse.tidyverse.org'>tidyverse</a></span><span class='o'>)</span></span>
<span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://lubridate.tidyverse.org'>lubridate</a></span><span class='o'>)</span></span></code></pre>

</div>

you can now just do

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='c'># now</span></span>
<span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://tidyverse.tidyverse.org'>tidyverse</a></span><span class='o'>)</span></span></code></pre>

</div>

and the lubridate package will be loaded as well.

If you, like me, use a graphic like the one below that maps the core tidyverse packages to phases of the data science cycle, here is an updated graphic including lubridate.

<img src="images/data-science.png" data-fig-alt="Data science cycle: import, tidy, transform, visualize, model, communicate. Packages readr and tibble are for import. Packages tidyr and purr for tidy and transform. Packages dplyr, stringr, forcats, and lubridate are for transform. Package ggplot2 is for visualize." />

## Conflict resolution in the tidyverse

You may have also noticed that the package loading message for the tidyverse has been updated as well, and now advertises the [conflicted](https://conflicted.r-lib.org/) package.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='c'>#&gt; ── <span style='font-weight: bold;'>Conflicts</span> ────────────────────────────────────────── tidyverse_conflicts() ──</span></span>
<span><span class='c'>#&gt; <span style='color: #BB0000;'>✖</span> <span style='color: #0000BB;'>dplyr</span>::<span style='color: #00BB00;'>filter()</span> masks <span style='color: #0000BB;'>stats</span>::filter()</span></span>
<span><span class='c'>#&gt; <span style='color: #BB0000;'>✖</span> <span style='color: #0000BB;'>dplyr</span>::<span style='color: #00BB00;'>lag()</span>    masks <span style='color: #0000BB;'>stats</span>::lag()</span></span>
<span><span class='c'>#&gt; <span style='color: #00BBBB;'>ℹ</span> Use the conflicted package (<span style='color: #0000BB; font-style: italic;'>&lt;http://conflicted.r-lib.org/&gt;</span>) to force all conflicts to become errors</span></span>
<span></span></code></pre>

</div>

Conflict resolution in R, i.e., what to do if multiple packages that are loaded in a session have functions with the same name, can get tricky, and the conflicted package is designed to help with that. R's default conflict resolution gives precedence to the most recently loaded package. For example, if you use the filter function before loading the tidyverse, R will use [`stats::filter()`](https://rdrr.io/r/stats/filter.html):

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>penguins</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/filter.html'>filter</a></span><span class='o'>(</span><span class='nv'>species</span> <span class='o'>==</span> <span class='s'>"Adelie"</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; Error in eval(expr, envir, enclos): object 'species' not found</span></span>
<span></span></code></pre>

</div>

However, after loading the tidyverse, when you call [`filter()`](https://dplyr.tidyverse.org/reference/filter.html), R will *silently* choose [`dplyr::filter()`](https://dplyr.tidyverse.org/reference/filter.html):

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>penguins</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/filter.html'>filter</a></span><span class='o'>(</span><span class='nv'>species</span> <span class='o'>==</span> <span class='s'>"Adelie"</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 152 × 8</span></span></span>
<span><span class='c'>#&gt;    species island    bill_length_mm bill_depth_mm flipper_length_mm body_mass_g</span></span>
<span><span class='c'>#&gt;    <span style='color: #555555; font-style: italic;'>&lt;fct&gt;</span>   <span style='color: #555555; font-style: italic;'>&lt;fct&gt;</span>              <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>         <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>             <span style='color: #555555; font-style: italic;'>&lt;int&gt;</span>       <span style='color: #555555; font-style: italic;'>&lt;int&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 1</span> Adelie  Torgersen           39.1          18.7               181        <span style='text-decoration: underline;'>3</span>750</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 2</span> Adelie  Torgersen           39.5          17.4               186        <span style='text-decoration: underline;'>3</span>800</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 3</span> Adelie  Torgersen           40.3          18                 195        <span style='text-decoration: underline;'>3</span>250</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 4</span> Adelie  Torgersen           <span style='color: #BB0000;'>NA</span>            <span style='color: #BB0000;'>NA</span>                  <span style='color: #BB0000;'>NA</span>          <span style='color: #BB0000;'>NA</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 5</span> Adelie  Torgersen           36.7          19.3               193        <span style='text-decoration: underline;'>3</span>450</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 6</span> Adelie  Torgersen           39.3          20.6               190        <span style='text-decoration: underline;'>3</span>650</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 7</span> Adelie  Torgersen           38.9          17.8               181        <span style='text-decoration: underline;'>3</span>625</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 8</span> Adelie  Torgersen           39.2          19.6               195        <span style='text-decoration: underline;'>4</span>675</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 9</span> Adelie  Torgersen           34.1          18.1               193        <span style='text-decoration: underline;'>3</span>475</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>10</span> Adelie  Torgersen           42            20.2               190        <span style='text-decoration: underline;'>4</span>250</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># ℹ 142 more rows</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># ℹ 2 more variables: sex &lt;fct&gt;, year &lt;int&gt;</span></span></span>
<span></span></code></pre>

</div>

This silent conflict resolution approach works fine until it doesn't, and then it can be very frustrating to debug. The conflicted package does not allow for silent conflict resolution:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://conflicted.r-lib.org/'>conflicted</a></span><span class='o'>)</span></span>
<span>    </span>
<span><span class='nv'>penguins</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/filter.html'>filter</a></span><span class='o'>(</span><span class='nv'>species</span> <span class='o'>==</span> <span class='s'>"Adelie"</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #BBBB00; font-weight: bold;'>Error</span><span style='font-weight: bold;'>:</span></span></span>
<span><span class='c'>#&gt; <span style='color: #BBBB00;'>!</span> <span style='color: #555555;'>[conflicted]</span> <span style='font-weight: bold;'>filter</span> found in 2 packages.</span></span>
<span><span class='c'>#&gt; Either pick the one you want with `::`:</span></span>
<span><span class='c'>#&gt; <span style='color: #00BBBB;'>•</span> <span style='color: #0000BB;'>dplyr</span>::filter</span></span>
<span><span class='c'>#&gt; <span style='color: #00BBBB;'>•</span> <span style='color: #0000BB;'>stats</span>::filter</span></span>
<span><span class='c'>#&gt; Or declare a preference with `conflicts_prefer()`:</span></span>
<span><span class='c'>#&gt; <span style='color: #00BBBB;'>•</span> `conflicts_prefer(dplyr::filter)`</span></span>
<span><span class='c'>#&gt; <span style='color: #00BBBB;'>•</span> `conflicts_prefer(stats::filter)`</span></span>
<span></span></code></pre>

</div>

You can, of course, use [`dplyr::filter()`](https://dplyr.tidyverse.org/reference/filter.html) but if you have a bunch of data wrangling pipelines, which is likely the case if you're teaching data wrangling, it can get pretty busy.

Instead, with conflicted, you can explicitly declare which [`filter()`](https://dplyr.tidyverse.org/reference/filter.html) you want to use at the beginning (of a session, of a script, or of an R Markdown or Quarto file) with [`conflicts_prefer()`](https://conflicted.r-lib.org/reference/conflicts_prefer.html):

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://conflicted.r-lib.org/reference/conflicts_prefer.html'>conflicts_prefer</a></span><span class='o'>(</span><span class='nf'>dplyr</span><span class='nf'>::</span><span class='nv'><a href='https://dplyr.tidyverse.org/reference/filter.html'>filter</a></span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>[conflicted]</span> Will prefer <span style='color: #0000BB; font-weight: bold;'>dplyr</span>::filter over any other package.</span></span>
<span></span><span>  </span>
<span><span class='nv'>penguins</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/filter.html'>filter</a></span><span class='o'>(</span><span class='nv'>species</span> <span class='o'>==</span> <span class='s'>"Adelie"</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 152 × 8</span></span></span>
<span><span class='c'>#&gt;    species island    bill_length_mm bill_depth_mm flipper_length_mm body_mass_g</span></span>
<span><span class='c'>#&gt;    <span style='color: #555555; font-style: italic;'>&lt;fct&gt;</span>   <span style='color: #555555; font-style: italic;'>&lt;fct&gt;</span>              <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>         <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>             <span style='color: #555555; font-style: italic;'>&lt;int&gt;</span>       <span style='color: #555555; font-style: italic;'>&lt;int&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 1</span> Adelie  Torgersen           39.1          18.7               181        <span style='text-decoration: underline;'>3</span>750</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 2</span> Adelie  Torgersen           39.5          17.4               186        <span style='text-decoration: underline;'>3</span>800</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 3</span> Adelie  Torgersen           40.3          18                 195        <span style='text-decoration: underline;'>3</span>250</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 4</span> Adelie  Torgersen           <span style='color: #BB0000;'>NA</span>            <span style='color: #BB0000;'>NA</span>                  <span style='color: #BB0000;'>NA</span>          <span style='color: #BB0000;'>NA</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 5</span> Adelie  Torgersen           36.7          19.3               193        <span style='text-decoration: underline;'>3</span>450</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 6</span> Adelie  Torgersen           39.3          20.6               190        <span style='text-decoration: underline;'>3</span>650</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 7</span> Adelie  Torgersen           38.9          17.8               181        <span style='text-decoration: underline;'>3</span>625</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 8</span> Adelie  Torgersen           39.2          19.6               195        <span style='text-decoration: underline;'>4</span>675</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 9</span> Adelie  Torgersen           34.1          18.1               193        <span style='text-decoration: underline;'>3</span>475</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>10</span> Adelie  Torgersen           42            20.2               190        <span style='text-decoration: underline;'>4</span>250</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># ℹ 142 more rows</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># ℹ 2 more variables: sex &lt;fct&gt;, year &lt;int&gt;</span></span></span>
<span></span></code></pre>

</div>

Getting back to the package loading message... It can be tempting, particularly in a teaching scenario, particularly to an audience of new learners, and particularly if you teach with slides and messages take up valuable slide real estate, I would urge you to not hide startup messages from teaching materials. Instead, address them early on to:

1.  Encourage reading and understanding messages, warnings, and errors -- teaching people to read error messages is hard enough, it's going to be even harder if you're not modeling that to them.

2.  Help during hard-to-debug situations resulting from base R's silent conflict resolution -- because, let's face it, someone in your class, if not you during a live-coding session, will see that pesky object not found error at some point when using [`filter()`](https://dplyr.tidyverse.org/reference/filter.html).

## Improved and expanded `*_join()` functionality

The [dplyr](https://dplyr.tidyverse.org/) package has long had the [`*_join()` family of functions](https://dplyr.tidyverse.org/articles/two-table.html) for joining data frames. dplyr 1.1.0 introduced a [bunch of extensions](https://www.tidyverse.org/blog/2023/01/dplyr-1-1-0-joins/) that bring joins closer to the power available in other systems like SQL and `data.table`.

### `join_by()`

New functionality for join functions includes a new [`join_by()`](https://dplyr.tidyverse.org/reference/join_by.html) function for the `by` argument. So, while in the past your code may have looked like the following:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'># previously
*_join(
  x, y, 
  by = c("<x var>" = "<y var>")
)
</code></pre>

</div>

you can now do:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'># now, optionally
*_join(
  x, y, 
  by = join_by(<x var> == <y var>)
)
</code></pre>

</div>

For example, suppose you have the following information on the three islands we have penguins from:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>islands</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://tibble.tidyverse.org/reference/tribble.html'>tribble</a></span><span class='o'>(</span></span>
<span>  <span class='o'>~</span><span class='nv'>name</span>,       <span class='o'>~</span><span class='nv'>coordinates</span>,</span>
<span>  <span class='s'>"Torgersen"</span>, <span class='s'>"64°46′S 64°5′W"</span>,</span>
<span>  <span class='s'>"Biscoe"</span>,    <span class='s'>"65°26′S 65°30′W"</span>,</span>
<span>  <span class='s'>"Dream"</span>,     <span class='s'>"64°44′S 64°14′W"</span></span>
<span><span class='o'>)</span></span>
<span></span>
<span><span class='nv'>islands</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 3 × 2</span></span></span>
<span><span class='c'>#&gt;   name      coordinates    </span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>     <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>          </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span> Torgersen 64°46′S 64°5′W </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span> Biscoe    65°26′S 65°30′W</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>3</span> Dream     64°44′S 64°14′W</span></span>
<span></span></code></pre>

</div>

You can join this to the penguins data frame by matching the `island` column in the penguins data frame to the `name` column in the islands data frame:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>penguins</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/mutate-joins.html'>left_join</a></span><span class='o'>(</span></span>
<span>    <span class='nv'>islands</span>, </span>
<span>    by <span class='o'>=</span> <span class='nf'><a href='https://dplyr.tidyverse.org/reference/join_by.html'>join_by</a></span><span class='o'>(</span><span class='nv'>island</span> <span class='o'>==</span> <span class='nv'>name</span><span class='o'>)</span></span>
<span>  <span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/select.html'>select</a></span><span class='o'>(</span><span class='nv'>species</span>, <span class='nv'>island</span>, <span class='nv'>coordinates</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 344 × 3</span></span></span>
<span><span class='c'>#&gt;    species island    coordinates   </span></span>
<span><span class='c'>#&gt;    <span style='color: #555555; font-style: italic;'>&lt;fct&gt;</span>   <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>     <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>         </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 1</span> Adelie  Torgersen 64°46′S 64°5′W</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 2</span> Adelie  Torgersen 64°46′S 64°5′W</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 3</span> Adelie  Torgersen 64°46′S 64°5′W</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 4</span> Adelie  Torgersen 64°46′S 64°5′W</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 5</span> Adelie  Torgersen 64°46′S 64°5′W</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 6</span> Adelie  Torgersen 64°46′S 64°5′W</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 7</span> Adelie  Torgersen 64°46′S 64°5′W</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 8</span> Adelie  Torgersen 64°46′S 64°5′W</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 9</span> Adelie  Torgersen 64°46′S 64°5′W</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>10</span> Adelie  Torgersen 64°46′S 64°5′W</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># ℹ 334 more rows</span></span></span>
<span></span></code></pre>

</div>

While `by = c("island" = "name")` would still work, I would recommend teaching [`join_by()`](https://dplyr.tidyverse.org/reference/join_by.html) over `by` so that:

1.  You can read it out loud as "where x is equal to y", just like in other logical statements where `==` is pronounced as "is equal to".
2.  You don't have to worry about `by = c(x = y)` (which is invalid) vs. `by = c(x = "y")` (which is valid) vs. `by = c("x" = "y")` (which is also valid).

In fact, for succinctness, you might avoid the argument name and express this as:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>penguins</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/mutate-joins.html'>left_join</a></span><span class='o'>(</span><span class='nv'>islands</span>, <span class='nf'><a href='https://dplyr.tidyverse.org/reference/join_by.html'>join_by</a></span><span class='o'>(</span><span class='nv'>island</span> <span class='o'>==</span> <span class='nv'>name</span><span class='o'>)</span><span class='o'>)</span></span></code></pre>

</div>

### Handling various matches

The `*_join()` functions now have additional arguments for handling `multiple` matches and `unmatched` rows as well as for specifying the `relationship` between the two data frames.

So, while in the past your code may have looked like the following:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'># previously
*_join(
  x, y, by
)
</code></pre>

</div>

you can now do:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'># now, optionally
*_join(
  x, y, by,
  multiple = "all",
  unmatched = "drop",
  relationship = NULL
)
</code></pre>

</div>

Let's set up three data frames to demonstrate the new functionality:

-   Information about three penguins, one row per `samp_id`:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>three_penguins</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://tibble.tidyverse.org/reference/tribble.html'>tribble</a></span><span class='o'>(</span></span>
<span>  <span class='o'>~</span><span class='nv'>samp_id</span>, <span class='o'>~</span><span class='nv'>species</span>,    <span class='o'>~</span><span class='nv'>island</span>,</span>
<span>  <span class='m'>1</span>,        <span class='s'>"Adelie"</span>,    <span class='s'>"Torgersen"</span>,</span>
<span>  <span class='m'>2</span>,        <span class='s'>"Gentoo"</span>,    <span class='s'>"Biscoe"</span>,</span>
<span>  <span class='m'>3</span>,        <span class='s'>"Chinstrap"</span>, <span class='s'>"Dream"</span></span>
<span><span class='o'>)</span></span>
<span></span>
<span><span class='nv'>three_penguins</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 3 × 3</span></span></span>
<span><span class='c'>#&gt;   samp_id species   island   </span></span>
<span><span class='c'>#&gt;     <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>     <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>    </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span>       1 Adelie    Torgersen</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span>       2 Gentoo    Biscoe   </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>3</span>       3 Chinstrap Dream</span></span>
<span></span></code></pre>

</div>

-   Information about weight measurements of these penguins, one row per `samp_id`, `meas_id` combination:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>weight_measurements</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://tibble.tidyverse.org/reference/tribble.html'>tribble</a></span><span class='o'>(</span></span>
<span>  <span class='o'>~</span><span class='nv'>samp_id</span>, <span class='o'>~</span><span class='nv'>meas_id</span>, <span class='o'>~</span><span class='nv'>body_mass_g</span>,</span>
<span>  <span class='m'>1</span>,        <span class='m'>1</span>,        <span class='m'>3220</span>,</span>
<span>  <span class='m'>1</span>,        <span class='m'>2</span>,        <span class='m'>3250</span>,</span>
<span>  <span class='m'>2</span>,        <span class='m'>1</span>,        <span class='m'>4730</span>,</span>
<span>  <span class='m'>2</span>,        <span class='m'>2</span>,        <span class='m'>4725</span>,</span>
<span>  <span class='m'>3</span>,        <span class='m'>1</span>,        <span class='m'>4000</span>,</span>
<span>  <span class='m'>3</span>,        <span class='m'>2</span>,        <span class='m'>4050</span></span>
<span><span class='o'>)</span></span>
<span></span>
<span><span class='nv'>weight_measurements</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 6 × 3</span></span></span>
<span><span class='c'>#&gt;   samp_id meas_id body_mass_g</span></span>
<span><span class='c'>#&gt;     <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>   <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>       <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span>       1       1        <span style='text-decoration: underline;'>3</span>220</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span>       1       2        <span style='text-decoration: underline;'>3</span>250</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>3</span>       2       1        <span style='text-decoration: underline;'>4</span>730</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>4</span>       2       2        <span style='text-decoration: underline;'>4</span>725</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>5</span>       3       1        <span style='text-decoration: underline;'>4</span>000</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>6</span>       3       2        <span style='text-decoration: underline;'>4</span>050</span></span>
<span></span></code></pre>

</div>

-   Information about flipper measurements of these penguins, one row per `samp_id`, `meas_id` combination:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>flipper_measurements</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://tibble.tidyverse.org/reference/tribble.html'>tribble</a></span><span class='o'>(</span></span>
<span>  <span class='o'>~</span><span class='nv'>samp_id</span>, <span class='o'>~</span><span class='nv'>meas_id</span>, <span class='o'>~</span><span class='nv'>flipper_length_mm</span>,</span>
<span>  <span class='m'>1</span>,        <span class='m'>1</span>,        <span class='m'>193</span>,</span>
<span>  <span class='m'>1</span>,        <span class='m'>2</span>,        <span class='m'>195</span>,</span>
<span>  <span class='m'>2</span>,        <span class='m'>1</span>,        <span class='m'>214</span>,</span>
<span>  <span class='m'>2</span>,        <span class='m'>2</span>,        <span class='m'>216</span>,</span>
<span>  <span class='m'>3</span>,        <span class='m'>1</span>,        <span class='m'>203</span>,</span>
<span>  <span class='m'>3</span>,        <span class='m'>2</span>,        <span class='m'>203</span></span>
<span><span class='o'>)</span></span>
<span></span>
<span><span class='nv'>flipper_measurements</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 6 × 3</span></span></span>
<span><span class='c'>#&gt;   samp_id meas_id flipper_length_mm</span></span>
<span><span class='c'>#&gt;     <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>   <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>             <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span>       1       1               193</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span>       1       2               195</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>3</span>       2       1               214</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>4</span>       2       2               216</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>5</span>       3       1               203</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>6</span>       3       2               203</span></span>
<span></span></code></pre>

</div>

One-to-many relationships don't require extra care, they just work:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>three_penguins</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/mutate-joins.html'>left_join</a></span><span class='o'>(</span><span class='nv'>weight_measurements</span>, <span class='nf'><a href='https://dplyr.tidyverse.org/reference/join_by.html'>join_by</a></span><span class='o'>(</span><span class='nv'>samp_id</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 6 × 5</span></span></span>
<span><span class='c'>#&gt;   samp_id species   island    meas_id body_mass_g</span></span>
<span><span class='c'>#&gt;     <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>     <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>       <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>       <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span>       1 Adelie    Torgersen       1        <span style='text-decoration: underline;'>3</span>220</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span>       1 Adelie    Torgersen       2        <span style='text-decoration: underline;'>3</span>250</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>3</span>       2 Gentoo    Biscoe          1        <span style='text-decoration: underline;'>4</span>730</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>4</span>       2 Gentoo    Biscoe          2        <span style='text-decoration: underline;'>4</span>725</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>5</span>       3 Chinstrap Dream           1        <span style='text-decoration: underline;'>4</span>000</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>6</span>       3 Chinstrap Dream           2        <span style='text-decoration: underline;'>4</span>050</span></span>
<span></span></code></pre>

</div>

However, many-to-many relationships require some extra care. For example, if we join the `three_penguins` data frame to the `flipper_measurements` data frame, we get a warning:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>weight_measurements</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/mutate-joins.html'>left_join</a></span><span class='o'>(</span><span class='nv'>flipper_measurements</span>, <span class='nf'><a href='https://dplyr.tidyverse.org/reference/join_by.html'>join_by</a></span><span class='o'>(</span><span class='nv'>samp_id</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; Warning in left_join(weight_measurements, flipper_measurements, join_by(samp_id)): Detected an unexpected many-to-many relationship between `x` and `y`.</span></span>
<span><span class='c'>#&gt; <span style='color: #00BBBB;'>ℹ</span> Row 1 of `x` matches multiple rows in `y`.</span></span>
<span><span class='c'>#&gt; <span style='color: #00BBBB;'>ℹ</span> Row 1 of `y` matches multiple rows in `x`.</span></span>
<span><span class='c'>#&gt; <span style='color: #00BBBB;'>ℹ</span> If a many-to-many relationship is expected, set `relationship =</span></span>
<span><span class='c'>#&gt;   "many-to-many"` to silence this warning.</span></span>
<span></span><span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 12 × 5</span></span></span>
<span><span class='c'>#&gt;    samp_id meas_id.x body_mass_g meas_id.y flipper_length_mm</span></span>
<span><span class='c'>#&gt;      <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>     <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>       <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>     <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>             <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 1</span>       1         1        <span style='text-decoration: underline;'>3</span>220         1               193</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 2</span>       1         1        <span style='text-decoration: underline;'>3</span>220         2               195</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 3</span>       1         2        <span style='text-decoration: underline;'>3</span>250         1               193</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 4</span>       1         2        <span style='text-decoration: underline;'>3</span>250         2               195</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 5</span>       2         1        <span style='text-decoration: underline;'>4</span>730         1               214</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 6</span>       2         1        <span style='text-decoration: underline;'>4</span>730         2               216</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 7</span>       2         2        <span style='text-decoration: underline;'>4</span>725         1               214</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 8</span>       2         2        <span style='text-decoration: underline;'>4</span>725         2               216</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 9</span>       3         1        <span style='text-decoration: underline;'>4</span>000         1               203</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>10</span>       3         1        <span style='text-decoration: underline;'>4</span>000         2               203</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>11</span>       3         2        <span style='text-decoration: underline;'>4</span>050         1               203</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>12</span>       3         2        <span style='text-decoration: underline;'>4</span>050         2               203</span></span>
<span></span></code></pre>

</div>

We get a warning about unexpected many-to-many relationships (unexpected because we didn't specify this type of relationship in our join call), and the warning suggests setting `relationship = "many-to-many"`. And note that we went from 6 rows (measurements) to 12, which is also unexpected.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>weight_measurements</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/mutate-joins.html'>left_join</a></span><span class='o'>(</span><span class='nv'>flipper_measurements</span>, <span class='nf'><a href='https://dplyr.tidyverse.org/reference/join_by.html'>join_by</a></span><span class='o'>(</span><span class='nv'>samp_id</span><span class='o'>)</span>, relationship <span class='o'>=</span> <span class='s'>"many-to-many"</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 12 × 5</span></span></span>
<span><span class='c'>#&gt;    samp_id meas_id.x body_mass_g meas_id.y flipper_length_mm</span></span>
<span><span class='c'>#&gt;      <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>     <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>       <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>     <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>             <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 1</span>       1         1        <span style='text-decoration: underline;'>3</span>220         1               193</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 2</span>       1         1        <span style='text-decoration: underline;'>3</span>220         2               195</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 3</span>       1         2        <span style='text-decoration: underline;'>3</span>250         1               193</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 4</span>       1         2        <span style='text-decoration: underline;'>3</span>250         2               195</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 5</span>       2         1        <span style='text-decoration: underline;'>4</span>730         1               214</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 6</span>       2         1        <span style='text-decoration: underline;'>4</span>730         2               216</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 7</span>       2         2        <span style='text-decoration: underline;'>4</span>725         1               214</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 8</span>       2         2        <span style='text-decoration: underline;'>4</span>725         2               216</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 9</span>       3         1        <span style='text-decoration: underline;'>4</span>000         1               203</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>10</span>       3         1        <span style='text-decoration: underline;'>4</span>000         2               203</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>11</span>       3         2        <span style='text-decoration: underline;'>4</span>050         1               203</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>12</span>       3         2        <span style='text-decoration: underline;'>4</span>050         2               203</span></span>
<span></span></code></pre>

</div>

With `relationship = "many-to-many"`, we no longer get a warning. However, the "explosion of rows" issue is still there. Addressing that requires rethinking what we join the two data frames by:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>weight_measurements</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/mutate-joins.html'>left_join</a></span><span class='o'>(</span><span class='nv'>flipper_measurements</span>, <span class='nf'><a href='https://dplyr.tidyverse.org/reference/join_by.html'>join_by</a></span><span class='o'>(</span><span class='nv'>samp_id</span>, <span class='nv'>meas_id</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 6 × 4</span></span></span>
<span><span class='c'>#&gt;   samp_id meas_id body_mass_g flipper_length_mm</span></span>
<span><span class='c'>#&gt;     <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>   <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>       <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>             <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span>       1       1        <span style='text-decoration: underline;'>3</span>220               193</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span>       1       2        <span style='text-decoration: underline;'>3</span>250               195</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>3</span>       2       1        <span style='text-decoration: underline;'>4</span>730               214</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>4</span>       2       2        <span style='text-decoration: underline;'>4</span>725               216</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>5</span>       3       1        <span style='text-decoration: underline;'>4</span>000               203</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>6</span>       3       2        <span style='text-decoration: underline;'>4</span>050               203</span></span>
<span></span></code></pre>

</div>

We can see that while the warning nudged us towards setting `relationship = "many-to-many"`, turns out the correct way to address the problem was to join by both `samp_id` and `meas_id`.

We'll wrap up our discussion on new functionality for handling `unmatched` cases. We'll create one more data frame (`four_penguins`) to exemplify this:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>four_penguins</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://tibble.tidyverse.org/reference/tribble.html'>tribble</a></span><span class='o'>(</span></span>
<span>  <span class='o'>~</span><span class='nv'>samp_id</span>, <span class='o'>~</span><span class='nv'>species</span>,    <span class='o'>~</span><span class='nv'>island</span>,</span>
<span>  <span class='m'>1</span>,        <span class='s'>"Adelie"</span>,    <span class='s'>"Torgersen"</span>,</span>
<span>  <span class='m'>2</span>,        <span class='s'>"Gentoo"</span>,    <span class='s'>"Biscoe"</span>,</span>
<span>  <span class='m'>3</span>,        <span class='s'>"Chinstrap"</span>, <span class='s'>"Dream"</span>,</span>
<span>  <span class='m'>4</span>,        <span class='s'>"Adelie"</span>,    <span class='s'>"Biscoe"</span></span>
<span><span class='o'>)</span></span>
<span></span>
<span><span class='nv'>four_penguins</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 4 × 3</span></span></span>
<span><span class='c'>#&gt;   samp_id species   island   </span></span>
<span><span class='c'>#&gt;     <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>     <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>    </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span>       1 Adelie    Torgersen</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span>       2 Gentoo    Biscoe   </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>3</span>       3 Chinstrap Dream    </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>4</span>       4 Adelie    Biscoe</span></span>
<span></span></code></pre>

</div>

If we just join `weight_measurements` to `four_penguins`, the unmatched fourth penguin silently disappears, which is less than ideal, particularly in a more realistic scenario with many more observations:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>weight_measurements</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/mutate-joins.html'>left_join</a></span><span class='o'>(</span><span class='nv'>four_penguins</span>, <span class='nf'><a href='https://dplyr.tidyverse.org/reference/join_by.html'>join_by</a></span><span class='o'>(</span><span class='nv'>samp_id</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 6 × 5</span></span></span>
<span><span class='c'>#&gt;   samp_id meas_id body_mass_g species   island   </span></span>
<span><span class='c'>#&gt;     <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>   <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>       <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>     <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>    </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span>       1       1        <span style='text-decoration: underline;'>3</span>220 Adelie    Torgersen</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span>       1       2        <span style='text-decoration: underline;'>3</span>250 Adelie    Torgersen</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>3</span>       2       1        <span style='text-decoration: underline;'>4</span>730 Gentoo    Biscoe   </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>4</span>       2       2        <span style='text-decoration: underline;'>4</span>725 Gentoo    Biscoe   </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>5</span>       3       1        <span style='text-decoration: underline;'>4</span>000 Chinstrap Dream    </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>6</span>       3       2        <span style='text-decoration: underline;'>4</span>050 Chinstrap Dream</span></span>
<span></span></code></pre>

</div>

Setting `unmatched = "error"` can protects you from accidentally dropping rows:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>weight_measurements</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/mutate-joins.html'>left_join</a></span><span class='o'>(</span><span class='nv'>four_penguins</span>, <span class='nf'><a href='https://dplyr.tidyverse.org/reference/join_by.html'>join_by</a></span><span class='o'>(</span><span class='nv'>samp_id</span><span class='o'>)</span>, unmatched <span class='o'>=</span> <span class='s'>"error"</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #BBBB00; font-weight: bold;'>Error</span><span style='font-weight: bold;'> in `left_join()`:</span></span></span>
<span><span class='c'>#&gt; <span style='color: #BBBB00;'>!</span> Each row of `y` must be matched by `x`.</span></span>
<span><span class='c'>#&gt; <span style='color: #00BBBB;'>ℹ</span> Row 4 of `y` was not matched.</span></span>
<span></span></code></pre>

</div>

Once you see the error message, you can decide how to handle the unmatched rows, e.g., explicitly drop them.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>weight_measurements</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/mutate-joins.html'>left_join</a></span><span class='o'>(</span><span class='nv'>four_penguins</span>, <span class='nf'><a href='https://dplyr.tidyverse.org/reference/join_by.html'>join_by</a></span><span class='o'>(</span><span class='nv'>samp_id</span><span class='o'>)</span>, unmatched <span class='o'>=</span> <span class='s'>"drop"</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 6 × 5</span></span></span>
<span><span class='c'>#&gt;   samp_id meas_id body_mass_g species   island   </span></span>
<span><span class='c'>#&gt;     <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>   <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>       <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>     <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>    </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span>       1       1        <span style='text-decoration: underline;'>3</span>220 Adelie    Torgersen</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span>       1       2        <span style='text-decoration: underline;'>3</span>250 Adelie    Torgersen</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>3</span>       2       1        <span style='text-decoration: underline;'>4</span>730 Gentoo    Biscoe   </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>4</span>       2       2        <span style='text-decoration: underline;'>4</span>725 Gentoo    Biscoe   </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>5</span>       3       1        <span style='text-decoration: underline;'>4</span>000 Chinstrap Dream    </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>6</span>       3       2        <span style='text-decoration: underline;'>4</span>050 Chinstrap Dream</span></span>
<span></span></code></pre>

</div>

There are many more developments related to `*_join()` functions (e.g., [inequality joins](/blog/2023/01/dplyr-1-1-0-joins/#inequality-joins) and [rolling joins](/blog/2023/01/dplyr-1-1-0-joins/#rolling-joins)), but many of these likely wouldn't come up in an introductory course so we won't get into their details. A good place to read more about them is [R for Data Science, 2nd edition](https://r4ds.hadley.nz/joins.html#sec-non-equi-joins).

Exploding joins (i.e., joins that result in a larger number of rows than either of the data frames from bie) can be hard to debug for students! Teaching them the tools to diagnose whether the join they performed, and that may not have given an error, is indeed the one they wanted to perform. Did they lose any cases? Did they gain an unexpected amount of cases? Did they perform a join without thinking and take down the entire teaching server? These things happen, particularly if students are working with their own data for an open-ended project!

## Per operation grouping

To calculate grouped summary statistics, you previously needed to do something like this:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='c'># previously</span></span>
<span><span class='nv'>df</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/group_by.html'>group_by</a></span><span class='o'>(</span><span class='nv'>x</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/summarise.html'>summarize</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/mean.html'>mean</a></span><span class='o'>(</span><span class='nv'>y</span><span class='o'>)</span><span class='o'>)</span></span></code></pre>

</div>

Now, an alternative approach is to pass the groups directly in the [`summarize()`](https://dplyr.tidyverse.org/reference/summarise.html) call:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='c'># now, optionally</span></span>
<span><span class='nv'>df</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/summarise.html'>summarize</a></span><span class='o'>(</span></span>
<span>    <span class='nf'><a href='https://rdrr.io/r/base/mean.html'>mean</a></span><span class='o'>(</span><span class='nv'>y</span><span class='o'>)</span>, </span>
<span>    .by <span class='o'>=</span> <span class='nv'>x</span></span>
<span>  <span class='o'>)</span></span></code></pre>

</div>

Let's take a look at the differences between these two approaches before making a recommendation for one over the other. [`group_by()`](https://dplyr.tidyverse.org/reference/group_by.html) can result in groups that persist in the output, particularly when grouping by multiple variables. For example, in the following pipeline we group the penguins data frame by `species` and `sex`, find mean body weights for each resulting species / sex combination, and then show the first observation in the output with `slice_head(n = 1)`. Since the output is grouped by species, this results in one summary statistic per species.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>penguins</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://tidyr.tidyverse.org/reference/drop_na.html'>drop_na</a></span><span class='o'>(</span><span class='nv'>sex</span>, <span class='nv'>body_mass_g</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/group_by.html'>group_by</a></span><span class='o'>(</span><span class='nv'>species</span>, <span class='nv'>sex</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/summarise.html'>summarize</a></span><span class='o'>(</span>mean_bw <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/mean.html'>mean</a></span><span class='o'>(</span><span class='nv'>body_mass_g</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/slice.html'>slice_head</a></span><span class='o'>(</span>n <span class='o'>=</span> <span class='m'>1</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; `summarise()` has grouped output by 'species'. You can override using the</span></span>
<span><span class='c'>#&gt; `.groups` argument.</span></span>
<span></span><span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 3 × 3</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># Groups:   species [3]</span></span></span>
<span><span class='c'>#&gt;   species   sex    mean_bw</span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;fct&gt;</span>     <span style='color: #555555; font-style: italic;'>&lt;fct&gt;</span>    <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span> Adelie    female   <span style='text-decoration: underline;'>3</span>369.</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span> Chinstrap female   <span style='text-decoration: underline;'>3</span>527.</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>3</span> Gentoo    female   <span style='text-decoration: underline;'>4</span>680.</span></span>
<span></span></code></pre>

</div>

If we explicitly drop the groups in the [`summarize()`](https://dplyr.tidyverse.org/reference/summarise.html) call, so that the output is no longer grouped, we get just one row in our output.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>penguins</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://tidyr.tidyverse.org/reference/drop_na.html'>drop_na</a></span><span class='o'>(</span><span class='nv'>sex</span>, <span class='nv'>body_mass_g</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/group_by.html'>group_by</a></span><span class='o'>(</span><span class='nv'>species</span>, <span class='nv'>sex</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/summarise.html'>summarize</a></span><span class='o'>(</span>mean_bw <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/mean.html'>mean</a></span><span class='o'>(</span><span class='nv'>body_mass_g</span><span class='o'>)</span>, .groups <span class='o'>=</span> <span class='s'>"drop"</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/slice.html'>slice_head</a></span><span class='o'>(</span>n <span class='o'>=</span> <span class='m'>1</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 1 × 3</span></span></span>
<span><span class='c'>#&gt;   species sex    mean_bw</span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;fct&gt;</span>   <span style='color: #555555; font-style: italic;'>&lt;fct&gt;</span>    <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span> Adelie  female   <span style='text-decoration: underline;'>3</span>369.</span></span>
<span></span></code></pre>

</div>

This pair of examples show that whether your output is grouped or not can affect downstream results, and if you're a [`group_by()`](https://dplyr.tidyverse.org/reference/group_by.html) user, you've probably been burnt by this once or twice.

Per-operation grouping allows you to define groups in a `.by` argument, and these groups don't persist. So, regardless of whether you group by one or two variables, the resulting data frame after calculating a summary statistic is not grouped.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='c'># group by 1 variable</span></span>
<span><span class='nv'>penguins</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://tidyr.tidyverse.org/reference/drop_na.html'>drop_na</a></span><span class='o'>(</span><span class='nv'>sex</span>, <span class='nv'>body_mass_g</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/summarise.html'>summarize</a></span><span class='o'>(</span></span>
<span>    mean_bw <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/mean.html'>mean</a></span><span class='o'>(</span><span class='nv'>body_mass_g</span><span class='o'>)</span>, </span>
<span>    .by <span class='o'>=</span> <span class='nv'>species</span></span>
<span>  <span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 3 × 2</span></span></span>
<span><span class='c'>#&gt;   species   mean_bw</span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;fct&gt;</span>       <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span> Adelie      <span style='text-decoration: underline;'>3</span>706.</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span> Gentoo      <span style='text-decoration: underline;'>5</span>092.</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>3</span> Chinstrap   <span style='text-decoration: underline;'>3</span>733.</span></span>
<span></span><span></span>
<span><span class='c'># group by 2 variables</span></span>
<span><span class='nv'>penguins</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://tidyr.tidyverse.org/reference/drop_na.html'>drop_na</a></span><span class='o'>(</span><span class='nv'>sex</span>, <span class='nv'>body_mass_g</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/summarise.html'>summarize</a></span><span class='o'>(</span></span>
<span>    mean_bw <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/mean.html'>mean</a></span><span class='o'>(</span><span class='nv'>body_mass_g</span><span class='o'>)</span>, </span>
<span>    .by <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='nv'>species</span>, <span class='nv'>sex</span><span class='o'>)</span></span>
<span>  <span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 6 × 3</span></span></span>
<span><span class='c'>#&gt;   species   sex    mean_bw</span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;fct&gt;</span>     <span style='color: #555555; font-style: italic;'>&lt;fct&gt;</span>    <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span> Adelie    male     <span style='text-decoration: underline;'>4</span>043.</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span> Adelie    female   <span style='text-decoration: underline;'>3</span>369.</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>3</span> Gentoo    female   <span style='text-decoration: underline;'>4</span>680.</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>4</span> Gentoo    male     <span style='text-decoration: underline;'>5</span>485.</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>5</span> Chinstrap female   <span style='text-decoration: underline;'>3</span>527.</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>6</span> Chinstrap male     <span style='text-decoration: underline;'>3</span>939.</span></span>
<span></span></code></pre>

</div>

So, when teaching grouped operations, you now have the option to choose between these two approaches. The most important teaching tip I can give, particularly for teaching to new learners, is to choose one method and stick to it. The `.by` method will result in fewer outputs that are unintentionally grouped, and hence, might potentially be easier for new learners. And while this approach is mentioned in R for Data Science, 2nd edition, the [`group_by()`](https://dplyr.tidyverse.org/reference/group_by.html) approach is described in more detail.

On the other hand. for more experienced learners, particularly those learning to design their own functions and packages, the evolution of grouping in the tidyverse can be an interesting subject to review.

## Quality of life improvements to `case_when()` and `if_else()`

### `case_when()`

Previously, when writing a [`case_when()`](https://dplyr.tidyverse.org/reference/case_when.html) statement, you had to use `TRUE` to indicate "all else". Additionally, [`case_when()`](https://dplyr.tidyverse.org/reference/case_when.html) has historically been strict about the types on the right-hand side, e.g., requiring `NA_character` when other right-hand side values are characters, and not letting you get away with just `NA`.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'># previously
df |>
  mutate(
    x = case_when(
      <condition 1> ~ "value 1",
      <condition 2> ~ "value 2",
      <condition 3> ~ "value 3",
      TRUE          ~ NA_character_
    )
  )
</code></pre>

</div>

Now, optionally, you can define "all else" in a `.default` argument of [`case_when()`](https://dplyr.tidyverse.org/reference/case_when.html) and you no longer need to worry about the type of `NA` you use on the right-hand side.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'># now, optionally
df |>
  mutate(
    x = case_when(
      <condition 1> ~ "value 1",
      <condition 2> ~ "value 2",
      <condition 3> ~ "value 3",
      .default = NA
    )
  )
</code></pre>

</div>

For example, you can now do something like the following when creating a categorical version of a numerical variable that has some `NA`s.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>penguins</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/mutate.html'>mutate</a></span><span class='o'>(</span></span>
<span>    bm_cat <span class='o'>=</span> <span class='nf'><a href='https://dplyr.tidyverse.org/reference/case_when.html'>case_when</a></span><span class='o'>(</span></span>
<span>      <span class='nf'><a href='https://rdrr.io/r/base/NA.html'>is.na</a></span><span class='o'>(</span><span class='nv'>body_mass_g</span><span class='o'>)</span> <span class='o'>~</span> <span class='kc'>NA</span>,</span>
<span>      <span class='nv'>body_mass_g</span> <span class='o'>&lt;</span> <span class='m'>3550</span> <span class='o'>~</span> <span class='s'>"Small"</span>,</span>
<span>      <span class='nf'><a href='https://dplyr.tidyverse.org/reference/between.html'>between</a></span><span class='o'>(</span><span class='nv'>body_mass_g</span>, <span class='m'>3550</span>, <span class='m'>4750</span><span class='o'>)</span> <span class='o'>~</span> <span class='s'>"Medium"</span>,</span>
<span>      .default <span class='o'>=</span> <span class='s'>"Large"</span></span>
<span>    <span class='o'>)</span></span>
<span>  <span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/relocate.html'>relocate</a></span><span class='o'>(</span><span class='nv'>body_mass_g</span>, <span class='nv'>bm_cat</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 344 × 9</span></span></span>
<span><span class='c'>#&gt;    body_mass_g bm_cat species island    bill_length_mm bill_depth_mm</span></span>
<span><span class='c'>#&gt;          <span style='color: #555555; font-style: italic;'>&lt;int&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>  <span style='color: #555555; font-style: italic;'>&lt;fct&gt;</span>   <span style='color: #555555; font-style: italic;'>&lt;fct&gt;</span>              <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>         <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 1</span>        <span style='text-decoration: underline;'>3</span>750 Medium Adelie  Torgersen           39.1          18.7</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 2</span>        <span style='text-decoration: underline;'>3</span>800 Medium Adelie  Torgersen           39.5          17.4</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 3</span>        <span style='text-decoration: underline;'>3</span>250 Small  Adelie  Torgersen           40.3          18  </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 4</span>          <span style='color: #BB0000;'>NA</span> <span style='color: #BB0000;'>NA</span>     Adelie  Torgersen           <span style='color: #BB0000;'>NA</span>            <span style='color: #BB0000;'>NA</span>  </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 5</span>        <span style='text-decoration: underline;'>3</span>450 Small  Adelie  Torgersen           36.7          19.3</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 6</span>        <span style='text-decoration: underline;'>3</span>650 Medium Adelie  Torgersen           39.3          20.6</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 7</span>        <span style='text-decoration: underline;'>3</span>625 Medium Adelie  Torgersen           38.9          17.8</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 8</span>        <span style='text-decoration: underline;'>4</span>675 Medium Adelie  Torgersen           39.2          19.6</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 9</span>        <span style='text-decoration: underline;'>3</span>475 Small  Adelie  Torgersen           34.1          18.1</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>10</span>        <span style='text-decoration: underline;'>4</span>250 Medium Adelie  Torgersen           42            20.2</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># ℹ 334 more rows</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># ℹ 3 more variables: flipper_length_mm &lt;int&gt;, sex &lt;fct&gt;, year &lt;int&gt;</span></span></span>
<span></span></code></pre>

</div>

### `if_else()`

Similarly, [`if_else()`](https://dplyr.tidyverse.org/reference/if_else.html) is no longer as strict about typed missing values either.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>penguins</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/mutate.html'>mutate</a></span><span class='o'>(</span></span>
<span>    bm_unit <span class='o'>=</span> <span class='nf'><a href='https://dplyr.tidyverse.org/reference/if_else.html'>if_else</a></span><span class='o'>(</span><span class='o'>!</span><span class='nf'><a href='https://rdrr.io/r/base/NA.html'>is.na</a></span><span class='o'>(</span><span class='nv'>body_mass_g</span><span class='o'>)</span>, <span class='nf'><a href='https://rdrr.io/r/base/paste.html'>paste</a></span><span class='o'>(</span><span class='nv'>body_mass_g</span>, <span class='s'>"g"</span><span class='o'>)</span>, <span class='kc'>NA</span><span class='o'>)</span></span>
<span>  <span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/relocate.html'>relocate</a></span><span class='o'>(</span><span class='nv'>body_mass_g</span>, <span class='nv'>bm_unit</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 344 × 9</span></span></span>
<span><span class='c'>#&gt;    body_mass_g bm_unit species island    bill_length_mm bill_depth_mm</span></span>
<span><span class='c'>#&gt;          <span style='color: #555555; font-style: italic;'>&lt;int&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>   <span style='color: #555555; font-style: italic;'>&lt;fct&gt;</span>   <span style='color: #555555; font-style: italic;'>&lt;fct&gt;</span>              <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>         <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 1</span>        <span style='text-decoration: underline;'>3</span>750 3750 g  Adelie  Torgersen           39.1          18.7</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 2</span>        <span style='text-decoration: underline;'>3</span>800 3800 g  Adelie  Torgersen           39.5          17.4</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 3</span>        <span style='text-decoration: underline;'>3</span>250 3250 g  Adelie  Torgersen           40.3          18  </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 4</span>          <span style='color: #BB0000;'>NA</span> <span style='color: #BB0000;'>NA</span>      Adelie  Torgersen           <span style='color: #BB0000;'>NA</span>            <span style='color: #BB0000;'>NA</span>  </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 5</span>        <span style='text-decoration: underline;'>3</span>450 3450 g  Adelie  Torgersen           36.7          19.3</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 6</span>        <span style='text-decoration: underline;'>3</span>650 3650 g  Adelie  Torgersen           39.3          20.6</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 7</span>        <span style='text-decoration: underline;'>3</span>625 3625 g  Adelie  Torgersen           38.9          17.8</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 8</span>        <span style='text-decoration: underline;'>4</span>675 4675 g  Adelie  Torgersen           39.2          19.6</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 9</span>        <span style='text-decoration: underline;'>3</span>475 3475 g  Adelie  Torgersen           34.1          18.1</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>10</span>        <span style='text-decoration: underline;'>4</span>250 4250 g  Adelie  Torgersen           42            20.2</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># ℹ 334 more rows</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># ℹ 3 more variables: flipper_length_mm &lt;int&gt;, sex &lt;fct&gt;, year &lt;int&gt;</span></span></span>
<span></span></code></pre>

</div>

While these may be seemingly small improvements, I think they have huge benefits for teaching and learning. It's a blessing to not have to introduce `NA_character_` and friends as early as introducing [`if_else()`](https://dplyr.tidyverse.org/reference/if_else.html) and [`case_when()`](https://dplyr.tidyverse.org/reference/case_when.html)! Different types of `NA`s are a good topic for a course on R as a programming language, statistical computing, etc. but they are unnecessarily complex for an introductory course.

## New syntax for separating columns

The following table summarizes new syntax for separating columns in tidyr that supersede [`extract()`](https://tidyr.tidyverse.org/reference/extract.html), [`separate()`](https://tidyr.tidyverse.org/reference/separate.html), and [`separate_rows()`](https://tidyr.tidyverse.org/reference/separate_rows.html). These updates are motivated by the goal of achieving a set of functions that have more consistent names and arguments, have better performance, and provide a new approach for handling problems:

|                                  | **MAKE COLUMNS**                                                                               | **MAKE ROWS**                                                                                    |
|:----------------|:---------------------------|:---------------------------|
| Separate with delimiter          | [`separate_wider_delim()`](https://tidyr.tidyverse.org/reference/separate_wider_delim.html)    | [`separate_longer_delim()`](https://tidyr.tidyverse.org/reference/separate_longer_delim.html)    |
| Separate by position             | [`separate_wider_position()`](https://tidyr.tidyverse.org/reference/separate_wider_delim.html) | [`separate_longer_position()`](https://tidyr.tidyverse.org/reference/separate_longer_delim.html) |
| Separate with regular expression |                                                                                                |                                                                                                  |

Here is an example for using some of these functions. Let's suppose we have data on three penguins with their descriptions.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>three_penguin_descriptions</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://tibble.tidyverse.org/reference/tribble.html'>tribble</a></span><span class='o'>(</span></span>
<span>  <span class='o'>~</span><span class='nv'>id</span>, <span class='o'>~</span><span class='nv'>description</span>,</span>
<span>  <span class='m'>1</span>,   <span class='s'>"Species: Adelie, Island - Torgersen"</span>,</span>
<span>  <span class='m'>2</span>,   <span class='s'>"Species: Gentoo, Island - Biscoe"</span>,</span>
<span>  <span class='m'>3</span>,   <span class='s'>"Species: Chinstrap, Island - Dream"</span>,</span>
<span><span class='o'>)</span></span>
<span></span>
<span><span class='nv'>three_penguin_descriptions</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 3 × 2</span></span></span>
<span><span class='c'>#&gt;      id description                        </span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>                              </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span>     1 Species: Adelie, Island - Torgersen</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span>     2 Species: Gentoo, Island - Biscoe   </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>3</span>     3 Species: Chinstrap, Island - Dream</span></span>
<span></span></code></pre>

</div>

We can seaprate the description column into `species` and `island` with [`separate_wider_delim()`](https://tidyr.tidyverse.org/reference/separate_wider_delim.html):

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>three_penguin_descriptions</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://tidyr.tidyverse.org/reference/separate_wider_delim.html'>separate_wider_delim</a></span><span class='o'>(</span></span>
<span>    cols <span class='o'>=</span> <span class='nv'>description</span>,</span>
<span>    delim <span class='o'>=</span> <span class='s'>", "</span>,</span>
<span>    names <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"species"</span>, <span class='s'>"island"</span><span class='o'>)</span></span>
<span>  <span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 3 × 3</span></span></span>
<span><span class='c'>#&gt;      id species            island            </span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>              <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>             </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span>     1 Species: Adelie    Island - Torgersen</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span>     2 Species: Gentoo    Island - Biscoe   </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>3</span>     3 Species: Chinstrap Island - Dream</span></span>
<span></span></code></pre>

</div>

Or we can do so with regular expressions:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>three_penguin_descriptions</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://tidyr.tidyverse.org/reference/separate_wider_delim.html'>separate_wider_regex</a></span><span class='o'>(</span></span>
<span>    cols <span class='o'>=</span> <span class='nv'>description</span>,</span>
<span>    patterns <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span></span>
<span>      <span class='s'>"Species: "</span>, species <span class='o'>=</span> <span class='s'>"[^,]+"</span>, </span>
<span>      <span class='s'>", "</span>, </span>
<span>      <span class='s'>"Island - "</span>, island <span class='o'>=</span> <span class='s'>".*"</span></span>
<span>    <span class='o'>)</span></span>
<span>  <span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 3 × 3</span></span></span>
<span><span class='c'>#&gt;      id species   island   </span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>     <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>    </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span>     1 Adelie    Torgersen</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span>     2 Gentoo    Biscoe   </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>3</span>     3 Chinstrap Dream</span></span>
<span></span></code></pre>

</div>

If teaching folks coming from doing data manipulation in spreadsheets, leverage that to motivate different types of `separate_*()` functions, and show the benefits of programming over point-and-click software for more advanced operations like separating longer and separating with regular expressions.

## New argument for line geoms: `linewidth`

If you, like me, have a bunch of scatterplots with smooth lines overlaid on them, you might run into the following warning.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='c'># previously</span></span>
<span><span class='nv'>penguins</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://tidyr.tidyverse.org/reference/drop_na.html'>drop_na</a></span><span class='o'>(</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggplot.html'>ggplot</a></span><span class='o'>(</span><span class='nf'><a href='https://ggplot2.tidyverse.org/reference/aes.html'>aes</a></span><span class='o'>(</span>x <span class='o'>=</span> <span class='nv'>flipper_length_mm</span>, y <span class='o'>=</span> <span class='nv'>body_mass_g</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/geom_smooth.html'>geom_smooth</a></span><span class='o'>(</span>size <span class='o'>=</span> <span class='m'>2</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; Warning: Using `size` aesthetic for lines was deprecated in ggplot2 3.4.0.</span></span>
<span><span class='c'>#&gt; <span style='color: #00BBBB;'>ℹ</span> Please use `linewidth` instead.</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>This warning is displayed once every 8 hours.</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>Call `lifecycle::last_lifecycle_warnings()` to see where this warning was</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>generated.</span></span></span>
<span></span><span><span class='c'>#&gt; `geom_smooth()` using method = 'loess' and formula = 'y ~ x'</span></span>
<span></span></code></pre>
<img src="figs/unnamed-chunk-42-1.png" width="700px" style="display: block; margin: auto;" />

</div>

Instead of `size`, you should now be using `linewidth`.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='c'># now</span></span>
<span><span class='nv'>penguins</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://tidyr.tidyverse.org/reference/drop_na.html'>drop_na</a></span><span class='o'>(</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggplot.html'>ggplot</a></span><span class='o'>(</span><span class='nf'><a href='https://ggplot2.tidyverse.org/reference/aes.html'>aes</a></span><span class='o'>(</span>x <span class='o'>=</span> <span class='nv'>flipper_length_mm</span>, y <span class='o'>=</span> <span class='nv'>body_mass_g</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/geom_smooth.html'>geom_smooth</a></span><span class='o'>(</span>linewidth <span class='o'>=</span> <span class='m'>2</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; `geom_smooth()` using method = 'loess' and formula = 'y ~ x'</span></span>
<span></span></code></pre>
<img src="figs/unnamed-chunk-43-1.png" width="700px" style="display: block; margin: auto;" />

</div>

The teaching tip should be obvious here... Check the output of your old teaching materials thoroughly to not make a fool of yourself when teaching! 🤣

## Other highlights

-   purrr 1.0.0: While purrr is likely not a common topic in introductory data science curricula, if you do teach iteration with purrr, you'll want to check out the [purrr 1.0.0 blog post](https://www.tidyverse.org/blog/2022/12/purrr-1-0-0/). I also highly recommend [Hadley's purrr video](https://youtu.be/EGAs7zuRutY) to those who are new to purrr as well as those who want to quickly review most recent updates to it.

-   webR 0.1.0: webR provides a framework for creating websites where users can run R code directly within the web browser, without R installed on their device or a supporting computational R server. This is hugely exciting for writing educational materials, like interactive lesson notes, and there's already a Quarto extension that allows you to do this: <https://github.com/coatless/quarto-webr>. I think this is an important space to watch for educators!

