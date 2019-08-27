#!/usr/bin/env Rscript

get_sha <- function(file) {
  sha <- system2("git", c("log", "-n", "1", "--pretty=format:%H", "--", file), stdout = TRUE)
  if (length(sha) < 1L) return("")
  sha
}

needs_build <- function(output_dir, config_file) {
  source_files <- bookdown:::source_files(all = TRUE)
  aux_files <- c(config_file, list.files(pattern = "^_output\\.yml$"))
  tracked_files <- c(source_files, aux_files)
  
  current_sha <- vapply(tracked_files, get_sha, character(1), USE.NAMES = FALSE)
  df <- as.data.frame(list(file = tracked_files, sha = current_sha), stringsAsFactors = FALSE)
  
  yes_build <- TRUE
  attr(yes_build, "sha") <- df

  if (!dir.exists(output_dir)) {
    message(output_dir, " does not exist. Bookdown needs to be built.")
    return(yes_build)
  }
  
  stored_sha <- file.path(output_dir, "sha.csv")
  if (file.exists(stored_sha)) {
    prev_sha <- read.csv(stored_sha, stringsAsFactors = FALSE)
  } else {
    message("Cannot find ", stored_sha, " file. Bookdown needs to be built.")
    return(yes_build)
  }
  
  if (!identical(colnames(prev_sha), c("file", "sha"))) {
    message(stored_sha, ": wrong file format.")
    return(yes_build)
  }
  
  merged <- merge(prev_sha, df, by.x = "file", by.y = "file", all = TRUE)
  if (isTRUE(all(merged$sha.x == merged$sha.y))) {
    return(FALSE)
  } else {
    message("Source files have changed.")
    return(yes_build)
  }
}

render_book_maybe <- function(
  input, output_format = NULL, ..., output_dir = NULL, 
  config_file = "_bookdown.yml", envir = parent.frame()
) {
  bookdown:::opts$set(config = rmarkdown:::yaml_load_file(config_file))
  output_dir <- bookdown:::output_dirname(output_dir, create = FALSE)
  csv_path <- file.path(output_dir, "sha.csv")
  to_build <- needs_build(output_dir, config_file)
  
   if (to_build) {
     bookdown::render_book(input = input, 
                           output_format = output_format, 
                           output_dir = output_dir, 
                           config_file = "_bookdown.yml", 
                           envir = envir, 
                           ...)
     write.csv(attr(to_build, "sha"), csv_path, row.names = FALSE)
   }
   else {
    message("No source file have changed.")
  }
}

render_book_maybe(".")
