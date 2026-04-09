# 02_estimate_models.R
# Estimate the main, placebo, and subgroup treatment-effect models.
#
# This script uses `movers` created by 01_prepare_data.R.
# Run the scripts in order via run_all.R.
#
# We use lm_robust() instead of lm() because it computes
# heteroskedasticity-robust standard errors (se_type = "stata"
# matches the Stata defaults used in the original paper).

library(broom)
library(dplyr)
library(estimatr)

# Helper =======================================================================
# Extract just the nudge coefficient row from a fitted model.
pull_nudge <- function(fit, label) {
  out <- tidy(fit, conf.int = TRUE) %>%
    filter(term == "nudgedTreated")
  out$model <- label
  out
}

# Covariate lists ==============================================================
# Define once here so the placebo and subgroup loops can reuse them.

# Full covariate list for the main (2018 general) model.
main_rhs_terms <- c(
  "nudged", "info_poll", "dist", "gen2016", "move_times",
  "poll_dist_2018", "pav", "age", "gender", "race", "party",
  "hhinc", "foreign_born", "szDistrictName_1B", "hhincB"
)

# Placebo models omit gen2016 because it is sometimes the outcome.
placebo_rhs_terms <- main_rhs_terms[main_rhs_terms != "gen2016"]

# Main model ===================================================================
# Outcome: did the voter turn out in the 2018 general election? (gen2018)
#
# We restrict to voters registered and old enough for the 2018 election.
# Note: we create main_data as a separate object so that movers stays
# intact for use in the placebo models below.

main_data <- movers %>%
  filter(dtOrigRegDate <= as.Date("2018-11-06")) %>%
  filter(dtBirthDate <= as.Date("2000-11-06"))

main_model <- lm_robust(
  gen2018 ~ nudged + info_poll + dist + gen2016 + move_times +
    poll_dist_2018 + pav + age + gender + race + party + hhinc +
    foreign_born + szDistrictName_1B + hhincB,
  data = main_data,
  se_type = "stata"
)

main_results <- pull_nudge(main_model, "Main: 2018 general")

# Placebo models ===============================================================
# We re-run the model with pre-treatment outcomes (2016 elections).
# Because the nudge happened in 2018, it cannot affect 2016 voting.

placebo_specs <- list(
  "Placebo: 2016 general" = list(
    outcome = "gen2016",
    reg_by  = as.Date("2016-11-08"),
    born_by = as.Date("1998-11-08")
  ),
  "Placebo: 2016 primary" = list(
    outcome = "pri2016",
    reg_by  = as.Date("2016-06-07"),
    born_by = as.Date("1998-06-07")
  )
)

placebo_results <- list()

for (label in names(placebo_specs)) {
  spec <- placebo_specs[[label]]
  dat <- movers %>%
    filter(dtOrigRegDate <= spec$reg_by) %>%
    filter(dtBirthDate <= spec$born_by)

  fmla <- as.formula(paste(
    spec$outcome, "~", paste(placebo_rhs_terms, collapse = " + ")
  ))
  fit <- lm_robust(fmla, data = dat, se_type = "stata")

  placebo_results[[label]] <- pull_nudge(fit, label)
}

# Subgroup models ==============================================================
# For each subgroup we re-run all three models (main + two placebos)
# on the subset of voters by partisanship.

run_models <- function(main_dat, full_dat, main_terms, placebo_terms) {
  fmla <- as.formula(
    paste("gen2018 ~", paste(main_terms, collapse = " + "))
  )
  fit <- lm_robust(fmla, data = main_dat, se_type = "stata")
  results <- list(pull_nudge(fit, "Main: 2018 general"))

  for (label in names(placebo_specs)) {
    spec <- placebo_specs[[label]]
    dat <- full_dat %>%
      filter(dtOrigRegDate <= spec$reg_by) %>%
      filter(dtBirthDate <= spec$born_by)
    p_fmla <- as.formula(paste(
      spec$outcome, "~", paste(placebo_terms, collapse = " + ")
    ))
    fit_p <- lm_robust(p_fmla, data = dat, se_type = "stata")
    results[[label]] <- pull_nudge(fit_p, label)
  }

  bind_rows(results)
}

subgroup_specs <- list(
  "Democrats"   = list(col = "party", val = "Dem"),
  "Republicans" = list(col = "party", val = "Rep"),
  "No party"    = list(col = "party", val = "None/Third-Party")
)

subgroup_estimates <- list()

for (sg_name in names(subgroup_specs)) {
  spec <- subgroup_specs[[sg_name]]
  sub_main <- main_data[main_data[[spec$col]] == spec$val, ]
  sub_movers <- movers[movers[[spec$col]] == spec$val, ]
  sg_main_terms <- main_rhs_terms[main_rhs_terms != spec$col]
  sg_placebo_terms <- placebo_rhs_terms[placebo_rhs_terms != spec$col]

  subgroup_estimates[[sg_name]] <- run_models(
    sub_main, sub_movers, sg_main_terms, sg_placebo_terms
  )
}

# Summary tables ===============================================================
main_estimates <- bind_rows(
  main_results, bind_rows(placebo_results)
) %>%
  select(model, estimate, std.error, conf.low, conf.high, p.value)

all_subgroup_estimates <- bind_rows(
  subgroup_estimates,
  .id = "subgroup"
) %>%
  select(subgroup, model, estimate, std.error, conf.low, conf.high, p.value)

print(main_estimates)
print(all_subgroup_estimates)
