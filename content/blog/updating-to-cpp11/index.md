---
output: hugodown::hugo_document

slug: updating-to-cpp11
title: Pathway to success - updating your package to cpp11
date: 2021-09-10
author: Shelby Bearrows
description: >
    The cpp11 summer intern reviews the process they used to convert readxl to using 
    cpp11.

photo:
  url: https://unsplash.com/photos/9MMd2uRpfvc
  author: John Salzarulo

# one of: "deep-dive", "learn", "package", "programming", or "other"
categories: [learn] 
tags: [cpp11, internship]
rmd_hash: ad94599f1f50e21c


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
* [ ] [`usethis::use_tidy_thanks()`](https://usethis.r-lib.org/reference/use_tidy_thanks.html)
-->

Over the summer I had the pleasure of working with Jim Hester on the [cpp11 package](https://cpp11.r-lib.org/) as a tidyverse summer intern. The cpp11 package is a header-only R package that helps R package developers handle R objects with C++ code. Its goals and syntax are similar to the excellent Rcpp package. During most of my internship, I worked on triaging issues, fixing bugs, and adding new features to cpp11. Near the end of the summer, I got to work with Jenny Bryan on converting the [readxl](https://github.com/tidyverse/readxl/pull/659) package from using Rcpp to using cpp11. Jim has written a [great post](https://cpp11.r-lib.org/articles/converting.html) about converting packages from Rcpp to cpp11, which I heavily referenced during the process. But there were still some challenges I encountered. To help others going through a similar process, I wanted to review the workflows and tools we used to make this easier.

To get started, I followed the initial set-up steps outlined in Jim's article and then recompiled, to confirm it was successful. Next, I needed to include either the `cpp11/R.hpp` header or the macros `R_NO_REMAP` and `STRICT_R_HEADERS`. I found it easier to include the macros since the header file needs to come before any headers that use Rcpp.

## Step-by-step integration

After I'd set-up my environment it was time to start converting the files. Initially, I made the mistake of selecting the most interconnected file in the readxl package. Since this file was central to the package, I would have had to convert the entire package over to cpp11 before the compilation errors would stop. After Jenny and Jim helped me select a more approachable file, the process was more incremental and I successfully maintained my sanity 🙌.

After I finished converting a file, I recompiled, ran the tests for the readxl package and fixed any compilation errors or test failures. Sometimes I had to edit other functions in other files, but I only edited files enough to fix the failures. If I did too much it was difficult for me to know what was causing the test failures. Another incremental approach I used was to convert one function in a file, and then rerun the tests. This approach worked best for larger files. Once the tests were passing, I'd commit and push to the PR so that my gracious reviewers could review my changes. This helped me maintain continuous integration and also helped my mentors review my code in stages, rather than in one, big batch. It's a win-win!

## The nitty-gritty

For the nitty-gritty details of converting the code, I definitely took advantage of [the table in Jim's post](https://cpp11.r-lib.org/articles/converting.html#class-comparison-table-1)! That comparison table is great for converting between Rcpp and cpp11 classes. Also, I had to keep track of whether an object was writable or readable. This new feature in cpp11 is great, since writable vectors are costly because the data must be fully copied, so using readable where appropriate is a good idea. When I was unsure of whether an object should be readable or writable, I would make it readable and then recompile to see if I was correct.

## Almost done

<<<<<<< HEAD
Then, when I converted all the objects to cpp11, I removed any stray `#include "Rcpp.h"` directives and ran `devtools::check()` to check for any other updates that might be required, such as in the DESCRIPTION file. And that's it!
=======
Then, when I converted all the objects to cpp11, I removed any stray #include "Rcpp.h" directives and ran devtools::check() to check for any other updates that might be required, like in the DESCRIPTION files. And that's it!
>>>>>>> 2a8dd80f6405657c0656789f0a771948f59732cc

I had so much fun working with the tidyverse team. And a big thank you to Jim for all the support over the summer and to Jenny for their help on readxl! If you're looking for more examples of updating packages to using cpp11, Jim has also gone through the process with [readr](https://github.com/tidyverse/readr/pull/1109). RStudio is a great place to look for summer internship opportunities. They had a variety of opportunities this summer and I'd encourage anyone looking for summer internships to apply for 2022!

