#' Summarise STATS19 severities with DfT adjustments
#'
#' @description
#' Calculates raw and DfT-adjusted severity counts for casualty or collision data.
#' Between 2016 and 2019, police forces in England and Wales progressively
#' transitioned to injury-based reporting systems (such as CRASH and COPA). This
#' caused an artificial upward shift in recorded "Serious" casualties relative
#' to "Slight" casualties. To enable consistent longitudinal analysis across
#' 2004--latest, the Department for Transport provides modeled adjustment probabilities.
#'
#' This helper calculates both unadjusted counts and DfT-adjusted counts:
#' \deqn{\text{Adjusted Serious} = \sum \text{coalesce}(\text{adjusted\_severity\_serious}, \mathbb{I}(\text{severity} == \text{"Serious"}))}
#'
#' @param x A `data.frame` or `tibble` containing STATS19 casualties or collisions
#'   (either raw or formatted).
#' @param by Optional character vector of column names to group by (e.g. `"collision_year"`).
#'   If `NULL` and `x` is already grouped, existing grouping is preserved.
#'
#' @return A `tibble` with counts for fatal, serious (unadjusted & adjusted),
#'   slight (unadjusted & adjusted), and total records.
#' @export
#' @examples
#' \donttest{
#' cas = casualties_sample
#' summarise_adjusted_severities(cas)
#' }
summarise_adjusted_severities = function(x, by = NULL) {
  stopifnot(is.data.frame(x))

  # Identify severity column
  sev_col = intersect(c("casualty_severity", "collision_severity", "accident_severity"), names(x))
  if (length(sev_col) == 0) {
    stop("Input data must contain a severity column ('casualty_severity', 'collision_severity', or 'accident_severity').", call. = FALSE)
  }
  sev_name = sev_col[1]

  # Identify adjustment columns
  adj_s_col = intersect(c("casualty_adjusted_severity_serious", "collision_adjusted_severity_serious"), names(x))
  adj_sl_col = intersect(c("casualty_adjusted_severity_slight", "collision_adjusted_severity_slight"), names(x))

  has_adj = length(adj_s_col) > 0 && length(adj_sl_col) > 0

  # Handle grouping
  if (!is.null(by)) {
    x = dplyr::group_by(x, dplyr::across(dplyr::all_of(by)))
  }

  is_fatal = function(s) s %in% c("Fatal", "1", 1)
  is_serious = function(s) s %in% c("Serious", "2", 2)
  is_slight = function(s) s %in% c("Slight", "3", 3)

  if (has_adj) {
    s_col = adj_s_col[1]
    sl_col = adj_sl_col[1]
    res = dplyr::summarise(
      x,
      fatal = sum(is_fatal(.data[[sev_name]]), na.rm = TRUE),
      serious_unadjusted = sum(is_serious(.data[[sev_name]]), na.rm = TRUE),
      serious_adjusted = round(sum(dplyr::coalesce(.data[[s_col]], as.numeric(is_serious(.data[[sev_name]]))), na.rm = TRUE)),
      slight_unadjusted = sum(is_slight(.data[[sev_name]]), na.rm = TRUE),
      slight_adjusted = round(sum(dplyr::coalesce(.data[[sl_col]], as.numeric(is_slight(.data[[sev_name]]))), na.rm = TRUE)),
      total = dplyr::n(),
      .groups = "drop"
    )
  } else {
    res = dplyr::summarise(
      x,
      fatal = sum(is_fatal(.data[[sev_name]]), na.rm = TRUE),
      serious_unadjusted = sum(is_serious(.data[[sev_name]]), na.rm = TRUE),
      serious_adjusted = serious_unadjusted,
      slight_unadjusted = sum(is_slight(.data[[sev_name]]), na.rm = TRUE),
      slight_adjusted = slight_unadjusted,
      total = dplyr::n(),
      .groups = "drop"
    )
  }

  res
}

#' Download and read-in severity adjustment factors
#'
#' See the DfT's documentation on adjustment factors
#' [Annex: Update to severity adjustments methodology](https://assets.publishing.service.gov.uk/government/uploads/system/uploads/attachment_data/file/833813/annex-update-severity-adjustments-methodology.pdf).
#'
#' See [Estimating and adjusting for changes in the method of severity reporting for road accidents and casualty data: final report](https://assets.publishing.service.gov.uk/government/uploads/system/uploads/attachment_data/file/820588/severity-reporting-methodology-final-report.odt)
#' for details.
#'
#' @param u The URL of the adjustment file.
#' @inheritParams read_collisions
#' @export
#' @examples
#' \dontrun{
#' if(curl::has_internet()) {
#' adjustment = get_stats19_adjustments()
#' }
#' }
get_stats19_adjustments = function(
  data_dir = get_data_directory(),
  u = paste0(
    "https://data.dft.gov.uk/road-accidents-safety-data/",
    "dft-road-casualty-statistics-casualty-adjustment-lookup_",
    "2004-latest-published-year.csv"
  )
) {
  message("Data not downloaded. Adjustment table is now merged into casualty table. Use get_stats19 function with 'casualty'. Adjusted data is under the column headings 'casualty_adjusted_severity_serious' and 'casualty_adjusted_severity_slight'")
  invisible(NULL)
}
