---
output: hugodown::hugo_document

slug: recipes-0-1-13
title: recipes 0.1.13
date: 2020-06-25
author: Max Kuhn
description: >
    Version 0.1.13 of recipes is on CRAN.

photo:
  url: https://unsplash.com/photos/pGM4sjt_BdQ
  author: Brooke Lark

# one of: "deep-dive", "learn", "package", "programming", or "other"
categories: [package] 
tags: [tidymodels, recipes]
rmd_hash: 0b10649a07a61d48

---

We're very chuffed to announce the release of [recipes](https://recipes.tidymodels.org) 0.1.13. recipes is an alternative method for creating and preprocessing design matrices that can be used for modeling or visualization.

You can install it from CRAN with:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'>install.packages</span>(<span class='s'>"recipes"</span>)</code></pre>

</div>

You can see a full list of changes in the [release notes](https://recipes.tidymodels.org/news/index.html). There are some improvements and changes to talk about.

General changes
---------------

First, `step_filter()`, `step_slice()`, `step_sample()`, and `step_naomit()` had their defaults for `skip` changed to `TRUE`. In the vast majority of applications, these steps should not be applied to the test or assessment sets.

Also, `step_upsample()` and `step_downsample()` are soft deprecated in recipes as they are now available in the [themis package](https://tidymodels.github.io/themis/). They will be removed in the next version.

Finally, for the new version of dplyr, the selectors `all_of()` and `any_of()` can now be used in step selections.

Feature extraction improvements
-------------------------------

In the [*feature extraction*](https://en.wikipedia.org/wiki/Feature_extraction) category, there are two improvements. First, the `tidy()` method for `step_pca()` can return the percentage of variation accounted for by each [PCA component](https://en.wikipedia.org/wiki/Principal_component_analysis). For example:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'>library</span>(<span class='k'><a href='https://rdrr.io/pkg/tidymodels/man'>tidymodels</a></span>)

<span class='c'># Many highly correlated numeric predictors:</span>
<span class='nf'>data</span>(<span class='k'>meats</span>, package = <span class='s'>"modeldata"</span>)

<span class='nf'>set.seed</span>(<span class='m'>2383</span>)
<span class='k'>split</span> <span class='o'>&lt;-</span> <span class='nf'>initial_split</span>(<span class='k'>meats</span>)
<span class='k'>meat_tr</span> <span class='o'>&lt;-</span> <span class='nf'>training</span>(<span class='k'>split</span>)
<span class='k'>meat_te</span> <span class='o'>&lt;-</span> <span class='nf'>testing</span>(<span class='k'>split</span>)

<span class='k'>pca_rec</span> <span class='o'>&lt;-</span> 
  <span class='nf'>recipe</span>(<span class='k'>water</span> <span class='o'>+</span> <span class='k'>fat</span> <span class='o'>+</span> <span class='k'>protein</span> <span class='o'>~</span> <span class='k'>.</span>, data = <span class='k'>meat_tr</span>) <span class='o'>%&gt;%</span> 
  <span class='nf'>step_normalize</span>(<span class='nf'>all_predictors</span>()) <span class='o'>%&gt;%</span> 
  <span class='nf'>step_pca</span>(<span class='nf'>all_predictors</span>(), num_comp = <span class='m'>10</span>, id = <span class='s'>"pca"</span>) <span class='o'>%&gt;%</span> 
  <span class='nf'>prep</span>()

<span class='k'>var_info</span> <span class='o'>&lt;-</span> <span class='nf'>tidy</span>(<span class='k'>pca_rec</span>, id = <span class='s'>"pca"</span>, type = <span class='s'>"variance"</span>)

<span class='nf'>table</span>(<span class='k'>var_info</span><span class='o'>$</span><span class='k'>terms</span>)
<span class='c'>#&gt; </span>
<span class='c'>#&gt; cumulative percent variance         cumulative variance </span>
<span class='c'>#&gt;                         100                         100 </span>
<span class='c'>#&gt;            percent variance                    variance </span>
<span class='c'>#&gt;                         100                         100</span>

<span class='k'>var_info</span> <span class='o'>%&gt;%</span> 
  <span class='k'>dplyr</span>::<span class='nf'><a href='https://dplyr.tidyverse.org/reference/filter.html'>filter</a></span>(<span class='k'>terms</span> <span class='o'>==</span> <span class='s'>"percent variance"</span>) <span class='o'>%&gt;%</span> 
  <span class='nf'>ggplot</span>(<span class='nf'>aes</span>(x = <span class='k'>component</span>, y = <span class='k'>value</span>)) <span class='o'>+</span> 
  <span class='nf'>geom_bar</span>(stat = <span class='s'>"identity"</span>) <span class='o'>+</span> 
  <span class='nf'>xlim</span>(<span class='nf'>c</span>(<span class='m'>0</span>, <span class='m'>10</span>)) <span class='o'>+</span> 
  <span class='nf'>ylab</span>(<span class='s'>"% of Total Variation"</span>)
</code></pre>
<img src="figs/pca-tidy-1.svg" width="700px" style="display: block; margin: auto;" />

</div>

Another change in this version of recipes is that `step_pls()` has received an upgrade. [Partial least squares](https://en.wikipedia.org/wiki/Partial_least_squares_regression) (PLS) is similar to PCA but takes the outcome(s) into account.

Previously, it used the [pls package](https://github.com/bhmevik/pls) to do the computations. That's a great package but it lacks two important features: allow for a categorical outcome value (e.g. "pls-da" for *discriminant analysis*) or allow for sparsity in the coefficients. Sparsity would facilitate simpler and perhaps more robust models.

`step_pls()` now uses the Bioconductor [mixOmics package](https://www.bioconductor.org/packages/release/bioc/html/mixOmics.html). As such, the outcome data can now be a factor and a new argument `predictor_prop` is used for sparsity. That argument specifies the maximum proportion of partial least squares loadings that will be *non-zero* (per component) during training. Newly prepped recipes will use this package but previously created recipes still use the pls package. For our previous example, let's look at the protein outcome and build a recipe:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='k'>pls_rec</span> <span class='o'>&lt;-</span> 
  <span class='nf'>recipe</span>(<span class='k'>water</span> <span class='o'>+</span> <span class='k'>fat</span> <span class='o'>+</span> <span class='k'>protein</span> <span class='o'>~</span> <span class='k'>.</span>, data = <span class='k'>meat_tr</span>) <span class='o'>%&gt;%</span> 
  <span class='nf'>step_normalize</span>(<span class='nf'>all_predictors</span>()) <span class='o'>%&gt;%</span> 
  <span class='nf'>step_pls</span>(
    <span class='nf'>all_predictors</span>(),
    outcome = <span class='nf'>vars</span>(<span class='k'>protein</span>),
    num_comp = <span class='m'>3</span>,
    predictor_prop = <span class='m'>0.75</span>,
    id = <span class='s'>"pls"</span>
  ) <span class='o'>%&gt;%</span> 
  <span class='nf'>prep</span>()

<span class='c'># for new data: </span>
<span class='nf'>bake</span>(<span class='k'>pls_rec</span>, <span class='k'>meat_te</span>, <span class='k'>protein</span>, <span class='nf'>starts_with</span>(<span class='s'>"PLS"</span>)) <span class='o'>%&gt;%</span>
  <span class='k'>tidyr</span>::<span class='nf'><a href='https://tidyr.tidyverse.org/reference/pivot_longer.html'>pivot_longer</a></span>(cols = <span class='nf'>c</span>(<span class='o'>-</span><span class='k'>protein</span>),
                      names_to = <span class='s'>"component"</span>,
                      values_to = <span class='s'>"values"</span>) <span class='o'>%&gt;%</span> 
  <span class='nf'>ggplot</span>(<span class='nf'>aes</span>(x = <span class='k'>values</span>, y = <span class='k'>protein</span>)) <span class='o'>+</span> 
  <span class='nf'>geom_point</span>(alpha = <span class='m'>0.5</span>) <span class='o'>+</span> 
  <span class='nf'>facet_wrap</span>(<span class='o'>~</span> <span class='k'>component</span>, scale = <span class='s'>"free_x"</span>) <span class='o'>+</span>
  <span class='nf'>xlab</span>(<span class='s'>"PLS Score"</span>)
</code></pre>
<img src="figs/pls-1.svg" width="700px" style="display: block; margin: auto;" />

</div>

What are the PLS coefficients from this?

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'>tidy</span>(<span class='k'>pls_rec</span>, id = <span class='s'>"pls"</span>) <span class='o'>%&gt;%</span>
  <span class='nf'>ggplot</span>(<span class='nf'>aes</span>(x = <span class='k'>component</span>, y = <span class='k'>terms</span>, fill = <span class='k'>value</span>)) <span class='o'>+</span>
  <span class='nf'>geom_tile</span>() <span class='o'>+</span>
  <span class='nf'>scale_fill_gradient2</span>(
    low = <span class='s'>"#B2182B"</span>,
    mid = <span class='s'>"white"</span>,
    high = <span class='s'>"#2166AC"</span>,
    limits = <span class='nf'>c</span>(<span class='o'>-</span><span class='m'>0.4</span>, <span class='m'>0.4</span>)
  ) <span class='o'>+</span> 
  <span class='nf'>theme</span>(axis.text.y = <span class='nf'>element_blank</span>()) <span class='o'>+</span> 
  <span class='nf'>ylab</span>(<span class='s'>"Predictors"</span>)
</code></pre>
<img src="figs/pls-coef-1.svg" width="700px" style="display: block; margin: auto;" />

</div>

The third component has the largest coefficients and the largest effect on predicting the percentage of protein. This is consistent with the scatter plot above. The blocks of white in the heatmap above are coefficients effected by the sparsity argument.

