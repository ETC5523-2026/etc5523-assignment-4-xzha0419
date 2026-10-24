library(shiny)
library(bslib)
library(ggplot2)

#use the installed package
rents <- australianrent::vic_rents


ui <- page_sidebar(
  title = "Affordability of rental in Victoria",
  sidebar = sidebar(
    selectInput(
      "property_type",
      "Choose a property type",
      choices = unique(rents$property_type),
      selected = "2 bedroom flat"
    ),
    numericInput(
      "weekly_income",
      "Weekly Household Income (AUD):",
      value = 1500,
      min = 0,
      step = 100
    )
  ),
  plotOutput("rent_plot")
)

server <- function(input, output, session) {

  output$rent_plot <- renderPlot({

    req(input$property_type)

    # Run your function using the selected property type
    result <- australianrent::rent_affordability(
      weekly_income = 1500,
      property_type = input$property_type
    ) |>
      dplyr::filter(!is.na(Median))

    # Plot the results
    ggplot(
      result,
      aes(
        x = reorder(lga, Median),
        y = Median,
        fill = affordable
      )
    ) +
      geom_col() +
      coord_flip() +
      labs(
        x = "LGA",
        y = "Median weekly rent (AUD)",
        fill = "Within budget",
        title = input$property_type,
        subtitle = "Weekly income: $1,500 | Rent budget: 30% | Latest quarter"
      ) +
      theme_minimal()
  })
}

shinyApp(ui = ui, server = server)
