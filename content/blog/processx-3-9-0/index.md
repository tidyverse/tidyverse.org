---
output: hugodown::hugo_document
slug: processx-3-9-0
title: processx 3.9.0
date: 2026-04-27
author: Gábor Csárdi
description: >
    processx 3.9.0 brings kernel-level process pipelines, pseudo-terminal
    support on Windows, Linux parent-death signals, binary I/O, and several
    other quality-of-life improvements.

photo:
  url: https://unsplash.com/photos/scUBcasSvbE
  author: Samuel Sianipar

# one of: "deep-dive", "learn", "package", "programming", "roundup", or "other"
categories: [package]
tags: [package, processx, processes, system]
rmd_hash: d24f657f2df3a587

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
* [x] ~~[`usethis::use_tidy_thanks()`](https://usethis.r-lib.org/reference/use_tidy_thanks.html)~~
-->

We're happy to announce the release of [processx](https://processx.r-lib.org/) 3.9.0. processx is an R package to run and manage system processes.

You can install it from CRAN with:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://rdrr.io/r/utils/install.packages.html'>install.packages</a></span><span class='o'>(</span><span class='s'>"processx"</span><span class='o'>)</span></span></code></pre>

</div>

This blog post discusses the major new features in processx 3.9.0. You can see a full list of changes in the [release notes](https://github.com/r-lib/processx/releases/tag/v3.9.0).

## Pipelines

New new `pipeline` class lets you connect two or more processes with kernel-level pipes, exactly like a Unix shell pipeline (`cmd1 | cmd2 | cmd3`): data flows directly between child processes without passing through R.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>pl</span> <span class='o'>&lt;-</span> <span class='nv'><a href='http://processx.r-lib.org/reference/pipeline.html'>pipeline</a></span><span class='o'>$</span><span class='nf'>new</span><span class='o'>(</span></span>
<span>  <span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"sort"</span><span class='o'>)</span>, <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"uniq"</span>, <span class='s'>"-c"</span><span class='o'>)</span>, <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"sort"</span>, <span class='s'>"-rn"</span><span class='o'>)</span><span class='o'>)</span>,</span>
<span>  stdin <span class='o'>=</span> <span class='s'>"|"</span>,</span>
<span>  stdout <span class='o'>=</span> <span class='s'>"|"</span></span>
<span><span class='o'>)</span></span>
<span><span class='nv'>pl</span><span class='o'>$</span><span class='nf'>write_input</span><span class='o'>(</span><span class='s'>"banana\napple\nbanana\norange\napple\nbanana\n"</span><span class='o'>)</span></span>
<span><span class='nv'>pl</span><span class='o'>$</span><span class='nf'>close_input</span><span class='o'>(</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; NULL</span></span>
<span></span><span><span class='nv'>pl</span><span class='o'>$</span><span class='nf'>read_all_output_lines</span><span class='o'>(</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; [1] "   3 banana" "   2 apple"  "   1 orange"</span></span>
<span></span><span><span class='nv'>pl</span><span class='o'>$</span><span class='nf'>wait</span><span class='o'>(</span><span class='o'>)</span></span>
<span><span class='nv'>pl</span><span class='o'>$</span><span class='nf'>get_exit_statuses</span><span class='o'>(</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; [[1]]</span></span>
<span><span class='c'>#&gt; [1] 0</span></span>
<span><span class='c'>#&gt; </span></span>
<span><span class='c'>#&gt; [[2]]</span></span>
<span><span class='c'>#&gt; [1] 0</span></span>
<span><span class='c'>#&gt; </span></span>
<span><span class='c'>#&gt; [[3]]</span></span>
<span><span class='c'>#&gt; [1] 0</span></span>
<span></span></code></pre>

</div>

The `pipeline$new()` constructor takes a list of character vectors --- one per command --- along with the usual `stdin`, `stdout`, and `stderr` arguments. These apply to the *ends* of the pipeline: `stdin` connects to the first process, `stdout` reads from the last, and `stderr` controls all processes.

The key benefit over calling [`run()`](http://processx.r-lib.org/reference/run.html) in sequence is efficiency: intermediate data never materialises in R. A pipeline processing gigabytes of log lines uses the same small kernel buffers as a shell pipeline would.

Because each step in the pipeline is a regular `process` object under the hood, you can access individual processes via `$get_processes()` --- useful for reading per-process stderr or checking exit codes when a stage fails.

`pipeline` works on Unix and Windows and is currently experimental: the API may still change.

## Pseudo-terminal support

### `processx::run(pty = TRUE)`

Many command-line tools behave differently when their output is not connected to a terminal: they disable colour, turn off progress bars, or buffer output more aggressively. The `pty = TRUE` option runs a process inside a pseudo-terminal so it sees a real terminal --- colour and interactive behaviour included.

[`run()`](http://processx.r-lib.org/reference/run.html) now supports `pty = TRUE` directly:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>out</span> <span class='o'>&lt;-</span> <span class='nf'><a href='http://processx.r-lib.org/reference/run.html'>run</a></span><span class='o'>(</span><span class='s'>"ls"</span>, <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"--color"</span>, <span class='nf'><a href='https://rdrr.io/r/base/path.expand.html'>path.expand</a></span><span class='o'>(</span><span class='s'>"~/works/processx"</span><span class='o'>)</span><span class='o'>)</span>, pty <span class='o'>=</span> <span class='kc'>TRUE</span><span class='o'>)</span></span>
<span><span class='nf'><a href='https://rdrr.io/r/base/cat.html'>cat</a></span><span class='o'>(</span><span class='nv'>out</span><span class='o'>$</span><span class='nv'>stdout</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; DESCRIPTION    NAMESPACE      README.md      <span style='color: #0000BB;'>inst</span>           <span style='color: #0000BB;'>tests</span></span></span>
<span><span class='c'>#&gt; LICENSE        NEWS.md        _pkgdown.yml   <span style='color: #0000BB;'>man</span>            <span style='color: #0000BB;'>tools</span></span></span>
<span><span class='c'>#&gt; LICENSE.md     <span style='color: #0000BB;'>R</span>              air.toml       processx.Rproj <span style='color: #0000BB;'>vignettes</span></span></span>
<span><span class='c'>#&gt; Makefile       README.Rmd     codecov.yml    <span style='color: #0000BB;'>src</span></span></span>
<span></span></code></pre>

</div>

When `pty = TRUE`, stderr is merged into stdout (the result's `$stderr` is always `NULL`), because a PTY has a single stream. You can also supply a file path as `stdin`; its contents are fed to the process via the PTY master, followed by an EOF signal.

### Windows support

processx 3.9.0 adds support for pseudo-terminals (PTYs) on Windows, starting from Windows 10 version 1809. The Windows implementation uses the ConPTY API (`CreatePseudoConsole`), loaded dynamically so processx continues to load on older Windows and emits a clear error if `pty = TRUE` is requested on an unsupported version.

## Other improvements

### New process cleanup article

A new article, [Process cleanup](https://processx.r-lib.org/articles/cleanup.html), documents all five mechanisms processx provides for ensuring subprocesses don't outlive their intended scope:

1.  Explicit cleanup with [`on.exit()`](https://rdrr.io/r/base/on.exit.html) --- always deterministic.
2.  Automatic cleanup on garbage collection (`cleanup = TRUE`, the default).
3.  Process-tree cleanup (`cleanup_tree = TRUE`).
4.  Linux parent-death signal (`linux_pdeathsig`) --- Linux only, handles R crashes.
5.  Supervisor process (`supervise = TRUE`) --- all platforms, handles R crashes.

### Death signal support on Linux

On Linux, you can now tell the kernel to deliver a signal to the child process automatically if the parent R process exits --- even if R crashes. Set `linux_pdeathsig = TRUE` to send `SIGTERM`, or pass an integer signal number directly:

``` r
p <- process$new("sleep", "100", linux_pdeathsig = TRUE)
```

This is useful when you want child processes to clean up after an R crash, without the overhead of running a supervisor. The argument is silently ignored on macOS and Windows.

### Record the time when a process exits

`process$get_end_time()` returns the time when the process exited as a `POSIXct`, or `NULL` if it is still running. This makes it straightforward to measure wall-clock duration without having to record timestamps yourself:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>p</span> <span class='o'>&lt;-</span> <span class='nv'><a href='http://processx.r-lib.org/reference/process.html'>process</a></span><span class='o'>$</span><span class='nf'>new</span><span class='o'>(</span><span class='s'>"sleep"</span>, <span class='s'>"1"</span><span class='o'>)</span></span>
<span><span class='nv'>p</span><span class='o'>$</span><span class='nf'>wait</span><span class='o'>(</span><span class='o'>)</span></span>
<span><span class='nv'>p</span><span class='o'>$</span><span class='nf'>get_end_time</span><span class='o'>(</span><span class='o'>)</span> <span class='o'>-</span> <span class='nv'>p</span><span class='o'>$</span><span class='nf'>get_start_time</span><span class='o'>(</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; Time difference of 1.010295 secs</span></span>
<span></span></code></pre>

</div>

### Append stdout/stderr to files

`process$new()` and [`run()`](http://processx.r-lib.org/reference/run.html) now support `">>"` as a prefix for `stdout` and `stderr` file paths to append output instead of truncating the file:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>log</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/tempfile.html'>tempfile</a></span><span class='o'>(</span><span class='o'>)</span></span>
<span><span class='nf'><a href='http://processx.r-lib.org/reference/run.html'>run</a></span><span class='o'>(</span><span class='s'>"echo"</span>, args <span class='o'>=</span> <span class='s'>"first line"</span>, stdout <span class='o'>=</span> <span class='nv'>log</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; $status</span></span>
<span><span class='c'>#&gt; [1] 0</span></span>
<span><span class='c'>#&gt; </span></span>
<span><span class='c'>#&gt; $stdout</span></span>
<span><span class='c'>#&gt; NULL</span></span>
<span><span class='c'>#&gt; </span></span>
<span><span class='c'>#&gt; $stderr</span></span>
<span><span class='c'>#&gt; [1] ""</span></span>
<span><span class='c'>#&gt; </span></span>
<span><span class='c'>#&gt; $timeout</span></span>
<span><span class='c'>#&gt; [1] FALSE</span></span>
<span></span><span><span class='nf'><a href='http://processx.r-lib.org/reference/run.html'>run</a></span><span class='o'>(</span><span class='s'>"echo"</span>, args <span class='o'>=</span> <span class='s'>"second line"</span>, stdout <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/paste.html'>paste0</a></span><span class='o'>(</span><span class='s'>"&gt;&gt;"</span>, <span class='nv'>log</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; $status</span></span>
<span><span class='c'>#&gt; [1] 0</span></span>
<span><span class='c'>#&gt; </span></span>
<span><span class='c'>#&gt; $stdout</span></span>
<span><span class='c'>#&gt; NULL</span></span>
<span><span class='c'>#&gt; </span></span>
<span><span class='c'>#&gt; $stderr</span></span>
<span><span class='c'>#&gt; [1] ""</span></span>
<span><span class='c'>#&gt; </span></span>
<span><span class='c'>#&gt; $timeout</span></span>
<span><span class='c'>#&gt; [1] FALSE</span></span>
<span></span><span><span class='nf'><a href='https://rdrr.io/r/base/readLines.html'>readLines</a></span><span class='o'>(</span><span class='nv'>log</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; [1] "first line"  "second line"</span></span>
<span></span></code></pre>

</div>

This is handy when you run the same process repeatedly and want to accumulate output in a single log file.

### Binary standard output and error

[`run()`](http://processx.r-lib.org/reference/run.html) and `process$new()` now support `encoding = "binary"` to capture raw bytes. In binary mode, [`run()`](http://processx.r-lib.org/reference/run.html) returns `stdout` and `stderr` as raw vectors, and `process$read_output()` / `process$read_error()` return raw vectors rather than character strings. All bytes are preserved exactly, including null bytes and non-UTF-8 sequences.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>result</span> <span class='o'>&lt;-</span> <span class='nf'><a href='http://processx.r-lib.org/reference/run.html'>run</a></span><span class='o'>(</span><span class='s'>"cat"</span>, args <span class='o'>=</span> <span class='s'>"/bin/ls"</span>, encoding <span class='o'>=</span> <span class='s'>"binary"</span><span class='o'>)</span></span>
<span><span class='nf'><a href='https://rdrr.io/r/base/typeof.html'>typeof</a></span><span class='o'>(</span><span class='nv'>result</span><span class='o'>$</span><span class='nv'>stdout</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; [1] "raw"</span></span>
<span></span><span><span class='nf'><a href='https://rdrr.io/r/base/length.html'>length</a></span><span class='o'>(</span><span class='nv'>result</span><span class='o'>$</span><span class='nv'>stdout</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; [1] 154624</span></span>
<span></span></code></pre>

</div>

Two new methods, `process$read_output_bytes()` and `process$read_error_bytes()`, and the [`conn_read_bytes()`](http://processx.r-lib.org/reference/processx_connections.html) function, provide direct access to raw bytes from processx connections.

## Acknowledgements

Thanks to everyone who contributed to processx 3.9.0 through code, issues, testing, and feedback:

[@advieser](https://github.com/advieser), [@cderv](https://github.com/cderv), [@chwpearse](https://github.com/chwpearse), [@HenrikBengtsson](https://github.com/HenrikBengtsson), [@king-of-poppk](https://github.com/king-of-poppk), [@r2evans](https://github.com/r2evans), [@sckott](https://github.com/sckott), [@sda030](https://github.com/sda030), [@stupidpupil](https://github.com/stupidpupil), and [@Yunuuuu](https://github.com/Yunuuuu).

