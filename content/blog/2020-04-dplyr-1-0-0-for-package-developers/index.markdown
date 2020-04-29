---
title: dplyr 1.0.0 for package developers
author: Hadley Wickham
date: '2020-04-29'
slug: dplyr-1-0-0-package-dev
description: > 
  dplyr 1.0.0 is scheduled for release on May 15. This blog post talks
  about what package maintainers can do to prepare.
categories:
  - package
tags:
  - dplyr
photo:
  author: Tekton
  url: https://unsplash.com/photos/LtphNTXHQAc
---



As you're hopefully aware, [dplyr 1.0.0 is coming soon](https://www.tidyverse.org/blog/2020/03/dplyr-1-0-0-is-coming-soon/), and we've been writing a [series of blog posts](https://www.tidyverse.org/tags/dplyr/) about the user-facing changes that you, as a data scientist have to look forward to. Today, I wanted to change tack a little and talk about the changes from the perspective of the package developer.

But first, an update on the release process: in the process of preparing for this release, we discovered some subtle problems that arise when combining different types of data frames (including [data.table](http://r-datatable.com)s and tibbles). It took us a little while to figure out what we (and package developers need to do), so we've decided to push back the dplyr release: we're now planning on releasing dplyr 1.0.0 to CRAN on May 15. We're sorry that its going to longer than expected, but this gives package authors who use dplyr more time to handle changes.

In this post, I want to address how dplyr changes might break package code, then discuss some of the major pain points a package developer might experience, and how to get help if you need it.


```r
library(dplyr, warn.conflicts = FALSE)
```

## Breaking changes

There are three main ways an update to a package might break your existing code:

* We've introduced a bug. Obviously, we do our best to make sure this doesn't 
  happen (by using software development best practices like unit testing and 
  code review) but it's impossible to eliminate all bugs.
  
* We've fixed a bug or otherwise made change we think is harmless. Sometimes 
  your code accidentally depends on a behaviour that we think is incorrect and 
  we change it. The change will be an improvement for most people, but 
  unfortunately it [breaks your code](https://xkcd.com/1172/).
  
* We've deliberately made a backward incompatible interface change. We try
  to make these as rarely as possible, and only to significantly improve 
  usability or consistency. Unless the package or function is experimental, 
  we do our best to make such changes gradually, so that there's a deprecation
  period before the behaviour goes away altogether.

dplyr 1.0.0 contains very few backward incompatible changes, but it does make a large number of changes that we believe are mostly harmless or minor improvements.  The vast majority of these will not affect data analysis code, but some can affect packages, particularly through their unit tests. To give you a flavour for what I mean here, dplyr now preserves the names of atomic vectors:


```r
df <- tibble(x = c(a = 1, b = 2))
df %>% filter(x == 1) %>% .$x %>% str()
#>  Named num 1
#>  - attr(*, "names")= chr "a"
```

(With dplyr 0.8.5, this returns an unnamed vector.)

We made this change to increase internal consistency, as some verbs already did preserve names, and all verbs preserved the names of list-columns. We expect that this will have minimal impact on data-analysis code, but it does affect some packages because now there are names where there weren't before. If this problem affects your code, typically the best strategy is to use `unname()` to strip the names off.

## Our release process

To make sure all package maintainers know about potential problems, we run `R CMD check` on all 1,986 packages that use dplyr. (You can see the results on [github](https://github.com/tidyverse/dplyr/tree/master/revdep#revdeps)). If you maintain a package that uses dplyr, and your package has problems, we have already emailed you several times throughout the release process. 

We're also slowly working through the list of packages with problems and preparing pull requests where we can figure out a fix. Unfortunately, we don't have the resources to fix every package, but we're happy to help out if you get stuck (more on that below).

## `all.equal()`

One of the subtlest, but furthest reaching changes for package authors is that we removed the `all.equal.tbl_df` method. This small change has big consequence because `testthat::expect_equal()` calls `all.equal()`, which calls `all.equal.tbl_df()` when the first argument is a tibble. Unfortunately `all.equal.tbl_df` had a couple of major problems:

*   It ignores the difference between data frames and tibbles so this code
    would pass:
  
    
    ```r
    expect_equal(tibble(x = 1), data.frame(x = 1))
    ```

*   By default, it ignores column and row order so the following tests
    would pass:

    
    ```r
    expect_equal(tibble(x = 1:2), tibble(x = 2:1))
    expect_equal(tibble(x = 1, y = 2), tibble(y = 2, x = 1))
    ```

The first issue was a genuine bug; the second one was something that I must've thought was a good idea at the time, but looking back at it was clearly a mistake. We've been aware of this problem for a while, but knew that fixing it would cause a large number of CRAN packages to fail to pass `R CMD check`. We decided that the 1.0.0 release was a good time to rip the band-aid off.

Unfortunately if this change affects your code, you won't get a terribly informative error message, so for now you'll just need to pattern match on the errors below:


```r
library(testthat)

# Class mismatch
expect_equal(tibble(x = 1), data.frame(x = 1))
#> Error: tibble(x = 1) not equal to data.frame(x = 1).
#> Attributes: < Component "class": Lengths (3, 1) differ (string compare on first 1) >
#> Attributes: < Component "class": 1 string mismatch >

# Row order is different
expect_equal(tibble(x = 1:2), tibble(x = 2:1))
#> Error: tibble(x = 1:2) not equal to tibble(x = 2:1).
#> Component "x": Mean relative difference: 0.6666667

# Column order is different
expect_equal(tibble(x = 1, y = 2), tibble(y = 2, x = 1))
#> Error: tibble(x = 1, y = 2) not equal to tibble(y = 2, x = 1).
#> Names: 2 string mismatches
#> Component 1: Mean relative difference: 1
#> Component 2: Mean relative difference: 0.5
```
Fixing these failures will typically involve updating the expected value.

(The problem of uninformative failures prompted me to start work on the [waldo package](https://waldo.r-lib.org) that attempts to do better. You can try it out by installing the dev version of testthat, `devtools::install_github("r-lib/testthat")`, but note that it's still experimental so it's only recommended for the adventurous.)

## Increased strictness from vctrs

As we [discussed recently](https://www.tidyverse.org/blog/2020/04/dplyr-1-0-0-and-vctrs/), dplyr now uses the [vctrs package](https://vctrs.r-lib.org) under the hood. This increased strictness affects a few edge cases. For example, in dplyr 0.8.5, the following code returned `tibble(x = character())` (what we'd now consider to be a bug):


```r
df1 <- tibble(x = integer())
df2 <- tibble(x = character())
bind_rows(df1, df2)
#> Error: Can't combine `..1$x` <integer> and `..2$x` <character>.
```
If this affects your package, you'll typically need to think about what the type of each column should be, and then ensure that's the case everywhere in your code.

## Need help?

If you just can't figure out how to fix your package, please let us know! The fastest way to get help is to [file an issue](https://github.com/tidyverse/dplyr) containing a [reprex](http://reprex.tidyverse.org/) that illustrates the precise problem. But if you're struggling to make a reprex, you can give us a link to your repo, and we'll take a look.
