---
output: hugodown::hugo_document

slug: tune-parallel
title: Parallel processing with tune 
date: 2020-11-27
author: Max Kuhn
description: >
    With version 0.1.2 of tune, there are more options for parallel processing.  

photo:
  url: https://unsplash.com/photos/mJ35U595uhA
  author: Joss Woodhead

# one of: "deep-dive", "learn", "package", "programming", or "other"
categories: [package] 
tags: [tidymodels,tune, parallelism]
---



<!--
TODO:
* [ ] Pick category and tags (see existing with `post_tags()`)
* [ ] Find photo & update yaml metadata
* [ ] Create `thumbnail-sq.jpg`; height and width should be equal
* [ ] Create `thumbnail-wd.jpg`; width should be >5x height
* [ ] `hugodown::use_tidy_thumbnail()`
* [ ] Add intro sentence
* [ ] `use_tidy_thanks()`
-->
This is the third post related to version 0.1.2 of the tune package. The [first post](https://www.tidyverse.org/blog/2020/11/tune-0-1-2/) discussed various new features while the [second post](https://www.tidyverse.org/blog/2020/11/tidymodels-sparse-support/) describes sparse matrix support. This post is an excerpt from an upcoming chapter in [_Tidy Modeling with R_](https://www.tmwr.org/) and is focused on parallel processing. 

Previously, the tune package allowed for parallel processing of calculations in a few different places: 

* Simple model resampling via `resample_fit()`

* Model tuning via `tune_grid()`

* During Bayesian optimization (`tune_bayes()`)

In the new version of tune, there are more options related to how parallelism occurs. It's a little complicated and we'll start by describing the most basic method. 

## Parallelizing the resampling loop

For illustration, let's suppose that we are tuning a set of model parameters (e.g. not recipe parameters). In tidymodels, we always use [out-of-sample predictions to measure performance](https://www.tmwr.org/resampling.html). With grid search, pseudo-code that illustrations the computations are: 


```r
for (resample in resamples) {
   # Create analysis and assessment sets
   # Preprocess data (e.g. formula or recipe)
   for (model in configurations) {
      # Fit {model} to the {resample} analysis set
      # Predict the {resample} assessment set
   }
}
```

Prior to the new version of tune, the only option was to run the outer resampling loop in parallel. The inner modeling loop is run sequentially. The rationale for this was this: if you are doing any significant preprocessing of the data (e.g., a complex recipe), you only have to do that as many times as you have resamples. Since the model tuning is conditional on the preprocessed data, this is pretty computationally efficient. 

There were two downsides to this approach: 

 * Suppose you have 10 resamples but access to 20 cores. The maximum core utilization would be 10 and using 10 cores might not maximize the computational efficiency.

 * Since tidymodels treats validation sets as a single resample, you can't parallel process at all. 

Parallel processing is somewhat unpredictable. While you might have a lot of cores (or machines) to throw at the problem, adding more might not help. This really depends on the model, the size of the data, and the parallel strategy used (i.e. forking vs socket). 

To illustrate how this approach utilizes parallel workers, we'll use a case where there are 7 model tuning parameter values along with 5-fold cross-validation. This visualization shows how the tasks are allocated to the worker processes:

<img src="figure/grid-logging-rs-1.svg" title="plot of chunk grid-logging-rs" alt="plot of chunk grid-logging-rs" width="70%" />

The code assigns each of the five resamples to their own worker process which, in this case, is a core on a single desktop machine. That worker conducts the preprocessing then loops over the models. The preprocessing happens once per resample. 

In the new version of tune, there is a control option called `parallel_over`. Setting this to a value of `"resamples"` will select this scheme to parallelize the computations. 


## Parallelizing everything

Another option that we can pursue is to take the two loops shown above and merge them into a single loop. 


```r
all_tasks <- crossing(resamples, configurations)

for (iter in all_tasks) {                           
   # Create analysis and assessment sets for {iter}
   # Preprocess data (e.g. formula or recipe)
   # Fit model {iter} to the {iter} analysis set
   # Predict the {iter} assessment set
}
```

With seven models and five resamples there are a total of 35 separate tasks that can be given to the worker processes. For this example, that would allow up to 35 cores/machines to run simultaneously. If we use a validation set, this would also enable the model loop to run in parallel. 

The downside to this approach is that the preprocessing is unnecessarily repeated multiple times (depending on how tasks are allocated to the worker processes). 

Taking our previous example, here is what the allocations look like if the 35 tasks are run across 10 cores: 

![plot of chunk grid-logging-all](figure/grid-logging-all-1.svg)

For each resample, the preprocessing is needlessly run six additional times. If the preprocessing is fast, this might be the best approach. 

To enable this approach, the control option is set to `parallel_over = "everything"`. 

## Automatic strategy detection

The default for `parallel_over` is `NULL`. This allows us to check and see if there are multiple resamples. If that is the case, it uses a value of `"resamples"`; otherwise, `"everything"` is used. 

## How much faster are the computations? 

As an example, we tuned a boosted tree with the `xgboost` engine on a data set of 4,000 samples. Five-fold cross-validation was used with 10 candidate models. These data required some baseline preprocessing that did not require any estimation. The preprocessing was handled three different ways:

1. Preprocess the data prior to modeling using a `dplyr` pipeline (labeled as "none" in the plots below).
2. Conduct the same preprocessing using a recipe (shown as "light" preprocessing).
3. With a recipe, add an additional step that has a high computational cost (labeled as "expensive"). 

The first and second preprocessing options are designed to measure the computational cost of the recipe. The third option measures the cost of performing redundant computations with `parallel_over = "everything"`. 

We evaluated this process using variable number of worker processes and using the two `parallel_over` options. The computer has 10 physical cores and 20 virtual cores (via hyper threading). 

Let's consider the raw execution times:

![plot of chunk grid-par-times](figure/grid-par-times-1.svg)

Since there were only five resamples, the number of cores used when `parallel_over = "resamples"` is limited to five. 

Comparing the curves in the first two panels for "none" and "light": 

* There is little difference in the execution times between the panels. This indicates, for these data, there is no real computational penalty for doing the preprocessing steps in a recipe. 

* There is some benefit for using `parallel_over = "everything"` with many cores. However, as shown below, the majority of the benefit of parallel processing occurs in the first five workers.

With the expensive preprocessing step, there is a considerable difference in execution times. Using `parallel_over = "everything"` is problematic since, even using all cores, it never achieves the execution time that `parallel_over = "resamples"` attains with five cores. This is because the costly preprocessing step is unnecessarily repeated in the computational scheme. 

## PSOCK clusters

The primary method for parallel processing on Windows computers uses a PSOCK cluster. From [_Parallel R_](https://www.oreilly.com/library/view/parallel-r/9781449317850/): 

> "The parallel package comes with two transports: 'PSOCK' and 'FORK'. The 'PSOCK' transport is a streamlined version of [snow](https://biostats.bepress.com/uwbiostat/paper193/)'s 'SOCK' transport. It starts workers using the Rscript command, and communicates between the master and workers using socket connections."

This method works on all major operating systems. 

Different parallel processing technologies work in different ways. About mid-year we started to receive a number of issue reports where PSOCK clusters were failing on Windows. This was due to how parallel workers are initialized; they really don't know anything about the main R process (e.g., what packages are loaded, what data objects should have access, etc). Those problems are now solved with the most recent versions of the parsnip, recipes, and tune packages. 
