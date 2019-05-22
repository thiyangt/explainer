#' Fiedman's H-Statistic calculations
#'
#' Given two features calculate Friedman's H-Statistic between two features
#' @param model name of the fitted randomforest model
#' @param fulldf full data set used to fit the random forest
#' @param subsetdf subset dataset used to evaluate the fitted model
#' @param allfeatures vector of names of all features
#' @param trimfeatures vector of names of features that need to trim
#' @param classnames vector of names of class names
#' @param grid.resolution number of levels to be considered in the interested features
#' @return data frame containing features and pedicted probabilities
#' @importFrom magrittr %>%
#' @author Thiyanga Talagala
#' @export
friedmanHstat <- function(model, fulldf, subsetdf, allfeatures,trimfeatures, grid.resolution, classnames){

## main effect calculations
maineffectsforallfeatures <- lapply(allfeatures, function(temp){
  x <- fulldf[,temp]

  if (temp %in% trimfeatures){
    trim.outliers==TRUE
  } else {trim.outliers==FALSE}

  # trim outliars
  if(trim.outliers==TRUE){
    out <- grDevices::boxplot.stats(x, do.out = TRUE)$out
    x <- x[!(x %in% out)]
  }

  # Create a list containing the values of interest for each of the predictor
  seqx <- seq(from = min(x, na.rm = TRUE), to = max(x, na.rm = TRUE),
              length = grid.resolution)

  # split the other predictors
  xc <- dplyr::select(subsetdf, -!!temp)

  # Create grid based on feature space
  grid.pred <- tidyr::crossing(seqx, xc)
  colnames(grid.pred)[1] <- paste(temp)
  predicted <- data.frame(stats::predict(model, grid.pred, type="prob"))
  grid.pred$id <- 1:dim(grid.pred)[1]
  predicted$id <- 1:dim(grid.pred)[1]
  mainfull <- dplyr::left_join(grid.pred, predicted)

  pdpx <- mainfull %>% group_by_(temp) %>% summarise_at(
    .vars = vars(classnames),
    .funs = c(mean="mean"))
  return(pdpx)

})
names(maineffectsforallfeatures) <- allfeatures
## End of main effect calculations -----


## Two-way interaction effects calculations and
## Friedman's H-statistic calculations
friedmanHstat <- lapply(allfeatures, function(tempx){
  ## creating x variable specifications
  x <- fulldf[,tempx]
  if (tempx %in% trimfeatures){
    trim1 = TRUE
  } else {trim1 = FALSE}

  if(trim1==TRUE){
    outx <- grDevices::boxplot.stats(x, do.out = TRUE)$out
    x <- x[!(x %in% outx)]
  }
  # Create a list containing the values of interest for each of the predictor
  seqx <- seq(from = min(x, na.rm = TRUE), to = max(x, na.rm = TRUE),
              length = grid.resolution)

  # Creating y vaiable(s*) specifications
  ynames <- allfeatures[!allfeatures %in% tempx]

  twointerac <- lapply(ynames, function(tempy){
    y <- fulldf[,tempy]
    if (tempy %in% trimfeatures){
      trim2 = TRUE
    } else {trim2 = FALSE}

    if(trim2==TRUE){
      outy <- grDevices::boxplot.stats(y, do.out = TRUE)$out
      y <- y[!(y %in% outy)]
    }

    # Create a list containing the values of interest for each of the predictor
    seqy <- seq(from = min(y, na.rm = TRUE), to = max(y, na.rm = TRUE),
                length = grid.resolution)
    # grid of selected variables
    xs <- tidyr::crossing(seqx, seqy)

    # split the other predictors
    xc <- dplyr::select(subsetdf, -!!c(tempx, tempy))

    # Create grid based on feature space
    grid.pred <- tidyr::crossing(xs, xc)
    colnames(grid.pred)[1] <- paste(tempx)
    colnames(grid.pred)[2] <- paste(tempy)
    predicted <- data.frame(predict(model, grid.pred, type="prob"))
    grid.pred$id <- 1:dim(grid.pred)[1]
    predicted$id <- 1:dim(grid.pred)[1]
    twofull <- dplyr::left_join(grid.pred, predicted)
    #twofull

    ## end of two-way interactions calculations
    ## mean main effect x
    # mainx <- maineffectsforallfeatures[[tempx]]
    # pdpx <- mainx %>% group_by_(tempx) %>% summarise_at(
    #   .vars = vars(classnames),
    #   .funs = c(mean="mean"))
    #
    # ## mean main effect y
    # mainy <- maineffectsforallfeatures[[tempy]]
    # pdpy <- mainy %>% group_by_(tempy) %>% summarise_at(
    #   .vars = vars(classnames),
    #   .funs = c(mean="mean"))

    ## mean two-way interaction effect
    # twoxy <- twofull %>% group_by_(tempx, tempy) %>% summarise_at(
    #   .vars = vars(classnames),
    #   .funs = c(mean="mean"))

    mainx <- maineffectsforallfeatures[[tempx]]
    mainy <- maineffectsforallfeatures[[tempy]]
    full1 <- merge(twofull, mainx, tempx, all = T)
    full <- merge(full1,mainy, tempy, all=T)
    indexxy <- which(colnames(twofull) %in% classnames==TRUE)
    two_xy <- data.frame(scale(full[,indexxy], center = TRUE, scale=FALSE))
    main_x <- data.frame(scale(full[,indexxy+length(classnames)], center = TRUE, scale = FALSE))
    main_y <- data.frame(scale(full[, indexxy+(2*length(classnames))], center = TRUE, scale=FALSE))

    top <- (two_xy-(main_x+main_y))^2
    bottom <- two_xy^2
    friedman <- round(colSums(top)/colSums(bottom),2)
   # friedman

  })
  names(twointerac) <- ynames
  twointerac
})

names(friedmanHstat) <- allfeatures

return(friedmanHstat)

}
#' @example
#'data(iris)
#'rf <- randomForest::randomForest(Species ~ ., data=iris)
#' subsetdf <- iris[1:2, -5]
#' model <- rf
#' fulldf <- iris
#' allfeatures <- c("Sepal.Length","Petal.Width", "Sepal.Width", "Petal.Length")
#' grid.resolution <- 2
#' trimfeatures <- c("Petal.Width")
#' trim.outliers <- FALSE
#' classnames <- c("setosa", "versicolor", "virginica")
#' friedmanHstat(rf, fulldf, subsetdf,
#'              allfeatures,
#'              trimfeatures,2, c("setosa", "versicolor", "virginica"))

