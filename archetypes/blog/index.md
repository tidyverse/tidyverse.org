---
title: ''
description: >
    A 2-3 sentence description of the post that appears on the articles page.
date: {{ dateFormat "2006-01" .Date }}
author: Hadley Wickham
# Featured photo
photo:
  url: https://unsplash.com/photos/n6vS3xlnsCc
  author: Mara
# one of: "case studies", "learn", "package", "programming", or "other"
categories: [Other] 
---


```{r setup, include = FALSE}
library(testthat) # add / replace as needed
knitr::opts_chunk$set(
  collapse = TRUE, comment = "#>", 
  fig.width = 7, 
  fig.align = 'center',
  fig.asp = 0.618, # 1 / phi
  out.width = "700px"
)
```
