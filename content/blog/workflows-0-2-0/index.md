---
output: hugodown::hugo_document
slug: workflows-0-2-0
title: workflows 0.2.0
date: 2020-09-16
author: Davis Vaughan
description: >
    workflows 0.2.0 is now on CRAN!
photo:
  url: https://unsplash.com/photos/nN5L5GXKFz8
  author: Mark Fletcher-Brown
categories: [package] 
tags: [tidymodels]
editor_options: 
  chunk_output_type: console
rmd_hash: b395e9e7edc0acf1

---

We're excited to announce the release of [workflows](https://workflows.tidymodels.org/) 0.2.0. workflows is a [tidymodels](https://www.tidymodels.org/) package for bundling a model specification from [parsnip](https://parsnip.tidymodels.org/) with a preprocessor, such as a formula or [recipe](https://recipes.tidymodels.org/). Doing this can streamline the model fitting workflow and combines nicely with [tune](https://tune.tidymodels.org/) for performing hyperparameter tuning.

You can install it from CRAN with:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://rdrr.io/r/utils/install.packages.html'>install.packages</a></span>(<span class='s'>"workflows"</span>)
</code></pre>

</div>

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://rdrr.io/r/base/library.html'>library</a></span>(<span class='k'><a href='https://github.com/tidymodels/workflows'>workflows</a></span>)
<span class='nf'><a href='https://rdrr.io/r/base/library.html'>library</a></span>(<span class='k'><a href='https://parsnip.tidymodels.org'>parsnip</a></span>)
</code></pre>

</div>

Variables
---------

