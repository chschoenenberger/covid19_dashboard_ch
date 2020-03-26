output$summaryTables <- renderUI({
  dataTableOutput("summaryDT_canton")
})

output$summaryDT_canton <- renderDataTable(getSummaryDT(data_atDate(current_date), "name", selectable = TRUE))
proxy_summaryDT_canton  <- dataTableProxy("summaryDT_canton")

observeEvent(input$timeSlider, {
  data <- data_atDate(input$timeSlider) %>%
    select(name, positive_cases, deceased, active)
  replaceData(proxy_summaryDT_canton, data, rownames = FALSE)
}, ignoreInit = TRUE, ignoreNULL = TRUE)

observeEvent(input$summaryDT_canton_row_last_clicked, {
  selectedRow    <- input$summaryDT_canton_row_last_clicked
  selectedCanton <- unlist(data_atDate(input$timeSlider)[selectedRow, "name"])
  location       <- data_evolution %>%
    distinct(name, lat, long) %>%
    filter(name == selectedCanton) %>%
    summarise(
      lat  = mean(lat),
      long = mean(long)
    )
  leafletProxy("overview_map") %>%
    setView(lng = location$long, lat = location$lat, zoom = 8)
})

getSummaryDT <- function(data, groupBy, selectable = FALSE) {
  data <- data_atDate(current_date) %>%
    select(name, positive_cases, deceased, active)
  datatable(
    na.omit(data),
    rownames  = FALSE,
    colnames = c("Kanton", "Positiv", "Verstorben", "Aktiv"),
    options   = list(
      order          = list(1, "desc"),
      scrollX        = TRUE,
      scrollY        = "40vh",
      scrollCollapse = T,
      dom            = 'ft',
      paging         = FALSE
    ),
    selection = ifelse(selectable, "single", "none")
  )
}