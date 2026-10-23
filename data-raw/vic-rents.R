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
  dplyr::mutate(across(-(1:3), ~ as.numeric(dplyr::na_if(.x, "-"))))
