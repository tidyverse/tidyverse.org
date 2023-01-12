---
output: hugodown::hugo_document

slug: usemodels-0-2-0
title: usemodels 0.2.0
date: 2022-03-23
author: Max Kuhn
description: >
    A new release of the usemodels package makes it even easier to use tidymodels.

photo:
  url: https://unsplash.com/photos/r1sTNKz0omE
  author: Eugenia Kozyr

# one of: "deep-dive", "learn", "package", "programming", "roundup", or "other"
categories: [package] 
tags: [tidymodels]
---

<!--
TODO:
* [x] Look over / edit the post's title in the yaml
* [x] Edit (or delete) the description; note this appears in the Twitter card
* [x] Pick category and tags (see existing with `hugodown::tidy_show_meta()`)
* [x] Find photo & update yaml metadata
* [x] Create `thumbnail-sq.jpg`; height and width should be equal
* [x] Create `thumbnail-wd.jpg`; width should be >5x height
* [x] `hugodown::use_tidy_thumbnails()`
* [x] Add intro sentence, e.g. the standard tagline for the package
* [x] `usethis::use_tidy_thanks()`
-->

We're chuffed to announce the release of [usemodels](https://usemodels.tidymodels.org/) 0.2.0. The usemodels package enables users to generate tidymodels code for fitting and tuning models. Given a) a formula and b) a data set, the `use_*()` functions (such as `use_glmnet()` and `use_xgboost()`) create code to fit that specific model to that data, including appropriate preprocessing. 

You can install it from CRAN with:


```r
install.packages("usemodels")
```

This blog post describes some new features. You can see a full list of changes in the [release notes](https://usemodels.tidymodels.org/news/index.html).


```r
library(usemodels)
```

## Clipboard access

Each of the `use_*()` functions now has a `clipboard` feature that will send the new code to the clipboard, instead of writing to the console window. 


```r
use_cubist(mpg ~ ., data = mtcars, clipboard = TRUE)
```

```
## ✓ code is on the clipboard.
```

## New models

As requested in GitHub issues, support for [C5.0](https://www.rulequest.com/see5-unix.html) and [SVM](https://en.wikipedia.org/wiki/Support-vector_machine) models was added. SVM models require centering and scaling of the predictors, so the usemodel function provides this automatically: 


```r
data(two_class_dat, package = "modeldata")
use_kernlab_svm_rbf(Class ~ ., data = two_class_dat)
```

```
## kernlab_recipe <- 
##   recipe(formula = Class ~ ., data = two_class_dat) %>% 
##   step_zv(all_predictors()) %>% 
##   step_normalize(all_numeric_predictors()) 
## 
## kernlab_spec <- 
##   svm_rbf(cost = tune(), rbf_sigma = tune()) %>% 
##   set_mode("classification") 
## 
## kernlab_workflow <- 
##   workflow() %>% 
##   add_recipe(kernlab_recipe) %>% 
##   add_model(kernlab_spec) 
## 
## set.seed(81161)
## kernlab_tune <-
##   tune_grid(kernlab_workflow, resamples = stop("add your rsample object"), grid = stop("add number of candidate points"))
```

Let us know if there are other features that would be interesting for the package on its GitHub [issues page](https://github.com/tidymodels/usemodels/issues).

## Acknowledgements

Thanks to all the people who contributed to usemodels since [our last blog post](https://www.tidyverse.org/blog/2020/09/usemodels-0-0-1/):  [&#x0040;amazongodman](https://github.com/amazongodman), [&#x0040;brshallo](https://github.com/brshallo), [&#x0040;bryceroney](https://github.com/bryceroney), [&#x0040;czeildi](https://github.com/czeildi), [&#x0040;EmilHvitfeldt](https://github.com/EmilHvitfeldt), [&#x0040;hfrick](https://github.com/hfrick), [&#x0040;jennybc](https://github.com/jennybc), [&#x0040;juliasilge](https://github.com/juliasilge), [&#x0040;larry77](https://github.com/larry77), and [&#x0040;topepo](https://github.com/topepo).
