---
output: hugodown::hugo_document

slug: waldo
title: waldo
date: 2020-10-15
author: Hadley Wickham
description: >
    waldo is a new package that makes it easier to see the differences
    between a pair of complex R objects.

photo:
  url: https://unsplash.com/photos/JVD3XPqjLaQ
  author: Jason Dent

categories: [package] 
tags: [testthat, waldo]
rmd_hash: c0b0f3d3d48cdc5b

---

We're stoked to announce the [waldo](http://waldo.r-lib.org/) package. waldo is designed to find and concisely describe the difference between a pair of R objects. It was designed primarily to improve failure messages for [`testthat::expect_equal()`](https://testthat.r-lib.org/reference/equality-expectations.html), but it turns out to be useful in a number of other situations.

You can install it from CRAN with:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://rdrr.io/r/utils/install.packages.html'>install.packages</a></span><span class='o'>(</span><span class='s'>"waldo"</span><span class='o'>)</span>
</code></pre>

</div>

waldo basics
------------

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://github.com/r-lib/waldo'>waldo</a></span><span class='o'>)</span>
</code></pre>

</div>

There's really only one function in waldo that you'll ever use: [`waldo::compare()`](https://rdrr.io/pkg/waldo/man/compare.html). Its job is to take a pair of objects and succinctly display all differences. When comparing atomic vectors, [`compare()`](https://rdrr.io/pkg/waldo/man/compare.html) uses the [diffobj](https://github.com/brodieG/diffobj) package by Brodie Gaslam to show additions, deletions, and changes:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='c'># addition</span>
<span class='nf'><a href='https://rdrr.io/pkg/waldo/man/compare.html'>compare</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"a"</span>, <span class='s'>"b"</span>, <span class='s'>"c"</span><span class='o'>)</span>, <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"a"</span>, <span class='s'>"b"</span><span class='o'>)</span><span class='o'>)</span>

<span class='c'>#&gt; `old`: <span style='color: #555555;'>"a"</span><span> </span><span style='color: #555555;'>"b"</span><span> </span><span style='color: #BBBB00;'>"c"</span></span>
<span class='c'>#&gt; `new`: <span style='color: #555555;'>"a"</span><span> </span><span style='color: #555555;'>"b"</span></span>


<span class='c'># deletion</span>
<span class='nf'><a href='https://rdrr.io/pkg/waldo/man/compare.html'>compare</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"a"</span>, <span class='s'>"b"</span><span class='o'>)</span>, <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"a"</span>, <span class='s'>"b"</span>, <span class='s'>"c"</span><span class='o'>)</span><span class='o'>)</span>

<span class='c'>#&gt; `old`: <span style='color: #555555;'>"a"</span><span> </span><span style='color: #555555;'>"b"</span><span>    </span></span>
<span class='c'>#&gt; `new`: <span style='color: #555555;'>"a"</span><span> </span><span style='color: #555555;'>"b"</span><span> </span><span style='color: #0000BB;'>"c"</span></span>


<span class='c'># modification</span>
<span class='nf'><a href='https://rdrr.io/pkg/waldo/man/compare.html'>compare</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"a"</span>, <span class='s'>"b"</span>, <span class='s'>"c"</span><span class='o'>)</span>, <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"a"</span>, <span class='s'>"B"</span>, <span class='s'>"c"</span><span class='o'>)</span><span class='o'>)</span>

<span class='c'>#&gt; `old`: <span style='color: #555555;'>"a"</span><span> </span><span style='color: #00BB00;'>"b"</span><span> </span><span style='color: #555555;'>"c"</span></span>
<span class='c'>#&gt; `new`: <span style='color: #555555;'>"a"</span><span> </span><span style='color: #00BB00;'>"B"</span><span> </span><span style='color: #555555;'>"c"</span></span>
</code></pre>

</div>

Large vectors with small changes only show a little context around the changes, not all the parts that are the same:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://rdrr.io/pkg/waldo/man/compare.html'>compare</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"X"</span>, <span class='nv'>letters</span>, <span class='nv'>letters</span><span class='o'>)</span>, <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='nv'>letters</span>, <span class='nv'>letters</span>, <span class='s'>"X"</span><span class='o'>)</span><span class='o'>)</span>

