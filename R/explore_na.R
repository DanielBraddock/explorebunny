
explore_na <- function(df
                       , return = "plot"
                       , probabilities = TRUE
                       , keep_all = FALSE
                       , colour_thresholds = c(.1, .3)
                       , zoom_in = FALSE
                       , reference_lines = TRUE) {

  stopifnot(return %in% c("plot", "table"))

  n <- nrow(df)

  # log
  message(paste("Rows:", n))

  # table
  result <-
    tibble(
      column = colnames(df)
      , n_missing = df |> sapply(function(x) sum(is.na(x)))
      , p_missing = n_missing / n
    ) |>
    mutate(
      column = column |> factor() |> fct_reorder(n_missing)
      , rating = case_when(
        p_missing < colour_thresholds[1] ~ "green"
        , p_missing < colour_thresholds[2] ~ "orange"
        , TRUE ~ "red"
      )
    ) |>
    arrange(desc(n_missing))

  # optional filter
  if (!keep_all) {
    result <- result |> filter(n_missing > 0)
  }

  # optionally convert to a plot (default)
  if (return == "plot") {

    if (probabilities) {
      result <- result |> ggplot(aes(column, p_missing, fill = rating))
    } else {
      result <- result |> ggplot(aes(column, n_missing, fill = rating))
    }

    result <-
      result +
      scale_fill_manual(values = c("green", "orange", "red")) +
      theme(legend.position = "none") +
      geom_col() +
      coord_flip()

    if (!zoom_in) {
      ylim_upper_bound <- if (probabilities) 1 else n
      result <- result + ylim(0, ylim_upper_bound)
    }

    if (reference_lines) {
      reference_values <- if (probabilities) colour_thresholds else colour_thresholds * n
      result <-
        result +
        geom_hline(yintercept = reference_values[1], linetype = 2) +
        geom_hline(yintercept = reference_values[2], linetype = 2)
    }

  }
  return(result)
}
