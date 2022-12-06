---
output: hugodown::hugo_document

slug: tidyclust-0-1-0
title: tidyclust is on CRAN
date: 2022-12-06
author: Emil Hvitfeldt
description: >
    Tidyclust is on CRAN. tidyclust provides a common interface for specifying 
    clustering models, in the same style as parsnip.

photo:
  url: https://unsplash.com/photos/4Xy08NbMBLM
  author: Ankush Minda

# one of: "deep-dive", "learn", "package", "programming", "roundup", or "other"
categories: [package] 
tags: [tidymodels, tidyclust]
rmd_hash: cdd426cca2591870

---

<!--
TODO:
* [X] Look over / edit the post's title in the yaml
* [X] Edit (or delete) the description; note this appears in the Twitter card
* [X] Pick category and tags (see existing with [`hugodown::tidy_show_meta()`](https://rdrr.io/pkg/hugodown/man/use_tidy_post.html))
* [X] Find photo & update yaml metadata
* [X] Create `thumbnail-sq.jpg`; height and width should be equal
* [X] Create `thumbnail-wd.jpg`; width should be >5x height
* [X] [`hugodown::use_tidy_thumbnails()`](https://rdrr.io/pkg/hugodown/man/use_tidy_post.html)
* [X] Add intro sentence, e.g. the standard tagline for the package
* [X] [`usethis::use_tidy_thanks()`](https://usethis.r-lib.org/reference/use_tidy_thanks.html)
-->

We're very pleased to announce the release of [tidyclust](https://tidyclust.tidymodels.org/) 0.1.0. tidyclust is the tidymodels extension for working with clustering models. This package wouldn't have been possible without the great work of [Kelly Bodwin](https://twitter.com/KellyBodwin).

You can install it from CRAN with:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://rdrr.io/r/utils/install.packages.html'>install.packages</a></span><span class='o'>(</span><span class='s'>"tidyclust"</span><span class='o'>)</span></span></code></pre>

</div>

This blog post will introduce tidyclust, how to use it with the rest of tidymodels, and how we can interact and evaluate the fitted clustering models.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://tidymodels.tidymodels.org'>tidymodels</a></span><span class='o'>)</span> </span>
<span><span class='c'>#&gt; ── <span style='font-weight: bold;'>Attaching packages</span> ────────────────────────────────────── tidymodels 1.0.0 ──</span></span>
<span></span><span><span class='c'>#&gt; <span style='color: #00BB00;'>✔</span> <span style='color: #0000BB;'>broom       </span> 1.0.1      <span style='color: #00BB00;'>✔</span> <span style='color: #0000BB;'>recipes     </span> 1.0.3 </span></span>
<span><span class='c'>#&gt; <span style='color: #00BB00;'>✔</span> <span style='color: #0000BB;'>dials       </span> 1.1.0      <span style='color: #00BB00;'>✔</span> <span style='color: #0000BB;'>rsample     </span> 1.1.0 </span></span>
<span><span class='c'>#&gt; <span style='color: #00BB00;'>✔</span> <span style='color: #0000BB;'>dplyr       </span> 1.0.10     <span style='color: #00BB00;'>✔</span> <span style='color: #0000BB;'>tibble      </span> 3.1.8 </span></span>
<span><span class='c'>#&gt; <span style='color: #00BB00;'>✔</span> <span style='color: #0000BB;'>ggplot2     </span> 3.4.0      <span style='color: #00BB00;'>✔</span> <span style='color: #0000BB;'>tidyr       </span> 1.2.1 </span></span>
<span><span class='c'>#&gt; <span style='color: #00BB00;'>✔</span> <span style='color: #0000BB;'>infer       </span> 1.0.4      <span style='color: #00BB00;'>✔</span> <span style='color: #0000BB;'>tune        </span> 1.0.1 </span></span>
<span><span class='c'>#&gt; <span style='color: #00BB00;'>✔</span> <span style='color: #0000BB;'>modeldata   </span> 1.0.1      <span style='color: #00BB00;'>✔</span> <span style='color: #0000BB;'>workflows   </span> 1.1.2 </span></span>
<span><span class='c'>#&gt; <span style='color: #00BB00;'>✔</span> <span style='color: #0000BB;'>parsnip     </span> 1.0.3      <span style='color: #00BB00;'>✔</span> <span style='color: #0000BB;'>workflowsets</span> 1.0.0 </span></span>
<span><span class='c'>#&gt; <span style='color: #00BB00;'>✔</span> <span style='color: #0000BB;'>purrr       </span> 0.3.5      <span style='color: #00BB00;'>✔</span> <span style='color: #0000BB;'>yardstick   </span> 1.1.0</span></span>
<span></span><span><span class='c'>#&gt; ── <span style='font-weight: bold;'>Conflicts</span> ───────────────────────────────────────── tidymodels_conflicts() ──</span></span>
<span><span class='c'>#&gt; <span style='color: #BB0000;'>✖</span> <span style='color: #0000BB;'>purrr</span>::<span style='color: #00BB00;'>discard()</span> masks <span style='color: #0000BB;'>scales</span>::discard()</span></span>
<span><span class='c'>#&gt; <span style='color: #BB0000;'>✖</span> <span style='color: #0000BB;'>dplyr</span>::<span style='color: #00BB00;'>filter()</span>  masks <span style='color: #0000BB;'>stats</span>::filter()</span></span>
<span><span class='c'>#&gt; <span style='color: #BB0000;'>✖</span> <span style='color: #0000BB;'>dplyr</span>::<span style='color: #00BB00;'>lag()</span>     masks <span style='color: #0000BB;'>stats</span>::lag()</span></span>
<span><span class='c'>#&gt; <span style='color: #BB0000;'>✖</span> <span style='color: #0000BB;'>recipes</span>::<span style='color: #00BB00;'>step()</span>  masks <span style='color: #0000BB;'>stats</span>::step()</span></span>
<span><span class='c'>#&gt; <span style='color: #0000BB;'>•</span> Search for functions across packages at <span style='color: #00BB00;'>https://www.tidymodels.org/find/</span></span></span>
<span></span><span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://github.com/tidymodels/tidyclust'>tidyclust</a></span><span class='o'>)</span></span></code></pre>

</div>

## Specifying clustering models

The first thing we need to do is decide on the type of clustering model we want to fit. The pkgdown site provides a [list of all clustering specifications](https://tidyclust.tidymodels.org/reference/index.html#specifications) provided by tidyclust. We are slowly adding more types of models---[suggestions in issues](https://github.com/tidymodels/tidyclust/issues) are highly welcome!

We will use a K-Means model for these examples using [`k_means()`](https://rdrr.io/pkg/tidyclust/man/k_means.html) to create a specification. As with other packages in the tidymodels, tidyclust tries to make use of informative names for functions and arguments; as such, the argument denoting the number of clusters is `num_clusters` rather than `k`.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>kmeans_spec</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/pkg/tidyclust/man/k_means.html'>k_means</a></span><span class='o'>(</span>num_clusters <span class='o'>=</span> <span class='m'>4</span><span class='o'>)</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span></span>
<span>  <span class='nf'><a href='https://parsnip.tidymodels.org/reference/set_engine.html'>set_engine</a></span><span class='o'>(</span><span class='s'>"ClusterR"</span><span class='o'>)</span></span>
<span><span class='nv'>kmeans_spec</span></span>
<span><span class='c'>#&gt; K Means Cluster Specification (partition)</span></span>
<span><span class='c'>#&gt; </span></span>
<span><span class='c'>#&gt; Main Arguments:</span></span>
<span><span class='c'>#&gt;   num_clusters = 4</span></span>
<span><span class='c'>#&gt; </span></span>
<span><span class='c'>#&gt; Computational engine: ClusterR</span></span>
<span></span></code></pre>

</div>

We can use the [`set_engine()`](https://parsnip.tidymodels.org/reference/set_engine.html), [`set_mode()`](https://parsnip.tidymodels.org/reference/set_args.html), and [`set_args()`](https://parsnip.tidymodels.org/reference/set_args.html) functions we are familiar with from parsnip. The specification itself isn't worth much if we don't apply it to some data. We will use the ames data set from the modeldata package

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://rdrr.io/r/utils/data.html'>data</a></span><span class='o'>(</span><span class='s'>"ames"</span>, package <span class='o'>=</span> <span class='s'>"modeldata"</span><span class='o'>)</span></span></code></pre>

</div>

This data set contains a number of categorical variables that unaltered can't be used with a K-Means model. Some light preprocessing can be done using the recipes package.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>rec_spec</span> <span class='o'>&lt;-</span> <span class='nf'>recipe</span><span class='o'>(</span><span class='o'>~</span> <span class='nv'>.</span>, data <span class='o'>=</span> <span class='nv'>ames</span><span class='o'>)</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span></span>
<span>  <span class='nf'>step_dummy</span><span class='o'>(</span><span class='nf'>all_nominal_predictors</span><span class='o'>(</span><span class='o'>)</span><span class='o'>)</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span></span>
<span>  <span class='nf'>step_zv</span><span class='o'>(</span><span class='nf'>all_predictors</span><span class='o'>(</span><span class='o'>)</span><span class='o'>)</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span></span>
<span>  <span class='nf'>step_normalize</span><span class='o'>(</span><span class='nf'>all_numeric_predictors</span><span class='o'>(</span><span class='o'>)</span><span class='o'>)</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span></span>
<span>  <span class='nf'>step_pca</span><span class='o'>(</span><span class='nf'>all_numeric_predictors</span><span class='o'>(</span><span class='o'>)</span>, threshold <span class='o'>=</span> <span class='m'>0.8</span><span class='o'>)</span></span></code></pre>

</div>

This recipe normalizes all of the numeric variables before applying PCA to create a more minimal set of uncorrelated features. Notice how we didn't specify an outcome as clustering models are unsupervised, meaning that we don't have outcomes.

These two specifications can be combined in a `workflow()`

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>kmeans_wf</span> <span class='o'>&lt;-</span> <span class='nf'>workflow</span><span class='o'>(</span><span class='nv'>rec_spec</span>, <span class='nv'>kmeans_spec</span><span class='o'>)</span></span></code></pre>

</div>

This workflow can then be fit to the `ames` data set

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>kmeans_fit</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://generics.r-lib.org/reference/fit.html'>fit</a></span><span class='o'>(</span><span class='nv'>kmeans_wf</span>, data <span class='o'>=</span> <span class='nv'>ames</span><span class='o'>)</span></span>
<span><span class='nv'>kmeans_fit</span></span>
<span><span class='c'>#&gt; ══ Workflow [trained] ══════════════════════════════════════════════════════════</span></span>
<span><span class='c'>#&gt; <span style='font-style: italic;'>Preprocessor:</span> Recipe</span></span>
<span><span class='c'>#&gt; <span style='font-style: italic;'>Model:</span> k_means()</span></span>
<span><span class='c'>#&gt; </span></span>
<span><span class='c'>#&gt; ── Preprocessor ────────────────────────────────────────────────────────────────</span></span>
<span><span class='c'>#&gt; 4 Recipe Steps</span></span>
<span><span class='c'>#&gt; </span></span>
<span><span class='c'>#&gt; • step_dummy()</span></span>
<span><span class='c'>#&gt; • step_zv()</span></span>
<span><span class='c'>#&gt; • step_normalize()</span></span>
<span><span class='c'>#&gt; • step_pca()</span></span>
<span><span class='c'>#&gt; </span></span>
<span><span class='c'>#&gt; ── Model ───────────────────────────────────────────────────────────────────────</span></span>
<span><span class='c'>#&gt; KMeans Cluster</span></span>
<span><span class='c'>#&gt;  Call: ClusterR::KMeans_rcpp(data = data, clusters = clusters) </span></span>
<span><span class='c'>#&gt;  Data cols: 121 </span></span>
<span><span class='c'>#&gt;  Centroids: 4 </span></span>
<span><span class='c'>#&gt;  BSS/SS: 0.1003306 </span></span>
<span><span class='c'>#&gt;  SS: 646321.6 = 581475.8 (WSS) + 64845.81 (BSS)</span></span>
<span></span></code></pre>

</div>

We have arbitrarily set the number of clusters to 4 above. If we wanted to figure out what values would be "optimal," we would have to fit multiple models. We can do this with [`tune_cluster()`](https://rdrr.io/pkg/tidyclust/man/tune_cluster.html); to make use of this function, though, we first need to use [`tune()`](https://hardhat.tidymodels.org/reference/tune.html) to specify that `num_clusters` is the argument we want to try with multiple values

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>kmeans_spec</span> <span class='o'>&lt;-</span> <span class='nv'>kmeans_spec</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span> </span>
<span>  <span class='nf'><a href='https://parsnip.tidymodels.org/reference/set_args.html'>set_args</a></span><span class='o'>(</span>num_clusters <span class='o'>=</span> <span class='nf'><a href='https://hardhat.tidymodels.org/reference/tune.html'>tune</a></span><span class='o'>(</span><span class='o'>)</span><span class='o'>)</span></span>
<span></span>
<span><span class='nv'>kmeans_wf</span> <span class='o'>&lt;-</span> <span class='nf'>workflow</span><span class='o'>(</span><span class='nv'>rec_spec</span>, <span class='nv'>kmeans_spec</span><span class='o'>)</span></span>
<span><span class='nv'>kmeans_wf</span></span>
<span><span class='c'>#&gt; ══ Workflow ════════════════════════════════════════════════════════════════════</span></span>
<span><span class='c'>#&gt; <span style='font-style: italic;'>Preprocessor:</span> Recipe</span></span>
<span><span class='c'>#&gt; <span style='font-style: italic;'>Model:</span> k_means()</span></span>
<span><span class='c'>#&gt; </span></span>
<span><span class='c'>#&gt; ── Preprocessor ────────────────────────────────────────────────────────────────</span></span>
<span><span class='c'>#&gt; 4 Recipe Steps</span></span>
<span><span class='c'>#&gt; </span></span>
<span><span class='c'>#&gt; • step_dummy()</span></span>
<span><span class='c'>#&gt; • step_zv()</span></span>
<span><span class='c'>#&gt; • step_normalize()</span></span>
<span><span class='c'>#&gt; • step_pca()</span></span>
<span><span class='c'>#&gt; </span></span>
<span><span class='c'>#&gt; ── Model ───────────────────────────────────────────────────────────────────────</span></span>
<span><span class='c'>#&gt; K Means Cluster Specification (partition)</span></span>
<span><span class='c'>#&gt; </span></span>
<span><span class='c'>#&gt; Main Arguments:</span></span>
<span><span class='c'>#&gt;   num_clusters = tune()</span></span>
<span><span class='c'>#&gt; </span></span>
<span><span class='c'>#&gt; Computational engine: ClusterR</span></span>
<span></span></code></pre>

</div>

We can use [`tune_cluster()`](https://rdrr.io/pkg/tidyclust/man/tune_cluster.html) in the same way we use `tune_grid()`, using bootstraps to fit multiple models for each value of `num_clusters`

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://rdrr.io/r/base/Random.html'>set.seed</a></span><span class='o'>(</span><span class='m'>1234</span><span class='o'>)</span></span>
<span><span class='nv'>boots</span> <span class='o'>&lt;-</span> <span class='nf'>bootstraps</span><span class='o'>(</span><span class='nv'>ames</span>, times <span class='o'>=</span> <span class='m'>10</span><span class='o'>)</span></span>
<span></span>
<span><span class='nv'>tune_res</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/pkg/tidyclust/man/tune_cluster.html'>tune_cluster</a></span><span class='o'>(</span></span>
<span>  <span class='nv'>kmeans_wf</span>,</span>
<span>  resamples <span class='o'>=</span> <span class='nv'>boots</span></span>
<span><span class='o'>)</span></span></code></pre>

</div>

The different [collect functions](https://tune.tidymodels.org/reference/collect_predictions.html) such as `collect_metrics()` works as they would do with tune output.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'>collect_metrics</span><span class='o'>(</span><span class='nv'>tune_res</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 18 × 7</span></span></span>
<span><span class='c'>#&gt;    num_clusters .metric          .estimator    mean     n std_err .config       </span></span>
<span><span class='c'>#&gt;           <span style='color: #555555; font-style: italic;'>&lt;int&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>            <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>        <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;int&gt;</span>   <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>         </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 1</span>            6 sse_total        standard   <span style='text-decoration: underline;'>624</span>435.    10   <span style='text-decoration: underline;'>1</span>675. Preprocessor1…</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 2</span>            6 sse_within_total standard   <span style='text-decoration: underline;'>557</span>147.    10   <span style='text-decoration: underline;'>2</span>579. Preprocessor1…</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 3</span>            1 sse_total        standard   <span style='text-decoration: underline;'>624</span>435.    10   <span style='text-decoration: underline;'>1</span>675. Preprocessor1…</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 4</span>            1 sse_within_total standard   <span style='text-decoration: underline;'>624</span>435.    10   <span style='text-decoration: underline;'>1</span>675. Preprocessor1…</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 5</span>            3 sse_total        standard   <span style='text-decoration: underline;'>624</span>435.    10   <span style='text-decoration: underline;'>1</span>675. Preprocessor1…</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 6</span>            3 sse_within_total standard   <span style='text-decoration: underline;'>588</span>001.    10   <span style='text-decoration: underline;'>5</span>703. Preprocessor1…</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 7</span>            5 sse_total        standard   <span style='text-decoration: underline;'>624</span>435.    10   <span style='text-decoration: underline;'>1</span>675. Preprocessor1…</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 8</span>            5 sse_within_total standard   <span style='text-decoration: underline;'>568</span>085.    10   <span style='text-decoration: underline;'>3</span>821. Preprocessor1…</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 9</span>            9 sse_total        standard   <span style='text-decoration: underline;'>624</span>435.    10   <span style='text-decoration: underline;'>1</span>675. Preprocessor1…</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>10</span>            9 sse_within_total standard   <span style='text-decoration: underline;'>535</span>120.    10   <span style='text-decoration: underline;'>2</span>262. Preprocessor1…</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>11</span>            2 sse_total        standard   <span style='text-decoration: underline;'>624</span>435.    10   <span style='text-decoration: underline;'>1</span>675. Preprocessor1…</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>12</span>            2 sse_within_total standard   <span style='text-decoration: underline;'>599</span>762.    10   <span style='text-decoration: underline;'>4</span>306. Preprocessor1…</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>13</span>            8 sse_total        standard   <span style='text-decoration: underline;'>624</span>435.    10   <span style='text-decoration: underline;'>1</span>675. Preprocessor1…</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>14</span>            8 sse_within_total standard   <span style='text-decoration: underline;'>541</span>813.    10   <span style='text-decoration: underline;'>2</span>506. Preprocessor1…</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>15</span>            4 sse_total        standard   <span style='text-decoration: underline;'>624</span>435.    10   <span style='text-decoration: underline;'>1</span>675. Preprocessor1…</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>16</span>            4 sse_within_total standard   <span style='text-decoration: underline;'>583</span>604.    10   <span style='text-decoration: underline;'>5</span>523. Preprocessor1…</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>17</span>            7 sse_total        standard   <span style='text-decoration: underline;'>624</span>435.    10   <span style='text-decoration: underline;'>1</span>675. Preprocessor1…</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>18</span>            7 sse_within_total standard   <span style='text-decoration: underline;'>548</span>299.    10   <span style='text-decoration: underline;'>2</span>907. Preprocessor1…</span></span>
<span></span></code></pre>

</div>

## Extraction

Going back to the first model we fit, tidyclust provides three main tools for interfacing with a fitted cluster model:

-   extract cluster assignments
-   extract centroid locations
-   prediction with new data

Each of these tasks has a function associated with them. First, we have [`extract_cluster_assignment()`](https://rdrr.io/pkg/tidyclust/man/extract_cluster_assignment.html), which can be used on fitted tidyclust objects, alone or as a part of a workflow, and it returns the cluster assignment as a factor named `.cluster` in a tibble.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://rdrr.io/pkg/tidyclust/man/extract_cluster_assignment.html'>extract_cluster_assignment</a></span><span class='o'>(</span><span class='nv'>kmeans_fit</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 2,930 × 1</span></span></span>
<span><span class='c'>#&gt;    .cluster </span></span>
<span><span class='c'>#&gt;    <span style='color: #555555; font-style: italic;'>&lt;fct&gt;</span>    </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 1</span> Cluster_1</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 2</span> Cluster_1</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 3</span> Cluster_1</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 4</span> Cluster_1</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 5</span> Cluster_2</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 6</span> Cluster_2</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 7</span> Cluster_2</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 8</span> Cluster_2</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 9</span> Cluster_2</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>10</span> Cluster_2</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># … with 2,920 more rows</span></span></span>
<span></span></code></pre>

</div>

The location of the clusters can be found using [`extract_centroids()`](https://rdrr.io/pkg/tidyclust/man/extract_centroids.html) which again returns a tibble, with `.cluster` being a factor with the same levels as what we got from [`extract_cluster_assignment()`](https://rdrr.io/pkg/tidyclust/man/extract_cluster_assignment.html).

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://rdrr.io/pkg/tidyclust/man/extract_centroids.html'>extract_centroids</a></span><span class='o'>(</span><span class='nv'>kmeans_fit</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 4 × 122</span></span></span>
<span><span class='c'>#&gt;   .cluster   PC001  PC002  PC003  PC004  PC005    PC006   PC007  PC008   PC009</span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;fct&gt;</span>      <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>  <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>  <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>  <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>  <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>    <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>   <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>  <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>   <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span> Cluster_1 -<span style='color: #BB0000;'>5.76</span>   0.713 11.9    2.80   4.09   3.44     1.26   -<span style='color: #BB0000;'>0.280</span> -<span style='color: #BB0000;'>0.486</span> </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span> Cluster_2  3.98  -<span style='color: #BB0000;'>1.18</span>   0.126  0.718  0.150  0.055<span style='text-decoration: underline;'>4</span>  -<span style='color: #BB0000;'>0.046</span><span style='color: #BB0000; text-decoration: underline;'>0</span> -<span style='color: #BB0000;'>0.346</span>  0.059<span style='text-decoration: underline;'>9</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>3</span> Cluster_3 -<span style='color: #BB0000;'>0.970</span>  2.45  -<span style='color: #BB0000;'>0.604</span> -<span style='color: #BB0000;'>0.523</span>  0.302 -<span style='color: #BB0000;'>0.298</span>   -<span style='color: #BB0000;'>0.174</span>   0.507 -<span style='color: #BB0000;'>0.153</span> </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>4</span> Cluster_4 -<span style='color: #BB0000;'>4.40</span>  -<span style='color: #BB0000;'>2.30</span>  -<span style='color: #BB0000;'>0.658</span> -<span style='color: #BB0000;'>0.671</span> -<span style='color: #BB0000;'>1.29</span>  -<span style='color: #BB0000;'>0.007</span><span style='color: #BB0000; text-decoration: underline;'>51</span>  0.222  -<span style='color: #BB0000;'>0.250</span>  0.223 </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># … with 112 more variables: PC010 &lt;dbl&gt;, PC011 &lt;dbl&gt;, PC012 &lt;dbl&gt;,</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>#   PC013 &lt;dbl&gt;, PC014 &lt;dbl&gt;, PC015 &lt;dbl&gt;, PC016 &lt;dbl&gt;, PC017 &lt;dbl&gt;,</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>#   PC018 &lt;dbl&gt;, PC019 &lt;dbl&gt;, PC020 &lt;dbl&gt;, PC021 &lt;dbl&gt;, PC022 &lt;dbl&gt;,</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>#   PC023 &lt;dbl&gt;, PC024 &lt;dbl&gt;, PC025 &lt;dbl&gt;, PC026 &lt;dbl&gt;, PC027 &lt;dbl&gt;,</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>#   PC028 &lt;dbl&gt;, PC029 &lt;dbl&gt;, PC030 &lt;dbl&gt;, PC031 &lt;dbl&gt;, PC032 &lt;dbl&gt;,</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>#   PC033 &lt;dbl&gt;, PC034 &lt;dbl&gt;, PC035 &lt;dbl&gt;, PC036 &lt;dbl&gt;, PC037 &lt;dbl&gt;,</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>#   PC038 &lt;dbl&gt;, PC039 &lt;dbl&gt;, PC040 &lt;dbl&gt;, PC041 &lt;dbl&gt;, PC042 &lt;dbl&gt;, …</span></span></span>
<span></span></code></pre>

</div>

Lastly, if the model has a notion that translates to "prediction," then [`predict()`](https://rdrr.io/r/stats/predict.html) will give you those results as well. In the case of K-Means, this is being interpreted as "which centroid is this observation closest to."

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://rdrr.io/r/stats/predict.html'>predict</a></span><span class='o'>(</span><span class='nv'>kmeans_fit</span>, new_data <span class='o'>=</span> <span class='nf'>slice_sample</span><span class='o'>(</span><span class='nv'>ames</span>, n <span class='o'>=</span> <span class='m'>10</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 10 × 1</span></span></span>
<span><span class='c'>#&gt;    .pred_cluster</span></span>
<span><span class='c'>#&gt;    <span style='color: #555555; font-style: italic;'>&lt;fct&gt;</span>        </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 1</span> Cluster_4    </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 2</span> Cluster_2    </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 3</span> Cluster_4    </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 4</span> Cluster_3    </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 5</span> Cluster_1    </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 6</span> Cluster_4    </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 7</span> Cluster_2    </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 8</span> Cluster_2    </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 9</span> Cluster_1    </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>10</span> Cluster_4</span></span>
<span></span></code></pre>

</div>

Please check the [pkgdown site](https://tidyclust.tidymodels.org/) for more in-depth articles. We couldn't be happier to have this package on CRAN and we encouraging you to check it out.

## Acknowledgements

A big thanks to all the contributors: [@aephidayatuloh](https://github.com/aephidayatuloh), [@avishaitsur](https://github.com/avishaitsur), [@bryanosborne](https://github.com/bryanosborne), [@cgoo4](https://github.com/cgoo4), [@coforfe](https://github.com/coforfe), [@EmilHvitfeldt](https://github.com/EmilHvitfeldt), [@JauntyJJS](https://github.com/JauntyJJS), [@kbodwin](https://github.com/kbodwin), [@malcolmbarrett](https://github.com/malcolmbarrett), [@mattwarkentin](https://github.com/mattwarkentin), [@ninohardt](https://github.com/ninohardt), [@nipnipj](https://github.com/nipnipj), and [@tomazweiss](https://github.com/tomazweiss).

