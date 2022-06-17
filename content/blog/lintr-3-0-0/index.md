---
output: hugodown::hugo_document

slug: lintr-3-0-0
title: lintr 3.0.0
date: 2022-06-14
author: Michael Chirico
description: >
    lintr 3.0.0 is a major release featuring a more consistent
    API for using linter and dozens of new linters included

photo:
  url: https://unsplash.com/photos/tt_HFMMae1w
  author: Hai Tran

# one of: "deep-dive", "learn", "package", "programming", "roundup", or "other"
categories: [package] 
tags: [lintr]

---

<!--
TODO:
* [x] Look over / edit the post's title in the yaml
* [x] Edit (or delete) the description; note this appears in the Twitter card
* [x] Pick category and tags (see existing with `hugodown::tidy_show_meta()`)
* [x] Find photo & update yaml metadata
* [ ] Create `thumbnail-sq.jpg`; height and width should be equal
* [ ] Create `thumbnail-wd.jpg`; width should be >5x height
* [ ] `hugodown::use_tidy_thumbnails()`
* [x] Add intro sentence, e.g. the standard tagline for the package
* [x] `usethis::use_tidy_thanks()`
-->

We are very excited to announce the release of [lintr](https://lintr.r-lib.org) 3.0.0! lintr provides
both a framework for [static analysis](https://www.perforce.com/blog/sca/what-static-analysis) of R packages
and scripts and a variety of linters, e.g. to enforce the [tidyverse style guide](https://style.tidyverse.org/).

You can install it from CRAN with:

```r
install.packages("lintr")
```

Check our vignettes for a quick introduction to the package:
 - Getting started ([`vignette("lintr")`](https://lintr.r-lib.org/articles/lintr.html))
 - Integrating lintr with your preferred IDE ([`vignette("editors")`](https://lintr.r-lib.org/articles/editors.html))
 - Integrating lintr with your preferred CI tools ([`vignette("continuous-integration")`](https://lintr.r-lib.org/articles/continuous-integration.html))

We've also added `lintr::use_lintr()` for a usethis-inspired interactive tool to configure lintr for your package/repo.

This blog post will highlight the biggest changes coming in this update which drove us to declare it a major release.

# Release highlights

## Selective exclusions

lintr now supports targeted exclusions of specific linters through an extension of the `# nolint` syntax.

Consider the following example:

```r
T_and_F_symbol_linter=function(){
  list()
}
```

This snippet generates 5 lints:

 1. `object_name_linter()` because the uppercase `T` and `F` do not match `lower_snake_case`
 2. `brace_linter()` because `{` should be separated from `)` by a space
 3. `paren_body_linter()` because `)` should be separated from the function body (starting at `{`) by a space
 4. `infix_spaces_linter()` because `=` should be surrounded by spaces on both sides
 5. `assignment_linter()` because `<-` should be used for assignment

The first lint is spurious because `t` and `f` do not correctly convey that this linter targets
the symbols `T` and `F`, so we want to ignore it. Prior to this release, we would have to
"throw the baby out with the bathwater" by suppressing _all five lints_ like so:

```r
T_and_F_symbol_linter=function(){ # nolint. T and F are OK here.
  list()
}
```

This hides the other four lints and prevents any new lints from being detected on this line in the future,
which on average allows the overall quality of your projects/scripts to dip.

With the new feature, you'd write the exclusion like this instead:

```r
T_and_F_symbol_linter=function(){ # nolint: object_name_linter. T and F are OK here.
  list()
}
```

By qualifying the exclusion, the other 4 lints will be detected and exposed by `lint()` so
that you can fix them! See `?exclude` for more details.

## Linter factories

As of lintr 3.0.0, _all_ linters must be [function factories](https://adv-r.hadley.nz/function-factories.html).

Previously, only parameterizable linters (such as `line_length_linter`, which takes a parameter controlling how
wide lines are allowed to be without triggering a lint) were factories, but this led to some problems:

 1. Inconsistency -- some linters were designated as calls like `line_length_linter(120)` while others were
    designated as names like `no_tab_linter`
 2. Brittleness -- some linters evolve to gain (or lose) parameters over time, e.g. in this release
    `assignment_linter` gained two arguments, `allow_cascading_assign` and `allow_right_assign`,
    to fine-tune the handling of the cascading assignment operators `<<-`/`->>` and
    right assignment operators `->`/`->>`, respectively)
 3. Performance -- factories can run some fixed computations at declaration and store them in the
    function environment, whereas previously the calculation would need to be repeated on every
    expression of every file being linted

This has two significant practical implications and are the main reason this is a major release.

First, lintr invocations should always use the call form, so old usages like:

```r
lint_package(linters = assignment_linter)
```

should be replaced with:

```r
lint_package(linters = assignment_linter())
```

We expect this to show up in most cases through users' .lintr configuration files.

Second, users implementing custom linters need to convert to function factories.

That means replacing:

```r
my_custom_linter <- function(source_expression) { ... }
```

With:

```r
my_custom_linter <- function() Linter(function(source_expression) { ... }))
```

`Linter()` is a wrapper to construct the `linter` S3 class.

## Linter metadatabase, linter documentation, and pkgdown

We have also overhauled how linters are documented. Previously, all linters
were documented on a single page and described in a quick blurb. This has
gotten unwieldy as lintr has grown to export 72 linters! Now, each linter gets its own
page, which will make it easier to document any parameters, enumerate edge cases/
known false positives, add links to external resources, etc.

To make linter discovery even more navigable, we've also added `available_linters()`, a
database with known linters and some associated metadata tags for each.
For example, `brace_linter` has tags `style`, `readability`, `default`, and `configurable`.
Each tag also gets its own documentation page (e.g. `?readability_linters`) which describes the tag
and lists all of the known associated linters. The tags are available in another database:
`available_tags()`. These databases can be extended to include custom linters in your package;
see `?available_linters`.

Moreover, lintr's documentation is now available as a website thanks to
Hadley Wickham's contribution to create a pkgdown website for the package:
[lintr.r-lib.org](https://lintr.r-lib.org).

## Google linters

This release also features more than 30 new linters originally authored by Google developers.
Google adheres mostly to the tidyverse style guide and uses lintr to improve the quality
of its considerable internal R code base. These linters detect common issues with
readability, consistency, and performance. Here are some examples:

 - `any_is_na_linter()` detects the usage of `any(is.na(x))`; `anyNA(x)` is nearly always a better choice,
   both for performance and for readability
 - `expect_named_linter()` detects usage in [testthat](http://testthat.r-lib.org/) suites like
   `expect_equal(names(x), c("a", "b", "c"))`; `testthat` also exports `expect_named()` which is
   tailor made to make more readable tests like `expect_named(x, c("a", "b", "c"))`
 - `vector_logic_linter()` detects usage of vector logic operators `|` and `&` in situations where
   scalar logic applies, e.g. `if (x | y) { ... }` should be `if (x || y) { ... }`. The latter
   is more efficient and less error-prone.
 - `strings_as_factors_linter()` helps developers maintaining code that straddles the R 4.0.0 boundary,
   where the default value of `stringsAsFactors`
   [changed from `TRUE` to `FALSE`](https://developer.r-project.org/Blog/public/2020/02/16/stringsasfactors/),
   by identifying usages of `data.frame()` that (1) have known string columns and (2) don't declare
   a value for `stringsAsFactors`, and thus rely on the R version-dependent default.

See the [NEWS](https://lintr.r-lib.org/news/index.html#google-linters-3-0-0) for the complete list.

## Other improvements

This is a big release -- almost 2 years in the making -- and there has been a plethora of smaller
but nonetheless important changes to lintr. Please check the
[NEWS](https://lintr.r-lib.org/news/index.html#lintr-300)
for a complete enumeration of these. Here are a few more new linters as a highlight:

 - `sprintf_linter()`: a new linter for detecting potentially problematic calls to `sprintf()` (e.g.
   using too many or too few arguments as compared to the number of template fields)
 - `package_hooks_linter()`: a new linter to check consistency of `.onLoad()` functions and
   other namespace hooks, as required by `R CMD check`
 - `namespace_linter()`: a new linter to check for common mistakes in `pkg::symbol` usage, e.g.
   if `symbol` is not an exported object from `pkg`

# What's next in lintr

## Hosting linters for non-tidyverse style guides?

With the decision to accept a bevy of linters from Google that are not strictly related to the tidyverse
style guide, we also opened the door to hosting linters for enforcing other style guides, for example
the [Bioconductor R code guide](https://contributions.bioconductor.org/r-code.html). We look forward to
community contributions in this vein.

## More Google linters

Google has developed and tested many more broad-purpose linters that it plans to share, e.g. for
detecting `length(which(x == y)) > 0` (i.e., `any(x == y)`), `lapply(x, function(xi) sum(xi))`
(i.e., `lapply(x, sum)`), `c("key_name" = "value_name")` (i.e., `c(key_name = "value_name")`),
and more! Follow [#884](https://github.com/r-lib/lintr/issues/884) for updates.

# Acknowledgements

Welcome [Alexander Rosenstock](@AshesITR), [Kun Ren](@renkun-ken),
and [Michael Chirico](@MichaelChirico) to the lintr authors team!

And a great big thanks to the other 97 people who have contributed to this release of lintr:

[&#x0040;1beb](https://github.com/1beb), [&#x0040;albert-ying](https://github.com/albert-ying), [&#x0040;aronatkins](https://github.com/aronatkins), [&#x0040;AshesITR](https://github.com/AshesITR), [&#x0040;assignUser](https://github.com/assignUser), [&#x0040;barryrowlingson](https://github.com/barryrowlingson), [&#x0040;belokoch](https://github.com/belokoch), [&#x0040;bersbersbers](https://github.com/bersbersbers), [&#x0040;bsolomon1124](https://github.com/bsolomon1124), [&#x0040;chrisumphlett](https://github.com/chrisumphlett), [&#x0040;csgillespie](https://github.com/csgillespie), [&#x0040;danielinteractive](https://github.com/danielinteractive), [&#x0040;dankessler](https://github.com/dankessler), [&#x0040;dgkf](https://github.com/dgkf), [&#x0040;dinakar29](https://github.com/dinakar29), [&#x0040;dmurdoch](https://github.com/dmurdoch), [&#x0040;dpprdan](https://github.com/dpprdan), [&#x0040;dragosmg](https://github.com/dragosmg), [&#x0040;dschlaep](https://github.com/dschlaep), [&#x0040;eitsupi](https://github.com/eitsupi), [&#x0040;ElsLommelen](https://github.com/ElsLommelen), [&#x0040;f-ritter](https://github.com/f-ritter), [&#x0040;fabian-s](https://github.com/fabian-s), [&#x0040;fdlk](https://github.com/fdlk), [&#x0040;fornaeffe](https://github.com/fornaeffe), [&#x0040;frederic-mahe](https://github.com/frederic-mahe), [&#x0040;GiuseppeTT](https://github.com/GiuseppeTT), [&#x0040;hadley](https://github.com/hadley), [&#x0040;hhoeflin](https://github.com/hhoeflin), [&#x0040;hrvg](https://github.com/hrvg), [&#x0040;huisman](https://github.com/huisman), [&#x0040;iago-pssjd](https://github.com/iago-pssjd), [&#x0040;IndrajeetPatil](https://github.com/IndrajeetPatil), [&#x0040;inventionate](https://github.com/inventionate), [&#x0040;ishaar226](https://github.com/ishaar226), [&#x0040;jabenninghoff](https://github.com/jabenninghoff), [&#x0040;jameslamb](https://github.com/jameslamb), [&#x0040;jennybc](https://github.com/jennybc), [&#x0040;jeremymiles](https://github.com/jeremymiles), [&#x0040;jhgoebbert](https://github.com/jhgoebbert), [&#x0040;jimhester](https://github.com/jimhester), [&#x0040;johanneswerner](https://github.com/johanneswerner), [&#x0040;jonkeane](https://github.com/jonkeane), [&#x0040;JSchoenbachler](https://github.com/JSchoenbachler), [&#x0040;JWiley](https://github.com/JWiley), [&#x0040;karlvurdst](https://github.com/karlvurdst), [&#x0040;klmr](https://github.com/klmr), [&#x0040;Kotsakis](https://github.com/Kotsakis), [&#x0040;kpagacz](https://github.com/kpagacz), [&#x0040;kpj](https://github.com/kpj), [&#x0040;latot](https://github.com/latot), [&#x0040;leogama](https://github.com/leogama), [&#x0040;liar666](https://github.com/liar666), [&#x0040;logstar](https://github.com/logstar), [&#x0040;lorenzwalthert](https://github.com/lorenzwalthert), [&#x0040;maelle](https://github.com/maelle), [&#x0040;markromanmiller](https://github.com/markromanmiller), [&#x0040;mattwarkentin](https://github.com/mattwarkentin), [&#x0040;maxheld83](https://github.com/maxheld83), [&#x0040;MichaelChirico](https://github.com/MichaelChirico), [&#x0040;michaelquinn32](https://github.com/michaelquinn32), [&#x0040;mikekaminsky](https://github.com/mikekaminsky), [&#x0040;milanglacier](https://github.com/milanglacier), [&#x0040;minimenchmuncher](https://github.com/minimenchmuncher), [&#x0040;mjsteinbaugh](https://github.com/mjsteinbaugh), [&#x0040;nathaneastwood](https://github.com/nathaneastwood), [&#x0040;nlarusstone](https://github.com/nlarusstone), [&#x0040;nsoranzo](https://github.com/nsoranzo), [&#x0040;nvuillam](https://github.com/nvuillam), [&#x0040;pakjiddat](https://github.com/pakjiddat), [&#x0040;pat-s](https://github.com/pat-s), [&#x0040;prncevince](https://github.com/prncevince), [&#x0040;QiStats-Joel](https://github.com/QiStats-Joel), [&#x0040;rahulrachh](https://github.com/rahulrachh), [&#x0040;razz-matazz](https://github.com/razz-matazz), [&#x0040;renkun-ken](https://github.com/renkun-ken), [&#x0040;rfalke](https://github.com/rfalke), [&#x0040;richfitz](https://github.com/richfitz), [&#x0040;russHyde](https://github.com/russHyde), [&#x0040;salim-b](https://github.com/salim-b), [&#x0040;schaffstein](https://github.com/schaffstein), [&#x0040;scottmmjackson](https://github.com/scottmmjackson), [&#x0040;sgvignali](https://github.com/sgvignali), [&#x0040;shaopeng-gh](https://github.com/shaopeng-gh), [&#x0040;StefanBRas](https://github.com/StefanBRas), [&#x0040;stefaneng](https://github.com/stefaneng), [&#x0040;stefanocoretta](https://github.com/stefanocoretta), [&#x0040;stufield](https://github.com/stufield), [&#x0040;TCABJ](https://github.com/TCABJ), [&#x0040;telegott](https://github.com/telegott), [&#x0040;ThierryO](https://github.com/ThierryO), [&#x0040;thisisnic](https://github.com/thisisnic), [&#x0040;tonyk7440](https://github.com/tonyk7440), [&#x0040;wfmueller29](https://github.com/wfmueller29), [&#x0040;wibeasley](https://github.com/wibeasley), [&#x0040;yannickwurm](https://github.com/yannickwurm), and [&#x0040;yutannihilation](https://github.com/yutannihilation).