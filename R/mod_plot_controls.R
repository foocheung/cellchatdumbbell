#' plot_controls UI Function
#'
#' @description A shiny Module for plot control inputs.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
#' @importFrom magrittr %>%
mod_plot_controls_ui <- function(id) {
  ns <- NS(id)
  tagList(
    conditionalPanel(
      condition = "output.fileUploaded",
      ns = ns,

      h4("Select Cell Type Pairs"),

      # Quick selection buttons
      actionButton(ns("select_all_senders"), "Select All Senders",
                   class = "btn-sm btn-default"),
      actionButton(ns("clear_senders"), "Clear Senders",
                   class = "btn-sm btn-default"),

      # Sender selection
      selectInput(ns("senders"), "Sender Cell Types:",
                  choices = NULL, multiple = TRUE),

      actionButton(ns("select_all_receivers"), "Select All Receivers",
                   class = "btn-sm btn-default"),
      actionButton(ns("clear_receivers"), "Clear Receivers",
                   class = "btn-sm btn-default"),

      # Receiver selection
      selectInput(ns("receivers"), "Receiver Cell Types:",
                  choices = NULL, multiple = TRUE),

      # Quick preset: CD4/CD8 crosstalk
      conditionalPanel(
        condition = "output.hasCDCells",
        ns = ns,
        hr(),
        actionButton(ns("cd4_cd8_preset"), "CD4↔CD8 Crosstalk (4 plots)",
                     class = "btn-sm btn-info btn-block")
      ),

      hr(),

      # Plot settings
      h4("Plot Settings"),
      radioButtons(ns("top_n_mode"), "LR pairs to show:",
                   choices = list("Top N by |delta|" = "topn",
                                  "All pairs" = "all"),
                   selected = "topn"),

      conditionalPanel(
        condition = "input.top_n_mode == 'topn'",
        ns = ns,
        numericInput(ns("top_n"), "Top N LR pairs per plot:",
                     value = 10, min = 5, max = 50, step = 5)
      ),

      numericInput(ns("label_width"), "Label truncation width:",
                   value = 70, min = 40, max = 120, step = 10),

      checkboxInput(ns("same_x_scale"), "Use same X-axis scale across plots",
                    value = TRUE),

      checkboxInput(ns("show_pathway"), "Show pathway in labels",
                    value = TRUE),

      selectInput(ns("color_palette"), "Color palette:",
                  choices = c("Default" = "default",
                              "Viridis" = "viridis",
                              "Set2" = "set2",
                              "Dark2" = "dark2",
                              "Red-Blue" = "redblue"),
                  selected = "default"),

      hr(),
      h4("Plot Dimensions"),
      sliderInput(ns("plot_width"), "Plot width (pixels):",
                  min = 600, max = 2000, value = 1000, step = 50),
      sliderInput(ns("plot_height_per_pair"), "Height per cell type pair (pixels):",
                  min = 200, max = 800, value = 400, step = 50),
      sliderInput(ns("point_size"), "Point size:",
                  min = 1, max = 8, value = 3, step = 0.5),
      sliderInput(ns("text_size"), "Text size:",
                  min = 6, max = 14, value = 9, step = 1),

      hr(),

      # Action button
      actionButton(ns("generate"), "Generate Plots",
                   class = "btn-primary btn-lg btn-block"),

      hr(),

      # Download buttons
      downloadButton(ns("download_plots"), "Download PDF",
                     class = "btn-success btn-block"),
      downloadButton(ns("download_data"), "Download Data (CSV)",
                     class = "btn-info btn-block")
    )
  )
}

