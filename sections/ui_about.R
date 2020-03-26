body_about <- dashboardBody(
  fluidRow(
    fluidRow(
      column(
        box(
          title = div(HTML("&Uuml;ber dieses Projekt"), style = "padding-left: 20px", class = "h2"),
          column(
            HTML("Dieses Dashboard zeigt die j&uuml;ngsten Entwicklungen der COVID-19-Pandemie in der Schweiz. Die neuesten
            Daten zur COVID-19-Verbreitung werden regelm&auml;ssig heruntergeladen und mit Hilfe einer Karte,
            zusammenfassenden Tabellen, Schl&uuml;sselzahlen und Diagrammen visualisiert. Urspr&uuml;nglich wurde ein"),
            tags$a(href = "https://chschoenenberger.shinyapps.io/covid19_dashboard/", "globales Dashboard"),
            HTML("entwickelt. Dieses wurde nun f&uuml;r die Schweiz angepasst."),
            tags$br(),
            h3("Motivation"),
            HTML("Verschiedene Unternehmen waren der Meinung, dass eine globale Krise eine ausgezeichnete Gelegenheit ist, um
            ihre Technologien zu pr&auml;sentieren. Daher war meine Idee, zu zeigen, dass Open-Source
            Technologien, wie z.B. R Shiny, verwendet werden k&ouml;nnen, um in wenigen Stunden ein Dashboard zu erstellen.
            Dar&uuml;ber hinaus ist das beliebteste COVID-19-Dashboard ("),
            tags$a(href = "https://coronavirus.jhu.edu/map.html", "Johns Hopkins COVID-19"), HTML(") eher alarmierend gestaltet.
            Ein neutraleres Dashboard k&ouml;nnte daher helfen, die bereits bestehende Hysterie etwas zu d&auml;mpfen."),
            h4("Wieso Open Source?"),
            HTML("Ich hoffe, dass dieses Dashboard Forschenden in der Schweiz und auf der ganzen Welt helfen kann, einen
            besseren &Uuml;berblick &uuml;ber die aktuelle COVID-19-Idee Situation zu erhalten. Ich lade hiermit alle ein, mit
            zus&auml;tzlichen Visualisierungen, Informationen usw. zu diesem Projekt beizutragen."),
            tags$br(),
            tags$br(),
            HTML("Finden Sie mehr Gedanken von Christoph Sch&ouml;nenberger zu diesem Thema in diesem"),
            tags$a(href = "https://medium.com/@ch.schoenenberger/covid-19-open-source-dashboard-fa1d2b4cd985",
              "Medium Artikel"), ".",
            h3("Daten"),
            HTML("Die COVID-19 Daten f&uuml;r die Schweiz werden vom"), tags$a(href = "https://statistik.zh.ch/internet/justiz_inneres/statistik/de/home.html",
              HTML("Statistischen Amt des Kanton Z&uuml;rich")),
            HTML("mehrmals t&auml;glich von verschiedenen Quellen zusammengetragen und auf"),
            tags$a(href = "https://github.com/openZH/covid_19", "Github"), HTML("ver&ouml;ffentlicht.
            Herzlichen Dank an dieser Stelle f&uuml;r die grossartige Arbeit!<br>
            Hinweis: F&uuml;r die Schweiz gibt es momentan keine Daten zu den geheilten F&auml;llen. Daher werden diese
            wie folgt gesch&auml;tzt: <i>Bekannten F&auml;lle vor zwei Wochen - aktuelle Verstorben</i>."),
            h3(HTML("Bugs, Probleme & Erweiterungsw&uuml;nsche")),
            HTML("Wenn Sie einen Fehler / ein Problem finden oder eine Idee haben, wie das Dashboard verbessert werden k&ouml;nnte,
            erstellen Sie bitte ein Problem auf"), tags$a(href = "https://github.com/chschoenenberger/covid19_dashboard_ch/issues",
              "Github"), HTML(". Ich werde versuchen, dem so schnell wie m&ouml;glich nachzugehen."),
            h3("Beitragen"),
            HTML("Wenn Sie eine Visualisierung oder weitere Informationen hinzuf&uuml;gen m&ouml;chten, k&ouml;nnen Sie auf"),
            tags$a(href = "https://github.com/chschoenenberger/covid19_dashboard_ch", "Github"), HTML("einen Pull-Request
            erstellen. Bei gr&ouml;sseren &Uuml;berarbeitungen bitte entweder das Repository forken oder ein Issue er&ouml;ffnen, damit wir es
            diskutieren k&ouml;nnen."),
            h3("Entwicklung"),
            HTML("Christoph Sch&ouml;nenberger | Data Scientist @"),
            tags$a(href = "https://www.zuehlke.com/ch/en/", HTML("Z&uuml;hlke Engineering AG")), "|",
            tags$a(href = "https://www.linkedin.com/in/cschonenberger/", "LinkedIn"), "|",
            tags$a(href = "https://twitter.com/ChSchonenberger", "Twitter"), "|",
            tags$a(href = "https://github.com/chschoenenberger/", "Github"),
            width = 12,
            style = "padding-left: 20px; padding-right: 20px; padding-bottom: 40px; margin-top: -15px;"
          ),
          width = 6,
        ),
        width = 12,
        style = "padding: 15px"
      )
    )
  )
)

page_about <- dashboardPage(
  title   = "About",
  header  = dashboardHeader(disable = TRUE),
  sidebar = dashboardSidebar(disable = TRUE),
  body    = body_about
)