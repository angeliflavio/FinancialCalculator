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
    

    store <- reactiveValues()
    store$variable <- data.frame(N=numeric(0),Months=numeric(0),Flow=numeric(0),
                                 Year=numeric(0),Present=numeric(0),Final=numeric(0))
    store$constant <- data.frame(N=numeric(0),Months=numeric(0),Flow=numeric(0),
                                 Year=numeric(0),Present=numeric(0),Final=numeric(0))
    
   
    observeEvent(input$insert,{
            i <- input$discountrate/100
            if (input$constantvariable=='Constant'){
                n <- input$numberflows
                m <- seq(1:n)*as.integer(input$flowsfrequency)
                store$constant <- data.frame(N=seq(1:n),Months=m,Flow=rep(input$constantflow,n))
                store$constant$Year <- store$constant$Months/12
                store$constant$Present <- round(store$constant$Flow*(1+i)^(-store$constant$Year),2)
                store$constant$Final <- round(store$constant$Flow*(1+i)^(rev(store$constant$Year)-1),2)
            }
            if (input$constantvariable=='Variable'){
                to <- input$to
                from <- input$from
                if (to>nrow(store$variable)){
                    add <- data.frame(N=numeric(to-nrow(store$variable)),Months=NA,Flow=NA,
                                      Year=NA,Present=NA,Final=NA)
                    store$variable <- rbind(store$variable,add)
                }
                store$variable$Flow[from:to] <- input$variableflow
                store$variable$N <- seq(1:nrow(store$variable))
                store$variable$Months <- store$variable$N*as.integer(input$flowsfrequency)
                store$variable$Year <- store$variable$Months/12
                store$variable$Present <- round(store$variable$Flow*(1+i)^(-store$variable$Year),2)
                store$variable$Final <- round(store$variable$Flow*(1+i)^(rev(store$variable$Year)-1),2)
            }
    })
    
    output$tableflows <- renderDataTable({
        if (input$constantvariable=='Constant'){d <- store$constant}
        if (input$constantvariable=='Variable'){d <- store$variable}
        d
    })
    
    observeEvent(input$delete,{
        if (input$constantvariable=='Constant'){
            store$constant <- data.frame(N=numeric(0),Months=numeric(0),Flow=numeric(0))
        }
        if (input$constantvariable=='Variable'){
            from <- input$from
            to <- input$to
            store$variable <- store$variable[-c(from:to),]
            store$variable$N <- seq(1:nrow(store$variable))
            store$variable$Months <- store$variable$N*as.integer(input$flowsfrequency)
        }
    })
    
    output$finalvalue <- renderValueBox({
        if (input$constantvariable=='Constant'){
            s <- sum(store$constant$Final)
        }
        if (input$constantvariable=='Variable'){
            s <- sum(store$variable$Final)
        }
        valueBox('Final Value',value = round(s),color = 'navy')
    })
    
    output$presentvalue <- renderValueBox({
        if (input$constantvariable=='Constant'){
            f <- sum(store$constant$Present)
        }
        if (input$constantvariable=='Variable'){
            f <- sum(store$variable$Present)
        }
        valueBox('Present Value',value = round(f),color = 'navy')
    })
    
    output$chartflow <- renderPlotly({
        if (input$constantvariable=='Constant'){
            c <- store$constant
        }
        if (input$constantvariable=='Variable'){
            c <- store$variable
        }
        c$cumsum <- cumsum(c$Flow) 
        plot_ly(x=c$Months,y=c$Flow,type = 'bar',name='Flow') %>% 
            add_trace(x=c$Months,y=c$cumsum,type='scatter',mode='line+markers',name='Cumulative',
                      yaxis='y2',line=list(width=3),color=I('black'),
                      markers=list(symbol='circle')) %>% 
            layout(yaxis=list(side='left',title='Flow',showgrid=F,zeroline=F),
                   yaxis2=list(side='right',title='Cumulative',overlaying='y',showgrid=F,zeroline=F),
                   xaxis=list(title='Months'))
    })
    
})





