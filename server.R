#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
#make sure working directory is set to parent folder - use setwd()
source(paste0(getwd(),"/queries.R"))


## Server Logic
  ## Defines output values and visualizations
shinyServer(function(input, output) {
  output$num_articles <- renderValueBox({
      valueBox(
        getNumArticles(), "Unique Articles Analyzed", icon = icon("list-alt", lib = "glyphicon"),
        color = "yellow"
      )
  })
  output$num_coders <- renderValueBox({
    valueBox(
      getNumCoders(), "Contributing Coders", icon = icon("user", lib = "glyphicon"),
      color = "purple"
    )
  })
  output$num_mentions <- renderValueBox({
    valueBox(
      getNumMentions(), "Software Mentions Found", icon = icon("ok",lib = "glyphicon"),
      color = "blue"
    )
  })
  output$pct_coded <- renderValueBox({
    valueBox(
      getPctAssignedCoded(), "of assigned articles coded", icon = icon("check", lib = "glyphicon"),
      color = "yellow"
    )
  })
  output$codedByCoder <- renderValueBox({
      if(!is.null(input$coderInput)){
        valueBox(
          getNumArticlesByCoder(input$coderInput), paste("articles coded by ",input$coderInput), icon = icon("user", lib = "glyphicon"),
          color = "yellow"
        )
      }
  })
  
  
  #Barplot descibing aspects of mentions
  #Would this look better as multiple pie plots??
  output$mention_compositions <- renderPlot({
    data <- c(getFracNames(), getFracVersions(), getFracUrls())
    par(mar=c(5,8,4,2)) # increase y-axis margin.
    barplot(data, names.arg=c("Software\nName", "Version\nNumber", "URL"),
            xlab = "Mention Characteristic",
            ylab = "Fraction of Total Mentions with Characteristic")
  })

  #Barplot of 10 most common software names
  output$software_names_chart <- renderPlot({
    data <- getMostCommonSoftware()
    par(las=2) # make label text perpendicular to axis
    par(mar=c(5,8,4,2)) # increase y-axis margin.
    barplot(data, horiz = TRUE,
            xlab = "Amount of References")
            #ylab = "Software Name")
  })
  output$missing_by_coder <- renderPlot({
    data <- getArticlesMissingByCoder()
    par(las=2) # make label text perpendicular to axis
    par(mar=c(5,8,4,2)) # increase y-axis margin.
    barplot(unlist(data$num_missing[0:5]), names.arg = unlist(data$coder[0:5]), horiz = TRUE,
            xlab = "Number of missing articles")
  })
  output$assigned_by_coder <- renderPlot({
    data <- getAssignmentsByCoder()
    par(las=2) # make label text perpendicular to axis
    par(mar=c(5,8,4,2)) # increase y-axis margin.
    barplot(unlist(data$num_missing[0:10]),
            col = rainbow(25),
            xlim=c(0,500),
            names.arg = unlist(data$coder[0:10]),
            horiz = TRUE,
            xlab = "Total Articles Assigned")
  })
})
