---
title: "scales 1.0.0"
author: Dana Seidel
date: '2018-08-09'
slug: scales-1-0-0
description: >
  scales 1.0.0 is now on CRAN.
categories:
  - package
photo:
  url: https://unsplash.com/photos/3kzlCL3rj8A
  author: Ricardo Gomez Angel
tags:
  - scales
  - r-lib
---



We're delighted to announce the release of [scales](https://scales.r-lib.org/) 1.0.0.
The scales packages provides the internal scaling infrastructure to ggplot2 and its functions allow users to customize the transformations, breaks, guides and palettes used in visualizations in ggplot2 and beyond.

This is a major release with significant changes to the popular formatter
functions, and added transformations. Below we demonstrate some of the biggest 
changes in this release including:

- updated formatter functions
- new transformations
- improved breaks on log-transformed scales

See the [News](https://scales.r-lib.org/news/index.html) for a detailed list of changes
and visit [the new website](https://scales.r-lib.org/) for complete documentation and 
additional usage examples.

Install the latest version with:

```r
install.packages("scales")
```

## Formatter changes

Thanks to the help of [@larmarange](https://github.com/larmarange), scales has 
now added a generic formatter function, `number_format()`, that powers the majority
of the formatters in the package. 

This change altered the arguments of most of the formatters: 
`comma_format()`, `percent_format()`, `unit_format()`, `dollar_format()`,
`ordinal_format()`, and `scientific_format()`. All gained new arguments `accuracy`, 
`scale`, `prefix`, and `suffix`, allowing users to specify rounding accuracy, 
a scaling value, a prefix, and a suffix to 
customize output. Furthermore, all of these functions now allow user 
specification of the thousands separator, `big.mark`, and the decimal separator,
`decimal.mark`. Users of these formatters will notice that the default thousands
separator is now a space. This default was chosen as a useful compromise for
an international audience (a space for thousands separator and a dot for decimal 
separator) and is officially endorsed by SI/ISO 31-0 standard, as well as by the 
International Bureau of Weights and Measures and the International Union of 
Pure and Applied Chemistry (IUPAC), the American Medical Association's widely 
followed AMA Manual of Style, and the Metrication Board, among others 
([read more here](https://www.wikiwand.com/en/Decimal_separator#/Digit_grouping)).
Those interested in number formatting with no separator can simply define 
`big.mark = ""` to revert to the previous behaviour. 


```r
library(scales)

number(c(12.3, 4, 12345.789, 0.0002))
#> [1] "12"     "4"      "12 346" "0"

# these functions round by default, but you can set the accuracy
number(c(12.3, 4, 12345.789, 0.0002), big.mark = "", accuracy = .01)
#> [1] "12.30"    "4.00"     "12345.79" "0.00"

# percent() function takes a numeric and does your division and labelling for you
percent(c(0.1, 1 / 3, 0.56))
#> [1] "10.0%" "33.3%" "56.0%"

# comma() adds commas into large numbers for easier readability
comma(10e6)
#> [1] "10,000,000"

# dollar() adds currency symbols speficifed by `prefix` or `suffix`
dollar(c(100, 125, 3000))
#> [1] "$100"   "$125"   "$3,000"
dollar(c(100, 125, 3000), suffix = "€", prefix = "")
#> [1] "100€"   "125€"   "3,000€"

# unit_format() adds unique units
# the scale argument can do simple conversion on the fly
unit_format(unit = "ha", scale = 1e-4)(c(10e6, 10e4, 8e3))
#> [1] "1 000 ha" "10 ha"    "1 ha"
```

Three additional formatters have been added: `pvalue_format()` formats p-values, `number_bytes_format()` formats numeric vectors into byte measurements, and 
`time_format()` provides support for formatting POSIXt and hms objects. Finally, `ordinal_format()` has gained new rules for French and Spanish formatting. 

## New transformations

Two new transformations were added to the package for this release: `psuedo_log_trans()`, 
and `modulus_trans()`. `pseudo_log_trans()` transforms data on a signed 
logarithmic scale with a smooth transition to a linear scale around 0. The 
`modulus_trans()` was added along with a refactored `boxcox_trans()` to 
provide a better option for negative numbers. Both `modulus_trans()` and 
`boxcox_trans()` gained an argument `offset` which now allows users to fit both
type-1 and type-2 Box-Cox transformations. 

## Better breaks

In a long awaited fix, `log_breaks()` now returns integer multiples of 
integer powers of base when finer breaks are needed on the log scale.
This will change all ggplot graphics with log-transformed axes. 


```r
library(ggplot2)
library(dplyr)
set.seed(5678)

dsamp <- sample_n(1000, tbl = diamonds)
ggplot(dsamp, aes(y = price, x = carat)) + 
  geom_point() + scale_x_log10() + scale_y_log10()
```

<img src="/articles/2018-08-scales-1-0-0_files/figure-html/logbreaks-1.png" width="700px" style="display: block; margin: auto;" />

## Acknowledgements
We’re grateful to the 24 people who contributed issues, code and comments:
[@alexandreliborio](https://github.com/alexandreliborio), [@AndreaCirilloAC](https://github.com/AndreaCirilloAC), [@batpigandme](https://github.com/batpigandme), [@BenOnEarth](https://github.com/BenOnEarth), [@billdenney](https://github.com/billdenney), [@Bisaloo](https://github.com/Bisaloo), [@CesarSancho](https://github.com/CesarSancho), [@christianhomberg](https://github.com/christianhomberg), [@clauswilke](https://github.com/clauswilke), [@cwickham](https://github.com/cwickham), 
[@dpseidel](https://github.com/dpseidel), [@foo-bar-baz-qux](https://github.com/foo-bar-baz-qux), [@graciecorgi](https://github.com/graciecorgi), [@hadley](https://github.com/hadley), [@jimhester](https://github.com/jimhester), [@jnolis](https://github.com/jnolis), [@larmarange](https://github.com/larmarange), [@lepennec](https://github.com/lepennec), [@markvanderloo](https://github.com/markvanderloo), [@ptoche](https://github.com/ptoche), [@RobertMyles](https://github.com/RobertMyles), [@statist7](https://github.com/statist7), [@ThierryO](https://github.com/ThierryO), and [@zeehio](https://github.com/zeehio).
