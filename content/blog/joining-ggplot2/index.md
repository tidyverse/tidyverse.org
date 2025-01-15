---
output: hugodown::hugo_document

slug: joining-ggplot2
title: Joining the ggplot2 team
date: 2025-01-09
author: Teun van den Brand
description: >
    I joined the ggplot2 team and would like to share the experience.

photo:
  url: https://unsplash.com/photos/person-holding-green-plant-on-black-pot-CbZh3kaPxrE
  author: Jonathan Kemper

# one of: "deep-dive", "learn", "package", "programming", "roundup", or "other"
categories: [other] 
tags: []
rmd_hash: 667a69f2874f61c6

---

<!--
TODO:
* [ ] Look over / edit the post's title in the yaml
* [ ] Edit (or delete) the description; note this appears in the Twitter card
* [ ] Pick category and tags (see existing with [`hugodown::tidy_show_meta()`](https://rdrr.io/pkg/hugodown/man/use_tidy_post.html))
* [ ] Find photo & update yaml metadata
* [ ] Create `thumbnail-sq.jpg`; height and width should be equal
* [ ] Create `thumbnail-wd.jpg`; width should be >5x height
* [ ] [`hugodown::use_tidy_thumbnails()`](https://rdrr.io/pkg/hugodown/man/use_tidy_post.html)
* [ ] Add intro sentence, e.g. the standard tagline for the package
* [ ] [`usethis::use_tidy_thanks()`](https://usethis.r-lib.org/reference/use_tidy_thanks.html)
-->

Hello there! I've been working on ggplot2 for a while now, and I'd like to tell you how that came about and what it is like.

## How I got involved

My journey into learning R started in 2017 during an internship at the EMBL-EBI. The main gripe about base R plotting that drove me into ggplot2's arms were the arcane invocations to get anything else than one of the pre-approved chart types. In contrast, ggplot2 absorbs a bunch of small paper cuts, is very compositional in nature while remaining highly customisable. In a bid to "learn from the mistakes of others" rather than (continue to copiously) make my own, I became active on Stack Overflow answering questions and solving plotting issues. For posterity: this was in the days before you could ask an large language model for personalised advice and actual humans were equally frustrated on both sides of the question.

I was keeping track of solutions to common problems in a personal cookbook that had its own arcane invocations. To give a bit of flavour: much of the cookbook was about preparing gtables, the data structure that comes out of building a plot, for combining and aligning plots. [^1] The cookbook eventually grew into my first ggplot2 extension package: [ggh4x](https://teunbrand.github.io/ggh4x/). Perhaps that package would be best subtitled: 'Remedies to my common ggplot2 ailments'. It contains a bunch of miscellaneous functions ranging from reorganising facets to putting minor ticks on the axes. Simultaneously this was also a downside, as ggh4x lacked any sense of scope (and still does, as befits any first package).

Around the time I was really getting into ggplot extensions, Gina Reynolds had started organising a meeting for people who build ggplot2 extensions. It is an interesting place to meet others and hear about their packages and how they face interacting with the ggplot2 extension system. I started attending with some degree of regularity and made a discussion place on GitHub. We now use this for general exchange of ideas, but also package specific issues.

Meanwhile, the questions on Stack Overflow kept directing my attention at the ggplot2 issue tracker every once in a while. After lurking in there for a bit, I started my first informal contributions to ggplot2 itself by answering the simple stuff just as I did on Stack Overflow. It may not seem like much of a contribution, but in retrospect, answering issues helps triaging them: it divorces those issues who need additional changes in ggplot2 from those that do not. My first 'proper contribution' in the shape of a pull request was in 2020. It replaced 3 lines of code with 2 lines of code to benefit type stability (this was prior to [vctrs](https://vctrs.r-lib.org/))[^2].

In 2022, I commented "I'd be willing to take a stab at this" on an issue proposing a large refactor of the guide system. I like to think it was this precise moment that Thomas, the project lead after having taken over for Hadley, took notice and later invited me to join the team[^3]. This new guide system ended up laying the foundation for [legendry](https://teunbrand.github.io/legendry/), so it wasn't entirely out of unselfish reasons that I volunteered. At any rate, this is a great opportunity to fill big shoes on a major R project, so I'm very excited to have joined!

## Becoming an insider

Part of being on the team is straightforward. You triage issues. You fix bugs. You implement new features. At the point that I joined, I had already done these things as an outsider. The only thing that really changes is that you get the keys of the kingdom: you can now close issues and merge pull requests [^4]. You're then trusted to wield this power wisely. You then hope you do.

At the time I joined the most active maintainers were Thomas, Claus and Hiroaki. I was surprised to learn that really most communication happens on GitHub and it is all public discussion. Even more abstract coordination that does not neatly fit into a single issue, like preparing a new release, didn't occur behind closed doors. I think what made my introduction to the team more awkward than it needed to be was that GitHub issues is not really a good place for announcements where you can say 'Hi everyone, this person is on the team now and will be doing stuff in the project'. I had interacted with the other active maintainers before, so I wasn't a completely alien actor, but I felt some unclarity lingered longer than it ought have. Perhaps I should more assertively have introduced myself [^5].

However, by the time posit::conf(2024) was over, I've met 6 out of the 9 other authors in person. I have more thoughts about conf and my first time in the United States, but it has been amazing to meet all these people in person whose work you've been admiring for a while!

## Maintaining ggplot2

The ggplot2 package has both the blessing and the curse of being a popular package. One the one hand, it is a blessing that people care about the project, post issues that they find and make intermittent contributions. The curse is that it is such a staple in the R ecosystem, that almost any change will inadvertently affect somebody else's code. Not only because ggplot2 is widely used, but also because people have been ...creative... with how they are using ggplot2. The art of making changes is to largely affect plots in a good way.

The first big project I was rummaging through was the guide system I proposed to rewrite. The guide system was never been advertised as an official extension point, but naturally that didn't preclude people from using it as an extension point anyway.[^6] So in addition to rewriting the system, we also had to prevent terribly breaking extensions that relied on the old system. In some cases, this meant sending out PRs to other packages to be compatible with both systems.

Having worked through a good number of issues at this point in time, I can see some emergent patterns. Different patterns can be partially explained by different audiences. The regular user wants to be empowered to execute their vision of a plot effectively. Maintainers of extensions would often like things to work consistently or change a very obscure line somewhere that they have identified as blocking a niche use case. Teachers would like their students to get stuck less often, which often involves improving error messages. All in all, there is no shortage of issues to work through.

The next big thing we're working on is some practical necromancy in getting themeable aesthetics resurrected, which was [initiated by Dana Paige Seidel](https://www.danaseidel.com/2018-09-01-ATidySummer/) all the way back in 2018! We'd like the theme to be a home for more default choices than just non-data elements. Default layer aesthetics are a start, but we plan on putting in default palettes too.

## A few words of thanks

I've been plucked from a level of relative obscurity ---a package maintainer that has this weird miscellaneous package--- into the path of a flagship R project, for which I'm very grateful. First and foremost I'm thankful to Thomas Lin Pedersen, who has put me into this position and steers the ggplot2 project. Secondly to Hadley Wickham and the rest of the tidyverse team, who make me feel included; both at conf and during regular meetings[^7]. Thirdly, the co-authors I met during conf: Claus Wilke, for whose workshop I TA'd, but also Kara Woo and Winston Chang. Lastly, I'd like to thank Posit the company for contracting me to do work I also enjoy as a hobby!

[^1]: Luckily, we don't have to think about this *at all*, thanks to the [patchwork](https://patchwork.data-imaginist.com/) package!

[^2]: I'm omitting here that I also had to write 50 lines of tests for this small change

[^3]: How much this actually reflects any truth is for any of us to guess and for Thomas to know. Later, I learned that this was also [how Thomas himself was roped into the project](https://www.data-imaginist.com/posts/2016-10-31-becoming-the-intern/)!

[^4]: After review though. You're not given *that* much power!

[^5]: But I'm not celebrated for my social graces :)

[^6]: I don't have a moral high ground here: I was one of the worst offenders!

[^7]: Mostly for The Golden Hex Sticker though!

