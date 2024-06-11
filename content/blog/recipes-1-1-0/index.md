---
output: hugodown::hugo_document

slug: recipes-1-1-0
title: recipes 1.1.0
date: 2024-07-01
author: Emil Hvitfeldt
description: >
    recipes 1.1.0 is on CRAN! recipes now has better input checking and quality of life errors.

photo:
  url: https://unsplash.com/photos/close-up-photo-of-baked-cookies-OfdDiqx8Cz8
  author: Food Photographer | Jennifer Pallian

# one of: "deep-dive", "learn", "package", "programming", "roundup", or "other"
categories: [package] 
tags: [tidymodels, recipes]
rmd_hash: 2d6d3d7956133624

---

<!--
TODO:
* [x] Look over / edit the post's title in the yaml
* [x] Edit (or delete) the description; note this appears in the Twitter card
* [x] Pick category and tags (see existing with [`hugodown::tidy_show_meta()`](https://rdrr.io/pkg/hugodown/man/use_tidy_post.html))
* [x] Find photo & update yaml metadata
* [ ] Create `thumbnail-sq.jpg`; height and width should be equal
* [ ] Create `thumbnail-wd.jpg`; width should be >5x height
* [ ] [`hugodown::use_tidy_thumbnails()`](https://rdrr.io/pkg/hugodown/man/use_tidy_post.html)
* [ ] Add intro sentence, e.g. the standard tagline for the package
* [ ] [`usethis::use_tidy_thanks()`](https://usethis.r-lib.org/reference/use_tidy_thanks.html)
-->

We're thrilled to announce the release of [recipes](https://recipes.tidymodels.org/) 1.1.0. censored is a parsnip extension package for survival models.

You can install it from CRAN with:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://rdrr.io/r/utils/install.packages.html'>install.packages</a></span><span class='o'>(</span><span class='s'>"recipes"</span><span class='o'>)</span></span></code></pre>

</div>

This blog post will go over some of the bigger changes in this release.

You can see a full list of changes in the [release notes](https://github.com/tidymodels/recipes/releases/tag/v1.1.0).

## ptype information

A [longtime issue](https://github.com/tidymodels/recipes/issues/793) in recipes comes from the fact that recipes didn't keep a [prototype](https://vctrs.r-lib.org/articles/type-size.html) (ptype) of the data it was specified with. This would cause unexpected things to happen or uninformative error messages to appear if different data was used to [`prep()`](https://recipes.tidymodels.org/reference/prep.html) than was used to specify it.

In the below example, we specify a recipe where `x2` starts by being a character vector, but the recipe is prepped where `x2` is a numeric vector. This didn't produce any problems before,

``` r
data_template <- tibble(outcome = rnorm(10), x1 = rnorm(10), x2 = sample(letters, 10, T))

rec <- recipe(outcome ~ ., data_template) %>%
  step_bin2factor(all_numeric_predictors())

data_training <- tibble(outcome = rnorm(1000), x1 = rnorm(1000), x2 = rnorm(1000))

prep(rec, training = data_training)
#> 
#> ── Recipe ──────────────────────────────────────────────────────────────────────
#> 
#> ── Inputs
#> Number of variables by role
#> outcome:   1
#> predictor: 2
#> 
#> ── Training information
#> Training data contained 1000 data points and no incomplete rows.
#> 
#> ── Operations
#> • Dummy variable to factor conversion for: x1 | Trained
```

but now we get an error detailing how the data is different:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>data_template</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://tibble.tidyverse.org/reference/tibble.html'>tibble</a></span><span class='o'>(</span>outcome <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/stats/Normal.html'>rnorm</a></span><span class='o'>(</span><span class='m'>10</span><span class='o'>)</span>, x1 <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/stats/Normal.html'>rnorm</a></span><span class='o'>(</span><span class='m'>10</span><span class='o'>)</span>, x2 <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/sample.html'>sample</a></span><span class='o'>(</span><span class='nv'>letters</span>, <span class='m'>10</span>, <span class='kc'>T</span><span class='o'>)</span><span class='o'>)</span></span>
<span></span>
<span><span class='nv'>rec</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://recipes.tidymodels.org/reference/recipe.html'>recipe</a></span><span class='o'>(</span><span class='nv'>outcome</span> <span class='o'>~</span> <span class='nv'>.</span>, <span class='nv'>data_template</span><span class='o'>)</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span></span>
<span>  <span class='nf'><a href='https://recipes.tidymodels.org/reference/step_bin2factor.html'>step_bin2factor</a></span><span class='o'>(</span><span class='nf'><a href='https://recipes.tidymodels.org/reference/has_role.html'>all_numeric_predictors</a></span><span class='o'>(</span><span class='o'>)</span><span class='o'>)</span></span>
<span></span>
<span><span class='nv'>data_training</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://tibble.tidyverse.org/reference/tibble.html'>tibble</a></span><span class='o'>(</span>outcome <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/stats/Normal.html'>rnorm</a></span><span class='o'>(</span><span class='m'>1000</span><span class='o'>)</span>, x1 <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/stats/Normal.html'>rnorm</a></span><span class='o'>(</span><span class='m'>1000</span><span class='o'>)</span>, x2 <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/stats/Normal.html'>rnorm</a></span><span class='o'>(</span><span class='m'>1000</span><span class='o'>)</span><span class='o'>)</span></span>
<span></span>
<span><span class='nf'><a href='https://recipes.tidymodels.org/reference/prep.html'>prep</a></span><span class='o'>(</span><span class='nv'>rec</span>, training <span class='o'>=</span> <span class='nv'>data_training</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #BBBB00; font-weight: bold;'>Error</span><span style='font-weight: bold;'> in `prep()`:</span></span></span>
<span><span class='c'>#&gt; <span style='color: #BB0000;'>✖</span> The following variable has the wrong class:</span></span>
<span><span class='c'>#&gt; <span style='color: #00BBBB;'>•</span> `x2` must have class <span style='color: #0000BB;'>&lt;numeric&gt;</span>, not <span style='color: #0000BB;'>&lt;character&gt;</span>.</span></span>
<span></span></code></pre>

</div>

In addition, we are exporting the two helper functions [`recipes_ptype()`](https://recipes.tidymodels.org/reference/recipes_ptype.html) and [`recipes_ptype_validate()`](https://recipes.tidymodels.org/reference/recipes_ptype_validate.html) to extract and validate ptype information for a given recipe.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://recipes.tidymodels.org/reference/recipes_ptype.html'>recipes_ptype</a></span><span class='o'>(</span><span class='nv'>rec</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 0 × 3</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># ℹ 3 variables: x1 &lt;dbl&gt;, x2 &lt;chr&gt;, outcome &lt;dbl&gt;</span></span></span>
<span></span></code></pre>

</div>

Note that recipes created before version 1.1.0 don't contain any ptype information, and will not undergo checking. Rerunning the code to specify the recipe will add ptype information to the recipe.

## Input checking in recipe()

Every recipe you create start with a call to [`recipe()`](https://recipes.tidymodels.org/reference/recipe.html). We have relaxed the requirements of data frames, while increasing the feedback when something goes wrong.

The data was previously passed through [`model.frame()`](https://rdrr.io/r/stats/model.frame.html) inside the recipe, which restricted what could be handled. Previously prohibited input included data frames with list-columns or [sf](https://r-spatial.github.io/sf/) data frames. Both of these are now supported, as long as they are a `data.frame` object.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>data_listcolumn</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://tibble.tidyverse.org/reference/tibble.html'>tibble</a></span><span class='o'>(</span></span>
<span>  y <span class='o'>=</span> <span class='m'>1</span><span class='o'>:</span><span class='m'>4</span>,</span>
<span>  x <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span><span class='m'>1</span><span class='o'>:</span><span class='m'>3</span>, <span class='m'>4</span><span class='o'>:</span><span class='m'>6</span>, <span class='m'>3</span><span class='o'>:</span><span class='m'>1</span>, <span class='m'>1</span><span class='o'>:</span><span class='m'>10</span><span class='o'>)</span></span>
<span><span class='o'>)</span></span>
<span></span>
<span><span class='nf'><a href='https://recipes.tidymodels.org/reference/recipe.html'>recipe</a></span><span class='o'>(</span><span class='nv'>y</span> <span class='o'>~</span> <span class='nv'>.</span>, data <span class='o'>=</span> <span class='nv'>data_listcolumn</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; </span></span>
<span></span><span><span class='c'>#&gt; <span style='color: #00BBBB;'>──</span> <span style='font-weight: bold;'>Recipe</span> <span style='color: #00BBBB;'>──────────────────────────────────────────────────────────────────────</span></span></span>
<span></span><span><span class='c'>#&gt; </span></span>
<span></span><span><span class='c'>#&gt; ── Inputs</span></span>
<span></span><span><span class='c'>#&gt; Number of variables by role</span></span>
<span></span><span><span class='c'>#&gt; outcome:   1</span></span>
<span><span class='c'>#&gt; predictor: 1</span></span>
<span></span></code></pre>

</div>

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://r-spatial.github.io/sf/'>sf</a></span><span class='o'>)</span></span>
<span><span class='c'>#&gt; Linking to GEOS 3.11.0, GDAL 3.5.3, PROJ 9.1.0; sf_use_s2() is TRUE</span></span>
<span></span><span><span class='nv'>pathshp</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/system.file.html'>system.file</a></span><span class='o'>(</span><span class='s'>"shape/nc.shp"</span>, package <span class='o'>=</span> <span class='s'>"sf"</span><span class='o'>)</span></span>
<span><span class='nv'>data_sf</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://r-spatial.github.io/sf/reference/st_read.html'>st_read</a></span><span class='o'>(</span><span class='nv'>pathshp</span>, quiet <span class='o'>=</span> <span class='kc'>TRUE</span><span class='o'>)</span></span>
<span></span>
<span><span class='nf'><a href='https://recipes.tidymodels.org/reference/recipe.html'>recipe</a></span><span class='o'>(</span><span class='nv'>AREA</span> <span class='o'>~</span> <span class='nv'>.</span>, data <span class='o'>=</span> <span class='nv'>data_sf</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; </span></span>
<span></span><span><span class='c'>#&gt; <span style='color: #00BBBB;'>──</span> <span style='font-weight: bold;'>Recipe</span> <span style='color: #00BBBB;'>──────────────────────────────────────────────────────────────────────</span></span></span>
<span></span><span><span class='c'>#&gt; </span></span>
<span></span><span><span class='c'>#&gt; ── Inputs</span></span>
<span></span><span><span class='c'>#&gt; Number of variables by role</span></span>
<span></span><span><span class='c'>#&gt; outcome:    1</span></span>
<span><span class='c'>#&gt; predictor: 14</span></span>
<span></span></code></pre>

</div>

We are excited to see what people can do with these new options.

Another way to specify a recipe is to use [`add_role()`](https://recipes.tidymodels.org/reference/roles.html) and [`update_role()`](https://recipes.tidymodels.org/reference/roles.html). But if you are not careful, you can end up in situations where the same variable is labeled as both the outcome and predictor.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='c'># didn't use to throw a warning</span></span>
<span><span class='nf'><a href='https://recipes.tidymodels.org/reference/recipe.html'>recipe</a></span><span class='o'>(</span><span class='nv'>mtcars</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://recipes.tidymodels.org/reference/roles.html'>update_role</a></span><span class='o'>(</span><span class='nf'><a href='https://tidyselect.r-lib.org/reference/everything.html'>everything</a></span><span class='o'>(</span><span class='o'>)</span>, new_role <span class='o'>=</span> <span class='s'>"predictor"</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://recipes.tidymodels.org/reference/roles.html'>add_role</a></span><span class='o'>(</span><span class='s'>"mpg"</span>, new_role <span class='o'>=</span> <span class='s'>"outcome"</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #BBBB00; font-weight: bold;'>Error</span><span style='font-weight: bold;'> in `add_role()`:</span></span></span>
<span><span class='c'>#&gt; <span style='color: #BBBB00;'>!</span> `mpg` cannot get <span style='color: #0000BB;'>"outcome"</span> role as it already has role <span style='color: #0000BB;'>"predictor"</span>.</span></span>
<span></span></code></pre>

</div>

This specific problem can be dealt with using [`update_role()`](https://recipes.tidymodels.org/reference/roles.html) instead of [`add_role()`](https://recipes.tidymodels.org/reference/roles.html).

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://recipes.tidymodels.org/reference/recipe.html'>recipe</a></span><span class='o'>(</span><span class='nv'>mtcars</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://recipes.tidymodels.org/reference/roles.html'>update_role</a></span><span class='o'>(</span><span class='nf'><a href='https://tidyselect.r-lib.org/reference/everything.html'>everything</a></span><span class='o'>(</span><span class='o'>)</span>, new_role <span class='o'>=</span> <span class='s'>"predictor"</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://recipes.tidymodels.org/reference/roles.html'>update_role</a></span><span class='o'>(</span><span class='s'>"mpg"</span>, new_role <span class='o'>=</span> <span class='s'>"outcome"</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; </span></span>
<span></span><span><span class='c'>#&gt; <span style='color: #00BBBB;'>──</span> <span style='font-weight: bold;'>Recipe</span> <span style='color: #00BBBB;'>──────────────────────────────────────────────────────────────────────</span></span></span>
<span></span><span><span class='c'>#&gt; </span></span>
<span></span><span><span class='c'>#&gt; ── Inputs</span></span>
<span></span><span><span class='c'>#&gt; Number of variables by role</span></span>
<span></span><span><span class='c'>#&gt; outcome:    1</span></span>
<span><span class='c'>#&gt; predictor: 10</span></span>
<span></span></code></pre>

</div>

## Long formulas in recipe()

Related to the changes we saw above, we now fully support very long formulas without hitting a `C stack usage` error.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>data_wide</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/matrix.html'>matrix</a></span><span class='o'>(</span><span class='m'>1</span><span class='o'>:</span><span class='m'>10000</span>, ncol <span class='o'>=</span> <span class='m'>10000</span><span class='o'>)</span></span>
<span><span class='nv'>data_wide</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/as.data.frame.html'>as.data.frame</a></span><span class='o'>(</span><span class='nv'>data_wide</span><span class='o'>)</span></span>
<span><span class='nf'><a href='https://rdrr.io/r/base/names.html'>names</a></span><span class='o'>(</span><span class='nv'>data_wide</span><span class='o'>)</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/paste.html'>paste0</a></span><span class='o'>(</span><span class='s'>"x"</span>, <span class='m'>1</span><span class='o'>:</span><span class='m'>10000</span><span class='o'>)</span><span class='o'>)</span></span>
<span></span>
<span><span class='nv'>long_formula</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/stats/formula.html'>as.formula</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/paste.html'>paste</a></span><span class='o'>(</span><span class='s'>"~ "</span>, <span class='nf'><a href='https://rdrr.io/r/base/paste.html'>paste</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/names.html'>names</a></span><span class='o'>(</span><span class='nv'>data_wide</span><span class='o'>)</span>, collapse <span class='o'>=</span> <span class='s'>" + "</span><span class='o'>)</span><span class='o'>)</span><span class='o'>)</span></span>
<span></span>
<span><span class='nf'><a href='https://recipes.tidymodels.org/reference/recipe.html'>recipe</a></span><span class='o'>(</span><span class='nv'>long_formula</span>, <span class='nv'>data_wide</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; </span></span>
<span></span><span><span class='c'>#&gt; <span style='color: #00BBBB;'>──</span> <span style='font-weight: bold;'>Recipe</span> <span style='color: #00BBBB;'>──────────────────────────────────────────────────────────────────────</span></span></span>
<span></span><span><span class='c'>#&gt; </span></span>
<span></span><span><span class='c'>#&gt; ── Inputs</span></span>
<span></span><span><span class='c'>#&gt; Number of variables by role</span></span>
<span></span><span><span class='c'>#&gt; predictor: 10000</span></span>
<span></span></code></pre>

</div>

## Better error for misspelled argument names

If you have used recipes long enough you are very likely to have run into the following error:

``` r
recipe(mpg ~ ., data = mtcars) |>
  step_pca(all_numeric_predictors(), number = 4) |>
  prep()
#> Error in `step_pca()`:
#> Caused by error in `prep()`:
#> ! Can't rename variables in this context.
```

and the first time you saw it, it didn't make much sense. Hopefully, you figured out that [step_pca()](https://recipes.tidymodels.org/reference/step_pca.html) doesn't have a `number` argument, and instead uses `num_comp` to determine the number of principal components to return. This confusion will be a thing of the past as we now include this improved error message:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://recipes.tidymodels.org/reference/recipe.html'>recipe</a></span><span class='o'>(</span><span class='nv'>mpg</span> <span class='o'>~</span> <span class='nv'>.</span>, data <span class='o'>=</span> <span class='nv'>mtcars</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://recipes.tidymodels.org/reference/step_pca.html'>step_pca</a></span><span class='o'>(</span><span class='nf'><a href='https://recipes.tidymodels.org/reference/has_role.html'>all_numeric_predictors</a></span><span class='o'>(</span><span class='o'>)</span>, number <span class='o'>=</span> <span class='m'>4</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://recipes.tidymodels.org/reference/prep.html'>prep</a></span><span class='o'>(</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #BBBB00; font-weight: bold;'>Error</span><span style='font-weight: bold;'> in `step_pca()`:</span></span></span>
<span><span class='c'>#&gt; <span style='font-weight: bold;'>Caused by error in `prep()`:</span></span></span>
<span><span class='c'>#&gt; <span style='color: #BBBB00;'>!</span> The following argument was specified but do not exist: `number`.</span></span>
<span></span></code></pre>

</div>

## Quality of life increases in step_dummy()

I would imagine that one of the most used steps is [`step_dummy()`](https://recipes.tidymodels.org/reference/step_dummy.html). We have improved the errors and warnings it spits out when things go sideways.

If you apply [`step_dummy()`](https://recipes.tidymodels.org/reference/step_dummy.html) to a variable that contains a lot of levels, it will produce a lot of columns, which depending on the size of your data won't fit in memory. This can lead to the following error:

``` r
data_id <- tibble(
  id = as.character(1:100000), 
  x1 = rnorm(100000), 
  x2 = sample(letters, 100000, TRUE)
)

recipe(~ ., data = data_id) |>
  step_dummy(all_nominal_predictors()) |>
  prep()
#> Error: vector memory exhausted (limit reached?)
```

Instead, you now get a more helpful error message.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>data_id</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://tibble.tidyverse.org/reference/tibble.html'>tibble</a></span><span class='o'>(</span></span>
<span>  id <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/character.html'>as.character</a></span><span class='o'>(</span><span class='m'>1</span><span class='o'>:</span><span class='m'>100000</span><span class='o'>)</span>, </span>
<span>  x1 <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/stats/Normal.html'>rnorm</a></span><span class='o'>(</span><span class='m'>100000</span><span class='o'>)</span>, </span>
<span>  x2 <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/sample.html'>sample</a></span><span class='o'>(</span><span class='nv'>letters</span>, <span class='m'>100000</span>, <span class='kc'>TRUE</span><span class='o'>)</span></span>
<span><span class='o'>)</span></span>
<span></span>
<span><span class='nf'><a href='https://recipes.tidymodels.org/reference/recipe.html'>recipe</a></span><span class='o'>(</span><span class='o'>~</span> <span class='nv'>.</span>, data <span class='o'>=</span> <span class='nv'>data_id</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://recipes.tidymodels.org/reference/step_dummy.html'>step_dummy</a></span><span class='o'>(</span><span class='nf'><a href='https://recipes.tidymodels.org/reference/has_role.html'>all_nominal_predictors</a></span><span class='o'>(</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://recipes.tidymodels.org/reference/prep.html'>prep</a></span><span class='o'>(</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #BBBB00; font-weight: bold;'>Error</span><span style='font-weight: bold;'> in `step_dummy()`:</span></span></span>
<span><span class='c'>#&gt; <span style='font-weight: bold;'>Caused by error:</span></span></span>
<span><span class='c'>#&gt; <span style='color: #BBBB00;'>!</span> `id` contains too many levels (100000), which would result in a</span></span>
<span><span class='c'>#&gt;   data.frame too large to fit in memory.</span></span>
<span></span></code></pre>

</div>

Likewise, you will get helpful errors if [`step_dummy()`](https://recipes.tidymodels.org/reference/step_dummy.html) gets a `NA` or unseen values

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>data_train</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://tibble.tidyverse.org/reference/tibble.html'>tibble</a></span><span class='o'>(</span>x <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"a"</span>, <span class='s'>"b"</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='nv'>data_unseen</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://tibble.tidyverse.org/reference/tibble.html'>tibble</a></span><span class='o'>(</span>x <span class='o'>=</span> <span class='s'>"c"</span><span class='o'>)</span></span>
<span></span>
<span><span class='nv'>rec_spec</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://recipes.tidymodels.org/reference/recipe.html'>recipe</a></span><span class='o'>(</span><span class='o'>~</span><span class='nv'>.</span>, data <span class='o'>=</span> <span class='nv'>data_train</span><span class='o'>)</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span></span>
<span>  <span class='nf'><a href='https://recipes.tidymodels.org/reference/step_dummy.html'>step_dummy</a></span><span class='o'>(</span><span class='nv'>x</span><span class='o'>)</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span></span>
<span>  <span class='nf'><a href='https://recipes.tidymodels.org/reference/prep.html'>prep</a></span><span class='o'>(</span><span class='o'>)</span></span>
<span></span>
<span><span class='nv'>rec_spec</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span></span>
<span>  <span class='nf'><a href='https://recipes.tidymodels.org/reference/bake.html'>bake</a></span><span class='o'>(</span><span class='nv'>data_unseen</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; Warning: <span style='color: #BBBB00;'>!</span> There are new levels in `x`: <span style='color: #0000BB;'>"c"</span>.</span></span>
<span><span class='c'>#&gt; <span style='color: #00BBBB;'>ℹ</span> Consider using step_novel() (`?recipes::step_novel()`) \ before</span></span>
<span><span class='c'>#&gt;   `step_dummy()` to handle unseen values.</span></span>
<span></span><span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 1 × 1</span></span></span>
<span><span class='c'>#&gt;     x_b</span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span>    <span style='color: #BB0000;'>NA</span></span></span>
<span></span></code></pre>

</div>

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>data_na</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://tibble.tidyverse.org/reference/tibble.html'>tibble</a></span><span class='o'>(</span>x <span class='o'>=</span> <span class='kc'>NA</span><span class='o'>)</span></span>
<span></span>
<span><span class='nv'>rec_spec</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span></span>
<span>  <span class='nf'><a href='https://recipes.tidymodels.org/reference/bake.html'>bake</a></span><span class='o'>(</span><span class='nv'>data_na</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; Warning: <span style='color: #BBBB00;'>!</span> There are new levels in `x`: <span style='color: #0000BB;'>NA</span>.</span></span>
<span><span class='c'>#&gt; <span style='color: #00BBBB;'>ℹ</span> Consider using step_unknown() (`?recipes::step_unknown()`) before</span></span>
<span><span class='c'>#&gt;   `step_dummy()` to handle missing values.</span></span>
<span></span><span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 1 × 1</span></span></span>
<span><span class='c'>#&gt;     x_b</span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span>    <span style='color: #BB0000;'>NA</span></span></span>
<span></span></code></pre>

</div>

## Acknowledgements

A big thank you to all the people who have contributed to recipes since the release of v1.0.10:

[@brynhum](https://github.com/brynhum), [@DemetriPananos](https://github.com/DemetriPananos), [@diegoperoni](https://github.com/diegoperoni), [@EmilHvitfeldt](https://github.com/EmilHvitfeldt), [@JiahuaQu](https://github.com/JiahuaQu), [@joranE](https://github.com/joranE), [@nhward](https://github.com/nhward), [@olivroy](https://github.com/olivroy), and [@simonpcouch](https://github.com/simonpcouch).

