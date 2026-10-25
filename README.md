
<!-- README.md is generated from README.Rmd. Please edit that file -->

# australianrent

<https://etc5523-2026.github.io/etc5523-assignment-4-xzha0419/>

This package aims to help tenants answer the question: “Which local
government area can I really afford to rent in?” Rental affordability is
personal. Published median rents are the same for all readers, but
whether those rents are affordable differs between households with
incomes of \$900 and \$2,500. The package therefore includes not only
published rental data but also a function that checks all areas against
a user-specified income. It also includes a Shiny app that visualizes
the results and allows users to compare rental prices in any three LGAs
over time.

## Data

`vic_rents` includes quarterly median advertised rents from June 1999 to
September 2025 by property type. The data has 58618 rows covering 79
local government areas, 7 property types and 106 quarters.

*Cautions* - Median number only incude the new rent contract but not the
whole market. - Home Victoria will turn the median price to NA if this
quarter has too few trade records.

Source: Homes Victoria, *Rental Report — Quarterly: Quarterly Median
Rents by LGA*, September quarter 2025, published on
[data.gov.au](https://data.gov.au/data/dataset/rental-report-quarterly-quarterly-median-rents-by-lga)
under a Creative Commons Attribution 3.0 Australia licence.

The script that downloads and reshapes the source workbook is in
[`data-raw/vic-rents.R`](data-raw/vic-rents.R).

## Installation

Install the development version form GitHub:

``` r
#need to install "remotes" package first
remotes::install_github("ETC5523-2026/etc5523-assignment-4-xzha0419")
```

## Launching the app

``` r
library(australianrent)
run_app()
```

The app reads the data installed with the package which fo not need
internet connection and external files.

## Example

Search the areas where the median rent for a one-bedroom flat is within
40% if a gross weekly household income of \$1000.

``` r
library(australianrent)

result <- rent_affordability(
  weekly_income = 1000,
  property_type = "1 bedroom flat",
  threshold = 0.40
)

head(result)
#> # A tibble: 6 × 7
#>   region            lga          quarter    Median Count income_share affordable
#>   <chr>             <chr>        <date>      <dbl> <dbl>        <dbl> <lgl>     
#> 1 Barwon South West Colac-Otway  2025-09-01    290     9         0.29 TRUE      
#> 2 Barwon South West Corangamite  2025-09-01     NA    NA        NA    NA        
#> 3 Barwon South West Glenelg      2025-09-01    300     5         0.3  TRUE      
#> 4 Barwon South West Greater Gee… 2025-09-01    340   140         0.34 TRUE      
#> 5 Barwon South West Moyne        2025-09-01     NA    NA        NA    NA        
#> 6 Barwon South West Queenscliffe 2025-09-01     NA    NA        NA    NA
```

The weekly tental budget is \$400.

- `Median` is the median weekly rent in Australian dollars.

- `income_share` is the proportion of household income spent on rent.

- `affordable` is `TRUE` when the median rent is within the budget.

- `NA` indicates unavailable data.
