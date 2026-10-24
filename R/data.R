#' Median rent of VIC by local government area of each quarter
#'
#' @format A data frame with 58618 rows and 6 column
#' \describe{
#'  \item{quarter}{First day of each quarter with median rent}
#'  \item{property_type}{Property type of the property from 1 bedroom to 4 bedroom house and all properties}
#'  \item{lga}{Local government area}
#'  \item{region}{Departmental region the area belongs to}
#'  \item{Median}{Median weekly rent in Australian dollars}
#'  \item{Count}{Number of new lettings the median is based on}
#'  }
#'@details
#'  Median only cover the new rental price but not all property resources.
#'  Homes Victoria will hide the data and show in NA if the quarter record only have too few trades.
#'@source Homes Victoria, Rental Report - Quarterly: Quarterly Median Rents by LGA, September quarter 2025. Licensed CC BY 3.0 AU.
#'  <https://data.gov.au/data/dataset/rental-report-quarterly-quarterly-median-rents-by-lga>
"vic_rents"
