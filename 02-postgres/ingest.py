import math
import click
import pandas as pd
from sqlalchemy import create_engine
from time import time
from tqdm import tqdm


@click.command()
@click.option(
    "--input-path",
    required=True,
    type=click.Path(exists=True),
    help="Path to input CSV file",
)
@click.option("--table-name", required=True, help="Target table name")
@click.option("--db-name", envvar="DB_NAME", required=True)
@click.option("--db-user", envvar="DB_USER", required=True)
@click.option("--db-pass", envvar="DB_PASS", required=True)
@click.option("--db-host", envvar="DB_HOST", default="localhost")
@click.option("--db-port", envvar="DB_PORT", default="5432")
@click.option(
    "--chunksize",
    default=100_000,
    show_default=True,
    help="Number of rows per batch insert",
)
def load_to_db(
    input_path,
    table_name,
    db_name,
    db_user,
    db_pass,
    db_host,
    db_port,
    chunksize,
):
    """
    Load large CSV file into PostgreSQL using chunked ingestion
    with a progress bar.
    """

    engine = create_engine(
        f"postgresql://{db_user}:{db_pass}@{db_host}:{db_port}/{db_name}"
    )

    click.echo("📊 Counting rows...")
    total_rows = sum(1 for _ in open(input_path)) - 1
    total_chunks = math.ceil(total_rows / chunksize)

    click.echo(f"Total rows: {total_rows}")
    click.echo(f"Total chunks: {total_chunks}")

    df_iter = pd.read_csv(
        input_path,
        iterator=True,
        chunksize=chunksize
    )

    with tqdm(
        total=total_chunks,
        desc="Loading CSV → Postgres",
        unit="chunk"
    ) as pbar:

        for chunk_no, df in enumerate(df_iter, start=1):
            t_start = time()

            df.tpep_pickup_datetime = pd.to_datetime(df.tpep_pickup_datetime)
            df.tpep_dropoff_datetime = pd.to_datetime(df.tpep_dropoff_datetime)

            df.to_sql(
                name=table_name,
                con=engine,
                if_exists="append",
                index=False
            )

            t_end = time()

            pbar.update(1)
            pbar.set_postfix({
                "chunk": chunk_no,
                "sec": f"{t_end - t_start:.2f}"
            })


if __name__ == "__main__":
    load_to_db()