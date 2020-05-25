---
title: "👩‍💻🚙👯: My googledrive internship"
slug: lucy-internship
description: >
  Over the past several months I have been working with Jenny Bryan on the googledrive package. I wanted to share a bit about the process and some things I learned along the way. While brainstorming this post, I went back through my GitHub commits to remind myself of the journey - it turns out they do a rather good job of showing the scope of this!
date: 2017-09-08
author: "Lucy D'Agostino McGowan"
photo:
  url: https://twitter.com/_inundata
  author: Karthik Ram
categories: [learn]
tags:
  - googledrive
---


_Over the past several months I have been working with Jenny Bryan on the googledrive package. I wanted to share a bit about the process and some things I learned along the way. While brainstorming this post, I went back through my GitHub commits to remind myself of the journey - it turns out they do a rather good job of showing the scope of this!_

## _Day to day_ <br> <img src = "/images/lucy-internship/01_first.png" width = "400"> </img>

The googledrive 📦 looked measurably different on this [first day](https://github.com/tidyverse/googledrive/tree/ef8a410f8e74080670ff3145a330cdaa100472a8). I think this gives some really good insight into the iterative process of package design as well as how much I absorbed from Jenny along the way. In these early days, I was beavering away, building some small wrappers for Drive endpoints, spending most of my time getting to know the [Drive documentation](https://developers.google.com/drive/v3/web/about-sdk) and celebrating small victories.

<div style="text-align: center;">
<div style="display: inline-block; text-align: left">
<img src = "/images/lucy-internship/02_upload.png" width = "300"> </img><br>_Small victory 1: The ability to upload files to Drive_.

<img src = "/images/lucy-internship/03_delete.png" width = "300"> </img><br> _Small victory 2: The ability to delete files on Drive_.
</div>
</div>
</br>

My day to day back in April seems so foreign to the workflow Jenny and I have now established, but those first few weeks were incredibly useful for getting me steeped in all things Google Drive. Our process eventually converged to:

👩🏻‍💻👩🏼‍💻 Video chatting once a week to set priorities / discuss design decisions.  
✍️🙊 Documenting all problems as GitHub issues to resolve.  
👷‍♀️👀 Submitting all changes via PRs for review. 

The PR review process was quite new to me, but SO integral to the success of this package. Here is an [example](https://github.com/tidyverse/googledrive/pull/13) of what this can look like. Our first PR with review consisted of 49 commits and 66 comments 😱. The GitHub review process allowed Jenny to comment line by line on my code, gently pushing me towards better coding conventions and style. This process really helped me to absorb all things "tidyverse" in a systematic way.


## _Absorbing all things "tidyverse"_ <br> <img src = "/images/lucy-internship/03_markdown-docs.png" width = "400"></img>

<center>
<blockquote class="twitter-tweet" data-lang="en"><p lang="en" dir="ltr">🌞 musing: learning a new coding style is like putting on freshly washed jeans; a struggle, but once I get it I&#39;m like that looks GOOD 💃 <a href="https://t.co/5QcEwEcI23">pic.twitter.com/5QcEwEcI23</a></p>&mdash; Lucy 🌻 (@LucyStats) <a href="https://twitter.com/LucyStats/status/873587893754843136">June 10, 2017</a></blockquote> <script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>
</center>

The tidyverse has an [R Style Guide](http://style.tidyverse.org). My first pass at incorporating the style was switching my roxygen documentation to [markdown](https://github.com/klutometis/roxygen/blob/master/vignettes/markdown.Rmd) (this can be enabled by adding `Roxygen: list(markdown = TRUE)` to the `DESCRIPTION` file, or if you already have documentation and you'd like to convert it to markdown automagically ✨, check out the [roxygen2md](https://github.com/r-lib/roxygen2md) 📦). This is an example of something I didn't even know existed prior to this project. Other pieces I absorbed include: 

<div style="text-align: center;">
<div style="display: inline-block; text-align: left">
<img src = "/images/lucy-internship/04_travis.png" width = "300"> </img><br>  _Absorption example 1: Recommendations for continuous integration._

<img src = "/images/lucy-internship/05_test.png" width = "300"> </img><br> _Absorption example 2: Learning sensible ways to test._

<img src = "/images/lucy-internship/06_clean-up.png" width = "300"> </img><br>
_Absorption example 3: Cleaning up my code._
</div>
</div>
</br>

I made GREAT use of [lintr](https://github.com/jimhester/lintr) 🛀 until the coding conventions became second nature to me. Even still, I cannot overstate the immense utility of coding alongside Jenny. I found myself slowly adapting her excellent coding principles and style simply from seeing her suggestions and reviewing her commits. She gently nudged me towards much prettier & more useful code!


## _Flexing my programming muscles_ <br> <img src = "/images/lucy-internship/08_s3-methods.png" width = "400"></img>

Finally, this experience allowed me to dive into 🏊 things I otherwise may not have been exposed to. Some things that were new to me include:

🙃 Writing S3 methods.  
🙆🏻 Writing tests for an API-calling package.  
💅 Working with / writing in an established coding style.

I am so grateful for the opportunity to learn these concepts in such a welcoming environment, and am certainly committed to passing any knowledge I have gained from this experience to anyone and everyone!

## _An ode to Jenny Bryan_

I'd like to wrap up by expressing my immense gratitude to Jenny 👯. This experience was SO excellent due to her rockstar coding abilities, impeccable teaching skills, and of course her unwavering patience. And so I'd like to end with a haiku:


Thank you, tidyverse.  
You've given me a leg up!  
Checkout googledrive!
