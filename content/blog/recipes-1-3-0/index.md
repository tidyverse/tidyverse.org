---
output: hugodown::hugo_document

slug: recipes-1-3-0
title: recipes 1.3.0
date: 2025-04-22
author: Emil Hvitfeldt
description: >
    This release brings multiple exciting features and streamlines many recipe steps.

photo:
  url: https://unsplash.com/photos/background-pattern-3b7sos3CD2c
  author: James Trenda

# one of: "deep-dive", "learn", "package", "programming", "roundup", or "other"
categories: [package] 
tags: [tidymodels, recipes]
rmd_hash: f3cab53603a39588

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

We're thrilled to announce the release of [recipes](https://recipes.tidymodels.org/) 1.3.0. recipes lets you create a pipeable sequence of feature engineering steps.

You can install it from CRAN with:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://rdrr.io/r/utils/install.packages.html'>install.packages</a></span><span class='o'>(</span><span class='s'>"recipes"</span><span class='o'>)</span></span></code></pre>

</div>

This blog post will walk through some of the highlights of this release.

You can see a full list of changes in the [release notes](https://recipes.tidymodels.org/news/index.html#recipes-130).

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://github.com/tidymodels/recipes'>recipes</a></span><span class='o'>)</span></span></code></pre>

</div>

## `strings_as_factors`

Recipes by default convert predictor strings to factors, and the option for that is located in [`prep()`](https://recipes.tidymodels.org/reference/prep.html). This caused an issue when you wanted to set `strings_as_factors = FALSE` for a recipe that is used somewhere else like in a workflow.

This is no longer an issue as we have moved the argument to [`recipe()`](https://recipes.tidymodels.org/reference/recipe.html) itself. We are at the same time deprecating the use of `strings_as_factors` when used in [`prep()`](https://recipes.tidymodels.org/reference/prep.html).

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://modeldata.tidymodels.org'>modeldata</a></span><span class='o'>)</span></span>
<span><span class='nv'>tate_text</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 4,284 × 5</span></span></span>
<span><span class='c'>#&gt;        id artist             title                                  medium  year</span></span>
<span><span class='c'>#&gt;     <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;fct&gt;</span>              <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>                                  <span style='color: #555555; font-style: italic;'>&lt;fct&gt;</span>  <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 1</span>  <span style='text-decoration: underline;'>21</span>926 Absalon            Proposals for a Habitat                Video…  <span style='text-decoration: underline;'>1</span>990</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 2</span>  <span style='text-decoration: underline;'>20</span>472 Auerbach, Frank    Michael                                Etchi…  <span style='text-decoration: underline;'>1</span>990</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 3</span>  <span style='text-decoration: underline;'>20</span>474 Auerbach, Frank    Geoffrey                               Etchi…  <span style='text-decoration: underline;'>1</span>990</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 4</span>  <span style='text-decoration: underline;'>20</span>473 Auerbach, Frank    Jake                                   Etchi…  <span style='text-decoration: underline;'>1</span>990</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 5</span>  <span style='text-decoration: underline;'>20</span>513 Auerbach, Frank    To the Studios                         Oil p…  <span style='text-decoration: underline;'>1</span>990</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 6</span>  <span style='text-decoration: underline;'>21</span>389 Ayres, OBE Gillian Phaëthon                               Oil p…  <span style='text-decoration: underline;'>1</span>990</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 7</span> <span style='text-decoration: underline;'>121</span>187 Barlow, Phyllida   Untitled                               Acryl…  <span style='text-decoration: underline;'>1</span>990</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 8</span>  <span style='text-decoration: underline;'>19</span>455 Baselitz, Georg    Green VIII                             Woodc…  <span style='text-decoration: underline;'>1</span>990</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 9</span>  <span style='text-decoration: underline;'>20</span>938 Beattie, Basil     Present Bound                          Oil p…  <span style='text-decoration: underline;'>1</span>990</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>10</span> <span style='text-decoration: underline;'>105</span>941 Beuys, Joseph      Joseph Beuys: A Private Collection. A… Print…  <span style='text-decoration: underline;'>1</span>990</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># ℹ 4,274 more rows</span></span></span>
<span></span></code></pre>

</div>

We are loading the modeldata package to get `tate_text` which has a character column `title`. If we don't do anything then it turns into a factor.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://recipes.tidymodels.org/reference/recipe.html'>recipe</a></span><span class='o'>(</span><span class='o'>~</span><span class='nv'>.</span>, data <span class='o'>=</span> <span class='nv'>tate_text</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://recipes.tidymodels.org/reference/prep.html'>prep</a></span><span class='o'>(</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://recipes.tidymodels.org/reference/bake.html'>bake</a></span><span class='o'>(</span><span class='nv'>tate_text</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 4,284 × 5</span></span></span>
<span><span class='c'>#&gt;        id artist             title                                  medium  year</span></span>
<span><span class='c'>#&gt;     <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;fct&gt;</span>              <span style='color: #555555; font-style: italic;'>&lt;fct&gt;</span>                                  <span style='color: #555555; font-style: italic;'>&lt;fct&gt;</span>  <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 1</span>  <span style='text-decoration: underline;'>21</span>926 Absalon            Proposals for a Habitat                Video…  <span style='text-decoration: underline;'>1</span>990</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 2</span>  <span style='text-decoration: underline;'>20</span>472 Auerbach, Frank    Michael                                Etchi…  <span style='text-decoration: underline;'>1</span>990</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 3</span>  <span style='text-decoration: underline;'>20</span>474 Auerbach, Frank    Geoffrey                               Etchi…  <span style='text-decoration: underline;'>1</span>990</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 4</span>  <span style='text-decoration: underline;'>20</span>473 Auerbach, Frank    Jake                                   Etchi…  <span style='text-decoration: underline;'>1</span>990</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 5</span>  <span style='text-decoration: underline;'>20</span>513 Auerbach, Frank    To the Studios                         Oil p…  <span style='text-decoration: underline;'>1</span>990</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 6</span>  <span style='text-decoration: underline;'>21</span>389 Ayres, OBE Gillian Phaëthon                               Oil p…  <span style='text-decoration: underline;'>1</span>990</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 7</span> <span style='text-decoration: underline;'>121</span>187 Barlow, Phyllida   Untitled                               Acryl…  <span style='text-decoration: underline;'>1</span>990</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 8</span>  <span style='text-decoration: underline;'>19</span>455 Baselitz, Georg    Green VIII                             Woodc…  <span style='text-decoration: underline;'>1</span>990</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 9</span>  <span style='text-decoration: underline;'>20</span>938 Beattie, Basil     Present Bound                          Oil p…  <span style='text-decoration: underline;'>1</span>990</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>10</span> <span style='text-decoration: underline;'>105</span>941 Beuys, Joseph      Joseph Beuys: A Private Collection. A… Print…  <span style='text-decoration: underline;'>1</span>990</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># ℹ 4,274 more rows</span></span></span>
<span></span></code></pre>

</div>

But we can set `strings_as_factors = FALSE` in [`recipe()`](https://recipes.tidymodels.org/reference/recipe.html) and it won't anymore.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://recipes.tidymodels.org/reference/recipe.html'>recipe</a></span><span class='o'>(</span><span class='o'>~</span><span class='nv'>.</span>, data <span class='o'>=</span> <span class='nv'>tate_text</span>, strings_as_factors <span class='o'>=</span> <span class='kc'>FALSE</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://recipes.tidymodels.org/reference/prep.html'>prep</a></span><span class='o'>(</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://recipes.tidymodels.org/reference/bake.html'>bake</a></span><span class='o'>(</span><span class='nv'>tate_text</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 4,284 × 5</span></span></span>
<span><span class='c'>#&gt;        id artist             title                                  medium  year</span></span>
<span><span class='c'>#&gt;     <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;fct&gt;</span>              <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>                                  <span style='color: #555555; font-style: italic;'>&lt;fct&gt;</span>  <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 1</span>  <span style='text-decoration: underline;'>21</span>926 Absalon            Proposals for a Habitat                Video…  <span style='text-decoration: underline;'>1</span>990</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 2</span>  <span style='text-decoration: underline;'>20</span>472 Auerbach, Frank    Michael                                Etchi…  <span style='text-decoration: underline;'>1</span>990</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 3</span>  <span style='text-decoration: underline;'>20</span>474 Auerbach, Frank    Geoffrey                               Etchi…  <span style='text-decoration: underline;'>1</span>990</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 4</span>  <span style='text-decoration: underline;'>20</span>473 Auerbach, Frank    Jake                                   Etchi…  <span style='text-decoration: underline;'>1</span>990</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 5</span>  <span style='text-decoration: underline;'>20</span>513 Auerbach, Frank    To the Studios                         Oil p…  <span style='text-decoration: underline;'>1</span>990</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 6</span>  <span style='text-decoration: underline;'>21</span>389 Ayres, OBE Gillian Phaëthon                               Oil p…  <span style='text-decoration: underline;'>1</span>990</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 7</span> <span style='text-decoration: underline;'>121</span>187 Barlow, Phyllida   Untitled                               Acryl…  <span style='text-decoration: underline;'>1</span>990</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 8</span>  <span style='text-decoration: underline;'>19</span>455 Baselitz, Georg    Green VIII                             Woodc…  <span style='text-decoration: underline;'>1</span>990</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 9</span>  <span style='text-decoration: underline;'>20</span>938 Beattie, Basil     Present Bound                          Oil p…  <span style='text-decoration: underline;'>1</span>990</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>10</span> <span style='text-decoration: underline;'>105</span>941 Beuys, Joseph      Joseph Beuys: A Private Collection. A… Print…  <span style='text-decoration: underline;'>1</span>990</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># ℹ 4,274 more rows</span></span></span>
<span></span></code></pre>

</div>

This change should also make pragmatic sense as whether you want to turn strings into factors is something that should encoded into the recipe itself.

## Deprecating `step_select()`

We have started the process of deprecating [`step_select()`](https://recipes.tidymodels.org/reference/step_select.html). Given the number of issues people are having with the step and the fact that it doesn't play well with workflows we think this is the right call.

There are two main use cases where [`step_select()`](https://recipes.tidymodels.org/reference/step_select.html) was used. Removing variables, and selecting variables. Removing variables when done with `-` in [`step_select()`](https://recipes.tidymodels.org/reference/step_select.html)

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://recipes.tidymodels.org/reference/recipe.html'>recipe</a></span><span class='o'>(</span><span class='nv'>mpg</span> <span class='o'>~</span> <span class='nv'>.</span>, <span class='nv'>mtcars</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://recipes.tidymodels.org/reference/step_select.html'>step_select</a></span><span class='o'>(</span><span class='o'>-</span><span class='nf'><a href='https://tidyselect.r-lib.org/reference/starts_with.html'>starts_with</a></span><span class='o'>(</span><span class='s'>"d"</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://recipes.tidymodels.org/reference/prep.html'>prep</a></span><span class='o'>(</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://recipes.tidymodels.org/reference/bake.html'>bake</a></span><span class='o'>(</span>new_data <span class='o'>=</span> <span class='kc'>NULL</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 32 × 9</span></span></span>
<span><span class='c'>#&gt;      cyl    hp    wt  qsec    vs    am  gear  carb   mpg</span></span>
<span><span class='c'>#&gt;    <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 1</span>     6   110  2.62  16.5     0     1     4     4  21  </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 2</span>     6   110  2.88  17.0     0     1     4     4  21  </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 3</span>     4    93  2.32  18.6     1     1     4     1  22.8</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 4</span>     6   110  3.22  19.4     1     0     3     1  21.4</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 5</span>     8   175  3.44  17.0     0     0     3     2  18.7</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 6</span>     6   105  3.46  20.2     1     0     3     1  18.1</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 7</span>     8   245  3.57  15.8     0     0     3     4  14.3</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 8</span>     4    62  3.19  20       1     0     4     2  24.4</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 9</span>     4    95  3.15  22.9     1     0     4     2  22.8</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>10</span>     6   123  3.44  18.3     1     0     4     4  19.2</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># ℹ 22 more rows</span></span></span>
<span></span></code></pre>

</div>

These use cases can seamlessly be converted to use [`step_rm()`](https://recipes.tidymodels.org/reference/step_rm.html) without the `-` for the same result.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://recipes.tidymodels.org/reference/recipe.html'>recipe</a></span><span class='o'>(</span><span class='nv'>mpg</span> <span class='o'>~</span> <span class='nv'>.</span>, <span class='nv'>mtcars</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://recipes.tidymodels.org/reference/step_rm.html'>step_rm</a></span><span class='o'>(</span><span class='nf'><a href='https://tidyselect.r-lib.org/reference/starts_with.html'>starts_with</a></span><span class='o'>(</span><span class='s'>"d"</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://recipes.tidymodels.org/reference/prep.html'>prep</a></span><span class='o'>(</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://recipes.tidymodels.org/reference/bake.html'>bake</a></span><span class='o'>(</span>new_data <span class='o'>=</span> <span class='kc'>NULL</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 32 × 9</span></span></span>
<span><span class='c'>#&gt;      cyl    hp    wt  qsec    vs    am  gear  carb   mpg</span></span>
<span><span class='c'>#&gt;    <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 1</span>     6   110  2.62  16.5     0     1     4     4  21  </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 2</span>     6   110  2.88  17.0     0     1     4     4  21  </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 3</span>     4    93  2.32  18.6     1     1     4     1  22.8</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 4</span>     6   110  3.22  19.4     1     0     3     1  21.4</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 5</span>     8   175  3.44  17.0     0     0     3     2  18.7</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 6</span>     6   105  3.46  20.2     1     0     3     1  18.1</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 7</span>     8   245  3.57  15.8     0     0     3     4  14.3</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 8</span>     4    62  3.19  20       1     0     4     2  24.4</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 9</span>     4    95  3.15  22.9     1     0     4     2  22.8</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>10</span>     6   123  3.44  18.3     1     0     4     4  19.2</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># ℹ 22 more rows</span></span></span>
<span></span></code></pre>

</div>

For selecting variables there are two cases. The first is as a tool to select which variables to use in our model. We recommend that you use [`select()`](https://dplyr.tidyverse.org/reference/select.html) to do that before passing the data into the [`recipe()`](https://recipes.tidymodels.org/reference/recipe.html). This is especially helpful since [recipes are tighter with respect to their input types](https://www.tidyverse.org/blog/2024/07/recipes-1-1-0/#column-type-checking), so only passing the data you need to use is helpful.

If you need to do the selection after another step takes effect you should still be able to do so, by using [`step_rm()`](https://recipes.tidymodels.org/reference/step_rm.html) in the following manner.

``` r
step_rm(recipe, all_predictors(), -all_of(<variables that you want to keep>))
```

## `step_dummy()` contrasts argument

Contrasts such as [`contr.treatment()`](https://rdrr.io/r/stats/contrast.html) and [`contr.poly()`](https://rdrr.io/r/stats/contrast.html) are used in [`step_dummy()`](https://recipes.tidymodels.org/reference/step_dummy.html) to determine how the steps should translate categorical values into one or more numeric columns. Traditionally the contrasts were set using [`options()`](https://rdrr.io/r/base/options.html) like so:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://rdrr.io/r/base/options.html'>options</a></span><span class='o'>(</span>contrasts <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span>unordered <span class='o'>=</span> <span class='s'>"contr.poly"</span>, ordered <span class='o'>=</span> <span class='s'>"contr.poly"</span><span class='o'>)</span><span class='o'>)</span></span></code></pre>

</div>

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://recipes.tidymodels.org/reference/recipe.html'>recipe</a></span><span class='o'>(</span><span class='o'>~</span><span class='nv'>species</span> <span class='o'>+</span> <span class='nv'>island</span>, <span class='nv'>penguins</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://recipes.tidymodels.org/reference/step_dummy.html'>step_dummy</a></span><span class='o'>(</span><span class='nf'><a href='https://recipes.tidymodels.org/reference/has_role.html'>all_nominal_predictors</a></span><span class='o'>(</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://recipes.tidymodels.org/reference/prep.html'>prep</a></span><span class='o'>(</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://recipes.tidymodels.org/reference/bake.html'>bake</a></span><span class='o'>(</span>new_data <span class='o'>=</span> <span class='nv'>penguins</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 344 × 4</span></span></span>
<span><span class='c'>#&gt;    species_Chinstrap species_Gentoo island_Dream island_Torgersen</span></span>
<span><span class='c'>#&gt;                <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>          <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>        <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>            <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 1</span>            -<span style='color: #BB0000;'>0.707</span>          0.408        0.707            0.408</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 2</span>            -<span style='color: #BB0000;'>0.707</span>          0.408        0.707            0.408</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 3</span>            -<span style='color: #BB0000;'>0.707</span>          0.408        0.707            0.408</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 4</span>            -<span style='color: #BB0000;'>0.707</span>          0.408        0.707            0.408</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 5</span>            -<span style='color: #BB0000;'>0.707</span>          0.408        0.707            0.408</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 6</span>            -<span style='color: #BB0000;'>0.707</span>          0.408        0.707            0.408</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 7</span>            -<span style='color: #BB0000;'>0.707</span>          0.408        0.707            0.408</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 8</span>            -<span style='color: #BB0000;'>0.707</span>          0.408        0.707            0.408</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 9</span>            -<span style='color: #BB0000;'>0.707</span>          0.408        0.707            0.408</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>10</span>            -<span style='color: #BB0000;'>0.707</span>          0.408        0.707            0.408</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># ℹ 334 more rows</span></span></span>
<span></span></code></pre>

</div>

The issue with this approach is that it pulls from [`options()`](https://rdrr.io/r/base/options.html) when it needs it instead of storing the information. This means that if you put this recipe in production you will need to set the option in the production environment to match that of the training environment.

<div class="highlight">

</div>

To fix this issue we have given [`step_dummy()`](https://recipes.tidymodels.org/reference/step_dummy.html) an argument `contrasts` that work in much the same way. You simply specify the contrast you want and it will be stored in the object for easy deployment.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://recipes.tidymodels.org/reference/recipe.html'>recipe</a></span><span class='o'>(</span><span class='o'>~</span><span class='nv'>species</span> <span class='o'>+</span> <span class='nv'>island</span>, <span class='nv'>penguins</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://recipes.tidymodels.org/reference/step_dummy.html'>step_dummy</a></span><span class='o'>(</span></span>
<span>    <span class='nf'><a href='https://recipes.tidymodels.org/reference/has_role.html'>all_nominal_predictors</a></span><span class='o'>(</span><span class='o'>)</span>, contrasts <span class='o'>=</span> <span class='s'>"contr.poly"</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://recipes.tidymodels.org/reference/prep.html'>prep</a></span><span class='o'>(</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://recipes.tidymodels.org/reference/bake.html'>bake</a></span><span class='o'>(</span>new_data <span class='o'>=</span> <span class='nv'>penguins</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 344 × 4</span></span></span>
<span><span class='c'>#&gt;    species_Chinstrap species_Gentoo island_Dream island_Torgersen</span></span>
<span><span class='c'>#&gt;                <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>          <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>        <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>            <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 1</span>            -<span style='color: #BB0000;'>0.707</span>          0.408        0.707            0.408</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 2</span>            -<span style='color: #BB0000;'>0.707</span>          0.408        0.707            0.408</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 3</span>            -<span style='color: #BB0000;'>0.707</span>          0.408        0.707            0.408</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 4</span>            -<span style='color: #BB0000;'>0.707</span>          0.408        0.707            0.408</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 5</span>            -<span style='color: #BB0000;'>0.707</span>          0.408        0.707            0.408</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 6</span>            -<span style='color: #BB0000;'>0.707</span>          0.408        0.707            0.408</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 7</span>            -<span style='color: #BB0000;'>0.707</span>          0.408        0.707            0.408</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 8</span>            -<span style='color: #BB0000;'>0.707</span>          0.408        0.707            0.408</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 9</span>            -<span style='color: #BB0000;'>0.707</span>          0.408        0.707            0.408</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>10</span>            -<span style='color: #BB0000;'>0.707</span>          0.408        0.707            0.408</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># ℹ 334 more rows</span></span></span>
<span></span></code></pre>

</div>

## tidyselect can be used everywhere

Several steps such as [`step_pls()`](https://recipes.tidymodels.org/reference/step_pls.html) and [`step_impute_bag()`](https://recipes.tidymodels.org/reference/step_impute_bag.html) require the selection of more than just the affected columns. [`step_pls()`](https://recipes.tidymodels.org/reference/step_pls.html) needs you to select an `outcome` variable and [`step_impute_bag()`](https://recipes.tidymodels.org/reference/step_impute_bag.html) needs you to select which variables to impute with, `impute_with`, if you don't want to use all predictors. Previously these needed to be strings or use special selectors like [`imp_vars()`](https://recipes.tidymodels.org/reference/step_impute_bag.html). You don't have to do that anymore. You can now use tidyselect in these arguments too.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://recipes.tidymodels.org/reference/recipe.html'>recipe</a></span><span class='o'>(</span><span class='nv'>mpg</span> <span class='o'>~</span> <span class='nv'>.</span>, <span class='nv'>mtcars</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://recipes.tidymodels.org/reference/step_pls.html'>step_pls</a></span><span class='o'>(</span><span class='nf'><a href='https://recipes.tidymodels.org/reference/has_role.html'>all_predictors</a></span><span class='o'>(</span><span class='o'>)</span>, outcome <span class='o'>=</span> <span class='nv'>mpg</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://recipes.tidymodels.org/reference/prep.html'>prep</a></span><span class='o'>(</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://recipes.tidymodels.org/reference/bake.html'>bake</a></span><span class='o'>(</span>new_data <span class='o'>=</span> <span class='nv'>mtcars</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 32 × 3</span></span></span>
<span><span class='c'>#&gt;      mpg   PLS1   PLS2</span></span>
<span><span class='c'>#&gt;    <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>  <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>  <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 1</span>  21    0.693  0.895</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 2</span>  21    0.650  0.654</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 3</span>  22.8  2.78   0.378</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 4</span>  21.4  0.210 -<span style='color: #BB0000;'>0.368</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 5</span>  18.7 -<span style='color: #BB0000;'>1.95</span>   0.845</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 6</span>  18.1  0.137 -<span style='color: #BB0000;'>0.624</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 7</span>  14.3 -<span style='color: #BB0000;'>2.77</span>   0.364</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 8</span>  24.4  1.81  -<span style='color: #BB0000;'>1.30</span> </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 9</span>  22.8  2.12  -<span style='color: #BB0000;'>1.95</span> </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>10</span>  19.2  0.531 -<span style='color: #BB0000;'>1.51</span> </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># ℹ 22 more rows</span></span></span>
<span></span></code></pre>

</div>

For arguments that allow for multiple selections now work with recipes selectors like [`all_numeric_predictors()`](https://recipes.tidymodels.org/reference/has_role.html) and [`has_role()`](https://recipes.tidymodels.org/reference/has_role.html).

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://recipes.tidymodels.org/reference/recipe.html'>recipe</a></span><span class='o'>(</span><span class='nv'>mpg</span> <span class='o'>~</span> <span class='nv'>.</span>, <span class='nv'>mtcars</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://recipes.tidymodels.org/reference/step_impute_bag.html'>step_impute_bag</a></span><span class='o'>(</span><span class='nf'><a href='https://recipes.tidymodels.org/reference/has_role.html'>all_predictors</a></span><span class='o'>(</span><span class='o'>)</span>, impute_with <span class='o'>=</span> <span class='nf'><a href='https://recipes.tidymodels.org/reference/has_role.html'>has_role</a></span><span class='o'>(</span><span class='s'>"predictor"</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://recipes.tidymodels.org/reference/prep.html'>prep</a></span><span class='o'>(</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://recipes.tidymodels.org/reference/bake.html'>bake</a></span><span class='o'>(</span>new_data <span class='o'>=</span> <span class='nv'>mtcars</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 32 × 11</span></span></span>
<span><span class='c'>#&gt;      cyl  disp    hp  drat    wt  qsec    vs    am  gear  carb   mpg</span></span>
<span><span class='c'>#&gt;    <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 1</span>     6  160    110  3.9   2.62  16.5     0     1     4     4  21  </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 2</span>     6  160    110  3.9   2.88  17.0     0     1     4     4  21  </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 3</span>     4  108     93  3.85  2.32  18.6     1     1     4     1  22.8</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 4</span>     6  258    110  3.08  3.22  19.4     1     0     3     1  21.4</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 5</span>     8  360    175  3.15  3.44  17.0     0     0     3     2  18.7</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 6</span>     6  225    105  2.76  3.46  20.2     1     0     3     1  18.1</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 7</span>     8  360    245  3.21  3.57  15.8     0     0     3     4  14.3</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 8</span>     4  147.    62  3.69  3.19  20       1     0     4     2  24.4</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 9</span>     4  141.    95  3.92  3.15  22.9     1     0     4     2  22.8</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>10</span>     6  168.   123  3.92  3.44  18.3     1     0     4     4  19.2</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># ℹ 22 more rows</span></span></span>
<span></span></code></pre>

</div>

These changes are backwards compatible meaning that the old ways still work with minimal warnings.

## `step_impute_bag()` now takes up less memory

We have another benefit for users of [`step_impute_bag()`](https://recipes.tidymodels.org/reference/step_impute_bag.html). For each variable, it imputes on it fits a bagged tree model, which is then used to predict with for imputation. It was noticed that these models had a larger memory footprint than was needed. This has been remedied so now there should be a noticebly decrease in size for recipes with [`step_impute_bag()`](https://recipes.tidymodels.org/reference/step_impute_bag.html).

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>rec</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://recipes.tidymodels.org/reference/recipe.html'>recipe</a></span><span class='o'>(</span><span class='nv'>Sale_Price</span> <span class='o'>~</span> <span class='nv'>.</span>, data <span class='o'>=</span> <span class='nv'>ames</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://recipes.tidymodels.org/reference/step_impute_bag.html'>step_impute_bag</a></span><span class='o'>(</span><span class='nf'><a href='https://tidyselect.r-lib.org/reference/starts_with.html'>starts_with</a></span><span class='o'>(</span><span class='s'>"Lot_"</span><span class='o'>)</span>, impute_with <span class='o'>=</span> <span class='nf'><a href='https://recipes.tidymodels.org/reference/has_role.html'>all_numeric_predictors</a></span><span class='o'>(</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://recipes.tidymodels.org/reference/prep.html'>prep</a></span><span class='o'>(</span><span class='o'>)</span></span>
<span></span>
<span><span class='nf'>lobstr</span><span class='nf'>::</span><span class='nf'><a href='https://lobstr.r-lib.org/reference/obj_size.html'>obj_size</a></span><span class='o'>(</span><span class='nv'>rec</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; 20.10 MB</span></span>
<span></span></code></pre>

</div>

This recipe took up over `75 MB` and now takes up `20 MB`.

## Acknowledgements

Many thanks to all the people who contributed to recipes since the last release!

[@chillerb](https://github.com/chillerb), [@dshemetov](https://github.com/dshemetov), [@EmilHvitfeldt](https://github.com/EmilHvitfeldt), [@kevbaer](https://github.com/kevbaer), [@nhward](https://github.com/nhward), [@regisely](https://github.com/regisely), and [@topepo](https://github.com/topepo).

