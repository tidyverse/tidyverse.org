---
output: hugodown::hugo_document

slug: recipes-0-1-16
title: recipes 0.1.16
date: 2021-04-23
author: Max Kuhn
description: >
    The new version of recipes contains several helpful improvements.  

photo:
  url: https://unsplash.com/photos/5K5Nc3AGF1w
  author: American Heritage Chocolate

# one of: "deep-dive", "learn", "package", "programming", or "other"
categories: [package] 
tags: [tidymodels, recipes]
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

We're tickled pink to announce the release of [recipes](https://recipes.tidymodels.org/) 0.1.16. recipes is package for preprocessing data for modeling and data analysis.  

You can install it from CRAN with:


```r
install.packages("recipes")
```


This blog post will discuss the several improvements to the package. Before discussing new features, please note that the package license was changed from GPL-2 to MIT. 

You can see a full list of changes in the [release notes](https://recipes.tidymodels.org/news/index.html#recipes-0-1-16-unreleased)

## New column selectors

We do our best to keep track of persistent issues that show up in our teaching, [StackOVerflow](https://stackoverflow.com/questions/tagged/?tagnames=r-recipes+r&sort=newest) posts, [RStudio Community](https://community.rstudio.com/tag/tidymodels) posts, the [R4DS Tidy Modeling Book Club](https://www.google.com/search?q=r4ds+tidymodels+book+club&oq=r4ds+tidymodels+book+club), and other venues. If there are persistent issues, we do our best to help make the programming interface better. 

[Mine Çetinkaya-Rundel](https://twitter.com/minebocek) had a good idea for one issue related to creating dummy variables. For classification data where one or more predictors are categorical, the users might accidentally capture the _outcome_ and the predictors when creating dummy variables. For example: 


```r
library(tidymodels)

data(scat, package = "modeldata")

scat_rec <- 
  recipe(Species ~ Location + Age + Mass + Diameter, data = scat) %>% 
  step_dummy(all_nominal(), one_hot = TRUE) %>% 
  prep()

scat_rec %>% 
  bake(new_data = NULL) %>% 
  names()
```

```
## [1] "Age"               "Mass"              "Diameter"         
## [4] "Location_edge"     "Location_middle"   "Location_off_edge"
## [7] "Species_bobcat"    "Species_coyote"    "Species_gray_fox"
```

Note that the outcome column (`Species`) was made into a binary indicators. Most classification models prefer a factor vector and this would cause errors. The fix would be to remember to remove `Species` from the step selector. 

Most selectors in recipes are used to capture _predictor_ columns. The new version of recipes contains new selectors that combine the role and the data type: `all_nominal_predictors()` and `all_numeric_predictors()`. Using these: 


```r
scat_rec <- 
  recipe(Species ~ Location + Age + Mass + Diameter, data = scat) %>% 
  step_dummy(all_nominal_predictors(), one_hot = TRUE) %>% 
  prep()

scat_rec %>% 
  bake(new_data = NULL) %>% 
  names()
```

```
## [1] "Age"               "Mass"              "Diameter"         
## [4] "Species"           "Location_edge"     "Location_middle"  
## [7] "Location_off_edge"
```

The existing selectors will remain. We'll be converting our documentation, books, and training to use these new selectors when we select predictors of a specific type. 

## New steps

A new selector was added to compliment `step_rm()` (which removes columns). The new `step_select()` declares which columns to retain and emulates `dplyr::select()`. 

In cases where there are missing data, some data analysis methods compliment the existing predictors with missing value indicators for the covariates that have incomplete values. Thanks to [Konrad Semsch](https://konradsemsch.netlify.com/), `step_indicate_na()` can be used to create these. Using the previous example: 


```r
scat_rec <- 
  recipe(Species ~ Location + Age + Mass + Diameter, data = scat) %>% 
  step_dummy(all_nominal_predictors(), one_hot = TRUE) %>% 
  step_indicate_na(Mass, Diameter) %>% 
  prep()

scat_rec %>% 
  bake(new_data = scat[!complete.cases(scat),],
       contains("Mass"), contains("Diameter")) 
```

```
## # A tibble: 19 x 4
##     Mass na_ind_Mass Diameter na_ind_Diameter
##    <dbl>       <int>    <dbl>           <int>
##  1  2.51           0     NA                 1
##  2 18.1            0     NA                 1
##  3  8.17           0     NA                 1
##  4  3.43           0     NA                 1
##  5  5.53           0     NA                 1
##  6 26.9            0     24.1               0
##  7  5.38           0     17.8               0
##  8 14.9            0     19.3               0
##  9  9.51           0     17.9               0
## 10 18.3            0     18.1               0
## 11  8.73           0     25.8               0
## 12 25.9            0     22.2               0
## 13 14.5            0     20.1               0
## 14 10.3            0     17.8               0
## 15 14.6            0     19.3               0
## 16  5.66           0     24.8               0
## 17 NA              1     14.9               0
## 18  6.77           0     17.3               0
## 19 20.3            0     NA                 1
```

Speaking of missing data, we've decided to rename the current eight imputation steps:

* `step_impute_knn()` is favored over `step_knnimpute()`
* `step_impute_median()` is favored over `step_medianimpute()`
* and so on...

These are a lot better since they work well with tab-complete. The old steps will go through a gradual deprecation process before being removed at some point in the future. 

## Keeping columns used in other features

A fair number of steps take one or more columns of the data and convert them to artificial features. For example, principal component regression represents a set of columns as artificial features that are amalgamations of the original data. In some cases, users desired top be able to keep the original columns. 

The following steps have an option called `keep_original_cols`: `step_date()`, `step_dummy()`, `step_holiday()`, `step_ica()`, `step_isomap()`, `step_kpca_poly()`, `step_kpca_rbf()`, `step_nnmf()`, `step_pca()`, `step_pls()`, and `step_ratio()`. 

For example: 


```r
scat_rec <- 
  recipe(Species ~ Location + d13C + d15N + CN, data = scat) %>% 
  step_impute_mean(d13C, d15N, CN) %>% 
  step_dummy(all_nominal_predictors(), one_hot = TRUE) %>% 
  step_pca(d13C, d15N, CN, keep_original_cols = TRUE) %>% 
  prep()

scat_rec %>% 
  bake(new_data = scat) %>% 
  names()
```

```
##  [1] "d13C"              "d15N"              "CN"               
##  [4] "Species"           "Location_edge"     "Location_middle"  
##  [7] "Location_off_edge" "PC1"               "PC2"              
## [10] "PC3"
```

## Acknowledgements

Thakns for everyone who contributed since the previous version: [&#x0040;AshesITR](https://github.com/AshesITR), [&#x0040;BenoitLondon](https://github.com/BenoitLondon), [&#x0040;CelloJuan](https://github.com/CelloJuan), [&#x0040;dfalbel](https://github.com/dfalbel), [&#x0040;EmilHvitfeldt](https://github.com/EmilHvitfeldt), [&#x0040;gregdenay](https://github.com/gregdenay), [&#x0040;gustavomodelli](https://github.com/gustavomodelli), [&#x0040;hfrick](https://github.com/hfrick), [&#x0040;hsbadr](https://github.com/hsbadr), [&#x0040;jake-mason](https://github.com/jake-mason), [&#x0040;jjcurtin](https://github.com/jjcurtin), [&#x0040;juliasilge](https://github.com/juliasilge), [&#x0040;konradsemsch](https://github.com/konradsemsch), [&#x0040;kylegilde](https://github.com/kylegilde), [&#x0040;LePeti](https://github.com/LePeti), [&#x0040;LordRudolf](https://github.com/LordRudolf), [&#x0040;lukasal](https://github.com/lukasal), [&#x0040;mattwarkentin](https://github.com/mattwarkentin), [&#x0040;mikemc](https://github.com/mikemc), [&#x0040;mine-cetinkaya-rundel](https://github.com/mine-cetinkaya-rundel), [&#x0040;paudel-arjun](https://github.com/paudel-arjun), [&#x0040;renanxcortes](https://github.com/renanxcortes), [&#x0040;rorynolan](https://github.com/rorynolan), [&#x0040;saadaslam](https://github.com/saadaslam), [&#x0040;schoonees](https://github.com/schoonees), [&#x0040;topepo](https://github.com/topepo), [&#x0040;uriahf](https://github.com/uriahf), [&#x0040;vadimus202](https://github.com/vadimus202), and [&#x0040;zenggyu](https://github.com/zenggyu).