The main change in this release of workflows is the introduction of a new preprocessor method: [`add_variables()`](https://workflows.tidymodels.org//reference/add_variables.html). This adds a third method to specify model terms, in addition to [`add_formula()`](https://workflows.tidymodels.org//reference/add_formula.html) and [`add_recipe()`](https://workflows.tidymodels.org//reference/add_recipe.html).

[`add_variables()`](https://workflows.tidymodels.org//reference/add_variables.html) has a tidyselect interface, where `outcomes` are specified using bare column names, followed by `predictors`.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='k'>linear_spec</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://parsnip.tidymodels.org/reference/linear_reg.html'>linear_reg</a></span>() <span class='o'>%&gt;%</span>
  <span class='nf'><a href='https://parsnip.tidymodels.org/reference/set_engine.html'>set_engine</a></span>(<span class='s'>"lm"</span>)

<span class='k'>wf</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://workflows.tidymodels.org//reference/workflow.html'>workflow</a></span>() <span class='o'>%&gt;%</span>
  <span class='nf'><a href='https://workflows.tidymodels.org//reference/add_model.html'>add_model</a></span>(<span class='k'>linear_spec</span>) <span class='o'>%&gt;%</span>
  <span class='nf'><a href='https://workflows.tidymodels.org//reference/add_variables.html'>add_variables</a></span>(<span class='k'>mpg</span>, <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span>(<span class='k'>cyl</span>, <span class='k'>disp</span>))

<span class='k'>wf</span>

<span class='c'>#&gt; ══ Workflow ════════════════════════════════════════════════════════════════════</span>
<span class='c'>#&gt; <span style='font-style: italic;'>Preprocessor:</span><span> Variables</span></span>
<span class='c'>#&gt; <span style='font-style: italic;'>Model:</span><span> linear_reg()</span></span>
<span class='c'>#&gt; </span>
<span class='c'>#&gt; ── Preprocessor ────────────────────────────────────────────────────────────────</span>
<span class='c'>#&gt; Outcomes: mpg</span>
<span class='c'>#&gt; Predictors: c(cyl, disp)</span>
<span class='c'>#&gt; </span>
<span class='c'>#&gt; ── Model ───────────────────────────────────────────────────────────────────────</span>
<span class='c'>#&gt; Linear Regression Model Specification (regression)</span>
<span class='c'>#&gt; </span>
<span class='c'>#&gt; Computational engine: lm</span>
</code></pre>

</div>

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='k'>model</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/pkg/generics/man/fit.html'>fit</a></span>(<span class='k'>wf</span>, <span class='k'>mtcars</span>)
<span class='k'>mold</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://workflows.tidymodels.org//reference/workflow-extractors.html'>pull_workflow_mold</a></span>(<span class='k'>model</span>)

<span class='k'>mold</span><span class='o'>$</span><span class='k'>predictors</span>

<span class='c'>#&gt; <span style='color: #949494;'># A tibble: 32 x 2</span></span>
<span class='c'>#&gt;      cyl  disp</span>
<span class='c'>#&gt;    <span style='color: #949494;font-style: italic;'>&lt;dbl&gt;</span><span> </span><span style='color: #949494;font-style: italic;'>&lt;dbl&gt;</span></span>
<span class='c'>#&gt; <span style='color: #BCBCBC;'> 1</span><span>     6  160 </span></span>
<span class='c'>#&gt; <span style='color: #BCBCBC;'> 2</span><span>     6  160 </span></span>
<span class='c'>#&gt; <span style='color: #BCBCBC;'> 3</span><span>     4  108 </span></span>
<span class='c'>#&gt; <span style='color: #BCBCBC;'> 4</span><span>     6  258 </span></span>
<span class='c'>#&gt; <span style='color: #BCBCBC;'> 5</span><span>     8  360 </span></span>
<span class='c'>#&gt; <span style='color: #BCBCBC;'> 6</span><span>     6  225 </span></span>
<span class='c'>#&gt; <span style='color: #BCBCBC;'> 7</span><span>     8  360 </span></span>
<span class='c'>#&gt; <span style='color: #BCBCBC;'> 8</span><span>     4  147.</span></span>
<span class='c'>#&gt; <span style='color: #BCBCBC;'> 9</span><span>     4  141.</span></span>
<span class='c'>#&gt; <span style='color: #BCBCBC;'>10</span><span>     6  168.</span></span>
<span class='c'>#&gt; <span style='color: #949494;'># … with 22 more rows</span></span>

<span class='k'>mold</span><span class='o'>$</span><span class='k'>outcomes</span>

<span class='c'>#&gt; <span style='color: #949494;'># A tibble: 32 x 1</span></span>
<span class='c'>#&gt;      mpg</span>
<span class='c'>#&gt;    <span style='color: #949494;font-style: italic;'>&lt;dbl&gt;</span></span>
<span class='c'>#&gt; <span style='color: #BCBCBC;'> 1</span><span>  21  </span></span>
<span class='c'>#&gt; <span style='color: #BCBCBC;'> 2</span><span>  21  </span></span>
<span class='c'>#&gt; <span style='color: #BCBCBC;'> 3</span><span>  22.8</span></span>
<span class='c'>#&gt; <span style='color: #BCBCBC;'> 4</span><span>  21.4</span></span>
<span class='c'>#&gt; <span style='color: #BCBCBC;'> 5</span><span>  18.7</span></span>
<span class='c'>#&gt; <span style='color: #BCBCBC;'> 6</span><span>  18.1</span></span>
<span class='c'>#&gt; <span style='color: #BCBCBC;'> 7</span><span>  14.3</span></span>
<span class='c'>#&gt; <span style='color: #BCBCBC;'> 8</span><span>  24.4</span></span>
<span class='c'>#&gt; <span style='color: #BCBCBC;'> 9</span><span>  22.8</span></span>
<span class='c'>#&gt; <span style='color: #BCBCBC;'>10</span><span>  19.2</span></span>
<span class='c'>#&gt; <span style='color: #949494;'># … with 22 more rows</span></span>
</code></pre>

</div>

`outcomes` are removed before `predictors` is evaluated, which means that formula specifications like `y ~ .` can be easily reproduced as:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://workflows.tidymodels.org//reference/workflow.html'>workflow</a></span>() <span class='o'>%&gt;%</span>
  <span class='nf'><a href='https://workflows.tidymodels.org//reference/add_variables.html'>add_variables</a></span>(<span class='k'>mpg</span>, <span class='nf'>everything</span>())

<span class='c'>#&gt; ══ Workflow ════════════════════════════════════════════════════════════════════</span>
<span class='c'>#&gt; <span style='font-style: italic;'>Preprocessor:</span><span> Variables</span></span>
<span class='c'>#&gt; <span style='font-style: italic;'>Model:</span><span> None</span></span>
<span class='c'>#&gt; </span>
<span class='c'>#&gt; ── Preprocessor ────────────────────────────────────────────────────────────────</span>
<span class='c'>#&gt; Outcomes: mpg</span>
<span class='c'>#&gt; Predictors: everything()</span>
</code></pre>

</div>

Importantly, [`add_variables()`](https://workflows.tidymodels.org//reference/add_variables.html) doesn't do any preprocessing to your columns whatsoever. This is in contrast to [`add_formula()`](https://workflows.tidymodels.org//reference/add_formula.html), which uses the standard [`model.matrix()`](https://rdrr.io/r/stats/model.matrix.html) machinery from R, and [`add_recipe()`](https://workflows.tidymodels.org//reference/add_recipe.html), which will [`recipes::prep()`](https://recipes.tidymodels.org/reference/prep.html) the recipe for you. It is especially useful when you aren't using a recipe, but you do have S3 columns that you don't want run through [`model.matrix()`](https://rdrr.io/r/stats/model.matrix.html) for fear of losing the S3 class, like with Date columns.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://rdrr.io/r/base/library.html'>library</a></span>(<span class='k'><a href='https://github.com/business-science/modeltime'>modeltime</a></span>)

<span class='k'>arima_spec</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/pkg/modeltime/man/arima_reg.html'>arima_reg</a></span>() <span class='o'>%&gt;%</span>
    <span class='nf'><a href='https://parsnip.tidymodels.org/reference/set_engine.html'>set_engine</a></span>(<span class='s'>"arima"</span>)

<span class='k'>df</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/data.frame.html'>data.frame</a></span>(
  y = <span class='nf'><a href='https://rdrr.io/r/base/sample.html'>sample</a></span>(<span class='m'>5</span>),
  date = <span class='nf'><a href='https://rdrr.io/r/base/as.Date.html'>as.Date</a></span>(<span class='s'>"2019-01-01"</span>) <span class='o'>+</span> <span class='m'>0</span><span class='o'>:</span><span class='m'>4</span>
)

<span class='k'>wf</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://workflows.tidymodels.org//reference/workflow.html'>workflow</a></span>() <span class='o'>%&gt;%</span>
  <span class='nf'><a href='https://workflows.tidymodels.org//reference/add_variables.html'>add_variables</a></span>(<span class='k'>y</span>, <span class='k'>date</span>) <span class='o'>%&gt;%</span>
  <span class='nf'><a href='https://workflows.tidymodels.org//reference/add_model.html'>add_model</a></span>(<span class='k'>arima_spec</span>)

<span class='k'>arima_model</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/pkg/generics/man/fit.html'>fit</a></span>(<span class='k'>wf</span>, <span class='k'>df</span>)

<span class='c'>#&gt; frequency = 1 observations per 1 day</span>


<span class='k'>arima_model</span>

<span class='c'>#&gt; ══ Workflow [trained] ══════════════════════════════════════════════════════════</span>
<span class='c'>#&gt; <span style='font-style: italic;'>Preprocessor:</span><span> Variables</span></span>
<span class='c'>#&gt; <span style='font-style: italic;'>Model:</span><span> arima_reg()</span></span>
<span class='c'>#&gt; </span>
<span class='c'>#&gt; ── Preprocessor ────────────────────────────────────────────────────────────────</span>
<span class='c'>#&gt; Outcomes: y</span>
<span class='c'>#&gt; Predictors: date</span>
<span class='c'>#&gt; </span>
<span class='c'>#&gt; ── Model ───────────────────────────────────────────────────────────────────────</span>
<span class='c'>#&gt; Series: outcome </span>
<span class='c'>#&gt; ARIMA(0,0,0) with non-zero mean </span>
<span class='c'>#&gt; </span>
<span class='c'>#&gt; Coefficients:</span>
<span class='c'>#&gt;         mean</span>
<span class='c'>#&gt;       3.0000</span>
<span class='c'>#&gt; s.e.  0.6325</span>
<span class='c'>#&gt; </span>
<span class='c'>#&gt; sigma^2 estimated as 2.5:  log likelihood=-8.83</span>
<span class='c'>#&gt; AIC=21.66   AICc=27.66   BIC=20.87</span>
</code></pre>

</div>

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='k'>mold</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://workflows.tidymodels.org//reference/workflow-extractors.html'>pull_workflow_mold</a></span>(<span class='k'>arima_model</span>)
<span class='k'>mold</span><span class='o'>$</span><span class='k'>predictors</span>

<span class='c'>#&gt; <span style='color: #949494;'># A tibble: 5 x 1</span></span>
<span class='c'>#&gt;   date      </span>
<span class='c'>#&gt;   <span style='color: #949494;font-style: italic;'>&lt;date&gt;</span><span>    </span></span>
<span class='c'>#&gt; <span style='color: #BCBCBC;'>1</span><span> 2019-01-01</span></span>
<span class='c'>#&gt; <span style='color: #BCBCBC;'>2</span><span> 2019-01-02</span></span>
<span class='c'>#&gt; <span style='color: #BCBCBC;'>3</span><span> 2019-01-03</span></span>
<span class='c'>#&gt; <span style='color: #BCBCBC;'>4</span><span> 2019-01-04</span></span>
<span class='c'>#&gt; <span style='color: #BCBCBC;'>5</span><span> 2019-01-05</span></span>
</code></pre>

</div>

Tune
----

workflows created with [`add_variables()`](https://workflows.tidymodels.org//reference/add_variables.html) do not work with the current CRAN version of tune (0.1.1). However, the development version of tune does have support for this, which you can install in the meantime until a new version of tune hits CRAN.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='k'>devtools</span>::<span class='nf'><a href='https://devtools.r-lib.org//reference/remote-reexports.html'>install_github</a></span>(<span class='s'>"tidymodels/tune"</span>)
</code></pre>

</div>

Acknowledgements
----------------

Thanks to the three contributors that helped with this version of workflows [@EmilHvitfeldt](https://github.com/EmilHvitfeldt), [@mdancho84](https://github.com/mdancho84), and [@RaviHela](https://github.com/RaviHela)!

