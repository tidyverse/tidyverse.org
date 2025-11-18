---
output: hugodown::hugo_document

slug: tidymodels-2025-q3
title: Q3 2025 tidymodels digest
date: 2025-11-18
author: Emil Hvitfeldt
description: >
    A summary of what has been going on for the tidymodels group in the mid 2025.

photo:
  url: https://unsplash.com/photos/autumn-trees-with-colorful-leaves-in-a-park-Qx6Ojv9WPo8
  author: Anurag Jamwal

# one of: "deep-dive", "learn", "package", "programming", "roundup", or "other"
categories: [roundup] 
tags: [tidymodels]
rmd_hash: 0cc22455fc61a268

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

The tidymodels framework is a collection of R packages for modeling and machine learning using tidyverse principles.

Since the beginning of 2021, we have been publishing quarterly updates here on the tidyverse blog summarizing what's new in the tidymodels ecosystem. The purpose of these regular posts is to share useful new features and any updates you may have missed. You can check out the tidymodels tag to find all tidymodels blog posts here, including our roundup posts as well as those that are more focused.

Since our last update we have had some larger releases that you can read about in these posts.

-   [tune 2.0.0](https://tidyverse.org/blog/2025/11/tune-2/)
-   [recipes 1.3.0](https://tidyverse.org/blog/2025/04/recipes-1-3-0/)
-   [rsample 1.3.0](https://tidyverse.org/blog/2025/04/rsample-1-3-0/)
-   [improved sparsity support in tidymodels](https://tidyverse.org/blog/2025/03/tidymodels-sparsity/)

The post will update, you on which packages have changed and the improvements you should know about that haven't been covered in the above posts.

Here's a list of the packages and their News sections:

-   [dials](https://dials.tidymodels.org/news/index.html)
-   [parsnip](https://parsnip.tidymodels.org/news/index.html)
-   [rsample](https://rsample.tidymodels.org/news/index.html)
-   [recipes](https://recipes.tidymodels.org/news/index.html)
-   [probably](https://probably.tidymodels.org/news/index.html)
-   [brulee](https://brulee.tidymodels.org/news/index.html)

Let's look at a few specific updates.

## Quiet linear svm models

When you used to fit a linear SVM model, you would get a message that you were not able to avoid.

``` r
library(parsnip)
library(modeldata)

res <- 
  svm_linear(mode = "classification", engine = "kernlab") |> 
  fit(Class ~ ., data = two_class_dat)
#>  Setting default kernel parameters
```

This message by itself was not that useful and was unable to turn off in a reasonable way. We have silenced this message to hopefully alleviate some of the noise that came from using this method.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://github.com/tidymodels/parsnip'>parsnip</a></span><span class='o'>)</span></span>
<span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://modeldata.tidymodels.org'>modeldata</a></span><span class='o'>)</span></span>
<span><span class='c'>#&gt; </span></span>
<span><span class='c'>#&gt; Attaching package: 'modeldata'</span></span>
<span></span><span><span class='c'>#&gt; The following object is masked from 'package:datasets':</span></span>
<span><span class='c'>#&gt; </span></span>
<span><span class='c'>#&gt;     penguins</span></span>
<span></span><span></span>
<span><span class='nv'>res</span> <span class='o'>&lt;-</span> </span>
<span>  <span class='nf'><a href='https://parsnip.tidymodels.org/reference/svm_linear.html'>svm_linear</a></span><span class='o'>(</span>mode <span class='o'>=</span> <span class='s'>"classification"</span>, engine <span class='o'>=</span> <span class='s'>"kernlab"</span><span class='o'>)</span> <span class='o'>|&gt;</span> </span>
<span>  <span class='nf'><a href='https://generics.r-lib.org/reference/fit.html'>fit</a></span><span class='o'>(</span><span class='nv'>Class</span> <span class='o'>~</span> <span class='nv'>.</span>, data <span class='o'>=</span> <span class='nv'>two_class_dat</span><span class='o'>)</span></span>
<span><span class='nv'>res</span></span>
<span><span class='c'>#&gt; parsnip model object</span></span>
<span><span class='c'>#&gt; </span></span>
<span><span class='c'>#&gt; Support Vector Machine object of class "ksvm" </span></span>
<span><span class='c'>#&gt; </span></span>
<span><span class='c'>#&gt; SV type: C-svc  (classification) </span></span>
<span><span class='c'>#&gt;  parameter : cost C = 1 </span></span>
<span><span class='c'>#&gt; </span></span>
<span><span class='c'>#&gt; Linear (vanilla) kernel function. </span></span>
<span><span class='c'>#&gt; </span></span>
<span><span class='c'>#&gt; Number of Support Vectors : 361 </span></span>
<span><span class='c'>#&gt; </span></span>
<span><span class='c'>#&gt; Objective Function Value : -357.1487 </span></span>
<span><span class='c'>#&gt; Training error : 0.178255 </span></span>
<span><span class='c'>#&gt; Probability model included.</span></span>
<span></span></code></pre>

</div>

## Fewer numeric overflow issues in brulee

The brulee package has been improved to try to help avoid numeric overflow in the loss functions. The following things have been done to help deal with this type of issue.

-   Starting values were transitioned to using Gaussian distribution (instead of uniform) with a smaller standard deviation.

-   The results always contain the initial results to use as a fallback if there is overflow during the first epoch.

-   `brulee_mlp()` has two additional parameters, `grad_value_clip` and `grad_value_clip`, that prevent issues.

-   The warning was changed to "Early stopping occurred at epoch {X} due to numerical overflow of the loss function."

## Additional torch optimizers in brulee

Several additional optimizers have been added: `"ADAMw"`, `"Adadelta"`, `"Adagrad"`, and `"RMSprop"`. Previously, the options were `"SGD"` and `LBFGS"`. \## Acknowledgements

We want to sincerely thank everyone who contributed to these packages since their previous versions:

-   dials: [@brendad8](https://github.com/brendad8), [@hfrick](https://github.com/hfrick), [@topepo](https://github.com/topepo), and [@Wander03](https://github.com/Wander03).
-   parsnip: [@chillerb](https://github.com/chillerb), [@EmilHvitfeldt](https://github.com/EmilHvitfeldt), [@jmgirard](https://github.com/jmgirard), [@topepo](https://github.com/topepo), and [@ZWael](https://github.com/ZWael).
-   rsample: [@abichat](https://github.com/abichat), [@hfrick](https://github.com/hfrick), [@mkiang](https://github.com/mkiang), and [@vincentarelbundock](https://github.com/vincentarelbundock).
-   recipes: [@EmilHvitfeldt](https://github.com/EmilHvitfeldt), [@SimonDedman](https://github.com/SimonDedman), and [@topepo](https://github.com/topepo).
-   probably: [@abichat](https://github.com/abichat), [@ayueme](https://github.com/ayueme), [@dchiu911](https://github.com/dchiu911), [@EmilHvitfeldt](https://github.com/EmilHvitfeldt), [@frankiethull](https://github.com/frankiethull), [@gaborcsardi](https://github.com/gaborcsardi), [@hfrick](https://github.com/hfrick), [@Jeffrothschild](https://github.com/Jeffrothschild), [@jgaeb](https://github.com/jgaeb), [@jrwinget](https://github.com/jrwinget), [@mark-burdon](https://github.com/mark-burdon), [@martinhulin](https://github.com/martinhulin), [@simonpcouch](https://github.com/simonpcouch), [@teunbrand](https://github.com/teunbrand), [@topepo](https://github.com/topepo), [@wjakethompson](https://github.com/wjakethompson), and [@yellowbridge](https://github.com/yellowbridge).
-   brulee: [@genec1](https://github.com/genec1), [@talegari](https://github.com/talegari), and [@topepo](https://github.com/topepo).

