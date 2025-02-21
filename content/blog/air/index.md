---
output: hugodown::hugo_document

slug: air
title: Air, an extremely fast R formatter
date: 2025-02-21
author: Davis Vaughan and Lionel Henry
description: >
    We are thrilled to announce Air, a new R formatter.

photo:
  url: https://unsplash.com/photos/above-cloud-photo-of-blue-skies-yQorCngxzwI
  author: Taylor Van Riper

# one of: "deep-dive", "learn", "package", "programming", "roundup", or "other"
categories: [programming] 
tags: []
editor:
  markdown:
    wrap: sentence
    canonical: true
rmd_hash: 89a3b17dfcbb27e9

---

We're thrilled to announce [Air](https://posit-dev.github.io/air/), an extremely fast R formatter. Formatters are used to automatically style code, but I find that it's much easier to show what Air can do rather than tell, so we'll start with a few examples. In the video below, we're inside [Positron](https://positron.posit.co/) and we're looking at some unformatted code. Saving the file (yep, that's it!) invokes Air, which automatically and instantaneously formats the code.

<video controls autoplay loop muted width="100%" src="video/case-when.mov" style="border: 2px solid #CCC;">
</video>

Next, let's go over to [RStudio](https://posit.co/products/open-source/rstudio/). Here we've got a pipe chain that could use a little formatting. Like in Positron, just save the file:

<video controls autoplay loop muted width="100%" src="video/ggplot.mov" style="border: 2px solid #CCC;">
</video>

Lastly, we'll jump back into Positron. Rather than formatting a single file on save, you might want to instead format an entire project (particularly when first adopting Air). To do so, just run `air format .` in a terminal from the project root, and Air will recursively format any R files it finds along the way (smartly excluding known generated files, like `cpp11.R`). Here we'll run Air on dplyr for the first time ever, analyzing and reformatting over 150 files instantly:

<video controls autoplay loop muted width="100%" src="video/project.mov" style="border: 2px solid #CCC;">
</video>

Within the tidyverse, we're already using Air in some of our largest packages, like [dplyr](https://github.com/tidyverse/dplyr/pull/7662), [tidyr](https://github.com/tidyverse/tidyr/pull/1591), and [recipes](https://github.com/tidymodels/recipes/pull/1425).

Throughout the rest of this post you'll learn what a formatter is, why you'd want to use one, and you'll learn a little about how Air decides to format your R code.

Note that Air is still in alpha, so there may be some breaking changes over the next few releases. We also encourage you to use it in combination with a version control system, like git, so that you can clearly see the changes Air makes. That said, we still feel very confident in the current state of Air, and can't wait for you to try it!

## Installing Air

If you already know how formatters work and want to jump straight in, follow one of the guides below:

-   For Positron, Air is [available](https://open-vsx.org/extension/posit/air-vscode) on OpenVSX as an Extension. Install it from the Extensions pane within Positron, then read our [Positron guide](https://posit-dev.github.io/air/editor-vscode.html).

-   For VS Code, Air is [available](https://marketplace.visualstudio.com/items?itemName=Posit.air-vscode) on the VS Code Marketplace as an Extension. Install it from the Extensions pane within VS Code, then read our [VS Code guide](https://posit-dev.github.io/air/editor-vscode.html).

-   For RStudio, Air can be set as an external formatter, but you'll need to install the command line tool for Air first. Read our [RStudio guide](https://posit-dev.github.io/air/editor-rstudio.html) to get started. Note that this is an experimental feature on the RStudio side, so the exact setup may change a little until it is fully stabilized.

-   For command line users, Air binaries can be installed using our [standalone installer scripts](https://posit-dev.github.io/air/cli.html).

For both Positron and VS Code, the most important thing to enable after installing the extension is format on save for R. You can do that by adding these lines to your `settings.json` file:

``` json
{
    "[r]": {
        "editor.formatOnSave": true
    }
}
```

To open your `settings.json` file, run one of the following from the Command Palette:

-   Run `Preferences: Open User Settings (JSON)` to modify global user settings.

-   Run `Preferences: Open Workspace Settings (JSON)` to modify project specific settings. You may want to use this instead of setting the user level setting if you drop in on multiple projects, but not all of them use Air. If you work on a project with collaborators, we recommend that you check in these project specific settings to your repository to ensure that every collaborator is using the same formatting settings.

If your preferred editor isn't listed here, but does support the [Language Server Protocol](https://microsoft.github.io/language-server-protocol/), then it is likely that we can add support for Air there as well. Feel free to open an [issue](https://github.com/posit-dev/air/issues)!

## What's a formatter?

A formatter is in charge of the *layout* of your R code. Formatters do not change the meaning of code; instead they ensure that whitespace, newlines, and other punctuation conform to a set of rules and standards, such as:

-   Making sure your code is **indented** with the appropriate amount of leading whitespace. By default, Air uses 2 spaces for indentation. You will see this indentation in pipelines:

    ``` r
    data |>
      ggplot(aes(x, y)) +
      geom_point()
    ```

    As well as in function calls:

    ``` r
    list(
      foo = 1,
      bar = 2
    )
    ```

-   Preventing your code from overflowing a given **line width**. By default, Air uses a line width of 80 characters. It enforces this by splitting long lines of code over multiple lines. For instance, notice how long these expressions are, they would "overflow" past 80 characters:

    ``` r
    band_members |> select(name) |> full_join(band_instruments2, by = join_by(name == artist))

    left_join <- function(x, y, by = NULL, copy = FALSE, suffix = c(".x", ".y"), ..., keep = NULL) {
      UseMethod("left_join")
    }
    ```

    Air reformats these expressions by switching them from a horizontal layout (called "flat") to a vertical one (called "expanded"):

    ``` r
    band_members |> 
      select(name) |> 
      full_join(band_instruments2, by = join_by(name == artist))

    left_join <- function(
      x,
      y,
      by = NULL,
      copy = FALSE,
      suffix = c(".x", ".y"),
      ...,
      keep = NULL
    ) {
      UseMethod("left_join")
    }
    ```

-   Standardizing the whitespace around code elements. Have you ever had difficulties deciphering very dense code?

    ``` r
    1+2:3*(4/5)
    ```

    Air reformats this expression to:

    ``` r
    1 + 2:3 * (4 / 5)
    ```

## How does a formatter improve your workflow?

By using a formatter it might seem like you're giving up control over the layout of your code. And indeed you are! However, putting Air in charge of styling your code has substantial advantages.

First, it automatically forces you to write legible code that is neither too wide nor too narrow, with proper breathing room around syntactic elements. Having a formatter as a companion significantly improves the process of writing code as you no longer have to think about style - the formatter does that for you!

Second, it reduces friction when working in a team. By agreeing to use a formatter in a project, collaborators no longer have to discuss styling and layout issues. Code sent to you by a colleague will adhere to the standards that you're used to. Code review no longer has to be about style nitpicks and can focus on the substance of the changes instead.

## How does Air decide how to format your code?

Air tries to strike a balance between enforcing rigid rules and allowing authors some control over the layout. Our main source of styling rules is the [Tidyverse style guide](https://style.tidyverse.org), but we occasionally deviate from these.

There is a trend among modern formatters of being *opinionated*. Air certainly fits this trend and provides very few [configuration options](https://posit-dev.github.io/air/configuration.html), mostly: the indent style (spaces versus tabs), the indent width, and the line width. However, Air also puts code authors in charge of certain aspects of the layout through the notion of **persistent line breaks**.

In general, Air is in control of deciding where to put vertical space (line breaks) in your code. For instance if you write:

``` r
dictionary <- list(bob = "apple",
  jill = "juice")
```

Air will figure out that this expression fits on a single line without exceeding the line width. It will discard the line break and reformat to:

``` r
dictionary <- list(bob = "apple", jill = "juice")
```

However there are very specific places at which you can insert a line break that Air perceives as persistent:

-   Before the very first argument in a function call. This:

    ``` r
    # Persistent line break after `(` and before `bob`
    dictionary <- list(
      bob = "apple", jill = "juice")
    ```

    gets formatted as:

    ``` r
    dictionary <- list(
      bob = "apple", 
      jill = "juice"
    )
    ```

-   Before the very first right-hand side expression in a pipeline. This:

    ``` r
    # Persistent line break after `|>` and before `select`
    data |>
      select(foo) |> filter(!bar)
    ```

    gets formatted as:

    ``` r
    data |>
      select(foo) |>
      filter(!bar)
    ```

A persistent line break will never be removed by Air. But you can remove it manually. Taking the last example, if you join the first lines like this:

``` r
# Removed persistent line break after `(`
dictionary <- list(bob = "apple", 
  jill = "juice"
)

# Removed persistent line break after `|>`
data |> select(foo) |>
  filter(!bar)
```

Air will recognize that you've removed the persistent line break, and reformat as:

``` r
dictionary <- list(bob = "apple", jill = "juice")

data |> select(foo) |> filter(!bar)
```

The goal of this feature is to strike a balance between being opinionated and recognizing that users often know when taking up more vertical space results in more readable output.

## How can I disable formatting?

If you need to disable formatting for a single expression, you can use a `# fmt: skip` comment. This is particularly useful for manual alignment.

``` r
# This skips formatting for `list()` and its arguments, retaining the manual alignment
# fmt: skip
list(
  dollar = "USA",
  yen    = "Japan",
  yuan   = "China"
)

# This skips formatting for `tribble()` and its arguments
# fmt: skip
tribble(
  ~x, ~y,
   1,  2,
)
```

If there is a file that Air should skip altogether, you can use a `# fmt: skip file` comment at the very top of the file.

To learn more about these features, see the [documentation](https://posit-dev.github.io/air/formatter.html#disabling-formatting).

## How can I use Air?

As we've touched on above, Air can be integrated into your IDE to format code on every save. We expect that this will be the most common way to invoke Air, but there are a few other ways to use Air that we think are pretty cool:

-   In IDEs:

    -   Format on save

    -   Format selection

-   At the command line:

    -   Format entire projects with `air format .`

    -   Set up a git precommit hook to invoke Air before committing

-   In CI:

    -   Use a GitHub Action to check that each PR conforms to formatting standards with `air format . --check`[^1]

    -   Use a GitHub Action to automatically format each PR by pushing the results of `air format` as a commit

We don't have guides for all of these use cases yet, but the best place to stay up to date is the [Air website](https://posit-dev.github.io/air/).

## How is this different from styler?

Air would not exist without the preexisting work and dedication poured into [styler](https://github.com/r-lib/styler). Created by [Lorenz Walthert](https://github.com/lorenzwalthert) and [Kirill Müller](https://github.com/krlmlr), styler proved that the R community does care about how their code is formatted, and has been the primary implementation of the [tidyverse style guide](https://style.tidyverse.org/) for many years. We've spoken to Lorenz about Air, and we are all very excited about what Air can do for the future of formatting in R.

Air is different from styler in a few key ways:

-   Air is much faster. So much so that it enables new ways of using a formatter that were somewhat painful before, like formatting on every save, or formatting entire projects on every pull request.

-   Air is less configurable. As mentioned above, Air provides very few [configuration options](https://posit-dev.github.io/air/configuration.html).

-   Air respects a line width, with a default of 80 characters.

-   Air does not require R to run. Unlike styler, which is an R package, Air is written in Rust and is distributed as a pre-compiled binary for many platforms. This makes Air easy to use across IDEs or on CI with very little setup required.

## How fast is "extremely fast"?

Air is written in Rust using the formatting infrastructure provided by [Biome](https://github.com/biomejs/biome)[^2]. This is also the same infrastructure that [Ruff](https://github.com/astral-sh/ruff), the fast Python formatter, originally forked from. Both of those projects are admired for their performance, and Air is no exception.

One goal for Air is for "format on save" to be imperceptibly fast, encouraging you to keep it on at all times. Benchmarking formatters is a bit hand wavy due to some having built in caching, so bear with me, but one way to proxy this performance is by formatting a large single file, for example the 800+ line [join.R](https://github.com/tidyverse/dplyr/blob/main/R/join.R) in dplyr. Formatting this takes[^3]:

-   0.01 seconds with Air

-   1 second with styler (no cache)

So, ~100x faster for Air! If you make a few changes in the file after the first round of formatting and run the formatter again, then you get something like:

-   0.01 seconds with Air

-   0.5 seconds with styler (with cache)

Half a second for styler might not sound that bad (and indeed, for a formatter written in R it's pretty good), but it's slow enough that you'll "feel" it if you try and invoke styler on every save. But 0.01 seconds? You'll never even know its running!

The differences get even more drastic if you format entire projects. Formatting the ~150 R files in dplyr takes[^4]:

-   0.3 seconds with Air

-   100 seconds with styler

Over 300x faster!

Out of curiosity, we also ran Air over all ~900 R files in base R and it finished in under 2 seconds.

## Wrapping up

By contributing this formatter to the R community, our objective is threefold:

-   Vastly improve your enjoyment of writing well-styled R code by removing the chore of editing whitespace.

-   Reduce friction in collaborative projects by establishing a consistent style once and for all.

-   Improve the overall readability of R code for the community.

We hope that Air will prove to be a valuable companion in your daily workflow!

[^1]: The Shiny team already has a [GitHub Action](https://github.com/rstudio/shiny-workflows/tree/main/format-r-code) to help with this. We will likely work on refining this and incorporating it more officially into an Air or r-lib repository.

[^2]: Biome is an open source project maintained by community members, please consider [sponsoring them](https://github.com/sponsors/biomejs#sponsors)!

[^3]: These benchmarks were run with `air format R/join.R` and `styler::style_file("R/join.R")`.

[^4]: With `air format .` and [`styler::style_pkg()`](https://styler.r-lib.org/reference/style_pkg.html)

