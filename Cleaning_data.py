import pandas as pd
import os

def clean_csv_file(filepath):
    # Read the CSV file
    df = pd.read_csv(filepath)

    # Strip whitespace from string columns
    df = df.applymap(lambda x: x.strip() if isinstance(x, str) else x)

    # Drop rows that are completely empty
    df.dropna(how='all', inplace=True)

    # Remove duplicate rows
    df.drop_duplicates(inplace=True)

    # Save the cleaned file (overwrite or save to new folder)
    cleaned_filepath = os.path.splitext(filepath)[0] + '_cleaned.csv'
    df.to_csv(cleaned_filepath, index=False)
    print(f'Cleaned file saved to: {cleaned_filepath}')

def clean_all_csv_in_folder(folder_path):
    for filename in os.listdir(folder_path):
        if filename.endswith('.csv'):
            filepath = os.path.join(folder_path, filename)
            clean_csv_file(filepath)

# Use the full Windows path here, with raw string notation
folder_path = r'C:\Users\sindh\Documents\Lego_Analysis\Data'

clean_all_csv_in_folder(folder_path)
