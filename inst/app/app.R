library(shiny)
library(bslib)
library(ggplot2)

# Use the installed package
rents <- australianrent::vic_rents

# Define custom theme
app_theme <- bs_theme(
  bg = "#f8f9fa",
  fg = "#212529",
  primary = "#20c997",
  base_font = font_google("Inter")
)

ui <- page_navbar(
  title = "Victorian Rent Explorer",
  theme = app_theme,
  nav_panel(
    "Explorer",
    page_sidebar(
      sidebar = sidebar(
        selectInput(
          "property_type",
          "Property type",
          choices = unique(rents$property_type),
          selected = "2 bedroom flat"
        ),
        numericInput(
          "weekly_income",
          "Weekly income before tax (AUD)",
          value = 1500,
          min = 0,
          step = 100
        ),
        sliderInput(
          "threshold",
          "Maximum income spent on rent (%)",
          min = 10,
          max = 60,
          value = 30,
          step = 1,
          post = "%"
        ),
        uiOutput("budget_display"),
        tags$details(
          tags$summary("What do these fields mean?"),
          tags$ul(
            tags$li(
              tags$strong("Weekly income before tax:"),
              " Your gross household income per week."
            ),
            tags$li(
              tags$strong("Maximum income spent on rent:"),
              " The percentage of income you can afford to spend on rent.
              30% is the standard benchmark for housing stress."
            ),
            tags$li(
              tags$strong("Median:"),
              " The middle advertised rent for ", tags$em("new"),
              " lettings in that area that quarter."
            ),
            tags$li(
              tags$strong("Count:"),
              " How many lettings the median was based on.
              Lower counts = less reliable."
            )
          )
        )
      ),
      layout_columns(
        col_widths = c(4, 4, 4),
        value_box(
          title = "Weekly rent budget",
          value = textOutput("budget_value"),
          showcase = bsicons::bs_icon("wallet2"),
          theme = "primary"
        ),
        value_box(
          title = "LGAs within budget",
          value = textOutput("affordable_count"),
          showcase = bsicons::bs_icon("house-check"),
          theme = "success"
        ),
        value_box(
          title = "Data period",
          value = textOutput("data_period"),
          showcase = bsicons::bs_icon("calendar3"),
          theme = "info"
        )
      ),
      card(
        full_screen = TRUE,
        card_header("Median weekly rent by Local Government Area"),
        card_body(
          style = "overflow-y: auto; max-height: 600px;",
          plotOutput("rent_plot", height = "auto")
        )
      ),
      uiOutput("suppressed_note")
    )
  ),
  nav_panel(
    "Pattern",

    card(
      full_screen = TRUE,
      card_header("Affordability over time"),

      selectizeInput(
        "pattern_lga",
        "Compare up to three LGAs",
        choices  = sort(unique(rents$lga)),
        selected = c("Melbourne", "Greater Geelong"),
        multiple = TRUE,
        options  = list(maxItems = 3)
      ),

      helpText(
        "Uses the property type, income and budget percentage",
        "selected in the Explorer tab."
      ),

      plotOutput("pattern_plot", height = "500px"),

      card_footer(
        "At or below the dashed line means within budget.",
        "The same income is used for every year;",
        "historical incomes and inflation are not adjusted."
      )
    )
  ),
  nav_panel(
    "How to read this",
    layout_column_wrap(
      width = 1/2,
      card(
        card_header("Who is this for?"),
        p("This app helps renters choosing where to live in Victoria.
          If you know your household income and the type of property you need,
          you can see which areas have affordable rents.")
      ),
      card(
        card_header("Why interactive?"),
        p("What counts as 'affordable' depends on ", tags$em("your"),
          " income. The sliders let you see the chart that matches your situation.")
      ),
      card(
        card_header("How to read the chart"),
        tags$ul(
          tags$li("Each bar = one Local Government Area (LGA)"),
          tags$li(tags$span(
            style = "color: #20c997; font-weight: bold;",
            "Teal bars"
          ), " = median rent within budget"),
          tags$li(tags$span(
            style = "color: #fd7e14; font-weight: bold;",
            "Orange bars"
          ), " = median rent above budget"),
          tags$li("Dashed line = your rent budget threshold"),
          tags$li("Cheapest LGAs appear at the top")
        )
      ),
      card(
        card_header("Data limitations"),
        tags$ul(
          tags$li("Source: Homes Victoria quarterly rental reports (CC BY 3.0 AU)"),
          tags$li("Median reflects ", tags$em("newly advertised"),
                  " rentals only, not existing tenants' rents"),
          tags$li("Some areas suppressed when too few properties were let"),
          tags$li("'Count' shows reliability; low counts (<5) are less reliable")
        )
      )
    )
  )
)

server <- function(input, output, session) {

  # Reactive expression for affordability data
  affordability_data <- reactive({
    req(input$property_type, input$weekly_income > 0)

    australianrent::rent_affordability(
      weekly_income = input$weekly_income,
      property_type = input$property_type,
      threshold = input$threshold / 100
    )
  })

  # Display budget below slider
  output$budget_display <- renderUI({
    budget <- input$weekly_income * (input$threshold / 100)
    tags$p(
      style = "color: #6c757d; font-size: 0.9em; margin-top: -0.5rem;",
      sprintf("Your rent budget: $%.0f per week", budget)
    )
  })

  # Value boxes
  output$budget_value <- renderText({
    budget <- input$weekly_income * (input$threshold / 100)
    sprintf("$%.0f/week", budget)
  })

  output$affordable_count <- renderText({
    result <- affordability_data()
    available <- result |> dplyr::filter(!is.na(Median))
    affordable <- available |> dplyr::filter(affordable == TRUE)
    sprintf("%d of %d", nrow(affordable), nrow(available))
  })

  output$data_period <- renderText({
    result <- affordability_data()
    if (nrow(result) > 0 && "date" %in% names(result)) {
      date_val <- result$date[1]
      format(date_val, "%b %Y")
    } else {
      "Latest quarter"
    }
  })

  output$rent_plot <- renderPlot({
    req(input$property_type)

    # Validate income is positive
    validate(
      need(input$weekly_income > 0,
           "Please enter a weekly household income greater than zero.")
    )

    result <- affordability_data()

    # Filter for plotting (keep only non-NA)
    plot_data <- result |>
      dplyr::filter(!is.na(Median))

    # Calculate budget line
    budget_line <- input$weekly_income * (input$threshold / 100)

    # Calculate dynamic height
    n_areas <- nrow(plot_data)
    plot_height <- max(400, n_areas * 25)

    # Plot the results
    ggplot(
      plot_data,
      aes(
        x = reorder(lga, -Median),  # Negative to show cheapest at top
        y = Median,
        fill = affordable
      )
    ) +
      geom_col() +
      geom_hline(
        yintercept = budget_line,
        linetype = "dashed",
        color = "#495057",
        linewidth = 0.7
      ) +
      coord_flip() +
      scale_fill_manual(
        values = c("TRUE" = "#20c997", "FALSE" = "#fd7e14"),
        labels = c("TRUE" = "Within budget", "FALSE" = "Above budget"),
        name = NULL
      ) +
      labs(
        x = NULL,
        y = "Median weekly rent (AUD)",
        title = input$property_type
      ) +
      theme_minimal(base_size = 13) +
      theme(
        axis.text.y = element_text(size = 12),
        legend.position = "top",
        panel.grid.major.y = element_blank(),
        panel.grid.minor = element_blank(),
        plot.title = element_text(size = 16, face = "bold")
      )
  }, height = function() {
    result <- affordability_data()
    plot_data <- result |> dplyr::filter(!is.na(Median))
    max(400, nrow(plot_data) * 25)
  })

  output$suppressed_note <- renderUI({
    req(input$property_type, input$weekly_income > 0)

    result <- affordability_data()

    # Find suppressed LGAs
    suppressed <- result |>
      dplyr::filter(is.na(Median)) |>
      dplyr::pull(lga)

    # Show note if any areas are suppressed
    if (length(suppressed) > 0) {
      tags$div(
        class = "alert alert-secondary",
        style = "margin-top: 1rem;",
        tags$strong(sprintf("%d LGAs have unavailable rent data", length(suppressed))),
        tags$details(
          style = "margin-top: 0.5rem;",
          tags$summary("View areas"),
          tags$p(
            style = "margin-top: 0.5rem;",
            paste(suppressed, collapse = ", ")
          )
        ),
        tags$p(
          style = "margin-top: 0.5rem; margin-bottom: 0;",
          class = "small",
          "Unavailable data does not mean these areas are affordable—Homes Victoria
          suppressed their data due to too few lettings that quarter."
        )
      )
    }
  })
  output$pattern_plot <- renderPlot({

    req(input$property_type, input$pattern_lga, input$threshold)

    validate(
      need(input$weekly_income > 0, "Enter a weekly income above zero.")
    )

    # Keep every quarter for the selected property type and areas
    pattern_data <- rents |>
      dplyr::filter(
        property_type == input$property_type,
        lga %in% input$pattern_lga
      ) |>
      dplyr::mutate(
        rent_percent = 100 * Median / input$weekly_income
      )

    validate(
      need(
        any(!is.na(pattern_data$rent_percent)),
        "No rent data are available for this selection."
      )
    )

    ggplot(
      pattern_data,
      aes(x = quarter, y = rent_percent, colour = lga)
    ) +
      geom_hline(
        yintercept = input$threshold,
        linetype   = "dashed",
        colour     = "#495057"
      ) +
      geom_line(linewidth = 1, na.rm = TRUE) +
      scale_colour_brewer(palette = "Dark2") +
      scale_x_date(date_breaks = "5 years", date_labels = "%Y") +
      scale_y_continuous(labels = function(x) paste0(x, "%")) +
      expand_limits(y = 0) +
      labs(
        x = "Year",
        y = "Rent as a percentage of weekly income",
        colour = "LGA",
        title = input$property_type,
        subtitle = paste0(
          "Weekly income held at $", input$weekly_income,
          " | Budget: ", input$threshold, "%"
        )
      ) +
      theme_minimal(base_size = 13) +
      theme(
        legend.position  = "bottom",
        panel.grid.minor = element_blank()
      )
  })
}

shinyApp(ui = ui, server = server)
