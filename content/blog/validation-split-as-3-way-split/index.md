---
output: hugodown::hugo_document

slug: validation-split-as-3-way-split
title: New interface to validation splits
date: 2023-08-21
author: Hannah Frick
description: >
    The latest releases of rsample and tune provide a new interface to 
    validation sets as a three-way split.

photo:
  url: https://unsplash.com/photos/68GdK1Aoc8g
  author: Scott Webb

# one of: "deep-dive", "learn", "package", "programming", "roundup", or "other"
categories: [package] 
tags: [tidymodels, rsample, tune]
rmd_hash: 97b055d193137859

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

We're chuffed to announce the release of a new interface to validation splits in [rsample](https://rsample.tidymodels.org/) 1.2.0 and [tune](https://tune.tidymodels.org/) 1.1.2. The rsample package makes it easy to create resamples for assessing model performance. The tune package facilitates hyperparameter tuning for the tidymodels packages.

You can install the new versions from CRAN with:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://rdrr.io/r/utils/install.packages.html'>install.packages</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"rsample"</span>, <span class='s'>"tune"</span><span class='o'>)</span><span class='o'>)</span></span></code></pre>

</div>

This blog post will walk you through how to make a validation split and use it for tuning.

<!-- You can see a full list of changes in the [release notes]({ github_release }) -->

Let's start with loading the tidymodels package which will load, among others, both rsample and tune.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://tidymodels.tidymodels.org'>tidymodels</a></span><span class='o'>)</span></span>
<span><span class='c'>#&gt; ── <span style='font-weight: bold;'>Attaching packages</span> ────────────────────────────────────── tidymodels 1.0.0 ──</span></span>
<span></span><span><span class='c'>#&gt; <span style='color: #00BB00;'>✔</span> <span style='color: #0000BB;'>broom       </span> 1.0.5.<span style='color: #BB0000;'>9000</span>     <span style='color: #00BB00;'>✔</span> <span style='color: #0000BB;'>recipes     </span> 1.0.7     </span></span>
<span><span class='c'>#&gt; <span style='color: #00BB00;'>✔</span> <span style='color: #0000BB;'>dials       </span> 1.2.0          <span style='color: #00BB00;'>✔</span> <span style='color: #0000BB;'>rsample     </span> 1.1.1.<span style='color: #BB0000;'>9001</span></span></span>
<span><span class='c'>#&gt; <span style='color: #00BB00;'>✔</span> <span style='color: #0000BB;'>dplyr       </span> 1.1.2          <span style='color: #00BB00;'>✔</span> <span style='color: #0000BB;'>tibble      </span> 3.2.1     </span></span>
<span><span class='c'>#&gt; <span style='color: #00BB00;'>✔</span> <span style='color: #0000BB;'>ggplot2     </span> 3.4.3          <span style='color: #00BB00;'>✔</span> <span style='color: #0000BB;'>tidyr       </span> 1.3.0     </span></span>
<span><span class='c'>#&gt; <span style='color: #00BB00;'>✔</span> <span style='color: #0000BB;'>infer       </span> 1.0.4          <span style='color: #00BB00;'>✔</span> <span style='color: #0000BB;'>tune        </span> 1.1.2     </span></span>
<span><span class='c'>#&gt; <span style='color: #00BB00;'>✔</span> <span style='color: #0000BB;'>modeldata   </span> 1.2.0          <span style='color: #00BB00;'>✔</span> <span style='color: #0000BB;'>workflows   </span> 1.1.3     </span></span>
<span><span class='c'>#&gt; <span style='color: #00BB00;'>✔</span> <span style='color: #0000BB;'>parsnip     </span> 1.1.0.<span style='color: #BB0000;'>9003</span>     <span style='color: #00BB00;'>✔</span> <span style='color: #0000BB;'>workflowsets</span> 1.0.1     </span></span>
<span><span class='c'>#&gt; <span style='color: #00BB00;'>✔</span> <span style='color: #0000BB;'>purrr       </span> 1.0.2          <span style='color: #00BB00;'>✔</span> <span style='color: #0000BB;'>yardstick   </span> 1.2.0.<span style='color: #BB0000;'>9001</span></span></span>
<span></span><span><span class='c'>#&gt; ── <span style='font-weight: bold;'>Conflicts</span> ───────────────────────────────────────── tidymodels_conflicts() ──</span></span>
<span><span class='c'>#&gt; <span style='color: #BB0000;'>✖</span> <span style='color: #0000BB;'>purrr</span>::<span style='color: #00BB00;'>discard()</span> masks <span style='color: #0000BB;'>scales</span>::discard()</span></span>
<span><span class='c'>#&gt; <span style='color: #BB0000;'>✖</span> <span style='color: #0000BB;'>dplyr</span>::<span style='color: #00BB00;'>filter()</span>  masks <span style='color: #0000BB;'>stats</span>::filter()</span></span>
<span><span class='c'>#&gt; <span style='color: #BB0000;'>✖</span> <span style='color: #0000BB;'>dplyr</span>::<span style='color: #00BB00;'>lag()</span>     masks <span style='color: #0000BB;'>stats</span>::lag()</span></span>
<span><span class='c'>#&gt; <span style='color: #BB0000;'>✖</span> <span style='color: #0000BB;'>recipes</span>::<span style='color: #00BB00;'>step()</span>  masks <span style='color: #0000BB;'>stats</span>::step()</span></span>
<span><span class='c'>#&gt; <span style='color: #0000BB;'>•</span> Dig deeper into tidy modeling with R at <span style='color: #00BB00;'>https://www.tmwr.org</span></span></span>
<span></span></code></pre>

