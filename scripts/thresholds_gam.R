
#' Find Thresholds Using Threshold GAMs
#'
#' Estimate the optimal index of a single threshold
#' GAM using minimised generalised cross-validation.
#' @param data A data.frame containing all variables referenced in `formula`
#' and `thresh.var`.
#' @param formula A formula object representing the desired model.
#' If `thresh.var` is the only explanatory variable,
#' use `formula(y ~ 1)`.
#' @param thresh.var The target variable to introduce thresholds around.
#' @param expl.var The variable split in to thresholds by `thresh.var`.
#' If is \code{NULL}, is assumed to be \code{thresh.var}.
#' @param thresh.range Numeric vector of length 2. The quantiles of
#' \code{"expl.var"} to threshold between.
#' #' @param by Numeric. The increment to step along `thresh.var`
#' when introducing thresholds.
#' #' @param k Numeric. The number of knots for the treshold smooth.
#' Knot value for other variables can be specified in the `formula`
#' argument.
#' @return a list with ranked threshold variable values, a
#' threshold factor vector for final GAM fitting, the
#' ranked GCV scores, and the model formula.
#' @keywords internal
#'
#'
find_threshold <- function(data, formula, thresh.var, expl.var = NULL , thresh.range = c(0.1,0.9),by = 1, k = -1){

  if(is.null(expl.var)){
    formula.tmp <- update.formula(formula, paste("~ . + threshold + s(",thresh.var,", bs='tp',k=",k,",by=threshold) -1"))
    #add threshold factor (pre vs post) to allow different intercepts, and vary slope of thresh.var via the by argument.
    #-1 is required to remove shared intercept
  }else{
    formula.tmp <- update.formula(formula, paste("~ . + threshold + s(",expl.var,", bs='tp',k=",k,",by=threshold) -1"))
  }

  round_digits <- data[[thresh.var]][2]
  if (abs(round_digits - round(round_digits)) > .Machine$double.eps^0.5) {
    digs <- nchar(strsplit(sub('0+$', '', as.character(round_digits)), ".", fixed = TRUE)[[1]][[2]])
  }else{
    digs <-0
  } #for non-integer sequences, digits need to be specified for quartile rounding

  thresh.values<-round(seq(quantile(data[[thresh.var]],thresh.range[1]),
                           quantile(data[[thresh.var]],thresh.range[2]),by=by),digits = digs)#create range of threshold dates (sequence increasing from 20% to 80% of thresh.var length)

  gcv.thresh<-thresh.values*NA

  for(jj in 1:length(thresh.values)){
    data$threshold <- factor(ifelse(data[[thresh.var]]<thresh.values[jj],'pre','post'), levels = c("pre","post"))

    gam.test <- mgcv::gam(formula.tmp, data = data,
                          family = gaussian(), method = "REML")
    gcv.thresh[jj] <-  gam.test$gcv.ubre #loop model fitting over sequence of thresholds and measure fit by gcv
  }

  threshold<-thresh.values[order(gcv.thresh)]
  thresh.fac<-factor(ifelse(data[[thresh.var]]<thresh.values[order(gcv.thresh)][1],'pre','post'), levels = c("pre","post")) #define threshold factor based upon best fitting thresh.value

  return(list("thresh_val" = threshold,"thresh_factor" = thresh.fac, "thresh_gcv" = cbind("thresh.val" = thresh.values,"thresh.gcv" = gcv.thresh), "thresh_formula" = formula(gam.test)))
}

