CREATE EXTERNAL TABLE `modern-data-stack-msp-uam-2026.bookstore_src.ext_transactions`
WITH PARTITION COLUMNS (
  date DATE
)
OPTIONS(
  format="JSON",
  hive_partition_uri_prefix="gs://modern-data-stack-msp-uam-2026-lab-workspace/data-lake/raw-data/transactions/",
  uris=["gs://modern-data-stack-msp-uam-2026-lab-workspace/data-lake/raw-data/transactions/*"]
);