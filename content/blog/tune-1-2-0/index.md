---
output: hugodown::hugo_document

slug: tune-1-2-0
title: tune 1.2.0
date: 2024-04-18
author: Simon Couch
description: >
    While we've written about survival analysis and machine learning fairness 
    already, the newest tune release includes a number of other major changes.

photo:
  url: https://unsplash.com/photos/1Pzhr6XPl6k
  author: Derek Story

categories: [package] 
tags: [tidymodels, tune, parallelism]
rmd_hash: a6fa78fc43bc6d12

---

<div class="highlight">

</div>

We're indubitably amped to announce the release of [tune](https://tune.tidymodels.org/) 1.2.0, a package for hyperparameter tuning in the [tidymodels framework](https://www.tidymodels.org/).

You can install it from CRAN, along with the rest of the core packages in tidymodels, using the tidymodels meta-package:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://rdrr.io/r/utils/install.packages.html'>install.packages</a></span><span class='o'>(</span><span class='s'>"tidymodels"</span><span class='o'>)</span></span></code></pre>

</div>

The 1.2.0 release of tune has introduced support for two major features that we've written about on the tidyverse blog already:

-   [Survival analysis for time-to-event data with tidymodels](https://www.tidyverse.org/blog/2024/04/tidymodels-survival-analysis/)
-   [Fair machine learning with tidymodels](https://www.tidyverse.org/blog/2024/03/tidymodels-fairness/)

While those features got their own blog posts, there are several more in this release that we thought were worth calling out. This post will highlight improvements to our support for parallel processing, introduction of support for percentile confidence intervals for performance metrics, and a few other bits and bobs. You can see a full list of changes in the [release notes](https://github.com/tidymodels/tune/releases/tag/v1.2.0).

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://tidymodels.tidymodels.org'>tidymodels</a></span><span class='o'>)</span></span></code></pre>

</div>

Throughout this post, I'll refer to the example of tuning an XGBoost model to predict the fuel efficiency of various car models. I hear this is already a well-explored modeling problem, but alas:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://rdrr.io/r/base/Random.html'>set.seed</a></span><span class='o'>(</span><span class='m'>2024</span><span class='o'>)</span></span>
<span></span>
<span><span class='nv'>xgb_res</span> <span class='o'>&lt;-</span> </span>
<span>  <span class='nf'>tune_grid</span><span class='o'>(</span></span>
<span>    <span class='nf'>boost_tree</span><span class='o'>(</span>mode <span class='o'>=</span> <span class='s'>"regression"</span>, mtry <span class='o'>=</span> <span class='nf'>tune</span><span class='o'>(</span><span class='o'>)</span>, learn_rate <span class='o'>=</span> <span class='nf'>tune</span><span class='o'>(</span><span class='o'>)</span><span class='o'>)</span>,</span>
<span>    <span class='nv'>mpg</span> <span class='o'>~</span> <span class='nv'>.</span>,</span>
<span>    <span class='nf'>bootstraps</span><span class='o'>(</span><span class='nv'>mtcars</span><span class='o'>)</span>,</span>
<span>    control <span class='o'>=</span> <span class='nf'>control_grid</span><span class='o'>(</span>save_pred <span class='o'>=</span> <span class='kc'>TRUE</span><span class='o'>)</span></span>
<span>  <span class='o'>)</span></span>
<span><span class='c'>#&gt; 10407 1523847456 -1848617311 -1361277970 -979033193 -878499092 -2050794755</span></span>
<span><span class='c'>#&gt; 10407 -1749431051 2049664161 -424116726 -1305918325 -498876097 1803933357</span></span>
<span><span class='c'>#&gt; 10407 -442865362 -1625359351 1831887819 -1726575624 -353030159 -16171787</span></span>
<span><span class='c'>#&gt; 10407 -893105428 336456598 1286441802 -1422091874 1062327954 -1355020861</span></span>
<span><span class='c'>#&gt; 10407 -2092097869 1987216093 -2031709361 -1206061097 -2086771890 -1979511053</span></span>
<span><span class='c'>#&gt; 10407 -1339583482 -364581237 1390267062 -114206992 1278702934 -213763861</span></span>
<span><span class='c'>#&gt; 10407 1114014189 -259827034 898019029 636355055 -1372428962 1845673968</span></span>
<span><span class='c'>#&gt; 10407 -383760607 -1886553406 269404824 -354885766 -422181986 637337179</span></span>
<span><span class='c'>#&gt; 10407 1930150197 2022843641 145719127 -735985733 -230724074 1440864742</span></span>
<span><span class='c'>#&gt; 10407 448913203 -1886748889 -2069212595 -1385131576 128680149 -2023352448</span></span>
<span><span class='c'>#&gt; 10407 -313532317 -407029021 836586038 -1583585869 1126244092 1980566493</span></span>
<span><span class='c'>#&gt; 10407 -449604037 1587505813 1871718195 -1097040931 -825066603 -2050373151</span></span>
<span><span class='c'>#&gt; 10407 1307128455 514654381 802339433 -917513502 -1185219243 -1398759104</span></span>
<span><span class='c'>#&gt; 10407 257800933 -2114892211 -320697118 -105352173 -1945252908 -863173574</span></span>
<span><span class='c'>#&gt; 10407 -4901089 -48546865 722587638 1419327113 -654975314 -2145281395</span></span>
<span><span class='c'>#&gt; 10407 -1058663242 2062304550 -1033279044 -94975559 -1818430575 -1809210516</span></span>
<span><span class='c'>#&gt; 10407 890029441 -758415837 -1552096301 -250994848 948317958 -2071284316</span></span>
<span><span class='c'>#&gt; 10407 -1391485567 -470194335 1303060429 -1968802035 1272928276 -511521013</span></span>
<span><span class='c'>#&gt; 10407 503213760 -530814852 -613687476 2131961742 -1735036425 1251964395</span></span>
<span><span class='c'>#&gt; 10407 1758305765 1359764743 -993545149 -1911762755 1624953667 -1694531802</span></span>
<span><span class='c'>#&gt; 10407 1118715361 -1077776996 -1984740398 -338338778 851218164 1118698228</span></span>
<span><span class='c'>#&gt; 10407 -838173101 -1021953012 -1093921146 -507804506 -1283535089 634777010</span></span>
<span><span class='c'>#&gt; 10407 1546664513 -738661842 -1320140673 -1384151599 -1637567235 -1698604010</span></span>
<span><span class='c'>#&gt; 10407 -263111828 702050825 -343250572 224066889 1360674532 1395537310</span></span>
<span><span class='c'>#&gt; 10407 1129030376 485378116 -442484020 1681810023 -1768087069 280713862</span></span>
<span></span></code></pre>

</div>

Note that we've used the [control option](https://tune.tidymodels.org/reference/control_grid.html) `save_pred = TRUE` to indicate that we want to save the predictions from our resampled models in the tuning results. Both `int_pctl()` and `compute_metrics()` below will need those predictions. The metrics for our resampled model look like so:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'>collect_metrics</span><span class='o'>(</span><span class='nv'>xgb_res</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 20 × 8</span></span></span>
<span><span class='c'>#&gt;    mtry learn_rate .metric .estimator   mean     n std_err .config              </span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;int&gt;</span>      <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>   <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>       <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;int&gt;</span>   <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>                </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span>     2    0.002<span style='text-decoration: underline;'>04</span> rmse    standard   19.7      25  0.262  Preprocessor1_Model01</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span>     2    0.002<span style='text-decoration: underline;'>04</span> rsq     standard    0.659    25  0.031<span style='text-decoration: underline;'>4</span> Preprocessor1_Model01</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>3</span>     6    0.008<span style='text-decoration: underline;'>59</span> rmse    standard   18.0      25  0.260  Preprocessor1_Model02</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>4</span>     6    0.008<span style='text-decoration: underline;'>59</span> rsq     standard    0.607    25  0.027<span style='text-decoration: underline;'>0</span> Preprocessor1_Model02</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>5</span>     3    0.027<span style='text-decoration: underline;'>6</span>  rmse    standard   14.0      25  0.267  Preprocessor1_Model03</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>6</span>     3    0.027<span style='text-decoration: underline;'>6</span>  rsq     standard    0.710    25  0.023<span style='text-decoration: underline;'>7</span> Preprocessor1_Model03</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># ℹ 14 more rows</span></span></span>
<span></span></code></pre>

</div>

## Modernized support for parallel processing

The tidymodels framework has long supported evaluating models in parallel using the [foreach](https://cran.r-project.org/web/packages/foreach/vignettes/foreach.html) package. This release of tune has introduced support for parallelism using the [futureverse](https://www.futureverse.org/) framework, and we will begin deprecating our support for foreach in a coming release.

To tune a model in parallel with foreach, a user would load a *parallel backend* package (usually with a name like [`library(doBackend)`](https://rdrr.io/r/base/library.html)) and then *register* it with foreach (with a function call like `registerDoBackend()`). The tune package would then detect that registered backend and take it from there. For example, the code to distribute the above tuning process across 10 cores with foreach would look like:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'>doMC</span><span class='o'>)</span></span>
<span><span class='nf'><a href='https://rdrr.io/pkg/doMC/man/registerDoMC.html'>registerDoMC</a></span><span class='o'>(</span>cores <span class='o'>=</span> <span class='m'>10</span><span class='o'>)</span></span>
<span></span>
<span><span class='nf'><a href='https://rdrr.io/r/base/Random.html'>set.seed</a></span><span class='o'>(</span><span class='m'>2024</span><span class='o'>)</span></span>
<span></span>
<span><span class='nv'>xgb_res</span> <span class='o'>&lt;-</span> </span>
<span>  <span class='nf'>tune_grid</span><span class='o'>(</span></span>
<span>    <span class='nf'>boost_tree</span><span class='o'>(</span>mode <span class='o'>=</span> <span class='s'>"regression"</span>, mtry <span class='o'>=</span> <span class='nf'>tune</span><span class='o'>(</span><span class='o'>)</span>, learn_rate <span class='o'>=</span> <span class='nf'>tune</span><span class='o'>(</span><span class='o'>)</span><span class='o'>)</span>,</span>
<span>    <span class='nv'>mpg</span> <span class='o'>~</span> <span class='nv'>.</span>,</span>
<span>    <span class='nf'>bootstraps</span><span class='o'>(</span><span class='nv'>mtcars</span><span class='o'>)</span>,</span>
<span>    control <span class='o'>=</span> <span class='nf'>control_grid</span><span class='o'>(</span>save_pred <span class='o'>=</span> <span class='kc'>TRUE</span><span class='o'>)</span></span>
<span>  <span class='o'>)</span></span></code></pre>

</div>

The code to do so with future is similarly simple. Users first load the [future](https://future.futureverse.org/index.html) package, and then specify a [`plan()`](https://future.futureverse.org/reference/plan.html) which dictates how computations will be distributed. For example, the code to distribute the above tuning process across 10 cores with future looks like:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://future.futureverse.org'>future</a></span><span class='o'>)</span></span>
<span><span class='nf'><a href='https://future.futureverse.org/reference/plan.html'>plan</a></span><span class='o'>(</span><span class='nv'>multisession</span>, workers <span class='o'>=</span> <span class='m'>10</span><span class='o'>)</span></span>
<span></span>
<span><span class='nf'><a href='https://rdrr.io/r/base/Random.html'>set.seed</a></span><span class='o'>(</span><span class='m'>2024</span><span class='o'>)</span></span>
<span></span>
<span><span class='nv'>xgb_res</span> <span class='o'>&lt;-</span> </span>
<span>  <span class='nf'>tune_grid</span><span class='o'>(</span></span>
<span>    <span class='nf'>boost_tree</span><span class='o'>(</span>mode <span class='o'>=</span> <span class='s'>"regression"</span>, mtry <span class='o'>=</span> <span class='nf'>tune</span><span class='o'>(</span><span class='o'>)</span>, learn_rate <span class='o'>=</span> <span class='nf'>tune</span><span class='o'>(</span><span class='o'>)</span><span class='o'>)</span>,</span>
<span>    <span class='nv'>mpg</span> <span class='o'>~</span> <span class='nv'>.</span>,</span>
<span>    <span class='nf'>bootstraps</span><span class='o'>(</span><span class='nv'>mtcars</span><span class='o'>)</span>,</span>
<span>    control <span class='o'>=</span> <span class='nf'>control_grid</span><span class='o'>(</span>save_pred <span class='o'>=</span> <span class='kc'>TRUE</span><span class='o'>)</span></span>
<span>  <span class='o'>)</span></span></code></pre>

</div>

For users, the transition to parallelism with future has several benefits:

-   The futureverse presently supports a greater number of parallelism technologies and has been more likely to receive implementations for new ones.
-   Once foreach is fully deprecated, users will be able to use the [interactive logger](https://www.tidyverse.org/blog/2023/04/tuning-delights/#interactive-issue-logging) when tuning in parallel.

From our perspective, transitioning our parallelism support to future makes our packages much more maintainable, reducing complexity in random number generation, error handling, and progress reporting.

In the next release of the package, you'll see a deprecation warning when a foreach parallel backend is registered but no future plan has been specified, so start transitioning your code sooner than later!

## Percentile confidence intervals

Following up on changes in the [most recent rsample release](https://github.com/tidymodels/rsample/releases/tag/v1.2.0), tune introduced a [method for `int_pctl()`](https://tune.tidymodels.org/reference/int_pctl.tune_results.html) that calculates percentile confidence intervals for performance metrics. To calculate a 90% confidence interval for the values of each performance metric returned in `collect_metrics()`, we'd write:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://rdrr.io/r/base/Random.html'>set.seed</a></span><span class='o'>(</span><span class='m'>2024</span><span class='o'>)</span></span>
<span></span>
<span><span class='nf'>int_pctl</span><span class='o'>(</span><span class='nv'>xgb_res</span>, alpha <span class='o'>=</span> <span class='m'>.1</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 20 × 8</span></span></span>
<span><span class='c'>#&gt;   .metric .estimator .lower .estimate .upper .config             mtry learn_rate</span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>   <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>       <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>     <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>  <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>              <span style='color: #555555; font-style: italic;'>&lt;int&gt;</span>      <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span> rmse    bootstrap  18.1      19.9   22.0   Preprocessor1_Mod…     2    0.002<span style='text-decoration: underline;'>04</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span> rsq     bootstrap   0.570     0.679  0.778 Preprocessor1_Mod…     2    0.002<span style='text-decoration: underline;'>04</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>3</span> rmse    bootstrap  16.6      18.3   19.9   Preprocessor1_Mod…     6    0.008<span style='text-decoration: underline;'>59</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>4</span> rsq     bootstrap   0.548     0.665  0.765 Preprocessor1_Mod…     6    0.008<span style='text-decoration: underline;'>59</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>5</span> rmse    bootstrap  12.5      14.1   15.9   Preprocessor1_Mod…     3    0.027<span style='text-decoration: underline;'>6</span> </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>6</span> rsq     bootstrap   0.622     0.720  0.818 Preprocessor1_Mod…     3    0.027<span style='text-decoration: underline;'>6</span> </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># ℹ 14 more rows</span></span></span>
<span></span></code></pre>

</div>

Note that the output has the same number of rows as the `collect_metrics()` output: one for each unique pair of metric and workflow.

This is very helpful for validation sets. Other resampling methods generate replicated performance statistics. We can compute simple interval estimates using the mean and standard error for those. Validation sets produce only one estimate, and these bootstrap methods are probably the best option for obtaining interval estimates.

## Breaking change: relocation of ellipses

We've made a **breaking change** in argument order for several functions in the package (and downstream packages like finetune and workflowsets). Ellipses (...) are now used consistently in the package to require optional arguments to be named. For functions that previously had unused ellipses at the end of the function signature, they have been moved to follow the last argument without a default value, and several other functions that previously did not have ellipses in their signatures gained them. This applies to methods for `augment()`, `collect_predictions()`, `collect_metrics()`, `select_best()`, `show_best()`, and `conf_mat_resampled()`.

## Compute new metrics without re-fitting

We also added a new function, [`compute_metrics()`](https://tune.tidymodels.org/reference/compute_metrics.html), that allows for calculating metric values for metrics that were not used when evaluating against resamples. For example, consider our `xgb_res` object. Since we didn't supply any metrics to evaluate, and this model is a regression model, tidymodels selected Root Mean Squared Error and R-Squared as defaults:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'>collect_metrics</span><span class='o'>(</span><span class='nv'>xgb_res</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 20 × 8</span></span></span>
<span><span class='c'>#&gt;    mtry learn_rate .metric .estimator   mean     n std_err .config              </span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;int&gt;</span>      <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>   <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>       <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;int&gt;</span>   <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>                </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span>     2    0.002<span style='text-decoration: underline;'>04</span> rmse    standard   19.7      25  0.262  Preprocessor1_Model01</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span>     2    0.002<span style='text-decoration: underline;'>04</span> rsq     standard    0.659    25  0.031<span style='text-decoration: underline;'>4</span> Preprocessor1_Model01</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>3</span>     6    0.008<span style='text-decoration: underline;'>59</span> rmse    standard   18.0      25  0.260  Preprocessor1_Model02</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>4</span>     6    0.008<span style='text-decoration: underline;'>59</span> rsq     standard    0.607    25  0.027<span style='text-decoration: underline;'>0</span> Preprocessor1_Model02</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>5</span>     3    0.027<span style='text-decoration: underline;'>6</span>  rmse    standard   14.0      25  0.267  Preprocessor1_Model03</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>6</span>     3    0.027<span style='text-decoration: underline;'>6</span>  rsq     standard    0.710    25  0.023<span style='text-decoration: underline;'>7</span> Preprocessor1_Model03</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># ℹ 14 more rows</span></span></span>
<span></span></code></pre>

</div>

In the past, if you wanted to evaluate that workflow against a performance metric that you hadn't included in your `tune_grid()` run, you'd need to re-run `tune_grid()`, fitting models and predicting new values all over again. Now, using the `compute_metrics()` function, you can use the `tune_grid()` output you've already generated and compute any number of new metrics without having to fit any more models as long as you use the control option `save_pred = TRUE` when tuning.

So, say I want to additionally calculate Huber Loss and Mean Absolute Percent Error. I just pass those metrics along with the tuning result to `compute_metrics()`, and the result looks just like `collect_metrics()` output for the metrics originally calculated:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'>compute_metrics</span><span class='o'>(</span><span class='nv'>xgb_res</span>, <span class='nf'>metric_set</span><span class='o'>(</span><span class='nv'>huber_loss</span>, <span class='nv'>mape</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 20 × 8</span></span></span>
<span><span class='c'>#&gt;    mtry learn_rate .metric    .estimator  mean     n std_err .config            </span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;int&gt;</span>      <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>      <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>      <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;int&gt;</span>   <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>              </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span>     2    0.002<span style='text-decoration: underline;'>04</span> huber_loss standard    18.3    25  0.232  Preprocessor1_Mode…</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span>     2    0.002<span style='text-decoration: underline;'>04</span> mape       standard    94.4    25  0.068<span style='text-decoration: underline;'>5</span> Preprocessor1_Mode…</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>3</span>     6    0.008<span style='text-decoration: underline;'>59</span> huber_loss standard    16.7    25  0.229  Preprocessor1_Mode…</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>4</span>     6    0.008<span style='text-decoration: underline;'>59</span> mape       standard    85.7    25  0.178  Preprocessor1_Mode…</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>5</span>     3    0.027<span style='text-decoration: underline;'>6</span>  huber_loss standard    12.6    25  0.230  Preprocessor1_Mode…</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>6</span>     3    0.027<span style='text-decoration: underline;'>6</span>  mape       standard    64.4    25  0.435  Preprocessor1_Mode…</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># ℹ 14 more rows</span></span></span>
<span></span></code></pre>

</div>

## Easily pivot resampled metrics

Finally, the `collect_metrics()` method for tune results recently [gained a new argument](https://tune.tidymodels.org/reference/collect_predictions.html#arguments), `type`, indicating the shape of the returned metrics. The default, `type = "long"`, is the same shape as before. The argument value `type = "wide"` will allot each metric its own column, making it easier to compare metrics across different models.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'>collect_metrics</span><span class='o'>(</span><span class='nv'>xgb_res</span>, type <span class='o'>=</span> <span class='s'>"wide"</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 10 × 5</span></span></span>
<span><span class='c'>#&gt;    mtry learn_rate .config                rmse   rsq</span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;int&gt;</span>      <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>                 <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span>     2    0.002<span style='text-decoration: underline;'>04</span> Preprocessor1_Model01  19.7 0.659</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span>     6    0.008<span style='text-decoration: underline;'>59</span> Preprocessor1_Model02  18.0 0.607</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>3</span>     3    0.027<span style='text-decoration: underline;'>6</span>  Preprocessor1_Model03  14.0 0.710</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>4</span>     2    0.037<span style='text-decoration: underline;'>1</span>  Preprocessor1_Model04  12.3 0.728</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>5</span>     5    0.005<span style='text-decoration: underline;'>39</span> Preprocessor1_Model05  18.8 0.595</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>6</span>     9    0.011<span style='text-decoration: underline;'>0</span>  Preprocessor1_Model06  17.4 0.577</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># ℹ 4 more rows</span></span></span>
<span></span></code></pre>

</div>

Under the hood, this is indeed just a `pivot_wider()` call. We've found that it's time-consuming and error-prone to programmatically determine identifying columns when pivoting resampled metrics, so we've localized and thoroughly tested the code that we use to do so with this feature.

## More love for the Brier score

Tuning and resampling functions use default metrics when the user does not specify a custom metric set. For regression models, these are RMSE and R<sup>2</sup>. For classification, accuracy and the area under the ROC curve *were* the default. We've also added the [Brier score](https://en.wikipedia.org/wiki/Brier_score) to the default classification metric list.

## Acknowledgements

As always, we're appreciative of the community contributors who helped make this release happen: [@AlbertoImg](https://github.com/AlbertoImg), [@dramanica](https://github.com/dramanica), [@epiheather](https://github.com/epiheather), [@joranE](https://github.com/joranE), [@jrosell](https://github.com/jrosell), [@jxu](https://github.com/jxu), [@kbodwin](https://github.com/kbodwin), [@kenraywilliams](https://github.com/kenraywilliams), [@KJT-Habitat](https://github.com/KJT-Habitat), [@lionel-](https://github.com/lionel-), [@marcozanotti](https://github.com/marcozanotti), [@MasterLuke84](https://github.com/MasterLuke84), [@mikemahoney218](https://github.com/mikemahoney218), [@PathosEthosLogos](https://github.com/PathosEthosLogos), and [@Peter4801](https://github.com/Peter4801).

<div class="highlight">

</div>

