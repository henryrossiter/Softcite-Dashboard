# ------ Server.R ------

#make sure working directory is set to parent folder - use setwd()
source(paste0(getwd(),"/queries.R"))


# ------ Server Logic - defines output values and visualizations ------
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
      #if a coder has been selected from 'coderInput' selectInput in UI
      if(!is.null(input$coderInput)){
        valueBox(
          #valuebox displays total articles coded by whichever coder is chosen in dropdown
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
            col = rainbow(25),
            xlab = "Mention Characteristic",
            ylab = "Fraction of Total Mentions with Characteristic")
  })

  #Barplot of 10 most common software names
  output$software_names_chart <- renderPlot({
    data <- getMostCommonSoftware()
    par(las=2) # make label text perpendicular to axis
    par(mar=c(5,8,4,2)) # increase y-axis margin.
    barplot(data, horiz = TRUE,
            col = rainbow(25),
            xlab = "Amount of References")
  })
  #Barplot of missing articles by coder
  output$missing_by_coder <- renderPlot({
    data <- getArticlesMissingByCoder()
    par(las=2) # make label text perpendicular to axis
    par(mar=c(5,8,4,2)) # increase y-axis margin.
    barplot(unlist(data$num_missing[0:5]), names.arg = unlist(data$coder[0:5]), horiz = TRUE,
            col = rainbow(25),
            xlab = "Number of missing articles")
  })
  #Barplots of articles assigned by coder
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
