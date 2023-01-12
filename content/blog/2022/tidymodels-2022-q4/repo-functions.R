suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(clipr))
library(lubridate)
library(glue)
library(usethis)

# ------------------------------------------------------------------------------

tm_pkgs <-
  c("agua", "applicable", "baguette", "bonsai", "broom", "brulee",
    "butcher", "censored", "corrr", "dials", "discrim", "embed",
    "finetune", "hardhat", "modeldata", "modeldb", "multilevelmod",
    "parsnip", "plsmod", "poissonreg", "probably", "recipes", "rsample",
    "rules", "shinymodels", "spatialsample", "stacks", "textrecipes",
    "themis", "tidymodels", "tidyposterior", "tidypredict", "tune",
    "usemodels", "workflows", "workflowsets", "yardstick")

# ------------------------------------------------------------------------------

# Quiet version of `use_tidy_thanks()` that returns the results
return_tidy_thanks <- function(repo_spec = NULL,
                               from = NULL,
                               to = NULL) {
  library(rlang)
  repo_spec <- repo_spec %||% usethis:::target_repo_spec()
  parsed_repo_spec <- usethis:::parse_repo_url(repo_spec)
  repo_spec <- parsed_repo_spec$repo_spec
  # this is the most practical way to propagate `host` to downstream helpers
  if (!is.null(parsed_repo_spec$host)) {
    withr::local_envvar(c(GITHUB_API_URL = parsed_repo_spec$host))
  }

  if (is.null(to)) {
    from <- from %||% usethis:::releases(repo_spec)[[1]]
  }

  # less verbose than usethis:::as_timestamp
  quiet_timestamp <- function(repo_spec, x = NULL) {
    if (is.null(x)) {
      return(NULL)
    }
    as_POSIXct <- try(as.POSIXct(x), silent = TRUE)
    if (inherits(as_POSIXct, "POSIXct")) {
      return(x)
    }
    usethis:::ref_df(repo_spec, refs = x)$timestamp
  }

  from_timestamp <- quiet_timestamp(repo_spec, x = from) %||% "2008-01-01"
  to_timestamp <- quiet_timestamp(repo_spec, x = to)

  res <- gh::gh(
    "/repos/{owner}/{repo}/issues",
    owner = usethis:::spec_owner(repo_spec), repo = usethis:::spec_repo(repo_spec),
    since = from_timestamp,
    state = "all",
    filter = "all",
    .limit = Inf
  )
  if (length(res) < 1) {
    return("No new contributors")
  }

  creation_time <- function(x) {
    as.POSIXct(purrr::map_chr(x, "created_at"))
  }

  res <- res[creation_time(res) >= as.POSIXct(from_timestamp)]

  if (!is.null(to_timestamp)) {
    res <- res[creation_time(res) <= as.POSIXct(to_timestamp)]
  }
  if (length(res) == 0) {
    return("No new contributors")
  }

  contributors <- sort(unique(purrr::map_chr(res, c("user", "login"))))
  contrib_link <- glue::glue("[&#x0040;{contributors}](https://github.com/{contributors})")

  res <- glue:::glue_collapse(contrib_link, sep = ", ", last = ", and ") + glue::glue(".")

  res
}

# ------------------------------------------------------------------------------

get_current_release <- function(pkg) {
  descr_url <- glue::glue(
    "https://cran.r-project.org/web/packages/{pkg}/DESCRIPTION"
  )
  descr_url <- url(descr_url)
  on.exit(close(descr_url))
  descr_res <-  try(read.dcf(descr_url), silent = TRUE)
  if (!inherits(descr_res, "try-error")) {
    res <-
      tibble(
        package = pkg,
        version = descr_res[,"Version"],
        date = descr_res[,"Date/Publication"]
      )
  } else {
    rlang::abort(glue::glue("Failed for {pkg}"))
  }
  res
}
