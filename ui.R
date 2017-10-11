library(shiny)
library(shinyBS)
library(shinydashboard)
library(plotly)

dashboardPage(
    dashboardHeader(title = 'Financial Calculator',
                    dropdownMenu(type = 'notification',headerText = ' ',
                                 icon = img(src='github.png',width='17px'),badgeStatus = NULL,
                                 notificationItem('GitHub Source Code',
                                                  href = 'https://github.com/angeliflavio/FinancialCalculator',
                                                  icon = icon('github')))),
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
                                valueBoxOutput('futurepresent',width = 6),
                                box(title = 'Chart',
                                    plotlyOutput('chartfuturepresent'),width = 12)
                            )
                            )
                    )),
            tabItem('flow',
                    fluidRow(
                        box(title = 'Options',background = 'light-blue',width = 3,collapsible = T,
                            numericInput('discountrate','Interest Rate (%)',value = 5),
                            numericInput('numberflows','Number of Flows',value = 12),
                            selectInput('flowsfrequency','Flows Frequency (months)',
                                        choices = seq(1,12),selected = 12),
                            br(),
                            radioButtons('constantvariable','Cash Flow',
                                         choices = c('Constant','Variable'),
                                         inline = T,selected = 'Constant'),
                            conditionalPanel(
                                condition = "input.constantvariable == 'Constant'",
                                numericInput('constantflow','Constant Flow',value = 1000)
                            ),
                            conditionalPanel(
                                condition = "input.constantvariable == 'Variable'",
                                fluidRow(
                                    column(width=6,numericInput('from','From',value = 1,min = 1,max = 100,step = 1)),
                                    column(width=6,numericInput('to','To',value = 1,min = 1,max = 100,step = 1))
                                ),
                                numericInput('variableflow','Variable Flow',value = 1000)
                            ),
                            actionButton('delete','Delete',
                                         style="color:white;background-color:midnightblue;border-color:midnightblue"),
                            actionButton('insert','Update',
                                         style="color:white;background-color:midnightblue;border-color:midnightblue")
                        ),
                        tabBox(width = 9,
                               tabPanel('Flows Table',
                                        flowLayout(
                                            valueBoxOutput('presentvalue',width = 12),
                                            valueBoxOutput('finalvalue',width = 12)
                                        ),
                                        dataTableOutput('tableflows')
                                        ),
                               tabPanel('Chart',plotlyOutput('chartflow')))
                    )
                    ),
            tabItem('irr',
                    fluidRow(
                        box(title = 'Options',background = 'light-blue',width = 3,collapsible = T,
                            numericInput('initialvalue','Initial Value',value = 1000),
                            numericInput('finalvalue','Final Value',value = 1500),
                            numericInput('yearsirr','Years',value = 5)),
                        box(width = 9,
                            valueBoxOutput('irr',width = 6))
                    )
                   ),
            tabItem('debt',
                    fluidRow(
                        box(title = 'Options',background = 'light-blue',width = 3,collapsible = T,
                            numericInput('debt','Debt Amount',value = 1000),
                            numericInput('yearsdebt','Duration (years)',value = 5),
                            numericInput('interestdebt','Annual Interest (in %)',value = 5),
                            selectInput('debtfrequency','Payment Frequency (months)',
                                        choices = seq(1:12),selected = 1)),
                        tabBox(width = 9,
                            tabPanel('Table',dataTableOutput('tabledebt')),
                            tabPanel('Chart',plotlyOutput('chartdebt')),
                            tabPanel('Summary',
                                     fluidRow(
                                         box(width = 12,
                                             valueBoxOutput('debtpayment',width = 6),
                                             valueBoxOutput('debtsummary',width = 6),
                                             valueBoxOutput('totalinterest',width = 6),
                                             valueBoxOutput('totalpaid',width = 6)
                                         )
                                     )
                                     )
                        )
                    )
                    )
        )
    )
    
)
    

