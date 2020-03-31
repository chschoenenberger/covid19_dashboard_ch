server <- function(input, output, session) {
  sourceDirectory("sections", recursive = TRUE)

  # Trigger once an hour
  dataLoadingTrigger <- reactiveTimer(3600000)

  observeEvent(dataLoadingTrigger, {
    updateData()
  })

  observe({
    data <- data_atDate(input$timeSlider)
  })
  
  #make dynamic slider
  observe({
    val <- input$timeSlider
    # Control the value, min, max, and step.
    # Step size is 2 when input value is even; 1 when value is odd.
    updateSliderInput(session, "overviewSlider", value = val,
                      min = min(data_evolution$date, na.rm = T), 
                      max = max(data_evolution$date, na.rm = T),
                      timeFormat = "%d.%m.%Y")
  })
  observe({
    val <- input$overviewSlider
    # Control the value, min, max, and step.
    # Step size is 2 when input value is even; 1 when value is odd.
    updateSliderInput(session, "timeSlider", value = val,
                      min = min(data_evolution$date, na.rm = T), 
                      max = max(data_evolution$date, na.rm = T),
                      timeFormat = "%d.%m.%Y")
  })
  
  #update date in table title
  output$selected_date <- renderText({strftime(input$timeSlider, format = "%d.%m.%Y")}) 
}
