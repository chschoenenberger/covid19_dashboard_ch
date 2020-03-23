getFullTableData <- function() {
  padding_left <- max(str_length(data_evolution$positive_cases))
  data <- data_evolution %>%
    filter(date == current_date) %>%
    select(-date, -lat, -long, -canton) %>%
    add_row(
      "canton_name"        = "Schweiz",
      "positive_cases"     = sum(.$positive_cases),
      "deceased"           = sum(.$deceased),
      "population"         = 8570000,
      "active"             = sum(.$active),
      "positive_cases_new" = sum(.$positive_cases_new),
      "deceased_new"       = sum(.$deceased_new),
      "active_new"         = sum(.$active_new),
    ) %>%
    mutate(
      positive_casesNorm = round(positive_cases / population * 100000, 2),
      activeNorm         = round(active / population * 100000, 2)
    ) %>%
    mutate(
      "positive_cases_newPer" = positive_cases_new / (positive_cases - positive_cases_new) * 100,
      "deceased_newPer"  = deceased_new / (deceased - deceased_new) * 100,
      "active_newPer"    = active_new / (active - active_new) * 100
    ) %>%
    mutate_at(vars(contains('_newPer')), list(~na_if(., Inf))) %>%
    mutate_at(vars(contains('_newPer')), list(~na_if(., 0))) %>%
    mutate(
      positive_cases_new = str_c(str_pad(positive_cases_new, width = padding_left, side = "left", pad = "0"), "|",
        positive_cases_new, if_else(!is.na(positive_cases_newPer), sprintf(" (%+.2f %%)", positive_cases_newPer), "")),
      deceased_new  = str_c(str_pad(deceased_new, width = padding_left, side = "left", pad = "0"), "|",
        deceased_new, if_else(!is.na(deceased_newPer), sprintf(" (%+.2f %%)", deceased_newPer), "")),
      active_new    = str_c(str_pad(active_new, width = padding_left, side = "left", pad = "0"), "|",
        active_new, if_else(!is.na(active_newPer), sprintf(" (%+.2f %%)", active_newPer), ""))
    ) %>%
    select(-population) %>%
    select(canton_name, positive_cases, positive_cases_new, positive_casesNorm, deceased, deceased_new,
      active, active_new, activeNorm, positive_cases_newPer, deceased_newPer, active_newPer)
}

output$fullTable <- renderDataTable({
  data       <- getFullTableData()
  columNames <- c(
    "Kanton",
    "Total Positive F&auml;lle",
    "Neue Positive F&auml;lle",
    "Total Positive F&auml;lle <br>(pro 100'000 Einwohner)",
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
      order          = list(6, "desc"),
      scrollX        = TRUE,
      scrollY        = "calc(100vh - 250px)",
      scrollCollapse = TRUE,
      dom            = "ft",
      server         = FALSE,
      columnDefs     = list(
        list(
          targets = c(2, 5, 7),
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
        list(visible = FALSE, targets = 9:11)
      )
    )
  ) %>%
    formatStyle(
      columns    = "canton_name",
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
      columns         = "active_new",
      valueColumns    = "active_newPer",
      backgroundColor = styleInterval(c(10, 20, 33, 50, 75), c("#FFFFFF", "#FFE5E5", "#FFB2B2", "#FF7F7F", "#FF4C4C", "#983232")),
      color           = styleInterval(75, c("#000000", "#FFFFFF"))
    )
})