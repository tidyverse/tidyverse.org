---
title: "Coming soon: tibble 2.0.0"
date: 2018-11-28
slug: tibble-2.0.0-pre-announce
author: Kirill Müller, Jenny Bryan
categories: [package]
tags:
  - tibble
  - tidyverse
description: >
    The upcoming tibble 2.0.0 release has internal changes relevant to package developers who depend on tibble.
photo:
  url: https://unsplash.com/photos/yYawh30qf28
  author: Gabriel Porras
---




Version 2.0.0 of the [tibble package](https://tibble.tidyverse.org) is almost ready for release. Tibbles are a modern reimagining of the data frame, keeping what time has shown to be effective, and throwing out what is not, with nicer default output too! Grab the development version with:


```r
devtools::install_github("tidyverse/tibble")
```

We're making a pre-release announcement, because some changes require the attention of maintainers of packages that import or otherwise depend on tibble.
This post describes how to adapt to the next version of tibble and is also an invitation for maintainers to provide feedback before v2.0.0 is finalized and submitted to CRAN.
The easiest way to get in touch is to file an issue at https://github.com/tidyverse/tibble/issues (or to comment on an existing one).
This blog post is aimed at package developers and those who maintain "production" scripts or apps. A high-level overview of new user-facing features will come in a separate blog post.

## Reverse dependency checks

We ran `R CMD check` for over 3000 CRAN and Bioconductor packages that depend directly or indirectly on the tibble package and compared results obtained with the CRAN versus development version of tibble.
We will notify the maintainers of all affected packages (regardless of the check results of their package) and aim for a CRAN release before Christmas, so the dust has settled in time for [rstudio::conf](https://www.rstudio.com/conference/).

We made pull requests to implement the necessary changes in several of the most heavily downloaded packages. Based on this experience, this post highlights the problems downstream maintainers are most likely to see and how to solve them. Most fixes should be quite simple.

For the full list of changes, features, and bug fixes, please see the [release notes](https://github.com/tidyverse/tibble/tree/master/NEWS.md).

## Tibble construction and validation

End users should use the [`tibble()`](https://tibble.tidyverse.org/dev/reference/tibble.html) function to construct tibbles.
It checks the input for consistency and makes sure that the returned tibble is valid.

Package developers, however, can also consider the low-level [`new_tibble()`](https://tibble.tidyverse.org/dev/reference/new_tibble.html) constructor. Use [`new_tibble()`](https://tibble.tidyverse.org/dev/reference/new_tibble.html) to quickly construct a tibble from a list if you are very sure that the input is well-formed (i.e., a list of vectors of equal length).
This function also supports the construction of subclasses of tibble through the `class` argument.

In the development version of tibble, the [`new_tibble()`](https://tibble.tidyverse.org/dev/reference/new_tibble.html) constructor is a more faithful implementation of the [design advice for S3 classes given in Advanced R](https://adv-r.hadley.nz/s3.html#s3-classes).
Specifically:

- [`new_tibble()`](https://tibble.tidyverse.org/dev/reference/new_tibble.html) is very fast and does very little checking itself.
- The new [`validate_tibble()`](https://tibble.tidyverse.org/dev/reference/new_tibble.html) function is responsible for validating the structure of a tibble.

This means that the `nrow` argument to [`new_tibble()`](https://tibble.tidyverse.org/dev/reference/new_tibble.html) is now mandatory.
We are aware that this might be the single most disruptive change, but we think that any guesswork here would be detrimental to stability (especially in corner cases) and that this particular problem is very easy to fix.
The `nrow` argument already existed in tibble v1.4.2, so code that uses it requires no change and should continue to work.
If you need to add `nrow` arguments to [`new_tibble()`](https://tibble.tidyverse.org/dev/reference/new_tibble.html) calls, you can do so independently of the tibble v2.0.0 release.
Please be aware that `nrow` must be passed as a named argument, because it comes after the ellipsis `...` in the signature. Here are common patterns for setting the `nrow` argument:


```r
library(tibble)

x <- data.frame(a = 1)

# Code that lacks `nrow` fails
new_tibble(x)
#> Error: Must pass a scalar integer as `nrow` argument to `new_tibble()`.

# Fix by specifying `nrow`
new_tibble(x, nrow = nrow(x)) # if x is a data frame
#> # A tibble: 1 x 1
#>       a
#>   <dbl>
#> 1     1

nrow_x <- NROW(x[[1]]) # if x has at least one column
# nrow_x <- ... # if the number of rows is given elsewhere
new_tibble(x, nrow = nrow_x)
#> # A tibble: 1 x 1
#>       a
#>   <dbl>
#> 1     1
```

## Coercion and name repair

The tibble mentality has always been that the user is responsible for managing column names, i.e. names are not automatically munged. This remains true, but the development version of tibble is stricter about names and offers more support for name repair.

In the development version of tibble, by default, column names must exist and be unique. Some packages use [`as_tibble()`](https://tibble.tidyverse.org/dev/reference/as_tibble.html) internally to coerce a dysfunctionally-named object to a tibble and *then* apply proper column names. Here's a typical error and solution:


```r
library(tibble)

(m <- cov(unname(iris[-5])))
#>            [,1]       [,2]       [,3]       [,4]
#> [1,]  0.6856935 -0.0424340  1.2743154  0.5162707
#> [2,] -0.0424340  0.1899794 -0.3296564 -0.1216394
#> [3,]  1.2743154 -0.3296564  3.1162779  1.2956094
#> [4,]  0.5162707 -0.1216394  1.2956094  0.5810063

# problematic approach:
# 1. make tibble
# 2. apply nice names
x <- as_tibble(m)
#> Error: Columns 1, 2, 3, 4 must be named.
#> Use .name_repair to specify repair.
colnames(x) <- letters[1:4]
#> Error in names(x) <- value: 'names' attribute [4] must be the same length as the vector [1]

# better approach that works with tibble v1.4.2 AND dev tibble:
# 1. apply nice names
# 2. make tibble
colnames(m) <- letters[1:4]
as_tibble(m)
#> # A tibble: 4 x 4
#>         a       b      c      d
#>     <dbl>   <dbl>  <dbl>  <dbl>
#> 1  0.686  -0.0424  1.27   0.516
#> 2 -0.0424  0.190  -0.330 -0.122
#> 3  1.27   -0.330   3.12   1.30 
#> 4  0.516  -0.122   1.30   0.581
```

If possible, we recommend applying your "good" column names prior to calling [`as_tibble()`](https://tibble.tidyverse.org/dev/reference/as_tibble.html). This creates code that works with tibble v1.4.2 and the development version, which is very appealing. For good examples, see these pull requests to [drake](https://github.com/ropensci/drake/pull/586), [prophet](https://github.com/facebook/prophet/pull/739), and [broom](https://github.com/tidymodels/broom/pull/536).

It is also possible to use the new `.name_repair` argument in [`tibble()`](https://tibble.tidyverse.org/dev/reference/tibble.html) and [`as_tibble()`](https://tibble.tidyverse.org/dev/reference/as_tibble.html) (more below) to explicitly declare your intention around column names. This code would require `packageVersion("tibble") >= "2.0.0"`:


```r
# Alternative: use new `.name_repair` argument to permit dysfunctional names
m <- cov(unname(iris[-5]))
as_tibble(m, .name_repair = "minimal")
#> # A tibble: 4 x 4
#>        ``      ``     ``     ``
#>     <dbl>   <dbl>  <dbl>  <dbl>
#> 1  0.686  -0.0424  1.27   0.516
#> 2 -0.0424  0.190  -0.330 -0.122
#> 3  1.27   -0.330   3.12   1.30 
#> 4  0.516  -0.122   1.30   0.581

# Alternative: use new `.name_repair` argument to fix dysfunctional names
m <- cov(unname(iris[-5]))
as_tibble(m, .name_repair = "unique")
#> New names:
#> * `` -> `..1`
#> * `` -> `..2`
#> * `` -> `..3`
#> * `` -> `..4`
#> # A tibble: 4 x 4
#>       ..1     ..2    ..3    ..4
#>     <dbl>   <dbl>  <dbl>  <dbl>
#> 1  0.686  -0.0424  1.27   0.516
#> 2 -0.0424  0.190  -0.330 -0.122
#> 3  1.27   -0.330   3.12   1.30 
#> 4  0.516  -0.122   1.30   0.581
```

What is the motivation for this increased attention to column names? The tibble package is offering stronger encouragement for names where each column can be identified by name and, preferably, without having to resort to backticks. Column names that don't meet these requirements are still allowed, but the user needs to permit them explicitly.

After all, there are scenarios where problematic names should be tolerated. For example, after importing data, the user might need to inspect the data in order to determine which columns to keep. Or perhaps the column names contain data that is about to be converted to a proper variable with [`gather()`](https://tidyr.tidyverse.org/reference/gather.html).

The [`tibble()`](https://tibble.tidyverse.org/dev/reference/tibble.html) constructor and the [`as_tibble()`](https://tibble.tidyverse.org/dev/reference/as_tibble.html) generic now support a new `.name_repair` argument that covers most use cases:

- `"minimal"`: No name repair or checks, beyond basic existence.
- `"unique"`: Make sure names are unique and not empty.
- `"check_unique"`: (default value), no name repair, but check they are `unique`.
- `"universal"`: Make the names `unique` and syntactic.
- a function: apply custom name repair (e.g., `.name_repair = make.names` or `.name_repair = ~make.names(., unique = TRUE)` for names in the style of base R).

See [`` ?`name-repair` ``](https://tibble.tidyverse.org/dev/reference/name-repair.html) for more details.

Packages that are in the business of making tibbles may even want to expose the `.name_repair` argument and pass it through to [`tibble()`](https://tibble.tidyverse.org/dev/reference/tibble.html) or [`as_tibble()`](https://tibble.tidyverse.org/dev/reference/as_tibble.html).
For example, this is the approach planned for [readxl](https://readxl.tidyverse.org), which reads rectangular data out of Excel workbooks.

## Deprecation of `validate` in [`as_tibble()`](https://tibble.tidyverse.org/dev/reference/as_tibble.html)

In tibble v1.4.2, [`as_tibble()`](https://tibble.tidyverse.org/dev/reference/as_tibble.html) has a `validate` argument, but its default behaviour value was inconsistent across different methods and there was no equivalent argument for [`tibble()`](https://tibble.tidyverse.org/dev/reference/tibble.html). The `validate` argument is now soft-deprecated and its use will trigger a message, once per session. The `validate` argument will eventually be removed, but for now it can be used jointly with the new `.name_repair` argument (without even triggering a message). This is possible, because fortunately the `.name_repair` argument to [`as_tibble()`](https://tibble.tidyverse.org/dev/reference/as_tibble.html) is ignored in tibble v1.4.2.

Here's what `validate` does in the development version of tibble for tibbles, data frames, and matrices, along with suggested alternatives.

### Tibbles and data frames

The default was `validate = FALSE` for tibbles and `validate = TRUE` for data frames.
Code that worked before for tibbles can now throw unexpected errors if the resulting tibble has problematic names.
To avoid warnings with tibble v2.0.0, use the default instead of `validate = TRUE`, and `.name_repair = "minimal"` in addition to `validate = FALSE`.
If your code targets tibble >= v2.0.0 exclusively, you can remove the `validate` argument.


```r
df <- new_tibble(list(a = 5, a = 6), nrow = 1)

# errors, as it should, because names are duplicated ... but also messages
as_tibble(df, validate = TRUE)
#> The `validate` argument to `as_tibble()` is deprecated. Please use `.name_repair` to control column names.
#> Error: Column name `a` must not be duplicated.
#> Use .name_repair to specify repair.

# errors due to default .name_repair = "check_unique"
# (but no error in tibble v1.4.2)
as_tibble(df)
#> Error: Column name `a` must not be duplicated.
#> Use .name_repair to specify repair.

# ensures that the validate = TRUE default is used for tibble < 2.0.0
as_tibble(as.data.frame(df))
#> Error: Column name `a` must not be duplicated.
#> Use .name_repair to specify repair.


# no error ... but still messages
as_tibble(df, validate = FALSE)
#> # A tibble: 1 x 2
#>       a     a
#>   <dbl> <dbl>
#> 1     5     6

# no error, quietly
as_tibble(df, .name_repair = "minimal")
#> # A tibble: 1 x 2
#>       a     a
#>   <dbl> <dbl>
#> 1     5     6

# no error, quietly, compatible with tibble < 2.0.0
as_tibble(df, validate = FALSE, .name_repair = "minimal")
#> # A tibble: 1 x 2
#>       a     a
#>   <dbl> <dbl>
#> 1     5     6
```


### Matrices and other objects

The `validate` argument now triggers a message, it was silently ignored in v1.4.2.
For compatibility with v2.0.0, remove the `validate` argument, or add a consistent `.name_repair` argument.
If you need anything other than `"minimal"` or `"check_unique"` and need to keep the `validate` argument, rename the columns beforehand.


```r
m <- cov(iris[-5])
# Assign colnames() if necessary
as_tibble(m)
#> # A tibble: 4 x 4
#>   Sepal.Length Sepal.Width Petal.Length Petal.Width
#>          <dbl>       <dbl>        <dbl>       <dbl>
#> 1       0.686      -0.0424        1.27        0.516
#> 2      -0.0424      0.190        -0.330      -0.122
#> 3       1.27       -0.330         3.12        1.30 
#> 4       0.516      -0.122         1.30        0.581
as_tibble(m, validate = TRUE, .name_repair = "check_unique")
#> # A tibble: 4 x 4
#>   Sepal.Length Sepal.Width Petal.Length Petal.Width
#>          <dbl>       <dbl>        <dbl>       <dbl>
#> 1       0.686      -0.0424        1.27        0.516
#> 2      -0.0424      0.190        -0.330      -0.122
#> 3       1.27       -0.330         3.12        1.30 
#> 4       0.516      -0.122         1.30        0.581
```


## Deprecation of `tidy_names()` and `set_tidy_names()`

The existing `tidy_names()` and `set_tidy_names()` functions are soft-deprecated, but remain available, unchanged. In the future, they could go away or take on a new meaning, i.e. implement a different algorithm for name repair. New code should use `.name_repair` instead.


```r
df <- new_tibble(list(a = 5, a = 6), nrow = 1)

# these functions are soft-deprecated
tidy_names(names(df))
#> New names:
#> a -> a..1
#> a -> a..2
#> [1] "a..1" "a..2"
set_tidy_names(df)
#> New names:
#> a -> a..1
#> a -> a..2
#> # A tibble: 1 x 2
#>    a..1  a..2
#>   <dbl> <dbl>
#> 1     5     6

# achieve same via `.name_repair`
as_tibble(df, .name_repair = "universal")
#> New names:
#> * a -> a..1
#> * a -> a..2
#> # A tibble: 1 x 2
#>    a..1  a..2
#>   <dbl> <dbl>
#> 1     5     6
```

tibble's name repair strategies are currently only exposed in [`tibble()`](https://tibble.tidyverse.org/dev/reference/tibble.html) and [`as_tibble()`](https://tibble.tidyverse.org/dev/reference/as_tibble.html), not (yet?) as utility functions that operate on a vector of names.

## Other changes

Intentionally assigning invalid names to a tibble via `names<-()` is generally a bad idea and this now warns (once per session).


```r
df <- tibble(a = 1)

names(df) <- NA
#> Warning: Column 1 must be named.
#> Warning: Must use a character vector as names.
```

Coercing a vector to a tibble is no longer supported and emits a warning once per session.
It's not clear if the result should be a tibble with one row or one column. We plan to revisit this in a future version, with an unambiguous interface.


```r
x <- 1:3
# Old:
as_tibble(x)
#> Warning: Calling `as_tibble()` on a vector is discouraged, because the
#> behavior is likely to change in the future. Use `enframe(name = NULL)`
#> instead.
#> # A tibble: 3 x 1
#>   value
#>   <int>
#> 1     1
#> 2     2
#> 3     3

# New (>= 2.0.0):
enframe(x, name = NULL)
#> # A tibble: 3 x 1
#>   value
#>   <int>
#> 1     1
#> 2     2
#> 3     3

# New (legacy):
tibble(value = x)
#> # A tibble: 3 x 1
#>   value
#>   <int>
#> 1     1
#> 2     2
#> 3     3
 ```
