---
output: hugodown::hugo_document

slug: postprocessing-preview
title: Postprocessing is coming to tidymodels
date: 2024-10-01
author: Simon Couch, Hannah Frick, and Max Kuhn
description: >
    The tidymodels team has been hard at work on postprocessing, a set of
    features to adjust model predictions. The functionality includes a new
    package as well as changes across the framework.

photo:
  url: https://unsplash.com/photos/dG35-kUxv34
  author: Dinh Pham

categories: [roundup] 
tags: [tidymodels, postprocessing, workflows]
rmd_hash: c331625022b91d17

---

We're bristling with elation to share about a set of upcoming features for postprocessing with tidymodels. Postprocessors refine predictions outputted from machine learning models to improve predictive performance or better satisfy distributional limitations. The developmental versions of many tidymodels core packages include changes to support postprocessors, and we're ready to share about our work and hear the community's thoughts on our progress so far.

Postprocessing support with tidymodels hasn't yet made it to CRAN, but you can install the needed versions of tidymodels packages with the following code.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'>pak</span><span class='nf'>::</span><span class='nf'><a href='https://pak.r-lib.org/reference/pak.html'>pak</a></span><span class='o'>(</span></span>
<span>  <span class='nf'><a href='https://rdrr.io/r/base/paste.html'>paste0</a></span><span class='o'>(</span></span>
<span>    <span class='s'>"tidymodels/"</span>,</span>
<span>    <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"tune"</span>, <span class='s'>"workflows"</span>, <span class='s'>"rsample"</span>, <span class='s'>"tailor"</span><span class='o'>)</span></span>
<span>  <span class='o'>)</span></span>
<span><span class='o'>)</span></span></code></pre>

</div>

Now, we load packages with those developmental versions installed.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://tidymodels.tidymodels.org'>tidymodels</a></span><span class='o'>)</span></span>
<span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://github.com/tidymodels/probably'>probably</a></span><span class='o'>)</span></span>
<span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://github.com/tidymodels/tailor'>tailor</a></span><span class='o'>)</span></span></code></pre>

</div>

Existing tidymodels users might have spotted something funky already; who is this tailor character?

## Meet tailor👋

The tailor package introduces tailor objects, which compose iterative adjustments to model predictions. tailor is to postprocessing as recipes is to preprocessing; applying your mental model of recipes to tailor should get you a good bit of the way there.

