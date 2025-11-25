#!/usr/bin/env/R

## Omnibenchmark-izes Marek Gagolewski's https://github.com/gagolews/clustering-results-v1/blob/eae7cc00e1f62f93bd1c3dc2ce112fda61e57b58/.devel/do_benchmark_fcps_aux.R

## Takes the true number of clusters into account and outputs a 2D matrix with as many columns as ks tested,
## being true number of clusters `k` and tested range `k plusminus 2`


library(argparse)
library(FCPS)
## library(R.utils)

parser <- ArgumentParser(description="FCPS caller")

parser$add_argument('--data.matrix',
                    type="character",
                    help='gz-compressed textfile containing the comma-separated data to be clustered.')
parser$add_argument('--data.true_labels',
                    type="character",
                    help='gz-compressed textfile with the true labels; used to select a range of ks.')
parser$add_argument('--seed',
                    type="integer",
                    help='Random seed',
                    default = 819797,
                    dest = 'seed')
parser$add_argument("--output_dir", "-o", dest="output_dir", type="character",
                    help="output directory where files will be saved", default=getwd())
parser$add_argument("--name", "-n", dest="name", type="character", help="name of the dataset")
# parser$add_argument("--method", "-m", dest="method", type="character", help="method")

args <- parser$parse_args()

load_labels <- function(data_file) {
  (fd <- read.table(gzfile(data_file), header = FALSE)$V1)
}

load_dataset <- function(data_file) {
  (fd <- read.table(gzfile(data_file), header = FALSE))
}

pin_seed <- function(fun, args, seed) {
  set.seed(seed)
  eval(as.call(c(fun, args)))
}

do_fcps <- function(data, seed) {
  
  # Number of cells
  n_cells <- nrow(data)
  
  # Define some fake cell types
  cell_types <- colnames(data)
  
  # Randomly assign a class to each cell
  res <- sample(cell_types, size = n_cells, replace = TRUE)

}

truth <- load_labels(args[['data.true_labels']])

res <- do_fcps(data = load_dataset(args[['data.matrix']]), seed = args$seed)

gz <- gzfile(file.path(args[['output_dir']], paste0(args[['name']], ".labels.gz")), "w")
write.table(file = gz, res, col.names = TRUE, row.names = FALSE, sep = ",")
close(gz)

