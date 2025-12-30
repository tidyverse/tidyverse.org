---
output: hugodown::hugo_document

slug: yaml12-0-1-0
title: "yaml12: YAML 1.2 for R and Python"
date: 2026-01-06
author: Tomasz Kalinowski
description: >
    We’re pleased to announce two new YAML 1.2 packages: `yaml12` for R and
    `py-yaml12` for Python. Both are implemented in Rust and designed for
    fast, predictable YAML 1.2 parsing, with safe opt-in tag handling and document stream support.

photo:
  url: https://unsplash.com/photos/green-plant-on-brown-clay-pot-PAEwrnasOvY
  author: Devin H

# one of: "deep-dive", "learn", "package", "programming", "roundup", or "other"
categories: [package]
tags: [yaml, r, python, rust]
rmd_hash: b7b11ca031b726af

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
* [ ] [`usethis::use_tidy_thanks()`](https://usethis.r-lib.org/reference/use_tidy_thanks.html) (optional)
-->

Today we're announcing two new packages for parsing and emitting YAML 1.2: [`yaml12`](https://posit-dev.github.io/r-yaml12/) for R and [`py-yaml12`](https://posit-dev.github.io/py-yaml12/) for Python.

In Python, the package is published on PyPI as `py-yaml12`, but you import it as `yaml12`.

Both packages are implemented in Rust and built on the excellent [`saphyr`](https://github.com/saphyr-rs/saphyr) crate. They share the same design goals: predictable YAML 1.2 typing, explicit control over tag interpretation via handlers, and clean round-tripping of unhandled tags.

Before we get into the details, a quick note on how this relates to the existing R [`yaml`](https://github.com/r-lib/yaml) package. The R `yaml` package is now in [r-lib](https://github.com/r-lib), and we've taken over maintenance after years of stewardship by its original author, Jeremy Stephens, and later by Shawn Garbett.

If `yaml` already works for you, there's no need to switch. `yaml12` is an experiment providing consistent R and Python bindings to a new Rust library specifically for YAML 1.2, which, as we'll see below, has some particular advantages.

## Install

Install the R package from CRAN:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://rdrr.io/r/utils/install.packages.html'>install.packages</a></span><span class='o'>(</span><span class='s'>"yaml12"</span><span class='o'>)</span></span></code></pre>

</div>

Install the Python package from PyPI:

``` bash
pip install py-yaml12
```

## Quick start (R)

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://posit-dev.github.io/r-yaml12/'>yaml12</a></span><span class='o'>)</span></span>
<span></span>
<span><span class='nv'>yaml</span> <span class='o'>&lt;-</span> <span class='s'>"</span></span>
<span><span class='s'>title: A modern YAML parser and emitter written in Rust</span></span>
<span><span class='s'>properties: [fast, correct, safe, simple]</span></span>
<span><span class='s'>"</span></span>
<span></span>
<span><span class='nv'>doc</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://posit-dev.github.io/r-yaml12/reference/parse_yaml.html'>parse_yaml</a></span><span class='o'>(</span><span class='nv'>yaml</span><span class='o'>)</span></span>
<span><span class='nf'><a href='https://rdrr.io/r/utils/str.html'>str</a></span><span class='o'>(</span><span class='nv'>doc</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; List of 2</span></span>
<span><span class='c'>#&gt;  $ title     : chr "A modern YAML parser and emitter written in Rust"</span></span>
<span><span class='c'>#&gt;  $ properties: chr [1:4] "fast" "correct" "safe" "simple"</span></span>
<span></span></code></pre>

</div>

Round-trip back to YAML:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>obj</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span></span>
<span>  seq <span class='o'>=</span> <span class='m'>1</span><span class='o'>:</span><span class='m'>2</span>,</span>
<span>  map <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span>key <span class='o'>=</span> <span class='s'>"value"</span><span class='o'>)</span>,</span>
<span>  tagged <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/structure.html'>structure</a></span><span class='o'>(</span><span class='s'>"1 + 1"</span>, yaml_tag <span class='o'>=</span> <span class='s'>"!expr"</span><span class='o'>)</span></span>
<span><span class='o'>)</span></span>
<span><span class='nf'><a href='https://posit-dev.github.io/r-yaml12/reference/format_yaml.html'>write_yaml</a></span><span class='o'>(</span><span class='nv'>obj</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; ---</span></span>
<span><span class='c'>#&gt; seq:</span></span>
<span><span class='c'>#&gt;   - 1</span></span>
<span><span class='c'>#&gt;   - 2</span></span>
<span><span class='c'>#&gt; map:</span></span>
<span><span class='c'>#&gt;   key: value</span></span>
<span><span class='c'>#&gt; tagged: !expr 1 + 1</span></span>
<span><span class='c'>#&gt; ...</span></span>
<span></span><span></span>
<span><span class='nf'><a href='https://rdrr.io/r/base/identical.html'>identical</a></span><span class='o'>(</span><span class='nv'>obj</span>, <span class='nf'><a href='https://posit-dev.github.io/r-yaml12/reference/parse_yaml.html'>parse_yaml</a></span><span class='o'>(</span><span class='nf'><a href='https://posit-dev.github.io/r-yaml12/reference/format_yaml.html'>format_yaml</a></span><span class='o'>(</span><span class='nv'>obj</span><span class='o'>)</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; [1] TRUE</span></span>
<span></span></code></pre>

</div>

## Quick start (Python)

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'># Install from PyPI:
#   python -m pip install py-yaml12
from yaml12 import parse_yaml, format_yaml, Yaml

yaml_text = """
title: A modern YAML parser and emitter written in Rust
properties: [fast, correct, safe, simple]
"""

doc = parse_yaml(yaml_text)

assert doc == {
  "title": "A modern YAML parser and emitter written in Rust",
  "properties": ["fast", "correct", "safe", "simple"]
}

assert doc == parse_yaml(format_yaml(doc))

# Tagged values
tagged = parse_yaml("!expr 1 + 1")
assert tagged == Yaml(value="1 + 1", tag="!expr")
</code></pre>

</div>

## Why YAML 1.2?

YAML 1.2 tightened up a number of ambiguous implicit conversions. In particular, plain scalars like `on`/`off`/`yes`/`no`/`y`/`n` are strings in the 1.2 core schema, and YAML 1.2 removed sexagesimal (base-60) parsing, so values like `1:2` are not treated as numbers.

YAML 1.2 also removed `!!timestamp`, `!!binary`, and `!!omap` from the set of core types, which further reduces implicit coercions (for example, getting a date/time object when you expected a string). If you want to interpret those values, you can do so explicitly via tags and handlers.

That makes YAML a better default for configuration files, front matter, and data interchange. You get fewer surprises and fewer "why did this become a boolean?" moments (or "why did this become a date?").

## Highlights

### A consistent API in R and Python

The two packages intentionally share the same high-level functions:

- [`parse_yaml()`](https://posit-dev.github.io/r-yaml12/reference/parse_yaml.html): Parse YAML from a string
- [`read_yaml()`](https://posit-dev.github.io/r-yaml12/reference/parse_yaml.html): Read YAML from a file
- [`format_yaml()`](https://posit-dev.github.io/r-yaml12/reference/format_yaml.html): Format values as YAML (to a string)
- [`write_yaml()`](https://posit-dev.github.io/r-yaml12/reference/format_yaml.html): Write YAML to a file (or stdout)

### Tags and handlers (opt-in, meaning, safe defaults)

In YAML, tags are explicit annotations like `!expr` or `!!timestamp` that attach type and meaning to a value.

Tags are preserved by default:

- In R, tags are kept in a `yaml_tag` attribute.
- In Python, tags are kept by wrapping values in a `Yaml()` object.

Handlers let you opt into custom behavior for tags (including tags on mapping keys) while keeping parsing as a data-only operation by default.

If you used R `yaml`'s `!expr` tag to evaluate expressions, you can recreate that behavior by registering a handler, but it's only recommended when parsing trusted YAML, since evaluating arbitrary code is a security risk. For untrusted input, the default behavior is safer because it keeps `!expr` as data and does not execute code.

R example:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='c'># by default, tags are kept as data</span></span>
<span><span class='nf'><a href='https://rdrr.io/r/base/dput.html'>dput</a></span><span class='o'>(</span><span class='nf'><a href='https://posit-dev.github.io/r-yaml12/reference/parse_yaml.html'>parse_yaml</a></span><span class='o'>(</span><span class='s'>"!expr 1 + 1"</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; structure("1 + 1", yaml_tag = "!expr")</span></span>
<span></span><span></span>
<span><span class='c'># Add a handler to process tagged nodes (like the &#123;yaml&#125; package does)</span></span>
<span><span class='nv'>handlers</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span><span class='s'>"!expr"</span> <span class='o'>=</span> \<span class='o'>(</span><span class='nv'>x</span><span class='o'>)</span> <span class='nf'><a href='https://rdrr.io/r/base/eval.html'>eval</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/parse.html'>str2expression</a></span><span class='o'>(</span><span class='nv'>x</span><span class='o'>)</span>, <span class='nf'><a href='https://rdrr.io/r/base/environment.html'>globalenv</a></span><span class='o'>(</span><span class='o'>)</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='nf'><a href='https://posit-dev.github.io/r-yaml12/reference/parse_yaml.html'>parse_yaml</a></span><span class='o'>(</span><span class='s'>"!expr 1 + 1"</span>, handlers <span class='o'>=</span> <span class='nv'>handlers</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; [1] 2</span></span>
<span></span></code></pre>

</div>

Python example:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'>from yaml12 import parse_yaml

handlers = {"!expr": eval}  # use with trusted input only
parse_yaml("!expr 1 + 1", handlers=handlers)

#> 2
</code></pre>

</div>

### Simplification and missing values (R)

In R, [`parse_yaml()`](https://posit-dev.github.io/r-yaml12/reference/parse_yaml.html) can simplify homogeneous sequences to vectors. When it does, YAML `null` becomes the appropriate `NA` type:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://posit-dev.github.io/r-yaml12/reference/parse_yaml.html'>parse_yaml</a></span><span class='o'>(</span><span class='s'>"[1, 2, 3, null]"</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; [1]  1  2  3 NA</span></span>
<span></span><span></span>
<span><span class='nf'><a href='https://rdrr.io/r/utils/str.html'>str</a></span><span class='o'>(</span><span class='nf'><a href='https://posit-dev.github.io/r-yaml12/reference/parse_yaml.html'>parse_yaml</a></span><span class='o'>(</span><span class='s'>"[1, 2, 3, null]"</span>, simplify <span class='o'>=</span> <span class='kc'>FALSE</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; List of 4</span></span>
<span><span class='c'>#&gt;  $ : int 1</span></span>
<span><span class='c'>#&gt;  $ : int 2</span></span>
<span><span class='c'>#&gt;  $ : int 3</span></span>
<span><span class='c'>#&gt;  $ : NULL</span></span>
<span></span></code></pre>

</div>

### Non-string mapping keys

YAML allows mapping keys that aren't plain strings (numbers, booleans, tagged scalars, even sequences and mappings). Both packages preserve these safely:

- In R, you'll get a regular named list plus a `yaml_keys` attribute when needed.
- In Python, unhashable keys (like lists/dicts) are wrapped in `Yaml` so they can still be used as `dict` keys and round-trip correctly.

R example:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://rdrr.io/r/base/dput.html'>dput</a></span><span class='o'>(</span><span class='nf'><a href='https://posit-dev.github.io/r-yaml12/reference/parse_yaml.html'>parse_yaml</a></span><span class='o'>(</span><span class='s'>"&#123;a: b&#125;: c"</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; structure(list("c"), names = "", yaml_keys = list(list(a = "b")))</span></span>
<span></span></code></pre>

</div>

Python example:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'>from yaml12 import parse_yaml, Yaml

doc = parse_yaml("{a: b}: c")
assert doc == {Yaml({'a': 'b'}): 'c'}
</code></pre>

</div>

### Mapping order is preserved

YAML mappings are ordered. `yaml12` preserves mapping/dictionary order when parsing and formatting, so the order you see in a YAML file (or emit) round-trips in both R and Python.

### Document streams and front matter

Both packages support multi-document YAML streams with `multi = TRUE`. When `multi = FALSE` (the default), parsing stops after the first document, which is handy for extracting YAML front matter from text that continues with non-YAML content.

Example:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>yaml</span> <span class='o'>&lt;-</span> <span class='s'>"</span></span>
<span><span class='s'>---</span></span>
<span><span class='s'>title: Extracting YAML front matter</span></span>
<span><span class='s'>---</span></span>
<span><span class='s'>This is technically now the second document in a YAML stream</span></span>
<span><span class='s'>"</span></span>
<span><span class='nf'><a href='https://rdrr.io/r/utils/str.html'>str</a></span><span class='o'>(</span><span class='nf'><a href='https://posit-dev.github.io/r-yaml12/reference/parse_yaml.html'>parse_yaml</a></span><span class='o'>(</span><span class='nv'>yaml</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; List of 1</span></span>
<span><span class='c'>#&gt;  $ title: chr "Extracting YAML front matter"</span></span>
<span></span><span><span class='nf'><a href='https://rdrr.io/r/utils/str.html'>str</a></span><span class='o'>(</span><span class='nf'><a href='https://posit-dev.github.io/r-yaml12/reference/parse_yaml.html'>parse_yaml</a></span><span class='o'>(</span><span class='nv'>yaml</span>, multi <span class='o'>=</span> <span class='kc'>TRUE</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; List of 2</span></span>
<span><span class='c'>#&gt;  $ :List of 1</span></span>
<span><span class='c'>#&gt;   ..$ title: chr "Extracting YAML front matter"</span></span>
<span><span class='c'>#&gt;  $ : chr "This is technically now the second document in a YAML stream"</span></span>
<span></span></code></pre>

</div>

### Performance and safety notes

`yaml12` is implemented in Rust and written with performance and safety in mind. It avoids unnecessary allocations, copies, and extra traversals where possible. In Python, `py-yaml12` (imported as `yaml12`) also releases the GIL for large parses and serializations.

In typical usage, the R package `yaml12` is ~2× faster than the `yaml` package, and the Python package `py-yaml12` is ≥50× faster than default `PyYAML` in the benchmarks ([R benchmarks](https://posit-dev.github.io/r-yaml12/articles/benchmarks.html); [Python benchmarks](https://posit-dev.github.io/py-yaml12/benchmarks/#read-performance)).

Tags are preserved by default, and interpreting them (including any kind of evaluation) is always an explicit opt-in via handlers. Plain scalars follow the YAML 1.2 core schema rules for predictable typing.

In Python, `py-yaml12` ships prebuilt wheels for common platforms. If you do need to build from source, you'll need a Rust toolchain. In R, `yaml12` is available from CRAN (including binaries on common platforms).

## Wrapping up

If you work with YAML as a data format for configuration, front matter, or data interchange, we hope `yaml12` (R) and `py-yaml12` (Python) help you parse and emit YAML 1.2 predictably. If you run into YAML that doesn't behave as expected, we'd love to hear about it in the issue trackers: [r-yaml12](https://github.com/posit-dev/r-yaml12/issues) and [py-yaml12](https://github.com/posit-dev/py-yaml12/issues).

## Learn more

- R package docs: <https://posit-dev.github.io/r-yaml12/>
- R package on CRAN: <https://cran.r-project.org/package=yaml12>
- Python package docs: <https://posit-dev.github.io/py-yaml12/>
- Python package on PyPI: <https://pypi.org/project/py-yaml12/>

## Acknowledgements

Both packages build on the fantastic work in the YAML ecosystem, especially the `saphyr` Rust crate and the [yaml-test-suite](https://github.com/yaml/yaml-test-suite).

