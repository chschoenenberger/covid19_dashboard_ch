library("htmltools")

addLabel <- function(data) {
  data$label <- paste0(
    '<b>', data$name, '</b><br>
    <table style="width:120px;">
    <tr><td>Positive F&auml;lle:</td><td align="right">', data$positive_cases, '</td></tr>
    <tr><td>Genesen (gesch&auml;tzt):</td><td align="right">', data$recovered, '</td></tr>
    <tr><td>Verstorben:</td><td align="right">', data$deceased, '</td></tr>
    <tr><td>Aktive F&auml;lle:</td><td align="right">', data$active, '</td></tr>
    </table>'
  )
  data$label <- lapply(data$label, HTML)

  return(data)
}

map <- leaflet(addLabel(data_latest)) %>%
  setView(8.231944, 46.798333, zoom = 7) %>%
  addTiles() %>%
  addProviderTiles(providers$CartoDB.Positron, group = "Hell") %>%
  addProviderTiles(providers$HERE.satelliteDay, group = "Satellit") %>%
  addLayersControl(
    baseGroups    = c("Hell", "Satellit"),
    overlayGroups = c("Positive F&auml;lle", "Positive F&auml;lle (pro 100'000 Einwohner)",
      "Genesene F&auml;lle (gesch&auml;tzt)", "Verstorben", "Aktive F&auml;lle",
      "Aktive F&auml;lle (pro 100'000 Einwohner)")
  ) %>%
  hideGroup(HTML("Positive F&auml;lle (pro 100'000 Einwohner)")) %>%
  hideGroup("Genesene F&auml;lle (gesch&auml;tzt)") %>%
  hideGroup("Verstorben") %>%
  hideGroup("Aktive F&auml;lle") %>%
  hideGroup("Aktive F&auml;lle (pro 100'000 Einwohner)") %>%
  addEasyButton(easyButton(
    icon    = "glyphicon glyphicon-globe", title = "Gesamte Schweiz",
    onClick = JS("function(btn, map){ map.setView([46.798333, 8.231944], 7); }"))) %>%
  addEasyButton(easyButton(
    icon    = "glyphicon glyphicon-map-marker", title = "Locate Me",
    onClick = JS("function(btn, map){ map.locate({setView: true, maxZoom: 9}); }")))

observe({
  req(input$timeSlider, input$overview_map_zoom)
  zoomLevel                    <- input$overview_map_zoom
  data                         <- data_atDate(input$timeSlider) %>% addLabel()
  data$positive_casesPerCapita <- data$positive_cases / data$population * 100000
  data$activePerCapita         <- data$active / data$population * 100000

  leafletProxy("overview_map", data = data) %>%
    clearMarkers() %>%
    addCircleMarkers(
      lng          = ~long,
      lat          = ~lat,
      radius       = ~log(positive_cases^(zoomLevel / 2)),
      stroke       = FALSE,
      fillOpacity  = 0.5,
      label        = ~label,
      labelOptions = labelOptions(textsize = 15),
      group        = "Positive F&auml;lle"
    ) %>%
    addCircleMarkers(
      lng          = ~long,
      lat          = ~lat,
      radius       = ~log(positive_casesPerCapita^(zoomLevel / 2)),
      stroke       = FALSE,
      color        = "#00b3ff",
      fillOpacity  = 0.5,
      label        = ~label,
      labelOptions = labelOptions(textsize = 15),
      group        = "Positive F&auml;lle (pro 100'000 Einwohner)"
    ) %>%
    addCircleMarkers(
      lng          = ~long,
      lat          = ~lat,
      radius       = ~log(recovered^(zoomLevel / 2)),
      stroke       = FALSE,
      color        = "#005900",
      fillOpacity  = 0.5,
      label        = ~label,
      labelOptions = labelOptions(textsize = 15),
      group        = "Genesene F&auml;lle (gesch&auml;tzt)"
    ) %>%
    addCircleMarkers(
      lng          = ~long,
      lat          = ~lat,
      radius       = ~log(deceased^(zoomLevel)),
      stroke       = FALSE,
      color        = "#E7590B",
      fillOpacity  = 0.5,
      label        = ~label,
      labelOptions = labelOptions(textsize = 15),
      group        = "Verstorben"
    ) %>%
    addCircleMarkers(
      lng          = ~long,
      lat          = ~lat,
      radius       = ~log(active^(zoomLevel / 2)),
      stroke       = FALSE,
      color        = "#f49e19",
      fillOpacity  = 0.5,
      label        = ~label,
      labelOptions = labelOptions(textsize = 15),
      group        = "Aktive F&auml;lle"
    ) %>%
    addCircleMarkers(
      lng          = ~long,
      lat          = ~lat,
      radius       = ~log(activePerCapita^(zoomLevel / 2)),
      stroke       = FALSE,
      color        = "#f4d519",
      fillOpacity  = 0.5,
      label        = ~label,
      labelOptions = labelOptions(textsize = 15),
      group = "Aktive F&auml;lle (pro 100'000 Einwohner)"
    )
})

output$overview_map <- renderLeaflet(map)


