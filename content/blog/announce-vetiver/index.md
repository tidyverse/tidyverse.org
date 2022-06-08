---
output: hugodown::hugo_document

slug: announce-vetiver
title: Announcing vetiver for MLOps in R and Python
date: 2022-06-09
author: Julia Silge
description: >
  We are thrilled to announce the release of vetiver, a framework for MLOps 
  tasks in R and Python. Use vetiver to version, share, deploy, and monitor a 
  trained model.

photo:
  url: https://unsplash.com/photos/3C5ZfCLSGC4
  author: "21 swan"


# one of: "deep-dive", "learn", "package", "programming", "roundup", or "other"
categories: [package] 
tags: [tidymodels, vetiver]
---

<!--
TODO:
* [ ] Look over / edit the post's title in the yaml
* [ ] Edit (or delete) the description; note this appears in the Twitter card
* [ ] Pick category and tags (see existing with `hugodown::tidy_show_meta()`)
* [ ] Find photo & update yaml metadata
* [ ] Create `thumbnail-sq.jpg`; height and width should be equal
* [ ] Create `thumbnail-wd.jpg`; width should be >5x height
* [ ] `hugodown::use_tidy_thumbnails()`
* [ ] Add intro sentence, e.g. the standard tagline for the package
* [ ] `usethis::use_tidy_thanks()`
-->




We are thrilled to announce the release of [vetiver](https://vetiver.rstudio.com/), a framework for MLOps tasks in R and Python! The goal of vetiver is to provide fluent tooling to **version**, **share**, **deploy**, and **monitor** a trained model. If you like perfume or candles, you may recognize this ingredient; vetiver, also known as the "oil of tranquility", is used as a stabilizing ingredient in perfumery to preserve more volatile fragrances.

You can install the released version of vetiver for R from [CRAN](https://cran.r-project.org/package=vetiver):

```r
install.packages("vetiver")
```

You can install the released version of vetiver for Python from [PyPI](https://pypi.org/project/vetiver/):

```python
pip install vetiver
```

We are sharing more about what vetiver is and how it works over [on the RStudio blog](https://www.rstudio.com/blog/announce-vetiver/) so check that out, but we want to share here as well!

## Train a model

For this example, let’s work with data on everyone's favorite dataset on fuel efficiency for cars to predict miles per gallon. In R, we can train a decision tree model to predict miles per gallon using a [tidymodels](https://www.tidymodels.org/) workflow:


```r
library(tidymodels)

car_mod <-
    workflow(mpg ~ ., decision_tree(mode = "regression")) %>%
    fit(mtcars)
```

In Python, we can train the same kind of model using [scikit-learn](https://scikit-learn.org/):


```python
from vetiver.data import mtcars
from sklearn import tree
car_mod = tree.DecisionTreeRegressor().fit(mtcars, mtcars["mpg"])
```

For both R and Python, the `car_mod` object is a fitted model, with parameters estimated using our training data `mtcars`.


## Create a vetiver model

We can create a `vetiver_model()` in R or `VetiverModel()` in Python from the trained model; a vetiver model object collects the information needed to store, version, and deploy a trained model.


```r
library(vetiver)
v <- vetiver_model(car_mod, "cars_mpg")
v
#> 
#> ── cars_mpg ─ <butchered_workflow> model for deployment 
#> A rpart regression modeling workflow using 10 features
```


```python
from vetiver import VetiverModel
v = VetiverModel(car_mod, model_name = "cars_mpg", 
                 save_ptype = True, ptype_data = mtcars)
v.description
#> "Scikit-learn <class 'sklearn.tree._classes.DecisionTreeRegressor'> model"
```


See our documentation for how to use these deployable model objects and:

- [publish and version your model](https://vetiver.rstudio.com/get-started/version.html)
- [deploy your model as a REST API](https://vetiver.rstudio.com/get-started/deploy.html)


Be sure to also read more [on the RStudio blog](https://www.rstudio.com/blog/announce-vetiver/).

## Acknowledgements

We'd like to extend our thanks to all of the contributors who helped make these initial releases of vetiver for R and Python possible!

- R package: [&#x0040;cderv](https://github.com/cderv), [&#x0040;ggpinto](https://github.com/ggpinto), [&#x0040;isabelizimm](https://github.com/isabelizimm), [&#x0040;juliasilge](https://github.com/juliasilge), and [&#x0040;mfansler](https://github.com/mfansler)

- Python package: [&#x0040;has2k1](https://github.com/has2k1), and [&#x0040;isabelizimm](https://github.com/isabelizimm)

