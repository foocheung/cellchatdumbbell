#' data_table UI Function
#'
#' @description A shiny Module for displaying data tables.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
#' @importFrom magrittr %>%
mod_data_table_ui <- function(id) {
  ns <- NS(id)
  tagList(
    br(),
    h4("LR Pair Changes Across Selected Cell Type Pairs"),
    DT::DTOutput(ns("data_table"))
  )
}

#' data_table Server Functions
#'
#' @noRd
mod_data_table_server <- function(id, shared_rv) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    # Data table output
    output$data_table <- DT::renderDT({
      req(shared_rv$plot_data)

      plot_data <- shared_rv$plot_data

      # Get condition names dynamically
      cond_names <- setdiff(names(plot_data),
                            c("lr", "delta", "abs_delta", "pathway", "lr_pathway",
                              "sender", "receiver", "pair"))

      # Select columns to display
      display_cols <- c("pair", "sender", "receiver", "lr", "pathway",
                        cond_names, "delta", "abs_delta")
      display_data <- plot_data %>%
        dplyr::select(dplyr::all_of(display_cols))

      DT::datatable(
        display_data,
        options = list(
          pageLength = 25,
          scrollX = TRUE,
          order = list(list(length(display_cols) - 1, 'desc'))
        ),
        filter = 'top',
        rownames = FALSE
      ) %>%
        DT::formatRound(columns = c(cond_names, 'delta', 'abs_delta'), digits = 4)
    })
  })
}
