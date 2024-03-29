---
output: hugodown::hugo_document

slug: relicensing-packages
title: "Re-licensing packages: a retrospective"
date: 2021-12-07
author: Mara Averick
description: >
    Over the past year and change we re-licensed the vast majority of tidyverse, tidymodels, and r-lib packages to use the MIT license. Here, we discuss the mechanics and rationale.

photo:
  url: https://unsplash.com/photos/ymf4_9Y9S_A
  author: Randy Fath

# one of: "deep-dive", "learn", "package", "programming", "roundup", or "other"
categories: [other] 
tags: []
rmd_hash: dfc3406c07092f42

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
* [x] [`usethis::use_tidy_thanks()`](https://usethis.r-lib.org/reference/use_tidy_thanks.html)
-->

The tidyverse (including tidymodels and r-lib) includes packages that have been written over the course of 15 years. Unfortunately this has lead to a diversity of licenses [^1]. It is fundamentally important that software has a license, because without it no one knows how they can use it. While our packages already had open source licenses, when we looked at them holistically, we realised that we used a rather large variety of licenses, including MIT, BSD, GPL (versions 2 and 3), and more! While nothing is wrong with any of these licenses individually, the collective variety makes things confusing, particularly for people or organizations who want to use multiple packages together.

To reduce this confusion and make it clear that our packages are an unconditional gift that can be freely used without reciprocal obligation, we embarked on a journey to apply the same license to as many of our packages as possible (we couldn't apply the same license to every package because some packages bundled code with incompatible licenses). No license is perfect, but we had to choose one, and after much discussion we decided on [the MIT License](https://spdx.org/licenses/MIT). The MIT License is short (171 words), widespread, relatively easy to understand (see lawyer/programmer Kyle E. Mitchell's ["The MIT License, Line by Line"](https://writing.kemitchell.com/2016/09/21/MIT-License-Line-by-Line.html) for details), and very permissive. MIT is not "copyleft" or "hereditary"[^2] which require that derivative works[^3] must be licensed under the same license (e.g. GPL) and be subject to (aka "inherit") all of its restrictions .

Once we decided on the MIT license, we needed to check with all the authors of the code to make sure it was OK to relicense it. This involved several steps. We started by reviewing all commits made by non-RStudio contributors[^4] to each package. We then contacted all (\~500) contributors whose changes could constitute a copyrightable contribution (i.e. anything other than minor edits, such as typo fixes) via GitHub, e-mail, or (in a limited number of cases) personal communication requesting their statement of agreement[^5] .

You can see an example of the process in [the re-licensing issue for purrr](https://github.com/tidyverse/purrr/issues/805). The re-licensing generated some discussion but we were grateful to receive unanimous agreement to re-license, thus avoiding the need to re-implement any existing code[^6].

The bulk of our packages are now under MIT, which means they're consistent (yay!), and you can continue to use them as you were before (especially since we didn't think there was any problem using them for any reason under their previous licenses).

This blog post has been a long time coming, and (by necessity) gives a reductive summary of nuanced topics. If you'd like to learn more about copyright and intellectual-property law as it pertains to open-source software, I recommend the following four books:

-   **Open Source Licensing: Software Freedom and Intellectual Property Law** by Lawrence Rosen (2004). Available from Rosen free online at <http://www.rosenlaw.com/oslbook.htm>.

-   **Understanding Open Source and Free Software Licensing** by Andrew M. St. Laurent (2004).

-   **Intellectual Property and Open Source: A Practical Guide to Protecting Code** by Van Lindberg (2008).

-   **The Open Source Alternative: Understanding Risks and Leveraging Opportunities** by Heather J. Meeker (2008).

You can also check out the [research notes](https://colorado.rstudio.com/rsc/relicensing-the-notes/the-notes.html) that I (Mara) made while working on this project.

[^1]: A license is an agreement in which a licensee is given permission to use the property by the property holder. The licensee's use is conditional on the grant, scope, and reservation of rights of the granted permission.

[^2]: Term used in Heather J. Meeker's *The Open Source Alternative: Understanding Risks and Leveraging Opportunities*, 2008.

[^3]: What constitutes a "derivative work" is complicated, nuanced, and beyond the scope of this discussion.

[^4]: This includes those who were not affiliated with RStudio at the time of their contributions.

[^5]: "Prior art" includes the re-licensing of the Bootstrap framework, the details of which are nicely documented in this [StackExchange thread](https://opensource.stackexchange.com/questions/6097/how-does-bootstrap-v4-mit-deal-with-contributions-made-under-v3-apache-2-0/6099#6099).

[^6]: This is permitted under what is known as the "idea-expression" dichotomy in copyright law, codified in 17 U.S.C. § 102 under which "protection is given only to the expression of the idea-not the idea itself" *Mazer v. Stein*, 347 U.S. 201 (1954) at 217.

