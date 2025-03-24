import os
import pandas as pd

def read_csv(folder_path):
    # Dictionary to store DataFrames
    dataframes = {}
    
    # Normalize the path
    folder_path = os.path.normpath(folder_path)
    
    # Check if the directory exists
    if not os.path.exists(folder_path):
        raise FileNotFoundError(f"The directory does not exist: {folder_path}")
    
    # Iterate through all files in the folder
    for filename in os.listdir(folder_path):
        if filename.endswith('.csv'):
            file_path = os.path.join(folder_path, filename)
            
            try:
                # Read the CSV file into a pandas DataFrame
                df = pd.read_csv(file_path)
                
                # Store the DataFrame in the dictionary, using the filename as the key
                dataframes[filename] = df
            except Exception as e:
                print(f"Error reading file {filename}: {str(e)}")
    
    return dataframes