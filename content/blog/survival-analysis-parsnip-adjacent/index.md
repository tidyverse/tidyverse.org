---
output: hugodown::hugo_document

slug: survival-analysis-parsnip-adjacent
title: Survival Analysis in tidymodels
date: 2021-09-28
author: Hannah Frick
description: >
    A 2-3 sentence description of the post that appears on the articles page.
    This can be omitted if it would just recapitulate the title.

photo:
  url: https://unsplash.com/photos/n6vS3xlnsCc
  author: Kelley Bozarth

# one of: "deep-dive", "learn", "package", "programming", or "other"
categories: [other] 
tags: []
rmd_hash: 57742b40eb5295f1

---

<!--
TODO:
* [ ] Look over / edit the post's title in the yaml
* [ ] Edit (or delete) the description; note this appears in the Twitter card
* [ ] Pick category and tags (see existing with [`hugodown::tidy_show_meta()`](https://rdrr.io/pkg/hugodown/man/use_tidy_post.html))
* [ ] Find photo & update yaml metadata
* [ ] Create `thumbnail-sq.jpg`; height and width should be equal
* [ ] Create `thumbnail-wd.jpg`; width should be >5x height
* [ ] [`hugodown::use_tidy_thumbnails()`](https://rdrr.io/pkg/hugodown/man/use_tidy_post.html)
* [ ] Add intro sentence, e.g. the standard tagline for the package
* [ ] [`usethis::use_tidy_thanks()`](https://usethis.r-lib.org/reference/use_tidy_thanks.html)
-->

Survival analysis is an important field in modelling and there are many R packages available which implement various models, from "classic" parametric models to boosted trees. While they cover a great variety of model types, they also come with considerable amounts of heterogeneity in syntax and levels of documentation. The tidymodels framework is a collection of R packages for modeling and machine learning using tidyverse principles. It provides a consistent interface to a variety of modelling functions along with tools for resampling, assessing performance, and hyperparameter tuning.

In terms of survival analysis, however, tidymodels so far hasn't been as feature-rich as we'd like it to be, e.g., the available models only covered parametric survival models. With this post we'd like to provide an update on recent work to extend the tooling for survival analysis in tidymodels and gather feedback on future plans.

Making survival analysis a first-class citizen in tidymodels requires touching several aspects across the collection of packages:

-   Pre-processing which accommodates the data structure of censored data.
-   A bigger selection of models which can be specified, fitted, and used for prediction.
-   Additional performance metrics tailored to survival data.

Our focus so far has been on model specification, fitting, and prediction so let's dive in and see what's new!

### Model specification

Several engines can be used for multiple purposes with the same model type, e.g. the `rpart` engine for [`decision_tree()`](https://parsnip.tidymodels.org/reference/decision_tree.html) can be used for classification or regression. This distinction can be made in parsnip by specifying the mode of a model. We have now introduced a new mode `"censored regression"` in parsnip for models which can be used for survival analysis. The aforementioned [`decision_tree()`](https://parsnip.tidymodels.org/reference/decision_tree.html) with the `rpart` engine can also be used to fit a survival decision tree:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://github.com/tidymodels/censored'>censored</a></span><span class='o'>)</span>

<span class='nf'><a href='https://parsnip.tidymodels.org/reference/decision_tree.html'>decision_tree</a></span><span class='o'>(</span><span class='o'>)</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span> 
  <span class='nf'><a href='https://parsnip.tidymodels.org/reference/set_engine.html'>set_engine</a></span><span class='o'>(</span><span class='s'>"rpart"</span><span class='o'>)</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span> 
  <span class='nf'><a href='https://parsnip.tidymodels.org/reference/set_args.html'>set_mode</a></span><span class='o'>(</span><span class='s'>"censored regression"</span><span class='o'>)</span>
<span class='c'>#&gt; Decision Tree Model Specification (censored regression)</span>
<span class='c'>#&gt; </span>
<span class='c'>#&gt; Computational engine: rpart</span></code></pre>

</div>

You may notice a new package name here, `censored`. The number of models supported in tidymodels is growing. The core models live in parsnip, however there are several parsnip-adjacent extension packages with additional models such as [discrim](https://discrim.tidymodels.org/) for discriminant analysis models, [poissonreg](https://poissonreg.tidymodels.org/) for Poisson regression models, and [baguette](https://baguette.tidymodels.org/) for ensemble models via bagging. The [censored](https://tidymodels.github.io/censored/) package is the extension package for censored regression.

Previously we kept the code for the model specifications and their engines in the relevant extension package. While this looks like a straightforward solution to keep code modular and maintainable, we are now reaching such richness in available models that we ran into the following: If the model specification for a `bag_tree()` lives in baguette but we want to add an engine for the new "censored regression" mode in censored, censored has to depend on both parsnip and baguette. To avoid such dependency structures, we are now moving towards keeping all model specifications in parsnip and the extensions packages contain the engine code.

### Model fitting

For fitting a model, parsnip typically supports a formula and a matrix interface, regardless of the interface of the engine. For censored regression models, we are currently only supporting a formula interface. Most engines already support this type of interface, and a formula allows us to specify the outcome via the standard [`survival::Surv()`](https://rdrr.io/pkg/survival/man/Surv.html) function, tying together event time and status.

A formula also let's us specify stratification for a proportional hazards model. For the [`survival::coxph()`](https://rdrr.io/pkg/survival/man/coxph.html) function, which powers the `survival` engine for [`proportional_hazards()`](https://rdrr.io/pkg/censored/man/proportional_hazards.html), this may look like

<div align="center">

`Surv(time, event) ~ x + z + strata(s)`.

</div>

The glmnet package, which powers the `glmnet` engine, does not have a formula interface. It requires us to specify the strata by stratifying the response via `stratifySurv(y, s)`. The response is typically a `Surv` object, so you could end up with a formula like this:

<div align="center">

`stratifySurv(Surv(time, event), strata) ~ x`.

</div>

This works for fitting the model but the syntax is rather convoluted on the left-hand side of the formula. The specification of the stratification is inconsistent with the approach taken by the survival package. Additionally, without further modification, prediction fails because variables on the left-hand side of the formula are treated as response variables by parsnip and not available at prediction time.

We already need to translate from formula interface to matrix interface for this engine, and we like interfaces to be as consistent as possible here in tidymodels so we decided to go with the specification of stratification through a [`strata()`](https://rdrr.io/pkg/survival/man/strata.html) term on the right-hand side of the formula for proportional hazards models, regardless of the engine.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://github.com/therneau/survival'>survival</a></span><span class='o'>)</span>

<span class='nv'>bladder_train</span> <span class='o'>&lt;-</span> <span class='nv'>bladder</span><span class='o'>[</span><span class='o'>-</span><span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='m'>1</span><span class='o'>:</span><span class='m'>3</span><span class='o'>)</span>,<span class='o'>]</span>
<span class='nv'>bladder_test</span> <span class='o'>&lt;-</span> <span class='nv'>bladder</span><span class='o'>[</span><span class='m'>1</span><span class='o'>:</span><span class='m'>3</span>,<span class='o'>]</span>

<span class='nv'>cox_spec</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/pkg/censored/man/proportional_hazards.html'>proportional_hazards</a></span><span class='o'>(</span>penalty <span class='o'>=</span> <span class='m'>0.123</span><span class='o'>)</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span>
    <span class='nf'><a href='https://parsnip.tidymodels.org/reference/set_engine.html'>set_engine</a></span><span class='o'>(</span><span class='s'>"glmnet"</span><span class='o'>)</span>

<span class='nv'>f_fit</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://generics.r-lib.org/reference/fit.html'>fit</a></span><span class='o'>(</span><span class='nv'>cox_spec</span>,
             <span class='nf'><a href='https://rdrr.io/pkg/survival/man/Surv.html'>Surv</a></span><span class='o'>(</span><span class='nv'>stop</span>, <span class='nv'>event</span><span class='o'>)</span> <span class='o'>~</span> <span class='nv'>rx</span> <span class='o'>+</span> <span class='nv'>size</span> <span class='o'>+</span> <span class='nv'>number</span> <span class='o'>+</span> <span class='nf'><a href='https://rdrr.io/pkg/survival/man/strata.html'>strata</a></span><span class='o'>(</span><span class='nv'>enum</span><span class='o'>)</span>,
             data <span class='o'>=</span> <span class='nv'>bladder_train</span><span class='o'>)</span></code></pre>

</div>

### Prediction

We have introduced several new prediction types: time to event (`time`), linear predictor (`linear_pred`), survival probability (`survival`), and hazard (`hazard`). Some of these types are time-dependent, e.g., the survival probability is the probability to survive beyond a certain time point. In keeping with the tidymodels design principle that each row of the data set you're predicting on should give you exactly one row in the dataset of predictions, `predict(type = "survival", time)` returns a nested tibble if `time` contains multiple time points.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>f_pred</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/stats/predict.html'>predict</a></span><span class='o'>(</span><span class='nv'>f_fit</span>, new_data <span class='o'>=</span> <span class='nv'>bladder_test</span>,
                  type <span class='o'>=</span> <span class='s'>"survival"</span>, time <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='m'>5</span>, <span class='m'>10</span>, <span class='m'>15</span>, <span class='m'>20</span><span class='o'>)</span><span class='o'>)</span>

<span class='c'># 3 rows for 3 observations</span>
<span class='nv'>f_pred</span> 
<span class='c'>#&gt; <span style='color: #555555;'># A tibble: 3 × 1</span></span>
<span class='c'>#&gt;   .pred           </span>
<span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;list&gt;</span>          </span>
<span class='c'>#&gt; <span style='color: #555555;'>1</span> <span style='color: #555555;'>&lt;tibble [4 × 2]&gt;</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>2</span> <span style='color: #555555;'>&lt;tibble [4 × 2]&gt;</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>3</span> <span style='color: #555555;'>&lt;tibble [4 × 2]&gt;</span></span>
<span class='c'># 4 rows for 4 time points</span>
<span class='nv'>f_pred</span><span class='o'>$</span><span class='nv'>.pred</span><span class='o'>[[</span><span class='m'>1</span><span class='o'>]</span><span class='o'>]</span>
<span class='c'>#&gt; <span style='color: #555555;'># A tibble: 4 × 2</span></span>
<span class='c'>#&gt;   .time .pred_survival</span>
<span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>          <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>1</span>     5          0.710</span>
<span class='c'>#&gt; <span style='color: #555555;'>2</span>    10          0.610</span>
<span class='c'>#&gt; <span style='color: #555555;'>3</span>    15          0.583</span>
<span class='c'>#&gt; <span style='color: #555555;'>4</span>    20          0.513</span></code></pre>

</div>

Usually, the linear predictor is the linear combination of the predictors, weighted with the coefficients, often denoted as $x^{T} \beta$. This is what is being returned by the `glmnet` engine for [`proportional_hazards()`](https://rdrr.io/pkg/censored/man/proportional_hazards.html) models and by the `mboost` engine for [`boost_tree()`](https://parsnip.tidymodels.org/reference/boost_tree.html) models (e.g., with mode `"censored regression"`). For proportional hazards models, the linear predictor describes *relative* risk, i.e., it refers to a pair of observations: the observation $x$ and a reference observation with value 0. The survival package by default centers the observation with the mean to allow for an interpretation of risk relative to a "standard" observation. For consistency with other engines, prediction of type `linear_pred` from [`proportional_hazards()`](https://rdrr.io/pkg/censored/man/proportional_hazards.html) models with engine `survival` also do not center the predictors.

The prodlim package let's us simulate survival data with two covariates `X1` (binary) and `X2` (numeric) which both have an effect of $exp(1)$ on the hazard of the unobserved event time.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://tidymodels.tidymodels.org'>tidymodels</a></span><span class='o'>)</span>
<span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://ggplot2.tidyverse.org'>ggplot2</a></span><span class='o'>)</span>
<span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'>prodlim</span><span class='o'>)</span>
<span class='nf'><a href='https://rdrr.io/r/base/Random.html'>set.seed</a></span><span class='o'>(</span><span class='m'>43500</span><span class='o'>)</span>

<span class='c'># add 0.5 to X2 (with mean 0) to demonstrate the effect of centering</span>
<span class='nv'>train_dat</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/pkg/prodlim/man/SimSurv.html'>SimSurv</a></span><span class='o'>(</span><span class='m'>2000</span><span class='o'>)</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span> <span class='nf'>mutate</span><span class='o'>(</span>X2 <span class='o'>=</span> <span class='nv'>X2</span> <span class='o'>+</span> <span class='m'>0.5</span><span class='o'>)</span>
<span class='nv'>test_dat</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/pkg/prodlim/man/SimSurv.html'>SimSurv</a></span><span class='o'>(</span><span class='m'>20</span><span class='o'>)</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span> <span class='nf'>mutate</span><span class='o'>(</span>X2 <span class='o'>=</span> <span class='nv'>X2</span> <span class='o'>+</span> <span class='m'>0.5</span><span class='o'>)</span>
<span class='nv'>test_pred</span> <span class='o'>&lt;-</span> <span class='nv'>test_dat</span><span class='o'>[</span>, <span class='m'>5</span><span class='o'>:</span><span class='m'>6</span><span class='o'>]</span></code></pre>

</div>

We can compare the value of the linear predictor using the true coefficients of 1 with the predictions from the survival package. Plotting them against each other shows the offset of the mean of `X2`.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>fit_survival</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/pkg/survival/man/coxph.html'>coxph</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/pkg/survival/man/Surv.html'>Surv</a></span><span class='o'>(</span><span class='nv'>time</span>, <span class='nv'>status</span><span class='o'>)</span> <span class='o'>~</span> <span class='nv'>X1</span> <span class='o'>+</span> <span class='nv'>X2</span>, data <span class='o'>=</span> <span class='nv'>train_dat</span><span class='o'>)</span>
<span class='nv'>pred_survival</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/stats/predict.html'>predict</a></span><span class='o'>(</span><span class='nv'>fit_survival</span>, newdata <span class='o'>=</span> <span class='nv'>test_pred</span><span class='o'>)</span>

<span class='nv'>pred</span> <span class='o'>&lt;-</span> <span class='nf'>bind_cols</span><span class='o'>(</span>
  <span class='nv'>test_pred</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span> <span class='nf'>mutate</span><span class='o'>(</span>linear_pred <span class='o'>=</span> <span class='nv'>X1</span> <span class='o'>*</span> <span class='m'>1</span>  <span class='o'>+</span> <span class='nv'>X2</span> <span class='o'>*</span> <span class='m'>1</span><span class='o'>)</span>,
  <span class='nf'>tibble</span><span class='o'>(</span>pred_survival <span class='o'>=</span> <span class='nv'>pred_survival</span><span class='o'>)</span>
<span class='o'>)</span>

<span class='nf'><a href='https://rdrr.io/r/base/mean.html'>mean</a></span><span class='o'>(</span><span class='nv'>train_dat</span><span class='o'>$</span><span class='nv'>X2</span><span class='o'>)</span>
<span class='c'>#&gt; [1] 0.4683339</span></code></pre>

</div>

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>pred</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span> 
  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggplot.html'>ggplot</a></span><span class='o'>(</span><span class='nf'><a href='https://ggplot2.tidyverse.org/reference/aes.html'>aes</a></span><span class='o'>(</span><span class='nv'>linear_pred</span>, <span class='nv'>pred_survival</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>+</span> 
  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/geom_point.html'>geom_point</a></span><span class='o'>(</span><span class='o'>)</span> <span class='o'>+</span>
  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/geom_abline.html'>geom_abline</a></span><span class='o'>(</span>slope <span class='o'>=</span> <span class='m'>1</span>, intercept <span class='o'>=</span> <span class='m'>0</span><span class='o'>)</span>
</code></pre>
<img src="figs/lp-center-plot-1.png" width="700px" style="display: block; margin: auto;" />

</div>

As part of the modelling workflow, we may want to use these predictions with a performance metric such as concordance. This metric captures the probability that the prediction goes in the same direction as the actual data. While the data captures *survival* time, the linear predictor for a proportional hazards model is a factor on the *risk*. The predicted survival time is longer if the linear predictor is lower. To make the prediction and the observation go in the same direction, we flip the sign of the prediction. This may be opposite to the sign of predictions obtained using the underlying engine directly.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>fit_censored</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/pkg/censored/man/proportional_hazards.html'>proportional_hazards</a></span><span class='o'>(</span><span class='o'>)</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span> 
  <span class='nf'><a href='https://parsnip.tidymodels.org/reference/set_engine.html'>set_engine</a></span><span class='o'>(</span><span class='s'>"survival"</span><span class='o'>)</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span> 
  <span class='nf'><a href='https://generics.r-lib.org/reference/fit.html'>fit</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/pkg/survival/man/Surv.html'>Surv</a></span><span class='o'>(</span><span class='nv'>time</span>, <span class='nv'>status</span><span class='o'>)</span> <span class='o'>~</span> <span class='nv'>X1</span> <span class='o'>+</span> <span class='nv'>X2</span>, data <span class='o'>=</span> <span class='nv'>train_dat</span><span class='o'>)</span>
<span class='nv'>pred_censored</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/stats/predict.html'>predict</a></span><span class='o'>(</span><span class='nv'>fit_censored</span>, type <span class='o'>=</span> <span class='s'>"linear_pred"</span>, new_data <span class='o'>=</span> <span class='nv'>test_pred</span><span class='o'>)</span>

<span class='nv'>pred</span> <span class='o'>&lt;-</span> <span class='nf'>bind_cols</span><span class='o'>(</span>
  <span class='nv'>pred</span>,
  <span class='nv'>pred_censored</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span> <span class='nf'>rename</span><span class='o'>(</span>pred_censored <span class='o'>=</span> <span class='nv'>.pred_linear_pred</span><span class='o'>)</span>
<span class='o'>)</span>

<span class='nv'>pred</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span> 
  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggplot.html'>ggplot</a></span><span class='o'>(</span><span class='nf'><a href='https://ggplot2.tidyverse.org/reference/aes.html'>aes</a></span><span class='o'>(</span><span class='nv'>linear_pred</span>, <span class='nv'>pred_censored</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>+</span> 
  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/geom_point.html'>geom_point</a></span><span class='o'>(</span><span class='o'>)</span> <span class='o'>+</span>
  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/geom_abline.html'>geom_abline</a></span><span class='o'>(</span>slope <span class='o'>=</span> <span class='o'>-</span><span class='m'>1</span>, intercept <span class='o'>=</span> <span class='m'>0</span><span class='o'>)</span>
</code></pre>
<img src="figs/lp-sign-1.png" width="700px" style="display: block; margin: auto;" />

</div>

### Model and prediction types available in censored

Currently, censored contains the following models, engine, and prediction types with ✔ indicating "available", ✖ indicating "unavailable", and ◯ indicating "to do".

<div class="highlight">

| model                | engine          | survival | linear_pred | time | raw | quantile | hazard |
|:---------------------|:----------------|:---------|:------------|:-----|:----|:---------|:-------|
| bag_tree             | ipred           | ✔        | ✖           | ✔    | ✖   | ✖        | ✖      |
| boost_tree           | mboost          | ✔        | ✔           | ◯    | ✖   | ✖        | ✖      |
| decision_tree        | party           | ✔        | ✖           | ✔    | ✖   | ✖        | ✖      |
| decision_tree        | rpart           | ✔        | ✖           | ✔    | ✖   | ✖        | ✖      |
| proportional_hazards | glmnet          | ✔        | ✔           | ◯    | ✔   | ✖        | ✖      |
| proportional_hazards | survival        | ✔        | ✔           | ✔    | ✖   | ✖        | ✖      |
| rand_forest          | party           | ✔        | ✖           | ✔    | ✖   | ✖        | ✖      |
| rand_forest          | randomForestSRC | ◯        | ✖           | ◯    | ✖   | ✖        | ✖      |
| rand_forest          | ranger          | ◯        | ✖           | ◯    | ✖   | ✖        | ✖      |
| survival_reg         | flexsurv        | ✔        | ◯           | ✔    | ✖   | ✔        | ✔      |
| survival_reg         | survival        | ✔        | ◯           | ✔    | ✖   | ✔        | ✔      |

</div>

### What's next?

We want survival analysis to be a first-class citizen in tidymodels which means having access to preprocessing, resampling, models, metrics, and tuning. The next steps on that path are a role for censoring indicator columns and a step `step_surv()` in recipes as well as a new ROC metric for survival models in yardstick. An adaption of workflows and tune is to follow after that. Additionally, we are in the process of figuring out how different types of censoring and time-dependent effects fit into our API.

We'd love to hear from you! Some questions we have include: Would you find this useful? Are there particular models/methods you'd like to see? Do you use time-dependent effects? Do you use interactions? Which types of censoring do you use?

We'd greatly appreciate feedback, ideally in form of an [issue on censored](https://github.com/tidymodels/censored/issues)!

