# Source R functions ----
r_files_paths <- list.files(
  path = here::here("./R"),
  pattern = "\\.R$",
  full.names = TRUE
)
purrr::walk(.x = r_files_paths, .f = source)

# Import data ----
reviews_df <- readr::read_csv(
  file = here::here("data/customers-feedback.csv")
) |>
  dplyr::mutate(
    mood2 = dplyr::case_when(
      mood == "love it" ~ "excellent",
      mood == "okay product" ~ "good",
      mood == "indifferent" ~ "indifferent",
      mood == "bad product" ~ "bad",
      mood == "horrible product" ~ "horrible"
    )
  )

# Sequential inference ----
reviews <- reviews_df$feedback[1:20]

tictoc::tic()
mood_seq <- purrr::map(.x = reviews, .f = \(review) {
  classify_review(
    address = "http://localhost:8000/v1/systemone",
    review = review
  )
})
tictoc::toc()


# Batch inference ----
tictoc::tic()
mood_batch <- classify_reviews_batch(
  address = "http://localhost:8001/v1/batch",
  reviews_vector = reviews
)
tictoc::toc()


# Inference quality ----
mood_results_seq <- unlist(purrr::map(.x = mood_seq, .f = \(el) {
  el$answers$review_class$choice
}))
mood_results_batch <- unlist(purrr::map_chr(.x = mood_batch[[1]], .f = \(el) {
  el$answers$review_class$choice
}))

data.frame(mood = reviews_df$mood2[1:20], mood_results_seq, mood_results_batch)
