---
output: hugodown::hugo_document

slug: reprex-2-0-0
title: reprex 2.0.0
date: 2021-04-02
author: Jenny Bryan
description: >
    reprex is now much easier to use on RStudio Server and RStudio Cloud.
photo:
  url: https://unsplash.com/photos/NROHA1B-NYk
  author: Mitchell Luo
categories: [package] 
rmd_hash: 345a8d65731f98a8

---

We're overjoyed to announce the release of [reprex](https://reprex.tidyverse.org) 2.0.0. reprex is a package that helps you prepare **REPR**oducible **EX**amples to share in places where people talk about code, e.g., on GitHub, on Stack Overflow, and in Slack or email messages.

You can install the current version of reprex from CRAN with[^1]:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://rdrr.io/r/utils/install.packages.html'>install.packages</a></span><span class='o'>(</span><span class='s'>"reprex"</span><span class='o'>)</span></code></pre>

</div>

reprex recently had a major release ([version 1.0.0](https://www.tidyverse.org/blog/2021/02/reprex-1-0-0/)), but we've added some big features since then. Specifically, reprex has gotten much, much easier to use on [RStudio Server](https://www.rstudio.com/products/rstudio/download-server/) and [RStudio Cloud](https://rstudio.cloud). It's also easier to specify the working directory, if you must, and reprex plays more nicely with the [renv package](https://rstudio.github.io/renv/).

You can see a full list of changes in the [release notes](https://reprex.tidyverse.org/news/index.html#reprex-2-0-0-2021-04-02).

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://reprex.tidyverse.org'>reprex</a></span><span class='o'>)</span></code></pre>

</div>

## Use in RStudio Server and RStudio Cloud

By default, reprex accepts a code snippet via the clipboard and also puts the rendered result there, ready to paste into GitHub, Stack Overflow, Slack or an email. Removing friction around reprex input/output is one of the main reasons the package exists.

But when working in [RStudio Server](https://www.rstudio.com/products/rstudio/download-server/) or [RStudio Cloud](https://rstudio.cloud), you're running R (and reprex) in a web browser. For very good security reasons, it's essentially impossible to access your system clipboard programmatically from R in this context. Luckily, thanks to the [rstudioapi package](https://rstudio.github.io/rstudio-extensions/rstudioapi.html), we can safely control the RStudio IDE. This means we can create a smooth reprex workflow using the **current selection**, instead of the clipboard.

When [`reprex()`](https://reprex.tidyverse.org/reference/reprex.html) is called without any code input, in RStudio Server or Cloud, the default is now to consult the current selection for reprex source. Previously this was only available via the [`reprex_selection()`](https://reprex.tidyverse.org/reference/reprex_addin.html) addin. [^2] Note that this "current selection" default behaviour propagates to convenience wrappers around [`reprex()`](https://reprex.tidyverse.org/reference/reprex.html), such as [`reprex_r()`](https://reprex.tidyverse.org/reference/reprex_venue.html) and [`reprex_slack()`](https://reprex.tidyverse.org/reference/reprex_venue.html).

Once your reprex has been rendered, you see the normal html preview, the file containing the rendered reprex is opened in RStudio, and its contents are selected, ready for you to copy via Cmd/Ctrl + C.

These changes also make the ["Render reprex" gadget](https://reprex.tidyverse.org/reference/reprex_addin.html) much more usable in RStudio Server or Cloud. reprex has always *technically* worked in the browser, but the user experience was pretty disappointing. Hopefully now it is actually pleasant!

## Working directory

Ideally, a reprex is entirely self-contained and does not read any local files which, presumably, nobody else has. That's why, by default, [`reprex()`](https://reprex.tidyverse.org/reference/reprex.html) works in an ephemeral directory created in the session temp directory. Run [`getwd()`](https://rdrr.io/r/base/getwd.html) inside [`reprex()`](https://reprex.tidyverse.org/reference/reprex.html):

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'>reprex</span><span class='nf'>::</span><span class='nf'><a href='https://reprex.tidyverse.org/reference/reprex.html'>reprex</a></span><span class='o'>(</span>
  <span class='nf'><a href='https://rdrr.io/r/base/getwd.html'>getwd</a></span><span class='o'>(</span><span class='o'>)</span>
<span class='o'>)</span></code></pre>

</div>

and you'll see something like this:

``` r
getwd()
#> [1] "/private/tmp/RtmpXrUKXE/reprex-13063117cb6d8-alive-lark"
```

However, in the real world, sometimes you must read a local data file that you can't share with the world. You can still at least use [`reprex()`](https://reprex.tidyverse.org/reference/reprex.html) to reveal your actual code and results.

This has always been possible, but we've reworked some arguments to make this more natural to express:

-   `wd` is a new argument to set the reprex working directory
-   `outfile` is deprecated, with the existing `input` argument taking over its duties

If we run:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'>reprex</span><span class='nf'>::</span><span class='nf'><a href='https://reprex.tidyverse.org/reference/reprex.html'>reprex</a></span><span class='o'>(</span>
  <span class='nf'><a href='https://rdrr.io/r/base/getwd.html'>getwd</a></span><span class='o'>(</span><span class='o'>)</span>,
  wd <span class='o'>=</span> <span class='s'>"."</span>
<span class='o'>)</span></code></pre>

</div>

we see the working directory is the directory where the source of this blog post lives:

``` r
getwd()
#> [1] "/Users/jenny/rrr/tidyverse.org/content/blog/reprex-2-0-0"
```

The old way to [`reprex()`](https://reprex.tidyverse.org/reference/reprex.html) in current working directory was [`reprex(outfile =  NA)`](https://reprex.tidyverse.org/reference/reprex.html), which was not very intuitive.

Another good reason to reprex in a specific working directory is for package development. Just put [`devtools::load_all(".")`](https://devtools.r-lib.org//reference/load_all.html) at the start of your reprex and then you can easily explore a code snippet in the context of an experimental version of the package. This is a nice way to create small, concrete "before vs. after" demos when developing a feature or fixing a bug.

## Local `.Rprofile` and renv happiness

The reprex working directory has even more significance, when you consider the implications for the callr and renv packages.

[`reprex()`](https://reprex.tidyverse.org/reference/reprex.html) renders the reprex in a separate, fresh R session using [`callr::r()`](https://callr.r-lib.org/reference/r.html). We accept this default behaviour from callr:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'>callr</span><span class='nf'>::</span><span class='nf'><a href='https://callr.r-lib.org/reference/r.html'>r</a></span><span class='o'>(</span><span class='nv'>...</span>, user_profile <span class='o'>=</span> <span class='s'>"project"</span><span class='o'>)</span></code></pre>

</div>

which means that callr executes a `"project"`-level `.Rprofile`, if such a file exists in current working directory.

Most reprexes happen in a temp directory and there will be no such `.Rprofile`. But if the user intentionally reprexes in, say, an existing project that has `.Rprofile`, [`callr::r()`](https://callr.r-lib.org/reference/r.html) and therefore [`reprex()`](https://reprex.tidyverse.org/reference/reprex.html) both honor it. (Remember, this has gotten easier, with [`reprex(wd = ".")`](https://reprex.tidyverse.org/reference/reprex.html).)

This is especially important for users of the [renv package](https://rstudio.github.io/renv/), which uses `.Rprofile` to implement a project-specific package library:

> In an renv project, [`reprex(wd = ".")`](https://reprex.tidyverse.org/reference/reprex.html) renders with respect to the project-specific library.

If you include [`renv::snapshot(reprex = TRUE)`](https://rstudio.github.io/renv//reference/snapshot.html) in your reprex code, the rendered result will even contain the associated renv lockfile, nicely tucked away as collapsible details.

reprex v2.0.0 introduces a few features around project-specific `.Rprofile`:

-   We explicitly make sure that the working directory of the [`callr::r()`](https://callr.r-lib.org/reference/r.html) call is the same as the effective working directory of the reprex.
-   We alert the user that a local `.Rprofile` has been found.
-   We indicate the usage of a local `.Rprofile` in the rendered reprex.

## Adjective-animal

Various changes mean that more users will see reprex filepaths. Therefore, we've revised them to be more self-explanatory and human-friendly. When reprex needs to invent a file name, it is now based on a random "adjective-animal" slug. Bring on the `angry-hamster`! [^3]

You actually saw one of these filepaths already, in the output of [`reprex(getwd())`](https://reprex.tidyverse.org/reference/reprex.html):

``` r
getwd()
#> [1] "/private/tmp/RtmpXrUKXE/reprex-13063117cb6d8-alive-lark"
```

## Acknowledgements

We thank these folks for contributing to this release through their issues, comments, and pull requests:

[@23ava](https://github.com/23ava), [@jennybc](https://github.com/jennybc), [@kiernann](https://github.com/kiernann), [@krlmlr](https://github.com/krlmlr), [@llrs](https://github.com/llrs), [@MatthieuStigler](https://github.com/MatthieuStigler), [@mcanouil](https://github.com/mcanouil), [@MilesMcBain](https://github.com/MilesMcBain), [@oharac](https://github.com/oharac), and [@remlapmot](https://github.com/remlapmot).

[^1]: Another way you might get reprex is by installing the tidyverse meta-package. reprex is one of the packages installed by [`install.packages("tidyverse")`](https://rdrr.io/r/utils/install.packages.html), however it is **not** among the [core packages](https://www.tidyverse.org/packages/#core-tidyverse) attached by [`library(tidyverse)`](http://tidyverse.tidyverse.org).

[^2]: The [`reprex_selection()`](https://reprex.tidyverse.org/reference/reprex_addin.html) addin is alive and well! What's new is that it has become the default behaviour in RStudio Server or Cloud. [`reprex_selection()`](https://reprex.tidyverse.org/reference/reprex_addin.html) is so handy that many reprex users wire it up to a [custom keyboard shortcut](https://support.rstudio.com/hc/en-us/articles/206382178-Customizing-Keyboard-Shortcuts), such as Cmd + Shift + R (macOS) or Ctrl + Shift + R (Windows).

[^3]: [`reprex()`](https://reprex.tidyverse.org/reference/reprex.html) draws randomly from a fixed set of adjective-animal slugs generated with the handy [ids package](https://reside-ic.github.io/ids/).

