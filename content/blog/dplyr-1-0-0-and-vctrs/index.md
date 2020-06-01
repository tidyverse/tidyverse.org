---
slug: dplyr-1-0-0-and-vctrs
title: dplyr 1.0.0 and vctrs
author: Hadley Wickham
date: '2020-04-27'

output: hugodown::hugo_document

categories:
- package
tags:
- dplyr
- dplyr-1-0-0
  
photo:
  url: https://unsplash.com/photos/IstXvxHGoA4
  author: 35mm
rmd_hash: 440e18876a8d1a58

---

This post is the latest in a series of post leading up the the dplyr 1.0.0 release. So far:

-   [dplyr 1.0.0 is coming soon](https://www.tidyverse.org/blog/2020/03/dplyr-1-0-0-is-coming-soon/)
-   [`summarise()` is growing](https://www.tidyverse.org/blog/2020/03/dplyr-1-0-0-summarise/)
-   [`select()`, `rename()`, `relocate()`](https://www.tidyverse.org/blog/2020/03/dplyr-1-0-0-select-rename-relocate/).
-   [Working `across()` columns](https://www.tidyverse.org/blog/2020/04/dplyr-1-0-0-colwise/).
-   [Working within rows](https://www.tidyverse.org/blog/2020/04/dplyr-1-0-0-rowwise/).

Today, I wanted to talk a little bit how dplyr 1.0.0 uses the [vctrs](http://vctrs.r-lib.org/) package. This post explains why vctrs is so important, why we can't just copy what base R does, how to interpret some of new error messages that you'll see, and some of the major changes since the last version.

If you're interested in living life on the edge (or trying out anything you see in this blog post), you can install the development version of dplyr with:

``` r
devtools::install_github("tidyverse/dplyr")
```

Note that the development version won't become 1.0.0 until it's released, but it has all the same features.

``` r
library(vctrs)
library(dplyr, warn.conflicts = FALSE)
```

Combining vectors
-----------------

The heart of the reason we're using vctrs is the need to combine vectors. You're already familiar with one base R tool for combining vectors, `c()`:

``` r
c(1, 2, 3)
#> [1] 1 2 3
c("a", "b", "c")
#> [1] "a" "b" "c"
```

Combining vectors comes up in many places in the tidyverse, e.g.:

-   `dplyr::mutate()` and `dplyr::summarise()` have to combine the results from each group.
-   `dplyr::bind_rows()` has to combine columns from different data frames.
-   `dplyr::full_join()` has to combine the keys from the `x` and `y` data frames.
-   `tidyr::pivot_longer()` has to combine multiple columns into one.

Our goal is to unify the code that underlies all these various functions so that there's one consistent, principled approach. We've already made the change in [tidyr](https://www.tidyverse.org/blog/2019/09/tidyr-1-0-0/), and now it's dplyr's turn.

Base R behaviour
----------------

You might wonder why we can't just copy the behaviour of `c()`. Unfortunately `c()` has some major downsides:

-   It doesn't possess a `factor` method so it converts factors to their underlying integer levels.

    ``` r
    c(factor("x"), factor("y"))
    #> [1] 1 1
    ```

-   It's difficult to implement methods when different classes are involved. For example, combining a date (`Date`) and a date-time (`POSIXct`) yields an incorrect result because the underlying data is combined without first being translated.

    ``` r
    today <- as.Date("2020-03-24")
    now <- as.POSIXct("2020-03-24 10:34")

    c(today, now)
    #> [1] "2020-03-24"    "4341727-12-11"
    # (the second value is the 11 Dec 4341727-12-11)
    class(c(today, now))
    #> [1] "Date"
    unclass(c(today, now))
    #> [1]      18345 1585064040

    c(now, today)
    #> [1] "2020-03-24 10:34:00 CDT" "1969-12-31 23:05:45 CST"
    class(c(now, today))
    #> [1] "POSIXct" "POSIXt"
    unclass(c(now, today))
    #> [1] 1585064040      18345
    ```

It's difficult to change how `c()` works because any changes are likely to break some existing code, and base R is committed to backward compatibility. Additionally, `c()` isn't the only way that base R combines vectors. `rbind()` and `unlist()` can also be used to perform a similar job, but return different results. This is not to say that the tidyverse has been any better in the past --- we have used a variety of ad hoc methods, undoubtedly using well more than three different approaches.

Given that it's hard to fix the problem in base R, we've come up with our own alternative to `c()`: `vctrs::vec_c()`. `vec_c()`'s behaviour is governed by three main principles:

-   Symmetry: `vec_c(x, y)` should return a type as similar as possible to `vec_c(y, x)`. For example, when combining a date and a date-time you always get a date-time.

    ``` r
    vec_c(today, now)
    #> [1] "2020-03-24 00:00:00 CDT" "2020-03-24 10:34:00 CDT"

    vec_c(now, today)
    #> [1] "2020-03-24 10:34:00 CDT" "2020-03-24 00:00:00 CDT"
    ```

-   Enrichment: `vec_c(x, y)` should return the richer type, where type `<x>` is richer than type `<y>` if `x` can represent all values in `y`. For example, this implies that combining an integer and double should return a double, and that combining a date and date-time should return a date-time.

    ``` r
    vec_c(1, 1.5)
    #> [1] 1.0 1.5
    vec_c(today, now)
    #> [1] "2020-03-24 00:00:00 CDT" "2020-03-24 10:34:00 CDT"
    ```

-   Consistency: `vec_c(x, y)` should error if `x` and `y` are of fundamentally different types. For example, this implies that combining a string and a number or a factor and a date should error.

    ``` r
    vec_c("a", 1)
    #> Error: Can't combine `..1` <character> and `..2` <double>.
    vec_c(factor("x"), today)
    #> Error: Can't combine `..1` <factor<5a425>> and `..2` <date>.
    ```

Errors
------

As a data scientist, you don't really need to know much about the vctrs package, except that it exists and its used internally by dplyr. (As a software engineer, you might want to learn about vctrs because [it makes it easier to create new types of vectors](https://vctrs.r-lib.org/articles/s3-vector.html)). But vctrs is responsible for creating a number of error messages in dplyr, so it's worth understanding their basic form.

In this first example, we attempt to bind two data frames together where the columns have incompatible types: double and character.

``` r
df1 <- tibble(a = 1, b = 1)
df2 <- tibble(a = 2, b = "a")
bind_rows(df1, df2)
#> Error: Can't combine `..1$b` <double> and `..2$b` <character>.
```

Note the components of the error message:

-   "Can't combine" means that vctrs can't combine double and character vectors.

-   vctrs error messages always puts the "type" of the variable in `<>`, like `<double>`, or `<character>`. I'm using type informally here (although it does have a precise definition); for many simple cases it's the same as the class.

-   `bind_rows()` doesn't have named arguments so vctrs uses `..1` and `..2` to refer to the first and second arguments. You can tell the problem is with the `b` column.

If after reading the error, you do still want to combine the data frames, you'll need to make them compatible by manually transforming one of the columns:

``` r
df1 <- df1 %>% mutate(b = as.character(b))
bind_rows(df1, df2)
#> # A tibble: 2 x 2
#>       a b    
#>   <dbl> <chr>
#> 1     1 1    
#> 2     2 a
```

Where possible, we attempt to give you more information to solve the problem. For example, if your call to `summarise()` or `mutate()` returns incompatible types, we'll tell you which groups have the problem:

``` r
df <- tibble(g = c(1, 2))
df %>% 
  group_by(g) %>% 
  mutate(y = if (g == 1) "a" else 1)
#> Error: Problem with `mutate()` input `y`.
#> x Input `y` must return compatible vectors across groups
#> ℹ Input `y` is `if (g == 1) "a" else 1`.
#> ℹ Result type for group 1 (g = 1): <character>.
#> ℹ Result type for group 2 (g = 2): <double>.
```

Writing good error messages is hard, so we've spent a lot of time trying to make them informative. We expect them to continue to improve as we see more examples from live data analysis code.

If you're not sure where the errors are coming from, learning how to use the traceback (either `traceback()` or `rlang::last_error()`) will be helpful. I'd highly recommend Jenny Bryan's rstudio::conf keynote on debugging: [Object of type 'closure' is not subsettable](https://resources.rstudio.com/rstudio-conf-2020/object-of-type-closure-is-not-subsettable-jenny-bryan).

Key changes
-----------

Using vctrs in dplyr also causes two behaviour changes. We hope that these don't affect much existing code because they both previously generated warnings.

-   When combining factors with different level sets, dplyr previously converted to a character vector with a warning. As of 1.0.0, dplyr will create a factor with the union of the individual levels:

    ``` r
    vec_c(factor("x"), factor("y"))
    #> [1] x y
    #> Levels: x y
    ```

-   When combining a factor and a character, dplyr previously warned about creating a character vector. It now silently creates a character vector:

    ``` r
    vec_c("x", factor("y"))
    #> [1] "x" "y"
    ```

These changes are motivated more by pragmatism than by theory. Strictly speaking, one should probably consider `factor("red")` and `factor("male")` to be incompatible, but this level of strictness causes much pain because character vectors can usually be used interchangeably with factors.

Note that dplyr continues to be stricter than base R when it comes to character conversions:

``` r
c(1, "2")
#> [1] "1" "2"
vec_c(1, "2")
#> Error: Can't combine `..1` <double> and `..2` <character>.
```

In this case, we don't know whether you want a character vector or a numeric vector, so you need to decide by manually converting one of the inputs:

``` r
vec_c(1, as.integer("2"))
#> [1] 1 2
vec_c(as.character(1), "2")
#> [1] "1" "2"
```
