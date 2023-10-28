import pandas as pd
import os

def export_to_excel(dataframe_dictionary, folder, readme_text):
    """
    Export a dictionary of dataframes to accessible Excel workbooks in a single folder.

    Parameters:
    dataframe_dictionary (dict): A dictionary of dataframes to be exported to Excel. 
        The keys are the names of the sheets in the Excel workbook. 
        The values are a list of the dataframe and the name of the workbook. 

    folder (str): The path to the folder where the Excel workbooks will be saved.

    readme_text (str): The text to be included in the README sheet of each Excel workbook.
    """

    # Iterate through each dataframe in the dictionary
    for key, val in dataframe_dictionary.items():
        data = val[0]
        name = val[1]
        file_path = folder + name + '.xlsx'

        # Initialize an Excel writer object
        writer = pd.ExcelWriter(file_path, engine='xlsxwriter')

        workbook = writer.book
        
        # Create a README sheet and set the provided text
        readme_sheet = workbook.add_worksheet('README')

        # Formatting: Define font and styles for title and text
        title_format = workbook.add_format({'font_name': 'Arial', 'font_size': 14, 'bold': True})
        text_format = workbook.add_format({'font_name': 'Arial', 'font_size': 11})

        readme_sheet.write('A1', readme_text, text_format)

        sheetname = key

        # Write the dataframe to an Excel sheet
        data.to_excel(writer, sheet_name=sheetname, header=False, index=False, startrow=2)

        worksheet = writer.sheets[sheetname]

        (max_row, max_col) = data.shape

        # Prepare column headers for the table
        column_settings = [{"header": column} for column in data.columns]

        # Calculate the table range
        table_range = f"A2:{chr(ord('A') + max_col - 1)}{max_row + 2}"

        # Format the sheet name to be used as a table name (replacing spaces with underscores)
        table_name = sheetname.replace(' ', '_')

        # Add the table to the worksheet with specific settings
        worksheet.add_table(table_range, {'columns': column_settings, 'style': 'Table Style Light 15', 'banded_rows': True, 'name': table_name})

        # Adjust column widths based on data
        worksheet.set_column(0, max_col - 1, 12, text_format)

        # Further adjust column widths based on maximum text length in each column
        for col_num, column in enumerate(data.columns):
            max_length = max(
                data[column].astype(str).map(len).max(),
                len(column),
                len(str(column)) + 1
            )
            worksheet.set_column(col_num, col_num, max_length + 2)

        # Add border formatting to the table
        border_format = workbook.add_format({'border': 1, 'border_color': 'black'})
        worksheet.conditional_format(table_range, {'type': 'no_errors', 'format': border_format})

        # Set row heights for better presentation
        worksheet.set_row(0, 35)  # Height for the first row
        worksheet.set_default_row(25)  # Default height for all other rows

        # Write the table title (key from the dictionary)
        title = key
        worksheet.write(0, 0, title, title_format)

        # Save and close the workbook
        writer.close()
