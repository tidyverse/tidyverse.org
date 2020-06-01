options(
  blogdown.ext = ".Rmarkdown",
  blogdown.subdir = "blog",
  blogdown.new_bundle = TRUE
)

rprofile <- Sys.getenv("R_PROFILE_USER", "~/.Rprofile")

if (file.exists(rprofile) && !grepl("callr", rprofile)) {
  source(file = rprofile)
}
