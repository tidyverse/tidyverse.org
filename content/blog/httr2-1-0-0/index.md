---
output: hugodown::hugo_document

slug: httr2-1-0-0
title: httr2 1.0.0
date: 2023-11-14
author: Hadley Wickham
description: >
    httr2 is the successor to httr, providing a pipeable interface for
    generating HTTP requests and handling the responses. It's focussed
    on the needs of an R user wrapping a modern web API, but is flexible
    enough to handle just about any HTTP related task.

photo:
  url: https://unsplash.com/photos/xKShyIiTNJk
  author: Mike Bowman

# one of: "deep-dive", "learn", "package", "programming", "roundup", or "other"
categories: [package] 
tags: [httr2, httr]
rmd_hash: 1f70f518f4df3769

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

We're delighted to announce the release of [httr2](https://httr2.r-lib.org)[^1] 1.0.0. httr2 is the second generation of httr: it helps you generate HTTP requests and process the responses, designed with an eye towards modern web APIs and potentially putting your code in a package.

You can install it from CRAN with:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://rdrr.io/r/utils/install.packages.html'>install.packages</a></span><span class='o'>(</span><span class='s'>"httr2"</span><span class='o'>)</span></span></code></pre>

</div>

httr2 has been under development for the last two years, but this is the first time we've blogged about it because we wanted to wait until we were confident that the interface was stable. We're now confident that it is, and we're ready to encourage you to use it whenever you need to talk to a web server. Most importantly httr2 is now a "real" package because it has a wonderful new logo, thanks to a collaborative effort involving Julie Jung, Greg Swineheart, and DALL•E 3.

<div class="highlight">

<img src="httr2.png" alt="The new httr2 logo is a dark blue hexagon with httr2 written in bright white at the top of logo. Underneath the text is a vibrant magenta baseball player hitting a ball emblazoned with the letters &quot;www&quot;." width="200px" style="display: block; margin: auto;" />

</div>

httr2 is the successor to httr. The biggest difference is that it has an explicit request object which you can build up over multiple function calls. This makes the interface fit more naturally with the pipe, generally makes life easier because you can iteratively build up a complex request. If you're a current httr user, there's no need to switch, as we'll continue to maintain the package for many years to come, but if you start on a new project, I'd recommend that you give httr2 a shot.

If you've been following httr2 development for a while, you might want to jump to the [release notes](https://github.com/r-lib/httr2/releases/tag/v1.0.0) to see what's new (a lot!). The most important change in this release is that [Maximilian Girlich](https://github.com/mgirlich) is now a httr2 author, in recognition of his many contributions to the package. This release also features improved tools for performing multiple requests (more on that below), as well as a bunch of bug fixes and minor improvements for OAuth.

For the rest of this blog post, I'll assume that you're familiar with the basics of HTTP. If you're not, you might want to start with `vignette("httr2")` which introduces you to HTTP using httr2.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://httr2.r-lib.org'>httr2</a></span><span class='o'>)</span></span></code></pre>

</div>

## Making a request

