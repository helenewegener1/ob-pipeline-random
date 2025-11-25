
# Matrix with markers as columns and cells as rows. 
library(HDCytoData)

set.seed(123)  # for reproducibility

########## SIMULATE DATA ########## 
# Parameters
n_cells <- 5000  # number of events
n_markers <- 6   # number of markers/channels

# Simulate marker expression
# Some markers normal, some skewed to mimic real cytometry
marker1 <- rnorm(n_cells, mean = 200, sd = 50)
marker2 <- rnorm(n_cells, mean = 500, sd = 100)
marker3 <- rgamma(n_cells, shape = 2, scale = 100)
marker4 <- rnorm(n_cells, mean = 1000, sd = 200)
marker5 <- rbeta(n_cells, 2, 5) * 1000
marker6 <- rnorm(n_cells, mean = 300, sd = 75)

# Combine into a matrix (rows = cells, columns = markers)
data.matrix <- cbind(marker1, marker2, marker3, marker4, marker5, marker6)
colnames(data.matrix) <- paste0("Marker", 1:n_markers)

# input: data.matrix

data.matrix


#################################
########## SIMULATE DATA ########## 

set.seed(60)

# label, vector 
data.true_labels <- sample(cell_types, size = n_cells, replace = TRUE)

#################################

set.seed(88)
# Number of cells
n_cells <- nrow(data.matrix)

# Define some fake cell types
cell_types <- colnames(data.matrix)

# Randomly assign a class to each cell
random_labels <- sample(cell_types, size = n_cells, replace = TRUE)

##### Export the  




