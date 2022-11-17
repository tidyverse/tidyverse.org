---
output: hugodown::hugo_document

slug: model-calibration
title: Model Calibration
date: 2022-11-17
author: Edgar Ruiz
description: >
    Model Calibration is coming to Tidymodels. This post covers the new plotting
    functions, and our plans for future enhancements. 

photo:
  url: https://unsplash.com/photos/n6vS3xlnsCc
  author: Bubbles the Puppy :) 

categories: [package]
tags: [model, plots]
rmd_hash: 798ea152dccc6383

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

## Model Calibration

*The goal of Model Calibration is to improve the accuracy of predictions.* It does this by adjusting the prediction's probabilities. Meaning that the predicted outcome may change based on the established threshold.

For example, a prediction could say that it is 60% certain of a result of "Yes". But, after applying the calibration, the new probability is now 45%. If the threshold is set to 50%, the new predicted outcome is now set to "No".

There are two main components to Model Calibration:

-   **Diagnosis** - Figuring out how well the original, and calibrated probabilities perform
-   **Remediation** - Calculating, and applying the calibration

## The plan

As with everything in machine learning, there are several options to consider when calibrating a model. Through the new features in the Tidymodels packages, we aspire to make those options as easily accessible as possible.

Our plan is to implement Model Calibration in two phases: The first phase will focus on binary models, and the second phase will focus on multi-class models.

The first batch of enhancements are now available in the development version of `probably`. The enhancements are centered around plotting functions meant for **diagnosing** the prediction's performance. These are more commonly known as **Calibration Plots**.

## Setup

If you wish to try out the new features, install the development version of `probably`

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'>remotes</span><span class='nf'>::</span><span class='nf'><a href='https://remotes.r-lib.org/reference/install_github.html'>install_github</a></span><span class='o'>(</span><span class='s'>"tidymodels/probably"</span><span class='o'>)</span></span></code></pre>

</div>

To start, we will load the `probably` and `dplyr` packages into our R session.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://github.com/tidymodels/probably/'>probably</a></span><span class='o'>)</span></span>
<span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://dplyr.tidyverse.org'>dplyr</a></span><span class='o'>)</span></span></code></pre>

</div>

`probably` comes with a few data sets. For most of the examples in this post, we will use `segment_logistic`. It is an example data set that contains predictions, and their probabilities.

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

## Breaks (Bins)

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>segment_logistic</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span> </span>
<span>  <span class='nf'><a href='https://probably.tidymodels.org/reference/cal_plot_breaks.html'>cal_plot_breaks</a></span><span class='o'>(</span><span class='nv'>Class</span>, <span class='nv'>.pred_good</span><span class='o'>)</span></span>
</code></pre>
<img src="figs/unnamed-chunk-4-1.png" width="700px" style="display: block; margin: auto;" />

</div>

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>segment_logistic</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span> </span>
<span>  <span class='nf'><a href='https://probably.tidymodels.org/reference/cal_plot_breaks.html'>cal_plot_breaks</a></span><span class='o'>(</span><span class='nv'>Class</span>, <span class='nv'>.pred_good</span>, num_breaks <span class='o'>=</span> <span class='m'>5</span><span class='o'>)</span></span>
</code></pre>
<img src="figs/unnamed-chunk-5-1.png" width="700px" style="display: block; margin: auto;" />

</div>

## Logistic

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>segment_logistic</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span> </span>
<span>  <span class='nf'><a href='https://probably.tidymodels.org/reference/cal_plot_breaks.html'>cal_plot_logistic</a></span><span class='o'>(</span><span class='nv'>Class</span>, <span class='nv'>.pred_good</span><span class='o'>)</span></span>
</code></pre>
<img src="figs/unnamed-chunk-6-1.png" width="700px" style="display: block; margin: auto;" />

</div>

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>segment_logistic</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span> </span>
<span>  <span class='nf'><a href='https://probably.tidymodels.org/reference/cal_plot_breaks.html'>cal_plot_logistic</a></span><span class='o'>(</span><span class='nv'>Class</span>, <span class='nv'>.pred_good</span>, smooth <span class='o'>=</span> <span class='kc'>FALSE</span><span class='o'>)</span></span>
</code></pre>
<img src="figs/unnamed-chunk-7-1.png" width="700px" style="display: block; margin: auto;" />

</div>

## Windowed

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>segment_logistic</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span> </span>
<span>  <span class='nf'><a href='https://probably.tidymodels.org/reference/cal_plot_breaks.html'>cal_plot_windowed</a></span><span class='o'>(</span><span class='nv'>Class</span>, <span class='nv'>.pred_good</span><span class='o'>)</span></span>
</code></pre>
<img src="figs/unnamed-chunk-9-1.png" width="700px" style="display: block; margin: auto;" />

</div>

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>segment_logistic</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span> </span>
<span>  <span class='nf'><a href='https://probably.tidymodels.org/reference/cal_plot_breaks.html'>cal_plot_windowed</a></span><span class='o'>(</span><span class='nv'>Class</span>, <span class='nv'>.pred_good</span>, step_size <span class='o'>=</span> <span class='m'>0.1</span><span class='o'>)</span></span>
</code></pre>
<img src="figs/unnamed-chunk-10-1.png" width="700px" style="display: block; margin: auto;" />

