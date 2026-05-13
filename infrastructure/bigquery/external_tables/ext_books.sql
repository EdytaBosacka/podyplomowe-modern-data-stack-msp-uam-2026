CREATE EXTERNAL TABLE `modern-data-stack-msp-uam-2026.bookstore_src.ext_books`
OPTIONS(
  format="PARQUET",
  uris=["gs://modern-data-stack-msp-uam-2026-lab-workspace/data-lake/raw-data/books/books.parquet"]
);