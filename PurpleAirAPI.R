library(readr) 
library(lubridate) 
library(httr) 

#API keys assigned by PurpleAir support
read_key <- "Read key "
write_key <- "Write key"

#end date and start date (API format is UNIX GMT)
start_date <- as.POSIXct("2020-01-01")
end_date <- as.POSIXct("2023-02-14")

while(start_date <= end_date) {
  #define end of 2 week period, max request period for 1hr data
  end_period <- start_date + days(14)
  
  #format start and end times as UNIX timestamps
  start_timestamp <- as.numeric(start_date)
  end_timestamp <- as.numeric(end_period)
  
  #substitute start_timestamp and end_timestamp into request URL
  #replace "sensorindex" with your actual sensor index
  url <- paste0("https://api.purpleair.com/v1/sensors/sensorindex/history/csv?start_timestamp=", start_timestamp, "&end_timestamp=", end_timestamp, "&average=60&fields=pm2.5_cf_1_a%2C%20pm2.5_cf_1_b%2Cpm2.5_atm_a%2C%20pm2.5_atm_b%2Cpm2.5_alt_a%2Cpm2.5_alt_b%2Chumidity%2Ctemperature%2Cpressure%2Cuptime%2Crssi%2Cpa_latency%2Cmemory")
  
  #send API request and write to text file
  data <- GET(url,add_headers('X-API-Key'=read_key))
  data <- content(data, "raw")
  writeBin(data, paste("sensorindex",start_timestamp,end_timestamp,".txt", sep="_"))
  
  start_date <- end_period + 1
  flush.console() #this makes sys.sleep work in a loop
  Sys.sleep(60)
}

## Merging files
listfile <- list.files("/path/to/directory", pattern = "txt",full.names = T, recursive = TRUE)

head(listfile)

#combined all the text files in listfile and store in dataframe 'Data'
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

write.csv(Data, "File Name.csv")
