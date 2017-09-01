########################################################################################
# This code calculates the Kneyser-Ney smoothing probabilities of ngrams created in
# ngramTable.R
#
# Dependency: ngramTable.R
#
# Code developed by E. Baskaradas
########################################################################################

ptm <- proc.time()
#setwd() -- set as required

require(data.table)

load("corpgrams.RData")

# Set minimum frequency
f <- 2
unigrams <- unigramsDT[, !("n"), with = FALSE]
rm(unigramsDT)
gc()

setnames(unigrams, "last", "first")

############################################
# D(frequency)  = 0     if frequency = 0
#               = D_1   if frequency = 1
#               = D_2   if frequency = 2
#               = D_3+  if frequency > 2
#
# where D_i= i - (i+1) * Y * (n_(i+1))/(n_i)
#
# and   Y = count(lowest frequency) /
#           (count(lowest frequency) + 
#           2 * count(lowest frequency + 1))
############################################


###### BIGRAM PROBABILITIES ################

bigrams <- bigramsDT[frequency >= f, !("n"), with = FALSE]
bigrams[, D := 0]

# Calculate Y
Y <- nrow(bigrams[frequency == f])/(nrow(bigrams[frequency == f]) + 2*nrow(bigrams[frequency == f+1]))

# Discount for all frequency = 2
bigrams[frequency == f]$D <- f - (f + 1) * Y * (nrow(bigrams[frequency == (f + 1)])/nrow(bigrams[frequency == f]))

# Discount for all frequency > 2
bigrams[frequency > f]$D <- (f + 1) - (f + 2) * Y * (nrow(bigrams[frequency == (f + 2)])/nrow(bigrams[frequency == (f + 1)]))

# Get new frequency (original frequency - D)
bigrams[, numerator := frequency - D]

# Get frequency of first terms
bigrams <- merge(bigrams, unigrams, by = "first")
setnames(bigrams, c("first", "last", "frequency", "D", "numerator", "denominator"))

# Get count of frequency of first terms
bigrams[, firstcount := .(.N), by = first]

# Calculate normalizing constant, lambda (D/denominator)*firstcount
bigrams[, lambda := (D/denominator)*firstcount]

# Calculate continuation probability
bigrams[, lastcount := .(.N), by = last]
bigrams[, Pcont := lastcount/nrow(bigrams)]

# Calculate bigram P_kn
bigrams[, Pkn := (numerator/denominator) + lambda*Pcont] # 40MB
bigrams <- bigrams[, c("first", "last", "frequency", "Pcont", "Pkn")] # 21.4MB first, last, frequency, Pcont, Pkn)

save(bigrams, file = "bigrams.RData")
rm(bigrams)
gc()

###### END BIGRAM PROBABILITIES ############

###### TRIGRAM PROBABILITIES ###############

trigrams <- trigramsDT[frequency >= f, !("n"), with = FALSE]
trigrams[, D := 0]

# Calculate Y
Y <- nrow(trigrams[frequency == f])/(nrow(trigrams[frequency == f]) + 2*nrow(trigrams[frequency == f+1]))

# Discount for all frequency = 2
trigrams[frequency == f]$D <- f - (f + 1) * Y * (nrow(trigrams[frequency == (f + 1)])/nrow(trigrams[frequency == f]))

# Discount for all frequency > 2
trigrams[frequency > f]$D <- (f + 1) - (f + 2) * Y * (nrow(trigrams[frequency == (f + 2)])/nrow(trigrams[frequency == (f + 1)]))

# Get new frequency (original_frequency - D)
trigrams[, numerator := frequency - D]

# First get 2-grams and concatenate first and last terms
bigramsRoot <- bigramsDT
rm(bigramsDT)
gc()

bigramsRoot <- bigramsRoot[, concat := .(paste(first, last, sep = "_")), by = last]
bigramsRoot <- bigramsRoot[, !(c("first", "last", "n")), with = FALSE]
setnames(bigramsRoot, c("frequency", "first"))

# Get frequency of first terms for denominator
trigrams <- merge(trigrams, bigramsRoot, by = "first")
rm(bigramsRoot)
gc()

setnames(trigrams, c("first", "last", "frequency", "D", "numerator", "denominator"))

# Get count of frequency of first terms
trigrams[, firstcount := .(.N), by = first]

# Calculate normalizing constant, lambda (D/denominator)*firstcount
trigrams[, lambda := (D/denominator)*firstcount]

### Get Pkn and Pcont from bigrams ######

load("bigrams.RData")

