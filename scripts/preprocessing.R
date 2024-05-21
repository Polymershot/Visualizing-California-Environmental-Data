library(tidyverse) #the best!
library(sf) #load in shp file and change into df
library(readxl) #read excel files
library(janitor) #to clean names
library(renv)


#Run code 
#<https://stackoverflow.com/questions/12945687/read-all-worksheets-in-an-excel-workbook-into-an-r-list-with-data-frames>
read_excel_allsheets <- function(filename, tibble = TRUE) {
  sheets <- readxl::excel_sheets(filename)
  x <- lapply(sheets, function(X) readxl::read_excel(filename, sheet = X))
  if(!tibble) x <- lapply(x, as.data.frame)
  names(x) <- sheets
  x
}

mysheets <- read_excel_allsheets("data/California-Environment-Data/envirodata.xlsx")
mysheets[[2]] <- mysheets[[2]] %>% row_to_names(row_number = 1)
names(mysheets) <- c("raw_data", "demographic_data")

#Change column types for science_data
mysheets[[1]]$`Census Tract` <- as.character(mysheets[[1]]$`Census Tract`)
varnames = c("Lead", "Lead Pctl", "Low Birth Weight", "Low Birth Weight Pctl","Education", "Education Pctl", "Linguistic Isolation", "Linguistic Isolation Pctl", "Unemployment", "Unemployment Pctl", "Housing Burden", "Housing Burden Pctl")
mysheets[[1]] <- mysheets[[1]] %>% mutate_if(names(.) %in% varnames, funs(as.numeric(.)))


#Change column types for demographic_data
varnames = names(mysheets[[2]][, -which(names(mysheets[[2]]) %in% c("Census Tract", "CES 4.0 Percentile Range", "California County"))])
mysheets[[2]] <- mysheets[[2]] %>% mutate_if(names(.) %in% varnames, funs(as.numeric(.)))

#Combine the datasets
master_df <- inner_join(mysheets[[1]], mysheets[[2]]) %>% clean_names() %>%
  rename(
    ces_4.0_score = ces_4_0_score,
    ces_4.0_percentile = ces_4_0_percentile,
    ces_4.0_percentile_range = ces_4_0_percentile_range,
    pm_2.5 = pm2_5,
    pm_2.5_pctl = pm2_5_pctl,
    children_less_than_10_years_percent = children_10_years_percent,
    pop_10_through_64_years_percent = pop_10_64_years_percent,
    elderly_greater_than_64_years_percent = elderly_64_years_percent
  )

#Read in shp
census_shp <- st_read("data/Census-Tracts-(Tigerline)/tl_2023_06_tract.shp")
county_shp <- st_read("data/County-Boundaries/CA_Counties_TIGER2016.shp")
census_tibble <- tibble(census_shp)

#Remove 0's from census tracts
census_tibble$GEOID <- gsub("^0", "", census_tibble$GEOID)

#Create copy of census_shp
census_shp_remove0s <- census_shp
census_shp_remove0s$GEOID <- gsub("^0", "", census_shp_remove0s$GEOID)

#Join master and census shp
shp_and_master <- right_join(census_shp_remove0s, master_df, by = join_by("GEOID" == "census_tract")) %>% clean_names()
shp_and_master$california_county <- paste0(shp_and_master$california_county, " County")

#Create list of counties
county_list <-  unique(county_shp$NAMELSAD)


#Select all columns associated with ethnicity/population characteristics
ethnicity_cols <- names(mysheets[[2]] %>% select(!c("Census Tract", "CES 4.0 Score", "CES 4.0 Percentile", "CES 4.0 Percentile Range", "California County")) %>% clean_names() %>% rename(
  children_less_than_10_years_percent = children_10_years_percent,
  pop_10_through_64_years_percent = pop_10_64_years_percent,
  elderly_greater_than_64_years_percent = elderly_64_years_percent
));ethnicity_cols

#Select all columns associated with scientific measures and percentile variables
scientific_cols <- names(mysheets[[1]] %>% select(!c("Census Tract", "CES 4.0 Percentile Range", "Total Population", "California County" ,"ZIP", "Approximate Location", "Longitude", "Latitude", "CES 4.0 Score", "CES 4.0 Percentile", "Pollution Burden", "Pop. Char." ), -matches("Pctl")) %>% clean_names() %>% rename(
  pm_2.5 = pm2_5
));scientific_cols

#Percentile Columns
scientific_cols_pctl <- names(mysheets[[1]] %>% select(!c("Census Tract", "CES 4.0 Percentile Range", "California County" ,"ZIP", "Approximate Location", "Longitude", "Latitude", "CES 4.0 Score", "CES 4.0 Percentile", "Pollution Burden", "Pop. Char." ), matches("Pctl")) %>% clean_names() %>% rename(
  pm_2.5 = pm2_5
) %>% select(matches("Pctl")));scientific_cols_pctl


#Complete Case Data
complete_case <- master_df[complete.cases(master_df),]
data <- complete_case %>% dplyr::select(ethnicity_cols, scientific_cols)


#list of variables to not choose
unwanted_vars = c("statefp", "countyfp", "tractce", "geoid", "geoidfq", "name", "namelsad", "mtfcc", "longitude", "latitude", "funcstat", "aland", "awater", "intptlat", "intptlon","geometry")
shp_master_names = colnames(shp_and_master)

