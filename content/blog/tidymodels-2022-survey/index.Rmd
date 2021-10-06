---
output: hugodown::hugo_document

slug: tidymodels-2022-survey
title: Take the tidymodels survey for 2022 priorities
date: 2021-10-06
author: Max Kuhn
description: >
    We are conducting our second tidymodels priorities survey. Please give us your
    feedback!

photo:
  url: https://unsplash.com/photos/ChUHmPPTnLQ
  author: Djim Loic

# one of: "deep-dive", "learn", "package", "programming", or "other"
categories: [other] 
tags: [survey,tidymodels]
---

In 2020, we created a survey to get community input on how we prioritize our projects. [The results](https://connect.rstudioservices.com/tidymodels-priorities-survey/README.html) gave us a good sense of which items people were most interested in. The top three requests were:

* **Model stacking!** This ended up resulting in the [award](https://twitter.com/simonpcouch/status/1347288263472553984)-winning [stacks package](https://stacks.tidymodels.org/) by our intern Simon Couch. 
* **Model ops (deploying and monitoring models).** We are currently working on this from [multiple fronts](https://twitter.com/juliasilge/status/1440784933576851456?s=20). 
* **Adaptive resampling and better parallel processing.** The [finetune package](https://finetune.tidymodels.org/) solved the first part and some work [on the tune package](https://github.com/tidymodels/tune/pull/305) resolved the second.  

Almost everything that respondents prioritized highly last year has either been completed or is currently in progress. Most of our time right now is spent on model ops, survival analysis, and case weights. That work will take us through the end of the year (at least). Since this survey seemed to work well last year, we've decided to use it again to prioritize features for next year.

## Looking toward 2022

**Take a look at [our survey for next year's priorities](https://conjoint.qualtrics.com/jfe/form/SV_3gtKaK8G1Z1JC50?Q_CHL=social&Q_SocialSource=tidyverseblog)** and let us know what you think. There are some items we've put "on the menu" but you can write in other items that you are interested in. 

The current slate of our possibile priorities include: 

* **Model fairness analysis and metrics**: Techniques to measure if there are biases in model predictions that treat groups or individuals unfairly.  

* **Supervised feature selection**: This includes basic supervised filtering methods as well as techniques such as recursive feature elimination. 

* **H2O integration**: We'd like for users to be able to have fully featured access to the excellent [H2O](https://www.h2o.ai/products/h2o/) platform via a tidymodels interface. 

* **Post modeling probability calibration**: Methods to characterize (and correct) probability predictions to make sure that probability estimates reflect the observed event rate(s).

* **Probability cut point optimization** (for two class models): Maybe a 50% probability threshold is not optimal for your application. We'd like to be able to optimize this in the same way as the tuning parameters associated with models and recipes.

* **Spatial analysis models and methods**: We have started to work on [spatial resampling](https://spatialsample.tidymodels.org/) but want to include more comprehensive support for spatial modeling. 

* **Better serialization tools**: Some frameworks (e.g. keras, xgboost, and others) store their models in memory. If you save the associated R object, you lose the model results. This project would create better tools for saving and reloading model objects. 

[Check out our survey](https://conjoint.qualtrics.com/jfe/form/SV_3gtKaK8G1Z1JC50?Q_CHL=social&Q_SocialSource=tidyverseblog) and tell us what your priorities are!
