---
title: Get help!
---

Are you stuck trying to get one of the packages in the tidyverse working? Are you banging your in frustration that some tidyverse code doesn't work? Follow the advice on this page to help us. help you.

## Reprex {#reprex}

If you need a help with a problem, the first step to create a __reprex__, or reproducible example. The goal of a reprex is to take that code that's causing a problem on your computer, and package it up in such a way that other's can use it too.

There are two parts to creating a reprex:

* First, you need to make your code reproducible. This means that you need
  to capture everything your code needs to run and bundle it up into a script.
  The easiest way to make sure you've done this is to use the reprex package.
  
* Second, you need to make it minimal. This involves progressively stripping
  out every element of the code that is not directly to your problem.

That sounds like a lot of work!  And is, but it pays off because:

* 80% of the time creating an excellent reprex allows you to solve your
  own problem because it helps you isolate exactly where the problem
  occurs.
  
* The other 20% of time you have captured the essence of your problem in
  a way that is easy for others to play with. This substantially improves
  your chances of getting help!

## Where to ask

Now that you've made a reprex that you can easily share with others, it's time to seek help.

* Mailing lists.  There are two mailing lists that cover smaller parts of the 
  tidyverse. The [ggplot2 mailing list][ggplot2-ml] is devoted to anything
  and everything related to visualisation with ggplot2. The
  [manipulatr][manipulatr-ml] covers anything related to data manipulation,
  including dplyr, tidyr, and all the data import packages.
  
* [Stack Overflow](https://stackoverflow.com). You're probably already familiar
  with Stack Overflow from googling: it's a frequent source of answers to
  coding related questions. Asking a question on stackoverflow can be 
  intimidating, but if you've taken the time to create a reprex, you're much
  more likely to get a useful answer. Make sure to tag your question with R
  and tidyverse so that the right people are more likely to see it.
  
* [Twitter][twitter-rstats]. It's hard to share your reprex on twitter,
  but it's a great place to share your reprex that's hosted elsewhere.
  The #rstats twitter community is extremely friendly and active, and
  it's a great community to be a part of. Make sure you use tag your tweet 
  with #rstats and #tidyverse.

* If you think you've found a bug, follow the instructions on 
  [contributing to the tidyverse](/contributing#issues).

[ggplot2-ml]: https://groups.google.com/forum/#!forum/ggplot2
[manipulatr-ml]: https://groups.google.com/forum/#!forum/manipulatr
[twitter-rstats]: https://twitter.com/search?q=%23rstats&src=typd
