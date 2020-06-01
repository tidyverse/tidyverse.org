---
slug: dplyr-1-0-0-colwise
title: 'dplyr 1.0.0: working across columns'
author: Hadley Wickham
date: '2020-04-03'

output: hugodown::hugo_document

categories:
- package
tags:
- dplyr
- dplyr-1-0-0

photo:
  author: Alexey Derevtsov
  url: https://unsplash.com/photos/Atl1BCVM2fo
rmd_hash: 009cba49d1ab674c

---

Today, I wanted to talk a little bit about the new `across()` function that makes it easy to perform the same operation on multiple columns.

------------------------------------------------------------------------

**Update**: as of June 1, dplyr 1.0.0 is now available on CRAN! Read [all about it](/blog/2020/06/dplyr-1-0-0/) or install it now with `install.packages("dplyr")`.

------------------------------------------------------------------------

Motivation
----------

It's often useful to perform the same operation on multiple columns, but copying and pasting is both tedious and error prone:

``` r
df %>% 
  group_by(g1, g2) %>% 
  summarise(a = mean(a), b = mean(b), c = mean(c), d = mean(c))
```

You can now rewrite such code using `across()`, which lets you apply a transformation to multiple variables selected with the same syntax as [`select()` and `rename()`](https://www.tidyverse.org/blog/2020/03/dplyr-1-0-0-select-rename-relocate/#select-and-renaming):

``` r
df %>% 
  group_by(g1, g2) %>% 
  summarise(across(a:d, mean))

# or with a function
df %>% 
  group_by(g1, g2) %>% 
  summarise(across(where(is.numeric), mean))
```

You might be familiar with `summarise_if()` and `summarise_at()` which we previously recommended for this sort of operation. Later in the blog post we'll come back to why we now prefer `across()`. But for now, let's dive into the basics of `across()`.

Basic usage
-----------

`across()` has two primary arguments:

-   The first argument, `.cols`, selects the columns you want to operate on. It uses the tidy select syntax so you can pick columns by position, name, function of name, type, or any combination thereof using Boolean operators.

-   The second argument, `.fns`, is a function or list of functions to apply to each column. You can use also purrr style formulas like `~ .x / 2`.

Here are a couple of examples of `across()` used with `summarise()`:

``` r
library(dplyr, warn.conflicts = FALSE)

starwars %>% 
  summarise(across(where(is.character), n_distinct))
#> # A tibble: 1 x 8
#>    name hair_color skin_color eye_color   sex gender homeworld species
#>   <int>      <int>      <int>     <int> <int>  <int>     <int>   <int>
#> 1    87         13         31        15     5      3        49      38

starwars %>% 
  group_by(species) %>% 
  filter(n() > 1) %>% 
  summarise(across(c(sex, gender, homeworld), n_distinct))
#> `summarise()` ungrouping output (override with `.groups` argument)
#> # A tibble: 9 x 4
#>   species    sex gender homeworld
#>   <chr>    <int>  <int>     <int>
#> 1 Droid        1      2         3
#> 2 Gungan       1      1         1
#> 3 Human        2      2        16
#> 4 Kaminoan     2      2         1
#> 5 Mirialan     1      1         1
#> 6 Twi'lek      2      2         1
#> 7 Wookiee      1      1         1
#> 8 Zabrak       1      1         2
#> 9 <NA>         1      1         3

starwars %>% 
  group_by(homeworld) %>% 
  filter(n() > 1) %>% 
  summarise(across(where(is.numeric), mean, na.rm = TRUE), n = n())
#> `summarise()` ungrouping output (override with `.groups` argument)
#> # A tibble: 10 x 5
#>    homeworld height  mass birth_year     n
#>    <chr>      <dbl> <dbl>      <dbl> <int>
#>  1 Alderaan    176.  64         43       3
#>  2 Corellia    175   78.5       25       2
#>  3 Coruscant   174.  50         91       3
#>  4 Kamino      208.  83.1       31.5     3
#>  5 Kashyyyk    231  124        200       2
#>  6 Mirial      168   53.1       49       2
#>  7 Naboo       175.  64.2       55      11
#>  8 Ryloth      179   55         48       2
#>  9 Tatooine    170.  85.4       54.6    10
#> 10 <NA>        139.  82        334.     10
```

Other cool features
-------------------

You'll find a lot more about `across()` in [`vignette("colwise")`](https://dplyr.tidyverse.org/dev/articles/colwise.html). There are three cool features you might be particularly interested in:

-   You can use it with [multiple summary functions](https://dplyr.tidyverse.org/dev/articles/colwise.html#multiple-functions).

-   You can use it with [any dplyr verb](https://dplyr.tidyverse.org/dev/articles/colwise.html#other-verbs).

-   If needed, you can access the name of the column currently being processed with [`cur_column()`](https://dplyr.tidyverse.org/dev/articles/colwise.html#current-column).

Why `across()`?
---------------

If you've tackled this problem with an older version of dplyr, you might've used one of the functions with an `_if`, `_at`, or `_all` suffix. These functions solved a pressing need and are used by many people, but are now superseded. This means that they'll stay around, but will only receive critical bug fixes.

Why did we decide to move away from these functions in favour of `across()`?

1.  `across()` makes it possible to compute useful summaries that were previously impossible. For example, it's now easy to summarise numeric vectors with one function, factors with another, and still compute the number of rows in each group:

    ``` r
    df %>%
      group_by(g1, g2) %>% 
      summarise(
        across(where(is.numeric), mean), 
        across(where(is.factor), nlevels),
        n = n(), 
      )
    ```

2.  `across()` reduces the number of functions that dplyr needs to provide. This makes dplyr easier for you to use (because there are fewer functions to remember) and easier for us to develop (since we only need to implement one function for each new verb, not four).

3.  With the `where()` helper, `across()` unifies `_if` and `_at` semantics, allowing combinations that used to be impossible. For example, you can now transform all numeric columns whose name begins with "x": `across(where(is.numeric) & starts_with("x"))`.

4.  `across()` doesn't need `vars()`. The `_at()` functions are the only place in dplyr where you have to use `vars()`, which makes them unusual, and hence harder to learn and remember.

Why did it take it long to discover `across()`? Surprisingly, the key idea that makes `across()` works came out of our low-level work on the [vctrs](http://vctrs.r-lib.org/) package, where we learnt that you can have a column of a data frame that is itself a data frame. It's a bummer that we had a few false starts before we discovered `across()`, but even with hindsight, I don't see how we could've skipped the intermediate steps.

Converting existing code
------------------------

If you want to update your existing code to use `across()` instead of the `_if`, `_at`, or `_all()` functions, it's generally straightforward:

-   Strip the `_if()`, `_at()` and `_all()` suffix off the function.

-   Call `across()`. The first argument will be:

    1.  For `_if()`, the old second argument.
    2.  For `_at()`, the old second argument. If there was a single element in `vars()` you can remove `vars()`, otherwise replace it with `c()`.
    3.  For `_all()`, `everything()`.

    The subsequent arguments can be copied as is.

Here are a few examples of this process:

``` r
df %>% mutate_if(is.numeric, mean, na.rm = TRUE)
# ->
df %>% mutate(across(where(is.numeric), mean, na.rm = TRUE))

df %>% mutate_at(vars(x, starts_with("y")), mean, na.rm = TRUE)
# ->
df %>% mutate(across(c(x, starts_with("y")), mean, na.rm = TRUE))

df %>% mutate_all(mean, na.rm = TRUE)
# ->
df %>% mutate(across(everything(), mean, na.rm = TRUE))
```

If you've used multiple `_if`/`_at`/`_all` functions in a row, you should also consider if it's now possible to collapse them into a single call, using the new features of `across()`.

Again, you don't need to worry about these functions going away in the short-term, but it's good practice to keep your code up-to-date. Note, however, that `across()` currently has a little more overhead than the older approaches so it will be a little slower. We have a plan to improve the performance in dplyr 1.1.0.
