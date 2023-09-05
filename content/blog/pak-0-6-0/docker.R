
hook_docker <- function(code, ...) {
  tmp <- tempfile("pak-docker", fileext = ".R")
  on.exit(unlink(tmp), add = TRUE)
  writeLines(code, tmp)
  out <- processx::run(
    "docker",
    c("exec", "-i",
      "-e", "R_CLI_DYNAMIC=true",
      "-e", "R_CLI_NUM_COLORS=256",
      "-e", paste0("GITHUB_PAT=", gitcreds::gitcreds_get()$password),
      "pak-ubuntu",
      "R", "-q", "--no-save", "--no-echo"
    ),
    stdin = tmp,
    stderr = "2>&1",
    error_on_status = knitr::opts_chunk$get("error")
  )

  output <- list(
    structure(list(src = code), class = "source"),
    out$stdout
  )
  output
}
