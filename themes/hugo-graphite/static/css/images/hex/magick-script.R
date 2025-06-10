# resize all hexes

library(magick)
library(fs)
library(purrr)

tidyverse_pngs <- fs::dir_ls("themes/hugo-graphite/static/css/images/hex", 
                       recurse = TRUE, 
                       glob = "*.png")

scale_hex <- function(hex) {
  hex %>%
    image_read() %>% 
    image_scale("240x278") %>% 
    image_write(hex, quality = 90)
}

purrr::map(tidyverse_pngs, scale_hex)
