``` r
library(googlesheets4)

gs4_auth("jenny.f.bryan@gmail.com")

gapminder <- gs4_example("gapminder")
sp <- sheet_properties(gapminder)
(n <- sp$grid_rows[sp$name == "Africa"])
#> [1] 625

# this is BAD IDEA = reading individual cells in a loop
for (i in seq_len(3)) {
  gapminder %>%
    range_read(sheet = "Africa", range = sprintf("C%i", i))
}
#> ✓ Reading from "gapminder".
#> ✓ Range ''Africa'!C1'.
#> ✓ Reading from "gapminder".
#> ✓ Range ''Africa'!C2'.
#> ✓ Reading from "gapminder".
#> ✓ Range ''Africa'!C3'.

# this is a GOOD IDEA = read all cells at once
gapminder %>%
  range_read(sheet = "Africa", range = "C:C") %>%
  head()
#> ✓ Reading from "gapminder".
#> ✓ Range ''Africa'!C:C'.
#> # A tibble: 6 x 1
#>    year
#>   <dbl>
#> 1  1952
#> 2  1957
#> 3  1962
#> 4  1967
#> 5  1972
#> 6  1977
```
