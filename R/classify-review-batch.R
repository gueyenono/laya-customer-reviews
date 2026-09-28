# Prereqs:
# ./batch_server.py file is in the working directory
# Run the following in bash: "uvicorn batch_server:app --host 0.0.0.0 --port 8001"

classify_reviews_batch <- function(
  address = "http://localhost:8001/v1/batch",
  reviews_vector
) {
  reviews_list <- lapply(X = reviews_vector, FUN = \(x) list(state = x))

  out <- httr2::request(address) |>
    httr2::req_headers("Content-Type" = "application/json") |>
    httr2::req_body_json(list(
      states = reviews_list,
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
