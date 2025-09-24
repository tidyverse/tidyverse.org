---
output: hugodown::hugo_document

slug: plumber2-0-1-0
title: plumber2 0.1.0
date: 2025-09-23
author: Thomas Lin Pedersen
description: >
    plumber2, a complete rewrite of plumber, has landed on CRAN, providing a modern, future proof solution for creating web servers in R. Read all about the new features here.

photo:
  url: https://unsplash.com/photos/a-blue-pipe-laying-on-top-of-a-pile-of-dirt-MzPnzK3prTU
  author: Rose Galloway Green

# one of: "deep-dive", "learn", "package", "programming", "roundup", or "other"
categories: [package] 
tags: [plumber2, web]
rmd_hash: 889151eee9a13ea8

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
* [x] [`usethis::use_tidy_thanks()`](https://usethis.r-lib.org/reference/use_tidy_thanks.html)
-->

I'm super excited to announce the release of the plumber2 package on CRAN. plumber2 is a package for creating webservers in R based on either an annotation-based or programmatic workflow. It is the successor to the plumber package who has empowered the R community for 10 years and allowed them to share their R based functionalities with their organizations and the world.

You can install it from CRAN with:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'>pak</span><span class='nf'>::</span><span class='nf'><a href='https://pak.r-lib.org/reference/pak.html'>pak</a></span><span class='o'>(</span><span class='s'>"plumber2"</span><span class='o'>)</span></span></code></pre>

</div>

This blog post will go over the new release. Why create a new package? What has changed? What has stayed the same? and, What is new?

It's a mouthful, so let's get to it!

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://posit-dev.github.io/plumber2/'>plumber2</a></span><span class='o'>)</span></span></code></pre>

</div>

## Waving goodbye to plumber

The first question that may cross your mind is: Why even create a new package instead of continue to build on, and improve, the old one?

It is always a weighing of pros and cons when such a decision is made, but what largely tipped the scale was that the codebase had accrued so much technical debt that it had become hard to maintain. A lot has happened in 10 years and plumber has had to adapt to it all while maintaining backwards compatibility and in the end it took a toll on the codebase.

If you end up deciding on a rewrite you might as well take the opportunity to learn from past mistakes and shed some decisions that turned out wrong, without worrying about breaking existing code. This both gives you a chance to improve on the API, but also give you the freedom to create the best possible foundation without artificial boundaries based on existing uses.

So, in the end, we wanted a complete rewrite, and we wanted breaking changes. Instead of pulling the rug on users and break their deployments we chose to start afresh, leave the old plumber around, and allow users to gradually migrate to the new package.

## Familiarity

If you fear that the decisions we outlined above means that you need to start from square one despite being a seasoned plumber user then fear not. plumber2 takes the soul of plumber and carries it on. Annotations are still central to how you use plumber2 and most of them work just as before. There are, however, foundational changes in store for you, so you will have to update some of your habits to suit a new (and better) world.

Let's start with the core of annotations, which is the parsing of them. In plumber this was handled by an internal parser which tried to mimic how roxygen2 parsed documentation annotation. This led to almost, but not quite, parity with roxygen2 which tripped up users. plumber2 now uses roxygen2 directly for parsing, so any convention you have become used to from writing package documentation can be transferred. Most important of these are support for multi-line annotation (hello 2025), and the conventions around the first line being the title as well as any text between that and the first tag being a long-form description.

Along with the move to using roxygen2 comes a well-defined way of extending the annotation API, so that other packages more easily can extend plumber2 in a way that feels native without resorting to any unpleasant hacks.

Enough talk. How does it look? Below you see an annotation for a `GET` endpoint written for plumber2:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='c'>#* Get a weather forecast</span></span>
<span><span class='c'>#* </span></span>
<span><span class='c'>#* This endpoint will provide the client with a forecast for a </span></span>
<span><span class='c'>#* specific city. You can modify the length of the forecast </span></span>
<span><span class='c'>#* through the query parameters</span></span>
<span><span class='c'>#* </span></span>
<span><span class='c'>#* @get /forecast/&lt;city&gt;</span></span>
<span><span class='c'>#*</span></span>
<span><span class='c'>#*.@param city:string The city to query</span></span>
<span><span class='c'>#* @query length:integer|1, 10|(7) How long a forecast</span></span>
<span><span class='c'>#*</span></span>
<span><span class='c'>#* @response 200:[&#123;day:date, temp:number, rain:boolean&#125;] An array </span></span>
<span><span class='c'>#* of objects, each corresponding to a day</span></span>
<span><span class='c'>#* </span></span>
<span><span class='c'>#* @serializer json</span></span>
<span><span class='c'>#* @serializer yaml</span></span>
<span><span class='c'>#* </span></span>
<span><span class='kr'>function</span><span class='o'>(</span><span class='nv'>city</span>, <span class='nv'>query</span><span class='o'>)</span> <span class='o'>&#123;</span></span>
<span>  <span class='nf'>get_forecast</span><span class='o'>(</span><span class='nv'>city</span>, <span class='nv'>query</span><span class='o'>$</span><span class='nv'>length</span><span class='o'>)</span></span>
<span><span class='o'>&#125;</span></span></code></pre>

</div>

If you are a plumber user I hope you can agree that it doesn't look totally foreign. Sure, there are new things in there but all of them in the same spirit as what you know. We have already mentioned the support for multi-lines and how the first lines until the first tag are parsed. The first line with a tag, `@get` is also straight out of the plumber book and so is the following `@param` line.

The `@query` line is new however (in multiple ways). In plumber2 function input can come from 3 places: path parameters (`city` in the above), the query string (`length` in the above), or the request body (not shown). This was true in plumber as well, but in plumber2 we have made the distinction explicit. Instead of using `@param` to document them all we now have dedicated tags for input coming from query and body (`@query` and `@body` respectively). This is also reflected in the function signature where only path parameters are provided directly as arguments. Query input is provided through the `query` argument and body input is provided through the `body` argument. This means that there is no longer the potential for masking out arguments if e.g. the query string contained an element with the same name as a path parameter. It also means that we can avoid parsing both the query string and the request body if it is not used by the handler function.

The `@query` line holds more surprises in the form of richer type annotation. Numbers and integers can now be bounded (here, between 1 and 10), and all input can be provided with a default value (here, 7). plumber2 does automatic input checking and type conversion based on this, and will return early with an error if an input is of the wrong format. There are also even more types to use. Enums, Dates, Datetimes, Bytes, and Patterns are all now possible, along with rich descriptions of objects (as can be seen in the `@response` line). All of these will be casted to the correct R type and can potentially be provided as arrays by enclosing them in `[...]`.

The `@response` tag is also available in plumber, but in plumber2 you can now annotate the return type as well, using the same type syntax as used for input. Doing so will allow the people using your API to now what kind of return value to expect which is critical to writing robust interfaces.

The last two annotations are both new an old. plumber had a `@serializer` tag as well, where you could specify a named serializer. This would then be used to convert the return value of your function into a string or binary representation to send back to the client. In plumber2 this is still the case, but what is new is the possibility of specifying multiples. In fact, the default is to use a collection of common serialization formats and let the client chose which they prefer through the `Content-Type` header (a process known as content negotiation). While not shown here, the same is true for the `@parser` tag which allows you to specify how the request body should be parsed into an R object. If content negotiation fails (on either side) plumber2 will send a structured error response to the client so they can see what goes wrong.

There are of course more to it (we will touch on a range of new tags below), but the above will probably cover 80% of use cases and hopefully that all feels very familiar.

### Programmatic interface

While plumber2 promotes the use of annotations as a way to describe your webserver logic, it also provides a programmatic API that gives you all of the same abilities. In plumber, this api was prefixed with `pr_` which was a an acronym for "Plumber Route". In plumber2, both to avoid namespace collision and because not all functions are concerned with creating routes, we use the `api_` prefix. Many functions in plumber have a counterpart in plumber2 but there has been made no attempt to ensure compatibility between arguments etc. Thus, if you have used the programmatic interface in plumber you may experience a bit more friction in moving over to plumber2. Consult the [extensive documentation](https://plumber2.posit.co/reference/index.html) if you are in that boat.

## New features

The rewrite has allowed us to add many new features which would either have been extremely cumbersome or downright unfeasible to add to plumber. While not exhaustive, the following will give you a taste of what is now possible

### Multi-file APIs

With plumber2 you are no longer limited to a single file for describing your api. Multiple files can be passed into the constructor ([`api()`](https://plumber2.posit.co/reference/api.html)) and by default they will each constitute a single route. This implies the plumber2 has support for multiple routes which will be tried in turn, which again implies full middleware support. This extended power replaces the filters and `@preempt` in plumber.

The properties of each plumber2 file can be modified with a few specific annotations that must (if present) appear at the top of the file, e.g.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='c'>#* @routeName secondary_route</span></span>
<span><span class='c'>#* @routeOrder 10</span></span>
<span><span class='c'>#* @root /sub/path</span></span>
<span><span class='kc'>NULL</span></span></code></pre>

</div>

The above sets the name of the route (defaults to the file name), the position in the chain of routes (defaults to the order they are passed to the constructor), as well as provides a root which will be prepended to all endpoints defined in the file. If multiple files has the same `@routeName` they will be merged into the same route, so even if you only need a single layer of middleware, this is a great way to organize a web server implementation that has grown large.

### Websocket support

While plumber was born as a way to create REST apis, the web is broader than that and sometimes your web server need to use additional technologies. WebSocket is a bidirectional communication layer that is initiated by the client and, once established, allows both the server and the client to send messages back and forth at any point in time. WebSockets is the technology that powers Shiny' reactive capabilities so it is not new in the world of R, and plumber2 gives you access to both receive and send messages at your leisure.

You can add a websocket listener using the `@message` tag like so:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='c'>#* @message</span></span>
<span><span class='kr'>function</span><span class='o'>(</span><span class='nv'>message</span>, <span class='nv'>client_id</span>, <span class='nv'>server</span><span class='o'>)</span> <span class='o'>&#123;</span></span>
<span>  <span class='nf'>cli</span><span class='nf'>::</span><span class='nf'><a href='https://cli.r-lib.org/reference/cli_abort.html'>cli_inform</a></span><span class='o'>(</span><span class='s'>"WS message from &#123;client_id&#125;: &#123;message&#125;"</span><span class='o'>)</span></span>
<span>  </span>
<span>  <span class='nv'>server</span><span class='o'>$</span><span class='nf'>time</span><span class='o'>(</span></span>
<span>    <span class='nv'>server</span><span class='o'>$</span><span class='nf'>send</span><span class='o'>(</span><span class='s'>"We got your message, alright!"</span>, <span class='nv'>client_id</span><span class='o'>)</span>,</span>
<span>    after <span class='o'>=</span> <span class='m'>5</span></span>
<span>  <span class='o'>)</span></span>
<span><span class='o'>&#125;</span></span></code></pre>

</div>

In the above we set up (a rather nonsensical) WebSocket logic which will log any incoming messages from a client and then, after 5 seconds have passed, send back a message to the client.

### Async evaluation

plumber2 expands on the asynchronous evaluation supported in plumber. Like in plumber it is still possible to return a promise from a handler (both for HTTP and websocket handlers), which will then be evaluated asynchronously and, in the case of a HTTP handler, modify the response once done, before sending it back to the client. What is new is that standard handlers can be converted to asynchronous handlers automatically. All it takes is adding the `@async` tag to the annotation, and plumber2 takes care of the rest. The functionality is build upon [mirai](https://mirai.r-lib.org), which is a modern framework for async evaluation with very little overhead. However, it is extendible so if a new better framework comes along it is easy to add, either directly in plumber2 or in an extension package.

To convert the forecast endpoint from our first example into an asynchronous one we just have to add a single line:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='c'>#* Get a weather forecast</span></span>
<span><span class='c'>#* </span></span>
<span><span class='c'>#* This endpoint will provide the client with a forecast for a </span></span>
<span><span class='c'>#* specific city. You can modify the length of the forecast </span></span>
<span><span class='c'>#* through the query parameters</span></span>
<span><span class='c'>#* </span></span>
<span><span class='c'>#* @get /forecast/&lt;city&gt;</span></span>
<span><span class='c'>#*</span></span>
<span><span class='c'>#*.@param city:string The city to query</span></span>
<span><span class='c'>#* @query length:integer|1, 10|(7) How long a forecast</span></span>
<span><span class='c'>#*</span></span>
<span><span class='c'>#* @response 200:[&#123;day:date, temp:number, rain:boolean&#125;] An array </span></span>
<span><span class='c'>#* of objects, each corresponding to a day</span></span>
<span><span class='c'>#* </span></span>
<span><span class='c'>#* @serializer json</span></span>
<span><span class='c'>#* @serializer yaml</span></span>
<span><span class='c'>#* </span></span>
<span><span class='c'>#* @async</span></span>
<span><span class='kr'>function</span><span class='o'>(</span><span class='nv'>city</span>, <span class='nv'>query</span><span class='o'>)</span> <span class='o'>&#123;</span></span>
<span>  <span class='nf'>get_forecast</span><span class='o'>(</span><span class='nv'>city</span>, <span class='nv'>query</span><span class='o'>$</span><span class='nv'>length</span><span class='o'>)</span></span>
<span><span class='o'>&#125;</span></span></code></pre>

</div>

Since async evaluation is happening in a different process they do not have access to the server object, nor the request and response object. All they can do is return a value which will be set to the response body. If you need to work with either of these objects you can chain a function call to the async one which will execute in the main process once the async expression has returned. You can do this by adding a `@then` block directly after the async one, e.g.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='c'>#* ...</span></span>
<span><span class='c'>#* of objects, each corresponding to a day</span></span>
<span><span class='c'>#* </span></span>
<span><span class='c'>#* @serializer json</span></span>
<span><span class='c'>#* @serializer yaml</span></span>
<span><span class='c'>#* </span></span>
<span><span class='c'>#* @async</span></span>
<span><span class='kr'>function</span><span class='o'>(</span><span class='nv'>city</span>, <span class='nv'>query</span><span class='o'>)</span> <span class='o'>&#123;</span></span>
<span>  <span class='nf'>get_forecast</span><span class='o'>(</span><span class='nv'>city</span>, <span class='nv'>query</span><span class='o'>$</span><span class='nv'>length</span><span class='o'>)</span></span>
<span><span class='o'>&#125;</span></span>
<span><span class='c'>#* @then</span></span>
<span><span class='kr'>function</span><span class='o'>(</span><span class='nv'>result</span>, <span class='nv'>response</span><span class='o'>)</span> <span class='o'>&#123;</span></span>
<span>  <span class='nv'>response</span><span class='o'>$</span><span class='nv'>body</span> <span class='o'>&lt;-</span> <span class='nv'>result</span></span>
<span>  <span class='nv'>response</span><span class='o'>$</span><span class='nf'>set_header</span><span class='o'>(</span><span class='s'>"cache-control"</span>, <span class='s'>"max-age=86400"</span><span class='o'>)</span></span>
<span>  <span class='nv'>Next</span></span>
<span><span class='o'>&#125;</span></span></code></pre>

</div>

In the above we set the body to the result of the prior async expression (this would have happened automatically), then we add an additional header to the response which would have been otherwise impossible in the async expression and lastly we return the `Next` sentinel which signal that the request can move on to the next route/middleware.

### Redirection and forwarding

Over the lifetime of a webserver you may end up cleaning up functionality or moving things around. If some functionality ends up at a different path your API will contain dead links unless you do something about it. plumber2 makes it easy to redirect requests to a new location so that users of the API can gracefully migrate to the new location without disruption.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='c'>#* @redirect !get /old/data/* /new/data/*</span></span>
<span><span class='c'>#* @redirect any /unstable/endpoint /stable/endpoint</span></span>
<span><span class='kc'>NULL</span></span></code></pre>

</div>

The above adds two different redirects. One is a permanent redirect (denoted by the `!` in front of the method). It redirects all `GET` requests from `/old/data/*` to `/new/data/*` be returning a `308` response directing the client to try the new location. The other is a temporary redirect which instead returns a `307` response.

You can use wildcards (as shown above) and path parameters in the redirection paths as long as they match between the old and new path (the new path can drop path parameters from old, but can't make up new ones).

Redirection goes through the client. The server responds with a `307`/`308` response that include the new location of the resource and it is up to the client to follow that to the final destination.

There is another kind of redirection, one that is invisible to the client, where the server forwards the request to another service and returns the response to the client once it receives it. This is called a reverse proxy. A reverse proxy can either forward a request to another service running locally, or to a service running on a separate server. Reverse proxying is implemented with the `@forward` tag:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='c'>#* @forward /proxy http://127.0.0.1:56789</span></span>
<span><span class='c'>#* @except /local</span></span>
<span><span class='kc'>NULL</span></span></code></pre>

</div>

The above sets up a reverse proxy that forwards requests made to `/proxy` to the service running locally on `http://127.0.0.1:56789`. It uses the `@except` tag to preclude requests to `/proxy/local/*` from being forwarded.

### Shiny support

Build on top of the reverse proxy capabilities is support for launching and serving one or more shiny applications. The shiny applications are launched in another process and HTTP and WebSocket communication is forwarded to it. Once the plumber2 server stops the shiny applications are stopped as well. Launching a shiny application is very straightforward:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='c'>#* @shiny /my_app/</span></span>
<span><span class='nf'>shiny</span><span class='nf'>::</span><span class='nf'><a href='https://rdrr.io/pkg/shiny/man/shinyApp.html'>shinyAppDir</a></span><span class='o'>(</span><span class='s'>"./shiny"</span><span class='o'>)</span></span></code></pre>

</div>

You use the `@shiny` tag and provide the path from where you want to serve the shiny app, then, below the annotation where the handler would normally be, you provide a shiny app object.

You can also use the `@except` tag here meaning that it is e.g. possible to serve a shiny app from the root, but e.g. let requests to `/api/*` fall through and be handled by plumber2:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='c'>#* @shiny /</span></span>
<span><span class='c'>#* @except /api</span></span>
<span><span class='nf'>shiny</span><span class='nf'>::</span><span class='nf'><a href='https://rdrr.io/pkg/shiny/man/shinyApp.html'>shinyAppDir</a></span><span class='o'>(</span><span class='s'>"./frontend"</span><span class='o'>)</span></span>
<span></span>
<span><span class='c'>#* @get /api</span></span>
<span><span class='c'>#* ...</span></span>
<span><span class='kr'>function</span><span class='o'>(</span><span class='nv'>...</span><span class='o'>)</span> <span class='o'>&#123;</span></span>
<span>  <span class='nv'>...</span></span>
<span><span class='o'>&#125;</span></span></code></pre>

</div>

### Serving Quarto and Rmarkdown documents

In the same vein as serving shiny applications, plumber2 also allows you to easily serve quarto or rmarkdown documents. The syntax for this follows that of the shiny functionality closely

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='c'>#* @report /quarterly_report</span></span>
<span><span class='s'>"./reports/my_amazing_report.qmd"</span></span></code></pre>

</div>

You provide the path to serve the report from with the `@report` tag and then points to the quarto (or rmarkdown) file below the block. If you have a parameterized report you can pass in parameters through the query string, and if your report provides multiple output formats the client can choose between them, either through content negotiation or be appending the correct file extension to the url (e.g. requesting `/quarterly_report.pdf` in the above will render a PDF version and requesting `/quarterly_report.html` will render to HTML). Reports are cached so they are only rendered when needed.

### Persistent data storage

Keeping state between requests to a server can be done in multiple ways. Of course a REST api does away completely with state so if you follow that then it is simply not needed. But not everything is RESTful and sometimes state is required. In plumber, this could be done through an encrypted session cookie. This cookie was passed back and forth at every request ensuring that the same data was available at repeat visits. This is still possible in plumber2 through the `session` field of the request and response object. However, as noted in the plumber documentation as well, this approach comes with certain downsides. First, the need to pass the data back and forth at every request limits how much data can feasibly be stored. Second, the use of a cookie means that e.g. websocket logic will not have access to the data. Lastly, sending it back and forth is a security liability even if encrypted. If someone got hold of your encryption key they could eavesdrop on everything going on between the server and client.

The alternative is to keep all the data on the server, in a persistent cross-session way. To that end plumber2 provides a persistent datastore build on the [storr](https://richfitz.github.io/storr/) package. storr provides a unified frontend for a variety of different data stores, such as redis, postgresql, LMDB etc. Neither storr nor plumber2 takes care of setting up the data store so the onus for that is still on the developer. However, once setup plumber2 automatically provides a global and a client-scoped key-value store accessible for handlers.

The data store cannot be set up through annotations but uses the programmatic interface. However, this can be mixed in with annotations in a `@plumber` block. Below is an example of setting it up as well as using it in a handler

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='c'>#* @plumber</span></span>
<span><span class='kr'>function</span><span class='o'>(</span><span class='nv'>api</span><span class='o'>)</span> <span class='o'>&#123;</span></span>
<span>  <span class='nv'>api</span> <span class='o'>|&gt;</span> </span>
<span>    <span class='nf'>api_datastore</span><span class='o'>(</span><span class='nf'>storr</span><span class='nf'>::</span><span class='nf'><a href='https://richfitz.github.io/storr/reference/storr_environment.html'>driver_environment</a></span><span class='o'>(</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='o'>&#125;</span></span>
<span></span>
<span><span class='c'>#* Example of using the datastore</span></span>
<span><span class='c'>#* </span></span>
<span><span class='c'>#* @get /hello</span></span>
<span><span class='c'>#* </span></span>
<span><span class='kr'>function</span><span class='o'>(</span><span class='nv'>datastore</span><span class='o'>)</span> <span class='o'>&#123;</span></span>
<span>  <span class='kr'>if</span> <span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/length.html'>length</a></span><span class='o'>(</span><span class='nv'>datastore</span><span class='o'>$</span><span class='nv'>session</span><span class='o'>)</span> <span class='o'>==</span> <span class='m'>0</span><span class='o'>)</span> <span class='o'>&#123;</span></span>
<span>    <span class='nv'>datastore</span><span class='o'>$</span><span class='nv'>global</span><span class='o'>$</span><span class='nv'>count</span> <span class='o'>&lt;-</span> <span class='o'>(</span><span class='nv'>datastore</span><span class='o'>$</span><span class='nv'>global</span><span class='o'>$</span><span class='nv'>count</span> <span class='o'><a href='https://rdrr.io/r/base/Control.html'>%||%</a></span> <span class='m'>0</span><span class='o'>)</span> <span class='o'>+</span> <span class='m'>1</span></span>
<span>    <span class='nv'>datastore</span><span class='o'>$</span><span class='nv'>session</span><span class='o'>$</span><span class='nv'>not_first_visit</span> <span class='o'>&lt;-</span> <span class='kc'>TRUE</span></span>
<span>    <span class='nf'><a href='https://rdrr.io/r/base/paste.html'>paste0</a></span><span class='o'>(</span><span class='s'>"Welcome. You are visitor #"</span>, <span class='nv'>datastore</span><span class='o'>$</span><span class='nv'>global</span><span class='o'>$</span><span class='nv'>count</span><span class='o'>)</span></span>
<span>  <span class='o'>&#125;</span> <span class='kr'>else</span> <span class='o'>&#123;</span></span>
<span>    <span class='s'>"Welcome back"</span></span>
<span>  <span class='o'>&#125;</span></span>
<span><span class='o'>&#125;</span></span>
<span></span>
<span><span class='nf'><a href='https://plumber2.posit.co/reference/api.html'>api</a></span><span class='o'>(</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'>api_datastore</span><span class='o'>(</span><span class='nf'>storr</span><span class='nf'>::</span><span class='nf'><a href='https://richfitz.github.io/storr/reference/storr_environment.html'>driver_environment</a></span><span class='o'>(</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://plumber2.posit.co/reference/api_request_handlers.html'>api_get</a></span><span class='o'>(</span><span class='s'>"hello"</span>, <span class='o'>)</span></span></code></pre>

</div>

Above we set up a datastore based on an R environment. This is of course not a scalable solution but is easy to use for trying things out. The `api_datastore()` most importantly takes a driver argument which is a storr compliant driver, as well as a number of other configurations that all have sensible defaults. After activating the datastore a new argument will be available in the handlers (the name defaults to `datastore` but can be changed). This argument contains two elements: `global` and `session`. Both of these are list-like interfaces to the underlying datastore and allows you to read and write data, either to the global store or one scoped to the current session.

### Security

Whenever you opens up a server to the rest of the world, security should be a concern. This is both true for servers only used internally, but even more so for servers that communicate with the world wide web. plumber2 sets out to be a huge improvement over plumber in this regard. While no amount of tooling can substitute good understanding of the various attack vectors possible on the web, they can make it more ergonomic to have sensible security measures.

The key takeaway from the above is that the following functionality doesn't negate the need for a security professional if your organization exposes a server to the web, but they can make said security professional more happy in their day-to-day work.

#### Security headers

A plumber2 API will predominantly use the HTTP protocol to communicate with the client. Over the cause of the internets existence there have been a cat-and-mouse game going on between bad actors that wish to scam or otherwise harm users, and the people developing the internet into being a safe experience. A lot of the improvements to security have been implemented as specific HTTP headers where the server opt into certain behavior that is safer for the client. plumber2 provides an easy way to set these headers and provides good sensible defaults as well.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>pa</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://plumber2.posit.co/reference/api.html'>api</a></span><span class='o'>(</span><span class='o'>)</span> <span class='o'>|&gt;</span> </span>
<span>  <span class='nf'>api_security_headers</span><span class='o'>(</span><span class='o'>)</span></span></code></pre>

</div>

There are a lot of different headers being set by the above code. Some of it is only relevant if you serve HTML, while other is relevant predominantly if you are serving other assets. Some of it may even stop your web server from working properly because it gets too restricted. The golden path to walk is as tight settings as possible without breaking the api, so always start with tight settings and then gradually relax it (or find alternative ways to implement it) until things work.

#### CORS

CORS (Cross Origin Resource Sharing) is a way to allow sharing of content across domains, something that is otherwise restricted for safety. If you host your API on one domain and tries to access it from another domain you need to allow CORS. In plumber2 this is fairly straightforward using the `@cors` tag:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='c'>#* Get a weather forecast</span></span>
<span><span class='c'>#* </span></span>
<span><span class='c'>#* This endpoint will provide the client with a forecast for a </span></span>
<span><span class='c'>#* specific city. You can modify the length of the forecast </span></span>
<span><span class='c'>#* through the query parameters</span></span>
<span><span class='c'>#* </span></span>
<span><span class='c'>#* @get /forecast/&lt;city&gt;</span></span>
<span><span class='c'>#* </span></span>
<span><span class='c'>#* @cors https://my-trusted-weather-app.com</span></span>
<span><span class='c'>#* </span></span>
<span><span class='c'>#* ...</span></span></code></pre>

</div>

Continuing our weather forecast app from before, if we wish to allow a secondary app to use the api, we will need to turn on CORS and allow it for the domain (here, `https://my-trusted-weather-app.com`). This is easily done with the `@cors` tag as can be seen above.

#### Resource Isolation Policies

RIP (Resource Isolation Policies) is another way of ensuring that resources from your server is not used by other sites. It is build upon the `Sec-Fetch-*` suite of request headers and allow you to block a request at the server level if it does not come from a trusted place or is being used for a valid reason. RIP can be configured much like CORS using the `@rip` tag.

## Future

So, plumber2 is here, it is great, and it contains a bunch of new stuff. What now?

Well, if you are already using plumber I hope you are excited. But, there is no rush. plumber will stay on CRAN in a superseded state and all your servers will continue to work. We hope you'll take part in kicking the tires on plumber2 however, so that it can get some milage under its belt.

If you haven't used plumber but still managed to reach this point of the blog post I think it is fair to assume that you are quite interested in creating web servers. Welcome! plumber2 will hopefully be a joyful experience for you but we can't wait to learn where it could be even easier to use for a newcomer.

If you do maintain packages that build on top of plumber, I hope you'll consider augmenting those to also work with plumber2. plumber2 has been build with extensibility in mind so hopefully you'll feel empowered to make your tools even more amazing. If you do come across things that are hard, or impossible, to extend, let us know so we may look into it.

Happy plumbing!

