---
title: tidymodels updates
slug: tidymodels-2019-07
author: Max Kuhn
description: The latest updates to the tidymodels packages
date: '2019-07-17'
categories: [package]
tags:
  - tidymodels
photo:
  url: https://unsplash.com/photos/rqIfy1UyIzE
  author: Branden Harvey
---

We've sent a few packages to CRAN recently. Here's a recap of the changes: 

## recipes 0.1.6

### Breaking Changes

 * Since 2018, a warning has been issued when the wrong argument was used in `bake(recipe, newdata)`. The depredation period is over and `new_data` is officially required.  
 * Previously, if [`step_other()`](https://tidymodels.github.io/recipes/reference/step_other.html) did _not_ collapse any levels, it would still add an "other" level to the factor. This would lump new factor levels into "other" when data were baked (as  [`step_novel()`](https://tidymodels.github.io/recipes/reference/step_novel.html) does). This no longer occurs since it was inconsistent with `?step_other`, which said that 
 > "If no pooling is done the data are unmodified".
 
### New Operations:

*  [`step_normalize()`](https://tidymodels.github.io/recipes/reference/step_normalize.html) centers and scales the data (if you are, like Max, too lazy to use two separate steps). 
*  [`step_unknown()`](https://tidymodels.github.io/recipes/reference/step_unknown.html) will convert missing data in categorical columns to "unknown" and update factor levels. 
 
### Other Changes:

* If `threshold` argument of [`step_other()`](https://tidymodels.github.io/recipes/reference/step_other.html) is greater than one then it specifies the minimum sample size before the levels of the factor are collapsed into the "other" category. [#289](https://github.com/tidymodels/recipes/issues/289)
 *  [`step_knnimpute()`](https://tidymodels.github.io/recipes/reference/step_knnimpute.html) can now pass two options to the underlying knn code, including the number of threads ([#323](https://github.com/tidymodels/recipes/issues/323)). 
* Due to changes by CRAN,  [`step_nnmf()`](https://tidymodels.github.io/recipes/reference/step_nnmf.html) only works on versions of R >= 3.6.0 due to dependency issues. 
*  [`step_dummy()`](https://tidymodels.github.io/recipes/reference/step_dummy.html) and [`step_other()`](https://tidymodels.github.io/recipes/reference/step_other.html) are now tolerant to cases where that step's selectors do not capture any columns. In this case, no modifications to the data are made. ([#290](https://github.com/tidymodels/recipes/issues/290), [#348](https://github.com/tidymodels/recipes/issues/348))
*  [`step_dummy()`](https://tidymodels.github.io/recipes/reference/step_dummy.html) can now retain the original columns that are used to make the dummy variables. ([#328](https://github.com/tidymodels/recipes/issues/328)) 
*  [`step_other()`](https://tidymodels.github.io/recipes/reference/step_other.html)'s print method only reports the variables with collapsed levels (as opposed to any column that was _tested_ to see if it needed collapsing). ([#338](https://github.com/tidymodels/recipes/issues/338)) 
 *  [`step_pca()`](https://tidymodels.github.io/recipes/reference/step_pca.html),  [`step_kpca()`](https://tidymodels.github.io/recipes/reference/step_kpca.html),  [`step_ica()`](https://tidymodels.github.io/recipes/reference/step_ica.html),  [`step_nnmf()`](https://tidymodels.github.io/recipes/reference/step_nnmf.html),  [`step_pls()`](https://tidymodels.github.io/recipes/reference/step_pls.html), and  [`step_isomap()`](https://tidymodels.github.io/recipes/reference/step_isomap.html) now accept zero components. In this case, the original data are returned. 
 
## embed 0.0.3

Two new steps were added:

 * [`step_umap()`](https://tidymodels.github.io/embed/reference/step_umap.html) was added for both supervised and unsupervised encodings. 
 * [`step_woe()`](https://tidymodels.github.io/embed/reference/step_woe.html) created weight of evidence encodings. Thanks to Athos Petri Damiani for this. 

## rsample 0.0.5

* Added three functions to compute different [bootstrap confidence intervals](https://tidymodels.github.io/rsample/articles/Applications/Intervals.html). 
* A new function ([`add_resample_id()`](https://tidymodels.github.io/rsample/reference/add_resample_id.html)) augments a data frame with columns for the resampling identifier. 
* Updated [`initial_split()`](https://tidymodels.github.io/rsample/reference/initial_split.html), [`mc_cv()`](https://tidymodels.github.io/rsample/reference/mc_cv.html), [`vfold_cv()`](https://tidymodels.github.io/rsample/reference/vfold_cv.html), [`bootstraps()`](https://tidymodels.github.io/rsample/reference/bootstraps.html), and [`group_vfold_cv()`](https://tidymodels.github.io/rsample/reference/group_vfold_cv.html) to use tidyselect on the stratification variable.
* Updated [`initial_split()`](https://tidymodels.github.io/rsample/reference/initial_split.html), [`mc_cv()`](https://tidymodels.github.io/rsample/reference/mc_cv.html), [`vfold_cv()`](https://tidymodels.github.io/rsample/reference/vfold_cv.html), and  [`bootstraps()`](https://tidymodels.github.io/rsample/reference/bootstraps.html) with new `breaks` parameter that specifies the number of bins to stratify by for a numeric stratification variable.

## corrr 0.4

### New features

* New function called [`dice()`](https://tidymodels.github.io/corrr/reference/dice.html) function, wraps `focus(x,..., mirror = TRUE)`
* A new [`retract()`](https://tidymodels.github.io/corrr/reference/retract.html) function does the opposite of `stretch()` 
* A new argument was added to [`stretch()`](https://tidymodels.github.io/corrr/reference/stretch.html) called `remove.dups`. It removes duplicates with out removing all NAs. 

### Improvements

* `correlate()`'s interface for databases was improved. It now only calculates unique pairs, and simplifies the formula that ultimately runs in-database. We also re-added the vignette to the package, which is also available in site as an [article](https://tidymodels.github.io/corrr/articles/databases.html)

## tidypredict 0.4.2

### New models

The new version is now able to parse the following models:

  * `cubist()`, from the `Cubist` package
  * `ctree()`, from the `partykit` package
  * XGBoost trained models, via the `xgboost` package

### New features

* Integration with `broom`'s `tidy()` function. It works with Regression models only
* Adds support for `parsnip` fitted models: `lm`, `randomForest`, `ranger`, and `earth`
* Adds [`as_parsed_model()`](https://tidymodels.github.io/tidypredict/reference/as_parsed_model.html) function. It adds the proper class components to the list. This allows any model exported in the correct spec to be read in by `tidypredict`. See the [Save Models](https://tidymodels.github.io/tidypredict/articles/save.html) and [Non-R models](https://tidymodels.github.io/tidypredict/articles/non-r.html) for more information

### Improvements

* Now supports classification models from `ranger`

### Website

The package's [official website](https://tidymodels.github.io/tidypredict/index.html) has been expanded greatly. Here are some highlights:

  * An article per each supported model, they are found under Model List
  * A how to guide to save and reload models, [link here](https://tidymodels.github.io/tidypredict/articles/save.html) 
  * How to integrate non-R models to `tidypredict`, [link here](https://tidymodels.github.io/tidypredict/articles/non-r.html) 
