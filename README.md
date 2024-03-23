# YouTube Sentiment Analysis
## Description:
This is a Shiny web app that performs sentiment analysis on YouTube video comments. Users can upload video URLs and YouTube API key, and the app visualizes sentiment scores through intuitive pie charts, word clouds, and bar charts, enabling content creators to gauge audience reactions.

## Inputs:
1. YouTube API Key: your YouTube Data API key obtained from the Google Developer Console.

2. URL Link: The link to the YouTube Video you want to analyze.

3. Max Comments: The maximum number of comments to retrieve and analyze.

## Instructions:
1. Input your **_YouTube API Key_** in the designated field.

2. Paste the _**URL link**_ to the YouTube video you want to analyze in the provided input box.

3. Specify the maximum _**number of comments**_ to analyze.

4. Click on the _**'Analyze'**_ button to initiate the Sentiment analysis.

5. Once the analysis is complete, the results will be displayed on the Analytics tab showing the distribution of sentiments in the comments of the given YT video.

## Note:
1. Before running the app, make sure you have obtain the **YouTube Data API** key from the Google Developers Console. Since the app need YouTube API key to obtain the comments data of the respective video link.

2. This application requires a stable internet connection to access the YouTube API and retrieve comments.

## Installation:
To run this application locally, follow theses steps:

1. Download the repository to your local machine.

2. Make sure you have **R** and **RStudio** installed.

3. Install the necessary **R packages** by running the following command in RStudio:

```
install.packages(c("shiny", "shinydashboard", "shinydashboardPlus", "tidyverse", "vosonSML", "syuzhet", "highcharter", "tidytext", "wordcloud2", "ggplot2")
```
