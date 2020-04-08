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

`rowwise()` works like `group_by()` in the sense that it doesn't change what the data looks like; it changes how dplyr verbs operate on it.


```r
df <- tibble(id = 1:6, w = 10:15, x = 20:25, y = 30:35, z = 40:45)
rf <- rowwise(df, id)
rf
#> # A tibble: 6 x 5
#> # Rowwise:  id
#>      id     w     x     y     z
#>   <int> <int> <int> <int> <int>
#> 1     1    10    20    30    40
#> 2     2    11    21    31    41
#> 3     3    12    22    32    42
#> 4     4    13    23    33    43
#> 5     5    14    24    34    44
#> 6     6    15    25    35    45
```
Imagine you wanted add a new variable that sums up `w`, `x`, `y`, and `z`. Using using `sum()` on a regular data frame doesn't work because it computes the sum across all rows:


```r
df %>% summarise(total = sum(c(w, x, y, z)))
#> # A tibble: 1 x 1
#>   total
#>   <int>
#> 1   660
```
But it does what you want on a `rowwise()` data frame:


```r
rf %>% mutate(total = sum(c(w, x, y, z)))
#> # A tibble: 6 x 6
#> # Rowwise:  id
#>      id     w     x     y     z total
#>   <int> <int> <int> <int> <int> <int>
#> 1     1    10    20    30    40   100
#> 2     2    11    21    31    41   104
#> 3     3    12    22    32    42   108
#> 4     4    13    23    33    43   112
#> 5     5    14    24    34    44   116
#> 6     6    15    25    35    45   120
```
With the added advantage you can use `c_across()`, which works returns the same type of data structure as `c()` but uses tidyselect, like `across()`:


```r
rf %>% mutate(total = sum(c_across(is.numeric)))
#> # A tibble: 6 x 6
#> # Rowwise:  id
#>      id     w     x     y     z total
#>   <int> <int> <int> <int> <int> <int>
#> 1     1    10    20    30    40   100
#> 2     2    11    21    31    41   104
#> 3     3    12    22    32    42   108
#> 4     4    13    23    33    43   112
#> 5     5    14    24    34    44   116
#> 6     6    15    25    35    45   120
```
### Other ways of achieving the same result

For some summary functions, its possible to achieve the same results without using `rowwise()`, and this is generally advantageous because you'll get the advantage of native vectorisation


```r
df %>% mutate(total = w + x + y + z)
#> # A tibble: 6 x 6
#>      id     w     x     y     z total
#>   <int> <int> <int> <int> <int> <int>
#> 1     1    10    20    30    40   100
#> 2     2    11    21    31    41   104
#> 3     3    12    22    32    42   108
#> 4     4    13    23    33    43   112
#> 5     5    14    24    34    44   116
#> 6     6    15    25    35    45   120
```

You can use the same basic approach with means:


```r
df %>% mutate(avg = (w + x + y + z) / 4)
#> # A tibble: 6 x 6
#>      id     w     x     y     z   avg
#>   <int> <int> <int> <int> <int> <dbl>
#> 1     1    10    20    30    40    25
#> 2     2    11    21    31    41    26
#> 3     3    12    22    32    42    27
#> 4     4    13    23    33    43    28
#> 5     5    14    24    34    44    29
#> 6     6    15    25    35    45    30
```

It's also possible to take advantage of `across()`: if you only pass one argument to `across()` it'll return a data frame, and then you can take advantage of a `rowXYZ()` function from base R:


```r
df %>% mutate(total = rowSums(across(is.numeric)))
#> # A tibble: 6 x 6
#>      id     w     x     y     z total
#>   <int> <int> <int> <int> <int> <dbl>
#> 1     1    10    20    30    40   101
#> 2     2    11    21    31    41   106
#> 3     3    12    22    32    42   111
#> 4     4    13    23    33    43   116
#> 5     5    14    24    34    44   121
#> 6     6    15    25    35    45   126
df %>% mutate(avg = rowMeans(across(is.numeric)))
#> # A tibble: 6 x 6
#>      id     w     x     y     z   avg
#>   <int> <int> <int> <int> <int> <dbl>
#> 1     1    10    20    30    40  20.2
#> 2     2    11    21    31    41  21.2
#> 3     3    12    22    32    42  22.2
#> 4     4    13    23    33    43  23.2
#> 5     5    14    24    34    44  24.2
#> 6     6    15    25    35    45  25.2
```

Another family of summary functions have "parallel" extensions where you can provide multiple variables in the arguments:


```r
df %>% mutate(
  min = pmin(w, x, y, z), 
  max = pmax(w, x, y, z), 
  string = paste(w, x, y, z, sep = "-")
)
#> # A tibble: 6 x 8
#>      id     w     x     y     z   min   max string     
#>   <int> <int> <int> <int> <int> <int> <int> <chr>      
#> 1     1    10    20    30    40    10    40 10-20-30-40
#> 2     2    11    21    31    41    11    41 11-21-31-41
#> 3     3    12    22    32    42    12    42 12-22-32-42
#> 4     4    13    23    33    43    13    43 13-23-33-43
#> 5     5    14    24    34    44    14    44 14-24-34-44
#> 6     6    15    25    35    45    15    45 15-25-35-45
```
The advantage of `rowwise()` + `c_across()` is that you can use it with any summary function, not just those with infix, row-wise, or parallel forms.

