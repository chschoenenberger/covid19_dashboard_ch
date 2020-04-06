body_fullTable <- dashboardBody(
  tags$head(
    tags$style(type = "text/css", ".legend { list-style: none; margin-left: -25px;}"),
    tags$style(type = "text/css", ".legend li { float: left; margin-right: 10px; position: relative; }"),
    tags$style(type = "text/css", ".legend span { border: 1px solid #ccc; float: left; width: 30px; height: 15px;
    margin-right: 5px; margin-top: 1px; position: relative;"),
    tags$style(type = "text/css", ".legend .pos1 { background-color: #FFFFFF; }"),
    tags$style(type = "text/css", ".legend .pos2 { background-color: #FFE5E5; }"),
    tags$style(type = "text/css", ".legend .pos3 { background-color: #FFB2B2; }"),
    tags$style(type = "text/css", ".legend .pos4 { background-color: #FF7F7F; }"),
    tags$style(type = "text/css", ".legend .pos5 { background-color: #FF4C4C; }"),
    tags$style(type = "text/css", ".legend .pos6 { background-color: #983232; }"),
    tags$style(type = "text/css", ".legend .neg1 { background-color: #FFFFFF; }"),
    tags$style(type = "text/css", ".legend .neg2 { background-color: #CCE4CC; }"),
    tags$style(type = "text/css", ".legend .neg3 { background-color: #99CA99; }"),
    tags$style(type = "text/css", ".legend .neg4 { background-color: #66B066; }")
  ),
  fluidPage(
    fluidRow(
      h3(HTML(paste0("&Uuml;bersichtstabelle - ", textOutput("selected_date", inline = T))),
        class = "box-title", style = "margin-top: 10px; font-size: 18px;"),
      div(
        dataTableOutput("fullTable"),
        style = "margin-top: -30px"
      ),
      div(
        tags$h5("Wachstumsrate", style = "margin-left: 15px;"),
        tags$ul(class = "legend",
          tags$li(tags$span(class = "pos1"), " 0 % bis 10 %"),
          tags$li(tags$span(class = "pos2"), "10 % bis 20 %"),
          tags$li(tags$span(class = "pos3"), "20 % bis 33 %"),
          tags$li(tags$span(class = "pos4"), "33 % bis 50 %"),
          tags$li(tags$span(class = "pos5"), "50 % bis 75 %"),
          tags$li(tags$span(class = "pos6"), "> 75 %"),
          tags$br()
        )
      ),
      width = 12
    ),
    fluidRow(
      column(
        sliderInput(
          "overviewSlider",
          label      = HTML("Datum ausw&auml;hlen"),
          min        = min(data_evolution$date, na.rm = T),
          max        = max(data_evolution$date, na.rm = T),
          value      = max(data_evolution$date, na.rm = T),
          width      = "100%",
          timeFormat = "%d.%m.%Y",
          animate    = animationOptions(loop = TRUE)
        ),
        width = 12,
        style = 'padding-left:15px; padding-right:15px;'
      )
    )
  )
)

page_fullTable <- dashboardPage(
  title   = "Full Table",
  header  = dashboardHeader(disable = TRUE),
  sidebar = dashboardSidebar(disable = TRUE),
  body    = body_fullTable
)
