---
output: hugodown::hugo_document

slug: plumber2-0-2-0
title: plumber2 0.2.0
date: 2026-01-20
author: Thomas Lin Pedersen
description: >
    The next version of plumber2 has hit CRAN. Read all about the new features 
    such as OpenTelemetry (OTEL) support, authentication, new tags, and performance 
    improvements here.

photo:
  url: https://unsplash.com/photos/black-and-gray-metal-pipe-4CNNH2KEjhc
  author: Sigmund

# one of: "deep-dive", "learn", "package", "programming", "roundup", or "other"
categories: [package] 
tags: [plumber2, web]
rmd_hash: 2716f3157be6958a

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
* [ ] Add intro sentence, e.g. the standard tagline for the package
* [ ] [`usethis::use_tidy_thanks()`](https://usethis.r-lib.org/reference/use_tidy_thanks.html)
-->

We're stoked to announce the release of [plumber2](https://plumber2.posit.co) 0.2.0. plumber2 is a package for creating webservers in R based on either an annotation-based or programmatic workflow. It is the successor to the [plumber](https://www.rplumber.io/) package who has empowered the R community for 10 years and allowed them to share their R based functionalities with their organizations and the world.

You can install it from CRAN with:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'>pak</span><span class='nf'>::</span><span class='nf'><a href='https://pak.r-lib.org/reference/pak.html'>pak</a></span><span class='o'>(</span><span class='s'>"plumber2"</span><span class='o'>)</span></span></code></pre>

</div>

This release covers both a bunch of new features as well as some tangible improvements to performance. The headlining features are OpenTelemetry (OTEL) support and support for authentication which we will dive into below. In the end we will also provide a grab-bag of miscellaneous improvements for your enjoyment.

You can see a full list of changes in the [release notes](/news/index.html)

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://plumber2.posit.co/'>plumber2</a></span><span class='o'>)</span></span></code></pre>

</div>

## OTEL support

We have been hard at work at adding support for [OpenTelemetry (OTEL)](https://opentelemetry.io/) for our tools to allow easy instrumentation across our offerings, see e.g. the [shiny blog post](https://shiny.posit.co/blog/posts/shiny-r-1.12/) announcing support for it there. If you do not know what OTEL is, here is a short introduction to the subject:

OTEL describes itself as "high-quality, ubiquitous, and portable telemetry to enable effective observability". In simpler terms, OpenTelemetry is a set of tools, APIs, and SDKs that help you collect and export telemetry data (like traces, logs, and metrics) from your applications. This data provides insights into how your applications are performing and behaving in real-world scenarios.

It captures three key types of data:

1.  **Traces:** These show the path of a request through your application.
2.  **Logs:** These are detailed event records that capture what happened at specific moments.
3.  **Metrics:** These are numerical measurements over time, like how many users are connected or how long outputs take to render.

These data types were standardized under the OTEL project, [which is supported by a large community and many companies](https://opentelemetry.io/community/marketing-guidelines/#i-opentelemetry-is-a-joint-effort). The goal is to provide a consistent way to collect and export observability data, making it easier to monitor and troubleshoot applications.

OTEL is vendor-neutral, meaning you can send your telemetry data to various local backends like [Jaeger](https://www.jaegertracing.io/), [Zipkin](https://zipkin.io/), [Prometheus](https://prometheus.io/), or cloud-based services like [Grafana Cloud](https://grafana.com/products/cloud/), [Logfire](https://pydantic.dev/logfire), and [Langfuse](https://langfuse.com/). This flexibility means you're not locked into any particular monitoring solution.

While that may be somewhat of a mouthful the *tldr;* is that with OTEL you can capture what goes on in your application and use a variety of services to explore this data. This is great especially for code that is meant to be deployed and thus not readily available for introspection.

A great thing about OTEL is that traces are linked across applications. If you have multiple linked microservices based on plumber2, then you can follow a request trace as it travels between the different APIs. The same goes for a shiny app that calls into a plumber2 api or the other way around. As we build out support across our tools this benefit will only get more profound.

### OTEL in plumber2

While OTEL is integrated into plumber2 it is not activated by default. To set it up you need the otel and otelsdk installed and configured:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'>pak</span><span class='nf'>::</span><span class='nf'><a href='https://pak.r-lib.org/reference/pak.html'>pak</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"otel"</span>, <span class='s'>"otelsdk"</span><span class='o'>)</span><span class='o'>)</span></span></code></pre>

</div>

Configuration is completely code free and based on environment variables. You can e.g. add the lines below to your `.Renviron` file to setup OTEL with Logfire

``` bash
# Enable OpenTelemetry by setting Collector environment variables
OTEL_TRACES_EXPORTER=http
OTEL_LOGS_EXPORTER=http
OTEL_LOG_LEVEL=debug
OTEL_METRICS_EXPORTER=http

OTEL_EXPORTER_OTLP_ENDPOINT="https://logfire-us.pydantic.dev"
OTEL_EXPORTER_OTLP_HEADERS="Authorization=<your-write-token>"
```

You can verify that everything is set up by calling [`otel::is_tracing_enabled()`](https://otel.r-lib.org/reference/is_tracing_enabled.html) which should return `TRUE` in that case.

OTEL has an extensive list of semantic conventions for telemetry of various domains so that information is captured in a standardised way. plumber2 adheres to the HTTP server conventions and supports all the required and most of the recommended [trace attributes](https://opentelemetry.io/docs/specs/semconv/http/http-spans/#http-server-span) and [metrics](https://opentelemetry.io/docs/specs/semconv/http/http-metrics/).

Within a plumber2 API, a trace span is started the moment a request is received. The span is populated with the following information:

- `http.request.method`: The method of the request (e.g. `GET`, `POST`, etc)
- `url.path`: The exact path requested
- `url.scheme`: The protocol used for the request
- `http.route`: The route pattern of the last of the route handlers the request went through
- `network.protocol.name`: The internal protocol used. Always `http`
- `network.protocol.version`: The version of the protocol. Always `1.1`
- `server.port`: The port the server is listening on. Can be used to distinguish multiple concurrent servers
- `url.query`: The querystring of the request
- `client.address`: The IP address the request comes from
- `server.address`: The address the request was send to
- `user_agent.original`: The user agent of the client sending the request
- `http.request.header.<header-name>`: The value of `header-name` in the request. E.g. `http.request.header.date` will contain the value of the `Date` header

Once the request has been handled it will further append the following information:

- `http.response.status_code`: The status code of the response
- `http.response.header.<header-name>`: The value of `header-name` in the response. E.g. `http.response.header.content-type` will contain the value of the `Content-Type` header

In addition to the trace attributes above, a number of OTEL metrics are also recorded:

- `http.server.request.duration`: The duration of the request handling from it is received to it is send back
- `http.server.active_requests`: The number of active requests being handled at the given time
- `http.server.request.body.size`: The size of the request body
- `http.server.response.body.size`: The size of the response body

As a child of this parent span each handler in your API will also initiate a span with the following attributes:

- `routr.route`: The path pattern of the handler. This will be recorded in the routr representation which uses `:param` instead of `{param}` format (e.g. `users/:username` instead of `users/{username}`)
- `routr.path.param.<param-name>`: The value of the `param-name` path parameter. E.g. a request for `users/thomas` will get a `routr.path.param.username` attribute with the value `thomas` for the route `users/{username}`.

Any span you initiate inside a handler will become a child of the handler span and through that be linked to the parent request span.

As you can see, the integration provides extensive information for you to use when figuring out what is going on in your application. On top of that, you can also use OTEL as your logging solution by setting `logger_otel` as your logging solution:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://plumber2.posit.co/reference/api.html'>api</a></span><span class='o'>(</span><span class='o'>)</span> <span class='o'>|&gt;</span> </span>
<span>  <span class='nf'><a href='https://plumber2.posit.co/reference/api_logger.html'>api_logger</a></span><span class='o'>(</span><span class='nv'>logger_otel</span><span class='o'>)</span></span></code></pre>

</div>

This ensures that all the logs from errors, warnings, etc all end up in the same place as your other recordings and further gets linked to the exact request that gave rise to the log.

We truly believe extensive OTEL support across the ecosystem will be a game changer for deployed R code and we can't wait for our users to take advantage of it!

## Auth support

The second headliner is support for various authentication schemes out of the box. This comes courtesy of of the [fireproof](https://fireproof.data-imaginist.com) package which provides an auth plugin for fiery.

Setting up authentication is twofold: creating guards and attaching guards to routes.

First, you need to define one or more guards to use. A guard is an adaption of a specific authentication scheme such as e.g. OAuth. Currently, fireproof supports the Basic and Bearer HTTP authorization schemes, a custom key based scheme, as well as OAuth 2.0 and OpenID Connect. Setting up a guard can be done both programmatically and with annotations:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='c'># Programmatic</span></span>
<span><span class='nv'>api</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://plumber2.posit.co/reference/api.html'>api</a></span><span class='o'>(</span><span class='o'>)</span> <span class='o'>|&gt;</span> </span>
<span>  <span class='nf'><a href='https://plumber2.posit.co/reference/api_auth_guard.html'>api_auth_guard</a></span><span class='o'>(</span></span>
<span>    guard <span class='o'>=</span> <span class='nf'>fireproof</span><span class='nf'>::</span><span class='nf'><a href='https://fireproof.data-imaginist.com/reference/guard_key.html'>guard_key</a></span><span class='o'>(</span></span>
<span>      key_name <span class='o'>=</span> <span class='s'>"X-API-KEY"</span>,</span>
<span>      validate <span class='o'>=</span> <span class='s'>"MY_VERY_SECRET_KEY"</span></span>
<span>    <span class='o'>)</span>,</span>
<span>    name <span class='o'>=</span> <span class='s'>"key_guard"</span></span>
<span>  <span class='o'>)</span></span></code></pre>

</div>

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='c'># Annotation</span></span>
<span></span>
<span><span class='c'>#* @authGuard key_guard</span></span>
<span><span class='nf'>fireproof</span><span class='nf'>::</span><span class='nf'><a href='https://fireproof.data-imaginist.com/reference/guard_key.html'>guard_key</a></span><span class='o'>(</span></span>
<span>  key_name <span class='o'>=</span> <span class='s'>"X-API-KEY"</span>,</span>
<span>  validate <span class='o'>=</span> <span class='s'>"MY_VERY_SECRET_KEY"</span></span>
<span><span class='o'>)</span></span></code></pre>

</div>

Both of these pieces of code yields the same result. You API now has a guard registered under the name `key_guard` which will (if called upon) check a request for the existence of a cookie named `X-API-KEY` with the value `MY_VERY_SECRET_KEY`.

Secondly, your handlers can now integrate the guards to protect access to the requested path. Again, this can be done both programmatically and in annotation and will generally be handled when the request handler is created:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='c'># Programmatic</span></span>
<span><span class='nv'>api</span> <span class='o'>|&gt;</span> </span>
<span>  <span class='nf'><a href='https://plumber2.posit.co/reference/api_request_handlers.html'>api_get</a></span><span class='o'>(</span></span>
<span>    path <span class='o'>=</span> <span class='s'>"/admin"</span>,</span>
<span>    <span class='kr'>function</span><span class='o'>(</span><span class='nv'>...</span><span class='o'>)</span> <span class='o'>&#123;</span></span>
<span>      <span class='c'># whatever you wish to protect</span></span>
<span>    <span class='o'>&#125;</span>,</span>
<span>    auth_flow <span class='o'>=</span> <span class='nv'>key_guard</span></span>
<span>  <span class='o'>)</span></span>
<span></span></code></pre>

</div>

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='c'># Annotation</span></span>
<span></span>
<span><span class='c'>#* An example endpoint with auth</span></span>
<span><span class='c'>#* </span></span>
<span><span class='c'>#* @get /admin</span></span>
<span><span class='c'>#* @auth key_guard</span></span>
<span><span class='kr'>function</span><span class='o'>(</span><span class='nv'>...</span><span class='o'>)</span> <span class='o'>&#123;</span></span>
<span>  <span class='c'># whatever you wish to protect</span></span>
<span><span class='o'>&#125;</span></span></code></pre>

</div>

Again, both code chunks achieve the same thing. They set up the endpoint to require the `key_guard` to be passed before further handling takes place.

### Multiple guards and requirements

The previous section demonstrates the most basic authentication setup as it only uses the key guard---the simplest guard to configure. We can imagine a situation where we both want to allow users to log in with a username and password *or* authorize with a key and a google login. This requires defining multiple guards which can be done in sequence:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='c'>#* @authGuard key</span></span>
<span><span class='nf'>fireproof</span><span class='nf'>::</span><span class='nf'><a href='https://fireproof.data-imaginist.com/reference/guard_key.html'>guard_key</a></span><span class='o'>(</span></span>
<span>  key_name <span class='o'>=</span> <span class='s'>"X-API-KEY"</span>,</span>
<span>  validate <span class='o'>=</span> <span class='s'>"MY_VERY_SECRET_KEY"</span></span>
<span><span class='o'>)</span></span>
<span><span class='c'>#* @authGuard basic</span></span>
<span><span class='nf'>fireproof</span><span class='nf'>::</span><span class='nf'><a href='https://fireproof.data-imaginist.com/reference/guard_basic.html'>guard_basic</a></span><span class='o'>(</span></span>
<span>  validate <span class='o'>=</span> <span class='kr'>function</span><span class='o'>(</span><span class='nv'>username</span>, <span class='nv'>password</span><span class='o'>)</span> <span class='o'>&#123;</span></span>
<span>    <span class='nv'>username</span> <span class='o'>==</span> <span class='s'>"thomas"</span> <span class='o'>&amp;&amp;</span> <span class='nv'>password</span> <span class='o'>==</span> <span class='s'>"xrCy45rWrgwq"</span></span>
<span>  <span class='o'>&#125;</span></span>
<span><span class='o'>)</span></span>
<span><span class='c'>#* @authGuard google</span></span>
<span><span class='nf'>fireproof</span><span class='nf'>::</span><span class='nf'><a href='https://fireproof.data-imaginist.com/reference/guard_google.html'>guard_google</a></span><span class='o'>(</span></span>
<span>  redirect_url <span class='o'>=</span> <span class='s'>"https://example.com/auth"</span>,</span>
<span>  client_id <span class='o'>=</span> <span class='s'>"MY_APP_ID"</span>,</span>
<span>  client_secret <span class='o'>=</span> <span class='s'>"SUCHASECRET"</span></span>
<span><span class='o'>)</span></span></code></pre>

</div>

We now have 3 guards (of dubious quality) that we can attach to our handler. How do we capture the relationship of requiring either the basic to pass or the key and google to pass? Simple, with a logical expression:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='c'>#* An example endpoint with auth</span></span>
<span><span class='c'>#* </span></span>
<span><span class='c'>#* @get /admin</span></span>
<span><span class='c'>#* @auth basic || (key &amp;&amp; google)</span></span>
<span><span class='kr'>function</span><span class='o'>(</span><span class='nv'>...</span><span class='o'>)</span> <span class='o'>&#123;</span></span>
<span>  <span class='c'># whatever you wish to protect</span></span>
<span><span class='o'>&#125;</span></span></code></pre>

</div>

The names of the guards act as booleans and can be composed with the basic boolean operators (`||`, `&&`, and `(`/`)`). The combinations are endless!

### Scopes

Sometimes you need more granularity in your authentication. Some users may only read while others may read and write to resources. This could be solved with multiple guards but it quickly becomes unwieldy. Instead you can set scope requirements on an endpoint. Guards can then grant scopes to a user in their `validate` function by returning a character vector instead of a boolean, like this:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='c'>#* @authGuard basic</span></span>
<span><span class='nf'>fireproof</span><span class='nf'>::</span><span class='nf'><a href='https://fireproof.data-imaginist.com/reference/guard_basic.html'>guard_basic</a></span><span class='o'>(</span></span>
<span>  validate <span class='o'>=</span> <span class='kr'>function</span><span class='o'>(</span><span class='nv'>username</span>, <span class='nv'>password</span><span class='o'>)</span> <span class='o'>&#123;</span></span>
<span>    <span class='kr'>if</span> <span class='o'>(</span><span class='nv'>username</span> <span class='o'>==</span> <span class='s'>"guest"</span><span class='o'>)</span> <span class='o'>&#123;</span></span>
<span>      <span class='kr'><a href='https://rdrr.io/r/base/function.html'>return</a></span><span class='o'>(</span><span class='s'>"read"</span><span class='o'>)</span></span>
<span>    <span class='o'>&#125;</span></span>
<span>    <span class='kr'>if</span> <span class='o'>(</span><span class='nv'>username</span> <span class='o'>==</span> <span class='s'>"thomas"</span> <span class='o'>&amp;&amp;</span> <span class='nv'>password</span> <span class='o'>==</span> <span class='s'>"xrCy45rWrgwq"</span><span class='o'>)</span> <span class='o'>&#123;</span></span>
<span>      <span class='kr'><a href='https://rdrr.io/r/base/function.html'>return</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"read"</span>, <span class='s'>"write"</span><span class='o'>)</span><span class='o'>)</span></span>
<span>    <span class='o'>&#125;</span></span>
<span>    <span class='kc'>FALSE</span></span>
<span>  <span class='o'>&#125;</span></span>
<span><span class='o'>)</span></span>
<span></span>
<span><span class='c'>#* Read the calendar entries</span></span>
<span><span class='c'>#* </span></span>
<span><span class='c'>#* @get /calendar</span></span>
<span><span class='c'>#* @auth basic</span></span>
<span><span class='c'>#* @authScope read</span></span>
<span><span class='c'>#* </span></span>
<span><span class='kr'>function</span><span class='o'>(</span><span class='nv'>...</span><span class='o'>)</span> <span class='o'>&#123;</span></span>
<span>  <span class='c'># return calendar entries</span></span>
<span><span class='o'>&#125;</span></span>
<span></span>
<span><span class='c'>#* Add a new calendar entry</span></span>
<span><span class='c'>#* </span></span>
<span><span class='c'>#* @post /calendar</span></span>
<span><span class='c'>#* @auth basic</span></span>
<span><span class='c'>#* @authScope write</span></span>
<span><span class='c'>#* </span></span>
<span><span class='kr'>function</span><span class='o'>(</span><span class='nv'>...</span><span class='o'>)</span> <span class='o'>&#123;</span></span>
<span>  <span class='c'># update the calendar</span></span>
<span><span class='o'>&#125;</span></span></code></pre>

</div>

The authentication that can be integrated is very flexible and will only grow as more guards are added to fireproof.

## Other news

### Annotation for datastores

While datastores through the [firesale](https://github.com/thomasp85/firesale) package was supported upon release, they could only be set up programmatically. This has now been corrected with the addition of the `@datastore` tag. It works like this:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='c'>#* @datastore my_store</span></span>
<span><span class='nf'>storr</span><span class='nf'>::</span><span class='nf'><a href='https://richfitz.github.io/storr/reference/storr_environment.html'>driver_environment</a></span><span class='o'>(</span><span class='o'>)</span></span></code></pre>

</div>

The `my_store` proceeding the key is optional and gives the name of the datastore (defaults to `datastore`). Below the block you provide a [storr](https://richfitz.github.io/storr/) driver and then you are good to go.

Authentication requires a datastore in order to work as it facilitates persistent session login. Below, you can see an annotation implementation of a single guard that leverages a storr datastore.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='c'>#* @datastore ds</span></span>
<span><span class='nf'>storr</span><span class='nf'>::</span><span class='nf'><a href='https://richfitz.github.io/storr/reference/storr_environment.html'>driver_environment</a></span><span class='o'>(</span><span class='o'>)</span></span>
<span></span>
<span><span class='c'>#* @authGuard github</span></span>
<span><span class='nf'>fireproof</span><span class='nf'>::</span><span class='nf'><a href='https://fireproof.data-imaginist.com/reference/guard_github.html'>guard_github</a></span><span class='o'>(</span></span>
<span>  redirect_url <span class='o'>=</span> <span class='s'>"https://example.com/auth"</span>,</span>
<span>  client_id <span class='o'>=</span> <span class='s'>"MY_APP_ID"</span>,</span>
<span>  client_secret <span class='o'>=</span> <span class='s'>"SUCHASECRET"</span></span>
<span><span class='o'>)</span></span>
<span></span>
<span><span class='c'>#* Get a summary of your github commit history</span></span>
<span><span class='c'>#* </span></span>
<span><span class='c'>#* @auth github</span></span>
<span><span class='kr'>function</span><span class='o'>(</span><span class='nv'>ds</span><span class='o'>)</span> <span class='o'>&#123;</span></span>
<span>  <span class='nv'>github_token</span> <span class='o'>&lt;-</span> <span class='nv'>ds</span><span class='o'>$</span><span class='nv'>session</span><span class='o'>$</span><span class='nv'>github</span><span class='o'>$</span><span class='nv'>token</span><span class='o'>$</span><span class='nv'>access_token</span></span>
<span>  <span class='c'># Use the access token to fetch commit history and do some fun things</span></span>
<span><span class='o'>&#125;</span></span></code></pre>

</div>

### More powerful report support

The report endpoint has gotten even more powerful in this release in a number of ways:

- Report endpoints can now be added programmatically as well using [`api_report()`](https://plumber2.posit.co/reference/api_report.html)
- There is now support for quarto documents using the jupyter engine
- OpenAPI documentation is now generated automatically for the report and incorporates the standard annotation known from request handler blocks.
- Parameterised reports now has their parameters type checked and casted based on the type of the default values or on explicit type specification in the `@param` tags.
- You can now request specific named output formats through the `/{output_format}` subpath. This is in addition to the content negotiation already available. E.g. `/report/revealjs` will request the revealjs format of the report served at `/report`.
- Caches can now be user specific if the rendering includes information specific to the user requesting it
- Caches can now be cleared using a `DELETE` request

## Thank you

I want to say thanks to everyone who has given plumber2 a spin. It takes some time to reach maturity when replacing a decade old package and every test spin brings more insight. With the addition of OTEL integration and auth support plumber2 has now reached the feature set I was planning for during the initial development and the next phase will be about refinement, performance, and bug fixes. Your input and experiences will be critical there.

