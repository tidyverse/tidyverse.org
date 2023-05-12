---
output: hugodown::hugo_document

slug: desirability2
title: desirability2
date: 2023-05-16
author: Max Kuhn
description: >
    The desirability2 package, for multivariable optimization, is now on CRAN.

photo:
  url: https://unsplash.com/photos/8cvksz5mmnE
  author: Joel Naren

# one of: "deep-dive", "learn", "package", "programming", "roundup", or "other"
categories: [package] 
tags: [tidymodels,desirability,optimization]
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

We're tickled pink to announce the release of [desirability2](http://desirability2.tidymodels.org) (version 0.0.1). You can install it from CRAN with:


```r
install.packages("desirability2")
```

This blog post will introduce you to the package and desirability functions. 

Let's load some packages! 


```r
library(desirability2)
library(dplyr)
library(ggplot2)
```




[Desirability functions](https://scholar.google.com/scholar?hl=en&as_sdt=0%2C7&q=%22desirability+functions%22) are tools that can be used to rank or optimize multiple characteristics at once. They are intuitive and easy to use. There are a few R packages that implement them, including [desirability](http://cran.r-project.org/package=desirability) and [desiR](http://cran.r-project.org/package=desiR). 

We have a new one, [desirability2](http://cran.r-project.org/package=desirability2), with an interface conducive to being used in-line via dplyr pipelines. 

Let's demonstrate by looking at an application. Suppose we created a classification model and produced multiple metrics on how well it classifies new data. We measured the area under the ROC curve and the binomial log-loss statistic in this example. There are about 300 different model configurations that we investigated via tuning. 

Looking for the "best" results, the two metrics give us different answers: 


```r
classification_results
```

```
## # A tibble: 298 × 5
##    mixture penalty mn_log_loss roc_auc num_features
##      <dbl>   <dbl>       <dbl>   <dbl>        <int>
##  1       0  0.1          0.199   0.869          211
##  2       0  0.0788       0.196   0.870          211
##  3       0  0.0621       0.194   0.871          211
##  4       0  0.0489       0.192   0.872          211
##  5       0  0.0386       0.191   0.873          211
##  6       0  0.0304       0.190   0.873          211
##  7       0  0.0240       0.188   0.874          211
##  8       0  0.0189       0.188   0.874          211
##  9       0  0.0149       0.187   0.874          211
## 10       0  0.0117       0.186   0.874          211
## # ℹ 288 more rows
```

```r
classification_results |> slice_max(roc_auc, n = 1)
```

```
## # A tibble: 1 × 5
##   mixture penalty mn_log_loss roc_auc num_features
##     <dbl>   <dbl>       <dbl>   <dbl>        <int>
## 1   0.222 0.00574       0.185   0.876           86
```

```r
classification_results |> slice_min(mn_log_loss, n = 1)
```

```
## # A tibble: 1 × 5
##   mixture  penalty mn_log_loss roc_auc num_features
##     <dbl>    <dbl>       <dbl>   <dbl>        <int>
## 1       1 0.000853       0.184   0.876          103
```

Are the two metrics related? Here's a plot of the data: 


```r
classification_results |> 
  ggplot(aes(roc_auc, mn_log_loss, col = num_features)) + 
  geom_point(alpha = 1/2)
```

<img src="figure/unnamed-chunk-4-1.svg" alt="plot of chunk unnamed-chunk-4" width="60%" />

We colored the point using the number of features used in the model. Fewer predictors are better; we'd like to factor that into the tuning parameter selection. 

To optimize them all at once, desirability functions map their values to be between zero and one (with the latter being the most desirable). For the ROC scores, a value of 1.0 is best, and we may not consider a model with an AUC of less than 0.80. We can use the [`d_max()`](http://desirability2.tidymodels.org/reference/inline_desirability.html) function to translate these values to desirability: 


```r
classification_results %>% 
  mutate(roc_d = d_max(roc_auc, high = 1, low = 0.8)) %>% 
  ggplot(aes(roc_auc, roc_d)) +
  geom_line() + 
  geom_point() + 
  lims(y = 0:1)
```

<img src="figure/unnamed-chunk-5-1.svg" alt="plot of chunk unnamed-chunk-5" width="60%" />

Note that all model configurations with ROC AUC scores below 0.80 have zero desirability. 

Since we want to reduce loss, we can use `d_min()` to show a curve where smaller is better. We'll use the min and max values, as defined by the data, for this specification:


```r
classification_results %>% 
  mutate(
    roc_d   = d_max(roc_auc, high = 1, low = 0.8),
    loss_d  = d_min(mn_log_loss, use_data = TRUE)
    ) %>% 
  ggplot(aes(mn_log_loss, loss_d)) +
  geom_line() + 
  geom_point() + 
  lims(y = 0:1)
```

<img src="figure/unnamed-chunk-6-1.svg" alt="plot of chunk unnamed-chunk-6" width="60%" />

Finally, we can factor in the number of features. Arguably this is more important to use than the other two outcomes; we will make this curve nonlinear so that it becomes more challenging to be desirable as the number of features increases. For this, we'll use the `scale` option to `d_min()`, where larger values make the criteria more difficult to satisfy: 


```r
classification_results %>% 
  mutate(
    roc_d   = d_max(roc_auc, high = 1, low = 0.8),
    loss_d  = d_min(mn_log_loss, use_data = TRUE),
    feat_d  = d_min(num_features, low = 0, high = 100, scale = 2)
    ) %>% 
  ggplot(aes(num_features, feat_d)) +
  geom_line() + 
  geom_point() + 
  lims(y = 0:1)
```

<img src="figure/unnamed-chunk-7-1.svg" alt="plot of chunk unnamed-chunk-7" width="60%" />

Combining these components into a single criterion using the geometric mean is common. Using this statistic has the side effect that any criteria with zero desirability make the overall desirability zero (since the geometric mean multiples the values). There is a function called [`d_overall()`](http://desirability2.tidymodels.org/reference/d_overall.html) that can be used with dplyr's `across()` function. Sorting by overall desirability gives us tuning parameter values (`mixture` and `penalty`) that are best for this combination of criteria. 


```r
classification_results %>% 
  mutate(
    roc_d   = d_max(roc_auc, high = 1, low = 0.8),
    loss_d  = d_min(mn_log_loss, use_data = TRUE),
    feat_d  = d_min(num_features, low = 0, high = 100, scale = 2),
    overall = d_overall(across(ends_with("_d")))
  ) %>% 
  slice_max(overall, n = 5)
```

```
## # A tibble: 5 × 9
##   mixture penalty mn_log_loss roc_auc num_features roc_d loss_d feat_d overall
##     <dbl>   <dbl>       <dbl>   <dbl>        <int> <dbl>  <dbl>  <dbl>   <dbl>
## 1   1     0.00924       0.200   0.859           15 0.295  0.815  0.722   0.558
## 2   0.667 0.0117        0.199   0.862           18 0.311  0.827  0.672   0.557
## 3   0.667 0.0149        0.201   0.858           14 0.291  0.802  0.740   0.557
## 4   0.889 0.00924       0.199   0.861           18 0.305  0.825  0.672   0.553
## 5   0.889 0.0117        0.201   0.857           14 0.285  0.801  0.740   0.553
```

That's it! That's the package.  

