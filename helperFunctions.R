########################################################################################
# This file contains a collection of helper functions called repeatedly in sourcing text,
# sampling, cleaning, and creating ngrams of various levels.
#
# Dependency: N/A
#
# Code developed by E. Baskaradas
########################################################################################

#setwd() -- set as required

# Function to get files

fileURL <- "https://d396qusza40orc.cloudfront.net/dsscapstone/dataset/Coursera-SwiftKey.zip"
filename <- "Coursera-SwiftKey.zip"
dirname <- "final"

getFiles <- function(){
  if(!file.exists(filename))
  {
    temp <- tempfile()
    download.file(fileURL, temp, mode = "wb")
    unzip(temp)
    unlink(temp)
  }else
  {
    if(!dir.exists(dirname))
    {
      "directory does not exist"
      unzip(filename)
    }
  }
}

# Samples the data, remove graphical characters, and convert to lowercase
sample_file <- function(rawfile, lines, sampleperc){
  set.seed(100)
  sample_output <- tolower(gsub("[^[:graph:]]", " ", rawfile[sample(1:lines, lines*sampleperc*0.01, replace = FALSE)]))
  sample_output <- gsub(" s ", "'s ", sample_output)
  sample_output <- gsub(" t ", "'t ", sample_output)
  return(sample_output)
}

# Data partitioning
data_part <- function(sampledata, partperc){
  set.seed(123)
  index <- sample.int(n = length(sampledata), size = floor(partperc*0.01*length(sampledata)), replace = FALSE)
  return(index)
}

# Creates document frame matrix from tokens
create_dfm <- function(myTokens){
  ngram <- dfm(myTokens, 
               remove = c("u", "lol", "rt"),
               verbose = FALSE)

  return(ngram)
}

# Converts ngram to data frame
create_ngramDF <- function(myngram){
  nDf <- sort(colSums(myngram), decreasing = TRUE)
  nDf <- as.data.frame(nDf)
  nDf <- cbind(term = rownames(nDf), nDf, row.names = NULL)
  colnames(nDf)[2] <- "frequency"
  return(nDf)
}


# Make extended table
split_terms <- function(myngramDF){
  ############################
  # Incoming format is
  # term    frequency
  # ----    ---------
  # of_the  26976
  # ...     ...
  
  # To split terms as follows:
  # first   last    frequency
  # -----   ----    ---------
  # of      the     26976
  # ...     ...     ...
  ############################
  testgram <- myngramDF
  
  # Determine number of words in the term
  n <- length(strsplit(gsub(' {2,}','_',testgram[1,1]), '_')[[1]])
  
  if(n != 1){
    # Create 2 new columns "first" and "last" and initialize as NA
    testgram <- as.data.frame(append(testgram, list(first = NA, last = NA), after = 1))
    # Make a list of all terms
    mylist <- list(name = unlist(strsplit(as.character(testgram[,1]), '\\s+')))
    
    # Split first terms into "first" column
    testgram[2] <- sub(unlist(mylist), pattern = "_[[:alpha:]\']*$", replacement = "")
    # Split last term into "last" column
    testgram[3] <- sub("^.*_([[:alnum:]\']+)$", "\\1", unlist(mylist))
    
    # Remove first column "term"
    testgram <- testgram[-1]
    testgram$n <- n
    
    # Order by "first" and "last" ascending and "frequency" descending
    testgram <- testgram[order(testgram$first, testgram$last, -testgram$frequency),]
    
    # Remove rows with $first containing only underscores
    testgram <- testgram[grepl("[^_]", testgram$first) == TRUE, ] 
    # Remove rows with leading underscores in $first
    testgram <- testgram[!grepl("^[_].*$", testgram$first) == TRUE, ]
    # Remove rows with non-ASCII characters
    testgram <- testgram[!grepl( "[^\x20-\x7F]",testgram$first) == TRUE,]
    testgram <- testgram[!grepl( "[^\x20-\x7F]",testgram$last) == TRUE,]
    # Remove rows with numbers
    testgram <- testgram[!grepl("^[[:digit:]]",testgram$first) == TRUE,]
    testgram <- testgram[!grepl("^[[:digit:]]",testgram$last) == TRUE,]
    
    
  }else{
    # Rename "term" column as "last"
    colnames(testgram)[1] <- "last"
    testgram$n <- n
    
    # Remove rows with $last containing only underscores
    testgram <- testgram[grepl("[^_]", testgram$last) == TRUE, ] 
    # Remove rows with leading underscores in $last
    testgram <- testgram[!grepl("^[_].*$", testgram$last) == TRUE, ]
    # Remove rows with non-ASCII characters
    testgram <- testgram[!grepl( "[^\x20-\x7F]",testgram$last) == TRUE,]
    # Remove rows with numbers
    testgram <- testgram[!grepl("^[[:digit:]]",testgram$last) == TRUE,]
    
    testgram <- testgram[order(testgram$last),]
    testgram$last <- as.character(testgram$last)
  }
  
  # Convert to data table
  testgram <- as.data.table(testgram)
  return(testgram)
}