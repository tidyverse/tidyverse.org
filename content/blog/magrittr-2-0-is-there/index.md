---
output: hugodown::hugo_document

slug: magrittr-2-0-is-there
title: magrittr 2.0 is there!
date: 2020-11-20
author: Lionel Henry
description: >
    A new version of the magrittr package brings laziness, better performance, and leaner backtraces for debugging errors.

photo:
  url: https://unsplash.com/photos/E4W60q8rkZs
  author: Florian Wächter

categories: [package]
tags: []
rmd_hash: b4355bea37932768

---

<div class="highlight">

</div>

It is with fiery joyousness that we announce the release of [magrittr](https://magrittr.tidyverse.org/) 2.0. magrittr is the package home to the [`%>%`](https://magrittr.tidyverse.org/reference/pipe.html) pipe operator written by Stefan Milton Bache and used throughout the tidyverse. This last and likely final version of magrittr has been completely rewritten in C to resolve the longstanding issues of overhead and backtrace footprint. It also uses a different approach to support laziness and make the magrittr pipe more compatible with the base pipe `|>` to be included in the next version of R.

This blog post covers the three main changes in this new version of the magrittr pipe and how to solve compatibility issues, should they arise. Our analysis and testing suggests that the new version should be a drop-in replacement in most cases. It is however possible that the lazy implementation causes issues with specific functions. You will find below some tips to fix these, which will also make your code compatible with `|>` in R 4.1.

Install the latest version of magrittr with:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://rdrr.io/r/utils/install.packages.html'>install.packages</a></span><span class='o'>(</span><span class='s'>"magrittr"</span><span class='o'>)</span>
</code></pre>

</div>

Attach magrittr to follow the examples:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://magrittr.tidyverse.org'>magrittr</a></span><span class='o'>)</span>
</code></pre>

</div>

Backtraces
----------

The R implementation of the magrittr pipe was rather costly in terms of backtrace clutter. This made it difficult to debug errors with functions using the pipe:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>foo</span> <span class='o'>&lt;-</span> <span class='kr'>function</span><span class='o'>(</span><span class='o'>)</span> <span class='nf'><a href='https://rdrr.io/r/grDevices/plotmath.html'>bar</a></span><span class='o'>(</span><span class='o'>)</span>
<span class='nv'>bar</span> <span class='o'>&lt;-</span> <span class='kr'>function</span><span class='o'>(</span><span class='o'>)</span> <span class='m'>1</span> <span class='o'>%&gt;%</span> <span class='nf'><a href='https://rdrr.io/r/base/identity.html'>identity</a></span><span class='o'>(</span><span class='o'>)</span> <span class='o'>%&gt;%</span> <span class='nf'>baz</span><span class='o'>(</span><span class='o'>)</span>
<span class='nv'>baz</span> <span class='o'>&lt;-</span> <span class='kr'>function</span><span class='o'>(</span><span class='nv'>x</span><span class='o'>)</span> <span class='nf'>rlang</span><span class='nf'>::</span><span class='nf'><a href='https://rlang.r-lib.org/reference/abort.html'>abort</a></span><span class='o'>(</span><span class='s'>"oh no"</span><span class='o'>)</span>

<span class='nf'>foo</span><span class='o'>(</span><span class='o'>)</span>
<span class='c'>#&gt; Error: oh no</span>

<span class='nf'>rlang</span><span class='nf'>::</span><span class='nf'><a href='https://rlang.r-lib.org/reference/last_error.html'>last_trace</a></span><span class='o'>(</span><span class='o'>)</span>
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
<span class='c'>#&gt;  11.                 └─global::baz(.)</span>
</code></pre>

</div>

This clutter is now completely resolved:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'>foo</span><span class='o'>(</span><span class='o'>)</span>
<span class='c'>#&gt; Error: oh no</span>

<span class='nf'>rlang</span><span class='nf'>::</span><span class='nf'><a href='https://rlang.r-lib.org/reference/last_error.html'>last_trace</a></span><span class='o'>(</span><span class='o'>)</span>
<span class='c'>#&gt; &lt;error/rlang_error&gt;</span>
<span class='c'>#&gt; oh no</span>
<span class='c'>#&gt; Backtrace:</span>
<span class='c'>#&gt;     █</span>
<span class='c'>#&gt;  1. ├─global::foo()</span>
<span class='c'>#&gt;  2. │ └─global::bar()</span>
<span class='c'>#&gt;  3. │   └─1 %&gt;% identity() %&gt;% baz()</span>
<span class='c'>#&gt;  4. └─global::baz(.)</span>
</code></pre>

</div>

Speed
-----

The pipe is now written in C to improve the performance. Here is a benchmark for the old R implementation:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>f1</span> <span class='o'>&lt;-</span> <span class='kr'>function</span><span class='o'>(</span><span class='nv'>x</span><span class='o'>)</span> <span class='nv'>x</span>
<span class='nv'>f2</span> <span class='o'>&lt;-</span> <span class='kr'>function</span><span class='o'>(</span><span class='nv'>x</span><span class='o'>)</span> <span class='nv'>x</span>
<span class='nv'>f3</span> <span class='o'>&lt;-</span> <span class='kr'>function</span><span class='o'>(</span><span class='nv'>x</span><span class='o'>)</span> <span class='nv'>x</span>
<span class='nv'>f4</span> <span class='o'>&lt;-</span> <span class='kr'>function</span><span class='o'>(</span><span class='nv'>x</span><span class='o'>)</span> <span class='nv'>x</span>

<span class='nf'>bench</span><span class='nf'>::</span><span class='nf'><a href='http://bench.r-lib.org/reference/mark.html'>mark</a></span><span class='o'>(</span>
  `1` <span class='o'>=</span> <span class='kc'>NULL</span> <span class='o'>%&gt;%</span> <span class='nf'>f1</span><span class='o'>(</span><span class='o'>)</span>,
  `2` <span class='o'>=</span> <span class='kc'>NULL</span> <span class='o'>%&gt;%</span> <span class='nf'>f1</span><span class='o'>(</span><span class='o'>)</span> <span class='o'>%&gt;%</span> <span class='nf'>f2</span><span class='o'>(</span><span class='o'>)</span>,
  `3` <span class='o'>=</span> <span class='kc'>NULL</span> <span class='o'>%&gt;%</span> <span class='nf'>f1</span><span class='o'>(</span><span class='o'>)</span> <span class='o'>%&gt;%</span> <span class='nf'>f2</span><span class='o'>(</span><span class='o'>)</span> <span class='o'>%&gt;%</span> <span class='nf'>f3</span><span class='o'>(</span><span class='o'>)</span>,
  `4` <span class='o'>=</span> <span class='kc'>NULL</span> <span class='o'>%&gt;%</span> <span class='nf'>f1</span><span class='o'>(</span><span class='o'>)</span> <span class='o'>%&gt;%</span> <span class='nf'>f2</span><span class='o'>(</span><span class='o'>)</span> <span class='o'>%&gt;%</span> <span class='nf'>f3</span><span class='o'>(</span><span class='o'>)</span> <span class='o'>%&gt;%</span> <span class='nf'>f4</span><span class='o'>(</span><span class='o'>)</span>,
<span class='o'>)</span>
<span class='c'>#&gt;   expression     min  median `itr/sec` mem_alloc `gc/sec` n_itr  n_gc</span>
<span class='c'>#&gt;   &lt;bch:expr&gt; &lt;bch:t&gt; &lt;bch:t&gt;     &lt;dbl&gt; &lt;bch:byt&gt;    &lt;dbl&gt; &lt;int&gt; &lt;dbl&gt;</span>
<span class='c'>#&gt; 1 1           59.4µs  68.9µs    13648.      280B     59.1  6004    26</span>
<span class='c'>#&gt; 2 2           82.6µs 101.6µs     9252.      280B     42.8  3894    18</span>
<span class='c'>#&gt; 3 3          106.4µs 124.7µs     7693.      280B     18.8  3690     9</span>
<span class='c'>#&gt; 4 4          130.9µs 156.1µs     6173.      280B     18.8  2956     9</span>
</code></pre>

</div>

The new implementation is less costly, especially with many pipe expressions:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'>bench</span><span class='nf'>::</span><span class='nf'><a href='http://bench.r-lib.org/reference/mark.html'>mark</a></span><span class='o'>(</span>
  `1` <span class='o'>=</span> <span class='kc'>NULL</span> <span class='o'>%&gt;%</span> <span class='nf'>f1</span><span class='o'>(</span><span class='o'>)</span>,
  `2` <span class='o'>=</span> <span class='kc'>NULL</span> <span class='o'>%&gt;%</span> <span class='nf'>f1</span><span class='o'>(</span><span class='o'>)</span> <span class='o'>%&gt;%</span> <span class='nf'>f2</span><span class='o'>(</span><span class='o'>)</span>,
  `3` <span class='o'>=</span> <span class='kc'>NULL</span> <span class='o'>%&gt;%</span> <span class='nf'>f1</span><span class='o'>(</span><span class='o'>)</span> <span class='o'>%&gt;%</span> <span class='nf'>f2</span><span class='o'>(</span><span class='o'>)</span> <span class='o'>%&gt;%</span> <span class='nf'>f3</span><span class='o'>(</span><span class='o'>)</span>,
  `4` <span class='o'>=</span> <span class='kc'>NULL</span> <span class='o'>%&gt;%</span> <span class='nf'>f1</span><span class='o'>(</span><span class='o'>)</span> <span class='o'>%&gt;%</span> <span class='nf'>f2</span><span class='o'>(</span><span class='o'>)</span> <span class='o'>%&gt;%</span> <span class='nf'>f3</span><span class='o'>(</span><span class='o'>)</span> <span class='o'>%&gt;%</span> <span class='nf'>f4</span><span class='o'>(</span><span class='o'>)</span>,
<span class='o'>)</span>
<span class='c'>#&gt;   expression      min   median `itr/sec` mem_alloc `gc/sec` n_itr  n_gc</span>
<span class='c'>#&gt;   &lt;bch:expr&gt; &lt;bch:tm&gt; &lt;bch:tm&gt;     &lt;dbl&gt; &lt;bch:byt&gt;    &lt;dbl&gt; &lt;int&gt; &lt;dbl&gt;</span>
<span class='c'>#&gt; 1 1            1.83µs   2.42µs   379343.        0B     75.9  9998     2</span>
<span class='c'>#&gt; 2 2             2.3µs   2.79µs   255363.        0B      0   10000     0</span>
<span class='c'>#&gt; 3 3            2.82µs   3.74µs   244980.        0B     24.5  9999     1</span>
<span class='c'>#&gt; 4 4            3.32µs   4.37µs   217986.        0B     21.8  9999     1</span>
</code></pre>

