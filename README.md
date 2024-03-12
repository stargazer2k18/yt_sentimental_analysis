Shiny YouTube Sentiment Analysis Web App
Description:
This Shiny web application allows users to perform sentiment analysis on YouTube video's comments and visualize the results in a pie chart.

Inputs:
1. YouTube API Key: your YouTube Data API key obtained from the Google Developer Console.

2. Video Link: The link to the YouTube Video you want to analyze.

3. Max Comments: The maximum number of comments to retrieve and analyze.

Instructions:
1. Input your YouTube API Key: in the designated field.

2. Paste the link to the YouTube video you want to analyze in the provided input box.

3. Specify the maximum number of comments to analyze.

4. Click on the 'Analyze' button to initiate the sentiment analysis.

5. Once the analysis is complete, a pie chart will be displayed showing the distribution of sentiments in the comments.

Note:
1. Before running the app, make sure you have obtain the YouTube Data API key from the Google Developers Console. Since the app need YT API key to obtain the data of the respective video link.

2. This application requires a stable internet connection to access the YouTube API and retrieve comments.

Installation:
To run this application locally, follow theses steps:

1. Download the repository to your local machine.

2. Make sure you have R and RStudio installed.

3. Install the necessary R packages by running the following command in RStudio:

install.packages(c("shiny", "shinydashboard", "tidyverse", "vosonSML", "syuzhet", "highcharter", "tidytext")
