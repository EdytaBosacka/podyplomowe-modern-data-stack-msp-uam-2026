import os
import shutil

import duckdb
import kagglehub
import pandas as pd
import ftfy

dataset_path = kagglehub.dataset_download("thedevastator/books-sales-and-ratings")
books_path = os.path.join(dataset_path, os.listdir(dataset_path)[0])
# shutil.copy(books_path, 'books.csv')

try:
    temp_df = pd.read_csv(books_path, encoding='ISO-8859-1')
    
    # --- Naprawa kodowania znaków ---
    for col in temp_df.select_dtypes(include="object").columns:
        temp_df[col] = temp_df[col].apply(lambda x: ftfy.fix_text(x) if isinstance(x, str) else x)

    # Zapisujemy jako UTF-8 – to naprawi plik 'books.csv' na dysku
    temp_df.to_csv('books.csv', index=False, encoding='utf-8')
    print("Plik books.csv został naprawiony i zapisany w UTF-8.")
    
    books_path = 'books.csv' 
except Exception as e:
    print(f"Błąd podczas konwersji pliku: {e}")
    exit()

# Create a DuckDB database
DB_PATH = "bookstore.ddb"
try:
    os.remove(DB_PATH)
except Exception:
    pass
con = duckdb.connect(database=DB_PATH, read_only=False)

# Read the CSV file into a pandas DataFrame
try:
    df = pd.read_csv(books_path)
except pd.errors.EmptyDataError:
    print(f"Error: The file at {books_path} is empty.")
    exit()
except FileNotFoundError:
    print(f"Error: The file at {books_path} was not found.")
    exit()
except Exception as e:
    print(f"An unexpected error occurred while reading the CSV file: {e}")
    exit()

# Create the 'books' table and insert the data from the DataFrame
try:
    con.execute("CREATE TABLE books AS SELECT * FROM df")
    print(f"Data successfully loaded into the 'books' table in '{DB_PATH}'.")
except Exception as e:
    print(f"An error occurred while creating the table or inserting data: {e}")

# Close the connection
con.close()
