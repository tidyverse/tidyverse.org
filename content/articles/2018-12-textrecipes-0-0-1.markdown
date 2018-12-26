---
title: 'textrecipes 0.0.1'
author: Emil Hvitfeldt
date: '2018-12-26'
slug: textrecipes-0-0-1
description: >
    textrecipes 0.0.1 is now on CRAN!
categories:
  - package
photo:
  url: https://unsplash.com/photos/X1exjxxBho4
  author: Roman Kraft
---



We're delighted to announce the release of [textrecipes 0.0.1](https://github.com/tidymodels/textrecipes) on CRAN. [textrecipes](https://tidymodels.github.io/textrecipes/) implements a collection of new steps for the [recipes](https://github.com/tidymodels/recipes) package to deal with text preprocessing. textrecipes is still in early development so any and all feedback is highly appreciated.

You can install it by running:


```r
install.packages("textrecipes")
```

## New steps

The steps introduced here can be split into 3 types, those that:

1. convert from characters to list-columns and vice versa,
1. modify the elements in list-columns, and
1. convert list-columns to numerics.

This allows for greater flexibility in the preprocessing tasks that can be done while staying inside the [recipes](https://github.com/tidymodels/recipes) framework. This also prevents having a single step with many arguments.

## Workflows

First we start by creating a [`recipe`](https://tidymodels.github.io/recipes/reference/recipe.html) object from the original data.


```r
data("okc_text")
rec_obj <- recipe(~ ., okc_text)

rec_obj
#> Data Recipe
#>
#> Inputs:
#>
#>       role #variables
#>  predictor         10
```

The workflow in textrecipes so far starts with [`step_tokenize()`](https://tidymodels.github.io/textrecipes/reference/step_tokenize.html), followed by a combination of type-1 and type-2 steps ending with a type-3 step. [`step_tokenize()`](https://tidymodels.github.io/textrecipes/reference/step_tokenize.html) wraps the [tokenizers](https://github.com/ropensci/tokenizers) package for tokenization, but other tokenization functions can be utilized using the `custom_token` argument. More information concerning arguments can be found in the documentation. The shortest possible recipes are `step_tokenize()` directly followed by a type-3 step.


```r
### Feature hashing done on word tokens
rec_obj %>%
  step_tokenize(essay0) %>% # token argument defaults to "words"
  step_texthash(essay0)
#> Data Recipe
#>
#> Inputs:
#>
#>       role #variables
#>  predictor         10
#>
#> Operations:
#>
#> Tokenization for essay0
#> Feature hashing with essay0

### Counting chacter occurrences
rec_obj %>%
  step_tokenize(essay0, token = "character") %>%
  step_tf(essay0)
#> Data Recipe
#>
#> Inputs:
#>
#>       role #variables
#>  predictor         10
#>
#> Operations:
#>
#> Tokenization for essay0
#> Term frequency with essay0
```

If one wanted to calculate the word count of the top 100 most frequently used words after stemming is performed, type-2 steps are needed. Here we use [`step_stem()`](https://tidymodels.github.io/textrecipes/reference/step_stem.html) to perform stemming using the [SnowballC](https://CRAN.R-project.org/package=SnowballC) package and [`step_tokenfilter()`](https://tidymodels.github.io/textrecipes/reference/step_tokenfilter.html) to keep only the 100 most frequent tokens.


```r
rec_obj %>%
  step_tokenize(essay0) %>%
  step_stem(essay0) %>%
  step_tokenfilter(essay0, max_tokens = 100) %>%
  step_tf(essay0)
#> Data Recipe
#>
#> Inputs:
#>
#>       role #variables
#>  predictor         10
#>
#> Operations:
#>
#> Tokenization for essay0
#> Stemming for essay0
#> Text filtering for essay0
#> Term frequency with essay0
```

For more combinations, please consult the documentation and the [vignette](https://tidymodels.github.io/textrecipes/articles/cookbook---using-more-complex-recipes-involving-text.html), which includes recipe examples.

## Acknowledgements

 A big thank you goes out to the 6 people who contributed to this release:
[&#x0040;ClaytonJY](https://github.com/ClaytonJY), [&#x0040;DavisVaughan](https://github.com/DavisVaughan), [&#x0040;EmilHvitfeldt](https://github.com/EmilHvitfeldt), [&#x0040;jwijffels](https://github.com/jwijffels), [&#x0040;kanishkamisra](https://github.com/kanishkamisra), and [&#x0040;topepo](https://github.com/topepo).
