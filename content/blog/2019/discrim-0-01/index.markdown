---
title: discrim 0.0.1
date: 2019-10-17
slug: discrim-0-0-1
author: Max Kuhn
categories: [package]
tags:
  - discrim
  - tidymodels
description: >
    The first version of discrim (0.0.1) is on CRAN. 
photo:
  url: https://unsplash.com/photos/4op9_2Bt2Eg
  author: Teo Duldulao
---



The new package [`discrim`](https://tidymodels.github.io/discrim/) contains `parsnip` bindings for additional classification models, including:

 * Linear discriminant analysis (LDA, simple and L2 regularized)
 * Regularized discriminant analysis (RDA, via [Friedman (1989)](https://scholar.google.com/scholar?hl=en&as_sdt=0%2C7&q=%22Regularized+Discriminant+Analysis%22&btnG=))
 * [Flexible discriminant analysis](https://scholar.google.com/scholar?hl=en&as_sdt=0%2C7&q=%22Flexible+discriminant+analysis%22&btnG=) (FDA) using [MARS features](https://scholar.google.com/scholar?hl=en&as_sdt=0%2C7&q=%22multivariate+adaptive+regression+splines%22&btnG=)
 * Naive Bayes models 

The package can also be used as a template for adding new models to `tidymodels` without having to directly involve `parsnip`. 

As an example, the package contains a simulated data set with two factors and two classes: 


```r
library(tidyverse)
#> ── Attaching packages ────────────────────────────────────────────────────────────────────────────────────── tidyverse 1.2.1 ──
#> ✔ tibble  2.1.3     ✔ purrr   0.3.2
#> ✔ tidyr   1.0.0     ✔ dplyr   0.8.3
#> ✔ readr   1.3.1     ✔ stringr 1.4.0
#> ✔ tibble  2.1.3     ✔ forcats 0.4.0
#> ── Conflicts ───────────────────────────────────────────────────────────────────────────────────────── tidyverse_conflicts() ──
#> ✖ dplyr::filter() masks stats::filter()
#> ✖ dplyr::lag()    masks stats::lag()
#> ✖ dplyr::select() masks MASS::select()
library(rsample)
library(discrim)
#> Loading required package: parsnip
library(earth)

data("parabolic", package = "rsample")
#> Warning in data("parabolic", package = "rsample"): data set 'parabolic' not
#> found
parabolic
#> # A tibble: 500 x 3
#>        X1     X2 class 
#>     <dbl>  <dbl> <fct> 
#>  1  3.29   1.66  Class1
#>  2  1.47   0.414 Class2
#>  3  1.66   0.791 Class2
#>  4  1.60   0.276 Class2
#>  5  2.17   3.17  Class1
#>  6  1.94   3.83  Class1
#>  7 -0.588 -0.977 Class2
#>  8 -0.951  1.40  Class1
#>  9  0.275  0.370 Class2
#> 10 -1.13  -1.14  Class1
#> # … with 490 more rows

ggplot(parabolic, aes(x = X1, y = X2)) + 
  geom_point(aes(col = class), alpha = .3) + 
  coord_equal() + 
  theme(legend.position = "top")
```

<img src="/articles/2019-10-discrim-0-01_files/figure-html/startup-1.png" width="700px" style="display: block; margin: auto;" />

How would a flexible discriminant model do here? We'll split the data then fit the model:


```r
set.seed(115)
data_split <- initial_split(parabolic, prop = 2/3)
data_tr <- training(data_split)
data_te <- testing(data_split)

fda_mod <- discrim_flexible() %>% set_engine("earth")

fda_fit <- 
  fda_mod %>% 
  fit(class ~ X1 + X2, data = data_tr)

fda_fit 
#> parsnip model object
#> 
#> Call:
#> mda::fda(formula = formula, data = data, method = earth::earth)
#> 
#> Dimension: 1 
#> 
#> Percent Between-Group Variance Explained:
#>  v1 
#> 100 
#> 
#> Training Misclassification Error: 0.105 ( N = 334 )
```

Since no model tuning parameters were specified, the MARS algorithm follows its own internal method for optimizing the number of features that are included in the model. The underlying MARS model is:


```r
summary(fda_fit$fit$fit)
#> Call: earth(x=x, y=Theta, weights=weights)
#> 
#>                  coefficients
#> (Intercept)            -0.892
#> h(X1- -1.42535)         2.780
#> h(X1- -0.907457)       -1.972
#> h(X1- -0.450335)       -0.766
#> h(X2-0.351695)         -1.634
#> h(X2-1.44562)           1.461
#> 
#> Selected 6 of 13 terms, and 2 of 2 predictors
#> Termination condition: Reached nk 21
#> Importance: X2, X1
#> Number of terms at each degree of interaction: 1 5 (additive model)
#> GCV 0.333    RSS 104    GRSq 0.669    RSq 0.688
```


The classification boundary, overlaid on the test set, shows a series of segmented lines:


```r
pred_grid <- 
  expand.grid(X1 = seq(-5, 5, length = 100), X2 = seq(-5, 5, length = 100))

pred_grid <- 
  bind_cols(
    pred_grid,
    predict(fda_fit, pred_grid, type = "prob") %>% 
      select(.pred_Class1) %>% 
      setNames("fda_pred")
  )

p <-
  ggplot(data_te, aes(x = X1, y = X2)) + 
  geom_point(aes(col = class), alpha = .3) + 
  coord_equal() + 
  theme(legend.position = "top")

p + 
  geom_contour(data = pred_grid, aes(z = fda_pred), breaks = .5, col = "black")
```

<img src="/articles/2019-10-discrim-0-01_files/figure-html/grid-1-1.png" width="700px" style="display: block; margin: auto;" />

This boundary seems pretty reasonable. 

These models also work with the new [`tune` package](https://github.com/tidymodels/tune). To demonstrate, a regularized discriminant analysis model^[Despite the name, this type of regularization is different from the more commonly used lasso ($L_1$) or ridge ($L_2$) regression methods. Here, the _covariance matrix_ of the predictors is regularized in different ways as described [here](https://rdrr.io/cran/klaR/man/rda.html).] will be fit to the data and optimized using a simple grid search. 

We'll use the devel version of dials:


```r
# devtools::install_github("tidymodels/tune")
# We use the devel version of several tidymodels packages:
library(tidymodels)
#> Registered S3 method overwritten by 'xts':
#>   method     from
#>   as.zoo.xts zoo
#> ── Attaching packages ───────────────────────────────────────────────────────────────────────────────────── tidymodels 0.0.3 ──
#> ✔ broom     0.5.2          ✔ recipes   0.1.7.9001
#> ✔ dials     0.0.3.9001     ✔ yardstick 0.0.4     
#> ✔ infer     0.5.0
#> ── Conflicts ──────────────────────────────────────────────────────────────────────────────────────── tidymodels_conflicts() ──
#> ✖ scales::discard() masks purrr::discard()
#> ✖ dplyr::filter()   masks stats::filter()
#> ✖ recipes::fixed()  masks stringr::fixed()
#> ✖ dplyr::lag()      masks stats::lag()
#> ✖ dials::margin()   masks ggplot2::margin()
#> ✖ dials::offset()   masks stats::offset()
#> ✖ dplyr::select()   masks MASS::select()
#> ✖ yardstick::spec() masks readr::spec()
#> ✖ recipes::step()   masks stats::step()
library(tune)
```

First, we mark the parameters for tuning:


```r
rda_mod <- 
  discrim_regularized(frac_common_cov = tune(), frac_identity = tune()) %>% 
  set_engine("klaR")
```

In order to tune the model, we require a grid of candidate values along with a resampling specification. We'll also setup a `yardstick` object to measure the area under the ROC curve for each candidate model:


```r
set.seed(20014)
folds <- vfold_cv(data_tr, repeats = 5)

# Use a space-filling design with 30 candidate models
candidates <- 
  rda_mod %>% 
  param_set() %>% 
  grid_max_entropy(size = 30)

roc_values <- metric_set(roc_auc)
```

Now we can tune the model:


```r
rda_res <-
  tune_grid(class ~ X1 + X2,
            model = rda_mod,
            rs = folds,
            grid = candidates,
            perf = roc_values)
```

The resampling estimates rank the models (starting with the best) as:


```r
auc_values <- estimate(rda_res) %>% arrange(desc(mean)) 
auc_values %>% slice(1:5)
#> # A tibble: 5 x 7
#>   frac_common_cov frac_identity .metric .estimator  mean     n std_err
#>             <dbl>         <dbl> <chr>   <chr>      <dbl> <int>   <dbl>
#> 1          0.0223         0.171 roc_auc binary     0.949    50 0.00392
#> 2          0.107          0.362 roc_auc binary     0.943    50 0.00421
#> 3          0.255          0.410 roc_auc binary     0.941    50 0.00445
#> 4          0.434          0.685 roc_auc binary     0.939    50 0.00454
#> 5          0.357          0.584 roc_auc binary     0.939    50 0.00454
```

Let's plot the resampling results:


```r
ggplot(auc_values, aes(x = frac_common_cov, y = frac_identity, size = mean)) + 
  geom_point(alpha = .5) + 
  coord_equal()
```

<img src="/articles/2019-10-discrim-0-01_files/figure-html/grid-res-1.png" width="700px" style="display: block; margin: auto;" />

There is a wide range of parameter combinations associated with good performance here. The poor results occur mostly when the model tries to enforce a mostly LDA covariance matrix (`frac_common_cov` > 0.9) along with `frac_identity` <= 0.6. The latter parameter tries to shrink the covariance matrix towards one where the parameters are considered to be nearly independent. 

The `parsnip` model object can be updated with the best parameter combination (`frac_common_cov` = 0.022 and `frac_identity` = 0.171).  These parameter values result in a model close to a pure QDA model. The `merge()` function can be used to insert these values into our original `parsnip` object:


```r
final_param <- 
  auc_values %>% 
  slice(1) %>% 
  select(frac_common_cov, frac_identity)

rda_mod <- 
  rda_mod %>% 
  merge(final_param) %>% 
  pull(x) %>% 
  pluck(1)

rda_mod
#> Regularized Discriminant Model Specification (classification)
#> 
#> Main Arguments:
#>   frac_common_cov = 0.0222721435129642
#>   frac_identity = 0.171292591374367
#> 
#> Computational engine: klaR

rda_fit <- 
  rda_mod %>% 
  fit(class ~ X1 + X2, data = data_tr)
```

To show the class boundary:


```r
pred_grid <- 
  bind_cols(
    pred_grid,
    predict(rda_fit, pred_grid, type = "prob") %>% 
      select(.pred_Class1) %>% 
      setNames("rda_pred")
  )

p + 
  geom_contour(data = pred_grid, aes(z = fda_pred), breaks = .5, col = "black", 
               alpha = .5, lty = 2) + 
  geom_contour(data = pred_grid, aes(z = rda_pred), breaks = .5, col = "black")
```

<img src="/articles/2019-10-discrim-0-01_files/figure-html/rda-boundary-1.png" width="700px" style="display: block; margin: auto;" />

This is pretty close to the true simulated boundary, which is parabolic in nature. 

The test sets results are:


```r
probs_te <- 
  predict(rda_fit, data_te, type = "prob") %>% 
  bind_cols(data_te %>% select(class))
probs_te
#> # A tibble: 166 x 3
#>    .pred_Class1 .pred_Class2 class 
#>           <dbl>        <dbl> <fct> 
#>  1        0.851     0.149    Class1
#>  2        0.205     0.795    Class2
#>  3        1.000     0.000339 Class1
#>  4        0.326     0.674    Class2
#>  5        0.377     0.623    Class2
#>  6        0.202     0.798    Class2
#>  7        0.333     0.667    Class1
#>  8        0.472     0.528    Class1
#>  9        0.979     0.0210   Class1
#> 10        0.166     0.834    Class2
#> # … with 156 more rows

roc_auc(probs_te, class, .pred_Class1)
#> # A tibble: 1 x 3
#>   .metric .estimator .estimate
#>   <chr>   <chr>          <dbl>
#> 1 roc_auc binary         0.971
```
Pretty good!