#' Compare GCV Threshold GAMs
#'
#' Estimate the optimal index of a single threshold
#' GAM using minimised generalised cross-validation.
#' @param data A data.frame containing all variables referenced in `formula`
#' and `thresh.var`.
#' @param cont_formula A formula object representing the desired continuous model.
#' @param thresh_formula A formula object representing the desired threshold model.
#' If `thresh.var` is the only explanatory variable,
#' use `formula(y ~ 1)`.
#' @param thresh.var The target variable to introduce thresholds around.
#' @param expl.var The variable split in to thresholds by `thresh.var`.
#' If is \code{NULL}, is assumed to be \code{thresh.var}.
#' @param thresh.range Numeric vector of length 2. The quantiles of
#' \code{"expl.var"} to threshold between.
#' @param by Numeric. The increment to step along `thresh.var`
#' when introducing thresholds.
#' @param k Numeric. The number of knots for the threshold smooth.
#' Knot value for other variables can be specified in the `formula`
#' argument.
#' @return a list containing three objects: \code{cont} (model object, of
#' the continuous gam), \code{thresh} (model object, of the threshold
#' gam), and \code{best} (ranked GCV scores for the two model types).
#'
#'
compare_gam <- function(data, cont_formula, thresh_formula, thresh.var, expl.var = NULL, thresh.range = c(0.1,0.9), by = 1, k = -1){
  library(magrittr)
  cont_gam <- mgcv::gam(cont_formula, data = data,
                        family = gaussian(), method = "REML") #fit continuous gam

  cont <- list(mod = cont_gam, summary = summary(cont_gam), method = "continuous", gcv = cont_gam$gcv.ubre, threshold = NA,"thresh_var" = data[[thresh.var]])

  if(is.null(expl.var)){
    expl.var.lab <- paste0("s(",thresh.var,")",collapse = "")
  }else{
    expl.var.lab <- paste0("s(",expl.var,")",collapse = "")
  }

  if(cont$summary$s.table[rownames(cont$summary$s.table) == expl.var.lab,4] < 0.5 &&
     cont$summary$s.table[rownames(cont$summary$s.table) == expl.var.lab,1] >=1.0){ #if smooth close to significant (p<0.1) and non-linear (>1 edf) trend, fit threshold gam

    found_thresh <- find_threshold(data = data, formula = thresh_formula, thresh.var = thresh.var, expl.var = expl.var, thresh.range = thresh.range, by = by, k = k)
    data$threshold <- found_thresh$thresh_factor #identify optimal threshold

    thresh_gam <- mgcv::gam(found_thresh$thresh_formula, #fit threshold gam
                            data = data,
                            family = gaussian(), method = "REML")

    thresh <- list(mod = thresh_gam, summary = summary(thresh_gam), method = "threshold", "gcv" = thresh_gam$gcv.ubre, "threshold" = found_thresh$thresh_val[1], "thresh_gcv" = found_thresh$thresh_gcv,"thresh_var" = data[[thresh.var]])

  }else{
    thresh <- list(mod = NA, method = "threshold", gcv = Inf)
  }
  return(list("cont" = cont,
              "thresh" = thresh,
              "best" = data.frame("model" = c("cont","thresh"), "gcv" = c(cont$gcv,thresh$gcv))  %>% (\(x){x[order(x$gcv),]})()))
}



