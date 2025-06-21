get_PA <- function(readKey, 
                   startDate,
                   endDate,
                   sensor) {
  
  
  read_key <- readKey

  # End date and start date (API format is UNIX GMT)
  start_date <- as.POSIXct(startDate)
  end_date <- as.POSIXct(endDate)
  
  n <- 0
  
  while(start_date <= end_date) {
    n <- n+1
    cli_progress_step(msg = paste0("PurpleAir API call #",n))
    
    
    # Define end of 2 week period, max request period for 1hr data
    end_period <- start_date + days(14)
    
    # Format start and end times as UNIX timestamps
    start_timestamp <- as.numeric(start_date)
    end_timestamp <- as.numeric(end_period)
    
    # Substitute start_timestamp and end_timestamp into request URL
    # Replace "sensorindex" with your actual sensor index
    url <- paste0("https://api.purpleair.com/v1/sensors/",sensor,"/history/csv?start_timestamp=", start_timestamp, "&end_timestamp=", end_timestamp, "&average=60&fields=pm2.5_cf_1_a%2C%20pm2.5_cf_1_b%2Cpm2.5_atm_a%2C%20pm2.5_atm_b%2Cpm2.5_alt_a%2Cpm2.5_alt_b%2Chumidity%2Ctemperature%2Cpressure%2Cuptime%2Crssi%2Cpa_latency%2Cmemory")
    
    # Send API request and write to text file
    data <- GET(url,add_headers('X-API-Key' = read_key))
    data <- content(data, "raw")
    writeBin(data, paste("sensorindex",start_timestamp,end_timestamp,".txt", sep = "_"))
    
    start_date <- end_period + 1
    flush.console() # This makes sys.sleep work in a loop
    Sys.sleep(60)
  }
  
  cli_progress_update()
  
  # ---- Combining files into one df and write csv ---- ####
  # Merge files
  listfile <- list.files(pattern = "txt",full.names = T, recursive = TRUE)
  
  # Inspect list
  head(listfile)
  
  # Combine files into df
  for (i in 1:length(listfile)){
    
    cli_progress_step(msg = "Compiling data")
    
    if(i == 1){
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
  
  paData <- Data
    
  return(paData)
}
