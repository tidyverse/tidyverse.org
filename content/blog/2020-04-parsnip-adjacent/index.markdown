---
title: New parsnip-adjacent packages
slug: parsnip-adjacent
description: >
    Three new tidymodels pacakges for building models were just released on CRAN.
date: 2020-04-15
author: Max Kuhn
photo:
  url: https://unsplash.com/photos/bph0kUmAoXc
  author: Mae Mu
categories: [package]
---



We're delighted to announce the release of three new tidymodels packages. These are "parsnip-adjacent" packages that add new models to the tidymodels framework. 

## baguette 

This package contains basic functions and parsnip wrappers for bagging (aka [bootstrap aggregating](https://scholar.google.com/scholar?hl=en&as_sdt=0%2C7&q=bagging+predictors+breiman+1996&oq=Bagging+predictors+)) ensemble models. Right now, there are parsnip wrappers called `bag_tree()` and `bag_mars()` although more are planned, especially for rule-based models. 

One nice feature of this package is that the resulting model objects are smaller than they would normally be. Two separate operations are used to do this: 

 1. The butcher package is used to remove object elements that are not crucial to using the models. For example, some models contain copies of the training set or model residuals when created. These are removed so that space is saved. 

 2. For ensembles whose base models use a formula method, there is is a built-in redundancy because each model has an identical `terms` object. However, each one of these takes up separate space in memory and can be quite large when there are many predictors. baguette fixes this by replacing each `terms` object with the object from the _first_ model in the ensemble. Since the other `terms` objects are not modified, we get the same functional capabilities using far less memory to save the ensemble. A similar trick is used for the resampling method sin `modelr` and `rsample`. 

The models also return aggregated variable importance scores. 

Here's an example: 


```r
library(tidymodels)
library(baguette)

bag_tree() %>% 
  set_engine("rpart") # C5.0 is also available here. 
#> Bagged Decision Tree Model Specification (unknown)
#> 
#> Main Arguments:
#>   cost_complexity = 0
#>   min_n = 2
#> 
#> Computational engine: rpart

set.seed(5128)
bag_cars <- 
  bag_tree() %>% 
  set_engine("rpart", times = 25) %>% # 25 ensemble members 
  set_mode("regression") %>% 
  fit(mpg ~ ., data = mtcars)
bag_cars
#> parsnip model object
#> 
#> Fit time:  4.6s 
#> Bagged CART (regression with 25 members)
#> 
#> Variable importance scores include:
#> 
#> # A tibble: 10 x 4
#>    term  value std.error  used
#>    <chr> <dbl>     <dbl> <int>
#>  1 disp  966.       56.7    25
#>  2 wt    951.       59.4    25
#>  3 hp    810.       53.9    25
#>  4 cyl   567.       53.9    25
#>  5 drat  558.       57.5    25
#>  6 qsec  214.       28.4    25
#>  7 am    133.       41.1    23
#>  8 carb  126.       37.7    25
#>  9 vs    108.       41.2    24
#> 10 gear   38.9      16.5    19
```

## poissonreg

The parsnip package has methods for linear, logistic, and multinomial models. poissonreg extends this to data where the outcome is a count. There are engines for `glm`, `rstanarm`, `glmnet`, `hurdle`, and `zeroinfl`. The latter two enable zero-inflated Poisson models from the pscl package. 

Here is an example using a log-linear model for analyzing a three dimensional contingency table using the data from Agresti (2007, Table 7.6):


```r
library(poissonreg)

log_lin_mod <-
  poisson_reg() %>%
  set_engine("glm") %>%
  fit(count ~ (.)^2, data = seniors)
log_lin_mod
#> parsnip model object
#> 
#> Fit time:  4ms 
#> 
#> Call:  stats::glm(formula = formula, family = stats::poisson, data = data)
#> 
#> Coefficients:
#>               (Intercept)               marijuanayes  
#>                    5.6334                    -5.3090  
#>              cigaretteyes                 alcoholyes  
#>                   -1.8867                     0.4877  
#> marijuanayes:cigaretteyes    marijuanayes:alcoholyes  
#>                    2.8479                     2.9860  
#>   cigaretteyes:alcoholyes  
#>                    2.0545  
#> 
#> Degrees of Freedom: 7 Total (i.e. Null);  1 Residual
#> Null Deviance:	    2851 
#> Residual Deviance: 0.374 	AIC: 63.42
```

One interesting thing about the zero-inflated Poisson models is that there can be different predictors for the usual linear predictor as well as others for the probability of a zero count (see [Zeileis _et al_ (2008)](https://www.jstatsoft.org/article/view/v027i08/) for more details). For example: 


```r
data("bioChemists", package = "pscl")

poisson_reg() %>%
  set_engine("hurdle") %>%
  # Extended formula:
  fit(art ~ . | phd, data = bioChemists)
#> parsnip model object
#> 
#> Fit time:  21ms 
#> 
#> Call:
#> pscl::hurdle(formula = formula, data = data)
#> 
#> Count model coefficients (truncated poisson with log link):
#> (Intercept)     femWomen   marMarried         kid5          phd         ment  
#>     0.67114     -0.22858      0.09648     -0.14219     -0.01273      0.01875  
#> 
#> Zero hurdle model coefficients (binomial with logit link):
#> (Intercept)          phd  
#>      0.3075       0.1750
```

# plsmod

This package has parsnip methods for Partial Least Squares (PLS) regression and classification models based on the work in the Bioconductor [mixOmics](https://bioconductor.org/packages/release/bioc/html/mixOmics.html) package. This package facilitates ordinary PLS models as well as sparse versions. Additionally, it can also be used for multivariate models. 

Let's take the `meats` data from the modeldata package. Spectroscopy was used to estimate the percentage of protein, fat, and water from different meats. The predictors are a set of 100 highly correlated spectra values that would come from an instrument. The model can be used to estimate the three percentages simultaneously: 


```r
library(plsmod)

data(meats, package = "modeldata")

pls_fit <- 
  pls(num_comp = 5, num_terms = 20) %>% 
  set_engine("mixOmics") %>% 
  set_mode("regression") %>% 
  fit_xy(
    x = meats %>% select(-protein, -fat, -water) %>% slice(-(1:5)),
    y = meats %>% select( protein,  fat,  water) %>% slice(-(1:5))
  )
predict(pls_fit, meats %>% select(-protein, -fat, -water) %>% slice(1:5))
#> # A tibble: 5 x 3
#>   .pred_protein .pred_fat .pred_water
#>           <dbl>     <dbl>       <dbl>
#> 1          16.5     19.3         62.7
#> 2          14.5     36.7         48.4
#> 3          20.2     10.9         69.1
#> 4          20.0      7.21        72.3
#> 5          15.6     23.0         59.7
```

This model used 5 PLS components for each of the outcomes. The use of `num_terms` enables effect _sparsity_ where the 20 most influential predictors (out of 100) are used for each of the 5 PLS components. Different predictors can be used for each component. While this is not feature selection, it does offer the possibility of simpler models than ordinary PLS techniques.

# Other notes

Each of these models come fully enables to be used with the tune package; their model parameters can be optimized for performance. 

There are one or two other parsnip-adjacent packages that are around the corner. One is for mixed- and hierarchical models and another is for rule-based machine learning models (e.g. cubist, RuleFit, etc.) currently on GitHub in the [rules repo](https://github.com/tidymodels/rules). 