</div>

We don't generally except this to have much impact on typical data analysis code, but it might yield meaningful speed ups if you are using the pipe inside very tight loops.

Laziness
--------

R core has expressed their interest in adding a native pipe in the next version of R and are working on an implementation[^1]. The main user-visible change in this release makes magrittr more compatible with the behaviour of the base pipe by evaluating the expressions lazily, only when needed.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>ignore_arguments</span> <span class='o'>&lt;-</span> <span class='kr'>function</span><span class='o'>(</span><span class='nv'>...</span><span class='o'>)</span> <span class='s'>"value"</span>

<span class='kr'><a href='https://rdrr.io/r/base/stop.html'>stop</a></span><span class='o'>(</span><span class='s'>"foo"</span><span class='o'>)</span> <span class='o'>%&gt;%</span> <span class='nf'>ignore_arguments</span><span class='o'>(</span><span class='o'>)</span>

<span class='c'>#&gt; [1] "value"</span>
</code></pre>

</div>

This has subtle implications but should be backward compatible with existing pipelines that run without error. The main source of behaviour change is that some code that previously failed may stop failing if the latter part of the pipeline specifically handled the error.

Similarly, warnings that were previously issued might now be suppressed by a function you're piping into. That's because the following expressions are now almost completely equivalent:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='c'># Piped</span>
<span class='kr'><a href='https://rdrr.io/r/base/warning.html'>warning</a></span><span class='o'>(</span><span class='s'>"foo"</span><span class='o'>)</span> <span class='o'>%&gt;%</span> <span class='nf'><a href='https://rdrr.io/r/base/warning.html'>suppressWarnings</a></span><span class='o'>(</span><span class='o'>)</span>

