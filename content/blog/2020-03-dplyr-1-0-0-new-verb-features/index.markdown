---
title: 'dplyr 1.0.0: new `summarise()` features'
author: Hadley Wickham
date: '2020-03-20'
slug: dplyr-1-0-0-new-verb-features
photo:
  url: https://unsplash.com/photos/OmCUSp8o7a4
  author: Brigitte Tohm
categories:
  - package
tags:
  - dplyr
---



As we've mentioned, [dplyr 1.0.0](https://www.tidyverse.org/blog/2020/03/dplyr-1-0-0-is-coming-soon/) is on its way. Today, we've started the official release process by notifying maintainers of packages that have problems with dplyr 1.0.0, and we're planning for a CRAN release on May 1.

If you're interested in living life on the edge (or trying out anything you see in this blog post), you can install the development version of dplyr with:


```r
devtools::install_github("tidyverse/dplyr")
```


```r
library(dplyr)
# not 1.0.0 but contains all the same features
packageVersion("dplyr") 
#> [1] '0.8.99.9000'
```

This post is the first in a series of posts that introduce you to new features in dplyr 1.0.0. Today, I'll start with some big changes to `summarise()` that make it significantly more powerful. 

## Multiple rows and columns

Two big changes make `summarise()` much more flexible. A single summary expression can now return:

* A vector of any length, creating multiple rows.
* A data frame, creating multiple columns.

In other words, each summary previously had to be a single value (one row, one column), and now we've lifted that restriction so each summary can generate a rectangle of arbitrary size. This change makes `summarise()` as powerful as the now superseded `do()`, and makes it possible to eliminate many uses of `tidyr::unnest()`.

This is a big change to `summarise()` but it should have minimal impact on existing code because it _broadens_ the interface: all existing code will continue to work, and a number of inputs that would have previously errored now work. 

## Quantiles

To demonstrate this new feature we'll start by looking at a summary that used to be hard to compute: `quantile()`. `quantile()` was hard to use because it returns multiple values which used to cause `summarise()` to error. Now it's straightforward:


```r
df <- tibble(
  grp = rep(1:2, each = 10), 
  x = c(rnorm(10, -0.25, 1), rnorm(10, 0, 1.5)),
  y = c(rnorm(10, 0.25, 1), rnorm(10, 0, 0.5)),
)
df %>% 
  group_by(grp) %>% 
  summarise(x = quantile(x, c(0.25, 0.5, 0.75)), q = c(0.25, 0.5, 0.75))
#> # A tibble: 6 x 3
#>     grp       x     q
#>   <int>   <dbl> <dbl>
#> 1     1 -1.37    0.25
#> 2     1 -0.496   0.5 
#> 3     1 -0.0599  0.75
#> 4     2 -1.24    0.25
#> 5     2 -0.431   0.5 
#> 6     2  0.803   0.75
```

It would be nice to be able to reduce the duplication in this code so that we don't have to type the quantile values twice. We can now write a simple function to do so because `summarise()` expressions can now return multiple columns:


```r
quantile2 <- function(x, q = c(0.25, 0.5, 0.75)) {
  tibble(x = quantile(x, q), q = q)
}
df %>% 
  group_by(grp) %>% 
  summarise(quantile2(x, c(0.25, 0.5, 0.75)))
#> # A tibble: 6 x 3
#>     grp       x     q
#>   <int>   <dbl> <dbl>
#> 1     1 -1.37    0.25
#> 2     1 -0.496   0.5 
#> 3     1 -0.0599  0.75
#> 4     2 -1.24    0.25
#> 5     2 -0.431   0.5 
#> 6     2  0.803   0.75
```

In the past, one of the challenges of writing this sort of function was naming the columns. For example, when you call `quantile2(y)` it'd be nice if you'd get columns `y` and `y_q`, not `x` and `x_q`. Now, thanks to the recent combination of [glue and tidy evaluation](https://www.tidyverse.org/blog/2020/02/glue-strings-and-tidy-eval/) that behaviour is straightforward to implement: 


```r
quantile2 <- function(x, q = c(0.25, 0.5, 0.75)) {
  tibble("{{ x }}" := quantile(x, q), "{{ x }}_q" := q)
}

df %>% 
  group_by(grp) %>% 
  summarise(quantile2(y, c(0.25, 0.5, 0.75)))
#> # A tibble: 6 x 3
#>     grp       y   y_q
#>   <int>   <dbl> <dbl>
#> 1     1 -0.659   0.25
#> 2     1  0.193   0.5 
#> 3     1  0.692   0.75
#> 4     2 -0.121   0.25
#> 5     2  0.0721  0.5 
#> 6     2  0.381   0.75
```
Figuring out how to name the output columns is a surprisingly complex task and we're still thinking about the best approach. 

## Data frame columns

Note that in the code above, we've been careful not to name the result of `quantile2()`. When we leave the names off, the data frame result is automatically **unpacked** so each column becomes a column in the result. What happens if we name the output?


```r
out <- df %>% 
  group_by(grp) %>% 
  summarise(y = quantile2(y, c(0.25, 0.75)))
out
#> # A tibble: 4 x 2
#>     grp    y$y  $y_q
#>   <int>  <dbl> <dbl>
#> 1     1 -0.659  0.25
#> 2     1  0.692  0.75
#> 3     2 -0.121  0.25
#> 4     2  0.381  0.75
```
Look carefully at the output - you'll see a `$` in the column names. This is a suggestion that something weird is going on and you have what we call a **df-column** because you have a column of a data frame that is itself a data frame! You can confirm that by extracting just that column:


```r
out$y
#> # A tibble: 4 x 2
#>        y   y_q
#>    <dbl> <dbl>
#> 1 -0.659  0.25
#> 2  0.692  0.75
#> 3 -0.121  0.25
#> 4  0.381  0.75
```

And of course, you can dig still deeper to get the individual values:


```r
out$y$y
#> [1] -0.6585828  0.6918536 -0.1214636  0.3812219
```

Df-columns are simultaneously esoteric and prosaic. On one hand they are an oddity of base data frames that are useful in very few places. On the other, they are very closely related ot merged column headers, which judging by the frequency that they are found in spreadsheets, and an incredibly popular tool.

Df-columns are surprisingly important to the internals of dplyr 1.0.0, but you should able to ignore their existence unless you deliberately want to try them out. They're definitely an advanced topic, and are something that we're continuing to play around with. We're also thinking about how improve the tibble print method to make it more obvious that something unusual is going on.

## Non-summaries

In combination with [`rowwise()`](http://dplyr.tidyverse.org/dev/articles/rowwise.html) (more on that in a future blog post), `summarise()` is now sufficiently powerful to replace many workflows that previously required a `map()` or `apply()` function. For example, to read all the all the `.csv` files in the current directory, you could write:


```r
tibble(path = dir(pattern = "\\.csv$")) %>% 
  rowwise(path) %>% 
  summarise(read.csv(path))
```

I feel deeply ambivalent about this code: it seems rather forced to claim that `read.csv()` computes a summary of a file path, but it's rather elegant pattern for reading in many files into a tibble.
