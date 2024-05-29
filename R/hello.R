
#' hello
#'
#' @param name Who am I talking to? Defaults to "world"
#'
#' @return A greeting to "name"
#' @export
#'
#' @examples
#' hello()
hello <- function(name = "world") {
  msg <- paste0("Hello, ", name, "!")
  return(msg)
}