<span class='c'>#&gt; `old[1:4]`: <span style='color: #BBBB00;'>"X"</span><span> </span><span style='color: #555555;'>"a"</span><span> </span><span style='color: #555555;'>"b"</span><span> </span><span style='color: #555555;'>"c"</span></span>
<span class='c'>#&gt; `new[1:3]`:     <span style='color: #555555;'>"a"</span><span> </span><span style='color: #555555;'>"b"</span><span> </span><span style='color: #555555;'>"c"</span></span>
<span class='c'>#&gt; </span>
<span class='c'>#&gt; `old[51:53]`: <span style='color: #555555;'>"x"</span><span> </span><span style='color: #555555;'>"y"</span><span> </span><span style='color: #555555;'>"z"</span><span>    </span></span>
<span class='c'>#&gt; `new[50:53]`: <span style='color: #555555;'>"x"</span><span> </span><span style='color: #555555;'>"y"</span><span> </span><span style='color: #555555;'>"z"</span><span> </span><span style='color: #0000BB;'>"X"</span></span>
</code></pre>

</div>

Depending on the size of the differences and the width of your console you'll get one of three displays. The default display shows the vectors one atop the other. If there's not enough room for that, the two vectors are shown side-by-side. And if there's still not enough room for side-by-side, then each element is shown on its own line:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>with_width</span> <span class='o'>&lt;-</span> <span class='kr'>function</span><span class='o'>(</span><span class='nv'>width</span>, <span class='nv'>code</span><span class='o'>)</span> <span class='o'>{</span>
  <span class='nf'>withr</span><span class='nf'>::</span><span class='nf'><a href='https://withr.r-lib.org/reference/with_options.html'>local_options</a></span><span class='o'>(</span>width <span class='o'>=</span> <span class='nv'>width</span><span class='o'>)</span>
  <span class='nv'>code</span>
<span class='o'>}</span>

<span class='nv'>old</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"x"</span>, <span class='s'>"y"</span>, <span class='s'>"a"</span>, <span class='s'>"b"</span>, <span class='s'>"c"</span><span class='o'>)</span>
<span class='nv'>new</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"y"</span>, <span class='s'>"a"</span>, <span class='s'>"B"</span>, <span class='s'>"c"</span>, <span class='s'>"d"</span><span class='o'>)</span>

<span class='nf'>with_width</span><span class='o'>(</span><span class='m'>80</span>, <span class='nf'><a href='https://rdrr.io/pkg/waldo/man/compare.html'>compare</a></span><span class='o'>(</span><span class='nv'>old</span>, <span class='nv'>new</span><span class='o'>)</span><span class='o'>)</span>

<span class='c'>#&gt; `old`: <span style='color: #BBBB00;'>"x"</span><span> </span><span style='color: #555555;'>"y"</span><span> </span><span style='color: #555555;'>"a"</span><span> </span><span style='color: #00BB00;'>"b"</span><span> </span><span style='color: #555555;'>"c"</span><span>    </span></span>
<span class='c'>#&gt; `new`:     <span style='color: #555555;'>"y"</span><span> </span><span style='color: #555555;'>"a"</span><span> </span><span style='color: #00BB00;'>"B"</span><span> </span><span style='color: #555555;'>"c"</span><span> </span><span style='color: #0000BB;'>"d"</span></span>

<span class='nf'>with_width</span><span class='o'>(</span><span class='m'>20</span>, <span class='nf'><a href='https://rdrr.io/pkg/waldo/man/compare.html'>compare</a></span><span class='o'>(</span><span class='nv'>old</span>, <span class='nv'>new</span><span class='o'>)</span><span class='o'>)</span>

<span class='c'>#&gt;     old | new    </span>
<span class='c'>#&gt; [1] <span style='color: #BBBB00;'>"x"</span><span> -        </span></span>
<span class='c'>#&gt; [2] <span style='color: #555555;'>"y"</span><span> | </span><span style='color: #555555;'>"y"</span><span> [1]</span></span>
<span class='c'>#&gt; [3] <span style='color: #555555;'>"a"</span><span> | </span><span style='color: #555555;'>"a"</span><span> [2]</span></span>
<span class='c'>#&gt; [4] <span style='color: #00BB00;'>"b"</span><span> - </span><span style='color: #00BB00;'>"B"</span><span> [3]</span></span>
<span class='c'>#&gt; [5] <span style='color: #555555;'>"c"</span><span> | </span><span style='color: #555555;'>"c"</span><span> [4]</span></span>
<span class='c'>#&gt;         - <span style='color: #0000BB;'>"d"</span><span> [5]</span></span>

