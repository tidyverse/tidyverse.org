---
output: hugodown::hugo_document

slug: tidypredict-1-0-0
title: tidypredict 1.0.0
date: 2025-12-04
author: Emil Hvitfeldt
description: >
    tidypredict 1.0.0 brings faster computations for tree-based models, more efficient tree representations, glmnet model support, and a change in how random forests are handled. 

photo:
  url: https://unsplash.com/photos/brown-leaves-covered-in-snow-on-a-branch-9XKkkeUwBhY
  author: Monique Caraballo

# one of: "deep-dive", "learn", "package", "programming", "roundup", or "other"
categories: [package] 
tags: [tidymodels, tidypredict, orbital]
rmd_hash: 8fe30706d8dce790

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

We're tickled pink to announce the release of version 1.0.0 of [tidypredict](https://tidypredict.tidymodels.org/). The main goal of tidypredict is to enable running predictions inside databases. It reads the model, extracts the components needed to calculate the prediction, and then creates an R formula that can be translated into SQL.

You can install them from CRAN with:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://rdrr.io/r/utils/install.packages.html'>install.packages</a></span><span class='o'>(</span><span class='s'>"tidypredict"</span><span class='o'>)</span></span></code></pre>

</div>

This blog post highlights the most important changes in this release, including faster computations for tree-based models, more efficient tree representations, glmnet model support, and a change in how random forests are handled. You can see a full list of changes in the [release notes](https://tidypredict.tidymodels.org/news/index.html#tidypredict-100).

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://tidypredict.tidymodels.org'>tidypredict</a></span><span class='o'>)</span></span></code></pre>

</div>

## Improved output for random forest models

The previous version of tidypredict [`tidypredict_fit()`](https://tidypredict.tidymodels.org/reference/tidypredict_fit.html) would return a list of expressions, one for each tree, when applied to random forest models. This didn't align with what is returned by other types of models. In version 1.0.0, this has been changed to produce a single combined expression to reflect how predictions should be done.

This is technically a breaking change, but one we believe is a worthwhile change as it provides a more consistent output for [`tidypredict_fit()`](https://tidypredict.tidymodels.org/reference/tidypredict_fit.html) as well as hides the technical details about how to combine trees from different packages.

## Faster parsing of trees

The parsing of xgboost, partykit, and ranger models should now be substantially faster than before. Examples have been shown to be 10 to 200 times faster. Please note that larger models, more trees, and deeper trees still take some time to parse.

## More efficient tree expressions

All trees, whether they are a single tree or part of a collection of trees, such as in boosted trees or random forests, are encoded as `case_when()` statements by tidypredict. This means that the following tree.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>model</span> <span class='o'>&lt;-</span> <span class='nf'>partykit</span><span class='nf'>::</span><span class='nf'><a href='https://rdrr.io/pkg/partykit/man/ctree.html'>ctree</a></span><span class='o'>(</span><span class='nv'>mpg</span> <span class='o'>~</span> <span class='nv'>am</span> <span class='o'>+</span> <span class='nv'>cyl</span>, data <span class='o'>=</span> <span class='nv'>mtcars</span><span class='o'>)</span></span>
<span><span class='nv'>model</span></span>
<span><span class='c'>#&gt; </span></span>
<span><span class='c'>#&gt; Model formula:</span></span>
<span><span class='c'>#&gt; mpg ~ am + cyl</span></span>
<span><span class='c'>#&gt; </span></span>
<span><span class='c'>#&gt; Fitted party:</span></span>
<span><span class='c'>#&gt; [1] root</span></span>
<span><span class='c'>#&gt; |   [2] cyl &lt;= 4: 26.664 (n = 11, err = 203.4)</span></span>
<span><span class='c'>#&gt; |   [3] cyl &gt; 4</span></span>
<span><span class='c'>#&gt; |   |   [4] cyl &lt;= 6: 19.743 (n = 7, err = 12.7)</span></span>
<span><span class='c'>#&gt; |   |   [5] cyl &gt; 6: 15.100 (n = 14, err = 85.2)</span></span>
<span><span class='c'>#&gt; </span></span>
<span><span class='c'>#&gt; Number of inner nodes:    2</span></span>
<span><span class='c'>#&gt; Number of terminal nodes: 3</span></span>
<span></span></code></pre>

</div>

Would be turned into the following `case_when()` statement.

``` r
case_when(
 cyl <= 4 ~ 26.6636363636364,
 cyl <= 6 & cyl > 4 ~ 19.7428571428571, 
 cyl > 6 & cyl > 4 ~= 15.1
)
```

With this new update, we have taken advantage of the `.default` argument whenever possible, hopefully leading to faster predictions as we don't need to calculate redundant conditionals.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://tidypredict.tidymodels.org/reference/tidypredict_fit.html'>tidypredict_fit</a></span><span class='o'>(</span><span class='nv'>model</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; case_when(cyl &lt;= 4 ~ 26.6636363636364, cyl &lt;= 6 &amp; cyl &gt; 4 ~ 19.7428571428571, </span></span>
<span><span class='c'>#&gt;     .default = 15.1)</span></span>
<span></span></code></pre>

</div>

## Glmnet support

We now support the glmnet package. This package provides generalized linear models with lasso or elasticnet regularization.

The main restriction when using a glmnet model with `tidypredict()` is that the model will need to have been fit with the `lmanbda` argument set.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>model</span> <span class='o'>&lt;-</span> <span class='nf'>glmnet</span><span class='nf'>::</span><span class='nf'><a href='https://glmnet.stanford.edu/reference/glmnet.html'>glmnet</a></span><span class='o'>(</span><span class='nv'>mtcars</span><span class='o'>[</span>, <span class='o'>-</span><span class='m'>1</span><span class='o'>]</span>, <span class='nv'>mtcars</span><span class='o'>$</span><span class='nv'>mpg</span>, lambda <span class='o'>=</span> <span class='m'>0.01</span><span class='o'>)</span></span>
<span></span>
<span><span class='nf'><a href='https://tidypredict.tidymodels.org/reference/tidypredict_fit.html'>tidypredict_fit</a></span><span class='o'>(</span><span class='nv'>model</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; 13.0081464696679 + (cyl * -0.0773532164346008) + (disp * 0.00969507138358544) + </span></span>
<span><span class='c'>#&gt;     (hp * -0.0192462098902709) + (drat * 0.816753237688302) + </span></span>
<span><span class='c'>#&gt;     (wt * -3.41564341709663) + (qsec * 0.758580151032383) + (vs * </span></span>
<span><span class='c'>#&gt;     0.277874296242861) + (am * 2.47356523820533) + (gear * 0.645144527527598) + </span></span>
<span><span class='c'>#&gt;     (carb * -0.300886812079305)</span></span>
<span></span></code></pre>

</div>

Note how, as we increase the penalty, the extracted expression correctly removes terms with coefficients of `0` instead of leaving them as `(disp * 0)`.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>model</span> <span class='o'>&lt;-</span> <span class='nf'>glmnet</span><span class='nf'>::</span><span class='nf'><a href='https://glmnet.stanford.edu/reference/glmnet.html'>glmnet</a></span><span class='o'>(</span><span class='nv'>mtcars</span><span class='o'>[</span>, <span class='o'>-</span><span class='m'>1</span><span class='o'>]</span>, <span class='nv'>mtcars</span><span class='o'>$</span><span class='nv'>mpg</span>, lambda <span class='o'>=</span> <span class='m'>1</span><span class='o'>)</span></span>
<span></span>
<span><span class='nf'><a href='https://tidypredict.tidymodels.org/reference/tidypredict_fit.html'>tidypredict_fit</a></span><span class='o'>(</span><span class='nv'>model</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; 35.3137765116027 + (cyl * -0.871451193824228) + (hp * -0.0101173960249783) + </span></span>
<span><span class='c'>#&gt;     (wt * -2.59443677687505)</span></span>
<span></span></code></pre>

</div>

tidypredict is being used as the main parser for models used by the [orbital](https://orbital.tidymodels.org/) package. This means that all the changes seen in this post also take effect when using orbital with tidymodels workflows. Such as using [`parsnip::linear_reg()`](https://parsnip.tidymodels.org/reference/linear_reg.html) with `engine = "glmnet"`.

## Acknowledgements

A big thank you to all the folks who helped make this release happen: [@EmilHvitfeldt](https://github.com/EmilHvitfeldt), and [@jeroenjanssens](https://github.com/jeroenjanssens).

