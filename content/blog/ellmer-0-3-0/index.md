---
output: hugodown::hugo_document

slug: ellmer-0-3-0
title: ellmer 0.3.0
date: 2025-07-24
author: Hadley Wickham
description: >
    The newest version of ellmer introduces a simpler `chat()` interface that 
    can use work with any provider, a bunch of improvements to tool calling,
    and a handful of smaller quality of life improvements.

photo:
  url: https://chatgpt.com/share/68824585-91dc-8009-a84b-82451f71ef65
  author: ChatGPT

# one of: "deep-dive", "learn", "package", "programming", "roundup", or "other"
categories: [package] 
tags: [ellmer, ai]
rmd_hash: f6899bc41b34a0b7

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

We're thrilled to announce that [ellmer 0.3.0](https://ellmer.tidyverse.org) is now available on CRAN! ellmer is an R package designed to make it easy to use large language models (LLMs) from R. It supports a wide variety of providers (including OpenAI, Anthropic, Azure, Google, Snowflake, Databricks and many more), makes it easy to [extract structured data](https://ellmer.tidyverse.org/articles/structured-data.html), and to give the LLM the ability to call R functions via [tool calling](https://ellmer.tidyverse.org/articles/tool-calling.html).

You can install the latest version from CRAN with:

``` r
install.packages("ellmer")
```

This release brings several exciting improvements: a simplified chat interface, enhanced tool specifications, and numerous quality of life improvements that make working with LLMs more reliable and efficient. Let's dive into what's new!

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://ellmer.tidyverse.org'>ellmer</a></span><span class='o'>)</span></span></code></pre>

</div>

## Simplified chat interface