<span class='nf'>with_width</span><span class='o'>(</span><span class='m'>10</span>, <span class='nf'><a href='https://rdrr.io/pkg/waldo/man/compare.html'>compare</a></span><span class='o'>(</span><span class='nv'>old</span>, <span class='nv'>new</span><span class='o'>)</span><span class='o'>)</span>

<span class='c'>#&gt; old vs new</span>
<span class='c'>#&gt; <span style='color: #0000BB;'>+ "x"</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>  "y"</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>  "a"</span></span>
<span class='c'>#&gt; <span style='color: #BBBB00;'>- "B"</span></span>
<span class='c'>#&gt; <span style='color: #0000BB;'>+ "b"</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>  "c"</span></span>
<span class='c'>#&gt; <span style='color: #BBBB00;'>- "d"</span></span>
</code></pre>

</div>

As you can see, in situations where colour is available, additions are coloured in blue, deletions in yellow, and changes in green.

Nested objects
--------------

For more complex objects, waldo drills down precisely to the location of differences, using R code to describe their location. Unnamed lists show the position of changes:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://rdrr.io/pkg/waldo/man/compare.html'>compare</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/factor.html'>factor</a></span><span class='o'>(</span><span class='s'>"x"</span><span class='o'>)</span><span class='o'>)</span>, <span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span><span class='m'>1L</span><span class='o'>)</span><span class='o'>)</span>

<span class='c'>#&gt; `old[[1]]` is <span style='color: #00BB00;'>an S3 object of class &lt;factor&gt;</span></span>
<span class='c'>#&gt; `new[[1]]` is <span style='color: #00BB00;'>an integer vector</span><span> (1)</span></span>
</code></pre>

</div>

But most complex lists have names, so if they're available waldo will use them:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://rdrr.io/pkg/waldo/man/compare.html'>compare</a></span><span class='o'>(</span>
  <span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span>x <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span>y <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span>z <span class='o'>=</span> <span class='m'>3</span><span class='o'>)</span><span class='o'>)</span><span class='o'>)</span>,
  <span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span>x <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span>y <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span>z <span class='o'>=</span> <span class='s'>"a"</span><span class='o'>)</span><span class='o'>)</span><span class='o'>)</span>
<span class='o'>)</span>

<span class='c'>#&gt; `old$x$y$z` is <span style='color: #00BB00;'>a double vector</span><span> (3)</span></span>
<span class='c'>#&gt; `new$x$y$z` is <span style='color: #00BB00;'>a character vector</span><span> ('a')</span></span>
</code></pre>

</div>

If named valued are the same but with different positions, waldo just reports on the difference in names:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://rdrr.io/pkg/waldo/man/compare.html'>compare</a></span><span class='o'>(</span>
  <span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span>x <span class='o'>=</span> <span class='m'>1</span>, y <span class='o'>=</span> <span class='m'>2</span><span class='o'>)</span>,
  <span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span>y <span class='o'>=</span> <span class='m'>2</span>, x <span class='o'>=</span> <span class='m'>1</span><span class='o'>)</span>
<span class='o'>)</span>

<span class='c'>#&gt; `names(old)`: <span style='color: #BBBB00;'>"x"</span><span> </span><span style='color: #555555;'>"y"</span><span>    </span></span>
<span class='c'>#&gt; `names(new)`:     <span style='color: #555555;'>"y"</span><span> </span><span style='color: #0000BB;'>"x"</span></span>
</code></pre>

</div>

waldo also reports on differences in attributes:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://rdrr.io/pkg/waldo/man/compare.html'>compare</a></span><span class='o'>(</span>
  <span class='nf'><a href='https://rdrr.io/r/base/structure.html'>structure</a></span><span class='o'>(</span><span class='m'>1</span><span class='o'>:</span><span class='m'>5</span>, a <span class='o'>=</span> <span class='m'>1</span><span class='o'>)</span>,
  <span class='nf'><a href='https://rdrr.io/r/base/structure.html'>structure</a></span><span class='o'>(</span><span class='m'>1</span><span class='o'>:</span><span class='m'>5</span>, a <span class='o'>=</span> <span class='m'>2</span><span class='o'>)</span>
