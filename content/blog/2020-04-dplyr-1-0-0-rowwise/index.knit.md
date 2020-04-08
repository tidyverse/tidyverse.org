---
title: 'dplyr 1.0.0: working within rows'
author: Hadley Wickham
date: '2020-04-10'
slug: dplyr-1-0-0-rowwise
categories:
  - package
tags:
  - dplyr
photo:
  author: Oleksandr Hrebelnyk
  url: https://unsplash.com/photos/ckZU2xZUjO8
---



This post is the latest in a series of post leading up the the dplyr 1.0.0 release. So far, the series has covered:

* [Major lifecycle changes](https://www.tidyverse.org/blog/2020/03/dplyr-1-0-0-is-coming-soon/).
* [New `summarise()` features](https://www.tidyverse.org/blog/2020/03/dplyr-1-0-0-summarise/).
* [`select()`, `rename()`, `relocate()`](https://www.tidyverse.org/blog/2020/03/dplyr-1-0-0-select-rename-relocate/).
* [Working `across()` columns](https://www.tidyverse.org/blog/2020/04/dplyr-1-0-0-colwise/).

Today, I wanted to talk a little bit about the renewed `rowwise()` function that makes it easy to perform operation on a row-by-row basis. This blog post hits the high points of [`vignette("rowwise")`](https://dplyr.tidyverse.org/dev/articles/rowwise.html); please read it for more details.

### Getting the dev version

If you're interested in living life on the edge (or trying out anything you see in this blog post), you can install the development version of dplyr with:


```r
devtools::install_github("tidyverse/dplyr")
```

Note that the development version won't become 1.0.0 until it's released, but it has all the same features.


```r
library(dplyr, warn.conflicts = FALSE)
```

## Basic operation

`rowwise()` works like `group_by()` in the sense that it doesn't change what the data looks like; it changes how dplyr verbs operate on it. Let's see how this works with a simple example:


```r
df <- tibble(student_id = 1:6, test1 = 10:15, test2 = 20:25, test3 = 30:35, test4 = 40:45)
df
#> # A tibble: 6 x 5
#>   student_id test1 test2 test3 test4
#>        <int> <int> <int> <int> <int>
#> 1          1    10    20    30    40
#> 2          2    11    21    31    41
#> 3          3    12    22    32    42
#> 4          4    13    23    33    43
#> 5          5    14    24    34    44
#> 6          6    15    25    35    45
```
Imagine you wanted compute the total score across all four tests. Using `mutate()` and `sum()` on a regular data frame doesn't work because it computes the sum over all rows:


```r
df %>% mutate(total = sum(c(test1, test2, test3, test4)))
#> # A tibble: 6 x 6
#>   student_id test1 test2 test3 test4 total
#>        <int> <int> <int> <int> <int> <int>
#> 1          1    10    20    30    40   660
#> 2          2    11    21    31    41   660
#> 3          3    12    22    32    42   660
#> 4          4    13    23    33    43   660
#> 5          5    14    24    34    44   660
#> 6          6    15    25    35    45   660
```
We want to compute the sum for each row, so we can instead use a "row-wise" data frame created with `rowwise()`. This data frame _looks_ very similar to the original, but _behaves_ very differently:


```r
rf <- rowwise(df, student_id)
rf
#> # A tibble: 6 x 5
#> # Rowwise:  student_id
#>   student_id test1 test2 test3 test4
#>        <int> <int> <int> <int> <int>
#> 1          1    10    20    30    40
#> 2          2    11    21    31    41
#> 3          3    12    22    32    42
#> 4          4    13    23    33    43
#> 5          5    14    24    34    44
#> 6          6    15    25    35    45

rf %>% mutate(total = sum(c(test1, test2, test3, test4)))
#> # A tibble: 6 x 6
#> # Rowwise:  student_id
#>   student_id test1 test2 test3 test4 total
#>        <int> <int> <int> <int> <int> <int>
#> 1          1    10    20    30    40   100
#> 2          2    11    21    31    41   104
#> 3          3    12    22    32    42   108
#> 4          4    13    23    33    43   112
#> 5          5    14    24    34    44   116
#> 6          6    15    25    35    45   120
```

(Note that the arguments to `rowwise()` are "identifier" variables, which are kind of like the grouping variables used by `group_by()`. Unlike `group_by()` they don't affect the grouping (since it's always per row), but are preserved when you use `summarise()`.)

The additional advantage of `rowwise()` is that's it's paired with `c_across()`. `c_across()` works like `c()` but uses the same tidyselect syntax as `across()` so you can easily select multiple variables:


```r
rf %>% mutate(total = sum(c_across(starts_with("test"))))
#> # A tibble: 6 x 6
#> # Rowwise:  student_id
#>   student_id test1 test2 test3 test4 total
#>        <int> <int> <int> <int> <int> <int>
#> 1          1    10    20    30    40   100
#> 2          2    11    21    31    41   104
#> 3          3    12    22    32    42   108
#> 4          4    13    23    33    43   112
#> 5          5    14    24    34    44   116
#> 6          6    15    25    35    45   120
```
### Other ways of achieving the same result

For some summary functions, its possible to achieve the same results without using `rowwise()`, and this is generally advantageous because you'll get the advantage of native vectorisation





















