# Introducing dplyr and tidyr

####################################################################################
## Data Manipulation using dplyr and tidyr                                        ##
####################################################################################
# We're going to learn some of the most common `dplyr` functions:
# - `select()`: subset columns
# - `filter()`: subset rows on conditions
# - `mutate()`: create new columns by using information from other columns
# - `group_by()` and `summarize()`: create summary statistics on grouped data
# - `arrange()`: sort results
# - `count()`: count discrete values

# Set Up
library(tidyverse)
interviews <- read_csv("SAFI_clean.csv", na = "NULL")
interviews

####################################################################################
## Selecting columns and filtering rows                                           ##
####################################################################################
# To select columns of a data frame, use `select()`.
# The first argument is the dataframe and the subsequent are the columns to keep.
select(interviews, village, no_membrs, years_liv)

# to do the same thing with subsetting
interviews[c("village","no_membrs","months_lack_food")]

# to select a series of connected columns
select(interviews, village:respondent_wall_type)

# To choose rows based on a specific criteria, use `filter()`:
filter(interviews, village == "Chirodzo")

# filters observations with "and" operator (comma)
# output dataframe satisfies ALL specified conditions
filter(interviews, village == "Chirodzo",
       rooms > 1,
       no_meals > 2)

# filters observations with "|" logical operator
# output dataframe satisfies AT LEAST ONE of the specified conditions
filter(interviews, village == "Chirodzo" | village == "Ruaca")


####################################################################################
## Pipes                                                                          ##
####################################################################################
# What if you want to select and filter at the same time?
# There are three ways to do this: use intermediate steps, nested functions, or pipes.

# Intermediate steps
interviews2 <- filter(interviews, village == "Chirodzo")
interviews_ch <- select(interviews2, village:respondent_wall_type)

# Nest functions (i.e. one function inside of another)
interviews_ch <- select(filter(interviews, village == "Chirodzo"), village:respondent_wall_type)

## Pipes
# - take the output of one function and send it directly to the next
# - `%>%`
# - require the `magrittr` package
# - you can type the pipe with 'Ctrl' + 'Shift' + 'M' ('Cmd' + 'Shift' + 'M' for Mac)
interviews %>%
  filter(village == "Chirodzo") %>%
  select(village:respondent_wall_type)

# we can also use |> (called native R pipe) and it comes preinstalled with R v4.1.0 onwards)
interviews |>
  filter(village == "Chirodzo") |>
  select(village:respondent_wall_type)

# If we want to create a new object with this smaller version of the data, we
# can assign it a new name:
interviews_ch <- interviews %>%
  filter(village == "Chirodzo") %>%
  select(village:respondent_wall_type)

interviews_ch


########## Exercise ########## 
# Using pipes, subset the `interviews` data to include interviews
# where respondents were members of an irrigation association (`memb_assoc`)
# and retain only the columns `affect_conflicts`, `liv_count`, and `no_meals`.
############################## 

####################################################################################
## Mutate                                                                         ##
####################################################################################
# Create new columns based on the values in existing columns

# We might be interested in the ratio of number of household members
# to rooms used for sleeping (i.e. avg number of people per room):

interviews %>%
  mutate(people_per_room = no_membrs / rooms)

# We may be interested in investigating whether being a member of an
# irrigation association had any effect on the ratio of household members
# to rooms. We have to remove data from our dataset where the respondent didn't 
# answer the question of whether they were a member of an irrigation association.
# To remove these cases, we could insert a `filter()` in the chain:

interviews %>%
  filter(!is.na(memb_assoc)) %>%
  mutate(people_per_room = no_membrs / rooms)

# The `!` symbol negates the result, so we're asking for every row where
# `memb_assoc` *is not* missing..

########## Exercise ########## 
#  Create a new data frame from the `interviews` data that meets the following
#  criteria: contains only the `village` column and a new column called
#  `total_meals` containing a value that is equal to the total number of meals
#  served in the household per day on average (`no_membrs` times `no_meals`).
#  Only the rows where `total_meals` is greater than 20 should be shown in the
#  final data frame.
#
#  **Hint**: think about how the commands should be ordered to produce this data
#  frame!
############################## 

####################################################################################
## Split-apply-combine data analysis and the summarize() function                 ##
####################################################################################

