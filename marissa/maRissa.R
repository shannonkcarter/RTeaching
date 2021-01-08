install.packages(c("tidyverse", "pdftools", "here"))
library(tidyverse)
library(pdftools)
library(here)

df21 <- pdf_text(here::here("marissa", "FY21 HB 3 CCR District Runs.pdf")) %>% 
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
