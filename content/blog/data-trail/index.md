---
output: hugodown::hugo_document

slug: data-trail
title: Solutions for R4DS, 2e with Data Trail
date: 2023-08-02
author: Jabir Ghaffar, Davon Person, Mine Çetinkaya-Rundel, Tracy Teal
description: >
    Jabir and Davon from Data Trail worked with us to create the solutions manual for R for Data Science, 2nd edition.
    This blog post summarizes their experience and shares their reflections from working on this project.

photo:
  url: https://unsplash.com/photos/BnwRf_m3EIg
  author: Tim Foster

# one of: "deep-dive", "learn", "package", "programming", "roundup", or "other"
categories: [learn] 
tags: [book, internship]
rmd_hash: 8aa13f52cfb3c5bd

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

Last year at rstudio::conf(2022) Jeff Leek [shared about the Data Trail program](https://youtu.be/Vf301YCxP1Q).

> DataTrail is a no-cost, paid 14-week educational initiative for young-adult, high school and GED-graduates. DataTrail aims to equip members of underserved communities with the necessary skills and support required to work in the booming field of data science. DataTrail is a fresh take on workforce development that focuses on training both Black, Indigenous, and other people of color (BIPOC) interested in the data science industry ***and*** their potential employers.

We then have been so excited to have the opportunity to work with two Data Trail interns this year! [Jabir Ghaffar](https://jabirghaffar.quarto.pub/jabir/) went through the Data Trail program June 2022, and [Davon Person](https://www.linkedin.com/in/davon-person-1ba973194/) went through the Data Trail program in 2019, and now works as a Data Programming Specialist with the project. Jabir and Davon worked on solutions for the R for Data Science book, explored some Tidy Tuesday datasets, created their own Quarto websites, and their perspective helped us learn more about how our tools and documentation can better support emerging data scientists.

Jabir's primary project was to work on the [R for Data Science solutions](https://mine-cetinkaya-rundel.github.io/r4ds-solutions/). The R for Data Science, 2nd Edition was released in June 2023. In this edition there is a lot of new content, and revisions and additions to exercises. We saw that [Jeffrey Arnold's solutions to the 1st edition](https://jrnold.github.io/r4ds-exercise-solutions/) are such a useful resource for the community. This project aimed to both create a similar resource for 2nd edition and serve as an educational resource for the interns to help sharpen their tidyverse and general data science skills.

Some learning highlights for Jabir included faceting (as a solution to overplotting), consistent code styling (which helps make the code more pleasing to read), and, making maps! Specifically, Jabir mentioned that he has always wondered "how did they do that?!" with maps and found them to be quite intimidating, so it was especially satisfying to create his first heatmap of US states and chance of getting a tornado (<https://jabirghaffar.quarto.pub/jabir/posts/tornado_mapping_exploration>). This was not just a satisfying visualization exercise, but also a great opportunity to dig into unfamiliar data wrangling functions like [`recode()`](https://dplyr.tidyverse.org/reference/recode.html) for converting 2-letter state abbreviations to state names.

The exercises in R4DS range from quick, almost obvious, drills to ones that can really make you think and spin your wheels for a bit. One such exercise for Jabir was the one on changing the display of presidential terms from [Section 12.4.6](https://r4ds.hadley.nz/communication.html#exercises-2). The exercise asks:

> Change the display of the presidential terms by:
>
> -   Combining the two variants that customize colors and x axis breaks.
> -   Improving the display of the y axis.
> -   Labelling each term with the name of the president.
> -   Adding informative plot labels.
> -   Placing breaks every 4 years (this is trickier than it seems!).

The starting points for the exercise are the following plots from the text:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://tidyverse.tidyverse.org'>tidyverse</a></span><span class='o'>)</span></span>
<span></span>
<span><span class='nv'>presidential</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/mutate.html'>mutate</a></span><span class='o'>(</span>id <span class='o'>=</span> <span class='m'>33</span> <span class='o'>+</span> <span class='nf'><a href='https://dplyr.tidyverse.org/reference/row_number.html'>row_number</a></span><span class='o'>(</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggplot.html'>ggplot</a></span><span class='o'>(</span><span class='nf'><a href='https://ggplot2.tidyverse.org/reference/aes.html'>aes</a></span><span class='o'>(</span>x <span class='o'>=</span> <span class='nv'>start</span>, y <span class='o'>=</span> <span class='nv'>id</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/geom_point.html'>geom_point</a></span><span class='o'>(</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/geom_segment.html'>geom_segment</a></span><span class='o'>(</span><span class='nf'><a href='https://ggplot2.tidyverse.org/reference/aes.html'>aes</a></span><span class='o'>(</span>xend <span class='o'>=</span> <span class='nv'>end</span>, yend <span class='o'>=</span> <span class='nv'>id</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/scale_date.html'>scale_x_date</a></span><span class='o'>(</span>name <span class='o'>=</span> <span class='kc'>NULL</span>, breaks <span class='o'>=</span> <span class='nv'>presidential</span><span class='o'>$</span><span class='nv'>start</span>, date_labels <span class='o'>=</span> <span class='s'>"'%y"</span><span class='o'>)</span></span>
<span></span>
<span><span class='nv'>presidential</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/mutate.html'>mutate</a></span><span class='o'>(</span>id <span class='o'>=</span> <span class='m'>33</span> <span class='o'>+</span> <span class='nf'><a href='https://dplyr.tidyverse.org/reference/row_number.html'>row_number</a></span><span class='o'>(</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggplot.html'>ggplot</a></span><span class='o'>(</span><span class='nf'><a href='https://ggplot2.tidyverse.org/reference/aes.html'>aes</a></span><span class='o'>(</span>x <span class='o'>=</span> <span class='nv'>start</span>, y <span class='o'>=</span> <span class='nv'>id</span>, color <span class='o'>=</span> <span class='nv'>party</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/geom_point.html'>geom_point</a></span><span class='o'>(</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/geom_segment.html'>geom_segment</a></span><span class='o'>(</span><span class='nf'><a href='https://ggplot2.tidyverse.org/reference/aes.html'>aes</a></span><span class='o'>(</span>xend <span class='o'>=</span> <span class='nv'>end</span>, yend <span class='o'>=</span> <span class='nv'>id</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/scale_manual.html'>scale_color_manual</a></span><span class='o'>(</span>values <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span>Republican <span class='o'>=</span> <span class='s'>"#E81B23"</span>, Democratic <span class='o'>=</span> <span class='s'>"#00AEF3"</span><span class='o'>)</span><span class='o'>)</span></span>
</code></pre>
<img src="figs/presidential-terms-start-1.png" width="50%" style="display: block; margin: auto;" /><img src="figs/presidential-terms-start-2.png" width="50%" style="display: block; margin: auto;" />

</div>

Jabir says "This question completely puzzled me. I'd say good luck, and if you're new and you get to this question, I recommend you look at the solution manual."

The first challenge was identifying where in the text the original plot was developed, and the code associated with it. And then, the most challenging part of this exercise was labeling the y-axis with the names of presidents. It took lots of Googling, but ultimately Jabir used suggestions from ChatGPT to get this over the finish line. And, perhaps, the frustrating and satisfying part is that the answer was pretty obvious in hindsight:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>presidential</span> <span class='o'>&lt;-</span> <span class='nv'>presidential</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/mutate.html'>mutate</a></span><span class='o'>(</span>id <span class='o'>=</span> <span class='m'>33</span> <span class='o'>+</span> <span class='nf'><a href='https://dplyr.tidyverse.org/reference/row_number.html'>row_number</a></span><span class='o'>(</span><span class='o'>)</span><span class='o'>)</span></span>
<span></span>
<span><span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggplot.html'>ggplot</a></span><span class='o'>(</span><span class='nv'>presidential</span>, <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/aes.html'>aes</a></span><span class='o'>(</span>x <span class='o'>=</span> <span class='nv'>start</span>, y <span class='o'>=</span> <span class='nv'>id</span>, color <span class='o'>=</span> <span class='nv'>party</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/geom_point.html'>geom_point</a></span><span class='o'>(</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/geom_segment.html'>geom_segment</a></span><span class='o'>(</span><span class='nf'><a href='https://ggplot2.tidyverse.org/reference/aes.html'>aes</a></span><span class='o'>(</span>xend <span class='o'>=</span> <span class='nv'>end</span>, yend <span class='o'>=</span> <span class='nv'>id</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/scale_manual.html'>scale_color_manual</a></span><span class='o'>(</span>values <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span>Republican <span class='o'>=</span> <span class='s'>"#E81B23"</span>, Democratic <span class='o'>=</span> <span class='s'>"#00AEF3"</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/scale_date.html'>scale_x_date</a></span><span class='o'>(</span></span>
<span>    name <span class='o'>=</span> <span class='s'>"Term"</span>,</span>
<span>    breaks <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/seq.html'>seq</a></span><span class='o'>(</span>from <span class='o'>=</span> <span class='nf'><a href='https://lubridate.tidyverse.org/reference/ymd.html'>ymd</a></span><span class='o'>(</span><span class='s'>"1953-01-20"</span><span class='o'>)</span>, to <span class='o'>=</span> <span class='nf'><a href='https://lubridate.tidyverse.org/reference/ymd.html'>ymd</a></span><span class='o'>(</span><span class='s'>"2021-01-20"</span><span class='o'>)</span>, by <span class='o'>=</span> <span class='s'>"4 years"</span><span class='o'>)</span>,</span>
<span>    date_labels <span class='o'>=</span> <span class='s'>"'%y"</span></span>
<span>  <span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/scale_continuous.html'>scale_y_continuous</a></span><span class='o'>(</span></span>
<span>    name <span class='o'>=</span> <span class='s'>"President"</span>,</span>
<span>    breaks <span class='o'>=</span> <span class='m'>34</span><span class='o'>:</span><span class='m'>45</span>,</span>
<span>    labels <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/paste.html'>paste0</a></span><span class='o'>(</span><span class='nv'>presidential</span><span class='o'>$</span><span class='nv'>name</span>, <span class='s'>" ("</span>, <span class='nv'>presidential</span><span class='o'>$</span><span class='nv'>id</span>, <span class='s'>")"</span><span class='o'>)</span></span>
<span>  <span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/theme.html'>theme</a></span><span class='o'>(</span></span>
<span>    panel.grid.minor <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>element_blank</a></span><span class='o'>(</span><span class='o'>)</span>,</span>
<span>    axis.ticks.y <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>element_blank</a></span><span class='o'>(</span><span class='o'>)</span></span>
<span>  <span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/theme.html'>theme</a></span><span class='o'>(</span></span>
<span>    panel.grid.minor <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>element_blank</a></span><span class='o'>(</span><span class='o'>)</span>,</span>
<span>    axis.ticks.y <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>element_blank</a></span><span class='o'>(</span><span class='o'>)</span></span>
<span>  <span class='o'>)</span> <span class='o'>+</span></span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/labs.html'>labs</a></span><span class='o'>(</span></span>
<span>    x <span class='o'>=</span> <span class='s'>"Term"</span>,</span>
<span>    y <span class='o'>=</span> <span class='s'>"President"</span>,</span>
<span>    title <span class='o'>=</span> <span class='s'>"Terms of US Presidents"</span>,</span>
<span>    subtitle <span class='o'>=</span> <span class='s'>"Eisenhower (34th) to Trump (45th)"</span>,</span>
<span>    color <span class='o'>=</span> <span class='s'>"Party"</span></span>
<span>  <span class='o'>)</span></span>
</code></pre>
<img src="figs/presidential-terms-end-1.png" width="700px" style="display: block; margin: auto;" />

</div>

Jabir felt like moments when he knew what to do and how to answer each question were very satisfying, but the moments where he felt stuck and went into rabbit holes looking for answers made him question whether he wanted to continue becoming a data scientist. Ultimately, though, the project was enjoyable, and not just a great learning experience for Jabir, but also a very meaningful one because it created a resource that can help future data scientists.

We felt like Jabir and Davon advanced their data science skills throughout the project, and their familiarity with working on an open source project. It was particularly exciting to see Jabir create his own data science portfolio as a Quarto website with posts on the Tidy Tuesday datasets. We really appreciated his work on the R4DS Solutions. In going through those, he helped better refine the book, and created a resource that so many people are going to be able to use and learn from. We could see how he learned not just data science, but also grew as a leader who will continue to support others in their learning as he moves on to work as a developer with the Data Trail program. Davon too not just focused on data science, but was a part of our team, and the Data Trail team, providing mentorship to Jabir and bringing teaching approaches, like using Tidy Tuesday datasets, to his community. We are so grateful to have had the opportunity to work with them both, and see this as the beginning of continued collaborations and hopefully contributions in open source.

Just like most open-source projects, the [R4DS Solutions](https://mine-cetinkaya-rundel.github.io/r4ds-solutions/) is a living and breathing project, still a work-in-progress. We would welcome any community contributions! All perspectives are important here, and it's a great project if you're a first-time contributor.

