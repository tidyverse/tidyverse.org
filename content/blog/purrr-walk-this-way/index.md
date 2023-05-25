---
output: hugodown::hugo_document

slug: purrr-walk-this-way
title: "`purrr::walk()` this way"
date: 2023-05-25
author: Mara Averick
description: >
    How to use `purrr::walk()` to write many files, 
    featuring file-system navigation with the fs package.
photo:
  url: https://unsplash.com/photos/TRJjPc0wss0
  author: Ryoji Iwata

# one of: "deep-dive", "learn", "package", "programming", "roundup", or "other"
categories: [learn] 
tags: [purrr, fs]
rmd_hash: 9dd0700e4952a9ac

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
* [ ] Add intro sentence, e.g. the standard tagline for the package
* [ ] [`usethis::use_tidy_thanks()`](https://usethis.r-lib.org/reference/use_tidy_thanks.html)
-->

## Meet the `map()` family

purrr's [`map()`](https://purrr.tidyverse.org/reference/map.html) family of functions are tools for **iteration**, performing the same action on multiple inputs. If you're new to purrr, the [Iteration chapter](https://r4ds.had.co.nz/iteration.html#iteration) of R for Data Science is a good place to get started.

One of the benefits of using [`map()`](https://purrr.tidyverse.org/reference/map.html) is that the function has variants (e.g. [`map2()`](https://purrr.tidyverse.org/reference/map2.html), [`pmap()`](https://purrr.tidyverse.org/reference/pmap.html), etc.) all of which work the same way. To borrow from Jennifer Thompson's excellent [Intro to purrr](https://github.com/jenniferthompson/RLadiesIntroToPurrr),the arguments can be broken into two groups: what we're iterating over, and what we're doing each time. The adapted figure below shows what this looks like for [`map()`](https://purrr.tidyverse.org/reference/map.html), [`map2()`](https://purrr.tidyverse.org/reference/map2.html), and [`pmap()`](https://purrr.tidyverse.org/reference/pmap.html).

<div class="highlight">

<div class="figure" style="text-align: center">

<img src="purrr-map-args.png" alt="Highlighted titles read: what we're iterating over, and what we're doing each time. For map(.x = , .f = ) .x is what we're iterating over and .f is what we're doing each time. For map2(.x = , .y = , .f = ) .x and .y are what we're iterating over and .f is what we're doing each time. For pmap(.l = list(), .f = ) .l is what we're iterating over and .f is what we're doing each time." width="700px" />
<p class="caption">
Grouped map function arguments, adapted from Intro to purrr by Jennifer Thompson'
</p>

</div>

</div>

In addition to handling different input arguments, the map family of functions has variants that create different outputs. The following table from the [Map-variants section of Advanced R](https://adv-r.hadley.nz/functionals.html#map-variants) shows how the orthogonal inputs and outputs can be used to organise the variants into a matrix:

|                      | List     | Atomic            | Same type   | Nothing   |
|----------------------|----------|-------------------|-------------|-----------|
| One argument         | [`map()`](https://purrr.tidyverse.org/reference/map.html)  | [`map_lgl()`](https://purrr.tidyverse.org/reference/map.html), ...  | [`modify()`](https://purrr.tidyverse.org/reference/modify.html)  | [`walk()`](https://purrr.tidyverse.org/reference/map.html)  |
| Two arguments        | [`map2()`](https://purrr.tidyverse.org/reference/map2.html) | [`map2_lgl()`](https://purrr.tidyverse.org/reference/map2.html), ... | [`modify2()`](https://purrr.tidyverse.org/reference/modify.html) | [`walk2()`](https://purrr.tidyverse.org/reference/map2.html) |
| One argument + index | [`imap()`](https://purrr.tidyverse.org/reference/imap.html) | [`imap_lgl()`](https://purrr.tidyverse.org/reference/imap.html), ... | [`imodify()`](https://purrr.tidyverse.org/reference/modify.html) | [`iwalk()`](https://purrr.tidyverse.org/reference/imap.html) |
| N arguments          | [`pmap()`](https://purrr.tidyverse.org/reference/pmap.html) | [`pmap_lgl()`](https://purrr.tidyverse.org/reference/pmap.html), ... | ---         | [`pwalk()`](https://purrr.tidyverse.org/reference/pmap.html) |

## What's up with `walk()`?

Based on the table above, you might think that [`walk()`](https://purrr.tidyverse.org/reference/map.html) isn't very useful. Indeed, [`walk()`](https://purrr.tidyverse.org/reference/map.html), [`walk2()`](https://purrr.tidyverse.org/reference/map2.html), and [`pwalk()`](https://purrr.tidyverse.org/reference/pmap.html) all invisibly return `.x`. However, they come in handy when you want to call a function for its ***side effects*** rather than its return value.

Here, we'll go through two common use cases: saving multiple CSVs, and multiple plots. We'll also make use of the [fs](https://fs.r-lib.org/) package, a cross-platform interface to file system operations, to inspect our outputs.

If you want to try this out but don't want to save files locally, there's a [companion project on **Posit Cloud**](https://posit.cloud/content/5983147) where you can follow along.

## Writing (and deleting) multiple CSVs

To get started, we'll need some data. Let's use the [gapminder](https://googlesheets4.tidyverse.org/reference/gs4_examples.html) example Sheet built into [googlesheets4](https://googlesheets4.tidyverse.org/). Because there are multiple worksheets (one for each continent), we'll use [`map()`](https://purrr.tidyverse.org/reference/map.html) to apply [`read_sheet()`](https://googlesheets4.tidyverse.org/reference/range_read.html)[^1] to each one, and get back a list of data frames.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://tidyverse.tidyverse.org'>tidyverse</a></span><span class='o'>)</span></span>
<span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://googlesheets4.tidyverse.org'>googlesheets4</a></span><span class='o'>)</span></span></code></pre>

</div>

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='c'># since we're using data built into googlesheets4 we don't need to auth</span></span>
<span><span class='nf'><a href='https://googlesheets4.tidyverse.org/reference/gs4_deauth.html'>gs4_deauth</a></span><span class='o'>(</span><span class='o'>)</span></span>
<span><span class='nv'>ss</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://googlesheets4.tidyverse.org/reference/gs4_examples.html'>gs4_example</a></span><span class='o'>(</span><span class='s'>"gapminder"</span><span class='o'>)</span> <span class='c'># get sheet id</span></span>
<span><span class='nv'>sheets</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://googlesheets4.tidyverse.org/reference/sheet_properties.html'>sheet_names</a></span><span class='o'>(</span><span class='nv'>ss</span><span class='o'>)</span> <span class='c'># get the names of individual sheets</span></span>
<span><span class='nv'>gap_dfs</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://purrr.tidyverse.org/reference/map.html'>map</a></span><span class='o'>(</span><span class='nv'>sheets</span>, .f <span class='o'>=</span> \<span class='o'>(</span><span class='nv'>x</span><span class='o'>)</span> <span class='nf'><a href='https://googlesheets4.tidyverse.org/reference/range_read.html'>read_sheet</a></span><span class='o'>(</span><span class='nv'>ss</span>, sheet <span class='o'>=</span> <span class='nv'>x</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #00BB00;'>✔</span> Reading from <span style='color: #00BBBB;'>gapminder</span>.</span></span>
<span></span><span><span class='c'>#&gt; <span style='color: #00BB00;'>✔</span> Range '<span style='color: #BBBB00;'>'Africa'</span>'.</span></span>
<span></span><span><span class='c'>#&gt; <span style='color: #00BB00;'>✔</span> Reading from <span style='color: #00BBBB;'>gapminder</span>.</span></span>
<span></span><span><span class='c'>#&gt; <span style='color: #00BB00;'>✔</span> Range '<span style='color: #BBBB00;'>'Americas'</span>'.</span></span>
<span></span><span><span class='c'>#&gt; <span style='color: #00BB00;'>✔</span> Reading from <span style='color: #00BBBB;'>gapminder</span>.</span></span>
<span></span><span><span class='c'>#&gt; <span style='color: #00BB00;'>✔</span> Range '<span style='color: #BBBB00;'>'Asia'</span>'.</span></span>
<span></span><span><span class='c'>#&gt; <span style='color: #00BB00;'>✔</span> Reading from <span style='color: #00BBBB;'>gapminder</span>.</span></span>
<span></span><span><span class='c'>#&gt; <span style='color: #00BB00;'>✔</span> Range '<span style='color: #BBBB00;'>'Europe'</span>'.</span></span>
<span></span><span><span class='c'>#&gt; <span style='color: #00BB00;'>✔</span> Reading from <span style='color: #00BBBB;'>gapminder</span>.</span></span>
<span></span><span><span class='c'>#&gt; <span style='color: #00BB00;'>✔</span> Range '<span style='color: #BBBB00;'>'Oceania'</span>'.</span></span>
<span></span></code></pre>

</div>

Note that the backslash syntax for anonymous functions (e.g. `\(x) x +1`) was introduced in base R version 4.1.0. If you're using an earlier version of R, you can use a formula instead (e.g. `~ .x + 1`).

Typically, you'd want to combine these data frames into one for the purposes of working with the data in R. To do so, we'll use [`list_rbind()`](https://purrr.tidyverse.org/reference/list_c.html) on `gap_dfs`. I've kept the intermediary object, since we'll use it in a moment with [`walk()`](https://purrr.tidyverse.org/reference/map.html), but could have just as easily piped the output directly. The combination of [`purrr::map()` and `list_rbind()`](https://r4ds.hadley.nz/iteration.html?#purrrmap-and-list_rbind) is a handy one you can learn more about in the linked section of R for Data Science.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>gap_combined</span> <span class='o'>&lt;-</span> <span class='nv'>gap_dfs</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://purrr.tidyverse.org/reference/list_c.html'>list_rbind</a></span><span class='o'>(</span><span class='o'>)</span></span></code></pre>

</div>

Now let's say that, for whatever reason, you'd like to save the data from these sheets as individual CSVs. This is where [`walk()`](https://purrr.tidyverse.org/reference/map.html) comes into play---writing out the file with [`write_csv()`](https://readr.tidyverse.org/reference/write_delim.html) is a "side effect." We'll use [`fs::dir_create()`](https://fs.r-lib.org/reference/create.html) to create a data folder to put our files into[^2], and build a vector of paths/file names. Since we have two arguments, the list of data frames, and the paths, we'll use [`walk2()`](https://purrr.tidyverse.org/reference/map2.html).

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'>fs</span><span class='nf'>::</span><span class='nf'><a href='https://fs.r-lib.org/reference/create.html'>dir_create</a></span><span class='o'>(</span><span class='s'>"data"</span><span class='o'>)</span></span>
<span><span class='nv'>paths</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://stringr.tidyverse.org/reference/str_glue.html'>str_glue</a></span><span class='o'>(</span><span class='s'>"data/gapminder_&#123;tolower(sheets)&#125;.csv"</span><span class='o'>)</span></span>
<span><span class='nf'><a href='https://purrr.tidyverse.org/reference/map2.html'>walk2</a></span><span class='o'>(</span><span class='nv'>gap_dfs</span>, <span class='nv'>paths</span>, <span class='nv'>write_csv</span><span class='o'>)</span></span></code></pre>

</div>

To see what we've done, we can use [`fs::dir_tree()`](https://fs.r-lib.org/reference/dir_tree.html) to see the contents of the directory as a tree, or [`fs::dir_ls()`](https://fs.r-lib.org/reference/dir_ls.html) to return the paths as a list.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'>fs</span><span class='nf'>::</span><span class='nf'><a href='https://fs.r-lib.org/reference/dir_tree.html'>dir_tree</a></span><span class='o'>(</span><span class='s'>"data"</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #0000BB; font-weight: bold;'>data</span></span></span>
<span><span class='c'>#&gt; ├── gapminder_africa.csv</span></span>
<span><span class='c'>#&gt; ├── gapminder_americas.csv</span></span>
<span><span class='c'>#&gt; ├── gapminder_asia.csv</span></span>
<span><span class='c'>#&gt; ├── gapminder_europe.csv</span></span>
<span><span class='c'>#&gt; └── gapminder_oceania.csv</span></span>
<span></span><span><span class='nf'>fs</span><span class='nf'>::</span><span class='nf'><a href='https://fs.r-lib.org/reference/dir_ls.html'>dir_ls</a></span><span class='o'>(</span><span class='s'>"data"</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; data/gapminder_africa.csv   data/gapminder_americas.csv </span></span>
<span><span class='c'>#&gt; data/gapminder_asia.csv     data/gapminder_europe.csv   </span></span>
<span><span class='c'>#&gt; data/gapminder_oceania.csv</span></span>
<span></span></code></pre>

</div>

If you're having regrets, or want to return your example project to its previous state, it's just as easy to [`walk()`](https://purrr.tidyverse.org/reference/map.html) [`fs::file_delete()`](https://fs.r-lib.org/reference/delete.html) along those same paths.[^3]

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://purrr.tidyverse.org/reference/map.html'>walk</a></span><span class='o'>(</span><span class='nv'>paths</span>, <span class='nf'>fs</span><span class='nf'>::</span><span class='nv'><a href='https://fs.r-lib.org/reference/delete.html'>file_delete</a></span><span class='o'>)</span></span></code></pre>

</div>

## Saving multiple plots

Now, let's say you want to create and save a bunch of plots. We'll use a modified version of the [`conditional_bars()`](https://r4ds.hadley.nz/functions.html#combining-with-other-tidyverse)[^4] function from the R for Data Science chapter on writing [functions](https://r4ds.hadley.nz/functions.html), and the built-in [diamonds](https://ggplot2.tidyverse.org/reference/diamonds.html) dataset.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='c'># modified conditional bars function from R4DS</span></span>
<span><span class='nv'>conditional_bars</span> <span class='o'>&lt;-</span> <span class='kr'>function</span><span class='o'>(</span><span class='nv'>df</span>, <span class='nv'>condition</span>, <span class='nv'>var</span><span class='o'>)</span> <span class='o'>&#123;</span></span>
<span>  <span class='nv'>df</span> <span class='o'>|&gt;</span></span>
<span>    <span class='nf'><a href='https://dplyr.tidyverse.org/reference/filter.html'>filter</a></span><span class='o'>(</span><span class='o'>&#123;</span><span class='o'>&#123;</span> <span class='nv'>condition</span> <span class='o'>&#125;</span><span class='o'>&#125;</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>    <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggplot.html'>ggplot</a></span><span class='o'>(</span><span class='nf'><a href='https://ggplot2.tidyverse.org/reference/aes.html'>aes</a></span><span class='o'>(</span>x <span class='o'>=</span> <span class='o'>&#123;</span><span class='o'>&#123;</span> <span class='nv'>var</span> <span class='o'>&#125;</span><span class='o'>&#125;</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>    <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/geom_bar.html'>geom_bar</a></span><span class='o'>(</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>    <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/labs.html'>ggtitle</a></span><span class='o'>(</span><span class='nf'>rlang</span><span class='nf'>::</span><span class='nf'><a href='https://rlang.r-lib.org/reference/englue.html'>englue</a></span><span class='o'>(</span><span class='s'>"Count of diamonds by &#123;&#123;var&#125;&#125; where &#123;&#123;condition&#125;&#125;"</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='o'>&#125;</span></span></code></pre>

</div>

It's easy enough to run this for one condition, for example for the diamonds with `cut == "Good"`.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>diamonds</span> <span class='o'>|&gt;</span> <span class='nf'>conditional_bars</span><span class='o'>(</span><span class='nv'>cut</span> <span class='o'>==</span> <span class='s'>"Good"</span>, <span class='nv'>clarity</span><span class='o'>)</span></span>
</code></pre>
<img src="figs/goodclarity-1.png" alt="Bar chart showing count of diamonds by clarity in the diamonds dataset where the cut == Good." width="700px" style="display: block; margin: auto;" />

</div>

But what if we want to make a and save plot for each cut? Again, it's [`map()`](https://purrr.tidyverse.org/reference/map.html) and [`walk()`](https://purrr.tidyverse.org/reference/map.html) to the rescue.

Because we're using the same data (`diamonds`) and conditioning on the same variable (`cut`), we'll only need to [`map()`](https://purrr.tidyverse.org/reference/map.html) across the levels of `cut`, and can hard code the rest into the anonymous function.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='c'># get the levels</span></span>
<span><span class='nv'>cuts</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/levels.html'>levels</a></span><span class='o'>(</span><span class='nv'>diamonds</span><span class='o'>$</span><span class='nv'>cut</span><span class='o'>)</span></span>
<span></span>
<span><span class='c'># make the plots</span></span>
<span><span class='nv'>plots</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://purrr.tidyverse.org/reference/map.html'>map</a></span><span class='o'>(</span></span>
<span>  <span class='nv'>cuts</span>, </span>
<span>  \<span class='o'>(</span><span class='nv'>x</span><span class='o'>)</span> <span class='nf'>conditional_bars</span><span class='o'>(</span>df <span class='o'>=</span> <span class='nv'>diamonds</span>, <span class='nv'>cut</span> <span class='o'>==</span> <span class='o'>&#123;</span><span class='o'>&#123;</span> <span class='nv'>x</span> <span class='o'>&#125;</span><span class='o'>&#125;</span>, <span class='nv'>clarity</span><span class='o'>)</span></span>
<span>  <span class='o'>)</span></span></code></pre>

</div>

As we did when saving our CSVs, we'll use fs to create a directory to store them in, and make a vector of paths for file names.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='c'># make the folder to put them it (if exists, &#123;fs&#125; does nothing)</span></span>
<span><span class='nf'>fs</span><span class='nf'>::</span><span class='nf'><a href='https://fs.r-lib.org/reference/create.html'>dir_create</a></span><span class='o'>(</span><span class='s'>"plots"</span><span class='o'>)</span></span>
<span><span class='c'># make the file names</span></span>
<span><span class='nv'>plot_paths</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://stringr.tidyverse.org/reference/str_glue.html'>str_glue</a></span><span class='o'>(</span><span class='s'>"plots/&#123;tolower(cuts)&#125;_clarity.png"</span><span class='o'>)</span></span></code></pre>

</div>

Now we can use the paths and plots with [`walk2()`](https://purrr.tidyverse.org/reference/map2.html) to pass them as arguments to [`ggsave()`](https://ggplot2.tidyverse.org/reference/ggsave.html). Note that, rather than putting constant arguments (such as height and width) in `…`, we pass them directly into [`ggsave()`](https://ggplot2.tidyverse.org/reference/ggsave.html) in an anonymous function.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://purrr.tidyverse.org/reference/map2.html'>walk2</a></span><span class='o'>(</span></span>
<span>  <span class='nv'>plot_paths</span>,</span>
<span>  <span class='nv'>plots</span>,</span>
<span>  \<span class='o'>(</span><span class='nv'>path</span>, <span class='nv'>plot</span><span class='o'>)</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggsave.html'>ggsave</a></span><span class='o'>(</span><span class='nv'>path</span>, <span class='nv'>plot</span>, width <span class='o'>=</span> <span class='m'>6</span>, height <span class='o'>=</span> <span class='m'>6</span><span class='o'>)</span></span>
<span><span class='o'>)</span></span></code></pre>

</div>

Again, we can use fs to see what we've done:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'>fs</span><span class='nf'>::</span><span class='nf'><a href='https://fs.r-lib.org/reference/dir_tree.html'>dir_tree</a></span><span class='o'>(</span><span class='s'>"plots"</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #0000BB; font-weight: bold;'>plots</span></span></span>
<span><span class='c'>#&gt; ├── <span style='color: #BB00BB; font-weight: bold;'>fair_clarity.png</span></span></span>
<span><span class='c'>#&gt; ├── <span style='color: #BB00BB; font-weight: bold;'>good_clarity.png</span></span></span>
<span><span class='c'>#&gt; ├── <span style='color: #BB00BB; font-weight: bold;'>ideal_clarity.png</span></span></span>
<span><span class='c'>#&gt; ├── <span style='color: #BB00BB; font-weight: bold;'>premium_clarity.png</span></span></span>
<span><span class='c'>#&gt; └── <span style='color: #BB00BB; font-weight: bold;'>very good_clarity.png</span></span></span>
<span></span></code></pre>

</div>

And, clean up after ourselves if we didn't *really* want those plots after all.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://purrr.tidyverse.org/reference/map.html'>walk</a></span><span class='o'>(</span><span class='nv'>plot_paths</span>, <span class='nf'>fs</span><span class='nf'>::</span><span class='nv'><a href='https://fs.r-lib.org/reference/delete.html'>file_delete</a></span><span class='o'>)</span></span></code></pre>

</div>

## Fin

Hopefully this gave you a taste for some of what [`walk()`](https://purrr.tidyverse.org/reference/map.html) can do. To learn more, see [Saving multiple outputs](https://r4ds.hadley.nz/iteration.html#saving-multiple-outputs) in the Iteration chapter of R for Data Science.

[^1]: See [Getting started with googlesheets4](https://googlesheets4.tidyverse.org/articles/googlesheets4.html) to learn more about the basics of reading and writing sheets.

[^2]: If the directory already exists, it will be left unchanged.

[^3]: There's also a function in fs called [`dir_walk()`](https://fs.r-lib.org/reference/dir_ls.html), which you can feel free to explore on your own.

[^4]: I've added a title that reflects the variable name and condition with [`rlang::englue()`](https://rlang.r-lib.org/reference/englue.html), which you can learn more about in the [Labeling](https://r4ds.hadley.nz/functions.html#labeling) section of the same R4DS chapter.

