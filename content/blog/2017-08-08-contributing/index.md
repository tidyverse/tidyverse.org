---
title: Contributing code to the tidyverse
author: Jim Hester
slug: contributing
date: 2017-08-14
photo:
  url: https://unsplash.com/photos/qFxS5FkUSAQ
  author: Yuriy Rzhemovskiy
categories: [programming]
description: >
  Contributing code to open source projects can be intimidating. These projects
  are often widely used and have well known maintainers. Contributing code and
  having it accepted seems an almost insurmountable task. However if you follow a
  few simple strategies you can have your code accepted into even the most
  popular projects in the tidyverse.
---

> This post originally appeared at <http://www.jimhester.com/2017/08/08/contributing/>

Contributing code to open source projects can be intimidating. These projects
are often widely used and have well known maintainers. Contributing code and
having it accepted seems an almost insurmountable task.

However if you follow a few simple strategies you can have your code accepted
into even the most popular projects in the [tidyverse](https://tidyverse.org).

### Don't contribute code ###

The easiest way to contribute to an open source package is not to contribute
code at all. Find a typo in the documentation, add a reproducible
example to an open issue without one, post a solution to a question in an
 issue, on [twitter](https://twitter.com/search?q=%23rstats) or
[stackoverflow](https://stackoverflow.com/questions/tagged/r). These types of
contributions are among the easiest things for maintainers to review and
accept, so it is a great place to start getting used to the contribution
process.

### Read CONTRIBUTING.md ###

Often projects will have a `CONTRIBUTING.md` document that has instructions for
contributing to the project. These are guidelines the maintainers would like
contributors to adhere to and exist to make the process flow more smoothly. As a
contributor you should try to make accepting your code as easy as you
can, this greatly increases the chance your contribution will be accepted.
These files are not currently widespread in the tidyverse, but it's something
we will be working on in the future!

### Explore previously merged contributions ###

Next you should read a few previously merged pull requests for additional
context. If a project does not have a `CONTRIBUTING.md` (or similar)
document this is your best source of information on expected practices for
contributions.

Things you should look for include how are the commit messages formatted? Are
any additional files changed apart from the code changes (such as NEWS
updates)? Do the contributions all include additional test cases? Do internal
only changes need documentation? 

Some Common tidyverse conventions are

 - Add a bullet to `NEWS.md` for each change referencing the issue number and your GitHub username.
 - Add `Closes #123` at the end of your commit message to automatically close the issue with the PR is merged.
 - Document functions with [roxygen](https://github.com/klutometis/roxygen) and be sure to run `devtools::document()` before submitting.

Read the reviewer comments in the pull request
to get an idea of what in particular reviewers are looking for. Do they require
certain [code style](http://style.tidyverse.org), variable names or code
organization? Are there common requests such as adding a note to the NEWS
commonly forgotten? If you can handle these things _before_ the reviewer even
sees your code is greatly reduces the friction in merging your changes.

### Make your changes as _small_ as possible ###

One of the most common mistakes contributors make is to add a complicated new
feature as their first contribution.

Accepting code as a maintainer means you
have to _maintain_ that code in the future, fixing bugs, updating
documentation, refactoring it as the rest of the code evolves. This means the
maintainer need to fully understand any code they accept.

What this means for contributors is they should strive to make their
contribution as simple to understand as possible. The best way to do this is to
make the contribution as short and clear as possible, changing as little of the
existing code as you can. First time contributions is not the time to do major
restructuring or reformatting of existing code. The best way to check exactly
what changes you are proposing is to use `git diff` _prior_ to submitting your
contribution. This will ensure it contains only the changes necessary for the
new functionality.

### Include tests ###

Contributions with test cases are easier to accept because the tests ensure the
code does what it intends to do and nothing else. Without tests the maintainer
needs to check the new functionality by hand, a burden you can lessen or remove
by including tests. If you are not sure what parts of your code is covered by
tests [covr](https://cran.r-project.org/package=covr) is a great tool to use
before submission. Just run the following to get a local coverage report of the
package so you can see exactly what lines are not covered in the project.

```r
# install.packages("covr")
co <- covr::package_coverage()
covr::report(co)
```

In addition adding tests to parts of the code base that is not currently
covered is a great way to contribute to a project.

### Follow the style ###

One of the first barriers to acceptance is coding style. Do not submit a
contribution using camelCase to a project that uses snake_case, or use tabs
when the project uses spaces. For tidyverse projects read the [Style
Guide](http://style.tidyverse.org) and use the
[lintr](https://cran.r-project.org/package=lintr) package to find code which
does not adhere to the style guide.

```r
# install.packages("lintr")
lintr::lint_package()
```

Remember to include style changes only in code you are contributing. If you
want to fix style overall in the package that is a great idea, but it should be
in a separate pull request!

### Contribute to active projects ###

Development of tidyverse projects typically progresses in waves. We work
intensely on a certain project for a period of time, then let it lie fallow for
awhile and work on other things. Because of this contributions to projects
which are not being actively developed may not be addressed for a long length
of time. This does not mean the contribution is not appreciated, but it does
mean you have to be patient and when it is reviewed be prompt with a response.

You can avoid these lengthy wait times by contributing to projects being
actively developed. Look at the GitHub contributions of members of the
tidyverse and times of recent commits of projects to see which are active and
which are fallow.

### Be attentive, not pushy ###

When a maintainer does review a contribution, try to address the comments in
short order, your changes are much more likely to be accepted if they
are addressed in the next day than the next month. In addition occasional
comments bumping the issue can be useful if changes have been made, but do not
repeatably 'ping' an issue because you feel it is been opened too long without
acceptance.

If you absolutely need a feature from a development package an option is to
install your personal fork with the features included, or even install the
package directly from the pull request.

```r
# install.packages("devtools")

# install from personal fork
devtools::install("/path/to/pkg")

# install from a pull request #123
devtools::install_github("tidyverse/glue#123")
```

### View contributing as a relationship, not a transaction ###

The best way to be successful contributing to open source projects is to do so
repeatedly. This means cultivating trust between yourself and the maintainer by
multiple successful contributions. After a series of smaller contributions the
maintainer will be much more willing to review and accept more substantial
changes. As with any relationship being polite and considerate throughout will
go a long way to improve trust. If you instead view the contribution as a
solitary transaction to add your pet feature you are much less likely to be
successful.

### Contribute! ###

Contributing to open source software will make you a better programmer, gain
valuable feedback through code review, look great on your resume and increase
your visibility in the community. It may even get you a job; I am on the
tidyverse team today mainly because I was a frequent open source contributor to
tidyverse packages over a number of years.
