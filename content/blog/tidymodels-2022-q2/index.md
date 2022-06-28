---
output: hugodown::hugo_document

slug: tidymodels-2022-q2
title: "Q2 2022 tidymodels digest"
date: 2022-06-24
author: Emil Hvitfeldt
description: >
    Q2 marks the end of the season of case weights, with TKTK new releases.

photo:
  url: https://unsplash.com/photos/BBR_zigEmyQ
  author:  Samuel Girven

# one of: "deep-dive", "learn", "package", "programming", "roundup", or "other"
categories: [roundup] 
tags: [tidymodels, parsnip, recipes]
rmd_hash: ee78d0bfcc61c9e5

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
* [ ] [`usethis::use_tidy_thanks()`](https://usethis.r-lib.org/reference/use_tidy_thanks.html)
-->

The [tidymodels](https://www.tidymodels.org/) framework is a collection of R packages for modeling and machine learning using tidyverse principles.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://tidymodels.tidymodels.org'>tidymodels</a></span><span class='o'>)</span>
<span class='c'>#&gt; ── <span style='font-weight: bold;'>Attaching packages</span> ────────────────────────────────────── tidymodels 0.2.0 ──</span>
<span class='c'>#&gt; <span style='color: #00BB00;'>✔</span> <span style='color: #0000BB;'>broom       </span> 0.8.0          <span style='color: #00BB00;'>✔</span> <span style='color: #0000BB;'>recipes     </span> 0.2.0.<span style='color: #BB0000;'>9002</span></span>
<span class='c'>#&gt; <span style='color: #00BB00;'>✔</span> <span style='color: #0000BB;'>dials       </span> 1.0.0.<span style='color: #BB0000;'>9000</span>     <span style='color: #00BB00;'>✔</span> <span style='color: #0000BB;'>rsample     </span> 0.1.1.<span style='color: #BB0000;'>9000</span></span>
<span class='c'>#&gt; <span style='color: #00BB00;'>✔</span> <span style='color: #0000BB;'>dplyr       </span> 1.0.9          <span style='color: #00BB00;'>✔</span> <span style='color: #0000BB;'>tibble      </span> 3.1.7     </span>
<span class='c'>#&gt; <span style='color: #00BB00;'>✔</span> <span style='color: #0000BB;'>ggplot2     </span> 3.3.6          <span style='color: #00BB00;'>✔</span> <span style='color: #0000BB;'>tidyr       </span> 1.2.0     </span>
<span class='c'>#&gt; <span style='color: #00BB00;'>✔</span> <span style='color: #0000BB;'>infer       </span> 1.0.2          <span style='color: #00BB00;'>✔</span> <span style='color: #0000BB;'>tune        </span> 0.2.0.<span style='color: #BB0000;'>9002</span></span>
<span class='c'>#&gt; <span style='color: #00BB00;'>✔</span> <span style='color: #0000BB;'>modeldata   </span> 0.1.1          <span style='color: #00BB00;'>✔</span> <span style='color: #0000BB;'>workflows   </span> 0.2.6.<span style='color: #BB0000;'>9001</span></span>
<span class='c'>#&gt; <span style='color: #00BB00;'>✔</span> <span style='color: #0000BB;'>parsnip     </span> 1.0.0.<span style='color: #BB0000;'>9000</span>     <span style='color: #00BB00;'>✔</span> <span style='color: #0000BB;'>workflowsets</span> 0.2.1     </span>
<span class='c'>#&gt; <span style='color: #00BB00;'>✔</span> <span style='color: #0000BB;'>purrr       </span> 0.3.4          <span style='color: #00BB00;'>✔</span> <span style='color: #0000BB;'>yardstick   </span> 1.0.0.<span style='color: #BB0000;'>9000</span></span>
<span class='c'>#&gt; ── <span style='font-weight: bold;'>Conflicts</span> ───────────────────────────────────────── tidymodels_conflicts() ──</span>
<span class='c'>#&gt; <span style='color: #BB0000;'>✖</span> <span style='color: #0000BB;'>purrr</span>::<span style='color: #00BB00;'>discard()</span> masks <span style='color: #0000BB;'>scales</span>::discard()</span>
<span class='c'>#&gt; <span style='color: #BB0000;'>✖</span> <span style='color: #0000BB;'>dplyr</span>::<span style='color: #00BB00;'>filter()</span>  masks <span style='color: #0000BB;'>stats</span>::filter()</span>
<span class='c'>#&gt; <span style='color: #BB0000;'>✖</span> <span style='color: #0000BB;'>dplyr</span>::<span style='color: #00BB00;'>lag()</span>     masks <span style='color: #0000BB;'>stats</span>::lag()</span>
<span class='c'>#&gt; <span style='color: #BB0000;'>✖</span> <span style='color: #0000BB;'>recipes</span>::<span style='color: #00BB00;'>step()</span>  masks <span style='color: #0000BB;'>stats</span>::step()</span>
<span class='c'>#&gt; <span style='color: #0000BB;'>•</span> Learn how to get started at <span style='color: #00BB00;'>https://www.tidymodels.org/start/</span></span></code></pre>

</div>

Since the beginning of last year, we have been publishing [quarterly updates](https://www.tidyverse.org/categories/roundup/) here on the tidyverse blog summarizing what's new in the tidymodels ecosystem. The purpose of these regular posts is to share useful new features and any updates you may have missed. You can check out the [`tidymodels` tag](https://www.tidyverse.org/tags/tidymodels/) to find all tidymodels blog posts here, including our roundup posts as well as those that are more focused, like these from the past month or so:

-   [spatialsample](https://www.tidyverse.org/blog/2022/06/spatialsample-0-2-0/)
-   [recipes and its extension packages](https://www.tidyverse.org/blog/2022/05/recipes-update-05-20222/)

Since [our last roundup post](https://www.tidyverse.org/blog/2022/04/tidymodels-2022-q1/), there have been CRAN releases of 25 tidymodels packages. You can install these updates from CRAN with:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://rdrr.io/r/utils/install.packages.html'>install.packages</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span>
  <span class='s'>"rsample"</span>, <span class='s'>"spatialsample"</span>, <span class='s'>"parsnip"</span>, <span class='s'>"baguette"</span>, <span class='s'>"multilevelmod"</span>, <span class='s'>"discrim"</span>,
  <span class='s'>"plsmod"</span>, <span class='s'>"poissonreg"</span>, <span class='s'>"rules"</span>, <span class='s'>"recipes"</span>, <span class='s'>"embed"</span>, <span class='s'>"themis"</span>, <span class='s'>"textrecipes"</span>,
  <span class='s'>"workflows"</span>, <span class='s'>"workflowsets"</span>, <span class='s'>"tune"</span>, <span class='s'>"yardstick"</span>, <span class='s'>"broom"</span>, <span class='s'>"dials"</span>, <span class='s'>"butcher"</span>,
  <span class='s'>"hardhat"</span>, <span class='s'>"infer"</span>, <span class='s'>"stacks"</span>, <span class='s'>"tidyposterior"</span>, <span class='s'>"tidypredict"</span>
<span class='o'>)</span><span class='o'>)</span></code></pre>

</div>

-   [baguette](https://baguette.tidymodels.org/news/index.html#baguette-100)
-   [broom](https://broom.tidymodels.org/news/index.html#broom-080)
-   [butcher](https://butcher.tidymodels.org/news/index.html#butcher-020)
-   [dials](https://dials.tidymodels.org/news/index.html#dials-100)
-   [discrim](https://discrim.tidymodels.org/news/index.html#discrim-100)
-   [embed](TODO)
-   [hardhat](https://hardhat.tidymodels.org/news/index.html#hardhat-110)
-   [infer](https://infer.tidymodels.org/news/index.html#infer-v102)
-   [modeldata](TODO)
-   [multilevelmod](https://multilevelmod.tidymodels.org/news/index.html#multilevelmod-100)
-   [parsnip](https://parsnip.tidymodels.org/news/index.html#parsnip-100)
-   [plsmod](TODO)
-   [poissonreg](https://poissonreg.tidymodels.org/news/index.html#poissonreg-100)
-   [recipes](TODO)
-   [rsample](https://rsample.tidymodels.org/news/index.html#rsample-100)
-   [rules](https://rules.tidymodels.org/news/index.html#rules-100)
-   [spatialsample](https://spatialsample.tidymodels.org/news/index.html#spatialsample-020)
-   [stacks](https://stacks.tidymodels.org/news/index.html#stacks-023)
-   [textrecipes](TODO)
-   [themis](TODO)
-   [tidyposterior](https://tidyposterior.tidymodels.org/news/index.html#tidyposterior-100)
-   [tidypredict](https://tidypredict.tidymodels.org/news/index.html#tidypredict-049)
-   [tune](TODO)
-   [workflows](TODO)
-   [workflowsets](TODO)
-   [yardstick](https://yardstick.tidymodels.org/news/index.html#yardstick-100)

The `NEWS` files are linked here for each package; you'll notice that there are a lot! We know it may be bothersome to keep up with all these changes, so we want to draw your attention to our recent blog posts above and also highlight a few more useful updates in today's blog post.

## case weights

Much of the work we have been doing so far this year has been related to case weights. For a more detailed account of the deliberations see this earlier post about the [use of case weights with tidymodels](https://www.tidyverse.org/blog/2022/05/case-weights/). We are confident that we have created a good foundation with our implementation and we are signaling the support for case weights by bumping the version of affected packages and extension packages to 1.0.0.

A full worked example can be found in the [prevous blog post](tidyverse.org/blog/2022/05/case-weights/#tidymodels-syntax) and on [the tidymodels site](TODO).

## non-standard roles in recipes

Recipes use the idea of roles to determine how and when the different variables are used. The main roles you have seen are "outcome", "predictor", and now "case_weights". You are also able to change the roles of these variables using `add_role()` and `update_role()`.

With a recent addition of case weights adding another type of standard role, we have made recipes more robust by having it check that all columns in the `data` supplied to `recipe()` are also present in the `new_data` supplied to `bake()` with the exception is made for columns with roles of either `"outcome"` or `"case_weights"`, which are typically not required at `bake()` time.

This change for stricter checking of roles will mean that you might need to make some small changes to your code if you are using non-standard roles. The function [update_role_requirements()](https://recipes.tidymodels.org/reference/update_role_requirements.html) can be used to specify whether a role will is required at bake time.

We have shown before how you can use `update_role()` to remove variables as predictors by setting them as id variables. Suppose we were to do some preprocessing on the `tate_text` data set

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://rdrr.io/r/utils/data.html'>data</a></span><span class='o'>(</span><span class='s'>"tate_text"</span><span class='o'>)</span>
<span class='nf'>glimpse</span><span class='o'>(</span><span class='nv'>tate_text</span><span class='o'>)</span>
<span class='c'>#&gt; Rows: 4,284</span>
<span class='c'>#&gt; Columns: 5</span>
<span class='c'>#&gt; $ id     <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> 21926, 20472, 20474, 20473, 20513, 21389, 121187, 19455, 20938,…</span>
<span class='c'>#&gt; $ artist <span style='color: #555555; font-style: italic;'>&lt;fct&gt;</span> "Absalon", "Auerbach, Frank", "Auerbach, Frank", "Auerbach, Fra…</span>
<span class='c'>#&gt; $ title  <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span> "Proposals for a Habitat", "Michael", "Geoffrey", "Jake", "To t…</span>
<span class='c'>#&gt; $ medium <span style='color: #555555; font-style: italic;'>&lt;fct&gt;</span> "Video, monitor or projection, colour and sound (stereo)", "Etc…</span>
<span class='c'>#&gt; $ year   <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> 1990, 1990, 1990, 1990, 1990, 1990, 1990, 1990, 1990, 1990, 199…</span></code></pre>

</div>

This data set includes an id variable that shouldn't have any predictive power and a title variable that we want to ignore for now. Previously we would have created the following recipe to process this data, using `update_role(id, title, new_role = "id")` to let the recipe know that we don't want it to treat id and title as predictors

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>tate_rec</span> <span class='o'>&lt;-</span> <span class='nf'>recipe</span><span class='o'>(</span><span class='nv'>year</span> <span class='o'>~</span> <span class='nv'>.</span>, data <span class='o'>=</span> <span class='nv'>tate_text</span><span class='o'>)</span> <span class='o'>%&gt;%</span>
  <span class='nf'>update_role</span><span class='o'>(</span><span class='nv'>id</span>, <span class='nv'>title</span>, new_role <span class='o'>=</span> <span class='s'>"id"</span><span class='o'>)</span> <span class='o'>%&gt;%</span> 
  <span class='nf'>step_dummy_extract</span><span class='o'>(</span><span class='nv'>artist</span>, <span class='nv'>medium</span>, sep <span class='o'>=</span> <span class='s'>", "</span><span class='o'>)</span>

<span class='nv'>tate_rec_prepped</span> <span class='o'>&lt;-</span> <span class='nf'>prep</span><span class='o'>(</span><span class='nv'>tate_rec</span><span class='o'>)</span></code></pre>

</div>

And this works fine until we try to apply the recipe to new data with our predictors

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>new_painting</span> <span class='o'>&lt;-</span> <span class='nf'>tibble</span><span class='o'>(</span>
  artist <span class='o'>=</span> <span class='s'>"Hamilton, Richard"</span>,
  medium <span class='o'>=</span> <span class='s'>"Letterpress on paper"</span> 
<span class='o'>)</span>

<span class='nf'>bake</span><span class='o'>(</span><span class='nv'>tate_rec_prepped</span>, <span class='nv'>new_painting</span><span class='o'>)</span>
<span class='c'>#&gt; <span style='color: #BBBB00; font-weight: bold;'>Error</span><span style='font-weight: bold;'> in `bake()`:</span></span>
<span class='c'>#&gt; <span style='color: #BBBB00;'>!</span> The following required columns are missing from `new_data`: "id", "title".</span>
<span class='c'>#&gt; <span style='color: #0000BB;'>ℹ</span> These columns have one of the following roles, which are required at `bake()` time: "id".</span>
<span class='c'>#&gt; <span style='color: #0000BB;'>ℹ</span> If these roles are not required at `bake()` time, use `update_role_requirements(role = "your_role", bake = FALSE)`.</span></code></pre>

</div>

This now complains because the recipe is expecting the `id` and `title` to be in the data set passed to `bake()`. This issue can be fixed by using `update_role_requirements()` as shown below to tell the recipe that variables of role `"id"` are not required when baking.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>tate_rec</span> <span class='o'>&lt;-</span> <span class='nf'>recipe</span><span class='o'>(</span><span class='nv'>year</span> <span class='o'>~</span> <span class='nv'>.</span>, data <span class='o'>=</span> <span class='nv'>tate_text</span><span class='o'>)</span> <span class='o'>%&gt;%</span>
  <span class='nf'>update_role</span><span class='o'>(</span><span class='nv'>id</span>, <span class='nv'>title</span>, new_role <span class='o'>=</span> <span class='s'>"id"</span><span class='o'>)</span> <span class='o'>%&gt;%</span>
  <span class='nf'>update_role_requirements</span><span class='o'>(</span>role <span class='o'>=</span> <span class='s'>"id"</span>, bake <span class='o'>=</span> <span class='kc'>FALSE</span><span class='o'>)</span> <span class='o'>%&gt;%</span>
  <span class='nf'>step_dummy_extract</span><span class='o'>(</span><span class='nv'>artist</span>, <span class='nv'>medium</span>, sep <span class='o'>=</span> <span class='s'>", "</span><span class='o'>)</span>

<span class='nv'>tate_rec_prepped</span> <span class='o'>&lt;-</span> <span class='nf'>prep</span><span class='o'>(</span><span class='nv'>tate_rec</span><span class='o'>)</span>

<span class='nf'>bake</span><span class='o'>(</span><span class='nv'>tate_rec_prepped</span>, <span class='nv'>new_painting</span><span class='o'>)</span>
<span class='c'>#&gt; <span style='color: #555555;'># A tibble: 1 × 2,675</span></span>
<span class='c'>#&gt;   artist_Abigail artist_Abraham artist_Absalon artist_Abts artist_Achill</span>
<span class='c'>#&gt;            <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>          <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>          <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>       <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>         <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>1</span>              0              0              0           0             0</span>
<span class='c'>#&gt; <span style='color: #555555;'># … with 2,670 more variables: artist_Ackroyd &lt;dbl&gt;, artist_Adam &lt;dbl&gt;,</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>#   artist_Agnes &lt;dbl&gt;, artist_Ahtila &lt;dbl&gt;, artist_Ai &lt;dbl&gt;,</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>#   artist_Akram &lt;dbl&gt;, artist_Aksel &lt;dbl&gt;, artist_Al &lt;dbl&gt;,</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>#   artist_Al.Ani &lt;dbl&gt;, artist_Alan &lt;dbl&gt;, artist_Albert &lt;dbl&gt;,</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>#   artist_Aleksandra &lt;dbl&gt;, artist_Alex &lt;dbl&gt;, artist_Alexander &lt;dbl&gt;,</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>#   artist_Alexandre.da &lt;dbl&gt;, artist_Alfredo &lt;dbl&gt;, artist_Alice &lt;dbl&gt;,</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>#   artist_Alimpiev &lt;dbl&gt;, artist_Alison &lt;dbl&gt;, artist_Allen &lt;dbl&gt;, …</span></span></code></pre>

</div>

## Acknowledgements

-   applicable: [@EmilHvitfeldt](https://github.com/EmilHvitfeldt), [@marlycormar](https://github.com/marlycormar), and [@topepo](https://github.com/topepo).

-   baguette: [@juliasilge](https://github.com/juliasilge), and [@topepo](https://github.com/topepo).

-   bonsai: [@pinogl](https://github.com/pinogl), [@simonpcouch](https://github.com/simonpcouch), and [@topepo](https://github.com/topepo).

-   broom: [@behrman](https://github.com/behrman), [@corybrunson](https://github.com/corybrunson), [@fschaffner](https://github.com/fschaffner), [@gjones1219](https://github.com/gjones1219), [@grantmcdermott](https://github.com/grantmcdermott), [@ray-p144](https://github.com/ray-p144), [@RichardJActon](https://github.com/RichardJActon), [@russHyde](https://github.com/russHyde), [@simonpcouch](https://github.com/simonpcouch), [@tappek](https://github.com/tappek), [@Timelessprod](https://github.com/Timelessprod), and [@vincentarelbundock](https://github.com/vincentarelbundock).

-   butcher: [@davidkane9](https://github.com/davidkane9), [@DavisVaughan](https://github.com/DavisVaughan), [@juliasilge](https://github.com/juliasilge), and [@simonpcouch](https://github.com/simonpcouch).

-   censored: [@bcjaeger](https://github.com/bcjaeger), [@brunocarlin](https://github.com/brunocarlin), [@erikvona](https://github.com/erikvona), [@gvelasq](https://github.com/gvelasq), [@hfrick](https://github.com/hfrick), [@mikemahoney218](https://github.com/mikemahoney218), and [@topepo](https://github.com/topepo).

-   corrr: [@astamm](https://github.com/astamm), [@EmilHvitfeldt](https://github.com/EmilHvitfeldt), [@john-s-f](https://github.com/john-s-f), [@juliasilge](https://github.com/juliasilge), and [@thisisdaryn](https://github.com/thisisdaryn).

-   dials: [@DavisVaughan](https://github.com/DavisVaughan), [@EmilHvitfeldt](https://github.com/EmilHvitfeldt), [@franzbischoff](https://github.com/franzbischoff), [@hadley](https://github.com/hadley), [@hfrick](https://github.com/hfrick), [@mikemahoney218](https://github.com/mikemahoney218), [@py9mrg](https://github.com/py9mrg), [@simonpcouch](https://github.com/simonpcouch), and [@topepo](https://github.com/topepo).

-   discrim: [@EmilHvitfeldt](https://github.com/EmilHvitfeldt), [@hfrick](https://github.com/hfrick), [@jmarshallnz](https://github.com/jmarshallnz), [@juliasilge](https://github.com/juliasilge), and [@topepo](https://github.com/topepo).

-   embed: [@EmilHvitfeldt](https://github.com/EmilHvitfeldt), [@exsell-jc](https://github.com/exsell-jc), [@juliasilge](https://github.com/juliasilge), [@mkhansa](https://github.com/mkhansa), [@talegari](https://github.com/talegari), and [@topepo](https://github.com/topepo).

-   hardhat: [@DavisVaughan](https://github.com/DavisVaughan), [@jonthegeek](https://github.com/jonthegeek), [@mdancho84](https://github.com/mdancho84), and [@topepo](https://github.com/topepo).

-   infer: [@gdbassett](https://github.com/gdbassett), [@liubao210](https://github.com/liubao210), [@nipnipj](https://github.com/nipnipj), and [@simonpcouch](https://github.com/simonpcouch).

-   modeldata: [@EmilHvitfeldt](https://github.com/EmilHvitfeldt), [@jbkunst](https://github.com/jbkunst), [@juliasilge](https://github.com/juliasilge), [@simonpcouch](https://github.com/simonpcouch), and [@topepo](https://github.com/topepo).

-   multilevelmod: [@a-difabio](https://github.com/a-difabio), [@EmilHvitfeldt](https://github.com/EmilHvitfeldt), [@hfrick](https://github.com/hfrick), [@sitendug](https://github.com/sitendug), [@topepo](https://github.com/topepo), and [@YiweiZhu](https://github.com/YiweiZhu).

-   parsnip: [@brunocarlin](https://github.com/brunocarlin), [@cb12991](https://github.com/cb12991), [@DavisVaughan](https://github.com/DavisVaughan), [@deschen1](https://github.com/deschen1), [@edgararuiz](https://github.com/edgararuiz), [@EmilHvitfeldt](https://github.com/EmilHvitfeldt), [@emmamendelsohn](https://github.com/emmamendelsohn), [@exsell-jc](https://github.com/exsell-jc), [@fdeoliveirag](https://github.com/fdeoliveirag), [@gundalav](https://github.com/gundalav), [@hfrick](https://github.com/hfrick), [@jmarshallnz](https://github.com/jmarshallnz), [@juliasilge](https://github.com/juliasilge), [@Npaffen](https://github.com/Npaffen), [@oj713](https://github.com/oj713), [@pmags](https://github.com/pmags), [@PursuitOfDataScience](https://github.com/PursuitOfDataScience), [@qiushiyan](https://github.com/qiushiyan), [@salim-b](https://github.com/salim-b), [@shosaco](https://github.com/shosaco), [@simonpcouch](https://github.com/simonpcouch), [@tolliam](https://github.com/tolliam), and [@topepo](https://github.com/topepo).

-   plsmod: [@juliasilge](https://github.com/juliasilge).

-   poissonreg: [@hfrick](https://github.com/hfrick), [@juliasilge](https://github.com/juliasilge), and [@topepo](https://github.com/topepo).

-   recipes: [@abichat](https://github.com/abichat), [@albertiniufu](https://github.com/albertiniufu), [@AndrewKostandy](https://github.com/AndrewKostandy), [@aridf](https://github.com/aridf), [@brunocarlin](https://github.com/brunocarlin), [@cb12991](https://github.com/cb12991), [@conorjudge](https://github.com/conorjudge), [@DavisVaughan](https://github.com/DavisVaughan), [@duccioa](https://github.com/duccioa), [@edgararuiz](https://github.com/edgararuiz), [@EmilHvitfeldt](https://github.com/EmilHvitfeldt), [@exsell-jc](https://github.com/exsell-jc), [@hsbadr](https://github.com/hsbadr), [@jkennel](https://github.com/jkennel), [@joeycouse](https://github.com/joeycouse), [@juliasilge](https://github.com/juliasilge), [@kendonB](https://github.com/kendonB), [@krzjoa](https://github.com/krzjoa), [@madprogramer](https://github.com/madprogramer), [@mdporter](https://github.com/mdporter), [@mdsteiner](https://github.com/mdsteiner), [@nipnipj](https://github.com/nipnipj), [@PursuitOfDataScience](https://github.com/PursuitOfDataScience), [@r2evans](https://github.com/r2evans), [@simonpcouch](https://github.com/simonpcouch), [@szymonkusak](https://github.com/szymonkusak), [@themichjam](https://github.com/themichjam), [@tmastny](https://github.com/tmastny), [@tomazweiss](https://github.com/tomazweiss), [@topepo](https://github.com/topepo), [@TylerGrantSmith](https://github.com/TylerGrantSmith), and [@zenggyu](https://github.com/zenggyu).

-   rsample: [@DavisVaughan](https://github.com/DavisVaughan), [@dfalbel](https://github.com/dfalbel), [@juliasilge](https://github.com/juliasilge), [@mattwarkentin](https://github.com/mattwarkentin), [@mdporter](https://github.com/mdporter), [@mikemahoney218](https://github.com/mikemahoney218), [@pgoodling-usgs](https://github.com/pgoodling-usgs), [@sametsoekel](https://github.com/sametsoekel), [@topepo](https://github.com/topepo), and [@wkdavis](https://github.com/wkdavis).

-   rules: [@DesmondChoy](https://github.com/DesmondChoy), [@EmilHvitfeldt](https://github.com/EmilHvitfeldt), [@juliasilge](https://github.com/juliasilge), [@simonpcouch](https://github.com/simonpcouch), [@topepo](https://github.com/topepo), and [@wdkeyzer](https://github.com/wdkeyzer).

-   shinymodels: [@simonpcouch](https://github.com/simonpcouch).

-   spatialsample: [@juliasilge](https://github.com/juliasilge), [@mikemahoney218](https://github.com/mikemahoney218), [@MxNl](https://github.com/MxNl), [@nipnipj](https://github.com/nipnipj), and [@PathosEthosLogos](https://github.com/PathosEthosLogos).

-   stacks: [@amcmahon17](https://github.com/amcmahon17), [@domijan](https://github.com/domijan), [@Jeffrothschild](https://github.com/Jeffrothschild), [@mvt-oviedo](https://github.com/mvt-oviedo), [@py9mrg](https://github.com/py9mrg), [@rcannood](https://github.com/rcannood), [@Saarialho](https://github.com/Saarialho), [@simonpcouch](https://github.com/simonpcouch), and [@williamshell](https://github.com/williamshell).

-   textrecipes: [@EmilHvitfeldt](https://github.com/EmilHvitfeldt), [@NLDataScientist](https://github.com/NLDataScientist), [@PursuitOfDataScience](https://github.com/PursuitOfDataScience), and [@raj-hubber](https://github.com/raj-hubber).

-   themis: [@coforfe](https://github.com/coforfe), and [@EmilHvitfeldt](https://github.com/EmilHvitfeldt).

-   tidymodels: [@DavisVaughan](https://github.com/DavisVaughan), [@EngrStudent](https://github.com/EngrStudent), [@exsell-jc](https://github.com/exsell-jc), [@juliasilge](https://github.com/juliasilge), [@kcarnold](https://github.com/kcarnold), [@scottlyden](https://github.com/scottlyden), and [@topepo](https://github.com/topepo).

-   tidyposterior: [@jmgirard](https://github.com/jmgirard), [@juliasilge](https://github.com/juliasilge), [@mikemahoney218](https://github.com/mikemahoney218), and [@topepo](https://github.com/topepo).

-   tidypredict: [@juliasilge](https://github.com/juliasilge), [@mgirlich](https://github.com/mgirlich), [@simonpcouch](https://github.com/simonpcouch), and [@topepo](https://github.com/topepo).

-   tune: [@DavisVaughan](https://github.com/DavisVaughan), [@dax44](https://github.com/dax44), [@EmilHvitfeldt](https://github.com/EmilHvitfeldt), [@felxcon](https://github.com/felxcon), [@franzbischoff](https://github.com/franzbischoff), [@hfrick](https://github.com/hfrick), [@joeycouse](https://github.com/joeycouse), [@juliasilge](https://github.com/juliasilge), [@mattwarkentin](https://github.com/mattwarkentin), [@mdancho84](https://github.com/mdancho84), [@munoztd0](https://github.com/munoztd0), [@nikhilpathiyil](https://github.com/nikhilpathiyil), [@pgoodling-usgs](https://github.com/pgoodling-usgs), [@py9mrg](https://github.com/py9mrg), [@qiushiyan](https://github.com/qiushiyan), [@siegfried](https://github.com/siegfried), [@simonpcouch](https://github.com/simonpcouch), [@thegargiulian](https://github.com/thegargiulian), [@topepo](https://github.com/topepo), [@williamshell](https://github.com/williamshell), and [@wtbxsjy](https://github.com/wtbxsjy).

-   usemodels: [@aloes2512](https://github.com/aloes2512), [@amcmahon17](https://github.com/amcmahon17), [@juliasilge](https://github.com/juliasilge), and [@larry77](https://github.com/larry77).

-   workflows: [@CarstenLange](https://github.com/CarstenLange), [@dajmcdon](https://github.com/dajmcdon), [@DavisVaughan](https://github.com/DavisVaughan), [@EmilHvitfeldt](https://github.com/EmilHvitfeldt), [@hfrick](https://github.com/hfrick), [@juliasilge](https://github.com/juliasilge), [@nipnipj](https://github.com/nipnipj), [@simonpcouch](https://github.com/simonpcouch), [@themichjam](https://github.com/themichjam), and [@TylerGrantSmith](https://github.com/TylerGrantSmith).

-   workflowsets: [@a-difabio](https://github.com/a-difabio), [@DavisVaughan](https://github.com/DavisVaughan), [@hfrick](https://github.com/hfrick), [@juliasilge](https://github.com/juliasilge), [@simonpcouch](https://github.com/simonpcouch), [@topepo](https://github.com/topepo), [@wdefreitas](https://github.com/wdefreitas), and [@yonicd](https://github.com/yonicd).

-   yardstick: [@1lliter8](https://github.com/1lliter8), [@amcmahon17](https://github.com/amcmahon17), [@brshallo](https://github.com/brshallo), [@DavisVaughan](https://github.com/DavisVaughan), and [@gsverhoeven](https://github.com/gsverhoeven).

