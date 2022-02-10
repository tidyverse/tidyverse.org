---
output: hugodown::hugo_document

slug: reprex-1-0-0
title: reprex 1.0.0
date: 2021-02-01
author: Jenny Bryan
description: >
    We've never blogged about reprex before, so the release of v1.0.0 seems
    like a good occasion for it.

photo:
  url: https://www.flickr.com/photos/iamagenious/6251271390/sizes/o/
  author: Eric Molina

# one of: "deep-dive", "learn", "package", "programming", or "other"
categories: [package] 
tags: [reprex,tidyverse]
rmd_hash: 622d27ac98e0c916

---

We're exhilarated to announce the release of reprex 1.0.0 ([reprex.tidyverse.org](https://reprex.tidyverse.org)). reprex is a package that helps you prepare **REPR**oducible **EX**amples to share in places where people talk about code, e.g., on GitHub, on Stack Overflow, and in Slack or email messages.

You can install the current version of reprex from CRAN with[^1]:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://rdrr.io/r/utils/install.packages.html'>install.packages</a></span><span class='o'>(</span><span class='s'>"reprex"</span><span class='o'>)</span></code></pre>

</div>

It turns out we've never blogged about reprex here on [tidyverse.org](https://www.tidyverse.org), so we start with a general overview for newcomers, then close with a summary of recent changes of interest to existing users.

You can see a full list of changes in the [release notes](https://reprex.tidyverse.org/news/index.html#reprex-1-0-0-2021-01-27).

## Why reprex exists

reprex is a convenience package that combines the power of R Markdown with conventional wisdom about what makes a good reproducible example. We believe that conversations about code are more productive with:

-   Code that **actually runs**
-   Code that the reader **doesn't necessarily have to run**
-   Code that the reader **can easily run**

Someone new to R might be puzzled by this code and want to discuss it:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>x</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/factor.html'>factor</a></span><span class='o'>(</span><span class='s'>"Hello, "</span><span class='o'>)</span>
<span class='nv'>y</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/factor.html'>factor</a></span><span class='o'>(</span><span class='s'>"world!"</span><span class='o'>)</span>
<span class='nv'>x</span>
<span class='c'>#&gt; [1] Hello, </span>
<span class='c'>#&gt; Levels: Hello,</span>
<span class='nv'>y</span>
<span class='c'>#&gt; [1] world!</span>
<span class='c'>#&gt; Levels: world!</span>
<span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='nv'>x</span>, <span class='nv'>y</span><span class='o'>)</span>
<span class='c'>#&gt; [1] 1 1</span></code></pre>

</div>

You, as a reader, just benefited from a few things:

1.  The code was actually executed by the R interpreter, because this post is generated from an `.Rmd` document. I am probably not misleading you, intentionally or by accident, with fictional or incomplete code.

2.  You got to see the actual result without firing up R yourself and executing this code locally. Many R veterans will instantly recognize what's going on and be able to provide some useful explanation at this point.

