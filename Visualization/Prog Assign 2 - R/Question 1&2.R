#Questions
#Created By: Jaimon Thyparambil Thomas
#Student ID: 29566428
#Mail ID: jthy0001@student.monash.edu

#Questions
#1.Read the data into R
#2.Create a static tabular visualisation using ggplot2 that shows for each kind of coral and for
#each site how the bleaching varies from year to year. You should use faceting with each facet 
#showing the bleaching for one kind of coral at one site across the time period. 
#The sites should be ordered by latitude. Fit smoothers to the data.

require(ggplot2)

data <- read.csv('assignment-02-data-formated.csv')
data$value <- as.numeric(sub("%", "", data$value ,fixed=TRUE))/100
data <- data[order(data$latitude),]
data$new_location = factor(data$location, levels=unique(data$location))

label1 <- seq(10,120,by=20)
myGraph <- ggplot(data = data , aes(x= data$year, y= data$value)) 
g2 <-  myGraph + 
  geom_point(aes(colour = data$coralType, size = data$year),size=5)+
  facet_grid(data$coralType~data$new_location)+ 
  
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
  
  labs(color="Coral Type") +  
  
  geom_smooth(method = "lm",
              color = "black",
              formula = y~ poly(x, 2),
  )
g2

