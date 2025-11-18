---
output: hugodown::hugo_document

slug: ellmer-0-4-0
title: ellmer 0.4.0
date: 2025-11-18
author: Hadley Wickham
description: >
    ellmer 0.4.0 includes important lifecycle updates, new Claude features
    (caching, file uploads, web tools), OpenAI improvements, and enhancements
    to error handling, pricing tracking, and security.
photo:
  url: https://unsplash.com/photos/a-herd-of-elephants-standing-next-to-each-other-CzIwSXedUGM
  author: Evan Jones

# one of: "deep-dive", "learn", "package", "programming", "roundup", or "other"
categories: [package]
tags: [ellmer]
rmd_hash: 1c7835a3eedd7777

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

We're very happy to announce the release of [ellmer](https://ellmer.tidyverse.org) 0.4.0. ellmer makes it easy to chat with a large language model directly from R. It supports a wide variety of providers (including OpenAI, Anthropic, Azure, Google, Snowflake, Databricks and many more), makes it easy to [extract structured data](https://ellmer.tidyverse.org/articles/structured-data.html), and to give the LLM the ability to call R functions via [tool calling](https://ellmer.tidyverse.org/articles/tool-calling.html).

You can install it from CRAN with:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://rdrr.io/r/utils/install.packages.html'>install.packages</a></span><span class='o'>(</span><span class='s'>"ellmer"</span><span class='o'>)</span></span></code></pre>

</div>

This blog post will cover the major changes in this release, including important lifecycle updates, new features for Claude (caching, file uploads, and web tools), improvements to OpenAI support (responses API and built-in tools), and a variety of enhancements to error handling, pricing tracking, and security.

