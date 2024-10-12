# Starting with Data

####################################################################################
## Setting Up                                                                     ##
####################################################################################

download.file("https://ndownloader.figshare.com/files/11492171",
              "SAFI_clean.csv", mode = "wb")


# You are going load the data in R's memory using the function `read_csv()`
# from the `readr` package which is part of the **`tidyverse`**. 
# So, before we can use the `read_csv()` function, we need to load the package. 
# The missing data is encoded as "NULL" in the dataset. 

library(tidyverse)
interviews <- read_csv("SAFI_clean.csv", na = "NULL")


####################################################################################
## What are data frames?                                                          ##
####################################################################################

## What are data frames?
# - the representation of data in the format of a table
# - columns are vectors that all have the same length
# - each column must contain a single type of data

View(interviews) # view the dataframe as a spreadsheet

## Inspecting data frames
# There are functions to extract this information from data frames.
# Here is a non-exhaustive list of some of these functions:
# 
# Size:
dim(interviews) # returns number of rows, number of columns
nrow(interviews) # returns the number of rows
ncol(interviews) # returns the number of columns

# Content:
head(interviews) # shows the first 6 rows
tail(interviews) # shows the last 6 rows

# Names:
names(interviews) # returns the column names (same as 'colnames()')

# Summary:
str(interviews) # structure of the object and information about the class, length and content of each column
summary(interviews) # summary statistics for each column
glimpse(interviews)

####################################################################################
## Indexing and subsetting data frames                                            ##
####################################################################################

## first element in the first column of the data frame
interviews[1, 1]

## first column of the data frame
interviews[, 1]

## first column of the data frame
interviews[1]

## first column of the data frame (as a vector)
interviews[[1]]

## first three elements in the 7th column
interviews[1:3, 7]

## the 3rd row of the data frame
interviews[3, ]

## equivalent to head(interviews)
interviews[1:6, ]
interviews[-c(7:131), ]

# The whole data frame, except the first column
interviews[, -1]          

# Data frames can be subset by calling indices (as shown previously), 
# but also by calling their column names directly:

interviews["village"]       # Result is a data frame
interviews[, "village"]     # Result is a data frame
interviews[["village"]]     # Result is a vector
interviews$village          # Result is a vector

########## Exercise ########## 
# 1. Create a data frame (`interviews_100`) containing only the data in
#    row 100 of the `surveys` dataset.
# 2. Notice how `nrow()` gave you the number of rows in a data frame?
#      * Use that number to pull out just that last row in the data frame.
#      * Compare that with what you see as the last row using `tail()` to make
#        sure it's meeting expectations.
#      * Pull out that last row using `nrow()` instead of the row number.
#      * Create a new data frame (`interviews_last`) from that last row.
# 3. Use `nrow()` to extract the row that is in the middle of the data frame.
#    Store the content of this row in an object named `interviews_middle`.
# 4. Combine `nrow()` with the `-` notation above to reproduce the behavior of
#    `head(interviews)`, keeping just the first through 6th rows of the interviews
#    dataset.
############################## 

####################################################################################
## Factors                                                                        ##
####################################################################################

## Factors:
# - represent categorical data
# - stored as integers associated with labels 
# - can be ordered or unordered. 
# - look like character vectors, but actually treated as integer vectors

# Once created, factors can only contain a pre-defined set of values, known as
# *levels*. By default, R always sorts levels in alphabetical order. For
# instance, if you have a factor with 2 levels:
respondent_floor_type <- factor(c("earth", "cement", "cement", "earth"))
respondent_floor_type

# R will assign `1` to the level `"cement"` and `2` to the level `"earth"`
# (because `c` comes before `e`, even though the first element in this vector is
# `"earth"`). You can see this by using the function `levels()` and you can find
# the number of levels using `nlevels()`:

levels(respondent_floor_type)
nlevels(respondent_floor_type)

# Reordering
respondent_floor_type # current order
respondent_floor_type <- factor(respondent_floor_type, levels = c("earth", "cement"))
respondent_floor_type # after re-ordering

# Renaming levels 
# Let's say we made a mistake and need to recode "cement" to "brick".
levels(respondent_floor_type)

respondent_floor_type <- fct_recode(respondent_floor_type, brick = "cement")
levels(respondent_floor_type)

levels(respondent_floor_type)[2] <- "brick"


respondent_floor_type

# You can make your factor an ordered factor by using the ordered=TRUE option inside your factor function. 
# Note how the reported levels changed from the unordered factor above to the ordered version below. 
# Ordered levels use the less than sign < to denote level ranking.
respondent_floor_type_ordered <- factor(respondent_floor_type, 
                                        ordered = TRUE)
respondent_floor_type_ordered

# Converting a factor to a character vector
as.character(respondent_floor_type)

# Converting factors where the levels appear as numbers to a numeric vector
# It's a little trickier!
# The `as.numeric()` function returns the index values of the factor, not its levels

year_fct <- factor(c(1990, 1983, 1977, 1998, 1990))
as.numeric(year_fct)                     # Wrong! And there is no warning...
as.numeric(as.character(year_fct))       # Works...
as.numeric(levels(year_fct))[year_fct]   # The recommended way.


####################################################################################
## Renaming factors                                                               ##
####################################################################################
# When your data is stored as a factor, you can use the `plot()` function to get a
# quick glance at the number of observations represented by each factor level:

# create a vector from the data frame column "memb_assoc"
memb_assoc <- interviews$memb_assoc
# convert it into a factor
memb_assoc <- as.factor(memb_assoc)
# let's see what it looks like
memb_assoc

plot(memb_assoc)

# Including missing data.
# Let's recreate the vector from the data frame column "memb_assoc"
memb_assoc <- interviews$memb_assoc
# replace the missing data with "undetermined"
memb_assoc[is.na(memb_assoc)] <- "undetermined"
# convert it into a factor
memb_assoc <- as.factor(memb_assoc)
# let's see what it looks like
memb_assoc

plot(memb_assoc)

########## Exercise ########## 
# * Rename the levels of the factor to have the first letter in uppercase:
#   "No","Undetermined", and "Yes". 
# * Now that we have renamed the factor level to "Undetermined", can you
#   recreate the barplot such that "Undetermined" is last (after "Yes")?
##############################

####################################################################################
## Formatting Dates                                                               ##
####################################################################################

library(lubridate)

dates <- interviews$interview_date
str(dates)

# When we imported the data in R, read_csv() recognized that this column contained date information. 
# We can now use the day(), month() and year() functions to extract this information from the date, 
# and create new columns in our data frame to store it:
interviews$day <- day(dates)
interviews$month <- month(dates)
interviews$year <- year(dates)
interviews


# In our example above, the interview_date column was read in correctly as a Date variable but generally that is not the case. 
# Date columns are often read in as character variables and one can use the as_date() function to convert them to the appropriate Date/POSIXctformat.


char_dates <- c("7/31/2012", "8/9/2014", "4/30/2016")
str(char_dates)

as_date(char_dates, format = "%m/%d/%Y")

# Argument format tells the function the order to parse the characters and identify the month, day and year. 
# The format above is the equivalent of mm/dd/yyyy. A wrong format can lead to parsing errors or incorrect results.
as_date(char_dates, format = "%m/%d/%y") # the %y part of the format stands for a two-digit year instead of a four-digit year

# We can also use functions ymd(), mdy() or dmy() to convert character variables to date.
mdy(char_dates)

