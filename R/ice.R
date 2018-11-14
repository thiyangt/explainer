#' Function to calculate Individual Conditional Expectation (ICE) plots
#'
#'Function to create partial dependence plots given features and the training set
#' @param model name of the randomForest model
#' @param variable name of the interested feature
#' @param fulldf full data set used to fit the random forest
#' @param subsetdf subset of the dataset use to compute ice
#' @param grid.resolution number of levels to be considered in the interested feature
#' @param trim.outliers if TRUE range for the grid.resolution is computed trimming the outliers
#' @return a dataframe including corresponding probability for each class
#' @author Thiyanga Talagala
#' @export
ice_cal <- function(model, variable, fulldf, subsetdf, grid.resolution = 10, trim.outliers=FALSE){

  x <- eval(substitute(variable), fulldf)
  # trim outliars
  if(trim.outliers==TRUE){
  out <- grDevices::boxplot.stats(x, do.out = TRUE)$out
  x <- x[!(x %in% out)]
  }
  # picking up the feature we are interested
  pars <- as.list(match.call()[-1])
  var <- as.character(pars$variable)

  # picking up the feature we are interested
  pars <- as.list(match.call()[-1])
  var <- as.character(pars$variable)

  # Create a list containing the values of interest for each of the predictor
  seqx <- seq(from = min(x, na.rm = TRUE), to = max(x, na.rm = TRUE),
              length = grid.resolution)

  # split the other predictors
  xc <- select(subsetdf, -!!var)

  # Create grid based on feature space
  grid.pred <- crossing(seqx, xc)
  colnames(grid.pred)[1] <- paste(pars$variable)
  predicted <- data.frame(predict(model, grid.pred, type="prob"))
  grid.pred$id <- 1:dim(grid.pred)[1]
  predicted$id <- 1:dim(grid.pred)[1]
  full <- left_join(grid.pred, predicted)
  return(full)

}
#' @example
#' data(iris)
#' rf <- randomForest::randomForest(Species ~ ., data=iris)
#' iris_sub <- iris[147:150, -5]
#' # without trimming outliers
#' ice_cal(rf, Sepal.Width, iris, iris_sub, grid.resolution=2, trim.outliers=FALSE)
#' # trim outliers
#' ice_cal(rf, Sepal.Width, iris, iris_sub, grid.resolution=2, trim.outliers=TRUE)
#'
