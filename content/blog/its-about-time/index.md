---
output: hugodown::hugo_document

slug: its-about-time
title: "It's about time"
date: 2022-09-28
author: Mara Averick
description: >
    Davis Vaughan's talk from rstudio::conf(2022) on clock, an R package that aims to provide
    comprehensive and safe handling of date-times.

photo:
  url: https://www.pexels.com/photo/collection-of-retro-wall-clocks-in-antique-store-2168241/
  author: Teddy Yang

# one of: "deep-dive", "learn", "package", "programming", "roundup", or "other"
categories: [learn] 
tags: [clock, r-lib]
rmd_hash: 8a4ef0744c5377b8

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
* [ ] Add intro sentence, e.g. the standard tagline for the package
* [ ] [`usethis::use_tidy_thanks()`](https://usethis.r-lib.org/reference/use_tidy_thanks.html)
-->

At rstudio::conf(2022), Davis Vaughan gave a lightning talk on [clock](https://clock.r-lib.org/), an R package that aims to provide comprehensive and safe handling of date-times. clock goes beyond the date and date-time types that base R provides, implementing new types for year-month, year-quarter, ISO year-week, and many other date-like formats, all with up to nanosecond precision.

In Davis' talk, you'll see how clock emphasizes "safety first" when manipulating date-times, and how its new date-time types can be used in your own work.

<script src="https://fast.wistia.com/embed/medias/pzuyostdz8.jsonp" async></script>
<script src="https://fast.wistia.com/assets/external/E-v1.js" async></script>

<div class="wistia_responsive_padding" style="padding:56.25% 0 0 0;position:relative;">

<div class="wistia_responsive_wrapper" style="height:100%;left:0;position:absolute;top:0;width:100%;">

<div class="wistia_embed wistia_async_pzuyostdz8 videoFoam=true" style="height:100%;position:relative;width:100%">

<div class="wistia_swatch" style="height:100%;left:0;opacity:0;overflow:hidden;position:absolute;top:0;transition:opacity 200ms;width:100%;">

<img src="https://fast.wistia.com/embed/medias/pzuyostdz8/swatch" style="filter:blur(5px);height:100%;object-fit:contain;width:100%;" alt="" aria-hidden="true" onload="this.parentNode.style.opacity=1;" />

</div>

</div>

</div>

</div>

<details>
<summary>
<strong>Transcript</strong>
</summary>

I am here to talk about time, which is obviously everyone's favorite subject. In particular, I'm actually here to talk about a package called clock.

So, clock is a date time manipulation library kind of in the same way that lubridate is a date time manipulation library. It does things you might expect add dates, subtract dates, format and parse them. All kinds of other manipulation. If you get anything out of this talk, it's really that clock is not here to replace lubridate in any way. The only idea would be that in the end clock might be a back end for lubridate in the same way that dtplyr or dbplyr are different types of back ends for dplyr. And I'm not even going to spend the rest of this talk talking about features that overlap with lubridate.

Instead, I want to talk about things that are pretty unique to clock. One of those is safety. And one of those is calendars.

Because I only have 5 minutes, I'm going to do that with one date, January 30th of this year. Safety is built into clock from the ground up to hopefully avoid issues like this, time zone issues, invalid date issues, things that are pretty common when you're working with time series and just drive you up the wall.

So let's jump into safety. Here's a timeline. This is January 30th, our date in question marked in blue on our timeline. It continues through to February. On the next line, you'll see this gap between February and March because February only has 28 days, but January had 31, so it doesn't necessarily map 1 to 1. If I were to ask you this seemingly innocuous question. Please add one month to this date. What would you get?

Well, if we were to ask lubridate, it gives you a somewhat reasonable answer of NA. There is nothing that maps 1 to 1 from January 30th to something in February, maybe. And there's nothing particularly wrong with this except for the fact that it's not the most useful answer. Generally, you'll be running this code and it happens silently. And then five steps downstream. All of a sudden, you discover there's some NAs here. Like, I didn't have those to begin with. Where did those come from? And you have to backtrack up through your calculations and figure out why they appeared.

If you were to ask clock this question with add months, it actually gives you an error in this special case by default. It says, whoa, hold up. There's something wrong here. Go look at location 1. If you had a vector, it might be location five, seven, whatever. And check out the invalid argument to learn more about this case. You go and you look at the documentation and you come out with the idea that maybe I could set this thing called invalid equals previous. That allows you to say, give me the previous valid date when I have this kind of problem. That's the end of February. I think that's a pretty reasonable result in this case. But you also might want to say, depending on your specific problem, invalid equals next to map forward to the beginning of March instead. If you actually do like that lubridate behavior, that's fine. You can say invalid equals NA any time that occurs, you'll get an NA instead. So that's about safety.

Let's talk about calendars. Calendars are just the idea of a way to represent a unique point in time. With our date in question, we could use a calendar called year month day to represent this date using three components the year, the month, and the day of the month. But this isn't the only way you could represent this date. You could also use the year and the day of the year, or you could use one of these many other calendar types that are built into clock.

If your finance person, you might be particularly interested in year quarter day, which uses a true fiscal year to represent your date. These are really nice because they're all convertible to each other. You can work with any particular calendar type and say you need to get the quarter out. You convert to year quarter day, you do manipulation over there, you convert back. It's obviously convertible with the date in POSIXct as well, since those are the date time types that you're most likely to start out with.

The other really neat thing that I find really fun about these calendar types is that they have what's known as variable precision. These are all day precision calendar types at this point, but we could narrow that down to month precision as needed. And you've got a built-in year month type in clock. Similarly, you could have a built-in year quarter type. You can actually go the other way, too. You can widen it out all the way to nanoseconds if you need it.

The last thing I'll say is that clock is completely compatible with some of the other packages you might be familiar with that I've created called slider and IVs. Slider is one for rolling averages, so you can use clock types as the index to say, give me a rolling average. looking back four or five quarters IVs is a relatively new package. You might not have heard of this one yet, but it deals with date ranges and you can use clock types as the components of those ranges.

So to sum up, lubridate is not going anywhere. Don't worry, but please try clock for enhanced safety in these powerful new types. Thank you.
</details>

## Try clock

To try clock out, you can install the released version from [CRAN](https://cran.r-project.org/) with:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://rdrr.io/r/utils/install.packages.html'>install.packages</a></span><span class='o'>(</span><span class='s'>"clock"</span><span class='o'>)</span></span></code></pre>

</div>

Or, install the development version from its [GitHub repo](https://github.com/r-lib/clock) with:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='c'># install.packages("remotes")</span></span>
<span><span class='nf'>remotes</span><span class='nf'>::</span><span class='nf'><a href='https://remotes.r-lib.org/reference/install_github.html'>install_github</a></span><span class='o'>(</span><span class='s'>"r-lib/clock"</span><span class='o'>)</span></span></code></pre>

</div>

## Learn more

You can learn more about clock by reading Davis' blog post announcing its first release, [Comprehensive date-time handling for R](https://www.tidyverse.org/blog/2021/03/clock-0-1-0/). Also be sure to check out its vignettes:

-   [Getting started](https://clock.r-lib.org/articles/clock.html)

-   [Motivations for clock](https://clock.r-lib.org/articles/articles/motivations.html)

-   [Examples and recipes](https://clock.r-lib.org/articles/recipes.html)

-   [Frequently asked questions](https://clock.r-lib.org/articles/faq.html)