| Tool | Applied to\... | Initialize with\... | Composes\... | Train with\... | Predict with\... |
|------------|------------|------------|------------|------------|------------|
| recipes | Training data | `recipe()` | `step_*()`s | `prep()` | `bake()` |
| tailor | Model predictions | [`tailor()`](https://tailor.tidymodels.org/reference/tailor.html) | `adjust_*()`ments | [`fit()`](https://generics.r-lib.org/reference/fit.html) | [`predict()`](https://rdrr.io/r/stats/predict.html) |

First, users can initialize a tailor object with [`tailor()`](https://tailor.tidymodels.org/reference/tailor.html).

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://tailor.tidymodels.org/reference/tailor.html'>tailor</a></span><span class='o'>(</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; </span></span>
<span></span><span><span class='c'>#&gt; <span style='color: #00BBBB;'>──</span> <span style='font-weight: bold;'>tailor</span> <span style='color: #00BBBB;'>──────────────────────────────────────────────────────────────────────</span></span></span>
<span></span><span><span class='c'>#&gt; A postprocessor with 0 adjustments.</span></span>
<span></span></code></pre>

</div>

Tailors compose "adjustments," analogous to steps from the recipes package.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://tailor.tidymodels.org/reference/tailor.html'>tailor</a></span><span class='o'>(</span><span class='o'>)</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span></span>
<span>  <span class='nf'><a href='https://tailor.tidymodels.org/reference/adjust_probability_threshold.html'>adjust_probability_threshold</a></span><span class='o'>(</span>threshold <span class='o'>=</span> <span class='m'>.7</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; </span></span>
<span></span><span><span class='c'>#&gt; <span style='color: #00BBBB;'>──</span> <span style='font-weight: bold;'>tailor</span> <span style='color: #00BBBB;'>──────────────────────────────────────────────────────────────────────</span></span></span>
<span></span><span><span class='c'>#&gt; A binary postprocessor with 1 adjustment:</span></span>
<span></span><span><span class='c'>#&gt; </span></span>
<span></span><span><span class='c'>#&gt; <span style='color: #00BBBB;'>•</span> Adjust probability threshold to 0.7.</span></span>
<span></span></code></pre>

</div>

As an example, we'll apply this tailor to the `two_class_example` data made available after loading tidymodels.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://rdrr.io/r/utils/head.html'>head</a></span><span class='o'>(</span><span class='nv'>two_class_example</span><span class='o'>)</span></span>
<span><span class='c'>#&gt;    truth      Class1       Class2 predicted</span></span>
<span><span class='c'>#&gt; 1 Class2 0.003589243 0.9964107574    Class2</span></span>
<span><span class='c'>#&gt; 2 Class1 0.678621054 0.3213789460    Class1</span></span>
<span><span class='c'>#&gt; 3 Class2 0.110893522 0.8891064779    Class2</span></span>
<span><span class='c'>#&gt; 4 Class1 0.735161703 0.2648382969    Class1</span></span>
<span><span class='c'>#&gt; 5 Class2 0.016239960 0.9837600397    Class2</span></span>
<span><span class='c'>#&gt; 6 Class1 0.999275071 0.0007249286    Class1</span></span>
<span></span></code></pre>

</div>

This data gives the true value of an outcome variable `truth` as well as predicted probabilities (`Class1` and `Class2`). The hard class predictions, in predicted, are `"Class1"` if the probability assigned to `"Class1"` is above .5, and `"Class2"` otherwise.

The model predicts `"Class1"` more often than it does `"Class2"`.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>two_class_example</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span> <span class='nf'>count</span><span class='o'>(</span><span class='nv'>predicted</span><span class='o'>)</span></span>
<span><span class='c'>#&gt;   predicted   n</span></span>
<span><span class='c'>#&gt; 1    Class1 277</span></span>
<span><span class='c'>#&gt; 2    Class2 223</span></span>
<span></span></code></pre>

</div>

If we wanted the model to predict `"Class2"` more often, we could increase the probability threshold assigned to `"Class1"` above which the hard class prediction will be `"Class1"`. In the tailor package, this adjustment is implemented in [`adjust_probability_threshold()`](https://tailor.tidymodels.org/reference/adjust_probability_threshold.html), which can be situated in a tailor object.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>tlr</span> <span class='o'>&lt;-</span></span>
<span>  <span class='nf'><a href='https://tailor.tidymodels.org/reference/tailor.html'>tailor</a></span><span class='o'>(</span><span class='o'>)</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span></span>
<span>  <span class='nf'><a href='https://tailor.tidymodels.org/reference/adjust_probability_threshold.html'>adjust_probability_threshold</a></span><span class='o'>(</span>threshold <span class='o'>=</span> <span class='m'>.7</span><span class='o'>)</span></span>
<span></span>
<span><span class='nv'>tlr</span></span>
<span><span class='c'>#&gt; </span></span>
<span></span><span><span class='c'>#&gt; <span style='color: #00BBBB;'>──</span> <span style='font-weight: bold;'>tailor</span> <span style='color: #00BBBB;'>──────────────────────────────────────────────────────────────────────</span></span></span>
<span></span><span><span class='c'>#&gt; A binary postprocessor with 1 adjustment:</span></span>
<span></span><span><span class='c'>#&gt; </span></span>
<span></span><span><span class='c'>#&gt; <span style='color: #00BBBB;'>•</span> Adjust probability threshold to 0.7.</span></span>
<span></span></code></pre>

</div>

tailors must be fitted before they can predict on new data. For adjustments like [`adjust_probability_threshold()`](https://tailor.tidymodels.org/reference/adjust_probability_threshold.html), there's no training that actually happens at the [`fit()`](https://generics.r-lib.org/reference/fit.html) step besides recording the name and type of relevant variables. For other adjustments, like numeric calibration with [`adjust_numeric_calibration()`](https://tailor.tidymodels.org/reference/adjust_numeric_calibration.html), parameters are actually estimated at the [`fit()`](https://generics.r-lib.org/reference/fit.html) step and separate data should be used to train the postprocessor and evaluate its performance. More on this in [Tailors in context](#tailors-in-context).

In this case, though, we can [`fit()`](https://generics.r-lib.org/reference/fit.html) on the whole dataset. The resulting object is still a tailor, but is now flagged as trained.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>tlr_trained</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://generics.r-lib.org/reference/fit.html'>fit</a></span><span class='o'>(</span></span>
<span>  <span class='nv'>tlr</span>,</span>
<span>  <span class='nv'>two_class_example</span>,</span>
<span>  outcome <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='nv'>truth</span><span class='o'>)</span>,</span>
<span>  estimate <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='nv'>predicted</span><span class='o'>)</span>,</span>
<span>  probabilities <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='nv'>Class1</span>, <span class='nv'>Class2</span><span class='o'>)</span></span>
<span><span class='o'>)</span></span>
<span></span>
<span><span class='nv'>tlr_trained</span></span>
<span><span class='c'>#&gt; </span></span>
<span></span><span><span class='c'>#&gt; <span style='color: #00BBBB;'>──</span> <span style='font-weight: bold;'>tailor</span> <span style='color: #00BBBB;'>──────────────────────────────────────────────────────────────────────</span></span></span>
<span></span><span><span class='c'>#&gt; A binary postprocessor with 1 adjustment:</span></span>
<span></span><span><span class='c'>#&gt; </span></span>
<span></span><span><span class='c'>#&gt; <span style='color: #00BBBB;'>•</span> Adjust probability threshold to 0.7. [trained]</span></span>
<span></span></code></pre>

</div>

When used with a model [workflow](https://workflows.tidymodels.org) via [`add_tailor()`](https://workflows.tidymodels.org/dev/reference/add_tailor.html), the arguments to [`fit()`](https://generics.r-lib.org/reference/fit.html) a tailor will be set automatically. Generally, as in recipes, we recommend that users add tailors to model workflows for training and prediction rather than using them standalone for greater ease of use and to prevent data leakage, but tailors are totally functional by themselves, too.

Now, when passed new data, the trained tailor will determine the outputted class based on whether the probability assigned to the level `"Class1"` is above `.7`, resulting in more predictions of `"Class2"` than before.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://rdrr.io/r/stats/predict.html'>predict</a></span><span class='o'>(</span><span class='nv'>tlr_trained</span>, <span class='nv'>two_class_example</span><span class='o'>)</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span> <span class='nf'>count</span><span class='o'>(</span><span class='nv'>predicted</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 2 × 2</span></span></span>
<span><span class='c'>#&gt;   predicted     n</span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;fct&gt;</span>     <span style='color: #555555; font-style: italic;'>&lt;int&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span> Class1      236</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span> Class2      264</span></span>
<span></span></code></pre>

</div>

Changing the probability threshold is one of many possible adjustments available in tailor.

-   For probabilities: [calibration](https://tailor.tidymodels.org/reference/adjust_probability_calibration.html)
-   For transformation of probabilities to hard class predictions: [thresholds](https://tailor.tidymodels.org/reference/adjust_probability_threshold.html), [equivocal zones](https://tailor.tidymodels.org/reference/adjust_equivocal_zone.html)
-   For numeric outcomes: [calibration](https://tailor.tidymodels.org/reference/adjust_numeric_calibration.html), [range](https://tailor.tidymodels.org/reference/adjust_numeric_range.html)

Support for tailors in now plumbed through workflows (via [`add_tailor()`](https://workflows.tidymodels.org/dev/reference/add_tailor.html)) and tune, and rsample includes a set of infastructural changes to prevent data leakage behind the scenes. That said, we haven't yet implemented support for tuning parameters in tailors, but we plan to implement that before this functionality heads to CRAN.

## Tailors in context

As an example, let's model a study of food delivery times in minutes (i.e., the time from the initial order to receiving the food) for a single restaurant. The `deliveries` data is available upon loading the tidymodels meta-package.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://rdrr.io/r/utils/data.html'>data</a></span><span class='o'>(</span><span class='nv'>deliveries</span><span class='o'>)</span></span>
<span></span>
<span><span class='c'># split into training and testing sets</span></span>
<span><span class='nf'><a href='https://rdrr.io/r/base/Random.html'>set.seed</a></span><span class='o'>(</span><span class='m'>1</span><span class='o'>)</span></span>
<span><span class='nv'>delivery_split</span> <span class='o'>&lt;-</span> <span class='nf'>initial_split</span><span class='o'>(</span><span class='nv'>deliveries</span><span class='o'>)</span></span>
<span><span class='nv'>delivery_train</span> <span class='o'>&lt;-</span> <span class='nf'>training</span><span class='o'>(</span><span class='nv'>delivery_split</span><span class='o'>)</span></span>
<span><span class='nv'>delivery_test</span>  <span class='o'>&lt;-</span> <span class='nf'>testing</span><span class='o'>(</span><span class='nv'>delivery_split</span><span class='o'>)</span></span>
<span></span>
<span><span class='c'># resample the training set using 10-fold cross-validation</span></span>
<span><span class='nf'><a href='https://rdrr.io/r/base/Random.html'>set.seed</a></span><span class='o'>(</span><span class='m'>1</span><span class='o'>)</span></span>
<span><span class='nv'>delivery_folds</span> <span class='o'>&lt;-</span> <span class='nf'>vfold_cv</span><span class='o'>(</span><span class='nv'>delivery_train</span><span class='o'>)</span></span>
<span></span>
<span><span class='c'># print out the training set</span></span>
<span><span class='nv'>delivery_train</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 7,509 × 31</span></span></span>
<span><span class='c'>#&gt;    time_to_delivery  hour day   distance item_01 item_02 item_03 item_04 item_05</span></span>
<span><span class='c'>#&gt;               <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;fct&gt;</span>    <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>   <span style='color: #555555; font-style: italic;'>&lt;int&gt;</span>   <span style='color: #555555; font-style: italic;'>&lt;int&gt;</span>   <span style='color: #555555; font-style: italic;'>&lt;int&gt;</span>   <span style='color: #555555; font-style: italic;'>&lt;int&gt;</span>   <span style='color: #555555; font-style: italic;'>&lt;int&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 1</span>             21.2  16.1 Tue       3.02       0       0       0       0       0</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 2</span>             17.9  12.4 Sun       3.37       0       0       0       0       0</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 3</span>             22.4  14.2 Fri       2.59       0       0       0       0       0</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 4</span>             30.9  19.1 Sat       2.77       0       0       0       0       0</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 5</span>             30.1  16.5 Fri       2.05       0       0       0       1       0</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 6</span>             35.3  14.7 Sat       4.57       0       0       2       1       1</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 7</span>             13.1  11.5 Sat       2.09       0       0       0       0       0</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 8</span>             18.3  13.4 Tue       2.35       0       2       1       0       0</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 9</span>             25.2  20.5 Sat       2.43       0       0       0       1       0</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>10</span>             30.7  16.7 Fri       2.24       0       0       0       1       0</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># ℹ 7,499 more rows</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># ℹ 22 more variables: item_06 &lt;int&gt;, item_07 &lt;int&gt;, item_08 &lt;int&gt;,</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>#   item_09 &lt;int&gt;, item_10 &lt;int&gt;, item_11 &lt;int&gt;, item_12 &lt;int&gt;, item_13 &lt;int&gt;,</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>#   item_14 &lt;int&gt;, item_15 &lt;int&gt;, item_16 &lt;int&gt;, item_17 &lt;int&gt;, item_18 &lt;int&gt;,</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>#   item_19 &lt;int&gt;, item_20 &lt;int&gt;, item_21 &lt;int&gt;, item_22 &lt;int&gt;, item_23 &lt;int&gt;,</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>#   item_24 &lt;int&gt;, item_25 &lt;int&gt;, item_26 &lt;int&gt;, item_27 &lt;int&gt;</span></span></span>
<span></span></code></pre>

</div>

Let's deliberately define a regression model that has poor predicted values: a boosted tree with only three ensemble members.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>delivery_wflow</span> <span class='o'>&lt;-</span></span>
<span>  <span class='nf'>workflow</span><span class='o'>(</span><span class='o'>)</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span></span>
<span>  <span class='nf'>add_formula</span><span class='o'>(</span><span class='nv'>time_to_delivery</span> <span class='o'>~</span> <span class='nv'>.</span><span class='o'>)</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span></span>
<span>  <span class='nf'>add_model</span><span class='o'>(</span><span class='nf'>boost_tree</span><span class='o'>(</span>mode <span class='o'>=</span> <span class='s'>"regression"</span>, trees <span class='o'>=</span> <span class='m'>3</span><span class='o'>)</span><span class='o'>)</span></span></code></pre>

</div>

Evaluating against resamples:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://rdrr.io/r/base/Random.html'>set.seed</a></span><span class='o'>(</span><span class='m'>1</span><span class='o'>)</span></span>
<span><span class='nv'>delivery_res</span> <span class='o'>&lt;-</span> </span>
<span>  <span class='nf'>fit_resamples</span><span class='o'>(</span></span>
<span>    <span class='nv'>delivery_wflow</span>, </span>
<span>    <span class='nv'>delivery_folds</span>, </span>
<span>    control <span class='o'>=</span> <span class='nf'>control_resamples</span><span class='o'>(</span>save_pred <span class='o'>=</span> <span class='kc'>TRUE</span><span class='o'>)</span></span>
<span>  <span class='o'>)</span></span></code></pre>

</div>

The $R^2$ looks quite strong!

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://tune.tidymodels.org/reference/collect_predictions.html'>collect_metrics</a></span><span class='o'>(</span><span class='nv'>delivery_res</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 2 × 6</span></span></span>
<span><span class='c'>#&gt;   .metric .estimator  mean     n std_err .config             </span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>   <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>      <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;int&gt;</span>   <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>               </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span> rmse    standard   9.52     10 0.053<span style='text-decoration: underline;'>3</span>  Preprocessor1_Model1</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span> rsq     standard   0.853    10 0.003<span style='text-decoration: underline;'>57</span> Preprocessor1_Model1</span></span>
<span></span></code></pre>

</div>

Let's take a closer look at the predictions, though. How well is it calibrated? We can use the [`cal_plot_regression()`](https://probably.tidymodels.org/reference/cal_plot_regression.html) helper from the probably package to put together a quick diagnostic plot.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://tune.tidymodels.org/reference/collect_predictions.html'>collect_predictions</a></span><span class='o'>(</span><span class='nv'>delivery_res</span><span class='o'>)</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span></span>
<span>  <span class='nf'><a href='https://probably.tidymodels.org/reference/cal_plot_regression.html'>cal_plot_regression</a></span><span class='o'>(</span>truth <span class='o'>=</span> <span class='nv'>time_to_delivery</span>, estimate <span class='o'>=</span> <span class='nv'>.pred</span><span class='o'>)</span></span>
</code></pre>
<img src="figs/predictions-bad-boost-1.png" width="700px" style="display: block; margin: auto;" />

</div>

Ooof.

In comes tailor! Numeric calibration can help address the correlated errors here. We can add a tailor to our existing workflow to "bump up" predictions towards their true value.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>delivery_wflow_improved</span> <span class='o'>&lt;-</span></span>
<span>  <span class='nv'>delivery_wflow</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span></span>
<span>  <span class='nf'>add_tailor</span><span class='o'>(</span><span class='nf'><a href='https://tailor.tidymodels.org/reference/tailor.html'>tailor</a></span><span class='o'>(</span><span class='o'>)</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span> <span class='nf'><a href='https://tailor.tidymodels.org/reference/adjust_numeric_calibration.html'>adjust_numeric_calibration</a></span><span class='o'>(</span><span class='o'>)</span><span class='o'>)</span></span></code></pre>

</div>

The resampling code looks the same from here.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://rdrr.io/r/base/Random.html'>set.seed</a></span><span class='o'>(</span><span class='m'>1</span><span class='o'>)</span></span>
<span><span class='nv'>delivery_res_improved</span> <span class='o'>&lt;-</span> </span>
<span>  <span class='nf'>fit_resamples</span><span class='o'>(</span></span>
<span>    <span class='nv'>delivery_wflow_improved</span>, </span>
<span>    <span class='nv'>delivery_folds</span>, </span>
<span>    control <span class='o'>=</span> <span class='nf'>control_resamples</span><span class='o'>(</span>save_pred <span class='o'>=</span> <span class='kc'>TRUE</span><span class='o'>)</span></span>
<span>  <span class='o'>)</span></span></code></pre>

</div>

Checking out the same plot reveals a much better fit!

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://tune.tidymodels.org/reference/collect_predictions.html'>collect_predictions</a></span><span class='o'>(</span><span class='nv'>delivery_res_improved</span><span class='o'>)</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span></span>
<span>  <span class='nf'><a href='https://probably.tidymodels.org/reference/cal_plot_regression.html'>cal_plot_regression</a></span><span class='o'>(</span>truth <span class='o'>=</span> <span class='nv'>time_to_delivery</span>, estimate <span class='o'>=</span> <span class='nv'>.pred</span><span class='o'>)</span></span>
</code></pre>
<img src="figs/predictios-better-boost-1.png" width="700px" style="display: block; margin: auto;" />

</div>

There's actually some tricky data leakage prevention happening under the hood here. When you add tailors to workflow and fit them with tune, this is all taken care of for you. If you're interested in using tailors outside of that context, check out [this documentation section](https://workflows.tidymodels.org/dev/reference/add_tailor.html#data-usage) in `add_tailor()`.

## What's to come

We're excited about how this work is shaping up and would love to hear yall's thoughts on what we've brought together so far. Please do comment on our social media posts about this blog entry or leave issues on the [tailor GitHub repository](https://github.com/tidymodels/tailor) and let us know what you think!

Before these changes head out to CRAN, we'll also be implementing tuning functionality for postprocessors. You'll be able to tag arguments like `adjust_probability_threshold(threshold)` or `adjust_probability_calibration(method)` with `tune()` to optimize across several values. Besides that, post-processing with tidymodels should "just work" on the developmental versions of our packages---let us know if you come across anything wonky.

## Acknowledgements

Postprocessing support has been a longstanding feature request across many of our repositories; we're grateful for the community discussions there for shaping this work. Additionally, we thank Ryan Tibshirani and Daniel McDonald for fruitful discussions on how we might scope these features.