# Create temp subset bigram and merging first_last terms
bigramsTemp <- bigrams[,.(first, last, Pkn)] # check what was removed from bigrams before it was saved
rm(bigrams)
gc()

bigramsTemp <- bigramsTemp[, merged := paste(first, last, sep = "_")]
setkey(bigramsTemp, merged)

# Create new column in trigrams to merge secondlast_last words
trigrams <- trigrams[, merged := paste(tail(strsplit(first, split="_")[[1]],1), last, sep = "_"), by = first]
setkey(trigrams, merged)

# Merge trigrams and bigramsTemp on "merged"
trigrams <- merge(trigrams, bigramsTemp, by = "merged")
rm(bigramsTemp)
gc()

setnames(trigrams, c("merged", "first", "last", "frequency", "D", "numerator", "denominator", "firstcount", "lambda", "firstbi", "lastbi", "Pknbi"))
trigrams <- trigrams[, !c("merged", "firstbi", "lastbi")]

### End Get Pkn and Pcont from bigrams ###

# Calculate trigram P_kn
trigrams[, Pkn := (numerator/denominator) + lambda*Pknbi] # 43MB
trigrams <- trigrams[, c("first", "last", "frequency", "Pkn")] # 23.3MB first, last, frequency, Pkn

save(trigrams, file = "trigrams.RData")
rm(trigrams)
gc()

###### END TRIGRAM PROBABILITIES ###########


###### QUADGRAM PROBABILITIES ##############

quadgrams <- quadgramsDT[frequency >= f, !("n"), with = FALSE]
rm(quadgramsDT)
gc()

quadgrams[, D := 0]

# Calculate Y
Y <- nrow(quadgrams[frequency == f])/(nrow(quadgrams[frequency == f]) + 2*nrow(quadgrams[frequency == f+1]))

# Discount for all frequency = 2
quadgrams[frequency == f]$D <- f - (f + 1) * Y * (nrow(quadgrams[frequency == (f + 1)])/nrow(quadgrams[frequency == f]))

# Discount for all frequency > 2
quadgrams[frequency > f]$D <- (f + 1) - (f + 2) * Y * (nrow(quadgrams[frequency == (f + 2)])/nrow(quadgrams[frequency == (f + 1)]))

# Get new frequency (original_frequency - D)
quadgrams[, numerator := frequency - D]

# First get 3-grams and concatenate first and last terms
trigramsRoot <- trigramsDT
rm(trigramsDT)
gc()

trigramsRoot <- trigramsRoot[, concat := .(paste(first, last, sep = "_")), by = last]
trigramsRoot <- trigramsRoot[, !(c("first", "last", "n")), with = FALSE]
setnames(trigramsRoot, c("frequency", "first"))

# Get frequency of first terms for denominator
quadgrams <- merge(quadgrams, trigramsRoot, by = "first")
rm(trigramsRoot)
gc()

setnames(quadgrams, c("first", "last", "frequency", "D", "numerator", "denominator"))

# Get count of frequency of first terms
quadgrams[, firstcount := .(.N), by = first]

# Calculate normalizing constant, lambda (D/denominator)*firstcount
quadgrams[, lambda := (D/denominator)*firstcount]

### Get Pkn from trigrams ######

load("trigrams.RData")

# Create temp subset bigram and merging first_last terms
trigramsTemp <- trigrams[,.(first, last, Pkn)]
rm(trigrams)
gc()

trigramsTemp <- trigramsTemp[, merged := paste(first, last, sep = "_")]
setkey(trigramsTemp, merged)

# Create new column in trigrams to merge thirdlast_secondlast_last words
quadgrams <- quadgrams[, merged := paste(paste(tail(strsplit(first, split="_")[[1]],2)[1],
                                               tail(strsplit(first, split="_")[[1]],2)[2],
                                               sep = "_"), 
                                         last, sep = "_"), by = first]
setkey(quadgrams, merged)

# Merge quadgrams and trigramsTemp on "merged"
quadgrams <- merge(quadgrams, trigramsTemp, by = "merged")
rm(trigramsTemp)
gc()

setnames(quadgrams, c("merged", "first", "last", "frequency", "D", "numerator", "denominator", "firstcount", "lambda", "firsttri", "lasttri", "Pkntri"))
quadgrams <- quadgrams[, !c("merged", "firsttri", "lasttri")]

### End Get Pkn from trigrams ###

# Calculate quadgram P_kn
quadgrams[, Pkn := (numerator/denominator) + lambda*Pkntri] # 22MB
quadgrams <- quadgrams[, c("first", "last", "frequency", "Pkn")] # 14MB first, last, Pkn

