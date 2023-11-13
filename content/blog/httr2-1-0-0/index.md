---
output: hugodown::hugo_document

slug: httr2-1-0-0
title: httr2 1.0.0
date: 2023-11-10
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
rmd_hash: ddab4a5c8fc85add

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

We're delighted to announce the release of [httr2](https://httr2.r-lib.org)[^1] 1.0.0. httr2 is the second generation of httr; it generates HTTP requests and helps you process the response, design with an towards modern web APIs and potentially putting your code in package.

You can install it from CRAN with:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://rdrr.io/r/utils/install.packages.html'>install.packages</a></span><span class='o'>(</span><span class='s'>"httr2"</span><span class='o'>)</span></span></code></pre>

</div>

httr2 has been under development for the last two years, but this is the first time we've blogged about it because we wanted to wait until we were confident that the API is stable. We're now confident that the API is stable, and we're ready to encourage you to use it. Most importantly httr2 is now a real package with a wonderful new logo, thanks to a collaborative effort involving Julie Jung, Greg Swineheart, and DALL•E 3.

<div class="highlight">

<img src="httr2.png" alt="The new httr2 logo is a dark blue hexagon with httr2 written in bright white at the top of logo. Underneath the text is a vibrant magenta baseball player hitting a ball emblazoned with the letters &quot;www&quot;." width="200px" style="display: block; margin: auto;" />

</div>

httr2 is the successor to httr. The big difference is that it has an explicit request object which you can build up over time. This makes the interface work much more naturally with pipe, and is generally easier to work with as you can build up a complex request with many simple features. If you're a current httr user, there's no need to switch, as we'll continue to maintain the package many years, but if you start on a new project, I'd recommend that you give httr2 a shot.

If you've been following httr2 development for a while, you might want to jump to the [release notes](%7B%20github_release%20%7D) to see what's new (a lot!). The most important change in this release is that @mgirlich is now a httr2 author, in recognition of his many contributions to the package.

For the rest of this blog post, I'll assume that you're familiar with the basics of HTTP. If you're not, you might want to start with `vignette("httr2")` which introduces the basics of httr2 and HTTP together.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://httr2.r-lib.org'>httr2</a></span><span class='o'>)</span></span></code></pre>

</div>

## Making a request

httr2 is designed around the two big pieces of HTTP: requests and responses. First you'll create a request, with a URL

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>req</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://httr2.r-lib.org/reference/request.html'>request</a></span><span class='o'>(</span><span class='nf'><a href='https://httr2.r-lib.org/reference/example_url.html'>example_url</a></span><span class='o'>(</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='nv'>req</span></span>
<span><span class='c'>#&gt; <span style='color: #0000BB;'>&lt;httr2_request&gt;</span></span></span>
<span></span><span><span class='c'>#&gt; <span style='font-weight: bold;'>GET</span> http://127.0.0.1:53014/</span></span>
<span></span><span><span class='c'>#&gt; <span style='font-weight: bold;'>Body</span>: empty</span></span>
<span></span></code></pre>

</div>

Here, instead of an external website, we use a test server that's built-in to httr2 itself. This ensures that this blog post, and many httr2 examples, work independently of the rest of the internet.

