---
output: hugodown::hugo_document

slug: recipes-0-2-0
title: recipes 0.2.0
date: 2022-02-22
author: Max Kuhn
description: >
    Recipes has added a few new steps along with many improvements.

photo:
  url: https://unsplash.com/photos/xZa4JUE7EdM
  author: Jonny Clow

# one of: "deep-dive", "learn", "package", "programming", "roundup", or "other"
categories: [package] 
tags: [recipes, tidymodels]
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

We're very excited to announce the release of [recipes](https://recipes.tidymodels.org/) 0.2.0. recipes is a package for preprocessing data before using it in models or visualizations. You can think of it as a mash-up of `model.matrix()` and dplyr. 

You can install it from CRAN with:


```r
install.packages("recipes")
```

This blog post will describe the highlights of what's new. You can see a full list of changes in the [release notes](https://github.com/tidymodels/recipes/blob/main/NEWS.md).

## New Steps

`step_nnmf_sparse()` was added to produce features using non-negative matrix factorization (via the [RcppML](https://github.com/zdebruine/RcppML) package). This will supersede the existing `step_nnmf()` since that step was difficult to support and use. The new step allows for a sparse representation via regularization and, from our initial testing, is **much faster** than the original NNMF step. 

The new step `step_dummy_extract()` helps create indicator variables from text data, especially those with multiple choice values. For example, if a row of a variable had a value of `"red,black,brown"`, the step can separate these values and make all of the required binary dummy variables. 

Here's a real example from [Episode 8 of _Sliced_](https://www.kaggle.com/c/sliced-s01e08-KJSEks) where a column of data from Spotify had the artist(s) of a song: 


```r
library(recipes)
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
  glimpse()
```

```
## Rows: 3
## Columns: 6
## $ artists_Billie.Holiday <dbl> 0, 1, 0
## $ artists_Genesis        <dbl> 1, 0, 0
## $ artists_INXS           <dbl> 0, 0, 1
## $ artists_Jimmy.Barnes   <dbl> 0, 0, 1
## $ artists_Teddy.Wilson   <dbl> 0, 1, 0
## $ artists_other          <dbl> 0, 0, 0
```

Note that this step produces an "other" column and has arguments similar to `step_other()` and `step_dummy_multi_choice()`. 

`step_percentile()` is a new step function after it had previously only been an example in the developer documentation. It can determine the empirical distribution of a variable using the training set, then convert any value to the percentile of this distribution. 

Finally, a new filtering function (`step_filter_missing()`) can filter out columns that have too many missing values (for some definition of "too many").

## Other notable new features

`step_zv()` now has a `group` argument. This can be helpful for models such as naive Bayes or quadratic discriminant analysis where the predictors must have at least two unique values _within each class_. 

All recipe steps now officially support empty selections to be more aligned with dplyr and other packages that use tidyselect. For example, if a previous step removed all of the columns needed for a later step, the recipe does not fail when it is estimated (with the exception of `step_mutate()`). The documentation in `?selections` has been updated with advice for writing selectors when filtering steps are used. 

There are new `extract_parameter_set_dials()` and `extract_parameter_dials()` methods to extract parameter sets and single parameters from a recipe. Since this is related to tuning parameters, the tune package should be loaded before they are used.  

## Breaking changes

Changes in `step_ica()` and  `step_kpca*()` will now cause recipe objects from previous versions to error when applied to new data. You will need to update these recipes with the current version to be able to use them. 

## Acknowledgements

We'd like to thank everyone that has contributed since the last release:
[&#x0040;agwalker82](https://github.com/agwalker82), [&#x0040;albert-ying](https://github.com/albert-ying), [&#x0040;AshesITR](https://github.com/AshesITR), [&#x0040;ddsjoberg](https://github.com/ddsjoberg), [&#x0040;DoktorMike](https://github.com/DoktorMike), [&#x0040;EmilHvitfeldt](https://github.com/EmilHvitfeldt), [&#x0040;emmansh](https://github.com/emmansh), [&#x0040;hermandr](https://github.com/hermandr), [&#x0040;hfrick](https://github.com/hfrick), [&#x0040;jacekkotowski](https://github.com/jacekkotowski), [&#x0040;JensPMB](https://github.com/JensPMB), [&#x0040;jkennel](https://github.com/jkennel), [&#x0040;juliasilge](https://github.com/juliasilge), [&#x0040;lg1000](https://github.com/lg1000), [&#x0040;lionel-](https://github.com/lionel-), [&#x0040;markjrieke](https://github.com/markjrieke), [&#x0040;mattwarkentin](https://github.com/mattwarkentin), [&#x0040;MichaelChirico](https://github.com/MichaelChirico), [&#x0040;ninohardt](https://github.com/ninohardt), [&#x0040;SewerynGrodny](https://github.com/SewerynGrodny), [&#x0040;SimonCoulombe](https://github.com/SimonCoulombe), [&#x0040;spsanderson](https://github.com/spsanderson), [&#x0040;tedmoorman](https://github.com/tedmoorman), [&#x0040;topepo](https://github.com/topepo), [&#x0040;tsengj](https://github.com/tsengj), [&#x0040;walrossker](https://github.com/walrossker), [&#x0040;williamshell](https://github.com/williamshell), and [&#x0040;xiaoxi-david](https://github.com/xiaoxi-david).

