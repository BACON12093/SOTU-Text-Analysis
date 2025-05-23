library(shiny)
library(tidyverse)
library(tidytext)
library(DT)
library(plotly)
library(RColorBrewer)
library(viridis)

# Load data
sotu = read_csv("sotu.csv")
bing = read_csv("bing.csv")
afinn = read_csv("afinn.csv")
nrc = read_csv("nrc.csv")

# UI
ui = fluidPage(
  titlePanel("SOTU Text Analysis"),
  
  fluidRow(
    column(3,
           selectInput("president", "Select President:",
                       choices = c("All Presidents", unique(sotu$name)),
                       selected = "All Presidents")),
    column(3,
           sliderInput("year_range", "Year range:",
                       min = min(sotu$year), max = max(sotu$year),
                       value = c(min(sotu$year), max(sotu$year)), sep = "")),
    column(3,
           radioButtons("sentiment_type", "Sentiment Lexicon:",
                        choices = c("bing", "afinn", "nrc"),
                        selected = "bing", inline = TRUE)),
    column(3,
           textInput("trend_words", "Words to track:", 
                     "freedom, economy, war, peace, democracy, security, growth, health, liberty, justice, america, change, prosperity, jobs, rights, taxes, power, defense, unity, education, inflation, trade, government, military, values
"))
  ),
  
  hr(),
  
  tabsetPanel(type = "tabs",
              tabPanel("Sentiment Analysis",
                       h3("Average Sentiment Score by Year"),
                       plotlyOutput("sentiment_plot"),
                       hr(),
                       dataTableOutput("sentiment_table")),
              tabPanel("Word Trend Analysis",
                       h3("Word Trends Over Time"),
                       plotlyOutput("trend_plot"),
                       hr(),
                       dataTableOutput("trend_table"))
  )
)

# Server
server = function(input, output, session) {
  
  # Dynamically get year range for selected president
  president_year_range <- reactive({
    if (input$president == "All Presidents") {
      range(sotu$year, na.rm = TRUE)
    } else {
      range(sotu$year[sotu$name == input$president], na.rm = TRUE)
    }
  })
  
  # Update slider when president changes
  observeEvent(input$president, {
    range_vals <- president_year_range()
    updateSliderInput(session, "year_range",
                      min = range_vals[1],
                      max = range_vals[2],
                      value = range_vals)
  })
  
  # Reactive filtered data
  filtered_sotu = reactive({
    data = sotu |>
      filter(year >= input$year_range[1],
             year <= input$year_range[2])
    
    if (input$president != "All Presidents") {
      data = data |> filter(name == input$president)
    }
    
    data
  })
  
  tidy_filtered = reactive({
    filtered_sotu() |>
      unnest_tokens(word, text) |>
      anti_join(stop_words, by = "word")
  })
  
  # Sentiment Analysis
  sentiment_data = reactive({
    data = tidy_filtered()
    if (nrow(data) == 0) return(NULL)
    
    sentiment_score = tibble()
    
    if (input$sentiment_type == "bing") {
      temp = data |>
        inner_join(bing, by = "word") |>
        count(year, sentiment) |>
        pivot_wider(names_from = sentiment, values_from = n, values_fill = list(n = 0))
      
      # Safe column checks BEFORE mutate
      if (!"positive" %in% colnames(temp)) temp$positive <- 0
      if (!"negative" %in% colnames(temp)) temp$negative <- 0
      
      temp = temp |>
        mutate(score = positive - negative)
      
      sentiment_score = bind_rows(sentiment_score, temp)
    }
    
    if (input$sentiment_type == "afinn") {
      temp = data |>
        inner_join(afinn, by = "word") |>
        group_by(year) |>
        summarize(score = sum(value, na.rm = TRUE)) |>
        ungroup()
      
      sentiment_score = bind_rows(sentiment_score, temp)
    }
    
    if (input$sentiment_type == "nrc") {
      temp = data |>
        inner_join(nrc, by = "word") |>
        count(year, sentiment) |>
        pivot_wider(names_from = sentiment, values_from = n, values_fill = list(n = 0))
      
      if (!"positive" %in% colnames(temp)) temp$positive = 0
      if (!"negative" %in% colnames(temp)) temp$negative = 0
      
      temp = temp |>
        mutate(score = positive - negative)
      
      sentiment_score = bind_rows(sentiment_score, temp)
    }
    
    sentiment_score
  })
  
  
  output$sentiment_plot = renderPlotly({
    req(nrow(sentiment_data()) > 0)
    
    p = ggplot(sentiment_data(), aes(x = year, y = score, fill = score)) +
      geom_bar(stat = "identity") +
      scale_fill_viridis(option = "C") +
      labs(x = "Year", y = "Sentiment Score") +
      theme_minimal(base_size = 14) +
      theme(axis.text.x = element_text(angle = 45, hjust = 1))
    
    ggplotly(p)
  })
  
  output$sentiment_table = renderDataTable({
    sentiment_data()
  })
  
  # Word Trend
  trend_words = reactive({
    str_split(input$trend_words, ",\\s*")[[1]] |> tolower()
  })
  
  trend_data = reactive({
    tidy_filtered() |>
      mutate(word = tolower(word)) |>
      filter(word %in% trend_words()) |>
      count(year, word)
  })
  
  output$trend_plot = renderPlotly({
    req(nrow(trend_data()) > 0)
    
    p = ggplot(trend_data(), aes(x = year, y = n, color = word)) +
      geom_line(linewidth = 1.5) +
      scale_color_viridis(discrete = TRUE) +
      labs(x = "Year", y = "Word Count") +
      theme_minimal(base_size = 14) +
      theme(axis.text.x = element_text(angle = 45, hjust = 1))
    
    ggplotly(p)
  })
  
  output$trend_table = renderDataTable({
    trend_data()
  })
}

# Run the app
shinyApp(ui = ui, server = server)
