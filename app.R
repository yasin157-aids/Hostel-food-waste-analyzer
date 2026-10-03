# Hostel Food Waste Analyzer
# RStudio project
# Run by opening run_project.R and clicking Source.

required <- c("shiny","shinydashboard","dplyr","ggplot2","plotly","DT")
missing <- required[!sapply(required, requireNamespace, quietly = TRUE)]
if (length(missing) > 0) {
  install.packages(missing, repos = "https://cloud.r-project.org")
}

library(shiny)
library(shinydashboard)
library(dplyr)
library(ggplot2)
library(plotly)
library(DT)

csv_path <- file.path("data", "hostel_food_waste.csv")

if (!file.exists(csv_path)) {
  stop("CSV file not found. Keep the data folder beside app.R.")
}

food_data <- read.csv(csv_path, stringsAsFactors = FALSE)

blocks <- sort(unique(food_data$Hostel_Block))
meal_types <- sort(unique(food_data$Meal_Type))
food_items <- sort(unique(food_data$Food_Item))

ui <- dashboardPage(
  dashboardHeader(title = "Hostel Food Waste Analyzer"),

  dashboardSidebar(
    sidebarMenu(
      menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard")),
      menuItem("Waste Analysis", tabName = "analysis", icon = icon("chart-bar")),
      menuItem("Food Insights", tabName = "insights", icon = icon("utensils")),
      menuItem("Add Record", tabName = "input", icon = icon("plus-circle")),
      menuItem("Data Table", tabName = "data", icon = icon("table"))
    ),

    hr(),

    selectInput(
      "block_filter",
      "Hostel Block",
      choices = c("All", blocks),
      selected = "All"
    ),

    selectInput(
      "meal_filter",
      "Meal Type",
      choices = c("All", meal_types),
      selected = "All"
    ),

    selectInput(
      "month_filter",
      "Month",
      choices = c("All", months),
      selected = "All"
    )
  ),

  dashboardBody(
    tags$head(
      tags$link(
        rel = "stylesheet",
        type = "text/css",
        href = "style.css"
      )
    ),

    tabItems(

      # ---------------- DASHBOARD ----------------
      tabItem(
        tabName = "dashboard",

        fluidRow(
          valueBoxOutput("total_records"),
          valueBoxOutput("total_waste"),
          valueBoxOutput("waste_cost"),
          valueBoxOutput("waste_rate")
        ),

        fluidRow(
          box(
            width = 7,
            title = "Food Waste by Meal",
            status = "primary",
            solidHeader = TRUE,
            plotlyOutput("meal_waste_plot", height = "320px")
          ),

          box(
            width = 5,
            title = "Waste Composition",
            status = "success",
            solidHeader = TRUE,
            plotlyOutput("composition_plot", height = "320px")
          )
        ),

        fluidRow(
          box(
            width = 7,
            title = "Monthly Waste Trend",
            status = "info",
            solidHeader = TRUE,
            plotlyOutput("monthly_plot", height = "300px")
          ),

          box(
            width = 5,
            title = "Quick Insights",
            status = "warning",
            solidHeader = TRUE,
            uiOutput("quick_insights")
          )
        )
      ),

      # ---------------- ANALYSIS ----------------
      tabItem(
        tabName = "analysis",

        fluidRow(
          box(
            width = 6,
            title = "Waste by Hostel Block",
            status = "primary",
            solidHeader = TRUE,
            plotlyOutput("block_waste_plot", height = "350px")
          ),

          box(
            width = 6,
            title = "Waste Cost by Meal",
            status = "danger",
            solidHeader = TRUE,
            plotlyOutput("cost_meal_plot", height = "350px")
          )
        ),

        fluidRow(
          box(
            width = 12,
            title = "Meals Served vs Food Waste",
            status = "success",
            solidHeader = TRUE,
            plotlyOutput("served_waste_plot", height = "360px")
          )
        )
      ),

      # ---------------- FOOD INSIGHTS ----------------
      tabItem(
        tabName = "insights",

        fluidRow(
          box(
            width = 6,
            title = "Top Food Items by Waste",
            status = "warning",
            solidHeader = TRUE,
            plotlyOutput("item_waste_plot", height = "360px")
          ),

          box(
            width = 6,
            title = "Snacks Waste Analysis",
            status = "info",
            solidHeader = TRUE,
            plotlyOutput("snacks_plot", height = "360px")
          )
        ),

        fluidRow(
          box(
            width = 12,
            title = "Waste Management Recommendations",
            status = "success",
            solidHeader = TRUE,
            uiOutput("recommendations")
          )
        )
      ),

      # ---------------- INPUT ----------------
      tabItem(
        tabName = "input",

        fluidRow(
          box(
            width = 7,
            title = "Add Food Waste Record",
            status = "primary",
            solidHeader = TRUE,

            dateInput(
              "record_date",
              "Record Date",
              value = Sys.Date()
            ),

            selectInput(
              "new_block",
              "Hostel Block",
              choices = blocks
            ),

            selectInput(
              "new_meal",
              "Meal Type",
              choices = meal_types
            ),

            textInput(
              "new_item",
              "Food Item",
              placeholder = "Example: Idli, Samosa, Rice..."
            ),

            numericInput(
              "new_served",
              "Meals Served",
              value = 100,
              min = 1
            ),

            numericInput(
              "new_consumed",
              "Meals Consumed",
              value = 85,
              min = 0
            ),

            numericInput(
              "new_waste",
              "Food Waste (Kg)",
              value = 5,
              min = 0
            ),

            numericInput(
              "new_plate_waste",
              "Plate Waste (Kg)",
              value = 3,
              min = 0
            ),

            numericInput(
              "new_leftover",
              "Kitchen Leftover (Kg)",
              value = 2,
              min = 0
            ),

            numericInput(
              "new_cost",
              "Estimated Waste Cost (Rs)",
              value = 350,
              min = 0
            ),

            numericInput(
              "new_bins",
              "Waste Bins Used",
              value = 1,
              min = 0
            ),

            actionButton(
              "save_record",
              "Save Food Waste Record",
              icon = icon("save"),
              class = "btn-primary"
            ),

            br(),
            br(),

            uiOutput("save_message")
          ),

          box(
            width = 5,
            title = "Why record food waste?",
            status = "info",
            solidHeader = TRUE,

            HTML(
              "<div class='info-card'>
              <h4>HostelPulse Food Management</h4>
              <p>Track food waste from breakfast, lunch, dinner and snacks.</p>
              <p><b>Identify:</b></p>
              <ul>
              <li>Meals producing the most waste</li>
              <li>Hostel blocks with higher waste</li>
              <li>Monthly waste trends</li>
              <li>Estimated money lost through waste</li>
              <li>Snack wastage patterns</li>
              </ul>
              </div>"
            )
          )
        )
      ),

      # ---------------- DATA ----------------
      tabItem(
        tabName = "data",

        box(
          width = 12,
          title = "Hostel Food Waste Records",
          status = "primary",
          solidHeader = TRUE,

          DTOutput("food_table")
        )
      )
    )
  )
)

