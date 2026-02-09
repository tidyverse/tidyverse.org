# Generate blog post thumbnails from the Unsplash photo in the YAML front matter.
#
# Usage:
#   Rscript thumbnails.R
#
# Requires: magick, hugodown, yaml
# Produces: thumbnail-sq.jpg (300x300) and thumbnail-wd.jpg (width >5x height, 200px tall)

library(magick)

# --- Read the photo URL from the post's YAML front matter ---
rmd <- list.files(".", pattern = "\\.Rmd$", full.names = TRUE)[1]
lines <- readLines(rmd, warn = FALSE)
delims <- which(lines == "---")
front_matter <- yaml::yaml.load(
  paste(lines[(delims[1] + 1):(delims[2] - 1)], collapse = "\n")
)
photo_url <- front_matter$photo$url

# Convert Unsplash page URL to a download URL
photo_id <- basename(photo_url)
download_url <- sprintf(
  "https://unsplash.com/photos/%s/download?force=true&w=2400",
  photo_id
)

cat("Downloading:", download_url, "\n")
img <- image_read(download_url)

info <- image_info(img)
w <- info$width
h <- info$height
cat(sprintf("Image dimensions: %d x %d\n", w, h))

# --- Square thumbnail (300 x 300) ---
# Crop the largest centered square, then scale to 300x300.
side <- min(w, h)
x_off <- (w - side) %/% 2
y_off <- (h - side) %/% 2
image_crop(img, geometry_area(side, side, x_off, y_off)) |>
  image_scale("300x300") |>
  image_write("thumbnail-sq.jpg", quality = 90)
cat("Created thumbnail-sq.jpg (300 x 300)\n")

# --- Wide thumbnail (? x 200, ratio >= 5:1) ---
# Target: final height 200px, width >= 1000px (i.e. 5:1 ratio).
# Strategy: crop a horizontal strip at 7:1 ratio from the source, then scale
# to height 200. This guarantees ratio > 5:1 regardless of source dimensions.
# If the source is too narrow for 7:1, fall back to the widest strip possible.
target_ratio <- 7
crop_w <- w
crop_h <- as.integer(w / target_ratio)
if (crop_h > h) {
  # Source is too short for a 7:1 strip -- use full height, full width.
  # The final ratio equals the source aspect ratio; warn if < 5:1.
  crop_h <- h
  if (w / h < 5) {
    warning(
      sprintf(
        "Source aspect ratio (%.1f:1) is less than 5:1. Consider a wider image.",
        w / h
      )
    )
  }
}
y_off_wd <- (h - crop_h) %/% 2
image_crop(img, geometry_area(crop_w, crop_h, 0, y_off_wd)) |>
  image_scale(paste0("x", 200)) |>
  image_write("thumbnail-wd.jpg", quality = 90)

wd_info <- image_info(image_read("thumbnail-wd.jpg"))
cat(sprintf("Created thumbnail-wd.jpg (%d x %d, ratio %.1f:1)\n",
            wd_info$width, wd_info$height, wd_info$width / wd_info$height))
