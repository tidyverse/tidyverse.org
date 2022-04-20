---
output: hugodown::hugo_document

slug: recipes-update-04-20222
title: Updates for recipes extension packages
date: 2022-04-19
author: Emil Hvitfeldt
description: >
    The three extension packages for recipes were recently updated 
    on CRAN adding new steps, features and bug fixes.

photo:
  url: https://unsplash.com/photos/nAMLTEerpWI
  author: Tim Hüfner

# one of: "deep-dive", "learn", "package", "programming", "roundup", or "other"
categories: [package] 
tags: [recipes, tidymodels]
rmd_hash: f0f5dbf60456ffed

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

We're tickled pink to announce the releases of extension packages that followed the recent release of [recipes](https://recipes.tidymodels.org/) 0.2.0. recipes is a package for preprocessing data before using it in models or visualizations. You can think of it as a mash-up of [`model.matrix()`](https://rdrr.io/r/stats/model.matrix.html) and dplyr.

You can install the these updates from CRAN with:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://rdrr.io/r/utils/install.packages.html'>install.packages</a></span><span class='o'>(</span><span class='s'>"embed"</span><span class='o'>)</span>
<span class='nf'><a href='https://rdrr.io/r/utils/install.packages.html'>install.packages</a></span><span class='o'>(</span><span class='s'>"themis"</span><span class='o'>)</span>
<span class='nf'><a href='https://rdrr.io/r/utils/install.packages.html'>install.packages</a></span><span class='o'>(</span><span class='s'>"textrecipes"</span><span class='o'>)</span></code></pre>

</div>

The `NEWS` files are linked here for each package; We will go over some of the bigger changes within and between these packages in this post. A lot of the smaller changes were done to make sure that these extension packages are up to the same standard as recipes itself.

