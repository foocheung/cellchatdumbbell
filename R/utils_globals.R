#' @importFrom rlang .data
#' @keywords internal
NULL

# Suppress R CMD check notes about global variables
utils::globalVariables(c(
  ".",
  "prob",
  "group",
  "lr",
  "prob_sum",
  "delta",
  "abs_delta",
  "pathway",
  "lr_pathway",
  "sender",
  "receiver",
  "pair",
  "Condition",
  "interaction_name",
  "pathway_name",
  "Var1",
  "Var2",
  "Var3",
  "Freq",
  "n_lr",
  "mean_abs_delta",
  "n_lr_pairs",
  "max_abs_delta",
  "top_lr",
  "top_pathway"
))
