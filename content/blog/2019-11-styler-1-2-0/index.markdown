---
title: "styler 1.2.0"
author: "Lorenz Walthert"
date: '2019-11-04'
description: |
  A major update of the styler package is available on CRAN now.
photo:
  author: Heng Films
  url: https://unsplash.com/photos/mpdIPhYqZ4Y
slug: styler-1-2-0
categories: ["package"]
tags:
  - styler
  - r-lib
---



We are pleased to announce that [styler](https://styler.r-lib.org) 1.2.0 is now available on CRAN. The 
[initial version of styler](https://www.tidyverse.org/articles/2017/12/styler-1.0.0/) 
was released in December 2017. Since then,
five new versions were released, and styler was improved substantially, but many
improvements were related to special cases or even edge cases. These are all
contained in the [change log](https://styler.r-lib.org/news/index.html). Here,
we want to focus on a few changes since version 1.0.0 that we believe are the 
most relevant. You can install the latest stable version from CRAN with
`install.packages("styler")`. Let's get started:


```r
library(styler)
```


## Alignment detection

styler can finally detect aligned code and keep it aligned! For example, the 
following code won't be modified by styler:


```r
call(
  some_arg = 123,
  more     = "x"
)
```

We've tried to make this as intuitive as possible, but have a look at 
[dedicated vignette](https://styler.r-lib.org/articles/detect-alignment.html)
when you are dealing with more complicated calls than the one above.
Note that the detection currently only works inside *function calls*, so styler will not 
recognize the below as aligned.


```r
x  <- 2
x2 <- f(x)

```

and turn it into


```r
x <- 2
x2 <- f(x)

```

unless you also use `strict = FALSE`.^[E.g. `styler::style_text(..., strict =
FALSE)`, but note that this also has other effects on styling that you might not
want.]

## rlang's {{

In [rlang 0.4.0](https://www.tidyverse.org/articles/2019/06/rlang-0-4-0/) a new
interpolation operator was introduced: `{{` (read curly curly). Because `styler
< 1.2.0` understood these as regular curly braces, you ended up with


```r
call({
  {
    x
  }
})
```

when styling `call({{x}})`, which is nonsense. Now styler yields `call({{ x
}})`.

## Addins

The *Style active file* addin now remembers the cursor position and the details
of styling can be specified as an R option:


```r
options(
  styler.addins_style_transformer = "styler::tidyverse_style(scope = 'spaces')"
)
```

You can also set the value of this option interactively with the *set style*
addin (not persistent over sessions). For details, see `help("styler_addins", "styler")` 
and `help("tidyverse_style", "styler")`.

The customization of the styling does not affect the command-line API
(`styler::style_text()` and friends). We are not sure how users could best
customize styling, but you can track our progress on that in
[r-lib/styler#319](https://github.com/r-lib/styler/issues/319).

You can also set the environment variable `save_after_styling` to
`TRUE`, if you are tired of saving the file after styling it with the addin.

## Braces in function calls

`tryCatch()` expressions often look like this:


```r
tryCatch(
  {
    exp(x)
  },
  error = function(x) x
)
```

Prior to version 1.2.0, styler would return this odd formatting:


```r
tryCatch({
  exp(x)
},
error = function(x) x
)
```

Now, the line is broken before the opening curly brace in function calls, except
if there is only one brace expression and it's the last in the function call.
The typical use case is `testthat::test_that(...)`, i.e. the following code
won't be modified:


```r
test_that("some condition holds", {
  some_code()
})
```

## Other changes


* styler depends on tibble >= 1.4.2 and runs 2x as fast as initially.

* styler can style roxygen code examples in the source code of
  packages.

* styler can style `.Rnw` files.

* The print method for the output of `style_text()` returns
  syntax-highlighted code by default, controllable via the option
  `styler.colored_print.vertical`.

## Adaption of styler

We'd like to highlight that styler integrates with various other tools you might
be using:

- As a git pre-commit hook. Two standard calls from the R console, and you are
  all set. We are convinced that this is the preferred way of using styler to
  ensure all your files are consistently formatted. Check out the
  [precommit](https://lorenzwalthert.github.io/precommit/) package that also 
  implements many other useful hooks.

- `usethis::use_tidy_style()` styles your project according to the tidyverse
  style guide.

- `knitr::knitr()` and friends recognize the R code chunk option `tidy =
  "styler"` for `.Rnw` and `.Rmd` files to pretty-print code.

- `reprex::reprex(..., style = TRUE)` to prettify reprex code before printing.
  To permanently use `style = TRUE` without specifying it every time, you can
  add the following line to your `.Rprofile` (e.g. via
  `usethis::edit_r_profile()`): `options(reprex.styler = TRUE)`.

- There are plugins for
  [Emacs](https://github.com/lassik/emacs-format-all-the-code) and
  [VIM](https://github.com/dense-analysis/ale/blob/master/doc/ale-r.txt).

## Outlook

We have some cool new features in the pipeline such as
[caching](https://github.com/r-lib/styler/pull/538) for faster styling, and 
[making styler ignore some lines](https://github.com/r-lib/styler/pull/560), 
which you can try out by installing from the respective branches. Feedback welcome.

## Acknowledgments

We are grateful to all of the people who contributed not just code, but also 
issues and comments over the last two years:

[&#x0040;aaronrudkin](https://github.com/aaronrudkin),
[&#x0040;aedobbyn](https://github.com/aedobbyn), [&#x0040;ArthurPERE](https://github.com/ArthurPERE), [&#x0040;Banana1530](https://github.com/Banana1530), [&#x0040;batpigandme](https://github.com/batpigandme), [&#x0040;Bio7](https://github.com/Bio7), [&#x0040;ClaytonJY](https://github.com/ClaytonJY), [&#x0040;courtiol](https://github.com/courtiol),
[&#x0040;crew102](https://github.com/crew102),
[&#x0040;cpsievert](https://github.com/cpsievert), [&#x0040;dchiu911](https://github.com/dchiu911),
[&#x0040;devSJR](https://github.com/devSJR),
[&#x0040;dirkschumacher](https://github.com/dirkschumacher), [&#x0040;ellessenne](https://github.com/ellessenne), [&#x0040;Emiller88](https://github.com/Emiller88),
[&#x0040;fny](https://github.com/fny),
[&#x0040;hadley](https://github.com/hadley), [&#x0040;Hasnep](https://github.com/Hasnep), [&#x0040;igordot](https://github.com/igordot), [&#x0040;IndrajeetPatil](https://github.com/IndrajeetPatil), [&#x0040;jackwasey](https://github.com/jackwasey), [&#x0040;jcrodriguez1989](https://github.com/jcrodriguez1989),
[&#x0040;jennybc](https://github.com/jennybc), [&#x0040;jjramsey](https://github.com/jjramsey),
[&#x0040;jkgrain](https://github.com/jkgrain)
[&#x0040;jonmcalder](https://github.com/jonmcalder),
[&#x0040;joranE](https://github.com/joranE),
[&#x0040;kalibera](https://github.com/kalibera),
[&#x0040;katrinleinweber](https://github.com/katrinleinweber), [&#x0040;kiranmaiganji](https://github.com/kiranmaiganji), [&#x0040;krivit](https://github.com/krivit), [&#x0040;krlmlr](https://github.com/krlmlr), 
[&#x0040;llrs](https://github.com/llrs),
[&#x0040;lorenzwalthert](https://github.com/lorenzwalthert), [&#x0040;lwjohnst86](https://github.com/lwjohnst86),
[&#x0040;martin-mfg](https://github.com/martin-mfg),
[&#x0040;maurolepore](https://github.com/maurolepore), [&#x0040;michaelquinn32](https://github.com/michaelquinn32), [&#x0040;mine-cetinkaya-rundel](https://github.com/mine-cetinkaya-rundel), [&#x0040;Moohan](https://github.com/Moohan), [&#x0040;msberends](https://github.com/msberends),
[&#x0040;NGaffney](https://github.com/NGaffney), [&#x0040;nxskok](https://github.com/nxskok), [&#x0040;oliverbeagley](https://github.com/oliverbeagley), [&#x0040;pat-s](https://github.com/pat-s), [&#x0040;ramnathv](https://github.com/ramnathv), [&#x0040;raynamharris](https://github.com/raynamharris), [&#x0040;reddy-ia](https://github.com/reddy-ia), [&#x0040;riccardoporreca](https://github.com/riccardoporreca), [&#x0040;rillig](https://github.com/rillig), [&#x0040;rjake](https://github.com/rjake), [&#x0040;Robinlovelace](https://github.com/Robinlovelace),
[&#x0040;RMHogervorst](https://github.com/RMHogervorst),
[&#x0040;rorynolan](https://github.com/rorynolan), [&#x0040;russHyde](https://github.com/russHyde),
[&#x0040;samhinshaw](https://github.com/samhinshaw),
[&#x0040;skirmer](https://github.com/skirmer), [&#x0040;thalesmello](https://github.com/thalesmello), [&#x0040;tobiasgerstenberg](https://github.com/tobiasgerstenberg), [&#x0040;tonytonov](https://github.com/tonytonov), [&#x0040;tvatter](https://github.com/tvatter),
[&#x0040;vnijs](https://github.com/vnijs),
[&#x0040;wdearden](https://github.com/wdearden), [&#x0040;wlandau](https://github.com/wlandau), [&#x0040;wmayner](https://github.com/wmayner), [&#x0040;yech1990](https://github.com/yech1990) and
[&#x0040;yutannihilation](https://github.com/yutannihilation).


