---
output: hugodown::hugo_document

slug: tidymodels-2024-survey
title: Take the tidymodels survey for 2024 priorities
date: 2024-02-28
author: Emil Hvitfeldt
description: >
    We are conducting our third tidymodels priorities survey. Please give us your
    feedback!

photo:
  url: https://unsplash.com/photos/white-flowers-under-blue-sky-during-daytime-peN6l68AWaw
  author: Aamyr

# one of: "deep-dive", "learn", "package", "programming", or "other"
categories: [other] 
tags: [survey,tidymodels]
rmd_hash: c2ba05ee760a40ca

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

At the end of 2021, we created a survey to get community input on how we prioritize our projects. [The results](https://colorado.posit.co/rsc/tidymodels-priorities-2022/) gave us a good sense of which items people were most interested in. Since then we have completed a number of projects:

-   **Model fairness metrics** were included in [yardstick 1.3.0](https://yardstick.tidymodels.org/news/index.html#yardstick-130) with [tidymodels.org](https://www.tidymodels.org/) posts coming soon.
-   **Spatial analysis models and methods** led to the creation of [spatialsample](https://spatialsample.tidymodels.org/).
-   **H2O.ai support** was achieved with the creation of [agua](https://agua.tidymodels.org/).
-   **Better serialization tools** are now provided in the [bundle](https://github.com/rstudio/bundle) package.

Almost everything that respondents prioritized highly last year has either been completed or is currently in progress. Our main focus right now is to wrap up survival analysis, which is being done right now with a series of CRAN releases for the affected packages. Most immediately following these releases, we will be working on postprocessing and supervised feature selection. Beyond that, we'd like to once again ask the community for feedback to help us better prioritize features in the coming year.

## Looking toward 2024

**Take a look at [our survey for next priorities](https://conjoint.qualtrics.com/jfe/form/SV_aWw8ocGN5aPgeZE)** and let us know what you think. There are some items we've put "on the menu" but you can write in other items that you are interested in.

The current slate of our possible priorities include:

### Sparse tibbles

Many models benefit from having sparse data, both in execution time and memory usage. We can't take full advantage of this since recipes use tibbles. This project would involve making it so the tibbles used *inside of a recipe* can hold sparse data. This would not be intended as a general substitute for regular tibbles.

### Causal inference interface

While many common causal inference workflows are already possible with tidymodels, a small set of helper functions could greatly ease the experience of causal modeling in the framework. Specifically, these changes would better accommodate a two-stage modeling approach, using predictions from a propensity model to set case weights for an outcome model.

### Improve chattr

[chattr](https://github.com/mlverse/chattr) is an interface to large language models (LLMs). It enables interaction with the model directly from the RStudio IDE. This task would involve fine-tuning it to give better results when used for tidymodels tasks.

### Cost-sensitive learning API

This feature is another solution for severe class imbalances. The main part of this task is making our approaches to this uniform across models.

### Expand models for stacking ensembles

As of now, the stacks package only supports combining the predictions of member models using a regularized linear model. We could extend the package to allow for combining predictions using any modeling [workflow](https://workflows.tidymodels.org).

### Extend support for spatial ML

[spatialsample](https://spatialsample.tidymodels.org/) introduced a number of spatial resampling methods to tidymodels. More comprehensive support for spatial ML would involve better integrating [spatial metrics](https://www.mm218.dev/posts/2022-08-11-waywiser-010-is-now-on-cran/) into the framework and introducing support for new spatial model types.

### Ordinal regression extension package

Ordinal regression models are specific to classification tasks with a natural ordering to the outcome categories (e.g., low, medium, high, etc.). We could add support for modeling this type of data in a parsnip extension package.

[Check out our survey](https://conjoint.qualtrics.com/jfe/form/SV_aWw8ocGN5aPgeZE) and tell us what your priorities are!

