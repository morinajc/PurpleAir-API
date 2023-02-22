# Load packages
library(readr) 
library(lubridate) 
library(httr)
library(openair)
library(dplyr)

#####--Retrieve data from PurpleAir API--####
# API keys assigned by PurpleAir support
read_key <- "Read Key"
write_key <- "Write Key"

# End date and start date (API format is UNIX GMT)
start_date <- as.POSIXct("2020-01-01")
end_date <- as.POSIXct("2023-02-14")

while(start_date <= end_date) {
  # Define end of 2 week period, max request period for 1hr data
  end_period <- start_date + days(14)
  
  # Format start and end times as UNIX timestamps
  start_timestamp <- as.numeric(start_date)
  end_timestamp <- as.numeric(end_period)
  
  # Substitute start_timestamp and end_timestamp into request URL
  # Replace "sensorindex" with your actual sensor index
  url <- paste0("https://api.purpleair.com/v1/sensors/sensorindex/history/csv?start_timestamp=", start_timestamp, "&end_timestamp=", end_timestamp, "&average=60&fields=pm2.5_cf_1_a%2C%20pm2.5_cf_1_b%2Cpm2.5_atm_a%2C%20pm2.5_atm_b%2Cpm2.5_alt_a%2Cpm2.5_alt_b%2Chumidity%2Ctemperature%2Cpressure%2Cuptime%2Crssi%2Cpa_latency%2Cmemory")
  
  # Send API request and write to text file
  data <- GET(url,add_headers('X-API-Key'=read_key))
  data <- content(data, "raw")
  writeBin(data, paste("sensorindex",start_timestamp,end_timestamp,".txt", sep="_"))
  
  start_date <- end_period + 1
  flush.console() # This makes sys.sleep work in a loop
  Sys.sleep(60)
}

#####--Combining files into one csv or df--####
# Merge files
listfile <- list.files("/path/to/directory", pattern = "txt",full.names = T, recursive = TRUE)

# Inspect list
head(listfile)

# Combine files into df
for (i in 1:length(listfile)){
  if(i==1){
    assign(paste0("Data"), read.table(listfile[i],header = TRUE, sep = ","))
  }
  
  if(!i==1){
    assign(paste0("Test",i), read.table(listfile[i],header = TRUE, sep = ","))
    Data <- rbind(Data,get(paste0("Test",i)))
    rm(list = ls(pattern = "Test"))
  }
}

# Create new date column with the value of the time_stamp column (UNIX)
Data$date <- as.POSIXct(as.numeric(Data$time_stamp), origin = '1970-01-01', tz = 'GMT')

# Convert timezone from GMT to EST
attr(Data$date, 'tzone') = 'EST'

# Save df to csv
write.csv(Data, "File Name.csv")

#####--Plot data using openair package--####
# Rename and create new columns, this example uses the sensor from Vasen
Vasen <- Data
Vasen$year <- year(Vasen$Date)
Vasen$hour <- hour(Vasen$Date)

# The "date" column Needs to be lowercase, use below code if you need to change
# Vasen <- Vasen %>% rename("date" = "Date")

# Select by year, save as numeric, then graph using openair package to visualize temporal trends
# 2020
V.2020 <-Vasen[Vasen$year=="2020",]
V.2020$pm2.5_atm_b <- as.numeric(V.2020$pm2.5_atm_b)
V.2020$pm2.5_atm_a <- as.numeric(V.2020$pm2.5_atm_a)
Vas_2020_graph <-timeVariation(V.2020,pollutant = c("pm2.5_atm_a","pm2.5_atm_b"), ylab = "pm25 (ug/m3)")

# 2021
V.2021 <-Vasen[Vasen$year=="2021",]
V.2021$pm2.5_atm_b <- as.numeric(V.2021$pm2.5_atm_b)
V.2021$pm2.5_atm_a <- as.numeric(V.2021$pm2.5_atm_a)
Vas_2021_graph <-timeVariation(V.2021,pollutant = c("pm2.5_atm_a","pm2.5_atm_b"), ylab = "pm25 (ug/m3)")

# 2022
V.2022 <-Vasen[Vasen$year=="2022",]
V.2022$pm2.5_atm_b <- as.numeric(V.2022$pm2.5_atm_b)
V.2022$pm2.5_atm_a <- as.numeric(V.2022$pm2.5_atm_a)
Vas_2022_graph <-timeVariation(V.2022,pollutant = c("pm2.5_atm_a","pm2.5_atm_b"), ylab = "pm25 (ug/m3)")

