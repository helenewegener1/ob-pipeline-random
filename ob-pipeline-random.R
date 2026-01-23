#!/usr/bin/env/R

## Omnibenchmark-izes Marek Gagolewski's https://github.com/gagolews/clustering-results-v1/blob/eae7cc00e1f62f93bd1c3dc2ce112fda61e57b58/.devel/do_benchmark_fcps_aux.R

## Takes the true number of clusters into account and outputs a 2D matrix with as many columns as ks tested,
## being true number of clusters `k` and tested range `k plusminus 2`

library(argparse)
library(glue)
library(readr)
library(dplyr)
library(utils)

cat("Getting arguments...")
# GET ARGUMENTS 
parser <- ArgumentParser(description="FCPS caller")

parser$add_argument('--data.train_matrix',
                    type="character",
                    help='gz-compressed textfile containing the comma-separated data to be clustered.')
parser$add_argument('--data.train_labels',
                    type="character",
                    help='gz-compressed textfile with the true labels.')
parser$add_argument('--data.test_matrix',
                    type="character",
                    help='gz-compressed textfile containing the comma-separated data to be clustered.')
# parser$add_argument('--data.test_labels',
#                     type="character",
#                     help='gz-compressed textfile with the true labels.')
parser$add_argument("--output_dir", "-o", dest="output_dir", type="character",
                    help="output directory where files will be saved", default=getwd())
parser$add_argument("--name", "-n", dest="name", type="character", help="name of the dataset")
# parser$add_argument("--method", "-m", dest="method", type="character", help="method")

args <- parser$parse_args()

train_x_path <- args[['data.train_matrix']]
train_y_path <- args[['data.train_labels']]
test_x_path <- args[['data.test_matrix']]
name <- args[['name']]
output_dir <- args[['output_dir']]

# FOR TESTING
# Path to zipped data
# dataset_path <- "/Users/srz223/Documents/courses/Benchmarking/repos/ob-pipeline-cytof/out/data/data_import/dataset_name-FR-FCM-Z2KP_virus_final_seed-42/preprocessing/data_preprocessing/num-1_test-sample-limit-5"
# train_x_path <- glue("{dataset_path}/data_import.train.matrix.tar.gz")
# train_y_path <- glue("{dataset_path}/data_import.train.labels.tar.gz")
# # test_y_path <- glue("{dataset_path}/data_import.test.labels.tar.gz")
# test_x_path <- glue("{dataset_path}/data_import.test.matrices.tar.gz")

# LOAD TRAIN Y
train_y_files <- utils::untar(train_y_path, list = TRUE)
train_y_list <- setNames(vector("list", length(train_y_files)), train_y_files)

# extract to a temp dir
tmp <- tempdir()
utils::untar(train_y_path, exdir = tmp)

for (file in train_y_files) {
  df <- read_csv(file.path(tmp, file), col_names = FALSE)
  train_y_list[[file]] <- df
}

# Flatten all labels from all training sets 
flat_list <- unlist(train_y_list, recursive = TRUE, use.names = FALSE)
flat_list

# LOAD X TEST 
test_x_files <- utils::untar(test_x_path, list = TRUE)
test_x_list <- setNames(vector("list", length(test_x_files)), test_x_files)

# extract to a temp dir
tmp <- tempdir()
utils::untar(test_x_path, exdir = tmp)

for (file in test_x_files) {
  df <- read_csv(file.path(tmp, file), col_names = FALSE)
  test_x_list[[file]] <- df
}

# Sample from unique true labels
do_random <- function(truth, n_cells, seed = 101) {
  
  set.seed(seed)

  # Randomly assign a class to each cell
  res <- unique(truth)
  
  res_final <- sample(res, n_cells, replace = TRUE)

  return(res_final)

}

truth <- flat_list
tmp_dir <- tempdir()
# tmp_dir <- "~/Documents/courses/Benchmarking/repos/ob-pipeline-random/tmp_dir"
csv_files <- character(length(test_x_list))
names(csv_files) <- names(test_x_list)
  
# Run random classification on each test sample. 
for (test_x_name in names(test_x_list)) {
  
  # test_x_name <- "data_import-data-14.csv"
  test_x <- test_x_list[[test_x_name]]
  
  n_cells <- nrow(test_x) 
  pred_y <- do_random(truth = truth, n_cells = n_cells)
  
  if (length(pred_y) != n_cells){
    message("N cells in y pred and x test does are not identical.")
    message(glue("N cells in y pred and x test does are not identical."))
  }
  
  csv_file <- file.path(tmp_dir, test_x_name)
  
  # If the element is a data.frame or list, coerce to data.frame
  df <- as.data.frame(pred_y)
  
  write_delim(df, file = csv_file, col_names = FALSE, quote = "none", delim = ",")
  csv_files[test_x_name] <- csv_file
  
}

# Create tar.gz archive of all CSVs
# name <- "random"
# output_dir <- "~/Documents/courses/Benchmarking/repos/ob-pipeline-random/tmp_out"
tar(tarfile = glue("{output_dir}/{name}_predicted_labels.tar.gz"), files = csv_files, compression = "gzip", tar = "internal")


# TEST 1)
# truth <- read.table(gzfile("Documents/courses/Benchmarking/data/true_labs.txt.gz"), header = FALSE, quote = "\'", na.strings = '""')$V1
# res <- do_fcps(truth = truth, seed = 66)
# outfile <- file.path("Downloads", "Bla_predicted_labels.txt")
# write.table(file = outfile, res, col.names = FALSE, row.names = FALSE, quote = FALSE, na = '99')


# TEST 2)
# truth <- read.table(gzfile("Documents/courses/Benchmarking/data/true_labs.txt.gz"), header = FALSE, quote = "\'", na.strings = '""')$V1
# data <- read.table(gzfile("Documents/courses/Benchmarking/data/data_matrix.matrix.gz"), header = TRUE, sep = ",")
# n_cells <- length(truth)
# res <- do_fcps(truth = truth, n_cells = n_cells, seed = 66)
# length(res)
# na_label <- res %>% as.integer() %>% na.exclude() %>% max() + 1
# outfile <- file.path("Downloads", "NEW_predicted_labels.txt")
# write.table(file = outfile, res, col.names = FALSE, row.names = FALSE, quote = FALSE, na = as.character(na_label))

# data <- read.table(outfile, header = FALSE)
# dim(data)
