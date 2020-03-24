---
title: dplyr 1.0.0 and vctrs
author: Hadley Wickham
date: '2020-03-25'
slug: dplyr-1-0-0-and-vctrs
photo:
  url: https://unsplash.com/photos/IstXvxHGoA4
  author: 35mm
categories:
  - package
tags:
  - dplyr
---

[dplyr 1.0.0 is coming soon](https://www.tidyverse.org/blog/2020/03/dplyr-1-0-0-is-coming-soon/), and we've already shown you how [`summarise()` is growing](https://www.tidyverse.org/blog/2020/03/dplyr-1-0-0-summarise/). Today, I wanted to talk a little bit how dplyr 1.0.0 now uses the  [vctrs](http://vctrs.r-lib.org/) package. This post explains why vctrs is so important, why we can't just copy what base R does, how to interpret some of new error messages that you'll see, and some of the major changes since the last version.



## Combining vectors

The heart of the reason we're using vctrs is the need to combine vectors together. You're already familiar with one base R tool for combining vectors, `c()`:


```r
c(1, 2, 3)
#> [1] 1 2 3
c("a", "b", "c")
#> [1] "a" "b" "c"
```

But combining vectors comes up in many places in the tidyverse, e.g.:

* `dplyr::mutate()` and `dplyr::summarise()` have to combine the results 
  from each group.
* `dplyr::bind_rows()` has to combine columns from different data frames.
* `dplyr::full_join()`  has to combine the keys from the `x` and `y` data
  frames.
* `tidyr::pivot_longer()` has to combine multiple columns into one.

Our goal is to unify the code that underlies all these various functions so that there's one consistent, principled approach. We've already made the change in [tidyr](https://www.tidyverse.org/blog/2019/09/tidyr-1-0-0/), and now it's dplyr's turn. 

## Base R behaviour

You might wonder why we can't just copy the behaviour of `c()`. Unfortunately `c()` has some major downsides:

*   It converts factors to their underlying integer levels:
    
    
    ```r
    c(factor("x"), factor("y"))
    #> [1] 1 1
    ```
  
*   It doesn't yield sensible results when combining dates and times:

    
    ```r
    today <- as.Date("2020-03-24")
    now <- as.POSIXct("2020-03-24 10:34")
    c(today, now)
    #> [1] "2020-03-24"    "4341727-12-11"
    c(now, today)
    #> [1] "2020-03-24 10:34:00 CDT" "1969-12-31 23:05:45 CST"
    ```

Additionally, `c()` isn't the only way that base R combines together. `rbind()` and `unlist()` can also be used to perform a similar job, but return different results. This is not to claim that the tidyverse has been any better in the past - we have used a variety of ad hoc method, undoubtedly using well more than three different approaches. 

So decided to come up with our own equivalent of `c()` that we call `vectrs::vec_c()`. `vec_c()`'s behaviour is governed by two main principles:

* Symmetry: `vec_c(x, y)` should return a type as similar as possible to 
  `vec_c(y, x)`.

* Decrease constraints: this is a bit harder to explain, but if you combine
  two vectors where one type can represent a subset of the values of the other,
  you should return the less constrained type. This principle implies that
  combine an integer and double should return a double, and that combining
  a date and date-time should return a date-time.

* Prefer to be explicit: if there's confusion about what the result should be,
  require that the user perform an explicit coercion.

This function resolves the greatest downsides of `c()` and provides a principled foundation for us to build tidyverse functions on top of:


```r
library(vctrs)
vec_c(today, now)
#> [1] "2020-03-24 00:00:00 CDT" "2020-03-24 10:34:00 CDT"
vec_c(factor("x"), factor("y"))
#> [1] x y
#> Levels: x y
```

## Errors

As a data scientist, you don't really need to know anything about the vctrs package, except that it exists and its used internally by dplyr. (As a software engineer, you might want to learn about vctrs [makes it easier to create new types of vector](https://vctrs.r-lib.org/articles/s3-vector.html)). But vctrs is responsible for creating a number of error messages in dplyr, so it's worth understanding there basic form.

In this first example, we attempt to bind two data frames together where the columns have incompatible types: double and character.


```r
library(dplyr)
#> 
#> Attaching package: 'dplyr'
#> The following objects are masked from 'package:stats':
#> 
#>     filter, lag
#> The following objects are masked from 'package:base':
#> 
#>     intersect, setdiff, setequal, union

df1 <- tibble(a = 1, b = 1)
df2 <- tibble(a = 2, b = "a")
bind_rows(df1, df2)
#> Error: Column `b` can't be converted from numeric to character
```
Note the components of the error message:

* "No common type" means that vctrs can't find a vector type that can
  represent both double and character values. 
  
* vctrs error messages always puts the "type" of the variable in `<>`.
  I'm using type informally here (although it does have a well-formed
  definition); for many simple cases it's the same as the class.
  
* `bind_rows()` doesn't have named arguments so vctrs use `..1` and 
  `..2` to refer to the first and second arguments. You can tell the
  problem is with the `b` column.
  
Where possible we attempt to give you more information to solve the problem. For example, if your call to `summarise()` or `mutate()` returns incompatible types, we'll tell you which groups have the problem:


```r
df <- tibble(g = c(1, 2))
df %>% 
  group_by(g) %>% 
  mutate(y = if (g == 1) "a" else 1)
#> Error: Column `y` can't be converted from character to numeric
```
Writing good error messages is hard, and we've spent a lot of time trying to make them informative. 

If you're not sure where the errors are coming from, learning how to use the traceback (either `traceback()` or `rlang::last_error()`) will be helpful. I'd highliy recommend Jenny Bryan's rstudio::conf keynote on debugging: [Object of type 'closure' is not subsettable](https://resources.rstudio.com/rstudio-conf-2020/object-of-type-closure-is-not-subsettable-jenny-bryan)

## Key changes

Using vctrs causes two major changes in dplyr 1.0.0:

*   When combining factors with different level sets, dplyr previously 
    converted to a character vector with a warning. As of 1.0.0, dplyr will
    create a factor with the union of the individual levels.
  
    
    ```r
    vec_c(factor("x"), factor("y"))
    #> [1] x y
    #> Levels: x y
    ```
  
*   When combining a factor and a character, dplyr previously warned about
    creating a character vector. It now silently creates a character vector.

    
    ```r
    vec_c("x", factor("y"))
    #> [1] "x" "y"
    ```

These changes are motivated primarily by pragmatism than by theory. Strictly speaking one should probably consider `factor("red")` and `factor("male")` to be incompatible, but this level of strictness causes much pain because character vectors are usually interchangeably with factors.

Also note that dplyr continues to be stricter than base R when it comes to character conversions: 


```r
vec_c(1, "a")
#> Error: No common type for `..1` <double> and `..2` <character>.
```

We don't allow coercions to character vectors because we believe this to be an easy path to subtle bugs:
