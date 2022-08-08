---
output: hugodown::hugo_document

slug: rsample-1-1-0
title: rsample 1.1.0
date: 2022-08-08
author: Mike Mahoney
description: >
    rsample 1.1.0 is now on CRAN! This release provides a ton of new functions for grouped resampling, as well as a few long-awaited utility functions.

photo:
  url: https://unsplash.com/photos/bukjsECgmeU
  author: Paul Teysen

# one of: "deep-dive", "learn", "package", "programming", "roundup", or "other"
categories: [package] 
tags: [rsample, tidymodels]
rmd_hash: 89edff4ed75ccacd

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
* [x] [`usethis::use_tidy_thanks()`](https://usethis.r-lib.org/reference/use_tidy_thanks.html)
-->

We're downright exhilarated to announce the release of [rsample](https://rsample.tidymodels.org/) 1.1.0. The rsample package makes it easy to create resamples for estimating distributions and assessing model performance.

You can install it from CRAN with:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://rdrr.io/r/utils/install.packages.html'>install.packages</a></span><span class='o'>(</span><span class='s'>"rsample"</span><span class='o'>)</span></code></pre>

</div>

This blog post will walk through some of the highlights from this newest release. You can see a full list of changes in the [release notes](https://rsample.tidymodels.org/news/index.html#rsample-110).

## Grouped Resampling

By far and away the biggest addition in this version of rsample is the set of new functions for grouped resampling. Grouped resampling is a form of resampling where observations need to be assigned to the analysis or assessment sets as a "group", not split between the two. This is a common need when some of your data is more closely related than would be expected under random chance: for instance, when taking multiple measurements of a single patient over time, or when your data is geographically clustered into distinct "locations" like different neighborhoods.

The rsample package has supported grouped v-fold cross-validation for a few years, through the [`group_vfold_cv()`](https://rsample.tidymodels.org/reference/group_vfold_cv.html) function:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='http://purrr.tidyverse.org'>purrr</a></span><span class='o'>)</span>
<span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://rsample.tidymodels.org'>rsample</a></span><span class='o'>)</span>
<span class='nf'><a href='https://rdrr.io/r/utils/data.html'>data</a></span><span class='o'>(</span><span class='nv'>ames</span>, package <span class='o'>=</span> <span class='s'>"modeldata"</span><span class='o'>)</span>

<span class='nv'>resample</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rsample.tidymodels.org/reference/group_vfold_cv.html'>group_vfold_cv</a></span><span class='o'>(</span><span class='nv'>ames</span>, group <span class='o'>=</span> <span class='nv'>Neighborhood</span>, v <span class='o'>=</span> <span class='m'>2</span><span class='o'>)</span>

<span class='nv'>resample</span><span class='o'>$</span><span class='nv'>splits</span> <span class='o'>%&gt;%</span>
  <span class='nf'><a href='https://purrr.tidyverse.org/reference/map.html'>map_lgl</a></span><span class='o'>(</span><span class='kr'>function</span><span class='o'>(</span><span class='nv'>x</span><span class='o'>)</span> <span class='o'>&#123;</span>
    <span class='nf'><a href='https://rdrr.io/r/base/any.html'>any</a></span><span class='o'>(</span><span class='nf'><a href='https://rsample.tidymodels.org/reference/as.data.frame.rsplit.html'>assessment</a></span><span class='o'>(</span><span class='nv'>x</span><span class='o'>)</span><span class='o'>$</span><span class='nv'>Neighborhood</span> <span class='o'>%in%</span> <span class='nf'><a href='https://rsample.tidymodels.org/reference/as.data.frame.rsplit.html'>analysis</a></span><span class='o'>(</span><span class='nv'>x</span><span class='o'>)</span><span class='o'>$</span><span class='nv'>Neighborhood</span><span class='o'>)</span>
  <span class='o'>&#125;</span>
<span class='o'>)</span>
<span class='c'>#&gt; [1] FALSE FALSE</span></code></pre>

</div>

rsample 1.1.0 extends this support by adding four new functions for grouped resampling. The new functions [`group_bootstraps()`](https://rsample.tidymodels.org/reference/group_bootstraps.html), [`group_mc_cv()`](https://rsample.tidymodels.org/reference/group_mc_cv.html), [`group_validation_split()`](https://rsample.tidymodels.org/reference/validation_split.html), and [`group_initial_split()`](https://rsample.tidymodels.org/reference/initial_split.html) all work like their ungrouped versions, but let you specify a grouping column to make sure related observations are all assigned to the same sets:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='c'># Bootstrap resampling with replacement:</span>
<span class='nf'><a href='https://rsample.tidymodels.org/reference/group_bootstraps.html'>group_bootstraps</a></span><span class='o'>(</span><span class='nv'>ames</span>, <span class='nv'>Neighborhood</span>, times <span class='o'>=</span> <span class='m'>1</span><span class='o'>)</span>
<span class='c'>#&gt; # Group bootstrap sampling </span>
<span class='c'>#&gt; <span style='color: #555555;'># A tibble: 1 × 2</span></span>
<span class='c'>#&gt;   splits              id        </span>
<span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;list&gt;</span>              <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>     </span>
<span class='c'>#&gt; <span style='color: #555555;'>1</span> <span style='color: #555555;'>&lt;split [3045/1151]&gt;</span> Bootstrap1</span>


<span class='c'># Random resampling without replacement:</span>
<span class='nf'><a href='https://rsample.tidymodels.org/reference/group_mc_cv.html'>group_mc_cv</a></span><span class='o'>(</span><span class='nv'>ames</span>, <span class='nv'>Neighborhood</span>, times <span class='o'>=</span> <span class='m'>1</span><span class='o'>)</span>
<span class='c'>#&gt; # Group Monte Carlo cross-validation (0.75/0.25) with 1 resamples  </span>
<span class='c'>#&gt; <span style='color: #555555;'># A tibble: 1 × 2</span></span>
<span class='c'>#&gt;   splits             id       </span>
<span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;list&gt;</span>             <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>    </span>
<span class='c'>#&gt; <span style='color: #555555;'>1</span> <span style='color: #555555;'>&lt;split [2205/725]&gt;</span> Resample1</span>


<span class='c'># Data splitting to create a validation set:</span>
<span class='nf'><a href='https://rsample.tidymodels.org/reference/validation_split.html'>group_validation_split</a></span><span class='o'>(</span><span class='nv'>ames</span>, <span class='nv'>Neighborhood</span><span class='o'>)</span>
<span class='c'>#&gt; # Group Validation Set Split (0.75/0.25)  </span>
<span class='c'>#&gt; <span style='color: #555555;'># A tibble: 1 × 2</span></span>
<span class='c'>#&gt;   splits             id        </span>
<span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;list&gt;</span>             <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>     </span>
<span class='c'>#&gt; <span style='color: #555555;'>1</span> <span style='color: #555555;'>&lt;split [2188/742]&gt;</span> validation</span>


<span class='c'># Data splitting to create an initial training/testing split:</span>
<span class='nf'><a href='https://rsample.tidymodels.org/reference/initial_split.html'>group_initial_split</a></span><span class='o'>(</span><span class='nv'>ames</span>, <span class='nv'>Neighborhood</span><span class='o'>)</span>
<span class='c'>#&gt; &lt;Training/Testing/Total&gt;</span>
<span class='c'>#&gt; &lt;2218/712/2930&gt;</span></code></pre>

</div>

These functions all target assigning a certain proportion of your data to the assessment fold. Hitting that target can be tricky when your groups aren't all the same size, however. To work around this, these new functions create a list of all the groups in your data, randomly reshuffle it, and then select the first *n* groups in the list that results in splitting the data as close to that proportion as possible. The net effect of this on users is that your analysis and assessment folds won't always be precisely the size you're targeting (particularly if you have a few large groups), but all data in a single group will always be entirely assigned to the same set and the splits will be entirely randomly created.

The other big change to grouped resampling comes as a new argument to [`group_vfold_cv()`](https://rsample.tidymodels.org/reference/group_vfold_cv.html). By default, [`group_vfold_cv()`](https://rsample.tidymodels.org/reference/group_vfold_cv.html) assigns roughly the same number of groups to each of your folds, so you wind up with the same number of patients, or neighborhoods, or whatever else you're grouping by in each assessment set. The new `balance` argument lets you instead assign roughly the same number of rows to each fold instead, if you set `balance = observations`:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://rsample.tidymodels.org/reference/group_vfold_cv.html'>group_vfold_cv</a></span><span class='o'>(</span><span class='nv'>ames</span>, <span class='nv'>Neighborhood</span>, balance <span class='o'>=</span> <span class='s'>"observations"</span><span class='o'>)</span>
<span class='c'>#&gt; # Group 28-fold cross-validation </span>
<span class='c'>#&gt; <span style='color: #555555;'># A tibble: 28 × 2</span></span>
<span class='c'>#&gt;    splits             id        </span>
<span class='c'>#&gt;    <span style='color: #555555; font-style: italic;'>&lt;list&gt;</span>             <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>     </span>
<span class='c'>#&gt; <span style='color: #555555;'> 1</span> <span style='color: #555555;'>&lt;split [2663/267]&gt;</span> Resample01</span>
<span class='c'>#&gt; <span style='color: #555555;'> 2</span> <span style='color: #555555;'>&lt;split [2859/71]&gt;</span>  Resample02</span>
<span class='c'>#&gt; <span style='color: #555555;'> 3</span> <span style='color: #555555;'>&lt;split [2882/48]&gt;</span>  Resample03</span>
<span class='c'>#&gt; <span style='color: #555555;'> 4</span> <span style='color: #555555;'>&lt;split [2487/443]&gt;</span> Resample04</span>
<span class='c'>#&gt; <span style='color: #555555;'> 5</span> <span style='color: #555555;'>&lt;split [2902/28]&gt;</span>  Resample05</span>
<span class='c'>#&gt; <span style='color: #555555;'> 6</span> <span style='color: #555555;'>&lt;split [2928/2]&gt;</span>   Resample06</span>
<span class='c'>#&gt; <span style='color: #555555;'> 7</span> <span style='color: #555555;'>&lt;split [2837/93]&gt;</span>  Resample07</span>
<span class='c'>#&gt; <span style='color: #555555;'> 8</span> <span style='color: #555555;'>&lt;split [2691/239]&gt;</span> Resample08</span>
<span class='c'>#&gt; <span style='color: #555555;'> 9</span> <span style='color: #555555;'>&lt;split [2748/182]&gt;</span> Resample09</span>
<span class='c'>#&gt; <span style='color: #555555;'>10</span> <span style='color: #555555;'>&lt;split [2799/131]&gt;</span> Resample10</span>
<span class='c'>#&gt; <span style='color: #555555;'># … with 18 more rows</span></span>
<span class='c'>#&gt; <span style='color: #555555;'># ℹ Use `print(n = ...)` to see more rows</span></span></code></pre>

</div>

This approach works in a similar way to the new grouped resampling functions, attempting to assign roughly `1 / v` of your data to each fold. When working with unbalanced groups, this can result in much more even assignments of data to each fold:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://ggplot2.tidyverse.org'>ggplot2</a></span><span class='o'>)</span>
<span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://dplyr.tidyverse.org'>dplyr</a></span><span class='o'>)</span>

<span class='nv'>analysis_sd</span> <span class='o'>&lt;-</span> <span class='kr'>function</span><span class='o'>(</span><span class='nv'>v</span>, <span class='nv'>balance</span><span class='o'>)</span> <span class='o'>&#123;</span>
  <span class='nf'><a href='https://rsample.tidymodels.org/reference/group_vfold_cv.html'>group_vfold_cv</a></span><span class='o'>(</span>
    <span class='nv'>ames</span>, 
    <span class='nv'>Neighborhood</span>, 
    <span class='nv'>v</span>, 
    balance <span class='o'>=</span> <span class='nv'>balance</span>
  <span class='o'>)</span><span class='o'>$</span><span class='nv'>splits</span> <span class='o'>%&gt;%</span> 
    <span class='nf'>purrr</span><span class='nf'>::</span><span class='nf'><a href='https://purrr.tidyverse.org/reference/map.html'>map_dbl</a></span><span class='o'>(</span><span class='o'>~</span> <span class='nf'><a href='https://rdrr.io/r/base/nrow.html'>nrow</a></span><span class='o'>(</span><span class='nf'><a href='https://rsample.tidymodels.org/reference/as.data.frame.rsplit.html'>analysis</a></span><span class='o'>(</span><span class='nv'>.x</span><span class='o'>)</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>%&gt;%</span> 
    <span class='nf'><a href='https://rdrr.io/r/stats/sd.html'>sd</a></span><span class='o'>(</span><span class='o'>)</span>
<span class='o'>&#125;</span>

<span class='nv'>resample</span> <span class='o'>&lt;-</span> <span class='nf'>tidyr</span><span class='nf'>::</span><span class='nf'><a href='https://tidyr.tidyverse.org/reference/expand.html'>crossing</a></span><span class='o'>(</span>
  idx <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/seq.html'>seq_len</a></span><span class='o'>(</span><span class='m'>100</span><span class='o'>)</span>,
  v <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='m'>2</span>, <span class='m'>5</span>, <span class='m'>10</span>, <span class='m'>15</span><span class='o'>)</span>,
  balance <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"groups"</span>, <span class='s'>"observations"</span><span class='o'>)</span>
<span class='o'>)</span>

<span class='nv'>resample</span> <span class='o'>%&gt;%</span>
  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/mutate.html'>mutate</a></span><span class='o'>(</span>sd <span class='o'>=</span> <span class='nf'>purrr</span><span class='nf'>::</span><span class='nf'><a href='https://purrr.tidyverse.org/reference/map2.html'>pmap_dbl</a></span><span class='o'>(</span>
    <span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span><span class='nv'>v</span>, <span class='nv'>balance</span><span class='o'>)</span>,
    <span class='nv'>analysis_sd</span>
  <span class='o'>)</span><span class='o'>)</span> <span class='o'>%&gt;%</span>
  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggplot.html'>ggplot</a></span><span class='o'>(</span><span class='nf'><a href='https://ggplot2.tidyverse.org/reference/aes.html'>aes</a></span><span class='o'>(</span><span class='nv'>sd</span>, fill <span class='o'>=</span> <span class='nv'>balance</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>+</span> 
  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/geom_histogram.html'>geom_histogram</a></span><span class='o'>(</span>alpha <span class='o'>=</span> <span class='m'>0.6</span>, color <span class='o'>=</span> <span class='s'>"black"</span>, size <span class='o'>=</span> <span class='m'>0.3</span><span class='o'>)</span> <span class='o'>+</span> 
  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/facet_wrap.html'>facet_wrap</a></span><span class='o'>(</span><span class='o'>~</span> <span class='nv'>v</span><span class='o'>)</span> <span class='o'>+</span> 
  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggtheme.html'>theme_minimal</a></span><span class='o'>(</span><span class='o'>)</span> <span class='o'>+</span> 
  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/labs.html'>labs</a></span><span class='o'>(</span>title <span class='o'>=</span> <span class='s'>"sd() of nrow(analysis) by balance method"</span><span class='o'>)</span>
</code></pre>
<img src="figs/unnamed-chunk-4-1.png" width="700px" style="display: block; margin: auto;" />

</div>

Right now, these grouping functions don't support stratification. If you have thoughts on how you'd expect stratification to work with grouping, or have an example of how another implementation has handled it, [let us know on GitHub](https://github.com/tidymodels/rsample/issues/317)!

## Other improvements

This release also adds a few new utility functions to make it easier to work with the rsets produced by rsample functions.

For instance, the new [`reshuffle_rset()`](https://rsample.tidymodels.org/reference/reshuffle_rset.html) will re-generate an rset, using the same arguments as were used to originally create it, but with the current random seed:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://rdrr.io/r/base/Random.html'>set.seed</a></span><span class='o'>(</span><span class='m'>123</span><span class='o'>)</span>
<span class='nv'>resample</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rsample.tidymodels.org/reference/vfold_cv.html'>vfold_cv</a></span><span class='o'>(</span><span class='nv'>mtcars</span><span class='o'>)</span>

<span class='nv'>resample</span><span class='o'>$</span><span class='nv'>splits</span><span class='o'>[[</span><span class='m'>1</span><span class='o'>]</span><span class='o'>]</span> <span class='o'>%&gt;%</span>
  <span class='nf'><a href='https://rsample.tidymodels.org/reference/as.data.frame.rsplit.html'>analysis</a></span><span class='o'>(</span><span class='o'>)</span> <span class='o'>%&gt;%</span>
  <span class='nf'><a href='https://rdrr.io/r/utils/head.html'>head</a></span><span class='o'>(</span><span class='o'>)</span>
<span class='c'>#&gt;                    mpg cyl disp  hp drat    wt  qsec vs am gear carb</span>
<span class='c'>#&gt; Mazda RX4 Wag     21.0   6  160 110 3.90 2.875 17.02  0  1    4    4</span>
<span class='c'>#&gt; Datsun 710        22.8   4  108  93 3.85 2.320 18.61  1  1    4    1</span>
<span class='c'>#&gt; Hornet 4 Drive    21.4   6  258 110 3.08 3.215 19.44  1  0    3    1</span>
<span class='c'>#&gt; Hornet Sportabout 18.7   8  360 175 3.15 3.440 17.02  0  0    3    2</span>
<span class='c'>#&gt; Valiant           18.1   6  225 105 2.76 3.460 20.22  1  0    3    1</span>
<span class='c'>#&gt; Duster 360        14.3   8  360 245 3.21 3.570 15.84  0  0    3    4</span>


<span class='nv'>resample</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rsample.tidymodels.org/reference/reshuffle_rset.html'>reshuffle_rset</a></span><span class='o'>(</span><span class='nv'>resample</span><span class='o'>)</span>

<span class='nv'>resample</span><span class='o'>$</span><span class='nv'>splits</span><span class='o'>[[</span><span class='m'>1</span><span class='o'>]</span><span class='o'>]</span> <span class='o'>%&gt;%</span>
  <span class='nf'><a href='https://rsample.tidymodels.org/reference/as.data.frame.rsplit.html'>analysis</a></span><span class='o'>(</span><span class='o'>)</span> <span class='o'>%&gt;%</span>
  <span class='nf'><a href='https://rdrr.io/r/utils/head.html'>head</a></span><span class='o'>(</span><span class='o'>)</span>
<span class='c'>#&gt;                    mpg cyl disp  hp drat    wt  qsec vs am gear carb</span>
<span class='c'>#&gt; Mazda RX4         21.0   6  160 110 3.90 2.620 16.46  0  1    4    4</span>
<span class='c'>#&gt; Mazda RX4 Wag     21.0   6  160 110 3.90 2.875 17.02  0  1    4    4</span>
<span class='c'>#&gt; Datsun 710        22.8   4  108  93 3.85 2.320 18.61  1  1    4    1</span>
<span class='c'>#&gt; Hornet 4 Drive    21.4   6  258 110 3.08 3.215 19.44  1  0    3    1</span>
<span class='c'>#&gt; Hornet Sportabout 18.7   8  360 175 3.15 3.440 17.02  0  0    3    2</span>
<span class='c'>#&gt; Duster 360        14.3   8  360 245 3.21 3.570 15.84  0  0    3    4</span></code></pre>

</div>

This works with repeated cross-validation, stratification, grouping -- anything you did originally should be preserved when reshuffling the rset.

Additionally, the new [`reverse_splits()`](https://rsample.tidymodels.org/reference/reverse_splits.html) function will "swap" the assessment and analysis folds of any rsplit or rset object:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>resample</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rsample.tidymodels.org/reference/initial_split.html'>initial_split</a></span><span class='o'>(</span><span class='nv'>mtcars</span><span class='o'>)</span>
<span class='nv'>resample</span>
<span class='c'>#&gt; &lt;Training/Testing/Total&gt;</span>
<span class='c'>#&gt; &lt;24/8/32&gt;</span>


<span class='nf'><a href='https://rsample.tidymodels.org/reference/reverse_splits.html'>reverse_splits</a></span><span class='o'>(</span><span class='nv'>resample</span><span class='o'>)</span>
<span class='c'>#&gt; &lt;Training/Testing/Total&gt;</span>
<span class='c'>#&gt; &lt;8/24/32&gt;</span></code></pre>

</div>

This is just scratching the surface of the new features and improvements in this release of rsample! You can see a full list of changes in the the [release notes](https://rsample.tidymodels.org/news/index.html#rsample-110).

## Acknowledgements

We'd like to thank everyone that has contributed since the last release: [@DavisVaughan](https://github.com/DavisVaughan), [@juliasilge](https://github.com/juliasilge), [@mattwarkentin](https://github.com/mattwarkentin), [@mikemahoney218](https://github.com/mikemahoney218), and [@sametsoekel](https://github.com/sametsoekel).

