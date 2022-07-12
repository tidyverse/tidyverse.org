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
rmd_hash: b42ae2721dbe279d

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

We're downright exhilarated to announce the release of [rsample](https://rsample.tidymodels.org/) 1.1.0. rsample is a package that makes it easy to create resamples for estimating distributions and assessing model performance.

You can install it from CRAN with:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://rdrr.io/r/utils/install.packages.html'>install.packages</a></span><span class='o'>(</span><span class='s'>"rsample"</span><span class='o'>)</span></code></pre>

</div>

This blog post will walk through some of the highlights from this newest release. You can see a full list of changes in the [release notes](https://rsample.tidymodels.org/news/index.html#rsample-110).

## Grouped Resampling

By far and away the biggest addition in this version of rsample is the set of new functions for grouped resampling. Grouped resampling is a form of resampling where observations need to be assigned to the analysis or assessment sets as a "group", not split between the two. This is a common need when some of your data is more closely related than would be expected under random chance: for instance, when taking multiple measurements of a single patient over time, or when your data is geographically clustered into distinct "locations" like different neighborhoods.

rsample has supported grouped V-fold cross-validation for a few years, through the `grouped_vfold_cv()` function:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='http://purrr.tidyverse.org'>purrr</a></span><span class='o'>)</span>
<span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://rsample.tidymodels.org'>rsample</a></span><span class='o'>)</span>
<span class='nf'><a href='https://rdrr.io/r/utils/data.html'>data</a></span><span class='o'>(</span><span class='nv'>ames</span>, package <span class='o'>=</span> <span class='s'>"modeldata"</span><span class='o'>)</span>

<span class='nv'>resample</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rsample.tidymodels.org/reference/group_vfold_cv.html'>group_vfold_cv</a></span><span class='o'>(</span><span class='nv'>ames</span>, group <span class='o'>=</span> <span class='nv'>Neighborhood</span>, v <span class='o'>=</span> <span class='m'>2</span><span class='o'>)</span>

