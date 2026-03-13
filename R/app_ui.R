#' The application User-Interface
#'
#' @param request Internal parameter for `{shiny}`.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_ui <- function(request) {
  tagList(
    # Leave this function for adding external resources
    golem_add_external_resources(),

    # Your application UI logic
    fluidPage(
      titlePanel("CellChat Crosstalk Analysis - Dumbbell Plots"),

      sidebarLayout(
        sidebarPanel(
          width = 3,
          mod_file_upload_ui("file_upload_1"),
          hr(),
          mod_plot_controls_ui("plot_controls_1")
        ),

        mainPanel(
          width = 9,
          tabsetPanel(
            id = "main_tabs",

            # Tab 1: Plots
            tabPanel(
              "Dumbbell Plots",
              mod_plot_display_ui("plot_display_1")
            ),

            # Tab 2: Data Table
            tabPanel(
              "Data Table",
              mod_data_table_ui("data_table_1")
            ),

            # Tab 3: Summary Statistics
            tabPanel(
              "Summary",
              mod_summary_ui("summary_1")
            ),

            # Tab 4: Help
            tabPanel(
              "Help",
              mod_help_ui("help_1")
            )
          )
        )
      )
    )
  )
}

#' Add external Resources to the Application
#'
#' This function is internally used to add external
#' resources inside the Shiny application.
#'
#' @import shiny
#' @importFrom golem add_resource_path activate_js favicon bundle_resources
#' @noRd
golem_add_external_resources <- function() {
  add_resource_path(
    "www",
    app_sys("app/www")
  )

  tags$head(
    favicon(),
    bundle_resources(
      path = app_sys("app/www"),
      app_title = "CellChat Dumbbell Plot"
    )
    # Add here other external resources
    # for example, you can add shinyalert::useShinyalert()
  )
}