<span class='c'># Nested</span>
<span class='nf'><a href='https://rdrr.io/r/base/warning.html'>suppressWarnings</a></span><span class='o'>(</span><span class='kr'><a href='https://rdrr.io/r/base/warning.html'>warning</a></span><span class='o'>(</span><span class='s'>"foo"</span><span class='o'>)</span><span class='o'>)</span>
</code></pre>

</div>

Thanks to this change, you will now be able to pipe into testthat error expectations, for instance:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://testthat.r-lib.org'>testthat</a></span><span class='o'>)</span> <span class='o'>%&gt;%</span>
  <span class='nf'><a href='https://rdrr.io/r/base/message.html'>suppressMessages</a></span><span class='o'>(</span><span class='o'>)</span>

<span class='o'>&#123;</span> <span class='m'>1</span> <span class='o'>+</span> <span class='s'>"a"</span> <span class='o'>&#125;</span> <span class='o'>%&gt;%</span>
  <span class='nf'><a href='https://testthat.r-lib.org/reference/expect_error.html'>expect_error</a></span><span class='o'>(</span><span class='s'>"non-numeric argument"</span><span class='o'>)</span>
</code></pre>

</div>

Note that one consequence of having a lazy pipe is that the whole pipeline will be shown on the call stack before any errors are thrown:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>f1</span> <span class='o'>&lt;-</span> <span class='kr'>function</span><span class='o'>(</span><span class='nv'>x</span><span class='o'>)</span> <span class='nv'>x</span>
<span class='nv'>f2</span> <span class='o'>&lt;-</span> <span class='kr'>function</span><span class='o'>(</span><span class='nv'>x</span><span class='o'>)</span> <span class='nv'>x</span>
<span class='nv'>f3</span> <span class='o'>&lt;-</span> <span class='kr'>function</span><span class='o'>(</span><span class='nv'>x</span><span class='o'>)</span> <span class='nv'>x</span>
<span class='nv'>f4</span> <span class='o'>&lt;-</span> <span class='kr'>function</span><span class='o'>(</span><span class='nv'>x</span><span class='o'>)</span> <span class='nv'>x</span>

