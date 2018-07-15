# ------ ui.R ------
library(shinydashboard)

#make sure working directory is set to parent folder - use setwd()
source(paste0(getwd(),"/queries.R"))


dashboardPage(skin = "black",
  dashboardHeader(title = "Softcite"),
  dashboardSidebar(
    # Sidebar Menu - contains menuItems, which are each associated with info pages
    sidebarMenu(
      menuItem("Project Status", tabName = "projectStatus", icon = icon("tasks", lib = "glyphicon")),
      menuItem("Missing Work", tabName = "missingWork", icon = icon("folder-open", lib = "glyphicon")),
      menuItem("Mention Analysis", tabName = "mentionAnalysis", icon = icon("align-left", lib = "glyphicon")),
      menuItem("Coder Information", tabName = "coderInfo", icon = icon("user", lib = "glyphicon"))
    )
  ),
  dashboardBody(
    #tabItems are pages associated with menuItems
    tabItems(
      tabItem(tabName = "projectStatus",
        # Boxes use row orientation
        fluidRow(
          #ouput stats as defined in server.r
          valueBoxOutput("numArticles"),
          valueBoxOutput("numCoders"),
          valueBoxOutput("numMentions"),
          box(title = "Articles Assigned By Coder",
              plotOutput("assignedByCoder")),
          box(title = "Cumulative Articles Assigned",
              plotOutput("progressPlot"))
        )
      ),
      tabItem(tabName = "missingWork",
        fluidRow(
          valueBoxOutput("pctCoded"),
          box(title = "Missing Work By Coder",
              plotOutput("missingByCoder"))
        )
      ),
      tabItem(tabName = "mentionAnalysis",
        fluidRow(
          box(title = "Mention Composition",
              plotOutput("mentionCompositions")
          ),
          box(title = "Software Names by Number of Mentions",
              plotOutput("softwareNamesChart")
          )
        )
      ),
      tabItem(tabName = "coderInfo",
              fluidRow(
                #selectInput allows viewer to choose a coders name to view personalized productivity stats
                selectInput("coderInput","Select a coder",
                            choices = getCoders()
                            ),
                valueBoxOutput("codedByCoder"),
                plotOutput("cumAssignedByCoder")
              )
      )
    )
  )
)
