# 01_prepare_data.R
# Build the analysis sample from the mover data.
#
# The paper studies whether California's automatic voter re-registration
# program (ARR) increased turnout among people who moved in 2018.
# When someone files a change-of-address form with the DMV, the state
# automatically updates their voter registration. The "nudge" treatment
# is receiving that automatic re-registration.
#
# Run this script via run_all.R or on its own

library(dplyr)
library(fst)
library(here)

# Load all movers in the anonymized dataset ====================================
# movers_raw keeps the original import intact so you can compare it with
# the cleaned movers object after the steps below.
movers_raw <- movers <- read_fst(here("data", "movers_anonymized.fst"))

# Focus on people who moved in June 2018.
# June movers had roughly five months before the November 2018 general
# election — enough time for re-registration to take effect.
movers <- movers %>%
  filter(coa_movdat_2 == as.Date("2018-06-01"))

# Drop the small number of rows where the key variables are missing. ===========
# info_poll: whether the mover received information about their polling place.
# nudged:    whether the mover received automatic re-registration
#            (the treatment).
movers <- movers %>%
  filter(!is.na(info_poll)) %>%
  filter(!is.na(nudged))

# R treats a 0/1 column as a number by default.
# Converting nudged to a factor tells R it is a group label
# (Control vs. Treated), so the regression prints a named coefficient
# rather than a slope.
movers$nudged <- factor(movers$nudged)
