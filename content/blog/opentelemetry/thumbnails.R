# Generate blog post thumbnails from the Unsplash photo in the YAML front matter.
#
# Usage:
#   Rscript thumbnails.R
#
# Requires: magick, yaml
# Produces: thumbnail-sq.jpg (300x300) and thumbnail-wd.jpg (width >5x height, 200px tall)

library(magick)

# --- Content-aware cropping helpers ---

# Extract a numeric (width x height) matrix from a single-channel magick image.
img_to_matrix <- function(img, channel = "gray") {
  d <- image_data(img, channel)
  matrix(as.numeric(d[1, , ]), nrow = dim(d)[2], ncol = dim(d)[3])
}

# Build a saliency map combining edge density, color saturation, and local
# contrast. Returns a width x height matrix with higher values indicating
# more visually interesting regions.
build_saliency_map <- function(img) {
  small <- image_scale(img, "200x")
  gray <- image_convert(small, colorspace = "gray")

  normalize <- function(m) {
    rng <- range(m)
    if (rng[2] == rng[1]) return(m * 0)
    (m - rng[1]) / (rng[2] - rng[1])
  }

  # Edge density: structural boundaries and detail
  edge_mat <- gray |>
    image_blur(radius = 0, sigma = 0.5) |>
    image_edge(radius = 1) |>
    img_to_matrix()

  # Saturation: colorful regions attract visual attention (HSV formula)
  rgb_raw <- image_data(small, "rgb")
  rgb_int <- array(as.integer(rgb_raw), dim = dim(rgb_raw))
  mx <- pmax(rgb_int[1, , ], rgb_int[2, , ], rgb_int[3, , ])
  mn <- pmin(rgb_int[1, , ], rgb_int[2, , ], rgb_int[3, , ])
  sat_mat <- (mx - mn) / pmax(mx, 1L)

  # Local contrast: absolute difference from a blurred version
  contrast_mat <- image_composite(gray, image_blur(gray, 0, 8), "difference") |>
    img_to_matrix()

  # Weighted combination of normalized signals
  0.5 * normalize(edge_mat) +
    0.3 * normalize(sat_mat) +
    0.2 * normalize(contrast_mat)
}

# Find the crop offset that maximizes total saliency within the crop window,
# using an integral image for efficient region-sum computation.
# Returns pixel offsets (x, y) in original image coordinates.
find_best_crop <- function(saliency, crop_w, crop_h, img_w, img_h) {
  sal_w <- nrow(saliency)
  sal_h <- ncol(saliency)

  # Fall back to center crop for completely uniform images
  if (max(saliency) == 0) {
    return(list(
      x = as.integer((img_w - crop_w) / 2),
      y = as.integer((img_h - crop_h) / 2)
    ))
  }

  # Scale crop dimensions to saliency map coordinates
  sc_w <- min(sal_w, max(1L, as.integer(round(crop_w / img_w * sal_w))))
  sc_h <- min(sal_h, max(1L, as.integer(round(crop_h / img_h * sal_h))))

  # Integral image with a leading row and column of zeros
  int_img <- matrix(0, sal_w + 1L, sal_h + 1L)
  int_img[-1, -1] <- saliency
  for (i in seq.int(2L, sal_w + 1L)) int_img[i, ] <- int_img[i, ] + int_img[i - 1L, ]
  for (j in seq.int(2L, sal_h + 1L)) int_img[, j] <- int_img[, j] + int_img[, j - 1L]

  # Vectorized score computation for all valid crop positions
  x_range <- seq_len(max(1L, sal_w - sc_w + 1L))
  y_range <- seq_len(max(1L, sal_h - sc_h + 1L))
  scores <- int_img[x_range + sc_w, y_range + sc_h, drop = FALSE] -
    int_img[x_range,        y_range + sc_h, drop = FALSE] -
    int_img[x_range + sc_w, y_range,        drop = FALSE] +
    int_img[x_range,        y_range,        drop = FALSE]

  best <- arrayInd(which.max(scores), dim(scores))

  list(
    x = as.integer((best[1] - 1) / sal_w * img_w),
    y = as.integer((best[2] - 1) / sal_h * img_h)
  )
}

# --- Read the photo URL from the post's YAML front matter ---
rmd <- list.files(".", pattern = "\\.Rmd$", full.names = TRUE)[1]
lines <- readLines(rmd, warn = FALSE)
delims <- which(lines == "---")
front_matter <- yaml::yaml.load(
  paste(lines[(delims[1] + 1):(delims[2] - 1)], collapse = "\n")
)
photo_url <- front_matter$photo$url

# Fetch the Unsplash page and extract the direct image URL from og:image.
# This handles both old-style (/photos/ID) and new-style (/photos/slug-ID) URLs.
page_text <- paste(readLines(photo_url, warn = FALSE), collapse = "")
m <- regexec(
  'og:image"\\s+content="(https://images\\.unsplash\\.com/photo-[^?&"]+)',
  page_text
)
img_base <- regmatches(page_text, m)[[1]][2]
download_url <- paste0(img_base, "?w=2400")

cat("Downloading:", download_url, "\n")
img <- image_read(download_url)

info <- image_info(img)
w <- info$width
h <- info$height
cat(sprintf("Image dimensions: %d x %d\n", w, h))

# Build saliency map once, reuse for both crop decisions
saliency <- build_saliency_map(img)

# --- Square thumbnail (300 x 300) ---
# Crop the largest square at the position maximizing visual interest.
side <- min(w, h)
sq_off <- find_best_crop(saliency, side, side, w, h)
cat(sprintf("Square crop offset: (%d, %d)\n", sq_off$x, sq_off$y))
image_crop(img, geometry_area(side, side, sq_off$x, sq_off$y)) |>
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
# Find the position that captures the most visual interest in the strip
wd_off <- find_best_crop(saliency, crop_w, crop_h, w, h)
cat(sprintf("Wide crop offset: (%d, %d)\n", wd_off$x, wd_off$y))
wd_thumb <- image_crop(img, geometry_area(crop_w, crop_h, wd_off$x, wd_off$y)) |>
  image_scale(paste0("x", 200))
image_write(wd_thumb, "thumbnail-wd.jpg", quality = 90)

wd_info <- image_info(wd_thumb)
cat(sprintf(
  "Created thumbnail-wd.jpg (%d x %d, ratio %.1f:1)\n",
  wd_info$width,
  wd_info$height,
  wd_info$width / wd_info$height
))
