---
title: ''
description: >
    A 2-3 sentence description of the post that appears on the articles page.
date: {{ .Date }}
author: Hadley Wickham
# Featured photo
photo:
  url: https://unsplash.com/photos/n6vS3xlnsCc
  author: Kelley Bozarth
# one of: "case studies", "learn", "package", "programming", or "other"
categories: [Other] 
---

<!--
Images:

+ place a square image with the string "sq" in the filename.

+ place a wide image with the string "wd" in the filename.
-->

```{r setup, include = FALSE}
knitr::opts_chunk$set(
  collapse = TRUE, 
  comment = "#>", 
  fig.width = 7, 
  fig.align = 'center',
  fig.asp = 0.618, # 1 / phi
  out.width = "700px",
  fig.path = "figs/"
)
```

```{r packages}
library(testthat) # add / replace as needed
```