## List-columns

`rowwise()` is a sort of general vectorisation tool, in the same way that the apply family is in base R or the map family is in purrr. This means that you can use `rowwise()` generally instead of for-loops when you're doing the same thing to each row. 

This works particularly well in conjunction with list-columns. A list-column is just a data frame column that's a list. The advantage of a list is that in R, a list can contain anything, so this means that you can put anything in a data frame. This is useful if you want to keep related things together.

I'll start by illustrating the basic idea, ignoring why you might have a list-column in the first place, and then show a examples where you deliberately create list-columns.


```r
df <- tibble(
  x = list(1, 2:3, 4:6)
)
df %>% mutate(l = length(x))
#> # A tibble: 3 x 2
#>   x             l
#>   <list>    <int>
#> 1 <dbl [1]>     3
#> 2 <int [2]>     3
#> 3 <int [3]>     3

df %>% mutate(l = purrr::map_int(x, length))
#> # A tibble: 3 x 2
#>   x             l
#>   <list>    <int>
#> 1 <dbl [1]>     1
#> 2 <int [2]>     2
#> 3 <int [3]>     3
df %>% mutate(l = sapply(x, length))
#> # A tibble: 3 x 2
#>   x             l
#>   <list>    <int>
#> 1 <dbl [1]>     1
#> 2 <int [2]>     2
#> 3 <int [3]>     3

df %>% mutate(l = lengths(x))
#> # A tibble: 3 x 2
#>   x             l
#>   <list>    <int>
#> 1 <dbl [1]>     1
#> 2 <int [2]>     2
#> 3 <int [3]>     3

df %>%
  rowwise() %>%
  mutate(l = length(x))
#> # A tibble: 3 x 2
#> # Rowwise: 
#>   x             l
#>   <list>    <int>
#> 1 <dbl [1]>     1
#> 2 <int [2]>     2
#> 3 <int [3]>     3
```

### How it works

The key difference between rowwise and a grouped df where each group is one row is `[[` vs `[`.


```r
# grouped
n <- nrow(df)
out1 <- integer(n)
for (i in seq_len(n)) {
  out1[[i]] <- length(df$x[i])
}
out1
#> [1] 1 1 1

# rowwise
out2 <- integer(n)
for (i in  seq_len(n)) {
  out2[[i]] <- length(df$x[[i]])
}
out2
#> [1] 1 2 3
```


```r
rf %>% mutate(y2 = y)
#> # A tibble: 6 x 6
#> # Rowwise:  id
#>      id     w     x     y     z    y2
#>   <int> <int> <int> <int> <int> <int>
#> 1     1    10    20    30    40    30
#> 2     2    11    21    31    41    31
#> 3     3    12    22    32    42    32
#> 4     4    13    23    33    43    33
#> 5     5    14    24    34    44    34
#> 6     6    15    25    35    45    35
```

Of course, you only need this when using `mutate()`, not `summarise()`, since `summarise()` can now produce multiple rows:


```r
rf %>% summarise(y2 = y)
#> # A tibble: 6 x 2
#> # Rowwise:  id
#>      id    y2
#>   <int> <int>
#> 1     1    30
#> 2     2    31
#> 3     3    32
#> 4     4    33
#> 5     5    34
#> 6     6    35
```

## Use cases

### Simulation


```r
df <- tribble(
  ~id, ~ n, ~ min, ~ max,
    1,   3,     0,     1,
    2,   2,    10,   100,
    3,   2,   100,  1000,
)

df %>%
  rowwise(id) %>%
  mutate(data = list(runif(n, min, max)))
#> # A tibble: 3 x 5
#> # Rowwise:  id
#>      id     n   min   max data     
#>   <dbl> <dbl> <dbl> <dbl> <list>   
#> 1     1     3     0     1 <dbl [3]>
#> 2     2     2    10   100 <dbl [2]>
#> 3     3     2   100  1000 <dbl [2]>

df %>%
  rowwise(id) %>%
  summarise(x = runif(n, min, max))
#> # A tibble: 7 x 2
#> # Rowwise:  id
#>      id       x
#>   <dbl>   <dbl>
#> 1     1   0.308
#> 2     1   0.146
#> 3     1   0.789
#> 4     2  36.8  
#> 5     2  54.1  
#> 6     3 850.   
#> 7     3 450.
```

### Modelling


```r
mtcars %>% 
  nest_by(cyl) %>% 
  mutate(
    mod = list(lm(mpg ~ wt, data = data)),
    pred = list(predict(mod, data))
  )
#> # A tibble: 3 x 4
#> # Rowwise:  cyl
#>     cyl            data mod    pred      
#>   <dbl> <list<df[,10]>> <list> <list>    
#> 1     4       [11 × 10] <lm>   <dbl [11]>
#> 2     6        [7 × 10] <lm>   <dbl [7]> 
#> 3     8       [14 × 10] <lm>   <dbl [14]>
```

