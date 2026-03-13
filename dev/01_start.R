# Building a Prod-Ready, Robust Shiny Application
#
# README: each step of the dev files is optional, and you don't have to
# fill every dev scripts before getting started.
# 01_start.R should be filled at start.
# 02_dev.R should be used to keep track of your development during the project.
# 03_deploy.R should be used once you need to deploy your application.
#
#
########################################
#### CURRENT FILE: ON START SCRIPT #####
########################################

## Fill the DESCRIPTION ----
## Add meta data about your application
##
## /!\ Note: if you want to change the name of your app during development,
## either re-run this function, call golem::set_golem_name(), or don't forget
## to change the name in the app_sys() function in app_config.R /!\
##
golem::fill_desc(
  pkg_name = "cellchatdumbbell", # The Name of the package containing the App
  pkg_title = "CellChat Crosstalk Analysis - Dumbbell Plots", # The Title of the package containing the App
  pkg_description = "A Shiny application for analyzing CellChat communication data using dumbbell plots to visualize ligand-receptor interactions between cell types across conditions.", # The Description of the package containing the App
  author_first_name = "Your", # Your First Name
  author_last_name = "Name", # Your Last Name
  author_email = "your.email@example.com", # Your Email
  repo_url = NULL # The URL of the GitHub Repo (optional)
)

## Set {golem} options ----
golem::set_golem_options()

## Create Common Files ----
## See ?usethis for more information
usethis::use_mit_license("Your Name")  # You can set another license here
usethis::use_readme_rmd(open = FALSE)
usethis::use_code_of_conduct(contact = "your.email@example.com")
usethis::use_lifecycle_badge("Experimental")
usethis::use_news_md(open = FALSE)

## Use git ----
usethis::use_git()

## Init Testing Infrastructure ----
## Create a template for tests
golem::use_recommended_tests()

## Use Recommended Packages ----
golem::use_recommended_deps()

## Add dependencies ----
usethis::use_package("dplyr")
usethis::use_package("tidyr")
usethis::use_package("ggplot2")
usethis::use_package("patchwork")
usethis::use_package("stringr")
usethis::use_package("shinycssloaders")
usethis::use_package("DT")
usethis::use_package("magrittr")

## Add modules ----
## Create a module infrastructure in R/
golem::add_module(name = "file_upload") # Name of the module
golem::add_module(name = "plot_controls") # Name of the module
golem::add_module(name = "plot_display") # Name of the module
golem::add_module(name = "data_table") # Name of the module
golem::add_module(name = "summary") # Name of the module
golem::add_module(name = "help") # Name of the module

## Add helper functions ----
## Creates fct_* and utils_* files
golem::add_fct("plot_generation") # Name of the file

## External resources
## Creates .js and .css files at inst/app/www
golem::add_js_file("script")
golem::add_js_handler("handlers")
golem::add_css_file("custom")

## Add internal datasets ----
## If you have data in your package
usethis::use_data_raw(name = "my_dataset", open = FALSE)

## Tests ----
## Add one line by test you want to create
usethis::use_test("app")

# Documentation

## Vignette ----
usethis::use_vignette("cellchatdumbbell")
devtools::build_vignettes()

## Code Coverage----
## Set the code coverage service ("codecov" or "coveralls")
usethis::use_coverage()

# Create a summary readme for the testthat subdirectory
covrpage::covrpage()

## CI ----
## Use this part of the script if you need to set up a CI
## service for your application
##
## (You'll need GitHub there)
usethis::use_github()

# GitHub Actions
usethis::use_github_action()
# Chose one of the three
# See https://usethis.r-lib.org/reference/use_github_action.html
usethis::use_github_action_check_release()
usethis::use_github_action_check_standard()
usethis::use_github_action_check_full()
# Add action for PR
usethis::use_github_action_pr_commands()

# Travis CI
usethis::use_travis()
usethis::use_travis_badge()

# AppVeyor
usethis::use_appveyor()
usethis::use_appveyor_badge()

# Circle CI
usethis::use_circleci()
usethis::use_circleci_badge()

# Jenkins
usethis::use_jenkins()

# GitLab CI
usethis::use_gitlab_ci()

# You're now set! ----
# go to dev/02_dev.R
rstudioapi::navigateToFile("dev/02_dev.R")
