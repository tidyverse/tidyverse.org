---
output: hugodown::hugo_document

slug: magrittr-2-0
title: magrittr 2.0 is coming soon
date: 2020-07-30
author: Lionel Henry
description: >
    A 2-3 sentence description of the post that appears on the articles page.
    This can be omitted if it would just recapitulate the title.

photo:
  url: https://unsplash.com/photos/X-NAMq6uP3Q
  author: Mike Benna

categories: [package]
tags: []
rmd_hash: 0eea8db631baf62e

---

<div class="highlight">

</div>

It is with unclouded exhilaration that we announce the impending release of [magrittr](https://magrittr.tidyverse.org/) 2.0. magrittr is the package home to the [`%>%`](https://magrittr.tidyverse.org/reference/pipe.html) pipe operator written by Stefan Milton Bache and used throughout the tidyverse.

With this major release, we intend to bring the behaviour of the pipe closer to the base pipe `|>` that will likely be included in a future version of R. We also fixed some longstanding issues that made the pipe problematic for programming in packages.

You can try this development version from github with:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='c'># install.packages("remotes")</span>
<span class='k'>remotes</span>::<span class='nf'><a href='https://remotes.r-lib.org/reference/install_github.html'>install_github</a></span>(<span class='s'>"magrittr"</span>)</code></pre>

</div>

This blog post covers the three main changes in this new version of the magrittr pipe.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://rdrr.io/r/base/library.html'>library</a></span>(<span class='k'><a href='http://magrittr.tidyverse.org'>magrittr</a></span>)</code></pre>

</div>

Laziness
--------

The main user-visible change in this release is that the pipe expressions are now evaluated lazily, only when needed.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='k'>ignore_arguments</span> <span class='o'>&lt;-</span> <span class='nf'>function</span>(<span class='k'>...</span>) <span class='s'>"value"</span>

<span class='nf'><a href='https://rdrr.io/r/base/stop.html'>stop</a></span>(<span class='s'>"foo"</span>) <span class='o'>%&gt;%</span> <span class='nf'>ignore_arguments</span>()
<span class='c'>#&gt; [1] "value"</span></code></pre>

</div>

This has subtle implications but should be mostly backward compatible with existing code. The main source of behaviour change is that some code that previously failed may stop failing if the latter part of the pipeline specifically handle the error.

Similarly, warnings that were previously issued might now be suppressed by a function you're piping into. That's because the following expressions are now almost completely equivalent:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='c'># Piped</span>
<span class='nf'><a href='https://rdrr.io/r/base/warning.html'>warning</a></span>(<span class='s'>"foo"</span>) <span class='o'>%&gt;%</span> <span class='nf'><a href='https://rdrr.io/r/base/warning.html'>suppressWarnings</a></span>()

<span class='c'># Nested</span>
<span class='nf'><a href='https://rdrr.io/r/base/warning.html'>suppressWarnings</a></span>(<span class='nf'><a href='https://rdrr.io/r/base/warning.html'>warning</a></span>(<span class='s'>"foo"</span>))</code></pre>

</div>

Thanks to this change, you will now be able to pipe into testthat error expectations, for instance:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://rdrr.io/r/base/library.html'>library</a></span>(<span class='k'><a href='http://testthat.r-lib.org'>testthat</a></span>) <span class='o'>%&gt;%</span>
  <span class='nf'><a href='https://rdrr.io/r/base/message.html'>suppressMessages</a></span>()

{ <span class='m'>1</span> <span class='o'>+</span> <span class='s'>"a"</span> } <span class='o'>%&gt;%</span>
  <span class='nf'><a href='https://testthat.r-lib.org/reference/expect_error.html'>expect_error</a></span>(<span class='s'>"non-numeric argument"</span>)</code></pre>

</div>

Backtraces
----------

The R implementation of the magrittr pipe was rather costly in terms of backtrace clutter. This made it difficult to debug errors with functions using the pipe:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='k'>foo</span> <span class='o'>&lt;-</span> <span class='nf'>function</span>() <span class='nf'><a href='https://rdrr.io/r/grDevices/plotmath.html'>bar</a></span>()
<span class='k'>bar</span> <span class='o'>&lt;-</span> <span class='nf'>function</span>() <span class='m'>1</span> <span class='o'>%&gt;%</span> <span class='nf'><a href='https://rdrr.io/r/base/identity.html'>identity</a></span>() <span class='o'>%&gt;%</span> <span class='nf'>baz</span>()
<span class='k'>baz</span> <span class='o'>&lt;-</span> <span class='nf'>function</span>(<span class='k'>x</span>) <span class='k'>rlang</span>::<span class='nf'><a href='https://rlang.r-lib.org/reference/abort.html'>abort</a></span>(<span class='s'>"oh no"</span>)

<span class='nf'>foo</span>()
<span class='c'>#&gt; Error: oh no</span>

<span class='k'>rlang</span>::<span class='nf'><a href='https://rlang.r-lib.org/reference/last_error.html'>last_trace</a></span>()
<span class='c'>#&gt; &lt;error/rlang_error&gt;</span>
<span class='c'>#&gt; oh no</span>
<span class='c'>#&gt; Backtrace:</span>
<span class='c'>#&gt;      █</span>
<span class='c'>#&gt;   1. └─global::foo()</span>
<span class='c'>#&gt;   2.   └─global::bar()</span>
<span class='c'>#&gt;   3.     └─1 %&gt;% identity() %&gt;% baz()</span>
<span class='c'>#&gt;   4.       ├─base::withVisible(eval(quote(`_fseq`(`_lhs`)), env, env))</span>
<span class='c'>#&gt;   5.       └─base::eval(quote(`_fseq`(`_lhs`)), env, env)</span>
<span class='c'>#&gt;   6.         └─base::eval(quote(`_fseq`(`_lhs`)), env, env)</span>
<span class='c'>#&gt;   7.           └─`_fseq`(`_lhs`)</span>
<span class='c'>#&gt;   8.             └─magrittr::freduce(value, `_function_list`)</span>
<span class='c'>#&gt;   9.               ├─base::withVisible(function_list[[k]](value))</span>
<span class='c'>#&gt;  10.               └─function_list[[k]](value)</span>
<span class='c'>#&gt;  11.                 └─global::baz(.)</span></code></pre>

</div>

This clutter is now completely fixed:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'>foo</span>()
<span class='c'>#&gt; Error: oh no</span>

<span class='k'>rlang</span>::<span class='nf'><a href='https://rlang.r-lib.org/reference/last_error.html'>last_trace</a></span>()
<span class='c'>#&gt; &lt;error/rlang_error&gt;</span>
<span class='c'>#&gt; oh no</span>
<span class='c'>#&gt; Backtrace:</span>
<span class='c'>#&gt;     █</span>
<span class='c'>#&gt;  1. ├─global::foo()</span>
<span class='c'>#&gt;  2. │ └─global::bar()</span>
<span class='c'>#&gt;  3. │   └─1 %&gt;% identity() %&gt;% baz()</span>
<span class='c'>#&gt;  4. └─global::baz(.)</span></code></pre>

</div>

Note however that one consequence of having a lazy pipe is that the whole pipeline is pushed on the stack before errors have a chance to be thrown.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='k'>f1</span> <span class='o'>&lt;-</span> <span class='nf'>function</span>(<span class='k'>x</span>) <span class='k'>x</span>
<span class='k'>f2</span> <span class='o'>&lt;-</span> <span class='nf'>function</span>(<span class='k'>x</span>) <span class='k'>x</span>
<span class='k'>f3</span> <span class='o'>&lt;-</span> <span class='nf'>function</span>(<span class='k'>x</span>) <span class='k'>x</span>
<span class='k'>f4</span> <span class='o'>&lt;-</span> <span class='nf'>function</span>(<span class='k'>x</span>) <span class='k'>x</span>

<span class='nf'><a href='https://rdrr.io/r/base/stop.html'>stop</a></span>(<span class='s'>"oh no"</span>) <span class='o'>%&gt;%</span> <span class='nf'>f1</span>() <span class='o'>%&gt;%</span> <span class='nf'>f2</span>() <span class='o'>%&gt;%</span> <span class='nf'>f3</span>() <span class='o'>%&gt;%</span> <span class='nf'>f4</span>()
<span class='c'>#&gt; Error in f1(.) : oh no</span>

<span class='k'>rlang</span>::<span class='nf'><a href='https://rlang.r-lib.org/reference/last_error.html'>last_trace</a></span>()
<span class='c'>#&gt; &lt;error/rlang_error&gt;</span>
<span class='c'>#&gt; oh no</span>
<span class='c'>#&gt; Backtrace:</span>
<span class='c'>#&gt;     █</span>
<span class='c'>#&gt;  1. ├─stop("oh no") %&gt;% f1() %&gt;% f2() %&gt;% f3() %&gt;% f4()</span>
<span class='c'>#&gt;  2. ├─global::f4(.)</span>
<span class='c'>#&gt;  3. ├─global::f3(.)</span>
<span class='c'>#&gt;  4. ├─global::f2(.)</span>
<span class='c'>#&gt;  5. └─global::f1(.)</span></code></pre>

</div>

The last function of the pipeline is `f4()`, so that's the first one to be run. It evaluates its argument which is provided by `f3()`, so that's the second function pushed on the stack. And so on until `f1()` needs the result of [`stop("oh no")`](https://rdrr.io/r/base/stop.html) which causes an error.

Speed
-----

The pipe is now written in C. This greatly improves the performance. Here is a benchmark for the old R implementation:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='k'>bench</span>::<span class='nf'><a href='http://bench.r-lib.org/reference/mark.html'>mark</a></span>(
  `0` = <span class='nf'>f1</span>(<span class='kr'>NULL</span>),
  `1` = <span class='kr'>NULL</span> <span class='o'>%&gt;%</span> <span class='nf'>f1</span>(),
  `2` = <span class='kr'>NULL</span> <span class='o'>%&gt;%</span> <span class='nf'>f1</span>() <span class='o'>%&gt;%</span> <span class='nf'>f2</span>(),
  `3` = <span class='kr'>NULL</span> <span class='o'>%&gt;%</span> <span class='nf'>f1</span>() <span class='o'>%&gt;%</span> <span class='nf'>f2</span>() <span class='o'>%&gt;%</span> <span class='nf'>f3</span>(),
  `4` = <span class='kr'>NULL</span> <span class='o'>%&gt;%</span> <span class='nf'>f1</span>() <span class='o'>%&gt;%</span> <span class='nf'>f2</span>() <span class='o'>%&gt;%</span> <span class='nf'>f3</span>() <span class='o'>%&gt;%</span> <span class='nf'>f4</span>(),
)
<span class='c'>#&gt; + + + + + + # A tibble: 5 x 13</span>
<span class='c'>#&gt;   expression     min  median `itr/sec` mem_alloc `gc/sec` n_itr  n_gc total_time result</span>
<span class='c'>#&gt;   &lt;bch:expr&gt; &lt;bch:t&gt; &lt;bch:t&gt;     &lt;dbl&gt; &lt;bch:byt&gt;    &lt;dbl&gt; &lt;int&gt; &lt;dbl&gt;   &lt;bch:tm&gt; &lt;list&gt;</span>
<span class='c'>#&gt; 1 0            258ns   319ns  2808344.        0B      0   10000     0     3.56ms &lt;NULL&gt;</span>
<span class='c'>#&gt; 2 1           59.4µs  68.9µs    13648.      280B     59.1  6004    26   439.91ms &lt;NULL&gt;</span>
<span class='c'>#&gt; 3 2           82.6µs 101.6µs     9252.      280B     42.8  3894    18   420.87ms &lt;NULL&gt;</span>
<span class='c'>#&gt; 4 3          106.4µs 124.7µs     7693.      280B     18.8  3690     9   479.64ms &lt;NULL&gt;</span>
<span class='c'>#&gt; 5 4          130.9µs 156.1µs     6173.      280B     18.8  2956     9   478.84ms &lt;NULL&gt;</span>
<span class='c'>#&gt; # … with 3 more variables: memory &lt;list&gt;, time &lt;list&gt;, gc &lt;list&gt;</span></code></pre>

</div>

The new C implementation is less costly per pipe expression:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='k'>bench</span>::<span class='nf'><a href='http://bench.r-lib.org/reference/mark.html'>mark</a></span>(
  `0` = <span class='nf'>f1</span>(<span class='kr'>NULL</span>),
  `1` = <span class='kr'>NULL</span> <span class='o'>%&gt;%</span> <span class='nf'>f1</span>(),
  `2` = <span class='kr'>NULL</span> <span class='o'>%&gt;%</span> <span class='nf'>f1</span>() <span class='o'>%&gt;%</span> <span class='nf'>f2</span>(),
  `3` = <span class='kr'>NULL</span> <span class='o'>%&gt;%</span> <span class='nf'>f1</span>() <span class='o'>%&gt;%</span> <span class='nf'>f2</span>() <span class='o'>%&gt;%</span> <span class='nf'>f3</span>(),
  `4` = <span class='kr'>NULL</span> <span class='o'>%&gt;%</span> <span class='nf'>f1</span>() <span class='o'>%&gt;%</span> <span class='nf'>f2</span>() <span class='o'>%&gt;%</span> <span class='nf'>f3</span>() <span class='o'>%&gt;%</span> <span class='nf'>f4</span>(),
)
<span class='c'>#&gt;   expression      min   median `itr/sec` mem_alloc `gc/sec` n_itr  n_gc total_time result</span>
<span class='c'>#&gt;   &lt;bch:expr&gt; &lt;bch:tm&gt; &lt;bch:tm&gt;     &lt;dbl&gt; &lt;bch:byt&gt;    &lt;dbl&gt; &lt;int&gt; &lt;dbl&gt;   &lt;bch:tm&gt; &lt;list&gt;</span>
<span class='c'>#&gt; 1 0             270ns    383ns  2240689.        0B    224.   9999     1     4.46ms &lt;NULL&gt;</span>
<span class='c'>#&gt; 2 1            4.47µs   5.95µs   159655.        0B     79.9  9995     5     62.6ms &lt;NULL&gt;</span>
<span class='c'>#&gt; 3 2            5.97µs    8.8µs   109534.        0B     32.9  9997     3    91.27ms &lt;NULL&gt;</span>
<span class='c'>#&gt; 4 3            8.83µs  10.63µs    89902.        0B     27.0  9997     3    111.2ms &lt;NULL&gt;</span>
<span class='c'>#&gt; 5 4           10.99µs  13.18µs    72330.        0B     36.2  9995     5   138.19ms &lt;NULL&gt;</span></code></pre>

</div>

Towards a release
-----------------

Though we have changed the behaviour of the pipe, none of 2600 the reverse dependencies of magrittr, purrr, tidyr, and dplyr were broken by the change. To be extra sure, we'd be grateful for any additional testing on real-life scripts with this development version.

If you're interested in the design tradeoffs involved in the creation of a pipe operator in R, see the [tradeoffs](https://magrittr.tidyverse.org/articles/tradeoffs.html) vignette. Any comments about the choices we have made are welcome.

