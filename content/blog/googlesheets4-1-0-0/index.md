---
output: hugodown::hugo_document

slug: googlesheets4-1-0-0
title: googlesheets4 1.0.0
date: 2021-07-21
author: Jenny Bryan
description: >
    A 2-3 sentence description of the post that appears on the articles page.
    This can be omitted if it would just recapitulate the title.

photo:
  url: https://unsplash.com/photos/VqYzKAviJ10
  author: Hendri Sabri

categories: [package]
tags: [googlesheets4, gargle]
rmd_hash: aeeeef893834693b

---

<!--
TODO:
* [ ] Look over / edit the post's title in the yaml
* [ ] Edit (or delete) the description; note this appears in the Twitter card
-->

We're over the moon to announce the release of googlesheets4, version 1.0.0 (<https://googlesheets4.tidyverse.org>).

googlesheets4 is a package to work with Google Sheets from R. It wraps [v4 of the Sheets API](https://developers.google.com/sheets/api/reference/rest). googlesheets4 is focused on spreadsheet-y tasks that require a notion of worksheets, cells, and ranges, while the companion package [googledrive](https://googledrive.tidyverse.org) handles more general file operations, such as renaming, sharing, or moving.

Install googlesheets4 from CRAN like so:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://rdrr.io/r/utils/install.packages.html'>install.packages</a></span><span class='o'>(</span><span class='s'>"googlesheets4"</span><span class='o'>)</span></code></pre>

</div>

Then attach it for use via:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://googlesheets4.tidyverse.org'>googlesheets4</a></span><span class='o'>)</span></code></pre>

</div>

The release of version 1.0.0 means googlesheets4 has graduated from being experimental to being stable, in terms of the [tidyverse lifecycle stages](https://lifecycle.r-lib.org/articles/stages.html). [^1]

Since we [last blogged about it](https://www.tidyverse.org/blog/2020/05/googlesheets4-0-2-0/), googlesheets4 has seen some "quality of life" improvements, but no earthshaking changes. The overall interface is more polished, we automatically retry requests that yield the dreaded `429 RESOURCE_EXHAUSTED`, and there's better handling of some empty cell edge cases. We're also bumping the required version of the gargle package (<https://gargle.r-lib.org>), which handles everything around auth.

You can see a full list of changes in the [release notes](https://googlesheets4.tidyverse.org/news/index.html).

## Auth updates

If you are generally fairly passive about googlesheets4 auth, then you should just sit back and let things happen organically during usage. If you've used googlesheets4 before, you can expect to see some messages about cleaning and relocating the token cache when you first use v1.0.0. You can also expect to re-authenticate yourself with Google and re-authorize the "Tidyverse API Packages" to work with your files. This is all due to changes in gargle.

If your usage requires you to be more proactive about auth, read the [blog post for gargle's recent v1.2.0 release](https://www.tidyverse.org/blog/2021/07/gargle-1-2-0/). A key point is that we have rolled the built-in OAuth client, which is why those relying on it will need to re-auth.

**If the rolling of the tidyverse OAuth client is highly disruptive to your workflow, consider this a wake-up call** that you should be using your own OAuth client or, quite possibly, an entirely different method of auth. Our credential rolling will have no impact on users who use their own OAuth client or service account tokens.

If you often use googlesheets4 together with googledrive, remember that the article [Using googlesheets4 with googledrive](https://googlesheets4.tidyverse.org/articles/articles/drive-and-sheets.html) gives some tips for how to coordinate auth.

## Retries

The Sheets API has [usage limits](https://developers.google.com/sheets/api/reference/limits) that are low enough even regular folks bump up against them occasionally:

-   100 requests per 100 seconds per user
-   500 requests per 100 seconds per project

When you hit one of these limits, your request fails with the error code `429 RESOURCE_EXHAUSTED`. Thanks to a change in gargle, we now automatically retry such a request and, if it looks like you've exhausted your **user** quota, that first wait is \> 100 seconds (!!).

If this happens to you fairly often, you should contemplate whether your code relies on some self-defeating pattern, like hitting the Sheets API repeatedly in a tight loop. Here's an example of bad vs. good googlesheets4 code:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>gapminder</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://googlesheets4.tidyverse.org/reference/gs4_examples.html'>gs4_example</a></span><span class='o'>(</span><span class='s'>"gapminder"</span><span class='o'>)</span>
<span class='nv'>sp</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://googlesheets4.tidyverse.org/reference/sheet_properties.html'>sheet_properties</a></span><span class='o'>(</span><span class='nv'>gapminder</span><span class='o'>)</span>
<span class='o'>(</span><span class='nv'>n</span> <span class='o'>&lt;-</span> <span class='nv'>sp</span><span class='o'>$</span><span class='nv'>grid_rows</span><span class='o'>[</span><span class='nv'>sp</span><span class='o'>$</span><span class='nv'>name</span> <span class='o'>==</span> <span class='s'>"Africa"</span><span class='o'>]</span><span class='o'>)</span>
<span class='c'>#&gt; [1] 625</span>

<span class='c'># this is BAD IDEA = reading individual cells in a loop</span>
<span class='kr'>for</span> <span class='o'>(</span><span class='nv'>i</span> <span class='kr'>in</span> <span class='nf'><a href='https://rdrr.io/r/base/seq.html'>seq_len</a></span><span class='o'>(</span><span class='nv'>n</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>&#123;</span>
  <span class='nv'>gapminder</span> <span class='o'><a href='https://googlesheets4.tidyverse.org/reference/pipe.html'>%&gt;%</a></span>
    <span class='nf'><a href='https://googlesheets4.tidyverse.org/reference/range_read.html'>range_read</a></span><span class='o'>(</span>sheet <span class='o'>=</span> <span class='s'>"Africa"</span>, range <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/sprintf.html'>sprintf</a></span><span class='o'>(</span><span class='s'>"C%i"</span>, <span class='nv'>i</span><span class='o'>)</span><span class='o'>)</span>
<span class='o'>&#125;</span>
<span class='c'>#&gt; ✓ Reading from "gapminder".</span>
<span class='c'>#&gt; ✓ Range ''Africa'!C1'.</span>
<span class='c'>#&gt; ...</span>
<span class='c'>#&gt; x Request failed [429]. Retry 1 happens in 100.8 seconds ...</span>
<span class='c'>#&gt; ✓ Range ''Africa'!C28'.</span>
<span class='c'>#&gt; ...</span>
<span class='c'>#&gt; x Request failed [429]. Retry 1 happens in 100.4 seconds ...</span>
<span class='c'>#&gt; x Request failed [429]. Retry 2 happens in 8.8 seconds ...</span>
<span class='c'>#&gt; ...</span>

<span class='c'># this is a GOOD IDEA = reading all cells at once</span>
<span class='nv'>gapminder</span> <span class='o'><a href='https://googlesheets4.tidyverse.org/reference/pipe.html'>%&gt;%</a></span>
  <span class='nf'><a href='https://googlesheets4.tidyverse.org/reference/range_read.html'>range_read</a></span><span class='o'>(</span>sheet <span class='o'>=</span> <span class='s'>"Africa"</span>, range <span class='o'>=</span> <span class='s'>"C:C"</span><span class='o'>)</span> <span class='o'><a href='https://googlesheets4.tidyverse.org/reference/pipe.html'>%&gt;%</a></span>
  <span class='nf'><a href='https://rdrr.io/r/utils/head.html'>head</a></span><span class='o'>(</span><span class='o'>)</span>
<span class='c'>#&gt; ✓ Reading from "gapminder".</span>
<span class='c'>#&gt; ✓ Range ''Africa'!C:C'.</span>
<span class='c'>#&gt; # A tibble: 6 x 1</span>
<span class='c'>#&gt;    year</span>
<span class='c'>#&gt;   &lt;dbl&gt;</span>
<span class='c'>#&gt; 1  1952</span>
<span class='c'>#&gt; 2  1957</span>
<span class='c'>#&gt; 3  1962</span>
<span class='c'>#&gt; 4  1967</span>
<span class='c'>#&gt; 5  1972</span>
<span class='c'>#&gt; 6  1977</span></code></pre>

</div>

Lesson: work in bulk as much as possible, as opposed to making lots of little piecemeal requests.

What about the per project limit? If you are auth'ed as a regular user, using the built-in OAuth client, this project refers to the Tidyverse API Packages. Yes, that means you're sharing project-level quota with all your fellow useRs who also auth'ed this way!

If you hit per project limits regularly and it upsets your workflow, the universe is telling you that it's time to configure your own OAuth client or use an entirely different method of auth, such as a service account token. Read more in the gargle article [How to get your own API credentials](https://gargle.r-lib.org/articles/get-api-credentials.html).

Casual googlesheets4 users can go with the flow and accept that the occasional request will need an automatic retry. If you want to learn more, the functionality comes from [`gargle::request_retry()`](https://gargle.r-lib.org/reference/request_retry.html). In the development version of gargle, we retry for an even larger set of error codes (408, 429, 500, 502, and 503). If that appeals to you and you're willing to install a pre-release package, we'd love to hear how this works for you.

## User interface

The googlesheets4 user interface (UI) has gotten more stylish, thanks to the cli package (<https://cli.r-lib.org>). This applies to informational messages, as well as to errors.

The semantic UI encouraged by cli is a great fit for googlesheets4, where it's useful to apply distinct inline styles for (spread)Sheet name, (work)sheet name, and cell range. Also bullets! Here is a fictional message that shows off some of these lovely things:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='c'>#&gt; Hey, we're doing exciting things in the <span style='color: #00BBBB;'>chicken_sheet</span>!</span>
<span class='c'>#&gt; <span style='color: #00BBBB;'>ℹ</span> Did you know it has a worksheet called <span style='color: #00BB00;'>chicken_scratch</span>?</span>
<span class='c'>#&gt; <span style='color: #BB0000;'>✖</span> Uh-oh, in range <span style='color: #BBBB00;'>A1:D4</span>, some data appears to be encoded in the cell color :(</span></code></pre>

</div>

In a more technical vein, all errors thrown by googlesheets4 now route through [`rlang::abort()`](https://rlang.r-lib.org/reference/abort.html). This has various benefits, including better access to the backtrace and error data. All errors thrown by googlesheets4 now bear the class `"googlesheets4_error"`.

`googlesheets4_quiet` is a new option to suppress informational messages from googlesheets4. [`local_gs4_quiet()`](https://googlesheets4.tidyverse.org/reference/googlesheets4-configuration.html) and [`with_gs4_quiet()`](https://googlesheets4.tidyverse.org/reference/googlesheets4-configuration.html) are [withr-style](https://withr.r-lib.org) convenience helpers for setting `googlesheets4_quiet = TRUE`.

## Empty cells

It's (not so) funny how much effort goes into handling the absence of data and googlesheets4 is no exception. We've made a few improvements to how we read or write nothing.

The `na` argument of [`read_sheet()`](https://googlesheets4.tidyverse.org/reference/range_read.html) has become more capable and more consistent with readr. Specifically, `na = character()` (or the general lack of `""` among the `na` strings) results in cells with no data appearing as the empty string `""` within a character vector, as opposed to `NA`.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>dat</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/data.frame.html'>data.frame</a></span><span class='o'>(</span>
  x <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"one"</span>, <span class='s'>""</span>, <span class='s'>"three"</span><span class='o'>)</span>
<span class='o'>)</span>
<span class='nv'>ss</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://googlesheets4.tidyverse.org/reference/gs4_create.html'>gs4_create</a></span><span class='o'>(</span><span class='s'>"blog-post-blanks"</span>, sheets <span class='o'>=</span> <span class='nv'>dat</span><span class='o'>)</span>
<span class='c'>#&gt; ✓ Creating new Sheet: "blog-post-blanks".</span>

<span class='nf'><a href='https://googlesheets4.tidyverse.org/reference/range_read.html'>read_sheet</a></span><span class='o'>(</span><span class='nv'>ss</span><span class='o'>)</span>
<span class='c'>#&gt; ✓ Reading from "blog-post-blanks".</span>
<span class='c'>#&gt; ✓ Range 'dat'.</span>
<span class='c'>#&gt; # A tibble: 3 x 1</span>
<span class='c'>#&gt;   x    </span>
<span class='c'>#&gt;   &lt;chr&gt;</span>
<span class='c'>#&gt; 1 one  </span>
<span class='c'>#&gt; 2 &lt;NA&gt; </span>
<span class='c'>#&gt; 3 three</span>

<span class='nf'><a href='https://googlesheets4.tidyverse.org/reference/range_read.html'>read_sheet</a></span><span class='o'>(</span><span class='nv'>ss</span>, na <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/character.html'>character</a></span><span class='o'>(</span><span class='o'>)</span><span class='o'>)</span>
<span class='c'>#&gt; ✓ Reading from "blog-post-blanks".</span>
<span class='c'>#&gt; ✓ Range 'dat'.</span>
<span class='c'>#&gt; # A tibble: 3 x 1</span>
<span class='c'>#&gt;   x      </span>
<span class='c'>#&gt;   &lt;chr&gt;  </span>
<span class='c'>#&gt; 1 "one"  </span>
<span class='c'>#&gt; 2 ""     </span>
<span class='c'>#&gt; 3 "three"</span></code></pre>

</div>

Explicit `NULL`s are also now written properly, i.e. as an empty cell. This can come up with list-columns. List-columns can easily creep in when working with Sheets edited by humans, who tend to create mixed columns by accident, i.e. mixing numbers and text.

## Acknowledgements

We'd like to thank everyone who has helped to shape googlesheets4, since the release of v0.2.0, through their contributions in issues and pull requests:

[@aaronmams](https://github.com/aaronmams), [@ajjitn](https://github.com/ajjitn), [@akgold](https://github.com/akgold), [@AvinaHunjan](https://github.com/AvinaHunjan), [@batpigandme](https://github.com/batpigandme), [@bwganblack](https://github.com/bwganblack), [@cmichaud92](https://github.com/cmichaud92), [@comicalequation](https://github.com/comicalequation), [@CorradoLanera](https://github.com/CorradoLanera), [@cpilat97](https://github.com/cpilat97), [@daattali](https://github.com/daattali), [@davidski](https://github.com/davidski), [@devu123](https://github.com/devu123), [@dgmdevelopment](https://github.com/dgmdevelopment), [@douglascm](https://github.com/douglascm), [@dulearnaux](https://github.com/dulearnaux), [@ericcrandall](https://github.com/ericcrandall), [@ericpgreen](https://github.com/ericpgreen), [@featherduino](https://github.com/featherduino), [@felixetorres](https://github.com/felixetorres), [@ferguskeatinge](https://github.com/ferguskeatinge), [@ghost](https://github.com/ghost), [@Helena-D](https://github.com/Helena-D), [@jasonboots](https://github.com/jasonboots), [@jcheng5](https://github.com/jcheng5), [@jennybc](https://github.com/jennybc), [@JimboMahoney](https://github.com/JimboMahoney), [@johnbde](https://github.com/johnbde), [@jpawlata](https://github.com/jpawlata), [@lpevzner](https://github.com/lpevzner), [@marcusbrito](https://github.com/marcusbrito), [@MateusMaiaDS](https://github.com/MateusMaiaDS), [@mathlete76](https://github.com/mathlete76), [@mattle24](https://github.com/mattle24), [@mikegunn](https://github.com/mikegunn), [@milamyslov](https://github.com/milamyslov), [@MonkmanMH](https://github.com/MonkmanMH), [@nicholailidow](https://github.com/nicholailidow), [@nikosbosse](https://github.com/nikosbosse), [@nilescbn](https://github.com/nilescbn), [@OmarGonD](https://github.com/OmarGonD), [@paulvern](https://github.com/paulvern), [@pschloss](https://github.com/pschloss), [@py9mrg](https://github.com/py9mrg), [@rhamo](https://github.com/rhamo), [@rhgof](https://github.com/rhgof), [@robitalec](https://github.com/robitalec), [@RussBowdrey](https://github.com/RussBowdrey), [@sacrevert](https://github.com/sacrevert), [@sanjmeh](https://github.com/sanjmeh), [@SebastianJHM](https://github.com/SebastianJHM), [@timothoms](https://github.com/timothoms), [@TMax66](https://github.com/TMax66), [@tomcardoso](https://github.com/tomcardoso), [@uhhiitsphilia](https://github.com/uhhiitsphilia), and [@YlanAllouche](https://github.com/YlanAllouche).

[^1]: The deprecated `sheets_*()` functions have been removed, as promised in the warning they have been throwing for over a year. No functionality was lost: this is just the result of the function (re-)naming scheme adopted in googlesheets4 \>= 0.2.0. This [internal documentation](https://googlesheets4.tidyverse.org/articles/articles/function-class-names.html#previous-use-of-sheets-prefix) has a table that maps deprecated functions to their current counterparts.

