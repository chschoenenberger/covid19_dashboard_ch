getFullTableData <- function(selectedDate) {
  padding_left  <- max(str_length(data_evolution$positive_cases))
  data_selected <- data_atDate(selectedDate)
  data          <- data_evolution %>%
    filter(date == selectedDate) %>%
    select(-date, -lat, -long, -canton) %>%
    add_row(
      "name"               = "Schweiz",
      "ncumul_tested"      = sum(data_selected[data_selected$name != "Liechtenstein", "ncumul_tested"], na.rm = T),
      "positive_cases"     = sum(data_selected[data_selected$name != "Liechtenstein", "positive_cases"], na.rm = T),
      "current_hosp"       = sum(data_selected[data_selected$name != "Liechtenstein", "current_hosp"], na.rm = T),
      "current_icu"        = sum(data_selected[data_selected$name != "Liechtenstein", "current_icu"], na.rm = T),
      "current_vent"       = sum(data_selected[data_selected$name != "Liechtenstein", "current_vent"], na.rm = T),
      "recovered"          = sum(data_selected[data_selected$name != "Liechtenstein", "recovered"], na.rm = T),
      "deceased"           = sum(data_selected[data_selected$name != "Liechtenstein", "deceased"], na.rm = T),
      "population"         = 8570000,
      "active"             = sum(data_selected[data_selected$name != "Liechtenstein", "active"], na.rm = T),
      "positive_cases_new" = sum(data_selected[data_selected$name != "Liechtenstein", "positive_cases_new"], na.rm = T),
      "recovered_new"      = sum(data_selected[data_selected$name != "Liechtenstein", "recovered_new"], na.rm = T),
      "deceased_new"       = sum(data_selected[data_selected$name != "Liechtenstein", "deceased_new"], na.rm = T),
      "active_new"         = sum(data_selected[data_selected$name != "Liechtenstein", "active_new"], na.rm = T),
    ) %>%
    mutate(
      positive_casesNorm = round(positive_cases / population * 100000, 2),
      activeNorm         = round(active / population * 100000, 2)
    ) %>%
    mutate(
      "positive_cases_newPer" = positive_cases_new / (positive_cases - positive_cases_new) * 100,
      "recovered_newPer"      = recovered_new / (recovered - recovered_new) * 100,
      "deceased_newPer"       = deceased_new / (deceased - deceased_new) * 100,
      "active_newPer"         = active_new / (active - active_new) * 100
    ) %>%
    mutate_at(vars(contains('_newPer')), list(~na_if(., Inf))) %>%
    mutate_at(vars(contains('_newPer')), list(~na_if(., 0))) %>%
    mutate(
      positive_cases_new = str_c(str_pad(positive_cases_new, width = padding_left, side = "left", pad = "0"), "|",
        positive_cases_new, if_else(!is.na(positive_cases_newPer), sprintf(" (%+.2f %%)", positive_cases_newPer), "")),
      recovered_new      = str_c(str_pad(recovered_new, width = padding_left, side = "left", pad = "0"), "|",
        recovered_new, if_else(!is.na(recovered_newPer), sprintf(" (%+.2f %%)", recovered_newPer), "")),
      deceased_new       = str_c(str_pad(deceased_new, width = padding_left, side = "left", pad = "0"), "|",
        deceased_new, if_else(!is.na(deceased_newPer), sprintf(" (%+.2f %%)", deceased_newPer), "")),
      active_new         = str_c(str_pad(active_new, width = padding_left, side = "left", pad = "0"), "|",
        active_new, if_else(!is.na(active_newPer), sprintf(" (%+.2f %%)", active_newPer), ""))
    ) %>%
    select(-population) %>%
    select(name, ncumul_tested, positive_cases, positive_cases_new, positive_casesNorm, current_hosp, current_icu, current_vent,
      recovered, recovered_new, deceased, deceased_new, active, active_new, activeNorm, positive_cases_newPer,
      recovered_newPer, deceased_newPer, active_newPer)
}

output$fullTable <- renderDataTable({
  data       <- getFullTableData(selectedDate = input$timeSlider)
  columNames <- c(
    "Kanton",
    "Total Tests",
    "Total Positive F&auml;lle",
    "Neue Positive F&auml;lle",
    "Total Positive F&auml;lle <br>(pro 100'000 Einwohner)",
    "Hospitalisiert",
    "Intensivstation",
    "K&uuml;nstlich beatmet",
    "Total Genesene F&auml;lle (gesch&auml;tzt)",
    "Neue Genesene F&auml;lle (gesch&auml;tzt)",
    "Total Verstorben",
    "Neu Verstorben",
    "Total Aktive F&auml;lle",
    "Neue Aktive F&auml;lle",
    "Total Aktive F&auml;lle <br>(pro 100'000 Einwohner)")
  datatable(
    data,
    rownames  = FALSE,
    colnames  = columNames,
    escape    = FALSE,
    selection = "none",
    options   = list(
      pageLength     = -1,
      order          = list(12, "desc"),
      scrollX        = TRUE,
      scrollY        = "57vh",
      scrollCollapse = TRUE,
      dom            = "ft",
      server         = FALSE,
      columnDefs     = list(
        list(
          targets = c(3, 9, 11, 13),
          render  = JS(
            "function(data, type, row, meta) {
                split = data.split('|')
                if (type == 'display') {
                  return split[1];
                } else {
                  return split[0];
                }
            }"
          )
        ),
        list(className = 'dt-right', targets = 1:ncol(data) - 1),
        list(width = '100px', targets = 0),
        list(visible = FALSE, targets = 15:18)
      )
    )
  ) %>%
    formatStyle(
      columns    = "name",
      fontWeight = "bold"
    ) %>%
    formatStyle(
      columns         = "positive_cases_new",
      valueColumns    = "positive_cases_newPer",
      backgroundColor = styleInterval(c(10, 20, 33, 50, 75), c("#FFFFFF", "#FFE5E5", "#FFB2B2", "#FF7F7F", "#FF4C4C", "#983232")),
      color           = styleInterval(75, c("#000000", "#FFFFFF"))
    ) %>%
    formatStyle(
      columns         = "deceased_new",
      valueColumns    = "deceased_newPer",
      backgroundColor = styleInterval(c(10, 20, 33, 50, 75), c("#FFFFFF", "#FFE5E5", "#FFB2B2", "#FF7F7F", "#FF4C4C", "#983232")),
      color           = styleInterval(75, c("#000000", "#FFFFFF"))
    ) %>%
    formatStyle(
      columns         = "recovered_new",
      valueColumns    = "recovered_newPer",
      backgroundColor = styleInterval(c(10, 20, 33), c("NULL", "#CCE4CC", "#99CA99", "#66B066"))
    ) %>%
    formatStyle(
      columns         = "active_new",
      valueColumns    = "active_newPer",
      backgroundColor = styleInterval(c(10, 20, 33, 50, 75), c("#FFFFFF", "#FFE5E5", "#FFB2B2", "#FF7F7F", "#FF4C4C", "#983232")),
      color           = styleInterval(75, c("#000000", "#FFFFFF"))
    )
})