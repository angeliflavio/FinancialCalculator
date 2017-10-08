library(shiny)
library(shinyBS)
library(shinydashboard)


dashboardPage(
    dashboardHeader(title = 'Financial Calculator'
                    ),
    dashboardSidebar(
        sidebarMenu(
            menuItem("Future or Present Value", tabName = "present"),
            menuItem("Cash Flows", tabName = "flow"),
            menuItem('IRR',tabName = 'irr'),
            menuItem('Debt Payment',tabName = 'debt')
        )
    ),
    dashboardBody(
        tabItems(
            tabItem('present',
                    fluidRow(
                        box(title = 'Options',background = 'light-blue',width = 3,collapsible = T,
                            radioButtons('futurepresent','Calculation',
                                         choices = c('Future'='f','Present'='p'),
                                         inline = T,selected = 'f'),
                            numericInput('value','Value',value = 1000),
                            numericInput('years','Years',value = 5),
                            numericInput('interest','Interest',value = 5)),
                        box(width = 9,
                            verticalLayout(
                                box(title='Result',background = 'navy',width = 4,
                                    textOutput('futurepresent')),
                                box(title = 'Timeline',
                                    plotlyOutput('chartfuturepresent'),width = 12)
                            )
                            )
                    )),
            tabItem('future',
                    sidebarLayout(
                        sidebarPanel(),
                        mainPanel()
                    )),
            tabItem('irr',
                    sidebarLayout(
                        sidebarPanel(),
                        mainPanel()
                    )),
            tabItem('debt',
                    sidebarLayout(
                        sidebarPanel(),
                        mainPanel()
                    ))
        )
    )
    
)
    


#tags$a(img(src='github.png'),href='https://github.com/angeliflavio')