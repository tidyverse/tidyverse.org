---
output: hugodown::hugo_document

slug: rapp-0-3-0
title: rapp 0 3 0
date: 2026-01-23
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
tags: []
rmd_hash: 46c19e9a0c1e7318

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

We're excited to share our first tidyverse blog post for {Rapp}, alongside the 0.3.0 release. Rapp helps you turn R scripts into polished command line tools, with argument parsing and help generation built in.

At its core, Rapp is an alternative front-end to R: a drop-in replacement for `Rscript` that automatically turns a handful of common R expression patterns into command-line options, switches, positional arguments, and subcommands. You write normal R code; Rapp handles the CLI surface.

## A tiny example

Here's a complete Rapp (from the package examples), a coin flipper:

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

Once you've installed {Rapp}, you can install the `Rapp` command-line launcher:

``` r
install.packages("Rapp")
Rapp::install_pkg_cli_apps("Rapp")
```

Then you can run your script with `Rapp`:

``` sh
Rapp flip-coin.R -n 3
Rapp flip-coin.R --help
```

Rapp generates `--help` from your script (and `--help-yaml` if you want a machine-readable spec). For `flip-coin.R`, the help output looks like:

``` text
Usage: flip-coin [OPTIONS]

Flip a coin.

Options:
  -n, --flips <FLIPS>  Number of coin flips [default: 1] [type: integer]
  --sep <SEP>          [default: " "] [type: string]
  --wrap / --no-wrap   [default: true] Disable with `--no-wrap`.
  --seed <SEED>        [default: NA] [type: integer]
```

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

A big part of sharing CLI tools is making them easy to run after installation. In 0.3.0, `install_pkg_cli_apps()` installs lightweight launchers for scripts in a package's `exec/` directory that use either `#!/usr/bin/env Rapp` or `#!/usr/bin/env Rscript`:

``` r
Rapp::install_pkg_cli_apps("mypackage")
```

(There's also `uninstall_pkg_cli_apps()` to remove a package's launchers.)

## Breaking change: positional arguments are required by default

In 0.3.0, positional arguments are now required unless you explicitly mark them optional.

If you declare a positional with:

``` r
name <- NULL
```

it's required. To make it optional:

``` r
#| required: false
name <- NULL
```

## Get started

- Install from CRAN: `install.packages("Rapp")`
- Install the `Rapp` launcher (and any package CLI launchers you want): `Rapp::install_pkg_cli_apps("Rapp")`
- Browse examples in the package (`inst/examples`) and the README: <https://github.com/r-lib/Rapp>

If you try Rapp out, we'd love feedback---especially on edge cases in argument parsing, help output, and how commands should feel. Issues and ideas are welcome at <https://github.com/r-lib/Rapp/issues>

