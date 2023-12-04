---
output: hugodown::hugo_document

slug: tidymodels-errors-q4
title: "Three ways errors are about to get better in tidymodels"
date: 2023-11-10
author: Simon Couch
description: >
    The tidymodels team's biannual spring cleaning gave us a chance to revisit 
    the way we raise some error messages.

photo:
  url: https://unsplash.com/photos/vYcH7pI6v1Q
  author: Nagesh Badu

categories: [programming] 
tags: [tidymodels, package maintenance, tune, parsnip]
rmd_hash: 247c47aa9b60a376

---

Twice a year, the tidymodels team comes together for "[spring cleaning](https://www.tidyverse.org/blog/2023/06/spring-cleaning-2023/)", a week-long project devoted to package maintenance. Ahead of the week, we come up with a list of maintenance tasks that we'd like to see consistently implemented across our packages. Many of these tasks can be completed by running one usethis function, while others are much more involved, like issue triage.[^1] In tidymodels, triaging issues in our core packages helps us to better understand common ways that users struggle to wrap their heads around an API choice we've made or find the information they need. So, among other things, refinements to the wording of our error messages is a common output of our spring cleanings. This blog post will call out three kinds of changes to our erroring that came out of this spring cleaning:

-   Improving existing errors: [The outcome went missing](#outcome)
-   Do something where we once did nothing: [Predicting with things that can't predict](#predict)
-   Make a place and point to it: [Model formulas](#model)

To demonstrate, we'll walk through some examples using the tidymodels packages:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://tidymodels.tidymodels.org'>tidymodels</a></span><span class='o'>)</span></span><span><span class='c'>#&gt; ── <span style='font-weight: bold;'>Attaching packages</span> ──────────────────────────── tidymodels 1.1.1 ──</span></span><span><span class='c'>#&gt; <span style='color: #00BB00;'>✔</span> <span style='color: #0000BB;'>broom       </span> 1.0.5     <span style='color: #00BB00;'>✔</span> <span style='color: #0000BB;'>recipes     </span> 1.0.8</span></span>
<span><span class='c'>#&gt; <span style='color: #00BB00;'>✔</span> <span style='color: #0000BB;'>dials       </span> 1.2.0     <span style='color: #00BB00;'>✔</span> <span style='color: #0000BB;'>rsample     </span> 1.2.0</span></span>
<span><span class='c'>#&gt; <span style='color: #00BB00;'>✔</span> <span style='color: #0000BB;'>dplyr       </span> 1.1.2     <span style='color: #00BB00;'>✔</span> <span style='color: #0000BB;'>tibble      </span> 3.2.1</span></span>
<span><span class='c'>#&gt; <span style='color: #00BB00;'>✔</span> <span style='color: #0000BB;'>ggplot2     </span> 3.4.4     <span style='color: #00BB00;'>✔</span> <span style='color: #0000BB;'>tidyr       </span> 1.3.0</span></span>
<span><span class='c'>#&gt; <span style='color: #00BB00;'>✔</span> <span style='color: #0000BB;'>infer       </span> 1.0.5     <span style='color: #00BB00;'>✔</span> <span style='color: #0000BB;'>tune        </span> 1.1.2</span></span>
<span><span class='c'>#&gt; <span style='color: #00BB00;'>✔</span> <span style='color: #0000BB;'>modeldata   </span> 1.2.0     <span style='color: #00BB00;'>✔</span> <span style='color: #0000BB;'>workflows   </span> 1.1.3</span></span>
<span><span class='c'>#&gt; <span style='color: #00BB00;'>✔</span> <span style='color: #0000BB;'>parsnip     </span> 1.1.1     <span style='color: #00BB00;'>✔</span> <span style='color: #0000BB;'>workflowsets</span> 1.0.1</span></span>
<span><span class='c'>#&gt; <span style='color: #00BB00;'>✔</span> <span style='color: #0000BB;'>purrr       </span> 1.0.2     <span style='color: #00BB00;'>✔</span> <span style='color: #0000BB;'>yardstick   </span> 1.2.0</span></span><span><span class='c'>#&gt; ── <span style='font-weight: bold;'>Conflicts</span> ─────────────────────────────── tidymodels_conflicts() ──</span></span>
<span><span class='c'>#&gt; <span style='color: #BB0000;'>✖</span> <span style='color: #0000BB;'>purrr</span>::<span style='color: #00BB00;'>discard()</span> masks <span style='color: #0000BB;'>scales</span>::discard()</span></span>
<span><span class='c'>#&gt; <span style='color: #BB0000;'>✖</span> <span style='color: #0000BB;'>dplyr</span>::<span style='color: #00BB00;'>filter()</span>  masks <span style='color: #0000BB;'>stats</span>::filter()</span></span>
<span><span class='c'>#&gt; <span style='color: #BB0000;'>✖</span> <span style='color: #0000BB;'>dplyr</span>::<span style='color: #00BB00;'>lag()</span>     masks <span style='color: #0000BB;'>stats</span>::lag()</span></span>
<span><span class='c'>#&gt; <span style='color: #BB0000;'>✖</span> <span style='color: #0000BB;'>recipes</span>::<span style='color: #00BB00;'>step()</span>  masks <span style='color: #0000BB;'>stats</span>::step()</span></span>
<span><span class='c'>#&gt; <span style='color: #0000BB;'>•</span> Use suppressPackageStartupMessages() to eliminate package startup messages</span></span></code></pre>

</div>

Note that my installed versions include the current dev version of a few tidymodels packages. You can install those versions with:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'>pak</span><span class='nf'>::</span><span class='nf'><a href='https://pak.r-lib.org/reference/pak.html'>pak</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/paste.html'>paste0</a></span><span class='o'>(</span><span class='s'>"tidymodels/"</span>, <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"tune"</span>, <span class='s'>"parsnip"</span>, <span class='s'>"recipes"</span><span class='o'>)</span><span class='o'>)</span><span class='o'>)</span></span></code></pre>

</div>

## The outcome went missing 👻

The tidymodels packages focus on *supervised* machine learning problems, predicting the value of an outcome using predictors.[^2] For example, in the code:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>linear_spec</span> <span class='o'>&lt;-</span> <span class='nf'>linear_reg</span><span class='o'>(</span><span class='o'>)</span></span>
<span></span>
<span><span class='nv'>linear_fit</span> <span class='o'>&lt;-</span> <span class='nf'>fit</span><span class='o'>(</span><span class='nv'>linear_spec</span>, <span class='nv'>mpg</span> <span class='o'>~</span> <span class='nv'>hp</span>, <span class='nv'>mtcars</span><span class='o'>)</span></span></code></pre>

</div>

The `mpg` variable is the outcome. There are many ways that an analyst may mistakenly fail to pass an outcome. In the most straightforward case, they might omit the outcome on the LHS of the formula:

``` r
fit(linear_spec, ~ hp, mtcars)
#> Error in lm.fit(x, y, offset = offset, singular.ok = singular.ok, ...) : 
#>   incompatible dimensions
```

In this case, parsnip used to defer to the modeling engine to raise an error, which may or may not be informative.

There are many less obvious ways an analyst may mistakenly supply no outcome variable. For example, try spotting the issue in the following code, defining a recipe to perform principal component analysis (PCA) on the numeric variables in the data before fitting the model:

``` r
mtcars_rec <-
  recipe(mpg ~ ., mtcars) %>%
  step_pca(all_numeric())

workflow(mtcars_rec, linear_spec) %>% fit(mtcars)
#> Error: object '.' not found
```

A head-scratcher! To help diagnose what's happening here, we could first try seeing what data is actually being passed to the model.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>mtcars_rec_trained</span> <span class='o'>&lt;-</span></span>
<span>  <span class='nv'>mtcars_rec</span> <span class='o'>%&gt;%</span> </span>
<span>  <span class='nf'>prep</span><span class='o'>(</span><span class='nv'>mtcars</span><span class='o'>)</span> </span>
<span></span>
<span><span class='nv'>mtcars_rec_trained</span> <span class='o'>%&gt;%</span> <span class='nf'>bake</span><span class='o'>(</span><span class='kc'>NULL</span><span class='o'>)</span></span><span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 32 × 5</span></span></span>
<span><span class='c'>#&gt;      PC1   PC2    PC3     PC4    PC5</span></span>
<span><span class='c'>#&gt;    <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>  <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>   <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>  <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 1</span> -<span style='color: #BB0000;'>195.</span>  12.8 -<span style='color: #BB0000;'>11.4</span>  -<span style='color: #BB0000;'>0.016</span><span style='color: #BB0000; text-decoration: underline;'>4</span> -<span style='color: #BB0000;'>2.17</span> </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 2</span> -<span style='color: #BB0000;'>195.</span>  12.9 -<span style='color: #BB0000;'>11.7</span>   0.479  -<span style='color: #BB0000;'>2.11</span> </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 3</span> -<span style='color: #BB0000;'>142.</span>  25.9 -<span style='color: #BB0000;'>16.0</span>   1.34    1.18 </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 4</span> -<span style='color: #BB0000;'>279.</span> -<span style='color: #BB0000;'>38.3</span> -<span style='color: #BB0000;'>14.0</span>  -<span style='color: #BB0000;'>0.157</span>   0.817</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 5</span> -<span style='color: #BB0000;'>399.</span> -<span style='color: #BB0000;'>37.3</span>  -<span style='color: #BB0000;'>1.38</span> -<span style='color: #BB0000;'>2.56</span>    0.444</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 6</span> -<span style='color: #BB0000;'>248.</span> -<span style='color: #BB0000;'>25.6</span> -<span style='color: #BB0000;'>12.2</span>   3.01    1.08 </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 7</span> -<span style='color: #BB0000;'>435.</span>  20.9  13.9  -<span style='color: #BB0000;'>0.801</span>   0.916</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 8</span> -<span style='color: #BB0000;'>160.</span> -<span style='color: #BB0000;'>20.0</span> -<span style='color: #BB0000;'>23.3</span>   1.06   -<span style='color: #BB0000;'>0.787</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 9</span> -<span style='color: #BB0000;'>172.</span>  10.8 -<span style='color: #BB0000;'>18.3</span>   4.40    0.836</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>10</span> -<span style='color: #BB0000;'>209.</span>  19.7  -<span style='color: #BB0000;'>8.94</span>  2.58   -<span style='color: #BB0000;'>1.33</span> </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># ℹ 22 more rows</span></span></span></code></pre>

</div>

Mmm. What happened to `mpg`? We mistakenly told `step_pca()` to perform PCA on *all* of the numeric variables, not just the numeric *predictors*! As a result, it incorporated `mpg` into the principal components, removing each of the original numeric variables after the fact. Rewriting using the correct tidyselect specification `all_numeric_predictors()`:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>mtcars_rec_new</span> <span class='o'>&lt;-</span> </span>
<span>  <span class='nf'>recipe</span><span class='o'>(</span><span class='nv'>mpg</span> <span class='o'>~</span> <span class='nv'>.</span>, <span class='nv'>mtcars</span><span class='o'>)</span> <span class='o'>%&gt;%</span></span>
<span>  <span class='nf'>step_pca</span><span class='o'>(</span><span class='nf'>all_numeric_predictors</span><span class='o'>(</span><span class='o'>)</span><span class='o'>)</span></span>
<span></span>
<span><span class='nf'>workflow</span><span class='o'>(</span><span class='nv'>mtcars_rec_new</span>, <span class='nv'>linear_spec</span><span class='o'>)</span> <span class='o'>%&gt;%</span> <span class='nf'>fit</span><span class='o'>(</span><span class='nv'>mtcars</span><span class='o'>)</span></span><span><span class='c'>#&gt; ══ Workflow [trained] ════════════════════════════════════════════════</span></span>
<span><span class='c'>#&gt; <span style='font-style: italic;'>Preprocessor:</span> Recipe</span></span>
<span><span class='c'>#&gt; <span style='font-style: italic;'>Model:</span> linear_reg()</span></span>
<span><span class='c'>#&gt; </span></span>
<span><span class='c'>#&gt; ── Preprocessor ──────────────────────────────────────────────────────</span></span>
<span><span class='c'>#&gt; 1 Recipe Step</span></span>
<span><span class='c'>#&gt; </span></span>
<span><span class='c'>#&gt; • step_pca()</span></span>
<span><span class='c'>#&gt; </span></span>
<span><span class='c'>#&gt; ── Model ─────────────────────────────────────────────────────────────</span></span>
<span><span class='c'>#&gt; </span></span>
<span><span class='c'>#&gt; Call:</span></span>
<span><span class='c'>#&gt; stats::lm(formula = ..y ~ ., data = data)</span></span>
<span><span class='c'>#&gt; </span></span>
<span><span class='c'>#&gt; Coefficients:</span></span>
<span><span class='c'>#&gt; (Intercept)          PC1          PC2          PC3          PC4  </span></span>
<span><span class='c'>#&gt;    43.39293      0.07609     -0.05266      0.57892      0.94890  </span></span>
<span><span class='c'>#&gt;         PC5  </span></span>
<span><span class='c'>#&gt;    -1.72569</span></span></code></pre>

</div>

Works like a charm. That error we saw previously could be much more helpful, though. With the current developmental version of parsnip, this looks like:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'>fit</span><span class='o'>(</span><span class='nv'>linear_spec</span>, <span class='o'>~</span> <span class='nv'>hp</span>, <span class='nv'>mtcars</span><span class='o'>)</span></span><span><span class='c'>#&gt; Error in lm.fit(x, y, offset = offset, singular.ok = singular.ok, ...): incompatible dimensions</span></span></code></pre>

</div>

Or, with workflows:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'>workflow</span><span class='o'>(</span><span class='nv'>mtcars_rec</span>, <span class='nv'>linear_spec</span><span class='o'>)</span> <span class='o'>%&gt;%</span> <span class='nf'>fit</span><span class='o'>(</span><span class='nv'>mtcars</span><span class='o'>)</span></span><span><span class='c'>#&gt; Error in eval_tidy(env$formula[[2]], env$data): object '.' not found</span></span></code></pre>

</div>

Much better.

## Predicting with things that can't predict

Earlier this year, Dr. Louise E. Sinks put out a [wonderful blog post](https://lsinks.github.io/posts/2023-04-10-tidymodels/tidymodels_tutorial.html) documenting what it felt like to approach the various object types defined in the tidymodels as a newcomer to the collection of packages. They wrote:

> I found it confusing that `fit`, `last_fit`, `fit_resamples`, etc., did not all produce objects that contained the same information and could be acted on by the same functions.

This makes sense. While we try to forefront the intended mental model for fitting and predicting with tidymodels in our APIs and documentation, we also need to be proactive in anticipating common challenges in constructing that mental model.

For example, we've found that it's sometimes not clear to users which outputs they can call [`predict()`](https://rdrr.io/r/stats/predict.html) on. One such situation, as Louise points out, is with `fit_resamples()`:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='c'># fit a linear regression model to bootstrap resamples of mtcars</span></span>
<span><span class='nv'>mtcars_res</span> <span class='o'>&lt;-</span> <span class='nf'>fit_resamples</span><span class='o'>(</span><span class='nf'>linear_reg</span><span class='o'>(</span><span class='o'>)</span>, <span class='nv'>mpg</span> <span class='o'>~</span> <span class='nv'>.</span>, <span class='nf'>bootstraps</span><span class='o'>(</span><span class='nv'>mtcars</span><span class='o'>)</span><span class='o'>)</span></span>
<span></span>
<span><span class='nv'>mtcars_res</span></span><span><span class='c'>#&gt; # Resampling results</span></span>
<span><span class='c'>#&gt; # Bootstrap sampling </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 25 × 4</span></span></span>
<span><span class='c'>#&gt;    splits          id          .metrics         .notes          </span></span>
<span><span class='c'>#&gt;    <span style='color: #555555; font-style: italic;'>&lt;list&gt;</span>          <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>       <span style='color: #555555; font-style: italic;'>&lt;list&gt;</span>           <span style='color: #555555; font-style: italic;'>&lt;list&gt;</span>          </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 1</span> <span style='color: #555555;'>&lt;split [32/13]&gt;</span> Bootstrap01 <span style='color: #555555;'>&lt;tibble [2 × 4]&gt;</span> <span style='color: #555555;'>&lt;tibble [0 × 3]&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 2</span> <span style='color: #555555;'>&lt;split [32/13]&gt;</span> Bootstrap02 <span style='color: #555555;'>&lt;tibble [2 × 4]&gt;</span> <span style='color: #555555;'>&lt;tibble [0 × 3]&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 3</span> <span style='color: #555555;'>&lt;split [32/15]&gt;</span> Bootstrap03 <span style='color: #555555;'>&lt;tibble [2 × 4]&gt;</span> <span style='color: #555555;'>&lt;tibble [0 × 3]&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 4</span> <span style='color: #555555;'>&lt;split [32/12]&gt;</span> Bootstrap04 <span style='color: #555555;'>&lt;tibble [2 × 4]&gt;</span> <span style='color: #555555;'>&lt;tibble [0 × 3]&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 5</span> <span style='color: #555555;'>&lt;split [32/14]&gt;</span> Bootstrap05 <span style='color: #555555;'>&lt;tibble [2 × 4]&gt;</span> <span style='color: #555555;'>&lt;tibble [0 × 3]&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 6</span> <span style='color: #555555;'>&lt;split [32/9]&gt;</span>  Bootstrap06 <span style='color: #555555;'>&lt;tibble [2 × 4]&gt;</span> <span style='color: #555555;'>&lt;tibble [0 × 3]&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 7</span> <span style='color: #555555;'>&lt;split [32/11]&gt;</span> Bootstrap07 <span style='color: #555555;'>&lt;tibble [2 × 4]&gt;</span> <span style='color: #555555;'>&lt;tibble [0 × 3]&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 8</span> <span style='color: #555555;'>&lt;split [32/12]&gt;</span> Bootstrap08 <span style='color: #555555;'>&lt;tibble [2 × 4]&gt;</span> <span style='color: #555555;'>&lt;tibble [0 × 3]&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 9</span> <span style='color: #555555;'>&lt;split [32/11]&gt;</span> Bootstrap09 <span style='color: #555555;'>&lt;tibble [2 × 4]&gt;</span> <span style='color: #555555;'>&lt;tibble [0 × 3]&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>10</span> <span style='color: #555555;'>&lt;split [32/13]&gt;</span> Bootstrap10 <span style='color: #555555;'>&lt;tibble [2 × 4]&gt;</span> <span style='color: #555555;'>&lt;tibble [0 × 3]&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># ℹ 15 more rows</span></span></span></code></pre>

</div>

With previous tidymodels versions, mistakenly trying to predict with this object resulted in the following output:

``` r
predict(mtcars_res)
#> Error in UseMethod("predict") : 
#>   no applicable method for 'predict' applied to an object of class
#>   "c('resample_results', 'tune_results', 'tbl_df', 'tbl', 'data.frame')"
```

Some R developers may recognize this error as what results when we didn't define any [`predict()`](https://rdrr.io/r/stats/predict.html) method for `tune_results` objects. We didn't do so because prediction isn't well-defined for tuning results. *But*, this error message does little to help a user understand why that's the case.

We've recently made some changes to error more informatively in this case. We do so by defining a "dummy" [`predict()`](https://rdrr.io/r/stats/predict.html) method for tuning results, implemented only for the sake of erroring more informatively. The same code will now give the following output:

``` r
predict(mtcars_res)
#> Error in `predict()`:
#> ! `predict()` is not well-defined for tuning results.
#> ℹ To predict with the optimal model configuration from tuning
#>   results, ensure that the tuning result was generated with the
#>   control option `save_workflow = TRUE`, run `fit_best()`, and
#>   then predict using `predict()` on its output.
#> ℹ To collect predictions from tuning results, ensure that the
#>   tuning result was generated with the control option `save_pred
#>   = TRUE` and run `collect_predictions()`.
```

References to important concepts or functions, like [control options](https://tune.tidymodels.org/reference/control_grid.html), [`fit_best()`](https://tune.tidymodels.org/reference/fit_best.html?q=fit_best), and [`collect_predictions()`](https://tune.tidymodels.org/reference/collect_predictions.html?q=collect), link to the help-files for those functions using [cli's erroring tools](https://cli.r-lib.org/reference/cli_abort.html).

We hope new error messages like this will help to get folks back on track.

## Model formulas

In R, formulas provide a compact, symbolic notation to specify model terms. Many modeling functions in R make use of "specials," or nonstandard notations used in formulas. Specials are defined and handled as a special case by a given modeling package. parsnip defers to engine packages to handle specials, so you can work with them as usual. For example, the mgcv package provides support for generalized additive models in R, and defines a special called `s()` to indicate smoothing terms. You can interface with it via tidymodels like so:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='c'># define a generalized additive model specification</span></span>
<span><span class='nv'>gam_spec</span> <span class='o'>&lt;-</span> <span class='nf'>gen_additive_mod</span><span class='o'>(</span><span class='s'>"regression"</span><span class='o'>)</span></span>
<span></span>
<span><span class='c'># fit the specification using a formula with specials</span></span>
<span><span class='nf'>fit</span><span class='o'>(</span><span class='nv'>gam_spec</span>, <span class='nv'>mpg</span> <span class='o'>~</span> <span class='nv'>cyl</span> <span class='o'>+</span> <span class='nf'>s</span><span class='o'>(</span><span class='nv'>disp</span>, k <span class='o'>=</span> <span class='m'>5</span><span class='o'>)</span>, <span class='nv'>mtcars</span><span class='o'>)</span></span><span><span class='c'>#&gt; parsnip model object</span></span>
<span><span class='c'>#&gt; </span></span>
<span><span class='c'>#&gt; </span></span>
<span><span class='c'>#&gt; Family: gaussian </span></span>
<span><span class='c'>#&gt; Link function: identity </span></span>
<span><span class='c'>#&gt; </span></span>
<span><span class='c'>#&gt; Formula:</span></span>
<span><span class='c'>#&gt; mpg ~ cyl + s(disp, k = 5)</span></span>
<span><span class='c'>#&gt; </span></span>
<span><span class='c'>#&gt; Estimated degrees of freedom:</span></span>
<span><span class='c'>#&gt; 3.39  total = 5.39 </span></span>
<span><span class='c'>#&gt; </span></span>
<span><span class='c'>#&gt; GCV score: 6.380152</span></span></code></pre>

</div>

While parsnip can handle specials just fine, the package is often used in conjunction with the greater tidymodels package ecosystem, which defines its own pre-processing infrastructure and functionality via packages like hardhat and recipes. The specials defined in many modeling packages introduce conflicts with that infrastructure. To support specials while also maintaining consistent syntax elsewhere in the ecosystem, **tidymodels delineates between two types of formulas: preprocessing formulas and model formulas**. Preprocessing formulas determine the input variables, while model formulas determine the model structure.

This is a tricky abstraction, and one that users have tripped up on in the past. Users could generate all sorts of different errors by 1) mistakenly passing model formulas where preprocessing formulas were expected, or 2) forgetting to pass a model formula where it's needed. For an example of 1), we could pass recipes the same formula we passed to parsnip:

``` r
recipe(mpg ~ cyl + s(disp, k = 5), mtcars)
#> Error in `inline_check()`:
#> ! No in-line functions should be used here; use steps to 
#>   define baking actions.
```

But we *just* used a special with another tidymodels function! Rude!

Or, to demonstrate 2), we pass the preprocessing formula as we ought to but forget to provide the model formula:

``` r
gam_wflow <- 
  workflow() %>%
  add_formula(mpg ~ .) %>%
  add_model(gam_spec) 

gam_wflow %>% fit(mtcars)
#> Error in `fit_xy()`:
#> ! `fit()` must be used with GAM models (due to its use of formulas).
```

Uh, but I *did* just use `fit()`!

Since the distinction between model formulas and preprocessor formulas comes up in functions across tidymodels, we decide to create a [central page](https://parsnip.tidymodels.org/dev/reference/model_formula.html) that documents the concept itself, hopefully making the syntax associated with it come more easily to users. Then, we link to it *all over the place*. For example, those errors now look like:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'>recipe</span><span class='o'>(</span><span class='nv'>mpg</span> <span class='o'>~</span> <span class='nv'>cyl</span> <span class='o'>+</span> <span class='nf'>s</span><span class='o'>(</span><span class='nv'>disp</span>, k <span class='o'>=</span> <span class='m'>5</span><span class='o'>)</span>, <span class='nv'>mtcars</span><span class='o'>)</span></span><span><span class='c'>#&gt; <span style='color: #BBBB00; font-weight: bold;'>Error</span><span style='font-weight: bold;'> in `inline_check()`:</span></span></span>
<span><span class='c'>#&gt; <span style='color: #BBBB00;'>!</span> No in-line functions should be used here; use steps to define baking actions.</span></span></code></pre>

</div>

Or:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>gam_wflow</span> <span class='o'>%&gt;%</span> <span class='nf'>fit</span><span class='o'>(</span><span class='nv'>mtcars</span><span class='o'>)</span></span><span><span class='c'>#&gt; <span style='color: #BBBB00; font-weight: bold;'>Error</span><span style='font-weight: bold;'> in `fit_xy()`:</span></span></span>
<span><span class='c'>#&gt; <span style='color: #BBBB00;'>!</span> `fit()` must be used with GAM models (due to its use of formulas).</span></span></code></pre>

</div>

While I've only outlined three, there are all sorts of improvements to error messages on their way to the tidymodels packages in upcoming releases. If you happen to stumble across them, we hope they quickly set you back on the right path. 🗺

[^1]: Issue triage consists of categorizing, prioritizing, and consolidating issues in a repository's issue tracker.

[^2]: See the [tidyclust](tidyclust.tidymodels.org) package for unsupervised learning with tidymodels!

