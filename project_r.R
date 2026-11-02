library(shiny)
library(shinydashboard)
library(ggplot2)
library(dplyr)
library(tidyr)
library(plotly)
library(DT)
library(lubridate)

set.seed(123)
locations <- data.frame(
  city = c(
    "Delhi", "Mumbai", "Pune", "Chandigarh", "Mohali", "Ludhiana", "Amritsar",
    "Bengaluru", "Kolkata", "Chennai", "Hyderabad", "Jaipur",
    "Shimla", "Solan", "Dharamshala", "Mandi", "Bilaspur",
    "Kullu", "Hamirpur", "Una", "Chamba", "Kinnaur", "Nahan", "Keylong"
  ),
  district = c(
    "New Delhi", "Mumbai City", "Pune", "Chandigarh", "SAS Nagar (Mohali)", "Ludhiana", "Amritsar",
    "Bengaluru Urban", "Kolkata", "Chennai", "Hyderabad", "Jaipur",
    "Shimla", "Solan", "Kangra", "Mandi", "Bilaspur",
    "Kullu", "Hamirpur", "Una", "Chamba", "Kinnaur", "Sirmaur", "Lahaul and Spiti"
  ),
  state = c(
    "Delhi", "Maharashtra", "Maharashtra", "Chandigarh", "Punjab", "Punjab", "Punjab",
    "Karnataka", "West Bengal", "Tamil Nadu", "Telangana", "Rajasthan",
    rep("Himachal Pradesh", 12)
  ),
  base_pm25 = c(110, 45, 35, 55, 48, 62, 58, 28, 65, 32, 42, 60, 25, 38, 30, 35, 32, 28, 30, 40, 22, 18, 35, 15),
  base_pm10 = c(190, 90, 75, 105, 95, 118, 110, 65, 120, 70, 85, 115, 55, 75, 65, 70, 68, 60, 65, 80, 50, 40, 75, 35),
  stringsAsFactors = FALSE
)

dates <- seq(
  as.Date("2025-11-01"),
  Sys.Date(),
  by = "day"
)
air_data <- expand.grid(date = dates, city = locations$city, stringsAsFactors = FALSE) %>%
  left_join(locations, by = "city") %>%
  mutate(
    month_effect = sin(2 * pi * yday(date) / 365),
    PM25 = pmax(5, round(base_pm25 + 15 * month_effect + rnorm(n(), 0, 12))),
    PM10 = pmax(10, round(base_pm10 + 20 * month_effect + rnorm(n(), 0, 18))),
    NO2 = pmax(5, round(PM25 * 0.30 + rnorm(n(), 10, 5))),
    SO2 = pmax(2, round(rnorm(n(), 12, 4))),
    CO = round(pmax(0.2, rnorm(n(), 1.2, 0.4)), 2),
    temperature = round(27 + 8 * month_effect + rnorm(n(), 0, 3), 1),
    humidity = pmin(95, pmax(20, round(rnorm(n(), 55, 12)))),
    AQI = pmin(500, round(PM25 * 2.2 + PM10 * 0.45 + NO2 * 0.7)),
    category = case_when(AQI <= 50 ~ "Good", AQI <= 100 ~ "Satisfactory", AQI <= 200 ~ "Moderate", AQI <= 300 ~ "Poor", AQI <= 400 ~ "Very Poor", TRUE ~ "Severe")
  ) %>% select(date, state, district, city, AQI, category, PM25, PM10, NO2, SO2, CO, temperature, humidity)

ui <- dashboardPage(
  dashboardHeader(title = "AirWatch Dashboard"),
  dashboardSidebar(
    width = 230,
    sidebarMenu(
      menuItem("Overview", tabName = "overview", icon = icon("dashboard")),
      menuItem("Pollution Trends", tabName = "trends", icon = icon("line-chart")),
      menuItem("City Comparison", tabName = "cities", icon = icon("bar-chart")),
      menuItem("Data Explorer", tabName = "data", icon = icon("table"))
    ),
    hr(),
    h4("Dashboard Filters", style = "color:white; padding-left:15px;"),
    selectInput("state", "Select State", choices = c("All India (All States)", sort(unique(locations$state))), selected = "All India (All States)"),
    selectInput("district", "Select District", choices = c("All Districts", sort(unique(locations$district))), selected = "All Districts"),
    selectInput("city", "Select City", choices = c("All Cities", sort(unique(locations$city))), selected = "All Cities"),
    dateRangeInput("dates", "Select Date Range", start = min(air_data$date), end = max(air_data$date), min = min(air_data$date), max = max(air_data$date))
  ),
  dashboardBody(
    h2("Air Quality & Pollution Analysis", style = "font-weight:bold; color:#123c50;"),
    p("Interactive All-India State & District environmental data analytics dashboard"),
    tabItems(
      tabItem(tabName = "overview",
        fluidRow(valueBoxOutput("avg_aqi", width = 3), valueBoxOutput("avg_pm25", width = 3), valueBoxOutput("avg_pm10", width = 3), valueBoxOutput("city_count", width = 3)),
        fluidRow(
          box(title = "AQI Trend Over Time", status = "primary", solidHeader = TRUE, width = 8, plotlyOutput("overview_trend", height = 300)),
          box(title = "Air Quality Categories", status = "info", solidHeader = TRUE, width = 4, plotlyOutput("category_chart", height = 300))
        )
      ),
      tabItem(tabName = "trends",
        fluidRow(box(title = "Pollution Trend Analysis", status = "primary", solidHeader = TRUE, width = 12, selectInput("pollutant", "Choose Pollutant", choices = c("AQI", "PM25", "PM10", "NO2", "SO2", "CO")), plotlyOutput("pollution_trend", height = 400))),
        fluidRow(box(title = "Temperature vs Humidity", status = "info", solidHeader = TRUE, width = 12, plotlyOutput("weather_chart", height = 350)))
      ),
      tabItem(tabName = "cities",
        fluidRow(box(title = "City-wise Average AQI", status = "primary", solidHeader = TRUE, width = 12, plotlyOutput("city_chart", height = 400))),
        fluidRow(box(title = "Top 5 Most Polluted Locations", status = "warning", solidHeader = TRUE, width = 12, tableOutput("top_cities")))
      ),
      tabItem(tabName = "data",
        fluidRow(box(title = "Air Quality Dataset", status = "primary", solidHeader = TRUE, width = 12, downloadButton("download_data", "Download CSV"), br(), br(), DTOutput("data_table")))
      )
    )
  )
)

