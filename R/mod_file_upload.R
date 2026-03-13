#' file_upload UI Function
#'
#' @description A shiny Module for file upload and cell type selection.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
#' @importFrom magrittr %>%
mod_file_upload_ui <- function(id) {
  ns <- NS(id)
  tagList(
    fileInput(ns("cellchat_file"), "Upload CellChat RDS file",
              accept = c(".rds", ".RDS"))
  )
}

#' file_upload Server Functions
#'
#' @noRd
mod_file_upload_server <- function(id, shared_rv) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    # Load CellChat object
    observeEvent(input$cellchat_file, {
      req(input$cellchat_file)

      tryCatch({
        # Load the RDS file
        cellchat <- readRDS(input$cellchat_file$datapath)

        # Validate it's a CellChat object
        if (length(cellchat@net) < 2) {
          showNotification(
            "Invalid CellChat object. Must contain at least 2 conditions in @net slot.",
            type = "error", duration = 10
          )
          return(NULL)
        }

        # Store the object
        shared_rv$cellchat <- cellchat

        # Extract cell types from the first condition
        condition_names <- names(cellchat@net)
        first_condition <- cellchat@net[[condition_names[1]]]
        cell_types <- rownames(first_condition$prob)
        shared_rv$cell_types <- cell_types

        # Build LR -> pathway map
        lr_pathway_map <- dplyr::bind_rows(
          lapply(names(cellchat@LR), function(cond) {
            cellchat@LR[[cond]]$LRsig %>%
              dplyr::transmute(lr = interaction_name, pathway = pathway_name)
          })
        ) %>% dplyr::distinct()
        shared_rv$lr_pathway_map <- lr_pathway_map

        # Build interaction dataframe
        df <- dplyr::bind_rows(
          lapply(names(cellchat@net), function(cond) {
            as.data.frame.table(cellchat@net[[cond]]$prob) %>%
              dplyr::rename(sender = Var1, receiver = Var2, lr = Var3, prob = Freq) %>%
              dplyr::mutate(group = cond)
          })
        ) %>%
          dplyr::filter(prob > 0)
        shared_rv$interaction_df <- df

        showNotification(
          paste0("Loaded CellChat object with ", length(cell_types),
                 " cell types and ", length(condition_names), " conditions."),
          type = "message", duration = 5
        )
      }, error = function(e) {
        showNotification(paste("Error loading file:", e$message),
                         type = "error", duration = 10)
      })
    })
  })
}
