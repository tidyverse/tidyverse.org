---
slug: dplyr-1-0-0-last-minute-additions
title: 'dplyr 1.0.0: last minute additions'
description: >
    Learn about two last-minute additions to dplyr 1.0.0: a chattier 
    `summarise()` with more options for controlling grouping of output,
    and new row manipulation functions inspired by SQL.
author: Hadley Wickham, Kirill Müller
date: '2020-05-06'

output: hugodown::hugo_document

categories:
- package
tags:
- dplyr
- dplyr-1-0-0

photo:
  url: https://unsplash.com/photos/FfbVFLAVscw
  author: Malvestida Magazine
rmd_hash: 3ef0b8a6baa92041

---

This post is the latest in a series of post leading up the the dplyr 1.0.0 release on May 15. So far, the series has covered:

-   [Major lifecycle changes](https://www.tidyverse.org/blog/2020/03/dplyr-1-0-0-is-coming-soon/).
-   [New `summarise()` features](https://www.tidyverse.org/blog/2020/03/dplyr-1-0-0-summarise/).
-   [`select()`, `rename()`, and (new) `relocate()`](https://www.tidyverse.org/blog/2020/03/dplyr-1-0-0-select-rename-relocate/).
-   [Working `across()` columns](https://www.tidyverse.org/blog/2020/04/dplyr-1-0-0-colwise/).
-   [Working within rows](https://www.tidyverse.org/blog/2020/04/dplyr-1-0-0-rowwise/).
-   [The role of the vctrs package](https://www.tidyverse.org/blog/2020/04/dplyr-1-0-0-and-vctrs/).
-   [Notes for package developers](https://www.tidyverse.org/blog/2020/04/dplyr-1-0-0-package-dev/).

Today I wanted to talk about two cool new features that we've added since I started blogging about dplyr 1.0.0: `summarise()` now gives you greater control over how the results are grouped, and a new set of functions make it easier to modify rows.

### Getting the dev version

If you'd like to try out anything you see in this blog post, you can install the development version of dplyr with:

``` r
devtools::install_github("tidyverse/dplyr")
```

Note that the development version won't become 1.0.0 until it's released, but at this point, it's very similar to what we'll be submitting to CRAN on May 15.

``` r
library(dplyr, warn.conflicts = FALSE)
```

`summarise()` and grouping
--------------------------

There\'s a common confusion about the result of `summarise()`. How do you think the result of the following code will be grouped?

``` r
homeworld_species <- starwars %>% 
  group_by(homeworld, species) %>% 
  summarise(n = n())
```

You might be surprised to learn that it's grouped by `homeworld`:

``` r
head(homeworld_species, 3)
#> # A tibble: 3 x 3
#> # Groups:   homeworld [3]
#>   homeworld   species     n
#>   <chr>       <chr>   <int>
#> 1 Alderaan    Human       3
#> 2 Aleen Minor Aleena      1
#> 3 Bespin      Human       1
```

That's because `summarise()` always peels off the last group, based on the logic that this group now occupies a single row so there's no point grouping by it. This behaviour made perfect sense to me at the time I implemented it, but it's been a long standing source of confusion among dplyr users (and it doesn't make sense if your summary [returns multiple rows](https://www.tidyverse.org/blog/2020/03/dplyr-1-0-0-summarise/)).

Unfortunately, it would be very difficult to change this default now because a lot of code probably relies on it. Instead, we're doing the next best thing: exposing the default behaviour more explicitly and making it easier to change. In dplyr 1.0.0, the code above will display a message telling you how the result has been grouped:

``` r
homeworld_species <- starwars %>% 
  group_by(homeworld, species) %>% 
  summarise(n = n())
#> `summarise()` regrouping output by 'homeworld' (override with `.groups` argument)
```

The text hints at how to take control of grouping and eliminate the message: a new `.groups` argument allows you to control the grouping of the result. It currently has four possible values:

-   `.groups = "drop_last"` drops the last grouping level (i.e. the default behaviour sans message).
-   `.groups = "drop"` drops all grouping levels and returns a tibble.
-   `.groups = "keep"` preserves the grouping of the input.
-   `.groups = "rowwise"` turns each row into [its own group](https://www.tidyverse.org/blog/2020/04/dplyr-1-0-0-rowwise/).

If you find the default message annoying, you can suppress by setting a global option:

``` r
options(dplyr.summarise.inform = FALSE)
```

`.groups` is very new, so we've marked it as experimental, meaning that it may change in the future. Please let us know what you think of it to help us make a decision about its future.

Row mutation
------------

Thanks to [Kirill Müller](http://krlmlr.info/), dplyr has a new experimental family of row mutation functions inspired by SQL's `UPDATE`, `INSERT`, `UPSERT`, and `DELETE`. Like the join functions, they all work with a pair of data frames:

-   `rows_update(x, y)` updates existing rows in `x` with values in `y`.
-   `rows_patch(x, y)` works like `rows_update()` but only changes `NA` values.
-   `rows_insert(x, y)` adds new rows to `x` from `y`.
-   `rows_upsert(x, y)` updates existing rows in `x` and adds new rows from `y`.
-   `rows_delete(x, y)` deletes rows in `x` that match rows in `y`.

The `rows_` functions match `x` and `y` using **keys**. A key is one or more variables that uniquely identifies each row. All `rows_` functions check that the keys of `x` and `y` are valid (i.e. unique) before doing anything.

Let's see how these work with some toy data:

``` r
df <- tibble(a = 1:3, b = letters[c(1:2, NA)], c = 0.5 + 0:2)
df
#> # A tibble: 3 x 3
#>       a b         c
#>   <int> <chr> <dbl>
#> 1     1 a       0.5
#> 2     2 b       1.5
#> 3     3 <NA>    2.5
```

We can use `rows_insert()` to add new rows:

``` r
new <- tibble(a = c(4, 5), b = c("d", "e"), c = c(3.5, 4.5))
df %>% rows_insert(new)
#> Matching, by = "a"
#> # A tibble: 5 x 3
#>       a b         c
#>   <dbl> <chr> <dbl>
#> 1     1 a       0.5
#> 2     2 b       1.5
#> 3     3 <NA>    2.5
#> 4     4 d       3.5
#> 5     5 e       4.5
```

Note that `rows_insert()` will fail if we attempt to insert a row that already exists:

``` r
df %>% rows_insert(tibble(a = 3, b = "c"))
#> Matching, by = "a"
#> Error: Attempting to insert duplicate rows.
```

(The error messages are very minimal right now; if people find these functions useful we'll invest more effort in useful errors.)

If you want to update existing values, use `rows_update()`. As you might expect, it'll error if one of the rows to update doesn't exist:

``` r
df %>% rows_update(tibble(a = 3, b = "c"))
#> Matching, by = "a"
#> # A tibble: 3 x 3
#>       a b         c
#>   <int> <chr> <dbl>
#> 1     1 a       0.5
#> 2     2 b       1.5
#> 3     3 c       2.5

df %>% rows_update(tibble(a = 4, b = "d"))
#> Matching, by = "a"
#> Error: Attempting to update missing rows.
```

`rows_patch()` is a variant of `rows_update()` that will only update values in `x` that are `NA`.

``` r
df %>% 
  rows_patch(tibble(a = 2:3, b = "B"))
#> Matching, by = "a"
#> # A tibble: 3 x 3
#>       a b         c
#>   <int> <chr> <dbl>
#> 1     1 a       0.5
#> 2     2 b       1.5
#> 3     3 B       2.5
```

If you want to update or insert, you can use `rows_upsert()`:

``` r
df %>% 
  rows_upsert(tibble(a = 3, b = "c")) %>% 
  rows_upsert(tibble(a = 4, b = "d"))
#> Matching, by = "a"
#> Matching, by = "a"
#> # A tibble: 4 x 3
#>       a b         c
#>   <dbl> <chr> <dbl>
#> 1     1 a       0.5
#> 2     2 b       1.5
#> 3     3 c       2.5
#> 4     4 d      NA
```

These functions are designed particularly with an eye towards mutable backends where you really might want to modify existing datasets in place (e.g. data.tables, databases, and googlesheets). That's a dangerous operation so you'll need to explicitly opt-in to modification with `in_place = TRUE`. For example, the [dm package](https://krlmlr.github.io/dm/) will use these functions to update multiple related tables in the correct order, in memory or on the database. Expect to hear more about this in the future.
