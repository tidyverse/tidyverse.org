---
output: hugodown::hugo_document

slug: finetune-0-0-1
title: finetune 0.0.1
date: 2020-12-02
author: Max Kuhn
description: >
    finetune is a new package that adds a few more model tuning methods. 

photo:
  url: https://unsplash.com/photos/nQYqEwimp5o
  author: Rob Wingate

categories: [package] 
tags: [tidymodels,finetune,tune]
---

<!--
TODO:
* [ ] Pick category and tags (see existing with `post_tags()`)
* [ ] Find photo & update yaml metadata
* [ ] Create `thumbnail-sq.jpg`; height and width should be equal
* [ ] Create `thumbnail-wd.jpg`; width should be >5x height
* [ ] `hugodown::use_tidy_thumbnail()`
* [ ] Add intro sentence
* [ ] `use_tidy_thanks()`
-->

We're thrilled to announce the first release of the [finetune](https://finetune.tidymodels.org/) package. finetune adds two additional approaches for model tuning.  

You can install it from CRAN with:


```r
install.packages("finetune")
```

This blog post will describe the two new tools in the package. 

## Racing

Tuning parameters are unknown quantities of a model that cannot be directly estimated from the data. The number of neighbors in a K nearest neighbor model is a good example. 

Grid search is a common method to find good values for model tuning parameters. A pre-defined set of parameters are created and often resampled so that good estimates of model performance are available. The user then choses a tuning parameter value that has acceptable results. 

The problem with this approach is that it requires all of the results to be able to make a decision. For example, if we evaluate 50 tuning parameter values on 10 resamples, 500 model fits are evaluated before any analysis of the results takes place. 

