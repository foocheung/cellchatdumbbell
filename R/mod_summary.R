#' summary UI Function
#'
#' @description A shiny Module for summary statistics.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
#' @importFrom magrittr %>%
mod_summary_ui <- function(id) {
  ns <- NS(id)
  tagList(
    br(),
    h4("Summary Statistics"),
    wellPanel(
      h5("Overall Statistics"),
      verbatimTextOutput(ns("summary_stats"))
    ),
    h4("Top Changes by Cell Type Pair"),
    DT::DTOutput(ns("summary_table"))
  )
}

#' summary Server Functions
#'
#' @noRd
mod_summary_server <- function(id, shared_rv) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    # Summary statistics
    output$summary_stats <- renderPrint({
      req(shared_rv$plot_data)

      plot_data <- shared_rv$plot_data

      cond_names <- setdiff(names(plot_data),
                            c("lr", "delta", "abs_delta", "pathway", "lr_pathway",
                              "sender", "receiver", "pair"))

      cat("=== Overall Statistics ===\n\n")
      cat("Total LR pairs analyzed:", nrow(plot_data), "\n")
      cat("Unique LR pairs:", length(unique(plot_data$lr)), "\n")
      cat("Unique pathways:", length(unique(plot_data$pathway)), "\n")
      cat("Cell type pairs:", length(unique(plot_data$pair)), "\n")
      cat("Conditions compared:", paste(cond_names, collapse = " vs "), "\n\n")

      cat("=== Delta Statistics ===\n\n")
      cat("Mean |delta|:", round(mean(plot_data$abs_delta, na.rm = TRUE), 4), "\n")
      cat("Median |delta|:", round(median(plot_data$abs_delta, na.rm = TRUE), 4), "\n")
      cat("Max |delta|:", round(max(plot_data$abs_delta, na.rm = TRUE), 4), "\n")
      cat("Min |delta|:", round(min(plot_data$abs_delta, na.rm = TRUE), 4), "\n\n")

      # Top increased and decreased
      cat("=== Top 5 Increased LR Pairs ===\n\n")
      top_inc <- plot_data %>%
        dplyr::arrange(dplyr::desc(delta)) %>%
        head(5) %>%
        dplyr::select(pair, lr, pathway, delta)
      print(top_inc, row.names = FALSE)

      cat("\n=== Top 5 Decreased LR Pairs ===\n\n")
      top_dec <- plot_data %>%
        dplyr::arrange(delta) %>%
        head(5) %>%
        dplyr::select(pair, lr, pathway, delta)
      print(top_dec, row.names = FALSE)

      cat("\n=== Top Pathways by Mean |Delta| ===\n\n")
      pathway_summary <- plot_data %>%
        dplyr::group_by(pathway) %>%
        dplyr::summarise(
          n_lr = dplyr::n(),
          mean_abs_delta = mean(abs_delta, na.rm = TRUE),
          .groups = "drop"
        ) %>%
        dplyr::arrange(dplyr::desc(mean_abs_delta)) %>%
        head(10)
      print(pathway_summary, n = 10)
    })

    # Summary table by pair
    output$summary_table <- DT::renderDT({
      req(shared_rv$plot_data)

      shared_rv$plot_data %>%
        dplyr::group_by(pair, sender, receiver) %>%
        dplyr::summarise(
          n_lr_pairs = dplyr::n(),
          mean_abs_delta = mean(abs_delta, na.rm = TRUE),
          max_abs_delta = max(abs_delta, na.rm = TRUE),
          top_lr = lr[which.max(abs_delta)],
          top_pathway = pathway[which.max(abs_delta)],
          .groups = "drop"
        ) %>%
        dplyr::arrange(dplyr::desc(mean_abs_delta)) %>%
        DT::datatable(
          options = list(
            pageLength = 15,
            scrollX = TRUE
          ),
          rownames = FALSE,
          colnames = c("Cell Type Pair", "Sender", "Receiver", "# LR Pairs",
                       "Mean |Delta|", "Max |Delta|", "Top LR Pair", "Top Pathway")
        ) %>%
        DT::formatRound(columns = c('mean_abs_delta', 'max_abs_delta'), digits = 4)
    })
  })
}
