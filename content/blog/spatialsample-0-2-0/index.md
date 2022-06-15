---
output: hugodown::hugo_document

slug: spatialsample-0-2-0
title: spatialsample 0.2.0
date: 2022-06-15
author: Mike Mahoney
description: >
    spatialsample 0.2.0 is now on CRAN! This release provides a bunch of new features, including new spatial resampling methods, visualization helpers, and spatial buffering.

photo:
  url: https://unsplash.com/photos/1-29wyvvLJA
  author: Andrew Neel

# one of: "deep-dive", "learn", "package", "programming", "roundup", or "other"
categories: [package] 
tags: [spatialsample, rsample, tidymodels]
rmd_hash: 07b16e6dfb0af81f

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

We're positively electrified to announce the release of [spatialsample](https://spatialsample.tidymodels.org/) 0.2.0. spatialsample is a package for spatial resampling, extending the rsample framework for resampling to help create spatial extrapolation between your analysis and assessment data sets.

You can install it from CRAN with:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://rdrr.io/r/utils/install.packages.html'>install.packages</a></span><span class='o'>(</span><span class='s'>"spatialsample"</span><span class='o'>)</span></code></pre>

</div>

This blog post will describe the highlights of what's new. You can see a full list of changes in the [release notes](https://github.com/tidymodels/spatialsample/blob/main/NEWS.md).

## New Features

This version of spatialsample includes a new data set, made up of 682 hexagons containing data about tree canopy cover change in Boston, Massachusetts:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://github.com/tidymodels/spatialsample'>spatialsample</a></span><span class='o'>)</span>
<span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://ggplot2.tidyverse.org'>ggplot2</a></span><span class='o'>)</span>

<span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggplot.html'>ggplot</a></span><span class='o'>(</span><span class='nv'>boston_canopy</span><span class='o'>)</span> <span class='o'>+</span> 
  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggsf.html'>geom_sf</a></span><span class='o'>(</span><span class='o'>)</span>
</code></pre>
<img src="figs/unnamed-chunk-2-1.png" title="A map showing the spatial arrangement of hexagons making up the boston_canopy data set." alt="A map showing the spatial arrangement of hexagons making up the boston_canopy data set." width="700px" style="display: block; margin: auto;" />

</div>

This data is stored as an sf object, and as such contains information about the proper coordinate reference system and units of measurement associated with the data.

