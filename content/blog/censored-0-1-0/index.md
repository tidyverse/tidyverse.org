---
output: hugodown::hugo_document

slug: censored-0-1-0
title: censored 0.1.0
date: 2022-08-10
author: Hannah Frick
description: >
    censored 0.1.0 is a new tidymodels package for survival models.

photo:
  url: https://unsplash.com/photos/UDlXygG0pgA
  author: Ranae Smith

# one of: "deep-dive", "learn", "package", "programming", "roundup", or "other"
categories: [package] 
tags: [tidymodels, parsnip, censored]
rmd_hash: 969dea0da72d7243

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

We're extremely pleased to announce the first release of [censored](https://censored.tidymodels.org) on CRAN. The censored package is a parsnip extension package for survival models.

You can install it from CRAN with:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://rdrr.io/r/utils/install.packages.html'>install.packages</a></span><span class='o'>(</span><span class='s'>"censored"</span><span class='o'>)</span></code></pre>

</div>

This blog post will introduce a new model type, a new mode, and new prediction types for survival analysis in the tidymodels framework. We have [previously](https://www.tidyverse.org/blog/2021/11/survival-analysis-parsnip-adjacent/) blogged about these changes while they were in development, now they have been released!

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://github.com/tidymodels/censored'>censored</a></span><span class='o'>)</span>
<span class='c'>#&gt; Loading required package: parsnip</span>
<span class='c'>#&gt; Loading required package: survival</span></code></pre>

</div>

## Model types, modes, and engines

A parsnip model specification consists of three elements:

-   a **model type** such as linear model, random forest, support vector machine, etc
-   a computational **engine** such as a specific R package or tools outside of R like Keras or Stan
-   a **mode** such as regression or classification

parsnip 1.0.0 introduces a new mode `"censored regression"` and the censored package provides engines to fit various models in this new mode. With the addition of the new [`proportional_hazards()`](https://parsnip.tidymodels.org/reference/proportional_hazards.html) model type, the available models cover parametric, semi-parametric, and tree-based models:

| model                    | engine   |
|:-------------------------|:---------|
| [`bag_tree()`](https://parsnip.tidymodels.org/reference/bag_tree.html)             | rpart    |
| [`boost_tree()`](https://parsnip.tidymodels.org/reference/boost_tree.html)           | mboost   |
| [`decision_tree()`](https://parsnip.tidymodels.org/reference/decision_tree.html)        | rpart    |
| [`decision_tree()`](https://parsnip.tidymodels.org/reference/decision_tree.html)        | partykit |
| [`proportional_hazards()`](https://parsnip.tidymodels.org/reference/proportional_hazards.html) | survival |
| [`proportional_hazards()`](https://parsnip.tidymodels.org/reference/proportional_hazards.html) | glmnet   |
| [`rand_forest()`](https://parsnip.tidymodels.org/reference/rand_forest.html)          | partykit |
| [`survival_reg()`](https://parsnip.tidymodels.org/reference/survival_reg.html)         | survival |
| [`survival_reg()`](https://parsnip.tidymodels.org/reference/survival_reg.html)         | flexsurv |

All models can be fitted through a formula interface. For example, when the engine allows for stratification variables, these can be specified by using a [`strata()`](https://rdrr.io/pkg/survival/man/strata.html) term in the formula, as in the survival package.

The `cetaceans` data set contains information about dolphins and whales living in captivity in the USA. It is derived from a [Tidy Tuesday data set](https://github.com/rfordatascience/tidytuesday/tree/master/data/2018/2018-12-18) and you can install the corresponding data package with `pak::pak("hfrick/cetaceans")`.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'>cetaceans</span><span class='o'>)</span>
<span class='nf'><a href='https://rdrr.io/r/utils/str.html'>str</a></span><span class='o'>(</span><span class='nv'>cetaceans</span><span class='o'>)</span>
<span class='c'>#&gt; tibble [1,358 × 10] (S3: tbl_df/tbl/data.frame)</span>
<span class='c'>#&gt;  $ age              : num [1:1358] 28 44 39 38 38 37 36 36 35 34 ...</span>
<span class='c'>#&gt;  $ event            : num [1:1358] 0 0 0 0 0 0 0 0 0 0 ...</span>
<span class='c'>#&gt;  $ species          : chr [1:1358] "Bottlenose" "Bottlenose" "Bottlenose" "Bottlenose" ...</span>
<span class='c'>#&gt;  $ sex              : chr [1:1358] "F" "F" "M" "F" ...</span>
<span class='c'>#&gt;  $ birth_decade     : num [1:1358] 1980 1970 1970 1970 1970 1980 1980 1980 1980 1980 ...</span>
<span class='c'>#&gt;  $ born_in_captivity: logi [1:1358] TRUE TRUE TRUE TRUE TRUE TRUE ...</span>
<span class='c'>#&gt;  $ time_in_captivity: num [1:1358] 1 1 1 1 1 1 1 1 1 1 ...</span>
<span class='c'>#&gt;  $ origin_location  : chr [1:1358] "Marineland Florida" "Dolphin Research Center" "SeaWorld" "SeaWorld" ...</span>
<span class='c'>#&gt;  $ transfers        : int [1:1358] 0 0 13 1 2 2 2 2 3 4 ...</span>
<span class='c'>#&gt;  $ current_location : chr [1:1358] "Marineland Florida" "Dolphin Research Center" "SeaWorld" "SeaWorld" ...</span></code></pre>

</div>

To illustrate the new modelling function [`proportional_hazards()`](https://parsnip.tidymodels.org/reference/proportional_hazards.html) and the formula interface for glmnet, let's fit a penalized Cox model.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>cox_penalized</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://parsnip.tidymodels.org/reference/proportional_hazards.html'>proportional_hazards</a></span><span class='o'>(</span>penalty <span class='o'>=</span> <span class='m'>0.1</span><span class='o'>)</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span>
  <span class='nf'><a href='https://parsnip.tidymodels.org/reference/set_engine.html'>set_engine</a></span><span class='o'>(</span><span class='s'>"glmnet"</span><span class='o'>)</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span>
  <span class='nf'><a href='https://parsnip.tidymodels.org/reference/set_args.html'>set_mode</a></span><span class='o'>(</span><span class='s'>"censored regression"</span><span class='o'>)</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span>
  <span class='nf'><a href='https://generics.r-lib.org/reference/fit.html'>fit</a></span><span class='o'>(</span>
    <span class='nf'><a href='https://rdrr.io/pkg/survival/man/Surv.html'>Surv</a></span><span class='o'>(</span><span class='nv'>age</span>, <span class='nv'>event</span><span class='o'>)</span> <span class='o'>~</span> <span class='nv'>sex</span> <span class='o'>+</span> <span class='nv'>transfers</span> <span class='o'>+</span> <span class='nf'><a href='https://rdrr.io/pkg/survival/man/strata.html'>strata</a></span><span class='o'>(</span><span class='nv'>born_in_captivity</span><span class='o'>)</span>,
    data <span class='o'>=</span> <span class='nv'>cetaceans</span>
  <span class='o'>)</span></code></pre>

</div>

## Prediction types

For censored regression, parsnip now also includes new prediction types:

-   `"time"` for the survival time
-   `"survival"` for the survival probability
-   `"hazard"` for the hazard
-   `"quantile"` for quantiles of the event time distribution
-   `"linear_pred"` for the linear predictor

Predictions made with censored respect the tidymodels principles of:

-   The predictions are always inside a tibble.
-   The column names and types are unsurprising and predictable.
-   The number of rows in `new_data` and the output are the same.

Let's demonstrate that with a small data set to predict on: just three observations, and the first one includes a missing value for one of the predictors.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>cetaceans_3</span> <span class='o'>&lt;-</span> <span class='nv'>cetaceans</span><span class='o'>[</span><span class='m'>1</span><span class='o'>:</span><span class='m'>3</span>,<span class='o'>]</span>
<span class='nv'>cetaceans_3</span><span class='o'>$</span><span class='nv'>sex</span><span class='o'>[</span><span class='m'>1</span><span class='o'>]</span> <span class='o'>&lt;-</span> <span class='kc'>NA</span></code></pre>

</div>

Predictions of types `"time"` and `"survival"` are available for all model/engine combinations in censored.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://rdrr.io/r/stats/predict.html'>predict</a></span><span class='o'>(</span><span class='nv'>cox_penalized</span>, new_data <span class='o'>=</span> <span class='nv'>cetaceans_3</span>, type <span class='o'>=</span> <span class='s'>"time"</span><span class='o'>)</span>
<span class='c'>#&gt; <span style='color: #555555;'># A tibble: 3 × 1</span></span>
<span class='c'>#&gt;   .pred_time</span>
<span class='c'>#&gt;        <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>1</span>       <span style='color: #BB0000;'>NA</span>  </span>
<span class='c'>#&gt; <span style='color: #555555;'>2</span>       31.8</span>
<span class='c'>#&gt; <span style='color: #555555;'>3</span>       52.6</span></code></pre>

</div>

Survival probability can be predicted at multiple time points, specified through the `time` argument to [`predict()`](https://rdrr.io/r/stats/predict.html). Here we are predicting survival probability at age 10, 20, 30, and 40 years.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>pred</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/stats/predict.html'>predict</a></span><span class='o'>(</span><span class='nv'>cox_penalized</span>, new_data <span class='o'>=</span> <span class='nv'>cetaceans_3</span>, type <span class='o'>=</span> <span class='s'>"survival"</span>, time <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='m'>10</span>, <span class='m'>20</span>, <span class='m'>30</span>, <span class='m'>40</span><span class='o'>)</span><span class='o'>)</span>
<span class='nv'>pred</span>
<span class='c'>#&gt; <span style='color: #555555;'># A tibble: 3 × 1</span></span>
<span class='c'>#&gt;   .pred           </span>
<span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;list&gt;</span>          </span>
<span class='c'>#&gt; <span style='color: #555555;'>1</span> <span style='color: #555555;'>&lt;tibble [4 × 2]&gt;</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>2</span> <span style='color: #555555;'>&lt;tibble [4 × 2]&gt;</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>3</span> <span style='color: #555555;'>&lt;tibble [4 × 2]&gt;</span></span></code></pre>

</div>

The `.pred` column is a list-column, containing nested tibbles:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='c'># for the observation with NA</span>
<span class='nv'>pred</span><span class='o'>$</span><span class='nv'>.pred</span><span class='o'>[[</span><span class='m'>1</span><span class='o'>]</span><span class='o'>]</span>
<span class='c'>#&gt; <span style='color: #555555;'># A tibble: 4 × 2</span></span>
<span class='c'>#&gt;   .time .pred_survival</span>
<span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>          <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>1</span>    10             <span style='color: #BB0000;'>NA</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>2</span>    20             <span style='color: #BB0000;'>NA</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>3</span>    30             <span style='color: #BB0000;'>NA</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>4</span>    40             <span style='color: #BB0000;'>NA</span></span>

<span class='c'># without NA</span>
<span class='nv'>pred</span><span class='o'>$</span><span class='nv'>.pred</span><span class='o'>[[</span><span class='m'>2</span><span class='o'>]</span><span class='o'>]</span>
<span class='c'>#&gt; <span style='color: #555555;'># A tibble: 4 × 2</span></span>
<span class='c'>#&gt;   .time .pred_survival</span>
<span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>          <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>1</span>    10          0.729</span>
<span class='c'>#&gt; <span style='color: #555555;'>2</span>    20          0.567</span>
<span class='c'>#&gt; <span style='color: #555555;'>3</span>    30          0.386</span>
<span class='c'>#&gt; <span style='color: #555555;'>4</span>    40          0.386</span></code></pre>

</div>

This can be used to visualize an approximation of the underlying survival curve.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://ggplot2.tidyverse.org'>ggplot2</a></span><span class='o'>)</span>

<span class='nf'><a href='https://rdrr.io/r/stats/predict.html'>predict</a></span><span class='o'>(</span><span class='nv'>cox_penalized</span>, new_data <span class='o'>=</span> <span class='nv'>cetaceans</span><span class='o'>[</span><span class='m'>2</span><span class='o'>:</span><span class='m'>3</span>,<span class='o'>]</span>, 
        type <span class='o'>=</span> <span class='s'>"survival"</span>, time <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/seq.html'>seq</a></span><span class='o'>(</span><span class='m'>0</span>, <span class='m'>80</span>, <span class='m'>1</span><span class='o'>)</span><span class='o'>)</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span> 
  <span class='nf'>dplyr</span><span class='nf'>::</span><span class='nf'><a href='https://dplyr.tidyverse.org/reference/mutate.html'>mutate</a></span><span class='o'>(</span>id <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/factor.html'>factor</a></span><span class='o'>(</span><span class='m'>2</span><span class='o'>:</span><span class='m'>3</span><span class='o'>)</span><span class='o'>)</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span> 
  <span class='nf'>tidyr</span><span class='nf'>::</span><span class='nf'><a href='https://tidyr.tidyverse.org/reference/nest.html'>unnest</a></span><span class='o'>(</span>cols <span class='o'>=</span> <span class='nv'>.pred</span><span class='o'>)</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span> 
  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggplot.html'>ggplot</a></span><span class='o'>(</span><span class='nf'><a href='https://ggplot2.tidyverse.org/reference/aes.html'>aes</a></span><span class='o'>(</span>x <span class='o'>=</span> <span class='nv'>.time</span>, y <span class='o'>=</span> <span class='nv'>.pred_survival</span>, col <span class='o'>=</span> <span class='nv'>id</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>+</span>
  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/geom_path.html'>geom_step</a></span><span class='o'>(</span><span class='o'>)</span> <span class='o'>+</span>
  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggtheme.html'>theme_bw</a></span><span class='o'>(</span><span class='o'>)</span>
</code></pre>
<img src="figs/survival-curve-1.png" width="700px" style="display: block; margin: auto;" />

</div>

More examples of available models, engines, and prediction types can be found in the article [Fitting and Predicting with censored](https://censored.tidymodels.org/articles/examples.html).

## What's next?

Our aim is to broadly integrate survival analysis in the tidymodels framework. Next, we'll be working on adding appropriate metrics to the yardstick package and enabling model tuning via the tune package.

## Acknowledgements

A big thanks to all the contributors: [@bcjaeger](https://github.com/bcjaeger), [@brunocarlin](https://github.com/brunocarlin), [@caimiao0714](https://github.com/caimiao0714), [@DavisVaughan](https://github.com/DavisVaughan), [@dvdsb](https://github.com/dvdsb), [@EmilHvitfeldt](https://github.com/EmilHvitfeldt), [@erikvona](https://github.com/erikvona), [@gvelasq](https://github.com/gvelasq), [@hfrick](https://github.com/hfrick), [@jennybc](https://github.com/jennybc), [@mattwarkentin](https://github.com/mattwarkentin), [@mikemahoney218](https://github.com/mikemahoney218), [@schelhorn](https://github.com/schelhorn), and [@topepo](https://github.com/topepo).

