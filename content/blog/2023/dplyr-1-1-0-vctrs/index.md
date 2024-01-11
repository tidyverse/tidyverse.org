---
output: hugodown::hugo_document
slug: dplyr-1-1-0-vctrs
title: "dplyr 1.1.0: The power of vctrs"
date: 2023-02-02
author: Davis Vaughan
description: >
    All of the dplyr vector functions, like `between()` and `case_when()`, are now powered by
    vctrs. We've also added two powerful new helpers: `case_match()` and `consecutive_id()`.
photo:
  url: https://unsplash.com/photos/n6vS3xlnsCc
  author: Armand Khoury
categories: [package] 
tags: [dplyr, dplyr-1-1-0]
editor_options: 
  chunk_output_type: console
rmd_hash: 2fa9c7c2be5db2e5

---

Today's [dplyr 1.1.0](https://dplyr.tidyverse.org/news/index.html#dplyr-110) post is focused on various updates to vector functions, like [`case_when()`](https://dplyr.tidyverse.org/reference/case_when.html) and [`between()`](https://dplyr.tidyverse.org/reference/between.html). If you missed our previous posts, you can also see the other [blog posts](https://www.tidyverse.org/tags/dplyr-1-1-0/) in this series. All of dplyr's vector functions are now backed by [vctrs](https://vctrs.r-lib.org/), which typically results in better error messages, better performance, and greater versatility.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://rdrr.io/r/utils/install.packages.html'>install.packages</a></span><span class='o'>(</span><span class='s'>"dplyr"</span><span class='o'>)</span></span></code></pre>

</div>

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://dplyr.tidyverse.org'>dplyr</a></span><span class='o'>)</span></span></code></pre>

</div>

## `case_when()`

If you've used [`case_when()`](https://dplyr.tidyverse.org/reference/case_when.html) before, you've probably written a statement like this:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>x</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='m'>1</span>, <span class='m'>12</span>, <span class='o'>-</span><span class='m'>5</span>, <span class='m'>6</span>, <span class='o'>-</span><span class='m'>2</span>, <span class='kc'>NA</span>, <span class='m'>0</span><span class='o'>)</span></span></code></pre>

</div>

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://dplyr.tidyverse.org/reference/case_when.html'>case_when</a></span><span class='o'>(</span></span>
<span>  <span class='nv'>x</span> <span class='o'>&gt;=</span> <span class='m'>10</span> <span class='o'>~</span> <span class='s'>"large"</span>,</span>
<span>  <span class='nv'>x</span> <span class='o'>&gt;=</span> <span class='m'>0</span> <span class='o'>~</span> <span class='s'>"small"</span>,</span>
<span>  <span class='nv'>x</span> <span class='o'>&lt;</span> <span class='m'>0</span> <span class='o'>~</span> <span class='kc'>NA</span></span>
<span><span class='o'>)</span></span>
<span><span class='c'>#&gt; Error: `NA` must be &lt;character&gt;, not &lt;logical&gt;.</span></span></code></pre>

</div>

Like me, you've probably forgotten that [`case_when()`](https://dplyr.tidyverse.org/reference/case_when.html) has historically been strict about the types on the right-hand side of the `~`, which means that I needed to use `NA_character_` here instead of `NA`. Luckily, the switch to vctrs means that the above code now "just works":

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://dplyr.tidyverse.org/reference/case_when.html'>case_when</a></span><span class='o'>(</span></span>
<span>  <span class='nv'>x</span> <span class='o'>&gt;=</span> <span class='m'>10</span> <span class='o'>~</span> <span class='s'>"large"</span>,</span>
<span>  <span class='nv'>x</span> <span class='o'>&gt;=</span> <span class='m'>0</span> <span class='o'>~</span> <span class='s'>"small"</span>,</span>
<span>  <span class='nv'>x</span> <span class='o'>&lt;</span> <span class='m'>0</span> <span class='o'>~</span> <span class='kc'>NA</span></span>
<span><span class='o'>)</span></span>
<span><span class='c'>#&gt; [1] "small" "large" NA      "small" NA      NA      "small"</span></span>
<span></span></code></pre>

