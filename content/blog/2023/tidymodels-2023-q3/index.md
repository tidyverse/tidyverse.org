---
output: hugodown::hugo_document

slug: tidymodels-2023-q3
title: "Q3 2023 tidymodels digest"
date: 2023-10-05
author: Emil Hvitfeldt
description: >
    The tidymodels team has been busy working on all sorts of new features 
    across the ecosystem.
photo:
  url: https://unsplash.com/photos/PGRwUQQhzMQ
  author: Tai's Captures

# one of: "deep-dive", "learn", "package", "programming", "roundup", or "other"
categories: [roundup] 
tags: [tidymodels, rsample, tidyclust]
rmd_hash: 991cf8aa6df1c1eb

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

Since the beginning of 2021, we have been publishing [quarterly updates](https://www.tidyverse.org/categories/roundup/) here on the tidyverse blog summarizing what's new in the tidymodels ecosystem. The purpose of these regular posts is to share useful new features and any updates you may have missed. You can check out the [`tidymodels` tag](https://www.tidyverse.org/tags/tidymodels/) to find all tidymodels blog posts here, including our roundup posts as well as those that are more focused, like this post from the past couple of months:

-   [New interface to validation splits](https://www.tidyverse.org/blog/2023/08/validation-split-as-3-way-split/)

Since [our last roundup post](https://www.tidyverse.org/blog/2022/12/tidymodels-2022-q4/), there have been CRAN releases of 11 tidymodels packages. Here are links to their NEWS files:

<div class="highlight">

-   butcher [(0.3.3)](https://butcher.tidymodels.org/news/index.html)
-   embed [(1.1.2)](https://embed.tidymodels.org/news/index.html)
-   modeldata [(1.2.0)](https://modeldata.tidymodels.org/news/index.html)
-   parsnip [(1.1.1)](https://parsnip.tidymodels.org/news/index.html)
-   recipes [(1.0.8)](https://recipes.tidymodels.org/news/index.html)
-   rsample [(1.2.0)](https://rsample.tidymodels.org/news/index.html)
-   textrecipes [(1.0.4)](https://textrecipes.tidymodels.org/news/index.html)
-   themis [(1.0.2)](https://themis.tidymodels.org/news/index.html)
-   tidyclust [(0.2.0)](https://tidyclust.tidymodels.org/news/index.html)
-   tidymodels [(1.1.1)](https://tidymodels.tidymodels.org/news/index.html)
-   tune [(1.1.2)](https://tune.tidymodels.org/news/index.html)

</div>

We'll highlight a few especially notable changes below: Updated workshop material, new K-means engines and quality of life improvements in rsample. First, loading the collection of packages:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://tidymodels.tidymodels.org'>tidymodels</a></span><span class='o'>)</span></span>
<span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://github.com/tidymodels/tidyclust'>tidyclust</a></span><span class='o'>)</span></span>
<span></span>
<span><span class='nf'><a href='https://rdrr.io/r/utils/data.html'>data</a></span><span class='o'>(</span><span class='s'>"ames"</span>, package <span class='o'>=</span> <span class='s'>"modeldata"</span><span class='o'>)</span></span></code></pre>

</div>

## Workshops

One of the biggest areas of work for our team this quarter was getting ready for this year's [posit::conf](https://posit.co/conference/). This year, two 1-day workshops were available: "Introduction to tidymodels" and "Advanced tidymodels". All the material can be found on our workshop website [workshops.tidymodels.org](https://workshops.tidymodels.org/), with these workshops being archived as [posit::conf 2023 workshops](https://workshops.tidymodels.org/archive/2023-09-posit-conf/).

Unless otherwise noted (i.e. not an original creation and reused from another source), these educational materials are licensed under Creative Commons Attribution [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/).

## Tidyclust update

The latest release of tidyclust featured a round of bug fixes, documentation improvements and quality-of-life improvements.

This release adds 2 new engines to the [`k_means()`](https://tidyclust.tidymodels.org/reference/k_means.html) model. [klaR](https://tidyclust.tidymodels.org/reference/details_k_means_klaR.html) to run K-Modes models and [clustMixType](https://tidyclust.tidymodels.org/reference/details_k_means_clustMixType.html) to run K-prototypes. K-Modes is the categorical analog to K-means, meaning that it is intended to be used on only categorical data, and K-prototypes is the more general method that works with categorical and numeric data at the same time.

If we were to fit a K-means model to a mixed-type data set such as `ames`, it would work, but under the hood, the model would apply a dummy transformation on the categorical predictors.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>kmeans_spec</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://tidyclust.tidymodels.org/reference/k_means.html'>k_means</a></span><span class='o'>(</span>num_clusters <span class='o'>=</span> <span class='m'>3</span><span class='o'>)</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span></span>
<span>  <span class='nf'><a href='https://parsnip.tidymodels.org/reference/set_engine.html'>set_engine</a></span><span class='o'>(</span><span class='s'>"stats"</span><span class='o'>)</span></span>
<span></span>
<span><span class='nv'>kmeans_fit</span> <span class='o'>&lt;-</span> <span class='nv'>kmeans_spec</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span></span>
<span>  <span class='nf'><a href='https://generics.r-lib.org/reference/fit.html'>fit</a></span><span class='o'>(</span><span class='o'>~</span> <span class='nv'>.</span>, data <span class='o'>=</span> <span class='nv'>ames</span><span class='o'>)</span></span></code></pre>

</div>

When extracting the cluster means, we see that the dummy variables were used when calculating the means, which can make it harder to interpret the output.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>kmeans_fit</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span></span>
<span>  <span class='nf'><a href='https://tidyclust.tidymodels.org/reference/extract_centroids.html'>extract_centroids</a></span><span class='o'>(</span><span class='o'>)</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span></span>
<span>  <span class='nf'>select</span><span class='o'>(</span><span class='m'>101</span><span class='o'>:</span><span class='m'>112</span><span class='o'>)</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span></span>
<span>  <span class='nf'>glimpse</span><span class='o'>(</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; Rows: 3</span></span>
<span><span class='c'>#&gt; Columns: 12</span></span>
<span><span class='c'>#&gt; $ Overall_CondGood           <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> 0.09009009, 0.17594787, 0.01234568</span></span>
<span><span class='c'>#&gt; $ Overall_CondVery_Good      <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> 0.02702703, 0.06694313, 0.01646091</span></span>
<span><span class='c'>#&gt; $ Overall_CondExcellent      <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> 0.01201201, 0.01303318, 0.02880658</span></span>
<span><span class='c'>#&gt; $ Overall_CondVery_Excellent <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> 0, 0, 0</span></span>
<span><span class='c'>#&gt; $ Year_Built                 <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> 1989.645, 1956.471, 1999.572</span></span>
<span><span class='c'>#&gt; $ Year_Remod_Add             <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> 1996.090, 1974.518, 2003.379</span></span>
<span><span class='c'>#&gt; $ Roof_StyleGable            <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> 0.8238238, 0.8234597, 0.4444444</span></span>
<span><span class='c'>#&gt; $ Roof_StyleGambrel          <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> 0.005005005, 0.010071090, 0.000000000</span></span>
<span><span class='c'>#&gt; $ Roof_StyleHip              <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> 0.1531532, 0.1558057, 0.5555556</span></span>
<span><span class='c'>#&gt; $ Roof_StyleMansard          <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> 0.005005005, 0.003554502, 0.000000000</span></span>
<span><span class='c'>#&gt; $ Roof_StyleShed             <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> 0.003003003, 0.001184834, 0.000000000</span></span>
<span><span class='c'>#&gt; $ Roof_MatlCompShg           <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> 0.9759760, 0.9905213, 0.9876543</span></span>
<span></span></code></pre>

</div>

Fitting a K-prototype model is done by setting the engine in [`k_means()`](https://tidyclust.tidymodels.org/reference/k_means.html) to `"clustMixType"`.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>kproto_spec</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://tidyclust.tidymodels.org/reference/k_means.html'>k_means</a></span><span class='o'>(</span>num_clusters <span class='o'>=</span> <span class='m'>3</span><span class='o'>)</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span></span>
<span>  <span class='nf'><a href='https://parsnip.tidymodels.org/reference/set_engine.html'>set_engine</a></span><span class='o'>(</span><span class='s'>"clustMixType"</span><span class='o'>)</span></span>
<span></span>
<span><span class='nv'>kproto_fit</span> <span class='o'>&lt;-</span> <span class='nv'>kproto_spec</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span></span>
<span>  <span class='nf'><a href='https://generics.r-lib.org/reference/fit.html'>fit</a></span><span class='o'>(</span><span class='o'>~</span> <span class='nv'>.</span>, data <span class='o'>=</span> <span class='nv'>ames</span><span class='o'>)</span></span></code></pre>

</div>

The clusters can now be extracted on the original data format as categorical predictors are supported.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>kproto_fit</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span></span>
<span>  <span class='nf'><a href='https://tidyclust.tidymodels.org/reference/extract_centroids.html'>extract_centroids</a></span><span class='o'>(</span><span class='o'>)</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span></span>
<span>  <span class='nf'>select</span><span class='o'>(</span><span class='m'>11</span><span class='o'>:</span><span class='m'>20</span><span class='o'>)</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span></span>
<span>  <span class='nf'>glimpse</span><span class='o'>(</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; Rows: 3</span></span>
<span><span class='c'>#&gt; Columns: 10</span></span>
<span><span class='c'>#&gt; $ Lot_Config     <span style='color: #555555; font-style: italic;'>&lt;fct&gt;</span> Inside, Inside, Inside</span></span>
<span><span class='c'>#&gt; $ Land_Slope     <span style='color: #555555; font-style: italic;'>&lt;fct&gt;</span> Gtl, Gtl, Gtl</span></span>
<span><span class='c'>#&gt; $ Neighborhood   <span style='color: #555555; font-style: italic;'>&lt;fct&gt;</span> College_Creek, North_Ames, Northridge_Heights</span></span>
<span><span class='c'>#&gt; $ Condition_1    <span style='color: #555555; font-style: italic;'>&lt;fct&gt;</span> Norm, Norm, Norm</span></span>
<span><span class='c'>#&gt; $ Condition_2    <span style='color: #555555; font-style: italic;'>&lt;fct&gt;</span> Norm, Norm, Norm</span></span>
<span><span class='c'>#&gt; $ Bldg_Type      <span style='color: #555555; font-style: italic;'>&lt;fct&gt;</span> OneFam, OneFam, OneFam</span></span>
<span><span class='c'>#&gt; $ House_Style    <span style='color: #555555; font-style: italic;'>&lt;fct&gt;</span> Two_Story, One_Story, One_Story</span></span>
<span><span class='c'>#&gt; $ Overall_Cond   <span style='color: #555555; font-style: italic;'>&lt;fct&gt;</span> Average, Average, Average</span></span>
<span><span class='c'>#&gt; $ Year_Built     <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> 1989.977, 1953.793, 1998.765</span></span>
<span><span class='c'>#&gt; $ Year_Remod_Add <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> 1995.934, 1972.973, 2003.035</span></span>
<span></span></code></pre>

</div>

## Stricter rsample functions

Before version 1.2.0 of rsample, misspelled and wrongly used arguments would be swallowed silently by the functions. This could be a big source of confusion as it is easy to slip between the cracks. We have made changes to all rsample functions such that whenever possible they alert the user when something is wrong.

Before 1.2.0 when you, for example, misspelled `strata` as `stata`, everything would go on like normal, with no indication that `stata` was ignored.

``` r
initial_split(ames, prop = 0.75, stata = Neighborhood)
#> <Training/Testing/Total>
#> <2197/733/2930>
```

The same code will now error and point to the problematic arguments.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'>initial_split</span><span class='o'>(</span><span class='nv'>ames</span>, prop <span class='o'>=</span> <span class='m'>0.75</span>, stata <span class='o'>=</span> <span class='nv'>Neighborhood</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #BBBB00; font-weight: bold;'>Error</span><span style='font-weight: bold;'> in `initial_split()`:</span></span></span>
<span><span class='c'>#&gt; <span style='color: #BBBB00;'>!</span> `...` must be empty.</span></span>
<span><span class='c'>#&gt; <span style='color: #BB0000;'>✖</span> Problematic argument:</span></span>
<span><span class='c'>#&gt; <span style='color: #00BBBB;'>•</span> stata = Neighborhood</span></span>
<span></span></code></pre>

</div>

## Acknowledgements

We'd like to thank those in the community that contributed to tidymodels in the last quarter:

<div class="highlight">

-   butcher: [@hfrick](https://github.com/hfrick), and [@juliasilge](https://github.com/juliasilge).
-   embed: [@EmilHvitfeldt](https://github.com/EmilHvitfeldt), and [@wbuchanan](https://github.com/wbuchanan).
-   modeldata: [@topepo](https://github.com/topepo).
-   parsnip: [@EmilHvitfeldt](https://github.com/EmilHvitfeldt), [@gmcmacran](https://github.com/gmcmacran), [@SHo-JANG](https://github.com/SHo-JANG), [@simonpcouch](https://github.com/simonpcouch), [@topepo](https://github.com/topepo), and [@vidarsumo](https://github.com/vidarsumo).
-   recipes: [@abichat](https://github.com/abichat), [@andreranza](https://github.com/andreranza), [@EmilHvitfeldt](https://github.com/EmilHvitfeldt), [@jkennel](https://github.com/jkennel), [@millermc38](https://github.com/millermc38), [@nikosGeography](https://github.com/nikosGeography), [@pgg1309](https://github.com/pgg1309), [@rdavis120](https://github.com/rdavis120), [@Sade154](https://github.com/Sade154), [@topepo](https://github.com/topepo), and [@walrossker](https://github.com/walrossker).
-   rsample: [@godscloset](https://github.com/godscloset), [@hfrick](https://github.com/hfrick), [@MasterLuke84](https://github.com/MasterLuke84), [@mikemahoney218](https://github.com/mikemahoney218), [@PathosEthosLogos](https://github.com/PathosEthosLogos), [@simonpcouch](https://github.com/simonpcouch), and [@topepo](https://github.com/topepo).
-   textrecipes: [@DavisVaughan](https://github.com/DavisVaughan), [@EmilHvitfeldt](https://github.com/EmilHvitfeldt), and [@gaohuachuan](https://github.com/gaohuachuan).
-   themis: [@EmilHvitfeldt](https://github.com/EmilHvitfeldt).
-   tidyclust: [@coforfe](https://github.com/coforfe), [@cphaarmeyer](https://github.com/cphaarmeyer), [@EmilHvitfeldt](https://github.com/EmilHvitfeldt), [@michaelgrund](https://github.com/michaelgrund), [@PathosEthosLogos](https://github.com/PathosEthosLogos), and [@trevorcampbell](https://github.com/trevorcampbell).
-   tidymodels: [@nikosGeography](https://github.com/nikosGeography), and [@topepo](https://github.com/topepo).
-   tune: [@dramanica](https://github.com/dramanica), [@EmilHvitfeldt](https://github.com/EmilHvitfeldt), [@forecastingEDs](https://github.com/forecastingEDs), [@hfrick](https://github.com/hfrick), [@kbodwin](https://github.com/kbodwin), [@KJT-Habitat](https://github.com/KJT-Habitat), [@MasterLuke84](https://github.com/MasterLuke84), [@simonpcouch](https://github.com/simonpcouch), and [@topepo](https://github.com/topepo).

</div>

We're grateful for all of the tidymodels community, from observers to users to contributors. Happy modeling!

