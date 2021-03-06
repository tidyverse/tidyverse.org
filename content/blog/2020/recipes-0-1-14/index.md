---
output: hugodown::hugo_document

slug: recipes-0-1-14
title: recipes 0.1.14
date: 2020-10-22
author: Max Kuhn
description: >
    A new version of the recipes package contains a signficant API update and 
    some additional features. 

photo:
  url: https://unsplash.com/photos/ToswmEekSFI
  author: Holly Stratton

# one of: "deep-dive", "learn", "package", "programming", or "other"
categories: [package] 
tags: [tidymodels, recipes]
---



We're stoked to announce the release of [recipes](https://recipes.tidymodels.org) 0.1.14. recipes is an alternative method for creating and preprocessing design matrices that can be used for modeling or visualization. 

You can install it from CRAN with:


```r
install.packages("recipes")
```

You can see a full list of changes in the [release notes](https://recipes.tidymodels.org/news/index.html). There are some improvements and changes to talk about. 

## An alternative to `juice()`

Now that we have taught with recipes for a few years, we've realized that there is a lot of  confusion about the differences between `juice()` and `bake()`:

* `juice(recipe)` returns the preprocessed training set (at very low computational costs).
* `bake(recipe, new_data)` applies the recipe to any data (e.g. training, testing, unknowns, etc.)

We were not able to find ways to make this distinction clear for many users. 

How could we solve this issue? We decided to come up with a better alternative to `juice()`  that would be more intuitive. As a result,  _all_ applications of the recipe can now use `bake()`: 

* `bake(recipe, new_data = some_data_set)` works as before. 
* `bake(recipe, new_data = NULL)` now returns the preprocessed training set. 

This is precedented in base R since many `predict()` methods re-predict the training set when the `newdata` argument is `NULL` or missing. Note that there is no default for `new_data`; you have to set it to `NULL` to get the training set. 

We felt that this was the best API change that we could make. An external poll showed some agreement: 

<img src="juice-poll.png" title="plot of chunk poll" alt="plot of chunk poll" width="80%" style="display: block; margin: auto;" />

`juice()`, which is still my favorite R function name of all time, will not be removed; you can still use it. However, we will not use it in training materials or most documentation. 

## Imputation with linear models

Tim Zhou contributed a step to use linear models for imputation. This is a nice, compact method for adding an imputation equation for numeric predictors into the recipe. The syntax is similar to the existing imputation steps. Here's an example from the Ames data: 


```r
library(tidymodels)
data(ames)
ames$Sale_Price <- log10(ames$Sale_Price)

# Set some of the latitude values to be missing: 

set.seed(393)
ames_missing <- ames
ames_missing$Latitude[sample(1:nrow(ames), 200)] <- NA
```

We might be able to reasonably approximate the missing values based on the other geographic predictors (`Longitude` and `Neighborhood`) as well as a few aspects of the houses (e.g., `MS_Zoning` and `Alley`). A linear model is create with these predictors in order to estimate the missing `Latitude` data: 


```r
imputed_ames <-
  recipe(Sale_Price ~ ., data = ames_missing) %>%
  step_impute_linear(
    Latitude,
    impute_with = imp_vars(Longitude, Neighborhood, MS_Zoning, Alley), 
    id = "lm-imp"
  ) %>%
  prep(ames_missing)
```

This plot shows the missing data's true values on the x-axis and their imputed values on the y-axis: 

<img src="figure/plot-values-1.svg" title="plot of chunk plot-values" alt="plot of chunk plot-values" width="70%" />

In future versions, we will standardize on the naming convention `step_impute_*()`. The existing functions will be soft-deprecated for a reasonable time period to ensure backward compatibility.  
## Other changes

This version of the package has an extra logging option for `prep()` that will print some information on the differences in the data before and after the step was prepared: 


```r
ames_rec <- recipe(Sale_Price ~ ., data = ames) %>%
  step_BoxCox(Lot_Area, Gr_Liv_Area) %>%
  step_other(Neighborhood, threshold = 0.05)  %>%
  step_dummy(all_nominal()) %>%
  step_interact(~ starts_with("Central_Air"):Year_Built) %>%
  step_ns(Longitude, Latitude, deg_free = 5) %>% 
  prep(log_changes = TRUE)
```

```
## step_BoxCox (BoxCox_KMeZW): same number of columns
## 
## step_other (other_b4CM3): same number of columns
## 
## step_dummy (dummy_q3sI4): 
##  new (223): MS_SubClass_One_Story_1945_and_Older, ...
##  removed (40): MS_SubClass, MS_Zoning, Street, Alley, Lot_Shape, ...
## 
## step_interact (interact_xjtSG): 
##  new (1): Central_Air_Y_x_Year_Built
## 
## step_ns (ns_pfpld): 
##  new (10): Longitude_ns_1, Longitude_ns_2, Longitude_ns_3, ...
##  removed (2): Longitude, Latitude
```

Another important change was behind the scenes. Before, there were problems with using PSOCK clusters on Windows because the worker processes were not aware of all the packages that should be loaded. Now, recipes ensures that all of the packages required by each step will be accessible in parallel. A similar change is coming soon to the parsnip package. 

## Acknowledgements

Thanks to those users who filed issues or contributed a pull request since the previous release: [&#x0040;AndrewKostandy](https://github.com/AndrewKostandy), [&#x0040;anks7190](https://github.com/anks7190), [&#x0040;AshesITR](https://github.com/AshesITR), [&#x0040;Bijaelo](https://github.com/Bijaelo), [&#x0040;brodz](https://github.com/brodz), [&#x0040;DavisVaughan](https://github.com/DavisVaughan), [&#x0040;dgkf](https://github.com/dgkf), [&#x0040;EllaKaye](https://github.com/EllaKaye), [&#x0040;EmilHvitfeldt](https://github.com/EmilHvitfeldt), [&#x0040;hamedbh](https://github.com/hamedbh), [&#x0040;hnagaty](https://github.com/hnagaty), [&#x0040;irkaal](https://github.com/irkaal), [&#x0040;jerome-laurent-pro](https://github.com/jerome-laurent-pro), [&#x0040;juliasilge](https://github.com/juliasilge), [&#x0040;karaesmen](https://github.com/karaesmen), [&#x0040;kylegilde](https://github.com/kylegilde), [&#x0040;LordRudolf](https://github.com/LordRudolf), [&#x0040;lorenzwalthert](https://github.com/lorenzwalthert), [&#x0040;mattwarkentin](https://github.com/mattwarkentin), [&#x0040;mpettis](https://github.com/mpettis), [&#x0040;mt-edwards](https://github.com/mt-edwards), [&#x0040;nhward](https://github.com/nhward), [&#x0040;Nilafhiosagam](https://github.com/Nilafhiosagam), [&#x0040;NRaillard](https://github.com/NRaillard), [&#x0040;Paul-Yuchao-Dong](https://github.com/Paul-Yuchao-Dong), [&#x0040;perluna](https://github.com/perluna), [&#x0040;RaminZi](https://github.com/RaminZi), [&#x0040;rorynolan](https://github.com/rorynolan), [&#x0040;Steviey](https://github.com/Steviey), [&#x0040;topepo](https://github.com/topepo), and [&#x0040;ttzhou](https://github.com/ttzhou).
