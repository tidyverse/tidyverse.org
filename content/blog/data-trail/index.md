---
output: hugodown::hugo_document

slug: data-trail
title: Solutions for R4DS, 2e with Data Trail
date: 2023-08-01
author: Jabir Ghaffar, Davon Person, Mine Çetinkaya-Rundel
description: >
    Jabir and Davon from Data Trail worked with us to create the solutions manual for R for Data Science, 2nd edition.
    This blog post summarizes their experience and shares their reflections from working on this project.

photo:
  url: https://unsplash.com/photos/BnwRf_m3EIg
  author: Tim Foster

# one of: "deep-dive", "learn", "package", "programming", "roundup", or "other"
categories: [learn] 
tags: [book, internship]
rmd_hash: a8b3a195a54f8a23

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

As Jeff Leek introduced at rstudio::conf(2022):

> DataTrail is a no-cost, paid 14-week educational initiative for young-adult, high school and GED-graduates. DataTrail aims to equip members of underserved communities with the necessary skills and support required to work in the booming field of data science. DataTrail is a fresh take on workforce development that focuses on training both Black, Indigenous, and other people of color (BIPOC) interested in the data science industry ***and*** their potential employers.

Watch the video... <https://youtu.be/Vf301YCxP1Q>\>.

***TO DO: Add transition...***

[Jabir](https://jabirghaffar.quarto.pub/jabir/) went through the Data Trail program June 2022 and [Davon](https://www.linkedin.com/in/davon-person-1ba973194/) went through the Data Trail program in 2019 and works as a Data Programming Specialist with the project.

***TO DO: Add transition + link to r4ds 2e release...***

R for Data Science, 2nd Edition was released in June 2023. Lots of new content and revisions and additions to exercises. Link to the solutions for 1st Edition, acknowledge that it was a very useful resource for the community. This project aimed to both create a similar resource for 2nd edition and serve as an educational resource for the interns to help sharpen their tidyverse and data science in general skills. Alongside working on the solution manual for R4DS, Jabir and Davon built their homepages with Quarto using TidyTuesday datasets.

***TO DO: Add link to the actual solution manual...***

Some learning highlights for Jabir included faceting (as a solution to overplotting), consistent code styling (which helps make the code more pleasing to read), and, making maps! Specifically, Jabir mentioned that he has always wondered "how did they do that?!" with maps and found them to be quite intimidating, so it was especially satisfying to create his first heatmap of US states and chance of getting a tornado (<https://jabirghaffar.quarto.pub/jabir/posts/tornado_mapping_exploration>). This was not just a satisfying visualization exercise, but also a great opportunity to dig into unfamiliar data wrangling functions like `recode()` for converting 2-letter state abbreviations to state names.

The exercises in R4DS range from quick, almost obvious, drills to ones that can really make you think and spin your wheels for a bit. One such exercises for Jabir was the one on changing the display of presidential terms from [Section 12.4.6](https://r4ds.hadley.nz/communication.html#exercises-2). Jabir says "This question completely puzzled me. I'd say good luck and if you're new and you get to this question i recommend you look at the solution manual."

The exercise provides the plot on the left as a starting point, and wants you to end with the plot on the right:

***TO DO: Insert book plot + Jabir's plot...***

The first challenge was identifying where in the text the original plot was developed, and the code associated with it. And then, the most challenging part of this exercise was labeling the y-axis with the names of presidents. It took lots of Googling, but ultimately Jabir used suggestions from ChatGPT to get this over the finish line. And, perhaps, the frustrating and satisfying part is that the answer was pretty obvious in hindsight.

Jabir felt like moments when he knew what to do and how to answer each question were very satisfying, but the moments where he felt stuck and went into rabbit holes looking for answers made him question whether he wanted to continue becoming a data scientist. Ultimately, though, the project was enjoyable, and not just a great learning experience for Jabir, but also a very meaningful one because it created a resource that can help future data scientists.

We felt like Jabir advanced his data science skills throughout the project. Mention TidyTuesday here. Appreciate contributions. Getting involved with first open-source project, hopefully more to come in the future... And just like most open-source projects, this one is a living and breathing project, still a work-in-progress. We would welcome any community contributions, it's a particularly well-suited project for first-time contributors...

