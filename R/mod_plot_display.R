#' plot_display UI Function
#'
#' @description A shiny Module for displaying plots.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_plot_display_ui <- function(id) {
  ns <- NS(id)
  tagList(
    uiOutput(ns("status_message")),
    hr(),
    shinycssloaders::withSpinner(
      plotOutput(ns("dumbbell_plots"), height = "auto"),
      type = 6, color = "#0073b7"
    )
  )
}

#' plot_display Server Functions
#'
#' @noRd
mod_plot_display_server <- function(id, shared_rv, plot_inputs) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    # Status message
    output$status_message <- renderUI({
      if (is.null(shared_rv$cellchat)) {
        tags$div(
          class = "alert alert-info",
          tags$strong("Upload a CellChat object to begin."),
          tags$p("The object should be a merged CellChat object with multiple conditions.")
        )
      } else if (is.null(shared_rv$plots)) {
        tags$div(
          class = "alert alert-success",
          tags$strong("CellChat object loaded successfully!"),
          tags$p(paste("Found", length(shared_rv$cell_types), "cell types.")),
          tags$p("Select sender and receiver cell types, then click 'Generate Plots'.")
        )
      } else {
        tags$div(
          class = "alert alert-success",
          tags$strong("Plots generated!"),
          tags$p(paste("Showing", length(shared_rv$plots), "dumbbell plot(s)."))
        )
      }
    })

    # Render plots
    output$dumbbell_plots <- renderPlot({
      req(shared_rv$plots)
      fct_combine_plots(shared_rv$plots)
    }, height = function() {
      if (!is.null(shared_rv$plot_height)) {
        shared_rv$plot_height
      } else {
        800
      }
    }, width = function() {
      inputs <- plot_inputs()
      if (!is.null(inputs) && !is.null(inputs$plot_width)) {
        inputs$plot_width
      } else {
        1000
      }
    })
  })
}
