tabPanel("Open MSnset file",
         value = "open",
         sidebarCustom(),
         splitLayout(cellWidths = c(widthLeftPanel, widthRightPanel),
                     wellPanel(id = "wellPanelFileOpen"
                               ,fileInput("file", 
                                          "Open a MSnset file",
                                          multiple = FALSE)
                     ),
                     conditionalPanel(id = "wellPanelOpenFile",
                                      condition = "true",
                                      h3("Quick overview of the dataset"),
                                      uiOutput("overview"),
                                      uiOutput("infoAboutAggregationTool")
                     )
         )
)