And that brings us to the first new feature in this release of spatialsample: [`spatial_clustering_cv()`](https://spatialsample.tidymodels.org/reference/spatial_clustering_cv.html) now supports sf objects, and will calculate distances in a way that respects coordinate reference systems (including using the s2 geometry library for geographic coordinate reference systems):

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://rdrr.io/r/base/Random.html'>set.seed</a></span><span class='o'>(</span><span class='m'>123</span><span class='o'>)</span>
<span class='nv'>kmeans_clustering</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://spatialsample.tidymodels.org/reference/spatial_clustering_cv.html'>spatial_clustering_cv</a></span><span class='o'>(</span><span class='nv'>boston_canopy</span>, v <span class='o'>=</span> <span class='m'>5</span><span class='o'>)</span>
<span class='nv'>kmeans_clustering</span>
<span class='c'>#&gt; #  5-fold spatial cross-validation </span>
<span class='c'>#&gt; <span style='color: #555555;'># A tibble: 5 × 2</span></span>
<span class='c'>#&gt;   splits            id   </span>
<span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;list&gt;</span>            <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>1</span> <span style='color: #555555;'>&lt;split [524/158]&gt;</span> Fold1</span>
<span class='c'>#&gt; <span style='color: #555555;'>2</span> <span style='color: #555555;'>&lt;split [493/189]&gt;</span> Fold2</span>
<span class='c'>#&gt; <span style='color: #555555;'>3</span> <span style='color: #555555;'>&lt;split [517/165]&gt;</span> Fold3</span>
<span class='c'>#&gt; <span style='color: #555555;'>4</span> <span style='color: #555555;'>&lt;split [605/77]&gt;</span>  Fold4</span>
<span class='c'>#&gt; <span style='color: #555555;'>5</span> <span style='color: #555555;'>&lt;split [589/93]&gt;</span>  Fold5</span></code></pre>

</div>

This release also provides [`autoplot()`](https://ggplot2.tidyverse.org/reference/autoplot.html) methods to visualize resamples via ggplot2, making it easy to see how exactly your data is being divided. Just call [`autoplot()`](https://ggplot2.tidyverse.org/reference/autoplot.html) on the outputs from any spatial clustering function:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://ggplot2.tidyverse.org/reference/autoplot.html'>autoplot</a></span><span class='o'>(</span><span class='nv'>kmeans_clustering</span><span class='o'>)</span> <span class='o'>+</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/labs.html'>labs</a></span><span class='o'>(</span>title <span class='o'>=</span> <span class='s'>"kmeans()"</span><span class='o'>)</span>
</code></pre>
<img src="figs/unnamed-chunk-4-1.png" title="A map showing the boston_canopy data set broken into five folds through spatial_clustering_cv. The five folds are visibly different sizes, and are grouped by spatial proximity." alt="A map showing the boston_canopy data set broken into five folds through spatial_clustering_cv. The five folds are visibly different sizes, and are grouped by spatial proximity." width="700px" style="display: block; margin: auto;" />

</div>

In addition to supporting more types of data, [`spatial_clustering_cv()`](https://spatialsample.tidymodels.org/reference/spatial_clustering_cv.html) has also been extended to support more types of clustering. Use the `cluster_function` argument to use hierarchical clustering via [`hclust()`](https://rdrr.io/r/stats/hclust.html) instead of the default [`kmeans()`](https://rdrr.io/r/stats/kmeans.html)-based clusters:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://rdrr.io/r/base/Random.html'>set.seed</a></span><span class='o'>(</span><span class='m'>123</span><span class='o'>)</span>
<span class='nf'><a href='https://spatialsample.tidymodels.org/reference/spatial_clustering_cv.html'>spatial_clustering_cv</a></span><span class='o'>(</span>
  <span class='nv'>boston_canopy</span>, 
  v <span class='o'>=</span> <span class='m'>5</span>, 
  cluster_function <span class='o'>=</span> <span class='s'>"hclust"</span>
<span class='o'>)</span> |&gt; 
  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/autoplot.html'>autoplot</a></span><span class='o'>(</span><span class='o'>)</span> <span class='o'>+</span> 
  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/labs.html'>labs</a></span><span class='o'>(</span>title <span class='o'>=</span> <span class='s'>"hclust()"</span><span class='o'>)</span>
</code></pre>
<img src="figs/unnamed-chunk-5-1.png" title="A map showing the boston_canopy data set broken into five folds through spatial_clustering_cv, using the hclust clustering method. The five folds are still visibly different sizes, and are grouped by spatial proximity, but the clusters are notably different from those produced by the default kmeans method." alt="A map showing the boston_canopy data set broken into five folds through spatial_clustering_cv, using the hclust clustering method. The five folds are still visibly different sizes, and are grouped by spatial proximity, but the clusters are notably different from those produced by the default kmeans method." width="700px" style="display: block; margin: auto;" />

</div>

This argument can also accept functions, letting you plug in clustering methodologies from other packages or that you've written yourself:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://rdrr.io/r/base/Random.html'>set.seed</a></span><span class='o'>(</span><span class='m'>123</span><span class='o'>)</span>

<span class='nv'>custom_clusters</span> <span class='o'>&lt;-</span> <span class='kr'>function</span><span class='o'>(</span><span class='nv'>dists</span>, <span class='nv'>v</span>, <span class='nv'>...</span><span class='o'>)</span> <span class='o'>&#123;</span>
  <span class='nf'><a href='https://rdrr.io/r/base/rep.html'>rep</a></span><span class='o'>(</span><span class='nv'>letters</span><span class='o'>[</span><span class='m'>1</span><span class='o'>:</span><span class='nv'>v</span><span class='o'>]</span>, length.out <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/nrow.html'>nrow</a></span><span class='o'>(</span><span class='nv'>boston_canopy</span><span class='o'>)</span><span class='o'>)</span>
<span class='o'>&#125;</span>

<span class='nf'><a href='https://spatialsample.tidymodels.org/reference/spatial_clustering_cv.html'>spatial_clustering_cv</a></span><span class='o'>(</span>
  <span class='nv'>boston_canopy</span>, 
  v <span class='o'>=</span> <span class='m'>5</span>, 
  cluster_function <span class='o'>=</span> <span class='nv'>custom_clusters</span>
<span class='o'>)</span> |&gt; 
  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/autoplot.html'>autoplot</a></span><span class='o'>(</span><span class='o'>)</span> <span class='o'>+</span> 
  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/labs.html'>labs</a></span><span class='o'>(</span>title <span class='o'>=</span> <span class='s'>"custom_clusters()"</span><span class='o'>)</span>
</code></pre>
<img src="figs/unnamed-chunk-6-1.png" title="A map showing the outputs of spatial_clustering_cv when using a custom clustering function. The custom clustering function assigned folds systematically, moving sequentially through rows in the data frame, and as such the output does not look very clustered. However, the functions in spatialsample performed exactly the same with the custom clustering function as they did with the built-in options." alt="A map showing the outputs of spatial_clustering_cv when using a custom clustering function. The custom clustering function assigned folds systematically, moving sequentially through rows in the data frame, and as such the output does not look very clustered. However, the functions in spatialsample performed exactly the same with the custom clustering function as they did with the built-in options." width="700px" style="display: block; margin: auto;" />

</div>

In addition to the clustering extensions, this version of spatialsample introduces a few functions for other popular spatial resampling methods. For instance, the new function [`spatial_block_cv()`](https://spatialsample.tidymodels.org/reference/spatial_block_cv.html) helps you perform [block cross-validation](https://doi.org/10.1111/ecog.02881), splitting your data into folds based on a grid of regular polygons. You can assign these polygons to folds at random:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://rdrr.io/r/base/Random.html'>set.seed</a></span><span class='o'>(</span><span class='m'>123</span><span class='o'>)</span>
<span class='nf'><a href='https://spatialsample.tidymodels.org/reference/spatial_block_cv.html'>spatial_block_cv</a></span><span class='o'>(</span><span class='nv'>boston_canopy</span>, v <span class='o'>=</span> <span class='m'>5</span><span class='o'>)</span> |&gt; 
  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/autoplot.html'>autoplot</a></span><span class='o'>(</span><span class='o'>)</span>
</code></pre>
<img src="figs/unnamed-chunk-7-1.png" title="A map showing the outputs of block cross-validation performed using spatial_block_cv. A regular grid of squares has been drawn over the boston_canopy data set, and all data falling into a single block is assigned to the same fold. Blocks are assigned to folds at random, resulting in a patchy distribution of folds across the data set." alt="A map showing the outputs of block cross-validation performed using spatial_block_cv. A regular grid of squares has been drawn over the boston_canopy data set, and all data falling into a single block is assigned to the same fold. Blocks are assigned to folds at random, resulting in a patchy distribution of folds across the data set." width="700px" style="display: block; margin: auto;" />

</div>

Or systematically, either by assigning folds in order from the bottom-left and proceeding from left to right along each row by setting `method = "continuous"`:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://spatialsample.tidymodels.org/reference/spatial_block_cv.html'>spatial_block_cv</a></span><span class='o'>(</span><span class='nv'>boston_canopy</span>, v <span class='o'>=</span> <span class='m'>5</span>, method <span class='o'>=</span> <span class='s'>"continuous"</span><span class='o'>)</span> |&gt; 
  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/autoplot.html'>autoplot</a></span><span class='o'>(</span><span class='o'>)</span>
</code></pre>
<img src="figs/unnamed-chunk-8-1.png" title="A map showing the outputs of block cross-validation performed using spatial_block_cv with continuous systematic assignment. Rather than the patchy random assignment before, blocks are now assigned from left to right for each row of the regular grid, resulting in the same folds always being adjacent to one another." alt="A map showing the outputs of block cross-validation performed using spatial_block_cv with continuous systematic assignment. Rather than the patchy random assignment before, blocks are now assigned from left to right for each row of the regular grid, resulting in the same folds always being adjacent to one another." width="700px" style="display: block; margin: auto;" />

</div>

Or by "snaking" back and forth up the grid by setting `method = "snake"`:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://spatialsample.tidymodels.org/reference/spatial_block_cv.html'>spatial_block_cv</a></span><span class='o'>(</span><span class='nv'>boston_canopy</span>, v <span class='o'>=</span> <span class='m'>5</span>, method <span class='o'>=</span> <span class='s'>"snake"</span><span class='o'>)</span> |&gt; 
  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/autoplot.html'>autoplot</a></span><span class='o'>(</span><span class='o'>)</span>
</code></pre>
<img src="figs/unnamed-chunk-9-1.png" title="A map showing the outputs of block cross-validation performed using spatial_block_cv with snaking systematic assignment. Blocks are now assigned alternatively from left to right and right to left, resulting in a similar alignment of folds to the continuous method." alt="A map showing the outputs of block cross-validation performed using spatial_block_cv with snaking systematic assignment. Blocks are now assigned alternatively from left to right and right to left, resulting in a similar alignment of folds to the continuous method." width="700px" style="display: block; margin: auto;" />

</div>

This release of spatialsample also adds support for [leave-location-out cross-validation](https://doi.org/10.1111/geb.12161) through the new function [`spatial_leave_location_out_cv()`](https://spatialsample.tidymodels.org/reference/spatial_vfold.html). You can use this to create resamples when you already have a good idea of what data might be spatially correlated together -- for instance, we can use it to split the Ames housing data from modeldata by neighborhood:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://rdrr.io/r/utils/data.html'>data</a></span><span class='o'>(</span><span class='nv'>ames</span>, package <span class='o'>=</span> <span class='s'>"modeldata"</span><span class='o'>)</span>

<span class='nv'>ames_sf</span> <span class='o'>&lt;-</span> <span class='nf'>sf</span><span class='nf'>::</span><span class='nf'><a href='https://r-spatial.github.io/sf/reference/st_as_sf.html'>st_as_sf</a></span><span class='o'>(</span><span class='nv'>ames</span>, coords <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"Longitude"</span>, <span class='s'>"Latitude"</span><span class='o'>)</span>, crs <span class='o'>=</span> <span class='m'>4326</span><span class='o'>)</span>

<span class='nf'><a href='https://rdrr.io/r/base/Random.html'>set.seed</a></span><span class='o'>(</span><span class='m'>123</span><span class='o'>)</span>
<span class='nf'><a href='https://spatialsample.tidymodels.org/reference/spatial_vfold.html'>spatial_leave_location_out_cv</a></span><span class='o'>(</span><span class='nv'>ames_sf</span>, <span class='nv'>Neighborhood</span><span class='o'>)</span> |&gt; 
  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/autoplot.html'>autoplot</a></span><span class='o'>(</span><span class='o'>)</span>
</code></pre>
<img src="figs/unnamed-chunk-10-1.png" title="A map showing the outputs of leave-location-out cross-validation performed using spatial_leave_location_out_cv on the Ames housing data. Folds are assigned based on what neighborhood each house falls into. Some neighborhoods are entirely contained within another neighborhood, and neighborhoods contain very different numbers of houses." alt="A map showing the outputs of leave-location-out cross-validation performed using spatial_leave_location_out_cv on the Ames housing data. Folds are assigned based on what neighborhood each house falls into. Some neighborhoods are entirely contained within another neighborhood, and neighborhoods contain very different numbers of houses." width="700px" style="display: block; margin: auto;" />

</div>

## Buffering

The last major feature in this release is the introduction of spatial buffering. Spatial buffering enforces a certain minimum distance between your analysis and assessment sets, making sure that you're spatially extrapolating when making predictions with a model.

While all spatial resampling functions in spatialsample can use spatial buffers, particularly interesting is the new [`spatial_buffer_vfold_cv()`](https://spatialsample.tidymodels.org/reference/spatial_vfold.html) function. This function makes it easy to add spatial buffers around a standard V-fold cross-validation procedure. When we plot the object returned by this function, it just looks like a standard V-fold cross-validation setup:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://rdrr.io/r/base/Random.html'>set.seed</a></span><span class='o'>(</span><span class='m'>123</span><span class='o'>)</span>
<span class='nv'>blocks</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://spatialsample.tidymodels.org/reference/spatial_vfold.html'>spatial_buffer_vfold_cv</a></span><span class='o'>(</span>
  <span class='nv'>boston_canopy</span>, 
  v <span class='o'>=</span> <span class='m'>15</span>,
  buffer <span class='o'>=</span> <span class='m'>100</span>,
  radius <span class='o'>=</span> <span class='kc'>NULL</span>
<span class='o'>)</span>

<span class='nf'><a href='https://ggplot2.tidyverse.org/reference/autoplot.html'>autoplot</a></span><span class='o'>(</span><span class='nv'>blocks</span><span class='o'>)</span>
</code></pre>
<img src="figs/unnamed-chunk-11-1.png" title="A map showing the outputs of spatially buffered cross-validation performed using spatial_buffer_vfold_cv, once again using the boston_canopy data set. When visualizing all folds at once, there does not seem to be any spatial structure to the resamples; folds are distributed randomly throughout the data set, and folds abut one another without any spatial separation." alt="A map showing the outputs of spatially buffered cross-validation performed using spatial_buffer_vfold_cv, once again using the boston_canopy data set. When visualizing all folds at once, there does not seem to be any spatial structure to the resamples; folds are distributed randomly throughout the data set, and folds abut one another without any spatial separation." width="700px" style="display: block; margin: auto;" />

</div>

However, if we use [`autoplot()`](https://ggplot2.tidyverse.org/reference/autoplot.html) to visualize the splits themselves, we can see that we've created an exclusion buffer around each of our assessment sets. Data inside this buffer is assigned to neither the assessment or analysis set, so you can be sure your data is spatially separated:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>blocks</span><span class='o'>$</span><span class='nv'>splits</span> |&gt; 
  <span class='nf'>purrr</span><span class='nf'>::</span><span class='nf'><a href='https://purrr.tidyverse.org/reference/map.html'>walk</a></span><span class='o'>(</span><span class='kr'>function</span><span class='o'>(</span><span class='nv'>x</span><span class='o'>)</span> <span class='nf'><a href='https://rdrr.io/r/base/print.html'>print</a></span><span class='o'>(</span><span class='nf'><a href='https://ggplot2.tidyverse.org/reference/autoplot.html'>autoplot</a></span><span class='o'>(</span><span class='nv'>x</span><span class='o'>)</span><span class='o'>)</span><span class='o'>)</span>
</code></pre>
<img src="figs/unnamed-chunk-12-.gif" title="An animation showing maps of each individual fold produced using spatial_buffer_vfold_cv. Now it is evident that any data adjacent to the assessment data has been added to a 'buffer' zone, and is part of neither the analysis or the assessment set." alt="An animation showing maps of each individual fold produced using spatial_buffer_vfold_cv. Now it is evident that any data adjacent to the assessment data has been added to a 'buffer' zone, and is part of neither the analysis or the assessment set." width="700px" style="display: block; margin: auto;" />

</div>

In addition to exclusion buffers, spatialsample now lets you add inclusion radii to any spatial resampling. This will add any points within a certain distance of the original assessment set to the assessment set, letting you create clumped "discs" of data to assess your models against:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://rdrr.io/r/base/Random.html'>set.seed</a></span><span class='o'>(</span><span class='m'>123</span><span class='o'>)</span>
<span class='nv'>blocks</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://spatialsample.tidymodels.org/reference/spatial_vfold.html'>spatial_buffer_vfold_cv</a></span><span class='o'>(</span>
  <span class='nv'>boston_canopy</span>, 
  v <span class='o'>=</span> <span class='m'>20</span>,
  buffer <span class='o'>=</span> <span class='m'>100</span>,
  radius <span class='o'>=</span> <span class='m'>100</span>
<span class='o'>)</span>

<span class='nv'>blocks</span><span class='o'>$</span><span class='nv'>splits</span> |&gt; 
  <span class='nf'>purrr</span><span class='nf'>::</span><span class='nf'><a href='https://purrr.tidyverse.org/reference/map.html'>walk</a></span><span class='o'>(</span><span class='kr'>function</span><span class='o'>(</span><span class='nv'>x</span><span class='o'>)</span> <span class='nf'><a href='https://rdrr.io/r/base/print.html'>print</a></span><span class='o'>(</span><span class='nf'><a href='https://ggplot2.tidyverse.org/reference/autoplot.html'>autoplot</a></span><span class='o'>(</span><span class='nv'>x</span><span class='o'>)</span><span class='o'>)</span><span class='o'>)</span>
</code></pre>
<img src="figs/unnamed-chunk-13-.gif" title="Another animation showing maps of each individual fold produced using spatial_buffer_vfold_cv. When using the argument radius, points adjacent to the assessment set are themselves added to the assessment set. The buffer is then applied to each data point in the enlarged assessment set." alt="Another animation showing maps of each individual fold produced using spatial_buffer_vfold_cv. When using the argument radius, points adjacent to the assessment set are themselves added to the assessment set. The buffer is then applied to each data point in the enlarged assessment set." width="700px" style="display: block; margin: auto;" />

</div>

## ...and more!

This is just scratching the surface of the new features and improvements in this release of spatialsample. You can see a full list of changes in the the [release notes](https://github.com/tidymodels/spatialsample/blob/main/NEWS.md).

## Acknowledgments

We'd like to thank everyone that has contributed since the last release: [@jennybc](https://github.com/jennybc), [@juliasilge](https://github.com/juliasilge), [@mikemahoney218](https://github.com/mikemahoney218), [@MxNl](https://github.com/MxNl), [@nipnipj](https://github.com/nipnipj), and [@PathosEthosLogos](https://github.com/PathosEthosLogos).