<span class='o'>)</span>

<span class='c'>#&gt; `attr(old, 'a')`: <span style='color: #00BB00;'>1</span></span>
<span class='c'>#&gt; `attr(new, 'a')`: <span style='color: #00BB00;'>2</span></span>
</code></pre>

</div>

And can recurse arbitrarily deep:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>x</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span>a <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span>b <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span>c <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/structure.html'>structure</a></span><span class='o'>(</span><span class='m'>1</span>, d <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/factor.html'>factor</a></span><span class='o'>(</span><span class='s'>"a"</span><span class='o'>)</span><span class='o'>)</span><span class='o'>)</span><span class='o'>)</span><span class='o'>)</span>
<span class='nv'>y</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span>a <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span>b <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span>c <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/structure.html'>structure</a></span><span class='o'>(</span><span class='m'>1</span>, d <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/factor.html'>factor</a></span><span class='o'>(</span><span class='s'>"a"</span>, levels <span class='o'>=</span> <span class='nv'>letters</span><span class='o'>[</span><span class='m'>1</span><span class='o'>:</span><span class='m'>2</span><span class='o'>]</span><span class='o'>)</span><span class='o'>)</span><span class='o'>)</span><span class='o'>)</span><span class='o'>)</span>
<span class='nf'><a href='https://rdrr.io/pkg/waldo/man/compare.html'>compare</a></span><span class='o'>(</span><span class='nv'>x</span>, <span class='nv'>y</span><span class='o'>)</span>

<span class='c'>#&gt; `levels(attr(old$a$b$c, 'd'))`: <span style='color: #555555;'>"a"</span><span>    </span></span>
<span class='c'>#&gt; `levels(attr(new$a$b$c, 'd'))`: <span style='color: #555555;'>"a"</span><span> </span><span style='color: #0000BB;'>"b"</span></span>
</code></pre>

</div>

To illustrate how you might use waldo in practice, I include two case studies below. They both come from my colleagues at RStudio, who have been trying it out prior to its public debut.

Case study: GitHub API
----------------------

The first case study comes from Jenny Bryan. She was trying to figure out precisely what changed when a certain request to the GitHub API was performed with and without authentication:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='c'># Use default auth</span>
<span class='nv'>x1</span> <span class='o'>&lt;-</span> <span class='nf'>gh</span><span class='nf'>::</span><span class='nf'><a href='https://gh.r-lib.org/reference/gh.html'>gh</a></span><span class='o'>(</span><span class='s'>"/repos/gaborcsardi/roxygenlabs"</span><span class='o'>)</span>
<span class='c'># Suppress auth</span>
<span class='nv'>x2</span> <span class='o'>&lt;-</span> <span class='nf'>gh</span><span class='nf'>::</span><span class='nf'><a href='https://gh.r-lib.org/reference/gh.html'>gh</a></span><span class='o'>(</span><span class='s'>"/repos/gaborcsardi/roxygenlabs"</span>, .token <span class='o'>=</span> <span class='s'>""</span><span class='o'>)</span>

<span class='c'># Strip part of the results that might expose my GitHub credentials</span>
<span class='nf'><a href='https://rdrr.io/r/base/attr.html'>attr</a></span><span class='o'>(</span><span class='nv'>x1</span>, <span class='s'>"response"</span><span class='o'>)</span> <span class='o'>&lt;-</span> <span class='kc'>NULL</span>
<span class='nf'><a href='https://rdrr.io/r/base/attr.html'>attr</a></span><span class='o'>(</span><span class='nv'>x1</span>, <span class='s'>".send_headers"</span><span class='o'>)</span> <span class='o'>&lt;-</span> <span class='kc'>NULL</span>
<span class='nf'><a href='https://rdrr.io/r/base/attr.html'>attr</a></span><span class='o'>(</span><span class='nv'>x2</span>, <span class='s'>"response"</span><span class='o'>)</span> <span class='o'>&lt;-</span> <span class='kc'>NULL</span>
<span class='nf'><a href='https://rdrr.io/r/base/attr.html'>attr</a></span><span class='o'>(</span><span class='nv'>x2</span>, <span class='s'>".send_headers"</span><span class='o'>)</span> <span class='o'>&lt;-</span> <span class='kc'>NULL</span>
</code></pre>

</div>

