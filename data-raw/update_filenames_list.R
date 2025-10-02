# updates the list rda from the .txt file

# get file names text file from raw folder
fn <- read.csv("data-raw/file_names.txt", header = FALSE)

# convert to list
file_names <- as.list(fn$V1)

# over write rda file
save(file_names, file = "data/file_names.rda")