<span class='nv'>resample</span><span class='o'>$</span><span class='nv'>splits</span> <span class='o'><a href='https://purrr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span>
  <span class='nf'><a href='https://purrr.tidyverse.org/reference/map.html'>map_lgl</a></span><span class='o'>(</span><span class='kr'>function</span><span class='o'>(</span><span class='nv'>x</span><span class='o'>)</span> <span class='o'>&#123;</span>
    <span class='nf'><a href='https://rdrr.io/r/base/any.html'>any</a></span><span class='o'>(</span><span class='nf'><a href='https://rsample.tidymodels.org/reference/as.data.frame.rsplit.html'>assessment</a></span><span class='o'>(</span><span class='nv'>x</span><span class='o'>)</span><span class='o'>$</span><span class='nv'>Neighborhood</span> <span class='o'><a href='https://rdrr.io/r/base/match.html'>%in%</a></span> <span class='nf'><a href='https://rsample.tidymodels.org/reference/as.data.frame.rsplit.html'>analysis</a></span><span class='o'>(</span><span class='nv'>x</span><span class='o'>)</span><span class='o'>$</span><span class='nv'>Neighborhood</span><span class='o'>)</span>
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
<span class='c'>#&gt; <span style='color: #555555;'>1</span> <span style='color: #555555;'>&lt;split [2891/1120]&gt;</span> Bootstrap1</span>

<span class='c'># Random resampling without replacement:</span>
<span class='nf'><a href='https://rsample.tidymodels.org/reference/group_mc_cv.html'>group_mc_cv</a></span><span class='o'>(</span><span class='nv'>ames</span>, <span class='nv'>Neighborhood</span>, times <span class='o'>=</span> <span class='m'>1</span><span class='o'>)</span>
<span class='c'>#&gt; # Group Monte Carlo cross-validation (0.75/0.25) with 1 resamples  </span>
<span class='c'>#&gt; <span style='color: #555555;'># A tibble: 1 × 2</span></span>
<span class='c'>#&gt;   splits             id       </span>
<span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;list&gt;</span>             <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>    </span>
<span class='c'>#&gt; <span style='color: #555555;'>1</span> <span style='color: #555555;'>&lt;split [2163/767]&gt;</span> Resample1</span>

<span class='c'># Data splitting to create a validation set:</span>
<span class='nf'><a href='https://rsample.tidymodels.org/reference/validation_split.html'>group_validation_split</a></span><span class='o'>(</span><span class='nv'>ames</span>, <span class='nv'>Neighborhood</span><span class='o'>)</span>
<span class='c'>#&gt; # Group Validation Set Split (0.75/0.25)  </span>
<span class='c'>#&gt; <span style='color: #555555;'># A tibble: 1 × 2</span></span>
<span class='c'>#&gt;   splits             id        </span>
<span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;list&gt;</span>             <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>     </span>
<span class='c'>#&gt; <span style='color: #555555;'>1</span> <span style='color: #555555;'>&lt;split [2227/703]&gt;</span> validation</span>

<span class='c'># Data splitting to create an initial training/testing split:</span>
<span class='nf'><a href='https://rsample.tidymodels.org/reference/initial_split.html'>group_initial_split</a></span><span class='o'>(</span><span class='nv'>ames</span>, <span class='nv'>Neighborhood</span><span class='o'>)</span>
<span class='c'>#&gt; &lt;Training/Testing/Total&gt;</span>
<span class='c'>#&gt; &lt;2232/698/2930&gt;</span></code></pre>

</div>

These functions all target assigning a certain proportion of your data to the assessment fold. Hitting that target can be tricky when your groups aren't all the same size, however. To work around this, these new functions create a list of all the groups in your data, randomly reshuffle it, and then select the first *n* groups in the list that results in splitting the data as close to that proportion as possible. The net effect of this on users is that your analysis and assessment folds won't always be precisely the size you're targeting (particularly if you have a few large groups), but all data in a single group will always be entirely assigned to the same set and the splits will be entirely randomly created.

The other big change to grouped resampling comes as a new argument to [`group_vfold_cv()`](https://rsample.tidymodels.org/reference/group_vfold_cv.html). By default, [`group_vfold_cv()`](https://rsample.tidymodels.org/reference/group_vfold_cv.html) assigns roughly the same number of groups to each of your folds, so you wind up with the same number of patients, or neighborhoods, or whatever else you're grouping by in each assessment set. The new `balance` argument lets you instead assign roughly the same number of rows to each fold instead, if you set `balance = observations`:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://rsample.tidymodels.org/reference/group_vfold_cv.html'>group_vfold_cv</a></span><span class='o'>(</span><span class='nv'>ames</span>, <span class='nv'>Neighborhood</span>, balance <span class='o'>=</span> <span class='s'>"observations"</span><span class='o'>)</span>
<span class='c'>#&gt; # Group 28-fold cross-validation </span>
<span class='c'>#&gt; <span style='color: #555555;'># A tibble: 28 × 2</span></span>
<span class='c'>#&gt;    splits             id        </span>
<span class='c'>#&gt;    <span style='color: #555555; font-style: italic;'>&lt;list&gt;</span>             <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>     </span>
<span class='c'>#&gt; <span style='color: #555555;'> 1</span> <span style='color: #555555;'>&lt;split [2779/151]&gt;</span> Resample01</span>
<span class='c'>#&gt; <span style='color: #555555;'> 2</span> <span style='color: #555555;'>&lt;split [2906/24]&gt;</span>  Resample02</span>
<span class='c'>#&gt; <span style='color: #555555;'> 3</span> <span style='color: #555555;'>&lt;split [2907/23]&gt;</span>  Resample03</span>
<span class='c'>#&gt; <span style='color: #555555;'> 4</span> <span style='color: #555555;'>&lt;split [2900/30]&gt;</span>  Resample04</span>
<span class='c'>#&gt; <span style='color: #555555;'> 5</span> <span style='color: #555555;'>&lt;split [2879/51]&gt;</span>  Resample05</span>
<span class='c'>#&gt; <span style='color: #555555;'> 6</span> <span style='color: #555555;'>&lt;split [2837/93]&gt;</span>  Resample06</span>
<span class='c'>#&gt; <span style='color: #555555;'> 7</span> <span style='color: #555555;'>&lt;split [2922/8]&gt;</span>   Resample07</span>
<span class='c'>#&gt; <span style='color: #555555;'> 8</span> <span style='color: #555555;'>&lt;split [2929/1]&gt;</span>   Resample08</span>
<span class='c'>#&gt; <span style='color: #555555;'> 9</span> <span style='color: #555555;'>&lt;split [2805/125]&gt;</span> Resample09</span>
<span class='c'>#&gt; <span style='color: #555555;'>10</span> <span style='color: #555555;'>&lt;split [2928/2]&gt;</span>   Resample10</span>
<span class='c'>#&gt; <span style='color: #555555;'># … with 18 more rows</span></span></code></pre>

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
  <span class='o'>)</span><span class='o'>$</span><span class='nv'>splits</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span> 
    <span class='nf'>purrr</span><span class='nf'>::</span><span class='nf'><a href='https://purrr.tidyverse.org/reference/map.html'>map_dbl</a></span><span class='o'>(</span><span class='o'>~</span> <span class='nf'><a href='https://rdrr.io/r/base/nrow.html'>nrow</a></span><span class='o'>(</span><span class='nf'><a href='https://rsample.tidymodels.org/reference/as.data.frame.rsplit.html'>analysis</a></span><span class='o'>(</span><span class='nv'>.x</span><span class='o'>)</span><span class='o'>)</span><span class='o'>)</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span> 
    <span class='nf'><a href='https://rdrr.io/r/stats/sd.html'>sd</a></span><span class='o'>(</span><span class='o'>)</span>
<span class='o'>&#125;</span>

<span class='nv'>resample</span> <span class='o'>&lt;-</span> <span class='nf'>tidyr</span><span class='nf'>::</span><span class='nf'><a href='https://tidyr.tidyverse.org/reference/expand.html'>crossing</a></span><span class='o'>(</span>
  idx <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/seq.html'>seq_len</a></span><span class='o'>(</span><span class='m'>100</span><span class='o'>)</span>,
  v <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='m'>2</span>, <span class='m'>5</span>, <span class='m'>10</span>, <span class='m'>15</span><span class='o'>)</span>,
  balance <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"groups"</span>, <span class='s'>"observations"</span><span class='o'>)</span>
