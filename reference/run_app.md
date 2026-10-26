# Launch the Victorian rental affordability app

Explore median weekly rents by local government area, property type and
quarter, and compare rents with a household's chosen weekly budget.

## Usage

``` r
run_app(...)
```

## Arguments

- ...:

  Additional arguments passed to
  [`shiny::runApp()`](https://rdrr.io/pkg/shiny/man/runApp.html), such
  as `launch.browser = TRUE` or `port = 3838`.

## Value

The value returned by
[`shiny::runApp()`](https://rdrr.io/pkg/shiny/man/runApp.html) when the
app stops.

## Examples

``` r
if (interactive()) {
  run_app()
}
```