3.  If you do want to execute the code yourself, you can easily copy the entire chunk, paste it into R, and press enter[^2]. Compare that with the fussy edits you'd have to make with this copy/paste from the R Console:

    ``` r
    > x <- factor("Hello, ")
    > y <- factor("world!")
    > x
    [1] Hello, 
    Levels: Hello, 
    > y
    [1] world!
    Levels: world!
    > c(x, y)
    [1] 1 1
    ```

    You need to remove the [`>`](https://rdrr.io/r/base/Comparison.html) prompts and delete all output. And don't get me started on the problem of screenshots.

All of this is entirely possible without reprex. People just need to create a suitable `.R` or `.Rmd` file, render it to an appropriate output format, in a fresh R session, with working directory set to session temp directory. And also send me a pony!

For any given code snippet, this feels like way too much work. But if you read, write, and talk about R often, this problem can easily come up multiple times per day. [`reprex::reprex()`](https://reprex.tidyverse.org/reference/reprex.html) aims to make doing the right thing so easy that people stop taking photos of broken code with their cell phone.

## `reprex::reprex()`

[`reprex::reprex()`](https://reprex.tidyverse.org/reference/reprex.html) is the main function in the package. It takes a little bit of R code, probably from the clipboard or current selection, and does all the fiddly things we mentioned:

-   Writes it to a file. By default, to a file below the session temp directory.
-   Sets various R and knitr options that are especially favorable for reprexes, such as the `error = TRUE` chunk option.
-   Renders the code in a fresh R session to ruthlessly expose missing [`library()`](https://rdrr.io/r/base/library.html) calls and the use of objects that haven't been defined.
-   Ensures the output is optimized for the target venue, e.g. GitHub-flavored Markdown vs. commented R code vs. Rich Text Format.

By default, the result is waiting on your clipboard and you'll also see an HTML preview of it.

Here is a 50 second video that shows an entire roundtrip: copying local code, `reprex()`ing, opening a GitHub issue, copying reprex from the issue, and re-executing the code in a local R session:

<iframe width="560" height="315" src="https://www.youtube.com/embed/35suhGR53wQ" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen>
</iframe>

There are many other handy features:

-   Optionally include session info
-   Post a figure to [imgur.com](https://imgur.com) and embed its link in the reprex
-   Handy RStudio addin and gadget for even more convenience
-   More ways to provide input and get output

Head over to [reprex.tidyverse.org](https://reprex.tidyverse.org) to learn more. In addition to the articles there, reprex --- as a lifestyle 🤓 and a package 📦 --- features in my [rstudio::global(2020) keynote about debugging](https://github.com/jennybc/debugging#readme). The reprex section starts around the 14:11 mark in [the video](https://rstudio.com/resources/rstudioconf-2020/object-of-type-closure-is-not-subsettable/).

## What's new in v1.0.0

For those who have been using reprex for a while, here are the most exciting developments in v1.0.0

### Venues

We've added `venue`-specific convenience wrappers. Instead of `reprex(..., venue = "r")`, you can now do `reprex_r(...)`. This makes non-default `venue`s easier to access with IDE autocompletion.

`"slack"` is a new venue that tweaks the default Markdown output for pasting into Slack messages. Slack's markup is a frustrating variant of the Markdown we use elsewhere and it's important to remove the `r` language identifier from the opening code fence. We also simplify image links and, by default, suppress the ad. Note that `venue = "slack"` or `reprex_slack()` work best for people who opt-out of the WYSIWYG message editor[^3]. While working on this, I appreciated for the first time that the default behaviour for figures (uploading to [imgur.com](https://imgur.com) and auto-linking) actually works pretty well for Slack messages. Who knew? 🤷‍♀ This is also a good time to remind everyone that `venue = "r"` or `reprex_r()` are great ways to create larger Slack code snippets. Before you finish by clicking "Create snippet", select `R` from the "Type" dropdown to get nice syntax highlighting.

Stack Overflow now supports fenced code blocks, which means that the `"so"` venue is no longer necessary. You can still request it, but it's just an alias for the default GitHub (`"gh"`) venue and we're going to tell you that every time you do it.

The experimental-but-oh-so-handy `venue = "rtf"` now works about as well on Windows as it does on macOS. It is experimental (and shall remain so) because we still shell out to the [highlight command line tool](http://www.andre-simon.de/doku/highlight/en/highlight.php), the installation of which is left as an exercise for the motivated user. This is a great way to get (un)rendered, syntax-highlighted code snippets into applications like PowerPoint, Keynote, and Word, when you aren't generating the whole document with R Markdown. This special `venue` is documented in [its own article](https://reprex.tidyverse.org/articles/articles/rtf.html).

### Internal changes

This should have no impact on most users, but `reprex()` has been internally refactored to achieve its goals by applying the new `reprex_render()` to an `.Rmd` file that uses the new `reprex_document()` output format. The motivation was mostly to make maintenance easier by using more official mechanisms for extending R Markdown and knitr.

We have eagerly followed knitr's lead and use UTF-8 everywhere internally.

The `tidyverse_quiet` argument and `reprex.tidyverse_quiet` option, which default to `TRUE`, also suppress startup messages from the tidymodels meta-package.

Remember you can see a full list of changes in the [release notes](https://reprex.tidyverse.org/news/index.html#reprex-1-0-0-2021-01-27).

## Acknowledgements

We've never blogged about reprex here, so we'll take this chance to thank all 116 people who have helped get reprex to this point. There have been 47 contributors since the previous release (v0.3.0).

[@1029YanMa](https://github.com/1029YanMa), [@Abhijitsj](https://github.com/Abhijitsj), [@aegerton](https://github.com/aegerton), [@alexpghayes](https://github.com/alexpghayes), [@alistaire47](https://github.com/alistaire47), [@andresrcs](https://github.com/andresrcs), [@assignUser](https://github.com/assignUser), [@atusy](https://github.com/atusy), [@baptiste](https://github.com/baptiste), [@barryrowlingson](https://github.com/barryrowlingson), [@batpigandme](https://github.com/batpigandme), [@billdenney](https://github.com/billdenney), [@blairj09](https://github.com/blairj09), [@brshallo](https://github.com/brshallo), [@brunocarlin](https://github.com/brunocarlin), [@carlmorgenstern](https://github.com/carlmorgenstern), [@cderv](https://github.com/cderv), [@chester-gan](https://github.com/chester-gan), [@chris-prener](https://github.com/chris-prener), [@chsafouane](https://github.com/chsafouane), [@coatless](https://github.com/coatless), [@ColinFay](https://github.com/ColinFay), [@cooknl](https://github.com/cooknl), [@crew102](https://github.com/crew102), [@cstepper](https://github.com/cstepper), [@cwickham](https://github.com/cwickham), [@daattali](https://github.com/daattali), [@david-romano](https://github.com/david-romano), [@davidbody](https://github.com/davidbody), [@DavisVaughan](https://github.com/DavisVaughan), [@dchiu911](https://github.com/dchiu911), [@dgrtwo](https://github.com/dgrtwo), [@dpprdan](https://github.com/dpprdan), [@dskard](https://github.com/dskard), [@ellessenne](https://github.com/ellessenne), [@emiltb](https://github.com/emiltb), [@filipwastberg](https://github.com/filipwastberg), [@franknarf1](https://github.com/franknarf1), [@friendly](https://github.com/friendly), [@gaborcsardi](https://github.com/gaborcsardi), [@GegznaV](https://github.com/GegznaV), [@gergness](https://github.com/gergness), [@gvdr](https://github.com/gvdr), [@hadley](https://github.com/hadley), [@harrismcgehee](https://github.com/harrismcgehee), [@HeidiSeibold](https://github.com/HeidiSeibold), [@helix123](https://github.com/helix123), [@Henrik-P](https://github.com/Henrik-P), [@HughParsonage](https://github.com/HughParsonage), [@IndrajeetPatil](https://github.com/IndrajeetPatil), [@isteves](https://github.com/isteves), [@j450h1](https://github.com/j450h1), [@jasonmtroos](https://github.com/jasonmtroos), [@jayhesselberth](https://github.com/jayhesselberth), [@jemus42](https://github.com/jemus42), [@jennformatics](https://github.com/jennformatics), [@jennybc](https://github.com/jennybc), [@JiaxiangBU](https://github.com/JiaxiangBU), [@jimhester](https://github.com/jimhester), [@joelgombin](https://github.com/joelgombin), [@JohnMount](https://github.com/JohnMount), [@jooyoungseo](https://github.com/jooyoungseo), [@juliasilge](https://github.com/juliasilge), [@jzadra](https://github.com/jzadra), [@karawoo](https://github.com/karawoo), [@kevinushey](https://github.com/kevinushey), [@krlmlr](https://github.com/krlmlr), [@lbusett](https://github.com/lbusett), [@lionel-](https://github.com/lionel-), [@lizhiwei1994](https://github.com/lizhiwei1994), [@llrs](https://github.com/llrs), [@lorenzwalthert](https://github.com/lorenzwalthert), [@maelle](https://github.com/maelle), [@marionlouveaux](https://github.com/marionlouveaux), [@markdly](https://github.com/markdly), [@mattfidler](https://github.com/mattfidler), [@maurolepore](https://github.com/maurolepore), [@mcanouil](https://github.com/mcanouil), [@mdlincoln](https://github.com/mdlincoln), [@mine-cetinkaya-rundel](https://github.com/mine-cetinkaya-rundel), [@missaugustina](https://github.com/missaugustina), [@moodymudskipper](https://github.com/moodymudskipper), [@mrchypark](https://github.com/mrchypark), [@mrdwab](https://github.com/mrdwab), [@njtierney](https://github.com/njtierney), [@no-reply](https://github.com/no-reply), [@noamross](https://github.com/noamross), [@npjc](https://github.com/npjc), [@paleolimbot](https://github.com/paleolimbot), [@pat-s](https://github.com/pat-s), [@paternogbc](https://github.com/paternogbc), [@PeteHaitch](https://github.com/PeteHaitch), [@pgensler](https://github.com/pgensler), [@PiotrKoller](https://github.com/PiotrKoller), [@PMassicotte](https://github.com/PMassicotte), [@prosoitos](https://github.com/prosoitos), [@PublicHealthDataGeek](https://github.com/PublicHealthDataGeek), [@r2evans](https://github.com/r2evans), [@rcorty](https://github.com/rcorty), [@restonslacker](https://github.com/restonslacker), [@RLesur](https://github.com/RLesur), [@robjhyndman](https://github.com/robjhyndman), [@romainfrancois](https://github.com/romainfrancois), [@rpruim](https://github.com/rpruim), [@sckott](https://github.com/sckott), [@scottcame](https://github.com/scottcame), [@sfirke](https://github.com/sfirke), [@sjspielman](https://github.com/sjspielman), [@Tugsdelger](https://github.com/Tugsdelger), [@tungmilan](https://github.com/tungmilan), [@uribo](https://github.com/uribo), [@wlandau](https://github.com/wlandau), [@yonicd](https://github.com/yonicd), [@yutannihilation](https://github.com/yutannihilation), [@zkamvar](https://github.com/zkamvar), and [@zx8754](https://github.com/zx8754).

[^1]: Another way you might get reprex is by installing the tidyverse meta-package. reprex is one of the packages installed by [`install.packages("tidyverse")`](https://rdrr.io/r/utils/install.packages.html), however it is **not** among the core packages attached by [`library(tidyverse)`](http://tidyverse.tidyverse.org).

[^2]: Since the output is commented out, its presence is harmless. But you can even use [`reprex::reprex_clean()`](https://reprex.tidyverse.org/reference/un-reprex.html) and friends to un-reprex code, if you like.

[^3]: You can disable the WYSIWYG Slack message interface in **Preferences \> Advanced**. Select the **Format messages with markup setting**. The [Slack section of The Markdown Guide](https://www.markdownguide.org/tools/slack/) is helpful for figuring out which subsets of Markdown are supported in different parts of Slack.

