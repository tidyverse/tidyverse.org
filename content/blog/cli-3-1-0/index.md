---
output: hugodown::hugo_document

slug: cli-3-1-0
title: cli 3.1.0
date: 2021-11-19
author: Gábor Csárdi
description: >
    cli 3.1.0 introduces customizable color palettes plus it
    comes with a number of other smaller improvements. 

photo:
  url: https://www.pexels.com/photo/colorful-hot-air-balloon-3580627
  author: Yumi

# one of: "deep-dive", "learn", "package", "programming", "roundup", or "other"
categories: [package] 
tags: []

editor_options:
  markdown:
    wrap: sentence
rmd_hash: 5ec5e0417073e221
---

We're very chuffed to announce the release of [cli](https://cli.r-lib.org "cli homepage") 3.1.0. cli helps you create a consistent and convenient command line interface.

You can install it from CRAN with:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://rdrr.io/r/utils/install.packages.html'>install.packages</a></span><span class='o'>(</span><span class='s'>"cli"</span><span class='o'>)</span></code></pre>

</div>

This release of cli comes with an important feature for end users: the ability to select or define their preferred palettes. The selected palette is respected by every package that relies on either cli or the crayon package. We also show some other improvements in this post, these are mainly aimed at developers.

You can see a full list of changes in the [release notes](https://github.com/r-lib/cli/releases/tag/v3.1.0).

## Color palettes

### Built-in palettes

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://cli.r-lib.org'>cli</a></span><span class='o'>)</span></code></pre>

</div>

This release of cli adds support for ANSI color customization. Now the 16 foreground colors, created via the `col_*()` functions, and the 16 background colors, created via the `bg_*()` functions, can be customized with the `cli.palette` option.

You can set `cli.palette` to one of the built-in cli palettes, or you can create your own palette. See all built-in palettes at the [cli homepage](https://cli.r-lib.org/articles/palettes.html). You can also look at the `ansi_palettes` object, which is a data frame of RGB colors, with one row for each palette. To look at a single palette, run [`ansi_palette_show()`](https://cli.r-lib.org/reference/ansi_palettes.html). It shows the current palette by default:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://cli.r-lib.org/reference/ansi_palettes.html'>ansi_palette_show</a></span><span class='o'>(</span><span class='o'>)</span></code></pre>

</div>

<div class="highlight">

<img src="figs//default.svg" width="700px" style="display: block; margin: auto;" />

</div>

To use a built-in palette, set `cli.palette` to the palette name. To make this permanent, put this setting into your `.Rprofile`:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://rdrr.io/r/base/options.html'>options</a></span><span class='o'>(</span>cli.palette <span class='o'>=</span> <span class='s'>"dichro"</span><span class='o'>)</span></code></pre>

</div>

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://cli.r-lib.org/reference/ansi_palettes.html'>ansi_palette_show</a></span><span class='o'>(</span><span class='o'>)</span></code></pre>

</div>

<div class="highlight">

<img src="figs//dichro.svg" width="700px" style="display: block; margin: auto;" />

</div>

To set the default palette again, set `cli.palette` to `NULL`:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://rdrr.io/r/base/options.html'>options</a></span><span class='o'>(</span>cli.palette <span class='o'>=</span> <span class='kc'>NULL</span><span class='o'>)</span></code></pre>

</div>

### Custom palettes

To create a custom palette, set the `cli.palette` option to a named list where the names are the same as the column names in `ansi_palettes`. Colors can be specified with RGB color strings of the `#rrggbb` form or R color names (see the output of [`grDevices::colors()`](https://rdrr.io/r/grDevices/colors.html)). For example:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://rdrr.io/r/base/options.html'>options</a></span><span class='o'>(</span>cli.palette <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span>
  black    <span class='o'>=</span> <span class='s'>"#010101"</span>, red        <span class='o'>=</span> <span class='s'>"#de382b"</span>,
  green    <span class='o'>=</span> <span class='s'>"#39b54a"</span>, yellow     <span class='o'>=</span> <span class='s'>"#ffc706"</span>,
  blue     <span class='o'>=</span> <span class='s'>"#006fb8"</span>, magenta    <span class='o'>=</span> <span class='s'>"#762671"</span>,
  cyan     <span class='o'>=</span> <span class='s'>"#2cb5e9"</span>, white      <span class='o'>=</span> <span class='s'>"#cccccc"</span>,
  br_black <span class='o'>=</span> <span class='s'>"#808080"</span>, br_red     <span class='o'>=</span> <span class='s'>"#ff0000"</span>, 
  br_green <span class='o'>=</span> <span class='s'>"#00ff00"</span>, br_yellow  <span class='o'>=</span> <span class='s'>"#ffff00"</span>, 
  br_blue  <span class='o'>=</span> <span class='s'>"#0000ff"</span>, br_magenta <span class='o'>=</span> <span class='s'>"#ff00ff"</span>, 
  br_cyan  <span class='o'>=</span> <span class='s'>"#00ffff"</span>, br_white   <span class='o'>=</span> <span class='s'>"#ffffff"</span>
<span class='o'>)</span><span class='o'>)</span></code></pre>

</div>

### Color interpolation

For color palettes your terminal or IDE needs to support at least 256 ANSI colors. On terminals with true color ANSI support cli will use the exact colors, as specified in the `cli.palette` option. On consoles with 256 ANSI colors, e.g. the RStudio console, cli will interpolate the specified colors to the closest ANSI-256 color. This means that the actual output will probably look slightly different from the specified RGB colors on these displays.

### What about the crayon package?

crayon is an older package than cli, with a smaller scope: adding ANSI colors to your display. More than 300 packages use crayon, so to make sure that cli palettes are respected in these packages as well, we added palette support to the latest release of crayon. Specifying the `cli.palette` option changes the colors in cli and in crayon as well, the same way.

This said, cli does have some additional features compared to crayon, e.g. the support of bright colors. Our focus will be on improving the cli package in the future, and crayon will only receive important bug fixes. If you already use both cli and crayon, then it might make sense to completely switch to cli.

### Palettes in terminals

Many modern terminal emulators, e.g. iTerm on macOS, already allow the customization of ANSI colors, and some also support themes with custom ANSI palettes. If you already use this method to customize ANSI colors, then you don't need to set the `cli.palette` option. If you use both terminals and RStudio then you can set it only in RStudio:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='kr'>if</span> <span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/Sys.getenv.html'>Sys.getenv</a></span><span class='o'>(</span><span class='s'>"RSTUDIO"</span><span class='o'>)</span><span class='o'>==</span><span class='s'>"1"</span><span class='o'>)</span> <span class='nf'><a href='https://rdrr.io/r/base/options.html'>options</a></span><span class='o'>(</span>cli.palette <span class='o'>=</span> <span class='s'>"dichro"</span><span class='o'>)</span></code></pre>

</div>

## Other improvements

### Bright ANSI colors

cli now has a new set of functions to create the bright version of the 8 base ANSI colors. The `col_br_*()` functions set the foreground and the `bg_br_*()` functions set the background colors of strings:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'>cli</span><span class='nf'>::</span><span class='nf'><a href='https://cli.r-lib.org/reference/ansi-styles.html'>col_blue</a></span><span class='o'>(</span><span class='s'>"This is blue."</span><span class='o'>)</span>
<span class='nf'>cli</span><span class='nf'>::</span><span class='nf'><a href='https://cli.r-lib.org/reference/ansi-styles.html'>col_br_blue</a></span><span class='o'>(</span><span class='s'>"This is bright blue."</span><span class='o'>)</span></code></pre>

</div>

<div class="highlight">

<img src="figs//bright.svg" width="700px" style="display: block; margin: auto;" />

</div>

### True color ANSI

cli now supports true color ANSI consoles better. Now custom styles made with [`make_ansi_style()`](https://cli.r-lib.org/reference/make_ansi_style.html) will not interpolate the specified color on these displays:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>orange</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://cli.r-lib.org/reference/make_ansi_style.html'>make_ansi_style</a></span><span class='o'>(</span><span class='s'>"#eb6123"</span><span class='o'>)</span>
<span class='nf'>orange</span><span class='o'>(</span><span class='s'>"This will be halloween orange."</span><span class='o'>)</span></code></pre>

</div>

<div class="highlight">

<img src="figs//orange.svg" width="700px" style="display: block; margin: auto;" />

</div>

### Unicode graphemes

cli's `ansi_*()` functions and the new `utf8_*()` functions now handle Unicode graphemes properly. For example [`ansi_nchar()`](https://cli.r-lib.org/reference/ansi_nchar.html) and [`utf8_nchar()`](https://cli.r-lib.org/reference/utf8_nchar.html) count graphemes by default, and [`ansi_substr()`](https://cli.r-lib.org/reference/ansi_substr.html) and [`utf8_substr()`](https://cli.r-lib.org/reference/utf8_substr.html) will break the input strings at grapheme boundaries.

Consider this Unicode grapheme: 👷🏽‍♀️ (female construction worker, medium skin tone). It consists of five Unicode code points:

-   `\U{1f477}`, construction worker,
-   `\U{1f3fd}`, emoji modifier Fitzpatrick type-4, for the skin tone,
-   `\u200d`, zero width joiner,
-   `\u2640`, female sign,
-   `\ufe0f`, variation selector-16, to specify that the preceding character should be displayed as an emoji.

cli functions handle this grapheme properly:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>wrk</span> <span class='o'>&lt;-</span> <span class='s'>"👷🏽‍♀️"</span>
<span class='nf'><a href='https://rdrr.io/r/base/hexmode.html'>as.hexmode</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/utf8Conversion.html'>utf8ToInt</a></span><span class='o'>(</span><span class='nv'>wrk</span><span class='o'>)</span><span class='o'>)</span>
<span class='c'>#&gt; [1] "1f477" "1f3fd" "0200d" "02640" "0fe0f"</span></code></pre>

</div>

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='c'># graphemes by default</span>
<span class='nf'><a href='https://cli.r-lib.org/reference/utf8_nchar.html'>utf8_nchar</a></span><span class='o'>(</span><span class='nv'>wrk</span><span class='o'>)</span>
<span class='c'>#&gt; [1] 1</span>
<span class='c'># code points</span>
<span class='nf'><a href='https://cli.r-lib.org/reference/utf8_nchar.html'>utf8_nchar</a></span><span class='o'>(</span><span class='nv'>wrk</span>, type <span class='o'>=</span> <span class='s'>"codepoints"</span><span class='o'>)</span>
<span class='c'>#&gt; [1] 5</span>
<span class='c'># correct display width</span>
<span class='nf'><a href='https://cli.r-lib.org/reference/utf8_nchar.html'>utf8_nchar</a></span><span class='o'>(</span><span class='nv'>wrk</span>, type <span class='o'>=</span> <span class='s'>"width"</span><span class='o'>)</span>
<span class='c'>#&gt; [1] 2</span></code></pre>

</div>

### Syntax highlight R code

The new [`code_highlight()`](https://cli.r-lib.org/reference/code_highlight.html) function parses and syntax highlights R code using ANSI colors and styles. You can use [`deparse()`](https://rdrr.io/r/base/deparse.html) to highlight the code of an existing function:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://rdrr.io/r/base/writeLines.html'>writeLines</a></span><span class='o'>(</span><span class='nf'><a href='https://cli.r-lib.org/reference/code_highlight.html'>code_highlight</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/deparse.html'>deparse</a></span><span class='o'>(</span><span class='nf'>cli</span><span class='nf'>::</span><span class='nv'><a href='https://cli.r-lib.org/reference/hash_emoji.html'>hash_emoji</a></span><span class='o'>)</span><span class='o'>)</span><span class='o'>)</span></code></pre>

</div>

<div class="highlight">

<img src="figs//code.svg" width="700px" style="display: block; margin: auto;" />

</div>

### Human readable hash functions

Sometimes it is convenient to create a short hash of a string, that is easy to compare to other hashes. The new [`hash_emoji()`](https://cli.r-lib.org/reference/hash_emoji.html) function creates a very short emoji hash of a string. The new [`hash_animal()`](https://cli.r-lib.org/reference/hash_animal.html) function uses a short expression with one or more adjectives and an animal name:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>txt</span> <span class='o'>&lt;-</span> <span class='s'>"Hash this string please!"</span>
<span class='nf'><a href='https://cli.r-lib.org/reference/hash_emoji.html'>hash_emoji</a></span><span class='o'>(</span><span class='nv'>txt</span><span class='o'>)</span><span class='o'>$</span><span class='nv'>hash</span>
<span class='c'>#&gt; [1] "👨‍👩‍👦‍👦🍘😽"</span>
<span class='nf'><a href='https://cli.r-lib.org/reference/hash_emoji.html'>hash_emoji</a></span><span class='o'>(</span><span class='nv'>txt</span><span class='o'>)</span><span class='o'>$</span><span class='nv'>text</span>
<span class='c'>#&gt; [1] "family: man, woman, boy, boy, rice cracker, kissing cat"</span>
<span class='nf'><a href='https://cli.r-lib.org/reference/hash_animal.html'>hash_animal</a></span><span class='o'>(</span><span class='nv'>txt</span><span class='o'>)</span><span class='o'>$</span><span class='nv'>hash</span>
<span class='c'>#&gt; [1] "deadsmooth anaemic bighorn"</span></code></pre>

</div>

If you are using the new version of the [sessioninfo](https://r-lib.github.io/sessioninfo/) package, then you already see an emoji hash on top of the [`sessioninfo::session_info()`](https://r-lib.github.io/sessioninfo/reference/session_info.html) output. This makes trivial to decide if `session_info()` outputs are the same or not, without comparing them line by line.

## Acknowledgements

A big thanks to all 76 contributors who filed issues and contributed code to this and past cli releases:

[@aedobbyn](https://github.com/aedobbyn), [@AkhilGNair](https://github.com/AkhilGNair), [@AlbertRapp](https://github.com/AlbertRapp), [@assignUser](https://github.com/assignUser), [@batpigandme](https://github.com/batpigandme), [@brodieG](https://github.com/brodieG), [@bwiernik](https://github.com/bwiernik), [@cderv](https://github.com/cderv), [@cfhammill](https://github.com/cfhammill), [@cjyetman](https://github.com/cjyetman), [@ColinFay](https://github.com/ColinFay), [@combiz](https://github.com/combiz), [@cpsievert](https://github.com/cpsievert), [@danielvartan](https://github.com/danielvartan), [@datafj](https://github.com/datafj), [@DavisVaughan](https://github.com/DavisVaughan), [@dchiu911](https://github.com/dchiu911), [@dfalbel](https://github.com/dfalbel), [@dgkf](https://github.com/dgkf), [@elinw](https://github.com/elinw), [@flying-sheep](https://github.com/flying-sheep), [@fmichonneau](https://github.com/fmichonneau), [@fmmattioni](https://github.com/fmmattioni), [@gaborcsardi](https://github.com/gaborcsardi), [@gavinsimpson](https://github.com/gavinsimpson), [@GjjvdBurg](https://github.com/GjjvdBurg), [@gregleleu](https://github.com/gregleleu), [@GregorDeCillia](https://github.com/GregorDeCillia), [@gwd999](https://github.com/gwd999), [@hadley](https://github.com/hadley), [@IndrajeetPatil](https://github.com/IndrajeetPatil), [@jennybc](https://github.com/jennybc), [@jimhester](https://github.com/jimhester), [@jonkeane](https://github.com/jonkeane), [@jonocarroll](https://github.com/jonocarroll), [@juniperlsimonis](https://github.com/juniperlsimonis), [@krlmlr](https://github.com/krlmlr), [@lazappi](https://github.com/lazappi), [@leeper](https://github.com/leeper), [@lionel-](https://github.com/lionel-), [@llrs](https://github.com/llrs), [@lorenzwalthert](https://github.com/lorenzwalthert), [@MarkEdmondson1234](https://github.com/MarkEdmondson1234), [@markwsac](https://github.com/markwsac), [@mattfidler](https://github.com/mattfidler), [@matthiaskaeding](https://github.com/matthiaskaeding), [@mgirlich](https://github.com/mgirlich), [@MilesMcBain](https://github.com/MilesMcBain), [@MislavSag](https://github.com/MislavSag), [@mjsteinbaugh](https://github.com/mjsteinbaugh), [@MLopez-Ibanez](https://github.com/MLopez-Ibanez), [@mrcaseb](https://github.com/mrcaseb), [@ms609](https://github.com/ms609), [@nfancy](https://github.com/nfancy), [@nick-komick](https://github.com/nick-komick), [@overmar](https://github.com/overmar), [@pat-s](https://github.com/pat-s), [@paul-sheridan](https://github.com/paul-sheridan), [@QuLogic](https://github.com/QuLogic), [@ramiromagno](https://github.com/ramiromagno), [@rrodrigueznt](https://github.com/rrodrigueznt), [@rundel](https://github.com/rundel), [@salim-b](https://github.com/salim-b), [@sgibb](https://github.com/sgibb), [@ShixiangWang](https://github.com/ShixiangWang), [@sthibaul](https://github.com/sthibaul), [@tentacles-from-outer-space](https://github.com/tentacles-from-outer-space), [@thothal](https://github.com/thothal), [@topepo](https://github.com/topepo), [@torfason](https://github.com/torfason), [@trestletech](https://github.com/trestletech), [@tzakharko](https://github.com/tzakharko), [@wngrtn](https://github.com/wngrtn), [@x1o](https://github.com/x1o), [@yutannihilation](https://github.com/yutannihilation), and [@zachary-foster](https://github.com/zachary-foster).