</div>

You've probably also written a statement like this:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://dplyr.tidyverse.org/reference/case_when.html'>case_when</a></span><span class='o'>(</span></span>
<span>  <span class='nv'>x</span> <span class='o'>&gt;=</span> <span class='m'>10</span> <span class='o'>~</span> <span class='s'>"large"</span>,</span>
<span>  <span class='nv'>x</span> <span class='o'>&gt;=</span> <span class='m'>0</span> <span class='o'>~</span> <span class='s'>"small"</span>,</span>
<span>  <span class='nf'><a href='https://rdrr.io/r/base/NA.html'>is.na</a></span><span class='o'>(</span><span class='nv'>x</span><span class='o'>)</span> <span class='o'>~</span> <span class='s'>"missing"</span>,</span>
<span>  <span class='kc'>TRUE</span> <span class='o'>~</span> <span class='s'>"other"</span></span>
<span><span class='o'>)</span></span>
<span><span class='c'>#&gt; [1] "small"   "large"   "other"   "small"   "other"   "missing" "small"</span></span>
<span></span></code></pre>

</div>

In this case, we have a fall-through "default" captured by `TRUE ~`. This has always felt a little awkward and is fairly difficult to explain to new R users. To make this clearer, we've added an explicit `.default` argument that we encourage you to use instead:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://dplyr.tidyverse.org/reference/case_when.html'>case_when</a></span><span class='o'>(</span></span>
<span>  <span class='nv'>x</span> <span class='o'>&gt;=</span> <span class='m'>10</span> <span class='o'>~</span> <span class='s'>"large"</span>,</span>
<span>  <span class='nv'>x</span> <span class='o'>&gt;=</span> <span class='m'>0</span> <span class='o'>~</span> <span class='s'>"small"</span>,</span>
<span>  <span class='nf'><a href='https://rdrr.io/r/base/NA.html'>is.na</a></span><span class='o'>(</span><span class='nv'>x</span><span class='o'>)</span> <span class='o'>~</span> <span class='s'>"missing"</span>,</span>
<span>  .default <span class='o'>=</span> <span class='s'>"other"</span></span>
<span><span class='o'>)</span></span>
<span><span class='c'>#&gt; [1] "small"   "large"   "other"   "small"   "other"   "missing" "small"</span></span>
<span></span></code></pre>

</div>

`.default` will always be processed last, regardless of where you put it in the call to [`case_when()`](https://dplyr.tidyverse.org/reference/case_when.html), so we recommend placing it at the very end.

We haven't started any formal deprecation process for `TRUE ~` yet, but now that there is a better solution available we encourage you to switch over. We do plan to deprecate this feature in the future because it involves some slightly problematic recycling rules (but we wouldn't even begin this process for at least a year).

## `case_match()`

Another type of [`case_when()`](https://dplyr.tidyverse.org/reference/case_when.html) statement you've probably written is some kind of value remapping like:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>x</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"USA"</span>, <span class='s'>"Canada"</span>, <span class='s'>"Wales"</span>, <span class='s'>"UK"</span>, <span class='s'>"China"</span>, <span class='kc'>NA</span>, <span class='s'>"Mexico"</span>, <span class='s'>"Russia"</span><span class='o'>)</span></span>
<span></span>
<span><span class='nf'><a href='https://dplyr.tidyverse.org/reference/case_when.html'>case_when</a></span><span class='o'>(</span></span>
<span>  <span class='nv'>x</span> <span class='o'><a href='https://rdrr.io/r/base/match.html'>%in%</a></span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"USA"</span>, <span class='s'>"Canada"</span>, <span class='s'>"Mexico"</span><span class='o'>)</span> <span class='o'>~</span> <span class='s'>"North America"</span>,</span>
<span>  <span class='nv'>x</span> <span class='o'><a href='https://rdrr.io/r/base/match.html'>%in%</a></span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"Wales"</span>, <span class='s'>"UK"</span><span class='o'>)</span> <span class='o'>~</span> <span class='s'>"Europe"</span>,</span>
<span>  <span class='nv'>x</span> <span class='o'><a href='https://rdrr.io/r/base/match.html'>%in%</a></span> <span class='s'>"China"</span> <span class='o'>~</span> <span class='s'>"Asia"</span></span>
<span><span class='o'>)</span></span>
<span><span class='c'>#&gt; [1] "North America" "North America" "Europe"        "Europe"       </span></span>
<span><span class='c'>#&gt; [5] "Asia"          NA              "North America" NA</span></span>
<span></span></code></pre>

