---
output: hugodown::hugo_document

slug: air
title: Air, an extremely fast R formatter
date: 2025-02-12
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
rmd_hash: be95e05694b3d96a

---

We're thrilled to announce [Air](https://posit-dev.github.io/air/), an extremely fast R formatter. I find that it's much easier to show what Air can do rather than tell, so we'll start with a few examples. Let's jump into Positron with some unformatted dplyr code for `case_when()`. Saving the file (yep, that's it!) calls Air, which automatically and instantaneously styles the code.

<video controls autoplay loop muted width="100%" src="video/case-when.mov" style="border: 2px solid #CCC;">
</video>

Next, let's go over to RStudio. Here we've got a pipe chain that could use a little styling. Like in Positron, just save the file:

<video controls autoplay loop muted width="100%" src="video/ggplot.mov" style="border: 2px solid #CCC;">
</video>

Throughout the rest of this post, you'll find details about what a formatter is, why you'd want to use one, and you'll learn about how Air makes decisions on how to format your R code.

Note that Air is still in alpha, so there may be some breaking changes over the next few releases, but we still feel very confident in the current state of Air, and can't wait for you to try it!

## Installing Air

If you already know how formatters work and want to jump straight in, follow one of the guides below:

-   For Positron, Air is [available](https://open-vsx.org/extension/posit/air-vscode) on OpenVSX as an Extension. Install it from the Extensions pane within Positron, then read our [Positron guide](https://posit-dev.github.io/air/editor-vscode.html).

-   For VS Code, Air is [available](https://marketplace.visualstudio.com/items?itemName=Posit.air-vscode) on the VS Code Marketplace as an Extension. Install it from the Extensions pane within VS Code, then read our [VS Code guide](https://posit-dev.github.io/air/editor-vscode.html).

-   For RStudio, Air can be set as an external formatter, but you'll need to install the command line tool for Air first. Read our [RStudio guide](https://posit-dev.github.io/air/editor-rstudio.html) to get started.

-   For command line users, Air binaries can be installed using our [standalone installer scripts](https://posit-dev.github.io/air/cli.html).

If your preferred editor isn't listed here, but does support the [Language Server Protocol](https://microsoft.github.io/language-server-protocol/), then it is likely that we can add support for Air there as well. Feel free to open an [issue](https://github.com/posit-dev/air/issues)!

## What's a formatter?

A formatter is in charge of the *layout* of your R code. Formatters do not change the meaning of code; instead they ensure that whitespace, newlines, and other punctuation conform to a set of rules and standards, such as:

-   Making sure your code is **indented** with the appropriate amount of leading whitespace depending on the context. By default, Air uses an indentation of 2 spaces. You will see this indentation in pipelines:

    ``` r
    data |>
      ggplot(aes(x, y)) +
      geom_point()
    ```

    As well as *expanded* (i.e. vertically laid out) function calls:

    ``` r
    list(
      foo = 1,
      bar = 2
    )
    ```

-   Preventing your code from overflowing a given **line width**. By default, we use a line width of 80 characters. It does so by splitting lines of code that have become too long over multiple lines. For instance, let's say that we've set the line width to be extremely small and these expressions would overflow:

    ``` r
                      # <- imagine the line width is set to here   
    data |> select(foo)

    foo <- function(bar = 1, baz = 2) {
      list(bar, baz)
    }
    ```

    To respect the very small line width, Air would switch these expressions from a horizontal layout (called "flat") to a vertical one (called "expanded"):

    ``` r
                      # <- imagine the line width is set to here
    data |>
      select(foo)

    foo <- function(
      bar = 1,
      baz = 2
    ) {
      list(
        bar,
        baz
      )
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

In general, a formatter takes over the whitespace in your code and moves elements around to respect style conventions and maximize readability.

## How does a formatter improve your workflow?

By using a formatter it might seem like you're rescinding control over the layout of your code. And indeed you are! However, putting Air in charge of styling your code has substantial advantages.

First, it automatically forces you to write legible code that is neither too wide nor too narrow, with proper breathing room around syntactic elements. Having a formatter as a companion significantly improves the process of writing code as you no longer have to think about style as much - the formatter does that for you!

Second, it reduces friction when working in a team. By agreeing to use a formatter in a project, collaborators no longer have to discuss styling and layout issues. Code sent to you by a colleague will adhere to the standards that you're used to. Code review no longer has to be about style nitpicks and can focus on the substance of the changes instead.

## How can I use Air?

As we've touched on above, Air can be integrated into your IDE to format code on every save. We expect that this will be the most common way to invoke Air, but there are a few other ways to use Air that we think are pretty cool:

-   In IDEs:

    -   Format on save

    -   Format selection

-   At the command line:

    -   Format entire projects with `air format`

    -   Set up a git precommit hook to invoke Air before committing

-   In CI:

    -   Check that each PR conforms to formatting standards with `air format --check`[^1]

    -   Automatically format each PR by pushing the results of `air format` as a commit

## How does Air decide how to format your code?

Air tries to strike a balance between enforcing rigid rules and allowing authors some control over the layout. Our main source of styling rules is the [Tidyverse style guide](https://style.tidyverse.org), but we occasionally deviate from these.

There is a trend among modern formatters of being *opinionated*. Air certainly fits this trend and provides very few [configuration options](https://posit-dev.github.io/air/configuration.html), mostly the indent style (spaces versus tabs), the indent width, and the line width. However, Air also puts code authors in charge of certain aspects of the layout through the notion of **persistent line breaks**.

In general, Air is in control of deciding where to put vertical space (line breaks) in your code. For instance if you write:

``` r
list(foo,
bar)
```

Air will figure out that this expression fits on a single line without exceeding the line width. It will discard the line break and reformat to:

``` r
list(foo, bar)
```

However there are very specific places at which you can enforce a line break, i.e. make it persistent.

-   Before the very first argument in a function call. This:

    ``` r
    list(
    foo, bar)
    ```

    gets formatted as:

    ``` r
    list(
      foo,
      bar
    )
    ```

-   Before the very first right-hand side expression in a pipeline. This:

    ``` r
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
list(foo,
  bar
)

data |> select(foo) |>
  filter(!bar)
```

Air will recognize that you've removed the persistent line break, and reformat as:

``` r
list(foo, bar)

data |> select(foo) |> filter(!bar)
```

The goal of this feature is to strike a balance between being opinionated and recognizing that users often know when taking up more vertical space results in more readable output.

## How is this different from styler?

Air would not exist without the preexisting work and dedication poured into [styler](https://github.com/r-lib/styler). Created by [Lorenz Walthert](https://github.com/lorenzwalthert) and [Kirill Müller](https://github.com/krlmlr), styler proved that the R community does care about how their code is formatted, and had been the primary implementation of the [tidyverse style guide](https://style.tidyverse.org/) for many years. We've spoken to Lorenz about Air, and we are all very excited about what Air can do for the future of formatting in R.

Air is different from styler in a few key ways:

-   Air is much faster. So much so that it enables new ways of using a formatter that were somewhat painful before, like formatting on every save, or formatting entire projects on every pull request.

-   Air is less configurable. As mentioned above, Air provides very few [configuration options](https://posit-dev.github.io/air/configuration.html).

-   Air respects a line width, with a default of 80 characters.

-   Air does not require R to run. Unlike styler, which is an R package, Air is written in Rust and is distributed as a pre-compiled binary for many platforms. This makes Air easily usable across IDEs or on CI with very little setup required.

## How fast is "extremely fast"?

Air is written in Rust using the formatting infrastructure provided by [Biome](https://github.com/biomejs/biome)[^2]. This is also the same infrastructure that [Ruff](https://github.com/astral-sh/ruff), the fast Python formatter, originally forked from. Both of those projects are admired for their performance, and Air is no exception.

One big goal for Air is for the "format on save" gesture to be imperceptibly fast, encouraging you to keep it on at all times. Benchmarking formatters is a bit hand wavy due to some having built in caching, so bear with me, but one way to proxy this performance is by formatting a large single file, for example the 800+ line [join.R](https://github.com/tidyverse/dplyr/blob/main/R/join.R) in dplyr. Formatting this takes[^3]:

-   0.01 seconds with Air

-   1 second with styler (no cache)

So, ~100x faster for Air. If you make a few changes in the file after the first round of formatting and run the formatter again, then you get something like:

-   0.01 seconds with Air

-   0.5 seconds with styler (with cache)

Half a second for styler might not sound that bad (and indeed, for a formatter written in R it's pretty good), but it's slow enough that you'll "feel" it if you try and invoke styler on every save.

The differences get even more drastic if you format entire projects. Formatting the ~150 R files in dplyr takes[^4]:

-   0.3 seconds with Air

-   100 seconds with styler

Over 300x faster!

Out of curiosity, we ran Air over all ~900 R files in base R and it finished in under 2 seconds. We didn't try this with styler :)

[^1]: The Shiny team already has a [GitHub Action](https://github.com/rstudio/shiny-workflows/tree/main/format-r-code) to help with this. We will likely work on refining this and incorporating it more officially into an Air or r-lib repository.

[^2]: Biome is an open source project maintained by community members, please consider [sponsoring them](https://github.com/sponsors/biomejs#sponsors)!

[^3]: These benchmarks were run with `air format R/join.R` and `styler::style_file("R/join.R")`.

[^4]: With `air format .` and [`styler::style_pkg()`](https://styler.r-lib.org/reference/style_pkg.html)

