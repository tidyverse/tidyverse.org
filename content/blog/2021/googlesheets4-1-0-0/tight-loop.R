library(googlesheets4)

gs4_auth("jenny.f.bryan@gmail.com")

gapminder <- gs4_example("gapminder")
sp <- sheet_properties(gapminder)
(n <- sp$grid_rows[sp$name == "Africa"])

# this is BAD IDEA = reading individual cells in a loop
for (i in seq_len(3)) {
  gapminder %>%
    range_read(sheet = "Africa", range = sprintf("C%i", i))
}

# this is a GOOD IDEA = read all cells at once
gapminder %>%
  range_read(sheet = "Africa", range = "C:C") %>%
  head()
