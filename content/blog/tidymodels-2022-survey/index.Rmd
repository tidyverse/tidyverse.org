---
output: hugodown::hugo_document

slug: tidymodels-2022-survey
title: tidymodels 2022 developer survey
date: 2021-09-27
author: Max Kuhn
description: >
    We are conducting our second tidymodels devleoper survey. Please give us your
    feedback!

photo:
  url: https://unsplash.com/photos/ChUHmPPTnLQ
  author: Djim Loic

# one of: "deep-dive", "learn", "package", "programming", or "other"
categories: [other] 
tags: [survey,tidymodels]
---

In 2020, we created a developer survey to get community impact on how we prioritize our projects. [The results](https://connect.rstudioservices.com/tidymodels-priorities-survey/README.html) gave us a good sense of which items people were most interested in. The top three requests were:

* Model stacking! This ended up resulting in the [award](https://twitter.com/simonpcouch/status/1347288263472553984) winning [stacks package](https://stacks.tidymodels.org/) by our intern Simon Couch. 
* Model Operations (deploying and monitoring models) was important. We _might_ be working on this from [multiple fronts](https://twitter.com/juliasilge/status/1440784933576851456?s=20). 
* Adaptive resampling and better parallel processing. The [finetune package](https://finetune.tidymodels.org/) solved the first part and some work [on the tune package](https://github.com/tidymodels/tune/pull/305) resolved the second.  

Almost everything on the list has been finalized or is currently in-progress. 

Most of our time right now is spent on model operations, survival analysis, and case weights. That work will proceed through the end of the year (at least). It's time to get more feedback on new features for next year. 

## The 2022 Survey

**Take a look at [the 2022 survey]()** to let us know what you think. There are some items "on the menu" but you can write-in other items that you are interested in. 

The current slate of priorities: 

* **Model fairness analysis and metrics**: Techniques to measure if there are biases in model predictions that treat groups or individuals unfairly.  

* **Supervised feature selection**: This includes basic supervised filtering methods as well as techniques such as recursive feature elimination. 

* **h2o integration**: We'd like for users to be able to have fully featured access to the excellent [h2o](https://www.h2o.ai/products/h2o/) platform via a tidymodels interface. 

* **Post modeling probability calibration**: Methods to characterize (and correct) probability predictions to make sure that the probability estimates reflect the observed event rate(s).

* **Probability cut point optimization** (for two class models): Maybe a 50% probability threshold is not optimal for your application. We'd like to be able to optimize this in the same way as the tuning parameters associated with models and recipes.

* **Spatial analysis models and methods**: We have started to work on [spatial resampling](https://spatialsample.tidymodels.org/) but want to have more comprehensive support for spatial modeling. 

* **Better serialization tools**: A lot of models (e.g keras, xgboost, and others) store there models in memory. If you save the associated R object, you loose the model results. This project would have better tools for saving and reloading model objects. 

Give it a look and tell us what you think!
