---
output: hugodown::hugo_document

slug: tidymodels-2021-q3
title: "Q3 2021 tidymodels roundup"
date: 2021-09-17
author: Julia Silge
description: >
    A 2-3 sentence description of the post that appears on the articles page.
    This can be omitted if it would just recapitulate the title.

photo:
  url: https://unsplash.com/photos/QA2clzv9E8c
  author: CHUTTERSNAP

# one of: "deep-dive", "learn", "package", "programming", or "other"
categories: [roundup] 
tags: [tidymodels, dials, modeldata]
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

The [tidymodels](https://www.tidymodels.org/) framework is a collection of R packages for modeling and machine learning using tidyverse principles. We now publish [regular updates](https://www.tidyverse.org/categories/roundup/) here on the tidyverse blog summarizing recent developments in the tidymodels ecosystem. You can check out the [`tidymodels` tag](https://www.tidyverse.org/tags/tidymodels/) to find all tidymodels blog posts here, including those that focus on a single package or more major releases. The purpose of these roundup posts is to keep you informed about any releases you may have missed and useful new functionality as we maintain these packages.

Since [our last roundup post](https://www.tidyverse.org/blog/2021/07/tidymodels-july-2021/), there have been 8 CRAN releases of tidymodels packages. You can install these updates from CRAN with:


```r
install.packages(c("baguette", "broom", "dials", "modeldata", 
                   "poissonreg", "rules", "stacks", "textrecipes"))
```

The `NEWS` files are linked here for each package; you'll notice that many of these releases involve small updates for CRAN policy or changes that are not user-facing. We write code in these smaller, modular packages that we can release frequently to make models easier to deploy and our software easier to maintain, but it can be a lot to keep up with as a user! We want to take the opportunity here to highlight a couple of more important changes in these releases.

- [baguette](FIXME)
- [broom](https://broom.tidymodels.org/news/index.html#broom-0-7-9-2021-07-27)
- [dials](https://dials.tidymodels.org/news/index.html#dials-0-0-10-2021-09-10)
- [modeldata](FIXME)
- [poissonreg](https://poissonreg.tidymodels.org/news/index.html#poissonreg-0-1-1-2021-08-07)
- [rules](https://rules.tidymodels.org/news/index.html#rules-0-1-2-2021-08-07)
- [stacks](https://github.com/tidymodels/stacks/blob/main/NEWS.md#v021)
- [textrecipes](https://textrecipes.tidymodels.org/news/index.html#textrecipes-0-4-1-2021-07-11)

## New parameter objects

The [dials](https://dials.tidymodels.org/) package is one that you might not have thought much about yet, even if you are a regular tidymodels user. It is an infrastructure package for creating and managing [hyperparameters](https://www.tmwr.org/tuning.html#tuning-params-tidymodels) as well as grids (both [regular and non-regular](https://www.tmwr.org/grid-search.html#grids)) of hyperparameters. The most recent release of dials includes several new parameters, and [Hannah Frick](https://www.frick.ws/) is now the package maintainer.

One of the new parameters in this release is [`stop_iter()`](https://dials.tidymodels.org/reference/stop_iter.html), the number of iterations without improvement before ["early stopping"](https://en.wikipedia.org/wiki/Early_stopping).


```r
library(tidymodels)
```

```
## Registered S3 method overwritten by 'tune':
##   method                   from   
##   required_pkgs.model_spec parsnip
```

```
## ── Attaching packages ──────────────────────────────────────────────────────────── tidymodels 0.1.3 ──
```

```
## ✓ broom        0.7.9      ✓ recipes      0.1.16
## ✓ dials        0.0.10     ✓ rsample      0.1.0 
## ✓ dplyr        1.0.7      ✓ tibble       3.1.4 
## ✓ ggplot2      3.3.5      ✓ tidyr        1.1.3 
## ✓ infer        1.0.0      ✓ tune         0.1.6 
## ✓ modeldata    0.1.1      ✓ workflows    0.2.3 
## ✓ parsnip      0.1.7      ✓ workflowsets 0.1.0 
## ✓ purrr        0.3.4      ✓ yardstick    0.0.8
```

```
## ── Conflicts ─────────────────────────────────────────────────────────────── tidymodels_conflicts() ──
## x purrr::discard() masks scales::discard()
## x dplyr::filter()  masks stats::filter()
## x dplyr::lag()     masks stats::lag()
## x recipes::step()  masks stats::step()
## • Use tidymodels_prefer() to resolve common conflicts.
```

```r
stop_iter()
```

```
## # Iterations Before Stopping (quantitative)
## Range: [3, 20]
```

You don't typically use parameters from dials like this, though. Instead, the infrastructure these parameters provide is what allows us to fluently tune our hyperparameters. For example, we can use data on high-performance computing jobs to predict the class of those jobs with xgboost, choosing to try out different values for early stopping (along with another hyperparameter `mtry`).


```r
data(hpc_data)
hpc_folds <- vfold_cv(hpc_data, strata = class)
hpc_formula <- class ~ compounds + input_fields + iterations + num_pending + hour

stopping_spec <-
  boost_tree(
    trees = 500,
    learn_rate = 0.02,
    mtry = tune(),
    stop_iter = tune()
  ) %>%
  set_engine("xgboost", validation = 0.2) %>%
  set_mode("classification")

early_stop_wf <- workflow(hpc_formula, stopping_spec)
```

We can now tune this `workflow()` over the resamples `hpc_folds` and find out which values for the hyperparameters turned out best.


```r
doParallel::registerDoParallel()
set.seed(123)
early_stop_rs <- tune_grid(early_stop_wf, hpc_folds)
```

```
## i Creating pre-processing data to finalize unknown parameter: mtry
```

```r
show_best(early_stop_rs, "roc_auc")
```

```
## # A tibble: 5 × 8
##    mtry stop_iter .metric .estimator  mean     n std_err .config              
##   <int>     <int> <chr>   <chr>      <dbl> <int>   <dbl> <chr>                
## 1     3        14 roc_auc hand_till  0.885    10 0.00459 Preprocessor1_Model04
## 2     5         4 roc_auc hand_till  0.885    10 0.00461 Preprocessor1_Model02
## 3     5        18 roc_auc hand_till  0.883    10 0.00512 Preprocessor1_Model05
## 4     2        15 roc_auc hand_till  0.882    10 0.00382 Preprocessor1_Model01
## 5     3        13 roc_auc hand_till  0.882    10 0.00482 Preprocessor1_Model07
```

In this case, the best value for the early stopping parameter is 14.

[This recent screencast demonstrates](https://youtu.be/aXAafzOFyjk) how to tune early stopping for xgboost as well.

Several of the new parameter objects in this version of dials are prep work for supporting more options in tidymodels, such as tuning yet more hyperparameters of xgboost (like L1 and L2 penalties and whether to balance classes), generalized additive models, discriminant analysis models, recursively partitioned models, and a recipe step for sparse PCA. Stay tuned for more on these new options!

## Reexamining example datasets

One of the tidymodels packages is [modeldata](https://modeldata.tidymodels.org/), where we keep example datasets for vignettes, examples, and other similar uses. We have included two datasets, `okc` and `okc_text`, in modeldata based on real user data from the dating website OkCupid.

This dataset was sourced from [Kim and Escobedo-Land (2015)](https://doi.org/10.1080/26939169.2021.1924516). Permission to use this dataset was explicitly granted by OkCupid, but since that time, concerns have been raised about the ethics of using this or similar data sets, for example to identify individuals. [Xiao and Ma (2021)](https://doi.org/10.1080/26939169.2021.1930812) specifically address the possible misuse of this particular dataset, and we now agree that it isn't a good option to use for examples or teaching. In the most recent release of modeldata, we have marked these datasets as deprecated. We have removed them from the [development version of the package on GitHub](https://github.com/tidymodels/modeldata/), and they will be removed entirely in the _next_ CRAN release. We especially want to thank Albert Kim, one of the authors of the original paper, for his [thoughtful and helpful discussion](https://github.com/tidymodels/modeldata/issues/10).

One of the reasons we found the OkCupid dataset useful was that it included multiple text columns per observation, so removing these two motivated us to look for a new option to include instead. We landed on [metadata for modern artwork from the Tate Gallery](https://modeldata.tidymodels.org/reference/tate_text.html); if you used `okc_text` in the past, we recommend switching to `tate_text`. For example, we can count how many of these examples of artwork involve paper or canvas.


```r
data(tate_text)

library(textrecipes)
paper_or_canvas <- c("paper", "canvas")

recipe(~ ., data = tate_text) %>%
  step_tokenize(medium) %>%
  step_stopwords(medium, custom_stopword_source = paper_or_canvas, keep = TRUE) %>%
  step_tf(medium) %>%
  prep() %>%
  bake(new_data = NULL) %>%
  select(artist, year, starts_with("tf"))
```

```
## # A tibble: 4,284 × 4
##    artist              year tf_medium_canvas tf_medium_paper
##    <fct>              <dbl>            <dbl>           <dbl>
##  1 Absalon             1990                0               0
##  2 Auerbach, Frank     1990                0               1
##  3 Auerbach, Frank     1990                0               1
##  4 Auerbach, Frank     1990                0               1
##  5 Auerbach, Frank     1990                1               0
##  6 Ayres, OBE Gillian  1990                1               0
##  7 Barlow, Phyllida    1990                0               1
##  8 Baselitz, Georg     1990                0               1
##  9 Beattie, Basil      1990                1               0
## 10 Beuys, Joseph       1990                0               1
## # … with 4,274 more rows
```

This artwork metadata was a [Tidy Tuesday dataset](https://github.com/rfordatascience/tidytuesday/blob/master/data/2021/2021-01-12/readme.md) earlier this year.

## Acknowledgements

We’d like to extend our thanks to all of the contributors who helped make these releases during Q3 possible!

- baguette: [&#x0040;DavisVaughan](https://github.com/DavisVaughan), [&#x0040;jennybc](https://github.com/jennybc), and [&#x0040;topepo](https://github.com/topepo).

- broom: [&#x0040;bcallaway11](https://github.com/bcallaway11), [&#x0040;billdenney](https://github.com/billdenney), [&#x0040;brshallo](https://github.com/brshallo), [&#x0040;corybrunson](https://github.com/corybrunson), [&#x0040;crsh](https://github.com/crsh), [&#x0040;hfrick](https://github.com/hfrick), [&#x0040;jamesrrae](https://github.com/jamesrrae), [&#x0040;jennybc](https://github.com/jennybc), [&#x0040;jthomasmock](https://github.com/jthomasmock), [&#x0040;kaseyzapatka](https://github.com/kaseyzapatka), [&#x0040;krivit](https://github.com/krivit), [&#x0040;LukasWallrich](https://github.com/LukasWallrich), [&#x0040;oskasf](https://github.com/oskasf), [&#x0040;simonpcouch](https://github.com/simonpcouch), and [&#x0040;tarensanders](https://github.com/tarensanders).

- dials: [&#x0040;camroberts](https://github.com/camroberts), [&#x0040;driapitek](https://github.com/driapitek), [&#x0040;hfrick](https://github.com/hfrick), [&#x0040;jennybc](https://github.com/jennybc), [&#x0040;joeycouse](https://github.com/joeycouse), [&#x0040;Steviey](https://github.com/Steviey), [&#x0040;tonyk7440](https://github.com/tonyk7440), and [&#x0040;topepo](https://github.com/topepo).

- modeldata: [&#x0040;EmilHvitfeldt](https://github.com/EmilHvitfeldt), [&#x0040;hfrick](https://github.com/hfrick), [&#x0040;jennybc](https://github.com/jennybc), [&#x0040;juliasilge](https://github.com/juliasilge), and [&#x0040;topepo](https://github.com/topepo).

- poissonreg: [&#x0040;jennybc](https://github.com/jennybc), and [&#x0040;topepo](https://github.com/topepo).

- rules: [&#x0040;jennybc](https://github.com/jennybc), and [&#x0040;topepo](https://github.com/topepo).

- stacks: [&#x0040;bensoltoff](https://github.com/bensoltoff), [&#x0040;dgrtwo](https://github.com/dgrtwo), [&#x0040;JoeSydlowski](https://github.com/JoeSydlowski), [&#x0040;PathosEthosLogos](https://github.com/PathosEthosLogos), and [&#x0040;simonpcouch](https://github.com/simonpcouch).

- textrecipes: [&#x0040;dgrtwo](https://github.com/dgrtwo), [&#x0040;EmilHvitfeldt](https://github.com/EmilHvitfeldt), [&#x0040;jcragy](https://github.com/jcragy), [&#x0040;jennybc](https://github.com/jennybc), and [&#x0040;topepo](https://github.com/topepo).


