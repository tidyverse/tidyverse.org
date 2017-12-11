---
title: workflow
author: Jenny Bryan
date: '2017-12-12'
slug: workflow-vs-script
description: >
  Advice on workflows for developing R scripts. How to decide if an action belongs in the script or not.
categories:
  - programming
photo:
  url: https://commons.wikimedia.org/wiki/File:Burned_laptop_secumem_11.jpg
  author: secumem
tags: []
---

I gave a talk today at the [IASC-ARS/NZSA Conference](http://www.nzsa2017.com), hosted by the Stat Department at The University of Auckland. One of the conference themes is to celebrate the accomplishments of Ross Ihaka, who got R started back in 1992, along with Robert Gentleman. My talk included lots of advice on ways to set up your R life to maximize effectiveness and reduce frustration.

Two specific slides have generated much discussion and consternation in #rstats Twitter and I think more explanation is in order:

*insert suitably small images here or use quotation*

> If the first line of your R script is
> 
> `rm(list = ls())`
> 
> I will come into your office and
>      SET YOUR COMPUTER ON FIRE 🔥.

> If the first line of your R script is
> 
> `setwd("C:\Users\jenny\path\that\only\I\have")`
> 
> I will come into your office and
>      SET YOUR COMPUTER ON FIRE 🔥.


Here's my attempt to explain *why* I have such strong opinions.

## Workflow versus Product

It's important to recognize the difference between things you do because of personal taste and habits ("workflow") versus the logic and output that is the essence of your project ("product"). Here are examples of what I consider to be workflow:

  * The IDE you use, e.g., RStudio, Emacs with ESS, or nothing at all.
  * The name of your home directory.
  * The R code you ran before lunch.
  
Here are examples of what I consider to be product:

  * The raw data.
  * The R code I would need to run on your raw data to get your results, including the explicit `library()` calls to load necessary packages.
  
Ideally, no one can detect anything about your workflow from your product. Or at least, it should be as easy as possible for people with a different workflow to reproduce your product if they have your input and code. 

## Self-sufficiency

I suggest organizing data analyses into *projects*: a folder on your computer that holds all the files relevant to a particular piece of work. Any resident R script should assume that it will be run from a fresh R process with working directory set to the directory where this project lives. This convention guarantees that the project can be moved around on your computer or onto other computers and will still "just work". I argue that this is the only practical convention that creates reliable behavior across different computers or users and over time.

## What's wrong with `setwd()`?

I run alot of student code in [STAT 545](http://stat545.com) and, at the start, I see alot of R scripts that look like this:

``` r
setwd("/Users/jenny/cuddly_broccoli/verbose_funicular/foofy/data")
df <- read.delim("raw_foofy_data.csv")
p <- ggplot(df, aes(x, y)) + geom_point()
ggsave("../figs/foofy_scatterplot.png")
```

The chance of the `setwd()` command having the desired effect -- making the file paths work -- for anyone besides its author is 0%. It's also unlikely to work for the author one or two years or computers from now. The project is not self-contained and is not portable. To recreate and perhaps extend this plot, the lucky recipient will need to hand edit one or more paths to reflect where the project has landed on their machine. When you do this for the 73rd time in 2 days, while marking an assignment, you start to fantasize about lighting the perpetrator's computer on fire.

This use of `setwd()` is also highly suggestive that the useR does all of their work in one R process and manually switches gears when they shift from one project to another. That sort of workflow makes it unpleasant to work on more than one project at a time and also makes it easy for work done on one project to accidentially leak into subsequent work on another (e.g., objects, loaded packages, session options).

## Use the [here package](https://CRAN.R-project.org/package=here) and Projects

How can you avoid `setwd()` at the top of every script?

  * Organize each logical project into a folder on your computer.
  * Make sure the top-level folder advertises itself as such: I HOLD A PROJECT! This can be as simple as having an empty file named `.here`. Or, if you use RStudio and/or Git, those both leave characteristic files behind that will get the job done.
  * Use the `here()` function from the [here package](https://CRAN.R-project.org/package=here) to build the path when you read or write a file. Create paths relative to the top-level directory.
  
Whenever you work on this project, launch the R process from the project's top-level directory. To continue our example, make sure R is launched in the `foofy` directory, wherever that may be. Now the code looks like so:

``` r
df <- read.delim(here("data", "raw_foofy_data.csv"))
p <- ggplot(df, aes(x, y)) + geom_point()
ggsave(here("figs", "foofy_scatterplot.png"))
```

This will run, with NO HAND EDITS, for anyone who follows the convention about launching R in the project folder. (In fact, it will even work if you launch R from any subfolder inside the project.) It's like agreeing that we will all drive on the left or the right. A hallmark of civilization is following conventions that constrain your behavior a little, in the name public safety.

If you do use RStudio, this can be even easier. RStudio allows you to designate a folder as an [RStudio Project](https://support.rstudio.com/hc/en-us/articles/200526207-Using-Projects) (note the capital "P"). All this means is that RStudio will leave a file, e.g., `foofy.Rproj`, in the folder. Consider this an RStudio "note to self" that can hold preferences specific to that project.

The here package piggybacks on the Project setup and uses the presence of an `.Rproj` file to recognize the top-level of your project. Last but not least, you can double click on the `.Rproj` file to launch an instance of RStudio where the associated R process and file browser are conveniently pointed at the correct folder. RStudio fully supports Project-based workflows, making it easy to switch from one to another, have many open at once, re-launch recently used Projects, etc.

Read up on the [here package](https://CRAN.R-project.org/package=here) to learn about more features, such as additional ways to mark the top directory and troubleshooting with `dr_here()`. I have also written a [more detailed paean](https://github.com/jennybc/here_here) about this package before.

## What's wrong with `rm(list = ls())`?

It's also fairly common to see data analysis scripts that begin with this workspace-nuking command:

``` r
rm(list = ls())
```

Just like hard-wiring the working directory, this is, again, highly suggestive the useR works in one R process and manually switches gears when they shift from one project to another. It's clear that "situation normal" for this user is an R process that is used, not fresh and clean.

The problem is that `rm(list = ls())` does NOT, in fact, create a fresh R process. All it does is delete user-created objects from the global workspace.

Many other important changes to the R landscape persist invisibly. Any packages that have been loaded are still available. Any options that have been set to non-default values remain that way. Working directory is unaffected (which is, of course, why we see `setwd()` so often here too!).

Why does this matter? It means your script is now vulnerable to hidden dependencies on things you ran in this R process before you executed `rm(list = ls())`.

  * You might use functions from a package without including the necessary `library()` call. Your collaborator won't be able to run this script.
  * You might code up an entire analysis assuming that `stringsAsFactors = FALSE` but next week, when you have restarted R, everything will inexplicably be broken.
  * You might write paths relative to some random working directory, then be puzzled next month when nothing can be found or results don't appear where you expect.

The solution is to write every script assuming it will be run in a fresh R process. How do you enforce this? Two key steps:

  * User-level setup: Do not save `.RData` when you quit R and don't load `.RData` when you fire up R. In RStudio, this behavior can be requested in the General tab of Preferences.
  * Daily/hourly operations: Restart R very often and re-run your under-development script from the top! No matter how you run R, this is not difficult. If you use RStudio, you can use the menu item *Session > Restart R* or the associated keyboard shortcut Ctrl+Shift+F10 (Windows and Linux) or Command+Shift+F10 (Mac OS).
  
This practice requires that you fully embrace the idea that **source is real** and that you always retain the source to create any valuable object from your raw data. This doesn't mean that your scripts need to be perfectly polished and ready to run, say, unattended a remote server. Scripts can be messy, anticipating interactive execution, but still *complete*. Clean them up when and if you need to.

What if you've got some object that took a long time to create and the idea of deleting it makes you nauseous? Isolate that bit in its own script and write the precious object to file with `saveRDS(my_precious, here("results", "fits.rds"))`. Now you can develop scripts to do downstream work that reload the precious object via `my_precious <- readRDS(here("results", "fits.rds"))`. It is a good idea to break such a process into logical, isolated pieces anyway.
  
Lastly, `rm(list = ls())` is hostile to anyone that you ask to help you with your R problems. If they take a short break from their own work to help debug your code, their generosity is rewarded by losing all of their previous work. Now granted, if your helper has bought into all the practices recommended here, this is easy to recover from, but it's still irritating. When this happens for the 100th time in a semester, it rekindles the computer arson fantasies triggered by last week's fiascos with `setwd()`.
