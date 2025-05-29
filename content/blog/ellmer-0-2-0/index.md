---
output: hugodown::hugo_document

slug: ellmer-0-2-0
title: ellmer 0.2.0
date: 2025-05-28
author: Hadley Wickham
description: >
    ellmer 0.2.0 lands with a swag of upgrades: Garrick Aden‑Buie joins the 
    team, we make a couple of breaking changes, and added serious scale with 
    `parallel_chat()` and `batch_chat()`. A new `params()` helper standardises 
    model settings across providers and chats now report how much they cost. 
    The release also tidies `chat_*` names, bumps default models and adds 
    Hugging Face, Mistral AI, and Portkey connectors.
photo:
  url: https://unsplash.com/photos/n6vS3xlnsCc
  author: Kelley Bozarth

# one of: "deep-dive", "learn", "package", "programming", "roundup", or "other"
categories: [package] 
tags: [ellmer, llms]
rmd_hash: 5f21f0f4ee8eef63

---

<!--
TODO:
* [x] Look over / edit the post's title in the yaml
* [x] Edit (or delete) the description; note this appears in the Twitter card
* [x] Pick category and tags (see existing with [`hugodown::tidy_show_meta()`](https://rdrr.io/pkg/hugodown/man/use_tidy_post.html))
* [ ] Find photo & update yaml metadata
* [ ] Create `thumbnail-sq.jpg`; height and width should be equal
* [ ] Create `thumbnail-wd.jpg`; width should be >5x height
* [ ] [`hugodown::use_tidy_thumbnails()`](https://rdrr.io/pkg/hugodown/man/use_tidy_post.html)
* [ ] Add intro sentence, e.g. the standard tagline for the package
* [ ] [`usethis::use_tidy_thanks()`](https://usethis.r-lib.org/reference/use_tidy_thanks.html)
-->

# ellmer 0.2.0

I'm thrilled to announce the release of [ellmer 0.2.0](https://ellmer.tidyverse.org)! ellmer is an R package designed to make it easy to use large language models (LLMs) from R. It supports a wide variety of providers (including OpenAI, Anthropic, Azure, Google, Snowflake, Databricks and many more), makes it easy to [extract structured data](https://ellmer.tidyverse.org/articles/structured-data.html), and to give the LLM the ability to call R functions via [tool calling](https://ellmer.tidyverse.org/articles/tool-calling.html).

You can install it from CRAN with:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://rdrr.io/r/utils/install.packages.html'>install.packages</a></span><span class='o'>(</span><span class='s'>"ellmer"</span><span class='o'>)</span></span></code></pre>

</div>

Before diving into the details of what's new, I wanted to welcome Garrick Aden-Buie to the development team! Garrick is one of my colleagues at Posit, and has been instrumental in building out the developer side of ellmer, particularly as it pertains to tool calling and async, with the goal of making [shinychat](https://posit-dev.github.io/shinychat/) as useful as possible.

In this post, I'll walk you through the key changes in this release: a couple of breaking changes, new batched and parallel processing capabilities, a cleaner way to set model parameters, built-in cost estimates, and general updates to our provider ecosystem. This was a giant release, and I'm only touching on the most important topics here, so if you want all the details, please check out the [release notes](https://github.com/tidyverse/ellmer/releases/tag/v0.2.0).

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://ellmer.tidyverse.org'>ellmer</a></span><span class='o'>)</span></span></code></pre>

</div>

## Breaking changes

Before we dive into the cool new features, we need to talk about the less fun stuff: some breaking changes. As the ellmer package is still experimental (i.e. it has not yet reached 1.0.0), we will be making some breaking changes from time-to-time. That said, we'll always provide a way to revert to the old behaviour and will generally avoid changes that we expect will affect a lot of exsiting code. There are three breaking changes in this release:

-   We've made some refinements to how ellmer converts JSON to R data structures. The most important change is that tools are now invoked with their inputs converted to standard R data structures. This means you'll get proper R vectors, lists, and data frames instead of raw JSON objects, making your functions easier to write. If you prefer the old behavior, you can opt out with `tool(convert = FALSE)`.

-   The `turn` argument has been removed been removed from the `chat_` functions; use `Chat$set_turns()` instead.

-   `Chat$tokens()` has been renamed to to `Chat$get_tokens()` and it now returns a correctly structured data frame with rows aligned to turns.

## Batch and parallel chat

One of the most exciting additions in 0.2.0 is support for processing multiple chats efficiently. If you've ever found yourself wanting to run the same prompt against hundreds or thousands of different inputs you now have two powerful options: [`parallel_chat()`](https://ellmer.tidyverse.org/reference/parallel_chat.html) and [`batch_chat()`](https://ellmer.tidyverse.org/reference/batch_chat.html).

[`parallel_chat()`](https://ellmer.tidyverse.org/reference/parallel_chat.html) works with any provider and lets you submit multiple chats simultaneously:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>chat</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://ellmer.tidyverse.org/reference/chat_openai.html'>chat_openai</a></span><span class='o'>(</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; Using <span style='color: #00BB00;'>model</span> = <span style='color: #0000BB;'>"gpt-4.1"</span>.</span></span>
<span></span><span><span class='nv'>prompts</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://ellmer.tidyverse.org/reference/interpolate.html'>interpolate</a></span><span class='o'>(</span><span class='s'>"</span></span>
<span><span class='s'>  What do people from &#123;&#123;state.name&#125;&#125; bring to a potluck dinner?</span></span>
<span><span class='s'>  Give me the top three things.</span></span>
<span><span class='s'>"</span><span class='o'>)</span></span></code></pre>

</div>

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>results</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://ellmer.tidyverse.org/reference/parallel_chat.html'>parallel_chat</a></span><span class='o'>(</span><span class='nv'>chat</span>, <span class='nv'>prompts</span><span class='o'>)</span></span>
<span><span class='c'># [working] (32 + 0) -&gt; 10 -&gt; 8 | ■■■■■■                            16%</span></span></code></pre>

</div>

This doesn't save you money, but it can be dramatically faster than processing chats sequentially. (Also note that [`interpolate()`](https://ellmer.tidyverse.org/reference/interpolate.html) is now vectorised, making it much easier to generate many prompts from vectors or data frames.)

[`batch_chat()`](https://ellmer.tidyverse.org/reference/batch_chat.html) currently works with OpenAI and Anthropic, offering a different trade-off:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>chat</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://ellmer.tidyverse.org/reference/chat_openai.html'>chat_openai</a></span><span class='o'>(</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; Using <span style='color: #00BB00;'>model</span> = <span style='color: #0000BB;'>"gpt-4.1"</span>.</span></span>
<span></span><span><span class='nv'>results</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://ellmer.tidyverse.org/reference/batch_chat.html'>batch_chat</a></span><span class='o'>(</span><span class='nv'>chat</span>, <span class='nv'>prompts</span>, path <span class='o'>=</span> <span class='s'>"potluck.json"</span><span class='o'>)</span></span>
<span><span class='nv'>results</span><span class='o'>[[</span><span class='m'>1</span><span class='o'>]</span><span class='o'>]</span></span>
<span><span class='c'>#&gt; &lt;Chat OpenAI/gpt-4.1 turns=2 tokens=26/133 $0.00&gt;</span></span>
<span><span class='c'>#&gt; ── <span style='color: #0000BB;'>user</span> [26] ────────────────────────────────────────────────────────────────────────</span></span>
<span><span class='c'>#&gt; What do people from Alabama bring to a potluck dinner?</span></span>
<span><span class='c'>#&gt; Give me the top three things.</span></span>
<span><span class='c'>#&gt; ── <span style='color: #00BB00;'>assistant</span> [133] ──────────────────────────────────────────────────────────────────</span></span>
<span><span class='c'>#&gt; At a potluck dinner in Alabama, you'll most often find these top three dishes brought by guests:</span></span>
<span><span class='c'>#&gt; </span></span>
<span><span class='c'>#&gt; 1. **Fried Chicken** – Always a southern staple, crispy homemade (or sometimes store-bought!) fried chicken is practically expected.</span></span>
<span><span class='c'>#&gt; 2. **Deviled Eggs** – Easy to make, transport, and always a crowd-pleaser at southern gatherings.</span></span>
<span><span class='c'>#&gt; 3. **Homemade Casserole** – Usually something like broccoli cheese casserole, hashbrown casserole, or chicken and rice casserole, casseroles are a potluck favorite because they serve many and are comforting.</span></span>
<span><span class='c'>#&gt; </span></span>
<span><span class='c'>#&gt; Honorable mentions: banana pudding, macaroni and cheese, and cornbread.</span></span>
<span></span></code></pre>

</div>

Batch requests can take up to 24 hours to complete (although often finish much faster), but cost 50% less than regular requests. This makes them perfect for large-scale analysis where you can afford to wait. Since they can take a long time to complete, [`batch_chat()`](https://ellmer.tidyverse.org/reference/batch_chat.html) requires a `path`, which is used to store information about the state of the job, ensuring that you never lose any work. If you want to keep using your R session, you can either set `wait = FALSE` or simply interrupt the waiting process, then later, either call [`batch_chat()`](https://ellmer.tidyverse.org/reference/batch_chat.html) to resume where you left off or call [`batch_chat_completed()`](https://ellmer.tidyverse.org/reference/batch_chat.html) to see if the results are ready to retrieve. [`batch_chat()`](https://ellmer.tidyverse.org/reference/batch_chat.html) will store the chat responses in this file, so you can either keep it around to cache the results, or delete it to free up disk space.

Both functions come with structured data variations: [`batch_chat_structured()`](https://ellmer.tidyverse.org/reference/batch_chat.html) and [`parallel_chat_structured()`](https://ellmer.tidyverse.org/reference/parallel_chat.html), which make it easy to extract structured data from multiple strings.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>prompts</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span></span>
<span>  <span class='s'>"I go by Alex. 42 years on this planet and counting."</span>,</span>
<span>  <span class='s'>"Pleased to meet you! I'm Jamal, age 27."</span>,</span>
<span>  <span class='s'>"They call me Li Wei. Nineteen years young."</span>,</span>
<span>  <span class='s'>"Fatima here. Just celebrated my 35th birthday last week."</span>,</span>
<span>  <span class='s'>"The name's Robert - 51 years old and proud of it."</span>,</span>
<span>  <span class='s'>"Kwame here - just hit the big 5-0 this year."</span></span>
<span><span class='o'>)</span></span>
<span><span class='nv'>type_person</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://ellmer.tidyverse.org/reference/type_boolean.html'>type_object</a></span><span class='o'>(</span>name <span class='o'>=</span> <span class='nf'><a href='https://ellmer.tidyverse.org/reference/type_boolean.html'>type_string</a></span><span class='o'>(</span><span class='o'>)</span>, age <span class='o'>=</span> <span class='nf'><a href='https://ellmer.tidyverse.org/reference/type_boolean.html'>type_number</a></span><span class='o'>(</span><span class='o'>)</span><span class='o'>)</span></span>
<span></span>
<span><span class='nv'>data</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://ellmer.tidyverse.org/reference/batch_chat.html'>batch_chat_structured</a></span><span class='o'>(</span></span>
<span>  chat <span class='o'>=</span> <span class='nv'>chat</span>,</span>
<span>  prompts <span class='o'>=</span> <span class='nv'>prompts</span>,</span>
<span>  path <span class='o'>=</span> <span class='s'>"people-data.json"</span>,</span>
<span>  type <span class='o'>=</span> <span class='nv'>type_person</span></span>
<span><span class='o'>)</span></span>
<span><span class='nv'>data</span></span>
<span><span class='c'>#&gt;     name age</span></span>
<span><span class='c'>#&gt; 1   Alex  42</span></span>
<span><span class='c'>#&gt; 2  Jamal  27</span></span>
<span><span class='c'>#&gt; 3 Li Wei  19</span></span>
<span><span class='c'>#&gt; 4 Fatima  35</span></span>
<span><span class='c'>#&gt; 5 Robert  51</span></span>
<span><span class='c'>#&gt; 6  Kwame  50</span></span>
<span></span></code></pre>

</div>

This family of functions is experimental because I'm still refining the user interface, particularly around error handling I'd love to hear your feedback!

## Parameters

Previously, setting model parameters like `temperature` and `seed` required knowing the details of each provider's API. The new [`params()`](https://ellmer.tidyverse.org/reference/params.html) function provides a consistent interface across providers:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>chat1</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://ellmer.tidyverse.org/reference/chat_openai.html'>chat_openai</a></span><span class='o'>(</span>params <span class='o'>=</span> <span class='nf'><a href='https://ellmer.tidyverse.org/reference/params.html'>params</a></span><span class='o'>(</span>temperature <span class='o'>=</span> <span class='m'>0.7</span>, seed <span class='o'>=</span> <span class='m'>42</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; Using <span style='color: #00BB00;'>model</span> = <span style='color: #0000BB;'>"gpt-4.1"</span>.</span></span>
<span></span><span><span class='nv'>chat2</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://ellmer.tidyverse.org/reference/chat_anthropic.html'>chat_anthropic</a></span><span class='o'>(</span>params <span class='o'>=</span> <span class='nf'><a href='https://ellmer.tidyverse.org/reference/params.html'>params</a></span><span class='o'>(</span>temperature <span class='o'>=</span> <span class='m'>0.7</span>, max_tokens <span class='o'>=</span> <span class='m'>100</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; Using <span style='color: #00BB00;'>model</span> = <span style='color: #0000BB;'>"claude-3-7-sonnet-latest"</span>.</span></span>
<span></span></code></pre>

</div>

ellmer automatically maps these to the appropriate provider-specific parameter names. If a provider doesn't support a particular parameter, it will generate a warning, not an error. This allows you to write provider-agnostic code without worrying about compatibility.

[`params()`](https://ellmer.tidyverse.org/reference/params.html) are currently supported by [`chat_anthropic()`](https://ellmer.tidyverse.org/reference/chat_anthropic.html), [`chat_azure()`](https://ellmer.tidyverse.org/reference/deprecated.html), [`chat_openai()`](https://ellmer.tidyverse.org/reference/chat_openai.html), and [`chat_gemini()`](https://ellmer.tidyverse.org/reference/deprecated.html); feel [file an issue](https://github.com/tidyverse/ellmer/issues/new) if you'd like us to add support for another provider.

## Cost estimates

Understanding the cost of your LLM usage is crucial, especially when working at scale. ellmer now tracks and displays cost estimates. For example, when you print a `Chat` object, you'll see estimated costs alongside token usage:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>chat</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://ellmer.tidyverse.org/reference/chat_openai.html'>chat_openai</a></span><span class='o'>(</span>echo <span class='o'>=</span> <span class='kc'>FALSE</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; Using <span style='color: #00BB00;'>model</span> = <span style='color: #0000BB;'>"gpt-4.1"</span>.</span></span>
<span></span><span><span class='nv'>joke</span> <span class='o'>&lt;-</span> <span class='nv'>chat</span><span class='o'>$</span><span class='nf'>chat</span><span class='o'>(</span><span class='s'>"Tell me a joke"</span><span class='o'>)</span></span>
<span><span class='nv'>chat</span></span>
<span><span class='c'>#&gt; &lt;Chat OpenAI/gpt-4.1 turns=2 tokens=11/17 $0.00&gt;</span></span>
<span><span class='c'>#&gt; ── <span style='color: #0000BB;'>user</span> [11] ────────────────────────────────────────────────────────────────────────</span></span>
<span><span class='c'>#&gt; Tell me a joke</span></span>
<span><span class='c'>#&gt; ── <span style='color: #00BB00;'>assistant</span> [17] ───────────────────────────────────────────────────────────────────</span></span>
<span><span class='c'>#&gt; Why don’t skeletons fight each other?  </span></span>
<span><span class='c'>#&gt; They don’t have the guts.</span></span>
<span></span></code></pre>

</div>

You can also access costs programmatically with `Chat$get_cost()` and see detailed breakdowns with `tokens_usage()`:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>chat</span><span class='o'>$</span><span class='nf'>get_cost</span><span class='o'>(</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; [1] $0.00</span></span>
<span></span><span></span>
<span><span class='nf'><a href='https://ellmer.tidyverse.org/reference/token_usage.html'>token_usage</a></span><span class='o'>(</span><span class='o'>)</span></span>
<span><span class='c'>#&gt;   provider   model input output price</span></span>
<span><span class='c'>#&gt; 1   OpenAI gpt-4.1  1788   8949 $0.08</span></span>
<span></span></code></pre>

</div>

(The numbers will be more interesting for real use cases.)

Keep in mind that these are estimates based on published pricing. LLM providers make it surprisingly difficult to determine exact costs, so treat these as helpful approximations rather than precise accounting.

## Developer tools

This release includes several improvements for developers building more sophisticated LLM applications, particularly around tool usage and debugging.

The most immediately useful addition is `echo = "output"` in `Chat$chat()`. When you're working with tools, this shows you exactly what's happening as tool requests and results flow back and forth. For example, if

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>chat</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://ellmer.tidyverse.org/reference/chat_anthropic.html'>chat_anthropic</a></span><span class='o'>(</span>echo <span class='o'>=</span> <span class='s'>"output"</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; Using <span style='color: #00BB00;'>model</span> = <span style='color: #0000BB;'>"claude-3-7-sonnet-latest"</span>.</span></span>
<span></span><span><span class='nv'>chat</span><span class='o'>$</span><span class='nf'>set_tools</span><span class='o'>(</span><span class='nf'>btw</span><span class='nf'>::</span><span class='nf'><a href='https://posit-dev.github.io/btw/reference/btw_tools.html'>btw_tools</a></span><span class='o'>(</span><span class='s'>"session"</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='nv'>chat</span><span class='o'>$</span><span class='nf'>chat</span><span class='o'>(</span><span class='s'>"Do I have bslib installed?"</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; I can check if the "bslib" package is installed in your R environment. Let me do </span></span>
<span><span class='c'>#&gt; that for you.</span></span>
<span></span><span><span class='c'>#&gt; <span style='color: #0000BB;'>◯</span> [<span style='color: #0000BB;'>tool call</span>] btw_tool_session_check_package_installed(package_name = "bslib",</span></span>
<span><span class='c'>#&gt; intent = "Checking if bslib package is installed")</span></span>
<span><span class='c'>#&gt; <span style='color: #00BB00;'>●</span> #&gt; <span style='font-style: italic;'>Package `bslib` version 0.9.0 is installed.</span></span></span>
<span></span><span><span class='c'>#&gt; Yes, you have the bslib package installed in your R environment. Specifically, </span></span>
<span><span class='c'>#&gt; you're running version 0.9.0 of the package. The bslib package is useful for </span></span>
<span><span class='c'>#&gt; creating custom Bootstrap themes for Shiny apps and R Markdown documents.</span></span>
<span></span></code></pre>

</div>

For more advanced use cases, we've added **tool annotations** via [`tool_annotations()`](https://ellmer.tidyverse.org/reference/tool_annotations.html). These follow the [Model Context Protocol](https://modelcontextprotocol.io/introduction) and let you provide richer descriptions of your tools:

``` r
weather_tool <- tool(
  fun = get_weather,
  description = "Get current weather for a location",
  .annotations = tool_annotations(
    audience = list("user", "assistant"),
    level = "beginner"
  )
)
```

We've also introduced [`tool_reject()`](https://ellmer.tidyverse.org/reference/tool_reject.html), which lets you reject tool requests with an explanation:

``` r
my_tool <- tool(function(dangerous_action) {
  if (dangerous_action == "delete_everything") {
    tool_reject("I can't perform destructive actions")
  }
  # ... normal tool logic
})
```

## Provider updates

The ellmer ecosystem continues to grow! We've added support for three new providers:

-   [Hugging Face](https://huggingface.co) via [`chat_huggingface()`](https://ellmer.tidyverse.org/reference/chat_huggingface.html), thanks to [Simon Spavound](https://github.com/s-spavound).
-   [Mistral AI](https://mistral.ai) via [`chat_mistral()`](https://ellmer.tidyverse.org/reference/chat_mistral.html).
-   [Portkey](https://portkey.ai) via [`chat_portkey()`](https://ellmer.tidyverse.org/reference/chat_portkey.html), thanks to [Maciej Banaś](https://github.com/maciekbanas).

We've also cleaned up the naming scheme for existing providers. The old function names still work but are deprecated:

-   [`chat_azure_openai()`](https://ellmer.tidyverse.org/reference/chat_azure_openai.html) replaces [`chat_azure()`](https://ellmer.tidyverse.org/reference/deprecated.html).
-   [`chat_aws_bedrock()`](https://ellmer.tidyverse.org/reference/chat_aws_bedrock.html) replaces [`chat_bedrock()`](https://ellmer.tidyverse.org/reference/deprecated.html).  
-   [`chat_google_gemini()`](https://ellmer.tidyverse.org/reference/chat_google_gemini.html) replaces [`chat_gemini()`](https://ellmer.tidyverse.org/reference/deprecated.html).

And updated some default models: [`chat_anthropic()`](https://ellmer.tidyverse.org/reference/chat_anthropic.html) now uses Claude Sonnet 4, and [`chat_openai()`](https://ellmer.tidyverse.org/reference/chat_openai.html) uses GPT-4.1.

Finally, we've added a family of `models_*()` functions that let you discover available models for each provider:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'>tibble</span><span class='nf'>::</span><span class='nf'><a href='https://tibble.tidyverse.org/reference/as_tibble.html'>as_tibble</a></span><span class='o'>(</span><span class='nf'><a href='https://ellmer.tidyverse.org/reference/chat_anthropic.html'>models_anthropic</a></span><span class='o'>(</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 11 × 6</span></span></span>
<span><span class='c'>#&gt;    <span style='font-weight: bold;'>id</span>                        <span style='font-weight: bold;'>name</span>  <span style='font-weight: bold;'>created_at</span>          <span style='font-weight: bold;'>cached_input</span> <span style='font-weight: bold;'>input</span> <span style='font-weight: bold;'>output</span></span></span>
<span><span class='c'>#&gt;    <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>                     <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dttm&gt;</span>                     <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span>  <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 1</span> claude-opus-4-20250514    Clau… 2025-05-22 <span style='color: #555555;'>00:00:00</span>        <span style='color: #BB0000;'>NA</span>    <span style='color: #BB0000;'>NA</span>     <span style='color: #BB0000;'>NA</span>   </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 2</span> claude-sonnet-4-20250514  Clau… 2025-05-22 <span style='color: #555555;'>00:00:00</span>        <span style='color: #BB0000;'>NA</span>    <span style='color: #BB0000;'>NA</span>     <span style='color: #BB0000;'>NA</span>   </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 3</span> claude-3-7-sonnet-202502… Clau… 2025-02-24 <span style='color: #555555;'>00:00:00</span>         0.3   3     15   </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 4</span> claude-3-5-sonnet-202410… Clau… 2024-10-22 <span style='color: #555555;'>00:00:00</span>         0.3   3     15   </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 5</span> claude-3-5-haiku-20241022 Clau… 2024-10-22 <span style='color: #555555;'>00:00:00</span>         0.08  0.8    4   </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 6</span> claude-3-5-sonnet-202406… Clau… 2024-06-20 <span style='color: #555555;'>00:00:00</span>         0.3   3     15   </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 7</span> claude-3-haiku-20240307   Clau… 2024-03-07 <span style='color: #555555;'>00:00:00</span>         0.03  0.25   1.25</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 8</span> claude-3-opus-20240229    Clau… 2024-02-29 <span style='color: #555555;'>00:00:00</span>         1.5  15     75   </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'> 9</span> claude-3-sonnet-20240229  Clau… 2024-02-29 <span style='color: #555555;'>00:00:00</span>        <span style='color: #BB0000;'>NA</span>    <span style='color: #BB0000;'>NA</span>     <span style='color: #BB0000;'>NA</span>   </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>10</span> claude-2.1                Clau… 2023-11-21 <span style='color: #555555;'>00:00:00</span>        <span style='color: #BB0000;'>NA</span>    <span style='color: #BB0000;'>NA</span>     <span style='color: #BB0000;'>NA</span>   </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>11</span> claude-2.0                Clau… 2023-07-11 <span style='color: #555555;'>00:00:00</span>        <span style='color: #BB0000;'>NA</span>    <span style='color: #BB0000;'>NA</span>     <span style='color: #BB0000;'>NA</span></span></span>
<span></span></code></pre>

</div>

These return data frames with model IDs, pricing information (where available), and other provider-specific metadata.

## Acknowledgements

