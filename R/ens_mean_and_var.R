#' Compute the ensemble mean and variance
#'
#' The ensemble mean and variance are computed and added as columns to tables in
#' a \code{harp_fcst} object.
#'
#' @param .fcst A \code{harp_fcst} object, or a data frame containing columns
#'   with "_mbr" as part of the column names.
#'
#' @return A \code{harp_fcst} object with columns ens_mean and ens_var added to
#'   the forecast tables.
#' @export
#'
#' @examples
ens_mean_and_var <- function(.fcst, mean_name = "ens_mean", var_name = "ens_var") {
  UseMethod("ens_mean_and_var")
}

#' @export
ens_mean_and_var.default <- function(.fcst, mean_name = "ens_mean", var_name = "ens_var") {
  col_names <- colnames(.fcst)
  mean_name <- rlang::sym(mean_name)
  var_name  <- rlang::sym(var_name)

  if (length(grep("_mbr", col_names)) < 1) {
    stop(".fcst column names must contain '_mbr' to indicate an ensemble", call. = FALSE)
  }

  member_data <- dplyr::select(.fcst, dplyr::contains("_mbr"))

  dplyr::mutate(
    .fcst,
    !!mean_name := rowMeans(member_data),
    !!var_name  := matrixStats::rowVars(as.matrix(member_data))
  )
}

#' @export
ens_mean_and_var.harp_fcst <- function(.fcst, mean_name = "ens_mean", var_name = "ens_var") {
  new_harp_fcst(purrr::map(.fcst, ens_mean_and_var, mean_name, var_name))
}

