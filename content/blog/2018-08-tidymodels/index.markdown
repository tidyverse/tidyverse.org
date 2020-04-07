---
title: The tidymodels Package
author: Max Kuhn
date: '2018-08-06'
slug: tidymodels-0-0-1
description: > 
  tidymodels 0.0.1 is on CRAN.
categories:
  - package
tags:
  - tidymodels
photo:
  url: https://github.com/tidymodels
  author: tidymodels
---



The `tidymodels` package is now on [CRAN](http://cran.r-project.org/web/packages/tidymodels). Similar to its sister package `tidyverse`, it can be used to install and load tidyverse packages related to modeling and analysis. Currently, it installs and attaches [`broom`](https://broom.tidyverse.org/), [`dplyr`](http://dplyr.tidyverse.org), [`ggplot2`](https://ggplot2.tidyverse.org/), [`infer`](http://infer.netlify.com/), [`purrr`](https://purrr.tidyverse.org/), [`recipes`](https://tidymodels.github.io/recipes/), [`rsample`](https://tidymodels.github.io/rsample/), [`tibble`](https://tibble.tidyverse.org/), and [`yardstick`](https://tidymodels.github.io/yardstick/). 


```r
library(tidymodels)
#> ── Attaching packages ───────────────────────────────── tidymodels 0.0.1 ──
#> ✔ ggplot2   3.0.0     ✔ recipes   0.1.3
#> ✔ tibble    1.4.2     ✔ broom     0.5.0
#> ✔ purrr     0.2.5     ✔ yardstick 0.0.1
#> ✔ dplyr     0.7.6     ✔ infer     0.3.0
#> ✔ rsample   0.0.2
#> ── Conflicts ──────────────────────────────────── tidymodels_conflicts() ──
#> ✖ rsample::fill() masks tidyr::fill()
#> ✖ dplyr::filter() masks stats::filter()
#> ✖ dplyr::lag()    masks stats::lag()
#> ✖ recipes::step() masks stats::step()
```



`tidymodels` also contains a burgeoning list of _tagged packages_. These can be used to install sets of packages for specific purposes. For example, if you are in need of additional tidy tools for analyzing text data:


```r
tag_attach("text analysis")
#> ── Attaching packages ───────────────────────────────── tidymodels 0.0.1 ──
#> ✔ tidytext 0.1.9     ✔ keras    2.1.6
```


These tags will be updated with each version of `tidymodels` as new packages are released. 

The number of tidyverse modeling package continues to grow. Some packages on the development horizon include:

 * [`parsnip`](https://topepo.github.io/parsnip): a unified interface to models. This should significantly reduce the amount of syntactical minutia that you'll need to memorize by having one standardized model function across different packages and by harmonizing the parameter names across models. 

 * [`dials`](https://tidymodels.github.io/dials): tools for tuning parameters. `dials` contains objects and methods for creating and validating tuning parameter values as well as grid search tools. This is designed to work seamlessly with `parsnip`.

 * [`embed`](https://topepo.github.io/embed): an add-on package for `recipes`. This can be used to efficiently encode high-cardinality categorical predictors using supervised methods such as likelihood encodings and entity embeddings.  

 * [`modelgenerics`](https://tidymodels.github.io/modelgenerics): a developer-related tool. This lightweight package can help reduce package dependencies by providing a set of generic methods for classes which are used across packages. For example, if you are creating a new `tidy` method for your model, this package can be used instead of `broom` (and its dependencies). 

Keep an eye on the [tidymodels organization page](https://github.com/tidymodels) for up-to-date information. 
 
 
