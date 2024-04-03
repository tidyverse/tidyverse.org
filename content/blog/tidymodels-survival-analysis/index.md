---
output: hugodown::hugo_document

slug: tidymodels-survival-analysis
title: Survival analysis for time-to-event data with tidymodels
date: 2024-03-29
author: Hannah Frick
description: >
    A 2-3 sentence description of the post that appears on the articles page.
    This can be omitted if it would just recapitulate the title.

photo:
  url: https://unsplash.com/photos/n6vS3xlnsCc
  author: Kelley Bozarth

# one of: "deep-dive", "learn", "package", "programming", "roundup", or "other"
categories: [learn] 
tags: [tidymodels, parsnip, censored, workflows, yardstick, tune, workflowsets]
rmd_hash: 49d0f7e5ba4fb8eb

---

<!--
TODO:
* [ ] Look over / edit the post's title in the yaml
* [ ] Edit (or delete) the description; note this appears in the Twitter card
* [x] Pick category and tags (see existing with [`hugodown::tidy_show_meta()`](https://rdrr.io/pkg/hugodown/man/use_tidy_post.html))
* [ ] Find photo & update yaml metadata
* [ ] Create `thumbnail-sq.jpg`; height and width should be equal
* [ ] Create `thumbnail-wd.jpg`; width should be >5x height
* [ ] [`hugodown::use_tidy_thumbnails()`](https://rdrr.io/pkg/hugodown/man/use_tidy_post.html)
* [ ] Add intro sentence, e.g. the standard tagline for the package
* [x] [`usethis::use_tidy_thanks()`](https://usethis.r-lib.org/reference/use_tidy_thanks.html)
-->

We're tickled pink to announce the support of survival analysis for time-to-event data across the tidymodels framework. This makes survival analysis a first-class citizen in tidymodels and gives censored regression modeling the same flexibility and ease as classification or regression.

The functionality resides in multiple tidymodels packages. The easiest way to install them all is to install the tidymodels meta-package:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://rdrr.io/r/utils/install.packages.html'>install.packages</a></span><span class='o'>(</span><span class='s'>"tidymodels"</span><span class='o'>)</span></span></code></pre>

</div>

This blog post will highlight why this is useful, explain which additions we've made to the framework, and point to several places to learn more.

You can see a full list of changes in the release notes:

-   [parsnip](https://parsnip.tidymodels.org/news/index.html#parsnip-120)
-   [censored](https://censored.tidymodels.org/news/index.html#censored-030)
-   [yardstick](https://yardstick.tidymodels.org/news/index.html#yardstick-130)
-   [workflows](https://workflows.tidymodels.org/news/index.html#workflows-114)
-   [tune](https://tune.tidymodels.org/news/index.html#tune-120)
-   [finetune](https://finetune.tidymodels.org/news/index.html#finetune-120)
-   [workflowsets](https://workflowsets.tidymodels.org/news/index.html#workflowsets-110)

## Increasing usefulness: Two perspectives

We'd like to situate the changes from two different perspectives: How this is useful for people already familiar with survival analysis as well as for people already familiar with tidymodels.

If you are already familiar with both: Excellent, this is very much for you! Read on for more details on how these two things come together.

### Adding tidymodels to your tool kit

If you are already familiar with survival analysis but maybe not tidymodels, these changes now unlock a whole framework for predictive modelling for you. It applies tidyverse principles to modeling, meaning it strives to be consistent, composable, and human-centered. The framework covers the modeling process from the initial test/train split of the data all the way to tuning various models. Along the way it offers a rich selection of preprocessing techniques, resampling schemes, and performance metrics along with safe-guards against accidental overfitting. We make the full case for tidymodels at [tidymodels.org](https://www.tidymodels.org/).

### Adding survival analysis to your tool kit

If you are already familiar with tidymodels but maybe not survival analysis, these changes let you leverage the familiar framework for an additional type of modeling problem. Survival analysis offers methods for modeling time-to-event data. While it has its roots in medical research, it has broad applications as that event of interest can be so much more than a medical outcome. Take customer churn as an example: We are interested in how long someone is a customer for and when they churn. For customers who churned, we have the complete time for which they were customers. For existing customers, we only know how long they've been customers for *so far*. Such observations are called censored. So what are our modeling choices here?

We could look at the time and model that as a regression problem. We could look at the event status and model that as a classification problem. Both options might get us somewhere close to an answer to our original modeling question but not quite there. Censored regression models let us model an outcome that includes both aspects, the time and the event status. And with that, it can deal with both censored and uncensored observations appropriately. With this type of model, we can predict the survival time, or in more applied terms, how long someone will stay as a customer. We can also predict the probability of survival at a given time point. This lets us answer questions like "How likely is it that this customer will churn after 3 months?". See which prediction types are available for which models at [censored.tidymodels.org](https://censored.tidymodels.org/).

## Ch-ch-changes: What's new for censored regression?

The main components needed for this full-fledged integration of survival analysis into tidymodels were

-   Survival analysis models that can take censoring into account
-   Survival analysis performance metrics that can take censoring into account
-   Integrating changes required by these models and metrics into the framework

For the models, parsnip gained a new mode, `"censored regression"`, for existing models as well as new model types such as `proportional_hazards()`. Engines for these reside in censored, the parsnip extension package for survival models. The `"censored regression"` mode has been around for a while and we've previously shared posts on [our initial thoughts](https://www.tidyverse.org/blog/2021/11/survival-analysis-parsnip-adjacent/) and the [release of censored](https://www.tidyverse.org/blog/2022/08/censored-0-1-0/).

Now we've added the metrics: [yardstick v1.3.0](https://yardstick.tidymodels.org/news/index.html#yardstick-130) includes new metrics for assessing censored regression models. Somewhat similar to how metrics for classification models can take class predictions or probability predictions as input, these survival metrics can take predicted survival times or predictions of survival probabilities as input.

The new metrics are

-   Concordance index on the survival time via `concordance_survival()`
-   Brier score on the survival probability and its integrated version via `brier_survival()` and `brier_survival_integrated()`
-   ROC curve and the area under the ROC curve on the survival probabilities via `roc_curve_survival()` and `auc_roc_survival()` respectively

The probability of survival is always defined *at a certain point in time*. We call that time point the *evaluation time* because it is then also the time point at which we want to evaluate model performance. Metrics that work on the survival probabilities are also called *dynamic metrics* and you can read more about them here:

-   [Dynamic Performance Metrics for Event Time Data](https://www.tidymodels.org/learn/statistics/survival-metrics/)
-   [Accounting for Censoring in Performance Metrics for Event Time Data](https://www.tidymodels.org/learn/statistics/survival-metrics-details/)

The evaluation time is also the best example to illustrate the changes necessary to the framework. Most of them were under the hood but the evaluation time is user-facing. Let's take a look at that.

While the need for evaluation times is dependent on type of metric, it is not actually specified as an argument to the metric functions. Like yardstick's other metrics, those take pre-made predictions as the input. So where do you specify it then?

-   You need to specify it to directly predict survival probabilities, via [`predict()`](https://rdrr.io/r/stats/predict.html) or `augment()`. We introduced the corresponding `eval_time` argument first for fitted models in [parsnip and censored](https://www.tidyverse.org/blog/2023/04/censored-0-2-0/#introducing-eval_time) and have added it now for workflows.
-   You also need to specify it for the tuning functions `tune_*()` from tune and finetune as they will predict survival probabilities as part of the tuning process.
-   Lastly, the `eval_time` argument now shows up when working with tuning/resampling results such as in `show_best()` or `autoplot()`. Those changes span the packages generating and working with resampling results: tune, finetune, and workflowsets.

As we said, plenty of changes under the hood but you shouldn't need to notice them. Everything else should work "as usual," allowing the same ease and flexibility in combining tidymodels functionality for censored regression as for classification and regression.

## The pieces come together: A case study

To see it all in action, check out the case study [How long until building complaints are dispositioned?](https://www.tidymodels.org/learn/statistics/survival-case-study/) on the tidymodels website!

The city of New York publishes data on complaints received by the Department of Buildings that include how long it takes for a complaint to be dealt with ("dispositioned") as well as several characteristics of the complaint. The case study covers a full analysis. We start with splitting the data into test and training sets, explore different preprocessing strategies and model types via tuning, and predict with a final model. It should give you a good first impression of how to use tidymodels for predictive survival analysis.

We hope you'll find this new capability of tidymodels useful!

## Acknowledgements

Many thanks to the people who contributed to our packages since their last release:

**parsnip:** [@AlbanOtt2](https://github.com/AlbanOtt2), [@birbritto](https://github.com/birbritto), [@christophscheuch](https://github.com/christophscheuch), [@EmilHvitfeldt](https://github.com/EmilHvitfeldt), [@Freestyleyang](https://github.com/Freestyleyang), [@gmcmacran](https://github.com/gmcmacran), [@hfrick](https://github.com/hfrick), [@jmunyoon](https://github.com/jmunyoon), [@joscani](https://github.com/joscani), [@jxu](https://github.com/jxu), [@marcelglueck](https://github.com/marcelglueck), [@mattheaphy](https://github.com/mattheaphy), [@mesdi](https://github.com/mesdi), [@millermc38](https://github.com/millermc38), [@nipnipj](https://github.com/nipnipj), [@pgg1309](https://github.com/pgg1309), [@rdavis120](https://github.com/rdavis120), [@seb-mueller](https://github.com/seb-mueller), [@SHo-JANG](https://github.com/SHo-JANG), [@simonpcouch](https://github.com/simonpcouch), [@topepo](https://github.com/topepo), [@vidarsumo](https://github.com/vidarsumo), and [@wzbillings](https://github.com/wzbillings).

**censored:** [@bcjaeger](https://github.com/bcjaeger), [@brunocarlin](https://github.com/brunocarlin), [@EmilHvitfeldt](https://github.com/EmilHvitfeldt), [@hfrick](https://github.com/hfrick), [@noahtsao](https://github.com/noahtsao), and [@tripartio](https://github.com/tripartio).

**yardstick:** [@aecoleman](https://github.com/aecoleman), [@asb2111](https://github.com/asb2111), [@atsyplenkov](https://github.com/atsyplenkov), [@bgreenwell](https://github.com/bgreenwell), [@Dpananos](https://github.com/Dpananos), [@EduMinsky](https://github.com/EduMinsky), [@EmilHvitfeldt](https://github.com/EmilHvitfeldt), [@heidekrueger](https://github.com/heidekrueger), [@hfrick](https://github.com/hfrick), [@iacrowe](https://github.com/iacrowe), [@jarbet](https://github.com/jarbet), [@jxu](https://github.com/jxu), [@mattwarkentin](https://github.com/mattwarkentin), [@maxwell-geospatial](https://github.com/maxwell-geospatial), [@moloscripts](https://github.com/moloscripts), [@rdavis120](https://github.com/rdavis120), [@ruddnr](https://github.com/ruddnr), [@SimonCoulombe](https://github.com/SimonCoulombe), [@simonpcouch](https://github.com/simonpcouch), [@tbrittoborges](https://github.com/tbrittoborges), [@tonyelhabr](https://github.com/tonyelhabr), [@tripartio](https://github.com/tripartio), [@TSI-PTG](https://github.com/TSI-PTG), [@vnijs](https://github.com/vnijs), [@wbuchanan](https://github.com/wbuchanan), and [@zkrog](https://github.com/zkrog).

**workflows:** [@Milardkh](https://github.com/Milardkh), [@simonpcouch](https://github.com/simonpcouch), and [@topepo](https://github.com/topepo).

**tune:** [@AlbertoImg](https://github.com/AlbertoImg), [@dramanica](https://github.com/dramanica), [@EmilHvitfeldt](https://github.com/EmilHvitfeldt), [@epiheather](https://github.com/epiheather), [@hfrick](https://github.com/hfrick), [@joranE](https://github.com/joranE), [@jrosell](https://github.com/jrosell), [@jxu](https://github.com/jxu), [@kbodwin](https://github.com/kbodwin), [@kenraywilliams](https://github.com/kenraywilliams), [@KJT-Habitat](https://github.com/KJT-Habitat), [@lionel-](https://github.com/lionel-), [@marcozanotti](https://github.com/marcozanotti), [@MasterLuke84](https://github.com/MasterLuke84), [@mikemahoney218](https://github.com/mikemahoney218), [@PathosEthosLogos](https://github.com/PathosEthosLogos), [@Peter4801](https://github.com/Peter4801), [@simonpcouch](https://github.com/simonpcouch), [@topepo](https://github.com/topepo), and [@walkerjameschris](https://github.com/walkerjameschris).

**finetune:** [@EmilHvitfeldt](https://github.com/EmilHvitfeldt), [@hfrick](https://github.com/hfrick), [@jdberson](https://github.com/jdberson), [@jrosell](https://github.com/jrosell), [@mfansler](https://github.com/mfansler), [@ruddnr](https://github.com/ruddnr), [@simonpcouch](https://github.com/simonpcouch), and [@topepo](https://github.com/topepo).

**workflowsets:** [@dchiu911](https://github.com/dchiu911), [@hfrick](https://github.com/hfrick), [@jkylearmstrong](https://github.com/jkylearmstrong), [@PathosEthosLogos](https://github.com/PathosEthosLogos), and [@simonpcouch](https://github.com/simonpcouch).