You can see a full list of changes in the [release notes](https://github.com/tidyverse/ellmer/releases/tag/v0.4.0).

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://ellmer.tidyverse.org'>ellmer</a></span><span class='o'>)</span></span></code></pre>

</div>

## Lifecycle

[`parallel_chat()`](https://ellmer.tidyverse.org/reference/parallel_chat.html) and [`batch_chat()`](https://ellmer.tidyverse.org/reference/batch_chat.html) are no longer experimental. Based on user feedback, both [`parallel_chat()`](https://ellmer.tidyverse.org/reference/parallel_chat.html) and [`batch_chat()`](https://ellmer.tidyverse.org/reference/batch_chat.html) do a much better job of handling errors, and I'm confident that they're around to stay.

Reflecting Anthropic's recent rebranding of developer tools under the Claude name, [`chat_claude()`](https://ellmer.tidyverse.org/reference/chat_anthropic.html) is no longer deprecated and is an alias for [`chat_anthropic()`](https://ellmer.tidyverse.org/reference/chat_anthropic.html). New [`models_claude()`](https://ellmer.tidyverse.org/reference/chat_anthropic.html) is now an alias for [`models_anthropic()`](https://ellmer.tidyverse.org/reference/chat_anthropic.html).

The following deprecated functions/arguments/methods have been removed:

-   `Chat$extract_data()` -\> `chat$chat_structured()` (0.2.0)
-   `Chat$extract_data_async()` -\> `chat$chat_structured_async()` (0.2.0)
-   `chat_anthropic(max_tokens)` -\> `chat_anthropic(params)` (0.2.0)
-   `chat_azure()` -\> [`chat_azure_openai()`](https://ellmer.tidyverse.org/reference/chat_azure_openai.html) (0.2.0)
-   `chat_azure_openai(token)` (0.1.1)
-   `chat_bedrock()` -\> [`chat_aws_bedrock()`](https://ellmer.tidyverse.org/reference/chat_aws_bedrock.html) (0.2.0)
-   [`chat_claude()`](https://ellmer.tidyverse.org/reference/chat_anthropic.html) -\> [`chat_anthropic()`](https://ellmer.tidyverse.org/reference/chat_anthropic.html) (0.2.0)
-   `chat_cortex()` -\> [`chat_snowflake()`](https://ellmer.tidyverse.org/reference/chat_snowflake.html) (0.2.0)
-   `chat_gemini()` -\> [`chat_google_gemini()`](https://ellmer.tidyverse.org/reference/chat_google_gemini.html) (0.2.0)
-   `chat_openai(seed)` -\> `chat_openai(params)` (0.2.0)
-   `create_tool_def(model)` -\> `create_tool_def(chat)` (0.2.0)

## `chat_claude()`

[`chat_claude()`](https://ellmer.tidyverse.org/reference/chat_anthropic.html) gains a new `cache` parameter to control caching. By default it is set to "5m". Claude's caching model is rather difficult to understand, but I'm reasonably confident that this will reduce your costs overall. [`?chat_claude`](https://ellmer.tidyverse.org/reference/chat_anthropic.html) goes into the details of why I think this will save you money.

With help from @dcomputing, ellmer has gained a suite of file management helpers such as [`claude_file_upload()`](https://ellmer.tidyverse.org/reference/claude_file_upload.html), [`claude_file_list()`](https://ellmer.tidyverse.org/reference/claude_file_upload.html), [`claude_file_delete()`](https://ellmer.tidyverse.org/reference/claude_file_upload.html), and so on. These allow you to upload [a variety of file types](https://docs.claude.com/en/docs/build-with-claude/files#file-types-and-content-blocks) for investigation.

You can now take advantage of Claude's built-in [web search](https://docs.claude.com/en/docs/agents-and-tools/tool-use/web-search-tool) and [web fetch](https://docs.claude.com/en/docs/agents-and-tools/tool-use/web-fetch-tool) with [`claude_tool_web_search()`](https://ellmer.tidyverse.org/reference/claude_tool_web_search.html) and [`claude_tool_web_fetch()`](https://ellmer.tidyverse.org/reference/claude_tool_web_fetch.html). These empower Claude to perform web searches and read web pages on your behalf.

## `chat_openai()` and `chat_openai_compatible()`

[`chat_openai()`](https://ellmer.tidyverse.org/reference/chat_openai.html) now uses OpenAI's more modern "responses API". This is their now-recommended API, and unlocks the ability to use the built-in tools, such as web search with [`openai_tool_web_search()`](https://ellmer.tidyverse.org/reference/openai_tool_web_search.html). It also gains a `service_tier` argument which allows you to request slower/cheaper or faster/more expensive results.

If you want to talk to a model provider that is OpenAI API compatible (i.e. uses the older "chat completions" API), you'll need to use [`chat_openai_compatible()`](https://ellmer.tidyverse.org/reference/chat_openai_compatible.html).

## New features

-   [`parallel_chat()`](https://ellmer.tidyverse.org/reference/parallel_chat.html) and [`batch_chat()`](https://ellmer.tidyverse.org/reference/batch_chat.html) are much better at dealing with errors, and should now (by and large) succeed even if not all prompts succeeded or return badly formatted output. This does make the output from [`parallel_chat()`](https://ellmer.tidyverse.org/reference/parallel_chat.html) a bit more complex, since it can now be a mix of `Chat` objects, error objects, and `NULL`, but we think the trade-off is worth it.

-   [`batch_chat()`](https://ellmer.tidyverse.org/reference/batch_chat.html) and friends have a revised hashing mechanism which is used to ensure that you don't accidentally use saved results with the wrong inputs. The mechanism now only hashes the provider `name`, `model`, and `base_url`. This should provide some protection from accidentally reusing the same `.json` file with different providers, while still allowing you to use the same batch file across ellmer versions. There's also a new `ignore_hash` argument that allows you to opt out of the check if you're confident the difference only arises because ellmer itself has changed.

-   There were a bunch of smaller improvements to pricing: the package now uses the latest pricing data, [`batch_chat()`](https://ellmer.tidyverse.org/reference/batch_chat.html) only records costs on retrieval, `Chat$get_tokens()` includes cost information, and the print method does a better job of matching underlying data.

-   [`params()`](https://ellmer.tidyverse.org/reference/params.html) gains new `reasoning_effort` and `reasoning_tokens` so you can control the amount of effort a reasoning model spends on thinking. Initial support is provided for [`chat_claude()`](https://ellmer.tidyverse.org/reference/chat_anthropic.html), [`chat_google_gemini()`](https://ellmer.tidyverse.org/reference/chat_google_gemini.html), and [`chat_openai()`](https://ellmer.tidyverse.org/reference/chat_openai.html).

-   `chat_*()` functions now use a `credentials` function instead of an `api_key` value. This means that API keys are never stored in the chat object (which might be saved to disk), but are instead retrieved on demand as needed. You generally shouldn't need to use the `credentials` argument directly yourself, but when you do, you should use it to dynamically retrieve the API key from some other source (i.e. never inline a secret directly into a function call).

-   [`tool()`](https://ellmer.tidyverse.org/reference/tool.html)s can now return image or PDF content types, with [`content_image_file()`](https://ellmer.tidyverse.org/reference/content_image_url.html) or `content_pdf()`.

-   You can use the new `schema_df()` to describe the schema of a data frame to an LLM. It's designed to give a high-quality summary without spending too many tokens.

## Acknowledgements

A big thanks to everyone who contributed to this release! [@abiyug](https://github.com/abiyug), [@AdaemmerP](https://github.com/AdaemmerP), [@AlmogAngel](https://github.com/AlmogAngel), [@app2let](https://github.com/app2let), [@benhmin](https://github.com/benhmin), [@bensoltoff](https://github.com/bensoltoff), [@benzipperer](https://github.com/benzipperer), [@bianchenhao](https://github.com/bianchenhao), [@bshor](https://github.com/bshor), [@CChen89](https://github.com/CChen89), [@cherylisabella](https://github.com/cherylisabella), [@cpsievert](https://github.com/cpsievert), [@dcomputing](https://github.com/dcomputing), [@durraniu](https://github.com/durraniu), [@fh-slangerman](https://github.com/fh-slangerman), [@flaviaerius](https://github.com/flaviaerius), [@foton263](https://github.com/foton263), [@gadenbuie](https://github.com/gadenbuie), [@gary-mu](https://github.com/gary-mu), [@Green-State-Data](https://github.com/Green-State-Data), [@hadley](https://github.com/hadley), [@howardbaik](https://github.com/howardbaik), [@jeroenjanssens](https://github.com/jeroenjanssens), [@jharvey-records](https://github.com/jharvey-records), [@joranE](https://github.com/joranE), [@kbenoit](https://github.com/kbenoit), [@LukasWallrich](https://github.com/LukasWallrich), [@m20m22](https://github.com/m20m22), [@maciekbanas](https://github.com/maciekbanas), [@mattwarkentin](https://github.com/mattwarkentin), [@parmsam](https://github.com/parmsam), [@parmsam-pfizer](https://github.com/parmsam-pfizer), [@promothesh](https://github.com/promothesh), [@rempsyc](https://github.com/rempsyc), [@roldanalex](https://github.com/roldanalex), [@rplsmn](https://github.com/rplsmn), [@schloerke](https://github.com/schloerke), [@simonpcouch](https://github.com/simonpcouch), [@t-kalinowski](https://github.com/t-kalinowski), [@wklimowicz](https://github.com/wklimowicz), [@wlandau](https://github.com/wlandau), and [@xx02al](https://github.com/xx02al).

