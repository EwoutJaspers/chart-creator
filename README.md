
# Timetrend chart-creator
R Shiny app to help create [d3.js](https://d3js.org/) interactive charts for the ISD website

### Data file preparation
To use the settings creator the following columns need to be included in the csv data file: 

*	date variable column (required). 

*	NHS Board location column (required). At the moment the first column needs to be an NHS Board column, this will change in the next update to the chart creator. 

*	Second location column (e.g. hospitals) (optional)

*	Measure column (e.g. specialty) (optional)  

*	Variable columns (maximum 6 can be included in a chart, though it advised to not include more than 3 to 4 variables). 

The location data will also need to include aggregated data on Scotland and board level. In case of two location columns they need to be in the following format, with the figures on NHS Board level and Scotland included with the same location name in both columns: 

| date_variable |	nhs_board_name |	location_name |
| ------------- | -------------- |-------------- |
| 2016-03-06 | NHS Ayrshire & Arran	| Location1 |
| 2016-03-06	| NHS Ayrshire & Arran |	Location2 |
| 2016-03-06 |	NHS Ayrshire & Arran |	NHS Ayrshire & Arran |
| 2016-03-06	| Scotland	| Scotland |
 
Please note that only Scotland as location name for Scotland currently works and not NHSScotland. This will change in the next update to the chart creator.

### Setup

R and RStudio with the following packages: 

1.	dplyr
2.	shiny
3.	readr
4.	jsonlite
5.	stringr

Creating the chart settings file

1.	Go to the "chart-settings-creator" folder
2.	Go to the "/www/data" folder
3.	Place the data file(s) for the charts in this folder
4.	Go back to the main "chart-settings-creator" folder 
5.	Open the App.R file in R
6.	Press Run App 
7.	Click open in Browser 
8.	Select the publication date
9.	Add the chart-topic
10.	Select the chart number (number of the chart on the page). 
11.	Select the data file. This dropdown automatically shows the files in the "www/data folder". Files need to be in the "www/data" folder to be selected
12.	Select new settings file or select a settings file to use as basis for the new settings file (or to overwrite). 
13.	Click the "Submit file names" button to start creating the settings file.
14.	The creator will now indicate which data file will be used, which base settings file and how the output file will be called. 

### Settings menu 
1.	In the Input date tab:

     1.	Select the date or category column in the data. 

     2.	Select (or add) the "Date format in the file". See the preview format to see how the column looks in the data (this might differ from how excel shows a csv).


2.	In the Dropdowns tab:

     1.	Select the NHS Board column 
  
     2.	Add NHS Board label (press enter or click "Add ."  to confirm and save the label).
  
     3.	Select the second location column (Optional)
  
     4.	Add NHS Board label (press enter or click "Add ."  to confirm and save the label).(Optional)
  
     5.	Select the measure column (Optional)
  
     6.	Add measure label (press enter or click "Add ."  to confirm and save the label).(Optional)
  
3.	In the Variables tab:

     1.	Select the variable 1 column 
  
     2.	Add variable 1 label (press enter or click "Add ."  to confirm and save the label).
  
     3.	Repeat a and b for any additional variable columns (Optional)
  
4.	In the Text tab:

     1.	Select (or add) the date format of the x axis
  
     2.	Set the x label
  
     3.	Set the y label
  
     4. Set title 
  
     5. Select (or add) the date format for the tooltip
  
5.	In the format tab:

     1. Select the chart type.
  
     2. Adjust the margin so all text and numbers fit in the chart. To set the left margin set the chart size to Large. And make sure all text and numbers are visible in the three screen sizes. 
  
     3. Adjust the number of ticks per screen size (there might be slight differences in the number selected and showing, e.g. 4 showing when 3 selected).  
  
     4. The line stroke width can be set between 1 and 4.
  
     5. Colours of the line can be adjusted in the colours section, though these should in general not be adjusted. 
  
### Creating and testing the settings file

To create the settings and preview the settings file press the "Create/reload and test settings" button. This will show a preview version of the chart. If required adjust and reload the settings file so the chart looks good in small, medium and large sizes. 

### Saving the settings file
Once the file is ready for publication click "Download settings file" and save the file. For the publication put the settings file in the publication folder together with the data file. Add in the email to the publications team which files belong together in the following format: 

Chart 1: datafile name, settings file name  

Chart 2: datafile name, settings file name  



