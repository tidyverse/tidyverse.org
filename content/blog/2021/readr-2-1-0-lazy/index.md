---
output: hugodown::hugo_document

slug: readr-2-1-0-lazy
title: Eager vs lazy reading in readr 2.1.0
date: 2021-11-11
author: Jim Hester
description: >
    readr 2.1.0 is now on CRAN. This post explains the change for default reading to be eager rather than lazy.

photo:
  url: https://unsplash.com/photos/ilRuQcu9czw
  author: June

# one of: "deep-dive", "learn", "package", "programming", "roundup", or "other"
categories: [package] 
tags: [readr]
rmd_hash: 2b3ff7197f605fac

---

<!--
TODO:
* [x] Look over / edit the post's title in the yaml
* [x] Edit (or delete) the description; note this appears in the Twitter card
* [x] Pick category and tags (see existing with [`hugodown::tidy_show_meta()`](https://rdrr.io/pkg/hugodown/man/use_tidy_post.html))
* [x] Find photo & update yaml metadata
* [x] Create `thumbnail-sq.jpg`; height and width should be equal
* [x] Create `thumbnail-wd.jpg`; width should be >5x height
* [x] [`hugodown::use_tidy_thumbnails()`](https://rdrr.io/pkg/hugodown/man/use_tidy_post.html)
* [x] Add intro sentence, e.g. the standard tagline for the package
* [ ] [`usethis::use_tidy_thanks()`](https://usethis.r-lib.org/reference/use_tidy_thanks.html)
-->

We're pleased to announce the release of [readr](https://readr.tidyverse.org/) 2.1.0. The readr package makes it easy to get rectangular data out of comma separated (csv), tab separated (tsv) or fixed width files (fwf) and into R. It is designed to flexibly parse many types of data found in the wild, while still cleanly failing when data unexpectedly changes.

The easiest way to install the latest version from CRAN is to install the whole tidyverse.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://rdrr.io/r/utils/install.packages.html'>install.packages</a></span><span class='o'>(</span><span class='s'>"tidyverse"</span><span class='o'>)</span></code></pre>

</div>

Alternatively, install just readr from CRAN:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://rdrr.io/r/utils/install.packages.html'>install.packages</a></span><span class='o'>(</span><span class='s'>"readr"</span><span class='o'>)</span></code></pre>

</div>

This blog post will discuss the recent change in readr 2.0 to lazy reading by default, and the recent change back to eager reading in readr 2.1.

You can see a full list of changes in the [readr release notes](https://github.com/tidyverse/readr/releases).

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://readr.tidyverse.org'>readr</a></span><span class='o'>)</span></code></pre>

</div>

## The advantages of Lazy reading

readr 2.0 introduced 'lazy' reading by default. The idea of lazy reading is that instead of reading all the data in a CSV file up front you instead read it only on-demand.

For example the following code reads the column headers, filters based on column `hp` then computes the mean of the filtered column `mpg`.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://tidyverse.tidyverse.org'>tidyverse</a></span><span class='o'>)</span>

<span class='nv'>df</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://readr.tidyverse.org/reference/read_delim.html'>read_csv</a></span><span class='o'>(</span><span class='nf'><a href='https://readr.tidyverse.org/reference/readr_example.html'>readr_example</a></span><span class='o'>(</span><span class='s'>"mtcars.csv"</span><span class='o'>)</span>, lazy <span class='o'>=</span> <span class='kc'>TRUE</span><span class='o'>)</span>

<span class='nv'>df</span> |&gt;
  <span class='nf'><a href='https://rdrr.io/r/stats/filter.html'>filter</a></span><span class='o'>(</span><span class='nv'>hp</span> <span class='o'>&gt;</span> <span class='m'>200</span><span class='o'>)</span> |&gt;
  <span class='nf'>summarise</span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/mean.html'>mean</a></span><span class='o'>(</span><span class='nv'>mpg</span><span class='o'>)</span><span class='o'>)</span>
<span class='c'>#&gt; <span style='color: #555555;'># A tibble: 1 × 1</span></span>
<span class='c'>#&gt;   `mean(mpg)`</span>
<span class='c'>#&gt;         <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>1</span>        13.4</span></code></pre>

</div>

When you run this example readr would then only read the data in the orange colored parts of the file.

![lazy diagram](lazy.png)

The long orange strip at the top is the column headers, the vertical bar is the data in the `hp` column, and the dotted parts are the filtered `mpg` values used to calculate the mean. As you can see depending on what you are doing with the file using lazy reading can drastically reduce the amount of the total file you end up needing to access.

This idea, first explored in the [vroom](https://vroom.r-lib.org/) package, can result in considerable speed improvements depending on the size of the file and what parts you are interested in. readr 2.0 used vroom under the hood to provide this type of lazy reading by default.

## The problems with lazy reading

vroom was first released to CRAN in May 2019, and not added to readr until 2 years later in July 2021. Unfortunately usage of vroom was dwarfed by that of readr and the overall pool of users using vroom remained small. In particular the proportion of Windows users using vroom was much lower than those using readr. Crucially the behavior of lazy reading on Windows suffers due to how Windows works with file handles.

One major downside to lazy reading is that the program needs to keep a file handle open to the file. File handles are the low level way computer programs read to or write to a file. How they work varies by the operating system. POSIX (Portable Operating System Interface) systems like macOS and linux allow multiple processes to hold read only file handles to the same file. In contrast on Windows the situation is different, once a process opens a file handle that file is locked from other processes opening it for as long as the handle is open. If you have ever encountered a message like

> File/Folder in Use. The action can't be completed because the file is open in another program. Close the folder or file and try again.

Then this file handle locking behavior is the likely cause. You are trying to open a file in program A that program B also has open.

We were aware of this issue, however we underestimated the prevalence of situations where users would run into this problem and amount of user confusion this would entail.

## Decision to change the default

Upon release of readr 2.0 most of the reaction was positive. However a number of people opened issues related to locked files and the use of lazy reading. Many of these cases occurred when users tried to open files in other programs like Excel or view it in the RStudio IDE, but there was another case we hadn't considered in detail.

A number of users had workflows where they read in a file, cleaned the data in R, and then wrote back to that same file name in the same R session. vroom and readr's writing functions had code in them to ensure if users did this with a lazily read data frame the data would be first fully read eagerly (and the file handle closed) before writing. However other functions we don't control (like [`utils::write.csv`](https://rdrr.io/r/utils/write.table.html), [`data.table::fread()`](https://Rdatatable.gitlab.io/data.table/reference/fread.html), etc.) would have no notion of this problem and would therefore fail to work. In addition this failure is hard to reason about unless you have a good mental model of how lazy reading works *and* happened to know that readr 2.0 now used lazy reading by default.

Because of the prevalence of these issues we started to consider changing the default to eager rather than lazy reading. But to get a better sense of the community's opinion we [conducted a survey](https://twitter.com/jimhester_/status/1446173748579770375) about this issue. We received over 250 responses to the survey (thanks to everyone who responded!) and the results were very conclusive.

-   \~1/2 of the respondents used Windows
-   \~3/4 of users overall would prefer `lazy = FALSE` as the default.
-   \~9/10 of Windows users would prefer `lazy = FALSE` as the default.

This reinforced our intuition that changing the default to `lazy = FALSE` was the right choice for the community going forward.

## Controlling the default yourself

Aside from changing the default to `lazy = FALSE` readr 2.1 also gives users a way to control the lazy default themselves.

    options(readr.read_lazy = TRUE)

This will change the default value back to lazy by default for the current R session. Note that this can have unintended consequences, code in downstream packages you are using may be using readr without your knowledge, and changing the default will also change their usage. The surest way to ensure consistency in your own code is to explicitly set either `lazy = FALSE` or `lazy = TRUE` when you call a [`read_csv()`](https://readr.tidyverse.org/reference/read_delim.html) function.

## Lessons learned

Reaching a more representative cross section of users and having them experiment with a new package is a challenge. As mentioned above, vroom was on CRAN for more than two years, and had significant performance advantages to readr, but even so only a small fraction of the community ended up using it. Crucially this usage did not reveal a complete enough picture of the challenges associated with lazy reading.

Most R users seem to prefer something which 'just works' for *all* use cases, even at the cost of reduced default performance.

Community surveys continue to be the best way to gauge the overall opinion of the community. In hindsight, we should have conducted the survey prior to the release of readr 2.0, though the full scope of the issue was not well known then.

Thank you to everyone who has used readr, opened an issue about this topic, or responded to the survey. Open source software is written to serve the community and your input is crucial to make sure we are making the best decisions. We apologize if this issue affected your work negatively and hope this article helps explain our rational for the initial behavior and change back. We hope readr will continue to make you more productive in the future.

Also a special thank you to all the 81 contributors who opened issues or contributed code since the readr 2.0 release, without your input readr would be a less useful package.

[@a-hurst](https://github.com/a-hurst), [@alon-sarid](https://github.com/alon-sarid), [@anonsmoose](https://github.com/anonsmoose), [@AshesITR](https://github.com/AshesITR), [@bersbersbers](https://github.com/bersbersbers), [@boshek](https://github.com/boshek), [@chrbknudsen](https://github.com/chrbknudsen), [@christopherkenny](https://github.com/christopherkenny), [@cwby](https://github.com/cwby), [@damianooldoni](https://github.com/damianooldoni), [@Darxor](https://github.com/Darxor), [@DizzyLimit](https://github.com/DizzyLimit), [@djnavarro](https://github.com/djnavarro), [@dongzhuoer](https://github.com/dongzhuoer), [@dzhang32](https://github.com/dzhang32), [@eutwt](https://github.com/eutwt), [@fernandovmacedo](https://github.com/fernandovmacedo), [@garrettgman](https://github.com/garrettgman), [@garthtarr](https://github.com/garthtarr), [@ggrothendieck](https://github.com/ggrothendieck), [@gorkang](https://github.com/gorkang), [@hadley](https://github.com/hadley), [@HakuShuu](https://github.com/HakuShuu), [@HedvigS](https://github.com/HedvigS), [@HenrikBengtsson](https://github.com/HenrikBengtsson), [@hidekoji](https://github.com/hidekoji), [@hongyuanjia](https://github.com/hongyuanjia), [@huixinz2](https://github.com/huixinz2), [@ibombonato](https://github.com/ibombonato), [@jcarbaut](https://github.com/jcarbaut), [@jeffeaton](https://github.com/jeffeaton), [@jennybc](https://github.com/jennybc), [@jimhester](https://github.com/jimhester), [@jimmyday12](https://github.com/jimmyday12), [@jkeuskamp](https://github.com/jkeuskamp), [@jmbarbone](https://github.com/jmbarbone), [@jmobrien](https://github.com/jmobrien), [@JoshuaSturm](https://github.com/JoshuaSturm), [@jpquast](https://github.com/jpquast), [@kiernann](https://github.com/kiernann), [@knokknok](https://github.com/knokknok), [@krlmlr](https://github.com/krlmlr), [@l-gorman](https://github.com/l-gorman), [@lindsayplatt](https://github.com/lindsayplatt), [@lionel-](https://github.com/lionel-), [@lukeholman](https://github.com/lukeholman), [@MilesMcBain](https://github.com/MilesMcBain), [@mkvasnicka](https://github.com/mkvasnicka), [@nigeljmckernan](https://github.com/nigeljmckernan), [@nik-humphries](https://github.com/nik-humphries), [@nstjhp](https://github.com/nstjhp), [@oharac](https://github.com/oharac), [@palderman](https://github.com/palderman), [@peterdesmet](https://github.com/peterdesmet), [@pfreese](https://github.com/pfreese), [@PierreStevenin](https://github.com/PierreStevenin), [@pieterjanvc](https://github.com/pieterjanvc), [@pschloss](https://github.com/pschloss), [@rbufba](https://github.com/rbufba), [@rdinnager](https://github.com/rdinnager), [@richelbilderbeek](https://github.com/richelbilderbeek), [@rvalieris](https://github.com/rvalieris), [@s-andrews](https://github.com/s-andrews), [@saulo1305](https://github.com/saulo1305), [@sbachstein](https://github.com/sbachstein), [@sdevine188](https://github.com/sdevine188), [@ShinyFabio](https://github.com/ShinyFabio), [@slodge](https://github.com/slodge), [@snaut](https://github.com/snaut), [@stephenturner](https://github.com/stephenturner), [@svraka](https://github.com/svraka), [@tarheel](https://github.com/tarheel), [@TCLamnidis](https://github.com/TCLamnidis), [@thackl](https://github.com/thackl), [@timothy-barry](https://github.com/timothy-barry), [@timothyslau](https://github.com/timothyslau), [@tmelliott](https://github.com/tmelliott), [@Tonyynot14](https://github.com/Tonyynot14), [@UrsineWelles](https://github.com/UrsineWelles), [@xinyu-zheng](https://github.com/xinyu-zheng), and [@yogat3ch](https://github.com/yogat3ch).

