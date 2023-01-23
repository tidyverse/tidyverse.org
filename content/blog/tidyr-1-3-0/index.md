---
output: hugodown::hugo_document

slug: tidyr-1-3-0
title: tidyr 1.3.0
date: 2023-01-23
author: Hadley Wickham
description: >
    tidyr 1.3.0 brings a new family of string separating functions,
    along with improvements to `unnest_longer()`, `unnest_wider()`,
    `pivot_longer()`, and `nest()`.

photo:
  url: https://unsplash.com/photos/TEDo1eO8te4
  author: Jan Kopřiva

# one of: "deep-dive", "learn", "package", "programming", "roundup", or "other"
categories: [package] 
tags: [tidyr]
rmd_hash: 783411b400b9183c

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

We're pleased to announce the release of [tidyr](https://tidyr.tidyverse.org) 1.3.0. tidyr provides a set of tools for transforming data frames to and from tidy data, where each variable is a column and each observation is a row. Tidy data is a convention for matching the semantics and structure of your data that makes using the rest of the tidyverse (and many other R packages) much easier.

You can install it from CRAN with:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://rdrr.io/r/utils/install.packages.html'>install.packages</a></span><span class='o'>(</span><span class='s'>"tidyr"</span><span class='o'>)</span></span></code></pre>

</div>

This post highlights the biggest changes in this release:

