---
title: generics 0.0.1
date: 2018-11-14
slug: generics-0.0.1
author: Max Kuhn, Davis Vaughan
categories: [package]
tags:
  - generics
  - r-lib
description: >
    Reduce package dependencies by using common lightweight S3 generics.
photo:
  url: https://unsplash.com/photos/9GMO0Sxyw_Y
  author: Jonathan Knepper
---



The [`generics`](https://github.com/r-lib/generics) package is now on CRAN. `generics` is a lightweight package that is designed to help developers reduce dependencies for their packages.

The idea is to have many generic S3 functions live in a single package that has almost no dependencies. Normally, if you wanted to create a `broom::tidy()` method, you would import `broom` as a dependency, import the `tidy()` generic, then export it so that package users can have access to that specific method. One issue with this is that your package now carries along the dependencies of the package that defines the generic (in this case, `broom`).

Consider `fit()`. There are at least 15 packages that export an object called `fit` (either a function or method), and at least 12 have specific S3 `fit()` methods. When more than one is loaded, there is a potential for conflicts to arise:

```r
library(NMF)
library(text2vec)
#> 
#> Attaching package: 'text2vec'
#> The following object is masked from 'package:NMF':
#> 
#>     fit
```

`generics` provides a way to avoid such conflicts. To do so, a package would include `generics` as an import dependency, import the generic function of interest, then re-export using the `roxygen2` commands:

```r
#' @importFrom generics fit
#' @export
generics::fit
```

One interesting aspect of the package is that the `generics` function documentation is dynamic. Suppose that `generics` is loaded in a clean R session. If you look at the help file `?generics::tidy`, the documentation page has:

```
Methods:

     No methods found in currently loaded packages.
```

However, once another package is loaded with an exported `tidy()` method, `?generics::tidy` shows a list of all exported methods and includes a link to the help page specific to each one. For example, after loading the `embed` package:

```
Methods:

     See the following help topics for more details about individual
     methods:

     ‘embed’

        • ‘step_embed’: ‘step_embed’

        • ‘step_lencode_bayes’: ‘step_lencode_bayes’

        • ‘step_lencode_glm’: ‘step_lencode_glm’

        • ‘step_lencode_mixed’: ‘step_lencode_mixed’

     ‘recipes’

        • ‘check_cols’: ‘check_cols’

        • ‘check_missing’: ‘check_missing’

        • ‘check_range’: ‘check_range’
```

The current list of S3 generics that are included in the package are: `as.factor`, `as.ordered`, `augment`, `calculate`, `compile`, `components`, `equation`, `estfun`, `evaluate`, `explain`, `fit`, `fit_xy`, `generate`, `glance`, `hypothesize`, `interpolate`, `intersect`, `is.element`, `learn`, `prune`, `refit`, `setdiff`, `setequal`, `specify`, `tidy`, `train`, `union`, `var_imp`, `varying_args`, and `visualize`.

Thanks to those who contributed to the discussion prior to releasing the package: Achim Zeileis, Alex Hayes, Andrew Bray, Andy Liaw, Chester Ismay, Davis Vaughan, Hadley Wickham, Mitchell O'Hara-Wild, Przemyslaw Biecek, Rob Hyndman, Thomas Lin Pedersen, and Torsten Hothorn.
 
