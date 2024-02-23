---
output: hugodown::hugo_document

slug: tidymodels-2024-survey
title: Take the tidymodels survey for 2024 priorities
date: 2024-02-26
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
rmd_hash: 1f9c4aa31d5adb51

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
-   **Better serialization tools** Serialization of tidymodels objects can now be done with [bundle](https://github.com/rstudio/bundle).

Almost everything that respondents prioritized highly last year has either been completed or is currently in progress. Our main focus right now is to wrap up survival analysis, which is being done right now with a series of CRAN releases for the affected packages. The upcoming things we will be working on are postprocessing and supervised feature selection. Since this survey seemed to work well last year, we've decided to use it again to prioritize features for next year.

## Looking toward 2024

**Take a look at [our survey for next priorities](TODO%20ADD%20LINK%20HERE)** and let us know what you think. There are some items we've put "on the menu" but you can write in other items that you are interested in.

The current slate of our possible priorities include:

-   **sparse tibbles**: Many models benefit from having sparse data, both in execution time and memory constraints. We can't take full advantage of this since recipes use tibbles. This project would involve making it so tibbles can hold sparse data.

-   **Causal inference interface**

-   **Improve chattr** [chattr](https://github.com/mlverse/chattr) is an interface to LLMs (Large Language Models). It enables interaction with the model directly from the RStudio IDE. This task would involve fine-tuning it to give better results when used for tidymodels tasks.

-   **Cost-sensitive learning api** The main part of this task is making our approaches to this uniform across models.

-   **Expand models for stacking ensembles**

-   **Extend support for spatial ML** The work on spatial resampling went well, but want to include more comprehensive support for spatial modeling.

-   **Ordinal regression extension package** Adding support for ordinal regression models in a parsnip extension package.

[Check out our survey](TODO%20ADD%20LINK%20HERE) and tell us what your priorities are!

