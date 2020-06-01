---
slug: dplyr-1-0-0-select-rename-relocate
title: 'dplyr 1.0.0: select, rename, relocate'
author: Hadley Wickham
date: '2020-03-27'
description: >
  `select()` and `rename()` can now select by position, name, function of
  name, type, and any combination thereof. A new `relocate()` function 
  makes it easy to change the position of columns.

output: hugodown::hugo_document

categories:
- package
tags:
- dplyr
- dplyr-1-0-0

photo:
  url: https://unsplash.com/photos/sxNt9g77PE0
  author: Erda Estremera
rmd_hash: 09d2ce43b9796704

---

[dplyr 1.0.0 is coming soon](https://www.tidyverse.org/blog/2020/03/dplyr-1-0-0-is-coming-soon/), and last week we showed how [`summarise()` is growing](https://www.tidyverse.org/blog/2020/03/dplyr-1-0-0-summarise/). Today, I wanted to talk a little bit about functions for selecting, renaming, and relocating columns.

------------------------------------------------------------------------

**Update**: as of June 1, dplyr 1.0.0 is now available on CRAN! Read [all about it](/blog/2020/06/dplyr-1-0-0/) or install it now with `install.packages("dplyr")`.

------------------------------------------------------------------------

### *Update notice*

We have updated the syntax for selecting with a function. Where you would use `data %>% select(is.numeric)` in the early development versions, you must now use `data %>% select(where(is.numeric))`. We made this change to avoid puzzling error messages when a variable is unexpectedly missing from the data frame and there is a corresponding function in the environment:

``` r
# Attempts to invoke `data()` function
data.frame(x = 1) %>% select(data)
```

The rest of this post has been updated accordingly.

Select and renaming
-------------------

`select()` and `rename()` are now significantly more flexible thanks to enhancements to the [tidyselect](https://tidyselect.r-lib.org/) package. There are now five ways to select variables in `select()` and `rename()`:

-   By **position**: `df %>% select(1, 5, 10)` or `df %>% select(1:4)`. Selecting by position is not generally recommended, but `rename()`ing by position can be very useful, particularly if the variable names are very long, non-syntactic, or duplicated.

-   By **name**: `df %>% select(a, e, j)`, `df %>% select(c(a, e, j))` or `df %>% select(a:d)`.

-   By **function of name**: `df %>% select(starts_with("x"))`, or `df %>% select(ends_with("s"))`. You can also use helpers `contains()` and `matches()` for more flexibly matching.

-   By **type**: `df %>% select(where(is.numeric))`, `df %>% select(where(is.factor))`.

-   By **any combination** of the above using the Boolean operators `!`, `&`, and `|`:

    -   `df %>% select(!where(is.factor))`: selects all non-factor variables.

    -   `df %>% select(where(is.numeric) & starts_with("x"))`: selects all numeric variables that starts with "x".

    -   `df %>% select(starts_with("a") | ends_with("z"))`: selects all variables that starts with "a" or ends with "z".

(We owe a debt of gratitude to [Irene Steves](http://irene.rbind.io/), who put together a [detailed analysis](https://gist.github.com/isteves/afb7ac5a3b185f600d7f130d99142174) showing the challenges of the previous approach, and motivating us to do better.)

Here's a few examples of how you might use these techniques in with some toy data:

``` r
library(dplyr, warn.conflicts = FALSE)

# Rename by position to fix a data frame with duplicated column names
df1 <- tibble(a = 1:5, a = 5:1, .name_repair = "minimal")
df1
#> # A tibble: 5 x 2
#>       a     a
#>   <int> <int>
#> 1     1     5
#> 2     2     4
#> 3     3     3
#> 4     4     2
#> 5     5     1
df1 %>% rename(b = 2)
#> # A tibble: 5 x 2
#>       a     b
#>   <int> <int>
#> 1     1     5
#> 2     2     4
#> 3     3     3
#> 4     4     2
#> 5     5     1

df2 <- tibble(x1 = 1, x2 = "a", x3 = 2, y1 = "b", y2 = 3, y3 = "c", y4 = 4)
# Keep numeric columns
df2 %>% select(where(is.numeric))
#> # A tibble: 1 x 4
#>      x1    x3    y2    y4
#>   <dbl> <dbl> <dbl> <dbl>
#> 1     1     2     3     4

# Or all columns that aren't character
df2 %>% select(!where(is.character))
#> # A tibble: 1 x 4
#>      x1    x3    y2    y4
#>   <dbl> <dbl> <dbl> <dbl>
#> 1     1     2     3     4

# Or columns that start with x and are numeric
df2 %>% select(starts_with("x") & where(is.numeric))
#> # A tibble: 1 x 2
#>      x1    x3
#>   <dbl> <dbl>
#> 1     1     2
```

Programming
-----------

We've also made `select()` and `rename()` a little easier to program with when you have a character vector of variable names, thanks to the new `any_of()` and `all_of()` functions. They both take a character vector of variable names:

``` r
vars <- c("x1", "x2", "y1", "z")
df2 %>% select(any_of(vars))
#> # A tibble: 1 x 3
#>      x1 x2    y1   
#>   <dbl> <chr> <chr>
#> 1     1 a     b
```

`any_of()` supersedes the poorly named `one_of()` function; I have no idea why I called it `one_of()` because it's always selected multiple variables!

They differ only in what happens when variables are not present in the data frame. Where `any_of()` silently ignores the missing columns, `all_of()` throws an error:

``` r
df2 %>% select(all_of(vars))
#> Error: Can't subset columns that don't exist.
#> x Column `z` doesn't exist.
```

You can learn more about programming with tidy selection in [`?dplyr_tidy_select`](https://dplyr.tidyverse.org/dev/reference/dplyr_tidy_select.html).

Renaming programatically
------------------------

The new `rename_with()` makes it easier to rename variables programmatically:

``` r
df2 %>% rename_with(toupper)
#> # A tibble: 1 x 7
#>      X1 X2       X3 Y1       Y2 Y3       Y4
#>   <dbl> <chr> <dbl> <chr> <dbl> <chr> <dbl>
#> 1     1 a         2 b         3 c         4
```

(This pairs well with functions like [`janitor::make_clean_names()`](http://sfirke.github.io/janitor/reference/make_clean_names.html).)

You can optionally choose which columns to apply the transformation to:

``` r
df2 %>% rename_with(toupper, starts_with("x"))
#> # A tibble: 1 x 7
#>      X1 X2       X3 y1       y2 y3       y4
#>   <dbl> <chr> <dbl> <chr> <dbl> <chr> <dbl>
#> 1     1 a         2 b         3 c         4

df2 %>% rename_with(toupper, where(is.numeric))
#> # A tibble: 1 x 7
#>      X1 x2       X3 y1       Y2 y3       Y4
#>   <dbl> <chr> <dbl> <chr> <dbl> <chr> <dbl>
#> 1     1 a         2 b         3 c         4
```

`rename_with()` supersedes `rename_if()` and `rename_at()`; we'll talk more about the other `_if()`, `_at()`, and `_all()` functions in the near future.

`relocate()`
------------

For a long time, people have asked an easy way to change the order of columns in data frame. It's always been possible to perform some transformations with `select()`, but it only worked for simple moves, and felt a bit hacky. dplyr now has a specialised function for moving columns around: `relocate()`. The most common need is to move variables to the front, so that's the default behaviour:

``` r
df3 <- tibble(w = 0, x = 1, y = "a", z = "b")
df3 %>% relocate(y, z)
#> # A tibble: 1 x 4
#>   y     z         w     x
#>   <chr> <chr> <dbl> <dbl>
#> 1 a     b         0     1
df3 %>% relocate(where(is.character))
#> # A tibble: 1 x 4
#>   y     z         w     x
#>   <chr> <chr> <dbl> <dbl>
#> 1 a     b         0     1
```

(It uses the same syntax as `select()` and `rename()` so you can use arbitrarily complex expressions to pick which variables you want to move.)

If you want to move columns to a different position use `.before` or `.after`:

``` r
df3 %>% relocate(w, .after = y)
#> # A tibble: 1 x 4
#>       x y         w z    
#>   <dbl> <chr> <dbl> <chr>
#> 1     1 a         0 b
df3 %>% relocate(w, .before = y)
#> # A tibble: 1 x 4
#>       x     w y     z    
#>   <dbl> <dbl> <chr> <chr>
#> 1     1     0 a     b

# If you want to move columns to the right hand side use `last_col()`
df3 %>% relocate(w, .after = last_col())
#> # A tibble: 1 x 4
#>       x y     z         w
#>   <dbl> <chr> <chr> <dbl>
#> 1     1 a     b         0
```

Column functions
----------------

Together these three functions form a family of functions for working with columns:

-   `select()` changes membership.
-   `rename()` or `rename_with()` to changes names.
-   `relocate()` to changes position.

It's interesting to think about how these compare to their row-based equivalents: `select()` is analogous to `filter()`, and `relocate()` to `arrange()`. There there's no row-wise equivalent to `rename()` because in the tidyverse rows don't have names.
