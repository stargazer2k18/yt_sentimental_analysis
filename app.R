# Import Libraries

library(shiny)
library(shinydashboard)
library(shinydashboardPlus)
library(tidyverse)
library(vosonSML)
library(syuzhet)
library(highcharter)
library(tidytext)
library(wordcloud2)

#######################
# User interface      #
#######################

# Define UI for application that draws a histogram
ui <- dashboardPage(
  
  dashboardHeader(title = "Sentimental Analysis"),
  
  dashboardSidebar(
    sidebarMenu(
      
      menuItem("Setup",
               tabName = "setup",
               icon = icon("list")),
      
      menuItem("Analytics",
               tabName = "output",
               icon = icon("wand-magic-sparkles"))
    )
  ),
  dashboardBody(
    tabItems(
      
      tabItem(tabName = "setup", 
              
              box(title = "YouTube Video Sentiment Analysis", 
                  status = "primary",solidHeader = T, height = 360,
                  
                  # Key for YouTube api from Google Developer
                  textInput("key", "Enter the YouTube API Key"), 
                  
                  # YouTube Video Link
                  textInput("link", "Enter the Youtube Video Link"),
                  
                  # Enter the max number to scrape the comments
                  textInput("max", "Enter the Max Comments"),
                  
                  # Submit button
                  actionButton("submit_yt", "Analyze", class = "btn btn-primary")
              ),
              box(
                img(src = "image_1.jpg", 
                      width = "550", 
                      height = "258", 
                      style = "object-fit: cover; cursor: pointer;")
              ),
              
              box(width = 12,
              title = h2(strong("YouTube Sentiment Analysis")),
              h3(strong("Description:")),
              p("This is a Shiny web app that performs sentiment analysis on YouTube video comments. Users can upload video URLs and YouTube API key, 
                and the app visualizes sentiment scores through intuitive pie charts, word clouds, and bar charts, enabling content creators to 
                gauge audience reactions."),
              h3(strong("Inputs:")),
              p("1. ", span("YouTube API Key:", style = "color:blue")," your YouTube Data API key obtained from the ", span("Google Developer Console.", style = "color:red")),
              p("2. ", span("URL Link:", style = "color:blue")," The link to the YouTube Video you want to analyze."),
              p("3. ", span("Max Comments:", style = "color:blue")," The maximum number of comments to retrieve and analyze."),
              h3(strong("Instructions:")),
              p("1. Input your ", span("YouTube API Key:", style = "color:blue")," in the designated field."),
              p("2. Paste the link to the YouTube video you want to analyze in the provided input box."),
              p("3. Specify the maximum number of comments to analyze."),
              p("4. Click on the ", span("'Analyze'", style = "color:blue")," button to initiate the Sentiment analysis."),	
              p("5. Once the analysis is complete, the results will be displayed on the Analytics tab showing the distribution of sentiments in the comments of the given YT video."),
              h3(strong("Note:")),
              p("1. Before running the app, make sure you have obtain the ", strong("YouTube Data API key")," from the Google Developers Console.
                Since the app need YouTube API key to obtain the comments data of the respective video link."),
              p("2. This application requires a stable internet connection to access the YouTube API and retrieve comments."),
              h3(strong("Installation:")),
              p("To run this application locally, follow theses steps:"),
              p("1. Download the repository to your local machine."),
              p("2. Make sure you have ", strong("R")," and ", strong("RStudio")," installed."),
              p("3. Install the necessary ", strong("R packages")," by running the following command in RStudio:"),
              code('install.packages(c("shiny", "shinydashboard", "shinydashboardPlus", "tidyverse", "vosonSML", "syuzhet", 
		   "highcharter", "tidytext", "wordcloud2", "ggplot2")'))
              ),
      
      tabItem(tabName = "output",
              
              box(
                title = "Insights from the Comments",
                width = 12,
                fluidRow(
                  valueBoxOutput("pos"),
                  valueBoxOutput("neg"),
                  valueBoxOutput("max_com")
                )
              ),
              
              box(
                width = 12, 
                # Bar Chart of Pos/Neg Comments
                plotOutput("bing_bar")
              ),
              
              box(
                width = 6,
                # High charter -- Pie Chart Output
                highchartOutput("pieplot", height = "500px")
              ),
              
              box(
                width = 6,
                # Word Cloud
                wordcloud2Output("wordcloud", height = "500px")
              ),
              
              box(
                width = 12,
                plotOutput("nrc_bar")
              )
      )
    )
  )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
  
  ytdata <- reactive({
    
    # Gathering video data from YouTube
    yt <- Authenticate("youtube", apiKey = input$key)
    
    yt_data <- yt |>
      Collect(input$link, maxComments = as.numeric(input$max), verbose = T, writeToFile = F)
    
    yt_data
    
  })
  
  bing <- get_sentiments("bing")
  
  nrc <- get_sentiments("nrc")
  
  # bing data
  df_bing <- eventReactive(input$submit_yt, {    
    
    ytdata <- ytdata()
    
    dfbing <- ytdata %>% 
      unnest_tokens(word, Comment) %>% 
      inner_join(bing, by = "word")
    
    dfbing
  })
  
  # nrc data
  df_nrc <-eventReactive(input$submit_yt, {    
    
    ytdata <- ytdata()
    
    dfnrc <- ytdata %>% 
      unnest_tokens(word, Comment) %>% 
      inner_join(nrc, by = "word", relationship = "many-to-many")
    
    dfnrc
  })
  
  ## Pie Chart -- data frame
  hc_yt <- eventReactive(input$submit_yt, {
    
    ytdata <- ytdata()
    
    pie_df <- ytdata %>% 
      unnest_tokens(word, Comment) %>% 
      inner_join(nrc, by = "word", relationship = "many-to-many") %>% 
      count(sentiment) %>% 
      mutate(percentage = round(n / sum(n) * 100, 2)) %>% 
      select(sentiment, percentage)
    
    pie_df
  })
  
  
  ## Outputs
  # Word Cloud 
  output$wordcloud <- renderWordcloud2({
    
    req(input$submit_yt)
    
    df_wc <- df_bing() %>%
      count(word, sentiment, sort = T) %>%
      select(word, n)
    
    wordcloud2(slice_max(df_wc, order_by = n, n = 100),
               size = 0.8, rotateRatio = 0,
               color = rep_len(c("red", "black"), nrow(df_wc)),
               backgroundColor = "white")
  })
  
  # Pie Chart
  output$pieplot <- renderHighchart({
    
    req(input$submit_yt)
    
    df <- hc_yt()
    
    hc <- df %>%
      hchart("pie",
             hcaes(x = sentiment, y = percentage),
             name = "Emotion") %>%
      hc_title(text = "Emotion Distribution in Comments") %>% 
      hc_add_theme(hc_theme_null())
    
    hc
  })
  
  # Bar Chart - Pos/Neg words in Comments
  output$bing_bar <- renderPlot({
    
    req(input$submit_yt)
    
    df_bing() %>% 
      count(word, sentiment, sort = T) %>% 
      group_by(sentiment) %>% 
      slice_max(n, n = 10) %>% 
      ungroup() %>% 
      mutate(word = reorder(word, n)) %>% 
      ggplot(aes(n, word, fill = sentiment)) +
      geom_col(show.legend = F) +
      facet_wrap(~sentiment, scales = "free_y") +
      theme_light() +
      labs(title = "Negative/Positive Words in Comments",
           subtitle = "Top 10 words",
           x = "Number of Words",
           y = NULL)
    
  })
  
  # Bar Chart - Emotion words in Comments
  output$nrc_bar <- renderPlot({
    
    req(input$submit_yt)
    
    df_nrc() %>% 
      count(word, sentiment, sort = T) %>% 
      group_by(sentiment) %>% 
      slice_max(n, n = 5) %>% 
      ungroup() %>% 
      mutate(word = reorder(word, n)) %>% 
      ggplot(aes(n, word, fill = sentiment)) +
      geom_col(show.legend = F) +
      facet_wrap(~sentiment, scales = "free_y") +
      theme_light() +
      labs(title = "Emotions Words in Comments",
           subtitle = "Top 5 words",
           x = NULL,
           y = NULL)
    
  })
  # Positive Comments
  output$pos <- renderValueBox({
    
    req(input$submit_yt)
    
    pos <- df_bing() %>%
      count(sentiment) %>%
      mutate(percentage = round(n / sum(n) * 100, 2)) %>% 
      filter(sentiment == "positive") %>%
      pull(percentage)
    
    valueBox(pos, subtitle = "Postive Comments",
             color = "teal", icon = icon("face-smile-beam")) 
  })
  
  # Negative Comments
  output$neg <- renderValueBox({
    
    req(input$submit_yt)
    
    neg <- df_bing() %>%
      count(sentiment) %>%
      mutate(percentage = round(n / sum(n) * 100, 2)) %>% 
      filter(sentiment == "negative") %>%
      pull(percentage)
    
    valueBox(neg, subtitle = "Negative Comments",
             color = "maroon", icon = icon("face-frown"))
  })
  
  # Number of Comments
  output$max_com <- renderValueBox({
    
    req(input$submit_yt)
    
    max_com <- nrow(ytdata())
    
    valueBox(max_com, subtitle = "Number of Comments",
             color = "lime", icon = icon("comments"))
  })
}

# Run the application 
shinyApp(ui = ui, server = server)
