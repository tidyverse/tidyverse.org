---
output: hugodown::hugo_document

slug: tidymodels-2023-q4
title: "Q4 2023 tidymodels digest"
date: 2024-01-08
author: Emil Hvitfeldt
description: >
    The tidymodels team has been busy working on all sorts of new features 
    across the ecosystem.
photo:
  url: https://www.pexels.com/photo/landscape-photography-of-snow-pathway-between-trees-during-winter-688660/
  author: Simon Berger

# one of: "deep-dive", "learn", "package", "programming", "roundup", or "other"
categories: [roundup] 
tags: [tidymodels, recipes]
rmd_hash: c1545b18956cd55f

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

The [tidymodels](https://www.tidymodels.org/) framework is a collection of R packages for modeling and machine learning using tidyverse principles.

Since the beginning of 2021, we have been publishing [quarterly updates](https://www.tidyverse.org/categories/roundup/) here on the tidyverse blog summarizing what's new in the tidymodels ecosystem. The purpose of these regular posts is to share useful new features and any updates you may have missed. You can check out the [`tidymodels` tag](https://www.tidyverse.org/tags/tidymodels/) to find all tidymodels blog posts here, including our roundup posts as well as those that are more focused, like this post from the past couple of months:

-   [Three ways errors are about to get better in tidymodels](https://www.tidyverse.org/blog/2023/11/tidymodels-errors-q4/)

Since [our last roundup post](https://www.tidyverse.org/blog/2022/12/tidymodels-2022-q4/), there have been CRAN releases of 7 tidymodels packages. Here are links to their NEWS files:

<div class="highlight">

-   embed [(1.1.3)](https://embed.tidymodels.org/news/index.html)
-   modeldb [(0.3.0)](https://modeldb.tidymodels.org/news/index.html)
-   recipes [(1.0.9)](https://recipes.tidymodels.org/news/index.html)
-   spatialsample [(0.5.1)](https://spatialsample.tidymodels.org/news/index.html)
-   stacks [(1.0.3)](https://stacks.tidymodels.org/news/index.html)
-   textrecipes [(1.0.6)](https://textrecipes.tidymodels.org/news/index.html)
-   tidyposterior [(1.0.1)](https://tidyposterior.tidymodels.org/news/index.html)

</div>

We'll highlight a few especially notable changes below: Updated warnings when normalizing, and better error messages in recipes.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://tidymodels.tidymodels.org'>tidymodels</a></span><span class='o'>)</span></span>
<span></span>
<span><span class='nf'><a href='https://rdrr.io/r/utils/data.html'>data</a></span><span class='o'>(</span><span class='s'>"ames"</span>, package <span class='o'>=</span> <span class='s'>"modeldata"</span><span class='o'>)</span></span></code></pre>

</div>

## Updated warnings when normalizing

The latest release of recipes features an overhaul of the warnings and error messages to use the [cli](https://cli.r-lib.org/) package. With this, we are starting the project of providing more information signaling when things don't go well.

The first type of issue we now signal for is when you try to normalize data that contains non-numeric numbers such as `NA` or `Inf`. These can sneak in for several reasons, and before this release, it happened silently. Below we are creating a recipe using the `ames` data set, and before we normalize we are taking the logarithms root of all variables that pertain to square footage.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>rec</span> <span class='o'>&lt;-</span> <span class='nf'>recipe</span><span class='o'>(</span><span class='nv'>Sale_Price</span> <span class='o'>~</span> <span class='nv'>.</span>, data <span class='o'>=</span> <span class='nv'>ames</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'>step_log</span><span class='o'>(</span><span class='nf'>contains</span><span class='o'>(</span><span class='s'>"SF"</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'>step_normalize</span><span class='o'>(</span><span class='nf'>all_numeric_predictors</span><span class='o'>(</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'>prep</span><span class='o'>(</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; Warning: Columns `BsmtFin_SF_1`, `BsmtFin_SF_2`, `Bsmt_Unf_SF`, `Total_Bsmt_SF`,</span></span>
<span><span class='c'>#&gt; `Second_Flr_SF`, `Wood_Deck_SF`, and `Open_Porch_SF` returned NaN, because</span></span>
<span><span class='c'>#&gt; variance cannot be calculated and scaling cannot be used. Consider avoiding</span></span>
<span><span class='c'>#&gt; `Inf` or `-Inf` values and/or setting `na_rm = TRUE` before normalizing.</span></span>
<span></span></code></pre>

</div>

We now get a warning that something happened. Telling us that it encountered `Inf` or `-Inf`. Knowing that we can go back and investigate what went wrong. If we exclude `step_normalize()` and `bake()` the recipe, we see that a number of `-Inf` appears

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'>recipe</span><span class='o'>(</span><span class='nv'>Sale_Price</span> <span class='o'>~</span> <span class='nv'>.</span>, data <span class='o'>=</span> <span class='nv'>ames</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'>step_log</span><span class='o'>(</span><span class='nf'>contains</span><span class='o'>(</span><span class='s'>"SF"</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'>prep</span><span class='o'>(</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'>bake</span><span class='o'>(</span>new_data <span class='o'>=</span> <span class='kc'>NULL</span>, <span class='nf'>contains</span><span class='o'>(</span><span class='s'>"SF"</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'>glimpse</span><span class='o'>(</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; Rows: 2,930</span></span>
<span><span class='c'>#&gt; Columns: 8</span></span>
<span><span class='c'>#&gt; $ BsmtFin_SF_1  <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> 0.6931472, 1.7917595, 0.0000000, 0.0000000, 1.0986123, 1…</span></span>
<span><span class='c'>#&gt; $ BsmtFin_SF_2  <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> -Inf, 4.969813, -Inf, -Inf, -Inf, -Inf, -Inf, -Inf, -Inf…</span></span>
<span><span class='c'>#&gt; $ Bsmt_Unf_SF   <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> 6.089045, 5.598422, 6.006353, 6.951772, 4.919981, 5.7807…</span></span>
<span><span class='c'>#&gt; $ Total_Bsmt_SF <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> 6.984716, 6.782192, 7.192182, 7.654443, 6.833032, 6.8308…</span></span>
<span><span class='c'>#&gt; $ First_Flr_SF  <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> 7.412160, 6.797940, 7.192182, 7.654443, 6.833032, 6.8308…</span></span>
<span><span class='c'>#&gt; $ Second_Flr_SF <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> -Inf, -Inf, -Inf, -Inf, 6.552508, 6.519147, -Inf, -Inf, …</span></span>
<span><span class='c'>#&gt; $ Wood_Deck_SF  <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> 5.347108, 4.941642, 5.973810, -Inf, 5.356586, 5.886104, …</span></span>
<span><span class='c'>#&gt; $ Open_Porch_SF <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> 4.127134, -Inf, 3.583519, -Inf, 3.526361, 3.583519, -Inf…</span></span>
<span></span></code></pre>

</div>

Looking at the bare data set, we notice that the `-Inf` all appear where there are `0`, which makes sense since `log(0)`.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>ames</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'>select</span><span class='o'>(</span><span class='nf'>contains</span><span class='o'>(</span><span class='s'>"SF"</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'>glimpse</span><span class='o'>(</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; Rows: 2,930</span></span>
<span><span class='c'>#&gt; Columns: 8</span></span>
<span><span class='c'>#&gt; $ BsmtFin_SF_1  <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> 2, 6, 1, 1, 3, 3, 3, 1, 3, 7, 7, 1, 7, 3, 3, 1, 3, 3, 4,…</span></span>
<span><span class='c'>#&gt; $ BsmtFin_SF_2  <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> 0, 144, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1120, 0, 0, …</span></span>
<span><span class='c'>#&gt; $ Bsmt_Unf_SF   <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> 441, 270, 406, 1045, 137, 324, 722, 1017, 415, 994, 763,…</span></span>
<span><span class='c'>#&gt; $ Total_Bsmt_SF <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> 1080, 882, 1329, 2110, 928, 926, 1338, 1280, 1595, 994, …</span></span>
<span><span class='c'>#&gt; $ First_Flr_SF  <span style='color: #555555; font-style: italic;'>&lt;int&gt;</span> 1656, 896, 1329, 2110, 928, 926, 1338, 1280, 1616, 1028,…</span></span>
<span><span class='c'>#&gt; $ Second_Flr_SF <span style='color: #555555; font-style: italic;'>&lt;int&gt;</span> 0, 0, 0, 0, 701, 678, 0, 0, 0, 776, 892, 0, 676, 0, 0, 1…</span></span>
<span><span class='c'>#&gt; $ Wood_Deck_SF  <span style='color: #555555; font-style: italic;'>&lt;int&gt;</span> 210, 140, 393, 0, 212, 360, 0, 0, 237, 140, 157, 483, 0,…</span></span>
<span><span class='c'>#&gt; $ Open_Porch_SF <span style='color: #555555; font-style: italic;'>&lt;int&gt;</span> 62, 0, 36, 0, 34, 36, 0, 82, 152, 60, 84, 21, 75, 0, 54,…</span></span>
<span></span></code></pre>

</div>

Knowing that it was `0` that caused the problem, we can set an `offset` to avoid taking `log(0)`.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>rec</span> <span class='o'>&lt;-</span> <span class='nf'>recipe</span><span class='o'>(</span><span class='nv'>Sale_Price</span> <span class='o'>~</span> <span class='nv'>.</span>, data <span class='o'>=</span> <span class='nv'>ames</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'>step_log</span><span class='o'>(</span><span class='nf'>contains</span><span class='o'>(</span><span class='s'>"SF"</span><span class='o'>)</span>, offset <span class='o'>=</span> <span class='m'>0.5</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'>step_normalize</span><span class='o'>(</span><span class='nf'>all_numeric_predictors</span><span class='o'>(</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'>prep</span><span class='o'>(</span><span class='o'>)</span></span></code></pre>

</div>

These warnings appear in `step_scale()`, `step_normalize()`, `step_center()` or `step_range()`.

## Better error messages in recipes

Another problem that happens a lot when using recipes, is accidentally selecting variables that have the wrong types. Previously this caused the following error:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'>recipe</span><span class='o'>(</span><span class='nv'>Sale_Price</span> <span class='o'>~</span> <span class='nv'>.</span>, data <span class='o'>=</span> <span class='nv'>ames</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'>step_dummy</span><span class='o'>(</span><span class='nf'>starts_with</span><span class='o'>(</span><span class='s'>"Lot_"</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'>prep</span><span class='o'>(</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; Error in `step_dummy()`:</span></span>
<span><span class='c'>#&gt; Caused by error in `prep()`:</span></span>
<span><span class='c'>#&gt; ! All columns selected for the step should be string, factor, or ordered.</span></span></code></pre>

</div>

In the newest release, it will detail the offending variables and what was wrong with them.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'>recipe</span><span class='o'>(</span><span class='nv'>Sale_Price</span> <span class='o'>~</span> <span class='nv'>.</span>, data <span class='o'>=</span> <span class='nv'>ames</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'>step_dummy</span><span class='o'>(</span><span class='nf'>starts_with</span><span class='o'>(</span><span class='s'>"Lot_"</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'>prep</span><span class='o'>(</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'>bake</span><span class='o'>(</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #BBBB00; font-weight: bold;'>Error</span><span style='font-weight: bold;'> in `step_dummy()`:</span></span></span>
<span><span class='c'>#&gt; <span style='font-weight: bold;'>Caused by error in `prep()`:</span></span></span>
<span><span class='c'>#&gt; <span style='color: #BB0000;'>✖</span> All columns selected for the step should be factor or ordered.</span></span>
<span><span class='c'>#&gt; <span style='color: #00BBBB;'>•</span> 1 double variable found: `Lot_Frontage`</span></span>
<span><span class='c'>#&gt; <span style='color: #00BBBB;'>•</span> 1 integer variable found: `Lot_Area`</span></span>
<span></span></code></pre>

</div>

## Acknowledgements

We'd like to thank those in the community that contributed to tidymodels in the last quarter:

<div class="highlight">

-   embed: [@EmilHvitfeldt](https://github.com/EmilHvitfeldt).
-   modeldb: [@EmilHvitfeldt](https://github.com/EmilHvitfeldt), [@hadley](https://github.com/hadley), and [@topepo](https://github.com/topepo).
-   recipes: [@atusy](https://github.com/atusy), [@bcadenato](https://github.com/bcadenato), [@collinberke](https://github.com/collinberke), [@EmilHvitfeldt](https://github.com/EmilHvitfeldt), [@gfronk](https://github.com/gfronk), [@jkennel](https://github.com/jkennel), [@joeycouse](https://github.com/joeycouse), [@jxu](https://github.com/jxu), [@mastoffel](https://github.com/mastoffel), [@matthewgson](https://github.com/matthewgson), [@millermc38](https://github.com/millermc38), [@ray-p144](https://github.com/ray-p144), [@sebsfox](https://github.com/sebsfox), [@simonpcouch](https://github.com/simonpcouch), and [@topepo](https://github.com/topepo).
-   spatialsample: [@mikemahoney218](https://github.com/mikemahoney218).
-   stacks: [@juliasilge](https://github.com/juliasilge), and [@simonpcouch](https://github.com/simonpcouch).
-   textrecipes: [@EmilHvitfeldt](https://github.com/EmilHvitfeldt), [@jd4ds](https://github.com/jd4ds), and [@masurp](https://github.com/masurp).
-   tidyposterior: [@topepo](https://github.com/topepo).

</div>

We're grateful for all of the tidymodels community, from observers to users to contributors. Happy modeling!

