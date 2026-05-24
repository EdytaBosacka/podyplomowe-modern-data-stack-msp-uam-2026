from __future__ import annotations
import pendulum
import os
from airflow.models.dag import DAG
from airflow.operators.bash import BashOperator
from airflow.utils.dates import days_ago
from airflow.models import Variable

# --- Default Configuration ---
GENERATOR_SCRIPT_PATH = os.getenv('GENERATOR_SCRIPT_PATH', '/config/workspace/podyplomowe-modern-data-stack-msp-uam-2026/ingestion/bookstore-generator/generator.py')
LOCAL_STAGING_DIR = os.getenv('LOCAL_STAGING_DIR', '/config/workspace/podyplomowe-modern-data-stack-msp-uam-2026/staging/local-data-staging')
GCS_BUCKET_NAME = Variable.get("GCS_bucket_name")

# --- Templated Command Logic using Jinja ---
templated_date_nodash = "{{ ds_nodash }}" 
templated_date_dash = "{{ ds }}"       

gcs_transactions_target_path = f"gs://{GCS_BUCKET_NAME}/data-lake/raw-data/transactions_recurrent/date={templated_date_dash}/transactions-{templated_date_nodash}.json"

templated_transactions_output_file = f"{LOCAL_STAGING_DIR}/transactions-historical-{templated_date_nodash}.json"

historical_customers_input_pattern = f"{LOCAL_STAGING_DIR}/customers-*.csv"

templated_offset = "{{ ti.execution_date.strftime('%Y%m%d%H%M%S') }}"

upload_transactions_to_gcs_command = f"gsutil cp {templated_transactions_output_file} {gcs_transactions_target_path}"

generate_data_command = (
    f"python {GENERATOR_SCRIPT_PATH} --generate transactions "
    f"--transactions-offset {templated_offset} "
    f"--customers-input '{historical_customers_input_pattern}' " 
    f"--transactions-output {templated_transactions_output_file} "
    f"--books-input {os.path.join(os.path.dirname(GENERATOR_SCRIPT_PATH), 'books.csv')} "
    f"--start-date {templated_date_dash} "
    f"--end-date {templated_date_dash} " 
    f"--mode recurrent" 
)

with DAG(
    dag_id='historical_recurrent_transactions_generator',
    start_date=pendulum.datetime(2025, 1, 1), 
    schedule='@daily',  
    catchup=True,          
    max_active_runs=1,
    tags=['data-generation', 'dbt', 'recurrent', 'weekly'],
) as dag:

    check_books_file_exists_task = BashOperator(
        task_id='check_books_file_exists',
        bash_command=f"test -f {os.path.join(os.path.dirname(GENERATOR_SCRIPT_PATH), 'books.csv')} || (echo 'Error: books.csv not found!' && exit 1)",
    )

    generate_daily_data_task = BashOperator(
        task_id='generate_daily_data',
        bash_command=generate_data_command,
        doc_md=(
            "Reads all historical customer files locally and generates"
            "transactional histories for everyone up to current execution date."
        ),
    )

    verify_files_exist_task = BashOperator(
        task_id='verify_generated_files_exist',
        bash_command=(
            f"echo 'Verifying existence of generated files...' && "
            f"ls -l {templated_transactions_output_file} && "
            f"echo 'Generated files found.'"
        ),
    )

    upload_transactions_to_gcs_task = BashOperator(
        task_id='upload_transactions_to_gcs',
        bash_command=upload_transactions_to_gcs_command,
    )

check_books_file_exists_task >> generate_daily_data_task >> verify_files_exist_task >> upload_transactions_to_gcs_task