server <- function(input, output, session) {
  
  observeEvent(input$state, {
    if (input$state == "All India (All States)") {
      dist_choices <- sort(unique(locations$district))
      city_choices <- sort(unique(locations$city))
    } else {
      sub_loc <- locations %>% filter(state == input$state)
      dist_choices <- sort(unique(sub_loc$district))
      city_choices <- sort(unique(sub_loc$city))
    }
    updateSelectInput(session, "district", choices = c("All Districts", dist_choices), selected = "All Districts")
    updateSelectInput(session, "city", choices = c("All Cities", city_choices), selected = "All Cities")
  })
  
  observeEvent(input$district, {
    if (input$district != "All Districts") {
      sub_loc <- locations %>% filter(district == input$district)
      updateSelectInput(session, "city", choices = c("All Cities", sort(unique(sub_loc$city))), selected = "All Cities")
    }
  })

  filtered_data <- reactive({
    req(input$dates)
    df <- air_data %>% filter(date >= input$dates[1], date <= input$dates[2])
    if (input$state != "All India (All States)") df <- df %>% filter(state == input$state)
    if (input$district != "All Districts") df <- df %>% filter(district == input$district)
    if (input$city != "All Cities") df <- df %>% filter(city == input$city)
    df
  })

  output$avg_aqi <- renderValueBox({ valueBox(round(mean(filtered_data()$AQI, na.rm = TRUE), 1), "Average AQI (Illustrative)", icon = icon("cloud"), color = "aqua") })
  output$avg_pm25 <- renderValueBox({ valueBox(round(mean(filtered_data()$PM25, na.rm = TRUE), 1), "Average PM2.5 (ug/m3)", icon = icon("fire"), color = "yellow") })
  output$avg_pm10 <- renderValueBox({ valueBox(round(mean(filtered_data()$PM10, na.rm = TRUE), 1), "Average PM10 (ug/m3)", icon = icon("cloud"), color = "purple") })
  output$city_count <- renderValueBox({ valueBox(n_distinct(filtered_data()$city), "Cities Selected", icon = icon("map-marker"), color = "green") })
  
  output$overview_trend <- renderPlotly({
    df <- filtered_data() %>% group_by(date) %>% summarise(AQI = mean(AQI, na.rm = TRUE), .groups = "drop")
    ggplotly(ggplot(df, aes(x = date, y = AQI)) + geom_line(color = "#159a91", linewidth = 1) + geom_smooth(method = "loess", se = FALSE, color = "#e67e22") + theme_minimal())
  })
  output$category_chart <- renderPlotly({
    df <- filtered_data() %>% count(category)
    ggplotly(ggplot(df, aes(x = category, y = n, fill = category)) + geom_col() + theme_minimal() + theme(legend.position = "none"))
  })
  output$pollution_trend <- renderPlotly({
    df <- filtered_data() %>% group_by(date) %>% summarise(value = mean(.data[[input$pollutant]], na.rm = TRUE), .groups = "drop")
    ggplotly(ggplot(df, aes(x = date, y = value)) + geom_line(color = "#2563a6", linewidth = 1) + theme_minimal())
  })
  output$weather_chart <- renderPlotly({
    ggplotly(ggplot(filtered_data(), aes(x = temperature, y = humidity, color = AQI)) + geom_point(size = 3, alpha = 0.7) + scale_color_gradient(low = "green", high = "red") + theme_minimal())
  })
  output$city_chart <- renderPlotly({
    df <- filtered_data() %>% group_by(city) %>% summarise(average_AQI = mean(AQI, na.rm = TRUE), .groups = "drop")
    ggplotly(ggplot(df, aes(x = reorder(city, average_AQI), y = average_AQI, fill = average_AQI)) + geom_col() + coord_flip() + labs(x = "City", y = "Average AQI") + theme_minimal())
  })
  output$top_cities <- renderTable({
    filtered_data() %>% group_by(state, district, city) %>% summarise(Average_AQI = round(mean(AQI, na.rm = TRUE), 1), Average_PM25 = round(mean(PM25, na.rm = TRUE), 1), Average_PM10 = round(mean(PM10, na.rm = TRUE), 1), .groups = "drop") %>% arrange(desc(Average_AQI)) %>% head(5)
  })
  output$data_table <- renderDT({ datatable(filtered_data(), options = list(pageLength = 10, scrollX = TRUE)) })
  output$download_data <- downloadHandler(filename = function() paste0("AirWatch_", Sys.Date(), ".csv"), content = function(file) write.csv(filtered_data(), file, row.names = FALSE))
}

shinyApp(ui = ui, server = server)
