




<style>

.section .reveal .state-background {
   background: 	#56678b;
}

.section .reveal .controls div.enabled.navigate-right {
  border-left-color: white;
}

.custom .reveal .state-background {
  background: white;
} 

.custom .reveal section img{
  background:none; 
  border:none; 
  box-shadow:none;
}

.custom .reveal h3,
.custom .reveal p {
  color: #0e275a;
  font-size: 50px;
}
.custom .reveal h1,
.custom .reveal h2,
.custom .reveal h6,
.custom .reveal p {
  color: #39445c;
  font-size: 30px;
}

.custom .reveal strong {
 color: #0e275a;
}

.custom .reveal table{
  font-size: 0.5em;
  border-style: ridge;
  color: #100842;
  margin: 0 auto;
}

.custom .reveal table th {
  border-width: 1px;
  padding-left: 10px;
  padding-right: 25px;
  font-weight: bold;
  border-style: ridge;
  border-color: #100842;
}

.reveal table td {
  border-width: 1px;
  padding-left: 10px;
  padding-right: 25px;
  border-style: ridge;
  border-color: #100842;
}

.midcenter {
    position: fixed;
    top: 35%;
    left: 20%;
}

.footer {
    color: #39445c; 
    background: white;
    top: 100%; left: 20%;
    text-align:left; width:100%;
}

.reveal small {
	font-size: 0.5em;
}


</style>

Predictive Text
========================================================
author: Evelyn Baskaradas
date: 4 September 2017
autosize: true
font-family: "Palatino Linotype", "Book Antiqua", Palatino, serif

<small>Capstone Project </br>
Data Science Specialization </br>
by Johns Hopkins University on Coursera</small>

Introduction
========================================================
type: custom

Predictive text is input technology used in assisting mobile users with typing messages or notes on their devices by providing a small number of word suggestions that may reasonably fit into the context of a given sentence or phrase.

<img style="float: right;" src="sets.png">

The Predictive Text Application delivers this functionality based on corpora collected from publicly available sources by a web crawler. The corpora is sourced from the [Capstone Dataset Coursera site](https://d396qusza40orc.cloudfront.net/dsscapstone/dataset/Coursera-SwiftKey.zip), with focus on the **en_US** locale (English - United States). 

Text is sourced from blogs, news, and twitter combined, and is partitioned for training (70%) and test (30%) sets. A 10% validation set is further partitioned from the training set. The prediction model is built on the training set.


<table>
 <thead>
  <tr>
   <th style="text-align:left;"> File </th>
   <th style="text-align:center;"> Lines </th>
   <th style="text-align:center;"> Words </th>
   <th style="text-align:center;"> Longest Line Length </th>
   <th style="text-align:center;"> Ave Char/Line </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> Training </td>
   <td style="text-align:center;"> 268,989 </td>
   <td style="text-align:center;"> 6,419,496 </td>
   <td style="text-align:center;"> 4,491 </td>
   <td style="text-align:center;"> 133 </td>
  </tr>
</tbody>
</table>


Kneser-Ney Smoothing
========================================================
type: custom

This application employs the **Kneser-Ney smoothing** algorithm to calculate the probability distribution of n-grams in a corpus based on their histories. It is  fundamentally a backoff smoothing algorithm, modified to exclude unseen higher-order n-grams when backing off and calculating the lower-order probability.

Take, for example, the common bigram example of "San Francisco" which may appear many times in a training corpus. As such, the unigram frequency "Francisco" occurs relatively often, though mostly following the word "San". Kneser-Ney smoothing considers the frequency of "Francisco" in relation to its possible preceeding words.

$$P_{KN}(Francisco) = \frac{N_{1+}(\bullet Francisco)}{N_{1+}(\bullet \bullet)} = \frac{c\ (Francisco)}{\sum_{w_i}c\ (w_i)}$$

$$P_{KN}(Francisco|San) = \frac{max\{c\ (San Francisco) - D,\ 0\}}{c\ (San)} + \frac{D}{c\ (San)}N_{1+}(San\bullet)P_{KN}(Francisco)$$ The discount value, <i>D</i>, is estimated based on the total number of n-grams occuring exactly once and twice. $$D = \frac{n_1}{n_1 + 2n_2}$$




The Application
========================================================
type: custom

<img style="float: right;" src="app.png">

The application takes in an input of any length and provides the top 5 predictions based on the context of the last quadgrams to bigrams depending on the observation matches in the dictionary. 

The default base for predictions is quadgrams, supplemented by predictions from trigrams and bigrams if the default is unable to provide all 5 predictions.

If no results are returned, skip-1 and skip-2 bigrams are utilized.

The user may also choose to view the predictions by n-gram probability distributions and compare them with raw frequency counts of word occurances in the dictionary.

Try the Application
========================================================
type: custom

<img style="float: right;" src="benchmark_final.png">

The accuracy of the model was evaluated using the [Next Word Prediction Benchmark](https://github.com/hfoffani/dsci-benchmark) tool*. 

While performing at an acceptable level, future enhancements will include explorations into further trimming the dictionary as well as considerations for the inclusion or exclusion of stop words.

The **Predictive Text** application is a useful interactive tool which enables users, particularly of mobile devices, to construct text messages or notes quickly and with ease.

<a href = "https://evelynb7.shinyapps.io/nextword/", target = "_blank">Get the app!</a>

<div class="footer" style="margin-top:-10px;font-size:50%; line-height:90%;">
* R script as modified by H. Foffani (accessed 27 August 2017)
</div>

<div class="footer" style="margin-top:20px;font-size:50%; line-height:90%;">
<b>Resources:</b> <br><br>

[1] Wikipedia, <a href =  "https://en.wikipedia.org/wiki/Kneser-Ney_smoothing", target = "_blank">Kneser-Ney smoothing</a><br>
[2] M.C. K&ouml;rner,
<a href =  "https://west.uni-koblenz.de/sites/default/files/BachelorArbeit_MartinKoerner.pdf", target = "_blank">Implementation of Modified Kneser-Ney Smoothing on Top of Generalized Language Models for Next Word Prediction</a><br>
[3] S. F. Chen and J. Goodman, <a href = "https://people.eecs.berkeley.edu/~klein/cs294-5/chen_goodman.pdf", target = "_blank">An Empirical Study of Smoothing Techniques for Language Modeling</a><br>
[4] J. Gauthier, <a href = "http://www.foldl.me/2014/kneser-ney-smoothing/", target = "_blank">Kneser-Ney smoothing explained</a><br>
[5] S. Milli, <a href = "http://smithamilli.com/blog/kneser-ney/", target = "_blank">Kneser-Ney Smoothing</a>

</div>
