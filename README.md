
<!-- README.md is generated from README.Rmd. Please edit that file -->
explainer
=========

[![Build Status](https://travis-ci.org/thiyangt/explainer.svg?branch=master)](https://travis-ci.org/thiyangt/explainer)

Installation
------------

``` r
# install.packages("devtools")
devtools::install_github("thiyangt/explainer")
library(explainer)
```

Usage
-----

### Number of times each variable appear in each tree in the forest (`forest_info`).

``` r
library(randomForest)
library(explainer)
set.seed(2018)
forest <- randomForest(Species ~ ., data = iris, ntree=50)
forest_details <- forest_info(forest, 50)
table_count_treeLevel <- lapply(forest_details,function(temp){as.data.frame(table(temp))})
table_count_treeLevel[1:2] ## show results corresponds to first two trees
#> [[1]]
#>           temp Freq
#> 1 Petal.Length    2
#> 2  Petal.Width    4
#> 3 Sepal.Length    2
#> 4  Sepal.Width    1
#> 
#> [[2]]
#>           temp Freq
#> 1 Petal.Length    3
#> 2  Petal.Width    2
#> 3 Sepal.Length    1
```

### Total number of times each variable appear in the forest

``` r
library(data.table)
full_forestLevel <- rbindlist(table_count_treeLevel, use.names=TRUE)
fullforest <- split(full_forestLevel, full_forestLevel$temp)
variable_freq <- sapply(fullforest , function(temp){sum(temp$Freq)})
variable_freq 
#> Petal.Length  Petal.Width Sepal.Length  Sepal.Width 
#>          137          136           87           61
variable_percent <- variable_freq/sum(variable_freq)*100
variable_percent
#> Petal.Length  Petal.Width Sepal.Length  Sepal.Width 
#>     32.54157     32.30404     20.66508     14.48931
```

Two-way partial dependency plots
--------------------------------

Create two-way partial dependency plots based on **subset of training data** used to train the random forest: `twowayinteraction`.

``` r
subset_iris <- iris[1:20, -5]
SL_PW_interaction <- twowayinteraction(forest, Sepal.Length, Petal.Width, iris, iris, grid.resolution=10)
head(SL_PW_interaction)
#> # A tibble: 6 x 9
#>   Sepal.Length Petal.Width Sepal.Width Petal.Length Species    id setosa
#>          <dbl>       <dbl>       <dbl>        <dbl> <fct>   <int>  <dbl>
#> 1          4.3         0.1         3.5          1.4 setosa      1      1
#> 2          4.3         0.1         3            1.4 setosa      2      1
#> 3          4.3         0.1         3.2          1.3 setosa      3      1
#> 4          4.3         0.1         3.1          1.5 setosa      4      1
#> 5          4.3         0.1         3.6          1.4 setosa      5      1
#> 6          4.3         0.1         3.9          1.7 setosa      6      1
#> # ... with 2 more variables: versicolor <dbl>, virginica <dbl>
```

Graphical representation of **SL\_PW\_interaction**

``` r
library(ggplot2)
#> 
#> Attaching package: 'ggplot2'
#> The following object is masked from 'package:randomForest':
#> 
#>     margin
p1 <-  ggplot(
  data = SL_PW_interaction, aes_string(x = SL_PW_interaction$Sepal.Length,y = SL_PW_interaction$Petal.Width, z = SL_PW_interaction$setosa, fill = SL_PW_interaction$setosa
  ))+geom_tile() + 
  scale_fill_viridis_c(limits = c(0, 1), breaks = seq(0, 1, 100),option = "A", direction = -1)+
  xlab("Sepal Length") + ylab("Petal Width") + theme(legend.position="none", aspect.ratio=1)+ggtitle("setosa")

p2 <-  ggplot(
  data = SL_PW_interaction, aes_string(x = SL_PW_interaction$Sepal.Length,y = SL_PW_interaction$Petal.Width, z = SL_PW_interaction$versicolor, fill = SL_PW_interaction$versicolor
  ))+geom_tile() + 
  scale_fill_viridis_c(limits = c(0, 1), breaks = seq(0, 1, 100),option = "A", direction = -1)+
  xlab("Sepal Length") + ylab("Petal Width") + theme(legend.position="none", aspect.ratio=1)+ggtitle("versicolor")

p3 <-  ggplot(
  data = SL_PW_interaction, aes_string(x = SL_PW_interaction$Sepal.Length,y = SL_PW_interaction$Petal.Width, z = SL_PW_interaction$virginica, fill = SL_PW_interaction$virginica
  ))+geom_tile() + 
  scale_fill_viridis_c(limits = c(0, 1), breaks = seq(0, 1, 100),option = "A", direction = -1)+
  xlab("Sepal Length") + ylab("Petal Width") + theme(legend.position="none", aspect.ratio=1)+ggtitle("virginica")

gridExtra::grid.arrange(p1, p2, p3, ncol=3)
```

<img src="man/figures/README-unnamed-chunk-5-1.png" width="100%" />