-   [embed](https://embed.tidymodels.org/news/index.html#embed-020)
-   [themis](https://themis.tidymodels.org/news/index.html#themis-020)
-   [textrecipes](https://textrecipes.tidymodels.org/news/index.html#textrecipes-051)

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://github.com/tidymodels/recipes'>recipes</a></span><span class='o'>)</span>
<span class='c'>#&gt; Loading required package: dplyr</span>
<span class='c'>#&gt; </span>
<span class='c'>#&gt; Attaching package: 'dplyr'</span>
<span class='c'>#&gt; The following objects are masked from 'package:stats':</span>
<span class='c'>#&gt; </span>
<span class='c'>#&gt;     filter, lag</span>
<span class='c'>#&gt; The following objects are masked from 'package:base':</span>
<span class='c'>#&gt; </span>
<span class='c'>#&gt;     intersect, setdiff, setequal, union</span>
<span class='c'>#&gt; </span>
<span class='c'>#&gt; Attaching package: 'recipes'</span>
<span class='c'>#&gt; The following object is masked from 'package:stats':</span>
<span class='c'>#&gt; </span>
<span class='c'>#&gt;     step</span>
<span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://embed.tidymodels.org'>embed</a></span><span class='o'>)</span>
<span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://github.com/tidymodels/themis'>themis</a></span><span class='o'>)</span>
<span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://github.com/tidymodels/textrecipes'>textrecipes</a></span><span class='o'>)</span>
<span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://modeldata.tidymodels.org'>modeldata</a></span><span class='o'>)</span>
<span class='nf'><a href='https://rdrr.io/r/base/Random.html'>set.seed</a></span><span class='o'>(</span><span class='m'>1234</span><span class='o'>)</span></code></pre>

</div>

## embed

[`step_feature_hash()`](https://embed.tidymodels.org/reference/step_feature_hash.html) is now soft deprecated in embed in favor of [`step_dummy_hash()`](https://textrecipes.tidymodels.org/reference/step_dummy_hash.html) in textrecipes. The embed version uses TensorFlow, which for some use cases is quite a dependency. One thing to keep an eye out for when moving over is that the textrecipes version uses `num_terms` instead of `num_hash` to denote the number of columns to output.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://rdrr.io/r/utils/data.html'>data</a></span><span class='o'>(</span><span class='nv'>Sacramento</span><span class='o'>)</span>

<span class='c'># Old recipe</span>
<span class='nv'>embed_rec</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://recipes.tidymodels.org/reference/recipe.html'>recipe</a></span><span class='o'>(</span><span class='nv'>price</span> <span class='o'>~</span> <span class='nv'>zip</span>, data <span class='o'>=</span> <span class='nv'>Sacramento</span><span class='o'>)</span> <span class='o'><a href='https://textrecipes.tidymodels.org/reference/pipe.html'>%&gt;%</a></span>
  <span class='nf'><a href='https://embed.tidymodels.org/reference/step_feature_hash.html'>step_feature_hash</a></span><span class='o'>(</span><span class='nv'>zip</span>, num_hash <span class='o'>=</span> <span class='m'>64</span><span class='o'>)</span>
<span class='c'>#&gt; Loaded Tensorflow version 2.8.0</span>

<span class='c'># New recipe</span>
<span class='nv'>textrecipes_rec</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://recipes.tidymodels.org/reference/recipe.html'>recipe</a></span><span class='o'>(</span><span class='nv'>price</span> <span class='o'>~</span> <span class='nv'>zip</span>, data <span class='o'>=</span> <span class='nv'>Sacramento</span><span class='o'>)</span> <span class='o'><a href='https://textrecipes.tidymodels.org/reference/pipe.html'>%&gt;%</a></span>
  <span class='nf'><a href='https://textrecipes.tidymodels.org/reference/step_dummy_hash.html'>step_dummy_hash</a></span><span class='o'>(</span><span class='nv'>zip</span>, num_terms <span class='o'>=</span> <span class='m'>64</span><span class='o'>)</span></code></pre>

</div>

## themis

In addition to fixing all the reported bugs, we have two fairly major announcements. A new step [`step_smotenc()`](https://themis.tidymodels.org/reference/step_smotenc.html) was added thanks to [Robert Gregg](https://github.com/RobertGregg). This step applies the SMOTENC algorithm that is used to synthetically generate observations from minority classes. The SMOTENC method can handle a mix of categorical and numerical predictors which was not possible using the existing SMOTE method which could only operate on numeric predictors.

The `hpc_data` illustrates this use case neatly. The data set contains characteristics of unix jobs and how long they look to run (the outcome `class`). The outcome is not that balanced, with the classes having almost 10 times fewer observations. One way to deal with an imbalance like this is to over-sample the minority observations to lessen the imbalance.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://rdrr.io/r/utils/data.html'>data</a></span><span class='o'>(</span><span class='nv'>hpc_data</span><span class='o'>)</span>

<span class='nv'>hpc_data</span> <span class='o'><a href='https://textrecipes.tidymodels.org/reference/pipe.html'>%&gt;%</a></span> <span class='nf'><a href='https://dplyr.tidyverse.org/reference/count.html'>count</a></span><span class='o'>(</span><span class='nv'>class</span><span class='o'>)</span>
<span class='c'>#&gt; <span style='color: #555555;'># A tibble: 4 × 2</span></span>
<span class='c'>#&gt;   class     n</span>
<span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;fct&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;int&gt;</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>1</span> VF     <span style='text-decoration: underline;'>2</span>211</span>
<span class='c'>#&gt; <span style='color: #555555;'>2</span> F      <span style='text-decoration: underline;'>1</span>347</span>
<span class='c'>#&gt; <span style='color: #555555;'>3</span> M       514</span>
<span class='c'>#&gt; <span style='color: #555555;'>4</span> L       259</span></code></pre>

</div>

Using [`step_smotenc()`](https://themis.tidymodels.org/reference/step_smotenc.html), with the `over_ratio` argument, we can make sure that all classes are over-sampled to have no less than 0.5 of the observations of the largest class.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>up_rec</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://recipes.tidymodels.org/reference/recipe.html'>recipe</a></span><span class='o'>(</span><span class='nv'>class</span> <span class='o'>~</span> <span class='nv'>.</span>, data <span class='o'>=</span> <span class='nv'>hpc_data</span><span class='o'>)</span> <span class='o'><a href='https://textrecipes.tidymodels.org/reference/pipe.html'>%&gt;%</a></span>
  <span class='nf'><a href='https://themis.tidymodels.org/reference/step_smotenc.html'>step_smotenc</a></span><span class='o'>(</span><span class='nv'>class</span>, over_ratio <span class='o'>=</span> <span class='m'>0.5</span><span class='o'>)</span> <span class='o'><a href='https://textrecipes.tidymodels.org/reference/pipe.html'>%&gt;%</a></span>
  <span class='nf'><a href='https://recipes.tidymodels.org/reference/prep.html'>prep</a></span><span class='o'>(</span><span class='o'>)</span>

<span class='nv'>up_rec</span> <span class='o'><a href='https://textrecipes.tidymodels.org/reference/pipe.html'>%&gt;%</a></span>
  <span class='nf'><a href='https://recipes.tidymodels.org/reference/bake.html'>bake</a></span><span class='o'>(</span>new_data <span class='o'>=</span> <span class='kc'>NULL</span><span class='o'>)</span> <span class='o'><a href='https://textrecipes.tidymodels.org/reference/pipe.html'>%&gt;%</a></span>
  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/count.html'>count</a></span><span class='o'>(</span><span class='nv'>class</span><span class='o'>)</span>
<span class='c'>#&gt; <span style='color: #555555;'># A tibble: 4 × 2</span></span>
<span class='c'>#&gt;   class     n</span>
<span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;fct&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;int&gt;</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>1</span> VF     <span style='text-decoration: underline;'>2</span>211</span>
<span class='c'>#&gt; <span style='color: #555555;'>2</span> F      <span style='text-decoration: underline;'>1</span>347</span>
<span class='c'>#&gt; <span style='color: #555555;'>3</span> M      <span style='text-decoration: underline;'>1</span>105</span>
<span class='c'>#&gt; <span style='color: #555555;'>4</span> L      <span style='text-decoration: underline;'>1</span>105</span></code></pre>

</div>

The method that was implemented in embed now has [standalone functions](https://themis.tidymodels.org/reference/index.html#methods) to apply these algorithms without having to create a recipe.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://themis.tidymodels.org/reference/smotenc.html'>smotenc</a></span><span class='o'>(</span><span class='nv'>hpc_data</span>, <span class='s'>"class"</span>, over_ratio <span class='o'>=</span> <span class='m'>0.5</span><span class='o'>)</span>
<span class='c'>#&gt; <span style='color: #555555;'># A tibble: 5,768 × 8</span></span>
<span class='c'>#&gt;    protocol compounds input_fields iterations num_pending  hour day   class</span>
<span class='c'>#&gt;    <span style='color: #555555; font-style: italic;'>&lt;fct&gt;</span>        <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>        <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>      <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>       <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;fct&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;fct&gt;</span></span>
<span class='c'>#&gt; <span style='color: #555555;'> 1</span> E              997          137         20           0  14   Tue   F    </span>
<span class='c'>#&gt; <span style='color: #555555;'> 2</span> E               97          103         20           0  13.8 Tue   VF   </span>
<span class='c'>#&gt; <span style='color: #555555;'> 3</span> E              101           75         10           0  13.8 Thu   VF   </span>
<span class='c'>#&gt; <span style='color: #555555;'> 4</span> E               93           76         20           0  10.1 Fri   VF   </span>
<span class='c'>#&gt; <span style='color: #555555;'> 5</span> E              100           82         20           0  10.4 Fri   VF   </span>
<span class='c'>#&gt; <span style='color: #555555;'> 6</span> E              100           82         20           0  16.5 Wed   VF   </span>
<span class='c'>#&gt; <span style='color: #555555;'> 7</span> E              105           88         20           0  16.4 Fri   VF   </span>
<span class='c'>#&gt; <span style='color: #555555;'> 8</span> E               98           95         20           0  16.7 Fri   VF   </span>
<span class='c'>#&gt; <span style='color: #555555;'> 9</span> E              101           91         20           0  16.2 Fri   VF   </span>
<span class='c'>#&gt; <span style='color: #555555;'>10</span> E               95           92         20           0  10.8 Wed   VF   </span>
<span class='c'>#&gt; <span style='color: #555555;'># … with 5,758 more rows</span></span></code></pre>

</div>

## textrecipes

The functions [`all_tokenized()`](https://textrecipes.tidymodels.org/reference/all_tokenized.html) and [`all_tokenized_predictors()`](https://textrecipes.tidymodels.org/reference/all_tokenized.html) were added to more easily select tokenized columns in a similar fashion to the existing [`all_numeric()`](https://recipes.tidymodels.org/reference/has_role.html) and [`all_numeric_predictors()`](https://recipes.tidymodels.org/reference/has_role.html) selectors.

Lastly, the main step in textrecipes tends to be [`step_tokenize()`](https://textrecipes.tidymodels.org/reference/step_tokenize.html) as you would need it to generate tokens that are modified that the other steps. Over the years we found that it got overloaded with functionality as more and more support for different types of tokenization was added. The remedy to this problem have been to create specialized steps, so [`step_tokenize()`](https://textrecipes.tidymodels.org/reference/step_tokenize.html) has gotten a couple of cousin steps [`step_tokenize_bpe()`](https://textrecipes.tidymodels.org/reference/step_tokenize_bpe.html), [`step_tokenize_sentencepiece()`](https://textrecipes.tidymodels.org/reference/step_tokenize_sentencepiece.html) and [`step_tokenize_wordpiece()`](https://textrecipes.tidymodels.org/reference/step_tokenize_wordpiece.html) which wraps {tokenizers.bpe}, {sentencepiece} and {wordpiece} respectively.

In addition to being easier to manage code-wise, it also allows for less, more readable code with better tab completion.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://rdrr.io/r/utils/data.html'>data</a></span><span class='o'>(</span><span class='nv'>tate_text</span><span class='o'>)</span>

<span class='c'># Old</span>
<span class='nv'>tate_rec</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://recipes.tidymodels.org/reference/recipe.html'>recipe</a></span><span class='o'>(</span><span class='o'>~</span><span class='nv'>.</span>, data <span class='o'>=</span> <span class='nv'>tate_text</span><span class='o'>)</span> <span class='o'><a href='https://textrecipes.tidymodels.org/reference/pipe.html'>%&gt;%</a></span>
 <span class='nf'><a href='https://textrecipes.tidymodels.org/reference/step_tokenize.html'>step_tokenize</a></span><span class='o'>(</span>
    <span class='nv'>text</span>,
    engine <span class='o'>=</span> <span class='s'>"tokenizers.bpe"</span>,
    training_options <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span>vocab_size <span class='o'>=</span> <span class='m'>1000</span><span class='o'>)</span>
  <span class='o'>)</span>

<span class='c'># New</span>
<span class='nv'>tate_rec</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://recipes.tidymodels.org/reference/recipe.html'>recipe</a></span><span class='o'>(</span><span class='o'>~</span><span class='nv'>.</span>, data <span class='o'>=</span> <span class='nv'>tate_text</span><span class='o'>)</span> <span class='o'><a href='https://textrecipes.tidymodels.org/reference/pipe.html'>%&gt;%</a></span>
  <span class='nf'><a href='https://textrecipes.tidymodels.org/reference/step_tokenize_bpe.html'>step_tokenize_bpe</a></span><span class='o'>(</span><span class='nv'>medium</span>, vocabulary_size <span class='o'>=</span> <span class='m'>1000</span><span class='o'>)</span></code></pre>

</div>

## Acknowledgements

We'd like to extend our thanks to all of the contributors who helped make these releases possible!

-   embed: [@EmilHvitfeldt](https://github.com/EmilHvitfeldt), [@juliasilge](https://github.com/juliasilge), [@naveranoc](https://github.com/naveranoc), [@talegari](https://github.com/talegari), and [@topepo](https://github.com/topepo).

-   themis: [@coforfe](https://github.com/coforfe), [@EmilHvitfeldt](https://github.com/EmilHvitfeldt), [@emilyriederer](https://github.com/emilyriederer), [@jennybc](https://github.com/jennybc), [@OGuggenbuehl](https://github.com/OGuggenbuehl), and [@RobertGregg](https://github.com/RobertGregg).

-   textrecipes: [@dgrtwo](https://github.com/dgrtwo), [@DiabbZegpi](https://github.com/DiabbZegpi), [@EmilHvitfeldt](https://github.com/EmilHvitfeldt), [@jcragy](https://github.com/jcragy), [@jennybc](https://github.com/jennybc), [@joeycouse](https://github.com/joeycouse), [@lionel-](https://github.com/lionel-), [@NLDataScientist](https://github.com/NLDataScientist), [@raj-hubber](https://github.com/raj-hubber), and [@topepo](https://github.com/topepo).

