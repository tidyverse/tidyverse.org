---
output: hugodown::hugo_document

slug: mirai-2-5-0
title: mirai 2.5.0
date: 2025-09-04
author: Charlie Gao
description: >
    mirai - minimalist async evaluation framework for R - brings production-grade
    parallel and distributed computing to the ecosystem.
photo:
  url: https://unsplash.com/photos/a-bunch-of-different-colored-sashes-hanging-on-a-wall-OEiN_lSyQqE
  author: Matt Benson

# one of: "deep-dive", "learn", "package", "programming", "roundup", or "other"
categories: [package] 
tags: [mirai, parallelism]
rmd_hash: 6870bc4a0d57ef7f

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

We're excited to announce [mirai](https://mirai.r-lib.org) 2.5.0, bringing production-grade async computing to R!

This milestone release delivers enhanced observability through OpenTelemetry, reproducible parallel RNG, and key user interface improvements for compute profiles. We've also packed in twice as many [changes](https://mirai.r-lib.org/news/index.html) as usual - going all out in delivering a round of quality-of-life fixes to make your use of mirai even smoother!

You can install it from CRAN with:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://rdrr.io/r/utils/install.packages.html'>install.packages</a></span><span class='o'>(</span><span class='s'>"mirai"</span><span class='o'>)</span></span></code></pre>

</div>

## Introduction to mirai

mirai (Japanese for 'future') provides a clean, modern approach to parallel computing in R. Built on current communication technologies, it delivers extreme performance through professional-grade scheduling and an event-driven architecture.

