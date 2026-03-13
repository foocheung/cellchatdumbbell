#' Generate Plot Data
#'
#' @description Process interaction data for plotting
#'
#' @param interaction_df Data frame of interactions
#' @param lr_pathway_map Data frame mapping LR to pathways
#' @param senders Vector of sender cell types
#' @param receivers Vector of receiver cell types
#' @param top_n_mode Mode for selecting LR pairs
#' @param top_n Number of top LR pairs
#' @param show_pathway Whether to show pathway in labels
#' @param label_width Width for label truncation
#'
#' @return List containing pair_data, all_pair_data, pairs, and cond_names
#'
#' @importFrom magrittr %>%
#' @noRd
fct_generate_plot_data <- function(interaction_df, lr_pathway_map, senders, receivers,
                                   top_n_mode, top_n, show_pathway, label_width) {

  # Create all sender-receiver combinations
  pairs <- expand.grid(
    sender = senders,
    receiver = receivers,
    stringsAsFactors = FALSE
  )

  n_pairs <- nrow(pairs)

  # Generate data for all pairs
  pair_data <- list()
  for (i in 1:n_pairs) {
    # Get LR change data for this pair
    pair_df <- interaction_df %>%
      dplyr::filter(sender == pairs$sender[i], receiver == pairs$receiver[i]) %>%
      dplyr::group_by(group, lr) %>%
      dplyr::summarise(prob_sum = sum(prob), .groups = "drop") %>%
      tidyr::pivot_wider(names_from = group, values_from = prob_sum, values_fill = 0)

    # Get condition names
    cond_names <- setdiff(names(pair_df), "lr")

    # Calculate delta
    pair_df <- pair_df %>%
      dplyr::mutate(
        delta = .data[[cond_names[1]]] - .data[[cond_names[2]]],
        abs_delta = abs(delta)
      ) %>%
      dplyr::arrange(dplyr::desc(abs_delta))

    # Filter by top N if requested
    if (top_n_mode == "topn") {
      pair_df <- pair_df %>% dplyr::slice_head(n = top_n)
    }

    # Add pathway info
    pair_df <- pair_df %>%
      dplyr::left_join(lr_pathway_map, by = "lr") %>%
      dplyr::mutate(
        pathway = ifelse(is.na(pathway) | pathway == "", "Unknown", pathway)
      )

    # Create labels
    if (show_pathway) {
      pair_df <- pair_df %>%
        dplyr::mutate(
          lr_pathway = paste0(lr, " [", pathway, "]"),
          lr_pathway = stringr::str_replace_all(lr_pathway, "\\s+", " "),
          lr_pathway = stringr::str_trunc(lr_pathway, width = label_width)
        )
    } else {
      pair_df <- pair_df %>%
        dplyr::mutate(
          lr_pathway = stringr::str_trunc(lr, width = label_width)
        )
    }

    pair_data[[i]] <- pair_df
  }

  # Get condition names from first pair
  cond_names <- setdiff(names(pair_data[[1]]),
                        c("lr", "delta", "abs_delta", "pathway", "lr_pathway"))

  # Combine all pair data for tables
  all_pair_data <- dplyr::bind_rows(
    lapply(1:n_pairs, function(i) {
      pair_data[[i]] %>%
        dplyr::mutate(
          sender = pairs$sender[i],
          receiver = pairs$receiver[i],
          pair = paste0(pairs$sender[i], " → ", pairs$receiver[i])
        )
    })
  )

  return(list(
    pair_data = pair_data,
    all_pair_data = all_pair_data,
    pairs = pairs,
    cond_names = cond_names
  ))
}

