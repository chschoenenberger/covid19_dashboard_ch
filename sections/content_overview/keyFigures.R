sumData <- function(date) {
  if (date >= min(data_evolution$date)) {
    data <- data_atDate(date) %>%
      filter(positive_cases > 0 | deceased > 0) %>%
      summarise(
        positive_cases = sum(positive_cases),
        deceased       = sum(deceased),
        cantons        = n_distinct(canton_name)
      )
    return(data)
  }
  return(NULL)
}

key_figures <- reactive({
  data           <- sumData(input$timeSlider)
  data_yesterday <- sumData(input$timeSlider - 1)

  data_new <- list(
    new_positive_cases = (data$positive_cases - data_yesterday$positive_cases) / data_yesterday$positive_cases * 100,
    new_deceased       = (data$deceased - data_yesterday$deceased) / data_yesterday$deceased * 100,
    new_cantons        = data$cantons - data_yesterday$cantons
  )

  keyFigures <- list(
    "positive_cases" = HTML(paste(format(data$positive_cases, big.mark = " "), sprintf("<h4>(%+.1f %%)</h4>", data_new$new_positive_cases))),
    "deceased"       = HTML(paste(format(data$deceased, big.mark = " "), sprintf("<h4>(%+.1f %%)</h4>", data_new$new_deceased))),
    "cantons"        = HTML(paste(format(data$cantons, big.mark = " "), "/ 26", sprintf("<h4>(%+d)</h4>", data_new$new_cantons)))
  )
  return(keyFigures)
})

output$valueBox_positive_cases <- renderValueBox({
  valueBox(
    key_figures()$positive_cases,
    subtitle = HTML("Positive F&auml;lle"),
    icon     = icon("file-medical"),
    color    = "light-blue",
    width    = NULL
  )
})

output$valueBox_deceased <- renderValueBox({
  valueBox(
    key_figures()$deceased,
    subtitle = "Verstorben",
    icon     = icon("heartbeat"),
    color    = "light-blue"
  )
})

output$valueBox_cantons <- renderValueBox({
  valueBox(
    key_figures()$cantons,
    subtitle = "Betroffene Kantone",
    icon     = icon("flag"),
    color    = "light-blue"
  )
})

output$box_keyFigures <- renderUI(box(
  title = paste0("Kennzahlen (", strftime(input$timeSlider, format = "%d.%m.%Y"), ")"),
  fluidRow(
    column(
      valueBoxOutput("valueBox_positive_cases", width = 4),
      valueBoxOutput("valueBox_deceased", width = 4),
      valueBoxOutput("valueBox_cantons", width = 4),
      width = 12,
      style = "margin-left: -20px"
    )
  ),
  div("Letztes Update: ", strftime(changed_date, format = "%d.%m.%Y - %R %Z")),
  width = 12
))