</div>

## Additional options

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>segment_logistic</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span> </span>
<span>  <span class='nf'><a href='https://probably.tidymodels.org/reference/cal_plot_breaks.html'>cal_plot_breaks</a></span><span class='o'>(</span><span class='nv'>Class</span>, <span class='nv'>.pred_good</span>, conf_level <span class='o'>=</span> <span class='m'>0.8</span><span class='o'>)</span></span>
</code></pre>
<img src="figs/unnamed-chunk-11-1.png" width="700px" style="display: block; margin: auto;" />

</div>

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>segment_logistic</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span> </span>
<span>  <span class='nf'><a href='https://probably.tidymodels.org/reference/cal_plot_breaks.html'>cal_plot_windowed</a></span><span class='o'>(</span><span class='nv'>Class</span>, <span class='nv'>.pred_good</span>, include_points <span class='o'>=</span> <span class='kc'>FALSE</span><span class='o'>)</span></span>
</code></pre>
<img src="figs/unnamed-chunk-12-1.png" width="700px" style="display: block; margin: auto;" />

</div>

## `tune` results

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://tidymodels.tidymodels.org'>tidymodels</a></span><span class='o'>)</span></span>
<span></span>
<span><span class='nf'><a href='https://rdrr.io/r/base/Random.html'>set.seed</a></span><span class='o'>(</span><span class='m'>111</span><span class='o'>)</span></span>
<span></span>
<span><span class='nv'>sim_data</span> <span class='o'>&lt;-</span> <span class='nf'>sim_classification</span><span class='o'>(</span><span class='m'>500</span><span class='o'>)</span></span>
<span></span>
<span><span class='nv'>rec</span> <span class='o'>&lt;-</span> <span class='nf'>recipe</span><span class='o'>(</span><span class='nv'>class</span> <span class='o'>~</span> <span class='nv'>.</span>, data <span class='o'>=</span> <span class='nv'>sim_data</span><span class='o'>)</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span></span>
<span>  <span class='nf'>step_ns</span><span class='o'>(</span><span class='nv'>linear_01</span>, deg_free <span class='o'>=</span> <span class='nf'>tune</span><span class='o'>(</span><span class='s'>"linear_01"</span><span class='o'>)</span><span class='o'>)</span></span>
<span></span>
<span><span class='nv'>tuned_model</span> <span class='o'>&lt;-</span> <span class='nf'>tune_grid</span><span class='o'>(</span></span>
<span>  object <span class='o'>=</span> <span class='nf'>set_engine</span><span class='o'>(</span><span class='nf'>logistic_reg</span><span class='o'>(</span><span class='o'>)</span>, <span class='s'>"glm"</span><span class='o'>)</span>,</span>
<span>  preprocessor <span class='o'>=</span> <span class='nv'>rec</span>,</span>
<span>  resamples <span class='o'>=</span> <span class='nf'>vfold_cv</span><span class='o'>(</span><span class='nv'>sim_data</span>, v <span class='o'>=</span> <span class='m'>2</span>, repeats <span class='o'>=</span> <span class='m'>3</span><span class='o'>)</span>,</span>
<span>  control <span class='o'>=</span> <span class='nf'>control_resamples</span><span class='o'>(</span>save_pred <span class='o'>=</span> <span class='kc'>TRUE</span><span class='o'>)</span></span>
<span><span class='o'>)</span></span></code></pre>

</div>

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>tuned_model</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span> </span>
<span>  <span class='nf'><a href='https://probably.tidymodels.org/reference/cal_plot_breaks.html'>cal_plot_breaks</a></span><span class='o'>(</span><span class='o'>)</span></span></code></pre>

</div>

## Getting ready for the next stage

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

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>combined</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/group_by.html'>group_by</a></span><span class='o'>(</span><span class='nv'>source</span><span class='o'>)</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span></span>
<span>  <span class='nf'><a href='https://probably.tidymodels.org/reference/cal_plot_breaks.html'>cal_plot_breaks</a></span><span class='o'>(</span><span class='nv'>Class</span>, <span class='nv'>.pred_good</span><span class='o'>)</span></span>
</code></pre>
<img src="figs/unnamed-chunk-16-1.png" width="700px" style="display: block; margin: auto;" />

</div>

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>combined</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span> </span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/group_by.html'>group_by</a></span><span class='o'>(</span><span class='nv'>source</span><span class='o'>)</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span> </span>
<span>  <span class='nf'><a href='https://probably.tidymodels.org/reference/cal_plot_breaks.html'>cal_plot_breaks</a></span><span class='o'>(</span><span class='nv'>Class</span>, <span class='nv'>.pred_good</span><span class='o'>)</span></span>
</code></pre>
<img src="figs/unnamed-chunk-17-1.png" width="700px" style="display: block; margin: auto;" />

</div>

