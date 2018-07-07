---
title: Talk Carpe Diem
author: Jenny Bryan and Mara Averick
date: '2018-07-06'
slug: talk-carpe-diem
description: >
  Seize the day and show off your work!
categories:
  - other
photo:
  url: https://unsplash.com/photos/iIWCjgK3704
  author: Karine Germain
---

Summer conference season is in full swing, with [useR! 2018 in Brisbane](https://user2018.r-project.org) coming up next week!

Conference talks are a great opportunity to help people learn about the cool and useful things you have built. A few concrete practices will make your marketing efforts more effective.

*We assume your product meets your quality standards and that you have already documented it. This is about stuff you can do in ~1 hour as you prepare you talk that will have high payoff in terms of recruiting users. This is also not about how to give a great talk.*

## Marketing is not a Four Letter Word

First, let's deal with the word and concept of "marketing".

> Marketing is the study and management of exchange relationships.

https://en.wikipedia.org/wiki/Marketing

If you have taken the trouble to build an R package, Shiny app, tutorial, or talk, presumably you would like people to know about it and use it! Marketing is the set of activities that help your target audience

  * discover that your thing exists
  * learn how your thing could benefit them

Use your talk (and documentation and README, etc.) to accomplish these goals!

Some creators take a peculiar pride in being "bad at marketing", but it is not some elusive skill. Nor is marketing ability anti-correlated with creating a high-quality product. You can acknowledge the value in marketing or you can declare that cultivating broader usage is not your goal. Pick one.

## Where does your thing live?

Determine the primary online home for your product. Possibilities:

  * A custom website, possibly made with [pkgdown](http://pkgdown.r-lib.org), [blogdown](https://bookdown.org/yihui/blogdown/), [bookdown](https://bookdown.org/yihui/bookdown/), or, in the case of [Shiny](https://shiny.rstudio.com), a [running instance of the app itself](https://www.shinyapps.io)
  * A development venue, such as a [GitHub repository](https://github.com)
  * A [CRAN](https://cran.r-project.org/web/packages/index.html) package landing page

Visit this home with the eyes of a newcomer and refine accordingly. If your thing has multiple online homes, make sure they link to each other, with a strong current towards the primary home.

## Make a shortlink

Unless your primary URL is already extremely short and memorable, consider creating a shortlink that is both. A link in a talk will be captured in cell phone photos and typed with fingers into phones. Make it easy on people!

http://bit.ly

## Title and closing slide

Make a slide with the most important details on you and your thing. Include this very early in your talk (probably first?) and repeat some variant at the end. This slide should feature your shortlink and any relevant URLs or handles, e.g. Twitter, GitHub, website, or email address.

DO THIS IN AN ABSOLUTELY HUGE FONT. Now is not the time for subtlety or mumbling "I know it's hard to read, but ...".

Leave this slide up for a bigly amount of time, so that people have ample opportunity to get out their phones and fire up the camera. Do not flash this vital slide for 3 seconds, only to spend 2 minutes displaying a bulleted outline of your talk.

## Feature slides

Admit that people photograph and share individual slides, e.g., via Twitter. This can be a good thing, especially if you harness it for your goals! If an audience member is moved to share your thing, it is natural they want to enhance the basic message with an evocative slide or image. Think about how well your slides work with this well-established behaviour.

If something would be terrible taken out of context or circulated widely, reflect on that and take appropriate measures.

If you have a pithy and hilarious point, give that slide some extra attention.

*Link to some guides on live-tweeting? If you'd be chuffed to see people tweet about your talk, view your talk through their eyes. This is like grant-writing: notice the words the funder uses to describe what they want to fund and repeat them back, verbatim. Find out what a live-tweeter needs and give them exactly that.*

## Post it before the talk

Choose your primary online home and secure a shortlink at it BEFORE YOUR TALK. Do not promise the slides or materials "after the talk". People are taking notes and photos right now, during your talk, and this is your best chance to tell them how to find your awesome thing when they get home.

Even if you add more materials or update your slides after the talk, it is still worth it to publicize the shortlink during the talk. These tweets will live on for months and wrap-up blog posts will come out over the next couple of weeks. Most of the genuine visits to your thing will happen later, but you will never have such a comparable opportunity to put the URL in front of people's eyeballs.

## Share slides on a slide-sharing platform

Consider how easy it is for a wide audience to click through your slides with minimum friction. Slide-specific platforms, such as [SpeakerDeck](https://speakerdeck.com), are ideal for quick browsing and linking to specific slides.

The way you interact with and present your slides is not necessarily a great distribution platform. Large PDFs in GitHub repo do not offer a pleasant browsing experience and raw HTML slides on GitHub are even worse, i.e. are not viewable.

## Notes dump so I can work on the plane

Complete the cycle: when you give talks, put links to those slides or to the video back in the appropriate part of your product's main landing page.

Ethics and mechanics of crediting others:

  * Over-creditting and over-thanking is *always* better than under. Did you get great ideas somewhere? Express this.
  * Don't use things w/o permission. Comply with licenses. Attribute. Link back to source.
  * Tricky: whether to credit/link each thing on each slide. Styles vary. I (JB) tend to create collect all such attributions in a talk-related README or on dedicated slides, as opposed to cluttering up each slide. Find something you feel is fair but aesthetically acceptable.

If you've been wavering, create a Twitter account and publicize your handle. Even if you have no immediate plans to tweet. Why? People who tweet about your talk will tag you if they can. This way you'll know about that and any ensuring likes, retweets, and discussion. Place a link to your primary website in your twitter profile, which helps people find you later and start to get a sense of your work. In effect, your Twitter handle can act as a shortlink for *you*.

Making your talk tweetable is like universal design: it makes it better for everyone, even those who don't Twitter. It's the modern version of the [Elevator Pitch](https://en.wikipedia.org/wiki/Elevator_pitch) or [Three Minute Thesis](https://en.wikipedia.org/wiki/Three_Minute_Thesis).

Think about the consumer. For example, just a link to a Youtube video will severely limit who can and will quickly take a look at your thing.

For sharing slides, the point: minimize friction!

Making slides in Rmd is great; making readers clone your repo, install any necessary packages, and knit the document in order to see your slides is not.

SpeakerDeck has some downsides (e.g. any links from your slide won't work), but you can always link to the PDF version on GitHub, etc.

Lucy: A few off the top of my head that were well publicized & had other appealing features (I'll add as I come up with more):

Alison Hill's "Take a Sad Plot and Make it Better"

  * catchy title
  * includes a gif
  * website with social buttons to immediately share: https://alison.rbind.io/talk/ohsu-biodatavis/
  * tweet: https://twitter.com/apreshill/status/982424211590230016

Kara Woo's "Anyone can play Git/R"

  * GREAT title!
  * Mara made a great tweet compilation: https://twitter.com/dataandme/status/1007333360509874177

Jennifer Thompson's "Intro to purrr"

  * promoted on twitter:
    - https://twitter.com/jent103/status/992417941533569024
    - https://twitter.com/jent103/status/976114726215266306
    - https://twitter.com/jent103/status/930455794516185088
  * beautiful (and tweet-able) slides
  * Includes a picture of a Very Cute cat

sdsifleet story of the Shiny apps, Youtube link

Jeffrey M Girard: I recently made a presentation to promote and instruct on my developing "circumplex" package. My slides are here: https://osf.io/wdaet/ and my repo is here: http://github.com/jmgirard/circumplex. Some things I learned while making this presentation:

  * I hosted my slides on the Open Science Framework as part of the conference "meeting" page
  * Putting syntax on the slides with comments in a different color was very helpful
  * Using a different (fixed width) font for syntax in the presentation was helpful
  * Making function names bold in syntax was helpful when highlighting their use
  * Putting a semi-transparent rectangle over important/changing parts of syntax was a good pointer
  * Not having my package on CRAN yet made it difficult for people to try the package out, I showed them how to install from GitHub using devtools but not everyone had Rtools installed and it was a hassle

Jennifer Thompson: Julia Silge's talk on PCA at SO is a nice example of several things:

  * where to find Julia/good ending slide
  * talk explains both the concept and the need for it
  * slides are attractive and tweetable - enough to follow without being a paper in slide form
  * stored on speakerdeck
  * one thing I also love about Alison's talk that Lucy mentioned is that the gifs + title + material all revolve around a theme! It's not only fun, but makes the talk more memorable and thus more likely to be shared. A+ marketing.

Garrick Aden-Buie: Just today I was admiring the fantastic README for @aedobbyn's postal package https://github.com/aedobbyn/postal#readme

Maelle: I saw @antuki present her COGugaison using a slidedeck like the one from her R-Ladies Paris talk https://antuki.github.io/presentations/ it's in French. I really liked the fact that her last slide had info about her, where to find the package (in today's talk direct link to the repo, in the R-Ladies one to her GitHub account) and meta-info about how she made the slides. Besides, having a talks section on her page is clever.

Maelle: For my own slides, the last few times I used gh-pages, and the last 2 times I had a shortlink to them. http://bit.do/rr2018 for instance

As a side note, making gh-pages use the master branch to render html slides is probably not as good as speaker deck since I imagine people are more used to that interface for browsing a slidedeck and discovering slidedecks but... It's so easy if you developed the slides in a GitHub repo, even a private one, that I consider this method to be a good lazy middleground. my slides about blog marketing (so not a product) were shared a lot thanks to a tweet, despite the ugly long URL https://twitter.com/robinson_es/status/977941365119176704?s=19 End of laziness advocacy. And links work with my lazy method

caitlinhudon

  * Jesse Maegan had a great shareable slide on learning with a community.
  * Eric Leung had a great slide on how to use skimr // slide 7 of this deck
  * Jonathan Nolan's presentation at Cascadia R, "Using deep learning and R to generate offensive license plates" was also great marketing for his growing consulting venture. The subject matter made everything very shareable, and the opening and closing slides were lovely too.
  * I'm fond of my own opening slide for Cascadia R as well.

Add to people to thank: Maelle Salmon, Lucy McGowan, Jeffrey M Girard, Jennifer Thompson, Garrick Aden-Buie, Caitlin Hudon
