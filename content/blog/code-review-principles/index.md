---
output: hugodown::hugo_document

slug: code-review-principles
title: Tidyteam code review principles
date: 2023-06-02
author: Davis Vaughan
description: >
    We've written a collection of tidyteam code review principles that
    act as a resource for new contributors and as a source of truth when
    there are questions about our code review process. We hope you find
    them useful!

photo:
  url: https://unsplash.com/photos/BvAoCypqRXU
  author: Lanju Fotografie

# one of: "deep-dive", "learn", "package", "programming", "roundup", or "other"
categories: ["other"] 
tags: []
rmd_hash: 2ae6c7e086178bdc

---

At Posit, we strive to write high quality code to ensure that you, our users, have the best experience possible. We feel that the code review process plays a critical role in delivering quality products, and in developing the skills of newer contributors, and we decided to make that process explicit through a [tidyteam code review principles](https://code-review.tidyverse.org/) guide.

At a high level, this guide walks you through the perspectives of both the pull request author and the pull request reviewer, discussing various aspects of the process from both points of view (such as how to [handle reviewer comments](https://code-review.tidyverse.org/author/handling-comments.html) and how to write [focused pull requests](https://code-review.tidyverse.org/author/focused.html)). Throughout the guide, we repeatedly tie back to three different [patterns of collaboration](https://code-review.tidyverse.org/collaboration/), which reflect that each code review is unique and comes with its own set of expectations between the author and the reviewer.

We posted about this guide on [Twitter](https://twitter.com/dvaughan32/status/1645866331487756288?s=20) and [Mastodon](https://fosstodon.org/@davis/110181751636631782) a few weeks ago:

<blockquote class="twitter-tweet"><p lang="en" dir="ltr">In the tidyverse, we work with a lot of people - each other and <a href="https://twitter.com/hashtag/rstats?src=hash&amp;ref_src=twsrc%5Etfw">#rstats</a> community members.<br><br>We wanted to document how we handle code review, so we&#39;ve drafted a guide detailing our review principles!<br><br>We hope you find it useful, and welcome your feedback!<a href="https://t.co/jGm0rSGg5M">https://t.co/jGm0rSGg5M</a></p>&mdash; Davis Vaughan (@dvaughan32) <a href="https://twitter.com/dvaughan32/status/1645866331487756288?ref_src=twsrc%5Etfw">April 11, 2023</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

And we were happy to see that [many of you](https://fosstodon.org/@jromanowska/110182021271601892) are already finding it useful!

<iframe src="https://fosstodon.org/@jromanowska/110182021271601892/embed" class="mastodon-embed" style="max-width: 100%; border: 0" width="400" allowfullscreen="allowfullscreen"></iframe><script src="https://fosstodon.org/embed.js" async="async"></script>

In particular, I'd like to shout out [Hiroaki Yutani](https://github.com/yutannihilation) who created a [two part video series](https://www.youtube.com/watch?v=gSv6h2heHQE) reading through the principles in Japanese!

Internally, we've also been referencing this guide when reviewing pull requests from each other and from the community. For example, Jenny Bryan linked out to the section on [creating a good pull request description](https://code-review.tidyverse.org/author/submitting.html#sec-descriptions) when reviewing a [bigrquery PR](https://github.com/r-dbi/bigrquery/pull/512#issuecomment-1511687647), and I internally linked a colleague to the section on [GitHub Suggestions](https://code-review.tidyverse.org/reviewer/comments.html#github-suggestions), which discusses how to batch multiple suggestions into a single commit.

We adapted these principles from Google's own [guide](https://google.github.io/eng-practices/review/), and we encourage you to do the same thing with ours. If you work in a research lab or are on a software team at your company, then code review should be as important to you as it is to us! Feel free to modify these principles to suit your own needs, and if you do use them, we'd love to hear about it.

