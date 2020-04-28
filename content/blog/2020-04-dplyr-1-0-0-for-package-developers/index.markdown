---
title: dplyr 1.0.0 for package developers
author: Hadley Wickham
date: '2020-04-29'
slug: dplyr-1-0-0-package-dev
categories:
  - package
tags:
  - dplyr
photo:
  author: Tekton
  url: https://unsplash.com/photos/LtphNTXHQAc

---



As you're hopefully aware, [dplyr 1.0.0 is coming soon](https://www.tidyverse.org/blog/2020/03/dplyr-1-0-0-is-coming-soon/), and we've been writing a [series of blog posts](https://www.tidyverse.org/tags/dplyr/) about the user-facing changes that you, as a data scientist have to look forward to. Today, I wanted to change tack a little and talk about the changes from the perspective of the package developer.

But first, an update on the release process: in the process of preparing for the release, we discovered some subtle problems that arise when combining different types of data frames (including [data.table](http://r-datatable.com)s. It took us a little while to figure out what we (and package developers need to do), so we've decided to push back the dplyr release: we're now planning on releasing dplyr 1.0.0 to CRAN on May 15.

In this post, I want to talk a little bit about how dplyr changes might break your package code, then discuss some of the major pain points and how to solve them. 


```r
library(dplyr, warn.conflicts = FALSE)
```

## Breaking changes

There are three main ways an update to a package might break your existing code:

* We've introduced a bug. We do our best to write bug free code but using 
  software development best practices like unit testing (including tracking 
  test coverage) and code review, but it's impossible to eliminate all bugs
  
* We've fixed a bug or otherwise made change we think is harmless. Sometimes 
  your code accidentally depends on a behaviour that we think is incorrect and 
  we change it. The change will be an improvement for most people, but 
  unfortunately it [breaks your code](https://xkcd.com/1172/).
  
* We've deliberately made a backward incompatible interface change. We 
  occasionally make these changes and always to significantly improve usability 
  or consistency. Unless the package or function is experimental, we do our best 
  to make such changes gradually, so that there's a deprecation period before 
  the behaviour goes away altogether.

dplyr 1.0.0 contains very few backward incompatible changes, but it does make a large number of changes that we believe are mostly harmless or minor improvements.  The vast majority of these will not affect data analysis code, but can affect package code, particularly unit tests. To give you a flavour for what I mean here, dplyr now preserves the names of atomic vectors:


```r
df <- tibble(x = c(a = 1, b = 2))
df %>% filter(x == 1) %>% .$x %>% str()
#>  Named num 1
#>  - attr(*, "names")= chr "a"
```

(With CRAN dplyr, this simply returns `1`.)

We made this change to increase internal consistency as we've always preserved the names of list-columns (and some verbs preserved names of atomic vectors), and we expect it to have minimal impact on data analysis code. But it is likely to affect unit tests because now there are names where there weren't before. If this problem affects your code, typically the best strategy is to use `unname()` to strip the names off.

## `all.equal()`

One of the subtlest but furthest reaching changes is that we removed the `all.equal.tbl_df` method. This has far reaching changes because `testthat::expect_equal()` calls `all.equal()`, which when the first argument is a tibble, calls `all.equal.tbl_df()`. Unfortunately `all.equal.tbl_df` had a couple of major problems:

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

The first issue was a genuine bug; the second one was something that I must've thought was a good idea at the time, but looking back at it was clearly a mistake. 

We've been aware of this problem for a while, but knew that fixing it would cause a large number of CRAN packages to fail to pass `R CMD check`. We decided that the 1.0.0 release was a good time to rip the band-aid off.

Unfortunately you won't get a terribly informative error message, so for now you'll just need to spot the errors shown below:


```r
library(testthat)

expect_equal(tibble(x = 1), data.frame(x = 1))
#> Error: tibble(x = 1) not equal to data.frame(x = 1).
#> Attributes: < Component "class": Lengths (3, 1) differ (string compare on first 1) >
#> Attributes: < Component "class": 1 string mismatch >

expect_equal(tibble(x = 1:2), tibble(x = 2:1))
#> Error: tibble(x = 1:2) not equal to tibble(x = 2:1).
#> Component "x": Mean relative difference: 0.6666667

expect_equal(tibble(x = 1, y = 2), tibble(y = 2, x = 1))
#> Error: tibble(x = 1, y = 2) not equal to tibble(y = 2, x = 1).
#> Names: 2 string mismatches
#> Component 1: Mean relative difference: 1
#> Component 2: Mean relative difference: 0.5
```
(The problem of uninformative failures prompted me to start work on the [waldo package](https://waldo.r-lib.org) that attempts to do better. You can try it out by installing the dev version of testthat, `devtools::install_gitub("r-lib/testthat")` but note that it's still experimental so it's only recommended for the adventurous.)

## Increased strictness from vctrs

As we [discussed recently](https://www.tidyverse.org/blog/2020/04/dplyr-1-0-0-and-vctrs/), dplyr now uses the [vctrs package](https://vctrs.r-lib.org) under the hood. This increase strictness affects a few edge cases. For example, in dplyr 0.8.5, the following code returned `tibble(x = character())` (which really was bug). Now that we're using the same process every where, a few problems of this nature have been revealed:


```r
df1 <- tibble(x = integer())
df2 <- tibble(x = character())
bind_rows(df1, df2)
#> Error: Can't combine `..1$x` <integer> and `..2$x` <character>.
```
Typically the fix here is to think a little about what the type of each column should be, and then ensure they're always that type from the get go.

## `data.frame` subclasses

We've had many struggles with dplyr verbs maintaining the correct types/classes. I'm fairly confident that we now have a solid foundation for what happens with individual vector classes (i.e. the type of object that you put in a data frame column). We're still working on verbs as a whole. 

I know that it feels like the goal posts keep shifting, and I can assure you that it's just as frustrating for us. But I think we're starting to converge on a theory that helps us understand what the correct results should be, and there should be much less change in the near future. 

## Need help?

If you just can't figure out how to fix your package please let us know! The fastest way to get help is to [file an issue](https://github.com/tidyverse/dplyr) containing a [reprex](http://reprex.tidyverse.org/) that illustrates the precise problem. But if you're struggling to make a reprex, you can give us a link to your repo, and we'll take a look.
