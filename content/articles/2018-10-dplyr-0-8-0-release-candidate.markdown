---
title: dplyr 0.8.0 release candidate
author: Romain François
date: '2018-10-23'
slug: dplyr-0-8-0-release-candidate
description: > 
  What you need to know about upcoming changes for dplyr 0.8.0.
categories:
  - package
tags:
  - dplyr
  - tidyverse
photo:
  url: https://unsplash.com/photos/kU-WKSyTcp4
  author: Pau Casals
---



A new release of dplyr (0.8.0) is on the horizon, and since it is a major release, we'd love for the 
community to try it out, give us some feedback and [report issues](https://github.com/tidyverse/dplyr/issues)
before we submit to CRAN. This version represents about six months of development, making dplyr more
respectful of factors and less surprising in its evaluation of expressions. 

In this post, we'll highlight the major changes, please see the 
[NEWS](https://github.com/tidyverse/dplyr/blob/master/NEWS.md) for a more 
detailed description of changes. Our formalised process for this release is captured 
in [this issue](https://github.com/tidyverse/dplyr/issues/3931)


```r
# install.packages("devtools")
devtools::install_github("tidyverse/dplyr")
```

If needed, you can restore the release version by installing from CRAN:


```r
install.packages("dplyr")
```

# New grouping algorithm

## Group creation

The algorithm behind `group_by()` has been redesigned to better respect factor levels, 
a group is created for each level of the factor, even if there is no data. This 
differs from previous versions of dplyr where groups were only created to 
match the observed data. This closes the epic issue 
[341](https://github.com/tidyverse/dplyr/issues/341) that dates back to 2014. 

Let's illustrate the new algorithm with the [count()](https://dplyr.tidyverse.org/reference/tally.html) 
function:


```r
df <- tibble(
  f1 = factor(c("a", "a", "a", "b", "b"), levels = c("a", "b", "c")), 
  f2 = factor(c("d", "e", "d", "e", "f"), levels = c("d", "e", "f")), 
  x  = c(1, 1, 1, 2, 2), 
  y  = 1:5
)
df
#> # A tibble: 5 x 4
#>   f1    f2        x     y
#>   <fct> <fct> <dbl> <int>
#> 1 a     d         1     1
#> 2 a     e         1     2
#> 3 a     d         1     3
#> 4 b     e         2     4
#> # … with 1 more row
df %>% 
  count(f1)
#> # A tibble: 3 x 2
#>   f1        n
#>   <fct> <int>
#> 1 a         3
#> 2 b         2
#> 3 c         0
```

Where previous versions of `dplyr` would have created only two groups (for levels `a` and `b`), 
it now creates one group per level, and the group related to the level `c` just happens to be 
empty. 

Groups are still made to match the data on other types of columns:


```r
df %>% 
  count(x)
#> # A tibble: 2 x 2
#>       x     n
#>   <dbl> <int>
#> 1     1     3
#> 2     2     2
```

Expansion of groups for factors happens at each step of the grouping, so if we group
by `f1` and `f2` we get 9 groups, 


```r
df %>% 
  count(f1, f2)
#> # A tibble: 9 x 3
#>   f1    f2        n
#>   <fct> <fct> <int>
#> 1 a     d         2
#> 2 a     e         1
#> 3 a     f         0
#> 4 b     d         0
#> # … with 5 more rows
```

When factors and non factors are involved in the grouping, the number of 
groups depends on the order. At each level of grouping, factors are always expanded
to one group per level, but non factors only create groups based on observed data. 


```r
df %>% 
  count(f1, x)
#> # A tibble: 3 x 3
#>   f1        x     n
#>   <fct> <dbl> <int>
#> 1 a         1     3
#> 2 b         2     2
#> 3 c        NA     0
```


In this example, we group by `f1` then `x`. At the first layer, grouping on `f1` creates
two groups. Each of these grouops is then subdivided based on the values of the second 
variable `x`. Since `x` is always 1 when `f1` is `a` the group is not 
further divided. 

The last group, associated with the level `c` of the factor `f1` is empty, and 
consequently has no values for the vector `x`. In that case, `group_by()` uses 
`NA`. 


```r
df %>% 
  count(x, f1)
#> # A tibble: 6 x 3
#>       x f1        n
#>   <dbl> <fct> <int>
#> 1     1 a         3
#> 2     1 b         0
#> 3     1 c         0
#> 4     2 a         0
#> # … with 2 more rows
```

When we group by `x` then `f1` we initially split the data according to `x` which 
gives 2 groups. Each of these two groups is then further divided in 3 groups, 
i.e. one for each level of `f1`. 

## Group preservation

The grouping structure is more coherently preserved by dplyr verbs, and the notion of 
lazy grouped data frame is now obsolete. We needed lazily grouped data frames 
in previous versions because the verbs did not reconstruct the groups. 


```r
df %>% 
  group_by(x, f1) %>% 
  summarise(y = mean(y))
#> # A tibble: 6 x 3
#> # Groups:   x [2]
#>       x f1        y
#>   <dbl> <fct> <dbl>
#> 1     1 a         2
#> 2     1 b       NaN
#> 3     1 c       NaN
#> 4     2 a       NaN
#> # … with 2 more rows
```

The expression `mean(y)` is evaluated for the empty groups as well, and gives 
coherent results with : 


```r
mean(numeric())
#> [1] NaN
```

In particular the result of `filter()` preserves the grouping structure of the input 
data frame. 


```r
df %>% 
  group_by(x, f1) %>% 
  filter(y < 4)
#> # A tibble: 3 x 4
#> # Groups:   x, f1 [6]
#>   f1    f2        x     y
#>   <fct> <fct> <dbl> <int>
#> 1 a     d         1     1
#> 2 a     e         1     2
#> 3 a     d         1     3
```

The resulting tibble after the `filter()` call has six groups, the same 
exact groups that were made by `group_by()`. Previous versions of dplyr
would perform an implicit `group_by()` after the filtering, potentially losing
groups. 

Because this is potentially disruptive, `filter()` has gained a `.preserve` argument, 
the default value (`TRUE`) keeps the existing groups, but
when `.preserve` is `FALSE` the data is first filtered and then grouped by:


```r
df %>% 
  group_by(x, f1) %>% 
  filter(y < 5, .preserve = FALSE)
#> # A tibble: 4 x 4
#> # Groups:   x, f1 [6]
#>   f1    f2        x     y
#>   <fct> <fct> <dbl> <int>
#> 1 a     d         1     1
#> 2 a     e         1     2
#> 3 a     d         1     3
#> 4 b     e         2     4
```

Note however, that even `.preserve = FALSE` respects the factors that are used as 
grouping variables, in particular `filter( , .preserve = FALSE)` is not a way to 
discard empty groups. The forcats 📦 may help: 


```r
iris %>% 
  group_by(Species) %>% 
  filter(stringr::str_detect(Species, "^v")) %>% 
  ungroup() %>% 
  group_by(Species = forcats::fct_drop(Species))
#> # A tibble: 100 x 5
#> # Groups:   Species [2]
#>   Sepal.Length Sepal.Width Petal.Length Petal.Width Species   
#>          <dbl>       <dbl>        <dbl>       <dbl> <fct>     
#> 1          7           3.2          4.7         1.4 versicolor
#> 2          6.4         3.2          4.5         1.5 versicolor
#> 3          6.9         3.1          4.9         1.5 versicolor
#> 4          5.5         2.3          4           1.3 versicolor
#> # … with 96 more rows
```

# Changes in filter and slice

Besides changes described previously related to preservation of the grouping structure, 
`filter()` and `slice()` now reorganize the data by groups for performance reasons: 


```r
tibble(
  x = c(1, 2, 1, 2, 1), 
  y = c(1, 2, 3, 4, 5)
) %>% 
  group_by(x) %>% 
  filter(y < 5)
#> # A tibble: 4 x 2
#> # Groups:   x [2]
#>       x     y
#>   <dbl> <dbl>
#> 1     1     1
#> 2     1     3
#> 3     2     2
#> 4     2     4
```

# Redesigned hybrid evaluation

## What's hybrid evaluation again ?

Hybrid evaluation is used in `summarise()` and `mutate()` to replace 
potential expensive R operations by native C++ code that is group aware. 


```r
iris %>% 
  group_by(Species) %>% 
  summarise(Petal.Length = mean(Petal.Length))
#> # A tibble: 3 x 2
#>   Species    Petal.Length
#>   <fct>             <dbl>
#> 1 setosa             1.46
#> 2 versicolor         4.26
#> 3 virginica          5.55
```

In the example, the `base::mean()` function is never called because the 
hybrid alternative can directly calculate the mean for each group. Hybrid 
evaluation typically gives better performance because it needs less memory
allocations. 

In this example, a standard evaluation path would need to: 
 - create subsets of the `Petal.Length` column for each group
 - call the `base::mean()` function on each subset, which would also 
   imply a cost for S3 dispatching to the right method
 - collect all results in a new vector
 
In constrast, hybrid evaluation can directly allocate the final 
vector, and calculate all 3 means without having to allocate the subsets. 

## Flaws in previous hybrid

Previous versions of hybrid evaluation relied on folding to 
replace part of the expression by their hybrid result. For example, 
there are hybrid versions of `sum()` and `n()`, so previous 
versions attempted to use them for:


```r
iris %>% 
  group_by(Species) %>% 
  summarise(Petal.Length = sum(Petal.Length) / n())
#> # A tibble: 3 x 2
#>   Species    Petal.Length
#>   <fct>             <dbl>
#> 1 setosa             1.46
#> 2 versicolor         4.26
#> 3 virginica          5.55
```

The gain of replacing parts of the expression with the result of the
hybrid versions was minimal, and the we had to rely on 
brittle heuristics to try to respect standard R evaluation semantics. 

## New implementation

The new hybrid system is stricter and falls back to standard R evaluation 

when the expression is not entirely recognized. 

The `hybrid_call()` function (subject to change) can be used to test if an expression
would be handled by hybrid or standard evaluation: 


```r
iris %>% hybrid_call(mean(Sepal.Length))
#> <hybrid evaluation>
#>   call      : base::mean(Sepal.Length)
#>   C++ class : dplyr::hybrid::internal::SimpleDispatchImpl<14, false, dplyr::NaturalDataFrame, dplyr::hybrid::internal::MeanImpl>
iris %>% hybrid_call(sum(Sepal.Length) / n())
#> <standard evaluation>
#>   call      : sum(Sepal.Length)/n()
iris %>% hybrid_call(+mean(Sepal.Length))
#> <standard evaluation>
#>   call      : +mean(Sepal.Length)
```

Hybrid is very picky about what it can handle, for example `TRUE` and `FALSE` 
are fine for `na.rm=` because they are reserved words that can't be replaced, but 
`T`, `F` or any expression that would resolve to a scalar logical are not: 


```r
iris %>% hybrid_call(mean(Sepal.Length, na.rm = TRUE))
#> <hybrid evaluation>
#>   call      : base::mean(Sepal.Length, na.rm = TRUE)
#>   C++ class : dplyr::hybrid::internal::SimpleDispatchImpl<14, true, dplyr::NaturalDataFrame, dplyr::hybrid::internal::MeanImpl>
iris %>% hybrid_call(mean(Sepal.Length, na.rm = T))
#> <standard evaluation>
#>   call      : mean(Sepal.Length, na.rm = T)
iris %>% hybrid_call(mean(Sepal.Length, na.rm = 1 == 1))
#> <standard evaluation>
#>   call      : mean(Sepal.Length, na.rm = 1 == 1)
```

The first step of the new hybrid system consists of studying the 
expression and compare it to known expression patterns. If we find an exact
match, then we have all the information we need, and R is never called 
to materialize the result. 

When there is no match, the expression gets evaluated for each group using R standard 
evaluation rules in the data mask: a special environment that makes the 
columns available and uses contextual information for functions such as `n()`
and `row_number()`. 


```r
iris %>% 
  group_by(Species) %>% 
  summarise(Petal.Length = sum(Petal.Length) / n())
#> # A tibble: 3 x 2
#>   Species    Petal.Length
#>   <fct>             <dbl>
#> 1 setosa             1.46
#> 2 versicolor         4.26
#> 3 virginica          5.55
```

# Performance

When `summarise()` or `mutate()` use expressions that cannot be handled by
hybrid evaluation, they call back to R from the c++ internals for each group. 

This is an expensive operation because the expressions have to be evaluated 
with extra care, traditionally it meant wrapping the expression in an R `tryCatch()` 
before evaluating, but R 3.5.0 has added unwind protection and we exposed that to 
Rcpp. Consequently, the cost of evaluating an R expression carefully is lower 
than before. 

We ran a benchmark of calculating the means of 10 000 small groups with the 
release version of dplyr (0.7.7) and this release candidate with and without 
using the unwind protect feature. 

Just using the `mean()` function would not illustrate the feature, because dplyr would
use hybrid evaluation and never use callbacks to R, so instead we defined a `mean_` 
function that has the same body as `base::mean()`, we also compare this to 
the expression `sum(x) / n()` because it woudld have been handled by 
partial hybrid evaluation in previous versions. 

![](/articles/2018-10-dplyr-0-8-0_files/timings_summarise_mean.jpeg)

The unwind protect feature gives better performance, however 
hybrid evaluation is still very relevant. 

# nest_join

The `nest_join()` function is the newest addition to the join family. 


```r
band_members %>% 
  nest_join(band_instruments)
#> Joining, by = "name"
#> # A tibble: 3 x 3
#>   name  band    band_instruments
#> * <chr> <chr>   <list>          
#> 1 Mick  Stones  <tibble [0 × 1]>
#> 2 John  Beatles <tibble [1 × 1]>
#> 3 Paul  Beatles <tibble [1 × 1]>
```

A nest join of `x` and `y` returns all rows and all columns from `x`, plus an additional column 
that contains a list of tibbles. Each tibble contains all the rows from `y` that match that row of `x`. 
When there is no match, the list column is a 0-row tibble with the same column names and types as `y`.

`nest_join()` is the most fundamental join since you can recreate the other joins from it: 
 - `inner_join()` is a `nest_join()` plus an `tidyr::unnest()`.
 - `left_join()` is a `nest_join()` plus an `unnest(drop = FALSE)`. 
 - `semi_join()` is a `nest_join()` plus a `filter()` where you check that every element of data has at least one row. 
 - `anti_join()` is a `nest_join()` plus a `filter()` where you check every element has zero rows.

# nest_by

With the new grouping algorithm, dplyr gains the `nest_by()` function, and 
associated `nest_by_at()` and `nest_by_if()` column wise variants. `nest_by()` is 
similar to `tidyr::nest()` but focuses on the columns that define the grouping
rather than the columns that are nested. 


```r
iris %>% 
  nest_by(Species)
#> # A tibble: 3 x 2
#>   Species    data             
#>   <fct>      <list>           
#> 1 setosa     <tibble [50 × 4]>
#> 2 versicolor <tibble [50 × 4]>
#> 3 virginica  <tibble [50 × 4]>
```

# split_by

The new function `split_by()` and its column wise variants `split_by_at()` and `split_by_if()`
implements a tidy version of `split()`. We anticipate that `split_by()` + `purrr::map()` will 
replace the `do()` questioning idiom. 


```r
mtcars %>% 
  split_by(cyl) %>% 
  purrr::map(~lm(mpg ~ disp, data = .))
#> [[1]]
#> 
#> Call:
#> lm(formula = mpg ~ disp, data = .)
#> 
#> Coefficients:
#> (Intercept)         disp  
#>     40.8720      -0.1351  
#> 
#> 
#> [[2]]
#> 
#> Call:
#> lm(formula = mpg ~ disp, data = .)
#> 
#> Coefficients:
#> (Intercept)         disp  
#>   19.081987     0.003605  
#> 
#> 
#> [[3]]
#> 
#> Call:
#> lm(formula = mpg ~ disp, data = .)
#> 
#> Coefficients:
#> (Intercept)         disp  
#>    22.03280     -0.01963
```

For convenience, dplyr also now has a `split()` method for grouped tibbles. 


```r
iris %>% 
  filter(Species == "setosa") %>% 
  group_by(Species) %>% 
  split()
#> [[1]]
#> # A tibble: 50 x 5
#>   Sepal.Length Sepal.Width Petal.Length Petal.Width Species
#>          <dbl>       <dbl>        <dbl>       <dbl> <fct>  
#> 1          5.1         3.5          1.4         0.2 setosa 
#> 2          4.9         3            1.4         0.2 setosa 
#> 3          4.7         3.2          1.3         0.2 setosa 
#> 4          4.6         3.1          1.5         0.2 setosa 
#> # … with 46 more rows
#> 
#> [[2]]
#> # A tibble: 0 x 5
#> # … with 5 variables: Sepal.Length <dbl>, Sepal.Width <dbl>,
#> #   Petal.Length <dbl>, Petal.Width <dbl>, Species <fct>
#> 
#> [[3]]
#> # A tibble: 0 x 5
#> # … with 5 variables: Sepal.Length <dbl>, Sepal.Width <dbl>,
#> #   Petal.Length <dbl>, Petal.Width <dbl>, Species <fct>
```

# Scoped variants

The scoped (or colwise) verbs are the set of verbs with `_at`, `_if` and `_all` suffixes. 
These verbs apply a certain behaviour (for instance, a mutating or summarising operation) to a given 
selection of columns. This release of dplyr improves the consistency of the syntax and the behaviour with grouped tibbles.


## A purrr-like syntax for passing functions

In dplyr 0.7.0, we have implemented support for functions and purrr-style lambda functions:


```r
iris <- as_tibble(iris) # For concise print method

mutate_if(iris, is.numeric, ~ . - mean(.))
#> # A tibble: 150 x 5
#>   Sepal.Length Sepal.Width Petal.Length Petal.Width Species
#>          <dbl>       <dbl>        <dbl>       <dbl> <fct>  
#> 1       -0.743      0.443         -2.36      -0.999 setosa 
#> 2       -0.943     -0.0573        -2.36      -0.999 setosa 
#> 3       -1.14       0.143         -2.46      -0.999 setosa 
#> 4       -1.24       0.0427        -2.26      -0.999 setosa 
#> # … with 146 more rows
```

And lists of functions and purrr-style lambda functions:


```r
fns <- list(
  centered = mean,                # Function object
  scaled = ~ . - mean(.) / sd(.)  # Purrr-style lambda
)
mutate_if(iris, is.numeric, fns)
#> # A tibble: 150 x 13
#>   Sepal.Length Sepal.Width Petal.Length Petal.Width Species
#>          <dbl>       <dbl>        <dbl>       <dbl> <fct>  
#> 1          5.1         3.5          1.4         0.2 setosa 
#> 2          4.9         3            1.4         0.2 setosa 
#> 3          4.7         3.2          1.3         0.2 setosa 
#> 4          4.6         3.1          1.5         0.2 setosa 
#> # … with 146 more rows, and 8 more variables: Sepal.Length_centered <dbl>,
#> #   Sepal.Width_centered <dbl>, Petal.Length_centered <dbl>,
#> #   Petal.Width_centered <dbl>, Sepal.Length_scaled <dbl>,
#> #   Sepal.Width_scaled <dbl>, Petal.Length_scaled <dbl>,
#> #   Petal.Width_scaled <dbl>
```

This is now the preferred syntax for passing functions to the scoped verbs because it is simpler and consistent with purrr. 
Counting from dplyr 0.8.0, the hybrid evaluator recognises and inlines these lambdas, so that native implementation of 
common algorithms will kick in just as it did with expressions passed with `funs()`. 
Consequently, we are soft-deprecating `funs()`. They will continue to work without any warnings for now, but will eventually start issuing warnings.


## Behaviour with grouped tibbles

We have reviewed the documentation of all scoped variants to make clear how the scoped operations 
are applied to grouped tibbles. For most of the scoped verbs, the operation also apply on 
the grouping variables when they are part of the selection. This includes:

* [arrange_all()], [arrange_at()], and [arrange_if()]
* [distinct_all()], [distinct_at()], and [distinct_if()]
* [filter_all()], [filter_at()], and [filter_if()]
* [group_by_all()], [group_by_at()], and [group_by_if()]
* [select_all()], [select_at()], and [select_if()]

This is not the case for summarising and mutating variants where operations are *not* applied on grouping variables. 
The behaviour depends on whether the selection is **implicit** (`all` and `if` selections) or **explicit** (`at` selections). 
Grouping variables covered by explicit selections (with [summarise_at()], [mutate_at()], and [transmute_at()]) are always an error.
For implicit selections, the grouping variables are always ignored. In this case, the level of verbosity depends on the kind of operation:

* Summarising operations ([summarise_all()] and [summarise_if()])
  ignore grouping variables silently because it is obvious that
  operations are not applied on grouping variables.

* On the other hand it isn't as obvious in the case of mutating operations ([mutate_all()], [mutate_if()], [transmute_all()], and [transmute_if()]). 
 For this reason, they issue a message indicating which grouping variables are ignored.

In order to make it easier to explicitly remove the grouping columns from an `_at` selection, we have introduced a 
new selection helper `group_cols()`. Just like `last_col()` matches the last column of a tibble, `group_cols()` matches all grouping columns:


```r
mtcars %>%
  group_by(cyl) %>%
  select(group_cols())
#> # A tibble: 32 x 1
#> # Groups:   cyl [3]
#>     cyl
#> * <dbl>
#> 1     6
#> 2     6
#> 3     4
#> 4     6
#> # … with 28 more rows
```

This new helper is mostly intended for selection in scoped variants:


```r
mtcars %>%
  group_by(cyl) %>%
  mutate_at(
    vars(starts_with("c")),
    ~ . - mean(.)
  )
#> Error: Column `cyl` can't be modified because it's a grouping variable
```

It makes it easy to remove explicitly the grouping variables:


```r
mtcars %>%
  group_by(cyl) %>%
  mutate_at(
    vars(starts_with("c"), -group_cols()),
    ~ . - mean(.)
  )
#> # A tibble: 32 x 11
#> # Groups:   cyl [3]
#>     mpg   cyl  disp    hp  drat    wt  qsec    vs    am  gear   carb
#>   <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>  <dbl>
#> 1  21       6   160   110  3.9   2.62  16.5     0     1     4  0.571
#> 2  21       6   160   110  3.9   2.88  17.0     0     1     4  0.571
#> 3  22.8     4   108    93  3.85  2.32  18.6     1     1     4 -0.545
#> 4  21.4     6   258   110  3.08  3.22  19.4     1     0     3 -2.43 
#> # … with 28 more rows
```


# Tidy grouping structure

Previous versions of `dplyr` used a messy set of attributes in grouped
tibbles to keep track of the groups and their indices. This has been 
re-organized into a tibble that can be accessed with the new 
`group_data()` function. 


```r
iris %>% 
  group_by(Species) %>% 
  group_data()
#> # A tibble: 3 x 2
#>   Species    .rows     
#>   <fct>      <list>    
#> 1 setosa     <int [50]>
#> 2 versicolor <int [50]>
#> 3 virginica  <int [50]>
```

The first columns of that tibble describe the groups in terms of the 
grouping variables, and the last column (always called `.rows`)
is a list of integer vectors identifying the (one-based) indices of 
each group. 

The related function `group_rows()` gives just that last column. 


```r
iris %>% 
  group_by(Species) %>% 
  group_rows()
#> [[1]]
#>  [1]  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19 20 21 22 23
#> [24] 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46
#> [47] 47 48 49 50
#> 
#> [[2]]
#>  [1]  51  52  53  54  55  56  57  58  59  60  61  62  63  64  65  66  67
#> [18]  68  69  70  71  72  73  74  75  76  77  78  79  80  81  82  83  84
#> [35]  85  86  87  88  89  90  91  92  93  94  95  96  97  98  99 100
#> 
#> [[3]]
#>  [1] 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117
#> [18] 118 119 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134
#> [35] 135 136 137 138 139 140 141 142 143 144 145 146 147 148 149 150
```
