#' Function to extract tree information in the forest
#'
#' Function to extract tree information in the forest
#' @param model name of the randomForest model
#' @param ntree number of trees in the forest
#' @return retun a list of variable information corresponds to each tree
#' @author Thiyanga Talagala
#' @export
forest_info <- function(model, ntree){
index <- 1:ntree
lapply(index, function(temp){
  info <- randomForest::getTree(model, temp, labelVar=TRUE)[,"split var"]
  info <-  info[!is.na(info)]
  })
}
#' @example
#' library(randomForest)
#' set.seed(2018)
#' forest <- randomForest(Species ~ ., data = iris, ntree=2)
#' forest_info(forest, 2)

