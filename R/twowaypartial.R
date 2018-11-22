#' Two-way interaction plots
#'
#' Given two features create partial two way interaction contourplots
#' @param model name of the fitted randomforest model
#' @param variable1 name of the first variable
#' @param variable2 name of the second variable
#' @param fulldf full data set used to fit the random forest
#' @param subsetdf subset dataset used to evaluate the fitted model
#' @param grid.resolution number of levels to be considered in the interested features
#' @param trim1 if TRUE remove outliers of the first variable
#' @param trim2 if TRUE remove outliers of the second variable
#' @return data frame containing features and pedicted probabilities
#' @importFrom magrittr %>%
#' @author Thiyanga Talagala
#' @export
twowayinteraction <- function(model, variable1, variable2, fulldf, subsetdf, grid.resolution = 10,trim1=FALSE, trim2=FALSE){
  # trim outliars
  # variable 1
  x <- eval(substitute(variable1), fulldf)
  if(trim1==TRUE){
  outx <- grDevices::boxplot.stats(x, do.out = TRUE)$out
  x <- x[!(x %in% outx)]
  }

  # variable 2
  y <- eval(substitute(variable2), fulldf)
  if(trim2==TRUE){
  outy <- grDevices::boxplot.stats(y, do.out = TRUE)$out
  y <- y[!(y %in% outy)]
  }

  # picking up the feature we are interested
  pars <- as.list(match.call()[-1])
  var1 <- as.character(pars$variable1)
  var2 <- as.character(pars$variable2)

  # Create a list containing the values of interest for each of the predictor
  seqx <- seq(from = min(x, na.rm = TRUE), to = max(x, na.rm = TRUE),
              length = grid.resolution)
  outx <- grDevices::boxplot.stats(x, do.out = TRUE)$out
  x1 <- x[!(x %in% outx)]
  minx1 <- min(x1, na.rm = TRUE)
  maxx1 <- max(x1, na.rm = TRUE)
  seqrmoutx <- seq(from = minx1, to = maxx1, length = grid.resolution)
  seqx.selected <- seqx[(seqx < minx1  & maxx1 < seqx)==TRUE]
  seq.x <- sort(c(seqx.selected, seqrmoutx))

  seqy <- seq(from = min(y, na.rm = TRUE), to = max(y, na.rm = TRUE),
              length = grid.resolution)
  outy <- grDevices::boxplot.stats(y, do.out = TRUE)$out
  y1 <- y[!(y %in% outy)]
  miny1 <- min(y1, na.rm = TRUE)
  maxy1 <- max(y1, na.rm = TRUE)
  seqrmouty <- seq(from = miny1, to = maxy1,length = grid.resolution)
  seqy.selected <- seqy[(seqy < miny1  & maxy1 < seqy)==TRUE]
  seq.y <- sort(c(seqy, seqrmouty))

  # grid of selected variables
  xs <- tidyr::crossing(seq.x, seq.y)

  # split the other predictors
  xc <- dplyr::select(subsetdf, -!!c(var1, var2))

  # Create grid based on feature space
  grid.pred <- tidyr::crossing(xs, xc)
  colnames(grid.pred)[1] <- paste(pars$variable1)
  colnames(grid.pred)[2] <- paste(pars$variable2)
  predicted <- data.frame(predict(model, grid.pred, type="prob"))
  grid.pred$id <- 1:dim(grid.pred)[1]
  predicted$id <- 1:dim(grid.pred)[1]
  full <- dplyr::left_join(grid.pred, predicted)
  return(full)

}
#' @example
#'data(iris)
#'rf <- randomForest::randomForest(Species ~ ., data=iris)
#'iris <- iris[1:2, -5]
#'a <- twowayinteraction(rf, Sepal.Length, Sepal.Width, iris, iris, grid.resolution=2)