#' Predict Curves From Optimal GAM
#'
#' Takes a \code{compare_gam()} object and produces predictions given a new
#' set of values for the model covariates or the original values used to fit
#' the model. The best fit model between a continuous or threshold gam is
#' returned.
#' @param object A fitted gam comparison as produced by \code{compare_gam()}.
#' @param gcv_diff The necessary difference in gcv between models to reject the
#' null continuous gam.
#' @param new.data A data frame or list containing the values of the model covariates
#' at which predictions are required. If this is not provided then predictions
#' corresponding to the original data are returned.
#' @param exclude Extraneous terms not to be returned.
#' @return a dataframe of new.data, fitted values and confidence interval.
#'
#'
predict_best_gam <- function(object, gcv_diff = 6, new.data = NULL,exclude = NULL){

  if(abs(object$cont$gcv-object$thresh$gcv) <= gcv_diff){
    best <- 1
  }else{
    best <- which.min(c(object$cont$gcv,object$thresh$gcv))
  }

  best.mod <- object[[best]] #subset best model (continuous vs threshold based upon gcv)

  if(is.null(new.data)){
    new.data <- as.data.frame(best.mod$mod$model)  %>%
      dplyr::mutate(thresh.var = best.mod$thresh_var)

    if(!("threshold" %in% colnames(new.data))){
      new.data <- new.data %>%
        dplyr::mutate(threshold = NA)
    }
  }else{
    if(!any(grepl("threshold",colnames(new.data)))){
      stop("new.data must contain a threshold variable")
    }
    new.data <- new.data
  }
  new.data <- new.data %>%
    dplyr::mutate(transition = ifelse(threshold == "pre" & dplyr::lead(threshold) == "post",'trans',
                                      ifelse(threshold == "post" & dplyr::lag(threshold) == "pre",'trans',
                                             'no.trans')))
  pred <- predict(best.mod$mod, newdata = new.data, type = 'response', se.fit = TRUE,
                  exclude = exclude)

  return(cbind(new.data,"fit" = pred$fit, "ci" = pred$se.fit))

}
#
#
#
#
# threshold.gam <-
#   function (formula, #gam formula construction possible with smoother
#             data, #data.frame
#             threshold.name, # colname of threshold variable to test within data
#             nthd, #number of steps between lower & upper bound
#             a = 0.2, #probability for lower bound quantile, 0:1
#             b = 0.8, #probability for upper bound quantile, 0:1
#             ...) # additional argument to gam() for gam.res & res
#   {
#     require(mgcv)
#     this.envir <- environment()
#     threshold.variable <- eval(parse(text = paste("data", threshold.name,
#                                                   sep = "$")))
#     lower <- quantile(threshold.variable, prob = a, na.rm = TRUE)
#     upper <- quantile(threshold.variable, prob = b, na.rm = TRUE)
#     rv <- NULL
#     gcvv <- NULL
#     mgcv <- 1e+06 #start value for mgcv to be optimised
#     mr <- NA
#     for (r in seq(lower, upper, (upper - lower)/nthd)) {
#       data$r <- r
#       gam.res <- with(data, {
#         attach(data)
#         gam(formula, ...)
#       })
#       detach("data")
#       rv <- c(rv, r)
#       gcvv <- c(gcvv, gam.res$gcv.ubre)
#       if (gam.res$gcv.ubre < mgcv) {
#         mr <- r #update mr to hold current threshold position (r) if it improves (lowers) GCV
#         mgcv <- gam.res$gcv.ubre
#       }
#     }
#     data$r <- mr
#     res <- with(data, {
#       attach(data)
#       gam(formula, ...)
#     }) #rerun gam, gets returned invisibly, used to plot residual points & hist
#     detach("data")
#     class(res) <- c("tgam", "gam", "glm", "lm")
#     invisible(list(res = res, mr = mr, mgcv = mgcv, gcvv = gcvv[order(rv)],
#                    rv = sort(rv)))
#   }
#
# threshold.gam.cv<-
#   function (response.name, data, ...)
#   {
#     data <- na.omit(data)
#     cv <- 0
#     y <- eval(parse(text = paste("data", response.name, sep = "$")))
#     pred <- pred.err <- y * 0
#     data.old <- data
#     n <- dim(data)[1]
#     for (i in 1:n) {
#       case.delete <- data.old[i, ]
#       data <- data.old[-i, ]
#       res <- threshold.gam(data = data, ...)
#       case.delete$r <- res$mr
#       l1 <- list(data = data, case.delete = case.delete)
#       pred.err[i] <- y[i] - (pred[i] <- with(l1, {
#         attach(l1$data)
#         predict(res$res, newdata = case.delete)
#       }))
#       detach(l1$data)
#       cv <- cv + pred.err[i]^2
#     }
#     cv <- cv/n
#     invisible(list(cv = cv, pred.err = pred.err, pred = pred))
#   }
#
# gam.cv<-
#   function (response.name, data, ...)
#   {
#     data <- na.omit(data)
#     cv <- 0
#     y <- eval(parse(text = paste("data", response.name, sep = "$")))
#     pred <- pred.err <- y * 0
#     data.old <- data
#     n <- dim(data)[1]
#     for (i in 1:n) {
#       case.delete <- data.old[i, ]
#       data <- data.old[-i, ]
#       res <- gam(data = data, ...)
#       case.delete$r <- res$mr
#       l1 <- list(data = data, case.delete = case.delete)
#       pred.err[i] <- y[i] - (pred[i] <- with(l1, {
#         attach(l1$data)
#         predict(res, newdata = case.delete)
#       }))
#       detach(l1$data)
#       cv <- cv + pred.err[i]^2
#     }
#     cv <- cv/n
#     invisible(list(cv = cv, pred.err = pred.err, pred = pred))
#   }
