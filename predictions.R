########################################################################################
# This code contains the prediction function that will return a set of "k" word
# suggestions for a given user input.
#
# Dependency: probabilities.R
#
# Code developed by E. Baskaradas
########################################################################################

#setwd() -- set as required

# load files saved in probabilities.R
load("bigrams.RData")
load("trigrams.RData")
load("quadgrams.RData")
load("bigrams1skip.RData")
load("bigrams2skip.RData")

require(data.table)

allgrams <- rbindlist(list(quadgrams, trigrams, bigrams), fill = TRUE) # 62.5 MB

rm(bigrams, trigrams, quadgrams)
gc()

predict_text <- function(input, results = 5){
  text <- input
  ngram <- 4 # ngram order
  n <- ngram
  k <- results # number of predictions to output
  input <- gsub("^\\s+|\\s+$", "", text)
  
  # Convert text to lower case
  text <- tolower(text)
  
  # Strip leading and trailing whitespace
  text <- gsub("^\\s+|\\s+$", "", text)
  
  # Strip punctuation except apostrophe
  text <- gsub("[^[:alnum:][:space:]']", "", text)
  
  # Extract last n-1 terms from input string "... a b c" (if n = 4, take last 3 and find the 4th)
  term <- stringr::word(text, -((ngram-1):1))
  term <- term[!is.na(term)]
  
  n <- (length(term) + 1)
  
  # Construct the first terms of the n-gram "a_b_c"
  first_terms <- paste(term, collapse = "_")
  
  pred_table <- allgrams[first == first_terms]
  
  for(i in ngram:2){
    if(nrow(pred_table) == 0){
      n <- n-1
      first_terms <- gsub("^.*?_","",first_terms)
      if(n > 1 & n < ngram){
        pred_table <- allgrams[first == first_terms]
      }else{
        pred_table
      }
    }else{
      pred_table
    }
  }
  
  ### At this point, we have:
  ### 1. n value for the n-gram
  ### 2. first_terms for the n-gram from the input
  ### 3. pred_table of ngrams based on first_terms
  
  pred_table <- head(pred_table[][order(-Pkn)], k) # top "k" ordered by Pkn desc
  
  # What if the output is < k?
  
  remainder <- (k - nrow(pred_table))
  if (remainder > 0){
    if(n > 2){
      sup_table <- pred_table
      new_first_terms <- first_terms
      for(i in remainder:1){
        new_first_terms <- gsub("^.*?_","",new_first_terms)
        temp_table <- allgrams[first == new_first_terms]
        
        # Get the rows in the supplementary table excluding the last terms already found prior
        temp_table <- subset(temp_table, !(last %in% sup_table$last))
        temp_table <- head(temp_table[][order(-Pkn)], (k-nrow(sup_table)))
        sup_table <- rbindlist(list(sup_table, temp_table), fill = TRUE)
        remainder <- (k - nrow(sup_table))
        
        if(remainder == 0) break
      }
      sup_table <- subset(sup_table, !(last %in% pred_table$last))
      pred_table <- rbindlist(list(pred_table, sup_table), fill = TRUE)
      rm(temp_table, sup_table, new_first_terms, remainder)
      gc()
    }else{
      # For n = 1 do skip-grams
      num_terms <- length(term) # Find the number of initial input terms
      first_terms <- paste(term, collapse = "_") # Reconstruct those terms again
      
      if((num_terms - 1) != 0){ # To make sure that when we go one back up, there is a term to be found
        new_first_terms <- strsplit(first_terms, "_")[[1]][(num_terms - 1)] # Get that one-up term
        # Find in skip-1 bigram
        sup_table <- bigrams1skip[first == new_first_terms]
        sup_table <- head(sup_table[][order(-Pkn)], (k-nrow(sup_table)))
        # After finding, count rows, find remainder
        remainder <- (k - nrow(sup_table))
        if(remainder == 0){
          pred_table <- sup_table
          rm(sup_table, new_first_terms, remainder)
          gc()
        }else{
          if((num_terms - 2) != 0){
            new_first_terms <- strsplit(first_terms, "_")[[1]][(num_terms - 2)]
            temp_table <- bigrams2skip[first == new_first_terms]
            temp_table <- subset(temp_table, !(last %in% sup_table$last))
            temp_table <- head(temp_table[][order(-Pkn)], (k-nrow(sup_table)))
            sup_table <- rbindlist(list(sup_table, temp_table), fill = TRUE)
            remainder <- (k - nrow(sup_table))
            if(remainder == 0){
              pred_table <- sup_table
              rm(temp_table, sup_table, new_first_terms, remainder)
              gc()
            }else{
              temp_table <- head(unique(allgrams[!is.na(Pcont), .(frequency = sum(frequency), Pcont), by = last][order(-Pcont)]), remainder)
              sup_table <- rbindlist(list(sup_table, temp_table), fill = TRUE)
              pred_table <- sup_table
              rm(temp_table, sup_table, new_first_terms, remainder)
              gc()
            }
          }else{
            pred_table <- head(unique(allgrams[!is.na(Pcont), .(frequency = sum(frequency), Pcont), by = last][order(-Pcont)]), remainder)
            rm(sup_table, new_first_terms, remainder)
            gc()
          }
        }
        
      }else{
        pred_table <- head(unique(allgrams[!is.na(Pcont), .(frequency = sum(frequency), Pcont), by = last][order(-Pcont)]), k)
        rm(remainder)
        gc()
      }
    }
    
    
  }
  
  output <- pred_table
  
  if(ncol(output) == 5){
    output <- output[order(-Pkn)]
  }else if(ncol(output) == 3){
    output <- output[order(-Pcont)]
  }
  
  return(output)
  
}
