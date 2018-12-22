
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
