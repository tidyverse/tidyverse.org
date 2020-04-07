---
title: broom 0.5.0
author: Alex Hayes
date: "2018-07-17"
slug: broom-0-5-0
description: > 
  broom 0.5.0 is on CRAN.
categories:
  - package
tags:
  - broom
  - tidymodels
photo:
  url: https://unsplash.com/photos/vYcH7pI6v1Q
  author: Nagesh Badu
---



<html>
<style>
h2 code {
    font-size: 1em;
}
</style>
</html>

I am delighted to announced that [broom](https://broom.tidyverse.org/) 0.5.0 is now available on CRAN. broom 0.5.0 is a major new release featuring changes that affect both users and developers. See the [News]( https://broom.tidyverse.org/news/) for a detailed list of changes.

This release was possible due to RStudio's internship program, which has enabled me ([Alex Hayes](https://github.com/alexpghayes/)) to act as broom's maintainer for the course of the summer. David Robinson continues to steer design decisions. Many thanks to both RStudio and Dave for this opportunity.

## Tibble output {#tibble}

All tidiers should now return `tibble`s rather than `data.frame`s. This allows broom to take advantage of the nice tibble print method and the more consistent behavior of tibbles:


```r
library(broom)

fit <- lm(mpg ~ ., mtcars)
tidy(fit)
```

```
## # A tibble: 11 x 5
##   term        estimate std.error statistic p.value
##   <chr>          <dbl>     <dbl>     <dbl>   <dbl>
## 1 (Intercept)  12.3      18.7        0.657   0.518
## 2 cyl          -0.111     1.05      -0.107   0.916
## 3 disp          0.0133    0.0179     0.747   0.463
## 4 hp           -0.0215    0.0218    -0.987   0.335
## 5 drat          0.787     1.64       0.481   0.635
## # ... with 6 more rows
```


These changes will mostly likely affect you when you:

- subset with `[`, which always returns a tibble.
- set rownames on a tibble, which is deprecated.
- use augment methods on models with matrix covariates specified in a formula, which will error.

`augment()` will error with matrix covariates because tibbles are more strict about their contents than data frames. More details are [available below](#appendix).

Deprecated tidiers still return data frames. Tidiers for mixed models also return data frames.

## New tidiers

broom 0.5.0 introduces tidiers for:

- `lavaan` objects from the `lavaan` package
- `ivreg` objects from the `AER` package
- `Kendall` objects from the `Kendall` package
- `garch` objects from the `tseries` package
- `irlba` lists from the `irlba` package
- `durbinWatsonTest` objects from the `car` package
- `confusionMatrix` objects from the `caret` package
- `glmnet` and `cv.glmnet` objects from the `glmnetUtils` package
- `clm` and `clmm` objects from the `ordinal` package
- `svyolr` objects from the `survey` package, and
- `polr` objects from the `MASS` package.

In addition to these new tidiers, this release includes fixes for a large number of bugs in existing tidiers.

## New test suite

We are heavily invested in making it easier to contribute to broom, and also in making broom behavior more standardized and consistent. To this end, we've written new testing infrastructure. At the moment, the new tests mostly ensure tibble output. For example, `tidy()` output should now pass the following test:


```r
td <- tidy(model)
check_tidy_output(td)
```

Similar tests exist for `glance()` and `augment()`. Stricter versions of these tests are under development for future releases.

## Mixed models are moving to `broom.mixed`

As broom's popularity has grown, broom has grown to encompass a fairly broad range of models. Dave and I have little to no experience with many of these models, and while we can fix bugs in the tidying code, we are no longer able to determine what constitutes a reasonable summary for many of these models.

Our intended solution is to split broom into several packages for tidying model objects. broom will provide tidiers for popular models (and those in `base` and `stats`), and then domain experts will manage domain-specific tidying packages. Currently we're working on a spec for all of these sub-packages to implement. With any luck this we'll have a well-written spec to accompany the next release. We'd like all of the domain-specific tidying packages to eventually live in [tidymodels](https://github.com/tidymodels), so that users can load a bunch of tools all at once with `library(tidymodels)`. tidymodels will act as meta-package that gathers together tidyverse compatible tools for modelling. Max Kuhn has migrated a number of his packages to the tidymodels organization, and we plan to move broom in the near future.

Mixed-model tidiers have long been a bit of a mess in broom. A while back [`broom.mixed`](https://github.com/bbolker/broom.mixed) forked off to clean them up. broom.mixed is now a pilot for the larger project of splitting broom into domain specific tidying packages. We anticipate that broom.mixed will makes its way onto CRAN in the next several weeks, which will allow us to deprecate mixed model tidiers in broom 0.7.0. Although these models are [not yet deprecated](https://broom.tidyverse.org/news/index.html#deprecations), there is currently no ongoing development work for them. In particular, the tidiers for:

- lme, lme4 and nmle models,
- brms models,
- rstanarm models, and 
- mcmc objects

are one release away from deprecation, and effectively frozen.

## New suggested workflow

When working with many models at the same time, we now recommend using list-columns and a `nest()-map()-unnest()` workflow. This mirrors similar moves across the rest of the tidyverse. We have updated the [kmeans](https://broom.tidyverse.org/articles/kmeans.html), [broom and dplyr](https://broom.tidyverse.org/articles/broom_and_dplyr.html) and  [bootstrapping](https://broom.tidyverse.org/articles/bootstrapping.html) vignettes to reflect the new workflow. Additional, we've updated the bootstrapping vignette to use [rsample](https://tidymodels.github.io/rsample/) rather than the now-deprecated `bootstrap()` function. We no longer recommend the older `group_by()-do()` workflow.

## New vignettes and documentation

The list of available tidiers has been moved out of the README and into the [Available Methods](https://broom.tidyverse.org/articles/available-methods.html) vignette. 

We also have two new vignettes that are **strictly works in progress** at the moment. The first covers [Adding New Tidiers](https://broom.tidyverse.org/articles/adding-tidiers.html) and seeks to make the barrier of entry for broom contributions as low as possible. The second contains a [Glossary](https://broom.tidyverse.org/articles/glossary.html) of terms we are developing for use in an upcoming release of broom. This glossary will standardize argument names across tidiers, and column names across tidy output.

We have also migrated to a new template-based documentation strategy. Repeated documentation material now lives in `roxygen2` templates and can easily be added to a new tidy method. For an example of how this works, see [`R/aer-tidiers.R`](https://github.com/tidyverse/broom/blob/master/R/aer-tidiers.R).

## Deprecations

### Hard deprecations

- `inflate()` has been removed from `broom`
- Matrix and vector tidiers have been deprecated in  favor of `tibble::as_tibble()` and `tibble::enframe()`
- Dataframe tidiers and rowwise dataframe tidiers have been deprecated
- `bootstrap()` has been deprecated in favor of the [`rsample`](https://tidymodels.github.io/rsample/)

### Soft deprecations

The following functions will be deprecated in the next release of broom:

- `sp` tidying methods (in favor of `sf`)
- `tidy.summaryDefault()` (in favor of `skimr::skim()`)
- `tidy.table()` (in favor of `tibble::as_tibble()`)
- Mixed model and bayesian tidiers

## Contributors

Max Kuhn provided advice on dealing with model objects. Mara Averick provided feedback on drafts of this post.

An additional 38 fantastic contributors offered thoughtful comments on design, wrote bug reports and created PRs. The broom community has been kind, supportive and insighftul and I look forward to working you all again!

[@atyre2](https://github.com/atyre2), [@batpigandme](https://github.com/batpigandme), [@bfgray3](https://github.com/bfgray3), [@bmannakee](https://github.com/bmannakee), [@briatte](https://github.com/briatte), [@cawoodjm](https://github.com/cawoodjm), [@cimentadaj](https://github.com/cimentadaj), [@dan87134](https://github.com/dan87134), [@dmenne](https://github.com/dmenne), [@ekatko1](https://github.com/ekatko1), [@ellessenne](https://github.com/ellessenne), [@erleholgersen](https://github.com/erleholgersen), [@Hong-Revo](https://github.com/Hong-Revo), [@huftis](https://github.com/huftis), [@IndrajeetPatil](https://github.com/IndrajeetPatil), [@jacob-long](https://github.com/jacob-long), [@jarvisc1](https://github.com/jarvisc1), [@jenzopr](https://github.com/jenzopr), [@jgabry](https://github.com/jgabry), [@jimhester](https://github.com/jimhester), [@josue-rodriguez](https://github.com/josue-rodriguez), [@karldw](https://github.com/karldw), [@kfeilich](https://github.com/kfeilich), [@larmarange](https://github.com/larmarange), [@lboller](https://github.com/lboller), [@mariusbarth](https://github.com/mariusbarth), [@michaelweylandt](https://github.com/michaelweylandt), [@mine-cetinkaya-rundel](https://github.com/mine-cetinkaya-rundel), [@mkuehn10](https://github.com/mkuehn10), [@mvevans89](https://github.com/mvevans89), [@nutterb](https://github.com/nutterb), [@ShreyasSingh](https://github.com/ShreyasSingh), [@stephlocke](https://github.com/stephlocke), [@strengejacke](https://github.com/strengejacke), [@topepo](https://github.com/topepo), [@willbowditch](https://github.com/willbowditch), [@WillemSleegers](https://github.com/WillemSleegers), and [@wilsonfreitas](https://github.com/wilsonfreitas)


## Additional details on tibbles and `augment()` {#appendix}

Data frames allow users to specify columns in a matrix, like so:


```r
y <- rnorm(5)
x <- matrix(rnorm(10), nrow = 5)
df <- data.frame(x, y)
```

Tibbles do not:


```r
library(tibble)

tibble(x, y)
```

```
## Error: Column `x` must be a 1d atomic vector or a list
```

Modelling functions will occasionally create a data frame like this, but since the model frame can't be coerced a tibble method, `augment()` will fail:


```r
fit <- lm(y ~ x, df)
augment(fit)
```

```
## Error: Column `x` must be a 1d atomic vector or a list
```

In some cases, explicitly passing the original dataset via the `data` argument can resolve this:


```r
augment(fit, data = df)
```

```
## # A tibble: 5 x 10
##       X1     X2      y .fitted .se.fit   .resid  .hat .sigma   .cooksd
## *  <dbl>  <dbl>  <dbl>   <dbl>   <dbl>    <dbl> <dbl>  <dbl>     <dbl>
## 1  0.617 -0.720 -0.167   0.173   0.341 -0.340   0.661  0.108 1.26     
## 2 -0.164  0.943 -0.389  -0.158   0.291 -0.232   0.480  0.499 0.181    
## 3 -0.434  0.424 -0.339  -0.529   0.390  0.190   0.863  0.300 3.12     
## 4  0.231  0.696  0.148   0.150   0.310 -0.00177 0.545  0.594 0.0000156
## 5  0.663 -0.274  0.704   0.320   0.282  0.384   0.451  0.290 0.418    
## # ... with 1 more variable: .std.resid <dbl>
```

Support for matrix-columns is on the way in dplyr and in a release cycle or two this won't be an issue.

 [Back to tibble section](#tibble)
