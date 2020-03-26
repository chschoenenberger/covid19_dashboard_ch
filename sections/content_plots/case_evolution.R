output$case_evolution <- renderPlotly({
  data <- data_evolution %>%
    group_by(date) %>%
    summarise(
      "positive_cases" = sum(positive_cases, na.rm = T),
      "deceased"       = sum(deceased, na.rm = T),
      "active"         = sum(active, na.rm = T)
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

output$selectize_casesByCanton <- renderUI({
  selectizeInput(
    "caseEvolution_canton",
    label    = "Select Countries",
    choices  = unique(data_evolution$name),
    selected = top5_cantons,
    multiple = TRUE
  )
})

output$case_evolution_byCanton <- renderPlotly({
  data <- data_evolution %>%
    select(name, date, positive_cases, deceased, population) %>%
    filter(if (is.null(input$caseEvolution_canton)) TRUE else name %in% input$caseEvolution_canton) %>%
    as.data.frame()

  if (input$checkbox_per100kEvolutionCanton) {
    data <- data %>%
      mutate(
        positive_cases = round(positive_cases / population * 100000, 2),
        deceased       = round(deceased / population * 100000, 2)
      ) %>%
      as.data.frame()
  }

  req(length(data$positive_cases) > 0)
  p <- plot_ly(data = data, x = ~date, y = ~positive_cases, color = ~name, type = 'scatter', mode = 'lines',
    legendgroup     = ~name) %>%
    add_trace(data = data, x = ~date, y = ~deceased, color = ~name, line = list(dash = 'dash'),
      legendgroup  = ~name, showlegend = FALSE) %>%
    add_trace(data = data[which(data$name == data$name[1]),],
      x            = ~date, y = -100, line = list(color = 'rgb(0, 0, 0)'), legendgroup = 'helper', name = "Positive F\U00E4lle") %>%
    add_trace(data = data[which(data$name == data$name[1]),],
      x            = ~date, y = -100, line = list(color = 'rgb(0, 0, 0)', dash = 'dash'), legendgroup = 'helper', name = "Verstorben") %>%
    layout(
      yaxis = list(title = "# F\U00E4lle", rangemode = "nonnegative"),
      xaxis = list(title = "Datum", range(c(min(data$date), max(data$date))))
    )

  if (input$checkbox_logCaseEvolutionCanton) {
    p <- layout(p, yaxis = list(type = "log"))
  }
  if (input$checkbox_per100kEvolutionCanton) {
    p <- layout(p, yaxis = list(title = "# F\U00E4lle per 100k Inhabitants"))
  }

  return(p)
})

output$selectize_casesByCanton_new <- renderUI({
  selectizeInput(
    "selectize_casesByCanton_new",
    label    = "Kanton",
    choices  = c("Alle", unique(data_evolution$name)),
    selected = "Alle"
  )
})

output$case_evolution_new <- renderPlotly({
  req(input$selectize_casesByCanton_new)

  data <- data_evolution %>%
    select(-lat, -long, -canton, -population, -positive_cases, -deceased, -active) %>%
    rename("Positive F\U00E4lle" = positive_cases_new, "Verstorben" = deceased_new, "Aktive F\U00E4lle" = active_new) %>%
    pivot_longer(cols = c("Positive F\U00E4lle", Verstorben, "Aktive F\U00E4lle"), names_to = "var", values_to = "value_new") %>%
    filter(if (input$selectize_casesByCanton_new == "Alle") TRUE else (name %in% input$selectize_casesByCanton_new)) %>%
    group_by(date, var, name) %>%
    summarise(new_cases = sum(value_new))

  if (input$selectize_casesByCanton_new == "Alle") {
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

output$selectize_casesByCantonAfter10th <- renderUI({
  selectizeInput(
    "caseEvolution_cantonAfter10th",
    label    = "Kanton",
    choices  = unique(data_evolution$name),
    selected = top5_cantons,
    multiple = TRUE
  )
})

output$case_evolution_after10 <- renderPlotly({
  req(!is.null(input$checkbox_per100kEvolutionCanton10th))

  data <- data_evolution %>%
    select(name, population, date, positive_cases) %>%
    arrange(date) %>%
    filter(positive_cases >= 10) %>%
    group_by(name, population) %>%
    filter(if (is.null(input$caseEvolution_cantonAfter10th)) TRUE else name %in% input$caseEvolution_cantonAfter10th) %>%
    mutate("daysSince" = row_number()) %>%
    ungroup() %>%
    as.data.frame()

  if (input$checkbox_per100kEvolutionCanton10th) {
    data$positive_cases <- data$positive_cases / data$population * 100000
  }

  p <- plot_ly(data = data, x = ~daysSince, y = ~positive_cases, color = ~name, type = 'scatter', mode = 'lines') %>%
    layout(
      yaxis = list(title = "# F\U00E4lle"),
      xaxis = list(title = "# Tage seit dem 10. Fall")
    )

  if (input$checkbox_logCaseEvolution10th) {
    p <- layout(p, yaxis = list(type = "log"))
  }
  if (input$checkbox_per100kEvolutionCanton10th) {
    p <- layout(p, yaxis = list(title = "# F\U00E4lle pro 100'000 Einwohner"))
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
          checkboxInput("checkbox_logCaseEvolution", label = "Logarithmische Y-Achse", value = FALSE),
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
          HTML("Hinweis: Aktive F\U00E4lle werden wie folgt berechnet: <i>Neue F\U00E4lle - (Geheilte F\U00E4lle +
          Verstorbene F\U00E4lle)</i>. Daher k\U00F6nnen <i>neue</i> aktive F\U00E4lle negativ sein f\U00FCr Tage, an
          welchen es mehr geheilte und verstorbene F\U00E4lle als neue F\U00E4lle gab."),
          width = 7
        ),
        width = 6
      )
    ),
    fluidRow(
      box(
        title = "F\U00E4lle pro Kanton",
        plotlyOutput("case_evolution_byCanton"),
        fluidRow(
          column(
            uiOutput("selectize_casesByCanton"),
            width = 3,
          ),
          column(
            checkboxInput("checkbox_logCaseEvolutionCanton", label = "Logarithmische Y-Achse", value = FALSE),
            checkboxInput("checkbox_per100kEvolutionCanton", label = "Pro 100'000 Einwohner", value = FALSE),
            width = 3,
            style = "float: right; padding: 10px; margin-right: 50px"
          )
        ),
        width = 6
      ),
      box(
        title = "Entwicklung der F\U00E4lle seit 10. Fall",
        plotlyOutput("case_evolution_after10"),
        fluidRow(
          column(
            uiOutput("selectize_casesByCantonAfter10th"),
            width = 3,
          ),
          column(
            checkboxInput("checkbox_logCaseEvolution10th", label = "Logarithmische Y-Achse", value = FALSE),
            checkboxInput("checkbox_per100kEvolutionCanton10th", label = "Pro 100'000 Einwohner", value = FALSE),
            width = 3,
            style = "float: right; padding: 10px; margin-right: 50px"
          )
        ),
        width = 6
      )
    )
  )
})