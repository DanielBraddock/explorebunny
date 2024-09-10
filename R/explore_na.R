
#' @title  Explore missing values in a dataset
#'
#' @description Primarily a visual tool, but also can tabulate the same, which allows exploration of the amount of missingness in a dataset. The visual shows the amount of missing data in each column.
#'
#' @param df dataset, of the class data.frame
#' @param return Either "plot" or "table", depending what you want the function to return
#' @param probabilities Do you want the amount missing reported in absolute (nrow) or relative (percentage)terms
#' @param keep_all Whether to include the columns which are not missing anything ie n_missing = 0
#' @param colour_thresholds The visuals give a RAG rating for the missingness depending on these thresholds
#' @param zoom_in Should the amount missing axis max out at 100 percent or the greatest non-zero amount missing?
#' @param reference_lines Should reference lines be drawn on the visual to show the thresholds used for the colours
#'
#' @returns A ggplot object
#' @export
#'
#' @examples
#' iris2 <- iris
#' iris2[iris2$Species == "setosa", "Species"] <- NA_character_
#' iris2[iris2$Sepal.Length < 5.1, "Sepal.Length"] <- NA_real_
#' iris2[iris2$Sepal.Width > 2.8, "Sepal.Width"] <- NA_real_
#' iris2 |> explore_na()
#'
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
      , p_missing = .data$n_missing / n
    ) |>
    mutate(
      column = .data$column |> factor() |> fct_reorder(.data$n_missing)
      , rating = case_when(
        p_missing < colour_thresholds[1] ~ "green"
        , p_missing < colour_thresholds[2] ~ "orange"
        , TRUE ~ "red"
      )
    ) |>
    arrange(desc("n_missing"))

  # optional filter
  if (!keep_all) {
    result <- result |> filter(.data$n_missing > 0)
  }

  # optionally convert to a plot (default)
  if (return == "plot") {

    if (probabilities) {
      result <- result |> ggplot(aes(.data$column, .data$p_missing, fill = .data$rating))
    } else {
      result <- result |> ggplot(aes(.data$column, .data$n_missing, fill = .data$rating))
    }

    result <-
      result +
      scale_fill_manual(values = c("green" = "green", "orange" = "orange", "red" = "red")) +
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
