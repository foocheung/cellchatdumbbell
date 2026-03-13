#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function(input, output, session) {
  # Increase file upload size limit
  options(shiny.maxRequestSize = 500*1024^2)

  # Central reactive values shared across all modules
  shared_rv <- reactiveValues(
    cellchat = NULL,
    lr_pathway_map = NULL,
    interaction_df = NULL,
    cell_types = NULL,
    plots = NULL,
    plot_data = NULL,
    plot_height = 800
  )

  # Call modules and pass shared reactive values
  mod_file_upload_server("file_upload_1", shared_rv)
  plot_inputs <- mod_plot_controls_server("plot_controls_1", shared_rv)
  mod_plot_display_server("plot_display_1", shared_rv, plot_inputs)
  mod_data_table_server("data_table_1", shared_rv)
  mod_summary_server("summary_1", shared_rv)
}
