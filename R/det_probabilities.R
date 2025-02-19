#' Compute binary probabilities for deterministic forecasts
#'
#' @param .fcst A \code{harp_fcst} object with tables that have a column for
#'   observations, or a single forecast table.
#' @param parameter The name of the column for the observed data.
#' @param thresholds A numeric vector of thresholds for which to compute
#'   probabilities.
#' @param groupings The groups for which to compute the ensemble mean and
#'   spread. See \link[dplyr]{group_by} for more information of how grouping
#'   works.
#'
#' @return An object of the same format as the inputs but with data grouped for
#'   the \code{groupings} column(s) and columns for \code{rank} and
#'   \code{rank_count} that are nested together in a column with the name
#'   \code{rank_histogram}.
#' @export
#'
#' @examples
det_probabilities <- function(.fcst, parameter, thresholds, obs_probabilities = TRUE) {
  UseMethod("det_probabilities")
}

#' @export
det_probabilities.default <- function(.fcst, parameter, thresholds, obs_probabilities = TRUE) {

  parameter  <- rlang::enquo(parameter)
  chr_param  <- rlang::quo_name(parameter)
  col_names  <- colnames(.fcst)
  if (length(grep(chr_param, col_names)) < 1) {
    stop(paste("No column found for", chr_param), call. = FALSE)
  }

  dplyr::bind_cols(
    .fcst,
    harp_probs(.fcst, thresholds, chr_param, obs_prob = obs_probabilities, fcst_type = "det")
  )

}

#' @export
det_probabilities.harp_fcst <- function(.fcst, parameter, thresholds, obs_probabilities = TRUE) {
  parameter <- rlang::enquo(parameter)
  purrr::map(.fcst, det_probabilities, !! parameter, thresholds, obs_probabilities) %>%
    new_harp_fcst()
}