It continues to evolve as the foundation for asynchronous and parallel computing across the R ecosystem, powering everything from [async Shiny](https://rstudio.github.io/promises/articles/promises_04_mirai.html) applications to [parallel map](https://www.tidyverse.org/blog/2025/07/purrr-1-1-0-parallel/) in purrr to [hyperparameter tuning](https://tune.tidymodels.org/news/index.html#parallel-processing-2-0-0) in tidymodels.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://mirai.r-lib.org'>mirai</a></span><span class='o'>)</span></span>
<span></span>
<span><span class='c'># Set up persistent background processes</span></span>
<span><span class='nf'><a href='https://mirai.r-lib.org/reference/daemons.html'>daemons</a></span><span class='o'>(</span><span class='m'>4</span><span class='o'>)</span></span>
<span></span>
<span><span class='c'># Async evaluation - non-blocking</span></span>
<span><span class='nv'>m</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://mirai.r-lib.org/reference/mirai.html'>mirai</a></span><span class='o'>(</span><span class='o'>&#123;</span></span>
<span>  <span class='nf'><a href='https://rdrr.io/r/base/Sys.sleep.html'>Sys.sleep</a></span><span class='o'>(</span><span class='m'>1</span><span class='o'>)</span></span>
<span>  <span class='m'>100</span> <span class='o'>+</span> <span class='m'>42</span></span>
<span><span class='o'>&#125;</span><span class='o'>)</span></span>
<span><span class='nv'>m</span></span>
<span><span class='c'>#&gt; &lt; mirai [] &gt;</span></span>
<span></span><span></span>
<span><span class='c'># Results are available when ready</span></span>
<span><span class='nv'>m</span><span class='o'>[</span><span class='o'>]</span></span>
<span><span class='c'>#&gt; [1] 142</span></span>
<span></span><span></span>
<span><span class='c'># Shut down persistent background processes</span></span>
<span><span class='nf'><a href='https://mirai.r-lib.org/reference/daemons.html'>daemons</a></span><span class='o'>(</span><span class='m'>0</span><span class='o'>)</span></span></code></pre>

</div>

## A unique design philosophy

### Modern foundation

mirai builds on [nanonext](https://nanonext.r-lib.org), the R binding to Nanomsg Next Generation, a high-performance messaging library designed for distributed systems. This means that it's using the very latest technologies, and supports the most optimal connections out of the box: IPC (inter-process communications), TCP or secure TLS. It also extends base R's serialization mechanism to support custom serialization of newer cross-language data formats such as safetensors, Arrow and Polars.

### Extreme performance

As a consequence of its solid technological foundation, mirai has the proven capacity to scale to millions of concurrent tasks over thousands of connections. Moreover, it delivers up to 1,000x the efficiency and responsiveness of common alternatives. A key innovation is the implementation of event-driven promises that react with zero latency - this provides an extra edge for real-time applications such as live inference or Shiny apps.

### Production first

mirai provides a clear mental model for parallel computation, with a clean separation of a user's current environment with that in which a mirai is evaluated. This explicitness and simplicity helps avoid common pitfalls that can afflict parallel processing, such as capturing incorrect or extraneous variables. Transparency and robustness are key to mirai's design, and are achieved by minimizing complexity, and eliminating all hidden state with no reliance on options or environment variables. Finally, its integration with OpenTelemetry provides for production-grade observability.

### Deploy everywhere

Deployment of daemon processes is made through a consistent interface across local, remote (SSH), and [HPC environments](https://shikokuchuo.net/posts/27-mirai-240/) (Slurm, SGE, PBS, LSF). Compute profiles are daemons settings that are managed independently, such that you can be connected to all three resource types simultaneously. You then have the freedom to distribute workload to the most appropriate resource for any given task - especially important if tasks have differing requirements such as GPU compute.

## OpenTelemetry integration

New in mirai 2.5.0: complete observability of mirai requests through OpenTelemetry traces. This is a core feature that completes the final pillar in mirai's 'production first' design philosophy.

When tracing is enabled via the otel and otelsdk packages, you can monitor the entire lifecycle of your async computations, from creation through to evaluation, making it easier to debug and optimize performance in production environments. This is especially powerful when used in conjunction with other otel-enabled packages (such as an upcoming Shiny release), providing end-to-end observability across your entire application stack.

<figure>
<img src="otel-screenshot.png" alt="Illustrative OpenTelemetry span structure shown in a Jaeger collector UI" />
<figcaption aria-hidden="true"><em>Illustrative OpenTelemetry span structure shown in a Jaeger collector UI</em></figcaption>
</figure>

## Reproducible parallel RNG

Introduced in mirai 2.4.1: reproducible parallel random number generation. Developed in consultation with our tidymodels colleagues and core members of the mlr team, this is a great example of the R community pulling together to solve a common problem. It addresses a long-standing challenge in parallel computing in R, important for reproducible science.

mirai has, since its early days, used L'Ecuyer-CMRG streams for statistically-sound parallel RNG. Streams essentially cut into the RNG's period (a very long sequence of pseudo-random numbers) at intervals that are far apart from each other that they do not in practice overlap. This ensures that statistical results obtained from parallel computations remain correct and valid.

Previously, we only offered the following option, matching the behaviour of base R's parallel package:

**Default behaviour** `daemons(seed = NULL)`: creates independent streams for each daemon. This ensures statistical validity but not numerical reproducibility between runs.

Now, we also offer the following option:

**Reproducible mode** `daemons(seed = integer)`: creates a stream for each [`mirai()`](https://mirai.r-lib.org/reference/mirai.html) call rather than each daemon. This guarantees identical results across runs, regardless of the number of daemons used.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='c'># Always provides identical results:</span></span>
<span></span>
<span><span class='nf'><a href='https://rdrr.io/r/base/with.html'>with</a></span><span class='o'>(</span></span>
<span>  <span class='nf'><a href='https://mirai.r-lib.org/reference/daemons.html'>daemons</a></span><span class='o'>(</span><span class='m'>3</span>, seed <span class='o'>=</span> <span class='m'>1234L</span><span class='o'>)</span>,</span>
<span>  <span class='nf'><a href='https://mirai.r-lib.org/reference/mirai_map.html'>mirai_map</a></span><span class='o'>(</span><span class='m'>1</span><span class='o'>:</span><span class='m'>3</span>, <span class='nv'>rnorm</span>, .args <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span>mean <span class='o'>=</span> <span class='m'>20</span>, sd <span class='o'>=</span> <span class='m'>2</span><span class='o'>)</span><span class='o'>)</span><span class='o'>[</span><span class='o'>]</span></span>
<span><span class='o'>)</span></span>
<span><span class='c'>#&gt; [[1]]</span></span>
<span><span class='c'>#&gt; [1] 19.86409</span></span>
<span><span class='c'>#&gt; </span></span>
<span><span class='c'>#&gt; [[2]]</span></span>
<span><span class='c'>#&gt; [1] 19.55834 22.30159</span></span>
<span><span class='c'>#&gt; </span></span>
<span><span class='c'>#&gt; [[3]]</span></span>
<span><span class='c'>#&gt; [1] 20.62193 23.06144 19.61896</span></span>
<span></span></code></pre>

</div>

## User interface improvements

### Compute profile helper functions

[`with_daemons()`](https://mirai.r-lib.org/reference/with_daemons.html) and [`local_daemons()`](https://mirai.r-lib.org/reference/with_daemons.html) make working with compute profiles much more convenient by allowing the temporary switching of contexts. This means that developers can continue to write mirai code without worrying about the resources on which it is eventually run. End-users now have the ability to change the destination of any mirai computation dynamically using one of these scoped helpers.

``` r
# Work with specific compute profiles
with_daemons("gpu", {
  result <- mirai(gpu_intensive_task())
})

# Local version for use inside functions
async_gpu_intensive_task <- function() {
  local_daemons("gpu")
  mirai(gpu_intensive_task())
}
```

### Re-designed `daemons()`

Creating new daemons is now more ergonomic, as it automatically resets existing ones. This provides for more convenient use in contexts such as notebooks, where cells may be run out of order. Manual `daemons(0)` calls are no longer required to reset daemons.

``` r
# Old approach
daemons(0)  # Had to reset first
daemons(4)

# New approach - automatic reset
daemons(4)  # Just works, resets if needed
```

### New `info()` function

Provides a more succinct alternative to [`status()`](https://mirai.r-lib.org/reference/status.html) for reporting key statistics. This is optimized and is now a supported developer interface for programmatic use.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://mirai.r-lib.org/reference/info.html'>info</a></span><span class='o'>(</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; connections  cumulative    awaiting   executing   completed </span></span>
<span><span class='c'>#&gt;           4           4           8           4           2</span></span></code></pre>

</div>

## Acknowledgements

We extend our gratitude to the R community for their continued feedback and contributions. Special thanks to all contributors who helped shape this release through feature requests, bug reports, and code contributions: [@agilly](https://github.com/agilly), [@D3SL](https://github.com/D3SL), [@DavZim](https://github.com/DavZim), [@dipterix](https://github.com/dipterix), [@eliocamp](https://github.com/eliocamp), [@erydit](https://github.com/erydit), [@karangattu](https://github.com/karangattu), [@louisaslett](https://github.com/louisaslett), [@mikkmart](https://github.com/mikkmart), [@sebffischer](https://github.com/sebffischer), [@shikokuchuo](https://github.com/shikokuchuo), and [@wlandau](https://github.com/wlandau).

