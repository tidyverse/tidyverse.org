---
output: hugodown::hugo_document

slug: choose-tidymodels-adventure
title: Choose your own tidymodels adventure
date: 2021-05-24
author: Julia Silge
description: >
    The tidymodels ecosystem is modular and flexible, which can sometimes make
    choosing an approach overwhelming for newcomers. This post offers opinionated 
    guidance on where to start!

photo:
  url: https://unsplash.com/photos/0LXFLzDOfuA
  author: Jonathan Fox

# one of: "deep-dive", "learn", "package", "programming", or "other"
categories: [learn] 
tags: [tidymodels, workflowsets, workflows, parsnip]
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

The [tidymodels](https://www.tidymodels.org/) framework is a collection of R packages for modeling and machine learning using tidyverse principles. You can install the tidymodels suite of packages from CRAN with:


```r
install.packages("tidymodels")
```

The packages in tidymodels are designed to work together in a unified ecosystem, but they are flexible and modular; you can use tidymodels packages for certain parts of a modeling analysis without committing to it entirely, when appropriate.


```r
library(tidymodels)
```

```
## ── Attaching packages ────────────────────────────────── tidymodels 0.1.3 ──
```

```
## ✓ broom        0.7.6      ✓ recipes      0.1.16
## ✓ dials        0.0.9      ✓ rsample      0.1.0 
## ✓ dplyr        1.0.6      ✓ tibble       3.1.2 
## ✓ ggplot2      3.3.3      ✓ tidyr        1.1.3 
## ✓ infer        0.5.4      ✓ tune         0.1.5 
## ✓ modeldata    0.1.0      ✓ workflows    0.2.2 
## ✓ parsnip      0.1.5      ✓ workflowsets 0.0.2 
## ✓ purrr        0.3.4      ✓ yardstick    0.0.8
```

```
## ── Conflicts ───────────────────────────────────── tidymodels_conflicts() ──
## x purrr::discard() masks scales::discard()
## x dplyr::filter()  masks stats::filter()
## x dplyr::lag()     masks stats::lag()
## x recipes::step()  masks stats::step()
## • Use tidymodels_prefer() to resolve common conflicts.
```

We purposefully write code in small, modular packages both to make them easier to maintain and easier to use in production systems. This does mean that it can be challenging for a newcomer to know where their specific problem fits into this ecosystem. We generally recommend a couple of resources for folks just getting started:

- the [**Get Started** section of tidymodels.org](https://www.tidymodels.org/start/) to get going quickly

- our book [*Tidy Modeling with R*](https://www.tmwr.org/)to dig deeper

This post takes on a more specific task for a newcomer to tidymodels; we consider several types of real-world modeling analyses and recommend ways to [choose your own adventure](https://en.wikipedia.org/wiki/Choose_Your_Own_Adventure) in the tidymodels ecosystem.

## Starting with the basics

A fully featured ecosystem for modeling and machine learning requires interfaces to, well, models, and the tidymodels package that provides those functions and interfaces is [parsnip](https://parsnip.tidymodels.org/). If your modeling adventure involves small data and straightforward data preprocessing (like that provided by [R's model formula](https://www.tmwr.org/base-r.html#formula)), you may be well-served by focusing on parsnip. To learn more about how to fit and evaluate parsnip models, check out [this article at tidymodel.org's **Get Started** section](https://www.tidymodels.org/start/models/) and [this blog post (complete with screencast) by me](https://juliasilge.com/blog/student-debt/).

![Student loan debt by race across time](https://juliasilge.com/blog/student-debt/index_files/figure-html/unnamed-chunk-3-1.png)

We don't believe most people using tidymodels fall into this first category, but we think that the tools we've built for these kinds of straightforward analyses are well-designed and will set you up for statistical and practical success. Some people will not reach for tidymodels as a whole ecosystem or even parsnip, choosing instead to use underlying model functions, like `lm()` instead of `linear_reg() %>% set_engine("lm")` (or at another extreme of data size and model complexity, the flexibility of [keras](https://keras.rstudio.com/) for deep learning architectures). Why might you choose to use one or more tidymodels packages anyway, if parsnip or the whole ecosystem is not a good fit for you?

- You may want to use our tidy data resampling infrastructure together with non-tidymodels modeling functions, as shown [here](https://www.tidymodels.org/learn/statistics/bootstrap/) and [here](https://juliasilge.com/blog/ceo-departures/).

- You may want to use [recipes](https://recipes.tidymodels.org/) for feature engineering with non-tidymodels modeling functions, as shown [here](https://smltar.com/dldnn.html).

## Holistic model workflows

When you are setting off on a modeling adventure, it might be worth asking what we even mean by the word "model"; it is a word that gets overloaded really quickly! In the tidymodels ecosystem, we carefully incorporate **both** feature engineering (also called data preprocessing) that must be learned from training data **and** a model fit into a modeling workflow that is estimated together. For example, if you trained a least squares regression model with features learned from principal component analysis, the PCA preprocessing step should be considered part of the model workflow:

![PCA preprocessing is part of the modeling process](https://www.tmwr.org/premade/proper-workflow.svg)

In the tidymodels ecosystem, we use the [workflows](https://workflows.tidymodels.org/) package to bundle together model components and promote more fluent modeling processes. You can fit, tune, and resample workflows, and using workflows has benefits from making it easier to keep track of model components in your code to avoiding data leakage in feature engineering.

We generally expect that most people using tidymodels fall into this middle category, and most of our ecosystem is designed to optimize for these users' experience. Choose a `workflow()` if you want to try several model and/or feature engineering options with your data, if you prefer a simpler and more unified interface for fitting and tuning, or if you like composable and pipeable code for analyses.

To learn more about using workflows, see them [used in action in this **Get Started** article](https://www.tidymodels.org/start/case-study/). Also, I have quite a number of blog posts and screencasts that walk through how to use workflows, such as [this one](https://juliasilge.com/blog/palmer-penguins/) that compares two approaches for the same modeling problem and [this one](https://juliasilge.com/blog/water-sources/) that trains and evaluates a single workflow (one preprocessor + model).


## Screening many models

Sometimes a modeling practitioner is in a situation where they don't want to try out just a few approaches on a given data set, but **many**: not just two or three or four, but A LOT. This is most common when a practitioner starts a new modeling project with a data set that is not well understood and there is little (or maybe no) _a priori_ knowledge about what kind of approach will work well.

For this kind of tidymodels adventure, we encourage users to try the [workflowsets](https://workflowsets.tidymodels.org/) package, which supports the creation, fitting, and comparison of sets of multiple workflows. Combinations of preprocessors and models can be created, and the resulting workflow set can be tuned or resampled, then evaluated (perhaps using Bayesian analysis).

![RMSE by workflow rank for many models](https://www.tidyverse.org/blog/2021/03/workflowsets-0-0-1/figure/plot-bayes-1.svg)
We don't expect that most people using tidymodels will use workflowsets, as it is a specialized tool only useful in some contexts. If you are familiar with AutoML tools, you may notice some similarities between them and what this package does; it has many of the same pros and cons. To learn more about workflowsets (including why our group was hesitant to support and build this functionality!) watch [Max's recent talk for the LA RUG](https://youtu.be/2OfTEakSFXQ), and also [read this chapter of our book](https://www.tmwr.org/workflow-sets.html).


## Your own tidymodels adventure

We believe these three general categories cover most of the modeling adventures you as a practitioner might want to embark on, and our guidance here outlines the best choices given the current status of the tidymodels ecosystem here in the middle of 2021. The ecosystem is growing ever more mature, and packages like parsnip and workflows are more stable, while workflowsets is quite new and may be considered more experimental for now.

For questions and discussions about tidymodels packages, modeling, and machine learning, join us [in discussion on RStudio Community](https://rstd.io/tidymodels-community).

