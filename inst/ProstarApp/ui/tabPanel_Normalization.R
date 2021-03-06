tabPanel("Normalization",
         value = "Normalization",
         sidebarCustom(),
         splitLayout(cellWidths = c(widthLeftPanel, widthRightPanel),
                     wellPanel(id = "sidebar_Normalization"
                               ,height = "100%"
                               ,h4("Normalization options")
                               ,uiOutput("choose_Normalization_Test")
                               ,uiOutput("choose_normalizationType")
                               ,uiOutput("choose_normalizationScaling")
                               ,uiOutput("choose_normalizationQuantile")
                               ,uiOutput("choose_normalizationQuantileOther")
                               ,checkboxInput("plotOptions", "Show plot options", 
                                              value = FALSE)
                               ,actionButton("perform.normalization", 
                                             "Perform normalization", 
                                             width="170px")
                               ,br(),br()
                               ,actionButton("valid.normalization",
                                             "Save normalization",
                                             width="170px")
                     )
                     ,conditionalPanel(id = "wellPanlNormalization",
                                       condition = "true",
                                       uiOutput("helpForNormalizationMethods"),
                                       #plotOutput("viewBoxPlotNorm")
                                       fluidRow(
                                           column(width=6, highchartOutput("viewDensityplotNorm")),
                                           column(width=6, plotOutput("viewComparisonNorm"))),
                                       plotOutput("viewBoxPlotNorm")
                     )
         ),
         tags$head(
             tags$style(type="text/css", 
                        "#AbsolutePanelPlotOptions {
                        background-color:transparent;"
             )
             ),
         absolutePanel(id  = "AbsolutePanelPlotOptions",
                       top = 200,
                       right = 50,
                       width = "200px",
                       height = "50px",
                       draggable = TRUE,
                       fixed = FALSE,
                       cursor = "move",
                       uiOutput("AbsShowOptions")
         )
         )