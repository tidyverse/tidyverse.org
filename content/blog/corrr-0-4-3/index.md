---
output: hugodown::hugo_document

slug: corrr-0-4-3
title: corrr 0.4.3
date: 2020-12-02
author: Daryn Ramsden, James Laird-Smith, Max Kuhn
description: >
    A new version of corrr features noteworthy improvements. 

photo:
  url: https://unsplash.com/photos/MOO6k3RaiwE
  author: Omar Flores

# one of: "deep-dive", "learn", "package", "programming", or "other"
categories: [package] 
tags: [corrr, tidymodels, correlation]
rmd_hash: 3857bbf27774d2ee

---

<!--
TODO:
* [ ] Pick category and tags (see existing with `post_tags()`)
* [ ] Find photo & update yaml metadata
* [ ] Create `thumbnail-sq.jpg`; height and width should be equal
* [ ] Create `thumbnail-wd.jpg`; width should be >5x height
* [ ] `hugodown::use_tidy_thumbnail()`
* [ ] Add intro sentence
* [ ] `use_tidy_thanks()`
-->

We're thrilled to announce the release of [corrr](https://corrr.tidymodels.org/) 0.4.3. corrr is for exploring correlations in R. It focuses on creating and working with data frames of correlations (instead of matrices) that can be easily explored via corrr functions or by leveraging tools like those in the tidyverse.

You can install it from CRAN with:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://rdrr.io/r/utils/install.packages.html'>install.packages</a></span><span class='o'>(</span><span class='s'>"corrr"</span><span class='o'>)</span>
</code></pre>

</div>

