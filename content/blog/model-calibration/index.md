---
output: hugodown::hugo_document

slug: model-calibration
title: Model Calibration
date: 2022-11-17
author: Edgar Ruiz
description: >
    Model Calibration is coming to tidymodels. This post covers the new plotting
    functions, and our plans for future enhancements. 

photo:
  url: https://unsplash.com/photos/s3B_pjK7UIs
  author: Graphic Node

categories: [package]
tags: [model, plots]
rmd_hash: e7249faf84097cf9

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

I am very excited to introduce work currently underway. We are looking to create early awareness, and to receive feedback from the community. That is why the enhancements discussed here are not yet in CRAN.

Even though the article is meant to introduce new package functionality. We also have the goal of introducing model calibration conceptually. We want to provide sufficient background for those who may not be familiar with model calibration. If you are already familiar with this technique, feel free to skip to the [Setup](#example-data) section to get started.

To install the version of probably used here:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'>remotes</span><span class='nf'>::</span><span class='nf'><a href='https://remotes.r-lib.org/reference/install_github.html'>install_github</a></span><span class='o'>(</span><span class='s'>"tidymodels/probably"</span><span class='o'>)</span></span></code></pre>

</div>

## Model Calibration

*The goal of model calibration is to ensure that the estimated class probabilities consistent with what would naturally occur.* If a model has poor calibration, we might be able to post-process the original predictions to coerce them to have better properties.

There are two main components to model calibration:

-   **Diagnosis** - Figuring out how well the original (and re-calibrated) probabilities perform.
-   **Remediation** - Adjusting the original values to have better properties.

### The Development Plan

As with everything in machine learning, there are several options to consider when calibrating a model. Through the new features in the tidymodels packages, we aspire to make those options as easily accessible as possible.

Our plan is to implement model calibration in two phases: The first phase will focus on binary models, and the second phase will focus on multi-class models.

The first batch of enhancements are now available in the development version of the probably package. The enhancements are centered around plotting functions meant for **diagnosing** the prediction's performance. These are more commonly known as **calibration plots**.

## Calibration Plots

The idea behind a calibration plot is that if we group the predictions based on their probability, then we should see an percentage of events [^1] that match such probability.

For example, if we collect a group of the predictions whose probabilities are estimated to be about 10%. We should expect that about 10% of the those in the group to indeed be events. The plots shown below can be used as diagnostics to see if our predictions are consistent with the observed event rates.

### Example Data

If you would like to follow along, load the probably and dplyr packages into you R session.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://tidymodels.tidymodels.org'>tidymodels</a></span><span class='o'>)</span></span>
<span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://github.com/tidymodels/probably/'>probably</a></span><span class='o'>)</span></span></code></pre>

</div>

The probably package comes with a few data sets. For most of the examples in this post, we will use `segment_logistic`. It is an example data set that contains predictions, and their probabilities. `Class` contains the outcome of "good" and "poor", `.pred_good` contains the probability that the event is "good".

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>segment_logistic</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 1,010 × 3</span></span></span>
<span><span class='c'>#&gt;    .pred_poor .pred_good Class</span></span>
<span><span class='c'>#&gt;  <span style='color: #555555;'>*</span>      <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>      <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;fct&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 1</span>    0.986      0.014<span style='text-decoration: underline;'>2</span>  poor </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 2</span>    0.897      0.103   poor </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 3</span>    0.118      0.882   good </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 4</span>    0.102      0.898   good </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 5</span>    0.991      0.009<span style='text-decoration: underline;'>14</span> poor </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 6</span>    0.633      0.367   good </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 7</span>    0.770      0.230   good </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 8</span>    0.008<span style='text-decoration: underline;'>42</span>    0.992   good </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 9</span>    0.995      0.004<span style='text-decoration: underline;'>58</span> poor </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>10</span>    0.765      0.235   poor </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># … with 1,000 more rows</span></span></span></code></pre>

</div>

### Binned Plot

On smaller data sets, it is a challenging to obtain an accurate *event rate* for a given probability. For example, if there are 5 predictions with about a 50% probability, and 3 of those are events, the plot would show a 60% event rate. This comparison would not be appropriate because there are not enough predictions to really determine how close to 50% the model really is.

The most common approach to group the probabilities into bins, or buckets. Usually, the data is split into 10 discrete buckets, from 0 to 1 (0 - 100%). The *event rate* and the *bin midpoint* is calculated for each bin.

In probably, binned calibration plots can be created using [`cal_plot_breaks()`](https://probably.tidymodels.org/reference/cal_plot_breaks.html). It expects a data set, and the un-quoted variable names that contains the events (`truth`), and the probabilities (`estimate`). For the example here, we pass the `segment_logistic` data set, and use `Class` and `.pred_good` as the arguments. By default, this function will create a calibration plot with 10 buckets (breaks):

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>segment_logistic</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span> </span>
<span>  <span class='nf'><a href='https://probably.tidymodels.org/reference/cal_plot_breaks.html'>cal_plot_breaks</a></span><span class='o'>(</span><span class='nv'>Class</span>, <span class='nv'>.pred_good</span><span class='o'>)</span></span>
</code></pre>
<img src="figs/unnamed-chunk-4-1.png" alt="Calibration plot with 10 bins, created with the cal_plot_breaks() function" width="700px" style="display: block; margin: auto;" />

</div>

The calibration plot for the ideal model will essentially be perfect incline line that start at (0,0) and ends in (1,1). In the case of this model, we can see that the seventh point has an event rate of 49.1% despite having estimated probabilities ranging from 60% to 70%. This indicates that the model is not creating predictions in this region that are consistent with the data (i.e., it is under-predicting).

The number of bins in [`cal_plot_breaks()`](https://probably.tidymodels.org/reference/cal_plot_breaks.html) can be adjusted using `num_breaks`. Here is an example of what the plot looks like if we reduce the bins from 10, to 5:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>segment_logistic</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span> </span>
<span>  <span class='nf'><a href='https://probably.tidymodels.org/reference/cal_plot_breaks.html'>cal_plot_breaks</a></span><span class='o'>(</span><span class='nv'>Class</span>, <span class='nv'>.pred_good</span>, num_breaks <span class='o'>=</span> <span class='m'>5</span> <span class='o'>)</span></span>
</code></pre>
<img src="figs/unnamed-chunk-6-1.png" alt="Calibration plot with 5 bins, created with the cal_plot_breaks() function" width="700px" style="display: block; margin: auto;" />

</div>

The number of breaks is a bit like a tuning parameter for these plots and should be based on ensuring that there is enough data in each bin to adequately estimate the observed event rate. If your data are small, the next version of the calibration plot might be a better solution.

### Windowed

Another approach is to use overlapping ranges, or windows. Like the previous plot, we bin the data and calculate the event rate. However, we can add more bins by allowing them to overlap. If the data set size is small, one strategy is to use a set of wide bins that overlap one another.

There are two variables that control the windows. The **step size**, controls the frequency of the windows. If we set a step size of 5%, will create a new window every 5% probability (5%, 10%, 15%... etc). The second argument is the (maximum) **window size**. If it is set to 10%, then a given step will overlap halfway into the previous step, as well as the next step. Here is a visual representation of this specific scenario:

<div class="highlight">

<img src="figs/unnamed-chunk-7-1.png" alt="Plot illustrating the horizontal location of each step and the size of the window" width="70%" style="display: block; margin: auto;" />

</div>

In probably, the [`cal_plot_windowed()`](https://probably.tidymodels.org/reference/cal_plot_breaks.html) function provides this functionality. The default step size is 0.05, and can be changed via the `step_size` argument. The default window size is 0.1, and can be changed via the `window_size` argument.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>segment_logistic</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span> </span>
<span>  <span class='nf'><a href='https://probably.tidymodels.org/reference/cal_plot_breaks.html'>cal_plot_windowed</a></span><span class='o'>(</span><span class='nv'>Class</span>, <span class='nv'>.pred_good</span><span class='o'>)</span></span>
</code></pre>
<img src="figs/unnamed-chunk-8-1.png" alt="Calibration plot with 21 windows, created with the cal_plot_windowed() function" width="700px" style="display: block; margin: auto;" />

</div>

Here is an example of reducing the `step_size` from 0.05, to 0.02. There are more than double the windows:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>segment_logistic</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span> </span>
<span>  <span class='nf'><a href='https://probably.tidymodels.org/reference/cal_plot_breaks.html'>cal_plot_windowed</a></span><span class='o'>(</span><span class='nv'>Class</span>, <span class='nv'>.pred_good</span>, step_size <span class='o'>=</span> <span class='m'>0.02</span><span class='o'>)</span></span>
</code></pre>
<img src="figs/unnamed-chunk-9-1.png" alt="Calibration plot with more steps than the default, created with the cal_plot_windowed() function" width="700px" style="display: block; margin: auto;" />

</div>

### Model-Based

Another way to visualize the performance is to fit a classification model of the events against the estimated probabilities. This is helpful because it avoids the use of pre-determined groupings. Another difference, is that we are not plotting midpoints of actual results, but rather predictions based on those results.

The [`cal_plot_logistic()`](https://probably.tidymodels.org/reference/cal_plot_breaks.html) provides this functionality. By default, it uses a logistic regression. There are two possible methods for fitting:

spline model, provided by the `mgcv` package. The idea is to visualize a smooth line based on the predictions based on the `smooth` argument:

-   `smooth = TRUE` (the default) fits a generalized additive model using splines. This allows for more flexible model fits.
-   `smooth = FALSE` uses an ordinary logistic regression model with linear terms for the predictor.

As an example:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>segment_logistic</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span> </span>
<span>  <span class='nf'><a href='https://probably.tidymodels.org/reference/cal_plot_breaks.html'>cal_plot_logistic</a></span><span class='o'>(</span><span class='nv'>Class</span>, <span class='nv'>.pred_good</span><span class='o'>)</span></span>
</code></pre>
<img src="figs/unnamed-chunk-10-1.png" alt="Logistic Spline calibration plot, created with the cal_plot_logistic() function" width="700px" style="display: block; margin: auto;" />

</div>

The cooresponding [`glm()`](https://rdrr.io/r/stats/glm.html) model produces:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>segment_logistic</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span> </span>
<span>  <span class='nf'><a href='https://probably.tidymodels.org/reference/cal_plot_breaks.html'>cal_plot_logistic</a></span><span class='o'>(</span><span class='nv'>Class</span>, <span class='nv'>.pred_good</span>, smooth <span class='o'>=</span> <span class='kc'>FALSE</span><span class='o'>)</span></span>
</code></pre>
<img src="figs/unnamed-chunk-11-1.png" alt="Ordinary logistic calibration plot, created with the cal_plot_logistic() function" width="700px" style="display: block; margin: auto;" />

</div>

### Additional options and features

#### Intervals

The confidence intervals are visualized using the gray ribbon. The default interval is 0.9, but can be changed using the `conf_level` argument.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>segment_logistic</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span> </span>
<span>  <span class='nf'><a href='https://probably.tidymodels.org/reference/cal_plot_breaks.html'>cal_plot_breaks</a></span><span class='o'>(</span><span class='nv'>Class</span>, <span class='nv'>.pred_good</span>, conf_level <span class='o'>=</span> <span class='m'>0.8</span><span class='o'>)</span></span>
</code></pre>
<img src="figs/unnamed-chunk-12-1.png" alt="Calibration plot with a confidence interval set to 0.8" width="700px" style="display: block; margin: auto;" />

</div>

If desired, the intervals can be removed by setting the `include_ribbon` argument to `FALSE`.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>segment_logistic</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span> </span>
<span>  <span class='nf'><a href='https://probably.tidymodels.org/reference/cal_plot_breaks.html'>cal_plot_breaks</a></span><span class='o'>(</span><span class='nv'>Class</span>, <span class='nv'>.pred_good</span>, include_ribbon <span class='o'>=</span> <span class='kc'>FALSE</span><span class='o'>)</span></span>
</code></pre>
<img src="figs/unnamed-chunk-13-1.png" alt="Calibration plot with the confidence interval ribbon turned off" width="700px" style="display: block; margin: auto;" />

</div>

#### Rugs

By default, the calibration plots include a RUGs layer at the top and at the bottom of the visualization. They are meant to give us an idea of the density of events, versus the density of non-events as the probabilities progress from 0 to 1.

<div class="highlight">

<img src="figs/unnamed-chunk-14-1.png" alt="Calibration plot with arrows pointing to where the RUGS plots are placed in the graph" width="700px" style="display: block; margin: auto;" />

</div>

This can layer can be removed by setting `include_rug` to `FALSE`:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>segment_logistic</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span> </span>
<span>  <span class='nf'><a href='https://probably.tidymodels.org/reference/cal_plot_breaks.html'>cal_plot_breaks</a></span><span class='o'>(</span><span class='nv'>Class</span>, <span class='nv'>.pred_good</span>, include_rug <span class='o'>=</span> <span class='kc'>FALSE</span><span class='o'>)</span> </span>
</code></pre>
<img src="figs/unnamed-chunk-15-1.png" alt="Calibration plot without RUGS" width="700px" style="display: block; margin: auto;" />

</div>

## Integration with tune

So far, the inputs to the functions have been data frames. In tidymodels, the tune package has methods for resampling models as well as functions for tuning hyperparameters.

The calibration plots in probably also support the results of these functions (with class `tune_results`). The functions read the metadata from the tune object, and the `truth` and `estimate` arguments automatically.

To showcase this feature, we will tune a model based on simulated data. In order for the calibration plot to work, the predictions need to be collected. This is done by setting `save_pred` to `TRUE`.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://rdrr.io/r/base/Random.html'>set.seed</a></span><span class='o'>(</span><span class='m'>111</span><span class='o'>)</span></span>
<span><span class='nv'>sim_data</span> <span class='o'>&lt;-</span> <span class='nf'>sim_classification</span><span class='o'>(</span><span class='m'>500</span><span class='o'>)</span></span>
<span><span class='nv'>sim_folds</span> <span class='o'>&lt;-</span> <span class='nf'>vfold_cv</span><span class='o'>(</span><span class='nv'>sim_data</span>, repeats <span class='o'>=</span> <span class='m'>3</span><span class='o'>)</span></span>
<span></span>
<span><span class='nv'>rf_mod</span> <span class='o'>&lt;-</span> <span class='nf'>rand_forest</span><span class='o'>(</span>min_n <span class='o'>=</span> <span class='nf'>tune</span><span class='o'>(</span><span class='o'>)</span><span class='o'>)</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span> <span class='nf'>set_mode</span><span class='o'>(</span><span class='s'>"classification"</span><span class='o'>)</span></span>
<span></span>
<span><span class='nf'><a href='https://rdrr.io/r/base/Random.html'>set.seed</a></span><span class='o'>(</span><span class='m'>222</span><span class='o'>)</span></span>
<span><span class='nv'>tuned_model</span> <span class='o'>&lt;-</span> </span>
<span>  <span class='nv'>rf_mod</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span> </span>
<span>  <span class='nf'>tune_grid</span><span class='o'>(</span></span>
<span>    <span class='nv'>class</span> <span class='o'>~</span> <span class='nv'>.</span>,</span>
<span>    resamples <span class='o'>=</span> <span class='nv'>sim_folds</span>,</span>
<span>    grid <span class='o'>=</span> <span class='m'>4</span>,</span>
<span>    <span class='c'># Important: `saved_pred` has to be set to TRUE in order for </span></span>
<span>    <span class='c'># the plotting to be possible</span></span>
<span>    control <span class='o'>=</span> <span class='nf'>control_resamples</span><span class='o'>(</span>save_pred <span class='o'>=</span> <span class='kc'>TRUE</span><span class='o'>)</span></span>
<span>  <span class='o'>)</span></span>
<span></span>
<span><span class='nv'>tuned_model</span></span>
<span><span class='c'>#&gt; # Tuning results</span></span>
<span><span class='c'>#&gt; # 10-fold cross-validation repeated 3 times </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 30 × 6</span></span></span>
<span><span class='c'>#&gt;    splits           id      id2    .metrics         .notes           .predicti…¹</span></span>
<span><span class='c'>#&gt;    <span style='color: #555555; font-style: italic;'>&lt;list&gt;</span>           <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>   <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>  <span style='color: #555555; font-style: italic;'>&lt;list&gt;</span>           <span style='color: #555555; font-style: italic;'>&lt;list&gt;</span>           <span style='color: #555555; font-style: italic;'>&lt;list&gt;</span>     </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 1</span> <span style='color: #555555;'>&lt;split [450/50]&gt;</span> Repeat1 Fold01 <span style='color: #555555;'>&lt;tibble [8 × 5]&gt;</span> <span style='color: #555555;'>&lt;tibble [0 × 3]&gt;</span> &lt;tibble&gt;   </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 2</span> <span style='color: #555555;'>&lt;split [450/50]&gt;</span> Repeat1 Fold02 <span style='color: #555555;'>&lt;tibble [8 × 5]&gt;</span> <span style='color: #555555;'>&lt;tibble [0 × 3]&gt;</span> &lt;tibble&gt;   </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 3</span> <span style='color: #555555;'>&lt;split [450/50]&gt;</span> Repeat1 Fold03 <span style='color: #555555;'>&lt;tibble [8 × 5]&gt;</span> <span style='color: #555555;'>&lt;tibble [0 × 3]&gt;</span> &lt;tibble&gt;   </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 4</span> <span style='color: #555555;'>&lt;split [450/50]&gt;</span> Repeat1 Fold04 <span style='color: #555555;'>&lt;tibble [8 × 5]&gt;</span> <span style='color: #555555;'>&lt;tibble [0 × 3]&gt;</span> &lt;tibble&gt;   </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 5</span> <span style='color: #555555;'>&lt;split [450/50]&gt;</span> Repeat1 Fold05 <span style='color: #555555;'>&lt;tibble [8 × 5]&gt;</span> <span style='color: #555555;'>&lt;tibble [0 × 3]&gt;</span> &lt;tibble&gt;   </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 6</span> <span style='color: #555555;'>&lt;split [450/50]&gt;</span> Repeat1 Fold06 <span style='color: #555555;'>&lt;tibble [8 × 5]&gt;</span> <span style='color: #555555;'>&lt;tibble [0 × 3]&gt;</span> &lt;tibble&gt;   </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 7</span> <span style='color: #555555;'>&lt;split [450/50]&gt;</span> Repeat1 Fold07 <span style='color: #555555;'>&lt;tibble [8 × 5]&gt;</span> <span style='color: #555555;'>&lt;tibble [0 × 3]&gt;</span> &lt;tibble&gt;   </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 8</span> <span style='color: #555555;'>&lt;split [450/50]&gt;</span> Repeat1 Fold08 <span style='color: #555555;'>&lt;tibble [8 × 5]&gt;</span> <span style='color: #555555;'>&lt;tibble [0 × 3]&gt;</span> &lt;tibble&gt;   </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 9</span> <span style='color: #555555;'>&lt;split [450/50]&gt;</span> Repeat1 Fold09 <span style='color: #555555;'>&lt;tibble [8 × 5]&gt;</span> <span style='color: #555555;'>&lt;tibble [0 × 3]&gt;</span> &lt;tibble&gt;   </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>10</span> <span style='color: #555555;'>&lt;split [450/50]&gt;</span> Repeat1 Fold10 <span style='color: #555555;'>&lt;tibble [8 × 5]&gt;</span> <span style='color: #555555;'>&lt;tibble [0 × 3]&gt;</span> &lt;tibble&gt;   </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># … with 20 more rows, and abbreviated variable name ¹​.predictions</span></span></span></code></pre>

</div>

The plotting functions will automatically collect the predictions. Each of the pre-processing groups will be plotted individually in its own facet.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>tuned_model</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span> </span>
<span>  <span class='nf'><a href='https://probably.tidymodels.org/reference/cal_plot_breaks.html'>cal_plot_logistic</a></span><span class='o'>(</span><span class='o'>)</span> </span>
</code></pre>
<img src="figs/unnamed-chunk-17-1.png" alt="Multiple calibration plots presented in a grid" width="700px" style="display: block; margin: auto;" />

</div>

A panel is produced for each value of `min_n`, coded with a automatically generated configuration name. This makes sure to use the out-of-sample data to make the plot (instead of just re-predicting the training set).

## Preparing for the next stage

As mentioned in the outset of this post, the goal is to also provide a way to calibrate the model, and to apply the calibration to future predictions. We have made sure that the plotting functions are ready now to accept multiple probability sets.

In this post, we will showcase that functionality by "manually" creating a quick calibration model, we we can use it to compare to the original probabilities. We will need both of them to be on the same data frame, and to have a way of distinguishing the original probabilities from the calibrated probabilities. In this case we will create a variable called `source`:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>model</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/stats/glm.html'>glm</a></span><span class='o'>(</span><span class='nv'>Class</span> <span class='o'>~</span> <span class='nv'>.pred_good</span>, <span class='nv'>segment_logistic</span>, family <span class='o'>=</span> <span class='s'>"binomial"</span><span class='o'>)</span></span>
<span></span>
<span><span class='nv'>preds</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/stats/predict.html'>predict</a></span><span class='o'>(</span><span class='nv'>model</span>, <span class='nv'>segment_logistic</span>, type <span class='o'>=</span> <span class='s'>"response"</span><span class='o'>)</span></span>
<span>  </span>
<span><span class='nv'>combined</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://dplyr.tidyverse.org/reference/bind.html'>bind_rows</a></span><span class='o'>(</span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/mutate.html'>mutate</a></span><span class='o'>(</span><span class='nv'>segment_logistic</span>, source <span class='o'>=</span> <span class='s'>"original"</span><span class='o'>)</span>, </span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/mutate.html'>mutate</a></span><span class='o'>(</span><span class='nv'>segment_logistic</span>, .pred_good <span class='o'>=</span> <span class='m'>1</span> <span class='o'>-</span> <span class='nv'>preds</span>, source <span class='o'>=</span> <span class='s'>"glm"</span><span class='o'>)</span></span>
<span>  <span class='o'>)</span></span>
<span></span>
<span><span class='nv'>combined</span> </span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 2,020 × 4</span></span></span>
<span><span class='c'>#&gt;    .pred_poor .pred_good Class source  </span></span>
<span><span class='c'>#&gt;         <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>      <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;fct&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>   </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 1</span>    0.986      0.014<span style='text-decoration: underline;'>2</span>  poor  original</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 2</span>    0.897      0.103   poor  original</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 3</span>    0.118      0.882   good  original</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 4</span>    0.102      0.898   good  original</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 5</span>    0.991      0.009<span style='text-decoration: underline;'>14</span> poor  original</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 6</span>    0.633      0.367   good  original</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 7</span>    0.770      0.230   good  original</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 8</span>    0.008<span style='text-decoration: underline;'>42</span>    0.992   good  original</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 9</span>    0.995      0.004<span style='text-decoration: underline;'>58</span> poor  original</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>10</span>    0.765      0.235   poor  original</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># … with 2,010 more rows</span></span></span></code></pre>

</div>

The new plot functions support dplyr groupings. So, to overlay the two groups, we just need to pass `source` to [`group_by()`](https://dplyr.tidyverse.org/reference/group_by.html):

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>combined</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/group_by.html'>group_by</a></span><span class='o'>(</span><span class='nv'>source</span><span class='o'>)</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span></span>
<span>  <span class='nf'><a href='https://probably.tidymodels.org/reference/cal_plot_breaks.html'>cal_plot_breaks</a></span><span class='o'>(</span><span class='nv'>Class</span>, <span class='nv'>.pred_good</span><span class='o'>)</span></span>
</code></pre>
<img src="figs/unnamed-chunk-19-1.png" alt="Calibration plot with two overlaying probability trends, one is the original and the second is the model" width="700px" style="display: block; margin: auto;" />

</div>

If we would like to plot them side by side, we can add [`facet_wrap()`](https://ggplot2.tidyverse.org/reference/facet_wrap.html) as an additional step of the plot:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>combined</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span> </span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/group_by.html'>group_by</a></span><span class='o'>(</span><span class='nv'>source</span><span class='o'>)</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span> </span>
<span>  <span class='nf'><a href='https://probably.tidymodels.org/reference/cal_plot_breaks.html'>cal_plot_breaks</a></span><span class='o'>(</span><span class='nv'>Class</span>, <span class='nv'>.pred_good</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/facet_wrap.html'>facet_wrap</a></span><span class='o'>(</span><span class='o'>~</span><span class='nv'>source</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/theme.html'>theme</a></span><span class='o'>(</span>legend.position <span class='o'>=</span> <span class='s'>"none"</span><span class='o'>)</span></span>
</code></pre>
<img src="figs/unnamed-chunk-20-1.png" alt="Calibration plot with two side-by-side probability trends" width="700px" style="display: block; margin: auto;" />

</div>

Our goal in the future is to provide calibration functions that create the models, and provide an easy way to visualize.

## Conclusion

As mentioned at the top of this post. We look forward to your feedback as you try out these features, and read about our plans for the new future. If you wish to send us your thoughts, feel free to open an issue in probably's GitHub repo here: <https://github.com/tidymodels/probably/issues>.

[^1]: We can think of an **event** as the outcome that is being tracked by the probability. For example, in a model predicting "heads" or "tails", and we want to calibrate the probability for "tails", then the **event** is when the column containing the outcome, has the value of "tails".

