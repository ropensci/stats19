#' Download and read-in severity adjustment factors
#'
#' See the DfT's documentation on adjustment factors
#' [Annex: Update to severity adjustments methodology](https://assets.publishing.service.gov.uk/government/uploads/system/uploads/attachment_data/file/833813/annex-update-severity-adjustments-methodology.pdf).
#'
#' See [Estimating and adjusting for changes in the method of severity reporting for road accidents and casualty data: final report](https://assets.publishing.service.gov.uk/government/uploads/system/uploads/attachment_data/file/820588/severity-reporting-methodology-final-report.odt)
#' for details.
#'
#' @param u The URL of the zip file with adjustments to download
#' @param adj_folder The folder where R will look for the unzipped adjustment files
#' @param filename The file name of the .csv file in the unzipped folder to read in
#' @export
get_stats19_adjustments = function(
  data_dir = get_data_directory(),
  u = paste0("http://data.dft.gov.uk/road-accidents-safety-data/",
    "accident-and-casualty-adjustment-2004-to-2019.zip"),
  adj_folder = "accident-and-casualty-adjusted",
  filename = "accident-adjustment.csv"
) {
  f_zip = basename(u)
  adj_zip = file.path(data_dir, f_zip)
  adj_folder_full = file.path(data_dir, adj_folder, adj_folder)
  f_csv = file.path(adj_folder_full, filename)

  if(!file.exists(adj_zip)) {
    utils::download.file(
      url = u,
      destfile = adj_zip
    )
  }

  utils::unzip(adj_zip, exdir = data_dir)
  message("Unzipped files from DfT can be found in the folder:\n", adj_folder_full)
  message(paste(list.files(adj_folder_full), collapse = "\n"))

  # read-in adjustment figures
  adjustments = readr::read_csv(f_csv)
  adjustments

}
