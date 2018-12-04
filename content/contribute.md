---
title: Contribute to the tidyverse
---

The tidyverse would not be possible without the contributions of the R community. No matter your current skills, it's possible to contribute back to the tidyverse. 

## Answer questions {#answers}

The easiest way to help out is to answer questions. You won't know the answer to everything, but that's ok! Even just the acknowledgement that someone cares enough to try can be tremendously encouraging.

Many people asking for help, don't know about reprexes. A little education, and some help crafting a [reprex](/help#reprex) can go a long way. You might not answer the question, but you'll help someone answer it more easily. 

If you're interested in answering questions, some good places to start are the [RStudio community site](https://community.rstudio.com/), or the tidyverse tags on [Twitter](https://twitter.com/search?q=%23tidyverse) and [Stack Overflow](https://stackoverflow.com/questions/tagged/tidyverse?sort=newest). Just remember that while you might have seen the problem a hundred times before, it's new to the person asking it. Be patient, polite, and empathic.

## File issues {#issues}

If you've found a bug, first create a minimal [reprex](/help#reprex). Spend some time trying to make it as minimal as possible: the more time you spend doing this, the easier it will be for the tidyverse team to fix it. Then file it on the GitHub repo of the appropriate package.

To be as efficient as possible, development of tidyverse packages tends to be very bursty. Nothing happens for a long time, until a sufficient quantity of issues accumulates. Then there's a burst of intense activity as we focus our efforts. That makes development more efficient because it avoids expensive context switching between problems. This process makes a good reprex particularly important because it might be multiple months between your initial report and when we start working on it. If you can't reproduce the bug, we can't fix it!

## Contribute documentation 

If you're a bit more experienced with the tidyverse and are looking to improve your open source development skills, the next step up is to contribute a pull request to a tidyverse package. The most important thing to know is that tidyverse packages use [roxygen2](https://github.com/klutometis/roxygen): this means that documentation is found in the R code close to the source of each function. There are some special tags, but most tidyverse packages now use markdown in the documentation which makes it particularly easy to get started.

## Contribute code

If you are a more experienced programmer, you might want to help out with the package development. Before you do a pull request, you should always file an issue and make sure someone from the tidyverse team agrees that it's a problem, and is happy with your basic proposal for fixing it. We don't want you to spend a bunch of time on something that we don't think is a good idea.

Also make sure to read the [tidyverse style guide](http://style.tidyverse.org/) which will make sure that your new code and documentation matches the existing style. This makes the review process much smoother.
