#' Download DVLA-based vehicle data from the TfL API using VRM.
#'
#' @section Details:
#' This function takes a character vector of vehicle registrations (VRMs) and returns DVLA-based vehicle data from TfL's API, included ULEZ eligibility.
#' It returns a data frame of those VRMs which were successfully used with the TfL API.  Vehicles are either compliant, non-compliant or exempt.  ULEZ-exempt vehicles will not have all vehicle details returned - they will simply be marked "exempt".
#'
#' Be aware that the API has usage limits.  The function will therefore limit API calls to below 50 per minute - this is the maximum rate before an API key is required.
#'
#' @param vrm A list of VRMs as character strings.
#'
#' @export
#' @examples
#' \donttest{
#' if(curl::has_internet()) {
#' vrm = c("1RAC","P1RAC")
#' get_ULEZ(vrm = vrm)
#' }
#' }
get_ULEZ = function(vrm) {
  # Check arguments
  if (!is.vector(vrm)) stop("vrm must be a vector.")
  for(i in 1:length(vrm)){
    if (!is.character(vrm[i])) stop("All VRMs must be character.")
  }
  for(i in 1:length(vrm)){
    if (grepl(" ", vrm[[i]])) stop("Please remove spaces from VRMs.  Check VRM number ", i, " in your list (", vrm[i], ").")
  }
  for(i in 1:length(vrm)){
    if (grepl('[^[:alnum:]]', vrm[i])) stop("VRMs must be alphanumeric.  Check VRM number ", i, " in your list (", vrm[i], ").")
  }
  message("This script only does 50 vrms per minute at most")
  message("Warning: TfL ULEZ API is producing some strange results currently")

  # Create an empty list for results
  result.list = list()

  # Create progress bar
  pb = utils::txtProgressBar(min = 0, max = length(vrm), style = 3)

  # Loop through VRMs
  timepercall = 60/(50-5)
  for(i in 1:length(vrm)){
    # Make API url and call API
    starttime = Sys.time()
    URL = as.character(paste('https://api.tfl.gov.uk/Vehicle/UlezCompliance?vrm=',vrm[i],sep=""))
    d = curl::curl_fetch_memory(URL)
    apistatus = d$status_code
    if(apistatus != 200L){
      result = as.data.frame(t(c(vrm[i],apistatus)))
      colnames(result) = c("vrm", "API Status")
      result.list[[i]] = result
      rm(result, d)
      next()}
    endtime = Sys.time()
    calltime = as.numeric(endtime) - as.numeric(starttime)
    if(calltime < timepercall){
      Sys.sleep(timepercall - calltime)
    }
    page.df = jsonlite::fromJSON(rawToChar(d$content))
    rm(starttime, endtime, calltime, URL, d)
    # Start assembling output data frame (called "result")
    result = as.data.frame(page.df)
    result$X.type = NULL
    result$`API Status` = apistatus
    rm(apistatus)
    result.list[[i]] = result
    utils::setTxtProgressBar(pb, i)
  }
  result.df = dplyr::bind_rows(result.list)
  return(result.df)
}
