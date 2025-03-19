---
output: hugodown::hugo_document

slug: tidymodels-sparsity
title: Improved sparsity support in tidymodels
date: 2025-03-19
author: Emil Hvitfeldt
description: >
 The tidymodels ecosystem now fully supports sparse data as input, output, and in creation.

photo:
  url: https://unsplash.com/photos/green-tree-in-the-middle-of-grass-field-KD8nzFznQQ0
  author: Oliver Olah

# one of: "deep-dive", "learn", "package", "programming", "roundup", or "other"
categories: [package] 
tags: [tidymodels, recipes, parsnip, workflows]
rmd_hash: 04c849ffdbfc01df

---

Photo by <a href="https://unsplash.com/@oxygenvisuals?utm_content=creditCopyText&utm_medium=referral&utm_source=unsplash">Oliver Olah</a> on <a href="https://unsplash.com/photos/green-tree-in-the-middle-of-grass-field-KD8nzFznQQ0?utm_content=creditCopyText&utm_medium=referral&utm_source=unsplash">Unsplash</a>

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

We're stoked to announce tidymodels now fully supports sparse data from end to end. We have been working on this for [over 5 years](https://github.com/tidymodels/recipes/pull/515). This is an extension of the work we have done [previously](https://www.tidyverse.org/blog/2020/11/tidymodels-sparse-support/) with blueprints, which would carry the data sparsely some of the way.

You will need recipes $\ge$ 1.2.0, parsnip $\ge$ 1.3.0, workflows $\ge$ 1.2.0 or later for this to work.

## What are sparse data?

The term **sparse data** refers to a data set containing many zeroes. Sparse data appears in all kinds of fields and can be produced in a number of preprocessing methods. The reason why we care about sparse data is because of how computers store numbers. A 32-bit integer value takes 4 bytes to store. An array of 32-bit integers takes 40 bytes, and so on. This happens because each value is written down.

A sparse representation instead stores the locations and values of the non-zero entries. Suppose we have the following vector with 20 entries:

``` r
c(0, 0, 1, 0, 3, 0, 0, 7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
```

It could be represented sparsely using the 3 values `positions = c(1, 3, 7)`, `values = c(3, 5, 8)`, and `length = 20`. Now, we have seven values to represent a vector of 20 elements. Since some modeling tasks contain even sparser data, this type of representation starts to show real benefits in terms of execution time and memory consumption.

The tidymodels set of packages has undergone several internal changes to allow it to represent data sparsely internally when it would be beneficial. These changes allow you to fit models that contain sparse data faster and more memory efficiently than before. Moreover, it allows you to fit models previously not possible due to them not fitting in memory.

## Sparse matrix support

The first benefit of these changes is that `recipe()`, `prep()`, `bake()`, `fit()`, and [`predict()`](https://rdrr.io/r/stats/predict.html) now accept sparse matrices created using the Matrix package.

The `permeability_qsar` data set from the modeldata package contains quite a lot of zeroes in the predictors, so we will use it as a demonstration. Starting by coercing it into a sparse matrix.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://tidymodels.tidymodels.org'>tidymodels</a></span><span class='o'>)</span></span>
<span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://Matrix.R-forge.R-project.org'>Matrix</a></span><span class='o'>)</span></span>
<span><span class='nv'>permeability_sparse</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/methods/as.html'>as</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/matrix.html'>as.matrix</a></span><span class='o'>(</span><span class='nv'>permeability_qsar</span><span class='o'>)</span>, <span class='s'>"sparseMatrix"</span><span class='o'>)</span></span></code></pre>

</div>

