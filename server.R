library(shiny)
library(ggplot2)
library(plotly)
library(FinancialMath)


shinyServer(function(input,output){
    
    output$futurepresent <- renderValueBox({
        years <- ifelse(input$futurepresent=='f',input$years,(-input$years))
        value <- (input$value*(1+(input$interest/100))^(years))
        valueBox('Result',value = round(value,2),color = 'navy')
    })
    
    output$chartfuturepresent <- renderPlotly({
        if (input$futurepresent=='f'){y <- seq(1,input$years)}
        if (input$futurepresent=='p'){y <- seq(-1,-input$years)}
        v <- input$value
        i <- input$interest/100
        d <- data.frame(Years=y,Value=numeric(length(y)))
        d$Value <- v*((1+i)^(d$Years))
        plot_ly(x=d$Years,y=d$Value,type = 'bar',mode='markers',marker=list(color='navy'),
                hoverinfo='y+name',name='Value') %>% 
            layout(yaxis=list(range=c(min(d$Value)*0.9,max(d$Value)*1.05)))
    })
    
    
    output$irr <- renderValueBox({
        irr <- (input$finalvalue/input$initialvalue)^(1/input$yearsirr)-1
        valueBox('IRR',value = paste(round(irr*100,2),'%',sep = ' '),color = 'navy')
    })
    
    debt <- reactive({
        n <- 12/as.integer(input$debtfrequency)
        d <- amort.table(Loan = input$debt,n = n*input$yearsdebt,i = input$interestdebt/100,pf = n)
        d <- as.data.frame(d$Schedule)
        colnames(d) <- c('Months','Payment','Interest','Principal','Balance')
        d$Months <- round(d$Months*12)
        d
    })
    
    output$tabledebt <- renderDataTable({
        d <- debt()
        d
    })
    
    output$chartdebt <- renderPlotly({
        c <- debt()
        plot_ly(c) %>% 
            add_trace(x=~Months,y=~Principal,type='bar',name='Principal',marker=list(color='light-blue'),
                      hoverinfo='y+name') %>% 
            add_trace(x=~Months,y=~Interest,type='bar',name='Interest',color=I('red'),
                      hoverinfo='y+name') %>% 
            add_trace(x=~Months,y=~Balance,type='scatter',mode='lines+markers',name='Balance',yaxis='y2',
                      hoverinfo='y+name',color=I('black'),line=list(width=3),
                      marker=list(symbol='circle')) %>%  
            layout(yaxis=list(side='left',title='Principal + Interest',showgrid=F,zeroline=F),
                   barmode='stack',
                   yaxis2=list(side='right',title='Debt Balance',overlaying='y',showgrid=F,zeroline=F))
    })
    
    output$debtsummary <- renderValueBox({
        valueBox('Debt',value = input$debt,color = 'navy')
    }) 
    
    output$debtpayment <- renderValueBox({
        p <- debt()
        pp <- p$Payment[1]
        valueBox('Periodical Payment',value = pp,color = 'navy')
    })
    
    output$totalinterest <- renderValueBox({
        i <- debt()
        valueBox('Total Interest Paid',value = sum(i$Interest),color = 'navy')
    })
    
    output$totalpaid <- renderValueBox({
        t <- debt()
        valueBox('Total Paid',value = sum(t$Payment),color = 'navy')
    })
    
})





