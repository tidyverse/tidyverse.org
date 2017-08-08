---
title: Get help!
---

> In space, no one can hear you scream.
>
> -- <cite>Alien (1979)</cite>
  
Luckily the Tidyverse is a friendlier place. Ease of adoption and ease of use are fundamental design principles for the packages in the Tidyverse. If you are banging your head in frustration, here's how you can help us help you.

## Reprex {#reprex}

If you need help getting unstuck, the first step is to create a __reprex__, or reproducible example. The goal of a reprex is to package your problematic code in such a way that other people can run it and feel your pain. Then, hopefully, they can provide a solution and put you out of your misery.

There are two parts to creating a reprex:

* First, you need to make your code reproducible. This means that you need
  to capture everything your code needs to run and bundle it up into a script.
   You need to capture any `library()` calls and create all necessary objects. The easiest way to make sure you've done this is to use the [reprex package](http://reprex.tidyverse.org).
  
* Second, you need to make it minimal. This requires stripping away every aspect of the data and code that is not directly related to your problem. This usually involves creating a much smaller and simpler R object than the one you're facing in real life.
  
That sounds like a lot of work!  And it can be, but it has a great payoff:

* 80% of the time creating an excellent reprex reveals the source of your problem. The process of creating a self-contained and minimal example often allows you to answer your own question.

* The other 20% of time you will have captured the essence of your problem in
  a way that is easy for others to play with. This substantially improves
  your chances of getting help!

## Where to ask

Now that you've made a reprex that you can easily inflict on others, you need to share it in an appropriate forum.

* Mailing lists.  There are two mailing lists that cover specific parts of the 
  tidyverse. The [ggplot2 mailing list][ggplot2-ml] is devoted to anything
  and everything related to visualisation with ggplot2. The
  [manipulatr][manipulatr-ml] covers anything related to data manipulation,
  including dplyr, tidyr, and all the data import packages.
  
* [Stack Overflow](https://stackoverflow.com). You're probably already familiar
  with Stack Overflow from googling: it's a frequent source of answers to
  coding related questions. Asking a question on Stack Overflow can be 
  intimidating, but if you've taken the time to create a reprex, you're much
  more likely to get a useful answer. Make sure to [tag your question](https://stackoverflow.com/help/tagging) with R
  and tidyverse so that the right people are more likely to see it.
  
* [Twitter][twitter-rstats]. It's hard to share your reprex only on twitter, because 140 characters are rarely enough and screenshots don't help others play with your code. But twitter is a great place to share a link to your reprex that's hosted elsewhere. The #rstats twitter community is extremely friendly and active, and is a great crowd to be a part of. Make sure you tag your tweet with #rstats and #tidyverse.

* If you think you've found a bug, follow the instructions on 
  [contributing to the tidyverse](/contribute#issues).

[ggplot2-ml]: https://groups.google.com/forum/#!forum/ggplot2
[manipulatr-ml]: https://groups.google.com/forum/#!forum/manipulatr
[twitter-rstats]: https://twitter.com/search?q=%23rstats&src=typd