<span class='o'>)</span>

<span class='nv'>resample</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span>
  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/mutate.html'>mutate</a></span><span class='o'>(</span>sd <span class='o'>=</span> <span class='nf'>purrr</span><span class='nf'>::</span><span class='nf'><a href='https://purrr.tidyverse.org/reference/map2.html'>pmap_dbl</a></span><span class='o'>(</span>
    <span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span><span class='nv'>v</span>, <span class='nv'>balance</span><span class='o'>)</span>,
    <span class='nv'>analysis_sd</span>
  <span class='o'>)</span><span class='o'>)</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span>
  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggplot.html'>ggplot</a></span><span class='o'>(</span><span class='nf'><a href='https://ggplot2.tidyverse.org/reference/aes.html'>aes</a></span><span class='o'>(</span><span class='nv'>sd</span>, fill <span class='o'>=</span> <span class='nv'>balance</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>+</span> 
  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/geom_histogram.html'>geom_histogram</a></span><span class='o'>(</span>alpha <span class='o'>=</span> <span class='m'>0.6</span>, color <span class='o'>=</span> <span class='s'>"black"</span>, size <span class='o'>=</span> <span class='m'>0.3</span><span class='o'>)</span> <span class='o'>+</span> 
  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/facet_wrap.html'>facet_wrap</a></span><span class='o'>(</span><span class='o'>~</span> <span class='nv'>v</span><span class='o'>)</span> <span class='o'>+</span> 
  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggtheme.html'>theme_minimal</a></span><span class='o'>(</span><span class='o'>)</span> <span class='o'>+</span> 
  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/labs.html'>labs</a></span><span class='o'>(</span>title <span class='o'>=</span> <span class='s'>"sd() of nrow(analysis) by balance method"</span><span class='o'>)</span>
</code></pre>
<img src="figs/unnamed-chunk-4-1.png" width="700px" style="display: block; margin: auto;" />

</div>