You can see the raw HTTP request that httr2 will perform by doing a dry run:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>req</span> <span class='o'>|&gt;</span> <span class='nf'><a href='https://httr2.r-lib.org/reference/req_dry_run.html'>req_dry_run</a></span><span class='o'>(</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; GET / HTTP/1.1</span></span>
<span><span class='c'>#&gt; <span style='font-weight: bold;'>Host</span>: 127.0.0.1:53014</span></span>
<span><span class='c'>#&gt; <span style='font-weight: bold;'>User-Agent</span>: httr2/0.2.3.9000 r-curl/5.1.0 libcurl/8.1.2</span></span>
<span><span class='c'>#&gt; <span style='font-weight: bold;'>Accept</span>: */*</span></span>
<span><span class='c'>#&gt; <span style='font-weight: bold;'>Accept-Encoding</span>: deflate, gzip</span></span>
<span></span></code></pre>

</div>

This makes a very simple `GET` request with user agent and accept headings automatically added by httr2. You can customise the request using the functions that start with `req_`. For example, you could make it a `HEAD` request and change the user agent with this code:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>req</span> <span class='o'>|&gt;</span> </span>
<span>  <span class='nf'><a href='https://httr2.r-lib.org/reference/req_user_agent.html'>req_user_agent</a></span><span class='o'>(</span><span class='s'>"My user agent"</span><span class='o'>)</span> <span class='o'>|&gt;</span> </span>
<span>  <span class='nf'><a href='https://httr2.r-lib.org/reference/req_method.html'>req_method</a></span><span class='o'>(</span><span class='s'>"HEAD"</span><span class='o'>)</span> <span class='o'>|&gt;</span> </span>
<span>  <span class='nf'><a href='https://httr2.r-lib.org/reference/req_dry_run.html'>req_dry_run</a></span><span class='o'>(</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; HEAD / HTTP/1.1</span></span>
<span><span class='c'>#&gt; <span style='font-weight: bold;'>Host</span>: 127.0.0.1:53014</span></span>
<span><span class='c'>#&gt; <span style='font-weight: bold;'>User-Agent</span>: My user agent</span></span>
<span><span class='c'>#&gt; <span style='font-weight: bold;'>Accept</span>: */*</span></span>
<span><span class='c'>#&gt; <span style='font-weight: bold;'>Accept-Encoding</span>: deflate, gzip</span></span>
<span></span></code></pre>

</div>

Or you could send some JSON in the body with this code:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>req</span> <span class='o'>|&gt;</span> </span>
<span>  <span class='nf'><a href='https://httr2.r-lib.org/reference/req_body.html'>req_body_json</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span>x <span class='o'>=</span> <span class='m'>1</span>, y <span class='o'>=</span> <span class='s'>"a"</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>|&gt;</span> </span>
<span>  <span class='nf'><a href='https://httr2.r-lib.org/reference/req_dry_run.html'>req_dry_run</a></span><span class='o'>(</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; POST / HTTP/1.1</span></span>
<span><span class='c'>#&gt; <span style='font-weight: bold;'>Host</span>: 127.0.0.1:53014</span></span>
<span><span class='c'>#&gt; <span style='font-weight: bold;'>User-Agent</span>: httr2/0.2.3.9000 r-curl/5.1.0 libcurl/8.1.2</span></span>
<span><span class='c'>#&gt; <span style='font-weight: bold;'>Accept</span>: */*</span></span>
<span><span class='c'>#&gt; <span style='font-weight: bold;'>Accept-Encoding</span>: deflate, gzip</span></span>
<span><span class='c'>#&gt; <span style='font-weight: bold;'>Content-Type</span>: application/json</span></span>
<span><span class='c'>#&gt; <span style='font-weight: bold;'>Content-Length</span>: 15</span></span>
<span><span class='c'>#&gt; </span></span>
<span><span class='c'>#&gt; &#123;"x":1,"y":"a"&#125;</span></span>
<span></span></code></pre>

</div>

httr2 provides a [wide range of helpers](https://httr2.r-lib.org/dev/reference/index.html#requests) to customise the request in common ways; if there's something you need but you can't figure out how, please [file an issue](https://github.com/r-lib/httr2/issues/new)!

## Performing the request and handling the response

Once you have a request that you are happy with, you can send it to the server with [`req_perform()`](https://httr2.r-lib.org/reference/req_perform.html):

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>req_json</span> <span class='o'>&lt;-</span> <span class='nv'>req</span> <span class='o'>|&gt;</span> <span class='nf'><a href='https://httr2.r-lib.org/reference/req_url.html'>req_url_path</a></span><span class='o'>(</span><span class='s'>"/json"</span><span class='o'>)</span></span>
<span><span class='nv'>resp</span> <span class='o'>&lt;-</span> <span class='nv'>req_json</span> <span class='o'>|&gt;</span> <span class='nf'><a href='https://httr2.r-lib.org/reference/req_perform.html'>req_perform</a></span><span class='o'>(</span><span class='o'>)</span></span></code></pre>

</div>

This returns a response object. You can see basic details by printing it or a simulation of what the response looked like with [`resp_raw()`](https://httr2.r-lib.org/reference/resp_raw.html) (this is only a simulation because it only shows the final response if there were redirects and it automatically uncompresses the body etc):

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>resp</span></span>
<span><span class='c'>#&gt; <span style='color: #0000BB;'>&lt;httr2_response&gt;</span></span></span>
<span></span><span><span class='c'>#&gt; <span style='font-weight: bold;'>GET</span> http://127.0.0.1:53014/json</span></span>
<span></span><span><span class='c'>#&gt; <span style='color: #00BB00;'>Status</span>: 200 OK</span></span>
<span></span><span><span class='c'>#&gt; <span style='color: #00BB00;'>Content-Type</span>: application/json</span></span>
<span></span><span><span class='c'>#&gt; <span style='color: #00BB00;'>Body</span>: In memory (407 bytes)</span></span>
<span></span><span></span>
<span><span class='nv'>resp</span> <span class='o'>|&gt;</span> <span class='nf'><a href='https://httr2.r-lib.org/reference/resp_raw.html'>resp_raw</a></span><span class='o'>(</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; HTTP/1.1 200 OK</span></span>
<span><span class='c'>#&gt; <span style='font-weight: bold;'>Connection</span>: close</span></span>
<span><span class='c'>#&gt; <span style='font-weight: bold;'>Date</span>: Mon, 13 Nov 2023 16:28:14 GMT</span></span>
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

Or get the value of one header, or a list of all of them:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>resp</span> <span class='o'>|&gt;</span> <span class='nf'><a href='https://httr2.r-lib.org/reference/resp_headers.html'>resp_header</a></span><span class='o'>(</span><span class='s'>"Content-Length"</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; [1] "407"</span></span>
<span></span><span></span>
<span><span class='nv'>resp</span> <span class='o'>|&gt;</span> <span class='nf'><a href='https://httr2.r-lib.org/reference/resp_headers.html'>resp_headers</a></span><span class='o'>(</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #0000BB;'>&lt;httr2_headers&gt;</span></span></span>
<span></span><span><span class='c'>#&gt; <span style='font-weight: bold;'>Connection</span>: close</span></span>
<span><span class='c'>#&gt; <span style='font-weight: bold;'>Date</span>: Mon, 13 Nov 2023 16:28:14 GMT</span></span>
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

However, this will almost always be 200, because httr2 automatically follows redirects (values in the 300s) and turns HTTP errors (values in the 400s and 500s) into errors. The following example shows what this looks like using a example endpoint that throws the returns the request status:

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

httr2 provides two main tools to customise this behaviour:

-   [`req_error()`](https://httr2.r-lib.org/reference/req_error.html) gives you full control over what responses will be considered to be errors, and allows you to put additional information in the body of the error.
-   [`req_retry()`](https://httr2.r-lib.org/reference/req_retry.html) helps deal with transient errors, where you need to wait a bit and try again. For example, many APIs are rate limited and will return a 429 status if you have made too many requests.

You can learn more about both of these functions in `vignette("wrapping-apis")` as they are particularly important when creating an R package (or script) that wraps a web API.

## Control the request process

There are a number of other `req_` functions don't directly affect the HTTP request but instead control the overall process of submitting a request and handling the response. These include:

-   [`req_cache()`](https://httr2.r-lib.org/reference/req_cache.html) sets up a cache so if repeated requests return the same results, you can avoid a trip to the server. [`req_cache()`](https://httr2.r-lib.org/reference/req_cache.html) automatically prunes the cache, ensuring that by default it stays under 1 GB

-   [`req_throttle()`](https://httr2.r-lib.org/reference/req_throttle.html) automatically adds a small delay before each request so you can avoid hammering a server with many requests.

-   [`req_progress()`](https://httr2.r-lib.org/reference/req_progress.html) adds a progress bar for long downloads or uploads.

-   [`req_cookie_preserve()`](https://httr2.r-lib.org/reference/req_cookie_preserve.html) lets you preserve cookies across requests.

Additionally, httr2 provides many helpers for authenticating with OAuth, wrapping many more styles than httr. You've probably used OAuth a bunch without knowing what it's called: you use it when you login to a non-Google website using your Google account, when you give your phone access to your twitter account, or when you login to a streaming app on your smart TV. OAuth is a big, complex topic, and is documented in `vignette("oauth2")`

## Multiple requests

httr2 includes three functions to perform multiple requests:

-   [`req_perform_sequential()`](https://httr2.r-lib.org/reference/req_perform_sequential.html) takes a list of requests and performs them in order.

-   [`req_perform_parallel()`](https://httr2.r-lib.org/reference/req_perform_parallel.html) takes a list of requests and performs them in parallel (up to 6 at a time by default). It's similar to [`req_perform_sequential()`](https://httr2.r-lib.org/reference/req_perform_sequential.html), but is obviously faster, at the expense of potentially hammering a server. However, it also has some limitations: most importantly it can't re-request an expired OAuth token and it doesn't respect [`req_retry()`](https://httr2.r-lib.org/reference/req_retry.html) or [`req_throttle()`](https://httr2.r-lib.org/reference/req_throttle.html).

-   [`req_perform_iterative()`](https://httr2.r-lib.org/reference/req_perform_iterative.html) takes a single request and a callback function to generate the next request from previous response. It'll keep going until it either your callback function returns `NULL` or the `max_reqs` requests have been performed.

For example, imagine we wanted to download each person from the [Star Wars API](https://swapi.dev). The urls have a very consistent structure so we can generate a bunch of them, then create the corresponding requests.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>urls</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/paste.html'>paste0</a></span><span class='o'>(</span><span class='s'>"https://swapi.dev/api/people/"</span>, <span class='m'>1</span><span class='o'>:</span><span class='m'>10</span><span class='o'>)</span></span>
<span><span class='nv'>reqs</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/lapply.html'>lapply</a></span><span class='o'>(</span><span class='nv'>urls</span>, <span class='nv'>request</span><span class='o'>)</span></span></code></pre>

</div>

Now I can perform those requests, collecting a list of responses:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>resps</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://httr2.r-lib.org/reference/req_perform_sequential.html'>req_perform_sequential</a></span><span class='o'>(</span><span class='nv'>reqs</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; Iterating <span style='color: #00BB00;'>■■■■■■■■■■                      </span>  30% | ETA:  3s</span></span>
<span></span><span><span class='c'>#&gt; Iterating <span style='color: #00BB00;'>■■■■■■■■■■■■■                   </span>  40% | ETA:  2s</span></span>
<span></span><span><span class='c'>#&gt; Iterating <span style='color: #00BB00;'>■■■■■■■■■■■■■■■■                </span>  50% | ETA:  2s</span></span>
<span></span><span><span class='c'>#&gt; Iterating <span style='color: #00BB00;'>■■■■■■■■■■■■■■■■■■■■■■          </span>  70% | ETA:  1s</span></span>
<span></span><span><span class='c'>#&gt; Iterating <span style='color: #00BB00;'>■■■■■■■■■■■■■■■■■■■■■■■■■       </span>  80% | ETA:  1s</span></span>
<span></span><span><span class='c'>#&gt; Iterating <span style='color: #00BB00;'>■■■■■■■■■■■■■■■■■■■■■■■■■■■■    </span>  90% | ETA:  0s</span></span>
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

There's lots of ways to deal with this sort of data (e.g. for loops or functional programming), httr2 comes with a helper,[`resps_data()`](https://httr2.r-lib.org/reference/resps_successes.html). It takes a callback function that retrieves the data for each response then concatenate all the responses back together. In this case that means we need to wrap [`resp_body_json()`](https://httr2.r-lib.org/reference/resp_body_raw.html) in a list, so we get one list for each person, rather than one list in total:

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

Another option would be to convert each response into a data frame or tibble. That's a little tricky here because of the lists that will need to become list-columns[^2], so we'll avoid that challenge here by focussing the first nine columns:

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

When you're performing large numbers of requests, it's almost inevitable that something will go wrong. By default, all three functions will bubble up errors, causing you to lose of the work that's been done so far. You can, however, use the `on_error` argument to change what happens, either ignoring errors, or returning when you hit the first error. This changes the return value: instead of a list of just responses, the list might also continue error objects.

httr2 provides other helpers to work with this output:

-   [`resps_successes()`](https://httr2.r-lib.org/reference/resps_successes.html) filters the list to find the successful responses. You'll then typically pair this with [`resps_data()`](https://httr2.r-lib.org/reference/resps_successes.html) to get the data from the successful request.
-   [`resps_failures()`](https://httr2.r-lib.org/reference/resps_successes.html) filters the list to find the failed responses. You'll typically pair this with [`resps_requests()`](https://httr2.r-lib.org/reference/resps_successes.html) to find the requests that generated them.

## Acknowledgements

[^1]: Pronounced "hitter 2".

[^2]: To turn these into list-columns, you need to wrap each list in another list, something like `is_list <- map_lgl(json, is.list); json[is_list] <- map(json[is_list], list)`. This ensures that each element has length 1, the invariant for a row in a tibble.

