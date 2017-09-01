########################################################################################
# This file contains code for sourcing text, sampling, cleaning, and creating ngrams of 
# various levels.
#
# Dependency: helperFunctions.R
#
# Code developed by E. Baskaradas
########################################################################################


#setwd() -- set as required
require(readr)
require(quanteda)
require(data.table)
source("helperFunctions.R")
raw_data <- "rawdata.Rdata"
corp_grams <- "corpgrams.RData"

ptm <- proc.time()
if(!file.exists(raw_data)){
  getFiles()
  
  ### Create object for each path (blogs, news, twitter)
  blogsdir <- "./final/en_US/en_US.blogs.txt"
  newsdir <- "./final/en_US/en_US.news.txt"
  twitdir <- "./final/en_US/en_US.twitter.txt"
  
  paths <- c(blogsdir, newsdir, twitdir)
  for(i in 1:length(paths)){
    mytext <- read_lines(paths[i])
    
    ### Save each type of file to an object (blogs, news, twitter)
    if (i == 1){
      myblogs <- mytext
    }else if (i == 2){
      mynews <- mytext
    }else{
      mytwit <- mytext
    }
  }
  
  sample_percentage = 10
  
  sample_blog <- sample_file(myblogs, length(myblogs), sample_percentage)
  sample_news <- sample_file(mynews, length(mynews), sample_percentage)
  sample_twit <- sample_file(mytwit, length(mytwit), sample_percentage)
  
  sample_files <- c(sample_blog, sample_news, sample_twit)
  
  profane <- "profane.txt"
  myprofane <- read_lines(profane)
  sample_files <- tm::removeWords(sample_files, myprofane)
  sample_files <- tm::stripWhitespace(sample_files)
  
  inTrain <- data_part(sample_files, 70)
  training <- sample_files[inTrain]
  testing <- sample_files[-inTrain]
  
  inVal <- data_part(training, 10)
  validation <- training[inVal]
  training <- training[-inVal]
  
  
  train_corpus <- corpus(training)
  
  save(training, validation, testing, train_corpus, file = raw_data)
}else{
  load(raw_data)
}

proc.time() - ptm

ptm <- proc.time()
if(!file.exists(corp_grams)){
  
  train_tokens <- tokens(train_corpus,
                         remove_punct = TRUE,
                         remove_numbers = TRUE,
                         remove_twitter = TRUE,
                         remove_hyphens = TRUE,
                         remove_symbols = TRUE,
                         remove_separators = TRUE,
                         remove_url = TRUE)
  
  train_tokens <- removeFeatures(train_tokens, c("u", "lol", "rt"))
  
  for(i in 1:4){
    
    if(i == 1){
      unigrams <- tokens_ngrams(train_tokens, i)
      unigrams <- dfm(unigrams, verbose = FALSE)
      unigramsDT <- create_ngramDF(unigrams)
      unigramsDT <- split_terms(unigramsDT)
    }
    else if(i == 2){
      bigrams <- tokens_ngrams(train_tokens, i)
      bigrams <- dfm(bigrams, verbose = FALSE)
      bigramsDT <- create_ngramDF(bigrams)
      bigramsDT <- split_terms(bigramsDT)
    }
    else if(i == 3){
      trigrams <- tokens_ngrams(train_tokens, i)
      trigrams <- dfm(trigrams, verbose = FALSE)
      trigramsDT <- create_ngramDF(trigrams)
      trigramsDT <- split_terms(trigramsDT)
    }
    else{
      quadgrams <- tokens_ngrams(train_tokens, i)
      quadgrams <- dfm(quadgrams, verbose = FALSE)
      quadgramsDT <- create_ngramDF(quadgrams)
      quadgramsDT <- split_terms(quadgramsDT)
    }
  }
  
  #### Bigrams skip 1 ####################################
  train_tokens <- tokens(train_corpus,
                         skip = 1,
                         remove_punct = TRUE,
                         remove_numbers = TRUE,
                         remove_twitter = TRUE,
                         remove_hyphens = TRUE,
                         remove_symbols = TRUE,
                         remove_separators = TRUE,
                         remove_url = TRUE)
  
  train_tokens <- removeFeatures(train_tokens, c("u", "lol", "rt"))
  
  bigrams1skip <- tokens_ngrams(train_tokens, 2)
  bigrams1skip <- dfm(bigrams1skip, verbose = FALSE)
  bigrams1skipDT <- create_ngramDF(bigrams1skip)
  bigrams1skipDT <- split_terms(bigrams1skipDT)
  #######################################################
  
  #### Bigrams skip 2 ####################################
  train_tokens <- tokens(train_corpus,
                         skip = 2,
                         remove_punct = TRUE,
                         remove_numbers = TRUE,
                         remove_twitter = TRUE,
                         remove_hyphens = TRUE,
                         remove_symbols = TRUE,
                         remove_separators = TRUE,
                         remove_url = TRUE)
  
  train_tokens <- removeFeatures(train_tokens, c("u", "lol", "rt"))
  
  bigrams2skip <- tokens_ngrams(train_tokens, 2)
  bigrams2skip <- dfm(bigrams2skip, verbose = FALSE)
  bigrams2skipDT <- create_ngramDF(bigrams2skip)
  bigrams2skipDT <- split_terms(bigrams2skipDT)
  #######################################################
  
  save(unigramsDT, bigramsDT, trigramsDT, quadgramsDT, bigrams1skipDT, bigrams2skipDT, file = corp_grams)
  
  
}else{
  load(corp_grams)
}

proc.time() - ptm