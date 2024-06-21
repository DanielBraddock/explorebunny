test_that("no error", {
  iris2 <- iris
  iris2[iris2$Species == "setosa", "Species"] <- NA_character_
  iris2[iris2$Sepal.Length < 5.1, "Sepal.Length"] <- NA_real_
  iris2[iris2$Sepal.Width > 2.8, "Sepal.Width"] <- NA_real_
  expect_no_error(iris2 |> explore_na())
})
