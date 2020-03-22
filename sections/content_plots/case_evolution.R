output$case_evolution <- renderPlotly({
  data <- data_evolution %>%
    group_by(date) %>%
    summarise(
      "positive_cases" = sum(positive_cases),
      "deceased"       = sum(deceased),
      "active"         = sum(active)
    ) %>%
    as.data.frame()

  p <- plot_ly(data, x = ~date, y = ~positive_cases, name = "Positive F\U00E4lle", type = 'scatter', mode = 'lines') %>%
    add_trace(x = ~date, y = ~deceased, name = "Verstorben", mode = 'lines') %>%
    add_trace(x = ~date, y = ~active, name = "Aktive F\U00E4lle", mode = 'lines') %>%
    layout(
      yaxis = list(title = "# F\U00E4lle"),
      xaxis = list(title = "Datum")
    )


  if (input$checkbox_logCaseEvolution) {
    p <- layout(p, yaxis = list(type = "log"))
  }

  return(p)
})

output$selectize_casesByCountries <- renderUI({
  selectizeInput(
    "caseEvolution_country",
    label    = "Select Countries",
    choices  = unique(data_evolution$`Country/Region`),
    selected = top5_countries,
    multiple = TRUE
  )
})

getDataByCountry <- function(countries, normalizeByPopulation) {
  req(countries)
  data_confirmed <- data_evolution %>%
    select(`Country/Region`, date, var, value, population) %>%
    filter(`Country/Region` %in% countries &
      var == "confirmed" &
      value > 0) %>%
    group_by(`Country/Region`, date, population) %>%
    summarise("Confirmed" = sum(value)) %>%
    arrange(date)
  if (nrow(data_confirmed) > 0) {
    data_confirmed <- data_confirmed %>%
      mutate(Confirmed = if_else(normalizeByPopulation, round(Confirmed / population * 100000, 2), Confirmed))
  }
  data_confirmed <- data_confirmed %>% as.data.frame()

  data_recovered <- data_evolution %>%
    select(`Country/Region`, date, var, value, population) %>%
    filter(`Country/Region` %in% countries &
      var == "recovered" &
      value > 0) %>%
    group_by(`Country/Region`, date, population) %>%
    summarise("Recovered" = sum(value)) %>%
    arrange(date)
  if (nrow(data_recovered) > 0) {
    data_recovered <- data_recovered %>%
      mutate(Recovered = if_else(normalizeByPopulation, round(Recovered / population * 100000, 2), Recovered))
  }
  data_recovered <- data_recovered %>% as.data.frame()

  data_deceased <- data_evolution %>%
    select(`Country/Region`, date, var, value, population) %>%
    filter(`Country/Region` %in% countries &
      var == "deceased" &
      value > 0) %>%
    group_by(`Country/Region`, date, population) %>%
    summarise("Deceased" = sum(value)) %>%
    arrange(date)
  if (nrow(data_deceased) > 0) {
    data_deceased <- data_deceased %>%
      mutate(Deceased = if_else(normalizeByPopulation, round(Deceased / population * 100000, 2), Deceased))
  }
  data_deceased <- data_deceased %>% as.data.frame()

  return(list(
    "confirmed" = data_confirmed,
    "recovered" = data_recovered,
    "deceased"  = data_deceased
  ))
}

output$case_evolution_byCountry <- renderPlotly({
  data <- getDataByCountry(input$caseEvolution_country, input$checkbox_per100kEvolutionCountry)

  req(nrow(data$confirmed) > 0)
  p <- plot_ly(data = data$confirmed, x = ~date, y = ~Confirmed, color = ~`Country/Region`, type = 'scatter', mode = 'lines',
    legendgroup     = ~`Country/Region`) %>%
    add_trace(data = data$recovered, x = ~date, y = ~Recovered, color = ~`Country/Region`, line = list(dash = 'dash'),
      legendgroup  = ~`Country/Region`, showlegend = FALSE) %>%
    add_trace(data = data$deceased, x = ~date, y = ~Deceased, color = ~`Country/Region`, line = list(dash = 'dot'),
      legendgroup  = ~`Country/Region`, showlegend = FALSE) %>%
    add_trace(data = data$confirmed[which(data$confirmed$`Country/Region` == input$caseEvolution_country[1]),],
      x            = ~date, y = -100, line = list(color = 'rgb(0, 0, 0)'), legendgroup = 'helper', name = "Confirmed") %>%
    add_trace(data = data$confirmed[which(data$confirmed$`Country/Region` == input$caseEvolution_country[1]),],
      x            = ~date, y = -100, line = list(color = 'rgb(0, 0, 0)', dash = 'dash'), legendgroup = 'helper', name = "Recovered") %>%
    add_trace(data = data$confirmed[which(data$confirmed$`Country/Region` == input$caseEvolution_country[1]),],
      x            = ~date, y = -100, line = list(color = 'rgb(0, 0, 0)', dash = 'dot'), legendgroup = 'helper', name = "Deceased") %>%
    layout(
      yaxis = list(title = "# Cases", rangemode = "nonnegative"),
      xaxis = list(title = "Date")
    )

  if (input$checkbox_logCaseEvolutionCountry) {
    p <- layout(p, yaxis = list(type = "log"))
  }
  if (input$checkbox_per100kEvolutionCountry) {
    p <- layout(p, yaxis = list(title = "# Cases per 100k Inhabitants"))
  }

  return(p)
})

