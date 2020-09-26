---
output: hugodown::hugo_document

slug: usemodels-0-0-1
title: usemodels 0-0-1
date: 2020-09-29
author: Max Kuhn
description: >
    The new usemodels R package is a helpful way to automatically generate 
    tidymodels code. 

photo:
  url: https://unsplash.com/photos/0TH1H1rq_eY
  author: Neven Krcmarek

categories: [package] 
tags: [tidymodels,parsnip,recipes,tune]
---



We're very excited to announce the first release of the [usemodels](https://usemodels.tidymodels.org/) package. usemodels creates templates for tidymodels analyses so you don't have to write as much new code. 

You can install it from CRAN with:


```r
install.packages("usemodels")
```

This blog post will show how to use the package. 

Let's start with something simple: creating a glmnet linear regression model for the `mtcars` data using tidymodels. This model typical is tuned over the amount and type of regularization. In tidymodels, there are a few intermediate steps to do this: 

 * Create a [`parsnip` model object](https://www.tmwr.org/models.html) and define the tuning parameters that we want to optimize. 
 
 * [Create a recipe](https://www.tmwr.org/recipes.html) that, at minimum, centers and scales the predictors. For some data sets, we also need to create dummy variables from any factor-encoded predictor columns. 
 
 * Define a [resampling scheme](https://www.tmwr.org/resampling.html) for our data. 
 
 * Use a function from the [tune package](https://tune.tidymodels.org/), such as `tune_grid()`, to optimize the parameters. For grid search, we'll also need some specification for the grid of candidate parameter values. 
 
We recognize that this might be more code than you would have had to write compared to a package like `caret`. However, the tidymodels ecosystem enables a wider variety of modeling techniques. 

usemodels automates much of this code infrastructure. For example: 


```r
> library(usemodels)
> use_glmnet(mpg ~ ., data = mtcars)
```
 
which produces the terminal output:


```
glmnet_recipe <- 
  recipe(formula = mpg ~ ., data = mtcars) %>% 
  step_zv(all_predictors()) %>% 
  step_normalize(all_predictors(), -all_nominal()) 

glmnet_spec <- 
  linear_reg(penalty = tune(), mixture = tune()) %>% 
  set_mode("regression") %>% 
  set_engine("glmnet") 

glmnet_workflow <- 
  workflow() %>% 
  add_recipe(glmnet_recipe) %>% 
  add_model(glmnet_spec) 

glmnet_grid <- tidyr::crossing(penalty = 10^seq(-6, -1, length.out = 20), mixture = c(0.05, 
    0.2, 0.4, 0.6, 0.8, 1)) 

glmnet_tune <- 
  tune_grid(glmnet_workflow, resamples = stop("add your rsample object"), grid = glmnet_grid) 
```
 
This can be copied to the source window and edited. Some notes: 

 * For this model, it is possible to prescribe a default grid of candidate tuning parameter values that  work well about 90% of time. For other models, the grid might be data-driven and our functions estimate an appropriate tuning grid. 
 
 * The extra recipes steps are the [recommend preprocessing](https://www.tmwr.org/pre-proc-table.html) for this model. Since this varies from model-to-model, the recipe has the minimal required steps. 
 
 * One thing that _should not be automated_ is the choice of resampling method. The code templates require the user to choose the `rsample` function that is appropriate. 
 
In case you are unfamiliar with the model and its preprocessing needs, a `verbose` option prints comments that explain _why_ some steps are included. For the glmnet model, the comments added to the recipe state: 

> Regularization methods sum up functions of the model slope coefficients. Because of this, the predictor variables should be on the same scale. Before centering and scaling the numeric predictors, any predictors with a single unique value are filtered out. 

Let's look at another example. The `ad_data` data set in the modeldata package has rows for 333 patients with a factor outcome for their level of cognitive impairment (e.g., Alzheimer's disease). There are also categorical predictors in the data. One important predictor is the Apolipoprotein E genotype, which has six levels. Let's suppose the `Genotype` column was encoded as character (instead of being a factor). This might be a problem if the resampling method excludes a level from the model fitting data set. 

Let's use a boosted tree model with the xgboost package and change the default prefix for the objects:


```r
> library(tidymodels)
> data(ad_data)
> 
> ad_data$Genotype <- as.character(ad_data$Genotype)
> 
> use_xgboost(Class ~ ., data = ad_data, prefix = "impairment")
```

```
impairment_recipe <- 
  recipe(formula = Class ~ ., data = ad_data) %>% 
  step_string2factor(one_of(Genotype)) %>% 
  step_novel(all_nominal(), -all_outcomes()) %>% 
  step_dummy(all_nominal(), -all_outcomes(), one_hot = TRUE) %>% 
  step_zv(all_predictors()) 

impairment_spec <- 
  boost_tree(trees = tune(), min_n = tune(), tree_depth = tune(), learn_rate = tune(), 
    loss_reduction = tune(), sample_size = tune()) %>% 
  set_mode("classification") %>% 
  set_engine("xgboost") 

impairment_workflow <- 
  workflow() %>% 
  add_recipe(impairment_recipe) %>% 
  add_model(impairment_spec) 

set.seed(17609)
impairment_tune <-
  tune_grid(impairment_workflow, resamples = stop("add your rsample object"), 
    grid = stop("add number of candidate points"))
```

Notice that the line

```
step_string2factor(one_of(Genotype)) 
```

is included in the recipe along with a step to generate one-hot encoded dummy variables. Also, for this particular model, we recommend using a [space-filling design](https://scholar.google.com/scholar?hl=en&as_sdt=0%2C7&q=space+filling+design+of+experiments) for the grid but the user must choose the number of grid points. 

The current set of templates included in the inaugural version of the package are: 


```r
ls("package:usemodels", pattern = "^use_")
```

```
## [1] "use_earth"   "use_glmnet"  "use_kknn"    "use_ranger"  "use_xgboost"
```

We'll likely add more but please file [an issue](https://github.com/tidymodels/usemodels/issues) if there are any that you see as a priority. 
