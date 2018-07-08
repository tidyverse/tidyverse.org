---
title: Carpe Talk
author: Jenny Bryan and Mara Averick
date: '2018-07-06'
slug: carpe-talk
description: >
  Seize the day and show off your work!
categories:
  - other
photo:
  url: https://unsplash.com/photos/iIWCjgK3704
  author: Karine Germain
---

Summer conference season is in full swing, with [useR! 2018 Brisbane](https://user2018.r-project.org) nearly upon us!

Conference talks are a great opportunity to help people learn about the cool and useful things you have built. Given all the hard work you've already put in, a bit of marketing effort can be a wise investment in drumming up users.

Making your talk tweet-able is like [universal design](http://universaldesign.ie/What-is-Universal-Design/): it makes your accomplishment more accessible for everyone, whether or not they use Twitter. It's another version of the [Elevator Pitch](https://en.wikipedia.org/wiki/Elevator_pitch) or [Three Minute Thesis](https://en.wikipedia.org/wiki/Three_Minute_Thesis), but with more hyperlinks!

## What this post is and is not about

We provide very concrete tips. Even if you can only dedicate 30 minutes or a couple of hours to this, you should find a few things here that feel worth implementing. No one does all of this, nor do they need to. At the very end we link to an annotated, crowd-sourced list of great examples of talk-based marketing.

We assume that your product already exists and is ready to be shared with others. We assume that it is already documented. For example, if it's a package, we assume you already have a good README, vignettes, or articles. There should be a way for someone to learn about your product and *then* install it. Realistically, this order of operations is much more likely than "install on blind faith, then figure out what it does".

This post is not about how to build a high-quality package, how to write documentation, or how to give a great talk. We include a few links to such resources below.

## Marketing is not a Four Letter Word

First, let's deal with the word and concept of "marketing".

> Marketing is the study and management of exchange relationships.
>
> -- <cite>https://en.wikipedia.org/wiki/Marketing</cite>

If you have taken the trouble to build an R package, Shiny app, tutorial, or talk, presumably you would like people to know about it and use it! Marketing is the set of activities that help your target audience:

  * discover that your thing exists,
  * learn how your thing could benefit them.

Some creators take a peculiar pride in being "bad at marketing," but it is not some elusive skill. Nor is marketing effort a sign that your work isn't good enough to sell itself. It's hard to digest all the exciting developments in the R world! It's a kindness to the community if you make it easy to find and appreciate your work.

You can acknowledge the value in marketing or you can declare that cultivating broader usage is not a goal. Pick one.

## Designate a primary online home

Pick one primary landing page for your product. Possibilities include:

  * A dedicated website, possibly made with [pkgdown](http://pkgdown.r-lib.org), [blogdown](https://bookdown.org/yihui/blogdown/), [bookdown](https://bookdown.org/yihui/bookdown/), or, in the case of [Shiny](https://shiny.rstudio.com), a [running app](https://www.shinyapps.io)
  * A development venue, such as a [GitHub repository](https://github.com)
  * A [CRAN](https://cran.r-project.org/web/packages/index.html) package landing page

Visit this with the eyes of a newcomer. Do you show basic usage? Do you define key terms and acronyms? If your product is related to vis, are there any actual visualizations? Refine accordingly.

If your thing has multiple online homes, make sure they are interlinked. There should be a strong push towards the primary home, which then links out to the other locations.

As you give talks or workshops related to you product, be sure to incorporate links to the slides or videos back into the primary online home or docs.

## A URL is a user interface

Take a hard look at your product's URL. Is it short, memorable, and informative? If not, work on that. Options include:

  * Give it a nice URL within your own website. Examples: <https://earo.me/talk/>.
  * Purchase a domain. Example: [happygitwithr.com](http://happygitwithr.com).
  * Make a shortlink using a service use as <http://bit.ly>.

Ideally your URL is easy to hold in human memory long enough to type it, with fat fingers, on a phone. In some settings, you might even include this URL in the slide footer, so it's visible at all times.

## Personal online home and shortlink

If you've been considering a Twitter account, go ahead and get one. Why? A Twitter handle can serve as a great shortlink for you as a person. You can include a link to your primary online presence in your Twitter profile. If people tweet about your talk and product, they will want to `@` mention you. And that, in turn, let's you see the reaction and join in any downstream conversations.

## Title slide

Make a slide with the most important coordinates for you and your thing. Include this as the first or second slide. This slide should include one or more of:

  * Your product's name and primary URL or shortlink.
  * Your name and primary URL(s), handles, or usernames.

DO THIS IN AN ABSOLUTELY HUGE FONT. Now is not the time for subtlety or mumbling "I know this is hard to read, but ...". Incorporate an evocative image or logo as appropriate.

Leave this slide up for a bigly amount of time, so people have ample opportunity to get out their phones and fire up the camera. Do not flash this vital slide for 3 seconds, only to spend 2 minutes displaying a bulleted outline of your talk. Consider omitting your outline slide and, instead, verbally convey this overview while displaying your title slide.

## Closing slide

Make a conclusion slide to display as you wrap up and take questions. It should repeat key URLs and handles from the title slide. Consider doing that in a smaller font, so you have room to recap a few key points. This delivers more value than a generic "THANK YOU" slide that lacks identifying content.

## Feature slides

Accept that people photograph and share individual slides, e.g., via Twitter. This can be a good thing, especially if you harness it for your ends! If an audience member is moved to share your thing, it is natural they want to enhance the basic message with an evocative slide or image. Think about how well your slides work with this predictable behaviour.

If something would be terrible taken out of context or circulated widely, reflect on that and take appropriate measures.

If you have a pithy and hilarious point, give that slide some extra attention.

Here are some resources for live-tweeting. If you'd like people to tweet about your talk, make it easy for them. This is just like grant-writing: notice the words the funder uses to describe what they want to fund and describe your work in those terms.

  * "Live Tweeting: Qualitative and Quantitative Advice", a [4 minute video](https://youtu.be/pxwGIZlPKT0) by [David Robinson](http://varianceexplained.org/about/) from the [NYR Conference](https://www.rstats.nyc)
  * [Twitter thread](https://twitter.com/alice_data/status/899613048771575816?s=19) by [Alice Daish](https://twitter.com/alice_data)
  * [Rachael Tatman’s Guide to Conference Livetweeting](http://www.rctatman.com/Livetweeting-Guide/)

## Post materials *before* the talk

Choose your primary online home and humane URL *before your talk*. It is very tempting, but sub-optimal, to promise the slides or materials "after the talk". People are taking notes and photos right now, during your talk, and this is your best chance to tell them how to find your awesome thing when they get home.

Even if you add more materials or update your slides after the talk, it is still worth it to publicize the URL during the talk. Tweets come up in searches months and years later and wrap-up blog posts will come out over the next couple of weeks. Most of the genuine visits to your thing will happen later, but your talk represents the best opportunity to put the URL in front of people's eyeballs.

## Make your slides easy to consume

When sharing slides, the main point is to minimize friction for the consumer. Making slides in Rmd is great; making readers clone your repo, install any necessary packages, and knit the document in order to see your slides is not.
 The way *you* store, interact with, and present your slides is not necessarily a great distribution platform, although it is certainly better than nothing.

Slide-specific platforms, such as [SpeakerDeck](https://speakerdeck.com), are very good for quick browsing, linking to specific slides, and embedding in blogs or websites. One downside is that hyperlinks in slides viewed this way are not immediately clickable.

PDF files can be shared in a GitHub repo, but this doesn't offer a very pleasant browsing experience, especially if the file is large. Raw R Markdown or HTML on GitHub are even more frustrating because they are not immediately consumable by the user. Video is also not a great primary source, as the perceived time commitment can be off-putting and it is often awkward to consume in the workplace.

## Credit where credit is due

When in doubt, over-credit and over-thank others whose work has enhanced yours, directly or indirectly. This is much better than under-crediting.

Don't use other people's work without permission. Comply with licenses and always give attribution. Link back to the source and original creator whenever possible.

A tricky mechanical question is where to provide information, such as photo credit. Some people include it directly on every slide, but that can create visual clutter. Others collect in a designated place, such as an acknowledgement section or document. Find a method that you feel is fair and aesthetically acceptable.

## Wild-caught and crowd-sourced examples

We solicited submissions from the community of talks that exemplified various aspects of good marketing. The response was fantastic and, indeed, proved to be too much to summarize here. So instead we encourage you to mine [this issue thread](https://github.com/tidyverse/tidyverse.org/issues/182) for inspiration. There are specific examples, complete with hyperlinks, of lots of different mechanics.

## Thanks and additional resources

Special thanks to Maëlle Salmon. In addition to weighing in on the [GitHub thread](https://github.com/tidyverse/tidyverse.org/issues/182), she provided several general suggestions that are incorporated above.

Recommended resources on talk preparation and the value of marketing and networking in data science:

  * [The Art of Slide Design](https://speakerdeck.com/mseckington/the-art-of-slide-design) by Melinda Seckington
  * [Presenting Effectively](https://kieranhealy.org/blog/archives/2018/03/24/making-slides/) by Kieran Healy
 * [7 Tips for Presenting Bulleted Lists in Digital Content](https://www.nngroup.com/articles/presenting-bulleted-lists/) by Hoa Loranger
 * [How To Give a Talk](http://www.howtogiveatalk.com) by David L. Stern
 * [Building Your Data Science Network: Finding Community](http://hookedondata.org/Building-Your-Data-Science-Network-Finding-Community/) by Emily Robinson
 * [Marketing for Data Science: A 7 Step ‘Go-to-Market’ Plan for Your Next Data Product](https://medium.com/indeed-data-science/marketing-for-data-science-a-7-step-go-to-market-plan-for-your-next-data-product-60c034c34d55) by Erik Oberg
