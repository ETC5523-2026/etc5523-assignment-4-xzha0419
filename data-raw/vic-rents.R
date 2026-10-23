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
readxl::excel_sheets(data_file)
readxl::excel_sheets(data_file)

