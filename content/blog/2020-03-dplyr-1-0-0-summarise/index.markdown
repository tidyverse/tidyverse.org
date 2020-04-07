---
title: 'dplyr 1.0.0: new `summarise()` features'
author: Hadley Wickham
date: '2020-03-20'
slug: dplyr-1-0-0-summarise
photo:
  url: https://unsplash.com/photos/OmCUSp8o7a4
  author: Brigitte Tohm
categories:
  - package
tags:
  - dplyr
---



As we've mentioned, [dplyr 1.0.0 is coming soon](https://www.tidyverse.org/blog/2020/03/dplyr-1-0-0-is-coming-soon/). Today, we've started the official release process by notifying maintainers of packages that have problems with dplyr 1.0.0, and we're planning for a CRAN release six weeks later, on May 1. This post is the first in a series that will introduce you to new features in dplyr 1.0.0. Today, I'll start with some big changes to `summarise()` that make it significantly more powerful.

If you're interested in living life on the edge (or trying out anything you see in this blog post), you can install the development version of dplyr with:


```r
devtools::install_github("tidyverse/dplyr")
```

Note that the development version won't become 1.0.0 until it's released, but it has all the same features.


```r
library(dplyr)
packageVersion("dplyr") 
#> [1] '0.8.99.9000'
```

## Multiple rows and columns

Two big changes make `summarise()` much more flexible. A single summary expression can now return:

* A vector of any length, creating multiple rows.
* A data frame, creating multiple columns.

To get a sense for what this means, take this toy dataset:


```r
df <- tibble(
  grp = rep(1:2, each = 5), 
  x = c(rnorm(5, -0.25, 1), rnorm(5, 0, 1.5)),
  y = c(rnorm(5, 0.25, 1), rnorm(5, 0, 0.5)),
)
df
#> # A tibble: 10 x 3
#>      grp        x       y
#>    <int>    <dbl>   <dbl>
#>  1     1 -1.65    -0.304 
#>  2     1  0.00532  0.879 
#>  3     1 -2.69     2.32  
#>  4     1 -0.256   -1.38  
#>  5     1  0.372    0.762 
#>  6     2  1.72    -0.932 
#>  7     2 -2.73    -0.261 
#>  8     2 -0.371   -0.0263
#>  9     2 -0.366    0.271 
#> 10     2 -0.424   -0.457
```

You can now use summaries that return multiple values:


```r
df %>% 
  group_by(grp) %>% 
  summarise(rng = range(x))
#> # A tibble: 4 x 2
#>     grp    rng
#>   <int>  <dbl>
#> 1     1 -2.69 
#> 2     1  0.372
#> 3     2 -2.73 
#> 4     2  1.72
```

Or return multiple columns from a single summary expression: 