</div>

Remapping values in this way is so common that SQL gives it its own name - the "simple" case statement. To streamline this further, we've taken out some of the repetition involved with `x %in%` by introducing [`case_match()`](https://dplyr.tidyverse.org/reference/case_match.html), a variant of [`case_when()`](https://dplyr.tidyverse.org/reference/case_when.html) that allows you to specify one or more *values* on the left-hand side of the `~`, rather than logical vectors.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://dplyr.tidyverse.org/reference/case_match.html'>case_match</a></span><span class='o'>(</span></span>
<span>  <span class='nv'>x</span>,</span>
<span>  <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"USA"</span>, <span class='s'>"Canada"</span>, <span class='s'>"Mexico"</span><span class='o'>)</span> <span class='o'>~</span> <span class='s'>"North America"</span>,</span>
<span>  <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"France"</span>, <span class='s'>"UK"</span><span class='o'>)</span> <span class='o'>~</span> <span class='s'>"Europe"</span>,</span>
<span>  <span class='s'>"China"</span> <span class='o'>~</span> <span class='s'>"Asia"</span></span>
<span><span class='o'>)</span></span>
<span><span class='c'>#&gt; [1] "North America" "North America" NA              "Europe"       </span></span>
<span><span class='c'>#&gt; [5] "Asia"          NA              "North America" NA</span></span>
<span></span></code></pre>

</div>

I think that [`case_match()`](https://dplyr.tidyverse.org/reference/case_match.html) is particularly neat because it can be wrapped into an ad-hoc replacement helper if you just need to collapse or replace a few problematic values in a vector, while leaving everything else unchanged:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>replace_match</span> <span class='o'>&lt;-</span> <span class='kr'>function</span><span class='o'>(</span><span class='nv'>x</span>, <span class='nv'>...</span><span class='o'>)</span> <span class='o'>&#123;</span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/case_match.html'>case_match</a></span><span class='o'>(</span><span class='nv'>x</span>, <span class='nv'>...</span>, .default <span class='o'>=</span> <span class='nv'>x</span>, .ptype <span class='o'>=</span> <span class='nv'>x</span><span class='o'>)</span></span>
<span><span class='o'>&#125;</span></span>
<span></span>
<span><span class='nf'>replace_match</span><span class='o'>(</span></span>
<span>  <span class='nv'>x</span>, </span>
<span>  <span class='s'>"USA"</span> <span class='o'>~</span> <span class='s'>"United States"</span>, </span>
<span>  <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"UK"</span>, <span class='s'>"Wales"</span><span class='o'>)</span> <span class='o'>~</span> <span class='s'>"United Kingdom"</span>,</span>
<span>  <span class='kc'>NA</span> <span class='o'>~</span> <span class='s'>"[Missing]"</span></span>
<span><span class='o'>)</span></span>
<span><span class='c'>#&gt; [1] "United States"  "Canada"         "United Kingdom" "United Kingdom"</span></span>
<span><span class='c'>#&gt; [5] "China"          "[Missing]"      "Mexico"         "Russia"</span></span>
<span></span></code></pre>

</div>

## `consecutive_id()`