Racing methods, devised by [Maron and Moore (1994)](https://scholar.google.com/scholar?hl=en&as_sdt=0%2C7&q=Hoeffding+races%3A+Accelerating+model+selection+search+for+classification+and+function+approximation&btnG=), enables a sequential type of grid search. All model parameters are evaluated on a few resamples. Racing methods analyze the initial results to determine if any of the tuning parameters are unacceptable enough to discard. If the analysis discards any parameters, they are not resampled further. This process can considerably reduce the total number of model evaluations. finetune has functions `tune_race_anova()` and `tune_race_win_loss()` for this purpose (with syntax similar to `tune_grid()`). Their analysis details are described in [Kuhn (2014)](https://arxiv.org/abs/1405.6974).   

As an example, we'll tune a K nearest neighbor (KNN) model on the sonar data.  The grid will consist of 20 tuning parameters values in conjunction with 25 bootstrap resamples.  


```r
library(tidymodels)
library(finetune)
library(mlbench)
data(Sonar)

# create resamples
set.seed(100)
resamp <- bootstraps(Sonar)

# create a model specification
model <- 
  nearest_neighbor(neighbors = tune(), weight_func = tune(), 
                   dist_power = tune()) %>% 
  set_engine("kknn") %>% 
  set_mode("classification")

# center and scale the data using a recipe
norm_rec <- recipe(Class ~ ., data = Sonar) %>% 
  step_normalize(all_predictors())

ctrl <- control_race(verbose_elim = TRUE)

set.seed(101)
sonar_race <- 
  model %>% 
  tune_race_anova(norm_rec, resamples = resamp, grid = 20, control = ctrl)
```
```
## ℹ Racing will maximize the roc_auc metric.
## ℹ Resamples are analyzed in a random order.
## ℹ Bootstrap23:  9 eliminated; 11 candidates remain.
## ℹ Bootstrap18:  4 eliminated;  7 candidates remain.
## ℹ Bootstrap05:  1 eliminated;  6 candidates remain.
## ℹ Bootstrap06:  0 eliminated;  6 candidates remain. 
## ℹ Bootstrap08:  1 eliminated;  5 candidates remain.
## ℹ Bootstrap01:  0 eliminated;  5 candidates remain.
## ℹ Bootstrap19:  0 eliminated;  5 candidates remain.
## ℹ Bootstrap15:  0 eliminated;  5 candidates remain.
## ℹ Bootstrap10:  0 eliminated;  5 candidates remain.
## ℹ Bootstrap07:  0 eliminated;  5 candidates remain.
## ℹ Bootstrap16:  2 eliminated;  3 candidates remain.
## ℹ Bootstrap09:  0 eliminated;  3 candidates remain.
## ℹ Bootstrap04:  0 eliminated;  3 candidates remain.
## ℹ Bootstrap24:  0 eliminated;  3 candidates remain.
## ℹ Bootstrap21:  0 eliminated;  3 candidates remain.
## ℹ Bootstrap12:  0 eliminated;  3 candidates remain.
## ℹ Bootstrap03:  0 eliminated;  3 candidates remain.
## ℹ Bootstrap13:  0 eliminated;  3 candidates remain.
## ℹ Bootstrap17:  0 eliminated;  3 candidates remain.
## ℹ Bootstrap11:  0 eliminated;  3 candidates remain.
## ℹ Bootstrap25:  0 eliminated;  3 candidates remain.
## ℹ Bootstrap14:  0 eliminated;  3 candidates remain.
```



```r
show_best(sonar_race, metric = "roc_auc")
```

```
## # A tibble: 3 x 9
##   neighbors weight_func dist_power .metric .estimator  mean     n std_err
##       <int> <chr>            <dbl> <chr>   <chr>      <dbl> <int>   <dbl>
## 1        14 triweight        0.902 roc_auc binary     0.938    25 0.00647
## 2        11 biweight         1.62  roc_auc binary     0.937    25 0.00627
## 3        10 biweight         0.501 roc_auc binary     0.934    25 0.00563
## # … with 1 more variable: .config <chr>
```

Using this approach, we evaluated 156 models (less than half of the full set of 500). The [help file](https://finetune.tidymodels.org/reference/tune_race_anova.html#details) describes how parallel processing can also be used to further speed up the racing process. 

There is also a handy plotting function that demonstrates how models are eliminated in the racing process:


```r
plot_race(sonar_race) + theme_bw()
```

![plot of chunk race](figure/race-1.svg)

Each line corresponds to a tuning parameter combination. Models with suboptimal ROC scores are eliminated quickly. 

## Simulated Annealing

Simulated annealing is an old global search method that does a controlled random walk. In our application, the walk is through the tuning parameter space. finetune uses it as an iterative search method where new tuning parameter values are created during the process (as opposed to a pre-defined grid). The `tune_sim_anneal()` function has syntax that is very similar to the `tune_bayes()` function.

For our KNN model: 


```r
ctrl <- control_sim_anneal(verbose = TRUE)

set.seed(102)
sonar_sa <- 
  model %>% 
  tune_sim_anneal(norm_rec, resamples = resamp, iter = 25, control = ctrl)
```
```
## >  Generating a set of 1 initial parameter results
## ✓ Initialization complete
## 
## Optimizing roc_auc
## Initial best: 0.91295
##  1 ◯ accept suboptimal  roc_auc=0.86702	(+/-0.009415)
##  2 + better suboptimal  roc_auc=0.89481	(+/-0.007461)
##  3 ♥ new best           roc_auc=0.91818	(+/-0.006982)
##  4 ♥ new best           roc_auc=0.93033	(+/-0.006978)
##  5 ♥ new best           roc_auc=0.93181	(+/-0.006744)
##  6 ◯ accept suboptimal  roc_auc=0.87504	(+/-0.009216)
##  7 + better suboptimal  roc_auc=0.8849	(+/-0.00875)
##  8 ♥ new best           roc_auc=0.93647	(+/-0.00611)
##  9 ◯ accept suboptimal  roc_auc=0.92365	(+/-0.006366)
## 10 ─ discard suboptimal roc_auc=0.88774	(+/-0.007586)
## 11 + better suboptimal  roc_auc=0.92405	(+/-0.006807)
## 12 ◯ accept suboptimal  roc_auc=0.92211	(+/-0.006764)
## 13 + better suboptimal  roc_auc=0.9297	(+/-0.006814)
## 14 ─ discard suboptimal roc_auc=0.86171	(+/-0.008326)
## 15 ─ discard suboptimal roc_auc=0.88501	(+/-0.007397)
## 16 x restart from best  roc_auc=0.92734	(+/-0.006484)
## 17 ◯ accept suboptimal  roc_auc=0.93554	(+/-0.006326)
## 18 ◯ accept suboptimal  roc_auc=0.92682	(+/-0.006275)
## 19 + better suboptimal  roc_auc=0.93057	(+/-0.006371)
## 20 ♥ new best           roc_auc=0.94017	(+/-0.006516)
## 21 ◯ accept suboptimal  roc_auc=0.92589	(+/-0.006573)
## 22 + better suboptimal  roc_auc=0.92809	(+/-0.006609)
## 23 + better suboptimal  roc_auc=0.93439	(+/-0.006754)
## 24 ◯ accept suboptimal  roc_auc=0.9314	(+/-0.00656)
## 25 ◯ accept suboptimal  roc_auc=0.93076	(+/-0.007003)
```


```r
show_best(sonar_sa, metric = "roc_auc")
```

```
## # A tibble: 5 x 10
##   neighbors weight_func dist_power .metric .estimator  mean     n std_err
##       <int> <chr>            <dbl> <chr>   <chr>      <dbl> <int>   <dbl>
## 1        10 triweight         1.50 roc_auc binary     0.940    25 0.00652
## 2        11 biweight          1.78 roc_auc binary     0.936    25 0.00611
## 3        10 biweight          1.92 roc_auc binary     0.936    25 0.00633
## 4         8 triweight         1.32 roc_auc binary     0.934    25 0.00675
## 5         7 cos               1.59 roc_auc binary     0.932    25 0.00674
## # … with 2 more variables: .config <chr>, .iter <int>
```

```r
autoplot(sonar_sa, type = "performance", metric = "roc_auc") + theme_bw()
```

![plot of chunk sa-best](figure/sa-best-1.svg)

We'll have more information on both these methods in a next release of chapters for [_Tidy Modeling with R_](https://www.tmwr.org/). 
