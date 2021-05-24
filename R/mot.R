#' Download vehicle data from the DVSA MOT API using VRM.
#'
#' @section Details:
#' This function takes a a character vector of vehicle registrations (VRMs) and returns vehicle data from MOT records.
#' It returns a data frame of those VRMs which were successfully used with the DVSA MOT API.
#'
#' Information on the DVSA MOT API is available here:
#' https://dvsa.github.io/mot-history-api-documentation/
#'
#' The DVSA MOT API requires a registration.  The function therefore requires the API key provided by the DVSA.
#' Be aware that the API has usage limits.  The function will therefore limit lists with more than 150,000 VRMs.
#'
#' @param vrm A list of VRMs as character strings.
#' @param apikey Your API key as a character string.
#'
#' @export
#' @examples
#' \donttest{
#' vrm = c("1RAC","P1RAC")
#' apikey = Sys.getenv("MOTKEY")
#' if(nchar(apikey) > 0) {
#'   get_MOT(vrm = vrm, apikey = apikey)
#' }
#' }
get_MOT = function(vrm, apikey) {
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
  if (!is.character(apikey)) stop("The api key must be a character string.")
  if (length(vrm) >= 150000) stop("Don't do more than 150,000 VRMs per day.")

  # Set up API key
  h = curl::new_handle()
  curl::handle_setheaders(h,
                          "Accept" = "application/json+v6",
                          "x-api-key" = apikey)

  # Create an empty list for results
  result.list = list()

  # Loop through VRMs
  for(i in 1:length(vrm)){
    # Make API url and call API
    URL = as.character(paste('https://beta.check-mot.service.gov.uk/trade/vehicles/mot-tests?registration=',vrm[i],sep=""))
    d = curl::curl_fetch_memory(URL, handle = h)
    if(d$status_code == 404){next()}
    page.df = jsonlite::fromJSON(rawToChar(d$content))
    # If VehicleID is available, use that instead to handle cherished plates.  Repeat API call.
    if(!is.null(page.df$vehicleID)) {
      vehicleID = page.df$vehicleId
      URL2 = as.character(paste('https://beta.check-mot.service.gov.uk/trade/vehicles/mot-tests?vehicleId=',vehicleID,sep=""))
      d2 = curl::curl_fetch_memory(URL2, handle = h)
      if(d2$status_code == 404){next()}
      page.df = jsonlite::fromJSON(rawToChar(d2$content))
      rm(vehicleID)
    }
    # Start assembling output data frame (called "result")
    result = page.df
    result$motTests = NULL
    # MOT results are in a list within the last column.  This extracts from MOT results to the flat "result" df.
    if(!is.null(page.df$motTests[[1]])) {
      MOTresults = page.df$motTests[[1]]
      result$numberoftests = nrow(MOTresults)
      result$numberofPassedTests = nrow(MOTresults[MOTresults$testResult == "PASSED",])
      advisory.df = MOTresults[MOTresults$testResult == "PASSED",]
      try(advisory.df$advisory <- NA, silent = TRUE)
      for(z in 1:nrow(advisory.df)){
        df = as.data.frame(advisory.df$rfrAndComments[z])
        if("ADVISORY" %in% df$type){advisory.df$advisory[z] = TRUE}
      }
      result$numberofPassedwithAdvisories =sum(advisory.df$advisory, na.rm = TRUE)
      result$latestExpiryDate = MOTresults$expiryDate[1]
      if(!is.null(result$latestExpiryDate)){
        result$latestExpiryDate = lubridate::ymd(result$latestExpiryDate)
      }
      result$latestOdometer = MOTresults$odometerValue[1]
      result$latestOdometerUnit = MOTresults$odometerUnit[1]
      result$latestOdometerDate = MOTresults$completedDate[1]
      result$latestOdometerDate = lubridate::ymd_hms(result$latestOdometerDate)
      MOTresults$completedDate = lubridate::ymd_hms(MOTresults$completedDate)
      # To estimate mileage rate, this looks for an MOT test at least 180 days prior to the most recent result.
      if(nrow(MOTresults) > 1){
        for(j in 2:nrow(MOTresults)){
          diff = as.numeric(MOTresults$completedDate[1]) - as.numeric(MOTresults$completedDate[j])
          if(diff >= 15552000){
            comparatorMOT = j
            result$prevOdometer = MOTresults$odometerValue[comparatorMOT]
            result$prevOdometerUnit = MOTresults$odometerUnit[comparatorMOT]
            result$prevOdometerDate = MOTresults$completedDate[comparatorMOT]
            rm(comparatorMOT)
            break()
          }
        }
      }
    }
    result.list[[i]] = result
    # Create progress bar
    pb = utils::txtProgressBar(min = 0, max = length(vrm), style = 3)
    utils::setTxtProgressBar(pb, i)
  }

  # Close progress bar and bind rows within list
  close(pb)
  result.df = dplyr::bind_rows(result.list)

  # Format dates and numeric etc.
  try(result.df$firstUsedDate <- lubridate::ymd(result.df$firstUsedDate), silent = TRUE)
  try(result.df$registrationDate <- lubridate::ymd(result.df$registrationDate), silent = TRUE)
  try(result.df$manufactureDate <- lubridate::ymd(result.df$manufactureDate), silent = TRUE)
  try(result.df$latestExpiryDate <- lubridate::ymd(result.df$latestExpiryDate), silent = TRUE)
  try(result.df$latestOdometerDate <- lubridate::ymd_hms(result.df$latestOdometerDate), silent = TRUE)
  try(result.df$prevOdometerDate <- lubridate::ymd_hms(result.df$prevOdometerDate), silent = TRUE)
  try(result.df$motTestDueDate <- lubridate::ymd(result.df$motTestDueDate), silent = TRUE)
  try(result.df$latestOdometer <- as.numeric(result.df$latestOdometer), silent = TRUE)
  try(result.df$prevOdometer <- as.numeric(result.df$prevOdometer), silent = TRUE)
  try(result.df$latestOdometerUnit <- as.factor(result.df$latestOdometerUnit), silent = TRUE)
  try(result.df$prevOdometerUnit <- as.factor(result.df$prevOdometerUnit), silent = TRUE)
  try(result.df$engineSize <- as.numeric(result.df$engineSize), silent = TRUE)
  try(result.df$fuelType <- as.factor(result.df$fuelType), silent = TRUE)
  try(result.df$primaryColour <- as.factor(result.df$primaryColour), silent = TRUE)
  try(result.df$make <- as.factor(result.df$make), silent = TRUE)
  try(result.df$model <- as.factor(result.df$model), silent = TRUE)

  # Derive year of manufacture if missing from date of manufacture
  try(result.df$manufactureYear[is.na(result.df$manufactureYear)] <- format(result.df$manufactureDate[is.na(result.df$manufactureYear)], format="%Y"), silent = TRUE)
  try(result.df$manufactureYear <- as.numeric(result.df$manufactureYear), silent = TRUE)

  # Convert all units to miles
  try(result.df$latestOdometer[is.na(result.df$latestOdometerUnit)] <- NA, silent = TRUE)
  try(result.df$prevOdometer[is.na(result.df$prevOdometerUnit)] <- NA, silent = TRUE)
  try(result.df$latestOdometer[result.df$latestOdometerUnit == "km" & !is.na(result.df$latestOdometer)] <- result.df$latestOdometer[result.df$latestOdometerUnit == "km" & !is.na(result.df$latestOdometer)] * 0.621371, silent = TRUE)
  try(result.df$prevOdometer[result.df$prevOdometerUnit == "km" & !is.na(result.df$prevOdometer)] <- result.df$prevOdometer[result.df$prevOdometerUnit == "km" & !is.na(result.df$prevOdometer)] * 0.621371, silent = TRUE)
  try(result.df$latestOdometerUnit <- NULL, silent = TRUE)
  try(result.df$prevOdometerUnit <- NULL, silent = TRUE)

  # Derive miles per year estimate
  try(result.df$test_diff <- as.Date(result.df$latestOdometerDate) - as.Date(result.df$prevOdometerDate), silent = TRUE)
  try(result.df$test_diff[is.na(result.df$prevOdometerDate)] <- as.Date(result.df$latestOdometerDate[is.na(result.df$prevOdometerDate)]) - as.Date(result.df$registrationDate[is.na(result.df$prevOdometerDate)]), silent = TRUE)
  try(result.df$dist_diff <- result.df$latestOdometer - result.df$prevOdometer, silent = TRUE)
  try(result.df$dist_diff[is.na(result.df$prevOdometerDate)] <- result.df$latestOdometer[is.na(result.df$prevOdometerDate)] - 0, silent = TRUE)
  try(result.df$latestAnnualEstMileage <- (result.df$dist_diff/as.numeric(result.df$test_diff))*365.24, silent = TRUE)
  try(result.df$EstimatePeriod <- result.df$test_diff/365.24, silent = TRUE)
  try(result.df$EstimatePeriod[is.na(result.df$latestAnnualEstMileage)] <- NA, silent = TRUE)

  # Remove unwanted columns
  try(result.df$test_diff <- NULL, silent = TRUE)
  try(result.df$dist_diff <- NULL, silent = TRUE)
  try(result.df$dvlaId <- NULL, silent = TRUE)
  try(result.df$vehicleId <- NULL, silent = TRUE)

  return(result.df)
}


