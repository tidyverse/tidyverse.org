---
output: hugodown::hugo_document

slug: tidymodels-2021-q2
title: Q2 2021 tidymodels digest
date: 2021-07-02
author: Julia Silge
description: >
    Releases of tidymodels packages in Q2 of 2021 include more streamlined
    memory footprints for feature-engineering recipes, new model engine options,
    and better support for post-processing predictions.

photo:
  url: https://unsplash.com/photos/UsZNiW6LyQ0
  author: SHOT

# one of: "deep-dive", "learn", "package", "programming", or "other"
categories: [roundup] 
tags: [tidymodels, parsnip, recipes, butcher, yardstick, probably]
---


The [tidymodels](https://www.tidymodels.org/) framework is a collection of R packages for modeling and machine learning using tidyverse principles. Earlier this year, we [started regular updates](https://www.tidyverse.org/blog/2021/03/tidymodels-2021-q1/) here on the tidyverse blog summarizing recent developments in the tidymodels ecosystem. You can check out the [`tidymodels` tag](https://www.tidyverse.org/tags/tidymodels/) to find all tidymodels blog posts here, including those that focus on a single package or more major releases. The purpose of these roundup posts is to keep you informed about any releases you may have missed and useful new functionality as we maintain these packages.

Since our last roundup post, there have been 19 CRAN releases of 15 different packages. That might sound like a lot of change to absorb as a tidymodels user! However, we purposefully write code in small, modular packages that we can release frequently to make models easier to deploy and our software easier to maintain. You can install these updates from CRAN with:


```r
install.packages(c("broom", "butcher", "discrim", "hardhat", "parsnip", "probably", 
                   "recipes", "rsample", "stacks", "themis", "tidymodels", 
                   "tidyposterior", "tune", "workflowsets", "yardstick"))
```

The `NEWS` files are linked here for each package; you'll notice that many of these releases involve small bug fixes or internal changes that are not user-facing. It's a lot to keep up with and there are some super useful updates in the mix, so read on for several highlights!

- [broom](https://broom.tidymodels.org/news/index.html#broom-0-7-8-2021-06-24)
- [butcher](https://butcher.tidymodels.org/news/index.html#butcher-0-1-4-2021-03-19)
- [discrim](https://discrim.tidymodels.org/news/index.html#discrim-0-1-2-2021-05-28)
- [hardhat](https://hardhat.tidymodels.org/news/index.html#hardhat-0-1-4-2020-07-02)
- [parsnip](https://parsnip.tidymodels.org/news/index.html#parsnip-0-1-6-2021-05-27)
- [probably](https://probably.tidymodels.org/news/index.html#probably-0-0-6-2020-06-05)
- [recipes](https://recipes.tidymodels.org/news/index.html#recipes-0-1-16-2021-04-16)
- [rsample](https://rsample.tidymodels.org/news/index.html#rsample-0-1-0-2021-05-08)
- [stacks](https://github.com/tidymodels/stacks/blob/main/NEWS.md#v020)
- [themis](https://themis.tidymodels.org/dev/news/index.html#themis-0-1-4-2021-06-12)
- [tidymodels](https://tidymodels.tidymodels.org/news/index.html#tidymodels-0-1-3-2021-04-19)
- [tidyposterior](https://github.com/tidymodels/tidyposterior/blob/master/NEWS.md#tidyposterior-010)
- [tune](https://tune.tidymodels.org/news/index.html#tune-0-1-5-2021-04-23)
- [workflowsets](https://workflowsets.tidymodels.org/news/index.html#workflowsets-0-0-2-2021-04-16)
- [yardstick](https://yardstick.tidymodels.org/news/index.html#yardstick-0-0-8-2021-03-28)


## Reduce the memory footprint of your recipes

The [butcher](https://butcher.tidymodels.org/) package provides methods to remove (or "axe") components from model objects that are not needed for prediction. The most recent release updated how butcher handles _recipes_ (the tidymodels approach for preprocessing and feature engineering) for more complete and robust coverage. Let's consider a simulated churn-classification dataset for phone company customers:


```r
library(tidymodels)
library(butcher)
data("mlc_churn")

set.seed(123)
churn_split <- initial_split(mlc_churn)
churn_train <- training(churn_split)
churn_test  <- testing(churn_split)

ggplot(churn_train, aes(y = voice_mail_plan, fill = churn)) +
  geom_bar(alpha = 0.8, position = "fill") +
  scale_x_continuous(labels = scales::percent_format()) +
  labs(x = NULL)
```

![plot of chunk unnamed-chunk-3](figure/unnamed-chunk-3-1.png)

For some kinds of models, we would want to create dummy or indicator variables from nominal predictors, and preprocess features to be on the same scale. We can use recipes for this task:


```r
churn_rec <- 
  recipe(churn ~ voice_mail_plan + total_intl_minutes + 
           total_day_minutes + total_eve_minutes + state, 
         data = churn_train) %>%
  step_dummy(all_nominal_predictors()) %>%
  step_normalize(all_predictors())
```

You can `prep(churn_rec)` to estimate the quantities needed to create categorical features and to scale all the predictors:


```r
churn_prep <- prep(churn_rec)
churn_prep
#> Data Recipe
#> 
#> Inputs:
#> 
#>       role #variables
#>    outcome          1
#>  predictor          5
#> 
#> Training data contained 3750 data points and no missing data.
#> 
#> Operations:
#> 
#> Dummy variables from voice_mail_plan, state [trained]
#> Centering and scaling for total_intl_minutes, total_day_minutes, ... [trained]
```

To remove everything from this prepped recipe not needed for applying to new data (e.g. [bake()](https://recipes.tidymodels.org/reference/bake.html) it), we can call `butcher(churn_prep)`. In some applications, modeling practitioners need to make custom functions with a feature-engineering recipe. Sometimes those functions have... a lot of extra STUFF in them, stuff that is not needed for prediction.


```r
butchered_plus <- function() {
  some_stuff_in_the_environment <- runif(1e6)
  
  churn_prep <- 
    recipe(churn ~ voice_mail_plan + total_intl_minutes + 
             total_day_minutes + total_eve_minutes + state, 
           data = churn_train) %>%
    step_dummy(all_nominal_predictors()) %>%
    step_normalize(all_predictors()) %>%
    prep()
  
  butcher(churn_prep)
}
```

In the old version of butcher, we did not successfully remove all that extra stuff, and recipes were bigger than they needed to be:


```r
# old version of butcher
lobstr::obj_size(butcher(churn_prep))
#> 1,835,512 B
lobstr::obj_size(butchered_plus())
#> 9,836,480 B
```

In the new version of butcher, we now successfully remove unneeded components from the recipe, so it is smaller:


```r
# new version of butcher
lobstr::obj_size(butcher(churn_prep))
#> 1,695,352 B
lobstr::obj_size(butchered_plus())
#> 1,695,352 B
```

There are also `butcher()` methods for `workflow()` objects, so when you `butcher()` a modeling workflow, you remove everything not needed for prediction from both its estimated recipe *and* its trained model, making it as lightweight as possible for deployment.

## SVMs and fast logistic regression with LiblineaR

Unfortunately, the `"liquidSVM"` engine for support vector machine models that parsnip supported was deprecated in the latest release, because that package was removed from CRAN. We added a new engine in the same release that allows users to fit linear SVMs with the [parsnip model `svm_linear()`](https://parsnip.tidymodels.org/reference/svm_linear.html), as well as having another option for logistic regression. This new `"LiblineaR"` engine is based on the same C++ library that is shipped with [scikit-learn](https://scikit-learn.org/). We'd like to thank the [maintainers of the LiblineaR R package](https://www.dnalytics.com/software/liblinear/) for all their help as we set up this integration.


```r
set.seed(234)
churn_folds <- vfold_cv(churn_train, v = 5, strata = churn)

liblinear_spec <-
  logistic_reg(penalty = 0.2, mixture = 1) %>%
  set_mode("classification") %>%
  set_engine("LiblineaR")

liblinear_wf <-
  workflow() %>%
  add_recipe(churn_rec) %>%
  add_model(liblinear_spec)

fit_resamples(liblinear_wf, resamples = churn_folds)
#> # Resampling results
#> # 5-fold cross-validation using stratification 
#> # A tibble: 5 x 4
#>   splits             id    .metrics         .notes          
#>   <list>             <chr> <list>           <list>          
#> 1 <split [2999/751]> Fold1 <tibble [2 × 4]> <tibble [0 × 1]>
#> 2 <split [2999/751]> Fold2 <tibble [2 × 4]> <tibble [0 × 1]>
#> 3 <split [3000/750]> Fold3 <tibble [2 × 4]> <tibble [0 × 1]>
#> 4 <split [3001/749]> Fold4 <tibble [2 × 4]> <tibble [0 × 1]>
#> 5 <split [3001/749]> Fold5 <tibble [2 × 4]> <tibble [0 × 1]>
```

The `"LiblineaR"` engine for regularized logistic regression [can be very fast compared to the `"glmnet"` engine](https://twitter.com/juliasilge/status/1374029310764359681), even when we use a [sparse representation](https://www.tidyverse.org/blog/2020/11/tidymodels-sparse-support/). Check out [benchmarking code here](https://gist.github.com/juliasilge/26a43e5e68cf12842354e6652dfed688).

## Post-processing your model predictions with probably and yardstick

We recently had releases of both the [yardstick](https://yardstick.tidymodels.org/) and [probably](https://probably.tidymodels.org/) packages, which now work together even better. The probably package can, among other things, help you post-process your model predictions. This data on churn is imbalanced, with many more customers who did not churn than those who did; we may need to use a threshold other than 0.5 for most appropriate results, or an organization may want to set a specific threshold for some action to prevent churn. You can set a threshold using the [probably function `make_two_class_pred()`](https://probably.tidymodels.org/reference/make_class_pred.html).


```r
library(probably)

set.seed(123)
churn_preds <- 
  liblinear_wf %>%
  fit(churn_train) %>%
  augment(churn_test)

churn_post <- 
  churn_preds %>%
  mutate(.pred = make_two_class_pred(.pred_yes, levels(churn), threshold = 0.7))
```

The class predictions created with probably integrate well with functions from yardstick, including custom sets of metrics created with [`metric_set()`](https://yardstick.tidymodels.org/reference/metric_set.html).


```r
churn_metrics <- metric_set(accuracy, sens, spec)

churn_post %>% churn_metrics(truth = churn, estimate = .pred_class)
#> # A tibble: 3 x 3
#>   .metric  .estimator .estimate
#>   <chr>    <chr>          <dbl>
#> 1 accuracy binary        0.854 
#> 2 sens     binary        0.0619
#> 3 spec     binary        0.999
churn_post %>% churn_metrics(truth = churn, estimate = .pred)
#> # A tibble: 3 x 3
#>   .metric  .estimator .estimate
#>   <chr>    <chr>          <dbl>
#> 1 accuracy binary         0.746
#> 2 sens     binary         0.149
#> 3 spec     binary         0.856
```

Notice that with the default threshold of 0.5, basically no customers were classified as at risk for churn! Adjusting the threshold with `make_two_class_pred()` helps to address this issue.

## Acknowledgements

We'd like to extend our thanks to all of the contributors who helped make these releases during Q2 possible!

- broom: [&#x0040;alexpghayes](https://github.com/alexpghayes), [&#x0040;andrewsris](https://github.com/andrewsris), [&#x0040;arcruz0](https://github.com/arcruz0), [&#x0040;bbolker](https://github.com/bbolker), [&#x0040;bgall](https://github.com/bgall), [&#x0040;cccneto](https://github.com/cccneto), [&#x0040;ddsjoberg](https://github.com/ddsjoberg), [&#x0040;DerForscher107](https://github.com/DerForscher107), [&#x0040;dikiprawisuda](https://github.com/dikiprawisuda), [&#x0040;dmenne](https://github.com/dmenne), [&#x0040;grantmcdermott](https://github.com/grantmcdermott), [&#x0040;japhir](https://github.com/japhir), [&#x0040;karldw](https://github.com/karldw), [&#x0040;kelseygonzalez](https://github.com/kelseygonzalez), [&#x0040;leejasme](https://github.com/leejasme), [&#x0040;LukasWallrich](https://github.com/LukasWallrich), [&#x0040;MatthieuStigler](https://github.com/MatthieuStigler), [&#x0040;mbac](https://github.com/mbac), [&#x0040;nt-williams](https://github.com/nt-williams), [&#x0040;pachadotdev](https://github.com/pachadotdev), [&#x0040;rpruim](https://github.com/rpruim), [&#x0040;rsbivand](https://github.com/rsbivand), [&#x0040;simonpcouch](https://github.com/simonpcouch), and [&#x0040;vincentarelbundock](https://github.com/vincentarelbundock).

- butcher: [&#x0040;bshor](https://github.com/bshor), [&#x0040;DavisVaughan](https://github.com/DavisVaughan), [&#x0040;juliasilge](https://github.com/juliasilge), and [&#x0040;lbenz-mdsol](https://github.com/lbenz-mdsol).

- discrim: [&#x0040;juliasilge](https://github.com/juliasilge), and [&#x0040;topepo](https://github.com/topepo).

- hardhat: [&#x0040;DavisVaughan](https://github.com/DavisVaughan), and [&#x0040;topepo](https://github.com/topepo).

- parsnip: [&#x0040;brshallo](https://github.com/brshallo), [&#x0040;cgoo4](https://github.com/cgoo4), [&#x0040;DavisVaughan](https://github.com/DavisVaughan), [&#x0040;dgrtwo](https://github.com/dgrtwo), [&#x0040;EmilHvitfeldt](https://github.com/EmilHvitfeldt), [&#x0040;graysonwhite](https://github.com/graysonwhite), [&#x0040;hfrick](https://github.com/hfrick), [&#x0040;hsbadr](https://github.com/hsbadr), [&#x0040;joeycouse](https://github.com/joeycouse), [&#x0040;jtlandis](https://github.com/jtlandis), [&#x0040;juliasilge](https://github.com/juliasilge), [&#x0040;klin333](https://github.com/klin333), [&#x0040;mdancho84](https://github.com/mdancho84), [&#x0040;paulponcet](https://github.com/paulponcet), [&#x0040;pfc5098](https://github.com/pfc5098), [&#x0040;RaymondBalise](https://github.com/RaymondBalise), [&#x0040;smingerson](https://github.com/smingerson), [&#x0040;topepo](https://github.com/topepo), [&#x0040;UnclAlDeveloper](https://github.com/UnclAlDeveloper), and [&#x0040;vadimus202](https://github.com/vadimus202).

- probably: [&#x0040;hsbadr](https://github.com/hsbadr), and [&#x0040;juliasilge](https://github.com/juliasilge).

- recipes: [&#x0040;AlbertRapp](https://github.com/AlbertRapp), [&#x0040;asmae-toumi](https://github.com/asmae-toumi), [&#x0040;atusy](https://github.com/atusy), [&#x0040;christiantillich](https://github.com/christiantillich), [&#x0040;EdwinTh](https://github.com/EdwinTh), [&#x0040;EmilHvitfeldt](https://github.com/EmilHvitfeldt), [&#x0040;hfrick](https://github.com/hfrick), [&#x0040;jake-mason](https://github.com/jake-mason), [&#x0040;jkennel](https://github.com/jkennel), [&#x0040;jtlandis](https://github.com/jtlandis), [&#x0040;juliasilge](https://github.com/juliasilge), [&#x0040;LiamBlake](https://github.com/LiamBlake), [&#x0040;lindeloev](https://github.com/lindeloev), [&#x0040;mikemc](https://github.com/mikemc), [&#x0040;mrkaye97](https://github.com/mrkaye97), [&#x0040;renanxcortes](https://github.com/renanxcortes), [&#x0040;schoonees](https://github.com/schoonees), [&#x0040;SlowMo24](https://github.com/SlowMo24), [&#x0040;smingerson](https://github.com/smingerson), and [&#x0040;topepo](https://github.com/topepo).

- rsample: [&#x0040;brian-j-smith](https://github.com/brian-j-smith), [&#x0040;EmilHvitfeldt](https://github.com/EmilHvitfeldt), [&#x0040;hfrick](https://github.com/hfrick), [&#x0040;juliasilge](https://github.com/juliasilge), [&#x0040;LiamBlake](https://github.com/LiamBlake), [&#x0040;mattwarkentin](https://github.com/mattwarkentin), [&#x0040;PathosEthosLogos](https://github.com/PathosEthosLogos), [&#x0040;rkb965](https://github.com/rkb965), and [&#x0040;supermdat](https://github.com/supermdat).

- stacks: [&#x0040;asmae-toumi](https://github.com/asmae-toumi), [&#x0040;Crisel12](https://github.com/Crisel12), [&#x0040;simonpcouch](https://github.com/simonpcouch), and [&#x0040;topepo](https://github.com/topepo).

- themis: [&#x0040;EmilHvitfeldt](https://github.com/EmilHvitfeldt), [&#x0040;kylegilde](https://github.com/kylegilde), and [&#x0040;topepo](https://github.com/topepo).

- tidymodels: [&#x0040;dmenne](https://github.com/dmenne), [&#x0040;Edward-Egros](https://github.com/Edward-Egros), [&#x0040;juliasilge](https://github.com/juliasilge), [&#x0040;PathosEthosLogos](https://github.com/PathosEthosLogos), [&#x0040;topepo](https://github.com/topepo), and [&#x0040;verajosemanuel](https://github.com/verajosemanuel).

- tidyposterior: [&#x0040;juliasilge](https://github.com/juliasilge), and [&#x0040;topepo](https://github.com/topepo).

- tune: [&#x0040;albert-ying](https://github.com/albert-ying), [&#x0040;amazongodman](https://github.com/amazongodman), [&#x0040;brshallo](https://github.com/brshallo), [&#x0040;dpanyard](https://github.com/dpanyard), [&#x0040;EmilHvitfeldt](https://github.com/EmilHvitfeldt), [&#x0040;juliasilge](https://github.com/juliasilge), [&#x0040;klin333](https://github.com/klin333), [&#x0040;mbac](https://github.com/mbac), [&#x0040;PathosEthosLogos](https://github.com/PathosEthosLogos), [&#x0040;silvanhi](https://github.com/silvanhi), [&#x0040;smingerson](https://github.com/smingerson), [&#x0040;topepo](https://github.com/topepo), and [&#x0040;yogat3ch](https://github.com/yogat3ch).

- workflowsets: [&#x0040;amazongodman](https://github.com/amazongodman), [&#x0040;DavisVaughan](https://github.com/DavisVaughan), [&#x0040;gunnergalactico](https://github.com/gunnergalactico), [&#x0040;hnagaty](https://github.com/hnagaty), [&#x0040;jonthegeek](https://github.com/jonthegeek), [&#x0040;juliasilge](https://github.com/juliasilge), [&#x0040;mdancho84](https://github.com/mdancho84), [&#x0040;oskasf](https://github.com/oskasf), [&#x0040;rafzamb](https://github.com/rafzamb), [&#x0040;topepo](https://github.com/topepo), and [&#x0040;yogat3ch](https://github.com/yogat3ch).

- yardstick: [&#x0040;brshallo](https://github.com/brshallo), [&#x0040;coletl](https://github.com/coletl), [&#x0040;datenzauberai](https://github.com/datenzauberai), [&#x0040;DavisVaughan](https://github.com/DavisVaughan), [&#x0040;EmilHvitfeldt](https://github.com/EmilHvitfeldt), [&#x0040;juliasilge](https://github.com/juliasilge), [&#x0040;klin333](https://github.com/klin333), [&#x0040;mattwarkentin](https://github.com/mattwarkentin), [&#x0040;mdancho84](https://github.com/mdancho84), and [&#x0040;topepo](https://github.com/topepo).