#' Generate Plots
#'
#' @description Create dumbbell plots from processed data
#'
#' @param pair_data List of data frames for each pair
#' @param pairs Data frame of sender-receiver pairs
#' @param cond_names Vector of condition names
#' @param same_x_scale Whether to use same x-axis scale
#' @param show_pathway Whether to show pathway in labels
#' @param color_palette Color palette choice
#' @param point_size Size of points
#' @param text_size Size of text
#'
#' @return List of ggplot objects
#'
#' @importFrom magrittr %>%
#' @noRd
fct_generate_plots <- function(pair_data, pairs, cond_names, same_x_scale,
                               show_pathway, color_palette, point_size, text_size) {

  n_pairs <- nrow(pairs)

  # Calculate shared x-axis limits if requested
  x_limits <- NULL
  if (same_x_scale) {
    all_data <- dplyr::bind_rows(pair_data)
    x_max <- max(c(all_data[[cond_names[1]]], all_data[[cond_names[2]]]), na.rm = TRUE)
    x_max <- x_max * 1.05
    x_limits <- c(0, x_max)
  }

  # Generate plots
  plots <- list()
  for (i in 1:n_pairs) {
    title <- paste0(pairs$sender[i], " → ", pairs$receiver[i])

    # Create dumbbell plot
    df_change <- pair_data[[i]] %>%
      dplyr::mutate(lr_pathway = factor(lr_pathway, levels = rev(lr_pathway)))

    long_df <- df_change %>%
      tidyr::pivot_longer(
        cols = dplyr::all_of(cond_names),
        names_to = "Condition",
        values_to = "prob_sum"
      )

    p <- ggplot2::ggplot(long_df, ggplot2::aes(y = lr_pathway)) +
      ggplot2::geom_segment(
        data = df_change,
        ggplot2::aes(x = .data[[cond_names[2]]], xend = .data[[cond_names[1]]],
                     y = lr_pathway, yend = lr_pathway),
        color = "grey60",
        linewidth = 0.8
      ) +
      ggplot2::geom_point(ggplot2::aes(x = prob_sum, color = Condition),
                          size = point_size) +
      ggplot2::theme_classic() +
      ggplot2::labs(
        title = title,
        subtitle = paste0(nrow(df_change), " LR pairs ordered by |delta|"),
        x = "Communication probability (sum(prob))",
        y = if(show_pathway) "Ligand–Receptor [Pathway]" else "Ligand–Receptor"
      ) +
      ggplot2::theme(
        legend.position = "bottom",
        axis.text.y = ggplot2::element_text(size = text_size),
        axis.text.x = ggplot2::element_text(size = text_size + 1),
        axis.title = ggplot2::element_text(size = text_size + 2),
        plot.title = ggplot2::element_text(size = text_size + 4, face = "bold"),
        plot.subtitle = ggplot2::element_text(size = text_size + 1)
      )

    # Apply color palette
    if (color_palette == "viridis") {
      p <- p + ggplot2::scale_color_viridis_d(end = 0.8)
    } else if (color_palette == "set2") {
      p <- p + ggplot2::scale_color_brewer(palette = "Set2")
    } else if (color_palette == "dark2") {
      p <- p + ggplot2::scale_color_brewer(palette = "Dark2")
    } else if (color_palette == "redblue") {
      p <- p + ggplot2::scale_color_manual(values = c("#d73027", "#4575b4"))
    }

    if (!is.null(x_limits)) {
      p <- p + ggplot2::scale_x_continuous(limits = x_limits)
    }

    plots[[i]] <- p
  }

  return(plots)
}

#' Combine Plots
#'
#' @description Combine multiple plots using patchwork
#'
#' @param plots List of ggplot objects
#'
#' @return Combined patchwork object
#'
#' @noRd
fct_combine_plots <- function(plots) {
  n_plots <- length(plots)

  if (n_plots == 1) {
    return(plots[[1]])
  } else if (n_plots == 2) {
    return(plots[[1]] / plots[[2]])
  } else if (n_plots == 3) {
    return(plots[[1]] / plots[[2]] / plots[[3]])
  } else if (n_plots == 4) {
    return((plots[[1]] | plots[[2]]) / (plots[[3]] | plots[[4]]))
  } else {
    return(patchwork::wrap_plots(plots, ncol = 2))
  }
}
