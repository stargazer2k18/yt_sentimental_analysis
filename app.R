# Import Libraries

library(shiny)
library(shinydashboard)
library(tidyverse)
library(vosonSML)
library(syuzhet)
library(highcharter)
library(tidytext)

#######################
# User interface      #
#######################

# Define UI for application that draws a histogram
ui <- dashboardPage(
  
  dashboardHeader(title = "Sentimental Analysis"),
  
  dashboardSidebar(
    sidebarMenu(
      
      menuItem("YouTube",
               tabName = "youtube_tab",
               icon = icon("youtube")),
      
      menuItem("Instructions",
               tabName = "inst",
               icon = icon("circle-info"))
    )
  ),
  dashboardBody(
    tabItems(
      
      tabItem(tabName = "youtube_tab",
              box(title = "YouTube Video Sentiment Analysis", 
                  status = "primary",solidHeader = T,
                  
                  # Key for YouTube api from Google Developer
                  textInput("key", "Enter the YouTube API Key"), 
                  
                  # YouTube Video Link
                  textInput("link", "Enter the Youtube Video Link"),
                  
                  # Enter the max number to scrape the comments
                  textInput("max", "Enter the Max Comments"),
                  
                  # Submit button
                  actionButton("submit_yt","Analyze", class = "btn btn-primary")
              ),
              box(
                
                # High charter -- Pie Chart Output
                highchartOutput("pieplot_yt", height = "500px")
                
              )
              
              ),
      
      tabItem(tabName = "inst",
              
              h2(strong("Shiny YouTube Sentiment Analysis Web App")),
              h3(strong("Description:")),
              p("This Shiny web application allows users to perform sentiment analysis on YouTube video's 
comments and visualize the results in a pie chart."),
              h3(strong("Inputs:")),
              p("1. ", span("YouTube API Key:", style = "color:blue")," your YouTube Data API key obtained from the ", span("Google Developer Console.", style = "color:red")),
              p("2. ", span("Video Link:", style = "color:blue")," The link to the YouTube Video you want to analyze."),
              p("3. ", span("Max Comments:", style = "color:blue")," The maximum number of comments to retrieve and analyze."),
              h3(strong("Instructions:")),
              p("1. Input your ", span("YouTube API Key:", style = "color:blue")," in the designated field."),
              p("2. Paste the link to the YouTube video you want to analyze in the provided input box."),
              p("3. Specify the maximum number of comments to analyze."),
              p("4. Click on the ", span("'Analyze'", style = "color:blue")," button to initiate the sentiment analysis."),	
              p("5. Once the analysis is complete, a pie chart will be displayed showing the distribution of sentiments in the comments."),
              h3(strong("Note:")),
              p("1. Before running the app, make sure you have obtain the ", strong("YouTube Data API key")," from the Google Developers Console.
                Since the app need YT API key to obtain the data of the respective video link."),
              p("2. This application requires a stable internet connection to access the YouTube API and retrieve comments."),
              h3(strong("Installation:")),
              p("To run this application locally, follow theses steps:"),
              p("1. Download the repository to your local machine."),
              p("2. Make sure you have ", strong("R")," and ", strong("RStudio")," installed."),
              p("3. Install the necessary ", strong("R packages")," by running the following command in RStudio:"),
              code('install.packages(c("shiny", "shinydashboard", "tidyverse", "vosonSML", "syuzhet", 
		   "highcharter", "tidytext")')
              )
  )
  )

)

# Define server logic required to draw a histogram
server <- function(input, output) {
  
  # Obtaining the comments section from the YT video
  comment <- reactive({
    
    # Collect YouTube data
    yt <- Authenticate("youtube", apiKey = input$key)
    
    
    ytdata <- yt |>
      Collect(input$link, maxComments = input$max, verbose = T, writeToFile = F)
    
    comment <- iconv(ytdata$Comment, to = 'utf-8')
    
    comment
  })
  
  # Pie Chart for YT --- using get_nrc_sentiment and Highcharter 
  hc_yt <- reactive({
    
    # getting sentiment info from the comments data
    s <- comment() %>% 
      get_nrc_sentiment()
    
    # Converting s data frame to percentage
    df <- 100*colSums(s)/sum(s)
    
    # Convert the named numeric vector to a data frame
    df <- data.frame(Emotion = names(df), Value = as.numeric(round(df,2)), stringsAsFactors = FALSE)
    
    # Pie Chart --- Using Highcharter Package
    hc <- df %>%
      hchart("pie",
             hcaes(x = Emotion, y = Value), 
             name = "Emotion") %>%
      hc_title(text = "Sentiment Distribution of Comments") %>% 
      hc_add_theme(hc_theme_null())
    
    hc
  })
  
  # Pie Chart for YT -- output
  output$pieplot_yt <- renderHighchart({
    if(input$submit_yt>0){
      isolate(hc_yt())
    }
   
  })
  
}

# Run the application 
shinyApp(ui = ui, server = server)
