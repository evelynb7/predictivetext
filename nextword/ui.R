#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinythemes)

# Define UI for application that calculates diamond price estimates
shinyUI(navbarPage("Predictive Text",
                   theme = shinytheme("spacelab"),#("simplex"),
                   tabPanel("Introduction",
                     fluidPage(
                       mainPanel(withMathJax(includeMarkdown("intronextword.md")), width = 10)
                     ) # end fluidPage
                   ), # end tabPanel "Introduction"
                   tabPanel("Application",
                            fluidPage(
                              titlePanel("Predictive Text"),
                              sidebarLayout(
                                sidebarPanel(
                                  uiOutput("isentence"),
                                  conditionalPanel(
                                    condition = "output.ilabel",
                                    uiOutput("icheck")
                                  ),
                                  uiOutput("iget"),
                                  tags$br()
                                ), # end sidebaPanel
                                mainPanel(
                                  h3(uiOutput("idisplay")),
                                  tags$br(),
                                  uiOutput("ilabel"),
                                  h4(uiOutput("isuggestions")),
                                  tags$br(),
                                  conditionalPanel(
                                    condition = "input.check == true",
                                    uiOutput("iplot")
                                  )
                                ) # end mainPanel
                              ) # end sidebarLayout
                            ) # end fluidPage
                   ), #end tabPanel "Next Word"
                   tabPanel(HTML("<li><a href=\"http://github.com/evelynb7/predictivetext\" target=\"_blank\">Code"))
) # end navbarPage
) # end ShinyUI