-   A new family of `separate_*()` functions supersede [`separate()`](https://tidyr.tidyverse.org/reference/separate.html) and [`extract()`](https://tidyr.tidyverse.org/reference/extract.html) and come with useful debugging features.

-   [`unnest_wider()`](https://tidyr.tidyverse.org/reference/unnest_wider.html) and [`unnest_longer()`](https://tidyr.tidyverse.org/reference/unnest_longer.html) gain a bundle of useful improvements.

-   [`pivot_longer()`](https://tidyr.tidyverse.org/reference/pivot_longer.html) gets a new `cols_vary` argument.

-   `nest(.by)` provides a new (and hopefully final) way to create nested datasets.

You should also notice generally improved errors with this release: we check function arguments more aggressively and take care to always report the name of the function that you called, not some internal helper. As usual, you can find a full set of changes in the [release notes](http://github.com/tidyverse/tidyr/releases/tag/v1.3.0).

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://tidyr.tidyverse.org'>tidyr</a></span><span class='o'>)</span></span>
<span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://dplyr.tidyverse.org'>dplyr</a></span>, warn.conflicts <span class='o'>=</span> <span class='kc'>FALSE</span><span class='o'>)</span></span></code></pre>

</div>

## `separate_*()` family of functions

The biggest feature of this release is a new, experimental, family of functions for separating string columns:

|                                  | Make columns                | Make rows                    |
|--------------------------|-----------------------|-----------------------|
| Separate with delimiter          | [`separate_wider_delim()`](https://tidyr.tidyverse.org/reference/separate_wider_delim.html)    | [`separate_longer_delim()`](https://tidyr.tidyverse.org/reference/separate_longer_delim.html)    |
| Separate by position             | [`separate_wider_position()`](https://tidyr.tidyverse.org/reference/separate_wider_delim.html) | [`separate_longer_position()`](https://tidyr.tidyverse.org/reference/separate_longer_delim.html) |
| Separate with regular expression | [`separate_wider_regex()`](https://tidyr.tidyverse.org/reference/separate_wider_delim.html)    |                              |

These functions collectively supersede [`extract()`](https://tidyr.tidyverse.org/reference/extract.html), [`separate()`](https://tidyr.tidyverse.org/reference/separate.html), and [`separate_rows()`](https://tidyr.tidyverse.org/reference/separate_rows.html) because they have more consistent names and arguments, have better performance (thanks to stringr), and provide a new approach for handling problems.

|                                  | Make columns                     | Make rows         |
|---------------------------|---------------------------|-------------------|
| Separate with delimiter          | `separate(sep = string)`         | [`separate_rows()`](https://tidyr.tidyverse.org/reference/separate_rows.html) |
| Separate by position             | `separate(sep = integer vector)` | N/A               |
| Separate with regular expression | [`extract()`](https://tidyr.tidyverse.org/reference/extract.html)                      |                   |

Here I'll focus on the `wider` functions because they generally present the most interesting challenges. Let's start by grabbing some census data with the [tidycensus](https://walker-data.com/tidycensus/) package:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>vt_census</span> <span class='o'>&lt;-</span> <span class='nf'>tidycensus</span><span class='nf'>::</span><span class='nf'><a href='https://walker-data.com/tidycensus/reference/get_decennial.html'>get_decennial</a></span><span class='o'>(</span></span>
<span>  geography <span class='o'>=</span> <span class='s'>"block"</span>,</span>
<span>  state <span class='o'>=</span> <span class='s'>"VT"</span>,</span>
<span>  county <span class='o'>=</span> <span class='s'>"Washington"</span>,</span>
<span>  variables <span class='o'>=</span> <span class='s'>"P1_001N"</span>,</span>
<span>  year <span class='o'>=</span> <span class='m'>2020</span></span>
<span><span class='o'>)</span></span>
<span><span class='c'>#&gt; Getting data from the 2020 decennial Census</span></span>
<span></span><span><span class='c'>#&gt; Using the PL 94-171 Redistricting Data summary file</span></span>
<span></span><span><span class='c'>#&gt; <span style='color: #00BBBB;'>Note: 2020 decennial Census data use differential privacy, a technique that</span></span></span>
<span><span class='c'><span style='color: #00BBBB;'>#&gt; introduces errors into data to preserve respondent confidentiality.</span></span></span>
<span><span class='c'>#&gt; <span style='color: #0000BB;'>ℹ</span> <span style='color: #BB00BB;'>Small counts should be interpreted with caution.</span></span></span>
<span><span class='c'>#&gt; <span style='color: #0000BB;'>ℹ</span> <span style='color: #BB00BB;'>See https://www.census.gov/library/fact-sheets/2021/protecting-the-confidentiality-of-the-2020-census-redistricting-data.html for additional guidance.</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>This message is displayed once per session.</span></span></span>
<span></span><span><span class='nv'>vt_census</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 2,150 × 4</span></span></span>
<span><span class='c'>#&gt;    <span style='font-weight: bold;'>GEOID</span>           <span style='font-weight: bold;'>NAME</span>                                           <span style='font-weight: bold;'>variable</span> <span style='font-weight: bold;'>value</span></span></span>
<span><span class='c'>#&gt;    <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>           <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>                                          <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>    <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 1</span> 500239555021014 Block 1014, Block Group 1, Census Tract 9555.… P1_001N     21</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 2</span> 500239555021015 Block 1015, Block Group 1, Census Tract 9555.… P1_001N     19</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 3</span> 500239555021016 Block 1016, Block Group 1, Census Tract 9555.… P1_001N      0</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 4</span> 500239555021017 Block 1017, Block Group 1, Census Tract 9555.… P1_001N      0</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 5</span> 500239555021018 Block 1018, Block Group 1, Census Tract 9555.… P1_001N     43</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 6</span> 500239555021019 Block 1019, Block Group 1, Census Tract 9555.… P1_001N     68</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 7</span> 500239555021020 Block 1020, Block Group 1, Census Tract 9555.… P1_001N     30</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 8</span> 500239555021021 Block 1021, Block Group 1, Census Tract 9555.… P1_001N      0</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 9</span> 500239555021022 Block 1022, Block Group 1, Census Tract 9555.… P1_001N     18</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>10</span> 500239555021023 Block 1023, Block Group 1, Census Tract 9555.… P1_001N     93</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># … with 2,140 more rows</span></span></span>
<span></span></code></pre>

</div>

The `GEOID` column is made up of four components: a 2 digit state identifier, a 3 digit county identifier, a 6 digit tract identifier, and a 4 digit block identifier. We could use [`separate_wider_position()`](https://tidyr.tidyverse.org/reference/separate_wider_delim.html) to extract these into their own variables:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>vt_census</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/select.html'>select</a></span><span class='o'>(</span><span class='nv'>GEOID</span><span class='o'>)</span> <span class='o'>|&gt;</span> </span>
<span>  <span class='nf'><a href='https://tidyr.tidyverse.org/reference/separate_wider_delim.html'>separate_wider_position</a></span><span class='o'>(</span></span>
<span>    <span class='nv'>GEOID</span>,</span>
<span>    widths <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span>state <span class='o'>=</span> <span class='m'>2</span>, county <span class='o'>=</span> <span class='m'>3</span>, tract <span class='o'>=</span> <span class='m'>6</span>, block <span class='o'>=</span> <span class='m'>4</span><span class='o'>)</span></span>
<span>  <span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 2,150 × 4</span></span></span>
<span><span class='c'>#&gt;    <span style='font-weight: bold;'>state</span> <span style='font-weight: bold;'>county</span> <span style='font-weight: bold;'>tract</span>  <span style='font-weight: bold;'>block</span></span></span>
<span><span class='c'>#&gt;    <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>  <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>  <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 1</span> 50    023    955502 1014 </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 2</span> 50    023    955502 1015 </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 3</span> 50    023    955502 1016 </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 4</span> 50    023    955502 1017 </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 5</span> 50    023    955502 1018 </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 6</span> 50    023    955502 1019 </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 7</span> 50    023    955502 1020 </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 8</span> 50    023    955502 1021 </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 9</span> 50    023    955502 1022 </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>10</span> 50    023    955502 1023 </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># … with 2,140 more rows</span></span></span>
<span></span></code></pre>

</div>

The `name` column contains this same information in a text form, with each component separated by a comma. We can use [`separate_wider_delim()`](https://tidyr.tidyverse.org/reference/separate_wider_delim.html) to break up this sort of data into individual variables:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>vt_census</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/select.html'>select</a></span><span class='o'>(</span><span class='nv'>NAME</span><span class='o'>)</span> <span class='o'>|&gt;</span> </span>
<span>  <span class='nf'><a href='https://tidyr.tidyverse.org/reference/separate_wider_delim.html'>separate_wider_delim</a></span><span class='o'>(</span></span>
<span>    <span class='nv'>NAME</span>,</span>
<span>    delim <span class='o'>=</span> <span class='s'>", "</span>,</span>
<span>    names <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"block"</span>, <span class='s'>"block_group"</span>, <span class='s'>"tract"</span>, <span class='s'>"county"</span>, <span class='s'>"state"</span><span class='o'>)</span></span>
<span>  <span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 2,150 × 5</span></span></span>
<span><span class='c'>#&gt;    <span style='font-weight: bold;'>block</span>      <span style='font-weight: bold;'>block_group</span>   <span style='font-weight: bold;'>tract</span>                <span style='font-weight: bold;'>county</span>            <span style='font-weight: bold;'>state</span>  </span></span>
<span><span class='c'>#&gt;    <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>      <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>         <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>                <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>             <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>  </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 1</span> Block 1014 Block Group 1 Census Tract 9555.02 Washington County Vermont</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 2</span> Block 1015 Block Group 1 Census Tract 9555.02 Washington County Vermont</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 3</span> Block 1016 Block Group 1 Census Tract 9555.02 Washington County Vermont</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 4</span> Block 1017 Block Group 1 Census Tract 9555.02 Washington County Vermont</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 5</span> Block 1018 Block Group 1 Census Tract 9555.02 Washington County Vermont</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 6</span> Block 1019 Block Group 1 Census Tract 9555.02 Washington County Vermont</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 7</span> Block 1020 Block Group 1 Census Tract 9555.02 Washington County Vermont</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 8</span> Block 1021 Block Group 1 Census Tract 9555.02 Washington County Vermont</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 9</span> Block 1022 Block Group 1 Census Tract 9555.02 Washington County Vermont</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>10</span> Block 1023 Block Group 1 Census Tract 9555.02 Washington County Vermont</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># … with 2,140 more rows</span></span></span>
<span></span></code></pre>

</div>

You'll notice that each row contains a lot of duplicated information ("Block", "Block Group", ...). You could certainly use [`mutate()`](https://dplyr.tidyverse.org/reference/mutate.html) and string manipulation to clean this up, but there's a more direct approach that you can use if you're familiar with regular expressions. The new [`separate_wider_regex()`](https://tidyr.tidyverse.org/reference/separate_wider_delim.html) takes a vector of regular expressions that are matched in order, from left to right. If you name the regular expression, it will appear in the output; otherwise, it will be dropped. I think this leads to a particularly elegant solution to many problems.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>vt_census</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/select.html'>select</a></span><span class='o'>(</span><span class='nv'>NAME</span><span class='o'>)</span> <span class='o'>|&gt;</span> </span>
<span>  <span class='nf'><a href='https://tidyr.tidyverse.org/reference/separate_wider_delim.html'>separate_wider_regex</a></span><span class='o'>(</span></span>
<span>    <span class='nv'>NAME</span>,</span>
<span>    patterns <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span></span>
<span>      <span class='s'>"Block "</span>, block <span class='o'>=</span> <span class='s'>"\\d+"</span>, <span class='s'>", "</span>,</span>
<span>      <span class='s'>"Block Group "</span>, block_group <span class='o'>=</span> <span class='s'>"\\d+"</span>, <span class='s'>", "</span>,</span>
<span>      <span class='s'>"Census Tract "</span>, tract <span class='o'>=</span> <span class='s'>"\\d+.\\d+"</span>, <span class='s'>", "</span>,</span>
<span>      county <span class='o'>=</span> <span class='s'>"[^,]+"</span>, <span class='s'>", "</span>,</span>
<span>      state <span class='o'>=</span> <span class='s'>".*"</span></span>
<span>    <span class='o'>)</span></span>
<span>  <span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 2,150 × 5</span></span></span>
<span><span class='c'>#&gt;    <span style='font-weight: bold;'>block</span> <span style='font-weight: bold;'>block_group</span> <span style='font-weight: bold;'>tract</span>   <span style='font-weight: bold;'>county</span>            <span style='font-weight: bold;'>state</span>  </span></span>
<span><span class='c'>#&gt;    <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>       <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>   <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>             <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>  </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 1</span> 1014  1           9555.02 Washington County Vermont</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 2</span> 1015  1           9555.02 Washington County Vermont</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 3</span> 1016  1           9555.02 Washington County Vermont</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 4</span> 1017  1           9555.02 Washington County Vermont</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 5</span> 1018  1           9555.02 Washington County Vermont</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 6</span> 1019  1           9555.02 Washington County Vermont</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 7</span> 1020  1           9555.02 Washington County Vermont</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 8</span> 1021  1           9555.02 Washington County Vermont</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 9</span> 1022  1           9555.02 Washington County Vermont</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>10</span> 1023  1           9555.02 Washington County Vermont</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># … with 2,140 more rows</span></span></span>
<span></span></code></pre>

</div>

These functions also have a new way to report problems. Let's start with a very simple example:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>df</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://tibble.tidyverse.org/reference/tibble.html'>tibble</a></span><span class='o'>(</span></span>
<span>  id <span class='o'>=</span> <span class='m'>1</span><span class='o'>:</span><span class='m'>3</span>,</span>
<span>  x <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"a"</span>, <span class='s'>"a-b"</span>, <span class='s'>"a-b-c"</span><span class='o'>)</span></span>
<span><span class='o'>)</span></span>
<span></span>
<span><span class='nv'>df</span> <span class='o'>|&gt;</span> <span class='nf'><a href='https://tidyr.tidyverse.org/reference/separate_wider_delim.html'>separate_wider_delim</a></span><span class='o'>(</span><span class='nv'>x</span>, delim <span class='o'>=</span> <span class='s'>"-"</span>, names <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"x"</span>, <span class='s'>"y"</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #BBBB00; font-weight: bold;'>Error</span><span style='font-weight: bold;'> in `separate_wider_delim()`:</span></span></span>
<span><span class='c'>#&gt; <span style='color: #BBBB00;'>!</span> Expected 2 pieces in each element of `x`.</span></span>
<span><span class='c'>#&gt; <span style='color: #BBBB00;'>!</span> 1 value was too short.</span></span>
<span><span class='c'>#&gt; <span style='color: #00BBBB;'>ℹ</span> Use `too_few = "debug"` to diagnose the problem.</span></span>
<span><span class='c'>#&gt; <span style='color: #00BBBB;'>ℹ</span> Use `too_few = "align_start"/"align_end"` to silence this message.</span></span>
<span><span class='c'>#&gt; <span style='color: #BBBB00;'>!</span> 1 value was too long.</span></span>
<span><span class='c'>#&gt; <span style='color: #00BBBB;'>ℹ</span> Use `too_many = "debug"` to diagnose the problem.</span></span>
<span><span class='c'>#&gt; <span style='color: #00BBBB;'>ℹ</span> Use `too_many = "drop"/"merge"` to silence this message.</span></span>
<span></span></code></pre>

</div>

We've requested two columns in the output (`x` and `y`), but the first row has only one element and the last row has three elements, so [`separate_wider_delim()`](https://tidyr.tidyverse.org/reference/separate_wider_delim.html) can't do what we've asked. The error lays out your options for resolving the problem using the `too_few` and `too_many` arguments. I'd recommend always starting with `"debug"` to get more information about the problem:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>probs</span> <span class='o'>&lt;-</span> <span class='nv'>df</span> <span class='o'>|&gt;</span> </span>
<span>  <span class='nf'><a href='https://tidyr.tidyverse.org/reference/separate_wider_delim.html'>separate_wider_delim</a></span><span class='o'>(</span></span>
<span>    <span class='nv'>x</span>,</span>
<span>    delim <span class='o'>=</span> <span class='s'>"-"</span>,</span>
<span>    names <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"a"</span>, <span class='s'>"b"</span><span class='o'>)</span>,</span>
<span>    too_few <span class='o'>=</span> <span class='s'>"debug"</span>,</span>
<span>    too_many <span class='o'>=</span> <span class='s'>"debug"</span></span>
<span>  <span class='o'>)</span></span>
<span><span class='c'>#&gt; Warning: Debug mode activated: adding variables `x_ok`, `x_pieces`, and `x_remainder`.</span></span>
<span></span><span><span class='nv'>probs</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 3 × 7</span></span></span>
<span><span class='c'>#&gt;      <span style='font-weight: bold;'>id</span> <span style='font-weight: bold;'>a</span>     <span style='font-weight: bold;'>b</span>     <span style='font-weight: bold;'>x</span>     <span style='font-weight: bold;'>x_ok</span>  <span style='font-weight: bold;'>x_pieces</span> <span style='font-weight: bold;'>x_remainder</span></span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;int&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;lgl&gt;</span>    <span style='color: #555555; font-style: italic;'>&lt;int&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>      </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span>     1 a     <span style='color: #BB0000;'>NA</span>    a     FALSE        1 <span style='color: #555555;'>""</span>         </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span>     2 a     b     a-b   TRUE         2 <span style='color: #555555;'>""</span>         </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>3</span>     3 a     b     a-b-c FALSE        3 <span style='color: #555555;'>"</span>-c<span style='color: #555555;'>"</span></span></span>
<span></span></code></pre>

</div>

This adds three new variables: `x_ok` tells you if the `x` could be separated as you requested, `x_pieces` tells you the actual number of pieces, and `x_remainder` shows you anything that remains after the columns you asked for. You can use this information to fix the problems in the input, or you can use the other options to `too_few` and `too_many` to tell [`separate_wider_delim()`](https://tidyr.tidyverse.org/reference/separate_wider_delim.html) to fix them for you:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>df</span> <span class='o'>|&gt;</span> </span>
<span>  <span class='nf'><a href='https://tidyr.tidyverse.org/reference/separate_wider_delim.html'>separate_wider_delim</a></span><span class='o'>(</span></span>
<span>    <span class='nv'>x</span>,</span>
<span>    delim <span class='o'>=</span> <span class='s'>"-"</span>,</span>
<span>    names <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"a"</span>, <span class='s'>"b"</span><span class='o'>)</span>,</span>
<span>    too_few <span class='o'>=</span> <span class='s'>"align_start"</span>,</span>
<span>    too_many <span class='o'>=</span> <span class='s'>"drop"</span></span>
<span>  <span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 3 × 3</span></span></span>
<span><span class='c'>#&gt;      <span style='font-weight: bold;'>id</span> <span style='font-weight: bold;'>a</span>     <span style='font-weight: bold;'>b</span>    </span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;int&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span>     1 a     <span style='color: #BB0000;'>NA</span>   </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span>     2 a     b    </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>3</span>     3 a     b</span></span>
<span></span></code></pre>

</div>

`too_few` and `too_many` also work with [`separate_wider_position()`](https://tidyr.tidyverse.org/reference/separate_wider_delim.html), and `too_few` works with [`separate_wider_regex()`](https://tidyr.tidyverse.org/reference/separate_wider_delim.html). The longer variants don't need these arguments because varying numbers of rows don't matter in the same way that varying numbers of columns do:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>df</span> <span class='o'>|&gt;</span> <span class='nf'><a href='https://tidyr.tidyverse.org/reference/separate_longer_delim.html'>separate_longer_delim</a></span><span class='o'>(</span><span class='nv'>x</span>, delim <span class='o'>=</span> <span class='s'>"-"</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 6 × 2</span></span></span>
<span><span class='c'>#&gt;      <span style='font-weight: bold;'>id</span> <span style='font-weight: bold;'>x</span>    </span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;int&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span>     1 a    </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span>     2 a    </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>3</span>     2 b    </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>4</span>     3 a    </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>5</span>     3 b    </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>6</span>     3 c</span></span>
<span></span></code></pre>

</div>

These functions are still experimental so we are actively seeking feedback. Please try them out and let us know if you find them useful or if there are other features you'd like to see.

## `unnest_wider()` and `unnest_longer()` improvements

[`unnest_longer()`](https://tidyr.tidyverse.org/reference/unnest_longer.html) and [`unnest_wider()`](https://tidyr.tidyverse.org/reference/unnest_wider.html) have both received some quality of life and consistency improvements. Most importantly:

-   [`unnest_wider()`](https://tidyr.tidyverse.org/reference/unnest_wider.html) now gives a better error when unnesting an unnamed vector:

    <div class="highlight">

    <pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>df</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://tibble.tidyverse.org/reference/tibble.html'>tibble</a></span><span class='o'>(</span></span>
    <span>  id <span class='o'>=</span> <span class='m'>1</span><span class='o'>:</span><span class='m'>2</span>,</span>
    <span>  x <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"a"</span>, <span class='s'>"b"</span><span class='o'>)</span>, <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"d"</span>, <span class='s'>"e"</span>, <span class='s'>"f"</span><span class='o'>)</span><span class='o'>)</span></span>
    <span><span class='o'>)</span></span>
    <span><span class='nv'>df</span> <span class='o'>|&gt;</span> </span>
    <span>  <span class='nf'><a href='https://tidyr.tidyverse.org/reference/unnest_wider.html'>unnest_wider</a></span><span class='o'>(</span><span class='nv'>x</span><span class='o'>)</span></span>
    <span><span class='c'>#&gt; <span style='color: #BBBB00; font-weight: bold;'>Error</span><span style='font-weight: bold;'> in `unnest_wider()`:</span></span></span>
    <span><span class='c'>#&gt; <span style='color: #00BBBB;'>ℹ</span> In column: `x`.</span></span>
    <span><span class='c'>#&gt; <span style='color: #00BBBB;'>ℹ</span> In row: 1.</span></span>
    <span><span class='c'>#&gt; <span style='font-weight: bold;'>Caused by error:</span></span></span>
    <span><span class='c'>#&gt; <span style='color: #BBBB00;'>!</span> Can't unnest elements with missing names.</span></span>
    <span><span class='c'>#&gt; <span style='color: #00BBBB;'>ℹ</span> Supply `names_sep` to generate automatic names.</span></span>
    <span></span><span></span>
    <span><span class='nv'>df</span> <span class='o'>|&gt;</span> </span>
    <span>  <span class='nf'><a href='https://tidyr.tidyverse.org/reference/unnest_wider.html'>unnest_wider</a></span><span class='o'>(</span><span class='nv'>x</span>, names_sep <span class='o'>=</span> <span class='s'>"_"</span><span class='o'>)</span></span>
    <span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 2 × 4</span></span></span>
    <span><span class='c'>#&gt;      <span style='font-weight: bold;'>id</span> <span style='font-weight: bold;'>x_1</span>   <span style='font-weight: bold;'>x_2</span>   <span style='font-weight: bold;'>x_3</span>  </span></span>
    <span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;int&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span></span></span>
    <span><span class='c'>#&gt; <span style='color: #555555;'>1</span>     1 a     b     <span style='color: #BB0000;'>NA</span>   </span></span>
    <span><span class='c'>#&gt; <span style='color: #555555;'>2</span>     2 d     e     f</span></span>
    <span></span></code></pre>

    </div>

    And this same behaviour now also applies to partially named vectors.

-   [`unnest_longer()`](https://tidyr.tidyverse.org/reference/unnest_longer.html) has gained a `keep_empty` argument like [`unnest()`](https://tidyr.tidyverse.org/reference/unnest.html), and it now treats `NULL` and empty vectors the same way:

    <div class="highlight">

    <pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>df</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://tibble.tidyverse.org/reference/tibble.html'>tibble</a></span><span class='o'>(</span></span>
    <span>  id <span class='o'>=</span> <span class='m'>1</span><span class='o'>:</span><span class='m'>3</span>,</span>
    <span>  x <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span><span class='kc'>NULL</span>, <span class='nf'><a href='https://rdrr.io/r/base/integer.html'>integer</a></span><span class='o'>(</span><span class='o'>)</span>, <span class='m'>1</span><span class='o'>:</span><span class='m'>3</span><span class='o'>)</span></span>
    <span><span class='o'>)</span></span>
    <span></span>
    <span><span class='nv'>df</span> <span class='o'>|&gt;</span> <span class='nf'><a href='https://tidyr.tidyverse.org/reference/unnest_longer.html'>unnest_longer</a></span><span class='o'>(</span><span class='nv'>x</span><span class='o'>)</span></span>
    <span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 3 × 2</span></span></span>
    <span><span class='c'>#&gt;      <span style='font-weight: bold;'>id</span>     <span style='font-weight: bold;'>x</span></span></span>
    <span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;int&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;int&gt;</span></span></span>
    <span><span class='c'>#&gt; <span style='color: #555555;'>1</span>     3     1</span></span>
    <span><span class='c'>#&gt; <span style='color: #555555;'>2</span>     3     2</span></span>
    <span><span class='c'>#&gt; <span style='color: #555555;'>3</span>     3     3</span></span>
    <span></span><span><span class='nv'>df</span> <span class='o'>|&gt;</span> <span class='nf'><a href='https://tidyr.tidyverse.org/reference/unnest_longer.html'>unnest_longer</a></span><span class='o'>(</span><span class='nv'>x</span>, keep_empty <span class='o'>=</span> <span class='kc'>TRUE</span><span class='o'>)</span></span>
    <span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 5 × 2</span></span></span>
    <span><span class='c'>#&gt;      <span style='font-weight: bold;'>id</span>     <span style='font-weight: bold;'>x</span></span></span>
    <span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;int&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;int&gt;</span></span></span>
    <span><span class='c'>#&gt; <span style='color: #555555;'>1</span>     1    <span style='color: #BB0000;'>NA</span></span></span>
    <span><span class='c'>#&gt; <span style='color: #555555;'>2</span>     2    <span style='color: #BB0000;'>NA</span></span></span>
    <span><span class='c'>#&gt; <span style='color: #555555;'>3</span>     3     1</span></span>
    <span><span class='c'>#&gt; <span style='color: #555555;'>4</span>     3     2</span></span>
    <span><span class='c'>#&gt; <span style='color: #555555;'>5</span>     3     3</span></span>
    <span></span></code></pre>

    </div>

## `pivot_longer(cols_vary)`

By default, [`pivot_longer()`](https://tidyr.tidyverse.org/reference/pivot_longer.html) creates its output row-by-row:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>df</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://tibble.tidyverse.org/reference/tibble.html'>tibble</a></span><span class='o'>(</span></span>
<span>  x <span class='o'>=</span> <span class='m'>1</span><span class='o'>:</span><span class='m'>2</span>,</span>
<span>  y <span class='o'>=</span> <span class='m'>3</span><span class='o'>:</span><span class='m'>4</span>,</span>
<span>  z <span class='o'>=</span> <span class='m'>5</span><span class='o'>:</span><span class='m'>6</span></span>
<span><span class='o'>)</span></span>
<span></span>
<span><span class='nv'>df</span> <span class='o'>|&gt;</span> </span>
<span>  <span class='nf'><a href='https://tidyr.tidyverse.org/reference/pivot_longer.html'>pivot_longer</a></span><span class='o'>(</span></span>
<span>    <span class='nf'><a href='https://tidyselect.r-lib.org/reference/everything.html'>everything</a></span><span class='o'>(</span><span class='o'>)</span>,</span>
<span>    names_to <span class='o'>=</span> <span class='s'>"name"</span>,</span>
<span>    values_to <span class='o'>=</span> <span class='s'>"value"</span></span>
<span>  <span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 6 × 2</span></span></span>
<span><span class='c'>#&gt;   <span style='font-weight: bold;'>name</span>  <span style='font-weight: bold;'>value</span></span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;int&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span> x         1</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span> y         3</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>3</span> z         5</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>4</span> x         2</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>5</span> y         4</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>6</span> z         6</span></span>
<span></span></code></pre>

</div>

You can now request to create the output column-by-column with `cols_vary = "slowest":`

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>df</span> <span class='o'>|&gt;</span> </span>
<span>  <span class='nf'><a href='https://tidyr.tidyverse.org/reference/pivot_longer.html'>pivot_longer</a></span><span class='o'>(</span></span>
<span>    <span class='nf'><a href='https://tidyselect.r-lib.org/reference/everything.html'>everything</a></span><span class='o'>(</span><span class='o'>)</span>,</span>
<span>    names_to <span class='o'>=</span> <span class='s'>"name"</span>,</span>
<span>    values_to <span class='o'>=</span> <span class='s'>"value"</span>,</span>
<span>    cols_vary <span class='o'>=</span> <span class='s'>"slowest"</span></span>
<span>  <span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 6 × 2</span></span></span>
<span><span class='c'>#&gt;   <span style='font-weight: bold;'>name</span>  <span style='font-weight: bold;'>value</span></span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;int&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span> x         1</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span> x         2</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>3</span> y         3</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>4</span> y         4</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>5</span> z         5</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>6</span> z         6</span></span>
<span></span></code></pre>

</div>

## `nest(.by)`

A nested data frame is a data frame where one (or more) columns is a list of data frames. Nested data frames are a powerful tool that allow you to turn groups into rows and can facilitate certain types of data manipulation that would be very tricky otherwise. (One place to learn more about them is my 2016 talk "[Managing many models with R](https://www.youtube.com/watch?v=rz3_FDVt9eg)".)

Over the years we've made a number of attempts at getting the correct interface for nesting, including [`tidyr::nest()`](https://tidyr.tidyverse.org/reference/nest.html), [`dplyr::nest_by()`](https://dplyr.tidyverse.org/reference/nest_by.html), and [`dplyr::group_nest()`](https://dplyr.tidyverse.org/reference/group_nest.html). In this version of tidyr we've taken one more stab at it by adding a new argument to [`nest()`](https://tidyr.tidyverse.org/reference/nest.html): `.by`, inspired by the upcoming [dplyr 1.1.0](https://www.tidyverse.org/blog/2022/11/dplyr-1-1-0-is-coming-soon/) release. This means that [`nest()`](https://tidyr.tidyverse.org/reference/nest.html) now allows you to specify the variables you want to nest by as an alternative to specifying the variables that appear in the nested data.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='c'># Specify what to nest by</span></span>
<span><span class='nv'>mtcars</span> <span class='o'>|&gt;</span> </span>
<span>  <span class='nf'><a href='https://tidyr.tidyverse.org/reference/nest.html'>nest</a></span><span class='o'>(</span>.by <span class='o'>=</span> <span class='nv'>cyl</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 3 × 2</span></span></span>
<span><span class='c'>#&gt;     <span style='font-weight: bold;'>cyl</span> <span style='font-weight: bold;'>data</span>              </span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;list&gt;</span>            </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span>     6 <span style='color: #555555;'>&lt;tibble [7 × 10]&gt;</span> </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span>     4 <span style='color: #555555;'>&lt;tibble [11 × 10]&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>3</span>     8 <span style='color: #555555;'>&lt;tibble [14 × 10]&gt;</span></span></span>
<span></span><span></span>
<span><span class='c'># Specify what should be nested</span></span>
<span><span class='nv'>mtcars</span> <span class='o'>|&gt;</span> </span>
<span>  <span class='nf'><a href='https://tidyr.tidyverse.org/reference/nest.html'>nest</a></span><span class='o'>(</span>data <span class='o'>=</span> <span class='o'>-</span><span class='nv'>cyl</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 3 × 2</span></span></span>
<span><span class='c'>#&gt;     <span style='font-weight: bold;'>cyl</span> <span style='font-weight: bold;'>data</span>              </span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;list&gt;</span>            </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span>     6 <span style='color: #555555;'>&lt;tibble [7 × 10]&gt;</span> </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span>     4 <span style='color: #555555;'>&lt;tibble [11 × 10]&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>3</span>     8 <span style='color: #555555;'>&lt;tibble [14 × 10]&gt;</span></span></span>
<span></span><span></span>
<span><span class='c'># Specify both (to drop variables)</span></span>
<span><span class='nv'>mtcars</span> <span class='o'>|&gt;</span> </span>
<span>  <span class='nf'><a href='https://tidyr.tidyverse.org/reference/nest.html'>nest</a></span><span class='o'>(</span>data <span class='o'>=</span> <span class='nv'>mpg</span><span class='o'>:</span><span class='nv'>drat</span>, .by <span class='o'>=</span> <span class='nv'>cyl</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 3 × 2</span></span></span>
<span><span class='c'>#&gt;     <span style='font-weight: bold;'>cyl</span> <span style='font-weight: bold;'>data</span>             </span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;list&gt;</span>           </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span>     6 <span style='color: #555555;'>&lt;tibble [7 × 5]&gt;</span> </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span>     4 <span style='color: #555555;'>&lt;tibble [11 × 5]&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>3</span>     8 <span style='color: #555555;'>&lt;tibble [14 × 5]&gt;</span></span></span>
<span></span></code></pre>

</div>

If this function is all we hope it to be, we're likely to supersede [`dplyr::nest_by()`](https://dplyr.tidyverse.org/reference/nest_by.html) and [`dplyr::group_nest()`](https://dplyr.tidyverse.org/reference/group_nest.html) in the future. This has the nice property of placing the functions for nesting and unnesting in the same package (tidyr).

## Acknowledgements

A big thanks to all 51 contributors who helped make this release possible, by writing code and documentating, asking questions, and reporting bugs! [@AdrianS85](https://github.com/AdrianS85), [@ahcyip](https://github.com/ahcyip), [@allenbaron](https://github.com/allenbaron), [@AnBarbosaBr](https://github.com/AnBarbosaBr), [@ArthurAndrews](https://github.com/ArthurAndrews), [@bart1](https://github.com/bart1), [@billdenney](https://github.com/billdenney), [@bknakker](https://github.com/bknakker), [@bwiernik](https://github.com/bwiernik), [@crissthiandi](https://github.com/crissthiandi), [@daattali](https://github.com/daattali), [@DavisVaughan](https://github.com/DavisVaughan), [@dcaud](https://github.com/dcaud), [@DSLituiev](https://github.com/DSLituiev), [@elgabbas](https://github.com/elgabbas), [@fabiangehring](https://github.com/fabiangehring), [@hadley](https://github.com/hadley), [@ilikegitlab](https://github.com/ilikegitlab), [@jennybc](https://github.com/jennybc), [@jic007](https://github.com/jic007), [@Joao-O-Santos](https://github.com/Joao-O-Santos), [@joeycouse](https://github.com/joeycouse), [@jonspring](https://github.com/jonspring), [@kevinushey](https://github.com/kevinushey), [@krlmlr](https://github.com/krlmlr), [@lionel-](https://github.com/lionel-), [@lotard](https://github.com/lotard), [@lschneiderbauer](https://github.com/lschneiderbauer), [@lucylgao](https://github.com/lucylgao), [@markfairbanks](https://github.com/markfairbanks), [@martina-starc](https://github.com/martina-starc), [@MatthieuStigler](https://github.com/MatthieuStigler), [@mattnolan001](https://github.com/mattnolan001), [@mattroumaya](https://github.com/mattroumaya), [@mdkrause](https://github.com/mdkrause), [@mgirlich](https://github.com/mgirlich), [@millermc38](https://github.com/millermc38), [@modche](https://github.com/modche), [@moodymudskipper](https://github.com/moodymudskipper), [@mspittler](https://github.com/mspittler), [@olivroy](https://github.com/olivroy), [@piokol23](https://github.com/piokol23), [@ppreshant](https://github.com/ppreshant), [@ramiromagno](https://github.com/ramiromagno), [@Rengervn](https://github.com/Rengervn), [@rjake](https://github.com/rjake), [@roohitk](https://github.com/roohitk), [@struckma](https://github.com/struckma), [@tjmahr](https://github.com/tjmahr), [@weirichs](https://github.com/weirichs), and [@wurli](https://github.com/wurli).