<span class='kr'><a href='https://rdrr.io/r/base/stop.html'>stop</a></span><span class='o'>(</span><span class='s'>"oh no"</span><span class='o'>)</span> <span class='o'>%&gt;%</span> <span class='nf'>f1</span><span class='o'>(</span><span class='o'>)</span> <span class='o'>%&gt;%</span> <span class='nf'>f2</span><span class='o'>(</span><span class='o'>)</span> <span class='o'>%&gt;%</span> <span class='nf'>f3</span><span class='o'>(</span><span class='o'>)</span> <span class='o'>%&gt;%</span> <span class='nf'>f4</span><span class='o'>(</span><span class='o'>)</span>
<span class='c'>#&gt; Error in f1(.) : oh no</span>

<span class='nf'>rlang</span><span class='nf'>::</span><span class='nf'><a href='https://rlang.r-lib.org/reference/last_error.html'>last_trace</a></span><span class='o'>(</span><span class='o'>)</span>
<span class='c'>#&gt; &lt;error/rlang_error&gt;</span>
<span class='c'>#&gt; oh no</span>
<span class='c'>#&gt; Backtrace:</span>
<span class='c'>#&gt;     █</span>
<span class='c'>#&gt;  1. ├─stop("oh no") %&gt;% f1() %&gt;% f2() %&gt;% f3() %&gt;% f4()</span>
<span class='c'>#&gt;  2. ├─global::f4(.)</span>
<span class='c'>#&gt;  3. ├─global::f3(.)</span>
<span class='c'>#&gt;  4. ├─global::f2(.)</span>
<span class='c'>#&gt;  5. └─global::f1(.)</span>
</code></pre>

</div>