The individual objects are rather complicated!

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://rdrr.io/r/utils/str.html'>str</a></span><span class='o'>(</span><span class='nv'>x1</span>, list.len <span class='o'>=</span> <span class='m'>10</span><span class='o'>)</span>

<span class='c'>#&gt; List of 77</span>
<span class='c'>#&gt;  $ id               : int 229545533</span>
<span class='c'>#&gt;  $ node_id          : chr "MDEwOlJlcG9zaXRvcnkyMjk1NDU1MzM="</span>
<span class='c'>#&gt;  $ name             : chr "roxygenlabs"</span>
<span class='c'>#&gt;  $ full_name        : chr "gaborcsardi/roxygenlabs"</span>
<span class='c'>#&gt;  $ private          : logi FALSE</span>
<span class='c'>#&gt;  $ owner            :List of 18</span>
<span class='c'>#&gt;   ..$ login              : chr "gaborcsardi"</span>
<span class='c'>#&gt;   ..$ id                 : int 660288</span>
<span class='c'>#&gt;   ..$ node_id            : chr "MDQ6VXNlcjY2MDI4OA=="</span>
<span class='c'>#&gt;   ..$ avatar_url         : chr "https://avatars3.githubusercontent.com/u/660288?v=4"</span>
<span class='c'>#&gt;   ..$ gravatar_id        : chr ""</span>
<span class='c'>#&gt;   ..$ url                : chr "https://api.github.com/users/gaborcsardi"</span>
<span class='c'>#&gt;   ..$ html_url           : chr "https://github.com/gaborcsardi"</span>
<span class='c'>#&gt;   ..$ followers_url      : chr "https://api.github.com/users/gaborcsardi/followers"</span>
<span class='c'>#&gt;   ..$ following_url      : chr "https://api.github.com/users/gaborcsardi/following{/other_user}"</span>
<span class='c'>#&gt;   ..$ gists_url          : chr "https://api.github.com/users/gaborcsardi/gists{/gist_id}"</span>
<span class='c'>#&gt;   .. [list output truncated]</span>
<span class='c'>#&gt;  $ html_url         : chr "https://github.com/gaborcsardi/roxygenlabs"</span>
<span class='c'>#&gt;  $ description      : chr "Experimental roxygen tags and extensions"</span>
<span class='c'>#&gt;  $ fork             : logi FALSE</span>
<span class='c'>#&gt;  $ url              : chr "https://api.github.com/repos/gaborcsardi/roxygenlabs"</span>
<span class='c'>#&gt;   [list output truncated]</span>
<span class='c'>#&gt;  - attr(*, "method")= chr "GET"</span>
<span class='c'>#&gt;  - attr(*, "class")= chr [1:2] "gh_response" "list"</span>
</code></pre>

</div>

