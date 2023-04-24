library(magick)
library(hugodown)
img <- image_read("https://unsplash.com/photos/urUdKCxsTUI/download?ixid=MnwxMjA3fDB8MXxzZWFyY2h8NjN8fGNoZXJyeSUyMGJsb3Nzb218ZW58MHx8fHwxNjgyMzcyMTQy&force=true")
h <- image_info(img)$height
w <- image_info(img)$width
image_crop(img, geometry = geometry_area(h, h, x_off = 1800)) |>
  image_write("content/blog/spring-cleaning/thumbnail-sq.jpg")
  # image_resize(geometry = geometry_size_percent(10))

img |>
  image_rotate(8) |>
  image_crop(geometry = geometry_area(w, w / 5, y_off = 1100)) |>
  image_fill("#90bcd8", fuzz = 23) |>
  image_write("content/blog/spring-cleaning/thumbnail-wd.jpg")
  # image_resize(geometry = geometry_size_percent(10))

use_tidy_thumbnails()
