### ====================== R BASICS ===================== ###

###--- 1. RStudio console panes -----------------------------

## Top left: text editor/script window
# save and edit commands
# most users probably spend the most time here

## Top right: Environment and history
# environment shows you data you've loaded and objects you've created

## Bottom left: console
# run commands, but does not save commands
# good for "scratch work", sanity checks. things you want to check on, but not save forever

## Bottom right: files, plots, packages, viewer
# shows files in your working director
# shows packages installed and loaded
# displays any plots you make

## Notes:
# can change window sizes
# can change window positions: tools --> global options --> pane layout

###--- 2. Commenting and sections---------------------------

## Commenting
# Any line with a "#" in front will not run as code
# Use this to annotate your code- make notes to explain what the code does
# Also use to temporarily pause functions of some code without deleting it

## Sections
# https://support.rstudio.com/hc/en-us/articles/200484568-Code-Folding-and-Sections
# Organize your code with sections
# Can collapse sections by pressing the arrow next to the line number
# Can navigate between sections by pressing the button in the top right of this window pane

###--- 3. Loading data --------------------------------------

## Read in a csv
# "<-" is assignment operator-- it gives a name to the data you read in
# header = T means that R will recognize first row as column names
stars <- read.csv("stars.csv", header = TRUE)

## Read in an excel spreadsheet

## View data
head(stars)   # shows first 10 rows
View(stars)   # shows data frame in a separate window -- can sort and filter here

###--- 4. Loading packages ----------------------------------

## About Packages 
# Packages are bundled code, data and functions + their documentation
# Toolkits that make most things in R easier-- visualization, stats, data cleaning...
# Expand the utility and ease of "base R"-- the functionality available without packages

## Installing Packages
# Add new packages to your R environment
# Only need to do this once

# Method 1: using the packages tab
# in bottom right pane under "Packages" tab, click "Install"

# Method 2: using install.packages()
# run a line of code with ctrl-enter
install.packages("tidyverse")               # install a single package
install.packages(c("leaflet", "babynames")) # install multiple at once by concatenating names into a list

## Loading Packages
# "Check out" installed packages for use
# Do this in every R session-- only load the packages you need for current project

# Method 1: using the packages tab
# in bottom right pane under "Packages" tab, select packages

# Method 2: using library()
# preferred method for reproducibility
library(tidyverse)
library(leaflet)
library(babynames)

###--- 5. Basics of tidyverse -------------------------------

## What is the tidyverse?
# a collection of packages for cleaning, wrangling and visualizing data
# R for Data Science (very great resource!)- https://r4ds.had.co.nz/

## Select - Select (and rename) columns
# reduces number of columns
# make a new object so you don't overwrite the original
# notice stars_select now appears in the environment
stars_select <- select(stars, star, magnitude, temp, type)  # fist arg is the data, following are columns to keep
stars_select <- select(stars, star:type)                    # shorter version if columns are consecutive

## Filter - 
# reduces number of rows
# filter by exact value
stars_filter <- filter(stars, type == "G")

# filter by value of a numeric variable
stars_filterb <- filter(stars, temp > 20000)

## Group by
# use in conjunction with a summarizing metric

## Summarize/Mutate

# help search

###--- 6. Piping a sequence of commands ---------------------

###--- 7. Regression model ----------------------------------

###--- 8. Plotting with ggplot ------------------------------

ggplot(stars, aes(x = temp, y = magnitude, color = type)) + 
  geom_point()
