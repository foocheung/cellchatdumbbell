# cellchatdumbbell



https://github.com/user-attachments/assets/2e6404ff-f09b-4e06-906f-2cfcb2c16b55





An interactive Shiny application for visualizing [CellChat](https://github.com/jinworks/CellChat) cell-cell communication results as dumbbell plots.

---

## Overview

`cellchatdumbbell` is an R package that wraps a Shiny app for exploring CellChat output interactively. It uses dumbbell plots — a dot plot with two endpoints connected by a line — to display changes in ligand-receptor interaction strengths or probabilities between two conditions (e.g., treated vs. control, two cell types, or two time points). This makes it easy to spot which interactions are gained, lost, or shifted across your comparisons.

## Features

- Upload and explore CellChat `.rds` objects directly in the browser
- Interactive dumbbell plots for pairwise comparison of cell-cell communication
- Filter by sender/receiver cell type, signaling pathway, and interaction
- Intuitive Shiny UI — no R scripting required after installation
- Built on the [`dumbbell`](https://cran.r-project.org/package=dumbbell) R package for ggplot2-based dumbbell visualizations

## Demo

A video walkthrough is included in the repository: [`CellChat Dumbbell Plot.mp4`](CellChat%20Dumbbell%20Plot.mp4)

---

## Installation

Install directly from GitHub using `devtools` or `remotes`:

```r
# install.packages("devtools")
devtools::install_github("foocheung/cellchatdumbbell")
```

### Dependencies

The following R packages are required and will be installed automatically:

- [`shiny`](https://cran.r-project.org/package=shiny)
- [`CellChat`](https://github.com/jinworks/CellChat)
- [`dumbbell`](https://cran.r-project.org/package=dumbbell)
- [`ggplot2`](https://cran.r-project.org/package=ggplot2)
- [`dplyr`](https://cran.r-project.org/package=dplyr)

If CellChat is not yet installed, install it first:

```r
devtools::install_github("jinworks/CellChat")
```

---

## Usage

Launch the Shiny app from your R console:

```r
library(cellchatdumbbell)
run_app()
```

Or run directly from GitHub without installing:

```r
shiny::runGitHub("cellchatdumbbell", "foocheung")
```

### Workflow

1. **Run CellChat** on your single-cell dataset(s) to generate a `CellChat` object (see the [CellChat tutorial](https://github.com/jinworks/CellChat)).
2. **Save your object(s)** as `.rds` files:
   ```r
   saveRDS(cellchat, file = "my_cellchat.rds")
   ```
3. **Launch the app** and upload your `.rds` file(s) via the file upload panel.
4. **Explore** interactions using the dropdown filters and interactive dumbbell plot.

---

## Input Format

The app expects a valid `CellChat` object (or a list of two objects for comparison) saved as an `.rds` file. Objects should have communication probabilities already computed (i.e., `computeCommunProb()` has been run).

---

## Background

[CellChat](https://github.com/jinworks/CellChat) is an R toolkit for inference, visualization, and analysis of cell-cell communication from single-cell and spatially resolved transcriptomics data. It quantifies signaling communication probabilities between cell populations using a mass-action model incorporating ligand-receptor interactions, co-factors, and multi-subunit complexes.

Dumbbell plots are an effective way to compare two-condition data — the two endpoints represent communication strength under each condition, and the connecting line makes the direction and magnitude of change immediately apparent.

---

## Citation

If you use `cellchatdumbbell` in your work, please also cite the underlying CellChat paper:

> Jin et al. *Inference and analysis of cell–cell communication using CellChat.* Nature Communications, 2021. https://doi.org/10.1038/s41467-021-21246-9

---

## Author

**Foo Cheung**
GitHub: [@foocheung](https://github.com/foocheung)

---

## License

MIT
