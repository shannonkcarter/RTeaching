### ====================== R BASICS ===================== ###

###--- 1. RStudio console panes -----------------------------

## Top left: text editor/script window
# save and edit commands
# most users probably spend the most time here

## Top right: console
# run commands, but does not save commands
# good for "scratch work", sanity checks. things you want to check on, but not save forever

## Bottom left: Environment and git
# environment shows you data you've loaded and objects you've created
# commit, push, and pull from RStudio!

## Bottom right: files, plots, packages, viewer
# shows files in your working directory
# shows packages installed and loaded
# displays any plots you make

## Notes:
# can change window sizes
# can change window positions: tools --> global options --> pane layout

###--- 2. Commenting and sections---------------------------

## Commenting
# Any line with a "#" in front will not run as code
Any line without a "#" in front will try to run as code
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
head(stars)   # shows first few rows of data
View(stars)   # shows data frame in a separate window -- can sort and filter here

###--- 4. Loading packages ----------------------------------

## About Packages 
# Packages are bundled code, data and functions + their documentation
# Toolkits that make most things in R easier-- visualization, stats, data cleaning...
# Expand the utility and ease of "base R"-- the functionality available without packages

## Installing Packages
# Add new packages to your computer
# Only need to do this once

# Method 1: using the packages tab
# in bottom right pane under "Packages" tab, click "Install" and search by package name

# Method 2: using install.packages()
# run a line of code with ctrl-enter
install.packages("tidyverse")               # install a single package
install.packages(c("leaflet", "tidyverse")) # install multiple at once by concatenating ("c()") names into a list

## Loading Packages
# "Check out" installed packages for use
# Do this in every R session-- only load the packages you need for current project

# Method 1: using the packages tab
# in bottom right pane under "Packages" tab, select packages

# Method 2: using library()
# preferred method for reproducibility
library(tidyverse)
library(leaflet)

###--- 5. Basics of tidyverse -------------------------------

## What is the tidyverse?
# a collection of packages for cleaning, wrangling, analyzing, and visualizing data
# R for Data Science (very great resource!)- https://r4ds.had.co.nz/

## Select - Select (and rename) columns
# reduces number of columns
# make a new object so you don't overwrite the original
# notice stars_select now appears in the environment
stars_select <- select(stars, star, magnitude, temp, type)  # first specify the data, then all columns to keep
stars_select <- select(stars, star:type)                    # shorter version if columns are consecutive
stars_select <- select(stars, -X)                           # drop a column
stars_selectb <- select(stars,                              # with select, you can also rename column headers
                        star_name = star,                   # newname = oldname, change "star" to "star_name"
                        magnitude = magnitude,              # can keep some headers the same
                        temperature = temp,                 # change temp to temperature
                        type = type)                        # columns you don't list will be dropped (use rename() to rename without selecting/dropping)

## Filter - filter rows of data by a certain criteria 
# reduces number of rows
# filter by exact name
stars_filter <- filter(stars, type == "G")

# filter by value of a numeric variable
stars_filterb <- filter(stars, temp > 20000)

# filter by multiple criteria at once
stars_filterc <- filter(stars, type == "A" & temp > 9000)  # returns type A stars that are over 9000deg
stars_filterd <- filter(stars, type == "A" | type == "B")  # "|" means "or"

## Group by - groups data by values of a particular variable
# use in conjunction with a summarizing metric
stars_group  <- group_by(stars, type)  # groups stars by type-- only useful if you then do something with those groupings

## Summarize - perform summary statistics on data
# "summarize" indicates you'll be grouping data and reducing number of rows
# make new variables (i.e., temp_avg = ) and define them however you like
# common summaries are mean, sd, max, min, length, median...
stars_summarize <- summarize(stars,                  # first, designate data
                       temp_avg = mean(temp),        # then, make as many calculations as you want
                       temp_sd  = sd(temp),          # each line here makes a new column in the df "stars_summarize"
                       temp_max = max(temp),
                       temp_min = min(temp),
                       mag_avg = mean(magnitude),
                       mag_sd  = sd(magnitude),
                       mag_max = max(magnitude),
                       mag_min = min(magnitude))

# summarize by group!
stars_summarizeb <- summarize(stars_groups, 
                              temp_avg = mean(temp))
# help search
?filter  # gives information on arguments and examples of use
?select

###--- 6. Piping a sequence of commands ---------------------

## About Pipes (" %>% ")
# chain together a sequence of commands
# read as "then"
# keyboard shortcut cmd-shift-m

## Calculate the average temperaure and magnitude of type A and G stars
stars_pipe <- stars %>%                  # make new object called stars_pipe by taking stars, then...
  select(star:type) %>%                 # select only these columns, then...           
  filter(type == "A" | type == "M") %>%  # filter to types A or M, then...
  group_by(type) %>%                     # group data by star type, then...
  summarize(avg_temp = mean(temp),       # calculate average temperature and magnitude for star types A and G
            avg_mag  = mean(magnitude))  
View(stars_pipe)

# Non-pipe method-- longer, more opportunity for error, harder to read
stars_select <- select(stars, star:type)
stars_filter <- filter(stars_select, type == "A" | type == "M")
stars_group  <- group_by(stars_filter, type)
stars_sum <- summarize(stars_group, 
                       avg_temp = mean(temp),
                       avg_mag  = mean(magnitude))
View(stars_sum)

###--- 7. Regression model ----------------------------------

# Are magnitude and temperature related?
# simple lm formula is y~x
linear_model <- lm(formula = magnitude ~ temp, data = stars)
coef(linear_model)      # gives intercept and slope of model
summary(linear_model)   # gives residuals, error, p-values

###--- 8. Plotting with ggplot ------------------------------

# https://www.r-graph-gallery.com/index.html

# scatter plot showing relationship between temperature and star type 
ggplot(data = stars, # specify data
       mapping = aes(x = temp, y = magnitude, color = type)) + # mapping (i.e., how components of the data relate to elements of the graph)
  geom_point()  # add "geom", basically what kind of graph (geom_bar, geom_boxplot, geom_line...)

# boxplot showing temperature of different star types
ggplot(data = stars, mapping = aes(x = type, y = temp)) +
  geom_boxplot(color = 'blue') +
  geom_point()     # multiple geoms possible on one plot
