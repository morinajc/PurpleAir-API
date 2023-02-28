# Retrieving Data From PurpleAir

This code is divided into three sections and will retrieve sensor data from PurpleAir API, combine the sensor files, and graph basic temporal scales. First, you will need to contact the PurpleAir support team to receive API keys (contact@purpleair.com). 

## 1. Download data from PurpleAir API
This first part of this code will generate text files for each two-week period. The API will only allow a maximum of 14 days of hourly data in one request, and thus multiple requests must be made in order to collect data over temporal periods greater than 2 weeks. In addition, a request to pull data can only be performed once every minute. This will generate a .txt file for every 14 day period. You can customize which data fields you want to request by adding them to the URL section of the code, the list of parameters can be found here: https://api.purpleair.com. 

## 2. Combine multiple text files
The second part of this code will then combine all of these text files into one file. If the sensor was down during a period of time during your request window, a .txt file will still be generated, but it will be significantly smaller than the files containing sensor data. These blank should be deleted before running this section of the code. The .txt files should be placed into a unique directory with no other .txt files as the code will combine all .txt files in the directory. You will need to edit the path/to/directory to identify the location of the files

## 3. Visualize data
The third part of this code will quickly plot annual data from a sensor to easily assess temporal trends in the pollutant of interest (PM<sub>2.5</sub> in this example). This code utilizes the openair R package. These graphs are made for a quick visual inspection of the data.  

## Other approaches
Alternative approachs can be used to download data from the PurpleAir API. PurpleAir has a guide on making API calls using cURL: https://community.purpleair.com/t/making-api-calls-with-the-purpleair-api/180. A quick way to see the current status of a sensor, or to get its GPS coordinates is to run the following code: 

```
curl -X GET "https://api.purpleair.com/v1/sensors/sensorindexID" -H "X-API-Key: Read-Key-Here"
```
