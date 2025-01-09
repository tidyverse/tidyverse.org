---
output: hugodown::hugo_document

slug: httr2-1-1-0
title: httr2 1.1.0
date: 2025-01-09
author: Hadley Wickham
description: >
    httr2 1.1.0 introduces powerful new streaming capabilities with
    `req_perform_connection()`. This release also brings comprehensive URL
    manipulation tools and improved support for AWS.

photo:
  url: https://unsplash.com/photos/person-holding-two-baseballs-3k_FcShH0jY
  author: Jose Morales

# one of: "deep-dive", "learn", "package", "programming", "roundup", or "other"
categories: [package]
tags: [httr2]
rmd_hash: 6a236a39ca96b9d6

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
* [ ] [`usethis::use_tidy_thanks()`](https://usethis.r-lib.org/reference/use_tidy_thanks.html)
-->

We're chuffed to announce the release of [httr2 1.1.0](https://httr2.r-lib.org). httr2 (pronounced "hitter2") is a comprehensive HTTP client that provides a modern, pipeable API for working with web APIs. It builds on top of [{curl}](https://jeroen.r-universe.dev/curl) to provide features like explicit request objects, built-in rate limiting & retry tooling, comprehensive OAuth support, and secure handling of secrets and credentials.

In this blog post, we'll dive into the new streaming interface built around [`req_perform_connection()`](https://httr2.r-lib.org/reference/req_perform_connection.html), explore the suite of URL manipulation tools, and highlight a few of the other biggest changes (including better support for AWS and enhancements to the caching system), and update you on the lifecycle changes.

As well as the changes in version 1.1.0 this blog post covers the most important enhacenments in versions 1.0.1 through 1.0.7, where we've been iterating on various features and fixing *numerous* bugs. For a complete list of changes, you can check the [GitHub release notes](https://github.com/r-lib/httr2/releases) or the [NEWS file](https://httr2.r-lib.org/news/index.html).

## Installation

Install httr2 from CRAN with:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://rdrr.io/r/utils/install.packages.html'>install.packages</a></span><span class='o'>(</span><span class='s'>"httr2"</span><span class='o'>)</span></span></code></pre>

</div>

## Streaming data

The headline feature of this release is a better API for streaming responses. The star of the show is [`req_perform_connection()`](https://httr2.r-lib.org/reference/req_perform_connection.html), which supersedes the older callback-based [`req_perform_stream()`](https://httr2.r-lib.org/reference/req_perform_stream.html). Unlike its predecessor, [`req_perform_connection()`](https://httr2.r-lib.org/reference/req_perform_connection.html) returns a regular response object with a connection object for the body:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://httr2.r-lib.org'>httr2</a></span><span class='o'>)</span></span>
<span></span>
<span><span class='nv'>req</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://httr2.r-lib.org/reference/request.html'>request</a></span><span class='o'>(</span><span class='nf'><a href='https://httr2.r-lib.org/reference/example_url.html'>example_url</a></span><span class='o'>(</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>|&gt;</span> <span class='nf'><a href='https://httr2.r-lib.org/reference/req_template.html'>req_template</a></span><span class='o'>(</span><span class='s'>"/stream-bytes/:n"</span>, n <span class='o'>=</span> <span class='m'>10240</span><span class='o'>)</span></span>
<span><span class='nv'>resp</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://httr2.r-lib.org/reference/req_perform_connection.html'>req_perform_connection</a></span><span class='o'>(</span><span class='nv'>req</span><span class='o'>)</span></span>
<span><span class='nv'>resp</span></span>
<span><span class='c'>#&gt; <span style='color: #0000BB;'>&lt;httr2_response&gt;</span></span></span>
<span></span><span><span class='c'>#&gt; <span style='font-weight: bold;'>GET</span> http://127.0.0.1:54691/stream-bytes/10240</span></span>
<span></span><span><span class='c'>#&gt; <span style='color: #00BB00;'>Status</span>: 200 OK</span></span>
<span></span><span><span class='c'>#&gt; <span style='color: #00BB00;'>Content-Type</span>: application/octet-stream</span></span>
<span></span><span><span class='c'>#&gt; <span style='color: #00BB00;'>Body</span>: Streaming connection</span></span>
<span></span></code></pre>

</div>

Once you have a streaming connection you can repeatedly call a `resp_stream_*()` function to pull down data in chunks, using [`resp_stream_is_complete()`](https://httr2.r-lib.org/reference/resp_stream_raw.html) to figure out when the stream is complete.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='kr'>while</span> <span class='o'>(</span><span class='o'>!</span><span class='nf'><a href='https://httr2.r-lib.org/reference/resp_stream_raw.html'>resp_stream_is_complete</a></span><span class='o'>(</span><span class='nv'>resp</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>&#123;</span></span>
<span>  <span class='nv'>bytes</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://httr2.r-lib.org/reference/resp_stream_raw.html'>resp_stream_raw</a></span><span class='o'>(</span><span class='nv'>resp</span>, kb <span class='o'>=</span> <span class='m'>2</span><span class='o'>)</span></span>
<span>  <span class='nf'><a href='https://rdrr.io/r/base/cat.html'>cat</a></span><span class='o'>(</span><span class='s'>"Downloaded "</span>, <span class='nf'><a href='https://rdrr.io/r/base/length.html'>length</a></span><span class='o'>(</span><span class='nv'>bytes</span><span class='o'>)</span>, <span class='s'>" bytes\n"</span>, sep <span class='o'>=</span> <span class='s'>""</span><span class='o'>)</span></span>
<span><span class='o'>&#125;</span></span>
<span><span class='c'>#&gt; Downloaded 2048 bytes</span></span>
<span><span class='c'>#&gt; Downloaded 2048 bytes</span></span>
<span><span class='c'>#&gt; Downloaded 2048 bytes</span></span>
<span><span class='c'>#&gt; Downloaded 2048 bytes</span></span>
<span><span class='c'>#&gt; Downloaded 2048 bytes</span></span>
<span><span class='c'>#&gt; Downloaded 0 bytes</span></span>
<span></span></code></pre>

</div>

As well as [`resp_stream_raw()`](https://httr2.r-lib.org/reference/resp_stream_raw.html), which returns a raw vector, you can also use [`resp_stream_lines()`](https://httr2.r-lib.org/reference/resp_stream_raw.html) to stream lines and [`resp_stream_sse()`](https://httr2.r-lib.org/reference/resp_stream_raw.html) to stream [server-sent events](https://developer.mozilla.org/en-US/docs/Web/API/Server-sent_events/Using_server-sent_events).

We've worked on these functions to support streaming chat responses for [ellmer](https://ellmer.tidyverse.org), our new package for chatting with LLMs from a variety of providers. So even though this feature is pretty new, it feels like it's been battle-tested and the interface feels stable.

## URL manipulation tools

Working with URLs got easier with three new functions: [`url_modify()`](https://httr2.r-lib.org/reference/url_modify.html), [`url_modify_query()`](https://httr2.r-lib.org/reference/url_modify.html), and [`url_modify_relative()`](https://httr2.r-lib.org/reference/url_modify.html).

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='c'># url_modify() modifies components of a URL</span></span>
<span><span class='nf'><a href='https://httr2.r-lib.org/reference/url_modify.html'>url_modify</a></span><span class='o'>(</span><span class='s'>"https://example.com"</span>, hostname <span class='o'>=</span> <span class='s'>"github.com"</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; [1] "https://github.com/"</span></span>
<span></span><span><span class='nf'><a href='https://httr2.r-lib.org/reference/url_modify.html'>url_modify</a></span><span class='o'>(</span><span class='s'>"https://example.com"</span>, scheme <span class='o'>=</span> <span class='s'>"http"</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; [1] "http://example.com/"</span></span>
<span></span><span><span class='nf'><a href='https://httr2.r-lib.org/reference/url_modify.html'>url_modify</a></span><span class='o'>(</span><span class='s'>"https://example.com"</span>, path <span class='o'>=</span> <span class='s'>"abc"</span>, query <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span>foo <span class='o'>=</span> <span class='s'>"bar"</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; [1] "https://example.com/abc?foo=bar"</span></span>
<span></span><span></span>
<span><span class='c'># url_modify_query() lets you modify individual query parameters</span></span>
<span><span class='c'># modifying an existing parameter:</span></span>
<span><span class='nf'><a href='https://httr2.r-lib.org/reference/url_modify.html'>url_modify_query</a></span><span class='o'>(</span><span class='s'>"http://example.com?a=1&amp;b=2"</span>, a <span class='o'>=</span> <span class='m'>10</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; [1] "http://example.com/?b=2&amp;a=10"</span></span>
<span></span><span><span class='c'># delete a parameter:</span></span>
<span><span class='nf'><a href='https://httr2.r-lib.org/reference/url_modify.html'>url_modify_query</a></span><span class='o'>(</span><span class='s'>"http://example.com?a=1&amp;b=2"</span>, b <span class='o'>=</span> <span class='kc'>NULL</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; [1] "http://example.com/?a=1"</span></span>
<span></span><span><span class='c'># add a new parameter:</span></span>
<span><span class='nf'><a href='https://httr2.r-lib.org/reference/url_modify.html'>url_modify_query</a></span><span class='o'>(</span><span class='s'>"http://example.com?a=1&amp;b=2"</span>, c <span class='o'>=</span> <span class='m'>3</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; [1] "http://example.com/?a=1&amp;b=2&amp;c=3"</span></span>
<span></span><span></span>
<span><span class='c'># url_modify_relative() navigates to a relative URL</span></span>
<span><span class='nf'><a href='https://httr2.r-lib.org/reference/url_modify.html'>url_modify_relative</a></span><span class='o'>(</span><span class='s'>"https://example.com/a/b/c.html"</span>, <span class='s'>"/d/e/f.html"</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; [1] "https://example.com/d/e/f.html"</span></span>
<span></span><span><span class='nf'><a href='https://httr2.r-lib.org/reference/url_modify.html'>url_modify_relative</a></span><span class='o'>(</span><span class='s'>"https://example.com/a/b/c.html"</span>, <span class='s'>"C.html"</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; [1] "https://example.com/a/b/C.html"</span></span>
<span></span><span><span class='nf'><a href='https://httr2.r-lib.org/reference/url_modify.html'>url_modify_relative</a></span><span class='o'>(</span><span class='s'>"https://example.com/a/b/c.html"</span>, <span class='s'>"../B.html"</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; [1] "https://example.com/a/B.html"</span></span>
<span></span></code></pre>

</div>

We also added [`req_url_relative()`](https://httr2.r-lib.org/reference/req_url.html) which uses [`url_modify_relative()`](https://httr2.r-lib.org/reference/url_modify.html) and makes it easier to navigate to a relative URL for an existing request.

## Other improvements

There are a handful of other improvements that are worth highlighting:

-   We've made it easier to talk to AWS web services with [`req_auth_aws_v4()`](https://httr2.r-lib.org/reference/req_auth_aws_v4.html) for signing requests and [`resp_stream_aws()`](https://httr2.r-lib.org/reference/resp_stream_raw.html) for streaming responses. Special thanks goes to the [lifion-aws-event-stream](https://github.com/lifion/lifion-aws-event-stream/) project for providing a clear reference implementation.

-   We've run-down a long list of bugs that made [`req_cache()`](https://httr2.r-lib.org/reference/req_cache.html) unreliable. This includes improved handling of header-only changes, better cache pruning, and new debugging options. If you're working with a web API that supports caching, we highly recommend that you try it out. The next release of {[gh](https://github.com/r-lib/gh)} includes caching support and my use of the dev version suggests a pretty nice performance improvment.

-   [`is_online()`](https://httr2.r-lib.org/reference/is_online.html) provides an easy way to check internet connectivity.

-   [`req_perform_promise()`](https://httr2.r-lib.org/reference/req_perform_promise.html) allows you to execute requests in the background (thanks to [@gergness](https://github.com/gergness)) using an efficient approach that waits on curl socket activity (thanks to [@shikokuchuo](https://github.com/shikokuchuo)).

## Breaking changes

As httr2 continues to mature, we're making some lifecycle changes:

-   [`req_perform_iterative()`](https://httr2.r-lib.org/reference/req_perform_iterative.html) is now stable and no longer experimental.
-   [`req_perform_stream()`](https://httr2.r-lib.org/reference/req_perform_stream.html) is superseded by [`req_perform_connection()`](https://httr2.r-lib.org/reference/req_perform_connection.html), as mentioned above.
-   [`with_mock()`](https://httr2.r-lib.org/reference/with_mocked_responses.html) and [`local_mock()`](https://httr2.r-lib.org/reference/with_mocked_responses.html) are defunct and will be rmeoved in the next release. Use [`with_mocked_responses()`](https://httr2.r-lib.org/reference/with_mocked_responses.html) and [`local_mocked_responses()`](https://httr2.r-lib.org/reference/with_mocked_responses.html) instead.

## Acknowledgements

A big thanks to all 76 folks who filed issues, created PRs and generally helped to make httr2 better! [@Aariq](https://github.com/Aariq), [@AGeographer](https://github.com/AGeographer), [@amael-ls](https://github.com/amael-ls), [@anishjoni](https://github.com/anishjoni), [@asadow](https://github.com/asadow), [@atheriel](https://github.com/atheriel), [@awpsoras](https://github.com/awpsoras), [@billsanto](https://github.com/billsanto), [@bonushenricus](https://github.com/bonushenricus), [@botan](https://github.com/botan), [@burgerga](https://github.com/burgerga), [@CareCT](https://github.com/CareCT), [@cderv](https://github.com/cderv), [@cole-brokamp](https://github.com/cole-brokamp), [@covid19ec](https://github.com/covid19ec), [@datapumpernickel](https://github.com/datapumpernickel), [@denskh](https://github.com/denskh), [@deschen1](https://github.com/deschen1), [@DyfanJones](https://github.com/DyfanJones), [@erydit](https://github.com/erydit), [@exetico](https://github.com/exetico), [@fh-mthomson](https://github.com/fh-mthomson), [@frzambra](https://github.com/frzambra), [@gergness](https://github.com/gergness), [@GreenGrassBlueOcean](https://github.com/GreenGrassBlueOcean), [@guslipkin](https://github.com/guslipkin), [@hadley](https://github.com/hadley), [@i2z1](https://github.com/i2z1), [@isachng93](https://github.com/isachng93), [@IshuaWang](https://github.com/IshuaWang), [@JamesHWade](https://github.com/JamesHWade), [@jameslairdsmith](https://github.com/jameslairdsmith), [@JBGruber](https://github.com/JBGruber), [@jcheng5](https://github.com/jcheng5), [@jeroen](https://github.com/jeroen), [@jimbrig](https://github.com/jimbrig), [@jjesusfilho](https://github.com/jjesusfilho), [@jl5000](https://github.com/jl5000), [@jmuhlenkamp](https://github.com/jmuhlenkamp), [@jonthegeek](https://github.com/jonthegeek), [@JosiahParry](https://github.com/JosiahParry), [@jwimberl](https://github.com/jwimberl), [@krjaworski](https://github.com/krjaworski), [@m-muecke](https://github.com/m-muecke), [@maarten-vermeyen](https://github.com/maarten-vermeyen), [@MarekGierlinski](https://github.com/MarekGierlinski), [@maxsutton](https://github.com/maxsutton), [@mgirlich](https://github.com/mgirlich), [@MichaelChirico](https://github.com/MichaelChirico), [@mkoohafkan](https://github.com/mkoohafkan), [@MSHelm](https://github.com/MSHelm), [@mstei4176](https://github.com/mstei4176), [@mthomas-ketchbrook](https://github.com/mthomas-ketchbrook), [@NateNohling](https://github.com/NateNohling), [@nick-youngblut](https://github.com/nick-youngblut), [@pbulsink](https://github.com/pbulsink), [@PietrH](https://github.com/PietrH), [@pkautio](https://github.com/pkautio), [@plietar](https://github.com/plietar), [@pmlefeuvre-met](https://github.com/pmlefeuvre-met), [@rkrug](https://github.com/rkrug), [@romainfrancois](https://github.com/romainfrancois), [@salim-b](https://github.com/salim-b), [@shikokuchuo](https://github.com/shikokuchuo), [@simplyalexander](https://github.com/simplyalexander), [@sluga](https://github.com/sluga), [@stefanedwards](https://github.com/stefanedwards), [@steveputman](https://github.com/steveputman), [@tebancr](https://github.com/tebancr), [@thohan88](https://github.com/thohan88), [@tony2015116](https://github.com/tony2015116), [@toobiwankenobi](https://github.com/toobiwankenobi), [@verhovsky](https://github.com/verhovsky), [@walinchus](https://github.com/walinchus), [@werkstattcodes](https://github.com/werkstattcodes), and [@zacdav-db](https://github.com/zacdav-db).

