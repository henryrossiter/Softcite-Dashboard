## ui.R ##
library(shinydashboard)

#make sure working directory is set to parent folder - use setwd()
source(paste0(getwd(),"/queries.R"))


dashboardPage(skin = "black",
  dashboardHeader(title = "Softcite"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Project Status", tabName = "projectStatus", icon = icon("tasks", lib = "glyphicon")),
      menuItem("Missing Work", tabName = "missingWork", icon = icon("folder-open", lib = "glyphicon")),
      menuItem("Mention Analysis", tabName = "mentionAnalysis", icon = icon("align-left", lib = "glyphicon")),
      menuItem("Coder Information", tabName = "coderInfo", icon = icon("user", lib = "glyphicon"))
    )
  ),
  dashboardBody(
    tabItems(
      tabItem(tabName = "projectStatus",
        # Boxes use row orientation
        fluidRow(
          #ouput stats as defined in server.r
          valueBoxOutput("num_articles"),
          valueBoxOutput("num_coders"),
          valueBoxOutput("num_mentions"),
          box(title = "Articles Assigned By Coder",
              plotOutput("assigned_by_coder"))
        )
      ),
      tabItem(tabName = "missingWork",
        fluidRow(
          valueBoxOutput("pct_coded"),
          box(title = "Missing Work By Coder",
              plotOutput("missing_by_coder"))
        )
      ),
      tabItem(tabName = "mentionAnalysis",
        fluidRow(
          box(title = "Mention Composition",
              plotOutput("mention_compositions")
          ),
          box(title = "Software Names by Number of Mentions",
              plotOutput("software_names_chart")
          )
        )
      ),
      tabItem(tabName = "coderInfo",
              fluidRow(
                selectInput("coderInput","Select a coder",
                            choices = getCoders(),
                            selected = "henryrossiter"),
                valueBoxOutput("codedByCoder")
              )
      )
    )
  )
)
