# Overview

This repository contains the files for developing a predictive text application, a product of the <b>Data Science Specialization by Johns Hopkins University on Coursera</b>.

The project covers
* Analyzing a large corpus of text documents to discover the structure in the data and how words are put together
* Cleaning and analyzing text data
* Building and sampling from a predictive text model
* Building a predictive text product

The application was developed with Natural Language Processing R packages <code>quanteda</code> and <code>tm</code>, and employs the Kneser-Ney smoothing algorithm in calculating the probability distributions of ngrams.

# Files

## Processing Corpus
* <code>ngramTable.R</code>
* <code>helperFunctions.R</code>

## Calculating Probabilities
* <code>probabilities.R</code>

## Building Prediction Model
* <code>predictions.R</code>

## Developing Shiny App
All files are contained within the <code>nextword</code> folder

## Presentation Slides
* <code>nextWord.Rpres</code>
* <code>nextWord.md</code>
#### Presentation Image Files
* <code>app.png</code>
* <code>benchmark_final.png</code>
* <code>sets.png</code>