This blog post will describe changes in the new version. You can see a full list of changes in the [release notes](https://corrr.tidymodels.org/news/index.html).

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://github.com/tidymodels/corrr'>corrr</a></span><span class='o'>)</span>
<span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://dplyr.tidyverse.org'>dplyr</a></span>, warn.conflicts <span class='o'>=</span> <span class='kc'>FALSE</span><span class='o'>)</span>
</code></pre>

</div>

Changes
-------

This version of corrr has a few changes in the behavior of user-facing functions as well as the introduction of a new user-facing function.

There are also some internal changes that make package functions more robust. These changes don't affect how you use the package but address some edge cases where previous versions were failing inappropriately.

New features of note are:

1.  The first column of a `cor_df` object is now named "term". Previously it was named "rowname". The name "term" is consistent with the output of [`broom::tidy()`](https://generics.r-lib.org/reference/tidy.html). **This is a breaking change**: code written to make use of the column name "rowname" will have to be amended.

2.  An `.order` argument has been added to [`rplot()`](https://corrr.tidymodels.org/reference/rplot.html) to allow users to choose the ordering of variables along the axes in the output plot. The default is that the output plots retain the variable ordering in the input `cor_df` object. Setting `.order` to "alphabet" orders the variables in alphabetical order in the plots.

3.  A new function, [`colpair_map()`](https://corrr.tidymodels.org/reference/colpair_map.html), allows for column comparisons using the values returned by an arbitrary function. [`colpair_map()`](https://corrr.tidymodels.org/reference/colpair_map.html) is discussed in detail below.

### New column name in `cor_df` objects

We can create a `cor_df` object containing the pairwise correlations between numerical columns of the [`palmerpenguins::penguins`](https://allisonhorst.github.io/palmerpenguins/reference/penguins.html) data set to see that the first column is now named "term":

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://allisonhorst.github.io/palmerpenguins/'>palmerpenguins</a></span><span class='o'>)</span>

<span class='nv'>penguins_cor</span> <span class='o'>&lt;-</span> <span class='nv'>penguins</span> <span class='o'>%&gt;%</span> 
  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/select.html'>select</a></span><span class='o'>(</span><span class='nf'>where</span><span class='o'>(</span><span class='nv'>is.numeric</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>%&gt;%</span> 
  <span class='nf'><a href='https://corrr.tidymodels.org/reference/correlate.html'>correlate</a></span><span class='o'>(</span><span class='o'>)</span>

<span class='nv'>penguins_cor</span>

<span class='c'>#&gt; <span style='color: #555555;'># A tibble: 5 x 6</span></span>
<span class='c'>#&gt;   term         bill_length_mm bill_depth_mm flipper_length_… body_mass_g    year</span>
<span class='c'>#&gt;   <span style='color: #555555;font-style: italic;'>&lt;chr&gt;</span><span>                 </span><span style='color: #555555;font-style: italic;'>&lt;dbl&gt;</span><span>         </span><span style='color: #555555;font-style: italic;'>&lt;dbl&gt;</span><span>            </span><span style='color: #555555;font-style: italic;'>&lt;dbl&gt;</span><span>       </span><span style='color: #555555;font-style: italic;'>&lt;dbl&gt;</span><span>   </span><span style='color: #555555;font-style: italic;'>&lt;dbl&gt;</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>1</span><span> bill_length…        </span><span style='color: #BB0000;'>NA</span><span>            -</span><span style='color: #BB0000;'>0.235</span><span>             0.656      0.595   0.054</span><span style='text-decoration: underline;'>5</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>2</span><span> bill_depth_…        -</span><span style='color: #BB0000;'>0.235</span><span>        </span><span style='color: #BB0000;'>NA</span><span>                -</span><span style='color: #BB0000;'>0.584</span><span>     -</span><span style='color: #BB0000;'>0.472</span><span>  -</span><span style='color: #BB0000;'>0.060</span><span style='color: #BB0000;text-decoration: underline;'>4</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>3</span><span> flipper_len…         0.656        -</span><span style='color: #BB0000;'>0.584</span><span>            </span><span style='color: #BB0000;'>NA</span><span>          0.871   0.170 </span></span>
<span class='c'>#&gt; <span style='color: #555555;'>4</span><span> body_mass_g          0.595        -</span><span style='color: #BB0000;'>0.472</span><span>             0.871     </span><span style='color: #BB0000;'>NA</span><span>       0.042</span><span style='text-decoration: underline;'>2</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>5</span><span> year                 0.054</span><span style='text-decoration: underline;'>5</span><span>       -</span><span style='color: #BB0000;'>0.060</span><span style='color: #BB0000;text-decoration: underline;'>4</span><span>            0.170      0.042</span><span style='text-decoration: underline;'>2</span><span> </span><span style='color: #BB0000;'>NA</span></span>
</code></pre>

</div>

### Ordering variables in `rplot()` output

Previously, the default behavior of [`rplot()`](https://corrr.tidymodels.org/reference/rplot.html) was that the variables were displayed in alphabetical order in the output. This was an artifact of using `ggplot2` and inheriting its behavior. The new default is to retain the ordering of variables in the input data:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://corrr.tidymodels.org/reference/rplot.html'>rplot</a></span><span class='o'>(</span><span class='nv'>penguins_cor</span><span class='o'>)</span> 

</code></pre>
<img src="figs/unnamed-chunk-3-1.png" width="700px" style="display: block; margin: auto;" />

</div>

If alphabetical ordering is desired, set `.order` to "alphabet":

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://corrr.tidymodels.org/reference/rplot.html'>rplot</a></span><span class='o'>(</span><span class='nv'>penguins_cor</span>, .order <span class='o'>=</span> <span class='s'>"alphabet"</span><span class='o'>)</span>

</code></pre>
<img src="figs/unnamed-chunk-4-1.png" width="700px" style="display: block; margin: auto;" />

</div>

[`colpair_map()`](https://corrr.tidymodels.org/reference/colpair_map.html)
---------------

Doing analysis with corrr has always been about correlations, usually starting with a call to [`correlate()`](https://corrr.tidymodels.org/reference/correlate.html).

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>mini_mtcars</span> <span class='o'>&lt;-</span> <span class='nv'>mtcars</span> <span class='o'>%&gt;%</span> <span class='nf'><a href='https://dplyr.tidyverse.org/reference/select.html'>select</a></span><span class='o'>(</span><span class='nv'>mpg</span>, <span class='nv'>cyl</span>, <span class='nv'>disp</span><span class='o'>)</span>

<span class='nf'><a href='https://corrr.tidymodels.org/reference/correlate.html'>correlate</a></span><span class='o'>(</span><span class='nv'>mini_mtcars</span><span class='o'>)</span>

<span class='c'>#&gt; </span>
<span class='c'>#&gt; Correlation method: 'pearson'</span>
<span class='c'>#&gt; Missing treated using: 'pairwise.complete.obs'</span>

<span class='c'>#&gt; <span style='color: #555555;'># A tibble: 3 x 4</span></span>
<span class='c'>#&gt;   term     mpg    cyl   disp</span>
<span class='c'>#&gt;   <span style='color: #555555;font-style: italic;'>&lt;chr&gt;</span><span>  </span><span style='color: #555555;font-style: italic;'>&lt;dbl&gt;</span><span>  </span><span style='color: #555555;font-style: italic;'>&lt;dbl&gt;</span><span>  </span><span style='color: #555555;font-style: italic;'>&lt;dbl&gt;</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>1</span><span> mpg   </span><span style='color: #BB0000;'>NA</span><span>     -</span><span style='color: #BB0000;'>0.852</span><span> -</span><span style='color: #BB0000;'>0.848</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>2</span><span> cyl   -</span><span style='color: #BB0000;'>0.852</span><span> </span><span style='color: #BB0000;'>NA</span><span>      0.902</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>3</span><span> disp  -</span><span style='color: #BB0000;'>0.848</span><span>  0.902 </span><span style='color: #BB0000;'>NA</span></span>
</code></pre>

</div>

The result is a data frame where each of the columns in the original data are compared on the basis of their correlation coefficients. But the correlation coefficient is just one possible statistic that can be used for comparing columns with one another. Correlations are also limited in their usefulness as they are only applicable to pairs of numeric columns.

This version of corrr introduces [`colpair_map()`](https://corrr.tidymodels.org/reference/colpair_map.html), which allows you to apply your own choice of function across the columns of your data. Just like with [`correlate()`](https://corrr.tidymodels.org/reference/correlate.html), [`colpair_map()`](https://corrr.tidymodels.org/reference/colpair_map.html) takes a data frame as its first argument, while the second argument is for the function you wish to apply.

Let's demonstrate using the `mini_mtcars` data frame we just created. Lets say we are interested in covariance values rather than correlations. These can be found by passing in [`cov()`](https://rdrr.io/r/stats/cor.html) from the stats package:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>cov_df</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://corrr.tidymodels.org/reference/colpair_map.html'>colpair_map</a></span><span class='o'>(</span><span class='nv'>mini_mtcars</span>, <span class='nf'>stats</span><span class='nf'>::</span><span class='nv'><a href='https://rdrr.io/r/stats/cor.html'>cov</a></span><span class='o'>)</span>

<span class='nv'>cov_df</span>

<span class='c'>#&gt; <span style='color: #555555;'># A tibble: 3 x 4</span></span>
<span class='c'>#&gt;   term      mpg    cyl  disp</span>
<span class='c'>#&gt;   <span style='color: #555555;font-style: italic;'>&lt;chr&gt;</span><span>   </span><span style='color: #555555;font-style: italic;'>&lt;dbl&gt;</span><span>  </span><span style='color: #555555;font-style: italic;'>&lt;dbl&gt;</span><span> </span><span style='color: #555555;font-style: italic;'>&lt;dbl&gt;</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>1</span><span> mpg     </span><span style='color: #BB0000;'>NA</span><span>     -</span><span style='color: #BB0000;'>9.17</span><span> -</span><span style='color: #BB0000;'>633.</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>2</span><span> cyl     -</span><span style='color: #BB0000;'>9.17</span><span>  </span><span style='color: #BB0000;'>NA</span><span>     200.</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>3</span><span> disp  -</span><span style='color: #BB0000;'>633.</span><span>   200.     </span><span style='color: #BB0000;'>NA</span></span>
</code></pre>

</div>

The resulting data frame behaves just like one returned by [`correlate()`](https://corrr.tidymodels.org/reference/correlate.html), except that it is populated with covariance values rather than correlations. This means we still have access to all corrr's other tooling when working with it. We can still use [`shave()`](https://corrr.tidymodels.org/reference/shave.html) for example to remove duplication, which will set the upper triangle of values to `NA`.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>cov_df</span> <span class='o'>%&gt;%</span> 
  <span class='nf'><a href='https://corrr.tidymodels.org/reference/shave.html'>shave</a></span><span class='o'>(</span><span class='o'>)</span>

<span class='c'>#&gt; <span style='color: #555555;'># A tibble: 3 x 4</span></span>
<span class='c'>#&gt;   term      mpg   cyl  disp</span>
<span class='c'>#&gt;   <span style='color: #555555;font-style: italic;'>&lt;chr&gt;</span><span>   </span><span style='color: #555555;font-style: italic;'>&lt;dbl&gt;</span><span> </span><span style='color: #555555;font-style: italic;'>&lt;dbl&gt;</span><span> </span><span style='color: #555555;font-style: italic;'>&lt;dbl&gt;</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>1</span><span> mpg     </span><span style='color: #BB0000;'>NA</span><span>      </span><span style='color: #BB0000;'>NA</span><span>     </span><span style='color: #BB0000;'>NA</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>2</span><span> cyl     -</span><span style='color: #BB0000;'>9.17</span><span>   </span><span style='color: #BB0000;'>NA</span><span>     </span><span style='color: #BB0000;'>NA</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>3</span><span> disp  -</span><span style='color: #BB0000;'>633.</span><span>    200.    </span><span style='color: #BB0000;'>NA</span></span>
</code></pre>

</div>

Similarly, we can still use [`stretch()`](https://corrr.tidymodels.org/reference/stretch.html) to get the resulting data frame into a longer format:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>cov_df</span> <span class='o'>%&gt;%</span> 
  <span class='nf'><a href='https://corrr.tidymodels.org/reference/stretch.html'>stretch</a></span><span class='o'>(</span><span class='o'>)</span>

<span class='c'>#&gt; <span style='color: #555555;'># A tibble: 9 x 3</span></span>
<span class='c'>#&gt;   x     y           r</span>
<span class='c'>#&gt;   <span style='color: #555555;font-style: italic;'>&lt;chr&gt;</span><span> </span><span style='color: #555555;font-style: italic;'>&lt;chr&gt;</span><span>   </span><span style='color: #555555;font-style: italic;'>&lt;dbl&gt;</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>1</span><span> mpg   mpg     </span><span style='color: #BB0000;'>NA</span><span>   </span></span>
<span class='c'>#&gt; <span style='color: #555555;'>2</span><span> mpg   cyl     -</span><span style='color: #BB0000;'>9.17</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>3</span><span> mpg   disp  -</span><span style='color: #BB0000;'>633.</span><span>  </span></span>
<span class='c'>#&gt; <span style='color: #555555;'>4</span><span> cyl   mpg     -</span><span style='color: #BB0000;'>9.17</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>5</span><span> cyl   cyl     </span><span style='color: #BB0000;'>NA</span><span>   </span></span>
<span class='c'>#&gt; <span style='color: #555555;'>6</span><span> cyl   disp   200.  </span></span>
<span class='c'>#&gt; <span style='color: #555555;'>7</span><span> disp  mpg   -</span><span style='color: #BB0000;'>633.</span><span>  </span></span>
<span class='c'>#&gt; <span style='color: #555555;'>8</span><span> disp  cyl    200.  </span></span>
<span class='c'>#&gt; <span style='color: #555555;'>9</span><span> disp  disp    </span><span style='color: #BB0000;'>NA</span></span>
</code></pre>

</div>

The first part of the name ("colpair\_") comes from the fact that we are comparing pairs of columns. The second part of the name (\"\_map\") is designed to evoke the same ideas as in purrr's family of `map_*` functions. These iterate over a set of elements and apply a function to each of them. In this case, [`colpair_map()`](https://corrr.tidymodels.org/reference/colpair_map.html) is iterating over each possible pair of columns and applying a function to each pairing.

As such, any function passed to [`colpair_map()`](https://corrr.tidymodels.org/reference/colpair_map.html) must accept a vector for both its first and second arguments. To illustrate, let's say we wanted to run a series t-tests to see which of our variables are significantly related to one another. We can write a function to do so as follows:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>calc_ttest_p_value</span> <span class='o'>&lt;-</span> <span class='kr'>function</span><span class='o'>(</span><span class='nv'>vec_a</span>, <span class='nv'>vec_b</span><span class='o'>)</span><span class='o'>&#123;</span>
  <span class='nf'><a href='https://rdrr.io/r/stats/t.test.html'>t.test</a></span><span class='o'>(</span><span class='nv'>vec_a</span>, <span class='nv'>vec_b</span><span class='o'>)</span><span class='o'>$</span><span class='nv'>p.value</span>
<span class='o'>&#125;</span>
</code></pre>

</div>

The function returns the t-test's p-value. The two arguments to the function are the two vectors being compared. Let's first run the function on each pair of columns individually.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'>calc_ttest_p_value</span><span class='o'>(</span><span class='nv'>mini_mtcars</span><span class='o'>[</span>, <span class='s'>"mpg"</span><span class='o'>]</span>, <span class='nv'>mini_mtcars</span><span class='o'>[</span>, <span class='s'>"cyl"</span><span class='o'>]</span><span class='o'>)</span>

<span class='c'>#&gt; [1] 9.507708e-15</span>

<span class='nf'>calc_ttest_p_value</span><span class='o'>(</span><span class='nv'>mini_mtcars</span><span class='o'>[</span>, <span class='s'>"mpg"</span><span class='o'>]</span>, <span class='nv'>mini_mtcars</span><span class='o'>[</span>, <span class='s'>"disp"</span><span class='o'>]</span><span class='o'>)</span>

<span class='c'>#&gt; [1] 7.978234e-11</span>

<span class='nf'>calc_ttest_p_value</span><span class='o'>(</span><span class='nv'>mini_mtcars</span><span class='o'>[</span>, <span class='s'>"cyl"</span><span class='o'>]</span>, <span class='nv'>mini_mtcars</span><span class='o'>[</span>, <span class='s'>"disp"</span><span class='o'>]</span><span class='o'>)</span>

<span class='c'>#&gt; [1] 1.774454e-11</span>
</code></pre>

</div>

As you can see, this is tedious and involves a lot of repeated code. But [`colpair_map()`](https://corrr.tidymodels.org/reference/colpair_map.html) lets us do this for all column pairings at once and the output makes the results easy to read.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://corrr.tidymodels.org/reference/colpair_map.html'>colpair_map</a></span><span class='o'>(</span><span class='nv'>mini_mtcars</span>, <span class='nv'>calc_ttest_p_value</span><span class='o'>)</span>

<span class='c'>#&gt; <span style='color: #555555;'># A tibble: 3 x 4</span></span>
<span class='c'>#&gt;   term        mpg       cyl      disp</span>
<span class='c'>#&gt;   <span style='color: #555555;font-style: italic;'>&lt;chr&gt;</span><span>     </span><span style='color: #555555;font-style: italic;'>&lt;dbl&gt;</span><span>     </span><span style='color: #555555;font-style: italic;'>&lt;dbl&gt;</span><span>     </span><span style='color: #555555;font-style: italic;'>&lt;dbl&gt;</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>1</span><span> mpg   </span><span style='color: #BB0000;'>NA</span><span>   </span><span style='color: #555555;'> </span><span>     9.51</span><span style='color: #555555;'>e</span><span style='color: #BB0000;'>-15</span><span>  7.98</span><span style='color: #555555;'>e</span><span style='color: #BB0000;'>-11</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>2</span><span> cyl    9.51</span><span style='color: #555555;'>e</span><span style='color: #BB0000;'>-15</span><span> </span><span style='color: #BB0000;'>NA</span><span>   </span><span style='color: #555555;'> </span><span>     1.77</span><span style='color: #555555;'>e</span><span style='color: #BB0000;'>-11</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>3</span><span> disp   7.98</span><span style='color: #555555;'>e</span><span style='color: #BB0000;'>-11</span><span>  1.77</span><span style='color: #555555;'>e</span><span style='color: #BB0000;'>-11</span><span> </span><span style='color: #BB0000;'>NA</span><span>   </span><span style='color: #555555;'> </span></span>
</code></pre>

</div>

Having the ability to use arbitrary functions like this opens up intriguing possibilities for analyzing data. One limitation of using only correlations is they will only work for continuous variables. With [`colpair_map()`](https://corrr.tidymodels.org/reference/colpair_map.html), we have a way of comparing categorical columns with one another. Let's try this with a few categorical columns from dplyr's dataset of Star Wars characters.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>mini_star_wars</span> <span class='o'>&lt;-</span> <span class='nv'>starwars</span> <span class='o'>%&gt;%</span> <span class='nf'><a href='https://dplyr.tidyverse.org/reference/select.html'>select</a></span><span class='o'>(</span><span class='nv'>hair_color</span>, <span class='nv'>eye_color</span>, <span class='nv'>skin_color</span><span class='o'>)</span>

<span class='nf'><a href='https://rdrr.io/r/utils/head.html'>head</a></span><span class='o'>(</span><span class='nv'>mini_star_wars</span><span class='o'>)</span>

<span class='c'>#&gt; <span style='color: #555555;'># A tibble: 6 x 3</span></span>
<span class='c'>#&gt;   hair_color  eye_color skin_color </span>
<span class='c'>#&gt;   <span style='color: #555555;font-style: italic;'>&lt;chr&gt;</span><span>       </span><span style='color: #555555;font-style: italic;'>&lt;chr&gt;</span><span>     </span><span style='color: #555555;font-style: italic;'>&lt;chr&gt;</span><span>      </span></span>
<span class='c'>#&gt; <span style='color: #555555;'>1</span><span> blond       blue      fair       </span></span>
<span class='c'>#&gt; <span style='color: #555555;'>2</span><span> </span><span style='color: #BB0000;'>NA</span><span>          yellow    gold       </span></span>
<span class='c'>#&gt; <span style='color: #555555;'>3</span><span> </span><span style='color: #BB0000;'>NA</span><span>          red       white, blue</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>4</span><span> none        yellow    white      </span></span>
<span class='c'>#&gt; <span style='color: #555555;'>5</span><span> brown       brown     light      </span></span>
<span class='c'>#&gt; <span style='color: #555555;'>6</span><span> brown, grey blue      light</span></span>
</code></pre>

</div>

There are a few different ways of finding the strength of the relationship between two categorical variables. One useful measure is called Cramer's V, which takes on values between 0 and 1 depending on how closely associated the variables are. The rcompanion package provides an implementation of Cramer's V which we can make use of.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='http://rcompanion.org/'>rcompanion</a></span><span class='o'>)</span>

<span class='nf'><a href='https://corrr.tidymodels.org/reference/colpair_map.html'>colpair_map</a></span><span class='o'>(</span><span class='nv'>mini_star_wars</span>, <span class='nv'>cramerV</span><span class='o'>)</span>

<span class='c'>#&gt; <span style='color: #555555;'># A tibble: 3 x 4</span></span>
<span class='c'>#&gt;   term       hair_color eye_color skin_color</span>
<span class='c'>#&gt;   <span style='color: #555555;font-style: italic;'>&lt;chr&gt;</span><span>           </span><span style='color: #555555;font-style: italic;'>&lt;dbl&gt;</span><span>     </span><span style='color: #555555;font-style: italic;'>&lt;dbl&gt;</span><span>      </span><span style='color: #555555;font-style: italic;'>&lt;dbl&gt;</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>1</span><span> hair_color     </span><span style='color: #BB0000;'>NA</span><span>         0.449      0.510</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>2</span><span> eye_color       0.449    </span><span style='color: #BB0000;'>NA</span><span>          0.691</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>3</span><span> skin_color      0.510     0.691     </span><span style='color: #BB0000;'>NA</span></span>
</code></pre>

</div>

[`colpair_map()`](https://corrr.tidymodels.org/reference/colpair_map.html) will allow you pass additional arguments to the called function via the dots (`...`). For example, the [`cramerV()`](https://rdrr.io/pkg/rcompanion/man/cramerV.html) function will allow you to specify the number of decimal places to round the results using `digits`. Let's instead pass in this option via the dots:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://corrr.tidymodels.org/reference/colpair_map.html'>colpair_map</a></span><span class='o'>(</span><span class='nv'>mini_star_wars</span>, <span class='nv'>cramerV</span>, digits <span class='o'>=</span> <span class='m'>1</span><span class='o'>)</span>

<span class='c'>#&gt; <span style='color: #555555;'># A tibble: 3 x 4</span></span>
<span class='c'>#&gt;   term       hair_color eye_color skin_color</span>
<span class='c'>#&gt;   <span style='color: #555555;font-style: italic;'>&lt;chr&gt;</span><span>           </span><span style='color: #555555;font-style: italic;'>&lt;dbl&gt;</span><span>     </span><span style='color: #555555;font-style: italic;'>&lt;dbl&gt;</span><span>      </span><span style='color: #555555;font-style: italic;'>&lt;dbl&gt;</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>1</span><span> hair_color       </span><span style='color: #BB0000;'>NA</span><span>         0.4        0.5</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>2</span><span> eye_color         0.4      </span><span style='color: #BB0000;'>NA</span><span>          0.7</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>3</span><span> skin_color        0.5       0.7       </span><span style='color: #BB0000;'>NA</span></span>
</code></pre>

</div>

We are excited to see the different ways [`colpair_map()`](https://corrr.tidymodels.org/reference/colpair_map.html) gets used by the R community. We are hopeful that it will open up new and exciting ways of conducting data analysis.

Acknowledgements
----------------

We'd like to thank everyone who contributed to the package or filed an issue since the last release: [@Aariq](https://github.com/Aariq), [@antoine-sachet](https://github.com/antoine-sachet), [@bjornerstedt](https://github.com/bjornerstedt), [@jameslairdsmith](https://github.com/jameslairdsmith), [@jamesMo84](https://github.com/jamesMo84), [@juliangkr](https://github.com/juliangkr), [@juliasilge](https://github.com/juliasilge), [@mattwarkentin](https://github.com/mattwarkentin), [@mwilson19](https://github.com/mwilson19), [@norhther](https://github.com/norhther), [@thisisdaryn](https://github.com/thisisdaryn), and [@topepo](https://github.com/topepo).

