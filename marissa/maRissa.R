
library(tidyverse)
library(pdftools)
library(here)
library(tidycensus)
library(sf)

df21 <- pdf_text("FY21 HB 3 CCR District Runs.pdf") %>% 
  readr::read_lines() %>%
  as.data.frame() 

## Option 1:
# parse this pdf by removing metadata rows, separating on whitespace
# tedious, but reproducible
# some reference code below
# might take a long time


## Option 2: 
# copy-paste data from pdf into a spreadsheet, load the spreadsheet here

## Option 3:
# research other pdf reader methods-- maybe there is another package, or technique to make option 1 easier


## General steps towards getting data off the pdf
# df <- pdf_text(here::here("marissa", "FY21 HB 3 CCR District Runs.pdf")) %>% 
#   readr::read_lines() %>%
#   as.data.frame() %>% 
#   # removes the header and footer on each page
#   # tried to do this in one line, but I think it recounts after each slice
#   # so, look at the data frame in R, count which rows are header, "slice" them out, reload, recount, reslice..
#   slice(-(1:8)) %>% 
#   slice(-(30:37)) %>% 
#   slice(-(61:69)) %>% 
#   slice(-(93:100)) %>% 
#   slice(-(125:132)) %>% 
#   slice(-(157:164)) %>% 
#   slice(-(189:196)) %>% 
#   slice(-(221:228)) %>% 
#   slice(-(253:260)) %>% 
#   slice(-(268:269)) %>% 
#   # rename our one column
#   rename(county = ".") %>% 
#   # make it a character vector for string manipulations
#   mutate(county = as.character(county)) %>% 
#   # squish out the white space
#   mutate_if(is.character, str_squish) %>% 
#   # squish county names with space into one word 
#   # only want spaces to exist where you want columns to separate- could be tricky
#   mutate(county = str_replace_all(county, " \\(P\\)", "(P)"),
#          county = str_replace_all(county, " 1\\(P\\)", "(P)"),
#          county = str_replace_all(county, " 2\\(P\\)", "(P)"),
#          county = str_replace_all(county, "Deaf Smith", "Deaf-Smith"),
#          county = str_replace_all(county, "El Paso", "El-Paso"),
#          county = str_replace_all(county, "Fort Bend", "Fort-Bend"),
#          county = str_replace_all(county, "Jeff Davis", "Jeff-Davis"),
#          county = str_replace_all(county, "Jim Hogg", "Jim-Hogg"),
#          county = str_replace_all(county, "Jim Wells", "Jim-Wells"),
#          county = str_replace_all(county, "La Salle", "La-Salle"),
#          county = str_replace_all(county, "Live Oak", "Live-Oak"),
#          county = str_replace_all(county, "Palo Pinto", "Palo-Pinto"),
#          county = str_replace_all(county, "Red River", "Red-River"),
#          county = str_replace_all(county, "San Augustine", "San-Augustine"),
#          county = str_replace_all(county, "San Jacinto", "San-Jacinto"),
#          county = str_replace_all(county, "San Patricio", "San-Patricio"),
#          county = str_replace_all(county, "San Saba", "San-Saba"),
#          county = str_replace_all(county, "Tom Green", "Tom-Green"),
#          county = str_replace_all(county, "Val Verde", "Val-Verde"),
#          county = str_replace_all(county, "Van Zandt", "Van-Zandt")) %>% 
#   # space delimit into columns 
#   separate(county, into = names, sep = " ") 
tidycensus::census_api_key("")

v19 <- tidycensus::load_variables(2019, "acs5/subject", cache = TRUE)
b19 <- tidycensus::load_variables(2019, "acs5", cache = T)  
acs_vars <- tidycensus::get_acs(
  geography = "county",
  state = "48",
  #county = "201",
  year = 2019,
  survey = "acs5",
  table = "B28003",         
  geometry = T,
  keep_geo_vars = F)

library(sf) # package for mapping

acs_vars_clean <- acs_vars %>%  # make a new dataframe so you don't have to repull the raw data from tidycensus every time
  select(-moe) %>%              # drop margin of error column- probably won't need
  mutate(variable_name = case_when(variable == "B28003_001" ~ "total_households", # mutate() makes a new column called "variable_name". here we use case_when() to make "variable_name" based on the value of "variable"
                                   variable == "B28003_002" ~ ...,                # finish recoding each variable with a new name
                                   ...)) 

# make a new version, this one in "wide" format, i.e., with each variable as a column
acs_vars_clean_wide <- acs_vars_clean %>% 
  st_drop_geometry() %>%        # drop the geometry variable to do this manipulation- will have to add it back later to map
  select(-variable) %>%         # don't need the variable code name anymore 
  pivot_wider(id_cols = c("GEOID", "NAME"),  # pivot wider makes your data wider by turning rows into columns
              names_from = variable_name,    # new column names come from "variable_name"
              values_from = estimate)        # new column values come from "estimate"
