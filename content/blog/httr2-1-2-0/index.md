---
output: hugodown::hugo_document

slug: httr2-1-2-0
title: httr2 1.2.0
date: 2025-07-08
author: Hadley Wickham
description: >
    httr2 1.2.0 improves security for redacted headers, improves URL parsing
    and building, enhances debugging, and inclues a bunch of other quality
    of life improvements.

photo:
  url: https://chatgpt.com/share/6870349d-20cc-8009-84b0-dd026c75cbb2
  author: chatGPT

# one of: "deep-dive", "learn", "package", "programming", "roundup", or "other"
categories: [package] 
tags: [httr2]
rmd_hash: 316580036d1a48f7

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

# httr2 1.2.0

We're delighted to announce the release of httr2 1.2.0! httr2 (pronounced "hitter2") is a comprehensive HTTP client that provides a modern, pipeable API for working with web APIs. It builds on top of {curl} to provide features like explicit request objects, built-in rate limiting & retry tooling, comprehensive OAuth support, and secure handling of secrets and credentials.

You can install it from CRAN with:

``` r
install.packages("httr2")
```

This blog post will walk you through the most important changes: lifecycle changes, improved security for redacted headers, URL handlimg improvements, improved debugging tools, and a handful of other quality of life improvements. You can see a full list of changes in the [release notes](https://github.com/r-lib/httr2/releases/tag/v1.2.0)

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://httr2.r-lib.org'>httr2</a></span><span class='o'>)</span></span></code></pre>

</div>

## Lifecycle changes

Part of httr2's continued evolution is phasing out features that we now believe were mistakes. In this release:

-   [`req_perform_stream()`](https://httr2.r-lib.org/reference/req_perform_stream.html) has been soft deprecated (not just superseded) in favour of [`req_perform_connection()`](https://httr2.r-lib.org/reference/req_perform_connection.html).

-   Deprecated functions `multi_req_perform()`, `req_stream()`, `with_mock()`, and `local_mock()` have now been removed. Please use their modern replacements, [`req_perform_parallel()`](https://httr2.r-lib.org/reference/req_perform_parallel.html), [`req_perform_stream()`](https://httr2.r-lib.org/reference/req_perform_stream.html), [`with_mocked_responses()`](https://httr2.r-lib.org/reference/with_mocked_responses.html), and [`local_mocked_responses()`](https://httr2.r-lib.org/reference/with_mocked_responses.html), instead.

-   Deprecated arguments `req_perform_parallel(pool)`, `req_oauth_auth_code(host_name, host_ip, port)`, and `oauth_flow_auth_code(host_name, host_ip, port)` have been removed. Please use `req_perform_parallel(max_active)` and `req_oauth_auth_code(redirect_url)`/ `oauth_flow_auth_code(redirect_url)` instead.

## Enhanced security for redacted headers

One of the most important improvements in this release relates to redacted headers. Redacted headers are used to conceal secrets that you don't want to accidentally reveal. For a long time, httr2 has automatically hidden these headers when you [`print()`](https://rdrr.io/r/base/print.html) or [`str()`](https://rdrr.io/r/utils/str.html) them, ensuring that they don't accidentally end up in log files. You can see this in action with the `Authorization` header, which httr2 now automatically redacts:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>req</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://httr2.r-lib.org/reference/request.html'>request</a></span><span class='o'>(</span><span class='s'>"http://example.com"</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://httr2.r-lib.org/reference/req_auth_basic.html'>req_auth_basic</a></span><span class='o'>(</span><span class='s'>"username"</span>, <span class='s'>"password"</span><span class='o'>)</span></span>
<span></span>
<span><span class='nv'>req</span></span>
<span><span class='c'>#&gt; <span style='color: #0000BB;'>&lt;httr2_request&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='font-weight: bold;'>GET</span> http://example.com</span></span>
<span><span class='c'>#&gt; <span style='font-weight: bold;'>Headers:</span></span></span>
<span><span class='c'>#&gt; * <span style='color: #00BB00;'>Authorization</span>: <span style='color: #555555;'>&lt;REDACTED&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='font-weight: bold;'>Body</span>: empty</span></span>
<span></span><span><span class='nf'><a href='https://rdrr.io/r/utils/str.html'>str</a></span><span class='o'>(</span><span class='nv'>req</span><span class='o'>$</span><span class='nv'>headers</span><span class='o'>)</span></span>
<span><span class='c'>#&gt;  &lt;httr2_headers&gt;</span></span>
<span><span class='c'>#&gt;  $ Authorization: <span style='color: #555555;'>&lt;REDACTED&gt;</span></span></span>
<span></span><span><span class='nv'>req</span> <span class='o'>|&gt;</span> <span class='nf'><a href='https://httr2.r-lib.org/reference/req_dry_run.html'>req_dry_run</a></span><span class='o'>(</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; GET / HTTP/1.1</span></span>
<span><span class='c'>#&gt; <span style='font-weight: bold;'>accept</span>: */*</span></span>
<span><span class='c'>#&gt; <span style='font-weight: bold;'>accept-encoding</span>: deflate, gzip</span></span>
<span><span class='c'>#&gt; <span style='font-weight: bold;'>authorization</span>: <span style='color: #555555;'>&lt;REDACTED&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='font-weight: bold;'>host</span>: example.com</span></span>
<span><span class='c'>#&gt; <span style='font-weight: bold;'>user-agent</span>: httr2/1.1.2.9000 r-curl/6.4.0 libcurl/8.14.1</span></span>
<span></span></code></pre>

</div>

(If for you do really need to see the redacted values you can get with a bit of extra effort: call the new [`req_get_headers()`](https://httr2.r-lib.org/reference/req_get_headers.html) function with `redacted = "reveal"`.)

In httr2 1.1.0, we've gone one step further, and prevented redacted headers from being saved to disk. Now if you save and reload a request, you'll notice that the redacted headers are no longer present:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>path</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/tempfile.html'>tempfile</a></span><span class='o'>(</span><span class='o'>)</span></span>
<span><span class='nf'><a href='https://rdrr.io/r/base/readRDS.html'>saveRDS</a></span><span class='o'>(</span><span class='nv'>req</span>, <span class='nv'>path</span><span class='o'>)</span></span>
<span></span>
<span><span class='nv'>req2</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/readRDS.html'>readRDS</a></span><span class='o'>(</span><span class='nv'>path</span><span class='o'>)</span></span>
<span><span class='nv'>req2</span> <span class='o'>|&gt;</span> <span class='nf'><a href='https://httr2.r-lib.org/reference/req_dry_run.html'>req_dry_run</a></span><span class='o'>(</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; GET / HTTP/1.1</span></span>
<span><span class='c'>#&gt; <span style='font-weight: bold;'>accept</span>: */*</span></span>
<span><span class='c'>#&gt; <span style='font-weight: bold;'>accept-encoding</span>: deflate, gzip</span></span>
<span><span class='c'>#&gt; <span style='font-weight: bold;'>host</span>: example.com</span></span>
<span><span class='c'>#&gt; <span style='font-weight: bold;'>user-agent</span>: httr2/1.1.2.9000 r-curl/6.4.0 libcurl/8.14.1</span></span>
<span></span></code></pre>

</div>

This protects you from accidentally revealing your credentials by caching a response, typically because it's slow so you only want to do it once. httr2 includes the request in the response object (to make debugging easier), so if you cache a response you also cache the request the made it, potentially leaking secure values. (Don't ask me how I discovdred this!)

## URL handling improvements

URL construction is now powered by [`curl::curl_modify_url()`](https://jeroen.r-universe.dev/curl/reference/curl_parse_url.html), which correctly escapes the path component:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>req</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://httr2.r-lib.org/reference/request.html'>request</a></span><span class='o'>(</span><span class='s'>"https://api.example.com"</span><span class='o'>)</span></span>
<span><span class='nv'>req</span> <span class='o'>|&gt;</span> <span class='nf'><a href='https://httr2.r-lib.org/reference/req_url.html'>req_url_path</a></span><span class='o'>(</span><span class='s'>"/users/john doe/profile"</span><span class='o'>)</span> <span class='o'>|&gt;</span> <span class='nf'>req_get_url</span><span class='o'>(</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; [1] "https://api.example.com/users/john%20doe/profile"</span></span>
<span></span></code></pre>

</div>

This means that [`req_url_path()`](https://httr2.r-lib.org/reference/req_url.html) can now only affect the path component of the URL, not the query parameters. If you previously relied on this behaviour, you'll need to switch to [`req_url_query()`](https://httr2.r-lib.org/reference/req_url.html):

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='c'># won't work any more:</span></span>
<span><span class='nv'>req</span> <span class='o'>|&gt;</span> <span class='nf'><a href='https://httr2.r-lib.org/reference/req_url.html'>req_url_path</a></span><span class='o'>(</span><span class='s'>"/users?name=john-doe"</span><span class='o'>)</span> <span class='o'>|&gt;</span> <span class='nf'>req_get_url</span><span class='o'>(</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; [1] "https://api.example.com/users%3Fname%3Djohn-doe"</span></span>
<span></span><span><span class='c'># so now do this:</span></span>
<span><span class='nv'>req</span> <span class='o'>|&gt;</span> <span class='nf'><a href='https://httr2.r-lib.org/reference/req_url.html'>req_url_path</a></span><span class='o'>(</span><span class='s'>"/users"</span><span class='o'>)</span> <span class='o'>|&gt;</span> <span class='nf'><a href='https://httr2.r-lib.org/reference/req_url.html'>req_url_query</a></span><span class='o'>(</span>name <span class='o'>=</span> <span class='s'>"john-doe"</span><span class='o'>)</span> <span class='o'>|&gt;</span> <span class='nv'>_</span><span class='o'>$</span><span class='nv'>url</span></span>
<span><span class='c'>#&gt; [1] "https://api.example.com/users?name=john-doe"</span></span>
<span></span></code></pre>

</div>

## Improved debugging tools

The vast majority of modern APIs use JSON, and httr2 now includes a few features to make debugging these APIs a little easier. Firstly, [`last_request()`](https://httr2.r-lib.org/reference/last_response.html) and [`last_response()`](https://httr2.r-lib.org/reference/last_response.html) are now paired with [`last_request_json()`](https://httr2.r-lib.org/reference/last_response.html) and [`last_response_json()`](https://httr2.r-lib.org/reference/last_response.html) which pretty-print the JSON bodies of the last request and response. Additionally, [`req_dry_run()`](https://httr2.r-lib.org/reference/req_dry_run.html) and [`req_verbose()`](https://httr2.r-lib.org/reference/req_verbose.html) automatically pretty print JSON bodies (if needed, you can turn this off by setting `options(httr2_pretty_json = FALSE)`).

We've also included a few general tools to make it easier to control httr2's default verbosity. You can now control the default via the `HTTR2_VERBOSITY` environment variable and there's a new [`local_verbosity()`](https://httr2.r-lib.org/reference/with_verbosity.html) function that matches the existing [`with_verbosity()`](https://httr2.r-lib.org/reference/with_verbosity.html).

## Quality of life improvements

This release also includes a bunch of few smaller quality of life improvements:

-   [`req_perform_parallel()`](https://httr2.r-lib.org/reference/req_perform_parallel.html) now lifts many of its previous restrictions. It now supports simplified versions of [`req_throttle()`](https://httr2.r-lib.org/reference/req_throttle.html) and [`req_retry()`](https://httr2.r-lib.org/reference/req_retry.html), it can refresh OAuth tokens, and it checks the cache beforeafter each request.

-   `req_get_url()`, [`req_get_method()`](https://httr2.r-lib.org/reference/req_get_method.html), [`req_get_headers()`](https://httr2.r-lib.org/reference/req_get_headers.html), `req_body_get_type()`, and [`req_get_body()`](https://httr2.r-lib.org/reference/req_get_body_type.html) allow you to introspect request objects.

-   [`req_throttle()`](https://httr2.r-lib.org/reference/req_throttle.html) now uses a "[leaky bucket](https://en.wikipedia.org/wiki/Leaky_bucket)". This maintains the same average rate limit as before, while allowing bursts of higher request rates.

-   [`resp_timing()`](https://httr2.r-lib.org/reference/resp_timing.html) exposes detailed timing information for a response.

## Acknowledgements

A big thanks to everyone who contributed to this release through issues, pull requests, and discussions on GitHub: [@Aariq](https://github.com/Aariq), [@annalena13](https://github.com/annalena13), [@apsteinmetz](https://github.com/apsteinmetz), [@arcresu](https://github.com/arcresu), [@arnaudgallou](https://github.com/arnaudgallou), [@atheriel](https://github.com/atheriel), [@DavidRLovell](https://github.com/DavidRLovell), [@dfalbel](https://github.com/dfalbel), [@Eli-Berkow](https://github.com/Eli-Berkow), [@fwimp](https://github.com/fwimp), [@hadley](https://github.com/hadley), [@jansim](https://github.com/jansim), [@jcheng5](https://github.com/jcheng5), [@jeffreyzuber](https://github.com/jeffreyzuber), [@jjesusfilho](https://github.com/jjesusfilho), [@jonthegeek](https://github.com/jonthegeek), [@Kevanness](https://github.com/Kevanness), [@m-muecke](https://github.com/m-muecke), [@maelle](https://github.com/maelle), [@mayeulk](https://github.com/mayeulk), [@mdsumner](https://github.com/mdsumner), [@noamross](https://github.com/noamross), [@omuelle](https://github.com/omuelle), [@pedrobtz](https://github.com/pedrobtz), [@plietar](https://github.com/plietar), [@ramiromagno](https://github.com/ramiromagno), [@salim-b](https://github.com/salim-b), [@sckott](https://github.com/sckott), [@shikokuchuo](https://github.com/shikokuchuo), [@vibalre](https://github.com/vibalre), [@vladimirobucina](https://github.com/vladimirobucina), and [@ZheFrench](https://github.com/ZheFrench).

