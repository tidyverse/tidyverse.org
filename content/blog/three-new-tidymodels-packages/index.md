---
output: hugodown::hugo_document

slug: three-new-tidymodels-packages
title: "Two New tidymodels Packages"
date: 2025-11-23
author: Max Kuhn, Frances Lin
description: >
    Two new tidymodels packages focus on supervised feature selection. 

photo:
  url: https://unsplash.com/photos/three-french-macaroons-on-plate-71jYZb6Ag7M
  author: Keila Hötzel

# one of: "deep-dive", "learn", "package", "programming", "roundup", or "other"
categories: [package] 
tags: [tidymodels,feature-selection]
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

We're very chuffed to announce the release of _two_ new modeling packages: filtro and  important. 

You can install them from CRAN with:


``` r
install.packages(c("filtro", "important"))
```

This blog post will describe each. 

## filtro

Feature selection is an important step in building machine learning models that are robust and reliable. By keeping only the most relevant predictors, we can reduce overfitting, improve model performance, and speed up computation. 

filtro is a low-level tidy tools designed for filter-based supervised feature selection. filtro makes it easy to score, rank, and select features using a wide range of statistical and model-based metrics. The scoring metrics include: p-values, correlation, random forest feature importance, information gain, and more. 

With filtro, we can quickly rank the variables and select either the top proportion or the top number features that best contribute to our model. It also supports multi-parameter optimization via desirability functions. filtro is a standalone tool, but it integrates with other packages, allowing it to be used within the tidymodels workflows.

Currently, filtro implements a total of six filters, and the filters are written in S7 for usability and extensibility. 

The available score class objects are:


```
##  [1] "score_aov_fstat"          "score_aov_pval"          
##  [3] "score_cor_pearson"        "score_cor_spearman"      
##  [5] "score_gain_ratio"         "score_imp_rf"            
##  [7] "score_imp_rf_conditional" "score_imp_rf_oblique"    
##  [9] "score_info_gain"          "score_roc_auc"           
## [11] "score_sym_uncert"         "score_xtab_pval_chisq"   
## [13] "score_xtab_pval_fisher"
```

Let's look at an example. [Kuhn and Johnson (2013)](https://www.google.com/search?q=Kuhn+and+Johnson+Applied+Predictive+Modeling+2013) described a data set where 176 samples were collected from a chemical manufacturing process. The goal is to predict process yield. Predictors are continuous, count, and categorical; some are correlated, and some contain missing values. 

Let’s create an initial split of the data (which are in the modeldata package):


``` r
library(tidymodels)
library(filtro)

set.seed(1)
yield_split <- initial_split(modeldata::chem_proc_yield)
yield_split
```

```
## <Training/Testing/Total>
## <132/44/176>
```

``` r
yield_train <- training(yield_split)
yield_test <- testing(yield_split)
```