At Posit, we have regular company update meetings. Since we are all remote, these meetings are over Zoom. Zoom has a neat feature where it can record the transcript of your call, and it will report who was speaking and what they said. It looks something like this:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>transcript</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://tibble.tidyverse.org/reference/tribble.html'>tribble</a></span><span class='o'>(</span></span>
<span>  <span class='o'>~</span><span class='nv'>name</span>, <span class='o'>~</span><span class='nv'>text</span>,</span>
<span>  <span class='s'>"Hadley"</span>, <span class='s'>"I'll never learn Python."</span>,</span>
<span>  <span class='s'>"Davis"</span>, <span class='s'>"But aren't you speaking at PyCon?"</span>,</span>
<span>  <span class='s'>"Hadley"</span>, <span class='s'>"So?"</span>,</span>
<span>  <span class='s'>"Hadley"</span>, <span class='s'>"That doesn't influence my decision."</span>,</span>
<span>  <span class='s'>"Hadley"</span>, <span class='s'>"I'm not budging!"</span>,</span>
<span>  <span class='s'>"Mara"</span>, <span class='s'>"Typical, Hadley. Stubborn as always."</span>,</span>
<span>  <span class='s'>"Davis"</span>, <span class='s'>"Fair enough!"</span>,</span>
<span>  <span class='s'>"Davis"</span>, <span class='s'>"Let's move on."</span></span>
<span><span class='o'>)</span></span>
<span></span>
<span><span class='nv'>transcript</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 8 × 2</span></span></span>
<span><span class='c'>#&gt;   name   text                                </span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>  <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>                               </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span> Hadley I'll never learn Python.            </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span> Davis  But aren't you speaking at PyCon?   </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>3</span> Hadley So?                                 </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>4</span> Hadley That doesn't influence my decision. </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>5</span> Hadley I'm not budging!                    </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>6</span> Mara   Typical, Hadley. Stubborn as always.</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>7</span> Davis  Fair enough!                        </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>8</span> Davis  Let's move on.</span></span>
<span></span></code></pre>

</div>