The last function of the pipeline is `f4()`, so that's the first one to be run. It evaluates its argument which is provided by `f3()`, so that's the second function pushed on the stack. And so on until `f1()` needs the result of [`stop("oh no")`](https://rdrr.io/r/base/stop.html) which causes an error.

Compatibility with magrittr 2.0
-------------------------------

Though we have changed the behaviour of the pipe, there should be no impact on your user code. The laziness makes it possible to use the pipe in more situations but is not any stricter. It should only cause problems in very rare corner cases and these should be minor. To confirm our analysis, we ran reverse dependency checks for magrittr, purrr, tidyr, dplyr, and tidymodels. Only a dozen out of the 2800 packages were broken by the new implementation, and fixing them has generally been easy (see the breaking changes section of the [NEWS file](https://github.com/tidyverse/magrittr/blob/master/NEWS.md)). In this section you will find a summary of the most common problems and how to fix them.

### Using `return()` inside `{` blocks

The issue you're most likely to encounter is that using [`return()`](https://rdrr.io/r/base/function.html) inside `{` inside [`%>%`](https://magrittr.tidyverse.org/reference/pipe.html) is no longer supported. If you do this, you will see this error:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='m'>1</span> <span class='o'>%&gt;%</span> <span class='o'>&#123;</span>
  <span class='kr'>if</span> <span class='o'>(</span><span class='nv'>.</span> <span class='o'>&gt;=</span> <span class='m'>0</span><span class='o'>)</span> <span class='o'>&#123;</span>
    <span class='kr'><a href='https://rdrr.io/r/base/function.html'>return</a></span><span class='o'>(</span><span class='nv'>.</span><span class='o'>)</span>
  <span class='o'>&#125;</span>
  <span class='nv'>.</span> <span class='o'>+</span> <span class='m'>1</span>
<span class='o'>&#125;</span>

<span class='c'>#&gt; Error in 1 %&gt;% &#123;: no function to return from, jumping to top level</span>
</code></pre>

</div>

In general, the behaviour of [`return()`](https://rdrr.io/r/base/function.html) inside a pipeline was not clearly defined. Should it return from the enclosing function, from the current pipe expression, or from the whole pipeline? We believe returning from the current function would be the ideal behaviour but for technical reasons we can't implement it this way.

The solution to these errors is to rewrite your pipeline:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='m'>1</span> <span class='o'>%&gt;%</span> <span class='o'>&#123;</span>
  <span class='kr'>if</span> <span class='o'>(</span><span class='nv'>.</span> <span class='o'>&gt;=</span> <span class='m'>0</span><span class='o'>)</span> <span class='o'>&#123;</span>
    <span class='nv'>.</span>
  <span class='o'>&#125;</span> <span class='kr'>else</span> <span class='o'>&#123;</span>
    <span class='nv'>.</span> <span class='o'>+</span> <span class='m'>1</span>
  <span class='o'>&#125;</span>
<span class='o'>&#125;</span>

<span class='c'>#&gt; [1] 1</span>
</code></pre>

</div>

In this case, creating a named function will probably produce clearer code:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>increment_negative</span> <span class='o'>&lt;-</span> <span class='kr'>function</span><span class='o'>(</span><span class='nv'>x</span><span class='o'>)</span> <span class='o'>&#123;</span>
  <span class='kr'>if</span> <span class='o'>(</span><span class='nv'>x</span> <span class='o'>&gt;=</span> <span class='m'>0</span><span class='o'>)</span> <span class='o'>&#123;</span>
    <span class='nv'>x</span>
  <span class='o'>&#125;</span> <span class='kr'>else</span> <span class='o'>&#123;</span>
    <span class='nv'>x</span> <span class='o'>+</span> <span class='m'>1</span>
  <span class='o'>&#125;</span>
<span class='o'>&#125;</span>

<span class='m'>1</span> <span class='o'>%&gt;%</span> <span class='nf'>increment_negative</span><span class='o'>(</span><span class='o'>)</span>

<span class='c'>#&gt; [1] 1</span>
</code></pre>

</div>

### Sequential evaluation

A pipeline is laid out as a series of sequential steps:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='m'>1</span> <span class='o'>%&gt;%</span> <span class='nf'><a href='https://magrittr.tidyverse.org/reference/aliases.html'>add</a></span><span class='o'>(</span><span class='m'>1</span><span class='o'>)</span> <span class='o'>%&gt;%</span> <span class='nf'><a href='https://magrittr.tidyverse.org/reference/aliases.html'>multiply_by</a></span><span class='o'>(</span><span class='m'>2</span><span class='o'>)</span>

<span class='c'>#&gt; [1] 4</span>
</code></pre>

</div>

The sequentiality may break down with a lazy implementation. The laziness of R means that function arguments are only evaluated when they are needed. If the function returns without touching the argument, it is never evaluated. In the example below, the user passes [`stop()`](https://rdrr.io/r/base/stop.html) to an ignored argument:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>ignore</span> <span class='o'>&lt;-</span> <span class='kr'>function</span><span class='o'>(</span><span class='nv'>x</span><span class='o'>)</span> <span class='kc'>NULL</span>

<span class='nf'>ignore</span><span class='o'>(</span><span class='kr'><a href='https://rdrr.io/r/base/stop.html'>stop</a></span><span class='o'>(</span><span class='s'>"No error is thrown because `x` is not needed"</span><span class='o'>)</span><span class='o'>)</span>

<span class='c'>#&gt; NULL</span>
</code></pre>

</div>

Here is a pipeline where the arguments are not evaluated until the end:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>f1</span> <span class='o'>&lt;-</span> <span class='kr'>function</span><span class='o'>(</span><span class='nv'>x</span><span class='o'>)</span> <span class='o'>&#123;</span>
  <span class='nf'><a href='https://rdrr.io/r/base/cat.html'>cat</a></span><span class='o'>(</span><span class='s'>"f1\n"</span><span class='o'>)</span>
  <span class='nv'>x</span>
<span class='o'>&#125;</span>
<span class='nv'>f2</span> <span class='o'>&lt;-</span> <span class='kr'>function</span><span class='o'>(</span><span class='nv'>x</span><span class='o'>)</span> <span class='o'>&#123;</span>
  <span class='nf'><a href='https://rdrr.io/r/base/cat.html'>cat</a></span><span class='o'>(</span><span class='s'>"f2\n"</span><span class='o'>)</span>
  <span class='nv'>x</span>
<span class='o'>&#125;</span>
<span class='nv'>f3</span> <span class='o'>&lt;-</span> <span class='kr'>function</span><span class='o'>(</span><span class='nv'>x</span><span class='o'>)</span> <span class='o'>&#123;</span>
  <span class='nf'><a href='https://rdrr.io/r/base/cat.html'>cat</a></span><span class='o'>(</span><span class='s'>"f3\n"</span><span class='o'>)</span>
  <span class='nv'>x</span>
<span class='o'>&#125;</span>

<span class='m'>1</span> <span class='o'>%&gt;%</span> <span class='nf'>f1</span><span class='o'>(</span><span class='o'>)</span> <span class='o'>%&gt;%</span> <span class='nf'>f2</span><span class='o'>(</span><span class='o'>)</span> <span class='o'>%&gt;%</span> <span class='nf'>f3</span><span class='o'>(</span><span class='o'>)</span>

<span class='c'>#&gt; f3</span>
<span class='c'>#&gt; f2</span>
<span class='c'>#&gt; f1</span>

<span class='c'>#&gt; [1] 1</span>
</code></pre>

</div>

Let's rewrite the pipeline to its nested form to understand what is happening:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'>f3</span><span class='o'>(</span><span class='nf'>f2</span><span class='o'>(</span><span class='nf'>f1</span><span class='o'>(</span><span class='m'>1</span><span class='o'>)</span><span class='o'>)</span><span class='o'>)</span>

<span class='c'>#&gt; f3</span>
<span class='c'>#&gt; f2</span>
<span class='c'>#&gt; f1</span>

<span class='c'>#&gt; [1] 1</span>
</code></pre>

</div>

`f3()` runs first. Because it first calls [`cat()`](https://rdrr.io/r/base/cat.html) before touching its argument, this is what runs first. Then it returns its argument, triggering evaluation of `f2()`, and so on.

In general, out-of-order evaluation only matters when your function produces side effects, such as printing output. It is easy to ensure sequential evaluation by forcing evaluation of arguments early in your function:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>f1</span> <span class='o'>&lt;-</span> <span class='kr'>function</span><span class='o'>(</span><span class='nv'>x</span><span class='o'>)</span> <span class='o'>&#123;</span>
  <span class='nf'><a href='https://rdrr.io/r/base/force.html'>force</a></span><span class='o'>(</span><span class='nv'>x</span><span class='o'>)</span>
  <span class='nf'><a href='https://rdrr.io/r/base/cat.html'>cat</a></span><span class='o'>(</span><span class='s'>"f1\n"</span><span class='o'>)</span>
  <span class='nv'>x</span>
<span class='o'>&#125;</span>
<span class='nv'>f2</span> <span class='o'>&lt;-</span> <span class='kr'>function</span><span class='o'>(</span><span class='nv'>x</span><span class='o'>)</span> <span class='o'>&#123;</span>
  <span class='nf'><a href='https://rdrr.io/r/base/force.html'>force</a></span><span class='o'>(</span><span class='nv'>x</span><span class='o'>)</span>
  <span class='nf'><a href='https://rdrr.io/r/base/cat.html'>cat</a></span><span class='o'>(</span><span class='s'>"f2\n"</span><span class='o'>)</span>
  <span class='nv'>x</span>
<span class='o'>&#125;</span>
<span class='nv'>f3</span> <span class='o'>&lt;-</span> <span class='kr'>function</span><span class='o'>(</span><span class='nv'>x</span><span class='o'>)</span> <span class='o'>&#123;</span>
  <span class='nf'><a href='https://rdrr.io/r/base/force.html'>force</a></span><span class='o'>(</span><span class='nv'>x</span><span class='o'>)</span>
  <span class='nf'><a href='https://rdrr.io/r/base/cat.html'>cat</a></span><span class='o'>(</span><span class='s'>"f3\n"</span><span class='o'>)</span>
  <span class='nv'>x</span>
<span class='o'>&#125;</span>
</code></pre>

</div>

This forces arguments to be evaluated in order:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='m'>1</span> <span class='o'>%&gt;%</span> <span class='nf'>f1</span><span class='o'>(</span><span class='o'>)</span> <span class='o'>%&gt;%</span> <span class='nf'>f2</span><span class='o'>(</span><span class='o'>)</span> <span class='o'>%&gt;%</span> <span class='nf'>f3</span><span class='o'>(</span><span class='o'>)</span>

<span class='c'>#&gt; f1</span>
<span class='c'>#&gt; f2</span>
<span class='c'>#&gt; f3</span>

<span class='c'>#&gt; [1] 1</span>


<span class='nf'>f3</span><span class='o'>(</span><span class='nf'>f2</span><span class='o'>(</span><span class='nf'>f1</span><span class='o'>(</span><span class='m'>1</span><span class='o'>)</span><span class='o'>)</span><span class='o'>)</span>

<span class='c'>#&gt; f1</span>
<span class='c'>#&gt; f2</span>
<span class='c'>#&gt; f3</span>

<span class='c'>#&gt; [1] 1</span>
</code></pre>

</div>

### Visibility

Another issue caused by laziness is that if any function in a pipeline returns invisibly, then the whole pipeline returns invisibly as well. All these calls return invisibly:

``` r
1 %>% identity() %>% invisible()

1 %>% invisible() %>% identity()

1 %>% identity() %>% invisible() %>% identity()
```

This is consistent with the equivalent nested code:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://rdrr.io/r/base/invisible.html'>invisible</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/identity.html'>identity</a></span><span class='o'>(</span><span class='m'>1</span><span class='o'>)</span><span class='o'>)</span>

<span class='nf'><a href='https://rdrr.io/r/base/identity.html'>identity</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/invisible.html'>invisible</a></span><span class='o'>(</span><span class='m'>1</span><span class='o'>)</span><span class='o'>)</span>

<span class='nf'><a href='https://rdrr.io/r/base/identity.html'>identity</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/invisible.html'>invisible</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/identity.html'>identity</a></span><span class='o'>(</span><span class='m'>1</span><span class='o'>)</span><span class='o'>)</span><span class='o'>)</span>
</code></pre>

</div>

This behaviour can be worked around in two ways. You can force visibility by wrapping the pipeline in parentheses:

``` r
my_function <- function(x) {
  (x %>% invisible() %>% identity())
}
```

Or by assigning the result to a variable and return it:

``` r
my_function <- function(x) {
  out <- x %>% invisible() %>% identity()
  out
}
```

Conclusion
----------

Despite these few corner cases, we are confident that this release should be seamless for the vast majority of users. It fixes longstanding issues of overhead and makes the behaviour of [`%>%`](https://magrittr.tidyverse.org/reference/pipe.html) interchangeable with the future `|>` pipe of base R. We will maintain magrittr on CRAN for the foreseeable future, making it possible to write pipelined code that is compatible with older versions of R. The long-term compatibility and the resolved overhead should make magrittr a good choice for writing pipelines in R packages. We also hope it will improve the experience of users until they switch to the base pipe. For all these reasons, we are very happy to bring this ultimate version of magrittr to CRAN.

Many thanks to all contributors over the years:

[@adamroyjones](https://github.com/adamroyjones), [@ajschumacher](https://github.com/ajschumacher), [@allswellthatsmaxwell](https://github.com/allswellthatsmaxwell), [@annytr](https://github.com/annytr), [@aouazad](https://github.com/aouazad), [@ateucher](https://github.com/ateucher), [@bakaburg1](https://github.com/bakaburg1), [@balwierz](https://github.com/balwierz), [@batpigandme](https://github.com/batpigandme), [@bdhumb](https://github.com/bdhumb), [@behrica](https://github.com/behrica), [@bfgray3](https://github.com/bfgray3), [@bkmontgom](https://github.com/bkmontgom), [@bramtayl](https://github.com/bramtayl), [@burchill](https://github.com/burchill), [@burgerga](https://github.com/burgerga), [@casallas](https://github.com/casallas), [@cathblatter](https://github.com/cathblatter), [@cfhammill](https://github.com/cfhammill), [@choisy](https://github.com/choisy), [@ClaytonJY](https://github.com/ClaytonJY), [@cstepper](https://github.com/cstepper), [@ctbrown](https://github.com/ctbrown), [@danklotz](https://github.com/danklotz), [@DarwinAwardWinner](https://github.com/DarwinAwardWinner), [@davharris](https://github.com/davharris), [@Deleetdk](https://github.com/Deleetdk), [@dirkschumacher](https://github.com/dirkschumacher), [@DroiPlatform](https://github.com/DroiPlatform), [@dustinvtran](https://github.com/dustinvtran), [@eddelbuettel](https://github.com/eddelbuettel), [@egnha](https://github.com/egnha), [@emankhalaf](https://github.com/emankhalaf), [@Enchufa2](https://github.com/Enchufa2), [@englianhu](https://github.com/englianhu), [@epipping](https://github.com/epipping), [@fabiangehring](https://github.com/fabiangehring), [@franknarf1](https://github.com/franknarf1), [@gaborcsardi](https://github.com/gaborcsardi), [@gdkrmr](https://github.com/gdkrmr), [@gforge](https://github.com/gforge), [@ghost](https://github.com/ghost), [@gwerbin](https://github.com/gwerbin), [@hackereye](https://github.com/hackereye), [@hadley](https://github.com/hadley), [@hh1985](https://github.com/hh1985), [@HughParsonage](https://github.com/HughParsonage), [@HuwCampbell](https://github.com/HuwCampbell), [@iago-pssjd](https://github.com/iago-pssjd), [@imanuelcostigan](https://github.com/imanuelcostigan), [@jaredlander](https://github.com/jaredlander), [@jarodmeng](https://github.com/jarodmeng), [@jcpetkovich](https://github.com/jcpetkovich), [@jdnewmil](https://github.com/jdnewmil), [@jennybc](https://github.com/jennybc), [@jepusto](https://github.com/jepusto), [@jeremyhoughton](https://github.com/jeremyhoughton), [@jeroenjanssens](https://github.com/jeroenjanssens), [@jerryzhujian9](https://github.com/jerryzhujian9), [@jimhester](https://github.com/jimhester), [@JoshOBrien](https://github.com/JoshOBrien), [@jread-usgs](https://github.com/jread-usgs), [@jroberayalas](https://github.com/jroberayalas), [@jzadra](https://github.com/jzadra), [@kbodwin](https://github.com/kbodwin), [@kendonB](https://github.com/kendonB), [@kevinykuo](https://github.com/kevinykuo), [@klmr](https://github.com/klmr), [@krlmlr](https://github.com/krlmlr), [@leerssej](https://github.com/leerssej), [@lionel-](https://github.com/lionel-), [@lorenzwalthert](https://github.com/lorenzwalthert), [@MajoroMask](https://github.com/MajoroMask), [@Make42](https://github.com/Make42), [@mhpedersen](https://github.com/mhpedersen), [@MichaelChirico](https://github.com/MichaelChirico), [@MilesMcBain](https://github.com/MilesMcBain), [@mitchelloharawild](https://github.com/mitchelloharawild), [@mmuurr](https://github.com/mmuurr), [@moodymudskipper](https://github.com/moodymudskipper), [@move\[bot\]](https://github.com/move%5Bbot%5D), [@Mullefa](https://github.com/Mullefa), [@nteetor](https://github.com/nteetor), [@odeleongt](https://github.com/odeleongt), [@peterdesmet](https://github.com/peterdesmet), [@philchalmers](https://github.com/philchalmers), [@pkq](https://github.com/pkq), [@prosoitos](https://github.com/prosoitos), [@r2evans](https://github.com/r2evans), [@restonslacker](https://github.com/restonslacker), [@richierocks](https://github.com/richierocks), [@robertzk](https://github.com/robertzk), [@romainfrancois](https://github.com/romainfrancois), [@rossholmberg](https://github.com/rossholmberg), [@rozsoma](https://github.com/rozsoma), [@rpruim](https://github.com/rpruim), [@rsaporta](https://github.com/rsaporta), [@salim-b](https://github.com/salim-b), [@sbgraves237](https://github.com/sbgraves237), [@SimonHeuberger](https://github.com/SimonHeuberger), [@smbache](https://github.com/smbache), [@stemangiola](https://github.com/stemangiola), [@tonytonov](https://github.com/tonytonov), [@trevorld](https://github.com/trevorld), [@triposorbust](https://github.com/triposorbust), [@Vlek](https://github.com/Vlek), [@vnijs](https://github.com/vnijs), [@vsalmendra](https://github.com/vsalmendra), [@vspinu](https://github.com/vspinu), [@wabarr](https://github.com/wabarr), [@wch](https://github.com/wch), [@westonplatter](https://github.com/westonplatter), [@wibeasley](https://github.com/wibeasley), [@wlandau](https://github.com/wlandau), [@yeedle](https://github.com/yeedle), [@yutannihilation](https://github.com/yutannihilation), [@zeehio](https://github.com/zeehio), and [@zerweck](https://github.com/zerweck).

[^1]: See Luke Tierney's [keynote](https://youtu.be/X_eDHNVceCU?t=3099) at the useR! 2020 conference

