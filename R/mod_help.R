#' help UI Function
#'
#' @description A shiny Module for help documentation.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_help_ui <- function(id) {
  ns <- NS(id)
  tagList(
    br(),
    h4("How to Use This App"),
    tags$ol(
      tags$li(tags$strong("Upload CellChat Object:"), " Use the file upload button to load your merged CellChat RDS file."),
      tags$li(tags$strong("Select Cell Types:"), " Choose sender and receiver cell types. You can select multiple of each."),
      tags$li(tags$strong("Adjust Settings:"), " Customize the number of LR pairs shown, label width, and color scheme."),
      tags$li(tags$strong("Generate Plots:"), " Click the 'Generate Plots' button to create dumbbell plots."),
      tags$li(tags$strong("Explore Results:"), " Switch between tabs to view plots, data tables, and summary statistics."),
      tags$li(tags$strong("Download:"), " Export plots as PDF or data as CSV.")
    ),
    hr(),
    h4("Understanding the Plots"),
    tags$ul(
      tags$li(tags$strong("Dumbbell plots"), " show the communication probability for each ligand-receptor pair in both conditions."),
      tags$li(tags$strong("Dots"), " represent the probability in each condition (connected by a line)."),
      tags$li(tags$strong("Longer lines"), " indicate bigger differences between conditions."),
      tags$li(tags$strong("Pathways"), " are shown in brackets after each LR pair (if available).")
    ),
    hr(),
    h4("Tips"),
    tags$ul(
      tags$li("Use the 'CD4↔CD8 Crosstalk' button for quick setup if analyzing T cell interactions."),
      tags$li("Try 'All pairs' mode to see complete data without filtering by top N."),
      tags$li("The Data Table tab allows sorting and searching for specific LR pairs."),
      tags$li("Summary statistics show which cell type pairs have the most dramatic changes.")
    )
  )
}
