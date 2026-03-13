---
output: hugodown::hugo_document

slug: orbital-0-5-0
title: orbital 0.5.0
date: 2026-03-13
author: Emil Hvitfeldt
description: >
    orbital 0.5.0 is on CRAN! More models and faster execution.

photo:
  url: https://unsplash.com/photos/red-nebula-and-stars-in-deep-space-tQLIYGBQkh8
  author: Scott Lord

# one of: "deep-dive", "learn", "package", "programming", "roundup", or "other"
categories: [package] 
tags: [tidymodels, orbital]
rmd_hash: 923fb447670fac7b

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

We're over the moon to announce the release of [orbital](https://orbital.tidymodels.org/) 0.5.0. orbital lets you predict in databases using tidymodels workflows. orbital uses [tidypredict](https://tidypredict.tidymodels.org/) under the hood to translate fitted models into expressions. This post will also cover things from tidypredict's 1.1.0 release.

You can install both from CRAN with:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://rdrr.io/r/utils/install.packages.html'>install.packages</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"orbital"</span>, <span class='s'>"tidypredict"</span><span class='o'>)</span><span class='o'>)</span></span></code></pre>

</div>

This blog post will cover the highlights, which are support for more models, faster performance, and more vignettes.

You can see a full list of changes in the [orbital release notes](https://orbital.tidymodels.org/news/index.html#orbital-050) and [tidypredict release notes](https://tidypredict.tidymodels.org/news/index.html#tidypredict-110).

## Newly supported models

We have added support for new models as well as more prediction types for existing supported models.

The newly supported models are.

-   `decision_tree(engine = "rpart")`
-   `boost_tree(engine = "lightgbm")`
-   `boost_tree(engine = "catboost")` (More on this soon)

All of which support regression, classification and probability estimates.

The following models now also support classification and probability estimates in addition to regression.

-   `mars(engine = "earth")`
-   `multinom_reg(engine = "glmnet")`
-   `rand_forest(engine = "randomForest")`
-   `rand_forest(engine = "ranger")`

If there is a model type you specifically need [please let us know](https://github.com/tidymodels/tidypredict/issues/232) so we can prioritize new additions.

## Nested `case_when()` support

All tree based models were previously implemented as a flat `case_when()` statement. This means that a small tree with 3 leaves would look like this.

``` r
case_when(
  x <= 5 & y <= 3 ~ "low",
  x <= 5 & y > 3  ~ "med",
  x > 5           ~ "high"
)
```

And while this works, it comes with a number of downsides. In this example we have to calculate `x <= 5` more than once. This might not be that big of a deal in this sized tree but it compounds very fast as the tree grows deeper.

We are also not using the information effectively. Since trees are exhaustive we shouldn't have to calculate the last condition as all other choices have been ruled out. With these considerations in mind we have switched all trees to be expressed as nested `case_when()` statements.

``` r
case_when(
  x <= 5 ~ case_when(
    y <= 3 ~ "low",
    .default = "med"
  ),
  .default = "high"
)
```

This `case_when()` evaluates exactly the same as the previous flat `case_when()` statement. While this might be a little harder to read it provides a lot of benefit in terms of performance. Each condition is evaluated at most 1 time. This has a really big influence on the computational speed.

This also means that the R version of orbital now matches what the [python version of orbital](https://posit-dev.github.io/orbital/) does when creating a tree.

## New `separate_trees` argument

Some models like the ensemble tree models can be represented as a combination of multiple smaller models.This typically manifests as a single massive expression in the following format:

``` r
.pred = "(tree1) + (tree2) + (tree3) + ... + (tree100)"
```

This can create trouble for two main reasons. The first one is that this can cause us to hit expression nesting depth when trying to execute these in a database if we have too many trees or have too deep trees. The second related issue is that databases will not be able to recognize that these trees could be calculated in parallel and combined afterwards.

This is where the new `separate_trees` argument comes in. When setting `separate_trees = TRUE` in [`orbital()`](https://orbital.tidymodels.org/reference/orbital.html) you change the internal representation of the orbital object to not have a single massive expression for `.pred` and instead split them out into multiple expressions like so.

``` r
.pred_tree_001 = "case_when(...)"
.pred_tree_002 = "case_when(...)"
.pred_tree_003 = "case_when(...)"
...
.pred = ".pred_tree_001 + .pred_tree_002 + .pred_tree_003 + ..."
```

This representation allows the database query optimizer to potentially evaluate trees in parallel, since each intermediate column is independent.

The `separate_trees` argument works for the following engines.

-   xgboost
-   lightgbm
-   catboost
-   ranger
-   randomForest

This change alone allows us to work with model types previously not possible with orbital. Together with the nested tree support you can now productionize some of the most popular machine learning models.

## splines support

Spline transformations are commonly used in preprocessing to capture non-linear relationships between predictors and the outcome.

With this release, orbital now supports `step_spline_b()`, `step_spline_convex()`, `step_spline_monotone()`, `step_spline_natural()`, and `step_spline_nonnegative()` from the recipes package. Under the hood, splines are translated into piecewise polynomial expressions that can be evaluated directly in SQL.

## More vignettes

We have added a handful of new vignettes as well in this release.

-   [SQL expression sizes](https://orbital.tidymodels.org/articles/sql-size.html): Goes over how different hyperparameters in models affect SQL sizes. This is useful information especially when working with boosted trees as there are many different combinations of hyperparameters that produce similar performance at different SQL expression sizes. With a little effort you could pick a model that runs 10-100 times faster with minimal loss in predictive performance.

-   [Parallel tree evaluation in databases](https://orbital.tidymodels.org/articles/separate-trees.html): A more in-depth look at how the `separate_trees` argument works. Also includes a section on why and when you should consider using it.

-   [Database deployment](https://orbital.tidymodels.org/articles/database-deployment.html): Shows examples of how we can deploy an orbital model using tables and views.

-   [Float precision at split boundaries](https://tidypredict.tidymodels.org/articles/float-precision.html): Some models like xgboost and Cubist models operate on 32-bit doubles instead of on 64-bit doubles like we have in R. This can cause some problems where predictions don't match exactly. If you use any of these models you should read this vignette to see if this issue is a dealbreaker for you or not.

## Acknowledgements

A special thanks to [Emily Riederer](https://github.com/emilyriederer) who helped workshop and benchmark these new features.

