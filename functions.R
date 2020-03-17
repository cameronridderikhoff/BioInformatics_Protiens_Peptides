# Most of this code is from Proteus, and has been modified for Dr. Glen Ulrig at the University of Alberta by Cameron Ridderikhoff
simple_theme <- ggplot2::theme_bw() +
  ggplot2::theme(
    panel.border = ggplot2::element_blank(),
    panel.grid.major = ggplot2::element_blank(),
    panel.grid.minor = ggplot2::element_blank(),
    axis.line = ggplot2::element_line(colour = "black")
  )
simple_theme_grid <- ggplot2::theme_bw() +
  ggplot2::theme(
    panel.border = ggplot2::element_blank(),
    panel.grid.major = ggplot2::element_line(colour = "grey90"),
    panel.grid.minor = ggplot2::element_line(colour = "grey95"),
    axis.line = ggplot2::element_line(colour = "black")
  )
cbPalette <- c("#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")

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


#'Volcano plot
#'
#'\code{plotVolcano} makes a volcano plot from limma results. Uses
#'\code{\link{stat_binhex}} function from ggplot2 to make a hexagonal heatmap.
#'
#'@param res Result table from  \code{\link{limmaDE}}.
#'@param bins Number of bins for binhex.
#'@param xmax Upper limit on x-axis. If used, the lower limit is -xmax.
#'@param ymax Upper limit on y-axis. If used, the lower limit is -ymax.
#'@param marginal.histograms A logical to add marginal histograms.
#'@param text.size Text size.
#'@param show.legend Logical to show legend (colour key).
#'@param plot.grid Logical to plot grid.
#'@param binhex Logical. If TRUE, a hexagonal density plot is made, otherwise it
#'  is a simple point plot.
#'
#' @return A \code{ggplot} object.
#'
#' @examples
#' library(proteusLabelFree)
#' data(proteusLabelFree)
#' prodat.med <- normalizeData(prodat)
#' res <- limmaDE(prodat.med)
#' plotVolcano(res)
#'
#'@export
plotVolcano_pvalue <- function(res, bins=80, xmax=NULL, ymax=NULL, marginal.histograms=FALSE, text.size=12, show.legend=TRUE,
                        plot.grid=TRUE, binhex=TRUE, pval = 0, pval_type = "unadjusted") {
  if(binhex & marginal.histograms) {
    warning("Cannot plot with both binhex=TRUE and marginal.histograms=TRUE. Ignoring binhex.")
    binhex=FALSE
  }

  tr <- attr(res, "transform.fun")
  conds <- attr(res, "conditions")
  xlab <- ifelse(is.null(tr), "FC", paste(tr, "FC"))
  tit <- paste(conds, collapse=":")
  id <- names(res)[1]
  

  if (pval_type == "unadjusted") {
    #select the top 10 results and label them separately
    #top10 <- res[order(-res$P.Value), ] 
    #top10 <- top10[1:10,] #change this number if you want to have more than the top ten be labeled
    g <- ggplot(res, aes_(~logFC, ~-log10(P.Value)))#, label = rownames(top10)
  }
  else if (pval_type == "adjusted") {
    #select the top 10 results and label them separately
    #top10 <- res[order(-res$adj.P.Value), ]
    #top10 <- top10[1:10,] #change this number if you want to have more than the top ten be labeled
    g <- ggplot(res, aes_(~logFC, ~-log10(adj.P.Val)))
  }
  else
    stop("Incorrect p-value type. Possible values: adjusted, unadjusted")
  
  if(binhex) {
    g <- g + stat_binhex(bins=bins, show.legend=show.legend, na.rm=TRUE) +
      viridis::scale_fill_viridis(name="count", na.value=NA)
    #scale_fill_gradientn(colours=c("seagreen","yellow", "red"), name = "count", na.value=NA)
  } else {
    g <- g + geom_point(na.rm=TRUE)
  }
  
  if(plot.grid) {
    g <- g + simple_theme_grid
  } else {
    g <- g + simple_theme
  }
  
  #Added by Cameron
  if (pval != 0) {
    g <- g + geom_hline(yintercept = exp(pval), linetype = "dashed")
  }
  #End added by Cameron
  g <- g + geom_vline(colour='red', xintercept=0) +
    theme(text = element_text(size=text.size)) +
    labs(x=xlab, y="-log10 P", title=tit)
  
  
  if(!is.null(xmax)) g <- g + scale_x_continuous(limits = c(-xmax, xmax), expand = c(0, 0))
  if(!is.null(ymax) ) g <- g + scale_y_continuous(limits = c(0, ymax), expand = c(0, 0))
  
  if(marginal.histograms) g <- ggExtra::ggMarginal(g, size=10, type = "histogram", xparams=list(bins=100), yparams=list(bins=50))
  return(g)
}