While [`all.equal()`](https://rdrr.io/r/base/all.equal.html) identifies that there is a difference, it doesn't make it easy to see what the difference is:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://rdrr.io/r/base/all.equal.html'>all.equal</a></span><span class='o'>(</span><span class='nv'>x1</span>, <span class='nv'>x2</span><span class='o'>)</span>

<span class='c'>#&gt; [1] "Names: 3 string mismatches"                           </span>
<span class='c'>#&gt; [2] "Length mismatch: comparison on first 76 components"   </span>
<span class='c'>#&gt; [3] "Component 74: Modes: list, NULL"                      </span>
<span class='c'>#&gt; [4] "Component 74: Lengths: 3, 0"                          </span>
<span class='c'>#&gt; [5] "Component 74: names for target but not for current"   </span>
<span class='c'>#&gt; [6] "Component 74: current is not list-like"               </span>
<span class='c'>#&gt; [7] "Component 75: Modes: character, numeric"              </span>
<span class='c'>#&gt; [8] "Component 75: target is character, current is numeric"</span>
<span class='c'>#&gt; [9] "Component 76: Mean relative difference: 0.5"</span>
</code></pre>

</div>

waldo makes it easy: the request with auth returns a new key that contains the `permissions`.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'>waldo</span><span class='nf'>::</span><span class='nf'><a href='https://rdrr.io/pkg/waldo/man/compare.html'>compare</a></span><span class='o'>(</span><span class='nv'>x1</span>, <span class='nv'>x2</span><span class='o'>)</span>

<span class='c'>#&gt; `old` is length 77</span>
<span class='c'>#&gt; `new` is length 76</span>
<span class='c'>#&gt; </span>
<span class='c'>#&gt;      names(old)          | names(new)              </span>
<span class='c'>#&gt; [71] <span style='color: #555555;'>"open_issues"</span><span>       | </span><span style='color: #555555;'>"open_issues"</span><span>       [71]</span></span>
<span class='c'>#&gt; [72] <span style='color: #555555;'>"watchers"</span><span>          | </span><span style='color: #555555;'>"watchers"</span><span>          [72]</span></span>
<span class='c'>#&gt; [73] <span style='color: #555555;'>"default_branch"</span><span>    | </span><span style='color: #555555;'>"default_branch"</span><span>    [73]</span></span>
<span class='c'>#&gt; [74] <span style='color: #BBBB00;'>"permissions"</span><span>       -                         </span></span>
<span class='c'>#&gt; [75] <span style='color: #555555;'>"temp_clone_token"</span><span>  | </span><span style='color: #555555;'>"temp_clone_token"</span><span>  [74]</span></span>
<span class='c'>#&gt; [76] <span style='color: #555555;'>"network_count"</span><span>     | </span><span style='color: #555555;'>"network_count"</span><span>     [75]</span></span>
<span class='c'>#&gt; [77] <span style='color: #555555;'>"subscribers_count"</span><span> | </span><span style='color: #555555;'>"subscribers_count"</span><span> [76]</span></span>
<span class='c'>#&gt; </span>
<span class='c'>#&gt; `old$permissions` is <span style='color: #0000BB;'>a list</span></span>
<span class='c'>#&gt; `new$permissions` is absent</span>
<span class='c'>#&gt; </span>
<span class='c'>#&gt; `old$temp_clone_token` is <span style='color: #00BB00;'>a character vector</span><span> ('')</span></span>
<span class='c'>#&gt; `new$temp_clone_token` is <span style='color: #00BB00;'>NULL</span></span>
</code></pre>

</div>

Case study: Spatial data
------------------------

The second case study comes from Joe Cheng who received a request from Roger Bivand to update map data bundled in the leaftlet package. Roger Bivand had helpfully provide the updated data, but Joe wanted to understand exactly what had changed:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>old</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/readRDS.html'>readRDS</a></span><span class='o'>(</span><span class='s'>"storms-old.rds"</span><span class='o'>)</span>
<span class='nv'>new</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/readRDS.html'>readRDS</a></span><span class='o'>(</span><span class='s'>"storms-new.rds"</span><span class='o'>)</span>
</code></pre>

</div>

Again, the individual objects are complicated:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://rdrr.io/r/utils/str.html'>str</a></span><span class='o'>(</span><span class='nv'>old</span>, list.len <span class='o'>=</span> <span class='m'>5</span>, max.level <span class='o'>=</span> <span class='m'>5</span><span class='o'>)</span>

<span class='c'>#&gt; Loading required package: sp</span>

<span class='c'>#&gt; Formal class 'SpatialLinesDataFrame' [package "sp"] with 4 slots</span>
<span class='c'>#&gt;   ..@ data       :'data.frame':  24 obs. of  3 variables:</span>
<span class='c'>#&gt;   .. ..$ Name    : Factor w/ 24 levels "ALPHA","ARLENE",..: 1 2 3 4 5 6 7 8 9 10 ...</span>
<span class='c'>#&gt;   .. ..$ MaxWind : num [1:24] 45 60 35 65 60 130 140 75 60 45 ...</span>
<span class='c'>#&gt;   .. ..$ MinPress: num [1:24] 998 989 1002 991 980 ...</span>
<span class='c'>#&gt;   ..@ lines      :List of 24</span>
<span class='c'>#&gt;   .. ..$ :Formal class 'Lines' [package "sp"] with 2 slots</span>
<span class='c'>#&gt;   .. .. .. ..@ Lines:List of 1</span>
<span class='c'>#&gt;   .. .. .. ..@ ID   : chr "1"</span>
<span class='c'>#&gt;   .. ..$ :Formal class 'Lines' [package "sp"] with 2 slots</span>
<span class='c'>#&gt;   .. .. .. ..@ Lines:List of 1</span>
<span class='c'>#&gt;   .. .. .. ..@ ID   : chr "2"</span>
<span class='c'>#&gt;   .. ..$ :Formal class 'Lines' [package "sp"] with 2 slots</span>
<span class='c'>#&gt;   .. .. .. ..@ Lines:List of 1</span>
<span class='c'>#&gt;   .. .. .. ..@ ID   : chr "3"</span>
<span class='c'>#&gt;   .. ..$ :Formal class 'Lines' [package "sp"] with 2 slots</span>
<span class='c'>#&gt;   .. .. .. ..@ Lines:List of 1</span>
<span class='c'>#&gt;   .. .. .. ..@ ID   : chr "4"</span>
<span class='c'>#&gt;   .. ..$ :Formal class 'Lines' [package "sp"] with 2 slots</span>
<span class='c'>#&gt;   .. .. .. ..@ Lines:List of 1</span>
<span class='c'>#&gt;   .. .. .. ..@ ID   : chr "5"</span>
<span class='c'>#&gt;   .. .. [list output truncated]</span>
<span class='c'>#&gt;   ..@ bbox       : num [1:2, 1:2] -101.4 10.7 6.6 68.8</span>
<span class='c'>#&gt;   .. ..- attr(*, "dimnames")=List of 2</span>
<span class='c'>#&gt;   .. .. ..$ : chr [1:2] "x" "y"</span>
<span class='c'>#&gt;   .. .. ..$ : chr [1:2] "min" "max"</span>
<span class='c'>#&gt;   ..@ proj4string:Formal class 'CRS' [package "sp"] with 1 slot</span>
<span class='c'>#&gt;   .. .. ..@ projargs: chr "+init=epsg:4326 +proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"</span>
</code></pre>

</div>

[`all.equal()`](https://rdrr.io/r/base/all.equal.html) is bit more helpful here, at least getting us to the right general vicinity:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://rdrr.io/r/base/all.equal.html'>all.equal</a></span><span class='o'>(</span><span class='nv'>old</span>, <span class='nv'>new</span><span class='o'>)</span>

<span class='c'>#&gt; [1] "Attributes: &lt; Component \"proj4string\": Attributes: &lt; Names: 1 string mismatch &gt; &gt;"                         </span>
<span class='c'>#&gt; [2] "Attributes: &lt; Component \"proj4string\": Attributes: &lt; Length mismatch: comparison on first 2 components &gt; &gt;"</span>
<span class='c'>#&gt; [3] "Attributes: &lt; Component \"proj4string\": Attributes: &lt; Component 2: 1 string mismatch &gt; &gt;"</span>
</code></pre>

</div>

But waldo gets us right to the change: the definition of the spatial projection has changed, and it now contains a comment with a lot more data.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'>waldo</span><span class='nf'>::</span><span class='nf'><a href='https://rdrr.io/pkg/waldo/man/compare.html'>compare</a></span><span class='o'>(</span><span class='nv'>old</span>, <span class='nv'>new</span><span class='o'>)</span>

<span class='c'>#&gt; old@proj4string@projargs vs new@proj4string@projargs</span>
<span class='c'>#&gt; <span style='color: #BBBB00;'>- "+proj=longlat +ellps=WGS84 +towgs84=0,0,0,0,0,0,0 +no_defs"</span></span>
<span class='c'>#&gt; <span style='color: #0000BB;'>+ "+init=epsg:4326 +proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"</span></span>
<span class='c'>#&gt; </span>
<span class='c'>#&gt; `comment(old@proj4string)` is absent</span>
<span class='c'>#&gt; `comment(new@proj4string)` is <span style='color: #BBBB00;'>a character vector</span><span> ('GEOGCRS["unknown",\n    DATUM["World Geodetic System 1984",\n        ELLIPSOID["WGS 84",6378137,298.257223563,\n            LENGTHUNIT["metre",1]],\n        ID["EPSG",6326]],\n    PRIMEM["Greenwich",0,\n        ANGLEUNIT["degree",0.0174532925199433],\n        ID["EPSG",8901]],\n    CS[ellipsoidal,2],\n        AXIS["longitude",east,\n            ORDER[1],\n            ANGLEUNIT["degree",0.0174532925199433,\n                ID["EPSG",9122]]],\n        AXIS["latitude",north,\n            ORDER[2],\n            ANGLEUNIT["degree",0.0174532925199433,\n                ID["EPSG",9122]]]]')</span></span>
</code></pre>

</div>

