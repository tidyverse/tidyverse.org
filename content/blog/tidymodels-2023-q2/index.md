---
output: hugodown::hugo_document

slug: tidymodels-2023-q2
title: "Q2 2023 tidymodels digest"
date: 2023-07-17
author: Hannah Frick
description: >
    The tidymodels team has been busy working on all sorts of new features 
    across the ecosystem.

photo:
  url: https://unsplash.com/photos/PuLsDCBbyBM
  author: United States Geological Survey

# one of: "deep-dive", "learn", "package", "programming", "roundup", or "other"
categories: [roundup] 
tags: [tidymodels]
rmd_hash: efa4599db68a3001

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

Since the beginning of 2021, we have been publishing [quarterly updates](https://www.tidyverse.org/categories/roundup/) here on the tidyverse blog summarizing what's new in the tidymodels ecosystem. The purpose of these regular posts is to share useful new features and any updates you may have missed. You can check out the [`tidymodels` tag](https://www.tidyverse.org/tags/tidymodels/) to find all tidymodels blog posts here, including our roundup posts as well as those that are more focused, like the [post](https://www.tidyverse.org/blog/2023/05/desirability2/) on the release of the new desirability2 package.

Since [our last roundup post](https://www.tidyverse.org/blog/2023/04/tidymodels-2023-q1/), there have been CRAN releases of 7 tidymodels packages. Here are links to their NEWS files:

<div class="highlight">

-   agua [(0.1.3)](https://agua.tidymodels.org/news/index.html)
-   broom [(1.0.5)](https://broom.tidymodels.org/news/index.html)
-   desirability2 [(0.0.1)](https://desirability2.tidymodels.org/news/index.html)
-   embed [(1.1.1)](https://embed.tidymodels.org/news/index.html)
-   probably [(1.0.2)](https://probably.tidymodels.org/news/index.html)
-   spatialsample [(0.4.0)](https://spatialsample.tidymodels.org/news/index.html)
-   tidymodels [(1.1.0)](https://tidymodels.tidymodels.org/news/index.html)

</div>

We'll highlight a few especially notable changes below: a new package with data for modeling, nearest neighbor distance matching cross-validation for spatial data, and a website refresh.

First, loading the collection of packages:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://tidymodels.tidymodels.org'>tidymodels</a></span><span class='o'>)</span></span></code></pre>

</div>

## modeldatatoo

Many of the datasets used in tidymodels examples are available in the modeldata package. The new modeldatatoo package now extends the collection by several bigger datasets. To allow for the bigger size, the package does not contain those datasets directly but rather provides functions to access them, prefixed with `data_`. For example:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://github.com/tidymodels/modeldatatoo'>modeldatatoo</a></span><span class='o'>)</span></span>
<span></span>
<span><span class='nf'><a href='https://tidymodels.github.io/modeldatatoo/reference/data_animals.html'>data_animals</a></span><span class='o'>(</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 610 × 48</span></span></span>
<span><span class='c'>#&gt;    text    colour lifespan weight kingdom class phylum diet  conservation_status</span></span>
<span><span class='c'>#&gt;    <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>   <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>  <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>    <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>  <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>   <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>  <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>              </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 1</span> <span style='color: #555555;'>"</span>Aardv… Brown… 23 years 60kg … Animal… Mamm… Chord… Omni… Least Concern      </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 2</span> <span style='color: #555555;'>"</span>Abyss… Fawn,… <span style='color: #BB0000;'>NA</span>       <span style='color: #BB0000;'>NA</span>     <span style='color: #BB0000;'>NA</span>      <span style='color: #BB0000;'>NA</span>    <span style='color: #BB0000;'>NA</span>     <span style='color: #BB0000;'>NA</span>    <span style='color: #BB0000;'>NA</span>                 </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 3</span> <span style='color: #555555;'>"</span>Adeli… Black… 10 - 20… 3kg -… Animal… Aves  Chord… Carn… Least Concern      </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 4</span> <span style='color: #555555;'>"</span>Affen… Black… <span style='color: #BB0000;'>NA</span>       <span style='color: #BB0000;'>NA</span>     <span style='color: #BB0000;'>NA</span>      <span style='color: #BB0000;'>NA</span>    <span style='color: #BB0000;'>NA</span>     <span style='color: #BB0000;'>NA</span>    <span style='color: #BB0000;'>NA</span>                 </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 5</span> <span style='color: #555555;'>"</span>Afgha… Black… <span style='color: #BB0000;'>NA</span>       <span style='color: #BB0000;'>NA</span>     <span style='color: #BB0000;'>NA</span>      <span style='color: #BB0000;'>NA</span>    <span style='color: #BB0000;'>NA</span>     <span style='color: #BB0000;'>NA</span>    <span style='color: #BB0000;'>NA</span>                 </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 6</span> <span style='color: #555555;'>"</span>Afric… Grey,… 60 - 70… 3,600… Animal… Mamm… Chord… Herb… Threatened         </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 7</span> <span style='color: #555555;'>"</span>Afric… Black… 15 - 20… 1.4kg… Animal… Mamm… Chord… Omni… Least Concern      </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 8</span> <span style='color: #555555;'>"</span>Afric… Brown… 8 - 15 … 25g -… Animal… Amph… Chord… Carn… Least Concern      </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 9</span> <span style='color: #555555;'>"</span>Afric… Grey,… 60 - 70… 900kg… Animal… Mamm… Chord… Herb… Endangered         </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>10</span> <span style='color: #555555;'>"</span>Afric… Black… 15 - 20… 1.4kg… Animal… Mamm… Chord… Omni… Least Concern      </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># ℹ 600 more rows</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># ℹ 39 more variables: order &lt;chr&gt;, scientific_name &lt;chr&gt;, skin_type &lt;chr&gt;,</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>#   habitat &lt;chr&gt;, predators &lt;chr&gt;, family &lt;chr&gt;, lifestyle &lt;chr&gt;,</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>#   average_litter_size &lt;chr&gt;, genus &lt;chr&gt;, top_speed &lt;chr&gt;,</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>#   favourite_food &lt;chr&gt;, main_prey &lt;chr&gt;, type &lt;chr&gt;, common_name &lt;chr&gt;,</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>#   group &lt;chr&gt;, size &lt;chr&gt;, distinctive_features &lt;chr&gt;, size_l &lt;chr&gt;,</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>#   origin &lt;chr&gt;, special_features &lt;chr&gt;, location &lt;chr&gt;, …</span></span></span>
<span></span></code></pre>

</div>

The new datasets are:

-   [`data_animals()`](https://tidymodels.github.io/modeldatatoo/reference/data_animals.html) contains a long-form description of the animal (in the `text` column) as well as quite a bit of missing data and malformed fields.
-   [`data_chimiometrie_2019()`](https://tidymodels.github.io/modeldatatoo/reference/data_chimiometrie_2019.html) contains spectra measured at 550 (unknown) wavelengths, published as the challenge at the Chimiometrie 2019 conference.
-   [`data_elevators()`](https://tidymodels.github.io/modeldatatoo/reference/data_elevators.html) contains information on a subset of the elevators in New York City.

Because those datasets are stored online, accessing them requires an active internet connection. We plan on using those datasets mostly for workshops and websites. The datasets in the modeldata package are part of the package directly, so they can be used everywhere (regardless of an active internet connection). We typically use them for package documentation.

## spatialsample

spatialsample is a package for spatial resampling, extending the rsample framework to help create spatial extrapolation between your analysis and assessment data sets.

The latest release of spatialsample includes nearest neighbor distance matching (NNDM) cross-validation via [`spatial_nndm_cv()`](https://spatialsample.tidymodels.org/reference/spatial_nndm_cv.html). NNDM is a variant of leave-one-out cross-validation which assigns each observation to a single assessment fold, and then attempts to remove data from each analysis fold until the nearest neighbor distance distribution between assessment and analysis folds matches the nearest neighbor distance distribution between training data and the locations a model will be used to predict. [Proposed by Milà et al. (2022)](https://doi.org/10.1111/2041-210X.13851), this method aims to provide accurate estimates of how well models will perform in the locations they will actually be predicting. This method was originally implemented in the CAST package and can now be used with spatialsample as well.

Let's use the Ames housing data and turn it from a regular tibble into a `sf` object for spatial data.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://github.com/tidymodels/spatialsample'>spatialsample</a></span><span class='o'>)</span></span>
<span><span class='nf'><a href='https://rdrr.io/r/utils/data.html'>data</a></span><span class='o'>(</span><span class='nv'>ames</span>, package <span class='o'>=</span> <span class='s'>"modeldata"</span><span class='o'>)</span></span>
<span></span>
<span><span class='nv'>ames_sf</span> <span class='o'>&lt;-</span> <span class='nf'>sf</span><span class='nf'>::</span><span class='nf'><a href='https://r-spatial.github.io/sf/reference/st_as_sf.html'>st_as_sf</a></span><span class='o'>(</span><span class='nv'>ames</span>, coords <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"Longitude"</span>, <span class='s'>"Latitude"</span><span class='o'>)</span>, crs <span class='o'>=</span> <span class='m'>4326</span><span class='o'>)</span></span></code></pre>

</div>

Let's assume that we are building a model to predict observations similar to this subset of the data:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>ames_prediction_sites</span> <span class='o'>&lt;-</span> <span class='nv'>ames_sf</span><span class='o'>[</span><span class='m'>2001</span><span class='o'>:</span><span class='m'>2100</span>, <span class='o'>]</span></span></code></pre>

</div>

Let's create NNDM cross-validation folds from a reduced training set as an example, just to keep things light.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>ames_folds</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://spatialsample.tidymodels.org/reference/spatial_nndm_cv.html'>spatial_nndm_cv</a></span><span class='o'>(</span><span class='nv'>ames_sf</span><span class='o'>[</span><span class='m'>1</span><span class='o'>:</span><span class='m'>100</span>, <span class='o'>]</span>, <span class='nv'>ames_prediction_sites</span><span class='o'>)</span></span></code></pre>

</div>

The resulting `rset` contains 100 splits of the data, always keeping 1 of the 100 data points in the assessment set.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>ames_folds</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 100 × 2</span></span></span>
<span><span class='c'>#&gt;    splits         id     </span></span>
<span><span class='c'>#&gt;    <span style='color: #555555; font-style: italic;'>&lt;list&gt;</span>         <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>  </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 1</span> <span style='color: #555555;'>&lt;split [50/1]&gt;</span> Fold001</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 2</span> <span style='color: #555555;'>&lt;split [83/1]&gt;</span> Fold002</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 3</span> <span style='color: #555555;'>&lt;split [50/1]&gt;</span> Fold003</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 4</span> <span style='color: #555555;'>&lt;split [50/1]&gt;</span> Fold004</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 5</span> <span style='color: #555555;'>&lt;split [50/1]&gt;</span> Fold005</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 6</span> <span style='color: #555555;'>&lt;split [50/1]&gt;</span> Fold006</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 7</span> <span style='color: #555555;'>&lt;split [50/1]&gt;</span> Fold007</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 8</span> <span style='color: #555555;'>&lt;split [76/1]&gt;</span> Fold008</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 9</span> <span style='color: #555555;'>&lt;split [86/1]&gt;</span> Fold009</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>10</span> <span style='color: #555555;'>&lt;split [88/1]&gt;</span> Fold010</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># ℹ 90 more rows</span></span></span>
<span></span></code></pre>

</div>

Starting with all other 99 points in the analysis set, points are excluded until the distribution of nearest neighbor distances from the analysis set to the assessment set matches that of nearest neighbor distances from the training set to the prediction sites.

Looking at one of the splits, we can see the single assessment point, the points included in the analysis set, and the points excluded as the buffer.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'>get_rsplit</span><span class='o'>(</span><span class='nv'>ames_folds</span>, <span class='m'>3</span><span class='o'>)</span> <span class='o'>|&gt;</span> </span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/autoplot.html'>autoplot</a></span><span class='o'>(</span><span class='o'>)</span></span>
</code></pre>
<img src="figs/unnamed-chunk-10-1.png" width="700px" style="display: block; margin: auto;" />

</div>

The `ames_fold` object can then be used with functions from the tune package as usual.

## tidymodels.org

The tidymodels website, [tidymodels.org](https://www.tidymodels.org/), has been updated to use [Quarto](https://quarto.org/). Things largely look the same as before but this change simplifies the build system which should make it easier for more people to contribute.

This change to Quarto has also allowed us to improve the search functionality of the website. The tables for finding parsnip models, recipe steps, and broom tidiers at <https://www.tidymodels.org/find/> now all list objects across all CRAN packages, not just tidymodels packages. This should make it much easier to find the right extension for your task, even if not implemented within tidymodels!

And if it does not exist yet, open an issue on GitHub or browse the [developer documentation for extending tidymodels](https://www.tidymodels.org/learn/#category=developer%20tools)!

## Acknowledgements

We'd like to extend our thanks to all of the contributors to tidymodels in the last quarter:

<div class="highlight">

-   agua: [@gvelasq](https://github.com/gvelasq).
-   broom: [@awcm0n](https://github.com/awcm0n), [@gregmacfarlane](https://github.com/gregmacfarlane), [@jwilliman](https://github.com/jwilliman), [@mccarthy-m-g](https://github.com/mccarthy-m-g), [@RoyalTS](https://github.com/RoyalTS), [@simonpcouch](https://github.com/simonpcouch), and [@ste-tuf](https://github.com/ste-tuf).
-   desirability2: [@topepo](https://github.com/topepo).
-   embed: [@EmilHvitfeldt](https://github.com/EmilHvitfeldt), and [@naveranoc](https://github.com/naveranoc).
-   probably: [@agormp](https://github.com/agormp), [@EmilHvitfeldt](https://github.com/EmilHvitfeldt), [@juliasilge](https://github.com/juliasilge), [@simonpcouch](https://github.com/simonpcouch), and [@topepo](https://github.com/topepo).
-   spatialsample: [@jamesgrecian](https://github.com/jamesgrecian), [@mikemahoney218](https://github.com/mikemahoney218), and [@nipnipj](https://github.com/nipnipj).
-   tidymodels: [@forecastingEDs](https://github.com/forecastingEDs), [@JosiahParry](https://github.com/JosiahParry), and [@topepo](https://github.com/topepo).

</div>

