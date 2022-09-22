---
output: hugodown::hugo_document

slug: brulee-0-2-0
title: brulee 0.2.0
date: 2022-09-26
author: Max Kuhn
description: >
    Version 0.2.0 of brulee introduces learning rate schedulers. 

photo:
  url: https://unsplash.com/photos/wiTWDYLURr8
  author: Alex Munsell

# one of: "deep-dive", "learn", "package", "programming", "roundup", or "other"
categories: [package] 
tags: [tidymodels, brulee]
---

We're thrilled to announce the release of [brulee](https://tidymodels.github.io/brulee/) 0.2.0. brulee contains several basic modeling functions that use the torch package infrastructure, such as: neural networks, linear regression, logistic regression, and multinomial regression. 

You can install it from CRAN with:


```r
install.packages("brulee")
```

This blog post will describe the changes to the package. You can see a full list of changes in the [release notes](https://tidymodels.github.io/brulee/news/index.html)

There were two main additions to brulee. 

First, since brulee is focused on fitting models to _tabular data_, we've been be moving away from optimizing via stochastic gradient descent (SGD) as the default. For `brulee_mlp()`, we switched the default optimizer from SGD to more traditional quasi-newton methods, specifically to Broyden–Fletcher–Goldfarb–Shanno algorithm (BFGS) method. You can still use SGD via the `optimizer` option. 

Second, we've added [learning rate schedulers](https://www.google.com/search?rls=en&q=%22learning+rate+schedule%22) to `brulee_mlp()`. The learning rate is one of the most important parameters to tune and there is an existing option to have a constant learning rate (via the `learn_rate` argument). However, there is some intuition that the rate should probably decrease once the optimizer is closer to the best solution (to avoid overshooting the target). A scheduler is just a function that adjusts the rate over time. Apart from a constant learning rate (the default), the options are: cyclic, exponential decay, time-based decay, and step functions: 

<img src="rates.png" title="plot of chunk unnamed-chunk-2" alt="plot of chunk unnamed-chunk-2" style="display: block; margin: auto;" />

The corresponding [set of functions](https://tidymodels.github.io/brulee/reference/schedule_decay_time.html) share the prefix `schedule_*()`. 

To use these with `brulee_mlp()`, there is a  `rate_schedule` argument with possible values: `"none"` (the default), `"decay_time"`, `"decay_expo"`, `"cyclic"` and `"step"`. Each function has arguments and these can be passed directly to `brulee_mlp()`. The `rate_schedule` argument can also be tuned as any other engine-specific parameter.


## Acknowledgements

We'd like to thank [&#x0040;EmilHvitfeldt](https://github.com/EmilHvitfeldt), [&#x0040;sametsoekel](https://github.com/sametsoekel), and  [&#x0040;dfalbel](https://github.com/dfalbel) for their help since the previous release. 
