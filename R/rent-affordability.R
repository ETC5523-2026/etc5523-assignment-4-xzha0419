#'Search the rental areas where affordable for family.
#'Comparing median number of advertised rent in each LGA of Victoria
#'and highlight the areas wheres rent has lower than given share of income
#'@param weekly_income The gross income of household per week is AUS dollars.
#'@param property_type One of the property type from `vic_rents$property_type`.
#'@param threshold Share of income which rent is treated as un affordable. Default with 0.3 align with Australian housing stress benchmark.
#'@param quarter Selected quarter to access data, default with most recent data.
#'@return A data frame with one row per LGA, the median rent, and share of income with corresponding rent, and whether if falls against the threshold.
#'@details Area where Home Victoria suppressed the median are returned with NA due to too few trades.
#'@examples
#'rent_affordability(1500, "2 bedroom flat")
#'
#'rent_affordability(900, "1 bedroom flat", threshold = 0.25)
#'@importFrom dplyr filter mutate select
#'@importFrom rlang .data .env
#'@export
rent_affordability <- function(
    weekly_income,
    property_type,
    threshold = 0.3,
    quarter = NULL
) { rents <- australianrent::vic_rents
#default with last quarter
if(is.null(quarter)){
  quarter <- max(rents$quarter[!is.na(rents$Median)])
}
rents |>
  dplyr::filter(
    .data$property_type == .env$property_type,
    .data$quarter == .env$quarter
  ) |>
  dplyr::mutate(
    income_share = .data$Median / .env$weekly_income,
    affordable = .data$income_share <= .env$threshold
  ) |>
  dplyr::select(
    "region", "lga", "quarter", "Median", "Count", "income_share", "affordable"
  )
}
