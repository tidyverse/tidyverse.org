---
output: hugodown::hugo_document

slug: stringr-1-6-0
title: stringr 1.6.0
date: 2025-10-27
author: Hadley Wickham
description: >
  This release deprecates `str_like(ignore_case)` and changes the behaviour of
  `str_replace_all()` for function replacements. It also introduces `str_ilike()` 
  for case-insensitive SQL-like pattern matching, three new case conversion 
  functions (`str_to_camel()`, `str_to_snake()`, and `str_to_kebab()`), and 
  presrves names in all relevant functions.
photo:
  url: https://unsplash.com/photos/white-yarn-on-white-surface-iYMSv8sf1uA
  author: Adam Valstar

# one of: "deep-dive", "learn", "package", "programming", "roundup", or "other"
categories: [package] 
tags: [stringr]
rmd_hash: 81cf0410d365c6cb

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

We're delighted to announce the release of stringr 1.6.0! stringr provides a cohesive set of functions designed to make working with strings as easy as possible. You can install it from CRAN with:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://rdrr.io/r/utils/install.packages.html'>install.packages</a></span><span class='o'>(</span><span class='s'>"stringr"</span><span class='o'>)</span></span></code></pre>

</div>

This release includes some lifecycle changes, improvements to SQL-like pattern matching functions, and a handful of other useful features. You can see a full list of changes in the [release notes](https://github.com/tidyverse/stringr/releases/tag/v1.6.0).

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://stringr.tidyverse.org'>stringr</a></span><span class='o'>)</span></span></code></pre>

</div>

## Lifecycle changes

This release includes two breaking changes that may affect existing code.

First, the `ignore_case` argument to [`str_like()`](https://stringr.tidyverse.org/reference/str_like.html) is now deprecated. Previously, it defaulted to `ignore_case = TRUE`. This was a mistake because it doesn't align with the conventions of the SQL `LIKE` operator, which is always case sensitive. Going forward, [`str_like()`](https://stringr.tidyverse.org/reference/str_like.html) will always be case sensitive and if you need case-insensitive matching, you can use the new [`str_ilike()`](https://stringr.tidyverse.org/reference/str_like.html) function.

Second, if you use [`str_replace_all()`](https://stringr.tidyverse.org/reference/str_replace.html) with a function for the `replacement` argument, that function now receives all values in a single character vector instead of being called once per string. This change dramatically improves performance, so I decided this change was worth it despite its impact on existing code. I don't think this should affect too much existing code, since it's only affected 9 of the 2,381 packages that use stringr (which I supplied PRs to fix). If your replacement function was designed to work on individual strings, you'll need to vectorise it.

If you haven't used this functionality before, it's pretty cool, because it allows you to supply a function that can transform matches in any way you can imagine. For example, this code that color names with their corresponding hex values:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>colours</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://stringr.tidyverse.org/reference/str_c.html'>str_c</a></span><span class='o'>(</span><span class='s'>"\\b"</span>, <span class='nf'><a href='https://rdrr.io/r/grDevices/colors.html'>colors</a></span><span class='o'>(</span><span class='o'>)</span>, <span class='s'>"\\b"</span>, collapse <span class='o'>=</span> <span class='s'>"|"</span><span class='o'>)</span></span>
<span><span class='nv'>col2hex</span> <span class='o'>&lt;-</span> <span class='kr'>function</span><span class='o'>(</span><span class='nv'>col</span><span class='o'>)</span> <span class='o'>&#123;</span></span>
<span>  <span class='nv'>rgb</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/grDevices/col2rgb.html'>col2rgb</a></span><span class='o'>(</span><span class='nv'>col</span><span class='o'>)</span></span>
<span>  <span class='nf'><a href='https://rdrr.io/r/grDevices/rgb.html'>rgb</a></span><span class='o'>(</span><span class='nv'>rgb</span><span class='o'>[</span><span class='s'>"red"</span>, <span class='o'>]</span>, <span class='nv'>rgb</span><span class='o'>[</span><span class='s'>"green"</span>, <span class='o'>]</span>, <span class='nv'>rgb</span><span class='o'>[</span><span class='s'>"blue"</span>, <span class='o'>]</span>, maxColorValue <span class='o'>=</span> <span class='m'>255</span><span class='o'>)</span></span>
<span><span class='o'>&#125;</span></span>
<span></span>
<span><span class='c'># by Claude Code</span></span>
<span><span class='nv'>poem</span> <span class='o'>&lt;-</span> <span class='s'>"Azure skies meet honeydew light,</span></span>
<span><span class='s'>While coral blooms kiss morning's face.</span></span>
<span><span class='s'>Gold spills across the wheat-field bright,</span></span>
<span><span class='s'>As lavender shadows lose their place.</span></span>
<span><span class='s'>Turquoise waters catch the sun,</span></span>
<span><span class='s'>Where salmon leap through chartreuse streams.</span></span>
<span><span class='s'>Orchid petals, one by one,</span></span>
<span><span class='s'>Fall like plum-soft summer dreams.</span></span>
<span><span class='s'>"</span></span>
<span><span class='nf'><a href='https://rdrr.io/r/base/cat.html'>cat</a></span><span class='o'>(</span><span class='nf'><a href='https://stringr.tidyverse.org/reference/str_replace.html'>str_replace_all</a></span><span class='o'>(</span><span class='nv'>poem</span>, <span class='nf'><a href='https://stringr.tidyverse.org/reference/modifiers.html'>regex</a></span><span class='o'>(</span><span class='nv'>colours</span>, ignore_case <span class='o'>=</span> <span class='kc'>TRUE</span><span class='o'>)</span>, <span class='nv'>col2hex</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; #F0FFFF skies meet #F0FFF0 light,</span></span>
<span><span class='c'>#&gt; While #FF7F50 blooms kiss morning's face.</span></span>
<span><span class='c'>#&gt; #FFD700 spills across the #F5DEB3-field bright,</span></span>
<span><span class='c'>#&gt; As #E6E6FA shadows lose their place.</span></span>
<span><span class='c'>#&gt; #40E0D0 waters catch the sun,</span></span>
<span><span class='c'>#&gt; Where #FA8072 leap through #7FFF00 streams.</span></span>
<span><span class='c'>#&gt; #DA70D6 petals, one by one,</span></span>
<span><span class='c'>#&gt; Fall like #DDA0DD-soft summer dreams.</span></span>
<span></span></code></pre>

</div>

Which version do you think is catchier? 🤣

## Other improvements

This release includes several other useful enhancements:

-   Three new functions make it easy to convert between different programming case conventions:

    <div class="highlight">

    <pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>x</span> <span class='o'>&lt;-</span> <span class='s'>"quick brown fox"</span></span>
    <span></span>
    <span><span class='nf'><a href='https://stringr.tidyverse.org/reference/str_to_camel.html'>str_to_camel</a></span><span class='o'>(</span><span class='nv'>x</span><span class='o'>)</span></span>
    <span><span class='c'>#&gt; [1] "quickBrownFox"</span></span>
    <span></span><span><span class='nf'><a href='https://stringr.tidyverse.org/reference/str_to_camel.html'>str_to_camel</a></span><span class='o'>(</span><span class='nv'>x</span>, first_upper <span class='o'>=</span> <span class='kc'>TRUE</span><span class='o'>)</span></span>
    <span><span class='c'>#&gt; [1] "QuickBrownFox"</span></span>
    <span></span><span><span class='nf'><a href='https://stringr.tidyverse.org/reference/str_to_camel.html'>str_to_snake</a></span><span class='o'>(</span><span class='nv'>x</span><span class='o'>)</span></span>
    <span><span class='c'>#&gt; [1] "quick_brown_fox"</span></span>
    <span></span><span><span class='nf'><a href='https://stringr.tidyverse.org/reference/str_to_camel.html'>str_to_kebab</a></span><span class='o'>(</span><span class='nv'>x</span><span class='o'>)</span></span>
    <span><span class='c'>#&gt; [1] "quick-brown-fox"</span></span>
    <span></span></code></pre>

    </div>

-   All relevant stringr functions now preserve names. This means if your input vector has names, those names will be preserved in the output:

    <div class="highlight">

    <pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>x</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span>first <span class='o'>=</span> <span class='s'>"apple"</span>, second <span class='o'>=</span> <span class='s'>"banana"</span><span class='o'>)</span></span>
    <span><span class='nf'><a href='https://stringr.tidyverse.org/reference/case.html'>str_to_upper</a></span><span class='o'>(</span><span class='nv'>x</span><span class='o'>)</span></span>
    <span><span class='c'>#&gt;    first   second </span></span>
    <span><span class='c'>#&gt;  "APPLE" "BANANA"</span></span>
    <span></span><span><span class='nf'><a href='https://stringr.tidyverse.org/reference/str_detect.html'>str_detect</a></span><span class='o'>(</span><span class='nv'>x</span>, <span class='s'>"b"</span><span class='o'>)</span></span>
    <span><span class='c'>#&gt;  first second </span></span>
    <span><span class='c'>#&gt;  FALSE   TRUE</span></span>
    <span></span></code></pre>

    </div>

-   A new `vignette("locale-sensitive")` provides detailed information about locale-sensitive functions in stringr, helping you understand how different locales affect string operations like sorting and case conversion.

## Acknowledgements

A big thank you to everyone who contributed to this release! [@alexanderbeatson](https://github.com/alexanderbeatson), [@allenbaron](https://github.com/allenbaron), [@Anaherasm](https://github.com/Anaherasm), [@arnaudgallou](https://github.com/arnaudgallou), [@AustinFournierKL](https://github.com/AustinFournierKL), [@brownj31](https://github.com/brownj31), [@ChristelSwift](https://github.com/ChristelSwift), [@DanChaltiel](https://github.com/DanChaltiel), [@davidciani](https://github.com/davidciani), [@davidhodge931](https://github.com/davidhodge931), [@Edgar-Zamora](https://github.com/Edgar-Zamora), [@edward-burn](https://github.com/edward-burn), [@gaborcsardi](https://github.com/gaborcsardi), [@hadley](https://github.com/hadley), [@jack-davison](https://github.com/jack-davison), [@jdonland](https://github.com/jdonland), [@jeroenjanssens](https://github.com/jeroenjanssens), [@JFormoso](https://github.com/JFormoso), [@jonovik](https://github.com/jonovik), [@KimLopezGuell](https://github.com/KimLopezGuell), [@krlmlr](https://github.com/krlmlr), [@kylieainslie](https://github.com/kylieainslie), [@librill](https://github.com/librill), [@Longfei2](https://github.com/Longfei2), [@LouisMPenrod](https://github.com/LouisMPenrod), [@mararva](https://github.com/mararva), [@mgacc0](https://github.com/mgacc0), [@MiguelCos](https://github.com/MiguelCos), [@nash-delcamp-slp](https://github.com/nash-delcamp-slp), [@ning-y](https://github.com/ning-y), [@Rekyt](https://github.com/Rekyt), [@salim-b](https://github.com/salim-b), [@shaggycamel](https://github.com/shaggycamel), [@SoyAndrea](https://github.com/SoyAndrea), [@tamimart](https://github.com/tamimart), [@tvedebrink](https://github.com/tvedebrink), [@VisruthSK](https://github.com/VisruthSK), [@warnes](https://github.com/warnes), and [@wright13](https://github.com/wright13).

