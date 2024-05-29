test_that("returns hello world", {
  expect_equal(hello(), "Hello, world!")
})

test_that("returns hello you", {
  expect_equal(hello("you"), "Hello, you!")
})