httr2 is designed around the two big pieces of HTTP: requests and responses. First you'll create a request, with a URL:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>req</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://httr2.r-lib.org/reference/request.html'>request</a></span><span class='o'>(</span><span class='nf'><a href='https://httr2.r-lib.org/reference/example_url.html'>example_url</a></span><span class='o'>(</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='nv'>req</span></span>
<span><span class='c'>#&gt; <span style='color: #0000BB;'>&lt;httr2_request&gt;</span></span></span>
<span></span><span><span class='c'>#&gt; <span style='font-weight: bold;'>GET</span> http://127.0.0.1:61307/</span></span>
<span></span><span><span class='c'>#&gt; <span style='font-weight: bold;'>Body</span>: empty</span></span>
<span></span></code></pre>

</div>

Instead of using an external website here, we're using a test server that's built-in to httr2 itself. This ensures that this blog post, and many httr2 examples, work independently of the rest of the internet.

You can see the HTTP request that httr2 will send, without actually sending it[^2], by doing a dry run:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>req</span> <span class='o'>|&gt;</span> <span class='nf'><a href='https://httr2.r-lib.org/reference/req_dry_run.html'>req_dry_run</a></span><span class='o'>(</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; GET / HTTP/1.1</span></span>
<span><span class='c'>#&gt; <span style='font-weight: bold;'>Host</span>: 127.0.0.1:61307</span></span>
<span><span class='c'>#&gt; <span style='font-weight: bold;'>User-Agent</span>: httr2/0.2.3.9000 r-curl/5.1.0 libcurl/8.1.2</span></span>
<span><span class='c'>#&gt; <span style='font-weight: bold;'>Accept</span>: */*</span></span>
<span><span class='c'>#&gt; <span style='font-weight: bold;'>Accept-Encoding</span>: deflate, gzip</span></span>
<span></span></code></pre>

</div>

This object will perform a simple `GET` request with user agent and accept headings automatically added by httr2. To make more complex requests, you modify the request object using functions that start with `req_`. For example, you could make it a `HEAD` request, with some query parameters, and a custom user agent:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>req</span> <span class='o'>|&gt;</span> </span>
<span>  <span class='nf'><a href='https://httr2.r-lib.org/reference/req_url.html'>req_url_query</a></span><span class='o'>(</span>param <span class='o'>=</span> <span class='s'>"value"</span><span class='o'>)</span> <span class='o'>|&gt;</span> </span>
<span>  <span class='nf'><a href='https://httr2.r-lib.org/reference/req_user_agent.html'>req_user_agent</a></span><span class='o'>(</span><span class='s'>"My user agent"</span><span class='o'>)</span> <span class='o'>|&gt;</span> </span>
<span>  <span class='nf'><a href='https://httr2.r-lib.org/reference/req_method.html'>req_method</a></span><span class='o'>(</span><span class='s'>"HEAD"</span><span class='o'>)</span> <span class='o'>|&gt;</span> </span>
<span>  <span class='nf'><a href='https://httr2.r-lib.org/reference/req_dry_run.html'>req_dry_run</a></span><span class='o'>(</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; HEAD /?param=value HTTP/1.1</span></span>
<span><span class='c'>#&gt; <span style='font-weight: bold;'>Host</span>: 127.0.0.1:61307</span></span>
<span><span class='c'>#&gt; <span style='font-weight: bold;'>User-Agent</span>: My user agent</span></span>
<span><span class='c'>#&gt; <span style='font-weight: bold;'>Accept</span>: */*</span></span>
<span><span class='c'>#&gt; <span style='font-weight: bold;'>Accept-Encoding</span>: deflate, gzip</span></span>
<span></span></code></pre>

</div>

Or you could send some JSON in the body of the request:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>req</span> <span class='o'>|&gt;</span> </span>
<span>  <span class='nf'><a href='https://httr2.r-lib.org/reference/req_body.html'>req_body_json</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span>x <span class='o'>=</span> <span class='m'>1</span>, y <span class='o'>=</span> <span class='s'>"a"</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>|&gt;</span> </span>
<span>  <span class='nf'><a href='https://httr2.r-lib.org/reference/req_dry_run.html'>req_dry_run</a></span><span class='o'>(</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; POST / HTTP/1.1</span></span>
<span><span class='c'>#&gt; <span style='font-weight: bold;'>Host</span>: 127.0.0.1:61307</span></span>
<span><span class='c'>#&gt; <span style='font-weight: bold;'>User-Agent</span>: httr2/0.2.3.9000 r-curl/5.1.0 libcurl/8.1.2</span></span>
<span><span class='c'>#&gt; <span style='font-weight: bold;'>Accept</span>: */*</span></span>
<span><span class='c'>#&gt; <span style='font-weight: bold;'>Accept-Encoding</span>: deflate, gzip</span></span>
<span><span class='c'>#&gt; <span style='font-weight: bold;'>Content-Type</span>: application/json</span></span>
<span><span class='c'>#&gt; <span style='font-weight: bold;'>Content-Length</span>: 15</span></span>
<span><span class='c'>#&gt; </span></span>
<span><span class='c'>#&gt; &#123;"x":1,"y":"a"&#125;</span></span>
<span></span></code></pre>

</div>

httr2 provides a [wide range of `req_` function](https://httr2.r-lib.org/dev/reference/index.html#requests) to customise the request in common ways; if there's something you need that httr2 doesn't support, please [file an issue](https://github.com/r-lib/httr2/issues/new)!

## Performing the request and handling the response

Once you have a request that you are happy with, you can send it to the server with [`req_perform()`](https://httr2.r-lib.org/reference/req_perform.html):

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>req_json</span> <span class='o'>&lt;-</span> <span class='nv'>req</span> <span class='o'>|&gt;</span> <span class='nf'><a href='https://httr2.r-lib.org/reference/req_url.html'>req_url_path</a></span><span class='o'>(</span><span class='s'>"/json"</span><span class='o'>)</span></span>
<span><span class='nv'>resp</span> <span class='o'>&lt;-</span> <span class='nv'>req_json</span> <span class='o'>|&gt;</span> <span class='nf'><a href='https://httr2.r-lib.org/reference/req_perform.html'>req_perform</a></span><span class='o'>(</span><span class='o'>)</span></span></code></pre>

</div>

Performing a request will return a response object (or throw an error, which we'll talk about next). You can see the basic details of the request by printing it or exactly what the raw response looked like with [`resp_raw()`](https://httr2.r-lib.org/reference/resp_raw.html)[^3]:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>resp</span></span>
<span><span class='c'>#&gt; <span style='color: #0000BB;'>&lt;httr2_response&gt;</span></span></span>
<span></span><span><span class='c'>#&gt; <span style='font-weight: bold;'>GET</span> http://127.0.0.1:61307/json</span></span>
<span></span><span><span class='c'>#&gt; <span style='color: #00BB00;'>Status</span>: 200 OK</span></span>
<span></span><span><span class='c'>#&gt; <span style='color: #00BB00;'>Content-Type</span>: application/json</span></span>
<span></span><span><span class='c'>#&gt; <span style='color: #00BB00;'>Body</span>: In memory (407 bytes)</span></span>
<span></span><span></span>
<span><span class='nv'>resp</span> <span class='o'>|&gt;</span> <span class='nf'><a href='https://httr2.r-lib.org/reference/resp_raw.html'>resp_raw</a></span><span class='o'>(</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; HTTP/1.1 200 OK</span></span>
<span><span class='c'>#&gt; <span style='font-weight: bold;'>Connection</span>: close</span></span>
<span><span class='c'>#&gt; <span style='font-weight: bold;'>Date</span>: Tue, 14 Nov 2023 14:00:52 GMT</span></span>
<span><span class='c'>#&gt; <span style='font-weight: bold;'>Content-Type</span>: application/json</span></span>
<span><span class='c'>#&gt; <span style='font-weight: bold;'>Content-Length</span>: 407</span></span>
<span><span class='c'>#&gt; <span style='font-weight: bold;'>ETag</span>: "de760e6d"</span></span>
<span><span class='c'>#&gt; </span></span>
<span><span class='c'>#&gt; &#123;</span></span>
<span><span class='c'>#&gt;   "firstName": "John",</span></span>
<span><span class='c'>#&gt;   "lastName": "Smith",</span></span>
<span><span class='c'>#&gt;   "isAlive": true,</span></span>
<span><span class='c'>#&gt;   "age": 27,</span></span>
<span><span class='c'>#&gt;   "address": &#123;</span></span>
<span><span class='c'>#&gt;     "streetAddress": "21 2nd Street",</span></span>
<span><span class='c'>#&gt;     "city": "New York",</span></span>
<span><span class='c'>#&gt;     "state": "NY",</span></span>
<span><span class='c'>#&gt;     "postalCode": "10021-3100"</span></span>
<span><span class='c'>#&gt;   &#125;,</span></span>
<span><span class='c'>#&gt;   "phoneNumbers": [</span></span>
<span><span class='c'>#&gt;     &#123;</span></span>
<span><span class='c'>#&gt;       "type": "home",</span></span>
<span><span class='c'>#&gt;       "number": "212 555-1234"</span></span>
<span><span class='c'>#&gt;     &#125;,</span></span>
<span><span class='c'>#&gt;     &#123;</span></span>
<span><span class='c'>#&gt;       "type": "office",</span></span>
<span><span class='c'>#&gt;       "number": "646 555-4567"</span></span>
<span><span class='c'>#&gt;     &#125;</span></span>
<span><span class='c'>#&gt;   ],</span></span>
<span><span class='c'>#&gt;   "children": [],</span></span>
<span><span class='c'>#&gt;   "spouse": null</span></span>
<span><span class='c'>#&gt; &#125;</span></span>
<span></span></code></pre>

</div>

But generally, you'll want to use the `resp_` functions to extract parts of the response. For example, you could parse the JSON body into an R data structure:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>resp</span> <span class='o'>|&gt;</span> </span>
<span>  <span class='nf'><a href='https://httr2.r-lib.org/reference/resp_body_raw.html'>resp_body_json</a></span><span class='o'>(</span><span class='o'>)</span> <span class='o'>|&gt;</span> </span>
<span>  <span class='nf'><a href='https://rdrr.io/r/utils/str.html'>str</a></span><span class='o'>(</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; List of 8</span></span>
<span><span class='c'>#&gt;  $ firstName   : chr "John"</span></span>
<span><span class='c'>#&gt;  $ lastName    : chr "Smith"</span></span>
<span><span class='c'>#&gt;  $ isAlive     : logi TRUE</span></span>
<span><span class='c'>#&gt;  $ age         : int 27</span></span>
<span><span class='c'>#&gt;  $ address     :List of 4</span></span>
<span><span class='c'>#&gt;   ..$ streetAddress: chr "21 2nd Street"</span></span>
<span><span class='c'>#&gt;   ..$ city         : chr "New York"</span></span>
<span><span class='c'>#&gt;   ..$ state        : chr "NY"</span></span>
<span><span class='c'>#&gt;   ..$ postalCode   : chr "10021-3100"</span></span>
<span><span class='c'>#&gt;  $ phoneNumbers:List of 2</span></span>
<span><span class='c'>#&gt;   ..$ :List of 2</span></span>
<span><span class='c'>#&gt;   .. ..$ type  : chr "home"</span></span>
<span><span class='c'>#&gt;   .. ..$ number: chr "212 555-1234"</span></span>
<span><span class='c'>#&gt;   ..$ :List of 2</span></span>
<span><span class='c'>#&gt;   .. ..$ type  : chr "office"</span></span>
<span><span class='c'>#&gt;   .. ..$ number: chr "646 555-4567"</span></span>
<span><span class='c'>#&gt;  $ children    : list()</span></span>
<span><span class='c'>#&gt;  $ spouse      : NULL</span></span>
<span></span></code></pre>

</div>

Or get the value of one header or a list of all of them:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>resp</span> <span class='o'>|&gt;</span> <span class='nf'><a href='https://httr2.r-lib.org/reference/resp_headers.html'>resp_header</a></span><span class='o'>(</span><span class='s'>"Content-Length"</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; [1] "407"</span></span>
<span></span><span></span>
<span><span class='nv'>resp</span> <span class='o'>|&gt;</span> <span class='nf'><a href='https://httr2.r-lib.org/reference/resp_headers.html'>resp_headers</a></span><span class='o'>(</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #0000BB;'>&lt;httr2_headers&gt;</span></span></span>
<span></span><span><span class='c'>#&gt; <span style='font-weight: bold;'>Connection</span>: close</span></span>
<span><span class='c'>#&gt; <span style='font-weight: bold;'>Date</span>: Tue, 14 Nov 2023 14:00:52 GMT</span></span>
<span><span class='c'>#&gt; <span style='font-weight: bold;'>Content-Type</span>: application/json</span></span>
<span><span class='c'>#&gt; <span style='font-weight: bold;'>Content-Length</span>: 407</span></span>
<span><span class='c'>#&gt; <span style='font-weight: bold;'>ETag</span>: "de760e6d"</span></span>
<span></span></code></pre>

</div>

## Error handling

You can use [`resp_status()`](https://httr2.r-lib.org/reference/resp_status.html) to see the returned status:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>resp</span> <span class='o'>|&gt;</span> <span class='nf'><a href='https://httr2.r-lib.org/reference/resp_status.html'>resp_status</a></span><span class='o'>(</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; [1] 200</span></span>
<span></span></code></pre>

</div>

However, this will almost always be 200, because httr2 automatically follows redirects (values in the 300s) and turns HTTP failures (values in the 400s and 500s) into R errors. The following example shows what this looks like using an example endpoint that returns a response with the status defined in the URL:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>req</span> <span class='o'>|&gt;</span> </span>
<span>  <span class='nf'><a href='https://httr2.r-lib.org/reference/req_url.html'>req_url_path</a></span><span class='o'>(</span><span class='s'>"/status/404"</span><span class='o'>)</span> <span class='o'>|&gt;</span> </span>
<span>  <span class='nf'><a href='https://httr2.r-lib.org/reference/req_perform.html'>req_perform</a></span><span class='o'>(</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #BBBB00; font-weight: bold;'>Error</span><span style='font-weight: bold;'> in `req_perform()`:</span></span></span>
<span><span class='c'>#&gt; <span style='color: #BBBB00;'>!</span> HTTP 404 Not Found.</span></span>
<span></span><span></span>
<span><span class='nv'>req</span> <span class='o'>|&gt;</span> </span>
<span>  <span class='nf'><a href='https://httr2.r-lib.org/reference/req_url.html'>req_url_path</a></span><span class='o'>(</span><span class='s'>"/status/500"</span><span class='o'>)</span> <span class='o'>|&gt;</span> </span>
<span>  <span class='nf'><a href='https://httr2.r-lib.org/reference/req_perform.html'>req_perform</a></span><span class='o'>(</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #BBBB00; font-weight: bold;'>Error</span><span style='font-weight: bold;'> in `req_perform()`:</span></span></span>
<span><span class='c'>#&gt; <span style='color: #BBBB00;'>!</span> HTTP 500 Internal Server Error.</span></span>
<span></span></code></pre>

</div>

Turning HTTP failures into R errors can make debugging hard, so httr2 provides the [`last_request()`](https://httr2.r-lib.org/reference/last_response.html) and [`last_response()`](https://httr2.r-lib.org/reference/last_response.html) helpers which you can use to figure out what went wrong:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://httr2.r-lib.org/reference/last_response.html'>last_request</a></span><span class='o'>(</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #0000BB;'>&lt;httr2_request&gt;</span></span></span>
<span></span><span><span class='c'>#&gt; <span style='font-weight: bold;'>GET</span> http://127.0.0.1:61307/status/500</span></span>
<span></span><span><span class='c'>#&gt; <span style='font-weight: bold;'>Body</span>: empty</span></span>
<span></span><span></span>
<span><span class='nf'><a href='https://httr2.r-lib.org/reference/last_response.html'>last_response</a></span><span class='o'>(</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #0000BB;'>&lt;httr2_response&gt;</span></span></span>
<span></span><span><span class='c'>#&gt; <span style='font-weight: bold;'>GET</span> http://127.0.0.1:61307/status/500</span></span>
<span></span><span><span class='c'>#&gt; <span style='color: #00BB00;'>Status</span>: 500 Internal Server Error</span></span>
<span></span><span><span class='c'>#&gt; <span style='color: #00BB00;'>Content-Type</span>: text/plain</span></span>
<span></span><span><span class='c'>#&gt; <span style='color: #00BB00;'>Body</span>: None</span></span>
<span></span></code></pre>

</div>

httr2 provides two other tools to customise error handling:

-   [`req_error()`](https://httr2.r-lib.org/reference/req_error.html) gives you full control over what responses should be turned into R errors, and allows you to add additional information to the error message.
-   [`req_retry()`](https://httr2.r-lib.org/reference/req_retry.html) helps deal with transient errors, where you need to wait a bit and try again. For example, many APIs are rate limited and will return a 429 status if you have made too many requests.

You can learn more about both of these functions in `vignette("wrapping-apis")` as they are particularly important when creating an R package (or script) that wraps a web API.

## Control the request process

There are a number of other `req_` functions don't directly affect the HTTP request but instead control the overall process of submitting a request and handling the response. These include:

-   [`req_cache()`](https://httr2.r-lib.org/reference/req_cache.html), which sets up a cache so if repeated requests return the same results, you can avoid a trip to the server. [`req_cache()`](https://httr2.r-lib.org/reference/req_cache.html) automatically prunes the cache, ensuring that by default it stays under 1 GB

-   [`req_throttle()`](https://httr2.r-lib.org/reference/req_throttle.html), which automatically adds a small delay before each request so you can avoid hammering a server with many requests.

-   [`req_progress()`](https://httr2.r-lib.org/reference/req_progress.html), which adds a progress bar for long downloads or uploads.

-   [`req_cookie_preserve()`](https://httr2.r-lib.org/reference/req_cookie_preserve.html), which lets you preserve cookies across requests.

Additionally, httr2 provides many helpers for authenticating with OAuth, implementing many more flows than httr. You've probably used OAuth a bunch without knowing what it's called: you use it when you login to a non-Google website using your Google account, when you give your phone access to your twitter account, or when you login to a streaming app on your smart TV. OAuth is a big, complex, topic, and is documented in `vignette("oauth2")`

## Multiple requests

httr2 includes three functions to perform multiple requests:

-   [`req_perform_sequential()`](https://httr2.r-lib.org/reference/req_perform_sequential.html) takes a list of requests and performs them one at a time.

-   [`req_perform_parallel()`](https://httr2.r-lib.org/reference/req_perform_parallel.html) takes a list of requests and performs them in parallel (up to 6 at a time by default). It's similar to [`req_perform_sequential()`](https://httr2.r-lib.org/reference/req_perform_sequential.html), but is obviously faster, at the expense of potentially hammering a server. It also has some limitations: most importantly it can't refresh an expired OAuth token and it doesn't respect [`req_retry()`](https://httr2.r-lib.org/reference/req_retry.html) or [`req_throttle()`](https://httr2.r-lib.org/reference/req_throttle.html).

-   [`req_perform_iterative()`](https://httr2.r-lib.org/reference/req_perform_iterative.html) takes a single request and a callback function to generate the next request from previous response. It'll keep going until the callback function returns `NULL` or `max_reqs` requests have been performed. This is very useful for paginated APIs that only tell you the URL for the *next* page.

For example, imagine we wanted to download each person from the [Star Wars API](https://swapi.dev). The URLs have a very consistent structure so we can generate a bunch of them, then create the corresponding requests:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>urls</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/paste.html'>paste0</a></span><span class='o'>(</span><span class='s'>"https://swapi.dev/api/people/"</span>, <span class='m'>1</span><span class='o'>:</span><span class='m'>10</span><span class='o'>)</span></span>
<span><span class='nv'>reqs</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/lapply.html'>lapply</a></span><span class='o'>(</span><span class='nv'>urls</span>, <span class='nv'>request</span><span class='o'>)</span></span></code></pre>

</div>

Now I can perform those requests, collecting a list of responses:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>resps</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://httr2.r-lib.org/reference/req_perform_sequential.html'>req_perform_sequential</a></span><span class='o'>(</span><span class='nv'>reqs</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; Iterating <span style='color: #00BB00;'>■■■■                            </span>  10% | ETA: 11s</span></span>
<span></span><span><span class='c'>#&gt; Iterating <span style='color: #00BB00;'>■■■■■■■                         </span>  20% | ETA:  9s</span></span>
<span></span><span><span class='c'>#&gt; Iterating <span style='color: #00BB00;'>■■■■■■■■■■                      </span>  30% | ETA:  8s</span></span>
<span></span><span><span class='c'>#&gt; Iterating <span style='color: #00BB00;'>■■■■■■■■■■■■■                   </span>  40% | ETA:  7s</span></span>
<span></span><span><span class='c'>#&gt; Iterating <span style='color: #00BB00;'>■■■■■■■■■■■■■■■■                </span>  50% | ETA:  6s</span></span>
<span></span><span><span class='c'>#&gt; Iterating <span style='color: #00BB00;'>■■■■■■■■■■■■■■■■■■■             </span>  60% | ETA:  4s</span></span>
<span></span><span><span class='c'>#&gt; Iterating <span style='color: #00BB00;'>■■■■■■■■■■■■■■■■■■■■■■          </span>  70% | ETA:  3s</span></span>
<span></span><span><span class='c'>#&gt; Iterating <span style='color: #00BB00;'>■■■■■■■■■■■■■■■■■■■■■■■■■       </span>  80% | ETA:  2s</span></span>
<span></span><span><span class='c'>#&gt; Iterating <span style='color: #00BB00;'>■■■■■■■■■■■■■■■■■■■■■■■■■■■■    </span>  90% | ETA:  1s</span></span>
<span></span><span><span class='c'>#&gt; Iterating <span style='color: #00BB00;'>■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■ </span> 100% | ETA:  0s</span></span>
<span></span></code></pre>

</div>

These responses contain their data in a JSON body:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>resps</span> <span class='o'>|&gt;</span> </span>
<span>  <span class='nv'>_</span><span class='o'>[[</span><span class='m'>1</span><span class='o'>]</span><span class='o'>]</span> <span class='o'>|&gt;</span> </span>
<span>  <span class='nf'><a href='https://httr2.r-lib.org/reference/resp_body_raw.html'>resp_body_json</a></span><span class='o'>(</span><span class='o'>)</span> <span class='o'>|&gt;</span> </span>
<span>  <span class='nf'><a href='https://rdrr.io/r/utils/str.html'>str</a></span><span class='o'>(</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; List of 16</span></span>
<span><span class='c'>#&gt;  $ name      : chr "Luke Skywalker"</span></span>
<span><span class='c'>#&gt;  $ height    : chr "172"</span></span>
<span><span class='c'>#&gt;  $ mass      : chr "77"</span></span>
<span><span class='c'>#&gt;  $ hair_color: chr "blond"</span></span>
<span><span class='c'>#&gt;  $ skin_color: chr "fair"</span></span>
<span><span class='c'>#&gt;  $ eye_color : chr "blue"</span></span>
<span><span class='c'>#&gt;  $ birth_year: chr "19BBY"</span></span>
<span><span class='c'>#&gt;  $ gender    : chr "male"</span></span>
<span><span class='c'>#&gt;  $ homeworld : chr "https://swapi.dev/api/planets/1/"</span></span>
<span><span class='c'>#&gt;  $ films     :List of 4</span></span>
<span><span class='c'>#&gt;   ..$ : chr "https://swapi.dev/api/films/1/"</span></span>
<span><span class='c'>#&gt;   ..$ : chr "https://swapi.dev/api/films/2/"</span></span>
<span><span class='c'>#&gt;   ..$ : chr "https://swapi.dev/api/films/3/"</span></span>
<span><span class='c'>#&gt;   ..$ : chr "https://swapi.dev/api/films/6/"</span></span>
<span><span class='c'>#&gt;  $ species   : list()</span></span>
<span><span class='c'>#&gt;  $ vehicles  :List of 2</span></span>
<span><span class='c'>#&gt;   ..$ : chr "https://swapi.dev/api/vehicles/14/"</span></span>
<span><span class='c'>#&gt;   ..$ : chr "https://swapi.dev/api/vehicles/30/"</span></span>
<span><span class='c'>#&gt;  $ starships :List of 2</span></span>
<span><span class='c'>#&gt;   ..$ : chr "https://swapi.dev/api/starships/12/"</span></span>
<span><span class='c'>#&gt;   ..$ : chr "https://swapi.dev/api/starships/22/"</span></span>
<span><span class='c'>#&gt;  $ created   : chr "2014-12-09T13:50:51.644000Z"</span></span>
<span><span class='c'>#&gt;  $ edited    : chr "2014-12-20T21:17:56.891000Z"</span></span>
<span><span class='c'>#&gt;  $ url       : chr "https://swapi.dev/api/people/1/"</span></span>
<span></span></code></pre>

</div>

There's lots of ways to deal with this sort of data (e.g. for loops or functional programming) but to make life easier, httr2 comes with its own helper, [`resps_data()`](https://httr2.r-lib.org/reference/resps_successes.html). This function takes a callback that retrieves the data for each response, then concatenates all the data into a single object. In this case, we need to wrap [`resp_body_json()`](https://httr2.r-lib.org/reference/resp_body_raw.html) in a list, so we get one list for each person, rather than one list in total:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>resps</span> <span class='o'>|&gt;</span> </span>
<span>  <span class='nf'><a href='https://httr2.r-lib.org/reference/resps_successes.html'>resps_data</a></span><span class='o'>(</span>\<span class='o'>(</span><span class='nv'>resp</span><span class='o'>)</span> <span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span><span class='nf'><a href='https://httr2.r-lib.org/reference/resp_body_raw.html'>resp_body_json</a></span><span class='o'>(</span><span class='nv'>resp</span><span class='o'>)</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>|&gt;</span> </span>
<span>  <span class='nv'>_</span><span class='o'>[</span><span class='m'>1</span><span class='o'>:</span><span class='m'>3</span><span class='o'>]</span> <span class='o'>|&gt;</span> </span>
<span>  <span class='nf'><a href='https://rdrr.io/r/utils/str.html'>str</a></span><span class='o'>(</span>list.len <span class='o'>=</span> <span class='m'>10</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; List of 3</span></span>
<span><span class='c'>#&gt;  $ :List of 16</span></span>
<span><span class='c'>#&gt;   ..$ name      : chr "Luke Skywalker"</span></span>
<span><span class='c'>#&gt;   ..$ height    : chr "172"</span></span>
<span><span class='c'>#&gt;   ..$ mass      : chr "77"</span></span>
<span><span class='c'>#&gt;   ..$ hair_color: chr "blond"</span></span>
<span><span class='c'>#&gt;   ..$ skin_color: chr "fair"</span></span>
<span><span class='c'>#&gt;   ..$ eye_color : chr "blue"</span></span>
<span><span class='c'>#&gt;   ..$ birth_year: chr "19BBY"</span></span>
<span><span class='c'>#&gt;   ..$ gender    : chr "male"</span></span>
<span><span class='c'>#&gt;   ..$ homeworld : chr "https://swapi.dev/api/planets/1/"</span></span>
<span><span class='c'>#&gt;   ..$ films     :List of 4</span></span>
<span><span class='c'>#&gt;   .. ..$ : chr "https://swapi.dev/api/films/1/"</span></span>
<span><span class='c'>#&gt;   .. ..$ : chr "https://swapi.dev/api/films/2/"</span></span>
<span><span class='c'>#&gt;   .. ..$ : chr "https://swapi.dev/api/films/3/"</span></span>
<span><span class='c'>#&gt;   .. ..$ : chr "https://swapi.dev/api/films/6/"</span></span>
<span><span class='c'>#&gt;   .. [list output truncated]</span></span>
<span><span class='c'>#&gt;  $ :List of 16</span></span>
<span><span class='c'>#&gt;   ..$ name      : chr "C-3PO"</span></span>
<span><span class='c'>#&gt;   ..$ height    : chr "167"</span></span>
<span><span class='c'>#&gt;   ..$ mass      : chr "75"</span></span>
<span><span class='c'>#&gt;   ..$ hair_color: chr "n/a"</span></span>
<span><span class='c'>#&gt;   ..$ skin_color: chr "gold"</span></span>
<span><span class='c'>#&gt;   ..$ eye_color : chr "yellow"</span></span>
<span><span class='c'>#&gt;   ..$ birth_year: chr "112BBY"</span></span>
<span><span class='c'>#&gt;   ..$ gender    : chr "n/a"</span></span>
<span><span class='c'>#&gt;   ..$ homeworld : chr "https://swapi.dev/api/planets/1/"</span></span>
<span><span class='c'>#&gt;   ..$ films     :List of 6</span></span>
<span><span class='c'>#&gt;   .. ..$ : chr "https://swapi.dev/api/films/1/"</span></span>
<span><span class='c'>#&gt;   .. ..$ : chr "https://swapi.dev/api/films/2/"</span></span>
<span><span class='c'>#&gt;   .. ..$ : chr "https://swapi.dev/api/films/3/"</span></span>
<span><span class='c'>#&gt;   .. ..$ : chr "https://swapi.dev/api/films/4/"</span></span>
<span><span class='c'>#&gt;   .. ..$ : chr "https://swapi.dev/api/films/5/"</span></span>
<span><span class='c'>#&gt;   .. ..$ : chr "https://swapi.dev/api/films/6/"</span></span>
<span><span class='c'>#&gt;   .. [list output truncated]</span></span>
<span><span class='c'>#&gt;  $ :List of 16</span></span>
<span><span class='c'>#&gt;   ..$ name      : chr "R2-D2"</span></span>
<span><span class='c'>#&gt;   ..$ height    : chr "96"</span></span>
<span><span class='c'>#&gt;   ..$ mass      : chr "32"</span></span>
<span><span class='c'>#&gt;   ..$ hair_color: chr "n/a"</span></span>
<span><span class='c'>#&gt;   ..$ skin_color: chr "white, blue"</span></span>
<span><span class='c'>#&gt;   ..$ eye_color : chr "red"</span></span>
<span><span class='c'>#&gt;   ..$ birth_year: chr "33BBY"</span></span>
<span><span class='c'>#&gt;   ..$ gender    : chr "n/a"</span></span>
<span><span class='c'>#&gt;   ..$ homeworld : chr "https://swapi.dev/api/planets/8/"</span></span>
<span><span class='c'>#&gt;   ..$ films     :List of 6</span></span>
<span><span class='c'>#&gt;   .. ..$ : chr "https://swapi.dev/api/films/1/"</span></span>
<span><span class='c'>#&gt;   .. ..$ : chr "https://swapi.dev/api/films/2/"</span></span>
<span><span class='c'>#&gt;   .. ..$ : chr "https://swapi.dev/api/films/3/"</span></span>
<span><span class='c'>#&gt;   .. ..$ : chr "https://swapi.dev/api/films/4/"</span></span>
<span><span class='c'>#&gt;   .. ..$ : chr "https://swapi.dev/api/films/5/"</span></span>
<span><span class='c'>#&gt;   .. ..$ : chr "https://swapi.dev/api/films/6/"</span></span>
<span><span class='c'>#&gt;   .. [list output truncated]</span></span>
<span></span></code></pre>

</div>

Another option would be to convert each response into a data frame or tibble. That's a little tricky here because of the nested lists that will need to become list-columns[^4], so we'll avoid that challenge here by focussing on the first nine columns:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>sw_data</span> <span class='o'>&lt;-</span> <span class='kr'>function</span><span class='o'>(</span><span class='nv'>resp</span><span class='o'>)</span> <span class='o'>&#123;</span></span>
<span>  <span class='nf'>tibble</span><span class='nf'>::</span><span class='nf'><a href='https://tibble.tidyverse.org/reference/as_tibble.html'>as_tibble</a></span><span class='o'>(</span><span class='nf'><a href='https://httr2.r-lib.org/reference/resp_body_raw.html'>resp_body_json</a></span><span class='o'>(</span><span class='nv'>resp</span><span class='o'>)</span><span class='o'>[</span><span class='m'>1</span><span class='o'>:</span><span class='m'>9</span><span class='o'>]</span><span class='o'>)</span></span>
<span><span class='o'>&#125;</span></span>
<span><span class='nv'>resps</span> <span class='o'>|&gt;</span> <span class='nf'><a href='https://httr2.r-lib.org/reference/resps_successes.html'>resps_data</a></span><span class='o'>(</span><span class='nv'>sw_data</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 10 × 9</span></span></span>
<span><span class='c'>#&gt;    <span style='font-weight: bold;'>name</span>           <span style='font-weight: bold;'>height</span> <span style='font-weight: bold;'>mass</span>  <span style='font-weight: bold;'>hair_color</span> <span style='font-weight: bold;'>skin_color</span> <span style='font-weight: bold;'>eye_color</span> <span style='font-weight: bold;'>birth_year</span> <span style='font-weight: bold;'>gender</span></span></span>
<span><span class='c'>#&gt;    <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>          <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>  <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>      <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>      <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>     <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>      <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span> </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 1</span> Luke Skywalker 172    77    blond      fair       blue      19BBY      male  </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 2</span> C-3PO          167    75    n/a        gold       yellow    112BBY     n/a   </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 3</span> R2-D2          96     32    n/a        white, bl… red       33BBY      n/a   </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 4</span> Darth Vader    202    136   none       white      yellow    41.9BBY    male  </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 5</span> Leia Organa    150    49    brown      light      brown     19BBY      female</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 6</span> Owen Lars      178    120   brown, gr… light      blue      52BBY      male  </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 7</span> Beru Whitesun… 165    75    brown      light      blue      47BBY      female</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 8</span> R5-D4          97     32    n/a        white, red red       unknown    n/a   </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 9</span> Biggs Darklig… 183    84    black      light      brown     24BBY      male  </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>10</span> Obi-Wan Kenobi 182    77    auburn, w… fair       blue-gray 57BBY      male  </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># ℹ 1 more variable: </span><span style='color: #555555; font-weight: bold;'>homeworld</span><span style='color: #555555;'> &lt;chr&gt;</span></span></span>
<span></span></code></pre>

</div>

When you're performing large numbers of requests, it's almost inevitable that something will go wrong. By default, all three functions will bubble up errors, causing you to lose all of the work that's been done so far. You can, however, use the `on_error` argument to change what happens, either ignoring errors, or returning when you hit the first error. This will changes the return value: instead of a list of responses, the list might now also contain error objects. httr2 provides other helpers to work with this object:

-   [`resps_successes()`](https://httr2.r-lib.org/reference/resps_successes.html) filters the list to find the successful responses. You'll can then pair this with [`resps_data()`](https://httr2.r-lib.org/reference/resps_successes.html) to get the data from the successful request.
-   [`resps_failures()`](https://httr2.r-lib.org/reference/resps_successes.html) filters the list to find the failed responses. You'll can then pair this with [`resps_requests()`](https://httr2.r-lib.org/reference/resps_successes.html) to find the requests that generated them and figure out what went wrong,.

## Acknowledgements

A big thanks to all 87 folks who have helped make httr2 possible!

[@allenbaron](https://github.com/allenbaron), [@asadow](https://github.com/asadow), [@atheriel](https://github.com/atheriel), [@boshek](https://github.com/boshek), [@casa-henrym](https://github.com/casa-henrym), [@cderv](https://github.com/cderv), [@colmanhumphrey](https://github.com/colmanhumphrey), [@cstjohn810](https://github.com/cstjohn810), [@cwang23](https://github.com/cwang23), [@DavidRLovell](https://github.com/DavidRLovell), [@DMerch](https://github.com/DMerch), [@dpprdan](https://github.com/dpprdan), [@ECOSchulz](https://github.com/ECOSchulz), [@edavidaja](https://github.com/edavidaja), [@elipousson](https://github.com/elipousson), [@emmansh](https://github.com/emmansh), [@Enchufa2](https://github.com/Enchufa2), [@ErdaradunGaztea](https://github.com/ErdaradunGaztea), [@fangzhou-xie](https://github.com/fangzhou-xie), [@fh-mthomson](https://github.com/fh-mthomson), [@fkohrt](https://github.com/fkohrt), [@flahn](https://github.com/flahn), [@gregleleu](https://github.com/gregleleu), [@guga31bb](https://github.com/guga31bb), [@gvelasq](https://github.com/gvelasq), [@hadley](https://github.com/hadley), [@hongooi73](https://github.com/hongooi73), [@howardbaek](https://github.com/howardbaek), [@jameslairdsmith](https://github.com/jameslairdsmith), [@JBGruber](https://github.com/JBGruber), [@jchrom](https://github.com/jchrom), [@jemus42](https://github.com/jemus42), [@jennybc](https://github.com/jennybc), [@jimrothstein](https://github.com/jimrothstein), [@jjesusfilho](https://github.com/jjesusfilho), [@jjfantini](https://github.com/jjfantini), [@jl5000](https://github.com/jl5000), [@jonthegeek](https://github.com/jonthegeek), [@JosiahParry](https://github.com/JosiahParry), [@judith-bourque](https://github.com/judith-bourque), [@juliasilge](https://github.com/juliasilge), [@kasperwelbers](https://github.com/kasperwelbers), [@kelvindso](https://github.com/kelvindso), [@kieran-mace](https://github.com/kieran-mace), [@KoderKow](https://github.com/KoderKow), [@lassehjorthmadsen](https://github.com/lassehjorthmadsen), [@llrs](https://github.com/llrs), [@lyndon-bird](https://github.com/lyndon-bird), [@m-mohr](https://github.com/m-mohr), [@maelle](https://github.com/maelle), [@maxheld83](https://github.com/maxheld83), [@mgirlich](https://github.com/mgirlich), [@MichaelChirico](https://github.com/MichaelChirico), [@michaelgfalk](https://github.com/michaelgfalk), [@misea](https://github.com/misea), [@MislavSag](https://github.com/MislavSag), [@mkoohafkan](https://github.com/mkoohafkan), [@mmuurr](https://github.com/mmuurr), [@multimeric](https://github.com/multimeric), [@nbenn](https://github.com/nbenn), [@nclsbarreto](https://github.com/nclsbarreto), [@nealrichardson](https://github.com/nealrichardson), [@Nelson-Gon](https://github.com/Nelson-Gon), [@olivroy](https://github.com/olivroy), [@owenjonesuob](https://github.com/owenjonesuob), [@paul-carteron](https://github.com/paul-carteron), [@pbulsink](https://github.com/pbulsink), [@ramiromagno](https://github.com/ramiromagno), [@rplati](https://github.com/rplati), [@rressler](https://github.com/rressler), [@samterfa](https://github.com/samterfa), [@schnee](https://github.com/schnee), [@sckott](https://github.com/sckott), [@sebastian-c](https://github.com/sebastian-c), [@selesnow](https://github.com/selesnow), [@Shaunson26](https://github.com/Shaunson26), [@SokolovAnatoliy](https://github.com/SokolovAnatoliy), [@spotrh](https://github.com/spotrh), [@stefanedwards](https://github.com/stefanedwards), [@taerwin](https://github.com/taerwin), [@vanhry](https://github.com/vanhry), [@wing328](https://github.com/wing328), [@xinzhuohkust](https://github.com/xinzhuohkust), [@yogat3ch](https://github.com/yogat3ch), [@yogesh-bansal](https://github.com/yogesh-bansal), [@yutannihilation](https://github.com/yutannihilation), and [@zacdav-db](https://github.com/zacdav-db).

[^1]: Pronounced "hitter 2".

[^2]: Well, technically, it does send the request, just to another test server that captures exactly what it was sent.

[^3]: This is only an approximation. For example, it only shows the final response if there were redirects, and it automatically uncompresses the body if it was compressed. Nevertheless, it's still pretty useful.

[^4]: To turn these into list-columns, you need to wrap each list in another list, something like `is_list <- map_lgl(json, is.list); json[is_list] <- map(json[is_list], list)`. This ensures that each element has length 1, the invariant for a row in a tibble.

