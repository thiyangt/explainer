#' Function to calculate standard deviation of partial dependence curves
#'
#'PDP-based variable importance measure: standard deviation of partial dependence curves
#'@param icedata ice calculations for a specific variable(output of icecal)
#'@param variable name of the interested feature
#'@param classlabelvec vector of names corresponds to classlabels
#'@return a dataframe including corresponding probability for each class
#'@importFrom magrittr %>%
#'@importFrom dplyr group_by_
#'@importFrom dplyr summarise_at
#'@author Thiyanga Talagala
#'@export
sd_pdp <- function(icedata, variable, classlabelvec){
  sd_var <- icedata %>%
    group_by_(variable) %>%
    summarise_at(vars(classlabelvec),
                 funs(mean(., na.rm=TRUE)))
  apply(sd_var[,-1], 2, sd, na.rm = TRUE)

}
#'@example
#'data(iris)
#'rf <- randomForest::randomForest(Species ~ ., data=iris)
#'iris_sub <- iris[147:150, -5]
#'# without trimming outliers
#'icdf <- ice_cal(rf, Sepal.Width, iris, iris_sub, grid.resolution=2, trim.outliers=FALSE)
#'sd_pdp(icdf, "Sepal.Width", c("setosa", "versicolor", "virginica"))
#'