We’d like to estimate the strength of the relationship between these 57 predictors and the process yield. We’ll quantify that in two ways. First is the old-fashioned [Spearman rank correlation](https://en.wikipedia.org/wiki/Spearman%27s_rank_correlation_coefficient) statistic. We can estimate these values and rank them by the absolute value of the correlations. We can also measure their value using a random forest variable importance. One quality of the predictors is that their values are correlated, so there may be some value in using an _oblique_ random forest model. This creates a collection of tree-based models with splits that are linear combinations of the selected predictors. 

With filtro, we use the pre-made score objects for these measures along with the `fit()` method: 


``` r
yield_rank_res <-
  score_cor_spearman |>
  fit(yield ~ ., data = yield_train)

# The object contains the statistics:
yield_rank_res@results |> 
  arrange(desc(abs(score)))
```

```
## # A tibble: 57 × 4
##    name          score outcome predictor      
##    <chr>         <dbl> <chr>   <chr>          
##  1 cor_spearman  0.655 yield   man_proc_32    
##  2 cor_spearman -0.537 yield   man_proc_36    
##  3 cor_spearman  0.519 yield   bio_material_03
##  4 cor_spearman  0.502 yield   bio_material_06
##  5 cor_spearman  0.491 yield   man_proc_09    
##  6 cor_spearman  0.478 yield   bio_material_02
##  7 cor_spearman  0.446 yield   man_proc_33    
##  8 cor_spearman  0.421 yield   bio_material_12
##  9 cor_spearman -0.420 yield   man_proc_13    
## 10 cor_spearman  0.412 yield   bio_material_04
## # ℹ 47 more rows
```

It is just as simple for the random forest model


``` r
yield_rf_res <-
  score_imp_rf_oblique |>
  fit(yield ~ ., data = yield_train)

yield_rf_res@results |> 
  arrange(desc(abs(score)))
```

```
## # A tibble: 57 × 4
##    name            score outcome predictor      
##    <chr>           <dbl> <chr>   <chr>          
##  1 imp_rf_oblique 0.128  yield   man_proc_32    
##  2 imp_rf_oblique 0.0697 yield   man_proc_36    
##  3 imp_rf_oblique 0.0670 yield   man_proc_17    
##  4 imp_rf_oblique 0.0644 yield   man_proc_09    
##  5 imp_rf_oblique 0.0612 yield   man_proc_13    
##  6 imp_rf_oblique 0.0446 yield   bio_material_03
##  7 imp_rf_oblique 0.0315 yield   man_proc_33    
##  8 imp_rf_oblique 0.0263 yield   man_proc_11    
##  9 imp_rf_oblique 0.0263 yield   bio_material_04
## 10 imp_rf_oblique 0.0262 yield   bio_material_06
## # ℹ 47 more rows
```

We should probably combine the scores and do a joint ranking. To combine the two sets of statistics: 


``` r
class_score_list <-
  list(
    yield_rank_res,
    yield_rf_res
  ) |>
  bind_scores()

class_score_list
```

```
## # A tibble: 57 × 4
##    outcome predictor       cor_spearman imp_rf_oblique
##    <chr>   <chr>                  <dbl>          <dbl>
##  1 yield   bio_material_01        0.404        0.0178 
##  2 yield   bio_material_02        0.478        0.0190 
##  3 yield   bio_material_03        0.519        0.0446 
##  4 yield   bio_material_04        0.412        0.0263 
##  5 yield   bio_material_05        0.116        0.00639
##  6 yield   bio_material_06        0.502        0.0262 
##  7 yield   bio_material_07       -0.101        0.00151
##  8 yield   bio_material_08        0.369        0.00714
##  9 yield   bio_material_09        0.109        0.0122 
## 10 yield   bio_material_10        0.214        0.00998
## # ℹ 47 more rows
```

We can accomplish a joint ranking via desirability functions. Here, we set goals for each score (i.e., maximize, minimize, etc.). The algorithm rescales their values and uses a geometric mean for an overall ranking. The desirability2 package has some nice tools for this. Here's how we do it: 


``` r
library(desirability2)
class_score_list |>
  show_best_desirability_prop(
    maximize(cor_spearman, low = 0.25, high = 1),
    maximize(imp_rf_oblique, scale = 2)
  ) |> 
  arrange(desc(.d_overall)) |> 
  select(-starts_with(".d_max_"))
```

```
## # A tibble: 57 × 5
##    outcome predictor       cor_spearman imp_rf_oblique .d_overall
##    <chr>   <chr>                  <dbl>          <dbl>      <dbl>
##  1 yield   man_proc_32            0.655         0.128      0.735 
##  2 yield   man_proc_09            0.491         0.0644     0.291 
##  3 yield   bio_material_03        0.519         0.0446     0.217 
##  4 yield   man_proc_33            0.446         0.0315     0.134 
##  5 yield   bio_material_06        0.502         0.0262     0.129 
##  6 yield   bio_material_04        0.412         0.0263     0.104 
##  7 yield   bio_material_02        0.478         0.0190     0.0926
##  8 yield   bio_material_01        0.404         0.0178     0.0719
##  9 yield   bio_material_11        0.381         0.0194     0.0714
## 10 yield   man_proc_12            0.391         0.0183     0.0705
## # ℹ 47 more rows
```

Using the `scale = 2` options puts more weight on the random forest results. 

Now that we've looked at filtro, next up is the important package (yes, this is what we named it). 

## important

The important package does two things. First, it provides yet another tool for calculating random forest-like permutation importance scores. We highly value other packages that perform these same calculations (such as [DALEX](https://modeloriented.github.io/DALEX/) and [vip](https://github.com/koalaverse/vip/)). Our rationale for creating another package for this is that we've developed interfaces for censored regression, including dynamic metrics such as Brier scores or ROC curves that evaluate models at a specific time point. These dynamic methods aren't available in other packages, and the peculiarities of these metrics make them difficult to incorporate into existing frameworks. 

Other niceties about importance scores are that any metric from the yardstick methods can be used, and we have optimized parallel processing for the underlying computations. For the latter feature, we support the future and mirai packages for parallel processing. 

important also has three recipe steps for supervised feature selection (similar to what Steven Pawley did with his [colino package](https://stevenpawley.github.io/colino/)). The steps are:

- [`step_predictors_best()`](https://important.tidymodels.org/reference/step_predictor_best.html)
- [`step_predictors_retain()`](https://important.tidymodels.org/reference/step_predictor_retain.html)
- [`step_predictors_desirability()`](https://important.tidymodels.org/reference/step_predictor_desirability.html)

Let's look at the last one, which mirrors our analysis above. 


``` r
library(important)
goals <-
  desirability(
    maximize(cor_spearman, low = 0.25, high = 1),
    maximize(imp_rf_oblique, scale = 2)
  )

yield_rec <-
  recipe(yield ~ ., data = yield_train) |>
  step_impute_knn(all_predictors(), neighbors = 10) |>
  step_predictor_desirability(
    all_predictors(),
    score = goals,
    prop_terms = 1 / 10
  )
yield_rec
```

```
## 
```

```
## ── Recipe ───────────────────────────────────────────────────────
```

```
## 
```

```
## ── Inputs
```

```
## Number of variables by role
```

```
## outcome:    1
## predictor: 57
```

```
## 
```

```
## ── Operations
```

```
## • K-nearest neighbor imputation for: all_predictors()
```

```
## • Feature selection via desirability functions (`cor_spearman`
##   and `imp_rf_oblique`) on: all_predictors()
```
Next up is the important package (yes, this is what we named it). When combined with a specific model, we can tune the number of neighbors as well as the proportion of predictors retained (10% above). 

`prep()` will do the appropriate estimation steps: 


``` r
trained_rec <- prep(yield_rec)
```

Which 10% of the predictors were retained? The `tidy()` method can list the scores and their rankings: 


``` r
scores <- tidy(trained_rec, number = 2)
scores |>
  arrange(desc(.d_overall)) |>
  select(-starts_with(".d_max_"), -id)
```

```
## # A tibble: 57 × 5
##    terms           removed cor_spearman imp_rf_oblique .d_overall
##    <chr>           <lgl>          <dbl>          <dbl>      <dbl>
##  1 man_proc_32     FALSE          0.655         0.128       0.735
##  2 man_proc_36     FALSE         -0.530         0.0668      0.325
##  3 man_proc_09     FALSE          0.491         0.0673      0.304
##  4 man_proc_13     FALSE         -0.420         0.0725      0.275
##  5 bio_material_03 FALSE          0.519         0.0517      0.249
##  6 bio_material_06 TRUE           0.502         0.0445      0.210
##  7 man_proc_17     TRUE          -0.303         0.0749      0.158
##  8 man_proc_33     TRUE           0.443         0.0374      0.156
##  9 bio_material_02 TRUE           0.478         0.0330      0.151
## 10 bio_material_04 TRUE           0.412         0.0347      0.133
## # ℹ 47 more rows
```

``` r
# What percentage was removed?
mean(scores$removed * 100)
```

```
## [1] 91.22807
```


