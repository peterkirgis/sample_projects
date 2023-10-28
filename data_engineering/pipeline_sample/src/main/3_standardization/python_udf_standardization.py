CREATE OR REPLACE PROCEDURE python_standardization(
      INPUT_UPLOAD_TABLE STRING
    , INPUT_MAPPING_TABLE STRING
    , INPUT_DESTINATION_TABLE STRING
  )
  returns string not null
  language python
  runtime_version = '3.8'
  packages = ('snowflake-snowpark-python', 'pandas')
  handler = 'python_standardization'
AS

$$
import pandas as pd
import numpy as np


def python_standardization(snowpark_session, upload_table: str, mapping_table: str, destination_table: str):

  applications = snowpark_session.table(upload_table)
  applications = applications.to_pandas()

  cities = snowpark_session.table(mapping_table)
  cities = cities.to_pandas()

  cities['ZIP_CODE'] = cities['ZIP_CODE'].astype(str)

  def clean_zips(zip):
    if len(zip) == 4:
        zip = '0' + zip
        return zip
    elif len(zip) > 5 or len(zip) < 4:
        return np.nan
    else:
        return zip

  applications.loc[applications['APPLICATION_DATE'] > applications['DENIAL_DATE'], 'DENIAL_DATE'] = np.nan
  
  applications['APPLICANT_ZIP'] = applications['APPLICANT_ZIP'].astype(str)
  applications['APPLICANT_ZIP'] = applications['APPLICANT_ZIP'].str.split('.').str[0]
  applications['APPLICANT_ZIP'] = applications['APPLICANT_ZIP'].apply(lambda x: clean_zips(x))
  
  applications['APPLICANT_STATE'] = 'MA'
  applications['APPLICANT_COUNTRY'] = 'USA'

  applications.loc[pd.isnull(applications['SEX']) | (applications['SEX'] == ""), 'SEX'] = "NOT REPORTED"

  applications = applications.merge(cities, how='left', left_on='APPLICANT_ZIP', right_on='ZIP_CODE')
  applications['APPLICANT_CITY'] = applications.apply(lambda x: x['CITY_TOWN'] if pd.notnull(x['ZIP_CODE']) else x['APPLICANT_CITY'], axis=1)
  applications['APPLICANT_CITY'] = applications.apply(lambda x: x['APPLICANT_CITY'] if pd.notnull(x['APPLICANT_ZIP']) else np.nan, axis=1)
  applications = applications.drop(columns=['ZIP_CODE', 'CITY_TOWN', 'REGION_NAME'])

  def clean_cities(x, y):
    if x not in cities['CITY_TOWN'].values and y not in cities['ZIP_CODE'].values:
        return 'Out of State'
    else:
        return x

  applications['APPLICANT_CITY'] = applications.apply(lambda x: clean_cities(x['APPLICANT_CITY'], x['APPLICANT_ZIP']), axis=1)

  applications_sf = snowpark_session.createDataFrame(applications)
  applications_sf.write.mode("overwrite").save_as_table(destination_table)

  return f"Succeeded: Results inserted into table {destination_table}"
$$
;

call python_standardization('UPLOAD.TEMP_UPLOAD_APPLICATIONS', 'UPLOAD.MASS_ZIPS', 'STANDARDIZATION.STANDARDIZED_APPLICATIONS_PYTHON');

SELECT * FROM standardization.standardized_applications_python;
