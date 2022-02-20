---
output: hugodown::hugo_document

slug: recipes-0-2-0
title: recipes 0.2.0
date: 2022-02-25
author: Max Kuhn
description: >
    Recipes has added a few new steps along with many improvements.

photo:
  url: https://unsplash.com/photos/xZa4JUE7EdM
  author: Jonny Clow

# one of: "deep-dive", "learn", "package", "programming", "roundup", or "other"
categories: [package] 
tags: [recipes tidymodels]
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

We're very excited to announce the release of [recipes](https://recipes.tidymodels.org/) 0.2.0. recipes is a package for preprocessing data before using it in models or visualizations. You can think of it as a machup of `model.matrix()` and dplyr. 

You can install it from CRAN with:


```r
install.packages("recipes")
```

This blog post will describe what's new. You can see a full list of changes in the [release notes](https://github.com/tidymodels/recipes/blob/main/NEWS.md)

## New Steps

`step_nnmf_sparse()` was added to produce features using non-negative matrix factorization (via the [RcppML](https://github.com/zdebruine/RcppML) package). This will supersede the existing `step_nnmf()` since the package requirements for that step were difficult to support and used. The new step allows for a sparse representation via regularization and, from our initial testing, to be **much faster** than the original NNMF step. 

A new function helps create indicator variables from text data, especially those with multiple choice values. `step_dummy_extract()`. For example, if a row of a variable had a value of `"red,black,brown"`, the step can separate these values and make all of the required binary dummy variables. 

Here's a real example from [Episode 8 of _Sliced_](https://www.kaggle.com/c/sliced-s01e08-KJSEks) where a column of data from Spotify had the artist(s) of a song: 


```r
library(recipes)
```

```
## Loading required package: dplyr
```

```
## 
## Attaching package: 'dplyr'
```

```
## The following objects are masked from 'package:stats':
## 
##     filter, lag
```

```
## The following objects are masked from 'package:base':
## 
##     intersect, setdiff, setequal, union
```

```
## 
## Attaching package: 'recipes'
```

```
## The following object is masked from 'package:stats':
## 
##     step
```

```r
spotify <- 
  tibble::tribble(
    ~ artists,
    "['Genesis']",
    "['Billie Holiday', 'Teddy Wilson']",
    "['Jimmy Barnes', 'INXS']"
  )
recipe(~ artists, data = spotify) %>% 
  step_dummy_extract(artists, pattern = "(?<=')[^',]+(?=')") %>% 
  prep() %>% 
  bake(new_data = NULL) %>% 
  names()
```

```
## [1] "artists_Billie.Holiday" "artists_Genesis"        "artists_INXS"          
## [4] "artists_Jimmy.Barnes"   "artists_Teddy.Wilson"   "artists_other"
```

Note that this step produces an "other" column and has arguments similar to `step_other()`. 

`step_percentile()`, previously seem in the developer documentation, can determine the empirical distribution of the variable using the training set, then convert any value to the percentile of this distribution. 

Finally, a new filtering function (`step_filter_missing()`) can filter out columns that have two many missing values (for some definition of "too many").

## Other notable new features

`step_zv()` now has a `group` argument. This can be helpful for models such as naive Bayes or quadratic discriminant analysis where the predictors must have at least two unique values _within each class_. 

All recipe steps now officially support empty selections to be more aligned with dplyr and other packages that use tidyselect. For example, if a previous step removed all of the columns needed for a later step, the recipe does not fail when it is estimated (with the exception of `step_mutate()`). The documentation in `?selections` has been updated with advice for writing selectors when filtering steps are used. 

There are new `extract_parameter_set_dials()` and `extract_parameter_dials()` methods to extract parameter sets and single parameters from a recipe. Since this is related to tuning parameters, the tune package should be loaded before they are used.  


## Acknowledgements

We'd like to thank everyone that has contributed since the last release: [&#x0040;arneschillert](https://github.com/arneschillert), [&#x0040;batpigandme](https://github.com/batpigandme), [&#x0040;DavisVaughan](https://github.com/DavisVaughan), [&#x0040;fenguoerbian](https://github.com/fenguoerbian), [&#x0040;gaborcsardi](https://github.com/gaborcsardi), [&#x0040;hadley](https://github.com/hadley), [&#x0040;hfrick](https://github.com/hfrick), [&#x0040;jimhester](https://github.com/jimhester), [&#x0040;juliasilge](https://github.com/juliasilge), [&#x0040;lionel-](https://github.com/lionel-), [&#x0040;maelle](https://github.com/maelle), [&#x0040;PursuitOfDataScience](https://github.com/PursuitOfDataScience), [&#x0040;sysilviakim](https://github.com/sysilviakim), and [&#x0040;topepo](https://github.com/topepo)


