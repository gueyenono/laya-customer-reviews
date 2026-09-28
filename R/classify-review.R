# Make sure to run in bash: "laya-serve"

classify_review <- function(
  address = "http://localhost:8000/v1/systemone",
  review
) {
  out <- httr2::request(address) |>
    httr2::req_headers("Content-Type" = "application/json") |>
    httr2::req_body_json(list(
      state = list(body = review),
      questions = list(
        review_class = list(
          type = "choice",
          instructions = "What is the sentiment of the review?",
          criteria = list(
            excellent = "The customer really likes the product",
            good = "The customer thinks the product is good enough",
            indifferent = "The customer is indifferent.",
            bad = "The customer thinks the product is bad",
            horrible = "The customer really dislikes the proudct"
          )
        )
      )
    )) |>
    httr2::req_perform()

  httr2::resp_body_json(out)
}
