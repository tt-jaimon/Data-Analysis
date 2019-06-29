#Created By: Jaimon Thyparambil Thomas
#Student ID: 29566428
#Mail ID: jthy0001@student.monash.edu

#Questions
#3.Based on this static visualisation use Shiny to create an interactive visualisation 
#that allows the user to vary the kind of coral displayed and the choice of smoother.
#4.Create a map by using Leaflet that shows the location of the sites.
#5Merge the map into your interactive visualisation. Remember to use some kind of visual indicator
#to link the sites on the map to the corresponding facet: text label, shape or colour coding.

require(ggplot2)
require(leaflet)
library(shiny)

data <- read.csv('assignment-02-data-formated.csv')
data$value <- as.numeric(sub("%", "", data$value ,fixed=TRUE))/100
data <- data[order(data$latitude),]
data$new_location = factor(data$location, levels=unique(data$location))

ui <- shinyUI( fluidPage(
  sidebarLayout(
    sidebarPanel(
      
      titlePanel("Plot Settings"),
      selectInput("coralType","Coral Type",
                  data$coralType, multiple = TRUE),
      selectInput("site","Location",
                  data$new_location, multiple = TRUE),
      selectInput("geom_smooth_method","GEOM SMOOTH METHOD",
                  c("lm","auto","glm","gam","loess"), multiple = FALSE),
      selectInput("smoother","Smoother",
                  c("Turn ON","Turn Off"), multiple = FALSE),
      selectInput("geom_smooth_se","Display Confidence Interval Across Smoother",
                  c("Turn ON","Turn Off"), multiple = FALSE),
      selectInput("plot_type","Plot Type",
                  c("Scatter","Bar"), multiple = FALSE),
      leafletOutput("mymap")
      
    )
    # Application title
    ,mainPanel(
      plotOutput("plot")
    )
  )
) 

)

server <- function(input, output) {
  
  output$mymap <- renderLeaflet({
    
    tempCoralType <- c("blue corals")
    if (length(input$coralType)>0){
      tempCoralType <- input$coralType
    }
    tempLocation <- c("site01")
    if (length(input$site)>0){
      tempLocation <- input$site
    }# create leaflet map
    tempData <- data[data$coralType  %in% tempCoralType & data$location  %in% tempLocation ,]
    
    leaflet(data = tempData) %>% addTiles() %>%
      addMarkers(~longitude, ~latitude, label = ~as.character(location), labelOptions = labelOptions(noHide = T, textOnly = TRUE,direction = "left",style = list(
        "color" = "Black",
        "font-family" = "serif",
        "font-style" = "italic",
        "font-size" = "20px"
      ))) 
    
  })
  
  output$plot <-renderPlot({
    
    label1 <- seq(10,120,by=20)
    tempCoralType <- c("blue corals")
    if (length(input$coralType)>0){
      tempCoralType <- input$coralType
    }
    tempLocation <- c("site01")
    if (length(input$site)>0){
      tempLocation <- input$site
    }
    tempData <- data[data$coralType  %in% tempCoralType & data$location  %in% tempLocation ,]
    
    g <- ggplot(data = tempData , aes(x= tempData$year, y= tempData$value))+
      facet_grid(tempData$coralType~tempData$new_location)+ 
      theme_grey()+ 
      theme(axis.text = element_text(face="bold", color="Black",size=12, angle=45),
            axis.text.y = element_text(angle = 0), 
            axis.title = element_text(face="bold", color="firebrick",size=20),
            strip.text = element_text(size = 20, colour = "DarkGreen",face="bold"),
            legend.title = element_text(size=20, color = "firebrick",face = "bold"), 
            legend.text = element_text(size=18,colour = "DarkGreen"),
            plot.title =  element_text(size=25, color = "firebrick",face = "bold",hjust = .5)) + 
      scale_y_continuous(name = "Bleaching Rates in %",breaks=seq(0.1,1.2,.2),labels = label1)+
      scale_x_continuous(name = "Years(2010 - 2017)") + 
      ggtitle("Bleaching Rates Of different Coral Types across various locations over the year")+
      labs(color="Coral Type",fill ="Coral Type" )
    
    if (input$smoother == "Turn ON"){
      g <- g + geom_smooth(method = input$geom_smooth_method,
                           color = "black",
                           se = input$geom_smooth_se == "Turn ON" )
    }
    if(input$plot_type == "Bar"){
      g <- g + geom_col(aes(fill = tempData$coralType))
    }
    else{
      g <- g + geom_point(aes(colour = tempData$coralType),size = 5)
    }
    g
    
    
  },height = 950, width = 1250)}

# Run the application 
shinyApp(ui = ui, server = server)

