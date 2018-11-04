The `generics` package is now on CRAN . `generics` is a lightweight package that is designed to help developers reduce dependencies for their packages. 

The idea is to have many generic S3 methods definitions live in a single package with almost no dependencies. For example, if you wanted to use a `broom` `tidy` method, you would use `broom` as an import dependency, import the `tidy` method, then export it so that your package can have a specific method. One issue with this is that your package now carries along the dependencies of the package that defines the generic (in this case, `broom`). 

Consider the `fit` method. There are at least 15 packages that export an object called `fit` (either a function or method) and at least 12 have specific S3 `fit` methods. When more than one are loaded, there is the potential for conflicts to arise:

```r
> library(NMF)
Loading required package: pkgmaker
Loading required package: registry

Attaching package: ‘pkgmaker’

The following object is masked from ‘package:base’:

    isFALSE

Loading required package: rngtools
Loading required package: cluster
NMF - BioConductor layer [OK] | Shared memory capabilities [NO: bigmemory] | Cores 19/20
  To enable shared memory capabilities, try: install.extras('
NMF
')

> library(text2vec)
text2vec is still in beta version - APIs can be changed.
For tutorials and examples visit http://text2vec.org.

For FAQ refer to
  1. https://stackoverflow.com/questions/tagged/text2vec?sort=newest
  2. https://github.com/dselivanov/text2vec/issues?utf8=%E2%9C%93&q=is%3Aissue%20label%3Aquestion
If you have questions please post them at StackOverflow and mark with 'text2vec' tag.

Attaching package: ‘text2vec’

The following object is masked from ‘package:NMF’:

    fit

The following object is masked from ‘package:BiocGenerics’:

    normalize

```

`generics` could allow these packages to avoid such conflicts. To do so, a package would include `generics` as an import dependency, import the generic method of interest, then re-export using the `roxygen2` commands:

```r
#' @importFrom generics fit
#' @export
generics::fit
```  

One interesting aspect of the package is that the `generics` documentation for the methods are dynamic. Suppose that `generics` is loaded in a clean R session. If you look at the help file `?generics::tidy`, the documentation page has:

```
Methods:

     No methods found in currently loaded packages.
```

However, once another package is loaded with an exported `tidy` method, `?generics::tidy` shows a list of all exported methods. For example, after loading the `embed` package: 

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

<snip>
```

The current list of S3 generics that are included in the package are: `as.factor`, `as.ordered`, `augment`, `calculate`, `compile`, `components`, `equation`, `estfun`, `evaluate`, `explain`, `fit`, `fit_xy`, `generate`, `glance`, `hypothesize`, `interpolate`, `intersect`, `is.element`, `learn`, `prune`, `refit`, `setdiff`, `setequal`, `specify`, `tidy`, `train`, `union`, `var_imp`, `varying_args`, and `visualize`. 

Thanks to those who contributed to the discussion prior to releasing the package: Achim Zeileis, Alex Hayes, Andrew Bray, Andy Liaw, Chester Ismay, Davis Vaughan, Hadley Wickham, Mitchell O'Hara-Wild, Przemyslaw Biecek, Rob Hyndman, Thomas Lin Pedersen, and Torsten Hothorn. 

