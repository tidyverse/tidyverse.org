---
title: 'dplyr 1.0.0: modifying individual rows'
author: Kirill Müller, Hadley Wickham
date: '2020-05-04'
slug: dplyr-1-0-0-rows
categories:
  - package
tags:
  - dplyr
photo:
  author: La-Rel Easter
  url: https://unsplash.com/photos/KuCGlBXjH_o
---



This post is the latest in a series of post leading up the the dplyr 1.0.0 release. So far, the series has covered:

* [Major lifecycle changes](https://www.tidyverse.org/blog/2020/03/dplyr-1-0-0-is-coming-soon/).
* [New `summarise()` features](https://www.tidyverse.org/blog/2020/03/dplyr-1-0-0-summarise/).
* [`select()`, `rename()`, `relocate()`](https://www.tidyverse.org/blog/2020/03/dplyr-1-0-0-select-rename-relocate/).
* [Working `across()` columns](https://www.tidyverse.org/blog/2020/04/dplyr-1-0-0-colwise/).
* [Working within rows](https://www.tidyverse.org/blog/2020/04/dplyr-1-0-0-rowwise/).

Today, I'm excited to present an entirely new feature: applying changes to individual rows.
FIXME Summary
FIXME Vignette? You can learn more about all of these topics in  [`vignette("rows")`](https://dplyr.tidyverse.org/dev/articles/rows.html).


### Getting the dev version

If you're interested in living life on the edge (or trying out anything you see in this blog post), you can install the development version of dplyr with:


```r
devtools::install_github("tidyverse/dplyr")
```

Note that the development version won't become 1.0.0 until it's released, but it has all the same features.


```r
library(dplyr, warn.conflicts = FALSE)
```

## Rationale

So far:

- Focused on querying data or applying transformations to the entire dataset
- Updating individual rows cumbersome
- No support for in-place updates on mutable backends (by design!)

Now:

- Consistent new interface, borrowing from SQL
- Specification of changes via data frames
- Designed for in-place updates (opt-in), also for multiple tables via dm
- Safety first: early warning for key mismatch or duplication


## Basic operation

- Consistent new interface: `rows_(x, y, by, ...)`
- Similar to joins, yet different
- Explain semantics
    - `y` is applied onto `x`
    - `by` columns must be perfect match or perfect mismatch
- No tidyselect, because generic and needs to be robust for programming

- Adding rows: similar to `bind_rows()` or `union_all()`, checks for keys


```r
data <- tibble(a = 1:3, b = letters[c(1:2, NA)], c = 0.5 + 0:2)
data
#> # A tibble: 3 x 3
#>       a b         c
#>   <int> <chr> <dbl>
#> 1     1 a       0.5
#> 2     2 b       1.5
#> 3     3 <NA>    2.5
rows_insert(data, tibble(a = 4, b = "z"))
#> Matching, by = "a"
#> # A tibble: 4 x 3
#>       a b         c
#>   <dbl> <chr> <dbl>
#> 1     1 a       0.5
#> 2     2 b       1.5
#> 3     3 <NA>    2.5
#> 4     4 z      NA
rows_insert(data, tibble(a = 3, b = "z"))
#> Matching, by = "a"
#> Error: Attempting to insert duplicate rows.
rows_insert(data, tibble(a = 3, b = "z"), by = c("a", "b"))
#> # A tibble: 4 x 3
#>       a b         c
#>   <dbl> <chr> <dbl>
#> 1     1 a       0.5
#> 2     2 b       1.5
#> 3     3 <NA>    2.5
#> 4     3 z      NA
```


Adding rows:

- similar to `INSERT`
- previously `bind_rows()` or `union_all()`
- checks for keys


```r
data <- tibble(a = 1:3, b = letters[c(1:2, NA)], c = 0.5 + 0:2)
data
#> # A tibble: 3 x 3
#>       a b         c
#>   <int> <chr> <dbl>
#> 1     1 a       0.5
#> 2     2 b       1.5
#> 3     3 <NA>    2.5

# Old way
bind_rows(data, tibble(a = 4, b = "z"))
#> # A tibble: 4 x 3
#>       a b         c
#>   <dbl> <chr> <dbl>
#> 1     1 a       0.5
#> 2     2 b       1.5
#> 3     3 <NA>    2.5
#> 4     4 z      NA

# Now
rows_insert(data, tibble(a = 4, b = "z"))
#> Matching, by = "a"
#> # A tibble: 4 x 3
#>       a b         c
#>   <dbl> <chr> <dbl>
#> 1     1 a       0.5
#> 2     2 b       1.5
#> 3     3 <NA>    2.5
#> 4     4 z      NA
rows_insert(data, tibble(a = 3, b = "z"))
#> Matching, by = "a"
#> Error: Attempting to insert duplicate rows.
rows_insert(data, tibble(a = 3, b = "z"), by = c("a", "b"))
#> # A tibble: 4 x 3
#>       a b         c
#>   <dbl> <chr> <dbl>
#> 1     1 a       0.5
#> 2     2 b       1.5
#> 3     3 <NA>    2.5
#> 4     3 z      NA
```

Updating rows

- similar to `UPDATE ... JOIN`
- equivalent: cumbersome join, mutate, select
- `rows_patch()`: no direct SQL equivalent, useful for tweaking
- checks for keys


```r
# Old way
data %>% 
  left_join(tibble(a = 2:3, b = "z"), by = "a", suffix = c("", ".new")) %>% 
  mutate(b = coalesce(b.new, b)) %>% 
  select(-ends_with(".new"))
#> # A tibble: 3 x 3
#>       a b         c
#>   <int> <chr> <dbl>
#> 1     1 a       0.5
#> 2     2 z       1.5
#> 3     3 z       2.5

# Now
rows_update(data, tibble(a = 2:3, b = "z"))
#> Matching, by = "a"
#> # A tibble: 3 x 3
#>       a b         c
#>   <int> <chr> <dbl>
#> 1     1 a       0.5
#> 2     2 z       1.5
#> 3     3 z       2.5
rows_patch(data, tibble(a = 2:3, b = "z"))
#> Matching, by = "a"
#> # A tibble: 3 x 3
#>       a b         c
#>   <int> <chr> <dbl>
#> 1     1 a       0.5
#> 2     2 b       1.5
#> 3     3 z       2.5

# Variants
rows_update(data, tibble(a = 2:4, b = "z"))
#> Matching, by = "a"
#> Error: Attempting to update missing rows.
rows_upsert(data, tibble(a = 2:4, b = "z"))
#> Matching, by = "a"
#> # A tibble: 4 x 3
#>       a b         c
#>   <int> <chr> <dbl>
#> 1     1 a       0.5
#> 2     2 z       1.5
#> 3     3 z       2.5
#> 4     4 z      NA
```

Deleting rows

- Similar to `DELETE`
- equivalent: `anti_join()`
- checks for keys


```r
rows_delete(data, tibble(a = 2:3))
#> Matching, by = "a"
#> # A tibble: 1 x 3
#>       a b         c
#>   <int> <chr> <dbl>
#> 1     1 a       0.5
rows_delete(data, tibble(a = 2:4))
#> Matching, by = "a"
#> Error: Attempting to delete missing rows.
```

Immutable

- `in_place = TRUE` gives an error, undefined for data frames


```r
data
#> # A tibble: 3 x 3
#>       a b         c
#>   <int> <chr> <dbl>
#> 1     1 a       0.5
#> 2     2 b       1.5
#> 3     3 <NA>    2.5
rows_delete(data, tibble(a = 2:3), in_place = TRUE)
#> Matching, by = "a"
#> Error: Data frames only support `in_place = FALSE`
```


Database operations

- incubating in dm, moving to dbplyr later
- return lazy tables by default, `in_place = TRUE` writes to the database


```r
library(dbplyr)
#> 
#> Attaching package: 'dbplyr'
#> The following objects are masked from 'package:dplyr':
#> 
#>     ident, sql
requireNamespace("dm") # for methods
#> Loading required namespace: dm

data <- memdb_frame(a = 1:3, b = letters[c(1:2, NA)], c = 0.5 + 0:2)
data
#> # Source:   table<dbplyr_001> [?? x 3]
#> # Database: sqlite 3.31.1 [:memory:]
#>       a b         c
#>   <int> <chr> <dbl>
#> 1     1 a       0.5
#> 2     2 b       1.5
#> 3     3 <NA>    2.5

# Now
rows_insert(data, tibble(a = 4, b = "z"))
#> Error in UseMethod("rows_insert"): no applicable method for 'rows_insert' applied to an object of class "c('tbl_SQLiteConnection', 'tbl_dbi', 'tbl_sql', 'tbl_lazy', 'tbl')"
rows_insert(data, memdb_frame(a = 4, b = "z"))
#> Error in UseMethod("rows_insert"): no applicable method for 'rows_insert' applied to an object of class "c('tbl_SQLiteConnection', 'tbl_dbi', 'tbl_sql', 'tbl_lazy', 'tbl')"
data
#> # Source:   table<dbplyr_001> [?? x 3]
#> # Database: sqlite 3.31.1 [:memory:]
#>       a b         c
#>   <int> <chr> <dbl>
#> 1     1 a       0.5
#> 2     2 b       1.5
#> 3     3 <NA>    2.5
rows_insert(data, memdb_frame(a = 4, b = "z"), in_place = TRUE)
#> Error in UseMethod("rows_insert"): no applicable method for 'rows_insert' applied to an object of class "c('tbl_SQLiteConnection', 'tbl_dbi', 'tbl_sql', 'tbl_lazy', 'tbl')"
data
#> # Source:   table<dbplyr_001> [?? x 3]
#> # Database: sqlite 3.31.1 [:memory:]
#>       a b         c
#>   <int> <chr> <dbl>
#> 1     1 a       0.5
#> 2     2 b       1.5
#> 3     3 <NA>    2.5
```
