---
output: hugodown::hugo_document

slug: tidymodels-2023-q1
title: "Q1 2023 tidymodels digest"
date: 2023-04-21
author: Emil Hvitfeldt
description: >
    The tidymodels team has been busy working on all sorts of new features across the ecosystem.
photo:
  url: https://unsplash.com/photos/l-rtCtc_4c0
  author: Chi Liu

# one of: "deep-dive", "learn", "package", "programming", "roundup", or "other"
categories: [roundup] 
tags: [tidymodels, recipes, yardstick, dials]
rmd_hash: 328e7ab528557112

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

The [tidymodels](https://www.tidymodels.org/) framework is a collection of R packages for modeling and machine learning using tidyverse principles.

Since the beginning of 2021, we have been publishing [quarterly updates](https://www.tidyverse.org/categories/roundup/) here on the tidyverse blog summarizing what's new in the tidymodels ecosystem. The purpose of these regular posts is to share useful new features and any updates you may have missed. You can check out the [`tidymodels` tag](https://www.tidyverse.org/tags/tidymodels/) to find all tidymodels blog posts here, including our roundup posts as well as those that are more focused, like these posts from the past couple of months:

-   [Tuning hyperparameters with tidymodels is a delight](https://www.tidyverse.org/blog/2023/04/tuning-delights/)
-   [censored 0.2.0](https://www.tidyverse.org/blog/2023/04/censored-0-2-0/)
-   [The tidymodels is getting a whole lot faster](https://www.simonpcouch.com/blog/speedups-2023/)

Since [our last roundup post](https://www.tidyverse.org/blog/2022/12/tidymodels-2022-q4/), there have been CRAN releases of 24 tidymodels packages. Here are links to their NEWS files:

<div class="highlight">

-   agua [(0.1.2)](https://agua.tidymodels.org/news/index.html)
-   baguette [(1.0.1)](https://baguette.tidymodels.org/news/index.html)
-   broom [(1.0.4)](https://broom.tidymodels.org/news/index.html)
-   butcher [(0.3.2)](https://butcher.tidymodels.org/news/index.html)
-   censored [(0.2.0)](https://censored.tidymodels.org/news/index.html)
-   dials [(1.2.0)](https://dials.tidymodels.org/news/index.html)
-   discrim [(1.0.1)](https://discrim.tidymodels.org/news/index.html)
-   embed [(1.1.0)](https://embed.tidymodels.org/news/index.html)
-   finetune [(1.1.0)](https://finetune.tidymodels.org/news/index.html)
-   hardhat [(1.3.0)](https://hardhat.tidymodels.org/news/index.html)
-   modeldata [(1.1.0)](https://modeldata.tidymodels.org/news/index.html)
-   parsnip [(1.1.0)](https://parsnip.tidymodels.org/news/index.html)
-   recipes [(1.0.5)](https://recipes.tidymodels.org/news/index.html)
-   rules [(1.0.2)](https://rules.tidymodels.org/news/index.html)
-   spatialsample [(0.3.0)](https://spatialsample.tidymodels.org/news/index.html)
-   stacks [(1.0.2)](https://stacks.tidymodels.org/news/index.html)
-   textrecipes [(1.0.3)](https://textrecipes.tidymodels.org/news/index.html)
-   themis [(1.0.1)](https://themis.tidymodels.org/news/index.html)
-   tidyclust [(0.1.2)](https://tidyclust.tidymodels.org/news/index.html)
-   tidypredict [(0.5)](https://tidypredict.tidymodels.org/news/index.html)
-   tune [(1.1.1)](https://tune.tidymodels.org/news/index.html)
-   workflows [(1.1.3)](https://workflows.tidymodels.org/news/index.html)
-   workflowsets [(1.0.1)](https://workflowsets.tidymodels.org/news/index.html)
-   yardstick [(1.2.0)](https://yardstick.tidymodels.org/news/index.html)

</div>

We'll highlight a few especially notable changes below: more informative errors and faster code. First, loading the collection of packages:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://tidymodels.tidymodels.org'>tidymodels</a></span><span class='o'>)</span></span>
<span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://embed.tidymodels.org'>embed</a></span><span class='o'>)</span></span>
<span></span>
<span><span class='nf'><a href='https://rdrr.io/r/utils/data.html'>data</a></span><span class='o'>(</span><span class='s'>"ames"</span>, package <span class='o'>=</span> <span class='s'>"modeldata"</span><span class='o'>)</span></span></code></pre>

</div>

## More informative errors

We like to make sure that the functions do what they are supposed to do. In the last months we are focused on making it so functions throw errors in such a way that they are easier for the users to pinpoint what went wrong and where. Since the modeling pipeline can be quite complicated, getting uninformative errors are a no-go.

Across the tidymodels, error messages will now indicate the user-facing function that caused the error rather than the internal function that it came from.

From dials, an error that looked like

``` r
degree(range = c(1L, 5L))
#> Error in `new_quant_param()`:
#> ! Since `type = 'double'`, please use that data type for the range.
```

Now says that the error came from `degree()` rather than `new_quant_param()`

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'>degree</span><span class='o'>(</span>range <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='m'>1L</span>, <span class='m'>5L</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #BBBB00; font-weight: bold;'>Error</span><span style='font-weight: bold;'> in `degree()`:</span></span></span>
<span><span class='c'>#&gt; <span style='color: #BBBB00;'>!</span> Since `type = 'double'`, please use that data type for the range.</span></span>
<span></span></code></pre>

</div>

The same thing can be seen with the yardstick metrics

``` r
mtcars |>
  accuracy(vs, am)
#> Error in `dplyr::summarise()`:
#> ℹ In argument: `.estimate = metric_fn(truth = vs, estimate = am, na_rm =
#>   na_rm)`.
#> Caused by error in `validate_class()`:
#> ! `truth` should be a factor but a numeric was supplied.
```

which now errors much better

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>mtcars</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'>accuracy</span><span class='o'>(</span><span class='nv'>vs</span>, <span class='nv'>am</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #BBBB00; font-weight: bold;'>Error</span><span style='font-weight: bold;'> in `accuracy()`:</span></span></span>
<span><span class='c'>#&gt; <span style='color: #BBBB00;'>!</span> `truth` should be a factor, not a `numeric`.</span></span>
<span></span></code></pre>

</div>

Lastly, one of the biggest improvements came in recipes, which now shows which step caused the error instead of saying it happened in [`prep()`](https://recipes.tidymodels.org/reference/prep.html) or [`bake()`](https://recipes.tidymodels.org/reference/bake.html). This is a huge improvement since you are likely to have many steps.

Before

``` r
recipe(~., data = ames) |>
  step_novel(Neighborhood, new_level = "Gilbert") |>
  prep()
#> Error in `prep()`:
#> ! Columns already contain the new level: Neighborhood
```

Now

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://recipes.tidymodels.org/reference/recipe.html'>recipe</a></span><span class='o'>(</span><span class='o'>~</span><span class='nv'>.</span>, data <span class='o'>=</span> <span class='nv'>ames</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://recipes.tidymodels.org/reference/step_novel.html'>step_novel</a></span><span class='o'>(</span><span class='nv'>Neighborhood</span>, new_level <span class='o'>=</span> <span class='s'>"Gilbert"</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://recipes.tidymodels.org/reference/prep.html'>prep</a></span><span class='o'>(</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #BBBB00; font-weight: bold;'>Error</span><span style='font-weight: bold;'> in `step_novel()`:</span></span></span>
<span><span class='c'>#&gt; <span style='font-weight: bold;'>Caused by error in `prep()`:</span></span></span>
<span><span class='c'>#&gt; <span style='color: #BBBB00;'>!</span> Columns already contain the new level: Neighborhood</span></span>
<span></span></code></pre>

</div>

While these changes might seem trivial, they make a big difference. Especially when the errors are coming when you are using `fit_resamples()` or `tune_grid()`.

## Things are getting faster

As we have written about in [The tidymodels is getting a whole lot faster](https://www.simonpcouch.com/blog/speedups-2023/) and [Writing performant code with tidy tools](https://www.tidyverse.org/blog/2023/04/performant-packages/), we have been working on tightening up the performance of the tidymodels code. These changes are mostly related to the infrastructure code, meaning that the speedup will bring you to closer underlying implementations.

A different kind of speedup is found with the addition of the [step_pca_truncated()](https://embed.tidymodels.org/reference/step_pca_truncated.html) step added in the embed package.

[Principal Component Analysis](https://en.wikipedia.org/wiki/Principal_component_analysis) is a really powerful and fast method for dimensionality reduction of large data sets. However, for data with many columns, it can be computationally expensive to calculate all the principal components. [`step_pca_truncated()`](https://embed.tidymodels.org/reference/step_pca_truncated.html) works in much the same way as [`step_pca()`](https://recipes.tidymodels.org/reference/step_pca.html) but it only calculates the number of components it needs

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>pca_normal</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://recipes.tidymodels.org/reference/recipe.html'>recipe</a></span><span class='o'>(</span><span class='nv'>Sale_Price</span> <span class='o'>~</span> <span class='nv'>.</span>, data <span class='o'>=</span> <span class='nv'>ames</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://recipes.tidymodels.org/reference/step_dummy.html'>step_dummy</a></span><span class='o'>(</span><span class='nf'><a href='https://recipes.tidymodels.org/reference/has_role.html'>all_nominal_predictors</a></span><span class='o'>(</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://recipes.tidymodels.org/reference/step_pca.html'>step_pca</a></span><span class='o'>(</span><span class='nf'><a href='https://recipes.tidymodels.org/reference/has_role.html'>all_numeric_predictors</a></span><span class='o'>(</span><span class='o'>)</span>, num_comp <span class='o'>=</span> <span class='m'>3</span><span class='o'>)</span></span>
<span></span>
<span><span class='nv'>pca_truncated</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://recipes.tidymodels.org/reference/recipe.html'>recipe</a></span><span class='o'>(</span><span class='nv'>Sale_Price</span> <span class='o'>~</span> <span class='nv'>.</span>, data <span class='o'>=</span> <span class='nv'>ames</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://recipes.tidymodels.org/reference/step_dummy.html'>step_dummy</a></span><span class='o'>(</span><span class='nf'><a href='https://recipes.tidymodels.org/reference/has_role.html'>all_nominal_predictors</a></span><span class='o'>(</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://embed.tidymodels.org/reference/step_pca_truncated.html'>step_pca_truncated</a></span><span class='o'>(</span><span class='nf'><a href='https://recipes.tidymodels.org/reference/has_role.html'>all_numeric_predictors</a></span><span class='o'>(</span><span class='o'>)</span>, num_comp <span class='o'>=</span> <span class='m'>3</span><span class='o'>)</span></span></code></pre>

</div>

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'>tictoc</span><span class='nf'>::</span><span class='nf'><a href='https://rdrr.io/pkg/tictoc/man/tic.html'>tic</a></span><span class='o'>(</span><span class='o'>)</span></span>
<span><span class='nf'><a href='https://recipes.tidymodels.org/reference/prep.html'>prep</a></span><span class='o'>(</span><span class='nv'>pca_normal</span><span class='o'>)</span> <span class='o'>|&gt;</span> <span class='nf'><a href='https://recipes.tidymodels.org/reference/bake.html'>bake</a></span><span class='o'>(</span><span class='nv'>ames</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 2,930 × 4</span></span></span>
<span><span class='c'>#&gt;    Sale_Price     PC1    PC2   PC3</span></span>
<span><span class='c'>#&gt;         <span style='color: #555555; font-style: italic;'>&lt;int&gt;</span>   <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>  <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 1</span>     <span style='text-decoration: underline;'>215</span>000 -<span style='color: #BB0000; text-decoration: underline;'>31</span><span style='color: #BB0000;'>793.</span>  <span style='text-decoration: underline;'>4</span>151. -<span style='color: #BB0000;'>197.</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 2</span>     <span style='text-decoration: underline;'>105</span>000 -<span style='color: #BB0000; text-decoration: underline;'>12</span><span style='color: #BB0000;'>198.</span>  -<span style='color: #BB0000;'>611.</span> -<span style='color: #BB0000;'>524.</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 3</span>     <span style='text-decoration: underline;'>172</span>000 -<span style='color: #BB0000; text-decoration: underline;'>14</span><span style='color: #BB0000;'>911.</span>  -<span style='color: #BB0000;'>265.</span> <span style='text-decoration: underline;'>7</span>568.</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 4</span>     <span style='text-decoration: underline;'>244</span>000 -<span style='color: #BB0000; text-decoration: underline;'>12</span><span style='color: #BB0000;'>072.</span> -<span style='color: #BB0000; text-decoration: underline;'>1</span><span style='color: #BB0000;'>813.</span>  918.</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 5</span>     <span style='text-decoration: underline;'>189</span>900 -<span style='color: #BB0000; text-decoration: underline;'>14</span><span style='color: #BB0000;'>418.</span>  -<span style='color: #BB0000;'>345.</span> -<span style='color: #BB0000;'>302.</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 6</span>     <span style='text-decoration: underline;'>195</span>500 -<span style='color: #BB0000; text-decoration: underline;'>10</span><span style='color: #BB0000;'>704.</span> -<span style='color: #BB0000; text-decoration: underline;'>1</span><span style='color: #BB0000;'>367.</span> -<span style='color: #BB0000;'>204.</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 7</span>     <span style='text-decoration: underline;'>213</span>500  -<span style='color: #BB0000; text-decoration: underline;'>5</span><span style='color: #BB0000;'>858.</span> -<span style='color: #BB0000; text-decoration: underline;'>2</span><span style='color: #BB0000;'>805.</span>  114.</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 8</span>     <span style='text-decoration: underline;'>191</span>500  -<span style='color: #BB0000; text-decoration: underline;'>5</span><span style='color: #BB0000;'>932.</span> -<span style='color: #BB0000; text-decoration: underline;'>2</span><span style='color: #BB0000;'>762.</span>  131.</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 9</span>     <span style='text-decoration: underline;'>236</span>500  -<span style='color: #BB0000; text-decoration: underline;'>6</span><span style='color: #BB0000;'>368.</span> -<span style='color: #BB0000; text-decoration: underline;'>2</span><span style='color: #BB0000;'>862.</span>  325.</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>10</span>     <span style='text-decoration: underline;'>189</span>000  -<span style='color: #BB0000; text-decoration: underline;'>8</span><span style='color: #BB0000;'>368.</span> -<span style='color: #BB0000; text-decoration: underline;'>2</span><span style='color: #BB0000;'>219.</span>  126.</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># ℹ 2,920 more rows</span></span></span>
<span></span><span><span class='nf'>tictoc</span><span class='nf'>::</span><span class='nf'><a href='https://rdrr.io/pkg/tictoc/man/tic.html'>toc</a></span><span class='o'>(</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; 0.871 sec elapsed</span></span>
<span></span></code></pre>

</div>

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'>tictoc</span><span class='nf'>::</span><span class='nf'><a href='https://rdrr.io/pkg/tictoc/man/tic.html'>tic</a></span><span class='o'>(</span><span class='o'>)</span></span>
<span><span class='nf'><a href='https://recipes.tidymodels.org/reference/prep.html'>prep</a></span><span class='o'>(</span><span class='nv'>pca_truncated</span><span class='o'>)</span> <span class='o'>|&gt;</span> <span class='nf'><a href='https://recipes.tidymodels.org/reference/bake.html'>bake</a></span><span class='o'>(</span><span class='nv'>ames</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 2,930 × 4</span></span></span>
<span><span class='c'>#&gt;    Sale_Price    PC1    PC2   PC3</span></span>
<span><span class='c'>#&gt;         <span style='color: #555555; font-style: italic;'>&lt;int&gt;</span>  <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>  <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 1</span>     <span style='text-decoration: underline;'>215</span>000 <span style='text-decoration: underline;'>31</span>793.  <span style='text-decoration: underline;'>4</span>151. -<span style='color: #BB0000;'>197.</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 2</span>     <span style='text-decoration: underline;'>105</span>000 <span style='text-decoration: underline;'>12</span>198.  -<span style='color: #BB0000;'>611.</span> -<span style='color: #BB0000;'>524.</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 3</span>     <span style='text-decoration: underline;'>172</span>000 <span style='text-decoration: underline;'>14</span>911.  -<span style='color: #BB0000;'>265.</span> <span style='text-decoration: underline;'>7</span>568.</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 4</span>     <span style='text-decoration: underline;'>244</span>000 <span style='text-decoration: underline;'>12</span>072. -<span style='color: #BB0000; text-decoration: underline;'>1</span><span style='color: #BB0000;'>813.</span>  918.</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 5</span>     <span style='text-decoration: underline;'>189</span>900 <span style='text-decoration: underline;'>14</span>418.  -<span style='color: #BB0000;'>345.</span> -<span style='color: #BB0000;'>302.</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 6</span>     <span style='text-decoration: underline;'>195</span>500 <span style='text-decoration: underline;'>10</span>704. -<span style='color: #BB0000; text-decoration: underline;'>1</span><span style='color: #BB0000;'>367.</span> -<span style='color: #BB0000;'>204.</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 7</span>     <span style='text-decoration: underline;'>213</span>500  <span style='text-decoration: underline;'>5</span>858. -<span style='color: #BB0000; text-decoration: underline;'>2</span><span style='color: #BB0000;'>805.</span>  114.</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 8</span>     <span style='text-decoration: underline;'>191</span>500  <span style='text-decoration: underline;'>5</span>932. -<span style='color: #BB0000; text-decoration: underline;'>2</span><span style='color: #BB0000;'>762.</span>  131.</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 9</span>     <span style='text-decoration: underline;'>236</span>500  <span style='text-decoration: underline;'>6</span>368. -<span style='color: #BB0000; text-decoration: underline;'>2</span><span style='color: #BB0000;'>862.</span>  325.</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>10</span>     <span style='text-decoration: underline;'>189</span>000  <span style='text-decoration: underline;'>8</span>368. -<span style='color: #BB0000; text-decoration: underline;'>2</span><span style='color: #BB0000;'>219.</span>  126.</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># ℹ 2,920 more rows</span></span></span>
<span></span><span><span class='nf'>tictoc</span><span class='nf'>::</span><span class='nf'><a href='https://rdrr.io/pkg/tictoc/man/tic.html'>toc</a></span><span class='o'>(</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; 0.253 sec elapsed</span></span>
<span></span></code></pre>

</div>

The speedup will be orders of magnitude larger for very wide data.

## Acknowledgements

We'd like to thank those in the community that contributed to tidymodels in the last quarter:

<div class="highlight">

-   agua: [@hfrick](https://github.com/hfrick), [@simonpcouch](https://github.com/simonpcouch), and [@topepo](https://github.com/topepo).
-   baguette: [@simonpcouch](https://github.com/simonpcouch), and [@topepo](https://github.com/topepo).
-   broom: [@benwhalley](https://github.com/benwhalley), [@dgrtwo](https://github.com/dgrtwo), [@egosv](https://github.com/egosv), [@hfrick](https://github.com/hfrick), [@JorisChau](https://github.com/JorisChau), [@mccarthy-m-g](https://github.com/mccarthy-m-g), [@MichaelChirico](https://github.com/MichaelChirico), [@paige-cho](https://github.com/paige-cho), [@PoGibas](https://github.com/PoGibas), [@rsbivand](https://github.com/rsbivand), [@simonpcouch](https://github.com/simonpcouch), [@ste-tuf](https://github.com/ste-tuf), and [@victor-vscn](https://github.com/victor-vscn).
-   butcher: [@ashbythorpe](https://github.com/ashbythorpe), [@DavisVaughan](https://github.com/DavisVaughan), [@hfrick](https://github.com/hfrick), [@juliasilge](https://github.com/juliasilge), [@rdavis120](https://github.com/rdavis120), and [@simonpcouch](https://github.com/simonpcouch).
-   censored: [@brunocarlin](https://github.com/brunocarlin), and [@hfrick](https://github.com/hfrick).
-   dials: [@amin0511ss](https://github.com/amin0511ss), [@EmilHvitfeldt](https://github.com/EmilHvitfeldt), [@emmafeuer](https://github.com/emmafeuer), [@hfrick](https://github.com/hfrick), and [@simonpcouch](https://github.com/simonpcouch).
-   discrim: [@EmilHvitfeldt](https://github.com/EmilHvitfeldt), and [@tomwagstaff-opml](https://github.com/tomwagstaff-opml).
-   embed: [@EmilHvitfeldt](https://github.com/EmilHvitfeldt), [@jackobenco016](https://github.com/jackobenco016), and [@skasowitz](https://github.com/skasowitz).
-   finetune: [@Freestyleyang](https://github.com/Freestyleyang), [@simonpcouch](https://github.com/simonpcouch), and [@topepo](https://github.com/topepo).
-   hardhat: [@cregouby](https://github.com/cregouby), [@DavisVaughan](https://github.com/DavisVaughan), [@EmilHvitfeldt](https://github.com/EmilHvitfeldt), [@frank113](https://github.com/frank113), and [@mikemahoney218](https://github.com/mikemahoney218).
-   modeldata: [@EmilHvitfeldt](https://github.com/EmilHvitfeldt), and [@topepo](https://github.com/topepo).
-   parsnip: [@EmilHvitfeldt](https://github.com/EmilHvitfeldt), [@exsell-jc](https://github.com/exsell-jc), [@hfrick](https://github.com/hfrick), [@mariamaseng](https://github.com/mariamaseng), [@SHo-JANG](https://github.com/SHo-JANG), [@simonpcouch](https://github.com/simonpcouch), and [@topepo](https://github.com/topepo).
-   recipes: [@AshesITR](https://github.com/AshesITR), [@EmilHvitfeldt](https://github.com/EmilHvitfeldt), [@hfrick](https://github.com/hfrick), [@jjcurtin](https://github.com/jjcurtin), [@lbui30](https://github.com/lbui30), [@PeterKoffeldt](https://github.com/PeterKoffeldt), [@rdavis120](https://github.com/rdavis120), [@simonpcouch](https://github.com/simonpcouch), [@StevenWallaert](https://github.com/StevenWallaert), [@tellyshia](https://github.com/tellyshia), [@topepo](https://github.com/topepo), [@ttrodrigz](https://github.com/ttrodrigz), and [@zecojls](https://github.com/zecojls).
-   rules: [@EmilHvitfeldt](https://github.com/EmilHvitfeldt), [@hfrick](https://github.com/hfrick), [@jonthegeek](https://github.com/jonthegeek), and [@topepo](https://github.com/topepo).
-   spatialsample: [@hfrick](https://github.com/hfrick), [@mikemahoney218](https://github.com/mikemahoney218), and [@RaymondBalise](https://github.com/RaymondBalise).
-   stacks: [@amin0511ss](https://github.com/amin0511ss), [@gundalav](https://github.com/gundalav), [@jrosell](https://github.com/jrosell), [@juliasilge](https://github.com/juliasilge), [@pbulsink](https://github.com/pbulsink), [@rdavis120](https://github.com/rdavis120), and [@simonpcouch](https://github.com/simonpcouch).
-   textrecipes: [@apsteinmetz](https://github.com/apsteinmetz), [@EmilHvitfeldt](https://github.com/EmilHvitfeldt), [@gary-mu](https://github.com/gary-mu), [@hfrick](https://github.com/hfrick), and [@nipnipj](https://github.com/nipnipj).
-   themis: [@carlganz](https://github.com/carlganz), [@EmilHvitfeldt](https://github.com/EmilHvitfeldt), [@hfrick](https://github.com/hfrick), [@nipnipj](https://github.com/nipnipj), [@rmurphy49](https://github.com/rmurphy49), and [@rowanjh](https://github.com/rowanjh).
-   tidyclust: [@EmilHvitfeldt](https://github.com/EmilHvitfeldt), [@hfrick](https://github.com/hfrick), [@hsbadr](https://github.com/hsbadr), [@jonthegeek](https://github.com/jonthegeek), and [@simonpcouch](https://github.com/simonpcouch).
-   tidypredict: [@edgararuiz](https://github.com/edgararuiz), and [@sdcharle](https://github.com/sdcharle).
-   tune: [@BenoitLondon](https://github.com/BenoitLondon), [@hfrick](https://github.com/hfrick), [@jthomasmock](https://github.com/jthomasmock), [@mrjujas](https://github.com/mrjujas), [@MxNl](https://github.com/MxNl), [@nabsiddiqui](https://github.com/nabsiddiqui), [@rdavis120](https://github.com/rdavis120), [@SHo-JANG](https://github.com/SHo-JANG), [@simonpcouch](https://github.com/simonpcouch), [@topepo](https://github.com/topepo), [@walrossker](https://github.com/walrossker), and [@yusuftengriverdi](https://github.com/yusuftengriverdi).
-   workflows: [@simonpcouch](https://github.com/simonpcouch).
-   workflowsets: [@EmilHvitfeldt](https://github.com/EmilHvitfeldt), [@gsimchoni](https://github.com/gsimchoni), and [@simonpcouch](https://github.com/simonpcouch).
-   yardstick: [@77makr](https://github.com/77makr), [@burch-cm](https://github.com/burch-cm), [@EmilHvitfeldt](https://github.com/EmilHvitfeldt), [@idavydov](https://github.com/idavydov), [@kadyb](https://github.com/kadyb), [@mawardivaz](https://github.com/mawardivaz), [@mikemahoney218](https://github.com/mikemahoney218), [@nyambea](https://github.com/nyambea), [@SHo-JANG](https://github.com/SHo-JANG), [@simdadim](https://github.com/simdadim), and [@simonpcouch](https://github.com/simonpcouch).

</div>

We're grateful for all of the tidymodels community, from observers to users to contributors, and wish you all a happy new year!

