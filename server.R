library(shiny)
library(ggplot2)
library(plotly)


shinyServer(function(input,output){
    
    output$futurepresent <- renderText({
        years <- ifelse(input$futurepresent=='f',input$years,(-input$years))
        value <- (input$value*(1+(input$interest/100))^(years))
        value
    })
    
    output$chartfuturepresent <- renderPlotly({
        if (input$futurepresent=='f'){y <- seq(1,input$years)}
        if (input$futurepresent=='p'){y <- seq(-1,-input$years)}
        v <- input$value
        i <- input$interest/100
        d <- data.frame(Years=y,Value=numeric(length(y)))
        d$Value <- v*((1+i)^(d$Years))
        plot_ly(x=d$Years,y=d$Value,type = 'bar',mode='markers',marker=list(color='navy'))
    })
    
})