We were working with this data and wanted a way to collapse each continuous thought down to one line. For example, rows 3-5 all contain a single idea from Hadley, so we'd like those to be collapsed into a single line. This isn't quite as straightforward as a simple group-by-`name` and [`summarise()`](https://dplyr.tidyverse.org/reference/summarise.html):

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>transcript</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/summarise.html'>summarise</a></span><span class='o'>(</span>text <span class='o'>=</span> <span class='nf'>stringr</span><span class='nf'>::</span><span class='nf'><a href='https://stringr.tidyverse.org/reference/str_flatten.html'>str_flatten</a></span><span class='o'>(</span><span class='nv'>text</span>, collapse <span class='o'>=</span> <span class='s'>" "</span><span class='o'>)</span>, .by <span class='o'>=</span> <span class='nv'>name</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 3 × 2</span></span></span>
<span><span class='c'>#&gt;   name   text                                                                   </span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>  <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>                                                                  </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span> Hadley I'll never learn Python. So? That doesn't influence my decision. I'm n…</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span> Davis  But aren't you speaking at PyCon? Fair enough! Let's move on.          </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>3</span> Mara   Typical, Hadley. Stubborn as always.</span></span>
<span></span></code></pre>

</div>

This isn't quite right because it collapsed the first row where Hadley says "I'll never learn Python" alongside rows 3-5. We need a way to identify consecutive *runs* representing when a single person is speaking, which is exactly what [`consecutive_id()`](https://dplyr.tidyverse.org/reference/consecutive_id.html) is for!

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>transcript</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/mutate.html'>mutate</a></span><span class='o'>(</span>id <span class='o'>=</span> <span class='nf'><a href='https://dplyr.tidyverse.org/reference/consecutive_id.html'>consecutive_id</a></span><span class='o'>(</span><span class='nv'>name</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 8 × 3</span></span></span>
<span><span class='c'>#&gt;   name   text                                    id</span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>  <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>                                <span style='color: #555555; font-style: italic;'>&lt;int&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span> Hadley I'll never learn Python.                 1</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span> Davis  But aren't you speaking at PyCon?        2</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>3</span> Hadley So?                                      3</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>4</span> Hadley That doesn't influence my decision.      3</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>5</span> Hadley I'm not budging!                         3</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>6</span> Mara   Typical, Hadley. Stubborn as always.     4</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>7</span> Davis  Fair enough!                             5</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>8</span> Davis  Let's move on.                           5</span></span>
<span></span></code></pre>

</div>

[`consecutive_id()`](https://dplyr.tidyverse.org/reference/consecutive_id.html) takes one or more columns and generates an integer vector that increments every time a value in one of those columns changes. This gives us something we can group on to correctly flatten our `text`.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>transcript</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/mutate.html'>mutate</a></span><span class='o'>(</span>id <span class='o'>=</span> <span class='nf'><a href='https://dplyr.tidyverse.org/reference/consecutive_id.html'>consecutive_id</a></span><span class='o'>(</span><span class='nv'>name</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/summarise.html'>summarise</a></span><span class='o'>(</span>text <span class='o'>=</span> <span class='nf'>stringr</span><span class='nf'>::</span><span class='nf'><a href='https://stringr.tidyverse.org/reference/str_flatten.html'>str_flatten</a></span><span class='o'>(</span><span class='nv'>text</span>, collapse <span class='o'>=</span> <span class='s'>" "</span><span class='o'>)</span>, .by <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='nv'>id</span>, <span class='nv'>name</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 5 × 3</span></span></span>
<span><span class='c'>#&gt;      id name   text                                                    </span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;int&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>  <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>                                                   </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span>     1 Hadley I'll never learn Python.                                </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span>     2 Davis  But aren't you speaking at PyCon?                       </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>3</span>     3 Hadley So? That doesn't influence my decision. I'm not budging!</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>4</span>     4 Mara   Typical, Hadley. Stubborn as always.                    </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>5</span>     5 Davis  Fair enough! Let's move on.</span></span>
<span></span></code></pre>

</div>

Grouping by `id` alone is actually enough, but I've also grouped by `name` for a convenient way to drag the name along into the summary table.

[`consecutive_id()`](https://dplyr.tidyverse.org/reference/consecutive_id.html) is inspired by [`data.table::rleid()`](https://rdatatable.gitlab.io/data.table/reference/rleid.html), which serves a similar purpose.

## Miscellaneous updates

-   [`between()`](https://dplyr.tidyverse.org/reference/between.html) is no longer restricted to length 1 `left` and `right` boundaries. They are now allowed to be length 1 or the same length as `x`. Additionally, [`between()`](https://dplyr.tidyverse.org/reference/between.html) now works with any type supported by vctrs, rather than just with numerics and date-times.

-   [`if_else()`](https://dplyr.tidyverse.org/reference/if_else.html) has received the same updates as [`case_when()`](https://dplyr.tidyverse.org/reference/case_when.html). In particular, it is no longer as strict about typed missing values.

-   The ranking functions, like [`dense_rank()`](https://dplyr.tidyverse.org/reference/row_number.html), now allow data frame inputs as a way to rank by multiple columns at once.

-   [`first()`](https://dplyr.tidyverse.org/reference/nth.html), [`last()`](https://dplyr.tidyverse.org/reference/nth.html), and [`nth()`](https://dplyr.tidyverse.org/reference/nth.html) have all gained an `na_rm` argument since they are summary functions.

-   [`na_if()`](https://dplyr.tidyverse.org/reference/na_if.html) now casts `y` to the type of `x` to make it clear that it is type stable on `x`. In particular, this means you can no longer do `na_if(<tbl>, 0)`, which previously accidentally allowed you to attempt to replace missing values in every column with `0`. This function has always been intended as a vector function, and this is considered off-label usage. It also now replaces `NaN` values in double and complex vectors.

