---
output: hugodown::hugo_document

slug: tuning-delights
title: Tuning hyperparameters with tidymodels is a delight
date: 2023-04-20
author: Simon Couch
description: >
    New releases of the tune, finetune, and workflowsets packages have made 
    optimizing model parameters with tidymodels even more pleasant.

photo:
  url: https://unsplash.com/photos/Wrx0iVcYKmM
  author: Mario La Pergola

categories: [roundup] 
tags: [tidymodels, tune, workflowsets]
rmd_hash: 40a4a8679d8bb183

---

The tidymodels team recently released new versions of the tune, finetune, and workflowsets packages, and we're super stoked about it! Each of these three packages facilitates tuning hyperparameters in , and their new releases work to make the experience of hyperparameter tuning more joyful.

You can install these releases from CRAN with:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://rdrr.io/r/utils/install.packages.html'>install.packages</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"tune"</span>, <span class='s'>"workflowsets"</span>, <span class='s'>"finetune"</span><span class='o'>)</span><span class='o'>)</span></span></code></pre>

</div>

This blog post will highlight some of new changes in these packages that we're most excited about.

You can see the full lists of changes in the release notes for each package:

-   [tune v1.1.0](https://github.com/tidymodels/tune/releases/tag/v1.1.0)
-   [workflowsets v1.0.1](https://github.com/tidymodels/workflowsets/releases/tag/v1.0.1)
-   [finetune v1.1.0](https://github.com/tidymodels/finetune/releases/tag/v1.1.0)

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://tidymodels.tidymodels.org'>tidymodels</a></span><span class='o'>)</span></span>
<span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://github.com/tidymodels/finetune'>finetune</a></span><span class='o'>)</span></span></code></pre>

</div>

## A shorthand for fitting the optimal model

In , the result of tuning a set of hyperparameters is a data structure describing the candidate models, their predictions, and the performance metrics associated with those predictions. For example, tuning the number of `neighbors` in a `nearest_neighbors()` model over a regular grid:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='c'># tune the `neighbors` hyperparameter</span></span>
<span><span class='nv'>knn_model_spec</span> <span class='o'>&lt;-</span> <span class='nf'>nearest_neighbor</span><span class='o'>(</span><span class='s'>"regression"</span>, neighbors <span class='o'>=</span> <span class='nf'><a href='https://hardhat.tidymodels.org/reference/tune.html'>tune</a></span><span class='o'>(</span><span class='o'>)</span><span class='o'>)</span></span>
<span></span>
<span><span class='nv'>tuning_res</span> <span class='o'>&lt;-</span> </span>
<span>  <span class='nf'><a href='https://tune.tidymodels.org/reference/tune_grid.html'>tune_grid</a></span><span class='o'>(</span></span>
<span>    <span class='nv'>knn_model_spec</span>,</span>
<span>    <span class='nv'>mpg</span> <span class='o'>~</span> <span class='nv'>.</span>,</span>
<span>    <span class='nf'>bootstraps</span><span class='o'>(</span><span class='nv'>mtcars</span>, <span class='m'>5</span><span class='o'>)</span>,</span>
<span>    control <span class='o'>=</span> <span class='nf'><a href='https://tune.tidymodels.org/reference/control_grid.html'>control_grid</a></span><span class='o'>(</span>save_workflow <span class='o'>=</span> <span class='kc'>TRUE</span><span class='o'>)</span></span>
<span>  <span class='o'>)</span></span>
<span></span>
<span><span class='c'># check out the resulting object</span></span>
<span><span class='nv'>tuning_res</span></span>
<span><span class='c'>#&gt; # Tuning results</span></span>
<span><span class='c'>#&gt; # Bootstrap sampling </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 5 × 4</span></span></span>
<span><span class='c'>#&gt;   splits          id         .metrics          .notes          </span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;list&gt;</span>          <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>      <span style='color: #555555; font-style: italic;'>&lt;list&gt;</span>            <span style='color: #555555; font-style: italic;'>&lt;list&gt;</span>          </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span> <span style='color: #555555;'>&lt;split [32/11]&gt;</span> Bootstrap1 <span style='color: #555555;'>&lt;tibble [18 × 5]&gt;</span> <span style='color: #555555;'>&lt;tibble [0 × 3]&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span> <span style='color: #555555;'>&lt;split [32/10]&gt;</span> Bootstrap2 <span style='color: #555555;'>&lt;tibble [18 × 5]&gt;</span> <span style='color: #555555;'>&lt;tibble [0 × 3]&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>3</span> <span style='color: #555555;'>&lt;split [32/11]&gt;</span> Bootstrap3 <span style='color: #555555;'>&lt;tibble [18 × 5]&gt;</span> <span style='color: #555555;'>&lt;tibble [0 × 3]&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>4</span> <span style='color: #555555;'>&lt;split [32/13]&gt;</span> Bootstrap4 <span style='color: #555555;'>&lt;tibble [18 × 5]&gt;</span> <span style='color: #555555;'>&lt;tibble [0 × 3]&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>5</span> <span style='color: #555555;'>&lt;split [32/9]&gt;</span>  Bootstrap5 <span style='color: #555555;'>&lt;tibble [18 × 5]&gt;</span> <span style='color: #555555;'>&lt;tibble [0 × 3]&gt;</span></span></span>
<span></span><span></span>
<span><span class='c'># examine proposed hyperparameters and associated metrics</span></span>
<span><span class='nf'><a href='https://tune.tidymodels.org/reference/collect_predictions.html'>collect_metrics</a></span><span class='o'>(</span><span class='nv'>tuning_res</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 18 × 7</span></span></span>
<span><span class='c'>#&gt;    neighbors .metric .estimator  mean     n std_err .config             </span></span>
<span><span class='c'>#&gt;        <span style='color: #555555; font-style: italic;'>&lt;int&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>   <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>      <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;int&gt;</span>   <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>               </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 1</span>         2 rmse    standard   3.54      5  0.374  Preprocessor1_Model1</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 2</span>         2 rsq     standard   0.761     5  0.056<span style='text-decoration: underline;'>1</span> Preprocessor1_Model1</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 3</span>         3 rmse    standard   3.46      5  0.299  Preprocessor1_Model2</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 4</span>         3 rsq     standard   0.767     5  0.061<span style='text-decoration: underline;'>1</span> Preprocessor1_Model2</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 5</span>         5 rmse    standard   3.39      5  0.285  Preprocessor1_Model3</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 6</span>         5 rsq     standard   0.776     5  0.069<span style='text-decoration: underline;'>6</span> Preprocessor1_Model3</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 7</span>         6 rmse    standard   3.34      5  0.293  Preprocessor1_Model4</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 8</span>         6 rsq     standard   0.783     5  0.069<span style='text-decoration: underline;'>3</span> Preprocessor1_Model4</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 9</span>         8 rmse    standard   3.25      5  0.298  Preprocessor1_Model5</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>10</span>         8 rsq     standard   0.797     5  0.059<span style='text-decoration: underline;'>3</span> Preprocessor1_Model5</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>11</span>         9 rmse    standard   3.22      5  0.297  Preprocessor1_Model6</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>12</span>         9 rsq     standard   0.803     5  0.054<span style='text-decoration: underline;'>0</span> Preprocessor1_Model6</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>13</span>        10 rmse    standard   3.20      5  0.296  Preprocessor1_Model7</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>14</span>        10 rsq     standard   0.808     5  0.049<span style='text-decoration: underline;'>5</span> Preprocessor1_Model7</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>15</span>        12 rmse    standard   3.21      5  0.298  Preprocessor1_Model8</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>16</span>        12 rsq     standard   0.814     5  0.044<span style='text-decoration: underline;'>0</span> Preprocessor1_Model8</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>17</span>        14 rmse    standard   3.26      5  0.300  Preprocessor1_Model9</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>18</span>        14 rsq     standard   0.814     5  0.041<span style='text-decoration: underline;'>7</span> Preprocessor1_Model9</span></span>
<span></span></code></pre>

</div>

Given these tuning results, the next steps are to choose the "best" hyperparameters, assign those hyperparameters to the model, and fit the finalized model on the training set. Previously in , this has felt like:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='c'># choose a method to define "best" and extract the resulting parameters</span></span>
<span><span class='nv'>best_param</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://tune.tidymodels.org/reference/show_best.html'>select_best</a></span><span class='o'>(</span><span class='nv'>tuning_res</span>, <span class='s'>"rmse"</span><span class='o'>)</span> </span>
<span></span>
<span><span class='c'># assign those parameters to model</span></span>
<span><span class='nv'>knn_model_final</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://tune.tidymodels.org/reference/finalize_model.html'>finalize_model</a></span><span class='o'>(</span><span class='nv'>knn_model_spec</span>, <span class='nv'>best_param</span><span class='o'>)</span></span>
<span></span>
<span><span class='c'># fit the finalized model to the training set</span></span>
<span><span class='nv'>knn_fit</span> <span class='o'>&lt;-</span> <span class='nf'>fit</span><span class='o'>(</span><span class='nv'>knn_model_final</span>, <span class='nv'>mpg</span> <span class='o'>~</span> <span class='nv'>.</span>, <span class='nv'>mtcars</span><span class='o'>)</span></span></code></pre>

</div>

Voilà! `knn_fit` is a properly resampled model that is ready to [`predict()`](https://rdrr.io/r/stats/predict.html) on new data:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://rdrr.io/r/stats/predict.html'>predict</a></span><span class='o'>(</span><span class='nv'>knn_fit</span>, <span class='nv'>mtcars</span><span class='o'>[</span><span class='m'>1</span>, <span class='o'>]</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 1 × 1</span></span></span>
<span><span class='c'>#&gt;   .pred</span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span>  21.8</span></span>
<span></span></code></pre>

</div>

The newest release of tune introduced a shorthand interface for going from tuning results to final fit called [`fit_best()`](https://tune.tidymodels.org/reference/fit_best.html). The function wraps each of those three functions with sensible defaults to abbreviate the process described above.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>knn_fit_2</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://tune.tidymodels.org/reference/fit_best.html'>fit_best</a></span><span class='o'>(</span><span class='nv'>tuning_res</span><span class='o'>)</span></span>
<span></span>
<span><span class='nf'><a href='https://rdrr.io/r/stats/predict.html'>predict</a></span><span class='o'>(</span><span class='nv'>knn_fit_2</span>, <span class='nv'>mtcars</span><span class='o'>[</span><span class='m'>1</span>, <span class='o'>]</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 1 × 1</span></span></span>
<span><span class='c'>#&gt;   .pred</span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span>  21.8</span></span>
<span></span></code></pre>

</div>

This function is closely related to the [`last_fit()`](https://tune.tidymodels.org/reference/last_fit.html) function. They both give you access to a workflow fitted on the training data but are situated somewhat differently in the modeling workflow. [`fit_best()`](https://tune.tidymodels.org/reference/fit_best.html) picks up after a tuning function like [`tune_grid()`](https://tune.tidymodels.org/reference/tune_grid.html) to take you from tuning results to fitted workflow, ready for you to predict and assess further. [`last_fit()`](https://tune.tidymodels.org/reference/last_fit.html) assumes you have made your choice of hyperparameters and finalized your workflow to then take you from finalized workflow to fitted workflow and further to performance assessment on the test data. While [`fit_best()`](https://tune.tidymodels.org/reference/fit_best.html) gives a fitted workflow, [`last_fit()`](https://tune.tidymodels.org/reference/last_fit.html) gives you the performance results. If you want the fitted workflow, you can extract it from the result of [`last_fit()`](https://tune.tidymodels.org/reference/last_fit.html) via [`extract_workflow()`](https://hardhat.tidymodels.org/reference/hardhat-extract.html).

The newest release of the workflowsets package also includes a [`fit_best()`](https://tune.tidymodels.org/reference/fit_best.html) method for workflow set objects. Given a set of $n$ tuning results, that method will sift through all of the possible models to find and fit the optimal model configuration.

## Interactive issue logging

Imagine, in the previous example, we made some subtle error in specifying the tuning process. For example, passing a function to `extract` elements of the proposed workflows that injects some warnings and errors into the tuning process:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>raise_concerns</span> <span class='o'>&lt;-</span> <span class='kr'>function</span><span class='o'>(</span><span class='nv'>x</span><span class='o'>)</span> <span class='o'>&#123;</span></span>
<span>  <span class='kr'><a href='https://rdrr.io/r/base/warning.html'>warning</a></span><span class='o'>(</span><span class='s'>"Ummm, wait. :o"</span><span class='o'>)</span></span>
<span>  <span class='kr'><a href='https://rdrr.io/r/base/stop.html'>stop</a></span><span class='o'>(</span><span class='s'>"Eep! Nooo!"</span><span class='o'>)</span></span>
<span><span class='o'>&#125;</span></span>
<span></span>
<span><span class='nv'>tuning_res</span> <span class='o'>&lt;-</span></span>
<span>  <span class='nf'><a href='https://tune.tidymodels.org/reference/tune_grid.html'>tune_grid</a></span><span class='o'>(</span></span>
<span>    <span class='nv'>knn_model_spec</span>,</span>
<span>    <span class='nv'>mpg</span> <span class='o'>~</span> <span class='nv'>.</span>,</span>
<span>    <span class='nf'>bootstraps</span><span class='o'>(</span><span class='nv'>mtcars</span>, <span class='m'>5</span><span class='o'>)</span>,</span>
<span>    control <span class='o'>=</span> <span class='nf'><a href='https://tune.tidymodels.org/reference/control_grid.html'>control_grid</a></span><span class='o'>(</span>extract <span class='o'>=</span> <span class='nv'>raise_concerns</span><span class='o'>)</span></span>
<span>  <span class='o'>)</span></span></code></pre>

</div>

Warnings and errors can come up in all sorts of places while tuning hyperparameters. Often, with obvious issues, we can raise errors early on and halt the tuning process, but with more subtle concerns, we don't want to be too restrictive; it's sometimes better to defer to the underlying modeling packages to decide what's a dire issue versus something that can be worked around.

In the past, we've raised warnings and issues as they occur, printing context on the issue to the console before logging the issue in the tuning result. In the above example, this would look like:

    ! Bootstrap1: preprocessor 1/1, model 1/1 (extracts): Ummm, wait. :o
    x Bootstrap1: preprocessor 1/1, model 1/1 (extracts): Error in extractor(object): Eep! Nooo!
    ! Bootstrap2: preprocessor 1/1, model 1/1 (extracts): Ummm, wait. :o
    x Bootstrap2: preprocessor 1/1, model 1/1 (extracts): Error in extractor(object): Eep! Nooo!
    ! Bootstrap3: preprocessor 1/1, model 1/1 (extracts): Ummm, wait. :o
    x Bootstrap3: preprocessor 1/1, model 1/1 (extracts): Error in extractor(object): Eep! Nooo!
    ! Bootstrap4: preprocessor 1/1, model 1/1 (extracts): Ummm, wait. :o
    x Bootstrap4: preprocessor 1/1, model 1/1 (extracts): Error in extractor(object): Eep! Nooo!
    ! Bootstrap5: preprocessor 1/1, model 1/1 (extracts): Ummm, wait. :o
    x Bootstrap5: preprocessor 1/1, model 1/1 (extracts): Error in extractor(object): Eep! Nooo!

The above messages are super descriptive about where issues occur---they note in which resample, from which proposed modeling workflow, and in which part of the fitting process the issues occurred in. At the same time, they are quite repetitive; if there's an issue during hyperparameter tuning, it probably occurs in every resample, always in the same place. If, instead, we were evaluating this model against 1,000 resamples, or there were more than just two issues, this output could get very overwhelming very quickly.

The new releases of our tuning packages include tools to determine which tuning issues are unique, and for each unique issue, only print out the message once while maintaining a dynamic count of how many times the issue occurred. With the new tune release, the same output would look like:

<div class="highlight">

<pre class='chroma'><span><span class='c'>#&gt; → <span style='color: #BBBB00; font-weight: bold;'>A</span> | <span style='color: #BBBB00;'>warning</span>: Ummm, wait. :o</span></span>
<span></span><span><span class='c'>#&gt; → <span style='color: #BB0000; font-weight: bold;'>B</span> | <span style='color: #BB0000;'>error</span>:   Eep! Nooo!</span></span>
<span><span class='c'>#&gt; There were issues with some computations   <span style='color: #BBBB00; font-weight: bold;'>A</span>: x5   <span style='color: #BB0000; font-weight: bold;'>B</span>: x5</span></span>
<span></span></code></pre>

</div>

This interface is hopefully less overwhelming for users. When the messages attached to these issues aren't enough to debug the issue, the complete set of information about the issues lives inside of the tuning result object, and can be retrieved with `collect_notes(tuning_res)`. To turn off the interactive logging, set the `verbose` control option to `TRUE`.

## Speedups

Each of these three releases, as well as releases of core tidymodels packages they depend on like parsnip, recipes, and hardhat, include a plethora of changes meant to optimize computational performance. Especially for modeling practitioners who work with many resamples and/or small data sets, our modeling workflows will feel a whole lot snappier:

![A ggplot2 line graph plotting relative change in time to evaluate model fits with the tidymodels packages. Fits on datasets with 100 training rows are 2 to 3 times faster, while fits on datasets with 100,000 or more rows take about the same amount of time as they used to.](https://simonpcouch.com/blog/speedups-2023/index_files/figure-html/unnamed-chunk-10-1.png)

With 100-row training data sets, the time to resample models with tune and friends has been at least halved. These releases are the first iteration of a set of changes to reduce the evaluation time of tidymodels code, and users can expect further optimizations in coming releases! See [this post on my blog](https://www.simonpcouch.com/blog/speedups-2023/) for more information about those speedups.

## Bonus points

Although they're smaller in scope, we wanted to highlight two additional developments in tuning hyperparameters with tidymodels.

### Workflow set support for tidyclust

The recent tidymodels package [tidyclust](github.com/tidymodels/tidyclust) introduced support for fitting and tuning clustering models in tidymodels. That package's function [`tune_cluster()`](https://tidyclust.tidymodels.org/reference/tune_cluster.html) is now an option for tuning in [`workflow_map()`](https://workflowsets.tidymodels.org/reference/workflow_map.html), meaning that users can fit sets of clustering models and preprocessors using workflow sets. These changes further integrate the tidyclust package into tidymodels framework.

### Refined retrieval of intermediate results

The `.Last.tune.result` helper stores the most recent tuning result in the object `.Last.tune.result` as a fail-safe in cases of interrupted tuning, uncaught tuning errors, and simply forgetting to assign tuning results to an object.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='c'># be a silly goose and forget to assign results</span></span>
<span><span class='nf'><a href='https://tune.tidymodels.org/reference/tune_grid.html'>tune_grid</a></span><span class='o'>(</span></span>
<span>  <span class='nv'>knn_model_spec</span>,</span>
<span>  <span class='nv'>mpg</span> <span class='o'>~</span> <span class='nv'>.</span>,</span>
<span>  <span class='nf'>bootstraps</span><span class='o'>(</span><span class='nv'>mtcars</span>, <span class='m'>5</span><span class='o'>)</span>,</span>
<span>  control <span class='o'>=</span> <span class='nf'><a href='https://tune.tidymodels.org/reference/control_grid.html'>control_grid</a></span><span class='o'>(</span>save_workflow <span class='o'>=</span> <span class='kc'>TRUE</span><span class='o'>)</span></span>
<span><span class='o'>)</span></span>
<span><span class='c'>#&gt; # Tuning results</span></span>
<span><span class='c'>#&gt; # Bootstrap sampling </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 5 × 4</span></span></span>
<span><span class='c'>#&gt;   splits          id         .metrics          .notes          </span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;list&gt;</span>          <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>      <span style='color: #555555; font-style: italic;'>&lt;list&gt;</span>            <span style='color: #555555; font-style: italic;'>&lt;list&gt;</span>          </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span> <span style='color: #555555;'>&lt;split [32/13]&gt;</span> Bootstrap1 <span style='color: #555555;'>&lt;tibble [16 × 5]&gt;</span> <span style='color: #555555;'>&lt;tibble [0 × 3]&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span> <span style='color: #555555;'>&lt;split [32/13]&gt;</span> Bootstrap2 <span style='color: #555555;'>&lt;tibble [16 × 5]&gt;</span> <span style='color: #555555;'>&lt;tibble [0 × 3]&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>3</span> <span style='color: #555555;'>&lt;split [32/10]&gt;</span> Bootstrap3 <span style='color: #555555;'>&lt;tibble [16 × 5]&gt;</span> <span style='color: #555555;'>&lt;tibble [0 × 3]&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>4</span> <span style='color: #555555;'>&lt;split [32/8]&gt;</span>  Bootstrap4 <span style='color: #555555;'>&lt;tibble [16 × 5]&gt;</span> <span style='color: #555555;'>&lt;tibble [0 × 3]&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>5</span> <span style='color: #555555;'>&lt;split [32/10]&gt;</span> Bootstrap5 <span style='color: #555555;'>&lt;tibble [16 × 5]&gt;</span> <span style='color: #555555;'>&lt;tibble [0 × 3]&gt;</span></span></span>
<span></span><span></span>
<span><span class='c'># all is not lost!</span></span>
<span><span class='nv'>.Last.tune.result</span></span>
<span><span class='c'>#&gt; # Tuning results</span></span>
<span><span class='c'>#&gt; # Bootstrap sampling </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 5 × 4</span></span></span>
<span><span class='c'>#&gt;   splits          id         .metrics          .notes          </span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;list&gt;</span>          <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>      <span style='color: #555555; font-style: italic;'>&lt;list&gt;</span>            <span style='color: #555555; font-style: italic;'>&lt;list&gt;</span>          </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span> <span style='color: #555555;'>&lt;split [32/13]&gt;</span> Bootstrap1 <span style='color: #555555;'>&lt;tibble [16 × 5]&gt;</span> <span style='color: #555555;'>&lt;tibble [0 × 3]&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span> <span style='color: #555555;'>&lt;split [32/13]&gt;</span> Bootstrap2 <span style='color: #555555;'>&lt;tibble [16 × 5]&gt;</span> <span style='color: #555555;'>&lt;tibble [0 × 3]&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>3</span> <span style='color: #555555;'>&lt;split [32/10]&gt;</span> Bootstrap3 <span style='color: #555555;'>&lt;tibble [16 × 5]&gt;</span> <span style='color: #555555;'>&lt;tibble [0 × 3]&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>4</span> <span style='color: #555555;'>&lt;split [32/8]&gt;</span>  Bootstrap4 <span style='color: #555555;'>&lt;tibble [16 × 5]&gt;</span> <span style='color: #555555;'>&lt;tibble [0 × 3]&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>5</span> <span style='color: #555555;'>&lt;split [32/10]&gt;</span> Bootstrap5 <span style='color: #555555;'>&lt;tibble [16 × 5]&gt;</span> <span style='color: #555555;'>&lt;tibble [0 × 3]&gt;</span></span></span>
<span></span><span></span>
<span><span class='c'># assign to object after the fact</span></span>
<span><span class='nv'>res</span> <span class='o'>&lt;-</span> <span class='nv'>.Last.tune.result</span></span></code></pre>

</div>

These three releases introduce support for the `.Last.tune.result` object in more settings and refine support in existing implementations.

## Acknowledgements

Thanks to [@walrossker](https://github.com/walrossker), [@Freestyleyang](https://github.com/Freestyleyang), and [@Jeffrothschild](https://github.com/Jeffrothschild) for their contributions to these packages since their last releases.

Happy modeling, y'all!

