# Search the rental areas where affordable for family. Comparing median number of advertised rent in each LGA of Victoria and highlight the areas wheres rent has lower than given share of income

Search the rental areas where affordable for family. Comparing median
number of advertised rent in each LGA of Victoria and highlight the
areas wheres rent has lower than given share of income

## Usage

``` r
rent_affordability(
  weekly_income,
  property_type,
  threshold = 0.3,
  quarter = NULL
)
```

## Arguments

- weekly_income:

  The gross income of household per week is AUS dollars.

- property_type:

  One of the property type from `vic_rents$property_type`.

- threshold:

  Share of income which rent is treated as un affordable. Default with
  0.3 align with Australian housing stress benchmark.

- quarter:

  Selected quarter to access data, default with most recent data.

## Value

A data frame with one row per LGA, the median rent, and share of income
with corresponding rent, and whether if falls against the threshold.

## Details

Area where Home Victoria suppressed the median are returned with NA due
to too few trades.

## Examples

``` r
rent_affordability(1500, "2 bedroom flat")
#> # A tibble: 79 × 7
#>    region            lga         quarter    Median Count income_share affordable
#>    <chr>             <chr>       <date>      <dbl> <dbl>        <dbl> <lgl>     
#>  1 Barwon South West Colac-Otway 2025-09-01    370    13        0.247 TRUE      
#>  2 Barwon South West Corangamite 2025-09-01     NA    NA       NA     NA        
#>  3 Barwon South West Glenelg     2025-09-01    305    22        0.203 TRUE      
#>  4 Barwon South West Greater Ge… 2025-09-01    435   257        0.29  TRUE      
#>  5 Barwon South West Moyne       2025-09-01     NA    NA       NA     NA        
#>  6 Barwon South West Queensclif… 2025-09-01     NA    NA       NA     NA        
#>  7 Barwon South West Southern G… 2025-09-01    345     6        0.23  TRUE      
#>  8 Barwon South West Surf Coast  2025-09-01    480     9        0.32  FALSE     
#>  9 Barwon South West Warrnambool 2025-09-01    420    60        0.28  TRUE      
#> 10 Grampians         Ararat      2025-09-01    340    10        0.227 TRUE      
#> # ℹ 69 more rows

rent_affordability(900, "1 bedroom flat", threshold = 0.25)
#> # A tibble: 79 × 7
#>    region            lga         quarter    Median Count income_share affordable
#>    <chr>             <chr>       <date>      <dbl> <dbl>        <dbl> <lgl>     
#>  1 Barwon South West Colac-Otway 2025-09-01    290     9        0.322 FALSE     
#>  2 Barwon South West Corangamite 2025-09-01     NA    NA       NA     NA        
#>  3 Barwon South West Glenelg     2025-09-01    300     5        0.333 FALSE     
#>  4 Barwon South West Greater Ge… 2025-09-01    340   140        0.378 FALSE     
#>  5 Barwon South West Moyne       2025-09-01     NA    NA       NA     NA        
#>  6 Barwon South West Queensclif… 2025-09-01     NA    NA       NA     NA        
#>  7 Barwon South West Southern G… 2025-09-01    260     5        0.289 FALSE     
#>  8 Barwon South West Surf Coast  2025-09-01    330     8        0.367 FALSE     
#>  9 Barwon South West Warrnambool 2025-09-01    318    10        0.353 FALSE     
#> 10 Grampians         Ararat      2025-09-01     NA    NA       NA     NA        
#> # ℹ 69 more rows
```
