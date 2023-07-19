---
output: hugodown::hugo_document

slug: teach-tidyverse-23
title: Teaching the tidyverse in 2023
date: 2023-07-28
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
rmd_hash: 7ca2755e87b74963

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

Specifically, I'll discuss: **TO DO: UPDATE OUTLINE**

-   [Nine core packages in tidyverse 2.0.0](#new-teaching-and-learning-resources)

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

And, let's also load the **palmerpenguins** package that we will use in examples.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://allisonhorst.github.io/palmerpenguins/'>palmerpenguins</a></span><span class='o'>)</span></span></code></pre>

</div>

## Nine core packages in tidyverse 2.0.0

The main update in tidyverse 2.0.0, which was released in March 2023, is that it **lubridate** is now a core tidyverse package. The lubridate package that makes it easier to do the things R does with date-times, is now a core tidyverse package. So, while many of your scripts in the past may have started with

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

Additionally, the package loading message for the tidyverse now advertises the **conflicted** package.

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

The **dplyr** package has long had the `*_join()` family of functions for joining data frames.

New functionality for join functions includes a new [`join_by()`](https://dplyr.tidyverse.org/reference/join_by.html) function for the `by` argument. So, while in the past your code may have looked like the following:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'># previously
x |>
  *_join(
    y, 
    by = c("<x var>" = "<y var>")
  )
</code></pre>

</div>

you can now do

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'># now, optionally
x |>
  *_join(
    y, 
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

## Acknowledgements