save(quadgrams, file = "quadgrams.RData")
rm(quadgrams)
gc()

###### END QUADGRAM PROBABILITIES ##########

###### BIGRAM SKIP 1 PROBABILITIES #########

bigrams1skip <- bigrams1skipDT[frequency >= f, !("n"), with = FALSE]
rm(bigrams1skipDT)
gc()

bigrams1skip[, D := 0]

# Calculate Y
Y <- nrow(bigrams1skip[frequency == f])/(nrow(bigrams1skip[frequency == f]) + 2*nrow(bigrams1skip[frequency == f+1]))

# Discount for all frequency = 2
bigrams1skip[frequency == f]$D <- f - (f + 1) * Y * (nrow(bigrams1skip[frequency == (f + 1)])/nrow(bigrams1skip[frequency == f]))

# Discount for all frequency > 2
bigrams1skip[frequency > f]$D <- (f + 1) - (f + 2) * Y * (nrow(bigrams1skip[frequency == (f + 2)])/nrow(bigrams1skip[frequency == (f + 1)]))

# Get new frequency (original frequency - D)
bigrams1skip[, numerator := frequency - D]

# Get frequency of first terms
bigrams1skip <- merge(bigrams1skip, unigrams, by = "first")
setnames(bigrams1skip, c("first", "last", "frequency", "D", "numerator", "denominator"))

# Get count of frequency of first terms
bigrams1skip[, firstcount := .(.N), by = first]

# Calculate normalizing constant, lambda (D/denominator)*firstcount
bigrams1skip[, lambda := (D/denominator)*firstcount]

# Calculate continuation probability
bigrams1skip[, lastcount := .(.N), by = last]
bigrams1skip[, Pcont := lastcount/nrow(bigrams1skip)]

# Calculate bigram P_kn
bigrams1skip[, Pkn := (numerator/denominator) + lambda*Pcont] # 40MB
bigrams1skip <- bigrams1skip[, c("first", "last", "frequency", "Pcont", "Pkn")] # 21.4MB first, last, frequency, Pcont, Pkn)

save(bigrams1skip, file = "bigrams1skip.RData")
rm(bigrams1skip)
gc()

###### END BIGRAM SKIP 1 PROBABILITIES #####

###### BIGRAM SKIP 2 PROBABILITIES #########

bigrams2skip <- bigrams2skipDT[frequency >= f, !("n"), with = FALSE]
rm(bigrams2skipDT)
gc()

bigrams2skip[, D := 0]

# Calculate Y
Y <- nrow(bigrams2skip[frequency == f])/(nrow(bigrams2skip[frequency == f]) + 2*nrow(bigrams2skip[frequency == f+1]))

# Discount for all frequency = 2
bigrams2skip[frequency == f]$D <- f - (f + 1) * Y * (nrow(bigrams2skip[frequency == (f + 1)])/nrow(bigrams2skip[frequency == f]))

# Discount for all frequency > 2
bigrams2skip[frequency > f]$D <- (f + 1) - (f + 2) * Y * (nrow(bigrams2skip[frequency == (f + 2)])/nrow(bigrams2skip[frequency == (f + 1)]))

# Get new frequency (original frequency - D)
bigrams2skip[, numerator := frequency - D]

# Get frequency of first terms
bigrams2skip <- merge(bigrams2skip, unigrams, by = "first")
setnames(bigrams2skip, c("first", "last", "frequency", "D", "numerator", "denominator"))
rm(unigrams)
gc()

# Get count of frequency of first terms
bigrams2skip[, firstcount := .(.N), by = first]

# Calculate normalizing constant, lambda (D/denominator)*firstcount
bigrams2skip[, lambda := (D/denominator)*firstcount]

# Calculate continuation probability
bigrams2skip[, lastcount := .(.N), by = last]
bigrams2skip[, Pcont := lastcount/nrow(bigrams2skip)]

# Calculate bigram P_kn
bigrams2skip[, Pkn := (numerator/denominator) + lambda*Pcont] # 40MB
bigrams2skip <- bigrams2skip[, c("first", "last", "frequency", "Pcont", "Pkn")] # 21.4MB first, last, frequency, Pcont, Pkn)

save(bigrams2skip, file = "bigrams2skip.RData")
rm(bigrams2skip)
gc()

###### END BIGRAM SKIP 2 PROBABILITIES #####

proc.time() - ptm
rm(f, Y, ptm)
gc()