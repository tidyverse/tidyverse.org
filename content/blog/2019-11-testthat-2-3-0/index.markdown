---
title: testthat 2.3.0
author: Hadley Wickham
date: '2019-11-04'
slug: tidyr-2-3-0
categories:
  - package
tags:
  - r-lib
  - devtools
  - tidyr
photo:
  url: https://unsplash.com/photos/n_vD-7RxA3Q
  author: Roman Kraft

---



We're pumped to announce that [testthat 2.3.0](http://testthat.r-lib.org) is now available on CRAN! 
testthat makes it easy to turn your existing informal tests into formal automated tests that you can rerun quickly and easily. 
testthat is the most popular unit-testing package for R, and is used by over 4,000 CRAN and Bioconductor packages. 
You can learn more about unit testing at <https://r-pkgs.org/tests.html>. 

Install the latest version of testthat with:


```r
install.packages("testthat")
```

This release features two main improvements:

* A general overhaul of condition and error handling.

* A polished `verify_output()` that is ready for you to use to test your
  print methods and error messages.

(We didn't write a blog post about testthat 2.2.0 because it only introduced a single experimental new feature: `verify_output()`. 
It's now matured to the point we think you should also try it out, so it's discussed below.)

For a complete list of all changes, please see the [release notes](https://testthat.r-lib.org/news/index.html#testthat-2-3-0).  


```r
library(testthat)
```

## Errors

The main improvements are mostly behind the scenes: we have overhauled the handling of errors and backtraces so that you should get more informative outputs when tests error unexpectedly or fail. 
It's a little hard to demonstrate this authentically in an RMarkdown document, but if you have an error inside a test, like this:


```r
f <- function() g()
g <- function() h()
h <- function() stop("This is an error!")

test_that("f() works as expected", {
  expect_equal(f(), 10)
})
```

You'll now get an informative backtrace that should allow you to quickly locate the source of the error:

```
test-error.R:6: error: f() works as expected
This is an error!
Backtrace:
 1. testthat::expect_equal(f(), 10) tests/testthat/test-error.R:6:2
 4. testthat:::f()
 5. testthat:::g() tests/testthat/test-catch.R:1:5
 6. testthat:::h() tests/testthat/test-catch.R:2:5
```

The previous version only showed the error message, which wasn't terribly useful!

## `verify_output()`

`verify_output()` provides a new tool in your testing arsenal. 
Rather being a _unit_ testing tool, `verify_output()` is a _regression_ testing tool.
This makes it useful for cases where you can't describe the correct output with code, and instead the best you can do is to check the results with your eyeballs, and then fail if the result changes.

`verify_output()` is designed to test output aimed at a human, like print methods and error message.
Here you want to test that the output is useful to a human, but there's obviously no way to do that automatically.
Instead the best you can do is make the output explicit by capturing it into a file, which when used with `git`, makes it easy to see if something has changed.

`verify_output()` works a little like RMarkdown: you give it some R code and it will run it and interleave the input and ouptut.
For example, imagine we were writing some tests to check that tibbles print correctly:




```r
library(tibble)

test_that("tibbles print usefully", {
  verify_output(test_path("test-print-dataframe.txt"), {
    df1 <- tibble(x = 1:1e6)
    print(df1)
  })
})
```

That will yield a `test-print-dataframe.txt` containing this output:

```
> df1 <- tibble(x = 1:1e+06)
> print(df1)
# A tibble: 1,000,000 x 1
       x
   <int>
 1     1
 2     2
 3     3
 4     4
 5     5
 6     6
 7     7
 8     8
 9     9
10    10
# ... with 999,990 more rows

```

Unfortunately there's no way for `verify_output()` to capture comments, so you can instead use bare strings if you want comments to appear in the output. If you start the comment with `#` it will be formatted as a heading:


```r
test_that("tibbles print usefully", {
  verify_output(test_path("test-print-dataframe-2.txt"), {
    "# long tibbles"
    df1 <- tibble(x = 1:1e6)
    print(df1)
    
    "# wide tibbles"
    "not yet implemented"
  })
})
```

```

long tibbles
============

> df1 <- tibble(x = 1:1e+06)
> print(df1)
# A tibble: 1,000,000 x 1
       x
   <int>
 1     1
 2     2
 3     3
 4     4
 5     5
 6     6
 7     7
 8     8
 9     9
10    10
# ... with 999,990 more rows


wide tibbles
============

> # not yet implemented
```

`verify_output()` is automatically skipped when run on CRAN.
This avoids false positives because it's very easy to accidentally depend on the code from other acpages, and failure does not imply incorrect computation, just a change in presentation.
