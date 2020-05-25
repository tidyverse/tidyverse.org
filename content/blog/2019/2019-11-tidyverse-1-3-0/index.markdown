---
title: tidyverse 1.3.0
author: Mara Averick
date: '2019-11-22'
slug: tidyverse-1-3-0
description: > 
  tidyverse 1.3.0 is on CRAN, and has a paper in the Journal of Open Source Software! This should make it easier to cite tidyverse packages.
categories:
  - package
tags:
  - tidyverse
photo:
  url: https://unsplash.com/photos/TIrXot28Znc
  author: Juskteez Vu
---

<html>
<style>
.footnote-ref {
    vertical-align: baseline;
    position: relative;
    top: -0.4em;
    font-size: smaller;
}
</style>
</html>




We're thrilled to announce that [tidyverse](https://tidyverse.tidyverse.org/) 1.3.0 is now on CRAN. 
The tidyverse is a set of packages that work in harmony because they share common data representations and API design. 
The tidyverse package is a "meta" package designed to make it easy to install and load core packages from the tidyverse in a single command. 
This is great for teaching and interactive use, but for package development purposes we recommend that authors import only the specific packages that
they use.
For a complete list of changes, please see the [release notes](https://tidyverse.tidyverse.org/news/index.html#tidyverse-1-3-0).

You can install the latest version of tidyverse with:


```r
install.packages("tidyverse")
```

And, as always, attach the package by running:


```r
library(tidyverse)
```

## Citing the tidyverse

The most significant update in this version is a new vignette, ["Welcome to the Tidyverse"](https://tidyverse.tidyverse.org/articles/paper.html), which is a mirror of the recently-released paper of the same name in the [Journal of Open Source Software](https://joss.theoj.org/papers/10.21105/joss.01686). 
The (long) list of authors includes all members of the tidyverse organisation and its component packages, and is now the canonical way to cite tidyverse packages.

### When to cite the tidyverse

If you're in a position where you can easily cite every package that materially contributed to your analysis, you should totally do it. 
But it is often hard because many packages don't have accompanying papers, and many journals still haven't got the memo that software is an important research artifact.
Alternatively, you may be publishing in a venue with very tight page constraints
and you simply don't have the room to cite every package. 
For a more comprehensive discussion of best practices regarding citing software, see [Software Citation Principles](https://www.force11.org/software-citation-principles) by Arfon Smith, Daniel Katz, Kyle Niemeyer, and The FORCE11 Software Citation Working Group.[^force11]

We generally recommend citing the tidyverse paper instead of citing individual packages. 
This is less work, making it more likely that people will do it, and helps concentrate the citations across the whole tidyverse into a single place, which makes it easier to show the academic merit of our work. 
Of course, you're still free to cite individual tidyverse packages if you feel like they have been particularly important for your analysis, but you shouldn't feel obliged.

### How to cite the tidyverse

The R [`citation()`](https://stat.ethz.ch/R-manual/R-devel/library/utils/html/citation.html) function makes it easy to cite R and R packages in publications.
The latest version of the tidyverse package has the citation built in: 


```r
citation("tidyverse")
#> 
#>   Wickham et al., (2019). Welcome to the tidyverse. Journal of Open
#>   Source Software, 4(43), 1686, https://doi.org/10.21105/joss.01686
#> 
#> A BibTeX entry for LaTeX users is
#> 
#>   @Article{,
#>     title = {Welcome to the {tidyverse}},
#>     author = {Hadley Wickham and Mara Averick and Jennifer Bryan and Winston Chang and Lucy D'Agostino McGowan and Romain François and Garrett Grolemund and Alex Hayes and Lionel Henry and Jim Hester and Max Kuhn and Thomas Lin Pedersen and Evan Miller and Stephan Milton Bache and Kirill Müller and Jeroen Ooms and David Robinson and Dana Paige Seidel and Vitalie Spinu and Kohske Takahashi and Davis Vaughan and Claus Wilke and Kara Woo and Hiroaki Yutani},
#>     year = {2019},
#>     journal = {Journal of Open Source Software},
#>     volume = {4},
#>     number = {43},
#>     pages = {1686},
#>     doi = {10.21105/joss.01686},
#>   }
```

Since the tidyverse wouldn't be possible without R, we strongly recommend that you also cite R:


```r
citation()
#> 
#> To cite R in publications use:
#> 
#>   R Core Team (2019). R: A language and environment for statistical
#>   computing. R Foundation for Statistical Computing, Vienna, Austria.
#>   URL https://www.R-project.org/.
#> 
#> A BibTeX entry for LaTeX users is
#> 
#>   @Manual{,
#>     title = {R: A Language and Environment for Statistical Computing},
#>     author = {{R Core Team}},
#>     organization = {R Foundation for Statistical Computing},
#>     address = {Vienna, Austria},
#>     year = {2019},
#>     url = {https://www.R-project.org/},
#>   }
#> 
#> We have invested a lot of time and effort in creating R, please cite it
#> when using it for data analysis. See also 'citation("pkgname")' for
#> citing R packages.
```

## Acknowledgments

A huge thank you to the paper's reviewers, [Laura DeCicco](https://github.com/ldecicco-USGS) and [Jeff Hanson](https://github.com/jeffreyhanson), and journal editor, [Karthik Ram](https://github.com/karthik), who improved the quality of the paper immensely.

We're also grateful to the 89 people who contributed to this release: [&#x0040;andrewheiss](https://github.com/andrewheiss), [&#x0040;arcole](https://github.com/arcole), [&#x0040;arfon](https://github.com/arfon), [&#x0040;Armos05](https://github.com/Armos05), [&#x0040;arne1921KF](https://github.com/arne1921KF), [&#x0040;batpigandme](https://github.com/batpigandme), [&#x0040;BenoitLondon](https://github.com/BenoitLondon), [&#x0040;bschneidr](https://github.com/bschneidr), [&#x0040;cawoodjm](https://github.com/cawoodjm), [&#x0040;christa88](https://github.com/christa88), [&#x0040;coatless](https://github.com/coatless), [&#x0040;cryptic0](https://github.com/cryptic0), [&#x0040;cwickham](https://github.com/cwickham), [&#x0040;d8aninja](https://github.com/d8aninja), [&#x0040;daltonhance](https://github.com/daltonhance), [&#x0040;dan-reznik](https://github.com/dan-reznik), [&#x0040;danhalligan](https://github.com/danhalligan), [&#x0040;DataXujing](https://github.com/DataXujing), [&#x0040;DavoOZ](https://github.com/DavoOZ), [&#x0040;dchiu911](https://github.com/dchiu911), [&#x0040;dhslone](https://github.com/dhslone), [&#x0040;Fredo-XVII](https://github.com/Fredo-XVII), [&#x0040;gaborcsardi](https://github.com/gaborcsardi), [&#x0040;genewch](https://github.com/genewch), [&#x0040;grayskripko](https://github.com/grayskripko), [&#x0040;gvwilson](https://github.com/gvwilson), [&#x0040;gwd999](https://github.com/gwd999), [&#x0040;hadley](https://github.com/hadley), [&#x0040;hammer](https://github.com/hammer), [&#x0040;harrismcgehee](https://github.com/harrismcgehee), [&#x0040;ijlyttle](https://github.com/ijlyttle), [&#x0040;jennybc](https://github.com/jennybc), [&#x0040;jeroen](https://github.com/jeroen), [&#x0040;jflynn264](https://github.com/jflynn264), [&#x0040;jimhester](https://github.com/jimhester), [&#x0040;jnolis](https://github.com/jnolis), [&#x0040;JoeFernando](https://github.com/JoeFernando), [&#x0040;JoFAM](https://github.com/JoFAM), [&#x0040;jonocarroll](https://github.com/jonocarroll), [&#x0040;josegonzalez](https://github.com/josegonzalez), [&#x0040;jrosen48](https://github.com/jrosen48), [&#x0040;jtelleria](https://github.com/jtelleria), [&#x0040;jzadra](https://github.com/jzadra), [&#x0040;karawoo](https://github.com/karawoo), [&#x0040;karthik](https://github.com/karthik), [&#x0040;kent37](https://github.com/kent37), [&#x0040;kevinushey](https://github.com/kevinushey), [&#x0040;kevinykuo](https://github.com/kevinykuo), [&#x0040;krlmlr](https://github.com/krlmlr), [&#x0040;ljmills](https://github.com/ljmills), [&#x0040;malcolmbarrett](https://github.com/malcolmbarrett), [&#x0040;maptracker](https://github.com/maptracker), [&#x0040;martinamorris](https://github.com/martinamorris), [&#x0040;martinjhnhadley](https://github.com/martinjhnhadley), [&#x0040;MartinMSPedersen](https://github.com/MartinMSPedersen), [&#x0040;mattsgithub](https://github.com/mattsgithub), [&#x0040;maurolepore](https://github.com/maurolepore), [&#x0040;mfherman](https://github.com/mfherman), [&#x0040;mgsosna](https://github.com/mgsosna), [&#x0040;mikeyEcology](https://github.com/mikeyEcology), [&#x0040;mloop](https://github.com/mloop), [&#x0040;moodymudskipper](https://github.com/moodymudskipper), [&#x0040;msberends](https://github.com/msberends), [&#x0040;njtierney](https://github.com/njtierney), [&#x0040;osmelmillan](https://github.com/osmelmillan), [&#x0040;pgensler](https://github.com/pgensler), [&#x0040;PoGibas](https://github.com/PoGibas), [&#x0040;psychelzh](https://github.com/psychelzh), [&#x0040;rkalescky](https://github.com/rkalescky), [&#x0040;rmcd1024](https://github.com/rmcd1024), [&#x0040;romainfrancois](https://github.com/romainfrancois), [&#x0040;rsheppar](https://github.com/rsheppar), [&#x0040;sampath2510](https://github.com/sampath2510), [&#x0040;Selvamjn](https://github.com/Selvamjn), [&#x0040;SinfantiHU](https://github.com/SinfantiHU), [&#x0040;steenharsted](https://github.com/steenharsted), [&#x0040;stefvanbuuren](https://github.com/stefvanbuuren), [&#x0040;steveharoz](https://github.com/steveharoz), [&#x0040;sulgik](https://github.com/sulgik), [&#x0040;talban14](https://github.com/talban14), [&#x0040;thanosgatos](https://github.com/thanosgatos), [&#x0040;tmalsburg](https://github.com/tmalsburg), [&#x0040;toouggy](https://github.com/toouggy), [&#x0040;topepo](https://github.com/topepo), [&#x0040;tsufz](https://github.com/tsufz), [&#x0040;willbowditch](https://github.com/willbowditch), [&#x0040;XiangyunHuang](https://github.com/XiangyunHuang), [&#x0040;yatharth](https://github.com/yatharth), and [&#x0040;yutannihilation](https://github.com/yutannihilation).


[^force11]: Smith AM, Katz DS, Niemeyer KE, FORCE11 Software Citation Working Group. (2016) Software Citation Principles. _PeerJ Computer Science_ 2:e86. doi: [10.7717/peerj-cs.86](https://doi.org/10.7717/peerj-cs.86).
