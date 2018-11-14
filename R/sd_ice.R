#' Function to calculate mean of standard deviation of ICE curves
#'
#'ICE-based variable importance measure: mean of standard deviation of ICE curves
#' @param ice_data ice calculations for a specific variable(output of ice_cal)
#' @param variable name of the interested feature
#' @param classlabelvec vector of names corresponds to classlabels
#' @param subrw number of rows in the subset of the data frame we use to calculate ice curves in ice_cal function
#' @param grid.resolution gridresolution size used in ice_cal function
#' @return a dataframe including corresponding probability for each class
#' @importFrom magrittr %>%
#' @author Thiyanga Talagala
#' @export
meansd_ice <- function(ice_data, variable, classlabelvec, subrw, grid.resolution){
  require("dplyr")
  data$individual <- rep(1:subrw, grid.resolution)
  sd_ice <- data %>%
    group_by(individual) %>%
    summarise_at(vars(classlabelvec),
                 funs(sd(., na.rm=TRUE)))
  apply(sd_ice[,-1], 2, mean, na.rm = TRUE)

}

#' @example
#' data(iris)
#' rf <- randomForest::randomForest(Species ~ ., data=iris)
#' iris_sub <- iris[147:150, -5]
#' # without trimming outliers
#' icdf <- ice_cal(rf, Sepal.Width, iris, iris_sub, grid.resolution=2, trim.outliers=FALSE)
#' meansd_ice(icdf, "Sepal.Width", c("setosa", "versicolor", "virginica"), subrw=4, grid.resolution=2)
#'
