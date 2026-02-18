---
output: hugodown::hugo_document

slug: rapp-0-3-0
title: Rapp 0.3.0
date: 2026-02-18
author: Tomasz Kalinowski
# title: "Rapp 0.3.0: write command line apps as plain R scripts
description: >
  Rapp is an R front-end (like Rscript) that turns simple scripts into polished CLIs,
  with automatic argument parsing, generated help, and support for
  commands and installable launchers.

photo:
  url: https://unsplash.com/photos/two-yellow-red-blue-papers-Ay7Nkvc49ag
  author: Carolina Garcia Tavizon


# one of: "deep-dive", "learn", "package", "programming", "roundup", or "other"
categories: [package]
tags: [r-lib, package, programming, yaml]
rmd_hash: a136d69e724b8816

---

<!--
TODO:
* [ ] Look over / edit the post's title in the yaml
* [ ] Edit (or delete) the description; note this appears in the Twitter card
* [ ] Pick category and tags (see existing with [`hugodown::tidy_show_meta()`](https://rdrr.io/pkg/hugodown/man/use_tidy_post.html))
* [ ] Find photo & update yaml metadata
* [ ] Create `thumbnail-sq.jpg`; height and width should be equal
* [ ] Create `thumbnail-wd.jpg`; width should be >5x height
* [ ] [`hugodown::use_tidy_thumbnails()`](https://rdrr.io/pkg/hugodown/man/use_tidy_post.html)
* [ ] Add intro sentence, e.g. the standard tagline for the package
* [ ] [`usethis::use_tidy_thanks()`](https://usethis.r-lib.org/reference/use_tidy_thanks.html)
-->

We're excited to share our first tidyverse blog post for Rapp, alongside the `0.3.0` release. Rapp helps you turn R scripts into polished command-line tools, with argument parsing and help generation built in.

## Why a command-line interface for R?

A command-line interface (CLI) lets you run programs from a terminal by typing commands. (So, no need to open an IDE or any interactive R session.) This is useful when you want to:

- automate tasks via cron jobs, scheduled tasks, or CI/CD pipelines
- chain R scripts together with other tools in data pipelines
- let others run your R code without needing to know R
- package reusable tools that feel native to the terminal

There are several established packages for building CLIs in R, including argparse, optparse, and docopt, where you explicitly parse and handle command-line arguments in code. Rapp takes a different approach: it derives the CLI surface from the structure of your R script and injects values at runtime, so you never need to handle CLI arguments manually.

## How Rapp works

At its core, Rapp is an alternative front-end to R: a drop-in replacement for `Rscript` that automatically turns common R expression patterns into command-line options, switches, positional arguments, and subcommands. You write normal R code and Rapp handles the CLI surface.

Rapp also uses special `#|` comments (this is similar to Quarto's YAML-in-comments syntax) to add metadata like descriptions and short aliases. These comments are ignored by regular R.

## A tiny example

Here's a complete Rapp script (from the package examples), a coin flipper:

``` r
#!/usr/bin/env Rapp
#| name: flip-coin
#| description: |
#|   Flip a coin.

#| description: Number of coin flips
#| short: 'n'
flips <- 1L

sep <- " "
wrap <- TRUE

seed <- NA_integer_
if (!is.na(seed)) {
  set.seed(seed)
}

cat(sample(c("heads", "tails"), flips, TRUE), sep = sep, fill = wrap)
```

Let's break down how Rapp interprets this script:

| R code | generated CLI option | What it does |
|------------------|--------------------------|----------------------------|
| `flips <- 1L` | `--flips` or `-n` | Integer option with default of 1 |
| `sep <- " "` | `--sep` | String option with default of `" "` |
| `wrap <- TRUE` | `--wrap` / `--no-wrap` | Boolean toggle (TRUE/FALSE becomes on/off) |
| `seed <- NA_integer_` | `--seed` | Optional integer (NA means "not set") |

The `#| short: 'n'` comment adds `-n` as a short alias for `--flips`. The `#!/usr/bin/env Rapp` line (called a "shebang") lets you run the script directly on macOS and Linux without typing `Rapp` first.

### Installation and running

First, install Rapp and its command-line launcher:

``` r
install.packages("Rapp")
Rapp::install_pkg_cli_apps("Rapp")
```

Then run your script from the terminal:

``` sh
Rapp flip-coin.R -n 3
#> heads tails heads

Rapp flip-coin.R --seed 42 -n 5
#> tails heads tails tails heads
```

### Auto-generated help

Rapp generates `--help` from your script (and `--help-yaml` if you want a machine-readable spec):

``` sh
Rapp flip-coin.R --help
```

``` text
Usage: flip-coin [OPTIONS]

Flip a coin.

Options:
  -n, --flips <FLIPS>  Number of coin flips [default: 1] [type: integer]
  --sep <SEP>          [default: " "] [type: string]
  --wrap / --no-wrap   [default: true] Disable with `--no-wrap`.
  --seed <SEED>        [default: NA] [type: integer]
```

<div class="callout-warning">

## Breaking change in 0.3.0: positional arguments are now required by default

If you're upgrading from an earlier version of Rapp, note that positional arguments are now **required** unless explicitly marked optional.

``` r
# Before 0.3.0: this positional was optional
name <- NULL

# In 0.3.0+: add this comment to keep it optional
#| required: false
name <- NULL
```

If your scripts use positional arguments with `NULL` defaults that should remain optional, add `#| required: false` above them.

</div>

## Highlights in 0.3.0

Rapp will be new to most readers, so rather than listing every change, here are the main ideas (and what's improved in 0.3.0).

### Options, switches, and repeatable flags from plain R

Rapp recognizes a small set of "declarative" patterns at the top level of your script:

- Scalar literals like `flips <- 1L` become options like `--flips 10`.
- Logical defaults like `wrap <- TRUE` become toggles like `--wrap` / `--no-wrap`.
- `#| short: n` adds a short alias like `-n` (new in 0.3.0).
- [`c()`](https://rdrr.io/r/base/c.html) and [`list()`](https://rdrr.io/r/base/list.html) defaults declare repeatable options (new in 0.3.0): callers can supply the same flag multiple times and values are appended.

### Subcommands with `switch()`

Rapp can now turn a [`switch()`](https://rdrr.io/r/base/switch.html) block into subcommands (and you can nest [`switch()`](https://rdrr.io/r/base/switch.html) blocks for nested commands). Here's a small sketch of a `todo`-style app:

``` r
#!/usr/bin/env Rapp
#| name: todo
#| description: Manage a simple todo list.

#| description: Path to the todo list file.
#| short: s
store <- ".todo.yml"

switch(
  command <- "",

  #| description: Display the todos
  list = {
    limit <- 30L
    # ...
  },

  #| description: Add a new todo
  add = {
    task <- NULL
    # ...
  }
)
```

Help is scoped to the command you're asking about, so `todo --help` lists the commands, and `todo list --help` shows just the options/arguments for `list` (plus any parent/global options).

### Installable launchers for package CLIs

A big part of sharing CLI tools is making them easy to run after installation. In `0.3.0`, `install_pkg_cli_apps()` installs lightweight launchers for scripts in a package's `exec/` directory that use either `#!/usr/bin/env Rapp` or `#!/usr/bin/env Rscript`:

``` r
Rapp::install_pkg_cli_apps("mypackage")
```

(There's also `uninstall_pkg_cli_apps()` to remove a package's launchers.)

## When to use Rapp vs. alternatives

If you've built CLIs in R before, you may have used [argparse](https://cran.r-project.org/web/packages/argparse/index.html), [optparse](https://cran.r-project.org/web/packages/optparse/index.html), or [docopt](https://cran.r-project.org/web/packages/docopt/index.html). These are solid, well-established packages (each with its own style for defining arguments).

Rapp takes a different approach: instead of writing argument definitions, you write plain R code and Rapp infers the CLI from it. This keeps your script readable, easy to test interactively, and quick to iterate on (without having to maintain separate argument definitions).

## Get started

Here's the quickest path to your first Rapp script:

``` r
# 1. Install the package
install.packages("Rapp")
```

``` r
# 2. Install the command-line launcher
Rapp::install_pkg_cli_apps("Rapp")
```

Then create a script (e.g., `hello.R`):

``` r
#!/usr/bin/env Rapp
#| name: hello
#| description: Say hello

name <- "world"
cat("Hello,", name, "\n")
```

And run it:

``` sh
Rapp hello.R --name "R users"
#> Hello, R users
```

### Learn more

To dig deeper into Rapp:

- browse examples in the package: `system.file("examples", package = "Rapp")`
- read the full documentation: <https://github.com/r-lib/Rapp>
- note that Rapp requires R ≥ 4.1.0

If you try Rapp, we'd love feedback! We especially want to hear about your experiences with edge cases in argument parsing, help output, and how commands should feel. Issues and ideas are welcome at <https://github.com/r-lib/Rapp/issues>.

