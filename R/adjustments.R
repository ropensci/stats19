#' Download and read-in severity adjustment factors
#'
#' See the DfT's documentation on adjustment factors
#' [Annex: Update to severity adjustments methodology](https://assets.publishing.service.gov.uk/government/uploads/system/uploads/attachment_data/file/833813/annex-update-severity-adjustments-methodology.pdf).
#'
#' See [Estimating and adjusting for changes in the method of severity reporting for road accidents and casualty data: final report](https://assets.publishing.service.gov.uk/government/uploads/system/uploads/attachment_data/file/820588/severity-reporting-methodology-final-report.odt)
#' for details.
#'
#' @param u The URL of the zip file with adjustments to download
#' @inheritParams read_collisions
#' @export
#' @examples
#' \donttest{
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
  adjustments = readr::read_csv(u)
  adjustments

}
