---
output: hugodown::hugo_document

slug: orbital-0-3-0
title: recipes 0.3.0
date: 2025-01-08
author: Emil Hvitfeldt
description: >
    orbital 0.3.0 is on CRAN! orbital now has classification support.

photo:
  url: https://www.pexels.com/photo/aerial-view-earth-exploration-flying-60132/
  author: SpaceX

# one of: "deep-dive", "learn", "package", "programming", "roundup", or "other"
categories: [package] 
tags: [tidymodels, orbital]
rmd_hash: a761c1ce3dd0bb76

---

<!--
TODO:
* [ ] Look over / edit the post's title in the yaml
* [ ] Edit (or delete) the description; note this appears in the Twitter card
* [ ] Pick category and tags (see existing with [`hugodown::tidy_show_meta()`](https://rdrr.io/pkg/hugodown/man/use_tidy_post.html))
* [ ] Find photo & update yaml metadata
* [ ] Create `thumbnail-sq.jpg`; height and width should be equal
* [ ] Create `thumbnail-wd.jpg`; width should be >5x height
* [ ] [`hugodown::use_tidy_thumbnails()`](https://rdrr.io/pkg/hugodown/man/use_tidy_post.html)
* [ ] Add intro sentence, e.g. the standard tagline for the package
* [ ] [`usethis::use_tidy_thanks()`](https://usethis.r-lib.org/reference/use_tidy_thanks.html)
-->

We're thrilled to announce the release of [orbital](https://orbital.tidymodels.org/) 0.3.0. orbital lets you predict in databases using tidymodels workflows.

You can install it from CRAN with:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://rdrr.io/r/utils/install.packages.html'>install.packages</a></span><span class='o'>(</span><span class='s'>"orbital"</span><span class='o'>)</span></span></code></pre>

</div>

This blog post will cover the highlights, which are classification support and the new augment method.

You can see a full list of changes in the [release notes](https://orbital.tidymodels.org/news/index.html#orbital-030).

## Classification support

The biggest improvement in this version is that [`orbital()`](https://orbital.tidymodels.org/reference/orbital.html) now works for supported classification models. See [vignette](https://orbital.tidymodels.org/articles/supported-models.html#supported-models) for list of all supported models.

Let's start by fitting a classification model on the `penguins` data set, using {xgboost} as the engine.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>rec_spec</span> <span class='o'>&lt;-</span> <span class='nf'>recipe</span><span class='o'>(</span><span class='nv'>species</span> <span class='o'>~</span> <span class='nv'>.</span>, data <span class='o'>=</span> <span class='nv'>penguins</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'>step_unknown</span><span class='o'>(</span><span class='nf'>all_nominal_predictors</span><span class='o'>(</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'>step_dummy</span><span class='o'>(</span><span class='nf'>all_nominal_predictors</span><span class='o'>(</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'>step_impute_mean</span><span class='o'>(</span><span class='nf'>all_numeric_predictors</span><span class='o'>(</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'>step_zv</span><span class='o'>(</span><span class='nf'>all_predictors</span><span class='o'>(</span><span class='o'>)</span><span class='o'>)</span></span>
<span></span>
<span><span class='nv'>lr_spec</span> <span class='o'>&lt;-</span> <span class='nf'>boost_tree</span><span class='o'>(</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'>set_mode</span><span class='o'>(</span><span class='s'>"classification"</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'>set_engine</span><span class='o'>(</span><span class='s'>"xgboost"</span><span class='o'>)</span></span>
<span></span>
<span><span class='nv'>wf_spec</span> <span class='o'>&lt;-</span> <span class='nf'>workflow</span><span class='o'>(</span><span class='nv'>rec_spec</span>, <span class='nv'>lr_spec</span><span class='o'>)</span></span>
<span><span class='nv'>wf_fit</span> <span class='o'>&lt;-</span> <span class='nf'>fit</span><span class='o'>(</span><span class='nv'>wf_spec</span>, data <span class='o'>=</span> <span class='nv'>penguins</span><span class='o'>)</span></span></code></pre>

</div>

With this fitted workflow object, we can call [`orbital()`](https://orbital.tidymodels.org/reference/orbital.html) on it to create an orbital object.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>orbital_obj</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://orbital.tidymodels.org/reference/orbital.html'>orbital</a></span><span class='o'>(</span><span class='nv'>wf_fit</span><span class='o'>)</span></span>
<span><span class='nv'>orbital_obj</span></span>
<span><span class='c'>#&gt; </span></span>
<span><span class='c'>#&gt; <span style='color: #00BBBB;'>──</span> <span style='font-weight: bold;'>orbital Object</span> <span style='color: #00BBBB;'>──────────────────────────────────────────────────────────────</span></span></span>
<span><span class='c'>#&gt; • island = dplyr::if_else(is.na(island), "unknown", island)</span></span>
<span><span class='c'>#&gt; • sex = dplyr::if_else(is.na(sex), "unknown", sex)</span></span>
<span><span class='c'>#&gt; • island_Dream = as.numeric(island == "Dream")</span></span>
<span><span class='c'>#&gt; • island_Torgersen = as.numeric(island == "Torgersen")</span></span>
<span><span class='c'>#&gt; • sex_male = as.numeric(sex == "male")</span></span>
<span><span class='c'>#&gt; • sex_unknown = as.numeric(sex == "unknown")</span></span>
<span><span class='c'>#&gt; • bill_length_mm = dplyr::if_else(is.na(bill_length_mm), 43.92193, bill_l ...</span></span>
<span><span class='c'>#&gt; • bill_depth_mm = dplyr::if_else(is.na(bill_depth_mm), 17.15117, bill_dep ...</span></span>
<span><span class='c'>#&gt; • flipper_length_mm = dplyr::if_else(is.na(flipper_length_mm), 201, flipp ...</span></span>
<span><span class='c'>#&gt; • body_mass_g = dplyr::if_else(is.na(body_mass_g), 4202, body_mass_g)</span></span>
<span><span class='c'>#&gt; • island_Dream = dplyr::if_else(is.na(island_Dream), 0.3604651, island_Dr ...</span></span>
<span><span class='c'>#&gt; • island_Torgersen = dplyr::if_else(is.na(island_Torgersen), 0.1511628, i ...</span></span>
<span><span class='c'>#&gt; • sex_male = dplyr::if_else(is.na(sex_male), 0.4883721, sex_male)</span></span>
<span><span class='c'>#&gt; • sex_unknown = dplyr::if_else(is.na(sex_unknown), 0.03197674, sex_unknow ...</span></span>
<span><span class='c'>#&gt; • Adelie = 0 + dplyr::case_when((bill_depth_mm &lt; 15.1 | is.na(bill_depth_ ...</span></span>
<span><span class='c'>#&gt; • Chinstrap = 0 + dplyr::case_when((island_Dream &lt; 0.5 | is.na(island_Dre ...</span></span>
<span><span class='c'>#&gt; • Gentoo = 0 + dplyr::case_when((bill_depth_mm &lt; 15.95 | is.na(bill_depth ...</span></span>
<span><span class='c'>#&gt; • .pred_class = dplyr::case_when(Adelie &gt; Chinstrap &amp; Adelie &gt; Gentoo ~ " ...</span></span>
<span><span class='c'>#&gt; ────────────────────────────────────────────────────────────────────────────────</span></span>
<span><span class='c'>#&gt; 18 equations in total.</span></span>
<span></span></code></pre>

</div>

This object contains all the information that is needed to produce predictions. Which we can produce with [`predict()`](https://rdrr.io/r/stats/predict.html).

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://rdrr.io/r/stats/predict.html'>predict</a></span><span class='o'>(</span><span class='nv'>orbital_obj</span>, <span class='nv'>penguins</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 344 × 1</span></span></span>
<span><span class='c'>#&gt;    .pred_class</span></span>
<span><span class='c'>#&gt;    <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>      </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 1</span> Adelie     </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 2</span> Adelie     </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 3</span> Adelie     </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 4</span> Adelie     </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 5</span> Adelie     </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 6</span> Adelie     </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 7</span> Adelie     </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 8</span> Adelie     </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 9</span> Adelie     </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>10</span> Adelie     </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># ℹ 334 more rows</span></span></span>
<span></span></code></pre>

</div>

The main thing to note here is that the orbital package produces character vectors instead of factors. This is done as a unifying approach since many databases don't have factor types.

Speaking of databases, you can [`predict()`](https://rdrr.io/r/stats/predict.html) on an orbital object using tables from databases. Below we create an ephemeral in-memory RSQLite database.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://dbi.r-dbi.org'>DBI</a></span><span class='o'>)</span></span>
<span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://rsqlite.r-dbi.org'>RSQLite</a></span><span class='o'>)</span></span>
<span></span>
<span><span class='nv'>con_sqlite</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://dbi.r-dbi.org/reference/dbConnect.html'>dbConnect</a></span><span class='o'>(</span><span class='nf'><a href='https://rsqlite.r-dbi.org/reference/SQLite.html'>SQLite</a></span><span class='o'>(</span><span class='o'>)</span>, path <span class='o'>=</span> <span class='s'>":memory:"</span><span class='o'>)</span></span>
<span><span class='nv'>penguins_sqlite</span> <span class='o'>&lt;-</span> <span class='nf'>copy_to</span><span class='o'>(</span><span class='nv'>con_sqlite</span>, <span class='nv'>penguins</span>, name <span class='o'>=</span> <span class='s'>"penguins_table"</span><span class='o'>)</span></span></code></pre>

</div>

And we can predict with it like normal. All the calculations are sent to the database for execution.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://rdrr.io/r/stats/predict.html'>predict</a></span><span class='o'>(</span><span class='nv'>orbital_obj</span>, <span class='nv'>penguins_sqlite</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># Source:   SQL [?? x 1]</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># Database: sqlite 3.47.1 []</span></span></span>
<span><span class='c'>#&gt;    .pred_class</span></span>
<span><span class='c'>#&gt;    <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>      </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 1</span> Adelie     </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 2</span> Adelie     </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 3</span> Adelie     </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 4</span> Adelie     </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 5</span> Adelie     </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 6</span> Adelie     </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 7</span> Adelie     </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 8</span> Adelie     </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 9</span> Adelie     </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>10</span> Adelie     </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># ℹ more rows</span></span></span>
<span></span></code></pre>

</div>

This works the same with [many types of databases](https://orbital.tidymodels.org/articles/databases.html).

Classification is different from regression in part because it comes with multiple prediction types. The above example showed the default which is hard classification. You can set the type of prediction you want with the `type` argument to `orbital`. For classification models, it takes `"class"` and `"prob"`.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>orbital_obj_prob</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://orbital.tidymodels.org/reference/orbital.html'>orbital</a></span><span class='o'>(</span><span class='nv'>wf_fit</span>, type <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"class"</span>, <span class='s'>"prob"</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='nv'>orbital_obj_prob</span></span>
<span><span class='c'>#&gt; </span></span>
<span><span class='c'>#&gt; <span style='color: #00BBBB;'>──</span> <span style='font-weight: bold;'>orbital Object</span> <span style='color: #00BBBB;'>──────────────────────────────────────────────────────────────</span></span></span>
<span><span class='c'>#&gt; • island = dplyr::if_else(is.na(island), "unknown", island)</span></span>
<span><span class='c'>#&gt; • sex = dplyr::if_else(is.na(sex), "unknown", sex)</span></span>
<span><span class='c'>#&gt; • island_Dream = as.numeric(island == "Dream")</span></span>
<span><span class='c'>#&gt; • island_Torgersen = as.numeric(island == "Torgersen")</span></span>
<span><span class='c'>#&gt; • sex_male = as.numeric(sex == "male")</span></span>
<span><span class='c'>#&gt; • sex_unknown = as.numeric(sex == "unknown")</span></span>
<span><span class='c'>#&gt; • bill_length_mm = dplyr::if_else(is.na(bill_length_mm), 43.92193, bill_l ...</span></span>
<span><span class='c'>#&gt; • bill_depth_mm = dplyr::if_else(is.na(bill_depth_mm), 17.15117, bill_dep ...</span></span>
<span><span class='c'>#&gt; • flipper_length_mm = dplyr::if_else(is.na(flipper_length_mm), 201, flipp ...</span></span>
<span><span class='c'>#&gt; • body_mass_g = dplyr::if_else(is.na(body_mass_g), 4202, body_mass_g)</span></span>
<span><span class='c'>#&gt; • island_Dream = dplyr::if_else(is.na(island_Dream), 0.3604651, island_Dr ...</span></span>
<span><span class='c'>#&gt; • island_Torgersen = dplyr::if_else(is.na(island_Torgersen), 0.1511628, i ...</span></span>
<span><span class='c'>#&gt; • sex_male = dplyr::if_else(is.na(sex_male), 0.4883721, sex_male)</span></span>
<span><span class='c'>#&gt; • sex_unknown = dplyr::if_else(is.na(sex_unknown), 0.03197674, sex_unknow ...</span></span>
<span><span class='c'>#&gt; • Adelie = 0 + dplyr::case_when((bill_depth_mm &lt; 15.1 | is.na(bill_depth_ ...</span></span>
<span><span class='c'>#&gt; • Chinstrap = 0 + dplyr::case_when((island_Dream &lt; 0.5 | is.na(island_Dre ...</span></span>
<span><span class='c'>#&gt; • Gentoo = 0 + dplyr::case_when((bill_depth_mm &lt; 15.95 | is.na(bill_depth ...</span></span>
<span><span class='c'>#&gt; • .pred_class = dplyr::case_when(Adelie &gt; Chinstrap &amp; Adelie &gt; Gentoo ~ " ...</span></span>
<span><span class='c'>#&gt; • norm = exp(Adelie) + exp(Chinstrap) + exp(Gentoo)</span></span>
<span><span class='c'>#&gt; • .pred_Adelie = exp(Adelie) / norm</span></span>
<span><span class='c'>#&gt; • .pred_Chinstrap = exp(Chinstrap) / norm</span></span>
<span><span class='c'>#&gt; • .pred_Gentoo = exp(Gentoo) / norm</span></span>
<span><span class='c'>#&gt; ────────────────────────────────────────────────────────────────────────────────</span></span>
<span><span class='c'>#&gt; 22 equations in total.</span></span>
<span></span></code></pre>

</div>

Notice how we can select both `"class"` and `"prob"`. The predictions now include both hard and soft class predictions.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://rdrr.io/r/stats/predict.html'>predict</a></span><span class='o'>(</span><span class='nv'>orbital_obj_prob</span>, <span class='nv'>penguins</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 344 × 4</span></span></span>
<span><span class='c'>#&gt;    .pred_class .pred_Adelie .pred_Chinstrap .pred_Gentoo</span></span>
<span><span class='c'>#&gt;    <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>              <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>           <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>        <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 1</span> Adelie             0.989         0.005<span style='text-decoration: underline;'>54</span>      0.005<span style='text-decoration: underline;'>60</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 2</span> Adelie             0.989         0.005<span style='text-decoration: underline;'>54</span>      0.005<span style='text-decoration: underline;'>60</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 3</span> Adelie             0.989         0.005<span style='text-decoration: underline;'>54</span>      0.005<span style='text-decoration: underline;'>60</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 4</span> Adelie             0.709         0.024<span style='text-decoration: underline;'>5</span>       0.267  </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 5</span> Adelie             0.989         0.005<span style='text-decoration: underline;'>54</span>      0.005<span style='text-decoration: underline;'>60</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 6</span> Adelie             0.989         0.005<span style='text-decoration: underline;'>54</span>      0.005<span style='text-decoration: underline;'>60</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 7</span> Adelie             0.989         0.005<span style='text-decoration: underline;'>54</span>      0.005<span style='text-decoration: underline;'>60</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 8</span> Adelie             0.989         0.005<span style='text-decoration: underline;'>54</span>      0.005<span style='text-decoration: underline;'>60</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 9</span> Adelie             0.979         0.005<span style='text-decoration: underline;'>49</span>      0.015<span style='text-decoration: underline;'>8</span> </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>10</span> Adelie             0.980         0.005<span style='text-decoration: underline;'>59</span>      0.014<span style='text-decoration: underline;'>8</span> </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># ℹ 334 more rows</span></span></span>
<span></span></code></pre>

</div>

That works equally well in databases.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://rdrr.io/r/stats/predict.html'>predict</a></span><span class='o'>(</span><span class='nv'>orbital_obj_prob</span>, <span class='nv'>penguins_sqlite</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># Source:   SQL [?? x 4]</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># Database: sqlite 3.47.1 []</span></span></span>
<span><span class='c'>#&gt;    .pred_class .pred_Adelie .pred_Chinstrap .pred_Gentoo</span></span>
<span><span class='c'>#&gt;    <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>              <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>           <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>        <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 1</span> Adelie             0.989         0.005<span style='text-decoration: underline;'>54</span>      0.005<span style='text-decoration: underline;'>60</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 2</span> Adelie             0.989         0.005<span style='text-decoration: underline;'>54</span>      0.005<span style='text-decoration: underline;'>60</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 3</span> Adelie             0.989         0.005<span style='text-decoration: underline;'>54</span>      0.005<span style='text-decoration: underline;'>60</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 4</span> Adelie             0.709         0.024<span style='text-decoration: underline;'>5</span>       0.267  </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 5</span> Adelie             0.989         0.005<span style='text-decoration: underline;'>54</span>      0.005<span style='text-decoration: underline;'>60</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 6</span> Adelie             0.989         0.005<span style='text-decoration: underline;'>54</span>      0.005<span style='text-decoration: underline;'>60</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 7</span> Adelie             0.989         0.005<span style='text-decoration: underline;'>54</span>      0.005<span style='text-decoration: underline;'>60</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 8</span> Adelie             0.989         0.005<span style='text-decoration: underline;'>54</span>      0.005<span style='text-decoration: underline;'>60</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 9</span> Adelie             0.979         0.005<span style='text-decoration: underline;'>49</span>      0.015<span style='text-decoration: underline;'>8</span> </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>10</span> Adelie             0.980         0.005<span style='text-decoration: underline;'>59</span>      0.014<span style='text-decoration: underline;'>8</span> </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># ℹ more rows</span></span></span>
<span></span></code></pre>

</div>

## New augment method

The users of tidymodels have found the [`augment()`](https://generics.r-lib.org/reference/augment.html) function to be a handy tool. This function performs predictions and returns them alongside the original data set.

This release adds [`augment()`](https://generics.r-lib.org/reference/augment.html) support for orbital objects.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://generics.r-lib.org/reference/augment.html'>augment</a></span><span class='o'>(</span><span class='nv'>orbital_obj</span>, <span class='nv'>penguins</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 344 × 8</span></span></span>
<span><span class='c'>#&gt;    .pred_class species island    bill_length_mm bill_depth_mm flipper_length_mm</span></span>
<span><span class='c'>#&gt;    <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>       <span style='color: #555555; font-style: italic;'>&lt;fct&gt;</span>   <span style='color: #555555; font-style: italic;'>&lt;fct&gt;</span>              <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>         <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>             <span style='color: #555555; font-style: italic;'>&lt;int&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 1</span> Adelie      Adelie  Torgersen           39.1          18.7               181</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 2</span> Adelie      Adelie  Torgersen           39.5          17.4               186</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 3</span> Adelie      Adelie  Torgersen           40.3          18                 195</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 4</span> Adelie      Adelie  Torgersen           <span style='color: #BB0000;'>NA</span>            <span style='color: #BB0000;'>NA</span>                  <span style='color: #BB0000;'>NA</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 5</span> Adelie      Adelie  Torgersen           36.7          19.3               193</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 6</span> Adelie      Adelie  Torgersen           39.3          20.6               190</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 7</span> Adelie      Adelie  Torgersen           38.9          17.8               181</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 8</span> Adelie      Adelie  Torgersen           39.2          19.6               195</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 9</span> Adelie      Adelie  Torgersen           34.1          18.1               193</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>10</span> Adelie      Adelie  Torgersen           42            20.2               190</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># ℹ 334 more rows</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># ℹ 2 more variables: body_mass_g &lt;int&gt;, sex &lt;fct&gt;</span></span></span>
<span></span></code></pre>

</div>

The function works for most databases, but for technical reasons doesn't work with all. It has been confirmed to not work work in spark databases or arrow tables.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://generics.r-lib.org/reference/augment.html'>augment</a></span><span class='o'>(</span><span class='nv'>orbital_obj</span>, <span class='nv'>penguins_sqlite</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># Source:   SQL [?? x 8]</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># Database: sqlite 3.47.1 []</span></span></span>
<span><span class='c'>#&gt;    .pred_class species island    bill_length_mm bill_depth_mm flipper_length_mm</span></span>
<span><span class='c'>#&gt;    <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>       <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>   <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>              <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>         <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>             <span style='color: #555555; font-style: italic;'>&lt;int&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 1</span> Adelie      Adelie  Torgersen           39.1          18.7               181</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 2</span> Adelie      Adelie  Torgersen           39.5          17.4               186</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 3</span> Adelie      Adelie  Torgersen           40.3          18                 195</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 4</span> Adelie      Adelie  Torgersen           <span style='color: #BB0000;'>NA</span>            <span style='color: #BB0000;'>NA</span>                  <span style='color: #BB0000;'>NA</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 5</span> Adelie      Adelie  Torgersen           36.7          19.3               193</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 6</span> Adelie      Adelie  Torgersen           39.3          20.6               190</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 7</span> Adelie      Adelie  Torgersen           38.9          17.8               181</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 8</span> Adelie      Adelie  Torgersen           39.2          19.6               195</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 9</span> Adelie      Adelie  Torgersen           34.1          18.1               193</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>10</span> Adelie      Adelie  Torgersen           42            20.2               190</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># ℹ more rows</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># ℹ 2 more variables: body_mass_g &lt;int&gt;, sex &lt;chr&gt;</span></span></span>
<span></span></code></pre>

</div>

## Acknowledgements

A big thank you to all the people who have contributed to orbital since the release of v0.3.0:

[@EmilHvitfeldt](https://github.com/EmilHvitfeldt), [@joscani](https://github.com/joscani), [@jrosell](https://github.com/jrosell), [@npelikan](https://github.com/npelikan), and [@szimmer](https://github.com/szimmer).

