# run_all.R
# ---------
# Run the full teaching workflow in order.
#
# Install packages once if you haven't already:
#   install.packages(
#     c("broom", "dplyr", "estimatr", "fst", "ggplot2", "here", "scales"),
#     repos = "https://cloud.r-project.org"
#   )

library(here)

source(here("R", "01_prepare_data.R"))
source(here("R", "02_estimate_models.R"))
source(here("R", "03_visualize_results.R"))
