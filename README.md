
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

``` r
library(randomForest)
set.seed(2018)
forest <- randomForest(Species ~ ., data = iris, ntree=50)
table_count <- lapply(yearly_forest_info,function(temp){as.data.frame(table(temp))})
table_count
```
