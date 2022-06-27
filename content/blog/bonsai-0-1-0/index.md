---
output: hugodown::hugo_document

slug: bonsai-0-1-0
title: bonsai 0.1.0
date: 2022-06-24
author: Simon Couch
description: >
    A new parsnip extension package for tree-based models is now on CRAN.

photo:
  url: https://unsplash.com/photos/-OBffuUekfQ
  author: 五玄土

categories: [package] 
tags: [tidymodels, parsnip, bonsai]
rmd_hash: a9524374c2e30abc

---

We're super stoked to announce the first release of the [bonsai](https://bonsai.tidymodels.org/) package on CRAN! bonsai is a [parsnip](https://parsnip.tidymodels.org/) extension package for tree-based models.

You can install it from CRAN with:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://rdrr.io/r/utils/install.packages.html'>install.packages</a></span><span class='o'>(</span><span class='s'>"bonsai"</span><span class='o'>)</span></code></pre>

</div>

Without extension packages, the parsnip package already supports fitting decision trees, random forests, and boosted trees. The bonsai package introduces support for two additional engines that implement variants of these algorithms:

-   [partykit](https://CRAN.R-project.org/package=partykit): conditional inference trees via [`decision_tree()`](https://parsnip.tidymodels.org/reference/decision_tree.html) and conditional random forests via [`rand_forest()`](https://parsnip.tidymodels.org/reference/rand_forest.html)
-   [LightGBM](https://CRAN.R-project.org/package=lightgbm): optimized gradient boosted trees via [`boost_tree()`](https://parsnip.tidymodels.org/reference/boost_tree.html)

To illustrate the advantages that these new engines have to offer, we'll fit a few models and explore their output. First, loading bonsai as well as the rest of the tidymodels core packages:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://bonsai.tidymodels.org/'>bonsai</a></span><span class='o'>)</span>
<span class='c'>#&gt; Loading required package: parsnip</span>

<span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://tidymodels.tidymodels.org'>tidymodels</a></span><span class='o'>)</span>
<span class='c'>#&gt; ── <span style='font-weight: bold;'>Attaching packages</span> ────────────────────────────────────── tidymodels 0.2.0 ──</span>
<span class='c'>#&gt; <span style='color: #00BB00;'>✔</span> <span style='color: #0000BB;'>broom       </span> 0.8.0          <span style='color: #00BB00;'>✔</span> <span style='color: #0000BB;'>rsample     </span> 0.1.1     </span>
<span class='c'>#&gt; <span style='color: #00BB00;'>✔</span> <span style='color: #0000BB;'>dials       </span> 1.0.0          <span style='color: #00BB00;'>✔</span> <span style='color: #0000BB;'>tibble      </span> 3.1.7     </span>
<span class='c'>#&gt; <span style='color: #00BB00;'>✔</span> <span style='color: #0000BB;'>dplyr       </span> 1.0.9          <span style='color: #00BB00;'>✔</span> <span style='color: #0000BB;'>tidyr       </span> 1.2.0     </span>
<span class='c'>#&gt; <span style='color: #00BB00;'>✔</span> <span style='color: #0000BB;'>ggplot2     </span> 3.3.6          <span style='color: #00BB00;'>✔</span> <span style='color: #0000BB;'>tune        </span> 0.2.0     </span>
<span class='c'>#&gt; <span style='color: #00BB00;'>✔</span> <span style='color: #0000BB;'>infer       </span> 1.0.2          <span style='color: #00BB00;'>✔</span> <span style='color: #0000BB;'>workflows   </span> 0.2.6     </span>
<span class='c'>#&gt; <span style='color: #00BB00;'>✔</span> <span style='color: #0000BB;'>modeldata   </span> 0.1.1.<span style='color: #BB0000;'>9000</span>     <span style='color: #00BB00;'>✔</span> <span style='color: #0000BB;'>workflowsets</span> 0.2.1     </span>
<span class='c'>#&gt; <span style='color: #00BB00;'>✔</span> <span style='color: #0000BB;'>purrr       </span> 0.3.4          <span style='color: #00BB00;'>✔</span> <span style='color: #0000BB;'>yardstick   </span> 1.0.0     </span>
<span class='c'>#&gt; <span style='color: #00BB00;'>✔</span> <span style='color: #0000BB;'>recipes     </span> 0.2.0</span>
<span class='c'>#&gt; ── <span style='font-weight: bold;'>Conflicts</span> ───────────────────────────────────────── tidymodels_conflicts() ──</span>
<span class='c'>#&gt; <span style='color: #BB0000;'>✖</span> <span style='color: #0000BB;'>purrr</span>::<span style='color: #00BB00;'>discard()</span> masks <span style='color: #0000BB;'>scales</span>::discard()</span>
<span class='c'>#&gt; <span style='color: #BB0000;'>✖</span> <span style='color: #0000BB;'>dplyr</span>::<span style='color: #00BB00;'>filter()</span>  masks <span style='color: #0000BB;'>stats</span>::filter()</span>
<span class='c'>#&gt; <span style='color: #BB0000;'>✖</span> <span style='color: #0000BB;'>dplyr</span>::<span style='color: #00BB00;'>lag()</span>     masks <span style='color: #0000BB;'>stats</span>::lag()</span>
<span class='c'>#&gt; <span style='color: #BB0000;'>✖</span> <span style='color: #0000BB;'>recipes</span>::<span style='color: #00BB00;'>step()</span>  masks <span style='color: #0000BB;'>stats</span>::step()</span>
<span class='c'>#&gt; <span style='color: #0000BB;'>•</span> Search for functions across packages at <span style='color: #00BB00;'>https://www.tidymodels.org/find/</span></span></code></pre>

</div>

We'll use a [dataset](https://allisonhorst.github.io/palmerpenguins/) containing measurements on 3 different species of penguins as an example. Loading that data in and checking it out:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://rdrr.io/r/utils/data.html'>data</a></span><span class='o'>(</span><span class='nv'>penguins</span>, package <span class='o'>=</span> <span class='s'>"modeldata"</span><span class='o'>)</span>

<span class='nf'><a href='https://rdrr.io/r/utils/str.html'>str</a></span><span class='o'>(</span><span class='nv'>penguins</span><span class='o'>)</span>
<span class='c'>#&gt; tibble [344 × 7] (S3: tbl_df/tbl/data.frame)</span>
<span class='c'>#&gt;  $ species          : Factor w/ 3 levels "Adelie","Chinstrap",..: 1 1 1 1 1 1 1 1 1 1 ...</span>
<span class='c'>#&gt;  $ island           : Factor w/ 3 levels "Biscoe","Dream",..: 3 3 3 3 3 3 3 3 3 3 ...</span>
<span class='c'>#&gt;  $ bill_length_mm   : num [1:344] 39.1 39.5 40.3 NA 36.7 39.3 38.9 39.2 34.1 42 ...</span>
<span class='c'>#&gt;  $ bill_depth_mm    : num [1:344] 18.7 17.4 18 NA 19.3 20.6 17.8 19.6 18.1 20.2 ...</span>
<span class='c'>#&gt;  $ flipper_length_mm: int [1:344] 181 186 195 NA 193 190 181 195 193 190 ...</span>
<span class='c'>#&gt;  $ body_mass_g      : int [1:344] 3750 3800 3250 NA 3450 3650 3625 4675 3475 4250 ...</span>
<span class='c'>#&gt;  $ sex              : Factor w/ 2 levels "female","male": 2 1 1 NA 1 2 1 2 NA NA ...</span></code></pre>

</div>

Specifically, we'll make use of flipper length and home island to model a penguin's species:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'>ggplot</span><span class='o'>(</span><span class='nv'>penguins</span><span class='o'>)</span> <span class='o'>+</span>
  <span class='nf'>aes</span><span class='o'>(</span>x <span class='o'>=</span> <span class='nv'>island</span>, y <span class='o'>=</span> <span class='nv'>flipper_length_mm</span>, col <span class='o'>=</span> <span class='nv'>species</span><span class='o'>)</span> <span class='o'>+</span>
  <span class='nf'>geom_jitter</span><span class='o'>(</span>width <span class='o'>=</span> <span class='m'>.2</span><span class='o'>)</span>
</code></pre>
<img src="figs/penguin-plot-1.png" width="700px" style="display: block; margin: auto;" />

</div>

Looking at this plot, you might begin to imagine your own simple set of binary splits for guessing which species a penguin might be given its home island and flipper length. Given that this small set of predictors almost completely separates our outcome with only a few splits, a relatively simple tree should serve our purposes just fine.

## Decision Trees

bonsai introduces support for fitting decision trees with partykit, which implements a variety of decision trees called conditional inference trees (CITs).

CITs differ from implementations of decision trees available elsewhere in the tidymodels in the criteria used to generate splits. The details of how these criteria differ are outside of the scope of this post.[^1] Practically, though, CITs offer a few notable advantages over CART- and C5.0-based decision trees:

-   **Overfitting**: Common implementations of decision trees are notoriously prone to overfitting, and require several well-chosen penalization (i.e. cost-complexity) and early stopping (e.g. pruning, max depth) hyperparameters to fit a model that will perform well when predicting on new observations. "Out-of-the-box," CITs are not as prone to these same issues and do not accept a penalization parameter at all.
-   **Selection bias**: Common implementations of decision trees are biased towards selecting variables with many possible split points or missing values. CITs are natively not prone to the first issue, and many popular implementations address the second vulnerability.

To define a conditional inference tree model specification, just set the modeling engine to `"partykit"` when creating a decision tree. Fitting to the penguins data, then:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>dt_mod</span> <span class='o'>&lt;-</span>
  <span class='nf'><a href='https://parsnip.tidymodels.org/reference/decision_tree.html'>decision_tree</a></span><span class='o'>(</span><span class='o'>)</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span>
  <span class='nf'><a href='https://parsnip.tidymodels.org/reference/set_engine.html'>set_engine</a></span><span class='o'>(</span>engine <span class='o'>=</span> <span class='s'>"partykit"</span><span class='o'>)</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span>
  <span class='nf'><a href='https://parsnip.tidymodels.org/reference/set_args.html'>set_mode</a></span><span class='o'>(</span>mode <span class='o'>=</span> <span class='s'>"classification"</span><span class='o'>)</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span>
  <span class='nf'><a href='https://generics.r-lib.org/reference/fit.html'>fit</a></span><span class='o'>(</span>
    formula <span class='o'>=</span> <span class='nv'>species</span> <span class='o'>~</span> <span class='nv'>flipper_length_mm</span> <span class='o'>+</span> <span class='nv'>island</span>, 
    data <span class='o'>=</span> <span class='nv'>penguins</span>
  <span class='o'>)</span>

<span class='nv'>dt_mod</span>
<span class='c'>#&gt; parsnip model object</span>
<span class='c'>#&gt; </span>
<span class='c'>#&gt; </span>
<span class='c'>#&gt; Model formula:</span>
<span class='c'>#&gt; species ~ flipper_length_mm + island</span>
<span class='c'>#&gt; </span>
<span class='c'>#&gt; Fitted party:</span>
<span class='c'>#&gt; [1] root</span>
<span class='c'>#&gt; |   [2] island in Biscoe</span>
<span class='c'>#&gt; |   |   [3] flipper_length_mm &lt;= 203</span>
<span class='c'>#&gt; |   |   |   [4] flipper_length_mm &lt;= 196: Adelie (n = 38, err = 0.0%)</span>
<span class='c'>#&gt; |   |   |   [5] flipper_length_mm &gt; 196: Adelie (n = 7, err = 14.3%)</span>
<span class='c'>#&gt; |   |   [6] flipper_length_mm &gt; 203: Gentoo (n = 123, err = 0.0%)</span>
<span class='c'>#&gt; |   [7] island in Dream, Torgersen</span>
<span class='c'>#&gt; |   |   [8] island in Dream</span>
<span class='c'>#&gt; |   |   |   [9] flipper_length_mm &lt;= 192: Adelie (n = 59, err = 33.9%)</span>
<span class='c'>#&gt; |   |   |   [10] flipper_length_mm &gt; 192: Chinstrap (n = 65, err = 26.2%)</span>
<span class='c'>#&gt; |   |   [11] island in Torgersen: Adelie (n = 52, err = 0.0%)</span>
<span class='c'>#&gt; </span>
<span class='c'>#&gt; Number of inner nodes:    5</span>
<span class='c'>#&gt; Number of terminal nodes: 6</span></code></pre>

</div>

Do any of these splits line up with your intuition? This tree results in only 6 terminal nodes and describes the structure shown in the above plot quite well.

Read more about this implementation of decision trees in [`?details_decision_tree_partykit`](https://parsnip.tidymodels.org/reference/details_decision_tree_partykit.html).

## Random Forests

One generalization of a decision tree is a *random forest*, which fits a large number of decision trees, each independently of the others. The fitted random forest model combines predictions from the individual decision trees to generate its predictions.

bonsai introduces support for random forests using the `partykit` engine, which implements an algorithm called a *conditional random forest*. Conditional random forests are a type of random forest that uses conditional inference trees (like the one we fit above!) for its constituent decision trees.

To fit a conditional random forest with partykit, our code looks pretty similar to that which we we needed to fit a conditional inference tree. Just switch out [`decision_tree()`](https://parsnip.tidymodels.org/reference/decision_tree.html) with [`rand_forest()`](https://parsnip.tidymodels.org/reference/rand_forest.html) and remember to keep the engine set as `"partykit"`.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>rf_mod</span> <span class='o'>&lt;-</span> 
  <span class='nf'><a href='https://parsnip.tidymodels.org/reference/rand_forest.html'>rand_forest</a></span><span class='o'>(</span><span class='o'>)</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span>
  <span class='nf'><a href='https://parsnip.tidymodels.org/reference/set_engine.html'>set_engine</a></span><span class='o'>(</span>engine <span class='o'>=</span> <span class='s'>"partykit"</span><span class='o'>)</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span>
  <span class='nf'><a href='https://parsnip.tidymodels.org/reference/set_args.html'>set_mode</a></span><span class='o'>(</span>mode <span class='o'>=</span> <span class='s'>"classification"</span><span class='o'>)</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span>
  <span class='nf'><a href='https://generics.r-lib.org/reference/fit.html'>fit</a></span><span class='o'>(</span>
    formula <span class='o'>=</span> <span class='nv'>species</span> <span class='o'>~</span> <span class='nv'>flipper_length_mm</span> <span class='o'>+</span> <span class='nv'>island</span>, 
    data <span class='o'>=</span> <span class='nv'>penguins</span>
  <span class='o'>)</span></code></pre>

</div>

Read more about this implementation of random forests in [`?details_rand_forest_partykit`](https://parsnip.tidymodels.org/reference/details_rand_forest_partykit.html).

## Boosted Trees

Another generalization of a decision tree is a series of decision trees where *each tree depends on the results of previous trees*---this is called a *boosted tree*. bonsai implements an additional parsnip engine for this model type called `"lightgbm"`. While fitting boosted trees is quite computationally intensive, especially with high-dimensional data, LightGBM provides an implementation of a highly efficient variant of the algorithm.

To make use of it, start out with a `boost_tree` model spec and set `engine = "lightgbm"`:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>bt_mod</span> <span class='o'>&lt;-</span>
  <span class='nf'><a href='https://parsnip.tidymodels.org/reference/boost_tree.html'>boost_tree</a></span><span class='o'>(</span><span class='o'>)</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span>
  <span class='nf'><a href='https://parsnip.tidymodels.org/reference/set_engine.html'>set_engine</a></span><span class='o'>(</span>engine <span class='o'>=</span> <span class='s'>"lightgbm"</span><span class='o'>)</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span>
  <span class='nf'><a href='https://parsnip.tidymodels.org/reference/set_args.html'>set_mode</a></span><span class='o'>(</span>mode <span class='o'>=</span> <span class='s'>"classification"</span><span class='o'>)</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span>
  <span class='nf'><a href='https://generics.r-lib.org/reference/fit.html'>fit</a></span><span class='o'>(</span>
    formula <span class='o'>=</span> <span class='nv'>species</span> <span class='o'>~</span> <span class='nv'>flipper_length_mm</span> <span class='o'>+</span> <span class='nv'>island</span>, 
    data <span class='o'>=</span> <span class='nv'>penguins</span>
  <span class='o'>)</span></code></pre>

</div>

The main benefit of using LightGBM is its computational efficiency: as the number of observations in training data increases, we can observe an increasingly substantial decrease in time-to-fit when using the LightGBM engine as compared to other implementations of boosted trees, like XGBoost.

To show this, we'll use the `sim_regression()` function from modeldata to simulate increasingly large datasets that we can fit models to. For example, generating a dataset with 10 observations and 20 numeric predictors:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'>sim_regression</span><span class='o'>(</span>num_samples <span class='o'>=</span> <span class='m'>10</span><span class='o'>)</span>
<span class='c'>#&gt; <span style='color: #555555;'># A tibble: 10 × 21</span></span>
<span class='c'>#&gt;    outcome predictor_01 predictor_02 predictor_03 predictor_04 predictor_05</span>
<span class='c'>#&gt;      <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>        <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>        <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>        <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>        <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>        <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span>
<span class='c'>#&gt; <span style='color: #555555;'> 1</span>  31.2        -<span style='color: #BB0000;'>0.352</span>         2.52         2.43        -<span style='color: #BB0000;'>3.45</span>         5.52 </span>
<span class='c'>#&gt; <span style='color: #555555;'> 2</span>  -<span style='color: #BB0000;'>0.635</span>      -<span style='color: #BB0000;'>4.26</span>          1.99         1.32        -<span style='color: #BB0000;'>1.38</span>        -<span style='color: #BB0000;'>1.37</span> </span>
<span class='c'>#&gt; <span style='color: #555555;'> 3</span>  27.7        -<span style='color: #BB0000;'>1.10</span>          2.02        -<span style='color: #BB0000;'>2.18</span>         5.85        -<span style='color: #BB0000;'>1.01</span> </span>
<span class='c'>#&gt; <span style='color: #555555;'> 4</span>  13.4        -<span style='color: #BB0000;'>1.76</span>         -<span style='color: #BB0000;'>1.12</span>        -<span style='color: #BB0000;'>3.11</span>        -<span style='color: #BB0000;'>0.122</span>        2.05 </span>
<span class='c'>#&gt; <span style='color: #555555;'> 5</span>   0.815      -<span style='color: #BB0000;'>1.73</span>          0.505        0.163        2.31        -<span style='color: #BB0000;'>6.38</span> </span>
<span class='c'>#&gt; <span style='color: #555555;'> 6</span>  39.7        -<span style='color: #BB0000;'>0.099</span><span style='color: #BB0000; text-decoration: underline;'>4</span>        0.666        3.46         4.05         2.61 </span>
<span class='c'>#&gt; <span style='color: #555555;'> 7</span>  33.4        -<span style='color: #BB0000;'>5.49</span>         -<span style='color: #BB0000;'>7.15</span>        -<span style='color: #BB0000;'>1.57</span>        -<span style='color: #BB0000;'>4.27</span>         1.61 </span>
<span class='c'>#&gt; <span style='color: #555555;'> 8</span>  18.0        -<span style='color: #BB0000;'>2.07</span>         -<span style='color: #BB0000;'>0.245</span>        0.620        1.28         1.94 </span>
<span class='c'>#&gt; <span style='color: #555555;'> 9</span>  25.9        -<span style='color: #BB0000;'>1.57</span>         -<span style='color: #BB0000;'>3.26</span>         6.20         1.50         0.164</span>
<span class='c'>#&gt; <span style='color: #555555;'>10</span>  12.0        -<span style='color: #BB0000;'>1.77</span>         -<span style='color: #BB0000;'>1.70</span>         1.70         1.35        -<span style='color: #BB0000;'>2.32</span> </span>
<span class='c'>#&gt; <span style='color: #555555;'># … with 15 more variables: predictor_06 &lt;dbl&gt;, predictor_07 &lt;dbl&gt;,</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>#   predictor_08 &lt;dbl&gt;, predictor_09 &lt;dbl&gt;, predictor_10 &lt;dbl&gt;,</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>#   predictor_11 &lt;dbl&gt;, predictor_12 &lt;dbl&gt;, predictor_13 &lt;dbl&gt;,</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>#   predictor_14 &lt;dbl&gt;, predictor_15 &lt;dbl&gt;, predictor_16 &lt;dbl&gt;,</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>#   predictor_17 &lt;dbl&gt;, predictor_18 &lt;dbl&gt;, predictor_19 &lt;dbl&gt;,</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>#   predictor_20 &lt;dbl&gt;</span></span></code></pre>

</div>

Now, fitting boosted trees on increasingly large datasets with XGBoost and LightGBM and observing time-to-fit:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='c'># given an engine and nrow(training_data), return the time to fit</span>
<span class='nv'>time_boost_fit</span> <span class='o'>&lt;-</span> <span class='kr'>function</span><span class='o'>(</span><span class='nv'>engine</span>, <span class='nv'>n</span><span class='o'>)</span> <span class='o'>&#123;</span>
  <span class='nv'>time</span> <span class='o'>&lt;-</span> 
    <span class='nf'><a href='https://rdrr.io/r/base/system.time.html'>system.time</a></span><span class='o'>(</span><span class='o'>&#123;</span>
      <span class='nf'><a href='https://parsnip.tidymodels.org/reference/boost_tree.html'>boost_tree</a></span><span class='o'>(</span><span class='o'>)</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span>
      <span class='nf'><a href='https://parsnip.tidymodels.org/reference/set_engine.html'>set_engine</a></span><span class='o'>(</span>engine <span class='o'>=</span> <span class='nv'>engine</span><span class='o'>)</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span>
      <span class='nf'><a href='https://parsnip.tidymodels.org/reference/set_args.html'>set_mode</a></span><span class='o'>(</span>mode <span class='o'>=</span> <span class='s'>"regression"</span><span class='o'>)</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span>
      <span class='nf'><a href='https://generics.r-lib.org/reference/fit.html'>fit</a></span><span class='o'>(</span>
        formula <span class='o'>=</span> <span class='nv'>outcome</span> <span class='o'>~</span> <span class='nv'>.</span>, 
        data <span class='o'>=</span> <span class='nf'>sim_regression</span><span class='o'>(</span>num_samples <span class='o'>=</span> <span class='nv'>n</span><span class='o'>)</span>
      <span class='o'>)</span>
    <span class='o'>&#125;</span><span class='o'>)</span>
  
  <span class='nf'>tibble</span><span class='o'>(</span>
    engine <span class='o'>=</span> <span class='nv'>engine</span>,
    n <span class='o'>=</span> <span class='nv'>n</span>,
    time_to_fit <span class='o'>=</span> <span class='nv'>time</span><span class='o'>[[</span><span class='s'>"elapsed"</span><span class='o'>]</span><span class='o'>]</span>
  <span class='o'>)</span>
<span class='o'>&#125;</span>

<span class='c'># setup engine and n_samples combinations</span>
<span class='nv'>engines</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/rep.html'>rep</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span>XGBoost <span class='o'>=</span> <span class='s'>"xgboost"</span>, LightGBM <span class='o'>=</span> <span class='s'>"lightgbm"</span><span class='o'>)</span>, each <span class='o'>=</span> <span class='m'>11</span><span class='o'>)</span>
<span class='nv'>n_samples</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/Round.html'>round</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/rep.html'>rep</a></span><span class='o'>(</span><span class='m'>10</span> <span class='o'>*</span> <span class='m'>10</span><span class='o'>^</span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/seq.html'>seq</a></span><span class='o'>(</span><span class='m'>2</span>, <span class='m'>4.5</span>, <span class='m'>.25</span><span class='o'>)</span><span class='o'>)</span>, times  <span class='o'>=</span> <span class='m'>2</span><span class='o'>)</span><span class='o'>)</span>

<span class='c'># apply the function over each combination</span>
<span class='nv'>fit_times</span> <span class='o'>&lt;-</span> 
  <span class='nf'>map2_dfr</span><span class='o'>(</span>
    <span class='nv'>engines</span>,
    <span class='nv'>n_samples</span>,
    <span class='nv'>time_boost_fit</span>
  <span class='o'>)</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span>
  <span class='nf'>mutate</span><span class='o'>(</span>
    engine <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/factor.html'>factor</a></span><span class='o'>(</span><span class='nv'>engine</span>, levels <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"xgboost"</span>, <span class='s'>"lightgbm"</span><span class='o'>)</span><span class='o'>)</span>
  <span class='o'>)</span>

<span class='c'># visualize results</span>
<span class='nf'>ggplot</span><span class='o'>(</span><span class='nv'>fit_times</span><span class='o'>)</span> <span class='o'>+</span>
  <span class='nf'>aes</span><span class='o'>(</span>x <span class='o'>=</span> <span class='nv'>n</span>, y <span class='o'>=</span> <span class='nv'>time_to_fit</span>, col <span class='o'>=</span> <span class='nv'>engine</span><span class='o'>)</span> <span class='o'>+</span>
  <span class='nf'>geom_line</span><span class='o'>(</span><span class='o'>)</span> <span class='o'>+</span>
  <span class='nf'>scale_x_log10</span><span class='o'>(</span><span class='o'>)</span>
</code></pre>
<img src="figs/boost-comparison-1.png" width="700px" style="display: block; margin: auto;" />

</div>

As we can see, the decrease in time-to-fit when using LightGBM as opposed to XGBoost becomes more notable as the number of rows in the training data increases.

Read more about this implementation of boosted trees in [`?details_boost_tree_lightgbm`](https://parsnip.tidymodels.org/reference/details_boost_tree_lightgbm.html).

## Other Notes

This package is based off of [the treesnip package](https://github.com/curso-r/treesnip) by Daniel Falbel, Athos Damiani, and Roel M. Hogervorst. Users of that package will note that we have not included support for [the catboost package](https://github.com/catboost/catboost). Unfortunately, the catboost R package is not on CRAN so we're not able to add support for the package for now. We'll be keeping an eye on discussions in that development community and plan to support the package upon its release to CRAN!

Each of these model specs and engines have several arguments and tuning parameters that affect user experience and results greatly. We recommend reading about each of these parameters and tuning them when you find them relevant for your modeling use case.

## Acknowledgements

A big thanks to Daniel Falbel, Athos Damiani, and Roel M. Hogervorst for their work on [the treesnip package](https://github.com/curso-r/treesnip), on which this package is based. We've listed the treesnip authors as co-authors of bonsai in recognition of their help in laying the foundations for this project.

We're also grateful for the wonderful package hex sticker by Amanda Petri!

Finally, thank you to those who have tested and provided feedback on the developmental versions of the package over the last couple months.

[^1]: For those interested, the [original paper](https://doi.org/10.1198/106186006X133933) introducing conditional inference trees describes and motivates these differences well.