Right now, these grouping functions don't support stratification. If you have thoughts on how you'd expect stratification to work with grouping, or have an example of how another implementation has handled it, [let us know on GitHub](https://github.com/tidymodels/rsample/issues/317)!

## Other Improvements

This release also adds a few new utility functions to make it easier to work with the rsets produced by rsample functions.

For instance, the new [`reshuffle_rset()`](https://rsample.tidymodels.org/reference/reshuffle_rset.html) will re-generate an rset, using the same arguments as were used to originally create it, but under the current random seed:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>resample</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rsample.tidymodels.org/reference/vfold_cv.html'>vfold_cv</a></span><span class='o'>(</span><span class='nv'>ames</span><span class='o'>)</span>

<span class='nv'>resample</span><span class='o'>$</span><span class='nv'>splits</span><span class='o'>[[</span><span class='m'>1</span><span class='o'>]</span><span class='o'>]</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span>
  <span class='nf'><a href='https://rsample.tidymodels.org/reference/as.data.frame.rsplit.html'>analysis</a></span><span class='o'>(</span><span class='o'>)</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span>
  <span class='nf'><a href='https://rdrr.io/r/utils/head.html'>head</a></span><span class='o'>(</span><span class='o'>)</span>
<span class='c'>#&gt; <span style='color: #555555;'># A tibble: 6 × 74</span></span>
<span class='c'>#&gt;   MS_SubClass             MS_Zoning Lot_Frontage Lot_Area Street Alley Lot_Shape</span>
<span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;fct&gt;</span>                   <span style='color: #555555; font-style: italic;'>&lt;fct&gt;</span>            <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>    <span style='color: #555555; font-style: italic;'>&lt;int&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;fct&gt;</span>  <span style='color: #555555; font-style: italic;'>&lt;fct&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;fct&gt;</span>    </span>
<span class='c'>#&gt; <span style='color: #555555;'>1</span> One_Story_1946_and_New… Resident…           80    <span style='text-decoration: underline;'>11</span>622 Pave   No_A… Regular  </span>
<span class='c'>#&gt; <span style='color: #555555;'>2</span> One_Story_1946_and_New… Resident…           81    <span style='text-decoration: underline;'>14</span>267 Pave   No_A… Slightly…</span>
<span class='c'>#&gt; <span style='color: #555555;'>3</span> One_Story_1946_and_New… Resident…           93    <span style='text-decoration: underline;'>11</span>160 Pave   No_A… Regular  </span>
<span class='c'>#&gt; <span style='color: #555555;'>4</span> Two_Story_1946_and_New… Resident…           74    <span style='text-decoration: underline;'>13</span>830 Pave   No_A… Slightly…</span>
<span class='c'>#&gt; <span style='color: #555555;'>5</span> Two_Story_1946_and_New… Resident…           78     <span style='text-decoration: underline;'>9</span>978 Pave   No_A… Slightly…</span>
<span class='c'>#&gt; <span style='color: #555555;'>6</span> One_Story_PUD_1946_and… Resident…           41     <span style='text-decoration: underline;'>4</span>920 Pave   No_A… Regular  </span>
<span class='c'>#&gt; <span style='color: #555555;'># … with 67 more variables: Land_Contour &lt;fct&gt;, Utilities &lt;fct&gt;,</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>#   Lot_Config &lt;fct&gt;, Land_Slope &lt;fct&gt;, Neighborhood &lt;fct&gt;, Condition_1 &lt;fct&gt;,</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>#   Condition_2 &lt;fct&gt;, Bldg_Type &lt;fct&gt;, House_Style &lt;fct&gt;, Overall_Cond &lt;fct&gt;,</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>#   Year_Built &lt;int&gt;, Year_Remod_Add &lt;int&gt;, Roof_Style &lt;fct&gt;, Roof_Matl &lt;fct&gt;,</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>#   Exterior_1st &lt;fct&gt;, Exterior_2nd &lt;fct&gt;, Mas_Vnr_Type &lt;fct&gt;,</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>#   Mas_Vnr_Area &lt;dbl&gt;, Exter_Cond &lt;fct&gt;, Foundation &lt;fct&gt;, Bsmt_Cond &lt;fct&gt;,</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>#   Bsmt_Exposure &lt;fct&gt;, BsmtFin_Type_1 &lt;fct&gt;, BsmtFin_SF_1 &lt;dbl&gt;, …</span></span>

<span class='nv'>resample</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rsample.tidymodels.org/reference/reshuffle_rset.html'>reshuffle_rset</a></span><span class='o'>(</span><span class='nv'>resample</span><span class='o'>)</span>

<span class='nv'>resample</span><span class='o'>$</span><span class='nv'>splits</span><span class='o'>[[</span><span class='m'>1</span><span class='o'>]</span><span class='o'>]</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span>
  <span class='nf'><a href='https://rsample.tidymodels.org/reference/as.data.frame.rsplit.html'>analysis</a></span><span class='o'>(</span><span class='o'>)</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span>
  <span class='nf'><a href='https://rdrr.io/r/utils/head.html'>head</a></span><span class='o'>(</span><span class='o'>)</span>
<span class='c'>#&gt; <span style='color: #555555;'># A tibble: 6 × 74</span></span>
<span class='c'>#&gt;   MS_SubClass             MS_Zoning Lot_Frontage Lot_Area Street Alley Lot_Shape</span>
<span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;fct&gt;</span>                   <span style='color: #555555; font-style: italic;'>&lt;fct&gt;</span>            <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>    <span style='color: #555555; font-style: italic;'>&lt;int&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;fct&gt;</span>  <span style='color: #555555; font-style: italic;'>&lt;fct&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;fct&gt;</span>    </span>
<span class='c'>#&gt; <span style='color: #555555;'>1</span> One_Story_1946_and_New… Resident…          141    <span style='text-decoration: underline;'>31</span>770 Pave   No_A… Slightly…</span>
<span class='c'>#&gt; <span style='color: #555555;'>2</span> One_Story_1946_and_New… Resident…           80    <span style='text-decoration: underline;'>11</span>622 Pave   No_A… Regular  </span>
<span class='c'>#&gt; <span style='color: #555555;'>3</span> One_Story_1946_and_New… Resident…           81    <span style='text-decoration: underline;'>14</span>267 Pave   No_A… Slightly…</span>
<span class='c'>#&gt; <span style='color: #555555;'>4</span> One_Story_1946_and_New… Resident…           93    <span style='text-decoration: underline;'>11</span>160 Pave   No_A… Regular  </span>
<span class='c'>#&gt; <span style='color: #555555;'>5</span> Two_Story_1946_and_New… Resident…           74    <span style='text-decoration: underline;'>13</span>830 Pave   No_A… Slightly…</span>
<span class='c'>#&gt; <span style='color: #555555;'>6</span> Two_Story_1946_and_New… Resident…           78     <span style='text-decoration: underline;'>9</span>978 Pave   No_A… Slightly…</span>
<span class='c'>#&gt; <span style='color: #555555;'># … with 67 more variables: Land_Contour &lt;fct&gt;, Utilities &lt;fct&gt;,</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>#   Lot_Config &lt;fct&gt;, Land_Slope &lt;fct&gt;, Neighborhood &lt;fct&gt;, Condition_1 &lt;fct&gt;,</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>#   Condition_2 &lt;fct&gt;, Bldg_Type &lt;fct&gt;, House_Style &lt;fct&gt;, Overall_Cond &lt;fct&gt;,</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>#   Year_Built &lt;int&gt;, Year_Remod_Add &lt;int&gt;, Roof_Style &lt;fct&gt;, Roof_Matl &lt;fct&gt;,</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>#   Exterior_1st &lt;fct&gt;, Exterior_2nd &lt;fct&gt;, Mas_Vnr_Type &lt;fct&gt;,</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>#   Mas_Vnr_Area &lt;dbl&gt;, Exter_Cond &lt;fct&gt;, Foundation &lt;fct&gt;, Bsmt_Cond &lt;fct&gt;,</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>#   Bsmt_Exposure &lt;fct&gt;, BsmtFin_Type_1 &lt;fct&gt;, BsmtFin_SF_1 &lt;dbl&gt;, …</span></span></code></pre>

</div>

This works with repeated cross-validation, stratification, grouping -- pretty much anything you did originally will be preserved when reshuffling the rset.

Additionally, the new [`reverse_splits()`](https://rsample.tidymodels.org/reference/reverse_splits.html) function will "swap" the assessment and analysis folds of any rsplit or rset object:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>resample</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rsample.tidymodels.org/reference/initial_split.html'>initial_split</a></span><span class='o'>(</span><span class='nv'>ames</span><span class='o'>)</span>

<span class='nv'>resample</span>
<span class='c'>#&gt; &lt;Training/Testing/Total&gt;</span>
<span class='c'>#&gt; &lt;2197/733/2930&gt;</span>
<span class='nf'><a href='https://rsample.tidymodels.org/reference/reverse_splits.html'>reverse_splits</a></span><span class='o'>(</span><span class='nv'>resample</span><span class='o'>)</span>
<span class='c'>#&gt; &lt;Training/Testing/Total&gt;</span>
<span class='c'>#&gt; &lt;733/2197/2930&gt;</span></code></pre>

</div>

And this is just scratching the surface of the new features and improvements in this release of rsample! You can see a full list of changes in the the [release notes](https://rsample.tidymodels.org/news/index.html#rsample-110).

## Acknowledgements

We'd like to thank everyone that has contributed since the last release: [@DavisVaughan](https://github.com/DavisVaughan), [@juliasilge](https://github.com/juliasilge), [@mattwarkentin](https://github.com/mattwarkentin), [@mikemahoney218](https://github.com/mikemahoney218), and [@sametsoekel](https://github.com/sametsoekel).