```r
df %>% 
  group_by(grp) %>% 
  summarise(tibble(min = min(x), mean = mean(x)))
#> # A tibble: 2 x 3
#>     grp   min   mean
#> * <int> <dbl>  <dbl>
#> 1     1 -2.69 -0.843
#> 2     2 -2.73 -0.434
```
(This isn't very useful when used directly, but as you'll see shortly, it's really useful inside of functions.)

To put this another way, before dplyr 1.0.0, each summary had to be a single value (one row, one column), but now we've lifted that restriction so each summary can generate a rectangle of arbitrary size. This is a big change to `summarise()` but it should have minimal impact on existing code because it _broadens_ the interface: all existing code will continue to work, and a number of inputs that would have previously errored now work. 

## Quantiles

To demonstrate this new flexibility in a more useful situation, let's take a look at `quantile()`. `quantile()` was hard to use previously because it returns multiple values. Now it's straightforward:


```r
df %>% 
  group_by(grp) %>% 
  summarise(x = quantile(x, c(0.25, 0.5, 0.75)), q = c(0.25, 0.5, 0.75))
#> # A tibble: 6 x 3
#>     grp        x     q
#>   <int>    <dbl> <dbl>
#> 1     1 -1.65     0.25
#> 2     1 -0.256    0.5 
#> 3     1  0.00532  0.75
#> 4     2 -0.424    0.25
#> 5     2 -0.371    0.5 
#> 6     2 -0.366    0.75
```

It would be nice to be able to reduce the duplication in this code so that we don't have to type the quantile values twice. We can now write a simple function because summary expressions can now be data frames or tibbles:


```r
quibble <- function(x, q = c(0.25, 0.5, 0.75)) {
  tibble(x = quantile(x, q), q = q)
}
df %>% 
  group_by(grp) %>% 
  summarise(quibble(x, c(0.25, 0.5, 0.75)))
#> # A tibble: 6 x 3
#>     grp        x     q
#>   <int>    <dbl> <dbl>
#> 1     1 -1.65     0.25
#> 2     1 -0.256    0.5 
#> 3     1  0.00532  0.75
#> 4     2 -0.424    0.25
#> 5     2 -0.371    0.5 
#> 6     2 -0.366    0.75
```

In the past, one of the challenges of writing this sort of function was naming the columns. For example, when you call `quibble(y)` it'd be nice if you could get columns `y` and `y_q`, rather than `x` and `x_q`. Now, thanks to the recent combination of [glue and tidy evaluation](https://www.tidyverse.org/blog/2020/02/glue-strings-and-tidy-eval/), that's easy to implement: 


```r
quibble2 <- function(x, q = c(0.25, 0.5, 0.75)) {
  tibble("{{ x }}" := quantile(x, q), "{{ x }}_q" := q)
}

df %>% 
  group_by(grp) %>% 
  summarise(quibble2(y, c(0.25, 0.5, 0.75)))
#> # A tibble: 6 x 3
#>     grp       y   y_q
#>   <int>   <dbl> <dbl>
#> 1     1 -0.304   0.25
#> 2     1  0.762   0.5 
#> 3     1  0.879   0.75
#> 4     2 -0.457   0.25
#> 5     2 -0.261   0.5 
#> 6     2 -0.0263  0.75
```

One note of caution: naming the output columns in a function like this is a surprisingly complex task, we're not yet sure what the best approach is. Expect to hear more about this as we continue to think about and experiment with it.

## Data-frame columns

We've been careful not to name the result of `quibble()` in the code above. That's because when we leave the name off, the data frame result is automatically **unpacked** so each column returned by `quibble()` becomes a column in the result. What happens if we name the output?


```r
out <- df %>% 
  group_by(grp) %>% 
  summarise(y = quibble2(y, c(0.25, 0.75)))
out
#> # A tibble: 4 x 2
#>     grp     y$y  $y_q
#>   <int>   <dbl> <dbl>
#> 1     1 -0.304   0.25
#> 2     1  0.879   0.75
#> 3     2 -0.457   0.25
#> 4     2 -0.0263  0.75
```
Look carefully at the output - you'll see a `$` in the column names. This lets you know that something weird is going on and you have what we call a **df-column**; a column of a data frame that is itself a data frame! 

You can see the structure a little better with `str()`:


```r
str(out)
#> tibble [4 × 2] (S3: tbl_df/tbl/data.frame)
#>  $ grp: int [1:4] 1 1 2 2
#>  $ y  : tibble [4 × 2] (S3: tbl_df/tbl/data.frame)
#>   ..$ y  : num [1:4] -0.3037 0.879 -0.457 -0.0263
#>   ..$ y_q: num [1:4] 0.25 0.75 0.25 0.75
```

And you can see that `y` is indeed a data frame by extracting it:


```r
out$y
#> # A tibble: 4 x 2
#>         y   y_q
#>     <dbl> <dbl>
#> 1 -0.304   0.25
#> 2  0.879   0.75
#> 3 -0.457   0.25
#> 4 -0.0263  0.75
```

And of course, you can dig still deeper to get the individual values:


```r
out$y$y
#> [1] -0.30369938  0.87898204 -0.45703741 -0.02630095
```

These df-columns are simultaneously esoteric and commonplace. On the one hand they are an oddity of data frames that has existed for a long time, but has been used in very few places. On the other hand, they are very closely related to merged column headers, which, judging by how often they're found in spreadsheets, are an incredibly popular tool. Our hope is that they are mostly kept under the covers in dplyr 1.0.0, but you can still deliberately choose to access them if you're interested.

## Non-summaries

In combination with [`rowwise()`](http://dplyr.tidyverse.org/dev/articles/rowwise.html) (more on that in a future blog post), `summarise()` is now sufficiently powerful to replace many workflows that previously required a `map()` or `apply()` function. 

For example, to read all the all the `.csv` files in the current directory, you could write:


```r
tibble(path = dir(pattern = "\\.csv$")) %>% 
  rowwise(path) %>% 
  summarise(read_csv(path))
```

I feel deeply ambivalent about this code: it seems rather forced to claim that `read.csv()` computes a summary of a file path, but it's rather elegant pattern for reading in many files into a tibble.

## Previous approaches

There were a couple of previous approach to solving the quantile problem illustrated above. One way was to create a list-column and then unnest it:


```r
df %>% 
  group_by(grp) %>% 
  summarise(y = list(quibble(y, c(0.25, 0.75)))) %>% 
  tidyr::unnest(y)
#> # A tibble: 4 x 3
#>     grp       x     q
#>   <int>   <dbl> <dbl>
#> 1     1 -0.304   0.25
#> 2     1  0.879   0.75
#> 3     2 -0.457   0.25
#> 4     2 -0.0263  0.75
```

Or to use `do()`:


```r
df %>% 
  group_by(grp) %>% 
  do(quibble(.$y, c(0.25, 0.75)))
#> # A tibble: 4 x 3
#> # Groups:   grp [2]
#>     grp       x     q
#>   <int>   <dbl> <dbl>
#> 1     1 -0.304   0.25
#> 2     1  0.879   0.75
#> 3     2 -0.457   0.25
#> 4     2 -0.0263  0.75
```

 We prefer the new `summarise()` approach because it's concise, doesn't require learning about list-columns and unnesting, and uses a familiar syntax.
