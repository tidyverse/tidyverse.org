---
output: hugodown::hugo_document

slug: mcptools-0-1-0
title: R and the Model Context Protocol
date: 2025-07-14
author: Simon Couch
description: >
    The newly released mcptools package makes coding assistants better at
    writing R code and applications built with ellmer more powerful.

photo:
  url: https://unsplash.com/photos/PacWLzKKTso
  author: Chad Peltola

categories: [package] 
tags: [ellmer, ai]
rmd_hash: 247a698b951e6996

---

We're hootin' to holler about the initial release of mcptools, a package implementing the Model Context Protocol (MCP) in R. MCP standardizes how applications provide context to LLMs. In the context of R:

-   R can be treated as the MCP **Server**, meaning that applications like Claude Code, VS Code Copilot Chat, and Cursor can run R code to better answer user queries.
-   R can also serve as the MCP **Client**, where users converse with LLMs via [ellmer](https://ellmer.tidyverse.org/) and additional tools are provided to access context from third-party MCP servers like Slack servers, GitHub PRs/issues, Google Drive documents, and Confluence sites.

You can install it from CRAN with:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://rdrr.io/r/utils/install.packages.html'>install.packages</a></span><span class='o'>(</span><span class='s'>"mcptools"</span><span class='o'>)</span></span></code></pre>

</div>

This blog post will highlight some use cases for R as an MCP server and client. See the [package website](https://posit-dev.github.io/mcptools/) for a more thorough overview of what's possible with mcptools!

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://github.com/posit-dev/mcptools'>mcptools</a></span><span class='o'>)</span></span></code></pre>

</div>

## R as a server

Treating R as an MCP server makes coding assistants better at writing R code. Applications like Claude Desktop, Claude Code, Copilot Chat in VS Code, and Positron Assistant can be configured with arbitrary R functions that allow them to e.g. peruse R package documentation, run R code, and look at objects in your interactive R sessions in order to write better code:

<div class="highlight">

<img src="r_as_a_server.png" alt="A system architecture diagram showing three main components: Client (left), Server (center), and Session (right). The Client box lists AI coding assistants including Claude Desktop, Claude Code, Copilot Chat in VS Code, and Positron Assistant. The Server is initiated with [`mcp_server()`](https://posit-dev.github.io/mcptools/reference/server.html) and contains tools for R functions like reading package documentation, running R code, and inspecting global environment objects. Sessions can be configured with [`mcp_session()`](https://posit-dev.github.io/mcptools/reference/server.html) and can optionally connect to interactive R sessions, with two example projects shown: 'Some R Project' and 'Other R Project'." width="700px" style="display: block; margin: auto;" />

</div>

Hooking Claude Code (or other coding assistants) up to tools that can peruse R package documentation allows me to say things like "read the docs for all of the functions I use in \[some file\] and then ...". The [btw package](https://posit-dev.github.io/btw/reference/mcp.html) provides helpers to start MCP servers with tools to peruse R package documentation. To use those tools with Claude Code, for example, install btw and then write `claude mcp add -s "user" r-btw -- Rscript -e "btw::btw_mcp_server()"` in your terminal.

To use [R as an MCP server](https://posit-dev.github.io/mcptools/articles/server.html), configure the command `Rscript -e "mcptools::mcp_server()"` with your LLM application. You'll likely want to provide a `tools` argument, perhaps `tools = btw::btw_tools()`, to configure additional R functions as tools in the server.

## R as a client

Treating R as an MCP client means that your [shinychat](https://posit-dev.github.io/shinychat/) and [querychat](https://posit-dev.github.io/querychat/) applications will have easy access to your organization's data, regardless of whether that lives in a Slack server, Google Drive, Confluence site, GitHub organization, or elsewhere.

<div class="highlight">

<img src="r_as_a_client.png" alt="An architecture diagram showing the Client (left) with R code using the ellmer library to create a chat object and then setting tools from mcp with [`mcp_tools()`](https://posit-dev.github.io/mcptools/reference/client.html), and the Server (right) containing third-party tools including GitHub (for reading PRs/Issues), Confluence (for searching), and Google Drive (for searching). Bidirectional arrows indicate communication between the client and server components." width="700px" style="display: block; margin: auto;" />

</div>

For example, if I'd like a chat app built with Shiny to be able to search a Slack server's history, I could configure the [Slack MCP server](https://github.com/modelcontextprotocol/servers-archived/tree/main/src/slack#usage-with-claude-desktop) and then register tools from [`mcp_tools()`](https://posit-dev.github.io/mcptools/reference/client.html) with the ellmer chat underlying the app.

To use [R as an MCP client](https://posit-dev.github.io/mcptools/reference/client.html), paste the Claude Desktop configuration `.json` for your desired MCP server (often found on MCP server READMEs) into the mcptools configuration file, and then call [`mcp_tools()`](https://posit-dev.github.io/mcptools/reference/client.html) for a list of ellmer tool definitions that can be registered with an ellmer chat using the [`set_tools()` method](https://ellmer.tidyverse.org/reference/Chat.html?q=set_tools#method-set-tools-).

## Acknowledgements

This package was written with Winston Chang and Charlie Gao, both of whose contributions were indespensable in bringing the package from a clunky, hard-to-install demo to what it is now.

Many thanks to [@grantmcdermott](https://github.com/grantmcdermott), [@HjorthenA](https://github.com/HjorthenA), [@MarekProkop](https://github.com/MarekProkop), and [@sounkou-bioinfo](https://github.com/sounkou-bioinfo) for adopting early and reporting issues!

