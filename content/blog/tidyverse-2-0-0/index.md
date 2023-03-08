---
output: hugodown::hugo_document

slug: tidyverse-2-0-0
title: tidyverse 2.0.0
date: 2023-03-08
author: Hadley Wickham
description: >
    Now including lubridate!

photo:
  url: https://unsplash.com/photos/fUnfEz3VLv4
  author: Graham Holtshausen

# one of: "deep-dive", "learn", "package", "programming", "roundup", or "other"
categories: [package] 
tags: [tidyverse]
rmd_hash: ccecf212304aebcd

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
* [x] [`usethis::use_tidy_thanks()`](https://usethis.r-lib.org/reference/use_tidy_thanks.html)
-->

We're tickled pink to announce the release of [tidyverse](http://tidyverse.tidyverse.org/) 2.0.0. The tidyverse is a set of packages that work in harmony because they share common data representations and API design. The tidyverse package is a "meta" package designed to make it easy to install and load core packages from the tidyverse in a single command. This is great for teaching and interactive use, but for package development purposes we recommend that authors import only the specific packages that they use. For a complete list of changes, please see the release notes.

You can install it from CRAN with:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://rdrr.io/r/utils/install.packages.html'>install.packages</a></span><span class='o'>(</span><span class='s'>"tidyverse"</span><span class='o'>)</span></span></code></pre>

</div>

There's only really one big change in this tidyverse 2.0.0: lubridate is now a core member of the tidyverse! This means it's attached automatically when you load the tidyverse:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://tidyverse.tidyverse.org'>tidyverse</a></span><span class='o'>)</span></span>
<span><span class='c'>#&gt; ── <span style='font-weight: bold;'>Attaching core tidyverse packages</span> ──────────────────────── tidyverse 2.0.0 ──</span></span>
<span><span class='c'>#&gt; <span style='color: #00BB00;'>✔</span> <span style='color: #0000BB;'>dplyr    </span> 1.1.0.<span style='color: #BB0000;'>9000</span>     <span style='color: #00BB00;'>✔</span> <span style='color: #0000BB;'>readr    </span> 2.1.4     </span></span>
<span><span class='c'>#&gt; <span style='color: #00BB00;'>✔</span> <span style='color: #0000BB;'>forcats  </span> 1.0.0          <span style='color: #00BB00;'>✔</span> <span style='color: #0000BB;'>stringr  </span> 1.5.0     </span></span>
<span><span class='c'>#&gt; <span style='color: #00BB00;'>✔</span> <span style='color: #0000BB;'>ggplot2  </span> 3.4.1          <span style='color: #00BB00;'>✔</span> <span style='color: #0000BB;'>tibble   </span> 3.1.8     </span></span>
<span><span class='c'>#&gt; <span style='color: #00BB00;'>✔</span> <span style='color: #0000BB;'>lubridate</span> 1.9.2          <span style='color: #00BB00;'>✔</span> <span style='color: #0000BB;'>tidyr    </span> 1.3.0     </span></span>
<span><span class='c'>#&gt; <span style='color: #00BB00;'>✔</span> <span style='color: #0000BB;'>purrr    </span> 1.0.1          </span></span>
<span><span class='c'>#&gt; ── <span style='font-weight: bold;'>Conflicts</span> ────────────────────────────────────────── tidyverse_conflicts() ──</span></span>
<span><span class='c'>#&gt; <span style='color: #BB0000;'>✖</span> <span style='color: #0000BB;'>dplyr</span>::<span style='color: #00BB00;'>filter()</span> masks <span style='color: #0000BB;'>stats</span>::filter()</span></span>
<span><span class='c'>#&gt; <span style='color: #BB0000;'>✖</span> <span style='color: #0000BB;'>dplyr</span>::<span style='color: #00BB00;'>lag()</span>    masks <span style='color: #0000BB;'>stats</span>::lag()</span></span>
<span><span class='c'>#&gt; <span style='color: #00BBBB;'>ℹ</span> Use the <a href='http://conflicted.r-lib.org/'>conflicted package</a> to force all conflicts to become errors</span></span>
<span></span></code></pre>

</div>

You'll notice one other small change to the tidyverse message: we now advertise the [conflicted package](https://conflicted.r-lib.org). This package has been around for a while, but we wanted to promote it a bit more heavily because it's so useful.

conflicted provides an alternative conflict resolution strategy, when multiple packages export a function of the same name. R's default conflict resolution system gives precedence to the most recently loaded package. This can make it hard to detect conflicts, particularly when they're introduced by an update to an existing package. conflicted takes a different approach, turning conflicts into errors and forcing you to choose which function to use.

To use conflicted, all you need to do is load it:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://conflicted.r-lib.org/'>conflicted</a></span><span class='o'>)</span></span></code></pre>

</div>

Using any function that's defined in multiple packages will now throw an error:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://dplyr.tidyverse.org/reference/filter.html'>filter</a></span><span class='o'>(</span><span class='nv'>mtcars</span>, <span class='nv'>cyl</span> <span class='o'>==</span> <span class='m'>8</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #BBBB00; font-weight: bold;'>Error</span><span style='font-weight: bold;'>:</span></span></span>
<span><span class='c'>#&gt; <span style='color: #BBBB00;'>!</span> <span style='color: #555555;'>[conflicted]</span> <span style='font-weight: bold;'>filter</span> found in 2 packages.</span></span>
<span><span class='c'>#&gt; Either pick the one you want with `::`:</span></span>
<span><span class='c'>#&gt; <span style='color: #00BBBB;'>•</span> <span style='color: #0000BB;'>dplyr</span>::filter</span></span>
<span><span class='c'>#&gt; <span style='color: #00BBBB;'>•</span> <span style='color: #0000BB;'>stats</span>::filter</span></span>
<span><span class='c'>#&gt; Or declare a preference with `conflicts_prefer()`:</span></span>
<span><span class='c'>#&gt; <span style='color: #00BBBB;'>•</span> `conflicts_prefer(dplyr::filter)`</span></span>
<span><span class='c'>#&gt; <span style='color: #00BBBB;'>•</span> `conflicts_prefer(stats::filter)`</span></span>
<span></span></code></pre>

</div>

As the error suggests, to resolve the problem you can either namespace individual calls:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'>dplyr</span><span class='nf'>::</span><span class='nf'><a href='https://dplyr.tidyverse.org/reference/filter.html'>filter</a></span><span class='o'>(</span><span class='nv'>mtcars</span>, <span class='nv'>am</span> <span class='o'>&amp;</span> <span class='nv'>cyl</span> <span class='o'>==</span> <span class='m'>8</span><span class='o'>)</span></span>
<span><span class='c'>#&gt;                 mpg cyl disp  hp drat   wt qsec vs am gear carb</span></span>
<span><span class='c'>#&gt; Ford Pantera L 15.8   8  351 264 4.22 3.17 14.5  0  1    5    4</span></span>
<span><span class='c'>#&gt; Maserati Bora  15.0   8  301 335 3.54 3.57 14.6  0  1    5    8</span></span>
<span></span></code></pre>

</div>

Or declare a session wide preference:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://conflicted.r-lib.org/reference/conflicts_prefer.html'>conflicts_prefer</a></span><span class='o'>(</span><span class='nf'>dplyr</span><span class='nf'>::</span><span class='nf'><a href='https://dplyr.tidyverse.org/reference/filter.html'>filter</a></span><span class='o'>(</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>[conflicted]</span> Will prefer <span style='color: #0000BB; font-weight: bold;'>dplyr</span>::filter over any other package.</span></span>
<span></span><span><span class='nf'><a href='https://dplyr.tidyverse.org/reference/filter.html'>filter</a></span><span class='o'>(</span><span class='nv'>mtcars</span>, <span class='nv'>am</span> <span class='o'>&amp;</span> <span class='nv'>cyl</span> <span class='o'>==</span> <span class='m'>8</span><span class='o'>)</span></span>
<span><span class='c'>#&gt;                 mpg cyl disp  hp drat   wt qsec vs am gear carb</span></span>
<span><span class='c'>#&gt; Ford Pantera L 15.8   8  351 264 4.22 3.17 14.5  0  1    5    4</span></span>
<span><span class='c'>#&gt; Maserati Bora  15.0   8  301 335 3.54 3.57 14.6  0  1    5    8</span></span>
<span></span></code></pre>

</div>

The conflicted package is fairly established, but it hasn't seen a huge amount of use, so if you think of something that would make it better, [please let us know!](https://github.com/r-lib/conflicted/issues).

