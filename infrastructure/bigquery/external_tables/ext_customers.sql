CREATE EXTERNAL TABLE `modern-data-stack-msp-uam-2026.bookstore_src.ext_customers`
WITH PARTITION COLUMNS (
  date DATE
)
OPTIONS(
  skip_leading_rows=1,
  format="CSV",
  hive_partition_uri_prefix="gs://modern-data-stack-msp-uam-2026-lab-workspace/data-lake/raw-data/customers/",
  uris=["gs://modern-data-stack-msp-uam-2026-lab-workspace/data-lake/raw-data/customers/*"]
);