We can now use this sparse matrix in our code the same way as a dense matrix or data frame:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>rec_spec</span> <span class='o'>&lt;-</span> <span class='nf'>recipe</span><span class='o'>(</span><span class='nv'>permeability</span> <span class='o'>~</span> <span class='nv'>.</span>, data <span class='o'>=</span> <span class='nv'>permeability_sparse</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'>step_zv</span><span class='o'>(</span><span class='nf'>all_predictors</span><span class='o'>(</span><span class='o'>)</span><span class='o'>)</span></span>
<span></span>
<span><span class='nv'>mod_spec</span> <span class='o'>&lt;-</span> <span class='nf'>boost_tree</span><span class='o'>(</span><span class='s'>"regression"</span>, <span class='s'>"xgboost"</span><span class='o'>)</span></span>
<span></span>
<span><span class='nv'>wf_spec</span> <span class='o'>&lt;-</span> <span class='nf'>workflow</span><span class='o'>(</span><span class='nv'>rec_spec</span>, <span class='nv'>mod_spec</span><span class='o'>)</span></span></code></pre>

</div>

Model training has the usual syntax:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>wf_fit</span> <span class='o'>&lt;-</span> <span class='nf'>fit</span><span class='o'>(</span><span class='nv'>wf_spec</span>, <span class='nv'>permeability_sparse</span><span class='o'>)</span></span></code></pre>

</div>

as does prediction:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://rdrr.io/r/stats/predict.html'>predict</a></span><span class='o'>(</span><span class='nv'>wf_fit</span>, <span class='nv'>permeability_sparse</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 165 × 1</span></span></span>
<span><span class='c'>#&gt;     .pred</span></span>
<span><span class='c'>#&gt;     <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 1</span> 10.5  </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 2</span>  1.50 </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 3</span> 13.1  </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 4</span>  1.10 </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 5</span>  1.25 </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 6</span>  0.738</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 7</span> 29.3  </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 8</span>  2.44 </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 9</span> 36.3  </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>10</span>  4.31 </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># ℹ 155 more rows</span></span></span>
<span></span></code></pre>

</div>

Note that only some models/engines work well with sparse data. These are all listed here <https://www.tidymodels.org/find/sparse/>. If the model doesn't support sparse data, it will be coerced into the default non-sparse representation and used as usual.

With a few exceptions, it should work like any other data set. However, this approach has two main limitations. The first is that we are limited to regression tasks since the outcome has to be numeric to be part of the sparse matrix.

The second limitation is that it only works with non-formula methods for parsnip and workflows. This means that you can use a recipe with `add_recipe()` or select variables directly with `add_variables()` when using a workflow. And you need to use `fit_xy()` instead of `fit()` when using a parsnip object by itself.

TODO: add tidymodels.org post about sparse matrix in tidymodels

## Sparse data from recipes steps

Where this sparsity support really starts to shine is when the recipe we use will generate sparse data. They come in two flavors, sparsity creation steps and sparsity preserving steps. Both listed here: <https://www.tidymodels.org/find/sparse/>.

Some steps like `step_dummy()`, `step_indicate_na()`, and [`textrecipes::step_tf()`](https://textrecipes.tidymodels.org/reference/step_tf.html) will almost always produce a lot of zeroes. We take advantage of that by generating it sparsely when it is beneficial. If these steps end up producing sparse vectors, we want to make sure the sparsity is preserved. A couple of handfuls of steps, such as `step_impute_mean()` and `step_scale(),` have been updated to be able to work efficiently with sparse vectors. Both types of steps are detailed in the above-linked list of compatible methods.

What this means in practice is that if you use a model/engine that supports sparse data and have a recipe that produces enough sparse data, then the steps will switch to produce sparse data by using a new sparse data format to store the data (when appropriate) as the recipe is being processed. Then if the model can accept sparse objects, we convert the data from our new sparse format to a standard sparse matrix object. Increasing performance when possible while preserving performance otherwise.

Below is a simple recipe using the `ames` data set. `step_dummy()` is applied to all the categorical predictors, leading to a significant amount of zeroes.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>rec_spec</span> <span class='o'>&lt;-</span> <span class='nf'>recipe</span><span class='o'>(</span><span class='nv'>Sale_Price</span> <span class='o'>~</span> <span class='nv'>.</span>, data <span class='o'>=</span> <span class='nv'>ames</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'>step_zv</span><span class='o'>(</span><span class='nf'>all_predictors</span><span class='o'>(</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'>step_normalize</span><span class='o'>(</span><span class='nf'>all_numeric_predictors</span><span class='o'>(</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'>step_dummy</span><span class='o'>(</span><span class='nf'>all_nominal_predictors</span><span class='o'>(</span><span class='o'>)</span><span class='o'>)</span></span>
<span></span>
<span><span class='nv'>mod_spec</span> <span class='o'>&lt;-</span> <span class='nf'>boost_tree</span><span class='o'>(</span><span class='s'>"regression"</span>, <span class='s'>"xgboost"</span><span class='o'>)</span></span>
<span></span>
<span><span class='nv'>wf_spec</span> <span class='o'>&lt;-</span> <span class='nf'>workflow</span><span class='o'>(</span><span class='nv'>rec_spec</span>, <span class='nv'>mod_spec</span><span class='o'>)</span></span></code></pre>

</div>

When we go to fit it now, it takes around 125ms and allocates 37.2MB. Compared to before these changes it would take around 335ms and allocate 67.5MB.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>wf_fit</span> <span class='o'>&lt;-</span> <span class='nf'>fit</span><span class='o'>(</span><span class='nv'>wf_spec</span>, <span class='nv'>ames</span><span class='o'>)</span></span></code></pre>

</div>

We see similar speedups when we predictor with around 20ms and 25.2MB now, compared to around 60ms and 55.6MB before.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://rdrr.io/r/stats/predict.html'>predict</a></span><span class='o'>(</span><span class='nv'>wf_fit</span>, <span class='nv'>ames</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 2,930 × 1</span></span></span>
<span><span class='c'>#&gt;      .pred</span></span>
<span><span class='c'>#&gt;      <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 1</span> <span style='text-decoration: underline;'>208</span>649.</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 2</span> <span style='text-decoration: underline;'>115</span>339.</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 3</span> <span style='text-decoration: underline;'>148</span>634.</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 4</span> <span style='text-decoration: underline;'>239</span>770.</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 5</span> <span style='text-decoration: underline;'>190</span>082.</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 6</span> <span style='text-decoration: underline;'>184</span>604.</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 7</span> <span style='text-decoration: underline;'>208</span>572.</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 8</span> <span style='text-decoration: underline;'>177</span>403 </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 9</span> <span style='text-decoration: underline;'>261</span>000.</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>10</span> <span style='text-decoration: underline;'>198</span>604.</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># ℹ 2,920 more rows</span></span></span>
<span></span></code></pre>

</div>

These improvements are tightly related to memory allocation, which depends on the sparsity of the data set produced by the recipe. This is why it is hard to say how much benefit you will see. We have seen orders of magnitudes of improvements, both in terms of time and memory allocation. We have also been able to fit models where previously the data was too big to fit in memory.

Please see the post on tidymodels.org, which goes into more detail about when you are likely to benefit from this and how to change your recipes and workflows to take full advantage of this new feature.

TODO: add tidymodels.org post about sparse recipes in tidymodels

