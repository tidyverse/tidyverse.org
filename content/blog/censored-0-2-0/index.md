---
output: hugodown::hugo_document

slug: censored-0-2-0
title: censored 0.2.0
date: 2023-04-19
author: Hannah Frick
description: >
    censored 0.2.0 is on CRAN! censored has two new engines for random forests 
    and parametric survival models.

photo:
  url: https://unsplash.com/photos/TuAZPj1uaZs
  author: Sam Poullain

# one of: "deep-dive", "learn", "package", "programming", "roundup", or "other"
categories: [package] 
tags: [tidymodels, parsnip, censored]
rmd_hash: c1360eb5c4d63da3

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

We're thrilled to announce the release of [censored](https://censored.tidymodels.org/) 0.2.0. censored is a parsnip extension package for survival models.

You can install it from CRAN with:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://rdrr.io/r/utils/install.packages.html'>install.packages</a></span><span class='o'>(</span><span class='s'>"censored"</span><span class='o'>)</span></span></code></pre>

</div>

This blog post will introduce you to a new argument name, `eval_time`, and two new engines for fitting random forests and parametric survival models.

You can see a full list of changes in the [release notes](https://github.com/tidymodels/censored/releases/tag/v0.2.0).

## Introducing `eval_time`

As we continue to add support for survival analysis across tidymodels, we have seen a need to be more explicit about which time we mean when we say "time": event time, observed time, censoring time, time at which to predict survival probability at? The last one is a particular mouthful. We now refer to this time as "evaluation time." In preparation for dynamic survival performance metrics which can be calculated at different evaluation time points, the argument to set these evaluation time points for [`predict()`](https://rdrr.io/r/stats/predict.html) is now called `eval_time` instead of just `time`.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>cox</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://parsnip.tidymodels.org/reference/proportional_hazards.html'>proportional_hazards</a></span><span class='o'>(</span><span class='o'>)</span> <span class='o'>|&gt;</span> </span>
<span>  <span class='nf'><a href='https://parsnip.tidymodels.org/reference/set_engine.html'>set_engine</a></span><span class='o'>(</span><span class='s'>"survival"</span><span class='o'>)</span> <span class='o'>|&gt;</span> </span>
<span>  <span class='nf'><a href='https://parsnip.tidymodels.org/reference/set_args.html'>set_mode</a></span><span class='o'>(</span><span class='s'>"censored regression"</span><span class='o'>)</span> <span class='o'>|&gt;</span> </span>
<span>  <span class='nf'><a href='https://generics.r-lib.org/reference/fit.html'>fit</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/pkg/survival/man/Surv.html'>Surv</a></span><span class='o'>(</span><span class='nv'>time</span>, <span class='nv'>status</span><span class='o'>)</span> <span class='o'>~</span> <span class='nv'>.</span>, data <span class='o'>=</span> <span class='nv'>lung</span><span class='o'>)</span></span>
<span><span class='nv'>pred</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/stats/predict.html'>predict</a></span><span class='o'>(</span><span class='nv'>cox</span>, <span class='nv'>lung</span><span class='o'>[</span><span class='m'>1</span><span class='o'>:</span><span class='m'>3</span>, <span class='o'>]</span>, type <span class='o'>=</span> <span class='s'>"survival"</span>, eval_time <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='m'>100</span>, <span class='m'>500</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='nv'>pred</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 3 × 1</span></span></span>
<span><span class='c'>#&gt;   .pred           </span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;list&gt;</span>          </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span> <span style='color: #555555;'>&lt;tibble [2 × 2]&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span> <span style='color: #555555;'>&lt;tibble [2 × 2]&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>3</span> <span style='color: #555555;'>&lt;tibble [2 × 2]&gt;</span></span></span>
<span></span></code></pre>

</div>

The predictions follow the tidymodels principle of one row per observation, and the nested tibble contains the predicted survival probability, `.pred_survival`, as well as the corresponding evaluation time. The column for the evaluation time is now called `.eval_time` instead of `.time`.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>pred</span><span class='o'>$</span><span class='nv'>.pred</span><span class='o'>[[</span><span class='m'>2</span><span class='o'>]</span><span class='o'>]</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 2 × 2</span></span></span>
<span><span class='c'>#&gt;   .eval_time .pred_survival</span></span>
<span><span class='c'>#&gt;        <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>          <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span>        100          0.910</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span>        500          0.422</span></span>
<span></span></code></pre>

</div>

## New engines

censored contains engines for parametric, semi-parametric, and tree-based models. This release adds two new engines:

-   the `"aorsf"` engine for random forests via [`rand_forest()`](https://parsnip.tidymodels.org/reference/rand_forest.html)
-   the `"flexsurvspline"` engine for parametric models via [`survival_reg()`](https://parsnip.tidymodels.org/reference/survival_reg.html)

### New `"aorsf"` engine for `rand_forest()`

This engine has been contributed by [Byron Jaeger](https://github.com/bcjaeger) and enables users to fit oblique random survival forests with the aorsf package. What's with the *oblique* you ask?

Oblique describes how the decision trees that form the random forest make their splits at each node. If the split is based on a single predictor, the resulting tree is called *axis-based* because the split is perpendicular to the axis of the predictor. If the split is based on a linear combination of predictors, there is a lot more flexibility in how the data is split: the split does not need to be perpendicular to any of the predictor axes. Such trees are called *oblique*.

The documentation for the [aorsf](https://docs.ropensci.org/aorsf) package includes a nice illustration of this with the splits for an axis-based tree on the left and an oblique tree on the right:

![Two scatter plots of data with two predictors, X1 and X2, and two classes, coded as pink dots and orange squares. The lefthand plot shows the splits of an axis-based decision tree which are at a right angle to the axis. The resulting partition generally separates the classes well but not perfectly. The righthand plot shows the splits of an oblique tree which achieves perfect separation on this example because it can cut across the predictor space diagnonally.](https://docs.ropensci.org/aorsf/reference/figures/tree_axis_v_oblique.png)

To fit such a model, set the engine for a random forest to `"aorsf"`:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>lung</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/stats/na.fail.html'>na.omit</a></span><span class='o'>(</span><span class='nv'>lung</span><span class='o'>)</span></span>
<span></span>
<span><span class='nv'>forest</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://parsnip.tidymodels.org/reference/rand_forest.html'>rand_forest</a></span><span class='o'>(</span><span class='o'>)</span> <span class='o'>|&gt;</span> </span>
<span>  <span class='nf'><a href='https://parsnip.tidymodels.org/reference/set_engine.html'>set_engine</a></span><span class='o'>(</span><span class='s'>"aorsf"</span><span class='o'>)</span> <span class='o'>|&gt;</span> </span>
<span>  <span class='nf'><a href='https://parsnip.tidymodels.org/reference/set_args.html'>set_mode</a></span><span class='o'>(</span><span class='s'>"censored regression"</span><span class='o'>)</span> <span class='o'>|&gt;</span> </span>
<span>  <span class='nf'><a href='https://generics.r-lib.org/reference/fit.html'>fit</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/pkg/survival/man/Surv.html'>Surv</a></span><span class='o'>(</span><span class='nv'>time</span>, <span class='nv'>status</span><span class='o'>)</span> <span class='o'>~</span> <span class='nv'>.</span>, data <span class='o'>=</span> <span class='nv'>lung</span><span class='o'>)</span></span>
<span></span>
<span><span class='nv'>pred</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/stats/predict.html'>predict</a></span><span class='o'>(</span><span class='nv'>forest</span>, <span class='nv'>lung</span><span class='o'>[</span><span class='m'>1</span><span class='o'>:</span><span class='m'>3</span>, <span class='o'>]</span>, type <span class='o'>=</span> <span class='s'>"survival"</span>, eval_time <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='m'>100</span>, <span class='m'>500</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='nv'>pred</span><span class='o'>$</span><span class='nv'>.pred</span><span class='o'>[[</span><span class='m'>1</span><span class='o'>]</span><span class='o'>]</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 2 × 2</span></span></span>
<span><span class='c'>#&gt;   .eval_time .pred_survival</span></span>
<span><span class='c'>#&gt;        <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>          <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span>        100          0.928</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span>        500          0.368</span></span>
<span></span></code></pre>

</div>

### New `"flexsurvspline"` engine for `survival_reg()`

This engine has been contributed by [Matt Warkentin](https://github.com/mattwarkentin) and enables users to fit a parametric survival model with splines via [`flexsurv::flexsurvspline()`](https://rdrr.io/pkg/flexsurv/man/flexsurvspline.html).

This model uses natural cubic splines to model a transformation of the survival function, e.g., the log cumulative hazard. This gives a lot more flexibility to a parametric model allowing us, for example, to represent more irregular hazard curves. Let's illustrate that with a data set of survival times of breast cancer patients, based on the example from [Jackson (2016)](https://www.jstatsoft.org/article/view/v070i08).

The flexibility of the model is governed by `k`, the number of knots in the spline. We set `scale = "odds"` for a proportional hazards model.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://rdrr.io/r/utils/data.html'>data</a></span><span class='o'>(</span><span class='nv'>bc</span>, package <span class='o'>=</span> <span class='s'>"flexsurv"</span><span class='o'>)</span></span>
<span></span>
<span><span class='nv'>fit_splines</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://parsnip.tidymodels.org/reference/survival_reg.html'>survival_reg</a></span><span class='o'>(</span><span class='o'>)</span> <span class='o'>|&gt;</span> </span>
<span>  <span class='nf'><a href='https://parsnip.tidymodels.org/reference/set_engine.html'>set_engine</a></span><span class='o'>(</span><span class='s'>"flexsurvspline"</span>, k <span class='o'>=</span> <span class='m'>5</span>, scale <span class='o'>=</span> <span class='s'>"odds"</span><span class='o'>)</span> <span class='o'>|&gt;</span> </span>
<span>  <span class='nf'><a href='https://generics.r-lib.org/reference/fit.html'>fit</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/pkg/survival/man/Surv.html'>Surv</a></span><span class='o'>(</span><span class='nv'>recyrs</span>, <span class='nv'>censrec</span><span class='o'>)</span> <span class='o'>~</span> <span class='nv'>group</span>, data <span class='o'>=</span> <span class='nv'>bc</span><span class='o'>)</span></span></code></pre>

</div>

For comparison, we also fit a parametric model without splines.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>fit_gengamma</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://parsnip.tidymodels.org/reference/survival_reg.html'>survival_reg</a></span><span class='o'>(</span>dist <span class='o'>=</span> <span class='s'>"gengamma"</span><span class='o'>)</span> <span class='o'>|&gt;</span> </span>
<span>  <span class='nf'><a href='https://parsnip.tidymodels.org/reference/set_engine.html'>set_engine</a></span><span class='o'>(</span><span class='s'>"flexsurv"</span><span class='o'>)</span> <span class='o'>|&gt;</span> </span>
<span>  <span class='nf'><a href='https://generics.r-lib.org/reference/fit.html'>fit</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/pkg/survival/man/Surv.html'>Surv</a></span><span class='o'>(</span><span class='nv'>recyrs</span>, <span class='nv'>censrec</span><span class='o'>)</span> <span class='o'>~</span> <span class='nv'>group</span>, data <span class='o'>=</span> <span class='nv'>bc</span><span class='o'>)</span></span></code></pre>

</div>

We can predict the hazard for the three levels of the prognostic `group`.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>bc_groups</span> <span class='o'>&lt;-</span> <span class='nf'>tibble</span><span class='o'>(</span>group <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"Poor"</span>,<span class='s'>"Medium"</span>,<span class='s'>"Good"</span><span class='o'>)</span><span class='o'>)</span></span>
<span></span>
<span><span class='nv'>pred_splines</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/stats/predict.html'>predict</a></span><span class='o'>(</span><span class='nv'>fit_splines</span>, new_data <span class='o'>=</span> <span class='nv'>bc_groups</span>, type <span class='o'>=</span> <span class='s'>"hazard"</span>, </span>
<span>                        eval_time <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/seq.html'>seq</a></span><span class='o'>(</span><span class='m'>0.1</span>, <span class='m'>8</span>, by <span class='o'>=</span> <span class='m'>0.1</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>|&gt;</span> </span>
<span>  <span class='nf'>mutate</span><span class='o'>(</span>model <span class='o'>=</span> <span class='s'>"splines"</span><span class='o'>)</span> <span class='o'>|&gt;</span> </span>
<span>  <span class='nf'>bind_cols</span><span class='o'>(</span><span class='nv'>bc_groups</span><span class='o'>)</span></span>
<span></span>
<span><span class='nv'>pred_gengamma</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/stats/predict.html'>predict</a></span><span class='o'>(</span><span class='nv'>fit_gengamma</span>, new_data <span class='o'>=</span> <span class='nv'>bc_groups</span>, type <span class='o'>=</span> <span class='s'>"hazard"</span>, </span>
<span>                         eval_time <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/seq.html'>seq</a></span><span class='o'>(</span><span class='m'>0.1</span>, <span class='m'>8</span>, by <span class='o'>=</span> <span class='m'>0.1</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>|&gt;</span> </span>
<span>  <span class='nf'>mutate</span><span class='o'>(</span>model <span class='o'>=</span> <span class='s'>"gengamma"</span><span class='o'>)</span> <span class='o'>|&gt;</span> </span>
<span>  <span class='nf'>bind_cols</span><span class='o'>(</span><span class='nv'>bc_groups</span><span class='o'>)</span></span></code></pre>

</div>

Plotting the predictions of both models shows a lot more flexibility in the splines model.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'>bind_rows</span><span class='o'>(</span><span class='nv'>pred_splines</span>, <span class='nv'>pred_gengamma</span><span class='o'>)</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span> </span>
<span>  <span class='nf'>mutate</span><span class='o'>(</span>group <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/factor.html'>factor</a></span><span class='o'>(</span><span class='nv'>group</span>, levels <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"Poor"</span>,<span class='s'>"Medium"</span>,<span class='s'>"Good"</span><span class='o'>)</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>|&gt;</span> </span>
<span>  <span class='nf'>tidyr</span><span class='nf'>::</span><span class='nf'><a href='https://tidyr.tidyverse.org/reference/unnest.html'>unnest</a></span><span class='o'>(</span>cols <span class='o'>=</span> <span class='nv'>.pred</span><span class='o'>)</span> <span class='o'>|&gt;</span> </span>
<span>  <span class='nf'>ggplot</span><span class='o'>(</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'>geom_line</span><span class='o'>(</span><span class='nf'>aes</span><span class='o'>(</span>x <span class='o'>=</span> <span class='nv'>.eval_time</span>, y <span class='o'>=</span> <span class='nv'>.pred_hazard</span>, group <span class='o'>=</span> <span class='nv'>group</span>, col <span class='o'>=</span> <span class='nv'>group</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'>facet_wrap</span><span class='o'>(</span><span class='o'>~</span> <span class='nv'>model</span><span class='o'>)</span></span>
</code></pre>
<img src="figs/unnamed-chunk-8-1.png" alt="Two panels side by side, showing the predicted hazard curves for the three prognostic groups from the parametric model on the left and the spline model on the right. The curves for the spline model show more wiggliness, having more flexibility to adapt to the data than the curves from the parametric model which have to follow a generalized gamma distribution." width="700px" style="display: block; margin: auto;" />

</div>

## Acknowledgements

Special thanks to Matt Warkentin and Byron Jaeger for the new engines! A big thank you to all the people who have contributed to censored since the release of v0.1.0:

[@bcjaeger](https://github.com/bcjaeger), [@hfrick](https://github.com/hfrick), [@mattwarkentin](https://github.com/mattwarkentin), [@simonpcouch](https://github.com/simonpcouch), [@therneau](https://github.com/therneau), and [@topepo](https://github.com/topepo).

