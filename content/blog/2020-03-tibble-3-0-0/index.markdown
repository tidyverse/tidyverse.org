---
title: tibble 3.0.0
slug: tibble-3-0-0
description: >
    tibble 3.0.0 is on CRAN now! Tibbles are a modern reimagining of the data frame, keeping what time has shown to be effective, and throwing out what is not, with nicer default output too! This article describes the latest major release and provides an outlook on further developments
date: 2020-03-30
author: Kirill Müller
photo:
  url: https://unsplash.com/photos/dbOV1qSiL-c
  author: Vinicius Amano
categories:
- package
- programming
---





Version 3.0.0 of the tibble package is on CRAN now. Tibbles are a modern reimagining of the data frame, keeping what time has shown to be effective, and throwing out what is not, with nicer default output too! Grab the latest version with:

```r
install.packages("tibble")
```

Tibble now fully embraces vctrs, using it under the hood for its subsetting and subset assignment ("subassignment") operations.
Accessing and updating rows and columns is now based on a rock-solid framework and works consistently for all types of columns, including list, data frame, and 
matrix columns.
We believe that the changes will ultimately lead to better and safer code.

This major release required quite some preparation, including a [new vignette](https://www.tidyverse.org/articles/2018/11/tibble-2.0.0-pre-announce/) that described the behavior of subsetting operations and the reasoning behind it.
Due to the nature of the changes, about 60 CRAN packages were failing with our release candidate.
Thanks to the maintainers of downstream packages who were very helpful in making this upgrade a smooth experience.

In this blog post, I focus on a few user- and programmer-related changes, and give an outlook over future development:

- How to ensure that an object can be part of a tibble
- Sturdy recycling
- Pitfalls with type conversion
- Safe error handling
- Formatting

For a complete overview please see the [release notes](https://github.com/tidyverse/tibble/releases/tag/v2.0.0).

Use the [issue tracker](https://github.com/tidyverse/tibble/issues) to submit bugs or suggest ideas, your contributions are always welcome.


## What can be part of a tibble?

Tibbles and data frames are collections of columns, each is a vector, all have the same length.
Neat.

What is a vector?
What is its length?

The new [vctrs package](https://vctrs.r-lib.org) is dedicated to answering these, surprisingly tricky, questions.
The `vctrs::vec_is()` function decides if an object is a vector.
This is important, because some objects are inherently scalar and cannot be added as a column to a data frame.

Environments, functions, and other "special" types of objects are clearly non-vectors.
It is far less obvious for lists, in particular if they have a `"class"` attribute:


```r
model <- lm(y ~ x, data.frame(x = 1:3, y = 2:4), model = FALSE)
is.list(model)
#> [1] TRUE
length(model)
#> [1] 11
time <- as.POSIXlt(Sys.time())
is.list(time)
#> [1] TRUE
length(time)
#> [1] 1
length(unclass(time))
#> [1] 11
```

By relying on `vctrs::vec_is()`, the `tibble::tibble()` function and others can give an early error if used with an inherent scalar:


```r
library(tibble)
tibble(model)
#> Error: All columns in a tibble must be vectors.
#> x Column `model` is a `lm` object.
tibble(time)
#> # A tibble: 1 x 1
#>   time               
#>   <dttm>             
#> 1 2020-03-30 08:42:18

x <- tibble(time)
x$model <- model
#> Error: `x` must be a vector, not a `lm` object.
```

This is safer than the data frame implementation, which currently allows putting all lists (vector or not) into a column:


```r
y <- data.frame(x = 1)
y$model <- model
#> Error in `$<-.data.frame`(`*tmp*`, model, value = structure(list(coefficients = c(`(Intercept)` = 0.999999999999999, : replacement has 11 rows, data has 1
y <- data.frame(x = 1:11)
y$model <- model
as_tibble(y)
#> Error: All columns in a tibble must be vectors.
#> x Column `model` is a `lm` object.
```

The new `tibble_row()` function reverses this: inherent scalars are wrapped in lists:


```r
tibble_row(model)
#> # A tibble: 1 x 1
#>   model 
#>   <list>
#> 1 <lm>
tibble_row(time)
#> # A tibble: 1 x 1
#>   time               
#>   <dttm>             
#> 1 2020-03-30 08:42:18
tibble_row(time = rep(time, 2))
#> Error: All vectors must be size one, use `list()` to wrap.
#> x Column `time` is of size 2.
```

For the `"POSIXlt"` class, this is handled by vctrs internally.
For your own class, there are two ways to ensure that a list object is treated as a vector:

- Add an explicit `"list"` to its classes
- Implement a `vctrs::vec_proxy()` method


```r
x <- structure(list(1), class = c("foo", "list"))
vctrs::vec_is(x)
#> [1] TRUE

y <- structure(list(1), class = "bar")
vctrs::vec_is(y)
#> [1] FALSE

vec_proxy.bar <- function(x, ...) x
vctrs::vec_is(y)
#> [1] TRUE
```

If you have implemented a vector class (list or not), please add it to my [Awesome vectors](https://github.com/krlmlr/awesome-vctrs#readme) list, or file an issue.

## Sturdy recycling

We always recycled only vectors of size one in `tibble()` and `as_tibble()`.
This now also applies to subassignment.
We believe that most of the time this is an unintended error.
Please use an explicit `rep()` if you really need to store a vector repeated multiple times in a column.


```r
x <- tibble(a = 1:4)
x$a <- 1:2
#> Error: Assigned data `1:2` must be compatible with existing data.
#> x Existing data has 4 rows.
#> x Assigned data has 2 rows.
#> ℹ Only vectors of size 1 are recycled.
x$a <- rep(1:2, 2)
x
#> # A tibble: 4 x 1
#>       a
#>   <int>
#> 1     1
#> 2     2
#> 3     1
#> 4     2
```

Related errors may also appear when applying a pattern that works with data frames:


```r
x <- data.frame(a = 1, b = 2)
x[1, ] <- c(a = 3, b = 4)
x
#>   a b
#> 1 3 4

x <- tibble(a = 1, b = 2)
x[1, ] <- c(a = 3, b = 4)
#> Error: Assigned data `c(a = 3, b = 4)` must be compatible with row subscript `1`.
#> x 1 row must be assigned.
#> x Assigned data has 2 rows.
```

This is because all vectors on the right-hand side are treated as columnar data.
Convert to a list to treat the input as row data:


```r
x[1, ] <- list(a = 3, b = 4)
x
#> # A tibble: 1 x 2
#>       a     b
#>   <dbl> <dbl>
#> 1     3     4
```


## Pitfalls with type conversion and recycling

The vctrs package now also provides a fail-safe way to

- vctrs decides which types are coercible
- clean error message when coercion fails
- updating NA columns

## Classed conditions

- all errors classed
- how to catch
- error classes experimental, subject to change

## Outlook: formatting moves to pillar

- full control over all parts of the tibble
- extensibility for formatting columns
- consolidate formatting code
- printing of data frames

## Acknowledgments

Thanks to the following contributors who sent issues, pull requests, and comments since tibble 2.1.3:

[&#x0040;adamdsmith](https://github.com/adamdsmith), [&#x0040;alankjackson](https://github.com/alankjackson), [&#x0040;anabbott](https://github.com/anabbott), [&#x0040;batpigandme](https://github.com/batpigandme), [&#x0040;billdenney](https://github.com/billdenney), [&#x0040;borisleto](https://github.com/borisleto), [&#x0040;Breza](https://github.com/Breza), [&#x0040;Cervangirard](https://github.com/Cervangirard), [&#x0040;courtiol](https://github.com/courtiol), [&#x0040;dan-reznik](https://github.com/dan-reznik), [&#x0040;daviddalpiaz](https://github.com/daviddalpiaz), [&#x0040;DavisVaughan](https://github.com/DavisVaughan), [&#x0040;elinw](https://github.com/elinw), [&#x0040;EmilHvitfeldt](https://github.com/EmilHvitfeldt), [&#x0040;eran3006](https://github.com/eran3006), [&#x0040;frederikziebell](https://github.com/frederikziebell), [&#x0040;gavinsimpson](https://github.com/gavinsimpson), [&#x0040;gdequeiroz](https://github.com/gdequeiroz), [&#x0040;guiastrennec](https://github.com/guiastrennec), [&#x0040;hadley](https://github.com/hadley), [&#x0040;HashRocketSyntax](https://github.com/HashRocketSyntax), [&#x0040;hope-data-science](https://github.com/hope-data-science), [&#x0040;jennybc](https://github.com/jennybc), [&#x0040;jmgirard](https://github.com/jmgirard), [&#x0040;kevinwolz](https://github.com/kevinwolz), [&#x0040;kieranjmartin](https://github.com/kieranjmartin), [&#x0040;krlmlr](https://github.com/krlmlr), [&#x0040;lionel-](https://github.com/lionel-), [&#x0040;LudvigOlsen](https://github.com/LudvigOlsen), [&#x0040;mabafaba](https://github.com/mabafaba), [&#x0040;matteodefelice](https://github.com/matteodefelice), [&#x0040;MatthieuStigler](https://github.com/MatthieuStigler), [&#x0040;md0u80c9](https://github.com/md0u80c9), [&#x0040;michaelquinn32](https://github.com/michaelquinn32), [&#x0040;mitchelloharawild](https://github.com/mitchelloharawild), [&#x0040;moodymudskipper](https://github.com/moodymudskipper), [&#x0040;msberends](https://github.com/msberends), [&#x0040;pavopax](https://github.com/pavopax), [&#x0040;rbjanis](https://github.com/rbjanis), [&#x0040;romainfrancois](https://github.com/romainfrancois), [&#x0040;rvg02010](https://github.com/rvg02010), [&#x0040;sfirke](https://github.com/sfirke), [&#x0040;Shians](https://github.com/Shians), [&#x0040;ShixiangWang](https://github.com/ShixiangWang), [&#x0040;stephensrmmartin](https://github.com/stephensrmmartin), [&#x0040;stufield](https://github.com/stufield), [&#x0040;Tazinho](https://github.com/Tazinho), [&#x0040;TimTeaFan](https://github.com/TimTeaFan), [&#x0040;tyluRp](https://github.com/tyluRp), [&#x0040;wgrundlingh](https://github.com/wgrundlingh), [&#x0040;xvrdm](https://github.com/xvrdm), [&#x0040;yannabraham](https://github.com/yannabraham), [&#x0040;ycroissant](https://github.com/ycroissant), [&#x0040;yogat3ch](https://github.com/yogat3ch), and [&#x0040;yutannihilation](https://github.com/yutannihilation).

Your contributions are very valuable and important to us!