output$selectize_casesByCanton_new <- renderUI({
  selectizeInput(
    "selectize_casesByCanton_new",
    label    = "Kanton",
    choices  = c("All", unique(data_evolution$canton_name)),
    selected = "All"
  )
})

output$case_evolution_new <- renderPlotly({
  req(input$selectize_casesByCanton_new)

  data <- data_evolution %>%
    select(-lat, -long, -canton, -population, -positive_cases, -deceased, -active) %>%
    rename("Positive F\U00E4lle" = positive_cases_new, "Verstorben" = deceased_new, "Aktive F\U00E4lle" = active_new) %>%
    pivot_longer(cols = c("Positive F\U00E4lle", Verstorben, "Aktive F\U00E4lle"), names_to = "var", values_to = "value_new") %>%
    filter(if (input$selectize_casesByCanton_new == "All") TRUE else (canton_name %in% input$selectize_casesByCanton_new)) %>%
    group_by(date, var, canton_name) %>%
    summarise(new_cases = sum(value_new))

  if (input$selectize_casesByCanton_new == "All") {
    data <- data %>%
      group_by(date, var) %>%
      summarise(new_cases = sum(new_cases))
  }

  p <- plot_ly(data = data, x = ~date, y = ~new_cases, color = ~var, type = 'bar') %>%
    layout(
      yaxis = list(title = "# Neue F\U00E4lle"),
      xaxis = list(title = "Datum")
    )
})

output$selectize_casesByCountriesAfter100th <- renderUI({
  selectizeInput(
    "caseEvolution_countryAfter100th",
    label    = "Select Countries",
    choices  = unique(data_evolution$`Country/Region`),
    selected = top5_countries,
    multiple = TRUE
  )
})

output$case_evolution_after100 <- renderPlotly({
  req(!is.null(input$checkbox_per100kEvolutionCountry100th))

  data <- data_evolution %>%
    arrange(date) %>%
    filter(value >= 100 & var == "confirmed") %>%
    group_by(`Country/Region`, population, date) %>%
    filter(if (is.null(input$caseEvolution_countryAfter100th)) TRUE else `Country/Region` %in% input$caseEvolution_countryAfter100th) %>%
    summarise(value = sum(value)) %>%
    mutate("daysSince" = row_number()) %>%
    ungroup()

  if (input$checkbox_per100kEvolutionCountry100th) {
    data$value <- data$value / data$population * 100000
  }

  p <- plot_ly(data = data, x = ~daysSince, y = ~value, color = ~`Country/Region`, type = 'scatter', mode = 'lines') %>%
    layout(
      yaxis = list(title = "# Cases"),
      xaxis = list(title = "# Days since 100th case")
    )

  if (input$checkbox_logCaseEvolution100th) {
    p <- layout(p, yaxis = list(type = "log"))
  }
  if (input$checkbox_per100kEvolutionCountry100th) {
    p <- layout(p, yaxis = list(title = "# Cases per 100k Inhabitants"))
  }

  return(p)
})

output$box_caseEvolution <- renderUI({
  tagList(
    fluidRow(
      box(
        title = "Entwicklung der F\U00E4lle seit Ausbruch",
        plotlyOutput("case_evolution"),
        column(
          checkboxInput("checkbox_logCaseEvolution", label = "Logaritmische Y-Axis", value = FALSE),
          width = 3,
          style = "float: right; padding: 10px; margin-right: 50px"
        ),
        width = 6
      ),
      box(
        title = "Neue F\U00E4lle",
        plotlyOutput("case_evolution_new"),
        column(
          uiOutput("selectize_casesByCanton_new"),
          width = 3,
        ),
        column(
          HTML("Beachte: Aktive F\U00E4lle werden wie folgt berechnet: <i>Neue F\U00E4lle - (Geheilte F\U00E4lle +
          Verstorbene F\U00E4lle)</i>. Daher k\U00F6nnen <i>neue</i> aktive F\U00E4lle negativ sein f\U00FCr Tage, an
          welchen es mehr geheilte und verstorbene F\U00E4lle als neue F\U00E4lle gab."),
          width = 7
        ),
        width = 6
      )
    ) #,
  # fluidRow(
  #   box(
  #     title = "Cases per Country",
  #     plotlyOutput("case_evolution_byCountry"),
  #     fluidRow(
  #       column(
  #         uiOutput("selectize_casesByCountries"),
  #         width = 3,
  #       ),
  #       column(
  #         checkboxInput("checkbox_logCaseEvolutionCountry", label = "Logaritmic Y-Axis", value = FALSE),
  #         checkboxInput("checkbox_per100kEvolutionCountry", label = "Per Population", value = FALSE),
  #         width = 3,
  #         style = "float: right; padding: 10px; margin-right: 50px"
  #       )
  #     ),
  #     width = 6
  #   ),
  #   box(
  #     title = "Evolution of Cases since 100th case",
  #     plotlyOutput("case_evolution_after100"),
  #     fluidRow(
  #       column(
  #         uiOutput("selectize_casesByCountriesAfter100th"),
  #         width = 3,
  #       ),
  #       column(
  #         checkboxInput("checkbox_logCaseEvolution100th", label = "Logaritmic Y-Axis", value = FALSE),
  #         checkboxInput("checkbox_per100kEvolutionCountry100th", label = "Per Population", value = FALSE),
  #         width = 3,
  #         style = "float: right; padding: 10px; margin-right: 50px"
  #       )
  #     ),
  #     width = 6
  #   )
  # )
  )
})