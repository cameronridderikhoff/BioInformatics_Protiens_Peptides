# Most of this code is from Proteus, and has been modified for Dr. Glen Ulrig at the University of Alberta by Cameron Ridderikhoff

#' Simple differential expression with limma
#'
#' \code{limmaDE} is a wrapper around \code{\link{limma}} to perform a
#' differential expression between a pair of conditions.
#'
#' @details
#'
#' Before \code{limma} is called, intensity data are transformed using the
#' \code{transform.fun} function. The default for this transformation is
#' \code{log2}. Therefore, by default, the column "logFC" in the output data
#' frame contains log2 fold change. If you need log10-based fold change, you can
#' use \code{transform.fun=log10}.
#'
#' \code{limmaDE} is only a simple wrapper around \code{\link{limma}}, to
#' perform differential expression between two conditions. For more complicated
#' designs we recommend using \code{\link{limma}} functions directly.
#'
#'
#' @param pdat Protein \code{proteusData} object.
#' @param formula A string with a formula for building the linear model.
#' @param conditions A character vector with two conditions for differential
#'   expression. Can be omitted if there are only two condition in \code{pdat}.
#' @param transform.fun A function to transform data before differential
#'   expression.
#' @param sig.level Significance level for rejecting the null hypothesis.
#' @param limma_adjust The adjust function used by limma. Possible values: "none", "BH", "BY", "holm"
#' @return A data frame with DE results. "logFC" column is a log-fold-change
#'   (using the \code{transform.fun}). Two columns with mean log-intensity
#'   (again, using \code{transform.fun}) and two columns with the number of good
#'   replicates (per condition) are added. Attributes contain additional
#'   information about the transformation function, significance level, formula
#'   and conditions.
#'
#' @examples
#' library(proteusLabelFree)
#' data(proteusLabelFree)
#' prodat.med <- normalizeData(prodat)
#' res <- limmaDE(prodat.med)
#'
#' @export
limmaDE_adjust <- function(pdat, formula="~condition", conditions=NULL, transform.fun=log2, sig.level=0.05, limma_adjust = "BH") {
  if(!is(pdat, "proteusData")) stop ("Input data must be of class proteusData.")
  
  meta <- pdat$metadata
  tab <- transform.fun(pdat$tab)
  
  # default conditions
  if(!is.null(conditions)) {
    for(cond in conditions ) {
      if(!(cond %in% meta$condition)) stop(paste("Condition", cond, "not found in metadata."))
    }
    sel <- which(meta$condition %in% conditions)
    meta <- droplevels(meta[sel,])
    tab <- tab[,sel]
  } else {
    conditions <- levels(meta$condition)
  }
  
  if(length(conditions) != 2) stop("This function requires exactly two conditions. Use the parameter conditions.")
  
  # ensure the limma_adjust parameter is valid
  if(!(limma_adjust == "none" | limma_adjust == "BH" | limma_adjust == "BY" | limma_adjust == "holm"))
     stop("Incorrect limma adjust function. Possible values: none, BH, BY, holm")
  
  # limma analysis
  design <- model.matrix(as.formula(formula), meta)
  fit <- limma::lmFit(tab, design)
  ebay <- limma::eBayes(fit)
  coef <- colnames(ebay$design)[2]
  res <- limma::topTable(ebay, coef=coef, adjust=limma_adjust, sort.by="none", number=1e9)
  res <- cbind(rownames(res), res)
  colnames(res)[1] <- pdat$content
  res$significant <- res$adj.P.Val <= sig.level
  rownames(res) <- c()
  
  # add columns with mean intensity
  for(cond in conditions) {
    cname <- paste0("mean_", cond)
    m <- rowMeans(tab[,which(meta$condition == cond), drop=FALSE], na.rm=TRUE)
    m[which(is.nan(m))] <- NA
    res[, cname] <- m
  }
  
  # add columns with number of good replicates
  ngood <- reshape2::dcast(pdat$stats, id ~ condition, fun.aggregate=sum, value.var="ngood")
  ngood <- ngood[, c("id", conditions)]
  names(ngood)[2:ncol(ngood)] <- paste0("ngood_", names(ngood)[2:ncol(ngood)])
  res <- merge(res, ngood, by.x=pdat$content, by.y="id")
  
  # add annotations
  if(!is.null(pdat$annotation)) {
    res <- merge(res, pdat$annotation, by=pdat$content, all.x=TRUE)
  }
  
  attr(res, "transform.fun") <- deparse(substitute(transform.fun))
  attr(res, "sig.level") <- sig.level
  attr(res, "formula") <- formula
  attr(res, "conditions") <- levels(meta$condition)
  
  return(res)
}
