---
output: hugodown::hugo_document

slug: usemodels-0-2-0
title: usemodels 0-2-0
date: 2022-02-19
author: Max Kuhn
description: >
    A new release of the use models makes it even easier to use tidymodels.

photo:
  url: https://unsplash.com/photos/r1sTNKz0omE
  author: Eugenia Kozyr

# one of: "deep-dive", "learn", "package", "programming", "roundup", or "other"
categories: [package] 
tags: [tidymodels]
---

<!--
TODO:
* [ ] Look over / edit the post's title in the yaml
* [ ] Edit (or delete) the description; note this appears in the Twitter card
* [ ] Pick category and tags (see existing with `hugodown::tidy_show_meta()`)
* [ ] Find photo & update yaml metadata
* [ ] Create `thumbnail-sq.jpg`; height and width should be equal
* [ ] Create `thumbnail-wd.jpg`; width should be >5x height
* [ ] `hugodown::use_tidy_thumbnails()`
* [ ] Add intro sentence, e.g. the standard tagline for the package
* [ ] `usethis::use_tidy_thanks()`
-->

We're chuffed to announce the release of the  [usemodels](https://usemodels.tidymodels.org/) package. usemodels enables users to generate tidymodels templates for fitting and tuning models. 

You can install it from CRAN with:


```r
install.packages("usemodels")
```

This blog post will describe the new features.

You can see a full list of changes in the [release notes](https://usemodels.tidymodels.org/news/index.html)


```r
library(usemodels)
```

## Clipboard access

Each of the `use_*()` functions has a `clipboard` feature that will send to new code to the clipboard instead of writing to the console window. 


```r
use_cubist(mpg ~ ., data = mtcars, clipboard = TRUE)
```

```
## ✓ code is on the clipboard.
```

## New Models

As requested in GitHub issues, [C5.0](https://www.rulequest.com/see5-unix.html) and [SVM](https://en.wikipedia.org/wiki/Support-vector_machine) model templates were added. For example, SVM models require centering and scaling of the predictors: 


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
## set.seed(98547)
## kernlab_tune <-
##   tune_grid(kernlab_workflow, resamples = stop("add your rsample object"), grid = stop("add number of candidate points"))
```

Let us know if there are other features that would be interesting for the package on its GitHub [issues page](https://github.com/tidymodels/usemodels/issues).

