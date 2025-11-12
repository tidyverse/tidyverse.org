---
output: hugodown::hugo_document

slug: python-open-source-developer
title: Python Open-Source Developer
date: 2025-11-12
author: Max Kuhn
description: >
    Posit is hiring a Python open-source developer to create more data analysis tools.

photo:
  author: Dan Kuhn and Max Kuhn. The subject is Doodle Ramen Noodle.

# one of: "deep-dive", "learn", "package", "programming", "roundup", or "other"
categories: [other] 
tags: [python, modeling]
---

We are hiring a Python open-source developer with a specialization in data analysis and modeling tools. Since deep learning models already have extensive support in Python, our focus is on the analysis and modeling of _tabular data_. Our primary goal is to develop packages that enhance the existing capabilities of frameworks such as scikit-learn. We are hiring a software developer to focus on creating new programming APIs to help users facilitate their data analysis and modeling tasks. Note that the current position doesn't involve building or publishing models created here; _this is a pure package developer role_. 

We think that the tidymodels philosophy can enhance modeling in Python, and we believe that learning more about modeling in Python will provide us with ideas on how to improve tidymodels. To clarify, we are not creating a tidymodels Python package; however, some of its APIs may be beneficial to Python users. Two examples are [recipes](https://recipes.tidymodels.org/) and broom's [tidy and augment](https://broom.tidymodels.org/) verbs. 

There are numerous ways that individuals can contribute to improving the Python ecosystem. We have a lot of ideas, but we also want to know what our new hire believes is most important. A sample of potential projects that have been on our mind:

- Grid search for model tuning has a fairly bad reputation for being inefficient. However, space-filling designs (SFDs) are excellent tools for making small tuning grids that methodically cover the entire parameter space. Users would benefit from having an integrated tool that can create grids from their pipelines using optimal SFDs. 

- There are occasions where we might decline to produce a prediction, perhaps due to our prediction data being extrapolations from the training set. _Applicability Domain_ methods measure extrapolation and can help determine where the model's predictions are likely to be poor. An API that can take a model object and the training set could generate a score that informs users when their predictions are ~~hallucinated~~ unlikely to be accurate. 

- Python deserves an original (Python-only) implementation of the popular [glmnet model](https://scholar.google.com/scholar?hl=en&as_sdt=0%2C7&q=Regularization+Paths+for+Generalized+Linear+Models+via+Coordinate+Descent&btnG=). There are Python libraries that wrap the original Fortran code; however, this approach isn't easily supported, nor is it able to facilitate the numerous extensions of this particular model (e.g., [group-wise penalties](https://scholar.google.com/scholar?hl=en&as_sdt=0%2C7&q=%22A+sparse-group+lasso%22&btnG=), [MCP](https://scholar.google.com/scholar?hl=en&as_sdt=0%2C7&q=%22Nearly+unbiased+variable+selection+under+minimax+concave+penalty%22&btnG=) penalties, etc). This would be a substantial and in-depth project. 

We have about a dozen other project ideas. 

Open-source software developers at Posit often have a broader role than just writing and testing code. We are often the folks defining what is deemed important and prioritizing our work. Additionally, we frequently undertake tasks that are typically considered part of developer relations, such as reaching out to the community, creating additional technical content, speaking at conferences, and teaching workshops. If you are a driven and independent developer, you might be interested in this position. You'll have a lot of agency here and in an environment that encourages quality. Our developers tend to feel a personal stake in our work and want it to be as good as it can be. We're a completely remote team, flexible in terms of how and when we work, and we do a good job of minimizing administrative overhead for engineers.

**To learn more about the position and to apply, visit the [Careers page](https://posit.co/job-detail/?gh_jid=7510613003).**
