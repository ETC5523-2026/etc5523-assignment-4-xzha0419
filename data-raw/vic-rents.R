#create the folder for rawdata
dir.create(
  "data-raw/downloads",
  recursive = TRUE,
  showWarnings = FALSE
)
#load the link
data_url <- paste0(
  "https://www.dffh.vic.gov.au/",
  "quarterly-median-rents-local-government-area-",
  "september-quarter-2025-excel"
)
data_file <- "data-raw/downloads/vic-median-rents-sep2025.xlsx"
#download the file(http2 is not able to use)
utils::download.file(
  url = data_url,
  destfile = data_file,
  method = "curl",
  mode = "wb",
  extra = "--http1.1 --location --fail"
)

# Check that R can read the workbook
sheet_names <- readxl::excel_sheets(data_file)

#All sheets has same layout, there have difference in property
rent_info <- list()

for(sheet_name in sheet_names) {
  #read the header of each sheet first
  headers <- suppressMessages(
    readxl::read_excel(
      data_file,
      sheet = sheet_name,
      skip = 1,
      n_max = 2,
      col_names = FALSE,
      col_types = "text"
    )
  )
#extract the date of data
  dates <- unlist(headers[1, -(1:2)], use.names = FALSE)
#extract the name of "count" and "median"
  measures <- unlist(headers[2, -(1:2)], use.names = FALSE)
#combine the date and measures
  col_names <- c(
    "region",
    "lga",
    paste(dates, measures, sep = "_")
   )
#import data
  rent_info[[sheet_name]] <- readxl::read_excel(
    data_file,
    sheet = sheet_name,
    skip = 3,
    col_names = col_names,
    col_types = "text"
 )
}
#bind all sheets together
binded_sheet <- dplyr::bind_rows(rent_info, .id = "property_type") |>
  #fill the NA of region
  tidyr::fill(region, .direction = "down") |>
#turn the numbers back to numeric
dplyr::filter(!is.na(lga),
              !lga %in% c("Group Total", "Victoria", "Metro", "Non-Metro")
              ) |>
  dplyr::mutate(across(-(1:3), ~ as.numeric(dplyr::na_if(.x, "-")))) |>
  tidyr::pivot_longer(
    cols = -(1:3),
    names_to = c("quarter_label", "measure"),
    names_sep = "_",
    values_to = "value"
  ) |> tidyr::pivot_wider(
    names_from = "measure",
    values_from = "value"
  ) |>
  dplyr::mutate(
  month = substr(quarter_label, 1, 3),
  year = substr(quarter_label, 5, 8),
  month_num = dplyr::case_when(
    month == "Mar" ~ "03",
    month == "Jun" ~ "06",
    month == "Sep" ~ "09",
    month == "Dec" ~ "12"
  ),
  quarter = as.Date(paste0(year, "-", month_num, "-01")),
  property_type = dplyr::case_when(
    property_type == "1br flat"       ~ "1 bedroom flat",
    property_type == "2br Flat"       ~ "2 bedroom flat",
    property_type == "3br Flat"       ~ "3 bedroom flat",
    property_type == "2br House"      ~ "2 bedroom house",
    property_type == "3br House"      ~ "3 bedroom house",
    property_type == "4br House"      ~ "4 bedroom house",
    property_type == "All Properties" ~ "All properties"
  )
  ) |>
  dplyr::select(quarter, property_type, lga, region, Median, Count)
vic_rents <- binded_sheet

usethis::use_data(vic_rents, overwrite = TRUE)
