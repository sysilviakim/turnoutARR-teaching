# 03_visualize_results.R
# Plot the main + placebo estimates, and one per-subgroup plot.
#
# This script uses objects created by 02_estimate_models.R.
# Run the scripts in order via run_all.R.

library(ggplot2)
library(here)
library(scales)

dir.create(here("fig"), showWarnings = FALSE)

# Shared plot function =========================================================
# Both the main plot and each subgroup plot have the same structure:
# three models on the x-axis, red for the main estimate, gray for
# placebos. We write the code once and call it for each group.

make_effect_plot <- function(df, title) {
  df$model <- factor(
    df$model,
    levels = c(
      "Main: 2018 general",
      "Placebo: 2016 general",
      "Placebo: 2016 primary"
    )
  )
  df$is_main <- df$model == "Main: 2018 general"

  ggplot(df, aes(x = model, y = estimate, color = is_main)) +
    geom_hline(yintercept = 0, linewidth = 0.5) +
    geom_pointrange(
      aes(ymin = conf.low, ymax = conf.high),
      linewidth = 0.7
    ) +
    scale_color_manual(
      values = c("TRUE" = "#B22222", "FALSE" = "#4D4D4D")
    ) +
    scale_y_continuous(labels = percent_format(accuracy = 1)) +
    labs(
      x = NULL,
      y = "Estimated treatment effect",
      title = title,
      subtitle = "Linear probability models with 95% confidence intervals"
    ) +
    theme_minimal(base_size = 11) +
    theme(
      legend.position = "none",
      panel.grid.minor = element_blank(),
      axis.text.x = element_text(size = 10)
    )
}

# Main plot ====================================================================
main_plot <- make_effect_plot(main_estimates, "Main and placebo estimates")
ggsave(
  here("fig", "main_effects.pdf"),
  plot = main_plot, width = 7, height = 4.5
)

# Subgroup plots ===============================================================
for (sg_name in names(subgroup_estimates)) {
  sg_plot <- make_effect_plot(
    subgroup_estimates[[sg_name]],
    paste("Subgroup:", sg_name)
  )
  sg_slug <- tolower(gsub(" ", "_", sg_name))
  ggsave(
    here("fig", paste0("subgroup_", sg_slug, ".pdf")),
    plot = sg_plot, width = 7, height = 4.5
  )
}
