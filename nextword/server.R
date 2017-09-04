#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(ggplot2)
source("predictions.R", local = TRUE)

# Define server logic required to draw a histogram
shinyServer(function(input, output, session) {
   
  # Display the sentence typed in the side panel
  output$display <- renderText({
    input$sentence
  })
  
  # Getting the results of the prediction; to use results type "results()"
  results <- reactive({
   predict_text(input$sentence)
  })
  
  # Get the prediction results from "results()" on click of button
  predictions <- eventReactive(input$get,{
    predict_text(input$sentence)
  })
  
  # On "Get suggestions" button click and change in input sentence, uncheck check box
  observe({
    input$get
    input$sentence
    updateCheckboxInput(session, "check", label = "Show plots", value = FALSE)
  })
  
  
  # Display the predicted next words
  output$suggestions <- renderText({
   if(grepl("^\\s*$", input$sentence)){ # check for empty string or whitespaces
      "Enter a word or phrase to get word suggestions!"
    }else{
      myresults <- predictions() # because this is event reactive on button click
      myresults <- myresults$last
      if("i" %in% myresults){
        myresults <- replace(myresults, myresults == "i", "I") # capitalize the letter "I"
        myresults <- paste(myresults, collapse = ", ")
      }else{
        myresults <- paste(myresults, collapse = ", ")
      }
    }
  })
  
  
  # Render plots 
  output$plot <- renderPlot({
    statsDT <- predictions()
    
    # Probabilities  
    if(ncol(statsDT) == 5){
       g <- ggplot(data=statsDT, 
                aes(x = reorder(last, -Pkn), y = Pkn))#,
                    #text = paste("word:", " ", last,
                     #            "</br>probability:"," ", round(Pkn, 3), sep = "")))
    }else if(ncol(statsDT) == 3){
      g <- ggplot(data=statsDT, 
                  aes(x = reorder(last, -Pcont), y = Pcont))#,
                     # text = paste("<b>Word:</b>", " ", last,
                        #           "</br><b>Probability:</b>"," ", round(Pcont, 3), sep = "")))
    }
    
    g <- g +  geom_bar(stat="identity", fill = "lightslategrey") +
      labs(title = "Probabilities", x = "word", y = "probability")
    
    
    # Frequencies
    if(ncol(statsDT) == 5){
      f <- ggplot(data = statsDT,
                aes(x = reorder(last, -Pkn), y = frequency)) 
    }else if(ncol(statsDT == 3)){
      f <- ggplot(data = statsDT,
                  aes(x = reorder(last, -Pcont), y = frequency))
    }
    
      f <- f + geom_bar(stat = "identity", fill = "lightslategrey") +
      labs(title = "Frequencies", x = "word", y = "frequency")
    
      y <- gridExtra::arrangeGrob(g, f, ncol = 2)
      gridExtra::grid.arrange(y)
  })
  
  
  ############# RENDERING UI CONTROLS ############################
  
  
  ### INPUT ###
  
  # Control for user input text box
  output$isentence <- renderUI({
    textInput("sentence", 
              label = "Enter a word or sentence",
              value = "Keep calm and carry"
    )
  })
  
  # Control for "Show plots" check box
  
  output$icheck <- renderUI({
      checkboxInput("check", label = "Show plots")
    })
  
  # Control for "Get Suggestions" button
  output$iget <- renderUI({
    if(is.null(input$sentence)){
      return()
    }else if(grepl("^\\s*$", input$sentence) != TRUE){
      actionButton("get", "Get suggestions")
    }else{
      return()
    }
    
  })
  
  
  ### END INPUT ###
  
  ### OUTPUT ###
  
  # Control for reactive sentence to be displayed in main panel
  # per user input in the side panel
  output$idisplay <- renderUI({
    textOutput("display")
  })
 
  
  # Label "Suggestions"
  output$ilabel <- renderUI({
    
    if(is.null(input$sentence)){
      return()
    }else if(grepl("^\\s*$", input$sentence) == TRUE){
      return() #"Suggestions" if != TRUE
    }else if(!is.null(predictions())){
      "Suggestions"
    }else{
      return()
    }
  })
  
  # Control for next word suggestions
  output$isuggestions <- renderUI({
    textOutput("suggestions")
  })
  
  
  # Control for plot
  output$iplot <- renderUI({
    plotOutput("plot")
  })
  
  ### END OUTPUT ###
  
})
