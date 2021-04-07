### ====================== R BASICS ===================== ###

###--- 1. RStudio console panes -----------------------------

## Top left: text editor/script window
# save and edit commands
# most users probably spend the most time here

## Bottom left: console
# run commands, but does not save commands
# good for "scratch work", sanity checks. things you want to check on, but not save forever

## Top right: Environment and git
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

###--- 3. Loading packages ----------------------------------

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
# run a line of code with ctrl-enter or cmd-enter
install.packages("tidyverse")               # install a single package
install.packages(c("tidycensus", "tidyverse")) # install multiple at once by concatenating ("c()") names into a list

## Loading Packages
# "Check out" installed packages for use
# Do this in every R session-- only load the packages you need for current project

# Method 1: using the packages tab
# in bottom right pane under "Packages" tab, select packages

# Method 2: using library()
# preferred method for reproducibility
library(tidyverse)
library(tidycensus)

###--- 4. Loading data --------------------------------------

## Read in a csv
# "<-" is assignment operator-- it gives a name to the data you read in
# header = T means that R will recognize first row as column names
# run a line of code with ctrl-enter or cmd-enter
stars <- read.csv("stars.csv", header = TRUE)

## View data
head(stars)   # shows first few rows of data
View(stars)   # shows data frame in a separate window -- can sort and filter here
names(stars)  # shows column names
str(stars)    # shows variable types and basic info for all vars

## Pull data from the Census API with tidycensus
# you'll need to obtain a census API key which you should only need to enter once
# https://api.census.gov/data/key_signup.html enter the key into the quotes here
tidycensus::census_api_key("")

# use load_variables() to look at variables in census tables
# use this in tandem with https://data.census.gov/cedsci/ to find the tables you need
s19 <- tidycensus::load_variables(2019, "acs5/subject", cache = TRUE)
b19 <- tidycensus::load_variables(2019, "acs5", cache = T)  

# use get_acs() to pull the actual data
# helpful resource: https://walker-data.com/tidycensus/articles/basic-usage.html
acs <- tidycensus::get_acs(
  geography = "county",  # geography options include "county", "tract", "block group", "state"
  state = "48",          # FIPS code 48 for texas
  #county = "201",       # can specify certain counties in TX or get all of them
  year = 2019,
  survey = "acs5",       # designate American Community Survey 5-year estimate. acs1 and others also options
  table = "B28003",      # found this table number by scanning b19 above    
  geometry = T,          # include the shape file to enable mapping?
  keep_geo_vars = F) %>%     # keep many extra variables related to location (sometimes useful)
  filter(variable == "B28003_001")
View(acs)


# https://data.census.gov/cedsci/table?q=ACSDT1Y2019.B28003&tid=ACSDT1Y2019.B28003&hidePreview=true

###--- 5. Basics of tidyverse -------------------------------

## What is the tidyverse?
# a collection of packages for cleaning, wrangling, analyzing, and visualizing data
# R for Data Science (very great resource!)- https://r4ds.had.co.nz/

## Select() - Select (and rename) columns
# reduces number of columns
# make a new object so you don't overwrite the original
# notice stars_select now appears in the environment
acs_select <- select(acs, GEOID, NAME, variable, estimate)  # first specify the data, then all columns to keep

acs_select <- select(acs,             # with select, you can also rename column headers
                     geoid = GEOID,   # newname = oldname, lowercase for ease of referencing
                     county = NAME,   
                     variable,        # to keep a name the same, just list it
                     estimate)        # columns you don't list will be dropped (use rename() to rename without selecting/dropping)

## Filter() - filter rows of data by a certain criteria 
# reduces number of rows
# filter by exact name
acs_harris <- filter(acs, NAME == "Harris County, Texas")

# filter by value of a numeric variable
acs_filterb <- filter(acs, estimate > 2000)

# filter by multiple criteria at once
acs_harrisb <- filter(acs, NAME == "Harris County, Texas" & estimate > 10000)  

# help search
?filter  # gives information on arguments and examples of use
?select

## Mutate() - make a new column based on existing column
acs_clean <- mutate(acs, variable_name = case_when(variable == "B28003_001" ~ "households_total", # mutate() makes a new column called "variable_name". here we use case_when() to make "variable_name" based on the value of "variable"
                                                   variable == "B28003_002" ~ "households_with_computer", # use table b19 filtered for name == B28003 to get the name of each variable
                                                   variable == "B28003_003" ~ "households_with_dialup",
                                                   variable == "B28003_004" ~ "households_with_broadband",
                                                   variable == "B28003_005" ~ "households_without_internet",
                                                   variable == "B28003_006" ~ "households_without_computer")) 
# do some validating here to ensure you got the table names correct- households_with_computer + households_without_computer should equal "total_households", etc

## Pivot_() - make data longer or wider
acs_wide <- pivot_wider(acs,
                        id_cols = c("GEOID", "NAME"),  # pivot wider makes your data wider by turning rows into columns
                        names_from = variable,         # new column names come from "variable"
                        values_from = estimate)        # new column values come from "estimate"

###--- 6. Piping a sequence of commands ---------------------

## About Pipes (" %>% ") 
# chain together a sequence of commands
# read as "then"
# keyboard shortcut cmd-shift-m

## Do several data cleaning steps in one command
# make new object called acs_pipe by taking acs, then...
acs_pipe <- acs %>%  
  # rename some columns and drop the moe column, then...
  select(geoid = GEOID, county = NAME, variable, estimate) %>%
  # recode the variable names, then...
  mutate(             
    variable_name = case_when(
      variable == "B28003_001" ~ "households_total",
      variable == "B28003_002" ~ "households_with_computer",
      variable == "B28003_003" ~ "households_with_dialup",
      variable == "B28003_004" ~ "households_with_broadband",
      variable == "B28003_005" ~ "households_without_internet",
      variable == "B28003_006" ~ "households_without_computer")
  ) %>% 
  # drop the code for variable name, then...
  select(-variable) %>%
  # pivot, to make variables columns (one row per county)
  pivot_wider(id_cols = c("geoid", "county"),
              names_from  = variable_name,
              values_from = estimate)
View(acs_pipe)

# quick plot with ggplot
ggplot(acs_pipe, aes(x = households_total, y = households_with_computer)) + 
  geom_point()
