# BTS

## ...is a toy-sized Bayesian Time Series project.

We'll look at monthly Google search query hit counts in the UK and NZ for the term "queen's birthday".

After a rapid EDA, supplemented by a touch of extrogenous research, we'll fit an Normal Dynamic Linear Model (NDLM)
to tackle three common timeseries tasks in a Bayesian manner:

Find the distribution of the number of hits at time t given
+ the available information up to and including time t (filtering)
+ all available information (up to and beyond) time t (smoothing)
+ only the information available up to time s for some s < t (prediction)

The fitted model describes the data remarkably well and accurately predicts 12 months into the future!
In spite of this, all models have caveats and failure modes: we close the project by highlighting assumptions and future 
events that might cause the modelling to diverge significantly from reality.

Two files are of particular interest:
  + `projects/gtrends_project.Rmd`: *The R Markdown version of the project.*
  + `projects/gtrends_project.pdf`: *A pdf version of the output!*