#' plot_controls Server Functions
#'
#' @noRd
mod_plot_controls_server <- function(id, shared_rv) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    # Track if file is uploaded
    output$fileUploaded <- reactive({
      return(!is.null(shared_rv$cellchat))
    })
    outputOptions(output, "fileUploaded", suspendWhenHidden = FALSE)

    # Track if CD4/CD8 cells exist
    output$hasCDCells <- reactive({
      if (is.null(shared_rv$cell_types)) return(FALSE)
      has_cd4 <- any(grepl("CD4", shared_rv$cell_types, ignore.case = TRUE))
      has_cd8 <- any(grepl("CD8", shared_rv$cell_types, ignore.case = TRUE))
      return(has_cd4 && has_cd8)
    })
    outputOptions(output, "hasCDCells", suspendWhenHidden = FALSE)

    # Update selector choices when file is loaded
    observe({
      req(shared_rv$cell_types)
      updateSelectInput(session, "senders", choices = shared_rv$cell_types)
      updateSelectInput(session, "receivers", choices = shared_rv$cell_types)
    })

    # Button handlers
    observeEvent(input$select_all_senders, {
      req(shared_rv$cell_types)
      updateSelectInput(session, "senders", selected = shared_rv$cell_types)
    })

    observeEvent(input$clear_senders, {
      updateSelectInput(session, "senders", selected = character(0))
    })

    observeEvent(input$select_all_receivers, {
      req(shared_rv$cell_types)
      updateSelectInput(session, "receivers", selected = shared_rv$cell_types)
    })

    observeEvent(input$clear_receivers, {
      updateSelectInput(session, "receivers", selected = character(0))
    })

    observeEvent(input$cd4_cd8_preset, {
      req(shared_rv$cell_types)
      cd4_cells <- shared_rv$cell_types[grepl("CD4", shared_rv$cell_types, ignore.case = TRUE)]
      cd8_cells <- shared_rv$cell_types[grepl("CD8", shared_rv$cell_types, ignore.case = TRUE)]
      both <- c(cd4_cells, cd8_cells)
      updateSelectInput(session, "senders", selected = both)
      updateSelectInput(session, "receivers", selected = both)
      showNotification("Selected CD4 and CD8 cell types for both senders and receivers",
                       type = "message", duration = 3)
    })

    # Generate plots (processing logic)
    observeEvent(input$generate, {
      req(shared_rv$cellchat, shared_rv$interaction_df, shared_rv$lr_pathway_map)
      req(length(input$senders) > 0, length(input$receivers) > 0)

      plot_data <- fct_generate_plot_data(
        interaction_df = shared_rv$interaction_df,
        lr_pathway_map = shared_rv$lr_pathway_map,
        senders = input$senders,
        receivers = input$receivers,
        top_n_mode = input$top_n_mode,
        top_n = input$top_n,
        show_pathway = input$show_pathway,
        label_width = input$label_width
      )

      shared_rv$plot_data <- plot_data$all_pair_data

      plots <- fct_generate_plots(
        pair_data = plot_data$pair_data,
        pairs = plot_data$pairs,
        cond_names = plot_data$cond_names,
        same_x_scale = input$same_x_scale,
        show_pathway = input$show_pathway,
        color_palette = input$color_palette,
        point_size = input$point_size,
        text_size = input$text_size
      )

      shared_rv$plots <- plots
      shared_rv$plot_height <- max(400, nrow(plot_data$pairs) * input$plot_height_per_pair)

      showNotification(paste("Generated", length(plots), "plot(s)!"),
                       type = "message", duration = 3)
    })

    # Download handlers
    output$download_plots <- downloadHandler(
      filename = function() {
        paste0("cellchat_dumbbell_plots_", Sys.Date(), ".pdf")
      },
      content = function(file) {
        req(shared_rv$plots)
        combined <- fct_combine_plots(shared_rv$plots)
        pdf_height <- max(8, length(shared_rv$plots) * 4)
        ggplot2::ggsave(file, combined, width = 8, height = pdf_height, units = "in")
      }
    )

    output$download_data <- downloadHandler(
      filename = function() {
        paste0("cellchat_lr_changes_", Sys.Date(), ".csv")
      },
      content = function(file) {
        req(shared_rv$plot_data)
        write.csv(shared_rv$plot_data, file, row.names = FALSE)
      }
    )

    # Return reactive inputs for plot display
    return(reactive({
      list(
        plot_width = input$plot_width
      )
    }))
  })
}
