#' Launch the Victorian rental affordability app
#'
#' Explore median weekly rents by local government area, property type and
#' quarter, and compare rents with a household's chosen weekly budget.
#'
#' @param ... Additional arguments passed to [shiny::runApp()], such as
#'   `launch.browser = TRUE` or `port = 3838`.
#' @return The value returned by [shiny::runApp()] when the app stops.
#' @examples
#' if (interactive()) {
#'   run_app()
#' }
#' @export
run_app <- function(...) {
  app_dir <- system.file("app", package = "australianrent")
  if (app_dir == "") {
    stop("The Shiny app could not be found. Reinstall australianrent.",
         call. = FALSE)
  }
  shiny::runApp(appDir = app_dir, ...)
}
