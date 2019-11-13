---
title: testthat 2.1.0
author: Hadley Wickham
date: '2019-04-23'
slug: testthat-2-1-0
description: Highlights include that `context()` is now optional, and 
  new `expect_invisible()` and `expect_mapequal()` expectations.
categories:
  - package
tags: [testthat, r-lib]
photo:
  url: https://www.pexels.com/photo/38070/
  author: Skitterphoto
---



<html>
<style>
h2 code {
    font-size: 1em;
}
</style>
</html>

We're happy to announce that [testthat 2.1.0](http://testthat.r-lib.org) is now available on CRAN! testthat makes it easy to turn your existing informal tests into formal automated tests that you can rerun quickly and easily. testthat is the most popular unit-testing package for R, and is used by over 4,000 CRAN and Bioconductor packages. You can learn more about unit testing at <https://r-pkgs.org/tests.html>. 

Install the latest version of testthat with:


```r
install.packages("testthat")
```

testthat 2.1.0 mostly contains a large number of minor improvements and bug fixes, as described in the [release notes](https://github.com/r-lib/testthat/releases/tag/v2.1.0). This blog post discusses the bigger improvements:

* `context()`s are now optional.

* Two new expectations: `expect_invisible()` and `expect_mapequal()`.
  
## `context()` is now optional

The biggest change in this version is that `context()` is now optional, and in fact we recommend that you no longer use it. `context()` made sense with the original design of testthat, which supported a very flexible mapping between your R code and the corresponding tests. 

Now, however, we have a stronger recommendation: organise the files in `tests/testthat` in the same way that you organise the files in `R/`, so that tests for code in `R/my-file.R` live in `tests/testthat-my-file.R`. (This begs the question of how you should organise your `R/` directory, which we don't have a good answer for yet, but at least you only need to struggle to organise one directory). With this convention, `context()` tends to end up duplicating the file name, causing needless hassle if you reorganise your code structure.

The convention that every file in `R/` has a corresponding file in `tests/testthat` (and vice versa) is used by two other helpful functions:

* `usethis::use_test()`, which, if you use RStudio, will automatically
  create and open a test file corresponding to the R file in the right
  location. (If you've written the test file first, you can instead use
  `usethis::use_r()`)

* `devtools::test_coverage_file()`: again, if you use RStudio, this will look 
  at the active file, run just the tests for that file, and report the coverage
  results. This is a great way to rapidly iterate to ensure that you have 
  tested all the branches of new code.

## New expectations


```r
library(testthat)
```

This version of testthat introduces two important new expectations:

*   `expect_invisible()` makes it easier to check if a function returns its
    results invisibly. This is useful if you are testing a function that is
    called primarily for its side-effects, which should (as a general rule)
    invisibly return its first argument.
    
    
    ```r
    greet <- function(name) {
      cat("Hello ", name, "!\n", sep = "")
      invisible(name)
    }
    
    x <- expect_invisible(greet("Hadley"))
    #> Hello Hadley!
    expect_equal(x, "Hadley")
    ```
    
    For symmetry, `expect_visible()` is also available, but you would not
    generally test for it, as visible return values are the default. 
    Only use it if you find a bug related to visibilty and want to
    programmatically verify that it's fixed.
    
*   New `expect_mapequal(x, y)` checks that `x` and `y` have the same names,
    and the same value associated with each name (i.e. it compares the values
    of the vector standardising the order of the names). 
    
    
    ```r
    exp <- list(a = 1, b = 2)
    expect_mapequal(list(a = 1, b = 2), exp)
    expect_mapequal(list(b = 2, a = 1), exp)
    
    expect_mapequal(list(b = 2), exp)
    #> Error: Names absent from `object`: "a",
    expect_mapequal(list(a = 3, b = 2), exp)
    #> Error: act$val[exp_nms] not equal to exp$val.
    #> Component "a": Mean relative difference: 0.6666667
    expect_mapequal(list(a = 1, b = 2, c = 3), exp)
    #> Error: Names absent from `expected`: "c",
    ```
    
    `expect_mapequal()` is related to `expect_setequal()`, which compares 
    values, ignoring order and count:
    
    
    ```r
    expect_setequal(c("a", "b"), c("b", "a"))
    expect_setequal(c("a", "b"), c("a", "a", "b"))
    ```

## Acknowledgements

A big thanks to all 51 people who helped contribute to this release by reporting bugs, suggesting new features, or creating pull requests: [&#x0040;aabor](https://github.com/aabor), [&#x0040;AEBilgrau](https://github.com/AEBilgrau), [&#x0040;antaldaniel](https://github.com/antaldaniel), [&#x0040;bflammers](https://github.com/bflammers), [&#x0040;billdenney](https://github.com/billdenney), [&#x0040;BillDunlap](https://github.com/BillDunlap), [&#x0040;Bisaloo](https://github.com/Bisaloo), [&#x0040;burchill](https://github.com/burchill), [&#x0040;chasemc](https://github.com/chasemc), [&#x0040;colearendt](https://github.com/colearendt), [&#x0040;comicfans](https://github.com/comicfans), [&#x0040;dmenne](https://github.com/dmenne), [&#x0040;euklid321](https://github.com/euklid321), [&#x0040;flying-sheep](https://github.com/flying-sheep), [&#x0040;gaborcsardi](https://github.com/gaborcsardi), [&#x0040;gabrielodom](https://github.com/gabrielodom), [&#x0040;gvwilson](https://github.com/gvwilson), [&#x0040;hadley](https://github.com/hadley), [&#x0040;harvey131](https://github.com/harvey131), [&#x0040;Hong-Revo](https://github.com/Hong-Revo), [&#x0040;HughParsonage](https://github.com/HughParsonage), [&#x0040;jackhannah95](https://github.com/jackhannah95), [&#x0040;jackwasey](https://github.com/jackwasey), [&#x0040;jarodmeng](https://github.com/jarodmeng), [&#x0040;jennybc](https://github.com/jennybc), [&#x0040;jsilve24](https://github.com/jsilve24), [&#x0040;kevinushey](https://github.com/kevinushey), [&#x0040;kforner](https://github.com/kforner), [&#x0040;lionel-](https://github.com/lionel-), [&#x0040;maelle](https://github.com/maelle), [&#x0040;markvanderloo](https://github.com/markvanderloo), [&#x0040;masaha03](https://github.com/masaha03), [&#x0040;mb706](https://github.com/mb706), [&#x0040;mbjoseph](https://github.com/mbjoseph), [&#x0040;merliseclyde](https://github.com/merliseclyde), [&#x0040;mikejiang](https://github.com/mikejiang), [&#x0040;Mooskey](https://github.com/Mooskey), [&#x0040;olsgaard](https://github.com/olsgaard), [&#x0040;patr1ckm](https://github.com/patr1ckm), [&#x0040;ramiromagno](https://github.com/ramiromagno), [&#x0040;randy3k](https://github.com/randy3k), [&#x0040;renkun-ken](https://github.com/renkun-ken), [&#x0040;smbache](https://github.com/smbache), [&#x0040;stevecondylios](https://github.com/stevecondylios), [&#x0040;topepo](https://github.com/topepo), [&#x0040;tramontini](https://github.com/tramontini), [&#x0040;wch](https://github.com/wch), [&#x0040;wsherwin](https://github.com/wsherwin), [&#x0040;Yuri-M-Dias](https://github.com/Yuri-M-Dias), [&#x0040;yutannihilation](https://github.com/yutannihilation), and [&#x0040;zappingseb](https://github.com/zappingseb).
