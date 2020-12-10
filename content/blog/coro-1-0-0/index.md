---
output: hugodown::hugo_document

slug: coro-1-0-0
title: Coroutines for R!
date: 2020-12-10
author: Lionel Henry
description: >
    A 2-3 sentence description of the post that appears on the articles page.
    This can be omitted if it would just recapitulate the title.

photo:
  url: https://unsplash.com/photos/n6vS3xlnsCc
  author: Kelley Bozarth

categories: [package]
tags: []
rmd_hash: fc24175ee5d04ac9

---

<!--
TODO:
* [ ] Pick category and tags (see existing with `post_tags()`)
* [ ] Find photo & update yaml metadata
* [ ] Create `thumbnail-sq.jpg`; height and width should be equal
* [ ] Create `thumbnail-wd.jpg`; width should be >5x height
* [ ] `hugodown::use_tidy_thumbnail()`
* [ ] Add intro sentence
* [ ] `use_tidy_thanks()`
-->

It is with unabated jolliness that we announce the first release of [coro](https://coro.r-lib.org/)! coro implements coroutines for R, a kind of functions that can suspend and resume themselves before their final [`return()`](https://rdrr.io/r/base/function.html). Coroutines have proved to be very useful in other languages for creating complex lazy sequences (with generators) and concurrent code that is easy for humans to read and write (with async functions).

You can install coro from CRAN with:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://rdrr.io/r/utils/install.packages.html'>install.packages</a></span><span class='o'>(</span><span class='s'>"coro"</span><span class='o'>)</span>
</code></pre>

</div>

This blog post will introduce the two sorts of coroutines implemented in coro, generators and coroutines. It will also demonstrate how to use these coroutines in your workflow for existing packages like reticulate and shiny.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://github.com/r-lib/coro'>coro</a></span><span class='o'>)</span>
</code></pre>

</div>

Coroutines
----------

Coroutines are a special sort of functions that can suspend themselves and resume later on. There are two kinds implemented in coro:

-   Generators which lazily produce values for complex sequences. Here laziness means that the values are produced on demand rather than ahead of time. Because they are lazy, these sequences may be infinite or produce objects that are too large to be held in memory all at once.

-   Async functions which work together with a scheduler of concurrent functions. Async functions suspend themselves when they can't make progress until some computation has finished or some event has occurred. The scheduler then launches a new concurrent computation or resumes a suspended async function that is now ready to make progress.

The common property of all coroutines is that they start to perform some work, decide that they have done enough work for now, and return an object to their caller. It is the caller which decides when to call the coroutine again to do some more work. Whereas generators communicate intermediate values to you, the user, async functions exclusively communicate in the background with a scheduler of concurrent computations.

Generators
----------

In coro the term "generator" refers to two sorts of functions:

-   Generator factories
-   Generator instances

[`coro::generator()`](https://rdrr.io/pkg/coro/man/generator.html) creates generator factories. These factories in turn create fresh generator instances. Generator factories look like normal function definitions for the most part, except that you can [`yield()`](https://rdrr.io/pkg/coro/man/yield.html) values.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='c'># Create a generator factory</span>
<span class='nv'>generate_abc</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/pkg/coro/man/generator.html'>generator</a></span><span class='o'>(</span><span class='kr'>function</span><span class='o'>(</span><span class='o'>)</span> <span class='o'>&#123;</span>
  <span class='nf'><a href='https://rdrr.io/pkg/coro/man/yield.html'>yield</a></span><span class='o'>(</span><span class='s'>"a"</span><span class='o'>)</span>
  <span class='nf'><a href='https://rdrr.io/pkg/coro/man/yield.html'>yield</a></span><span class='o'>(</span><span class='s'>"b"</span><span class='o'>)</span>
  <span class='s'>"c"</span>
<span class='o'>&#125;</span><span class='o'>)</span>
</code></pre>

</div>

The other difference with normal functions is that generator factories don't return a value immediately. They return a function object, a fresh generator *instance*.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='c'># Create a generator instance</span>
<span class='nv'>abc</span> <span class='o'>&lt;-</span> <span class='nf'>generate_abc</span><span class='o'>(</span><span class='o'>)</span>

<span class='nv'>abc</span>

<span class='c'>#&gt; &lt;generator/instance&gt;</span>
<span class='c'>#&gt; function() &#123;</span>
<span class='c'>#&gt;   yield("a")</span>
<span class='c'>#&gt;   yield("b")</span>
<span class='c'>#&gt;   "c"</span>
<span class='c'>#&gt; &#125;</span>
</code></pre>

</div>

A generator instance is called repeatedly, as many times as necessary. Each time, it *yields* a value. The last value is *returned*. Once a generator has returned, it becomes stale and returns an exhaustion value when it is run again.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'>abc</span><span class='o'>(</span><span class='o'>)</span>

<span class='c'>#&gt; [1] "a"</span>


<span class='nf'>abc</span><span class='o'>(</span><span class='o'>)</span>

<span class='c'>#&gt; [1] "b"</span>


<span class='nf'>abc</span><span class='o'>(</span><span class='o'>)</span>

<span class='c'>#&gt; [1] "c"</span>


<span class='nf'>abc</span><span class='o'>(</span><span class='o'>)</span>

<span class='c'>#&gt; exhausted</span>


<span class='nf'>abc</span><span class='o'>(</span><span class='o'>)</span>

<span class='c'>#&gt; exhausted</span>


<span class='nf'><a href='https://rdrr.io/pkg/coro/man/iterator.html'>is_exhausted</a></span><span class='o'>(</span><span class='nf'>abc</span><span class='o'>(</span><span class='o'>)</span><span class='o'>)</span>

<span class='c'>#&gt; [1] TRUE</span>
</code></pre>

</div>

Generators can [`yield()`](https://rdrr.io/pkg/coro/man/yield.html) flexibly inside `if` branches, loops, or [`tryCatch()`](https://rdrr.io/r/base/conditions.html) expressions. For instance we could rewrite the `abc` generator with a loop:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>generate_abc</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/pkg/coro/man/generator.html'>generator</a></span><span class='o'>(</span><span class='kr'>function</span><span class='o'>(</span><span class='o'>)</span> <span class='o'>&#123;</span>
 <span class='kr'>for</span> <span class='o'>(</span><span class='nv'>x</span> <span class='kr'>in</span> <span class='nv'>letters</span><span class='o'>[</span><span class='m'>1</span><span class='o'>:</span><span class='m'>3</span><span class='o'>]</span><span class='o'>)</span> <span class='o'>&#123;</span>
   <span class='nf'><a href='https://rdrr.io/pkg/coro/man/yield.html'>yield</a></span><span class='o'>(</span><span class='nv'>x</span><span class='o'>)</span>
 <span class='o'>&#125;</span>
<span class='o'>&#125;</span><span class='o'>)</span>
</code></pre>

</div>

To make things a bit more complex, we could yield conditionally inside the loop to return only every other letter:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>generate_odd_letters</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/pkg/coro/man/generator.html'>generator</a></span><span class='o'>(</span><span class='kr'>function</span><span class='o'>(</span><span class='o'>)</span> <span class='o'>&#123;</span>
  <span class='kr'>for</span> <span class='o'>(</span><span class='nv'>i</span> <span class='kr'>in</span> <span class='nf'><a href='https://rdrr.io/r/base/seq.html'>seq_along</a></span><span class='o'>(</span><span class='nv'>letters</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>&#123;</span>
    <span class='kr'>if</span> <span class='o'>(</span><span class='nv'>i</span> <span class='o'>%%</span> <span class='m'>2</span> <span class='o'>!=</span> <span class='m'>0</span><span class='o'>)</span> <span class='o'>&#123;</span>
      <span class='nf'><a href='https://rdrr.io/pkg/coro/man/yield.html'>yield</a></span><span class='o'>(</span><span class='nv'>letters</span><span class='o'>[[</span><span class='nv'>i</span><span class='o'>]</span><span class='o'>]</span><span class='o'>)</span>
    <span class='o'>&#125;</span>
 <span class='o'>&#125;</span>
<span class='o'>&#125;</span><span class='o'>)</span>

<span class='nv'>odd_letters</span> <span class='o'>&lt;-</span> <span class='nf'>generate_odd_letters</span><span class='o'>(</span><span class='o'>)</span>

<span class='nf'>odd_letters</span><span class='o'>(</span><span class='o'>)</span>

<span class='c'>#&gt; [1] "a"</span>


<span class='nf'>odd_letters</span><span class='o'>(</span><span class='o'>)</span>

<span class='c'>#&gt; [1] "c"</span>


<span class='nf'>odd_letters</span><span class='o'>(</span><span class='o'>)</span>

<span class='c'>#&gt; [1] "e"</span>
</code></pre>

</div>

### Working with iterators

Technically, generator instances are **iterator functions**. Calling them repeatedly advances the iteration step by step until exhaustion. coro provides two helpers that make it easy to work with iterator functions.

-   [`coro::loop()`](https://rdrr.io/pkg/coro/man/collect.html) instruments `for` so that it understands how to loop over these iterators:

    <div class="highlight">

    <pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://rdrr.io/pkg/coro/man/collect.html'>loop</a></span><span class='o'>(</span><span class='kr'>for</span> <span class='o'>(</span><span class='nv'>x</span> <span class='kr'>in</span> <span class='nf'>generate_abc</span><span class='o'>(</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>&#123;</span>
      <span class='nf'><a href='https://rdrr.io/r/base/print.html'>print</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/chartr.html'>toupper</a></span><span class='o'>(</span><span class='nv'>x</span><span class='o'>)</span><span class='o'>)</span>
    <span class='o'>&#125;</span><span class='o'>)</span>

    <span class='c'>#&gt; [1] "A"</span>
    <span class='c'>#&gt; [1] "B"</span>
    <span class='c'>#&gt; [1] "C"</span>
    </code></pre>

    </div>

-   [`coro::collect()`](https://rdrr.io/pkg/coro/man/collect.html) loops over the iterator and collects all values in a list:

    <div class="highlight">

    <pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://rdrr.io/pkg/coro/man/collect.html'>collect</a></span><span class='o'>(</span><span class='nf'>generate_abc</span><span class='o'>(</span><span class='o'>)</span><span class='o'>)</span>

    <span class='c'>#&gt; [[1]]</span>
    <span class='c'>#&gt; [1] "a"</span>
    <span class='c'>#&gt; </span>
    <span class='c'>#&gt; [[2]]</span>
    <span class='c'>#&gt; [1] "b"</span>
    <span class='c'>#&gt; </span>
    <span class='c'>#&gt; [[3]]</span>
    <span class='c'>#&gt; [1] "c"</span>
    </code></pre>

    </div>

    You can also supply a certain number of elements to collect:

    <div class="highlight">

    <pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>odd_letters</span> <span class='o'>&lt;-</span> <span class='nf'>generate_odd_letters</span><span class='o'>(</span><span class='o'>)</span>

    <span class='nf'><a href='https://rdrr.io/pkg/coro/man/collect.html'>collect</a></span><span class='o'>(</span><span class='nv'>odd_letters</span>, n <span class='o'>=</span> <span class='m'>3</span><span class='o'>)</span>

    <span class='c'>#&gt; [[1]]</span>
    <span class='c'>#&gt; [1] "a"</span>
    <span class='c'>#&gt; </span>
    <span class='c'>#&gt; [[2]]</span>
    <span class='c'>#&gt; [1] "c"</span>
    <span class='c'>#&gt; </span>
    <span class='c'>#&gt; [[3]]</span>
    <span class='c'>#&gt; [1] "e"</span>


    <span class='nf'><a href='https://rdrr.io/pkg/coro/man/collect.html'>collect</a></span><span class='o'>(</span><span class='nv'>odd_letters</span>, n <span class='o'>=</span> <span class='m'>2</span><span class='o'>)</span>

    <span class='c'>#&gt; [[1]]</span>
    <span class='c'>#&gt; [1] "g"</span>
    <span class='c'>#&gt; </span>
    <span class='c'>#&gt; [[2]]</span>
    <span class='c'>#&gt; [1] "i"</span>
    </code></pre>

    </div>

In a generator function, all `for` loops natively understand iterators. This makes it easy to chain generators. A generator that takes other generators as input to modify their values is called an *adaptor*:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>adapt_prefix</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/pkg/coro/man/generator.html'>generator</a></span><span class='o'>(</span><span class='kr'>function</span><span class='o'>(</span><span class='nv'>it</span>, <span class='nv'>prefix</span><span class='o'>)</span> <span class='o'>&#123;</span>
  <span class='kr'>for</span> <span class='o'>(</span><span class='nv'>x</span> <span class='kr'>in</span> <span class='nv'>it</span><span class='o'>)</span> <span class='o'>&#123;</span>
    <span class='nf'><a href='https://rdrr.io/pkg/coro/man/yield.html'>yield</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/paste.html'>paste0</a></span><span class='o'>(</span><span class='nv'>prefix</span>, <span class='nv'>x</span><span class='o'>)</span><span class='o'>)</span>
  <span class='o'>&#125;</span>
<span class='o'>&#125;</span><span class='o'>)</span>

<span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://magrittr.tidyverse.org'>magrittr</a></span><span class='o'>)</span>

<span class='nf'>generate_abc</span><span class='o'>(</span><span class='o'>)</span> <span class='o'>%&gt;%</span> <span class='nf'>adapt_prefix</span><span class='o'>(</span><span class='s'>"foo_"</span><span class='o'>)</span> <span class='o'>%&gt;%</span> <span class='nf'><a href='https://rdrr.io/pkg/coro/man/collect.html'>collect</a></span><span class='o'>(</span><span class='o'>)</span>

<span class='c'>#&gt; [[1]]</span>
<span class='c'>#&gt; [1] "foo_a"</span>
<span class='c'>#&gt; </span>
<span class='c'>#&gt; [[2]]</span>
<span class='c'>#&gt; [1] "foo_b"</span>
<span class='c'>#&gt; </span>
<span class='c'>#&gt; [[3]]</span>
<span class='c'>#&gt; [1] "foo_c"</span>
</code></pre>

</div>

### Compatibility with reticulate

Python iterators from the [reticulate](https://rstudio.github.io/reticulate/) package are fully compatible with coro. Let's create a Python generator for the first `n` integers:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://rdrr.io/r/base/message.html'>suppressMessages</a></span><span class='o'>(</span>
  <span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://github.com/rstudio/reticulate'>reticulate</a></span><span class='o'>)</span>
<span class='o'>)</span>

<span class='nf'><a href='https://rdrr.io/pkg/reticulate/man/py_run.html'>py_run_string</a></span><span class='o'>(</span><span class='s'>"
def first_n(n):
    num = 1
    while num &lt;= n:
        yield num
        num += 1
"</span><span class='o'>)</span>
</code></pre>

</div>

You can [`loop()`](https://rdrr.io/pkg/coro/man/collect.html) over iterators created by this generator:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>first_3</span> <span class='o'>&lt;-</span> <span class='nv'>py</span><span class='o'>$</span><span class='nf'>first_n</span><span class='o'>(</span><span class='m'>3</span><span class='o'>)</span>

<span class='nf'><a href='https://rdrr.io/pkg/coro/man/collect.html'>loop</a></span><span class='o'>(</span><span class='kr'>for</span> <span class='o'>(</span><span class='nv'>x</span> <span class='kr'>in</span> <span class='nv'>first_3</span><span class='o'>)</span> <span class='o'>&#123;</span>
  <span class='nf'><a href='https://rdrr.io/r/base/print.html'>print</a></span><span class='o'>(</span><span class='nv'>x</span> <span class='o'>*</span> <span class='m'>2</span><span class='o'>)</span>
<span class='o'>&#125;</span><span class='o'>)</span>

<span class='c'>#&gt; [1] 2</span>
<span class='c'>#&gt; [1] 4</span>
<span class='c'>#&gt; [1] 6</span>
</code></pre>

</div>

You can [`collect()`](https://rdrr.io/pkg/coro/man/collect.html) the values:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://rdrr.io/pkg/coro/man/collect.html'>collect</a></span><span class='o'>(</span><span class='nv'>py</span><span class='o'>$</span><span class='nf'>first_n</span><span class='o'>(</span><span class='m'>3</span><span class='o'>)</span><span class='o'>)</span>

<span class='c'>#&gt; [[1]]</span>
<span class='c'>#&gt; [1] 1</span>
<span class='c'>#&gt; </span>
<span class='c'>#&gt; [[2]]</span>
<span class='c'>#&gt; [1] 2</span>
<span class='c'>#&gt; </span>
<span class='c'>#&gt; [[3]]</span>
<span class='c'>#&gt; [1] 3</span>
</code></pre>

</div>

And you can chain them with coro generators:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>adapt_plus</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/pkg/coro/man/generator.html'>generator</a></span><span class='o'>(</span><span class='kr'>function</span><span class='o'>(</span><span class='nv'>it</span>, <span class='nv'>n</span><span class='o'>)</span> <span class='o'>&#123;</span>
  <span class='kr'>for</span> <span class='o'>(</span><span class='nv'>x</span> <span class='kr'>in</span> <span class='nv'>it</span><span class='o'>)</span> <span class='nf'><a href='https://rdrr.io/pkg/coro/man/yield.html'>yield</a></span><span class='o'>(</span><span class='nv'>x</span> <span class='o'>+</span> <span class='nv'>n</span><span class='o'>)</span>
<span class='o'>&#125;</span><span class='o'>)</span>

<span class='nv'>py</span><span class='o'>$</span><span class='nf'>first_n</span><span class='o'>(</span><span class='m'>3</span><span class='o'>)</span> <span class='o'>%&gt;%</span> <span class='nf'>adapt_plus</span><span class='o'>(</span><span class='m'>10</span><span class='o'>)</span> <span class='o'>%&gt;%</span> <span class='nf'><a href='https://rdrr.io/pkg/coro/man/collect.html'>collect</a></span><span class='o'>(</span><span class='o'>)</span>

<span class='c'>#&gt; [[1]]</span>
<span class='c'>#&gt; [1] 11</span>
<span class='c'>#&gt; </span>
<span class='c'>#&gt; [[2]]</span>
<span class='c'>#&gt; [1] 12</span>
<span class='c'>#&gt; </span>
<span class='c'>#&gt; [[3]]</span>
<span class='c'>#&gt; [1] 13</span>
</code></pre>

</div>

### When should I use generators?

Generators are important in Python because they provide a flexible way of creating iterators and these are at the heart of the language. However, whereas Python is scalar oriented, R is a vector oriented language. As a result, it is generally more efficient to take advantage of vectorisation when possible.

Also, since R is a functional language, iterators are a bit awkward to work with because they are *stateful*. Advancing an iterator changes the state of R. To reproduce yielded values, you need to start over.

For these reasons, generators are likely not the most appropriate way of solving your problems in R. In most cases it will be more efficient and natural to work with vectorised or functional idioms. On the other hand, vectorised and functional idioms do not work so well when:

-   The data doesn't fit in memory. Infinite sequences are an extreme case of this. When you can't work with all the data at once, it must be chunked into more manageable slices.

-   The sequence is complex or you don't need to compute all of it in advance.

Generators are a good way of structuring computations on chunked data and lazy sequences.

Async functions
---------------

The most useful application of generators is to create *cooperative* concurrency. In that paradigm, generators are concurrent computations that politely yield to each other so that they can both make progress in a given lapse of time. This pattern is so useful and instinctive that it has been captured in a convenient syntax in many languages in the form of **async** functions.

An async function definition looks a bit like a generator factory except that the keyword [`yield()`](https://rdrr.io/pkg/coro/man/yield.html) is replaced by [`await()`](https://rdrr.io/pkg/coro/man/async.html):

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>my_async</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/pkg/coro/man/async.html'>async</a></span><span class='o'>(</span><span class='kr'>function</span><span class='o'>(</span><span class='nv'>url</span><span class='o'>)</span> <span class='o'>&#123;</span>
  <span class='nv'>file</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/pkg/coro/man/async.html'>await</a></span><span class='o'>(</span><span class='nf'>async_some_download</span><span class='o'>(</span><span class='nv'>url</span><span class='o'>)</span><span class='o'>)</span>
  <span class='nf'><a href='https://rdrr.io/r/utils/head.html'>head</a></span><span class='o'>(</span><span class='nv'>file</span><span class='o'>)</span>
<span class='o'>&#125;</span><span class='o'>)</span>
</code></pre>

</div>

[`await()`](https://rdrr.io/pkg/coro/man/async.html) takes a promise object as defined in the [promises](https://rstudio.github.io/promises/) package. It also supports objects coercible to promises, such as [`future::future()`](https://rdrr.io/pkg/future/man/future.html). When an async function uses [`await()`](https://rdrr.io/pkg/coro/man/async.html), it registers itself to be called back once the promise has run to completion and a value is ready. Control is yielded to the scheduler and the next async computation that is ready to make progress is run.

All async functions are then-able because they return a promise object. You can [`await()`](https://rdrr.io/pkg/coro/man/async.html) an async function or chain it with [`promises::then()`](https://rstudio.github.io/promises/reference/then.html).

### Waiting for results

Your async function should use [`await()`](https://rdrr.io/pkg/coro/man/async.html) when it can no longer make progress on its own because it is waiting for a result. For example because it is downloading a file or waiting for a computation in another R process. While your async function is waiting, other concurrent functions get a chance to run.

Cooperative concurrency is especially important when you are writing Shiny applications because the reactive components that update the Shiny UI are only run when R is idle. If a function doesn't give up control while it is waiting for a result, the Shiny UI stops reacting to user inputs. From the user point of view, it appears as if the app is freezing.

TODO: `future()`

### Courtesy yields

If your async function is iterating over a long loop, you may consider politely yielding to other concurrent routines by calling [`await()`](https://rdrr.io/pkg/coro/man/async.html) without argument. In this case, [`await()`](https://rdrr.io/pkg/coro/man/async.html) does not signal that you are waiting for a value, only that you would like Shiny and other concurrent functions to make progress as well after you've been busy for a while.

To illustrate this, take the following function. It writes a message in a loop every 10 iterations.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>async_print_progress</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/pkg/coro/man/async.html'>async</a></span><span class='o'>(</span><span class='kr'>function</span><span class='o'>(</span><span class='nv'>msg</span>, <span class='nv'>n</span> <span class='o'>=</span> <span class='m'>30</span><span class='o'>)</span> <span class='o'>&#123;</span>
  <span class='kr'>for</span> <span class='o'>(</span><span class='nv'>i</span> <span class='kr'>in</span> <span class='nf'><a href='https://rdrr.io/r/base/seq.html'>seq_len</a></span><span class='o'>(</span><span class='nv'>n</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>&#123;</span>
    <span class='kr'>if</span> <span class='o'>(</span><span class='nv'>i</span> <span class='o'>%%</span> <span class='m'>10</span> <span class='o'>==</span> <span class='m'>0</span><span class='o'>)</span> <span class='o'>&#123;</span>
      <span class='c'># Print message every 10 iterations</span>
      <span class='nf'><a href='https://rdrr.io/r/base/writeLines.html'>writeLines</a></span><span class='o'>(</span><span class='nv'>msg</span><span class='o'>)</span>
    <span class='o'>&#125;</span>
  <span class='o'>&#125;</span>

  <span class='nf'><a href='https://rdrr.io/r/base/writeLines.html'>writeLines</a></span><span class='o'>(</span><span class='s'>"Done"</span><span class='o'>)</span>
<span class='o'>&#125;</span><span class='o'>)</span>
</code></pre>

</div>

Running two instances of this function concurrently reveals the problem. The first instance is run to completion and only then the other instance can start doing some work.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'>promises</span><span class='nf'>::</span><span class='nf'><a href='https://rstudio.github.io/promises/reference/promise_all.html'>promise_all</a></span><span class='o'>(</span>
  <span class='nf'>async_print_progress</span><span class='o'>(</span><span class='s'>"foo"</span><span class='o'>)</span>,
  <span class='nf'>async_print_progress</span><span class='o'>(</span><span class='s'>"bar"</span><span class='o'>)</span>
<span class='o'>)</span>
<span class='c'>#&gt; foo</span>
<span class='c'>#&gt; foo</span>
<span class='c'>#&gt; foo</span>
<span class='c'>#&gt; Done</span>
<span class='c'>#&gt; bar</span>
<span class='c'>#&gt; bar</span>
<span class='c'>#&gt; bar</span>
<span class='c'>#&gt; Done</span>
</code></pre>

</div>

Calling [`await()`](https://rdrr.io/pkg/coro/man/async.html) inside the loop improves the concurrency of your function because it allows other routines to take their turn. It doesn't need to be called at each iteration. Every 1000 iterations is often sufficient because, if an iteration takes too much time, you should probably consider running it in another process to start with. In this example we yield every 10 iterations right after printing the message:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>async_print_progress</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/pkg/coro/man/async.html'>async</a></span><span class='o'>(</span><span class='kr'>function</span><span class='o'>(</span><span class='nv'>msg</span>, <span class='nv'>n</span> <span class='o'>=</span> <span class='m'>30</span><span class='o'>)</span> <span class='o'>&#123;</span>
  <span class='kr'>for</span> <span class='o'>(</span><span class='nv'>i</span> <span class='kr'>in</span> <span class='nf'><a href='https://rdrr.io/r/base/seq.html'>seq_len</a></span><span class='o'>(</span><span class='nv'>n</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>&#123;</span>
    <span class='kr'>if</span> <span class='o'>(</span><span class='nv'>i</span> <span class='o'>%%</span> <span class='m'>10</span> <span class='o'>==</span> <span class='m'>0</span><span class='o'>)</span> <span class='o'>&#123;</span>
      <span class='c'># Print message every 10 iterations</span>
      <span class='nf'><a href='https://rdrr.io/r/base/writeLines.html'>writeLines</a></span><span class='o'>(</span><span class='nv'>msg</span><span class='o'>)</span>

      <span class='c'># Courtesy yield</span>
      <span class='nf'><a href='https://rdrr.io/pkg/coro/man/async.html'>await</a></span><span class='o'>(</span><span class='o'>)</span>
    <span class='o'>&#125;</span>
  <span class='o'>&#125;</span>

  <span class='nf'><a href='https://rdrr.io/r/base/writeLines.html'>writeLines</a></span><span class='o'>(</span><span class='s'>"Done"</span><span class='o'>)</span>
<span class='o'>&#125;</span><span class='o'>)</span>
</code></pre>

</div>

The cooperative call to [`await()`](https://rdrr.io/pkg/coro/man/async.html) allows other routines to run concurrently:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'>promises</span><span class='nf'>::</span><span class='nf'><a href='https://rstudio.github.io/promises/reference/promise_all.html'>promise_all</a></span><span class='o'>(</span>
  <span class='nf'>async_print_progress</span><span class='o'>(</span><span class='s'>"foo"</span><span class='o'>)</span>,
  <span class='nf'>async_print_progress</span><span class='o'>(</span><span class='s'>"bar"</span><span class='o'>)</span>
<span class='o'>)</span>
<span class='c'>#&gt; foo</span>
<span class='c'>#&gt; bar</span>
<span class='c'>#&gt; foo</span>
<span class='c'>#&gt; bar</span>
<span class='c'>#&gt; foo</span>
<span class='c'>#&gt; bar</span>
<span class='c'>#&gt; Done</span>
<span class='c'>#&gt; Done</span>
</code></pre>

</div>

