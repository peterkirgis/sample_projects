# Open Data Firearms Licensing Data Pipeline

## Project Documentation

1.[Project Description](#project-description)

2.[ETL Structure](#etl-structure)

3.[Infrastructure Details](#infrastructure-details)

### Project Description

This folder holds an end-to-end data pipline sample using AWS, Snowflake, and Power BI. This was for a project to automate the process of firearms licensing data in the state of Massachusetts. The src folder holds the database creation scripts and DAGs which take a large raw data file from s3 as an input and create a set of reporting tables. The pipeline also includes a process for intaking Census data for reference populations using the tidycensus package in R. All of the data used in this project was already publicly availabile. 

### ETL Structure

![alt text](https://github.com/massgov/DS-analytics-team/blob/DP-26510-firearms-etl/ETL.png)

ETL processes:  

  1. Client deposits data in s3 bucket
  2. Snowflake picks up data from s3 bucket and places it in external storage
  3. Copy data from external storage into upload tables
  4. Standardize data to clean up dates and geographies
  5. Create reporting tables to feed Power BI dashboard and flat files to be published on mass.gov
  6. Upload data to Power BI and publish flat files to mass.gov

### Infrastructure Details

Cloud Storage: s3  
Database Solution: Snowflake  
ETL Tool: Snowflake Tasks  
BI Tool: Power BI