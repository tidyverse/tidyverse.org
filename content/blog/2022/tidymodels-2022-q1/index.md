---
output: hugodown::hugo_document

slug: tidymodels-2022-q1
title: "Q1 2022 tidymodels digest"
date: 2022-04-01
author: Julia Silge
description: >
    There were 21 releases of tidymodels packages during Q1 of this year,
    and this post shares some highlights!

photo:
  url: https://unsplash.com/photos/nSTFkVywiCU
  author: Aiden Frazier

# one of: "deep-dive", "learn", "package", "programming", "roundup", or "other"
categories: [roundup] 
tags: [tidymodels, textrecipes, workflowsets, dials]
---

<!--
TODO:
* [x] Look over / edit the post's title in the yaml
* [x] Edit (or delete) the description; note this appears in the Twitter card
* [x] Pick category and tags (see existing with `hugodown::tidy_show_meta()`)
* [x] Find photo & update yaml metadata
* [x] Create `thumbnail-sq.jpg`; height and width should be equal
* [x] Create `thumbnail-wd.jpg`; width should be >5x height
* [x] `hugodown::use_tidy_thumbnails()`
* [x] Add intro sentence, e.g. the standard tagline for the package
* [x] `usethis::use_tidy_thanks()`
-->



The [tidymodels](https://www.tidymodels.org/) framework is a collection of R packages for modeling and machine learning using tidyverse principles. 


```r
library(tidymodels)
#> ── Attaching packages ──────────────────────────── tidymodels 0.2.0 ──
#> ✓ broom        0.7.12     ✓ rsample      0.1.1 
#> ✓ dials        0.1.0      ✓ tibble       3.1.6 
#> ✓ dplyr        1.0.8      ✓ tidyr        1.2.0 
#> ✓ infer        1.0.0      ✓ tune         0.2.0 
#> ✓ modeldata    0.1.1      ✓ workflows    0.2.6 
#> ✓ parsnip      0.2.1      ✓ workflowsets 0.2.1 
#> ✓ purrr        0.3.4      ✓ yardstick    0.0.9 
#> ✓ recipes      0.2.0
#> ── Conflicts ─────────────────────────────── tidymodels_conflicts() ──
#> x purrr::discard() masks scales::discard()
#> x dplyr::filter()  masks stats::filter()
#> x dplyr::lag()     masks stats::lag()
#> x recipes::step()  masks stats::step()
#> • Dig deeper into tidy modeling with R at https://www.tmwr.org
```

Since the beginning of last year, we have been publishing [quarterly updates](https://www.tidyverse.org/categories/roundup/) here on the tidyverse blog summarizing what's new in the tidymodels ecosystem. The purpose of these regular posts is to share useful new features and any updates you may have missed. You can check out the [`tidymodels` tag](https://www.tidyverse.org/tags/tidymodels/) to find all tidymodels blog posts here, including our roundup posts as well as those that are more focused, like these from the past month or so: 

- [recipes](https://www.tidyverse.org/blog/2022/02/recipes-0-2-0/)
- [usemodels](https://www.tidyverse.org/blog/2022/03/usemodels-0-2-0/)
- [parsnip and its extension packages](https://www.tidyverse.org/blog/2022/03/parsnip-roundup-2022/)

Since [our last roundup post](https://www.tidyverse.org/blog/2021/12/tidymodels-2021-q4/), there have been 21 CRAN releases of tidymodels packages. You can install these updates from CRAN with:


```r
install.packages(c(
  "baguette", "broom", "brulee", "dials", "discrim", "finetune",
  "hardhat", "multilevelmod", "parsnip", "plsmod", "poissonreg",
  "recipes", "rules", "stacks", "textrecipes", "tune",
  "tidymodels", "usemodels", "vetiver", "workflows", "workflowsets"
))
```

The `NEWS` files are linked here for each package; you'll notice that there are a lot! We know it may be bothersome to keep up with all these changes, so we want to draw your attention to our recent blog posts above and also highlight a few more useful updates in today's blog post.

- [baguette](https://baguette.tidymodels.org/news/index.html#baguette-020)
- [broom](https://broom.tidymodels.org/news/index.html#broom-0711)
- [brulee](https://tidymodels.github.io/brulee/news/index.html#brulee-010)
- [dials](https://dials.tidymodels.org/news/index.html#dials-010)
- [finetune](https://finetune.tidymodels.org/news/index.html#finetune-020)
- [hardhat](https://hardhat.tidymodels.org/news/index.html#hardhat-020)
- [hardhat](https://hardhat.tidymodels.org/news/index.html#hardhat-020)
- [multilevelmod](https://github.com/tidymodels/multilevelmod/blob/main/NEWS.md)
- [parsnip](https://parsnip.tidymodels.org/news/index.html#parsnip-021)
- [plsmod](https://plsmod.tidymodels.org/news/index.html#plsmod-012)
- [poissonreg](https://poissonreg.tidymodels.org/news/index.html#poissonreg-020)
- [recipes](https://github.com/tidymodels/recipes/blob/HEAD/NEWS.md#recipes-020)
- [rules](https://rules.tidymodels.org/news/index.html#rules-020)
- [stacks](https://stacks.tidymodels.org/news/index.html#stacks-022)
- [textrecipes](https://textrecipes.tidymodels.org/news/index.html#textrecipes-050)
- [tune](https://tune.tidymodels.org/news/index.html#tune-020)
- the [tidymodels](https://tidymodels.tidymodels.org/news/index.html#tidymodels-020) metapackage itself
- [usemodels](https://usemodels.tidymodels.org/news/index.html#usemodels-020)
- [vetiver](https://vetiver.tidymodels.org/news/index.html#vetiver-012)
- [workflows](https://workflows.tidymodels.org/news/index.html#workflows-025)
- [workflowsets](https://workflowsets.tidymodels.org/news/index.html#workflowsets-021)

We're really excited about [brulee](https://tidymodels.github.io/brulee/) and [vetiver](https://vetiver.tidymodels.org/) but will share more in upcoming blog posts.


## Feature hashing

The newest [textrecipes](https://textrecipes.tidymodels.org/) release provides support for feature hashing, a feature engineering approach that can be helpful when working with high cardinality categorical data or text. A hashing function takes an input of variable size and maps it to an output of fixed size. Hashing functions are commonly used in cryptography and databases, and we can create a hash in R using `rlang::hash()`:


```r
library(textrecipes)
data(Sacramento)
set.seed(123)
sac_split <- initial_split(Sacramento, strata = price)
sac_train <- training(sac_split)
sac_test  <- testing(sac_split)

tibble(sac_train) %>%
  mutate(zip_hash = map_chr(zip, rlang::hash)) %>%
  select(zip, zip_hash)
#> # A tibble: 698 × 2
#>    zip    zip_hash                        
#>    <fct>  <chr>                           
#>  1 z95838 32cbb7d319c97f062be64075c2ae6c07
#>  2 z95815 55d08d816f0d2e9ec16af15239826e91
#>  3 z95824 235b72b9a37a6154552498eb3f90e9e3
#>  4 z95841 d973597ab5cc48a0dfe54b84a91249e1
#>  5 z95842 c44537f2eecd51707b19e69027228a85
#>  6 z95820 e1b86cbed49c029f9fa25bba94ede11e
#>  7 z95670 60ee71387789bb8c58748e4632089cc4
#>  8 z95838 32cbb7d319c97f062be64075c2ae6c07
#>  9 z95815 55d08d816f0d2e9ec16af15239826e91
#> 10 z95822 8e212bdf9650ef39a1634e6e18529834
#> # … with 688 more rows
```

The variable `zip` in this data on home sales in Sacramento, CA is of ["high cardinality"][1] (as ZIP codes often are) with 67 unique values. When we `hash()` the ZIP code, we get out, well, a hash value, and we will always get the same hash value for the same input (as you can see for ZIP code 95838 here). We can choose the fixed size of our hashed output to reduce the number of possible values to whatever we want; it turns out this works well in a lot of situations.

[1]: https://en.wikipedia.org/wiki/Cardinality_(SQL_statements)

Let's use a hashing algorithm like this one (with an output size of 16) to create binary indicator variables for this high cardinality `zip`:


```r
hash_rec <- 
  recipe(price ~ zip + beds + baths, data = sac_train) %>%
  step_dummy_hash(zip, signed = FALSE, num_terms = 16L)

prep(hash_rec) %>% bake(new_data = NULL)
#> # A tibble: 698 × 19
#>    dummyhash_zip_01 dummyhash_zip_02 dummyhash_zip_03 dummyhash_zip_04
#>               <dbl>            <dbl>            <dbl>            <dbl>
#>  1                0                0                0                0
#>  2                0                1                0                0
#>  3                0                0                1                0
#>  4                1                0                0                0
#>  5                0                0                0                0
#>  6                0                0                0                0
#>  7                0                1                0                0
#>  8                0                0                0                0
#>  9                0                1                0                0
#> 10                0                0                0                0
#> # … with 688 more rows, and 15 more variables:
#> #   dummyhash_zip_05 <dbl>, dummyhash_zip_06 <dbl>,
#> #   dummyhash_zip_07 <dbl>, dummyhash_zip_08 <dbl>,
#> #   dummyhash_zip_09 <dbl>, dummyhash_zip_10 <dbl>,
#> #   dummyhash_zip_11 <dbl>, dummyhash_zip_12 <dbl>,
#> #   dummyhash_zip_13 <dbl>, dummyhash_zip_14 <dbl>,
#> #   dummyhash_zip_15 <dbl>, dummyhash_zip_16 <dbl>, beds <int>, …
```

We now have 16 columns for `zip` (along with the other predictors and the outcome), instead of the over 60 we would have had by making regular dummy variables.

For more on feature hashing including its benefits (fast and low memory!) and downsides (not directly interpretable!), check out [Section 6.7 of _Supervised Machine Learning for Text Analysis with R_](https://smltar.com/mlregression.html#case-study-feature-hashing) and/or [Section 17.4 of _Tidy Modeling with R_](https://www.tmwr.org/categorical.html#feature-hashing). 

## More customization for workflow sets

Last year about this time, we introduced [workflowsets](https://www.tidyverse.org/blog/2021/03/workflowsets-0-0-1/), a new package for creating, handling, and tuning multiple workflows at once. See [Section 7.5](https://www.tmwr.org/workflows.html#workflow-sets-intro) and especially [Chapter 15](https://www.tmwr.org/workflow-sets.html) of _Tidy Modeling with R_ for more on workflow sets. In the latest release of [workflowsets](https://workflowsets.tidymodels.org/), we provide finer control of customization for the workflows you create with workflowsets. First you can create a standard workflow set by crossing a set of models with a set of preprocessors (let's just use the feature hashing recipe we already created):


```r
glmnet_spec <- 
  linear_reg(penalty = tune(), mixture = tune()) %>% 
  set_engine("glmnet")

mars_spec <- 
  mars(prod_degree = tune()) %>%
  set_engine("earth") %>% 
  set_mode("regression")

old_set <- 
  workflow_set(
    preproc = list(hash = hash_rec), 
    models = list(MARS = mars_spec, glmnet = glmnet_spec)
  )

old_set
#> # A workflow set/tibble: 2 × 4
#>   wflow_id    info             option    result    
#>   <chr>       <list>           <list>    <list>    
#> 1 hash_MARS   <tibble [1 × 4]> <opts[0]> <list [0]>
#> 2 hash_glmnet <tibble [1 × 4]> <opts[0]> <list [0]>
```

The `option` column is a placeholder for any arguments to use when we _evaluate_ the workflow; the possibilities here are any argument to functions like [`tune_grid()`](https://tune.tidymodels.org/reference/tune_grid.html) or [`fit_resamples()`](https://tune.tidymodels.org/reference/fit_resamples.html). But what about arguments that belong not to the workflow as a whole, but to a recipe or a parsnip model? In the new release, we added support for customizing those kinds of arguments via `update_workflow_model()` and `update_workflow_recipe()`. This lets you, for example, say that you want to use a [sparse blueprint](https://www.tidyverse.org/blog/2020/11/tidymodels-sparse-support/) for fitting:


```r
sparse_bp <- hardhat::default_recipe_blueprint(composition = "dgCMatrix")
new_set <- old_set %>%
  update_workflow_recipe("hash_glmnet", hash_rec, blueprint = sparse_bp)
```

Now we can tune this workflow set, with the sparse blueprint for the glmnet model, over a set of resampling folds.


```r
set.seed(123)
folds <- vfold_cv(sac_train, strata = price)

new_set %>%
  workflow_map(resamples = folds, grid = 5, verbose = TRUE)
#> i 1 of 2 tuning:     hash_MARS
#> ✓ 1 of 2 tuning:     hash_MARS (2.2s)
#> i 2 of 2 tuning:     hash_glmnet
#> ✓ 2 of 2 tuning:     hash_glmnet (3.9s)
#> # A workflow set/tibble: 2 × 4
#>   wflow_id    info             option    result   
#>   <chr>       <list>           <list>    <list>   
#> 1 hash_MARS   <tibble [1 × 4]> <opts[2]> <tune[+]>
#> 2 hash_glmnet <tibble [1 × 4]> <opts[2]> <tune[+]>
```


## New parameter objects and parameter handling

Even if you are a regular tidymodels user, you may not have thought much about [dials](https://dials.tidymodels.org/). This is an infrastructure package that is used to create and manage model hyperparameters. In the latest release of dials, we provide a handful of new parameters for various models and feature engineering approaches. There are a handful of parameters [for the new `parsnip::bart()`](https://parsnip.tidymodels.org/reference/bart.html), i.e. Bayesian additive regression trees model:


```r
prior_outcome_range()
#> Prior for Outcome Range (quantitative)
#> Range: (0, 5]
prior_terminal_node_coef()
#> Terminal Node Prior Coefficient (quantitative)
#> Range: (0, 1]
prior_terminal_node_expo()
#> Terminal Node Prior Exponent (quantitative)
#> Range: [0, 3]
```

This version of dials, along with the new hardhat release, also provides new functions for extracting single parameters and parameter sets from modeling objects.


```r
recipe(price ~ zip + beds + baths, data = sac_train) %>%
  step_dummy_hash(zip, signed = FALSE, num_terms = tune()) %>%
  extract_parameter_set_dials()
#> Collection of 1 parameters for tuning
#> 
#>  identifier      type    object
#>   num_terms num_terms nparam[+]
```

You can also extract a single parameter by name:


```r
mars_spec %>% extract_parameter_dials("prod_degree")
#> Degree of Interaction (quantitative)
#> Range: [1, 2]
glmnet_spec %>% extract_parameter_dials("penalty")
#> Amount of Regularization (quantitative)
#> Transformer:  log-10 
#> Range (transformed scale): [-10, 0]
```


## Acknowledgements

We’d like to extend our thanks to all of the contributors who helped make these releases during Q1 possible!

- baguette: [&#x0040;EmilHvitfeldt](https://github.com/EmilHvitfeldt) and [&#x0040;hfrick](https://github.com/hfrick).

- broom: [&#x0040;cgoo4](https://github.com/cgoo4), [&#x0040;colinbrislawn](https://github.com/colinbrislawn), [&#x0040;DanChaltiel](https://github.com/DanChaltiel), [&#x0040;ddsjoberg](https://github.com/ddsjoberg), [&#x0040;fschaffner](https://github.com/fschaffner), [&#x0040;grantmcdermott](https://github.com/grantmcdermott), [&#x0040;hughjonesd](https://github.com/hughjonesd), [&#x0040;jennybc](https://github.com/jennybc), [&#x0040;Marc-Girondot](https://github.com/Marc-Girondot), [&#x0040;MichaelChirico](https://github.com/MichaelChirico), [&#x0040;mlaviolet](https://github.com/mlaviolet), [&#x0040;oliverbothe](https://github.com/oliverbothe), [&#x0040;PursuitOfDataScience](https://github.com/PursuitOfDataScience), [&#x0040;simonpcouch](https://github.com/simonpcouch), and [&#x0040;vincentarelbundock](https://github.com/vincentarelbundock).

- brulee: [&#x0040;dfalbel](https://github.com/dfalbel), [&#x0040;EmilHvitfeldt](https://github.com/EmilHvitfeldt), and [&#x0040;topepo](https://github.com/topepo).

- dials: [&#x0040;EmilHvitfeldt](https://github.com/EmilHvitfeldt), [&#x0040;hfrick](https://github.com/hfrick), and [&#x0040;py9mrg](https://github.com/py9mrg).

- discrim: [&#x0040;deschen1](https://github.com/deschen1), [&#x0040;EmilHvitfeldt](https://github.com/EmilHvitfeldt), [&#x0040;hfrick](https://github.com/hfrick), [&#x0040;jmarshallnz](https://github.com/jmarshallnz), and [&#x0040;juliasilge](https://github.com/juliasilge).

- finetune: [&#x0040;juliasilge](https://github.com/juliasilge), [&#x0040;Steviey](https://github.com/Steviey), and [&#x0040;topepo](https://github.com/topepo).

- hardhat: [&#x0040;DavisVaughan](https://github.com/DavisVaughan), [&#x0040;ddsjoberg](https://github.com/ddsjoberg), [&#x0040;EmilHvitfeldt](https://github.com/EmilHvitfeldt), [&#x0040;hfrick](https://github.com/hfrick), and [&#x0040;MasterLuke84](https://github.com/MasterLuke84).

- multilevelmod: [&#x0040;EmilHvitfeldt](https://github.com/EmilHvitfeldt) and [&#x0040;sitendug](https://github.com/sitendug).

- parsnip: [&#x0040;brunocarlin](https://github.com/brunocarlin), [&#x0040;dietrichson](https://github.com/dietrichson), [&#x0040;edgararuiz](https://github.com/edgararuiz), [&#x0040;EmilHvitfeldt](https://github.com/EmilHvitfeldt), [&#x0040;hfrick](https://github.com/hfrick), [&#x0040;jmarshallnz](https://github.com/jmarshallnz), [&#x0040;juliasilge](https://github.com/juliasilge), [&#x0040;mattwarkentin](https://github.com/mattwarkentin), [&#x0040;nikhilpathiyil](https://github.com/nikhilpathiyil), [&#x0040;nvelden](https://github.com/nvelden), [&#x0040;t-kalinowski](https://github.com/t-kalinowski), [&#x0040;tiagomaie](https://github.com/tiagomaie), [&#x0040;tolliam](https://github.com/tolliam), and [&#x0040;topepo](https://github.com/topepo).

- plsmod: [&#x0040;EmilHvitfeldt](https://github.com/EmilHvitfeldt) and [&#x0040;topepo](https://github.com/topepo).

- poissonreg: [&#x0040;EmilHvitfeldt](https://github.com/EmilHvitfeldt) and [&#x0040;juliasilge](https://github.com/juliasilge).

- recipes: [&#x0040;agwalker82](https://github.com/agwalker82), [&#x0040;AndrewKostandy](https://github.com/AndrewKostandy), [&#x0040;aridf](https://github.com/aridf), [&#x0040;brunocarlin](https://github.com/brunocarlin), [&#x0040;DoktorMike](https://github.com/DoktorMike), [&#x0040;duccioa](https://github.com/duccioa), [&#x0040;EmilHvitfeldt](https://github.com/EmilHvitfeldt), [&#x0040;FieteO](https://github.com/FieteO), [&#x0040;hfrick](https://github.com/hfrick), [&#x0040;joeycouse](https://github.com/joeycouse), [&#x0040;juliasilge](https://github.com/juliasilge), [&#x0040;lionel-](https://github.com/lionel-), [&#x0040;mattwarkentin](https://github.com/mattwarkentin), [&#x0040;mdsteiner](https://github.com/mdsteiner), [&#x0040;MichaelChirico](https://github.com/MichaelChirico), [&#x0040;spsanderson](https://github.com/spsanderson), [&#x0040;themichjam](https://github.com/themichjam), [&#x0040;tmastny](https://github.com/tmastny), [&#x0040;tomazweiss](https://github.com/tomazweiss), [&#x0040;topepo](https://github.com/topepo), [&#x0040;walrossker](https://github.com/walrossker), and [&#x0040;zenggyu](https://github.com/zenggyu).

- rules: [&#x0040;EmilHvitfeldt](https://github.com/EmilHvitfeldt), [&#x0040;juliasilge](https://github.com/juliasilge), and [&#x0040;wdkeyzer](https://github.com/wdkeyzer).

- stacks: [&#x0040;amcmahon17](https://github.com/amcmahon17), [&#x0040;py9mrg](https://github.com/py9mrg), [&#x0040;Saarialho](https://github.com/Saarialho), [&#x0040;siegfried](https://github.com/siegfried), [&#x0040;simonpcouch](https://github.com/simonpcouch), [&#x0040;StuieT85](https://github.com/StuieT85), [&#x0040;topepo](https://github.com/topepo), and [&#x0040;williamshell](https://github.com/williamshell).

- textrecipes: [&#x0040;EmilHvitfeldt](https://github.com/EmilHvitfeldt), [&#x0040;lionel-](https://github.com/lionel-), and [&#x0040;NLDataScientist](https://github.com/NLDataScientist).

- tune: [&#x0040;abichat](https://github.com/abichat), [&#x0040;AndrewKostandy](https://github.com/AndrewKostandy), [&#x0040;dax44](https://github.com/dax44), [&#x0040;EmilHvitfeldt](https://github.com/EmilHvitfeldt), [&#x0040;felxcon](https://github.com/felxcon), [&#x0040;hfrick](https://github.com/hfrick), [&#x0040;juanydlh](https://github.com/juanydlh), [&#x0040;juliasilge](https://github.com/juliasilge), [&#x0040;mattwarkentin](https://github.com/mattwarkentin), [&#x0040;mdancho84](https://github.com/mdancho84), [&#x0040;py9mrg](https://github.com/py9mrg), [&#x0040;topepo](https://github.com/topepo), [&#x0040;walrossker](https://github.com/walrossker), [&#x0040;williamshell](https://github.com/williamshell), and [&#x0040;wtbxsjy](https://github.com/wtbxsjy).

- tidymodels: [&#x0040;EmilHvitfeldt](https://github.com/EmilHvitfeldt), [&#x0040;exsell-jc](https://github.com/exsell-jc), [&#x0040;hardin47](https://github.com/hardin47), [&#x0040;juliasilge](https://github.com/juliasilge), [&#x0040;PursuitOfDataScience](https://github.com/PursuitOfDataScience), [&#x0040;RaymondBalise](https://github.com/RaymondBalise), [&#x0040;scottlyden](https://github.com/scottlyden), and [&#x0040;topepo](https://github.com/topepo).

- usemodels: [&#x0040;juliasilge](https://github.com/juliasilge) and [&#x0040;topepo](https://github.com/topepo).

- vetiver: [&#x0040;atheriel](https://github.com/atheriel) and [&#x0040;juliasilge](https://github.com/juliasilge).

- workflows: [&#x0040;CarstenLange](https://github.com/CarstenLange), [&#x0040;DavisVaughan](https://github.com/DavisVaughan), [&#x0040;dpprdan](https://github.com/dpprdan), [&#x0040;hfrick](https://github.com/hfrick), and [&#x0040;juliasilge](https://github.com/juliasilge).

- workflowsets: [&#x0040;DavisVaughan](https://github.com/DavisVaughan), [&#x0040;dvanic](https://github.com/dvanic), [&#x0040;gdmcdonald](https://github.com/gdmcdonald), [&#x0040;hfrick](https://github.com/hfrick), [&#x0040;juliasilge](https://github.com/juliasilge), [&#x0040;topepo](https://github.com/topepo), and [&#x0040;wdefreitas](https://github.com/wdefreitas).
