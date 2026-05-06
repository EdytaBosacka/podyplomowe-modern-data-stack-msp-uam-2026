from __future__ import annotations

import pendulum
import os

from airflow.models.dag import DAG
from airflow.operators.bash import BashOperator
from airflow.utils.dates import days_ago
from airflow.models import Variable

# --- Default Configuration ---
# Ścieżka do skryptu generatora
GENERATOR_SCRIPT_PATH = os.getenv('GENERATOR_SCRIPT_PATH', '/config/workspace/podyplomowe-modern-data-stack-msp-uam-2026/dbt/lab-dbt01/generator.py')
# Ścieżka do folderu wyjściowego dla dbt_bookstore_lab
DBT_BOOKSTORE_LAB_DIR = os.getenv('DBT_BOOKSTORE_LAB_DIR', '/config/workspace/dbt_bookstore_lab')
# Domyślna ścieżka do projektu dbt (używana przez dbt_dag_run)
DEFAULT_DBT_PROJECT_DIR = os.getenv('DBT_PROJECT_DIR', '/config/workspace/dbt_bookstore_lab/dbt_project')
GCS_BUCKET_NAME = Variable.get("GCS_bucket_name")


# --- Templated Command Logic using Jinja ---
# Data wykonania DAGa (execution_date) będzie używana do generowania danych dla konkretnego dnia
# Format daty dla nazw plików i parametrów skryptu
templated_date_nodash = "{{ ds_nodash }}" # YYYYMMDD
templated_date_dash = "{{ ds }}"       # YYYY-MM-DD


gcs_customers_target_path = f"gs://{GCS_BUCKET_NAME}/data-lake/raw-data/customers/date={templated_date_dash}/customers-{templated_date_nodash}.csv"
gcs_transactions_target_path = f"gs://{GCS_BUCKET_NAME}/data-lake/raw-data/transactions/date={templated_date_dash}/transactions-{templated_date_nodash}.json"


# Nazwy plików wyjściowych z datą
templated_customers_output_file = f"{DBT_BOOKSTORE_LAB_DIR}/customers-{templated_date_nodash}.csv"
templated_transactions_output_file = f"{DBT_BOOKSTORE_LAB_DIR}/transactions-{templated_date_nodash}.json"

# Offsety - można je uczynić bardziej dynamicznymi, np. na podstawie poprzednich uruchomień lub bazy danych
# Dla uproszczenia, użyjemy daty jako części offsetu, aby zapewnić unikalność (to proste podejście, w produkcji wymagałoby to lepszego zarządzania)
templated_offset = "{{ ti.execution_date.strftime('%Y%m%d%H%M%S') }}"


upload_customers_to_gcs_command = f"gsutil cp {templated_customers_output_file} {gcs_customers_target_path}"
upload_transactions_to_gcs_command = f"gsutil cp {templated_transactions_output_file} {gcs_transactions_target_path}"


# Budowanie komendy generatora
generate_data_command = (
    f"python {GENERATOR_SCRIPT_PATH} "
    f"--generate all "
    f"--customers-offset {templated_offset} " # Używamy dynamicznego offsetu
    f"--transactions-offset {templated_offset} " # Używamy dynamicznego offsetu
    f"--customers-output {templated_customers_output_file} "
    f"--transactions-output {templated_transactions_output_file} "
    f"--books-input {os.path.join(os.path.dirname(GENERATOR_SCRIPT_PATH), 'books.csv')} "
    f"--start-date {templated_date_dash} "
    f"--end-date {templated_date_dash}"
)


with DAG(
    dag_id='daily_data_generator',
    start_date=days_ago(1), # Uruchom od wczoraj
    schedule='@daily',      # Uruchamiaj codziennie o północy UTC
    catchup=False,          # Nie uruchamiaj dla przeszłych, nieuruchomionych interwałów
    max_active_runs=1,
    tags=['data-generation', 'dbt', 'daily'],
    description='Generates daily customer and transaction data and uploads to GCS.',
    default_args={
        'owner': 'airflow',
    },
) as dag:

    check_books_file_exists_task = BashOperator(
        task_id='check_books_file_exists',
        bash_command=f"test -f {os.path.join(os.path.dirname(GENERATOR_SCRIPT_PATH), 'books.csv')} || (echo 'Error: books.csv not found!' && exit 1)",
        doc_md="Verifies that the books.csv file exists before attempting to generate transaction data.",
    )

    generate_daily_data_task = BashOperator(
        task_id='generate_daily_data',
        bash_command=generate_data_command,
        doc_md=(
            "Generates new customer and transaction data for the DAG's execution date. "
            "Output files are named with the execution date (e.g., customers-YYYYMMDD.csv)."
        ),
    )

    verify_files_exist_task = BashOperator(
        task_id='verify_generated_files_exist',
        bash_command=(
            f"echo 'Verifying existence of generated files...' && "
            f"ls -l {templated_customers_output_file} && "
            f"ls -l {templated_transactions_output_file} && "
            f"echo 'Generated files found.'"
        ),
        doc_md=(
            "Verifies that the customer and transaction files for the execution date have been generated "
            "in the target directory. The task will fail if `ls` returns an error (e.g., file not found)."
        ),
    )

    upload_customers_to_gcs_task = BashOperator(
        task_id='upload_customers_to_gcs',
        bash_command=upload_customers_to_gcs_command,
    )

    upload_transactions_to_gcs_task = BashOperator(
        task_id='upload_transactions_to_gcs',
        bash_command=upload_transactions_to_gcs_command,
    )

check_books_file_exists_task >> generate_daily_data_task >> verify_files_exist_task >> [upload_customers_to_gcs_task, upload_transactions_to_gcs_task]