server <- function(input, output, session) {

  food_records <- reactiveVal(food_data)

  filtered_data <- reactive({

    d <- food_records()

    if (input$block_filter != "All") {
      d <- d %>% filter(Hostel_Block == input$block_filter)
    }

    if (input$meal_filter != "All") {
      d <- d %>% filter(Meal_Type == input$meal_filter)
    }

    if (input$month_filter != "All") {
      d <- d %>% filter(Month == input$month_filter)
    }

    d
  })

  # ---------------- KPI CARDS ----------------

  output$total_records <- renderValueBox({

    valueBox(
      nrow(filtered_data()),
      "Records",
      icon = icon("database"),
      color = "aqua"
    )
  })

  output$total_waste <- renderValueBox({

    valueBox(
      paste0(round(sum(filtered_data()$Food_Waste_Kg), 1), " kg"),
      "Total Food Waste",
      icon = icon("trash"),
      color = "red"
    )
  })

  output$waste_cost <- renderValueBox({

    valueBox(
      paste0("Rs. ", format(round(sum(filtered_data()$Estimated_Waste_Cost_Rs), 0), big.mark = ",")),
      "Estimated Waste Cost",
      icon = icon("rupee-sign"),
      color = "yellow"
    )
  })

  output$waste_rate <- renderValueBox({

    d <- filtered_data()

    rate <- if (sum(d$Meals_Served) > 0) {
      (sum(d$Food_Waste_Kg) / sum(d$Meals_Served)) * 100
    } else {
      0
    }

    valueBox(
      paste0(round(rate, 2), "%"),
      "Waste Rate",
      icon = icon("percent"),
      color = "green"
    )
  })

  # ---------------- CHARTS ----------------

  output$meal_waste_plot <- renderPlotly({

    d <- filtered_data() %>%
      group_by(Meal_Type) %>%
      summarise(Waste = sum(Food_Waste_Kg), .groups = "drop")

    p <- ggplot(
      d,
      aes(
        x = Meal_Type,
        y = Waste,
        text = paste0(
          Meal_Type,
          "<br>Waste: ",
          round(Waste, 1),
          " kg"
        )
      )
    ) +
      geom_col() +
      theme_minimal() +
      labs(
        x = NULL,
        y = "Food Waste (Kg)"
      )

    plotly::ggplotly(p, tooltip = "text")
  })

  output$composition_plot <- renderPlotly({

    d <- filtered_data()

    comp <- data.frame(
      Type = c("Plate Waste", "Kitchen Leftover"),
      Waste = c(
        sum(d$Plate_Waste_Kg),
        sum(d$Kitchen_Leftover_Kg)
      )
    )

    p <- ggplot(
      comp,
      aes(
        x = Type,
        y = Waste,
        fill = Type,
        text = paste0(
          Type,
          ": ",
          round(Waste, 1),
          " kg"
        )
      )
    ) +
      geom_col(width = 0.65) +
      theme_minimal() +
      labs(
        x = NULL,
        y = "Waste (Kg)"
      ) +
      theme(legend.position = "none")

    plotly::ggplotly(p, tooltip = "text")
  })

  output$monthly_plot <- renderPlotly({

    d <- filtered_data() %>%
      group_by(Month) %>%
      summarise(Waste = sum(Food_Waste_Kg), .groups = "drop")

    d$Month <- factor(
      d$Month,
      levels = c("June", "July", "August", "September")
    )

    p <- ggplot(
      d,
      aes(
        x = Month,
        y = Waste,
        group = 1,
        text = paste0(
          Month,
          "<br>Waste: ",
          round(Waste, 1),
          " kg"
        )
      )
    ) +
      geom_line(linewidth = 1.2) +
      geom_point(size = 3) +
      theme_minimal() +
      labs(
        x = NULL,
        y = "Food Waste (Kg)"
      )

    plotly::ggplotly(p, tooltip = "text")
  })

  output$block_waste_plot <- renderPlotly({

    d <- filtered_data() %>%
      group_by(Hostel_Block) %>%
      summarise(Waste = sum(Food_Waste_Kg), .groups = "drop")

    p <- ggplot(
      d,
      aes(
        x = reorder(Hostel_Block, Waste),
        y = Waste,
        text = paste0(
          Hostel_Block,
          "<br>Waste: ",
          round(Waste, 1),
          " kg"
        )
      )
    ) +
      geom_col() +
      coord_flip() +
      theme_minimal() +
      labs(
        x = NULL,
        y = "Food Waste (Kg)"
      )

    plotly::ggplotly(p, tooltip = "text")
  })

  output$cost_meal_plot <- renderPlotly({

    d <- filtered_data() %>%
      group_by(Meal_Type) %>%
      summarise(Cost = sum(Estimated_Waste_Cost_Rs), .groups = "drop")

    p <- ggplot(
      d,
      aes(
        x = Meal_Type,
        y = Cost,
        text = paste0(
          Meal_Type,
          "<br>Estimated cost: Rs. ",
          round(Cost, 0)
        )
      )
    ) +
      geom_col() +
      theme_minimal() +
      labs(
        x = NULL,
        y = "Estimated Cost (Rs.)"
      )

    plotly::ggplotly(p, tooltip = "text")
  })

  output$served_waste_plot <- renderPlotly({

    d <- filtered_data()

    p <- ggplot(
      d,
      aes(
        x = Meals_Served,
        y = Food_Waste_Kg,
        text = paste0(
          "Block: ", Hostel_Block,
          "<br>Meal: ", Meal_Type,
          "<br>Served: ", Meals_Served,
          "<br>Waste: ", Food_Waste_Kg, " kg"
        )
      )
    ) +
      geom_point(size = 3, alpha = 0.7) +
      theme_minimal() +
      labs(
        x = "Meals Served",
        y = "Food Waste (Kg)"
      )

    plotly::ggplotly(p, tooltip = "text")
  })

  output$item_waste_plot <- renderPlotly({

    d <- filtered_data() %>%
      group_by(Food_Item) %>%
      summarise(Waste = sum(Food_Waste_Kg), .groups = "drop") %>%
      arrange(desc(Waste)) %>%
      head(10)

    p <- ggplot(
      d,
      aes(
        x = reorder(Food_Item, Waste),
        y = Waste,
        text = paste0(
          Food_Item,
          "<br>Waste: ",
          round(Waste, 1),
          " kg"
        )
      )
    ) +
      geom_col() +
      coord_flip() +
      theme_minimal() +
      labs(
        x = NULL,
        y = "Food Waste (Kg)"
      )

    plotly::ggplotly(p, tooltip = "text")
  })

  output$snacks_plot <- renderPlotly({

    d <- filtered_data() %>%
      filter(Meal_Type == "Snacks") %>%
      group_by(Food_Item) %>%
      summarise(Waste = sum(Food_Waste_Kg), .groups = "drop")

    if (nrow(d) == 0) {
      d <- data.frame(
        Food_Item = "No snack records",
        Waste = 0
      )
    }

    p <- ggplot(
      d,
      aes(
        x = reorder(Food_Item, Waste),
        y = Waste,
        text = paste0(
          Food_Item,
          "<br>Waste: ",
          round(Waste, 1),
          " kg"
        )
      )
    ) +
      geom_col() +
      coord_flip() +
      theme_minimal() +
      labs(
        x = NULL,
        y = "Snack Waste (Kg)"
      )

    plotly::ggplotly(p, tooltip = "text")
  })

  # ---------------- INSIGHTS ----------------

  output$quick_insights <- renderUI({

    d <- filtered_data()

    if (nrow(d) == 0) {
      return(HTML(
        "<div class='insight-card'>No records match the selected filters.</div>"
      ))
    }

    top_meal <- d %>%
      group_by(Meal_Type) %>%
      summarise(Waste = sum(Food_Waste_Kg), .groups = "drop") %>%
      arrange(desc(Waste)) %>%
      slice(1)

    top_block <- d %>%
      group_by(Hostel_Block) %>%
      summarise(Waste = sum(Food_Waste_Kg), .groups = "drop") %>%
      arrange(desc(Waste)) %>%
      slice(1)

    HTML(
      paste0(
        "<div class='insight-card'><b>Highest waste meal:</b> ",
        top_meal$Meal_Type,
        " (",
        round(top_meal$Waste, 1),
        " kg)</div>",

        "<div class='insight-card'><b>Highest waste block:</b> ",
        top_block$Hostel_Block,
        " (",
        round(top_block$Waste, 1),
        " kg)</div>",

        "<div class='insight-card'><b>Total records:</b> ",
        nrow(d),
        "</div>",

        "<div class='insight-card'><b>Focus:</b> Review portions, menu planning and leftover quantities.</div>"
      )
    )
  })

  output$recommendations <- renderUI({

    d <- filtered_data()

    waste <- sum(d$Food_Waste_Kg)

    if (waste > 2500) {
      level <- "High waste level detected. Review meal quantities and portion sizes."
    } else if (waste > 1200) {
      level <- "Moderate waste level. Monitor high-waste meals and leftovers."
    } else {
      level <- "Waste level is relatively controlled. Continue regular monitoring."
    }

    HTML(
      paste0(
        "<div class='recommendation-card'>
        <h4>Recommended Actions</h4>
        <ul>
        <li>", level, "</li>
        <li>Track breakfast, lunch, dinner and snacks separately.</li>
        <li>Adjust meal preparation based on previous consumption.</li>
        <li>Identify food items repeatedly appearing in the top-waste list.</li>
        <li>Monitor snack waste because small items can create repeated daily losses.</li>
        <li>Use the estimated waste cost to understand financial impact.</li>
        </ul>
        </div>"
      )
    )
  })

  # ---------------- SAVE USER INPUT ----------------

  observeEvent(input$save_record, {

    req(input$new_item)

    old <- food_records()

    new_id <- ifelse(
      nrow(old) == 0,
      1,
      max(old$Record_ID) + 1
    )

    new_month <- format(
      as.Date(input$record_date),
      "%B"
    )

    new_row <- data.frame(
      Record_ID = new_id,
      Month = new_month,
      Hostel_Block = input$new_block,
      Meal_Type = input$new_meal,
      Food_Item = input$new_item,
      Meals_Served = input$new_served,
      Meals_Consumed = input$new_consumed,
      Food_Waste_Kg = input$new_waste,
      Plate_Waste_Kg = input$new_plate_waste,
      Kitchen_Leftover_Kg = input$new_leftover,
      Estimated_Waste_Cost_Rs = input$new_cost,
      Waste_Bins = input$new_bins,
      stringsAsFactors = FALSE
    )

    updated <- bind_rows(old, new_row)

    food_records(updated)

    write.csv(
      updated,
      csv_path,
      row.names = FALSE
    )

    output$save_message <- renderUI(
      HTML(
        "<div class='success-msg'>
        Food waste record saved successfully!
        </div>"
      )
    )
  })

  # ---------------- DATA TABLE ----------------

  output$food_table <- renderDT({

    datatable(
      filtered_data(),
      filter = "top",
      rownames = FALSE,
      options = list(
        pageLength = 12,
        scrollX = TRUE
      )
    )
  })
}

shinyApp(ui, server)
