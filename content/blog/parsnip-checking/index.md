---
output: hugodown::hugo_document

slug: parsnip-checking-1-0-2
title: Improvements to model specification checking in tidymodels
date: 2022-10-10
author: Simon Couch
description: >
    parsnip 1.0.2 includes a number of changes to how the package checks
    model specifications, improving error messages and tightening integration
    with its extension packages.

photo:
  url: https://unsplash.com/photos/ry2JvVpR8Ro
  author: Wayne Hollman

# one of: "deep-dive", "learn", "package", "programming", "roundup", or "other"
categories: [package] 
tags: [parsnip, tidymodels]
rmd_hash: 04e68e74f43ce86b

---

<!--
TODO:
* [x] Look over / edit the post's title in the yaml
* [x] Edit (or delete) the description; note this appears in the Twitter card
* [x] Pick category and tags (see existing with [`hugodown::tidy_show_meta()`](https://rdrr.io/pkg/hugodown/man/use_tidy_post.html))
* [x] Find photo & update yaml metadata
* [x] Create `thumbnail-sq.jpg`; height and width should be equal
* [x] Create `thumbnail-wd.jpg`; width should be >5x height
* [x] [`hugodown::use_tidy_thumbnails()`](https://rdrr.io/pkg/hugodown/man/use_tidy_post.html)
* [x] Add intro sentence, e.g. the standard tagline for the package
* [x] [`usethis::use_tidy_thanks()`](https://usethis.r-lib.org/reference/use_tidy_thanks.html)
-->

We're stoked to announce the upcoming release of [parsnip](https://parsnip.tidymodels.org/) v1.0.2 on CRAN! parsnip provides a tidy, unified interface to models that can be used to try a range of models without getting bogged down in the syntactical minutiae of the underlying packages. This release includes improvements to errors and warnings that proliferate throughout the tidymodels ecosystem. These changes are meant to better anticipate common mistakes and nudge users informatively when defining model specifications.

First, though, we'll start off with a higher-level overview of parsnip and its foundational role in the tidymodels collection of packages.

## A bird's eye view of parsnip and friends

We'll load parsnip, along with other core packages in tidymodels, using the tidymodels meta-package:

``` r
library(tidymodels)
```

parsnip provides a unified interface to machine learning models, supporting a wide array of modeling approaches implemented across numerous R packages. For instance, the code to specify a linear regression model using the `glmnet` library:

``` r
linear_reg() %>%
  set_engine("glmnet") %>%
  set_mode("regression")
#> Linear Regression Model Specification (regression)
#> 
#> Computational engine: glmnet
```

...is quite similar to that needed to specify a boosted tree regression model using `xgboost`:

``` r
boost_tree() %>%
  set_engine("xgboost") %>%
  set_mode("regression")
#> Boosted Tree Model Specification (regression)
#> 
#> Computational engine: xgboost
```

We refer to these objects as *model specifications*, and each are composed of three main components:

-   The **model type**: In this case, a linear regression or boosted tree.
-   The **mode**: The learning task, such as regression or classification.
-   The **engine**: The package or function supplying the implementation for the given model type and mode.

Aside from the consistency in syntax, another advantage of the parsnip package is that it's extensible; anyone (including you!) can write a parsnip *extension package* that tightly integrates with our packages out-of-the-box. We maintain a few of these packages ourselves, such as:

-   [agua](https://github.com/tidymodels/agua): support for models from the H2O modeling ecosystem
-   [baguette](https://github.com/tidymodels/baguette): support for bootstrap aggregating ensemble models
-   [censored](https://github.com/tidymodels/censored): support for censored regression and survival analysis

Similarly, community members outside of the tidymodels team have written parsnip extension packages, such as:

-   [modeltime](https://github.com/business-science/modeltime): support for time series forecasting
-   [additive](https://github.com/hsbadr/additive): support for generalized additive models

Much of our work on improving errors and warnings in this release has focused on parsnip's integration with its extensions.

## Improvements to errors and warnings

Two "big ideas" have helped us focus our efforts related to improving errors and messages in the ecosystem.

-   The same kind of mistake should raise the same prompt
-   Don't tell the user they did something they didn't do

We'll address both in the sections below!

### The same kind of mistake should raise the same prompt

The first problem we sought to address with these changes is that, in some cases, the same conceptual mistake could lead to different kinds of errors from parsnip and the packages that depend on it.

A common mistake that users (and we, as developers) make when defining model specifications is forgetting to load the needed extension package for a given model specification.

For example, parsnip supports bagged decision tree models via the `bag_tree()` model type, though requires extension packages for actual implementations of the model. The censored package implements the `censored regression` mode for bagged decision trees via `rpart`, and the baguette package implements a few additional engines for `regression` and `classification` with this model type.

In parsnip v1.0.1, if we specified a `bag_tree()` model without loading any extension packages, we'd see:

``` r
bt <-
  bag_tree() %>%
  set_engine("rpart")
  
bt
#> parsnip could not locate an implementation for `bag_tree` model specifications
#> using the `rpart` engine.
#>
#> Bagged Decision Tree Model Specification (unknown)
#> 
#> Main Arguments:
#>   cost_complexity = 0
#>   min_n = 2
#> 
#> Computational engine: rpart
```

After seeing this prompt, we may not remember which extension package was the one that implemented this specification. A reasonable guess might be the censored package:

``` r
library(censored)
#> Loading required package: survival
```

Then, trying again:

``` r
bag_tree() %>%
  set_engine("rpart") %>%
  set_mode("regression")
#> Error in `stop_incompatible_mode()`:
#> ! Available modes for engine rpart are: 'unknown', 'censored regression'
```

The censored package clearly wasn't the right one to load. Strangely, though, a side effect of loading it was that the prompt then became more cryptic, and it was converted from a message to an error. Perhaps even more strangely, if we instead supply an engine that only has an implementation in baguette and not censored, we see a different error:

``` r
bag_tree() %>%
  set_engine("C5.0")
#> Error in `check_spec_mode_engine_val()`:
#> ! Engine 'C5.0' is not supported for `bag_tree()`. See `show_engines('bag_tree')`.
```

Not only is this error different from the one above, but it seems to suggest that there is literally no `C5.0` implementation anywhere.

Returning to our `bt` object, suppose we moved forward with defining tuning parameters, and want to define the grid to optimize over:

``` r
bt <- 
  bt %>%
  update(cost_complexity = tune())

extract_parameter_set_dials(bt) %>%
  grid_random(size = 3)
#> Error in `grid_random()`:
#> ! At least one parameter object is required.
```

So far in this section, we've made the same mistake---failing to load the needed parsnip extension package---four times, and received four different prompts.

The good news is that, in each of the above cases, the newest version of parsnip always supplies a message, *and* it's the same kind of message, *and* it's much more helpful.

``` r
library(parsnip)

bag_tree() %>%
  set_engine("rpart")
#> ! parsnip could not locate an implementation for `bag_tree` model
#>   specifications using the `rpart` engine.
#> ℹ The parsnip extension packages censored and baguette implement support for
#>   this specification.
#> ℹ Please install (if needed) and load to continue.
#> 
#> Bagged Decision Tree Model Specification (unknown mode)
#> 
#> Main Arguments:
#>   cost_complexity = 0
#>   min_n = 2
#> 
#> Computational engine: rpart
```

Note how the above message now suggests the two possible parsnip extensions that could provide support for this model specification.

We could load censored, and then this specification is possible; censored implements a `censored regression` mode for bagged trees:

``` r
library(censored)
#> Loading required package: survival

bag_tree() %>%
  set_engine("rpart")
#> Bagged Decision Tree Model Specification (unknown mode)
#> 
#> Main Arguments:
#>   cost_complexity = 0
#>   min_n = 2
#> 
#> Computational engine: rpart
```

If we specify the mode as a regression model, though, the specification is no longer well-supported given the extensions we've loaded. parsnip will again prompt us to load the correct package:

``` r
bag_tree() %>%
  set_engine("rpart") %>%
  set_mode("regression")
#> ! parsnip could not locate an implementation for `bag_tree` regression model
#>   specifications using the `rpart` engine.
#> ℹ The parsnip extension package baguette implements support for this
#>   specification.
#> ℹ Please install (if needed) and load to continue.
#> 
#> Bagged Decision Tree Model Specification (regression)
#> 
#> Main Arguments:
#>   cost_complexity = 0
#>   min_n = 2
#> 
#> Computational engine: rpart
```

That side-effect of loading censored is no longer the case for the `C5.0` engine, as well:

``` r
bag_tree() %>%
  set_engine("C5.0")
#> ! parsnip could not locate an implementation for `bag_tree` model
#>   specifications using the `C5.0` engine.
#> ℹ The parsnip extension package baguette implements support for this
#>   specification.
#> ℹ Please install (if needed) and load to continue.
#> 
#> Bagged Decision Tree Model Specification (unknown mode)
#> 
#> Main Arguments:
#>   cost_complexity = 0
#>   min_n = 2
#> 
#> Computational engine: C5.0
```

Finally, if we try to extract information about tuning parameters for a model that's not well-specified with parsnip v1.0.2, the message about missing extensions is elevated to an error:

``` r
bt <- 
  bt %>%
  update(cost_complexity = tune())

extract_parameter_set_dials(bt) %>%
  grid_random(size = 3)
#> Error:
#> ! parsnip could not locate an implementation for `bag_tree` regression
#>   model specifications using the `rpart` engine.
#> ℹ The parsnip extension package baguette implements support for this
#>   specification.
#> ℹ Please install (if needed) and load to continue.
```

Given parsnip's infrastructure, the technical conditions that raise these four prompts are quite different, but *the technical reasons don't matter*; the mistake being made is the same, and that's what ought to determine the prompt raised.

### Don't tell the user they did something they didn't do

Another consideration that helped us frame these changes is that we feel error messages shouldn't reference operations that users don't need to know about. We'll return to the example of forgetting to load extension packages to elaborate on what we mean here.

With parsnip v1.0.1, if we just load the package and initialize a `bag_tree()` model, we see:

``` r
library(parsnip)

bag_tree()
#> parsnip could not locate an implementation for `bag_tree` model specifications
#> using the `rpart` engine.
#> 
#> Bagged Decision Tree Model Specification (unknown)
#> 
#> Main Arguments:
#>   cost_complexity = 0
#>   min_n = 2
#> 
#> Computational engine: rpart
```

Note the ending of the message: "...using the `rpart` engine." We didn't specify that we wanted to use `rpart` as an engine, yet that seems to be what went wrong!

Readers who have fitted bagged decision tree models with parsnip before may realize that `rpart` is the default engine for these models. This shouldn't be requisite knowledge to interpret this message, though, and is not helpful in addressing the issue. With v1.0.2, we only mention the information that users give to us when constructing that message, and tell them exactly which packages they might need to install/load:

``` r
library(parsnip)

bag_tree()
#> ! parsnip could not locate an implementation for `bag_tree` model
#>   specifications.
#> ℹ The parsnip extension packages censored and baguette implement support for
#>   this specification.
#> ℹ Please install (if needed) and load to continue.
#> 
#> Bagged Decision Tree Model Specification (unknown mode)
#> 
#> Main Arguments:
#>   cost_complexity = 0
#>   min_n = 2
#> 
#> Computational engine: rpart
```

We hinted at another example of this guideline in the previous section; parsnip shouldn't refer to internal functions when it raises error messages. Above, with parsnip v1.0.1, we saw:

``` r
library(censored)
#> Loading required package: survival

bag_tree() %>%
  set_engine("rpart") %>%
  set_mode("regression")
#> Error in `stop_incompatible_mode()`:
#> ! Available modes for engine rpart are: 'unknown', 'censored regression'
```

The error points out a function called `stop_incompatible_mode()`, which is a function used internally by parsnip to check modes. There's a different function, `check_spec_mode_engine_val()`, that will flag super silly modes:

``` r
library(parsnip)

bag_tree() %>%
  set_engine("rpart") %>%
  set_mode("beep bop boop")
#> Error in `check_spec_mode_engine_val()`:
#> ! 'beep bop boop' is not a known mode for model `bag_tree()`.
```

The important part, though, is that *the technical reasons don't matter*. Users don't know---and don't need to know---what `stop_incompatible_mode()` or `check_spec_mode_engine_val()` do.

In parsnip v1.0.2, we now point users to the function they actually called that eventually gave rise to the error:

``` r
bag_tree() %>%
  set_engine("rpart") %>%
  set_mode("beep bop boop")
#> Error in `set_mode()`:
#> ! 'beep bop boop' is not a known mode for model `bag_tree()`.
```

We hope these changes improve folks' experience when modeling with parsnip in the future!

## Other bits and bobs

<!-- This post has highlighted upcoming improvements to model specification checking in parsnip. For those who'd like to learn more, I've written a [companion article](https://simonpcouch.com/blog) on my blog that delves further into the tooling we use to check model specifications. -->

parsnip v1.0.2 includes a number of other changes that you can read about [here](https://github.com/tidymodels/parsnip/blob/main/NEWS.md).

Thanks to the folks who have contributed to this release of parsnip via GitHub: [@gustavomodelli](https://github.com/gustavomodelli), [@joeycouse](https://github.com/joeycouse), [@mrkaye97](https://github.com/mrkaye97), [@siegfried](https://github.com/siegfried).

Contributions from many others, in the form of StackOverflow and RStudio Community posts, have been greatly helpful in our work on these improvements.

