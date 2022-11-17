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
rmd_hash: d93d1d96e46ea8cf

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

I am very excited to introduce the work currently underway. These changes are not yet in the CRAN versions of the packages. We opted to write this post to create early awareness, and to recieve feedback from the community. For Model Calibration, the main driver will be the `probably` package, but there is an upcoming update to `yardstick` that will also apply to the calibration process.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'>remotes</span><span class='nf'>::</span><span class='nf'><a href='https://remotes.r-lib.org/reference/install_github.html'>install_github</a></span><span class='o'>(</span><span class='s'>"tidymodels/probably"</span><span class='o'>)</span></span></code></pre>

</div>

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://github.com/tidymodels/probably/'>probably</a></span><span class='o'>)</span></span>
<span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://dplyr.tidyverse.org'>dplyr</a></span><span class='o'>)</span></span></code></pre>

</div>

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

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://rdrr.io/r/base/Random.html'>set.seed</a></span><span class='o'>(</span><span class='m'>111</span><span class='o'>)</span></span>
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
<span>  <span class='nf'><a href='https://probably.tidymodels.org/reference/cal_plot_breaks.html'>cal_plot_breaks</a></span><span class='o'>(</span><span class='o'>)</span></span>
</code></pre>
<img src="figs/unnamed-chunk-14-1.png" width="700px" style="display: block; margin: auto;" />

</div>

