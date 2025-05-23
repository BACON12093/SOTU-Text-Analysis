# State of the Union (SOTU) Text Analysis

This Shiny app provides an interactive platform to explore the sentiment and word trends in the State of the Union (SOTU) addresses from various U.S. presidents over time.

## Summary
- Loads a dataset of SOTU speeches along with sentiment lexicons (bing, afinn, and nrc).

- Allows users to filter speeches by president and year range.

- Provides options to select the sentiment lexicon for analysis.

- Tracks the frequency of user-specified words over time.

- Displays interactive sentiment score bar charts and word trend line plots.

- Offers data tables showing underlying sentiment scores and word counts.

## Features
Sentiment Analysis

  Computes average sentiment scores per year using the selected lexicon to show positive or negative trends in presidential rhetoric.

Word Trend Analysis

  Tracks the usage of specified keywords across speeches and years, visualizing how topics evolve in political discourse.

Customizable Filters

  Users can select any president or all presidents, adjust year ranges, choose sentiment lexicons, and specify words to track.

## Tools
- R and Shiny for app development and interactivity

- Tidyverse for data manipulation

- Tidytext for text tokenization and sentiment joining

- Plotly for interactive visualizations

- DT for interactive data tables

- Color palettes from RColorBrewer and viridis

## Insights
Sentiment scores reveal how presidential tone shifts over different administrations and historical periods.

Word trend analysis highlights the prominence and evolution of key themes such as freedom, economy, war, peace, democracy, and others across decades, matching up with times of war or peace.
