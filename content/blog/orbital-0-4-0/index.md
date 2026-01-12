---
output: hugodown::hugo_document

slug: orbital-0-4-0
title: orbital 0.4.0
date: 2026-01-12
author: Emil Hvitfeldt
description: >
    orbital 0.4.0 is on CRAN! orbital now has post processing support.

photo:
  url: https://unsplash.com/photos/a-wispy-nebula-glows-with-purple-and-orange-hues-KLFP4HwaXyk
  author: Scott Lord

# one of: "deep-dive", "learn", "package", "programming", "roundup", or "other"
categories: [package] 
tags: [tidymodels, orbital]
rmd_hash: af5478c76965d272

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
* [ ] [`usethis::use_tidy_thanks()`](https://usethis.r-lib.org/reference/use_tidy_thanks.html)
-->

We're over the moon to announce the release of [orbital](https://orbital.tidymodels.org/) 0.4.0. orbital lets you predict in databases using tidymodels workflows.

You can install it from CRAN with:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://rdrr.io/r/utils/install.packages.html'>install.packages</a></span><span class='o'>(</span><span class='s'>"orbital"</span><span class='o'>)</span></span></code></pre>

</div>

This blog post will cover the highlights, which are post processing support and the new `show_query()` method.

You can see a full list of changes in the [release notes](https://orbital.tidymodels.org/news/index.html#orbital-040).

## Post processing support

The biggest improvement in this version is that [`orbital()`](https://orbital.tidymodels.org/reference/orbital.html) now works for supported [tailor](https://tailor.tidymodels.org/) methods. See [vignette](https://orbital.tidymodels.org/articles/supported-models.html#tailor-adjustments) for a list of all supported post-processors.

Let's start by fitting a classification model on the `penguins` data set, using {xgboost} as the engine. We will be showcasing using an adjustment that only works on binary classification and will thus recode `species` to have levels `"Adelie"` and `"not_Adelie"`.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>penguins</span><span class='o'>$</span><span class='nv'>species</span> <span class='o'>&lt;-</span> <span class='nf'>forcats</span><span class='nf'>::</span><span class='nf'><a href='https://forcats.tidyverse.org/reference/fct_recode.html'>fct_recode</a></span><span class='o'>(</span></span>
<span> <span class='nv'>penguins</span><span class='o'>$</span><span class='nv'>species</span>,</span>
<span> not_Adelie <span class='o'>=</span> <span class='s'>"Chinstrap"</span>, not_Adelie <span class='o'>=</span> <span class='s'>"Gentoo"</span></span>
<span><span class='o'>)</span></span></code></pre>

</div>

After we have modified the data, we set up a simple workflow, with a preprocessor using recipes and the model specification using parsnip.

We also set up a post processor using the tailor package. A single adjustment will be done by adding `adjust_equivocal_zone()`. This will apply an equivocal zone to our binary classification model. Stopping predictions that are too close to the thresholds by labeling them as `"[EQ]"`. Setting the argument `value = 0.2` means that any predictions with a predicted probability of between 0.3 and 0.7 will be predicted as `"[EQ]"` instead.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>rec_spec</span> <span class='o'>&lt;-</span> <span class='nf'>recipe</span><span class='o'>(</span><span class='nv'>species</span> <span class='o'>~</span> <span class='nv'>.</span>, data <span class='o'>=</span> <span class='nv'>penguins</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'>step_unknown</span><span class='o'>(</span><span class='nf'>all_nominal_predictors</span><span class='o'>(</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'>step_dummy</span><span class='o'>(</span><span class='nf'>all_nominal_predictors</span><span class='o'>(</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'>step_impute_mean</span><span class='o'>(</span><span class='nf'>all_numeric_predictors</span><span class='o'>(</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'>step_zv</span><span class='o'>(</span><span class='nf'>all_predictors</span><span class='o'>(</span><span class='o'>)</span><span class='o'>)</span></span>
<span></span>
<span><span class='nv'>lr_spec</span> <span class='o'>&lt;-</span> <span class='nf'>boost_tree</span><span class='o'>(</span>tree_depth <span class='o'>=</span> <span class='m'>1</span>, trees <span class='o'>=</span> <span class='m'>5</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'>set_mode</span><span class='o'>(</span><span class='s'>"classification"</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'>set_engine</span><span class='o'>(</span><span class='s'>"xgboost"</span><span class='o'>)</span></span>
<span></span>
<span><span class='nv'>tlr_spec</span> <span class='o'>&lt;-</span> <span class='nf'>tailor</span><span class='o'>(</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'>adjust_equivocal_zone</span><span class='o'>(</span>value <span class='o'>=</span> <span class='m'>0.2</span><span class='o'>)</span></span>
<span></span>
<span><span class='nv'>wf_spec</span> <span class='o'>&lt;-</span> <span class='nf'>workflow</span><span class='o'>(</span><span class='nv'>rec_spec</span>, <span class='nv'>lr_spec</span>, <span class='nv'>tlr_spec</span><span class='o'>)</span></span>
<span><span class='nv'>wf_fit</span> <span class='o'>&lt;-</span> <span class='nf'>fit</span><span class='o'>(</span><span class='nv'>wf_spec</span>, data <span class='o'>=</span> <span class='nv'>penguins</span><span class='o'>)</span></span></code></pre>

</div>

With this fitted workflow object, we can call [`orbital()`](https://orbital.tidymodels.org/reference/orbital.html) on it to create an orbital object. Notice that for `adjust_equivocal_zone()` to work, we need to set `type = c("class", "prob")` as both are required for the `adjust_equivocal_zone()` transformation.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>orbital_obj</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://orbital.tidymodels.org/reference/orbital.html'>orbital</a></span><span class='o'>(</span><span class='nv'>wf_fit</span>, type <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"class"</span>, <span class='s'>"prob"</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='nv'>orbital_obj</span></span>
<span><span class='c'>#&gt; </span></span>
<span><span class='c'>#&gt; <span style='color: #00BBBB;'>──</span> <span style='font-weight: bold;'>orbital Object</span> <span style='color: #00BBBB;'>───────────────────────────────────────────────────────</span></span></span>
<span><span class='c'>#&gt; • bill_length_mm = dplyr::if_else(is.na(bill_length_mm), 43.92193, ...</span></span>
<span><span class='c'>#&gt; • flipper_length_mm = dplyr::if_else(is.na(flipper_length_mm), 201 ...</span></span>
<span><span class='c'>#&gt; • .pred_class = dplyr::case_when(1 - 1/(1 + exp(dplyr::case_when(b ...</span></span>
<span><span class='c'>#&gt; • .pred_Adelie = 1 - 1/(1 + exp(dplyr::case_when(bill_length_mm &lt; ...</span></span>
<span><span class='c'>#&gt; • .pred_not_Adelie = 1 - (1 - 1/(1 + exp(dplyr::case_when(bill_len ...</span></span>
<span><span class='c'>#&gt; • .pred_class = dplyr::case_when( .pred_Adelie &gt; 0.5 + 0.2 ~ 'Adel ...</span></span>
<span><span class='c'>#&gt; ─────────────────────────────────────────────────────────────────────────</span></span>
<span><span class='c'>#&gt; 6 equations in total.</span></span>
<span></span></code></pre>

</div>

This object contains all the information that is needed to produce predictions. Which we can produce with [`predict()`](https://rdrr.io/r/stats/predict.html).

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>preds</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/stats/predict.html'>predict</a></span><span class='o'>(</span><span class='nv'>orbital_obj</span>, <span class='nv'>penguins</span><span class='o'>)</span></span>
<span><span class='nv'>preds</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 344 × 3</span></span></span>
<span><span class='c'>#&gt;    .pred_class .pred_Adelie .pred_not_Adelie</span></span>
<span><span class='c'>#&gt;    <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>              <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>            <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 1</span> Adelie             0.845            0.155</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 2</span> Adelie             0.845            0.155</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 3</span> Adelie             0.845            0.155</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 4</span> not_Adelie         0.291            0.709</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 5</span> Adelie             0.845            0.155</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 6</span> Adelie             0.845            0.155</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 7</span> Adelie             0.845            0.155</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 8</span> Adelie             0.845            0.155</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 9</span> Adelie             0.845            0.155</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>10</span> Adelie             0.845            0.155</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># ℹ 334 more rows</span></span></span>
<span></span></code></pre>

</div>

The predictions are working; however, we don't see any evidence that `adjust_equivocal_zone()` is working. A call to `count()` reveals that a couple of observation lands in the equivocal zone.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'>count</span><span class='o'>(</span><span class='nv'>preds</span>, <span class='nv'>.pred_class</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 3 × 2</span></span></span>
<span><span class='c'>#&gt;   .pred_class     n</span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>       <span style='color: #555555; font-style: italic;'>&lt;int&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span> Adelie        144</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span> [EQ]           15</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>3</span> not_Adelie    185</span></span>
<span></span></code></pre>

</div>

And we can further verify that they are correct.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://rdrr.io/r/stats/filter.html'>filter</a></span><span class='o'>(</span><span class='nv'>preds</span>, <span class='nv'>.pred_class</span> <span class='o'>==</span> <span class='s'>'[EQ]'</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 15 × 3</span></span></span>
<span><span class='c'>#&gt;    .pred_class .pred_Adelie .pred_not_Adelie</span></span>
<span><span class='c'>#&gt;    <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>              <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>            <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 1</span> [EQ]               0.483            0.517</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 2</span> [EQ]               0.483            0.517</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 3</span> [EQ]               0.483            0.517</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 4</span> [EQ]               0.483            0.517</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 5</span> [EQ]               0.483            0.517</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 6</span> [EQ]               0.483            0.517</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 7</span> [EQ]               0.483            0.517</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 8</span> [EQ]               0.348            0.652</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 9</span> [EQ]               0.348            0.652</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>10</span> [EQ]               0.348            0.652</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>11</span> [EQ]               0.348            0.652</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>12</span> [EQ]               0.348            0.652</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>13</span> [EQ]               0.483            0.517</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>14</span> [EQ]               0.483            0.517</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>15</span> [EQ]               0.483            0.517</span></span>
<span></span></code></pre>

</div>

## New show_query method

One of the main purposes of orbital is to allow for predictions in databases.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://dbi.r-dbi.org'>DBI</a></span><span class='o'>)</span></span>
<span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://rsqlite.r-dbi.org'>RSQLite</a></span><span class='o'>)</span></span>
<span></span>
<span><span class='nv'>con_sqlite</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://dbi.r-dbi.org/reference/dbConnect.html'>dbConnect</a></span><span class='o'>(</span><span class='nf'><a href='https://rsqlite.r-dbi.org/reference/SQLite.html'>SQLite</a></span><span class='o'>(</span><span class='o'>)</span>, path <span class='o'>=</span> <span class='s'>":memory:"</span><span class='o'>)</span></span>
<span><span class='nv'>penguins_sqlite</span> <span class='o'>&lt;-</span> <span class='nf'>copy_to</span><span class='o'>(</span><span class='nv'>con_sqlite</span>, <span class='nv'>penguins</span>, name <span class='o'>=</span> <span class='s'>"penguins_table"</span><span class='o'>)</span></span></code></pre>

</div>

Having set up a database we could have used [`orbital_sql()`](https://orbital.tidymodels.org/reference/orbital_sql.html) to show what the SQL query would have looked like. For quick testing, the output isn't immediately ready to be pasted into its own file due to the `<SQL>` fragments within the output.

The `show_query()` method has been implemented to see exactly what the generated SQL looks like.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'>show_query</span><span class='o'>(</span><span class='nv'>orbital_obj</span>, <span class='nv'>con_sqlite</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; CASE WHEN ((`bill_length_mm` IS NULL)) THEN 43.9219298245614 WHEN NOT ((`bill_length_mm` IS NULL)) THEN `bill_length_mm` END AS bill_length_mm</span></span>
<span><span class='c'>#&gt; CASE WHEN ((`flipper_length_mm` IS NULL)) THEN 201.0 WHEN NOT ((`flipper_length_mm` IS NULL)) THEN `flipper_length_mm` END AS flipper_length_mm</span></span>
<span><span class='c'>#&gt; CASE</span></span>
<span><span class='c'>#&gt; WHEN ((1.0 - 1.0 / (1.0 + EXP(((((CASE</span></span>
<span><span class='c'>#&gt; WHEN (`bill_length_mm` &lt; 42.4000015) THEN 0.627138138</span></span>
<span><span class='c'>#&gt; WHEN ((`bill_length_mm` &gt;= 42.4000015 OR (`bill_length_mm` IS NULL))) THEN (-0.449751347)</span></span>
<span><span class='c'>#&gt; END + CASE</span></span>
<span><span class='c'>#&gt; WHEN (`bill_length_mm` &lt; 43.2999992) THEN 0.425288886</span></span>
<span><span class='c'>#&gt; WHEN ((`bill_length_mm` &gt;= 43.2999992 OR (`bill_length_mm` IS NULL))) THEN (-0.398178101)</span></span>
<span><span class='c'>#&gt; END) + CASE</span></span>
<span><span class='c'>#&gt; WHEN (`bill_length_mm` &lt; 42.4000015) THEN 0.380251437</span></span>
<span><span class='c'>#&gt; WHEN ((`bill_length_mm` &gt;= 42.4000015 OR (`bill_length_mm` IS NULL))) THEN (-0.306771189)</span></span>
<span><span class='c'>#&gt; END) + CASE</span></span>
<span><span class='c'>#&gt; WHEN (`bill_length_mm` &lt; 44.4000015) THEN 0.286071777</span></span>
<span><span class='c'>#&gt; WHEN ((`bill_length_mm` &gt;= 44.4000015 OR (`bill_length_mm` IS NULL))) THEN (-0.330096036)</span></span>
<span><span class='c'>#&gt; END) + CASE</span></span>
<span><span class='c'>#&gt; WHEN (`flipper_length_mm` &lt; 203.0) THEN 0.209298179</span></span>
<span><span class='c'>#&gt; WHEN ((`flipper_length_mm` &gt;= 203.0 OR (`flipper_length_mm` IS NULL))) THEN (-0.348002464)</span></span>
<span><span class='c'>#&gt; END) + LOG(0.44186047 / (1.0 - 0.44186047))))) &gt; 0.5) THEN 'Adelie'</span></span>
<span><span class='c'>#&gt; ELSE 'not_Adelie'</span></span>
<span><span class='c'>#&gt; END AS .pred_class</span></span>
<span><span class='c'>#&gt; 1.0 - 1.0 / (1.0 + EXP(((((CASE</span></span>
<span><span class='c'>#&gt; WHEN (`bill_length_mm` &lt; 42.4000015) THEN 0.627138138</span></span>
<span><span class='c'>#&gt; WHEN ((`bill_length_mm` &gt;= 42.4000015 OR (`bill_length_mm` IS NULL))) THEN (-0.449751347)</span></span>
<span><span class='c'>#&gt; END + CASE</span></span>
<span><span class='c'>#&gt; WHEN (`bill_length_mm` &lt; 43.2999992) THEN 0.425288886</span></span>
<span><span class='c'>#&gt; WHEN ((`bill_length_mm` &gt;= 43.2999992 OR (`bill_length_mm` IS NULL))) THEN (-0.398178101)</span></span>
<span><span class='c'>#&gt; END) + CASE</span></span>
<span><span class='c'>#&gt; WHEN (`bill_length_mm` &lt; 42.4000015) THEN 0.380251437</span></span>
<span><span class='c'>#&gt; WHEN ((`bill_length_mm` &gt;= 42.4000015 OR (`bill_length_mm` IS NULL))) THEN (-0.306771189)</span></span>
<span><span class='c'>#&gt; END) + CASE</span></span>
<span><span class='c'>#&gt; WHEN (`bill_length_mm` &lt; 44.4000015) THEN 0.286071777</span></span>
<span><span class='c'>#&gt; WHEN ((`bill_length_mm` &gt;= 44.4000015 OR (`bill_length_mm` IS NULL))) THEN (-0.330096036)</span></span>
<span><span class='c'>#&gt; END) + CASE</span></span>
<span><span class='c'>#&gt; WHEN (`flipper_length_mm` &lt; 203.0) THEN 0.209298179</span></span>
<span><span class='c'>#&gt; WHEN ((`flipper_length_mm` &gt;= 203.0 OR (`flipper_length_mm` IS NULL))) THEN (-0.348002464)</span></span>
<span><span class='c'>#&gt; END) + LOG(0.44186047 / (1.0 - 0.44186047)))) AS .pred_Adelie</span></span>
<span><span class='c'>#&gt; 1.0 - (1.0 - 1.0 / (1.0 + EXP(((((CASE</span></span>
<span><span class='c'>#&gt; WHEN (`bill_length_mm` &lt; 42.4000015) THEN 0.627138138</span></span>
<span><span class='c'>#&gt; WHEN ((`bill_length_mm` &gt;= 42.4000015 OR (`bill_length_mm` IS NULL))) THEN (-0.449751347)</span></span>
<span><span class='c'>#&gt; END + CASE</span></span>
<span><span class='c'>#&gt; WHEN (`bill_length_mm` &lt; 43.2999992) THEN 0.425288886</span></span>
<span><span class='c'>#&gt; WHEN ((`bill_length_mm` &gt;= 43.2999992 OR (`bill_length_mm` IS NULL))) THEN (-0.398178101)</span></span>
<span><span class='c'>#&gt; END) + CASE</span></span>
<span><span class='c'>#&gt; WHEN (`bill_length_mm` &lt; 42.4000015) THEN 0.380251437</span></span>
<span><span class='c'>#&gt; WHEN ((`bill_length_mm` &gt;= 42.4000015 OR (`bill_length_mm` IS NULL))) THEN (-0.306771189)</span></span>
<span><span class='c'>#&gt; END) + CASE</span></span>
<span><span class='c'>#&gt; WHEN (`bill_length_mm` &lt; 44.4000015) THEN 0.286071777</span></span>
<span><span class='c'>#&gt; WHEN ((`bill_length_mm` &gt;= 44.4000015 OR (`bill_length_mm` IS NULL))) THEN (-0.330096036)</span></span>
<span><span class='c'>#&gt; END) + CASE</span></span>
<span><span class='c'>#&gt; WHEN (`flipper_length_mm` &lt; 203.0) THEN 0.209298179</span></span>
<span><span class='c'>#&gt; WHEN ((`flipper_length_mm` &gt;= 203.0 OR (`flipper_length_mm` IS NULL))) THEN (-0.348002464)</span></span>
<span><span class='c'>#&gt; END) + LOG(0.44186047 / (1.0 - 0.44186047))))) AS .pred_not_Adelie</span></span>
<span><span class='c'>#&gt; CASE</span></span>
<span><span class='c'>#&gt; WHEN (`.pred_Adelie` &gt; (0.5 + 0.2)) THEN 'Adelie'</span></span>
<span><span class='c'>#&gt; WHEN (`.pred_Adelie` &lt; (0.5 - 0.2)) THEN 'not_Adelie'</span></span>
<span><span class='c'>#&gt; ELSE '[EQ]'</span></span>
<span><span class='c'>#&gt; END AS .pred_class</span></span>
<span></span></code></pre>

</div>

## Acknowledgements

A big thank you to all the people who have contributed to orbital since the release of v0.4.0:

[@EmilHvitfeldt](https://github.com/EmilHvitfeldt), [@frankiethull](https://github.com/frankiethull), [@jeroenjanssens](https://github.com/jeroenjanssens), and [@topepo](https://github.com/topepo).

