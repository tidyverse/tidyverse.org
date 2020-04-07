---
title: parsnip
date: 2018-11-28
slug: parsnip-0-0-1
author: Max Kuhn
categories: [package]
tags:
  - parsnip
  - tidymodels
description: >
    A tidy unified interface to models
photo:
  url: https://unsplash.com/photos/ahB6ZhxHRtk
  author: rawpixel
---



The `parsnip` package is now [on CRAN](https://cran.r-project.org/package=parsnip). It is designed to solve a specific problem related to model fitting in R, the interface.  Many functions have different interfaces and arguments names and `parsnip` standardizes the interface for fitting models as well as the return values. When using `parsnip`, you don't have to remember each interface and its unique set of argument names to easily move between R packages.  

This is the first of several blog posts that discuss the package. More information can be found at the [`parsnip` pkgdown site](https://tidymodels.github.io/parsnip/). 

# The Problem

The interface problem is something that I've talked about for some time. I'll use logistic regression to demonstrate the issue here. Many of us are familiar with the standard `glm` syntax for fitting models^[This syntax predates R and was formally described in the 1992 book _Statistical Models in S_. It's older than [_debian_](https://www.debian.org/doc/manuals/project-history/ch-intro.en.html#s1.1).]. It uses the formula method and, to fit a logistic model, the `family = binomial` argument is required. Suppose that we want to apply some regularization to the model. A popular choice is the [`glmnet`](https://cran.r-project.org/package=glmnet) package, but its interface is very different from `glm`:

* It does not use the formula method and expects the predictors in a matrix (so dummy variables must be pre-computed).
* Nonstandard `family` objects are used. The argument is `family = "binomial"`. 

While each of these is not a significant issue, these types of inconsistencies are common across R packages. The only way to avoid them is to only use a single package. 

There is a larger issue when you want to fit the same model via `tensorflow`'s [`keras`](https://keras.rstudio.com/) interface. `keras` has a beautiful approach to sequentially assembling deep learning models, but it has very little resemblance to the traditional approaches. Creating a simple logistic model requires the user to learn and use drastically different syntax. 

There is also inconsistency in how different packages return predictions. _Most_ R packages use the `predict()` function to make predictions on new data. If we want to get class probabilities for our logistic regression model, using `predict(obj, newdata, type = "response")` will return a vector of probabilities for the second level of our factor. However, this convention can be wildly inconsistent across R packages. Examples are:

<style>
td,th {
  padding: 0.4em;
}
</style>

|Function      |Package      |Code                                       |
|:-------------|:------------|:------------------------------------------|
|`glm`         |`stats`      |`predict(obj, type = "response")`          |
|`lda`         |`MASS`       |`predict(obj)`                             |
|`gbm`         |`gbm`        |`predict(obj, type = "response", n.trees)` |
|`mda`         |`mda`        |`predict(obj, type = "posterior")`         |
|`rpart`       |`rpart`      |`predict(obj, type = "prob")`              |
|`Weka`        |`RWeka`      |`predict(obj, type = "probability")`       |
|`logitboost`  |`LogitBoost` |`predict(obj, type = "raw", nIter)`        |
|`pamr.train`  |`pamr`       |`pamr.predict(obj, type = "posterior")`    |

<br>

An added complication is that some models can create predictions across multiple _submodels_ at once. For example, boosted trees fit using `\(i\)` iterations can produce predictions using less than `\(i\)` iterations (effectively creating a different prediction model). This can lead to further inconsistencies.

These issues, in aggregate, can be grating. Sometimes it might feel like:

> "Is R working for me or am I working for R?"

`parsnip` aims to decrease the frustration for people who want to evaluate different types of models on a data set. This is very much related to our [guidelines for developing modeling packages](https://tidymodels.github.io/model-implementation-principles/) (on which we are still looking for feedback).  

# parsnip syntax

To demonstrate, we'll use `mtcars` once again. 


```r
library(parsnip)
library(tidymodels)
```

```
#> ── Attaching packages ─────────────────────────────────────────────────────────────────── tidymodels 0.0.1 ──
```

```
#> ✔ ggplot2   3.1.0     ✔ recipes   0.1.4
#> ✔ tibble    1.4.2     ✔ broom     0.5.0
#> ✔ purrr     0.2.5     ✔ yardstick 0.0.2
#> ✔ dplyr     0.7.8     ✔ infer     0.3.1
#> ✔ rsample   0.0.3
```

```
#> ── Conflicts ────────────────────────────────────────────────────────────────────── tidymodels_conflicts() ──
#> ✖ purrr::accumulate()      masks foreach::accumulate()
#> ✖ rsample::fill()          masks tidyr::fill()
#> ✖ dplyr::filter()          masks stats::filter()
#> ✖ yardstick::get_weights() masks keras::get_weights()
#> ✖ dplyr::lag()             masks stats::lag()
#> ✖ rsample::populate()      masks Rcpp::populate()
#> ✖ recipes::step()          masks stats::step()
#> ✖ yardstick::tidy()        masks broom::tidy(), recipes::tidy(), rsample::tidy()
#> ✖ purrr::when()            masks foreach::when()
```

```r
set.seed(4831)
split <- initial_split(mtcars, props = 9/10)
car_train <- training(split)
car_test  <- testing(split)
```

Let's preprocess these data to center and scale the predictors. We'll use a basic recipe to do this:


```r
car_rec <- 
  recipe(mpg ~ ., data = car_train) %>%
  step_center(all_predictors()) %>%
  step_scale(all_predictors()) %>%
  prep(training = car_train, retain = TRUE)

# The processed versions are:
train_data <- juice(car_rec)
test_data  <- bake(car_rec, car_test)
```

To use `parsnip`, you start with a model _specification_. This is a simple object that defines the _intent_ of the model. Since we will be using linear regression of various flavors, our first step is a simple statement:


```r
car_model <- linear_reg()
car_model
```

```
#> Linear Regression Model Specification (regression)
```

That's pretty underwhelming because we haven't given it any details yet. `parsnip` offers a variety of methods to fit this general model. We will use ordinary least squares, but could also use penalized least squares too (via the lasso, ridge regression, Bayesian estimation, dropout, etc). We differentiate these cases by the ***computational engines***, which is a combination of the estimation type, such as least squares, and the _implemention_. The latter could be an R package or some other computing platform like Spark or Tensorflow. 

To start simple, let's use `lm`:


```r
lm_car_model <- 
  car_model %>%
  set_engine("lm")
lm_car_model
```

```
#> Linear Regression Model Specification (regression)
#> 
#> Computational engine: lm
```

There are no additional arguments that we should specify here, so let's jump to fitting the actual model. Our two choices at this point are whether to use `fit()` or `fit_xy()`. `fit()` takes a formula, while `fit_xy()` takes objects for the predictors and outcome(s). Recall that `glm` and `lm` only allow for formulas, while `glmnet` only takes a matrix of predictors and an outcome. `parsnip` allows for either so that you can avoid having to think about what the underlying model function requires. To demonstrate, let's make a simple model:


```r
lm_fit <-
  lm_car_model %>%
  fit(mpg ~ ., data = car_train)

# or
lm_car_model %>%
  fit_xy(x = select(car_train, -mpg), y = select(car_train, mpg))
```

```
#> parsnip model object
#> 
#> 
#> Call:
#> stats::lm(formula = formula, data = data)
#> 
#> Coefficients:
#> (Intercept)          cyl         disp           hp         drat  
#>     23.1945      -1.6396       0.0439      -0.0301       0.8517  
#>          wt         qsec           vs           am         gear  
#>     -6.0165       0.8668       0.8757       2.4274      -0.4658  
#>        carb  
#>      0.7889
```

If we had predictors that were factors, `fit()` would be a better choice. If the underlying model takes a formula, the formula and data is passed directly to the function without modification. Otherwise, `fit()` applies the standard `model.matrix()` machinery to do the preprocessing and converts the data to the required format (e.g. a matrix for `glmnet`). Note that, for Spark tables, `fit()` must be used.  

It should be noted that `lm_car_model` is a [model specification object](https://tidymodels.github.io/parsnip/reference/model_spec.html) while `lm_fit` is a [model fit object](https://tidymodels.github.io/parsnip/reference/model_fit.html). 

# More Engines

The value of `parsnip` starts to show when we want to try different engines. Let's take our same model and use Bayesian estimation to fit the parameters using Stan. We can change the engine to do so:


```r
stan_car_model <- 
  car_model %>%
  set_engine("stan")
stan_car_model
```

```
#> Linear Regression Model Specification (regression)
#> 
#> Computational engine: stan
```

To fit this model, `parsnip` calls `stan_glm()` from the [`rstanarm`](http://mc-stan.org/rstanarm/) package. If you want to pass in arguments to this function, just add them to `set_engine`:


```r
stan_car_model <- 
  car_model %>%
  set_engine("stan", iter = 5000, prior_intercept = rstanarm::cauchy(0, 10), seed = 2347)
stan_car_model
```

```
#> Linear Regression Model Specification (regression)
#> 
#> Engine-Specific Arguments:
#>   iter = 5000
#>   prior_intercept = rstanarm::cauchy(0, 10)
#>   seed = 2347
#> 
#> Computational engine: stan
```

The namespace was used to call `cauchy()` since `parsnip` does not fully attach the package when the model is fit. 

The model can be fit in the same way. We'll add a feature here; `rstanarm` prints _a lot_ of output when fitting. This can be helpful to diagnose issues but we'll exclude it using a control function:


```r
# don't print anything:
ctrl <- fit_control(verbosity = 0)

stan_fit <- 
  stan_car_model %>%
    fit(mpg ~ ., data = car_train, control = ctrl)
stan_fit
```

```
#> parsnip model object
#> 
#> stan_glm
#>  family:       gaussian [identity]
#>  formula:      mpg ~ .
#>  observations: 24
#>  predictors:   11
#> ------
#>             Median MAD_SD
#> (Intercept) 23.6   24.1  
#> cyl         -1.5    1.6  
#> disp         0.0    0.0  
#> hp           0.0    0.0  
#> drat         0.8    2.4  
#> wt          -5.4    3.1  
#> qsec         0.8    0.9  
#> vs           0.7    3.2  
#> am           2.3    2.7  
#> gear        -0.4    2.1  
#> carb         0.6    1.4  
#> 
#> Auxiliary parameter(s):
#>       Median MAD_SD
#> sigma 3.1    0.6   
#> 
#> Sample avg. posterior predictive distribution of y:
#>          Median MAD_SD
#> mean_PPD 20.6    0.9  
#> 
#> ------
#> * For help interpreting the printed output see ?print.stanreg
#> * For info on the priors used see ?prior_summary.stanreg
```

That was easy. 

**But wait, there's more**! Getting predictions for these models is simple and _tidy_. We've been working on coming up with a [standard for model predictions](https://tidymodels.github.io/model-implementation-principles/model-predictions.html) where the predictions always return a tibble that has the same number of rows as the data being predicted. This solves the frustrating issue of having new data with missing predictor values and a `predict()` method that returns predictions for only the complete data. In that case, you have to match up the rows of the original data to the predicted values. 

For regression, basic predictions come back in a column called `.pred`:


```r
predict(lm_fit, car_test)
```

```
#> # A tibble: 8 x 1
#>   .pred
#>   <dbl>
#> 1  17.5
#> 2  17.7
#> 3  11.0
#> 4  13.2
#> 5  13.2
#> 6  10.9
#> 7  31.9
#> 8  24.9
```

```r
predict(stan_fit, car_test)
```

```
#> # A tibble: 8 x 1
#>   .pred
#>   <dbl>
#> 1  17.4
#> 2  17.9
#> 3  11.6
#> 4  13.6
#> 5  13.6
#> 6  10.9
#> 7  31.5
#> 8  24.9
```

This can be easily joined to the original data and the `.` in the name is there to prevent duplicate name conflicts. 

`parsnip` also enables different types of predictions with a standard interface. To get interval estimates:



```r
predict(lm_fit, car_test, type = "conf_int")
```

```
#> # A tibble: 8 x 2
#>   .pred_lower .pred_upper
#>         <dbl>       <dbl>
#> 1       14.1         21.0
#> 2       11.6         23.8
#> 3        3.57        18.3
#> 4        7.41        18.9
#> 5        7.15        19.3
#> 6        6.39        15.5
#> 7       23.2         40.7
#> 8       19.0         30.9
```

```r
# Not really a confidence interval but gives quantiles of 
# the posterior distribution of the fitted values. 
predict(stan_fit, car_test, type = "conf_int")
```

```
#> # A tibble: 8 x 2
#>   .pred_lower .pred_upper
#>         <dbl>       <dbl>
#> 1       14.0         20.7
#> 2       12.0         23.9
#> 3        5.03        18.4
#> 4        8.37        18.9
#> 5        8.17        19.3
#> 6        6.38        15.4
#> 7       23.1         39.6
#> 8       19.1         30.8
```

As one might expect, the code to obtain these values using the original packages are very different from one another. `parsnip` works to make the interface easy. A mapping between the available models and their prediction types is [here](https://tidymodels.github.io/parsnip/articles/articles/Models.html).  

# Standardized Arguments

Now let's look at estimating this model using an L2 penalty (a.k.a weight decay, a.k.a ridge regression). There are a few ways of doing this. `glmnet` is an obvious choice. While we don't have to declare the size of the penalty at the time of model fitting, we'll do so below for illustration. 


```r
x_mat <- 
  car_train %>% 
  select(-mpg) %>%
  as.matrix()

glmnet(x = x_mat, y = car_train$mpg, alpha = 0, lambda = 0.1)
```

`alpha = 0` tells `glmnet` to only use an L2 penalty (as opposed to L1  and L2). 


For `keras`, [possible syntax](https://keras.rstudio.com/articles/tutorial_basic_regression.html) could be:


```r
lr_model <- keras_model_sequential() 
lr_model %>% 
  layer_dense(units = 1, input_shape = dim(x_mat)[2], activation = 'linear',
              kernel_regularizer = regularizer_l2(0.1)) 
  
early_stopping <- callback_early_stopping(monitor = 'loss', min_delta = 0.000001)

lr_model %>% compile(
  loss = 'mean_squared_error',
  optimizer = optimizer_adam(lr = 0.001)
)

lr_model %>%
  fit(
    x = x_mat,
    y = car_train$mpg,
    epochs = 1000,
    batch_size = 1,
    callbacks = early_stopping
  )
```

This is very powerful but maybe it's not something that you want to have to type more than once. 

`parsnip` model functions, like `linear_reg()`, can also have _main arguments_ that are standardized and avoid jargon like `lambda` or `kernel_regularizer`. Here, a model specification would be:


```r
penalized <- linear_reg(mixture = 0, penalty = 0.1)
penalized
```

```
#> Linear Regression Model Specification (regression)
#> 
#> Main Arguments:
#>   penalty = 0.1
#>   mixture = 0
```

`penalty` is the amount of regularization penalty that we want to use. `mixture` is only used for models like `glmnet` that can fit different types of penalties, and is the proportion of the penalty that corresponds to weight decay (in other words, `alpha` from above). 

From here, the `glmnet` model would be:


```r
glmn_fit <-
  penalized %>%
  set_engine("glmnet") %>%
  fit(mpg ~ ., data = car_train)
glmn_fit
```

```
#> parsnip model object
#> 
#> 
#> Call:  glmnet::glmnet(x = as.matrix(x), y = y, family = "gaussian",      alpha = ~0, lambda = ~0.1) 
#> 
#>      Df  %Dev Lambda
#> [1,] 10 0.854    0.1
```

For `keras`, we can add the other options (unrelated to the penalty) via `set_engine()`:


```r
early_stopping <- callback_early_stopping(monitor = 'loss', min_delta = 0.000001)

keras_fit <-
  penalized %>%
  set_engine("keras", epochs = 1000, batch_size = 1, callbacks = !!early_stopping) %>%
  fit(mpg ~ ., data = car_train, control = ctrl)
keras_fit
```

```
#> parsnip model object
#> 
#> Model
#> ___________________________________________________________________________
#> Layer (type)                     Output Shape                  Param #     
#> ===========================================================================
#> dense_1 (Dense)                  (None, 1)                     11          
#> ___________________________________________________________________________
#> dense_2 (Dense)                  (None, 1)                     2           
#> ===========================================================================
#> Total params: 13
#> Trainable params: 13
#> Non-trainable params: 0
#> ___________________________________________________________________________
```

The main arguments are standardized in `parsnip`, so that `logistic_reg()` and other functions use the same name, and are being standardized in other packages like [`recipes`](https://tidymodels.github.io/recipes/) and [`dials`](https://tidymodels.github.io/dials/). 

# What parsnip is and what it isn't

Other packages, such as [`caret`](https://topepo.github.io/caret/) and `mlr`, help to solve the R model API issue. These packages do a lot of other things too: preprocessing, model tuning, resampling, feature selection, ensembling, and so on. In the tidyverse, we strive to make our packages modular and `parsnip` is designed _only_ to solve the interface issue. It is **not** designed to be a drop-in replacement for [`caret`](https://topepo.github.io/caret/). 

The [`tidymodels` package collection](https://github.com/tidymodels), which includes `parsnip`, has other packages for many of these tasks, and they are designed to work together. We are working towards higher-level APIs that can replicate and extend what the current model packages can do. 

For example, `fit()` and `fit_xy()` do not involve recipes. It might seem natural to include a recipe interface like `caret` does (and, originally, `parsnip` did). The reason that recipes are excluded from fitting `parsnip` objects is that you probably want to process the recipe _once_ and use it across different models. To include it would link that specific recipe to _each_ fitted model object. 

As an alternative, we are working on a different object type that is similar to existing pipelines where a set of modeling activities can be woven together to represent the entire **modeling process**. To get an idea of the activities that we have in store for tidy modeling, look [here](https://github.com/orgs/tidymodels/projects).  

# What's next

Subsequent blog posts on `parsnip` will talk about the underlying architecture and choices that we made along the line (and why). We'll also talk more about how `parsnip` integrates with other `tidymodels` packages, how quasiquotation can/should be used, and some other features that are [particularly interesting](https://tidymodels.github.io/parsnip/reference/descriptors.html) to us. 
 