</div>

## The new functions

You can now make a three-way split of your data instead of doing a sequence of two binary splits.

-   `initial_validation_split()` with variants `initial_validation_time_split()` and `group_initial_validation_split()` for the initial three-way split
-   `validation_set()` to create the `rset` for tuning containing the analysis (= training) and assessment (= validation) set
-   `training()`, `validation()`, and `testing()` for access to the separate subsets
-   `last_fit()` (and `fit_best()`) now also work on the initial three-way split

## The new functions in action

To illustrate how to use the new functions, we'll replicate an analysis of [childcare cost](https://github.com/rfordatascience/tidytuesday/blob/master/data/2023/2023-05-09/readme.md) from a [Tidy Tuesday](https://github.com/rfordatascience/tidytuesday) done by Julia Silge in one of her [screencasts](https://juliasilge.com/blog/childcare-costs/).

We are modeling the median weekly price for school-aged kids in childcare centers `mcsa` and are thus removing the other variables containing different variants of median prices (e.g, for different age groups). We are also removing the FIPS code identifying the county as we are including various characteristics of the counties instead of their ID.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://readr.tidyverse.org'>readr</a></span><span class='o'>)</span></span>
<span><span class='c'>#&gt; </span></span>
<span><span class='c'>#&gt; Attaching package: 'readr'</span></span>
<span></span><span><span class='c'>#&gt; The following object is masked from 'package:yardstick':</span></span>
<span><span class='c'>#&gt; </span></span>
<span><span class='c'>#&gt;     spec</span></span>
<span></span><span><span class='c'>#&gt; The following object is masked from 'package:scales':</span></span>
<span><span class='c'>#&gt; </span></span>
<span><span class='c'>#&gt;     col_factor</span></span>
<span></span><span></span>
<span><span class='nv'>childcare_costs</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://readr.tidyverse.org/reference/read_delim.html'>read_csv</a></span><span class='o'>(</span><span class='s'>'https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2023/2023-05-09/childcare_costs.csv'</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='font-weight: bold;'>Rows: </span><span style='color: #0000BB;'>34567</span> <span style='font-weight: bold;'>Columns: </span><span style='color: #0000BB;'>61</span></span></span>
<span></span><span><span class='c'>#&gt; <span style='color: #00BBBB;'>──</span> <span style='font-weight: bold;'>Column specification</span> <span style='color: #00BBBB;'>────────────────────────────────────────────────────────</span></span></span>
<span><span class='c'>#&gt; <span style='font-weight: bold;'>Delimiter:</span> ","</span></span>
<span><span class='c'>#&gt; <span style='color: #00BB00;'>dbl</span> (61): county_fips_code, study_year, unr_16, funr_16, munr_16, unr_20to64...</span></span>
<span><span class='c'>#&gt; </span></span>
<span><span class='c'>#&gt; <span style='color: #00BBBB;'>ℹ</span> Use `spec()` to retrieve the full column specification for this data.</span></span>
<span><span class='c'>#&gt; <span style='color: #00BBBB;'>ℹ</span> Specify the column types or set `show_col_types = FALSE` to quiet this message.</span></span>
<span></span><span></span>
<span><span class='nv'>childcare_costs</span> <span class='o'>&lt;-</span> <span class='nv'>childcare_costs</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'>select</span><span class='o'>(</span><span class='o'>-</span><span class='nf'>matches</span><span class='o'>(</span><span class='s'>"^mc_|^mfc"</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'>select</span><span class='o'>(</span><span class='o'>-</span><span class='nv'>county_fips_code</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://rdrr.io/r/stats/na.fail.html'>na.omit</a></span><span class='o'>(</span><span class='o'>)</span> </span>
<span></span>
<span><span class='nf'>glimpse</span><span class='o'>(</span><span class='nv'>childcare_costs</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; Rows: 23,593</span></span>
<span><span class='c'>#&gt; Columns: 53</span></span>
<span><span class='c'>#&gt; $ study_year                <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> 2008, 2009, 2010, 2011, 2012, 2013, 2014, 20…</span></span>
<span><span class='c'>#&gt; $ unr_16                    <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> 5.42, 5.93, 6.21, 7.55, 8.60, 9.39, 8.50, 7.…</span></span>
<span><span class='c'>#&gt; $ funr_16                   <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> 4.41, 5.72, 5.57, 8.13, 8.88, 10.31, 9.18, 8…</span></span>
<span><span class='c'>#&gt; $ munr_16                   <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> 6.32, 6.11, 6.78, 7.03, 8.29, 8.56, 7.95, 6.…</span></span>
<span><span class='c'>#&gt; $ unr_20to64                <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> 4.6, 4.8, 5.1, 6.2, 6.7, 7.3, 6.8, 5.9, 4.4,…</span></span>
<span><span class='c'>#&gt; $ funr_20to64               <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> 3.5, 4.6, 4.6, 6.3, 6.4, 7.6, 6.8, 6.1, 4.6,…</span></span>
<span><span class='c'>#&gt; $ munr_20to64               <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> 5.6, 5.0, 5.6, 6.1, 7.0, 7.0, 6.8, 5.9, 4.3,…</span></span>
<span><span class='c'>#&gt; $ flfpr_20to64              <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> 68.9, 70.8, 71.3, 70.2, 70.6, 70.7, 69.9, 68…</span></span>
<span><span class='c'>#&gt; $ flfpr_20to64_under6       <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> 66.9, 63.7, 67.0, 66.5, 67.1, 67.5, 65.2, 66…</span></span>
<span><span class='c'>#&gt; $ flfpr_20to64_6to17        <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> 79.59, 78.41, 78.15, 77.62, 76.31, 75.91, 75…</span></span>
<span><span class='c'>#&gt; $ flfpr_20to64_under6_6to17 <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> 60.81, 59.91, 59.71, 59.31, 58.30, 58.00, 57…</span></span>
<span><span class='c'>#&gt; $ mlfpr_20to64              <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> 84.0, 86.2, 85.8, 85.7, 85.7, 85.0, 84.2, 82…</span></span>
<span><span class='c'>#&gt; $ pr_f                      <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> 8.5, 7.5, 7.5, 7.4, 7.4, 8.3, 9.1, 9.3, 9.4,…</span></span>
<span><span class='c'>#&gt; $ pr_p                      <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> 11.5, 10.3, 10.6, 10.9, 11.6, 12.1, 12.8, 12…</span></span>
<span><span class='c'>#&gt; $ mhi_2018                  <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> 58462.55, 60211.71, 61775.80, 60366.88, 5915…</span></span>
<span><span class='c'>#&gt; $ me_2018                   <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> 32710.60, 34688.16, 34740.84, 34564.32, 3432…</span></span>
<span><span class='c'>#&gt; $ fme_2018                  <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> 25156.25, 26852.67, 27391.08, 26727.68, 2796…</span></span>
<span><span class='c'>#&gt; $ mme_2018                  <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> 41436.80, 43865.64, 46155.24, 45333.12, 4427…</span></span>
<span><span class='c'>#&gt; $ total_pop                 <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> 49744, 49584, 53155, 53944, 54590, 54907, 55…</span></span>
<span><span class='c'>#&gt; $ one_race                  <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> 98.1, 98.6, 98.5, 98.5, 98.5, 98.6, 98.7, 98…</span></span>
<span><span class='c'>#&gt; $ one_race_w                <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> 78.9, 79.1, 79.1, 78.9, 78.9, 78.3, 78.0, 77…</span></span>
<span><span class='c'>#&gt; $ one_race_b                <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> 17.7, 17.9, 17.9, 18.1, 18.1, 18.4, 18.6, 18…</span></span>
<span><span class='c'>#&gt; $ one_race_i                <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> 0.4, 0.4, 0.3, 0.2, 0.3, 0.3, 0.4, 0.4, 0.4,…</span></span>
<span><span class='c'>#&gt; $ one_race_a                <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> 0.4, 0.6, 0.7, 0.7, 0.8, 1.0, 0.9, 1.0, 0.8,…</span></span>
<span><span class='c'>#&gt; $ one_race_h                <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.1,…</span></span>
<span><span class='c'>#&gt; $ one_race_other            <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> 0.7, 0.7, 0.6, 0.5, 0.4, 0.7, 0.7, 0.9, 1.4,…</span></span>
<span><span class='c'>#&gt; $ two_races                 <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> 1.9, 1.4, 1.5, 1.5, 1.5, 1.4, 1.3, 1.6, 2.0,…</span></span>
<span><span class='c'>#&gt; $ hispanic                  <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> 1.8, 2.0, 2.3, 2.4, 2.4, 2.5, 2.5, 2.6, 2.6,…</span></span>
<span><span class='c'>#&gt; $ households                <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> 18373, 18288, 19718, 19998, 19934, 20071, 20…</span></span>
<span><span class='c'>#&gt; $ h_under6_both_work        <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> 1543, 1475, 1569, 1695, 1714, 1532, 1557, 13…</span></span>
<span><span class='c'>#&gt; $ h_under6_f_work           <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> 970, 964, 1009, 1060, 938, 880, 1191, 1258, …</span></span>
<span><span class='c'>#&gt; $ h_under6_m_work           <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> 22, 16, 16, 106, 120, 161, 159, 211, 109, 10…</span></span>
<span><span class='c'>#&gt; $ h_under6_single_m         <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> 995, 1099, 1110, 1030, 1095, 1160, 954, 883,…</span></span>
<span><span class='c'>#&gt; $ h_6to17_both_work         <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> 4900, 5028, 5472, 5065, 4608, 4238, 4056, 40…</span></span>
<span><span class='c'>#&gt; $ h_6to17_fwork             <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> 1308, 1519, 1541, 1965, 1963, 1978, 2073, 20…</span></span>
<span><span class='c'>#&gt; $ h_6to17_mwork             <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> 114, 92, 113, 246, 284, 354, 373, 551, 322, …</span></span>
<span><span class='c'>#&gt; $ h_6to17_single_m          <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> 1966, 2305, 2377, 2299, 2644, 2522, 2269, 21…</span></span>
<span><span class='c'>#&gt; $ emp_m                     <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> 27.40, 29.54, 29.33, 31.17, 32.13, 31.74, 32…</span></span>
<span><span class='c'>#&gt; $ memp_m                    <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> 24.41, 26.07, 25.94, 26.97, 28.59, 27.44, 28…</span></span>
<span><span class='c'>#&gt; $ femp_m                    <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> 30.68, 33.40, 33.06, 35.96, 36.09, 36.61, 37…</span></span>
<span><span class='c'>#&gt; $ emp_service               <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> 17.06, 15.81, 16.92, 16.18, 16.09, 16.72, 16…</span></span>
<span><span class='c'>#&gt; $ memp_service              <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> 15.53, 14.16, 15.09, 14.21, 14.71, 13.92, 13…</span></span>
<span><span class='c'>#&gt; $ femp_service              <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> 18.75, 17.64, 18.93, 18.42, 17.63, 19.89, 20…</span></span>
<span><span class='c'>#&gt; $ emp_sales                 <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> 29.11, 28.75, 29.07, 27.56, 28.39, 27.22, 25…</span></span>
<span><span class='c'>#&gt; $ memp_sales                <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> 15.97, 17.51, 17.82, 17.74, 17.79, 17.38, 15…</span></span>
<span><span class='c'>#&gt; $ femp_sales                <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> 43.52, 41.25, 41.43, 38.76, 40.26, 38.36, 36…</span></span>
<span><span class='c'>#&gt; $ emp_n                     <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> 13.21, 11.89, 11.57, 10.72, 9.02, 9.27, 9.38…</span></span>
<span><span class='c'>#&gt; $ memp_n                    <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> 22.54, 20.30, 19.86, 18.28, 16.03, 16.79, 17…</span></span>
<span><span class='c'>#&gt; $ femp_n                    <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> 2.99, 2.52, 2.45, 2.09, 1.19, 0.77, 0.58, 0.…</span></span>
<span><span class='c'>#&gt; $ emp_p                     <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> 13.22, 14.02, 13.11, 14.38, 14.37, 15.04, 16…</span></span>
<span><span class='c'>#&gt; $ memp_p                    <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> 21.55, 21.96, 21.28, 22.80, 22.88, 24.48, 24…</span></span>
<span><span class='c'>#&gt; $ femp_p                    <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> 4.07, 5.19, 4.13, 4.77, 4.84, 4.36, 6.07, 7.…</span></span>
<span><span class='c'>#&gt; $ mcsa                      <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> 80.92, 83.42, 85.92, 88.43, 90.93, 93.43, 95…</span></span>
<span></span></code></pre>

</div>

Even after omitting rows with missing values are we left with 23593 observations. That is plenty to work with! We are likely to get a reliable estimate of the model performance from a validation set without having to fit and evaluate the model multiple times, as with, for example, v-fold cross-validation.

We are creating a three-way split of the data into a training, a validation, and a test set with the new `initial_validation_split()` function. We are stratifying based on our outcome `mcsa`. The default of `prop = c(0.6, 0.2)` means that 60% of the data gets allocated to the training set and 20% to the validation set - and the remaining 20% go into the test set.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://rdrr.io/r/base/Random.html'>set.seed</a></span><span class='o'>(</span><span class='m'>123</span><span class='o'>)</span></span>
<span><span class='nv'>childcare_split</span> <span class='o'>&lt;-</span> <span class='nv'>childcare_costs</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'>initial_validation_split</span><span class='o'>(</span>strata <span class='o'>=</span> <span class='nv'>mcsa</span><span class='o'>)</span></span>
<span><span class='nv'>childcare_split</span></span>
<span><span class='c'>#&gt; &lt;Training/Validation/Testing/Total&gt;</span></span>
<span><span class='c'>#&gt; &lt;14155/4718/4720/23593&gt;</span></span>
<span></span></code></pre>

</div>

You can access the subsets of the data with the familiar `training()` and `testing()` as well as the new `validation()`:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'>validation</span><span class='o'>(</span><span class='nv'>childcare_split</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 4,718 × 53</span></span></span>
<span><span class='c'>#&gt;    study_year unr_16 funr_16 munr_16 unr_20to64 funr_20to64 munr_20to64</span></span>
<span><span class='c'>#&gt;         <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>  <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>   <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>   <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>      <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>       <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>       <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 1</span>       <span style='text-decoration: underline;'>2</span>013   9.39   10.3     8.56        7.3         7.6         7  </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 2</span>       <span style='text-decoration: underline;'>2</span>011  13.0    12.4    13.6        13.2        12.4        13.9</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 3</span>       <span style='text-decoration: underline;'>2</span>008   3.85    4.4     3.43        3.7         3.9         3.6</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 4</span>       <span style='text-decoration: underline;'>2</span>015   8.31   11.8     5.69        7.8        11.7         4.9</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 5</span>       <span style='text-decoration: underline;'>2</span>015   7.67    6.92    8.27        7.6         6.7         8.3</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 6</span>       <span style='text-decoration: underline;'>2</span>016   5.95    6.33    5.66        5.7         5.9         5.5</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 7</span>       <span style='text-decoration: underline;'>2</span>009  10.7    15.9     7.06        8.7        16.8         2.9</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 8</span>       <span style='text-decoration: underline;'>2</span>010  11.2    15.2     7.89       10.9        14.7         7.8</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 9</span>       <span style='text-decoration: underline;'>2</span>013  15.0    17.0    13.4        15.2        18.1        13  </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>10</span>       <span style='text-decoration: underline;'>2</span>014  17.4    16.3    18.2        17.2        17.7        16.9</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># ℹ 4,708 more rows</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># ℹ 46 more variables: flfpr_20to64 &lt;dbl&gt;, flfpr_20to64_under6 &lt;dbl&gt;,</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>#   flfpr_20to64_6to17 &lt;dbl&gt;, flfpr_20to64_under6_6to17 &lt;dbl&gt;,</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>#   mlfpr_20to64 &lt;dbl&gt;, pr_f &lt;dbl&gt;, pr_p &lt;dbl&gt;, mhi_2018 &lt;dbl&gt;, me_2018 &lt;dbl&gt;,</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>#   fme_2018 &lt;dbl&gt;, mme_2018 &lt;dbl&gt;, total_pop &lt;dbl&gt;, one_race &lt;dbl&gt;,</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>#   one_race_w &lt;dbl&gt;, one_race_b &lt;dbl&gt;, one_race_i &lt;dbl&gt;, one_race_a &lt;dbl&gt;,</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>#   one_race_h &lt;dbl&gt;, one_race_other &lt;dbl&gt;, two_races &lt;dbl&gt;, hispanic &lt;dbl&gt;, …</span></span></span>
<span></span></code></pre>

</div>

You may want to extract the training data to do some exploratory data analysis but here we are going to rely on xgboost to figure out patterns in the data so we can breeze straight to tuning a model.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>xgb_spec</span> <span class='o'>&lt;-</span></span>
<span>  <span class='nf'>boost_tree</span><span class='o'>(</span></span>
<span>    trees <span class='o'>=</span> <span class='m'>500</span>,</span>
<span>    min_n <span class='o'>=</span> <span class='nf'>tune</span><span class='o'>(</span><span class='o'>)</span>,</span>
<span>    mtry <span class='o'>=</span> <span class='nf'>tune</span><span class='o'>(</span><span class='o'>)</span>,</span>
<span>    stop_iter <span class='o'>=</span> <span class='nf'>tune</span><span class='o'>(</span><span class='o'>)</span>,</span>
<span>    learn_rate <span class='o'>=</span> <span class='m'>0.01</span></span>
<span>  <span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'>set_engine</span><span class='o'>(</span><span class='s'>"xgboost"</span>, validation <span class='o'>=</span> <span class='m'>0.2</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'>set_mode</span><span class='o'>(</span><span class='s'>"regression"</span><span class='o'>)</span></span>
<span></span>
<span><span class='nv'>xgb_wf</span> <span class='o'>&lt;-</span> <span class='nf'>workflow</span><span class='o'>(</span><span class='nv'>mcsa</span> <span class='o'>~</span> <span class='nv'>.</span>, <span class='nv'>xgb_spec</span><span class='o'>)</span></span>
<span><span class='nv'>xgb_wf</span></span>
<span><span class='c'>#&gt; ══ Workflow ════════════════════════════════════════════════════════════════════</span></span>
<span><span class='c'>#&gt; <span style='font-style: italic;'>Preprocessor:</span> Formula</span></span>
<span><span class='c'>#&gt; <span style='font-style: italic;'>Model:</span> boost_tree()</span></span>
<span><span class='c'>#&gt; </span></span>
<span><span class='c'>#&gt; ── Preprocessor ────────────────────────────────────────────────────────────────</span></span>
<span><span class='c'>#&gt; mcsa ~ .</span></span>
<span><span class='c'>#&gt; </span></span>
<span><span class='c'>#&gt; ── Model ───────────────────────────────────────────────────────────────────────</span></span>
<span><span class='c'>#&gt; Boosted Tree Model Specification (regression)</span></span>
<span><span class='c'>#&gt; </span></span>
<span><span class='c'>#&gt; Main Arguments:</span></span>
<span><span class='c'>#&gt;   mtry = tune()</span></span>
<span><span class='c'>#&gt;   trees = 500</span></span>
<span><span class='c'>#&gt;   min_n = tune()</span></span>
<span><span class='c'>#&gt;   learn_rate = 0.01</span></span>
<span><span class='c'>#&gt;   stop_iter = tune()</span></span>
<span><span class='c'>#&gt; </span></span>
<span><span class='c'>#&gt; Engine-Specific Arguments:</span></span>
<span><span class='c'>#&gt;   validation = 0.2</span></span>
<span><span class='c'>#&gt; </span></span>
<span><span class='c'>#&gt; Computational engine: xgboost</span></span>
<span></span></code></pre>

</div>

We give this workflow object with the model specification to `tune_grid()` to try multiple combinations of the hyperparameters we tagged for tuning (`min_n`, `mtry`, and `stop_iter`).

<!-- But `tune_grid()` also needs data to fit the model on and data to assess the fitted model on! That's the training set and the validation set. The test set needs to be put aside until we've picked our final model. -->
<!-- The new `validation_set()` function takes our initial three-way split object and returns the training set and the validation set, ready for use with the tuning functions like `tune_grid()`. -->

During tuning, the model should not have access to the test data, only to the data used to fit the model (the analysis set) and the data used to assess the model (the assessment set). Each pair of analysis and assessment set forms a resample. With a validation split, we have just one resample with the training set functioning as the analysis set and the validation set as the assessment set. For 10-fold cross-validation, we'd have 10 resamples. The tidymodels tuning functions all expect a *set* of resamples and the corresponding objects are of class `rset`. To remove the test data from the initial three-way split and create such an `rset` object for tuning, use `validation_set()`.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://rdrr.io/r/base/Random.html'>set.seed</a></span><span class='o'>(</span><span class='m'>234</span><span class='o'>)</span></span>
<span><span class='nv'>childcare_set</span> <span class='o'>&lt;-</span> <span class='nf'>validation_set</span><span class='o'>(</span><span class='nv'>childcare_split</span><span class='o'>)</span></span>
<span><span class='nv'>childcare_set</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 1 × 2</span></span></span>
<span><span class='c'>#&gt;   splits               id        </span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;list&gt;</span>               <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>     </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span> <span style='color: #555555;'>&lt;split [14155/4718]&gt;</span> validation</span></span>
<span></span></code></pre>

</div>

We are going to try 15 different parameter combinations and pick the one with the smallest RMSE.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://rdrr.io/r/base/Random.html'>set.seed</a></span><span class='o'>(</span><span class='m'>234</span><span class='o'>)</span></span>
<span><span class='nv'>xgb_res</span> <span class='o'>&lt;-</span> <span class='nf'>tune_grid</span><span class='o'>(</span><span class='nv'>xgb_wf</span>, <span class='nv'>childcare_set</span>, grid <span class='o'>=</span> <span class='m'>15</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #0000BB;'>i</span> <span style='color: #000000;'>Creating pre-processing data to finalize unknown parameter: mtry</span></span></span>
<span></span><span><span class='c'>#&gt; Warning in `[.tbl_df`(x, is.finite(x &lt;- as.numeric(x))): NAs introduced by coercion</span></span>
<span></span><span><span class='nv'>best_parameters</span> <span class='o'>&lt;-</span> <span class='nf'>select_best</span><span class='o'>(</span><span class='nv'>xgb_res</span>, <span class='s'>"rmse"</span><span class='o'>)</span></span>
<span><span class='nv'>childcare_wflow</span> <span class='o'>&lt;-</span> <span class='nf'>finalize_workflow</span><span class='o'>(</span><span class='nv'>xgb_wf</span>, <span class='nv'>best_parameters</span><span class='o'>)</span></span></code></pre>

</div>

`last_fit()` then lets you fit your model on the training data and calculate performance on the test data. If you provide it with a three-way split, you can choose if you want your model to be fitted on the training data only or on the combination of training and validation set. You can specify this with the `add_validation_set` argument.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>childcare_fit</span> <span class='o'>&lt;-</span> <span class='nf'>last_fit</span><span class='o'>(</span><span class='nv'>childcare_wflow</span>, <span class='nv'>childcare_split</span>, add_validation_set <span class='o'>=</span> <span class='kc'>TRUE</span><span class='o'>)</span></span>
<span><span class='nf'>collect_metrics</span><span class='o'>(</span><span class='nv'>childcare_fit</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 2 × 4</span></span></span>
<span><span class='c'>#&gt;   .metric .estimator .estimate .config             </span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>   <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>          <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>               </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span> rmse    standard      21.4   Preprocessor1_Model1</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span> rsq     standard       0.610 Preprocessor1_Model1</span></span>
<span></span></code></pre>

</div>

## Acknowledgements

Many thanks to the people who contributed since the last releases!

For rsample: [@afrogri37](https://github.com/afrogri37), [@AngelFelizR](https://github.com/AngelFelizR), [@bschneidr](https://github.com/bschneidr), [@erictleung](https://github.com/erictleung), [@exsell-jc](https://github.com/exsell-jc), [@hfrick](https://github.com/hfrick), [@jrosell](https://github.com/jrosell), [@MasterLuke84](https://github.com/MasterLuke84), [@MichaelChirico](https://github.com/MichaelChirico), [@mikemahoney218](https://github.com/mikemahoney218), [@rdavis120](https://github.com/rdavis120), [@sametsoekel](https://github.com/sametsoekel), [@Shafi2016](https://github.com/Shafi2016), [@simonpcouch](https://github.com/simonpcouch), [@topepo](https://github.com/topepo), and [@trevorcampbell](https://github.com/trevorcampbell).

For tune: [@blechturm](https://github.com/blechturm), [@cphaarmeyer](https://github.com/cphaarmeyer), [@EmilHvitfeldt](https://github.com/EmilHvitfeldt), [@forecastingEDs](https://github.com/forecastingEDs), [@hfrick](https://github.com/hfrick), [@kjbeath](https://github.com/kjbeath), [@mikemahoney218](https://github.com/mikemahoney218), [@rdavis120](https://github.com/rdavis120), [@simonpcouch](https://github.com/simonpcouch), and [@topepo](https://github.com/topepo).