# Many data analysis tasks can be approached using the *split-apply-combine* paradigm:
# 1. split the data into groups
# 2. apply some analysis to each group
# 3. combine the results.

# `group_by()` is often used together with `summarize()`, which collapses each
# group into a single-row summary of that group.  `group_by()` takes as arguments
# the column names that contain the categorical variables for which you want
# to calculate the summary statistics.

#So to compute the average household size by village:
interviews %>%
  group_by(village, memb_assoc) %>%
  summarize(mean_no_membrs = mean(no_membrs)) %>%
  ungroup()

# You can also group by multiple columns:
interviews %>%
  group_by(village, memb_assoc) %>%
  summarize(mean_no_membrs = mean(no_membrs))

# Note that the output is a grouped tibble. To obtain an ungrouped tibble, use the ungroup function:
interviews %>%
  group_by(village, memb_assoc) %>%
  summarize(mean_no_membrs = mean(no_membrs)) %>%
  ungroup()

# We can exclude missing data from our table using a filter step.
interviews %>%
  filter(!is.na(memb_assoc)) %>%
  group_by(village, memb_assoc) %>%
  summarize(mean_no_membrs = mean(no_membrs))

# You can also summarize multiple variables at the same time
interviews %>%
  filter(!is.na(memb_assoc)) %>%
  group_by(village, memb_assoc) %>%
  summarize(mean_no_membrs = mean(no_membrs),
            min_membrs = min(no_membrs))

# You can rearrange the result of a query to inspect the values.
interviews %>%
  filter(!is.na(memb_assoc)) %>%
  group_by(village, memb_assoc) %>%
  summarize(mean_no_membrs = mean(no_membrs), min_membrs = min(no_membrs)) %>%
  arrange(min_membrs)

# To sort in descending order, add the `desc()` function.
interviews %>%
  filter(!is.na(memb_assoc)) %>%
  group_by(village, memb_assoc) %>%
  summarize(mean_no_membrs = mean(no_membrs),
            min_membrs = min(no_membrs)) %>%
  arrange(desc(min_membrs))


########## Exercise ########## 
# Use `group_by()` and `summarize()` to find the mean, min, and max
# number of household members for each village. Also add the number of
# observations (hint: see `?n`).
############################## 

####################################################################################
## Counting                                                                       ##
####################################################################################
# When working with data, we often want to know the number of observations found
# for each factor or combination of factors.

interviews %>%
  count(village)

# `count()` provides the `sort` argument
interviews %>%
  count(village, sort = TRUE)

########## Exercise ########## 
# 1. How many households in the survey have two meals per day? Three meals per day? 
#    Are there any other numbers of meals represented?
# 2. Use group_by() and summarize() to find the mean, min, and max number of household members for each village. 
#    Also add the number of observations (hint: see ?n).
# 3. What was the largest household interviewed in each month?
############################## 

####################################################################################
## Exporting data                                                                 ##
####################################################################################
# Similar to the `read_csv()` function used for reading CSV files into R, there is
# a `write_csv()` function that generates CSV files from data frames.

# In preparation for our next lesson on plotting, we are going to create a
# version of the dataset where each of the columns includes only one
# data value. To do this, we will use spread to expand the
# `months_lack_food` and `items_owned` columns. We will also create a couple of summary columns.

interviews_plotting <- interviews %>%
  ## spread data by items_owned
  mutate(split_items = strsplit(items_owned, ";")) %>%
  unnest() %>%
  mutate(items_owned_logical = TRUE) %>%
  spread(key = split_items, value = items_owned_logical, fill = FALSE) %>%
  rename(no_listed_items = `<NA>`) %>%
  ## spread data by months_lack_food
  mutate(split_months = strsplit(months_lack_food, ";")) %>%
  unnest() %>%
  mutate(months_lack_food_logical = TRUE) %>%
  spread(key = split_months, value = months_lack_food_logical, fill = FALSE) %>%
  ## add some summary columns
  mutate(number_months_lack_food = rowSums(select(., Apr:Sept))) %>%
  mutate(number_items = rowSums(select(., bicycle:television)))

# Now we can save this data frame to our `data_output` directory.
write_csv(interviews_plotting, path = "interviews_plotting.csv")