The biggest new feature in this release is the [`chat()`](https://ellmer.tidyverse.org/reference/chat-any.html) function, which provides an easy way to start a conversations with any provider. Instead of using different function names for different providers, you can now use a single string:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='c'># You can specify a particular model</span></span>
<span><span class='nv'>openai_chat</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://ellmer.tidyverse.org/reference/chat-any.html'>chat</a></span><span class='o'>(</span><span class='s'>"openai/gpt-4.1"</span><span class='o'>)</span></span>
<span><span class='nv'>openai_chat</span><span class='o'>$</span><span class='nf'>chat</span><span class='o'>(</span><span class='s'>"Tell me a joke about an R programmer"</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; Why did the R programmer go broke?</span></span>
<span><span class='c'>#&gt; </span></span>
<span><span class='c'>#&gt; Because he lost all his objects in the garbage collection!</span></span>
<span></span><span></span>
<span><span class='c'># Or use the default for a given provider</span></span>
<span><span class='nv'>anthropic_chat</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://ellmer.tidyverse.org/reference/chat-any.html'>chat</a></span><span class='o'>(</span><span class='s'>"anthropic"</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; Using <span style='color: #00BB00;'>model</span> = <span style='color: #0000BB;'>"claude-sonnet-4-20250514"</span>.</span></span>
<span></span><span><span class='nv'>anthropic_chat</span><span class='o'>$</span><span class='nf'>chat</span><span class='o'>(</span><span class='s'>"Write an acrostic for tidyr"</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; Here's an acrostic for tidyr:</span></span>
<span><span class='c'>#&gt; </span></span>
<span><span class='c'>#&gt; **T**ransform messy data into structured form  </span></span>
<span><span class='c'>#&gt; **I**ntegrating scattered values with ease  </span></span>
<span><span class='c'>#&gt; **D**ata reshaping becomes the norm  </span></span>
<span><span class='c'>#&gt; **Y**ielding clean datasets that please  </span></span>
<span><span class='c'>#&gt; **R**eorganizing rows and columns to perform</span></span>
<span></span></code></pre>

</div>

## Improved tool specification

We've significantly simplified how you define tools for function calling. The [`tool()`](https://ellmer.tidyverse.org/reference/tool.html) function now has a cleaner, more intuitive specification that focuses on the essentials: the function, a name, a description, and the arguments specifications.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>get_weather</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://ellmer.tidyverse.org/reference/tool.html'>tool</a></span><span class='o'>(</span></span>
<span>  <span class='kr'>function</span><span class='o'>(</span><span class='nv'>location</span>, <span class='nv'>unit</span> <span class='o'>=</span> <span class='s'>"celsius"</span><span class='o'>)</span> <span class='o'>&#123;</span></span>
<span>    <span class='c'># Function implementation here</span></span>
<span>    <span class='nf'><a href='https://rdrr.io/r/base/paste.html'>paste0</a></span><span class='o'>(</span><span class='s'>"Weather in "</span>, <span class='nv'>location</span>, <span class='s'>" is 22 "</span>, <span class='nv'>unit</span><span class='o'>)</span></span>
<span>  <span class='o'>&#125;</span>,</span>
<span>  name <span class='o'>=</span> <span class='s'>"get_weather"</span>,</span>
<span>  description <span class='o'>=</span> <span class='s'>"Get current weather for a location"</span>,</span>
<span>  arguments <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span></span>
<span>    location <span class='o'>=</span> <span class='nf'><a href='https://ellmer.tidyverse.org/reference/type_boolean.html'>type_string</a></span><span class='o'>(</span><span class='s'>"The city and state, e.g. San Francisco, CA"</span><span class='o'>)</span>,</span>
<span>    unit <span class='o'>=</span> <span class='nf'><a href='https://ellmer.tidyverse.org/reference/type_boolean.html'>type_enum</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"C"</span>, <span class='s'>"F"</span><span class='o'>)</span>, <span class='s'>"Temperature unit: celsius/fahrenheit"</span><span class='o'>)</span></span>
<span>  <span class='o'>)</span></span>
<span><span class='o'>)</span></span>
<span></span>
<span><span class='c'># Use the tool in a chat</span></span>
<span><span class='nv'>chat</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://ellmer.tidyverse.org/reference/chat-any.html'>chat</a></span><span class='o'>(</span><span class='s'>"anthropic"</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; Using <span style='color: #00BB00;'>model</span> = <span style='color: #0000BB;'>"claude-sonnet-4-20250514"</span>.</span></span>
<span></span><span><span class='nv'>chat</span><span class='o'>$</span><span class='nf'>register_tool</span><span class='o'>(</span><span class='nv'>get_weather</span><span class='o'>)</span></span>
<span><span class='nv'>chat</span><span class='o'>$</span><span class='nf'>chat</span><span class='o'>(</span><span class='s'>"What's the weather in Paris?"</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; The current weather in Paris, France is 22°C (approximately 72°F). It's</span></span>
<span><span class='c'>#&gt; a pleasant temperature!</span></span>
<span></span></code></pre>

</div>

This is a breaking change from previous versions, and I apologise for the pain that this will cause. However, I'm confident that this is a better interface overall and will make tool usage clearer and more maintainable in the long run. If you have existing tools you need to convert to the new format, check out [`?tool`](https://ellmer.tidyverse.org/reference/tool.html) for an LLM prompt to help you automate the work.

We've also tweaked the type specification functions: [`type_array()`](https://ellmer.tidyverse.org/reference/type_boolean.html) and [`type_enum()`](https://ellmer.tidyverse.org/reference/type_boolean.html). These now have a more logical argument order, with the `values`/`items` first and the description second:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>type_colour</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://ellmer.tidyverse.org/reference/type_boolean.html'>type_enum</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"red"</span>, <span class='s'>"green"</span>, <span class='s'>"blue"</span><span class='o'>)</span>, <span class='s'>"Colour options"</span><span class='o'>)</span></span>
<span><span class='nv'>type_names</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://ellmer.tidyverse.org/reference/type_boolean.html'>type_array</a></span><span class='o'>(</span><span class='nf'><a href='https://ellmer.tidyverse.org/reference/type_boolean.html'>type_string</a></span><span class='o'>(</span><span class='o'>)</span><span class='o'>)</span></span></code></pre>

</div>

This makes them a little easier to use since `values` and `items` are required and the `description` is optional.

## Quality of life improvements

This release includes several improvements that make ellmer more reliable and easier to use at scale:

-   **Enhanced reliability**. ellmer now retries requests up to 3 times by default (controllable with `options(ellmer_max_tries)`), and will retry if the connection fails, not just if the request returns a transient error. The default timeout (`options(ellmer_timeout)`) now applies to the initial connection phase. Together these changes should make ellmer much more reliable in turbulent network conditions.

-   **Batch processing**. New [`parallel_chat_text()`](https://ellmer.tidyverse.org/reference/parallel_chat.html) and [`batch_chat_text()`](https://ellmer.tidyverse.org/reference/batch_chat.html) functions make it easy to just extract the text responses from parallel/batch responses.

-   **Better cost tracking**. ellmer's cost estimates are now more accurate and comprehensive. [`chat_openai()`](https://ellmer.tidyverse.org/reference/chat_openai.html) and [`chat_google_gemini()`](https://ellmer.tidyverse.org/reference/chat_google_gemini.html) now distinguish between cached and uncached input tokens. And we've switched to LiteLLM as our pricing data source, dramatically expanding the number of providers and models with cost information.

## Acknowledgements

We're grateful to all the contributors who made this release possible through their code contributions, bug reports, and feedback. Your input helps make ellmer better for the entire R community working with large language models!

