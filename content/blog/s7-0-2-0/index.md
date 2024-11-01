---
output: hugodown::hugo_document

slug: s7-0-2-0
title: S7 0.2.0
date: 2024-10-30
author: Tomasz Kalinowski and Hadley Wickham
description: >
    S7 is a new package that simplifies object-oriented programming (OOP) in R. 
    It combines the simplicity of S3 with the structure of S4 to create a 
    clearer system that's accessible to everyone.

# photo: from Tomasz's iPhone

# one of: "deep-dive", "learn", "package", "programming", "roundup", or "other"
categories: [package] 
tags: []
rmd_hash: 3492a079747cbfde

---

<!--
TODO:
* [ ] Look over / edit the post's title in the yaml
* [ ] Edit (or delete) the description; note this appears in the Twitter card
* [ ] Pick category and tags (see existing with [`hugodown::tidy_show_meta()`](https://rdrr.io/pkg/hugodown/man/use_tidy_post.html))
* [ ] Find photo & update yaml metadata
* [ ] Create `thumbnail-sq.jpg`; height and width should be equal
* [ ] Create `thumbnail-wd.jpg`; width should be >5x height
* [ ] [`hugodown::use_tidy_thumbnails()`](https://rdrr.io/pkg/hugodown/man/use_tidy_post.html)
* [ ] Add intro sentence, e.g. the standard tagline for the package
* [ ] [`usethis::use_tidy_thanks()`](https://usethis.r-lib.org/reference/use_tidy_thanks.html)
-->

We're excited to announce that [S7](https://rconsortium.github.io/S7/) v0.2.0 is now available on CRAN! S7 is a new object-oriented programming (OOP) system designed to superceed both S3 and S4. You might wonder why R needs a new OOP system when we already have two. The reason lies in the history of R's OOP journey: S3 is a simple and effective system for single dispatch, while S4 adds formal class definitions and multiple dispatch, but at the cost of complexity. This has forced developers to choose between the simplicity of S3 and the sophistication of S4.

The goal of S7 is to unify the OOP landscape by building on S3's existing dispatch system and incorporating the most useful features of S4 (along with some new ones), all with a simpler syntax. S7's design and implementation have been a collaborative effort by a working group from the [R Consortium](https://www.r-consortium.org), including representatives from R-Core, Bioconductor, tidyverse/Posit, ROpenSci, and the wider R community. Since S7 builds on S3, it is fully compatible with existing S3-based code. It's also been thoughtfully designed to work with S4, and as we learn more about the challenges of transitioning from S4 to S7, we'll continue to add features to ease this process.

Our long-term goal is to include S7 in base R, but for now, you can install it from CRAN:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://rdrr.io/r/utils/install.packages.html'>install.packages</a></span><span class='o'>(</span><span class='s'>"S7"</span><span class='o'>)</span></span></code></pre>

</div>

## What's new in the second release

The second release of S7 brings refinements and bug fixes. Highlights include:

-   Support for lazy property defaults, making class setup more flexible.
-   Custom property setters now run on object initialization.
-   Significant speed improvements for setting and getting properties with `@` and `@<-`.
-   Expanded compatibility with base S3 classes.
-   [`convert()`](https://rconsortium.github.io/S7/reference/convert.html) now provides a default method for transforming a parent class into a subclass.

Additionally, there are numerous bug fixes and quality-of-life improvements, such as better error messages, improved support for base Ops methods, and compatibility improvements for using `@` in R versions prior to 4.3. You can see a full list of changes in the [release notes](https://github.com/RConsortium/S7/blob/main/NEWS.md).

## Who should use S7

S7 is a great fit for R users who like to try new things but don't need to be the first. It's already used in several CRAN packages, and the tidyverse team is applying it in new projects. While you may still run into a few issues, many early problems have been resolved.

## Usage

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://github.com/rconsortium/S7/'>S7</a></span><span class='o'>)</span></span></code></pre>

</div>

Let's dive into the basics of S7. To learn more, check out the package vignettes, including a more detailed introduction in [`vignette("S7")`](https://rconsortium.github.io/OOP-WG/articles/S7.html), and coverage of generics and methods in [`vignette("generics-methods")`](https://rconsortium.github.io/OOP-WG/articles/generics-methods.html), and classes and objects in [`vignette("classes-objects")`](https://rconsortium.github.io/OOP-WG/articles/classes-objects.html).

### Classes and Objects

S7 classes have formal definitions, specified by [`new_class()`](https://rconsortium.github.io/S7/reference/new_class.html), which includes a list of properties and an optional validator. For example, the following code creates a `Range` class with `start` and `end` properties, and a validator to ensure that `start` is always less than `end`:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>Range</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rconsortium.github.io/S7/reference/new_class.html'>new_class</a></span><span class='o'>(</span><span class='s'>"Range"</span>,</span>
<span>  properties <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span></span>
<span>    start <span class='o'>=</span> <span class='nv'>class_double</span>,</span>
<span>    end <span class='o'>=</span> <span class='nv'>class_double</span></span>
<span>  <span class='o'>)</span>,</span>
<span>  validator <span class='o'>=</span> <span class='kr'>function</span><span class='o'>(</span><span class='nv'>self</span><span class='o'>)</span> <span class='o'>&#123;</span></span>
<span>    <span class='kr'>if</span> <span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/length.html'>length</a></span><span class='o'>(</span><span class='nv'>self</span><span class='o'>@</span><span class='nv'>start</span><span class='o'>)</span> <span class='o'>!=</span> <span class='m'>1</span><span class='o'>)</span> <span class='o'>&#123;</span></span>
<span>      <span class='s'>"@start must be length 1"</span></span>
<span>    <span class='o'>&#125;</span> <span class='kr'>else</span> <span class='kr'>if</span> <span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/length.html'>length</a></span><span class='o'>(</span><span class='nv'>self</span><span class='o'>@</span><span class='nv'>end</span><span class='o'>)</span> <span class='o'>!=</span> <span class='m'>1</span><span class='o'>)</span> <span class='o'>&#123;</span></span>
<span>      <span class='s'>"@end must be length 1"</span></span>
<span>    <span class='o'>&#125;</span> <span class='kr'>else</span> <span class='kr'>if</span> <span class='o'>(</span><span class='nv'>self</span><span class='o'>@</span><span class='nv'>end</span> <span class='o'>&lt;</span> <span class='nv'>self</span><span class='o'>@</span><span class='nv'>start</span><span class='o'>)</span> <span class='o'>&#123;</span></span>
<span>      <span class='s'>"@end must be greater than or equal to @start"</span></span>
<span>    <span class='o'>&#125;</span></span>
<span>  <span class='o'>&#125;</span></span>
<span><span class='o'>)</span></span></code></pre>

</div>

[`new_class()`](https://rconsortium.github.io/S7/reference/new_class.html) returns the class object, which also serves as the constructor to create instances of the class:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>x</span> <span class='o'>&lt;-</span> <span class='nf'>Range</span><span class='o'>(</span>start <span class='o'>=</span> <span class='m'>1</span>, end <span class='o'>=</span> <span class='m'>10</span><span class='o'>)</span></span>
<span><span class='nv'>x</span></span>
<span><span class='c'>#&gt; &lt;Range&gt;</span></span>
<span><span class='c'>#&gt;  @ start: num 1</span></span>
<span><span class='c'>#&gt;  @ end  : num 10</span></span>
<span></span></code></pre>

</div>

### Properties

The data an object holds are called its **properties**. Use `@` to get and set properties:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>x</span><span class='o'>@</span><span class='nv'>start</span></span>
<span><span class='c'>#&gt; [1] 1</span></span>
<span></span><span><span class='nv'>x</span><span class='o'>@</span><span class='nv'>end</span> <span class='o'>&lt;-</span> <span class='m'>20</span></span>
<span><span class='nv'>x</span></span>
<span><span class='c'>#&gt; &lt;Range&gt;</span></span>
<span><span class='c'>#&gt;  @ start: num 1</span></span>
<span><span class='c'>#&gt;  @ end  : num 20</span></span>
<span></span></code></pre>

</div>

Properties are automatically validated against the type declared in [`new_class()`](https://rconsortium.github.io/S7/reference/new_class.html) (in this case, `double`) and checked by the class **validator**:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>x</span><span class='o'>@</span><span class='nv'>end</span> <span class='o'>&lt;-</span> <span class='s'>"x"</span></span>
<span><span class='c'>#&gt; Error: &lt;Range&gt;@end must be &lt;double&gt;, not &lt;character&gt;</span></span>
<span></span><span><span class='nv'>x</span><span class='o'>@</span><span class='nv'>end</span> <span class='o'>&lt;-</span> <span class='o'>-</span><span class='m'>1</span></span>
<span><span class='c'>#&gt; Error: &lt;Range&gt; object is invalid:</span></span>
<span><span class='c'>#&gt; - @end must be greater than or equal to @start</span></span>
<span></span></code></pre>

</div>

### Generics and Methods

Like S3 and S4, S7 uses **functional OOP**, where methods belong to **generic** functions, and method calls look like regular function calls: `generic(object, arg2, arg3)`. A generic uses the types of its arguments to automatically pick the appropriate method implementation.

You can create a new generic with [`new_generic()`](https://rconsortium.github.io/S7/reference/new_generic.html), specifying the arguments to dispatch on:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>inside</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rconsortium.github.io/S7/reference/new_generic.html'>new_generic</a></span><span class='o'>(</span><span class='s'>"inside"</span>, <span class='s'>"x"</span><span class='o'>)</span></span></code></pre>

</div>

To define a method for a specific class, use `method(generic, class) <- implementation`:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://rconsortium.github.io/S7/reference/method.html'>method</a></span><span class='o'>(</span><span class='nv'>inside</span>, <span class='nv'>Range</span><span class='o'>)</span> <span class='o'>&lt;-</span> <span class='kr'>function</span><span class='o'>(</span><span class='nv'>x</span>, <span class='nv'>y</span><span class='o'>)</span> <span class='o'>&#123;</span></span>
<span>  <span class='nv'>y</span> <span class='o'>&gt;=</span> <span class='nv'>x</span><span class='o'>@</span><span class='nv'>start</span> <span class='o'>&amp;</span> <span class='nv'>y</span> <span class='o'>&lt;=</span> <span class='nv'>x</span><span class='o'>@</span><span class='nv'>end</span></span>
<span><span class='o'>&#125;</span></span>
<span></span>
<span><span class='nf'>inside</span><span class='o'>(</span><span class='nv'>x</span>, <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='m'>0</span>, <span class='m'>5</span>, <span class='m'>10</span>, <span class='m'>15</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; [1] FALSE  TRUE  TRUE  TRUE</span></span>
<span></span></code></pre>

</div>

Printing the generic shows its methods:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>inside</span></span>
<span><span class='c'>#&gt; &lt;S7_generic&gt; inside(x, ...) with 1 methods:</span></span>
<span><span class='c'>#&gt; 1: method(inside, Range)</span></span>
<span></span></code></pre>

</div>

And you can retrieve the method for a specific class:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://rconsortium.github.io/S7/reference/method.html'>method</a></span><span class='o'>(</span><span class='nv'>inside</span>, <span class='nv'>Range</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; &lt;S7_method&gt; method(inside, Range)</span></span>
<span><span class='c'>#&gt; function (x, y) </span></span>
<span><span class='c'>#&gt; &#123;</span></span>
<span><span class='c'>#&gt;     y &gt;= x@start &amp; y &lt;= x@end</span></span>
<span><span class='c'>#&gt; &#125;</span></span>
<span></span></code></pre>

</div>

## Known Limitations

While we are pleased with S7's design, there are still some limitations:

-   S7 objects can be serialized to disk (with [`saveRDS()`](https://rdrr.io/r/base/readRDS.html)), but the current implementation saves the entire class specification with each object. This may change in the future.
-   Support for implicit S3 classes `"array"` and `"matrix"` is still in development.

We expect the community will uncover more issues as S7 is more widely adopted. If you encounter any problems, please file an issue at <https://github.com/RConsortium/OOP-WG/issues>. We appreciate your feedback in helping us make S7 even better! 😃

## Acknowledgements

Thank you to all people who have contributed issues, code, and comments to this release:

[@calderonsamuel](https://github.com/calderonsamuel), [@Crosita](https://github.com/Crosita), [@DavisVaughan](https://github.com/DavisVaughan), [@dipterix](https://github.com/dipterix), [@guslipkin](https://github.com/guslipkin), [@gvelasq](https://github.com/gvelasq), [@hadley](https://github.com/hadley), [@jeffkimbrel](https://github.com/jeffkimbrel), [@jl5000](https://github.com/jl5000), [@jmbarbone](https://github.com/jmbarbone), [@jmiahjones](https://github.com/jmiahjones), [@jonthegeek](https://github.com/jonthegeek), [@JosiahParry](https://github.com/JosiahParry), [@jtlandis](https://github.com/jtlandis), [@lawremi](https://github.com/lawremi), [@MarcellGranat](https://github.com/MarcellGranat), [@mikmart](https://github.com/mikmart), [@mmaechler](https://github.com/mmaechler), [@mynanshan](https://github.com/mynanshan), [@rikivillalba](https://github.com/rikivillalba), [@sjcowtan](https://github.com/sjcowtan), [@t-kalinowski](https://github.com/t-kalinowski), [@teunbrand](https://github.com/teunbrand), and [@waynelapierre](https://github.com/waynelapierre).

