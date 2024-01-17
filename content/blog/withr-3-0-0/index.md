---
output: hugodown::hugo_document

slug: withr-3-0-0
title: withr 3.0.0
date: 2024-01-17
author: Lionel Henry
description: >
    withr is the tidyverse solution for automatically cleaning
    up after yourselves (temporary files, options, etc). This milestone makes withr much faster.

photo:
  url: https://unsplash.com/photos/brown-and-black-brush-on-brown-wooden-table-V0cSTljC92k
  author: Neal E. Johnson

categories: [package]
tags: [r-lib, withr]
rmd_hash: 4b52adda2279dd4f

---

It's not without jubilant bearing that we announce the release of the 3.0.0 version of [withr](https://withr.r-lib.org/), the tidyverse solution for automatic cleanup of resources! In this release, the internals of withr were rewritten to improve the performance and increase the compatibility with base R's [`on.exit()`](https://rdrr.io/r/base/on.exit.html) mechanism.

You can install it from CRAN with:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://rdrr.io/r/utils/install.packages.html'>install.packages</a></span><span class='o'>(</span><span class='s'>"withr"</span><span class='o'>)</span></span></code></pre>

</div>

In this blog post we'll go over the changes that made this rewrite possible, but first we'll rewiew the cleanup strategies made possible by withr.

You can see a full list of changes in the [release notes](https://withr.r-lib.org/news/index.html#withr-300).

<div class="highlight">

</div>

## Cleaning up resources with base R and with withr

Traditionally, resource cleanups in R is done with [`base::on.exit()`](https://rdrr.io/r/base/on.exit.html). Cleaning up in the on-exit hook ensures that the cleanup happens both in the normal case, when the code has finished running without error, and in the error case, when something went wrong and execution is interrupted.

[`on.exit()`](https://rdrr.io/r/base/on.exit.html) is meant to be used inside functions but it also works within [`local()`](https://rdrr.io/r/base/eval.html), which we'll use here for our examples:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://rdrr.io/r/base/eval.html'>local</a></span><span class='o'>(</span><span class='o'>&#123;</span></span>
<span>  <span class='nf'><a href='https://rdrr.io/r/base/on.exit.html'>on.exit</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/message.html'>message</a></span><span class='o'>(</span><span class='s'>"Cleaning time!"</span><span class='o'>)</span><span class='o'>)</span></span>
<span>  <span class='m'>1</span> <span class='o'>+</span> <span class='m'>2</span></span>
<span><span class='o'>&#125;</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; Cleaning time!</span></span>
<span></span><span><span class='c'>#&gt; [1] 3</span></span>
<span></span></code></pre>

</div>

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://rdrr.io/r/base/eval.html'>local</a></span><span class='o'>(</span><span class='o'>&#123;</span></span>
<span>  <span class='nf'><a href='https://rdrr.io/r/base/on.exit.html'>on.exit</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/message.html'>message</a></span><span class='o'>(</span><span class='s'>"Cleaning time!"</span><span class='o'>)</span><span class='o'>)</span></span>
<span>  <span class='kr'><a href='https://rdrr.io/r/base/stop.html'>stop</a></span><span class='o'>(</span><span class='s'>"uh oh"</span><span class='o'>)</span></span>
<span>  <span class='m'>1</span> <span class='o'>+</span> <span class='m'>2</span></span>
<span><span class='o'>&#125;</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #BBBB00; font-weight: bold;'>Error</span><span style='font-weight: bold;'>:</span></span></span>
<span><span class='c'>#&gt; <span style='color: #BBBB00;'>!</span> uh oh</span></span>
<span></span><span><span class='c'>#&gt; Cleaning time!</span></span>
<span></span></code></pre>

</div>

[`on.exit()`](https://rdrr.io/r/base/on.exit.html) is guaranteed to run no matter what and this property makes it invaluable for resource cleaning. No more accidental littering!

However the process of cleaning up this way can be a bit verbose and feel too manual. Here is how you'd create and clean up a temporary file for instance:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://rdrr.io/r/base/eval.html'>local</a></span><span class='o'>(</span><span class='o'>&#123;</span></span>
<span>  <span class='nv'>my_file</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/tempfile.html'>tempfile</a></span><span class='o'>(</span><span class='o'>)</span></span>
<span></span>
<span>  <span class='nf'><a href='https://rdrr.io/r/base/files.html'>file.create</a></span><span class='o'>(</span><span class='nv'>my_file</span><span class='o'>)</span></span>
<span>  <span class='nf'><a href='https://rdrr.io/r/base/on.exit.html'>on.exit</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/files.html'>file.remove</a></span><span class='o'>(</span><span class='nv'>my_file</span><span class='o'>)</span><span class='o'>)</span></span>
<span></span>
<span>  <span class='nf'><a href='https://rdrr.io/r/base/writeLines.html'>writeLines</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"a"</span>, <span class='s'>"b"</span><span class='o'>)</span>, con <span class='o'>=</span> <span class='nv'>my_file</span><span class='o'>)</span></span>
<span><span class='o'>&#125;</span><span class='o'>)</span></span></code></pre>

</div>

To streamline the process, withr provides `local_`-prefixed tools that combine both the creation or modification of a resource and its restoration to the original state in a single function:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://rdrr.io/r/base/eval.html'>local</a></span><span class='o'>(</span><span class='o'>&#123;</span></span>
<span>  <span class='nv'>my_file</span> <span class='o'>&lt;-</span> <span class='nf'>withr</span><span class='nf'>::</span><span class='nf'><a href='https://withr.r-lib.org/reference/with_tempfile.html'>local_tempfile</a></span><span class='o'>(</span><span class='o'>)</span></span>
<span></span>
<span>  <span class='nf'><a href='https://rdrr.io/r/base/writeLines.html'>writeLines</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"a"</span>, <span class='s'>"b"</span><span class='o'>)</span>, con <span class='o'>=</span> <span class='nv'>my_file</span><span class='o'>)</span></span>
<span><span class='o'>&#125;</span><span class='o'>)</span></span></code></pre>

</div>

In this case we have created a resource (a file), but the same principle applies to modifying resources such as global options:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://rdrr.io/r/base/eval.html'>local</a></span><span class='o'>(</span><span class='o'>&#123;</span></span>
<span>  <span class='c'># Let's temporarily print with a single decimal place</span></span>
<span>  <span class='nf'>withr</span><span class='nf'>::</span><span class='nf'><a href='https://withr.r-lib.org/reference/with_options.html'>local_options</a></span><span class='o'>(</span>digits <span class='o'>=</span> <span class='m'>1</span><span class='o'>)</span></span>
<span>  <span class='nf'><a href='https://rdrr.io/r/base/print.html'>print</a></span><span class='o'>(</span><span class='m'>1</span><span class='o'>/</span><span class='m'>3</span><span class='o'>)</span></span>
<span><span class='o'>&#125;</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; [1] 0.3</span></span>
<span></span><span></span>
<span><span class='c'># The original option value has been restored</span></span>
<span><span class='nf'><a href='https://rdrr.io/r/base/options.html'>getOption</a></span><span class='o'>(</span><span class='s'>"digits"</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; [1] 7</span></span>
<span></span><span></span>
<span><span class='nf'><a href='https://rdrr.io/r/base/print.html'>print</a></span><span class='o'>(</span><span class='m'>1</span><span class='o'>/</span><span class='m'>3</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; [1] 0.3333333</span></span>
<span></span></code></pre>

</div>

And you can equivalently use the `with_`-prefixed variants (from which the package takes its name!), this way you don't need to wrap in [`local()`](https://rdrr.io/r/base/eval.html):

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'>withr</span><span class='nf'>::</span><span class='nf'><a href='https://withr.r-lib.org/reference/with_options.html'>with_options</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span>digits <span class='o'>=</span> <span class='m'>1</span><span class='o'>)</span>, <span class='nf'><a href='https://rdrr.io/r/base/print.html'>print</a></span><span class='o'>(</span><span class='m'>1</span><span class='o'>/</span><span class='m'>3</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; [1] 0.3</span></span>
<span></span></code></pre>

</div>

The `with_` functions are useful for creating very small scopes for given resources, inside or outside a function.

## The withr 3.0.0 rewrite

Traditionally, withr implemented its own exit event system on top of [`on.exit()`](https://rdrr.io/r/base/on.exit.html). We needed an extra layer because of a couple of missing features:

-   When multiple resources are managed by a piece of code, the order in which these resources are restored or cleaned up sometimes matter. The most consistent order for cleanup is last in first out (LIFO). In other words the oldest resource, on which younger resources might depend, is cleaned up last.

-   The other missing piece was being able to inspect the contents of the exit hook. The [`sys.on.exit()`](https://rdrr.io/r/base/sys.parent.html) R helper was created for this purpose but was affected by a bug that prevented it to work elsewhere than at top-level.

We have contributed two changes to R 3.5.0 that filled these missing pieces. The [`sys.on.exit()`](https://rdrr.io/r/base/sys.parent.html) bug was fixed and we've added an `after` argument to [`on.exit()`](https://rdrr.io/r/base/on.exit.html) to allow FIFO ordering.

Until now, we haven't been able to leverage these contributions because of our policy of supporting the last 5 versions of R (see <https://www.tidyverse.org/blog/2019/04/r-version-support>). Now that more than five years have passed, it was time for a rewrite! [`withr::defer()`](https://withr.r-lib.org/reference/defer.html), our version of [`on.exit()`](https://rdrr.io/r/base/on.exit.html) that uses better defaults and allows cleaning up resources non-locally (ironically an essential feature for implementing `local_` functions) is now able to be implemented as a simple wrapper around [`on.exit()`](https://rdrr.io/r/base/on.exit.html).

One benefit of the rewrite is that mixing withr tools and [`on.exit()`](https://rdrr.io/r/base/on.exit.html) in the same function now behaves more correctly in terms of the order of execution:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://rdrr.io/r/base/eval.html'>local</a></span><span class='o'>(</span><span class='o'>&#123;</span></span>
<span>  <span class='nf'><a href='https://rdrr.io/r/base/on.exit.html'>on.exit</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/print.html'>print</a></span><span class='o'>(</span><span class='m'>1</span><span class='o'>)</span><span class='o'>)</span></span>
<span></span>
<span>  <span class='nf'>withr</span><span class='nf'>::</span><span class='nf'><a href='https://withr.r-lib.org/reference/defer.html'>defer</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/print.html'>print</a></span><span class='o'>(</span><span class='m'>2</span><span class='o'>)</span><span class='o'>)</span></span>
<span></span>
<span>  <span class='nf'><a href='https://rdrr.io/r/base/on.exit.html'>on.exit</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/print.html'>print</a></span><span class='o'>(</span><span class='m'>3</span><span class='o'>)</span>, add <span class='o'>=</span> <span class='kc'>TRUE</span>, after <span class='o'>=</span> <span class='kc'>FALSE</span><span class='o'>)</span></span>
<span></span>
<span>  <span class='nf'>withr</span><span class='nf'>::</span><span class='nf'><a href='https://withr.r-lib.org/reference/defer.html'>defer</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/print.html'>print</a></span><span class='o'>(</span><span class='m'>4</span><span class='o'>)</span><span class='o'>)</span></span>
<span></span>
<span>  <span class='nf'><a href='https://rdrr.io/r/base/print.html'>print</a></span><span class='o'>(</span><span class='m'>5</span><span class='o'>)</span></span>
<span><span class='o'>&#125;</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; [1] 5</span></span>
<span><span class='c'>#&gt; [1] 4</span></span>
<span><span class='c'>#&gt; [1] 3</span></span>
<span><span class='c'>#&gt; [1] 2</span></span>
<span><span class='c'>#&gt; [1] 1</span></span>
<span></span></code></pre>

</div>

But the main benefit is increased performance. Here is how `defer()` compared to [`on.exit()`](https://rdrr.io/r/base/on.exit.html) in the previous version:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>base</span> <span class='o'>&lt;-</span> <span class='kr'>function</span><span class='o'>(</span><span class='o'>)</span> <span class='nf'><a href='https://rdrr.io/r/base/on.exit.html'>on.exit</a></span><span class='o'>(</span><span class='kc'>NULL</span><span class='o'>)</span></span>
<span><span class='nv'>withr</span> <span class='o'>&lt;-</span> <span class='kr'>function</span><span class='o'>(</span><span class='o'>)</span> <span class='nf'>defer</span><span class='o'>(</span><span class='kc'>NULL</span><span class='o'>)</span></span>
<span></span>
<span><span class='c'># withr 2.5.2</span></span>
<span><span class='nf'>bench</span><span class='nf'>::</span><span class='nf'><a href='http://bench.r-lib.org/reference/mark.html'>mark</a></span><span class='o'>(</span><span class='nf'>base</span><span class='o'>(</span><span class='o'>)</span>, <span class='nf'>withr</span><span class='o'>(</span><span class='o'>)</span>, check <span class='o'>=</span> <span class='kc'>FALSE</span><span class='o'>)</span><span class='o'>[</span><span class='m'>1</span><span class='o'>:</span><span class='m'>8</span><span class='o'>]</span></span>
<span><span class='c'>#&gt; # A tibble: 2 × 8</span></span>
<span><span class='c'>#&gt;   expression      min median `itr/sec` mem_alloc `gc/sec` n_itr  n_gc</span></span>
<span><span class='c'>#&gt;   &lt;bch:expr&gt; &lt;bch:tm&gt; &lt;bch:&gt;     &lt;dbl&gt; &lt;bch:byt&gt;    &lt;dbl&gt; &lt;int&gt; &lt;dbl&gt;</span></span>
<span><span class='c'>#&gt; 1 base()            0   82ns  6954952.        0B    696.   9999     1</span></span>
<span><span class='c'>#&gt; 2 withr()      26.2µs 27.9µs    35172.    88.4KB     52.8  9985    15</span></span></code></pre>

</div>

withr 3.0.0 has now caught up to [`on.exit()`](https://rdrr.io/r/base/on.exit.html) quite a bit:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='c'># withr 3.0.0</span></span>
<span><span class='nf'>bench</span><span class='nf'>::</span><span class='nf'><a href='http://bench.r-lib.org/reference/mark.html'>mark</a></span><span class='o'>(</span><span class='nf'>base</span><span class='o'>(</span><span class='o'>)</span>, <span class='nf'>withr</span><span class='o'>(</span><span class='o'>)</span>, check <span class='o'>=</span> <span class='kc'>FALSE</span><span class='o'>)</span><span class='o'>[</span><span class='m'>1</span><span class='o'>:</span><span class='m'>8</span><span class='o'>]</span></span>
<span><span class='c'>#&gt; # A tibble: 2 × 8</span></span>
<span><span class='c'>#&gt;   expression      min median `itr/sec` mem_alloc `gc/sec` n_itr  n_gc</span></span>
<span><span class='c'>#&gt;   &lt;bch:expr&gt; &lt;bch:tm&gt; &lt;bch:&gt;     &lt;dbl&gt; &lt;bch:byt&gt;    &lt;dbl&gt; &lt;int&gt; &lt;dbl&gt;</span></span>
<span><span class='c'>#&gt; 1 base()            0   82ns  7329829.        0B       0  10000     0</span></span>
<span><span class='c'>#&gt; 2 withr()      2.95µs  3.4µs   280858.        0B     225.  9992     8</span></span></code></pre>

</div>

Of course [`on.exit()`](https://rdrr.io/r/base/on.exit.html) is still much faster, in part because `defer()` supports more features (more on that below), but mostly because `on.exit` is a primitive function whereas `defer()` is implemented as a normal R function. That said we hope that we now have made `defer()` (and the `local_` and `with_` functions that use it) sufficiently fast to be used even in performance-critical micro-tools.

## Improved withr features

Over the successive releases of withr we've improved the behaviour of cleanup expressions interactively, in scripts executed with [`source()`](https://rdrr.io/r/base/source.html), and in knitr.

[`on.exit()`](https://rdrr.io/r/base/on.exit.html) is a bit inconsistent when it is used outside of a function:

-   Interactively, it doesn't run at all
-   In [`source()`](https://rdrr.io/r/base/source.html) and in knitr, it runs "line by line" instead of a the end of the script

[`withr::defer()`](https://withr.r-lib.org/reference/defer.html) and the [`withr::local_`](https://withr.r-lib.org/reference/with_.html) helpers try to be more helpful for these cases.

Interactively, it saves the cleanup action in a special global hook and you get information about how to actually perform the cleanup:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>file</span> <span class='o'>&lt;-</span> <span class='nf'>withr</span><span class='nf'>::</span><span class='nf'><a href='https://withr.r-lib.org/reference/with_tempfile.html'>local_tempfile</a></span><span class='o'>(</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; Setting global deferred event(s).</span></span>
<span><span class='c'>#&gt; i These will be run:</span></span>
<span><span class='c'>#&gt;   * Automatically, when the R session ends.</span></span>
<span><span class='c'>#&gt;   * On demand, if you call `withr::deferred_run()`.</span></span>
<span><span class='c'>#&gt; i Use `withr::deferred_clear()` to clear them without executing.</span></span>
<span></span>
<span><span class='c'># Clean up now</span></span>
<span><span class='nf'>withr</span><span class='nf'>::</span><span class='nf'><a href='https://withr.r-lib.org/reference/defer.html'>deferred_run</a></span><span class='o'>(</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; Ran 1/1 deferred expressions</span></span></code></pre>

</div>

In knitr or [`source()`](https://rdrr.io/r/base/source.html)[^1], the cleanup is performed at the end of the document or of the script. If you need chunk-wide cleanup, use [`local()`](https://rdrr.io/r/base/eval.html) as we've been doing in the examples of this blog post:

```` md
Cleaning up at the end of the document:

```r
document_wide_file <- withr::local_tempfile()
```

Cleaning up at the end of the chunk:

```r
local({
  local_file <- withr::local_tempfile()
})
```
````

Starting from with 3.0.0, you can also run `deferred_run()` inside of a chunk:

```` md
```r
withr::deferred_run()
#> Ran 1/1 deferred expressions
```
````

## Acknowledgements

Thanks to the github contributors who helped us with this release!

[@ashbythorpe](https://github.com/ashbythorpe), [@bastistician](https://github.com/bastistician), [@DavisVaughan](https://github.com/DavisVaughan), [@fkohrt](https://github.com/fkohrt), [@gaborcsardi](https://github.com/gaborcsardi), [@gdurif](https://github.com/gdurif), [@hadley](https://github.com/hadley), [@HenrikBengtsson](https://github.com/HenrikBengtsson), [@honghaoli42](https://github.com/honghaoli42), [@IndrajeetPatil](https://github.com/IndrajeetPatil), [@jameslairdsmith](https://github.com/jameslairdsmith), [@jennybc](https://github.com/jennybc), [@jonkeane](https://github.com/jonkeane), [@krlmlr](https://github.com/krlmlr), [@lionel-](https://github.com/lionel-), [@maelle](https://github.com/maelle), [@MichaelChirico](https://github.com/MichaelChirico), [@MLopez-Ibanez](https://github.com/MLopez-Ibanez), [@moodymudskipper](https://github.com/moodymudskipper), [@multimeric](https://github.com/multimeric), [@orichters](https://github.com/orichters), [@pfuehrlich-pik](https://github.com/pfuehrlich-pik), [@solmos](https://github.com/solmos), [@tillea](https://github.com/tillea), and [@vanhry](https://github.com/vanhry).

[^1]: [`source()`](https://rdrr.io/r/base/source.html) is only supported by default when running in the global environment, which is usually the case. For the special case of sourcing in a local environment, you need to set `options(withr.hook_source = TRUE)` first.

