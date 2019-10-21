There will often be a paragraph of text right here.

## HTML

### Lists

-   This is a bullet list

-   This bullet contains some code

    ```R
    library(tidyverse)
    tibble(x = runif(100))
    ```

You need to perform these actions in order.

1.  Install the tidyverse.

2.  Load the tidyverse: `library(tidyverse)`

3.  Use the tidyverse.

### Blockquote

> All tidy datasets are alike. Every messy dataset is messy in its own
> way. 
>
> — Hadley Tolstoy

## R code

```R
a <- 10
b <- 30

a + b
#> [1] 40

ggplot(starwars, aes(mass, height)) +
  geom_point(na.rm = TRUE)
```

![](../test-ggplot2-1.png)
