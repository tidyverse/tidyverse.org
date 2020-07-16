---
output: hugodown::hugo_document

slug: broom-0-7-0
title: broom 0.7.0
date: 2020-07-17
author: Simon Couch and Alex Hayes
description: >
    The newest release of broom features many new tidier methods, bug fixes, and
    improvements to internal consistency.

photo:
  url: https://unsplash.com/photos/3gS-lDkOuJ4
  author: Timothy Dykes

categories: [package] 
tags:
  - tidymodels
rmd_hash: 139ec680ae431425

---

We're excited to announce the release of broom 0.7.0 on CRAN!

broom is a package for summarizing statistical model objects in tidy tibbles. While several compatibility updates have been released in recent months, this is the first major update to broom in almost two years. This update includes many new tidier methods, bug fixes, improvements to existing tidier methods and their documentation, and improvements to maintainability and internal consistency. The full list of changes is available in the package [release notes](https://broom.tidymodels.org/news/index.html).

This release was made possible in part by the RStudio internship program, which has allowed one of us ([Simon Couch](https://github.com/simonpcouch)) to work on broom full-time for the last month.

You can install the most recent broom update with the following code:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'>install.packages</span>(<span class='s'>"broom"</span>)</code></pre>

</div>

Then attach it for use with:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'>library</span>(<span class='k'><a href='https://broom.tidymodels.org/reference'>broom</a></span>)</code></pre>

</div>

We'll outline some of the more notable changes below!

### New Tidier Methods

For one, this release includes support for several new model objects---many of these additions came from first-time contributors to broom!

-   `anova` objects from the `car` package
-   `pam` objects from the `cluster` package
-   `drm` objects from the `drc` package
-   `summary_emm` objects from the `emmeans` package
-   `epi.2by2` objects from the `epiR` package
-   `fixest` objects from the `fixest` package
-   `regsubsets` objects from the `leaps` package
-   `lm.beta` objects from the `lm.beta` package
-   `rma` objects from the `metafor` package
-   `mfx`, `logitmfx`, `negbinmfx`, `poissonmfx`, `probitmfx`, and `betamfx` objects from the`mfx` package
-   `lmrob` and `glmrob` objects from the `robustbase` package
-   `sarlm` objects from the `spatialreg` package
-   `speedglm` objects from the `speedglm` package
-   `svyglm` objects from the `survey` package
-   We have restored a simplified version of [`glance.aov()`](https://broom.tidymodels.org/reference/glance.aov.html)

### Improvements and Bug Fixes for Existing Tidiers

This update also features many bug fixes improvements to existing tidiers. Some of the more notable ones:

-   Many improvements to the consistency of `augment.*()` methods:
    -   If you pass a dataset to [`augment()`](https://rdrr.io/pkg/generics/man/augment.html) via the `data` or `newdata` arguments, you are now guaranteed that the augmented dataset will have exactly the same number of rows as the original dataset. This differs from previous behavior primarily when there are missing values. Previously [`augment()`](https://rdrr.io/pkg/generics/man/augment.html) would drop rows containing `NA`. This should no longer be the case. As a result, `augment.*()` methods no longer accept an `na.action` argument.
    -   In previous versions, several `augment.*()` methods inherited the [`augment.lm()`](https://broom.tidymodels.org/reference/augment.lm.html) method, but required additions to the [`augment.lm()`](https://broom.tidymodels.org/reference/augment.lm.html) method itself. We have shifted away from this approach in favor of re-implementing many `augment.*()` methods as standalone methods making use of internal helper functions. As a result, [`augment.lm()`](https://broom.tidymodels.org/reference/augment.lm.html) and some related methods have deprecated (previously unused) arguments.
    -   The `.resid` column in the output of `augment().*` methods is now consistently defined as `y - y_hat`.
    -   [`augment()`](https://rdrr.io/pkg/generics/man/augment.html) tries to give an informative error when `data` isn't the original training data.
-   Several `glance.*()` methods have been refactored in order to return a one-row tibble even when the model matrix is rank-deficient.
-   Many [`glance()`](https://rdrr.io/pkg/generics/man/glance.html) methods now return a `nobs` column, which contains the number of data points used to fit the model!
-   Various warnings resulting from changes to the tidyr API in v1.0.0 have been fixed.
-   Added options to provide additional columns in the outputs of [`glance.biglm()`](https://broom.tidymodels.org/reference/glance.biglm.html), [`tidy.felm()`](https://broom.tidymodels.org/reference/tidy.felm.html), `tidy.lmsobj()`, [`tidy.lmodel2()`](https://broom.tidymodels.org/reference/tidy.lmodel2.html), [`tidy.polr()`](https://broom.tidymodels.org/reference/tidy.polr.html), [`tidy.prcomp()`](https://broom.tidymodels.org/reference/tidy.prcomp.html), [`tidy.zoo()`](https://broom.tidymodels.org/reference/tidy.zoo.html), [`tidy_optim()`](https://broom.tidymodels.org/reference/tidy_optim.html)

### Breaking Changes and Deprecations

This release also contains a number of breaking changes and deprecations meant to improve maintainability and internal consistency.

-   We have changed how we report degrees of freedom for `lm` objects. This is especially important for instructors in statistics courses. Previously the `df` column in [`glance.lm()`](https://broom.tidymodels.org/reference/glance.lm.html) reported the rank of the design matrix. Now it reports degrees of freedom of the numerator for the overall F-statistic. This is equal to the rank of the model matrix minus one (unless you omit an intercept column), so the new `df` should be the old `df` minus one.
-   We are moving away from supporting `summary.*()` objects. In particular, we have removed `tidy.summary.lm()` as part of a major overhaul of internals. Instead of calling [`tidy()`](https://rdrr.io/pkg/generics/man/tidy.html) on `summary`-like objects, please call [`tidy()`](https://rdrr.io/pkg/generics/man/tidy.html) directly on model objects moving forward.
-   We have removed all support for the `quick` argument in [`tidy()`](https://rdrr.io/pkg/generics/man/tidy.html) methods. This is to simplify internals and is for maintainability purposes. We anticipate this will not influence many users as few people seemed to use it. If this majorly cramps your style, let us know, as we are considering a new verb to return only model parameters. In the meantime, [`stats::coef()`](https://rdrr.io/r/stats/coef.html) together with [`tibble::enframe()`](https://tibble.tidyverse.org/reference/enframe.html) provides most of the functionality of [`tidy(..., quick = TRUE)`](https://rdrr.io/pkg/generics/man/tidy.html).
-   All `conf.int` arguments now default to `FALSE`, and all `conf.level` arguments now default to `0.95`. This should primarily affect [`tidy.survreg()`](https://broom.tidymodels.org/reference/tidy.survreg.html), which previously always returned confidence intervals, although there are some others.
-   Tidiers for `emmeans`-objects use the arguments `conf.int` and `conf.level` instead of relying on the argument names native to the `emmeans::summary()`-methods (i.e., `infer` and `level`). Similarly, `multcomp`-tidiers now include a call to `summary()` as previous behavior was akin to setting the now removed argument `quick = TRUE`. Both families of tidiers now use the `adj.p.value` column name when appropriate. Finally, `emmeans`-, `multcomp`-, and `TukeyHSD`-tidiers now consistently use the column names `contrast` and `null.value` instead of `comparison`, `level1` and `level2`, or `lhs` and `rhs`.

This release of broom also deprecates several helper functions as well as tidier methods for a number of non-model objects, each in favor of more principled approaches from other packages (outlined in the NEWS file). Notably, though, tidiers have been deprecated for data frames, rowwise data frames, vectors, and matrices. Further, we have moved forward with the planned transfer of tidiers for mixed models to `broom.mixed`.

### Other Changes

Most all unit testing for the package is now supported by the [modeltests](https://github.com/alexpghayes/modeltests) package!

Also, we have revised several vignettes and moved them to the tidymodels website. For backward compatibility, the existing vignettes will now simply link to the revised versions.

Finally, the package's website has moved from its previous tidyverse domain to [broom.tidymodels.org](https://broom.tidymodels.org/).

### Looking Forward

Most notably, **the broom dev team generally is changing the process to add new tidying methods to the package.** Instead, we ask that issues/PRs requesting support for new model objects be directed to the model-owning package (i.e. the package that the model is exported from) rather than to broom. If the maintainers of those packages are unable or unwilling to provide tidying methods in the model-owning package, we would then welcome a PR with a new tidier to broom.

For developers exporting tidying methods directly from model-owning packages, we are actively working to provide resources to both ease the process of writing new tidiers methods and reduce the dependency burden of taking on broom generics and helpers. As for the first point, we recently posted an [article](https://www.tidymodels.org/learn/develop/broom/) on the tidymodels website providing notes on best practices for writing tidiers. This article will be kept up to date as we develop new resources for easing the process of writing new tidier methods. As for the latter, the [`r-lib/generics`](https://github.com/r-lib/generics) package provides lightweight dependencies for the main broom generics. We hope to soon provide a coherent suite of helper functions for use in external broom methods.

We anticipate that the most active development on the broom package, looking forward, will center on improving [`augment()`](https://rdrr.io/pkg/generics/man/augment.html) methods. We are also hoping to change our CRAN release cycle and to provide incremental updates every several months rather than major changes every couple years.

### Contributors

This release features work and input from over 140 contributors (over 50 of them for their first time) since the last major release. See the package [release notes](https://broom.tidymodels.org/news/index.html) to see more specific notes on contributions. Thank you all for your thoughtful comments, patience, and hard work!

[@abbylsmith](https://github.com/abbylsmith), [@acoppock](https://github.com/acoppock), [@ajb5d](https://github.com/ajb5d), [@aloy](https://github.com/aloy), [@AndrewKostandy](https://github.com/AndrewKostandy), [@angusmoore](https://github.com/angusmoore), [@anniew](https://github.com/anniew), [@aperaltasantos](https://github.com/aperaltasantos), [@asbates](https://github.com/asbates), [@asondhi](https://github.com/asondhi), [@asreece](https://github.com/asreece), [@atyre2](https://github.com/atyre2), [@bachmeil](https://github.com/bachmeil), [@batpigandme](https://github.com/batpigandme), [@bbolker](https://github.com/bbolker), [@benjbuch](https://github.com/benjbuch), [@bfgray3](https://github.com/bfgray3), [@BibeFiu](https://github.com/BibeFiu), [@billdenney](https://github.com/billdenney), [@BrianOB](https://github.com/BrianOB), [@briatte](https://github.com/briatte), [@bruc](https://github.com/bruc), [@brunaw](https://github.com/brunaw), [@brunolucian](https://github.com/brunolucian), [@bschneidr](https://github.com/bschneidr), [@carlislerainey](https://github.com/carlislerainey), [@CGMossa](https://github.com/CGMossa), [@CharlesNaylor](https://github.com/CharlesNaylor), [@ChuliangXiao](https://github.com/ChuliangXiao), [@cimentadaj](https://github.com/cimentadaj), [@crsh](https://github.com/crsh), [@cwang23](https://github.com/cwang23), [@DavisVaughan](https://github.com/DavisVaughan), [@dchiu911](https://github.com/dchiu911), [@ddsjoberg](https://github.com/ddsjoberg), [@dgrtwo](https://github.com/dgrtwo), [@dmenne](https://github.com/dmenne), [@dylanjm](https://github.com/dylanjm), [@ecohen13](https://github.com/ecohen13), [@economer](https://github.com/economer), [@EDiLD](https://github.com/EDiLD), [@ekatko1](https://github.com/ekatko1), [@ellessenne](https://github.com/ellessenne), [@ethchr](https://github.com/ethchr), [@florencevdubois](https://github.com/florencevdubois), [@GegznaV](https://github.com/GegznaV), [@gershomtripp](https://github.com/gershomtripp), [@grantmcdermott](https://github.com/grantmcdermott), [@gregmacfarlane](https://github.com/gregmacfarlane), [@hadley](https://github.com/hadley), [@haozhu233](https://github.com/haozhu233), [@hasenbratan](https://github.com/hasenbratan), [@HenrikBengtsson](https://github.com/HenrikBengtsson), [@hermandr](https://github.com/hermandr), [@hideaki](https://github.com/hideaki), [@hughjonesd](https://github.com/hughjonesd), [@iago-pssjd](https://github.com/iago-pssjd), [@ifellows](https://github.com/ifellows), [@IndrajeetPatil](https://github.com/IndrajeetPatil), [@Inferrator](https://github.com/Inferrator), [@istvan60](https://github.com/istvan60), [@jamesmartherus](https://github.com/jamesmartherus), [@JanLauGe](https://github.com/JanLauGe), [@jasonyang5](https://github.com/jasonyang5), [@jaspercooper](https://github.com/jaspercooper), [@jcfisher](https://github.com/jcfisher), [@jennybc](https://github.com/jennybc), [@jessecambon](https://github.com/jessecambon), [@jkylearmstrongibx](https://github.com/jkylearmstrongibx), [@jmuhlenkamp](https://github.com/jmuhlenkamp), [@JulianMutz](https://github.com/JulianMutz), [@Jungpin](https://github.com/Jungpin), [@jwilber](https://github.com/jwilber), [@jyuu](https://github.com/jyuu), [@karissawhiting](https://github.com/karissawhiting), [@karldw](https://github.com/karldw), [@khailper](https://github.com/khailper), [@krauskae](https://github.com/krauskae), [@kuriwaki](https://github.com/kuriwaki), [@kyusque](https://github.com/kyusque), [@KZARCA](https://github.com/KZARCA), [@Laura-O](https://github.com/Laura-O), [@ldlpdx](https://github.com/ldlpdx), [@ldmahoney](https://github.com/ldmahoney), [@lilymedina](https://github.com/lilymedina), [@llendway](https://github.com/llendway), [@lrose1](https://github.com/lrose1), [@ltobalina](https://github.com/ltobalina), [@LukasWallrich](https://github.com/LukasWallrich), [@lukesonnet](https://github.com/lukesonnet), [@lwjohnst86](https://github.com/lwjohnst86), [@malcolmbarrett](https://github.com/malcolmbarrett), [@margarethannum](https://github.com/margarethannum), [@mariusbarth](https://github.com/mariusbarth), [@MatthieuStigler](https://github.com/MatthieuStigler), [@mattle24](https://github.com/mattle24), [@mattpollock](https://github.com/mattpollock), [@mattwarkentin](https://github.com/mattwarkentin), [@mine-cetinkaya-rundel](https://github.com/mine-cetinkaya-rundel), [@mkirzon](https://github.com/mkirzon), [@mlaviolet](https://github.com/mlaviolet), [@Move87](https://github.com/Move87), [@namarkus](https://github.com/namarkus), [@nlubock](https://github.com/nlubock), [@nmjakobsen](https://github.com/nmjakobsen), [@ns-1m](https://github.com/ns-1m), [@nt-williams](https://github.com/nt-williams), [@oij11](https://github.com/oij11), [@petrhrobar](https://github.com/petrhrobar), [@PirateGrunt](https://github.com/PirateGrunt), [@pjpaulpj](https://github.com/pjpaulpj), [@pkq](https://github.com/pkq), [@poppymiller](https://github.com/poppymiller), [@QuLogic](https://github.com/QuLogic), [@randomgambit](https://github.com/randomgambit), [@riinuots](https://github.com/riinuots), [@RobertoMuriel](https://github.com/RobertoMuriel), [@Roisin-White](https://github.com/Roisin-White), [@romainfrancois](https://github.com/romainfrancois), [@rsbivand](https://github.com/rsbivand), [@serina-robinson](https://github.com/serina-robinson), [@shabbybanks](https://github.com/shabbybanks), [@Silver-Fang](https://github.com/Silver-Fang), [@Sim19](https://github.com/Sim19), [@simonpcouch](https://github.com/simonpcouch), [@sjackson1236](https://github.com/sjackson1236), [@softloud](https://github.com/softloud), [@stefvanbuuren](https://github.com/stefvanbuuren), [@strengejacke](https://github.com/strengejacke), [@sushmitavgopalan16](https://github.com/sushmitavgopalan16), [@tcuongd](https://github.com/tcuongd), [@thisisnic](https://github.com/thisisnic), [@topepo](https://github.com/topepo), [@tyluRp](https://github.com/tyluRp), [@vincentarelbundock](https://github.com/vincentarelbundock), [@vjcitn](https://github.com/vjcitn), [@vnijs](https://github.com/vnijs), [@weiyangtham](https://github.com/weiyangtham), [@william3031](https://github.com/william3031), [@x249wang](https://github.com/x249wang), [@xieguagua](https://github.com/xieguagua), [@yrosseel](https://github.com/yrosseel), and [@zoews](https://github.com/zoews)

