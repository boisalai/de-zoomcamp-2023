# Data Engineering Zoomcamp 2023 Week 1: Introduction & Prerequisites

See [README.md](https://github.com/DataTalksClub/data-engineering-zoomcamp/blob/main/week_1_basics_n_setup/README.md) from week 1.

Table of contents

* Docker + Postgred
  * Introduction to Docker
  * Ingesting NY Taxi Data to Postgres
  * Connecting to Postgres with Jupyter and Pandas
  * Connecting pdAgmin and Postgres
  * Dockerizing the Ingestion Script
  * Running Postgres and pgAdmin with Docker-Compose 
  * SQL Refresher
  * Port Mapping and Networks in Docker (Bonus)
* GCP + Terraform
  * Introduction to GCP
  * Introduction to Terraform Concepts & GCP Pre-Requisites
  * Workshop: Creating GCP Infrastructure with Terraform
  * Setting up the environment on cloud VM
* See also

## Docker + Postgres

### Introduction to Docker

See [DE Zoomcamp 1.2.1 - Introduction to Docker](https://www.youtube.com/watch?v=EYNwNlOrpr0).

![Docker](dtc/docker.png).

Download, install and start [Docker Desktop](https://www.docker.com/products/docker-desktop/).

Try running a container by running: `$ docker run -d -p 80:80 docker/getting-started`.

Run also this command: `$ docker run hello-world`.

You should see this in your terminal.

``` bash
$ docker run hello-world

Hello from Docker!
This message shows that your installation appears to be working correctly.

To generate this message, Docker took the following steps:
 1. The Docker client contacted the Docker daemon.
 2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
    (arm64v8)
 3. The Docker daemon created a new container from that image which runs the
    executable that produces the output you are currently reading.
 4. The Docker daemon streamed that output to the Docker client, which sent it
    to your terminal.

To try something more ambitious, you can run an Ubuntu container with:
 $ docker run -it ubuntu bash

Share images, automate workflows, and more with a free Docker ID:
 https://hub.docker.com/

For more examples and ideas, visit:
 https://docs.docker.com/get-started/
```

Inside **Docker Desktop**, we should see two new containers. Dans le cas présent, nous avons le conteneur
**lucid_zhukovsky**.

![s34](dtc/s34.png)

To install Ubuntu, run this command:

``` bash
$ docker run -it ubuntu /bin/bash
root@a578cd2f0f16:/# ls
bin  boot  dev  etc  home  lib  media  mnt  opt  proc  root  run  sbin  srv  sys  tmp  usr  var
root@a578cd2f0f16:/#
```

![s02](dtc/s02.png)

To quit Ubuntu, enter `exit`.

To install Python 3.9 et open the Python shell, run the commande `$ docker run -it python:3.9`. But this way of doing
things is discouraged since the Python shell does not allow installing other libraries.

On propose plutôt cette commande: `$ docker run -it --entrypoint=bash python:3.9`. To quit Python shell: kbd:\[Ctrl+D\].

``` bash
$ docker run -it --entrypoint=bash python:3.9
root@5b81137975ca:/# pip install pandas
Collecting pandas
  Downloading pandas-1.5.2-cp39-cp39-manylinux_2_17_aarch64.manylinux2014_aarch64.whl (11.5 MB)
     ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 11.5/11.5 MB 27.9 MB/s eta 0:00:00
Collecting numpy>=1.20.3
  Downloading numpy-1.24.1-cp39-cp39-manylinux_2_17_aarch64.manylinux2014_aarch64.whl (14.0 MB)
     ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 14.0/14.0 MB 28.4 MB/s eta 0:00:00
Collecting python-dateutil>=2.8.1
  Downloading python_dateutil-2.8.2-py2.py3-none-any.whl (247 kB)
     ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 247.7/247.7 KB 25.5 MB/s eta 0:00:00
Collecting pytz>=2020.1
  Downloading pytz-2022.7-py2.py3-none-any.whl (499 kB)
     ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 499.4/499.4 KB 30.1 MB/s eta 0:00:00
Collecting six>=1.5
  Downloading six-1.16.0-py2.py3-none-any.whl (11 kB)
Installing collected packages: pytz, six, numpy, python-dateutil, pandas
Successfully installed numpy-1.24.1 pandas-1.5.2 python-dateutil-2.8.2 pytz-2022.7 six-1.16.0
WARNING: Running pip as the 'root' user can result in broken permissions and conflicting behaviour with the system package manager. It is recommended to use a virtual environment instead: https://pip.pypa.io/warnings/venv
WARNING: You are using pip version 22.0.4; however, version 22.3.1 is available.
You should consider upgrading via the '/usr/local/bin/python -m pip install --upgrade pip' command.
root@5b81137975ca:/# python
Python 3.9.16 (main, Dec 21 2022, 11:01:23)
[GCC 10.2.1 20210110] on linux
Type "help", "copyright", "credits" or "license" for more information.
>>> import pandas
>>> pandas.__version__
'1.5.2'
>>> # Ctrl-D to quit the Python shell.
root@5b81137975ca:/# exit
exit
$
```

But, a more efficient way to install Python with pandas already installed is with a `Dockerfile`.

<div class="formalpara-title">

**File `Dockerfile`**

</div>

``` txt
FROM python:3.9

RUN pip install pandas

ENTRYPOINT [ "bash" ]
```

Then, in the same directory as the `Dockerfile`, run the following two commands:

``` bash
$ docker build -t test:pandas .
$ docker run -it test:pandas
```

You should see something like this.

``` bash
$ docker build -t test:pandas .
[+] Building 7.1s (6/6) FINISHED
 => [internal] load build definition from Dockerfile                         0.0s
 => => transferring dockerfile: 104B                                         0.0s
 => [internal] load .dockerignore                                            0.0s
 => => transferring context: 2B                                              0.0s
 => [internal] load metadata for docker.io/library/python:3.9                0.0s
 => [1/2] FROM docker.io/library/python:3.9                                  0.0s
 => [2/2] RUN pip install pandas                                             6.6s
 => exporting to image                                                       0.4s
 => => exporting layers                                                      0.4s
 => => writing image sha256:993884641e93ffc311d83b206dab261ae435173767cd4dc  0.0s
 => => naming to docker.io/library/test:pandas                               0.0s

Use 'docker scan' to run Snyk tests against images to find vulnerabilities and learn how to fix them
$
$ docker run -it test:pandas
root@49850793ee99:/# python
Python 3.9.16 (main, Dec 21 2022, 11:01:23)
[GCC 10.2.1 20210110] on linux
Type "help", "copyright", "credits" or "license" for more information.
>>> import pandas
>>> pandas.__version__
'1.5.2'
>>> # Ctrl-D to quit the Python shell
root@49850793ee99:/# exit
exit
$
```

Now let’s create in the same directory a `pipeline.py` file with the following instructions:

<div class="formalpara-title">

**File `pipeline.py`**

</div>

``` python
import pandas as pd

# some fancy stuff with pandas
print('job finished successfully')
```

Let’s add instructions to the `Dockerfile` file.

<div class="formalpara-title">

**File `Dockerfile`**

</div>

``` txt
FROM python:3.9

RUN pip install pandas

WORKDIR /app
COPY pipeline.py pipeline.py

ENTRYPOINT [ "bash" ]
```

Then, let’s run the same two commands `build` and `run`:

``` bash
$ docker build -t test:pandas .
[+] Building 0.1s (9/9) FINISHED
 => [internal] load build definition from Dockerfile                         0.0s
 => => transferring dockerfile: 148B                                         0.0s
 => [internal] load .dockerignore                                            0.0s
 => => transferring context: 2B                                              0.0s
 => [internal] load metadata for docker.io/library/python:3.9                0.0s
 => [internal] load build context                                            0.0s
 => => transferring context: 125B                                            0.0s
 => [1/4] FROM docker.io/library/python:3.9                                  0.0s
 => CACHED [2/4] RUN pip install pandas                                      0.0s
 => [3/4] WORKDIR /app                                                       0.0s
 => [4/4] COPY pipeline.py pipeline.py                                       0.0s
 => exporting to image                                                       0.0s
 => => exporting layers                                                      0.0s
 => => writing image sha256:fe068e33f64738d77647616eec203b4e17a02e07d7ed247  0.0s
 => => naming to docker.io/library/test:pandas                               0.0s

Use 'docker scan' to run Snyk tests against images to find vulnerabilities and learn how to fix them
$
$ docker run -it test:pandas
root@740f1eedbd03:/app# pwd
/app
root@740f1eedbd03:/app# ls
pipeline.py
root@740f1eedbd03:/app# python pipeline.py
job finished successfully
root@740f1eedbd03:/app# exit
$
```

Now let’s add instructions to the `pipeline.py` file.

<div class="formalpara-title">

**File `pipeline.py`**

</div>

``` python
import sys
import pandas as pd

print(sys.argv)
day = sys.argv[1]

print(f'job finished successfully for day = f{day}')
```

Next, let’s modify the `Dockerfile`.

<div class="formalpara-title">

**File `Dockerfile`**

</div>

``` txt
FROM python:3.9

RUN pip install pandas

WORKDIR /app
COPY pipeline.py pipeline.py

ENTRYPOINT [ "python", "pipeline.py" ]
```

Then, let’s restart the `build` and the `run`.

``` bash
$ docker build -t test:pandas .
$ docker run -it test:pandas 2021-10-15
['pipeline.py', '2021-10-15']
job finished successfully for day = f2021-10-15
$
```

<div class="note">

**Reminder about Docker CLI**

The `docker ps` command only shows running containers by default. To see all containers, use the `-a` (or `--all`) flag.

See [docker ps](https://docs.docker.com/engine/reference/commandline/ps/).

To stop one or more running containers:

``` bash
$ docker stop [OPTIONS] CONTAINER [CONTAINER...]
```

See [docker stop](https://docs.docker.com/engine/reference/commandline/stop/).

</div>

### Ingesting NY Taxi Data to Postgres

See [DE Zoomcamp 1.2.2 - Ingesting NY Taxi Data to Postgres](https://www.youtube.com/watch?v=2JM-ziJt0WI).

We will install a docker image with Postgres. To do this, we will take inspiration from lines 82 to 95 of the file
[docker-compose.yaml](https://github.com/DataTalksClub/data-engineering-zoomcamp/blob/main/week_2_data_ingestion/airflow/docker-compose.yaml).

Clone the GitHub repository with this command:

``` bash
$ git clone https://github.com/DataTalksClub/data-engineering-zoomcamp.git
$ cd data-engineering-zoomcamp
$ cd week_1_basics_n_setup
$ cd 2_docker_sql
```

We will use a docker image of postgres. See [postgres](https://hub.docker.com/_/postgres) on DockerHub for more
information.

To start a postgres instance, run this command:

``` bash
$ mkdir ny_taxi_postgres_data
$ docker run -it \
  -e POSTGRES_USER="root" \
  -e POSTGRES_PASSWORD="root" \
  -e POSTGRES_DB="ny_taxi" \
  -v $(pwd)/ny_taxi_postgres_data:/var/lib/postgresql/data \
  -p 5432:5432 \
  postgres:13
```

You should see in the terminal `database system is ready to accept connections`.

Next, open an other terminal window, and install [pgcli](https://www.pgcli.com/). The password for root is `root`.

Note that I’m using macOS. If you are using Windows, you can run the `$ pip install pgcli` command.

``` bash
$ brew install pgcli
$ pgcli --help
$ pgcli -h localhost -p 5432 -u root -d ny_taxi
Password for root:
Server: PostgreSQL 13.9 (Debian 13.9-1.pgdg110+1)
Version: 3.5.0
Home: http://pgcli.com
root@localhost:ny_taxi> \dt
+--------+------+------+-------+
| Schema | Name | Type | Owner |
|--------+------+------+-------|
+--------+------+------+-------+
SELECT 0
Time: 0.032s
root@localhost:ny_taxi> SELECT 1;
+----------+
| ?column? |
|----------|
| 1        |
+----------+
SELECT 1
Time: 0.006s
root@localhost:ny_taxi>
```

![s03](dtc/s03.png)

Now, install the classic Jupyter Notebook with:

``` bash
pip install notebook
```

See [Install Jupyter](https://jupyter.org/install.html) for more information.

To run the notebook:

``` bash
jupyter notebook
```

Choose the `Python 3 (ipykernel)`.

We will use the data from [TLC Trip Record Data](https://www.nyc.gov/site/tlc/about/tlc-trip-record-data.page),
especially data on :

- <https://d37ci6vzurychx.cloudfront.net/trip-data/yellow_tripdata_2021-01.parquet> for Yellow Taxi Trip Records
  (PARQUET) for January 2021.

- <https://d37ci6vzurychx.cloudfront.net/misc/taxi+_zone_lookup.csv> for Taxi Zone Loopup Table (CSV).

- But it’s better to use data from this repository: <https://github.com/DataTalksClub/nyc-tlc-data>.

So in jupyter add the following statements:

``` python
import pandas as pd
pd.__version__
# 1.5.1

# Method 1 with parquet file.
!wget https://d37ci6vzurychx.cloudfront.net/trip-data/yellow_tripdata_2021-01.parquet
!pip install pyarrow

df = pd.read_parquet('yellow_tripdata_2021-01.parquet')
df.to_csv('yellow_tripdata_2021-01.csv')
df.head(100).to_csv("yellow_head.csv")

# Method 2 with csv.gz file.
!wget https://github.com/DataTalksClub/nyc-tlc-data/releases/download/yellow/yellow_tripdata_2021-01.csv.gz

df = pd.read_csv('yellow_tripdata_2021-01.csv.gz', compression='gzip', header=0, sep=',', quotechar='"')
df.to_csv('yellow_tripdata_2021-01.csv')
df.head(100).to_csv("yellow_head.csv")

# Find out number of lines.
!wc -l yellow_tripdata_2021-01.csv
""" 1369766 yellow_tripdata_2021-01.csv """
!wc -l yellow_head.csv
""" 101 yellow_head.csv """

df.info(verbose=True, show_counts=True)
"""
<class 'pandas.core.frame.DataFrame'>
RangeIndex: 1369765 entries, 0 to 1369764
Data columns (total 18 columns):
 #   Column                 Non-Null Count    Dtype
---  ------                 --------------    -----
 0   VendorID               1271413 non-null  float64
 1   tpep_pickup_datetime   1369765 non-null  object
 2   tpep_dropoff_datetime  1369765 non-null  object
 3   passenger_count        1271413 non-null  float64
 4   trip_distance          1369765 non-null  float64
 5   RatecodeID             1271413 non-null  float64
 6   store_and_fwd_flag     1271413 non-null  object
 7   PULocationID           1369765 non-null  int64
 8   DOLocationID           1369765 non-null  int64
 9   payment_type           1271413 non-null  float64
 10  fare_amount            1369765 non-null  float64
 11  extra                  1369765 non-null  float64
 12  mta_tax                1369765 non-null  float64
 13  tip_amount             1369765 non-null  float64
 14  tolls_amount           1369765 non-null  float64
 15  improvement_surcharge  1369765 non-null  float64
 16  total_amount           1369765 non-null  float64
 17  congestion_surcharge   1369765 non-null  float64
dtypes: float64(13), int64(2), object(3)
memory usage: 188.1+ MB
"""
```

The structure of these files is described in le [data
dictionary](https://www.nyc.gov/assets/tlc/downloads/pdf/data_dictionary_trip_records_yellow.pdf).

The "taxi zones" are presented in the file [Taxi Zone Lookup
Table](https://d37ci6vzurychx.cloudfront.net/misc/taxi+_zone_lookup.csv).

``` python
print(df.head())
"""
   VendorID tpep_pickup_datetime tpep_dropoff_datetime  passenger_count  \
0       1.0  2021-01-01 00:30:10   2021-01-01 00:36:12              1.0
1       1.0  2021-01-01 00:51:20   2021-01-01 00:52:19              1.0
2       1.0  2021-01-01 00:43:30   2021-01-01 01:11:06              1.0
3       1.0  2021-01-01 00:15:48   2021-01-01 00:31:01              0.0
4       2.0  2021-01-01 00:31:49   2021-01-01 00:48:21              1.0

   trip_distance  RatecodeID store_and_fwd_flag  PULocationID  DOLocationID  \
0           2.10         1.0                  N           142            43
1           0.20         1.0                  N           238           151
2          14.70         1.0                  N           132           165
3          10.60         1.0                  N           138           132
4           4.94         1.0                  N            68            33

   payment_type  fare_amount  extra  mta_tax  tip_amount  tolls_amount  \
0           2.0          8.0    3.0      0.5        0.00           0.0
1           2.0          3.0    0.5      0.5        0.00           0.0
2           1.0         42.0    0.5      0.5        8.65           0.0
3           1.0         29.0    0.5      0.5        6.05           0.0
4           1.0         16.5    0.5      0.5        4.06           0.0

   improvement_surcharge  total_amount  congestion_surcharge
0                    0.3         11.80                   2.5
1                    0.3          4.30                   0.0
2                    0.3         51.95                   0.0
3                    0.3         36.35                   0.0
4                    0.3         24.36                   2.5
"""
```

We must convert the "date" fields to "timestamp" in the following way.

``` python
df = pd.read_csv("yellow_head.csv")
df.tpep_pickup_datetime = pd.to_datetime(df.tpep_pickup_datetime)
df.tpep_dropoff_datetime = pd.to_datetime(df.tpep_dropoff_datetime)
```

We get the SQL schema like this:

``` python
print(pd.io.sql.get_schema(df, name="yellow_taxi_data"))
"""
CREATE TABLE "yellow_taxi_data" (
"Unnamed: 0" INTEGER,
  "VendorID" REAL,
  "tpep_pickup_datetime" TIMESTAMP,
  "tpep_dropoff_datetime" TIMESTAMP,
  "passenger_count" REAL,
  "trip_distance" REAL,
  "RatecodeID" REAL,
  "store_and_fwd_flag" TEXT,
  "PULocationID" INTEGER,
  "DOLocationID" INTEGER,
  "payment_type" REAL,
  "fare_amount" REAL,
  "extra" REAL,
  "mta_tax" REAL,
  "tip_amount" REAL,
  "tolls_amount" REAL,
  "improvement_surcharge" REAL,
  "total_amount" REAL,
  "congestion_surcharge" REAL
)
"""
```

Il est maintenant temps de charger les données dans postgres.

We will use [SQLALchemy](https://www.sqlalchemy.org/). This tool is normally already installed with anaconda. But if you
don’t have anaconda installed, just run the command `$ pip install sqlalchemy`.

In my case I also had to install [psycopg2-binary](https://pypi.org/project/psycopg2-binary/).

``` python
from sqlalchemy import create_engine
!pip install psycopg2-binary

engine = create_engine('postgresql://root:root@localhost:5432/ny_taxi')
engine.connect()
""" <sqlalchemy.engine.base.Connection at 0x11b58bd90> """

print(pd.io.sql.get_schema(df, name="yellow_taxi_data", con=engine))
"""
CREATE TABLE yellow_taxi_data (
    "Unnamed: 0" BIGINT,
    "VendorID" FLOAT(53),
    tpep_pickup_datetime TIMESTAMP WITHOUT TIME ZONE,
    tpep_dropoff_datetime TIMESTAMP WITHOUT TIME ZONE,
    passenger_count FLOAT(53),
    trip_distance FLOAT(53),
    "RatecodeID" FLOAT(53),
    store_and_fwd_flag TEXT,
    "PULocationID" BIGINT,
    "DOLocationID" BIGINT,
    payment_type FLOAT(53),
    fare_amount FLOAT(53),
    extra FLOAT(53),
    mta_tax FLOAT(53),
    tip_amount FLOAT(53),
    tolls_amount FLOAT(53),
    improvement_surcharge FLOAT(53),
    total_amount FLOAT(53),
    congestion_surcharge FLOAT(53)
)
"""
```

But to load all rather large data, it would be better to partition it.

``` python
df_iter = pd.read_csv('yellow_tripdata_2021-01.csv', iterator=True, chunksize=100000)
df.tpep_pickup_datetime = pd.to_datetime(df.tpep_pickup_datetime)
df.tpep_dropoff_datetime = pd.to_datetime(df.tpep_dropoff_datetime)

df = next(df_iter)
len(df)
# 100000
```

To create the table in postgres:

``` python
df.head(0).to_sql(name='yellow_taxi_data', con=engine, if_exists='replace')
```

We check if the table has actually been created in postgres.

``` bash
$ pgcli -h localhost -p 5432 -u root -d ny_taxi
Password for root:
Server: PostgreSQL 13.9 (Debian 13.9-1.pgdg110+1)
Version: 3.5.0
Home: http://pgcli.com
root@localhost:ny_taxi> \dt
+--------+------------------+-------+-------+
| Schema | Name             | Type  | Owner |
|--------+------------------+-------+-------|
| public | yellow_taxi_data | table | root  |
+--------+------------------+-------+-------+
SELECT 1
Time: 0.032s
root@localhost:ny_taxi> \d yellow_taxi_data

+-----------------------+-----------------------------+-----------+
| Column                | Type                        | Modifiers |
|-----------------------+-----------------------------+-----------|
| index                 | bigint                      |           |
| VendorID              | bigint                      |           |
| tpep_pickup_datetime  | timestamp without time zone |           |
| tpep_dropoff_datetime | timestamp without time zone |           |
| passenger_count       | double precision            |           |
| trip_distance         | double precision            |           |
| RatecodeID            | double precision            |           |
| store_and_fwd_flag    | text                        |           |
| PULocationID          | bigint                      |           |
| DOLocationID          | bigint                      |           |
| payment_type          | bigint                      |           |
| fare_amount           | double precision            |           |
| extra                 | double precision            |           |
| mta_tax               | double precision            |           |
| tip_amount            | double precision            |           |
| tolls_amount          | double precision            |           |
| improvement_surcharge | double precision            |           |
| total_amount          | double precision            |           |
| congestion_surcharge  | double precision            |           |
| airport_fee           | double precision            |           |
+-----------------------+-----------------------------+-----------+
Indexes:
    "ix_yellow_taxi_data_index" btree (index)
```

To load all data, do this:

``` python
%time df.to_sql(name='yellow_taxi_data', con=engine, if_exists='append')
# CPU times: user 3.22 s, sys: 82.7 ms, total: 3.3 s
# Wall time: 8.38 s
#1000
```

Pour vérifier s’il existe la table **yellow_taxi_data** contient toutes les données, faire ceci:

``` bash
root@localhost:ny_taxi> SELECT count(1) FROM yellow_taxi_data;
+--------+
| count  |
|--------|
| 100000 |
+--------+
SELECT 1
Time: 0.045s
root@localhost:ny_taxi>
```

![s04](dtc/s04.png)

To load all chunk data into the database, do this:

``` python
from time import time

while True:
    t_start = time()
    df = next(df_iter)

    df.tpep_pickup_datetime = pd.to_datetime(df.tpep_pickup_datetime)
    df.tpep_dropoff_datetime = pd.to_datetime(df.tpep_dropoff_datetime)

    df.to_sql(name='yellow_taxi_data', con=engine, if_exists='append')

    t_end = time()

    print('insert another chunk..., took %.3f second' % (t_end - t_start))
"""
insert another chunk..., took 8.471 second
insert another chunk..., took 8.174 second
insert another chunk..., took 8.810 second
insert another chunk..., took 8.161 second
insert another chunk..., took 8.078 second
insert another chunk..., took 7.997 second
insert another chunk..., took 8.394 second
insert another chunk..., took 9.329 second
insert another chunk..., took 9.535 second
insert another chunk..., took 9.294 second
insert another chunk..., took 8.557 second
/var/folders/d_/71qkpq1n5zn9lq_6v8j8hgkr0000gn/T/ipykernel_20284/387323172.py:5: DtypeWarning: Columns (7) have mixed types. Specify dtype option on import or set low_memory=False.
  df = next(df_iter)
insert another chunk..., took 8.277 second
insert another chunk..., took 5.024 second
"""
```

It seems that I have an error.

Let’s check the number of rows in the postgres database.

``` bash
root@localhost:ny_taxi> SELECT count(1) FROM yellow_taxi_data;
+---------+
| count   |
|---------|
| 1369765 |
+---------+
SELECT 1
Time: 0.472s
root@localhost:ny_taxi>
```

I have 1369765 rows in the database while the source file contains 1369766. So I am missing one row.

### Connecting to Postgres with Jupyter and Pandas

See also [DE Zoomcamp 1.2.2 - Optional: Connecting to Postgres with Jupyter and Pandas](https://www.youtube.com/watch)
on Youtube.

We present here an alternative to using **pgcli**.

``` python
import pandas as pd

!pip install sqlalchemy psycopg2-binary

from sqlalchemy import create_engine

engine = create_engine('postgresql://root:root@localhost:5432/ny_taxi')
engine.connect()

query = """
SELECT 1 as number;
"""

pd.read_sql(query, con=engine)

# Au lieu de la commande \dt.
query = """
SELECT *
FROM pg_catalog.pg_tables
WHERE schemaname != 'pg_catalog' AND
    schemaname != 'information_schema';
"""

pd.read_sql(query, con=engine)

df = pd.read_parquet('yellow_tripdata_2021-01.parquet', nrows=100)

df.tpep_pickup_datetime = pd.to_datetime(df.tpep_pickup_datetime)
df.tpep_dropoff_datetime = pd.to_datetime(df.tpep_dropoff_datetime)

df.to_sql(name='yellow_tripdata_trip', con-engine, index=False)

query = """
SELECT * FROM yellow_tripdata_trip LIMIT 100;
"""

pd.read_sql(query, con=engine)
```

Source: [PostgreSQL Show Tables](https://www.postgresqltutorial.com/postgresql-show-tables/).

### Connecting pgAdmin and Postgres

> 2023-01-19.

See [DE Zoomcamp 1.2.3 - Connecting pgAdmin and Postgres](https://www.youtube.com/watch?v=hCAIVe9N0ow) on Youtube.

You can scan the data that has been loaded into the database.

``` bash
root@localhost:ny_taxi> SELECT max(tpep_pickup_datetime),
    min(tpep_pickup_datetime), max(total_amount) FROM yellow_taxi_data;
+---------------------+---------------------+---------+
| max                 | min                 | max     |
|---------------------+---------------------+---------|
| 2021-02-22 16:52:16 | 2008-12-31 23:05:14 | 7661.28 |
+---------------------+---------------------+---------+
SELECT 1
Time: 1.549s (1 second), executed in: 1.544s (1 second)
root@localhost:ny_taxi>
```

[pgAdmin](https://www.pgadmin.org/) is easier to use than **pgcli**.

Since we already have Docker, we don’t need to install pgAdmin. We only need to use a docker image from pgAdmin.

Go to [pgAdmin 4 (Container)](https://www.pgadmin.org/download/pgadmin-4-container/), or directly to
[pgadmin4](https://www.pgadmin.org/download/pgadmin-4-container/) on DockerHub.

Here is the command to run pgAdmin in Docker.

``` bash
$ docker run -it \
  -e PGADMIN_DEFAULT_EMAIL="admin@admin.com" \
  -e PGADMIN_DEFAULT_PASSWORD="root" \
  -p 8080:80 \
  dpage/pgadmin4
```

Then open the browser to <http://localhost:8080/> and you should see this.

![s05](dtc/s05.png)

Enter username `admin@admin.com` and password `root`, and you should see this.

![s06](dtc/s06.png)

We must then create a server. Click on **Add New Server** and identify the postgres instance located in another
container.

But this will not work since we must ensure that the two containers can communicate with each other. To do this, we will
use **docker network**.

Stop both containers (postgres and pgAdmin) with kbd:\[Ctrl+C\] and go to [docker network
create](https://docs.docker.com/engine/reference/commandline/network_create/).

In a new terminal window, run this command to create a new network:

``` bash
$ docker network create pg-network
$ docker run -it \
  -e POSTGRES_USER="root" \
  -e POSTGRES_PASSWORD="root" \
  -e POSTGRES_DB="ny_taxi" \
  -v $(pwd)/ny_taxi_postgres_data:/var/lib/postgresql/data \
  -p 5432:5432 \
  --network=pg-network \
  --name pg-database \
  postgres:13
```

With pgcli, we can check if our connection is still working and that the data is still present.

``` txt
root@localhost:ny_taxi> SELECT COUNT(1) FROM yellow_taxi_data;
Reconnecting...
Reconnected!
+---------+
| count   |
|---------|
| 1369765 |
+---------+
SELECT 1
Time: 0.305s
root@localhost:ny_taxi>
```

Then run the following command in another terminal window.

``` bash
$ docker run -it \
  -e PGADMIN_DEFAULT_EMAIL="admin@admin.com" \
  -e PGADMIN_DEFAULT_PASSWORD="root" \
  -p 8080:80 \
  --network=pg-network \
  --name pgadmin-2 \
  dpage/pgadmin4
```

Then go to <http://localhost:8080/> again, enter username `admin@admin.com` and password `root`.

Then create a server. Click on **Add New Server**, enter the information as below (still with username `admin@admin.com`
and password `root`), then click the **Save** button.

|                     |                     |
|---------------------|---------------------|
| ![s07](dtc/s07.png) | ![s08](dtc/s08.png) |

In the left menu, click successively on **Server**, **Local Docker**, **Database**, **ny_taxi**, **Schemas**,
**public**, **Tables**, **yellow_taxi_data**. After, right-click and select **View/Edit Data** and **First 100 Rows**.

We should see this after asking to display the first 100 rows of the **yellow_taxi_data** table.

![s09](dtc/s09.png)

Enter this query `SELECT COUNT(1) FROM yellow_daxi_data;`.

![s10](dtc/s10.png)

### Dockerizing the Ingestion Script

> 2023-01-20.

See [DE Zoomcamp 1.2.4 - Dockerizing the Ingestion
Script](https://www.youtube.com/watch?v=B1WwATwf-vY&list=PL3MmuxUbc_hJed7dXYoJw8DoCuVHhGEQb&index=8) on Youtube.

Let’s convert our jupyter notebook to a Python script:

``` bash
$ jupyter nbconvert --to=script upload-data.ipynb
# [NbConvertApp] Converting notebook upload-data.ipynb to script
# [NbConvertApp] Writing 1949 bytes to upload-data.py
```

Then let’s clean it up and adjust the code to have a clean script like this.

See
[ingest_data.py](https://github.com/DataTalksClub/data-engineering-zoomcamp/blob/main/week_1_basics_n_setup/2_docker_sql/ingest_data.py).

Note that we will use [argparse](https://docs.python.org/3/library/argparse.html).

<div class="formalpara-title">

**File `ingest_data.py`**

</div>

``` python
#!/usr/bin/env python
# coding: utf-8

import os
import argparse

from time import time

import pandas as pd
from sqlalchemy import create_engine


def main(params):
    user = params.user
    password = params.password
    host = params.host
    port = params.port
    db = params.db
    table_name = params.table_name
    url = params.url

    # the backup files are gzipped, and it's important to keep the correct extension
    # for pandas to be able to open the file
    if url.endswith('.csv.gz'):
        file_name = 'output.csv.gz'
    elif url.endswith('.parquet'):
        file_name = 'output.parquet'
    else:
        file_name = 'output.csv'

    os.system(f"wget {url} -O {file_name}")

    engine = create_engine(f'postgresql://{user}:{password}@{host}:{port}/{db}')

    if url.endswith('.parquet'):
        df = pd.read_parquet(file_name)
        file_name = 'output.csv.gz'
        df.to_csv(file_name, index=False, compression="gzip")

    df_iter = pd.read_csv(file_name, iterator=True, chunksize=100000)

    df = next(df_iter)

    df.tpep_pickup_datetime = pd.to_datetime(df.tpep_pickup_datetime)
    df.tpep_dropoff_datetime = pd.to_datetime(df.tpep_dropoff_datetime)

    df.head(n=0).to_sql(name=table_name, con=engine, if_exists='replace')

    df.to_sql(name=table_name, con=engine, if_exists='append')


    while True:

        try:
            t_start = time()

            df = next(df_iter)

            df.tpep_pickup_datetime = pd.to_datetime(df.tpep_pickup_datetime)
            df.tpep_dropoff_datetime = pd.to_datetime(df.tpep_dropoff_datetime)

            df.to_sql(name=table_name, con=engine, if_exists='append')

            t_end = time()

            print('inserted another chunk, took %.3f second' % (t_end - t_start))

        except StopIteration:
            print("Finished ingesting data into the postgres database")
            break

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Ingest CSV data to Postgres')

    parser.add_argument('--user', required=True, help='user name for postgres')
    parser.add_argument('--password', required=True, help='password for postgres')
    parser.add_argument('--host', required=True, help='host for postgres')
    parser.add_argument('--port', required=True, help='port for postgres')
    parser.add_argument('--db', required=True, help='database name for postgres')
    parser.add_argument('--table_name', required=True, help='name of the table where we will write the results to')
    parser.add_argument('--url', required=True, help='url of the csv file')

    args = parser.parse_args()

    main(args)
```

Avant run this script, we need to drop **yellow_taxi_data** table with pgAdmin with this SQL:

``` sql
DROP TABLE yellow_taxi_data;
-- Query returned successfully in 101 msec.
SELECT COUNT(1) FROM yellow_taxi_data;
-- ERROR:  relation "yellow_taxi_data" does not exist
-- LINE 2: SELECT COUNT(1) FROM yellow_taxi_data;
--                              ^
-- SQL state: 42P01
-- Character: 54
```

Now, we could run this script `ingest_data.py`:

``` bash
# URL="https://d37ci6vzurychx.cloudfront.net/trip-data/yellow_tripdata_2021-01.parquet"
$ URL="https://github.com/DataTalksClub/nyc-tlc-data/releases/download/yellow/yellow_tripdata_2021-01.csv.gz"
$ python3 ingest_data.py \
    --user=root \
    --password=root \
    --host=localhost \
    --port=5432 \
    --db=ny_taxi \
    --table_name=yellow_taxi_trips \
    --url=${URL}
```

Providing the password directly in a command is not secure since it can be found in particular with the `history`
command. But, for now, let’s continue with the simpler way.

When the execution is finished, one can check in pgAdmin if the table is complete.

``` sql
SELECT COUNT(1) FROM yellow_taxi_trips;
-- 1369765
```

Now, we will dockerize this ingestion script.

We need to destroy the table in Postgres and adjust the `Dockerfile`.

``` sql
DROP TABLE yellow_taxi_trips;
-- Query returned successfully in 117 msec.
```

<div class="formalpara-title">

**File `Dockerfile`**

</div>

``` txt
FROM python:3.9

RUN apt-get install wget
RUN pip install pandas sqlalchemy psycopg2

WORKDIR /app
COPY ingest_data.py ingest_data.py

ENTRYPOINT [ "python", "ingest_data.py" ]
```

Then, we execute the following command:

``` bash
$ docker build -t taxi_ingest:v001 .
```

You should see this in your terminal.

![s11](dtc/s11.png)

Then, we execute the following command:

``` bash
$ URL="https://github.com/DataTalksClub/nyc-tlc-data/releases/download/yellow/yellow_tripdata_2021-01.csv.gz"
$ docker run -it \
    --network=pg-network \ 
    taxi_ingest:v001 \
      --user=root \
      --password=root \
      --host=pg-database \ 
      --port=5432 \
      --db=ny_taxi \
      --table_name=yellow_taxi_trips \
      --url=${URL}
```

- We should run this thing in the network, and not on the localhost.

- Who need also to use `pd-database`.

![s12](dtc/s12.png)

On peut lancer cette requête SQL dans pgAdmin pour vérifier si la table est complète.

``` sql
SELECT COUNT(1) FROM yellow_taxi_trips;
-- 1369765
```

<div class="note">

Remember that we list the containers with the command `docker ps` and stop containers with the command
`docker kill <CONTAINER_ID>`.

</div>

<div class="note">

**15:15 HTTP server + ipconfig**  
We also mention the possibility of creating your own http server with the commands `python3 -m http.server` and
`ifconfig` (`ipconfig` on windows) then change the URL to search for the source file on our own machine.

</div>

### Running Postgres and pgAdmin with Docker-Compose

> 2023-01-20.

See [DE Zoomcamp 1.2.5 - Running Postgres and pgAdmin with Docker-Compose](https://www.youtube.com/watch?v=hKI6PkPhpa0)
on Youtube.

#### 01:04 Introduction to Docker-Compose

So far we have run several commands to create docker instances, load data, etc. We’re gonna make it all simple using
[docker compose](https://docs.docker.com/compose/).

Compose is a tool for defining and running multi-container Docker applications. With Compose, you use a YAML file to
configure your application’s services. Then, with a single command, you create and start all the services from your
configuration.

#### 01:22 Installing Docker-Compose

Normally, Docker compose is already installed since it is included in Docker Desktop.

#### 01:56 Configuration of postgres database and pgadmin in Docker-Compose file

With Docker compose, the images will be installed automatically in the same network.

See
[docker-compose.yaml](https://github.com/DataTalksClub/data-engineering-zoomcamp/blob/main/week_1_basics_n_setup/2_docker_sql/docker-compose.yaml).

<div class="formalpara-title">

**File `docker-compose.yaml`**

</div>

``` yaml
services:
  pgdatabase:
    image: postgres:13
    environment:
      - POSTGRES_USER=root
      - POSTGRES_PASSWORD=root
      - POSTGRES_DB=ny_taxi
    volumes:
      - "./ny_taxi_postgres_data:/var/lib/postgresql/data:rw"
    ports:
      - "5432:5432"
  pgadmin:
    image: dpage/pgadmin4
    environment:
      - PGADMIN_DEFAULT_EMAIL=admin@admin.com
      - PGADMIN_DEFAULT_PASSWORD=root
    ports:
      - "8080:80"
```

#### 05:51 Running the Docker-Compose file

we need to stop the current running containers **pgadmin** et **postgres**.

![s13](dtc/s13.png)

Then run this command:

``` bash
$ docker-compose up
```

Then go to <http://localhost:8080/> again, enter username `admin@admin.com` and password `root`.

Then create a server. Click **Add New Server**, enter the following information, then click the **Save** button.

- Tab **General**

  - Name: `Local Docker`

- Tab **Connection**

  - Host name: `pgdatabase`

  - Port: `5432`

  - Username: `root`

  - Password: `root`

Let’s check if the database table is correct.

![s35](dtc/s35.png)

#### 07:34 Stopping the running containers with Docker-Compose

To stop this running docker compose, just do kbd:\[Ctrl+C\] and run the command `$ docker-compose down`.

#### 07:50 Running Docker-Compose in detached mode

You can restart in detached mode, with the command `$ docker-compose up -d`. This way allows us to find the terminal
window and you don’t need to open a new window.

To stop a running container in detached mode, we can use the same command `$ docker-compose down`.

### SQL Refresher

> 2023-01-20.

See [DE Zoomcamp 1.2.6 - SQL Refreshser](https://www.youtube.com/watch?v=QEcps_iskgg).

We refer to the file located here [Taxi Zone Lookup
Table](https://d37ci6vzurychx.cloudfront.net/misc/taxi+_zone_lookup.csv) that I must load in postgres in a table called
**zones**.

We need to restart in detached mode, with the command `$ docker-compose up -d`.

After that, here bellow the python code I am running in jupyter notebook.

``` python
import pandas as pd
from sqlalchemy import create_engine

!pip install psycopg2-binary # I can't remember if this tool is required.

engine = create_engine('postgresql://root:root@localhost:5432/ny_taxi')
# engine.connect()

df = pd.read_csv('https://d37ci6vzurychx.cloudfront.net/misc/taxi+_zone_lookup.csv')
# df.head()

df.to_sql(name='zones', con=engine, if_exists='replace')
# Requirement already satisfied: psycopg2-binary in /opt/homebrew/lib/python3.10/site-packages (2.9.5)
# 265
```

Let’s check in pgAdmin if the **zones** table is loaded.

![s36](dtc/s36.png)

Then I run the code below in pgAdmin to cross the tables.

``` sql
SELECT
  tpep_pickup_datetime,
  tpep_dropoff_datetime,
  total_amount,
  CONCAT(zpu."Borough", ' / ', zpu."Zone") AS "pickup_loc",
  CONCAT(zdo."Borough", ' / ', zdo."Zone") AS "dropoff_loc"
FROM
  yellow_taxi_trips t,
  zones zpu,
  zones zdo
WHERE
  t."PULocationID" = zpu."LocationID" AND
  t."DOLocationID" = zdo."LocationID"
LIMIT 100;
```

![s14](dtc/s14.png)

We could rewrite the SQL query like this:

``` sql
SELECT
  tpep_pickup_datetime,
  tpep_dropoff_datetime,
  total_amount,
  CONCAT(zpu."Borough", ' / ', zpu."Zone") AS "pickup_loc",
  CONCAT(zdo."Borough", ' / ', zdo."Zone") AS "dropoff_loc"
FROM
  yellow_taxi_trips t
  JOIN zones zpu ON t."PULocationID" = zpu."LocationID"
  JOIN zones zdo ON t."DOLocationID" = zdo."LocationID"
LIMIT 100;
```

To check if a value is missing in the zones table, we can do:

``` sql
SELECT
  tpep_pickup_datetime,
  tpep_dropoff_datetime,
  total_amount,
  "PULocationID",
  "DOLocationID"
FROM
  yellow_taxi_trips t
WHERE
  "PULocationID" NOT IN (SELECT "LocationID" FROM zones)
LIMIT 100;
```

To delete a record with SQL:

``` sql
DELETE FROM zones WHERE "LocationID" = 142;
```

We should take some time to revise `JOIN`, `LEFT JOIN`, `RIGHT JOIN`, `OUTER JOIN`…​

We talk also of `DATE_TRUNC`, `CAST`…​

<div class="formalpara-title">

**Example 1**

</div>

``` sql
SELECT
-- DATE_TRUNC('DAY', tpep_dropoff_datetime) as "day", 
  CAST(tpep_dropoff_datetime AS DATE) as "day", 
  COUNT(1) as "count",
  MAX(total_amount)
FROM
  yellow_taxi_trips t
GROUP BY
  CAST(tpep_dropoff_datetime AS DATE)
ORDER BY "count" DESC;
```

- Remove time explicitly.

- Remove time but by casting on date type.

<div class="formalpara-title">

**Example 2**

</div>

``` sql
SELECT
  CAST(tpep_dropoff_datetime AS DATE) as "day",
  "DOLocationId",
  COUNT(1) as "count",
  MAX(total_amount)
FROM
  yellow_taxi_trips t
GROUP BY
  1, 2
ORDER BY "count" ASC;
```

### Port Mapping and Networks in Docker (Bonus)

> 2023-01-20.

See [DE Zoomcamp 1.4.2 - Port Mapping and Networks in Docker (Bonus)](https://www.youtube.com/watch?v=tOr4hTsHOzU).

- Docker networks

- Port forwarding to the host environment

- Communicating between containers in the network

- `.dockerignore` file

![s28](dtc/s28.png)

<div class="formalpara-title">

**File `docker-compose.yaml`**

</div>

``` yaml
services:
  pgdatabase:
    image: postgres:13
    environment:
      - POSTGRES_USER=root
      - POSTGRES_PASSWORD=root
      - POSTGRES_DB=ny_taxi
    volumes:
      - "./ny_taxi_postgres_data:/var/lib/postgresql/data:rw"
    ports:
      - "5431:5432"
  pgadmin:
    image: dpage/pgadmin4
    environment:
      - PGADMIN_DEFAULT_EMAIL=admin@admin.com
      - PGADMIN_DEFAULT_PASSWORD=root
    ports:
      - "8080:80"
```

<div class="formalpara-title">

**Localhost computer side**

</div>

``` bash
$ pgcli -h localhost -p 5431 -U root -d ny_taxi
```

Then, we execute the following command:

<div class="formalpara-title">

**Network side**

</div>

``` bash
$ URL="https://github.com/DataTalksClub/nyc-tlc-data/releases/download/yellow/yellow_tripdata_2021-01.csv.gz"
$ docker run -it \
    --network=2_docker_sql_default \
    taxi_ingest:v001 \
      --user=root \
      --password=root \
      --host=pgdatabase \
      --port=5432 \
      --db=ny_taxi \
      --table_name=yellow_taxi_trips \
      --url=${URL}
```

There is a lot of stuff in this video and you might have to watch it again to fully understand.

## GCP + Terraform

The code is
[here](https://github.com/DataTalksClub/data-engineering-zoomcamp/tree/main/week_1_basics_n_setup/1_terraform_gcp).

### Introduction to Google Cloud Platform

> 2023-01-20.

See [DE Zoomcamp 1.1.1 - Introduction to Google Cloud Platform](https://www.youtube.com/watch?v=18jIzE41fJ4) on Youtube.

This video is a introduction a GCP.

![s37](dtc/s37.png)

### Introduction to Terraform Concepts & GCP Pre-Requisites

> 2023-01-20.

See [DE Zoomcamp 1.3.1 - Introduction to Terraform Concepts & GCP
Pre-Requisites](https://www.youtube.com/watch?v=Hajwnmj0xfQ) on Youtube and
[1_terraform_overview.md](https://github.com/DataTalksClub/data-engineering-zoomcamp/blob/main/week_1_basics_n_setup/1_terraform_gcp/1_terraform_overview.md)
on GitHub.

- What is Terraform?

  - [Terraform](https://www.terraform.io/) is a tool for build, change, and destroy infrastructure.

  - Ppen-source tool by HashiCorp, used for provisioning infrastructure resources.

  - Supports DevOps best practices for change management.

  - Managing configuration files in source control to maintain an ideal provisioning state for testing and production
    environments.

- What is IaC?

  - Infrastructure-as-Code.

  - Build, change, and manage your infrastructure in a safe, consistent, and repeatable way by defining resource
    configurations that you can version, reuse, and share.

- Some advantages

  - Infrastructure lifecycle management.

  - Version control commits.

  - Very useful for stack-based deployments, and with cloud providers such as AWS, GCP, Azure, K8S.

  - State-based approach to track resource changes throughout deployments.

See [Install Terraform](https://developer.hashicorp.com/terraform/downloads) and [Install Terraform
CLI](https://developer.hashicorp.com/terraform/tutorials/gcp-get-started/install-cli).

``` bash
$ brew tap hashicorp/tap
$ brew install hashicorp/tap/terraform
$ terraform -help
$ terraform --version
# Terraform v1.3.7
# on darwin_arm64
```

If you decide to install manually, Terraform suggests installing to `/usr/local/bin/terraform`.

On January 5, 2023, I opened my free GCP account with \$300 credit to spend within 90 days.

I was asked for my credit card. But it was clearly indicated :  
**No autocharge after free trial ends**  
We ask you for your credit card to make sure you are not a robot. You won’t be charged unless you manually upgrade to a
paid account.

Go to the [Google Cloud Console](https://console.cloud.google.com/welcome).

I created the project **dtc-dez** (for DataTalks.Club Data Engineering Zoomcamp). Edit the Project ID and click on the
circular arrow button to generate one. I choosed **hopeful-summer-375416**.

![s15](dtc/s15.png)

Select the **dtc-dez** project and go to the left menu **IAM & Admin**, then **Service Accounts**.

![s16](dtc/s16.png)

We must then click on **+ CREATE SERVICE ACCOUNT** located at the top.

See [Understanding service accounts"](https://cloud.google.com/iam/docs/understanding-service-accounts).

Enter **dtc-dez-user** in the **Service account name** field, then click on **CREATE AND CONTINUE** button.

Select `Viewer` in the **Role** field, then click the **DONE** button.

![s17](dtc/s17.png)

Right under **Actions**, select **Manage keys**. Then under the **ADD KEY** button, select **Create New Key** and keep
**JSON** as key type.

Save the private key `hopeful-summer-375416-e9bf81ca5686.json` to your computer (like here `~/opt/gcp/`).

Download [Gougle Cloud CLI](https://cloud.google.com/sdk/docs/install-sdk) for local setup.

I downloaded the file `google-cloud-cli-412.0.0-darwin-arm.tar.gz`, unzipped this file and moved the directory in
`~/opt/gougle-cloud-sdk`. Then I ran the script below from that directory using the following command:

``` bash
./google-cloud-sdk/install.sh
```

Voici ce qu’il est apparu dans le terminal

``` txt
Your current Google Cloud CLI version is: 412.0.0
The latest available version is: 412.0.0

┌────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                 Components                                                 │
├───────────────┬──────────────────────────────────────────────────────┬──────────────────────────┬──────────┤
│     Status    │                         Name                         │            ID            │   Size   │
├───────────────┼──────────────────────────────────────────────────────┼──────────────────────────┼──────────┤
│ Not Installed │ App Engine Go Extensions                             │ app-engine-go            │  4.0 MiB │
│ Not Installed │ Appctl                                               │ appctl                   │ 18.5 MiB │
│ Not Installed │ Artifact Registry Go Module Package Helper           │ package-go-module        │  < 1 MiB │
│ Not Installed │ Cloud Bigtable Command Line Tool                     │ cbt                      │  9.8 MiB │
│ Not Installed │ Cloud Bigtable Emulator                              │ bigtable                 │  6.3 MiB │
│ Not Installed │ Cloud Datalab Command Line Tool                      │ datalab                  │  < 1 MiB │
│ Not Installed │ Cloud Datastore Emulator                             │ cloud-datastore-emulator │ 35.1 MiB │
│ Not Installed │ Cloud Firestore Emulator                             │ cloud-firestore-emulator │ 40.2 MiB │
│ Not Installed │ Cloud Pub/Sub Emulator                               │ pubsub-emulator          │ 62.4 MiB │
│ Not Installed │ Cloud Run Proxy                                      │ cloud-run-proxy          │  7.4 MiB │
│ Not Installed │ Cloud SQL Proxy                                      │ cloud_sql_proxy          │  7.3 MiB │
│ Not Installed │ Google Container Registry's Docker credential helper │ docker-credential-gcr    │          │
│ Not Installed │ Kustomize                                            │ kustomize                │  7.4 MiB │
│ Not Installed │ Log Streaming                                        │ log-streaming            │ 11.9 MiB │
│ Not Installed │ Minikube                                             │ minikube                 │ 29.8 MiB │
│ Not Installed │ Nomos CLI                                            │ nomos                    │ 24.6 MiB │
│ Not Installed │ On-Demand Scanning API extraction helper             │ local-extract            │ 11.5 MiB │
│ Not Installed │ Skaffold                                             │ skaffold                 │ 19.9 MiB │
│ Not Installed │ Terraform Tools                                      │ terraform-tools          │ 51.5 MiB │
│ Not Installed │ anthos-auth                                          │ anthos-auth              │ 19.2 MiB │
│ Not Installed │ config-connector                                     │ config-connector         │ 55.6 MiB │
│ Not Installed │ gcloud Alpha Commands                                │ alpha                    │  < 1 MiB │
│ Not Installed │ gcloud Beta Commands                                 │ beta                     │  < 1 MiB │
│ Not Installed │ gcloud app Java Extensions                           │ app-engine-java          │ 63.9 MiB │
│ Not Installed │ gcloud app PHP Extensions                            │ app-engine-php           │ 21.9 MiB │
│ Not Installed │ gcloud app Python Extensions                         │ app-engine-python        │  8.6 MiB │
│ Not Installed │ gcloud app Python Extensions (Extra Libraries)       │ app-engine-python-extras │ 26.4 MiB │
│ Not Installed │ gke-gcloud-auth-plugin                               │ gke-gcloud-auth-plugin   │  7.1 MiB │
│ Not Installed │ kpt                                                  │ kpt                      │ 12.7 MiB │
│ Not Installed │ kubectl                                              │ kubectl                  │  < 1 MiB │
│ Not Installed │ kubectl-oidc                                         │ kubectl-oidc             │ 19.2 MiB │
│ Not Installed │ pkg                                                  │ pkg                      │          │
│ Installed     │ BigQuery Command Line Tool                           │ bq                       │  1.6 MiB │
│ Installed     │ Cloud Storage Command Line Tool                      │ gsutil                   │ 15.5 MiB │
│ Installed     │ Google Cloud CLI Core Libraries                      │ core                     │ 25.9 MiB │
│ Installed     │ Google Cloud CRC32C Hash Tool                        │ gcloud-crc32c            │  1.1 MiB │
└───────────────┴──────────────────────────────────────────────────────┴──────────────────────────┴──────────┘
To install or remove components at your current SDK version [412.0.0], run:
  $ gcloud components install COMPONENT_ID
  $ gcloud components remove COMPONENT_ID

To update your SDK installation to the latest version [412.0.0], run:
  $ gcloud components update

Modify profile to update your $PATH and enable shell command completion?

Do you want to continue (Y/n)?
```

Then I check if **Google Cloud CLI** is installed with the following command:

``` bash
$ gcloud -v
# Google Cloud SDK 412.0.0
# bq 2.0.83
# core 2022.12.09
# gcloud-crc32c 1.0.0
# gsutil 5.17
```

Then I run this:

``` bash
$ gcloud components update
# Do you want to continue (Y/n)? Y
```

See [Install the Google Cloud CLI](https://cloud.google.com/sdk/docs/install-sdk) for more information.

Finally, I ran the following command:

``` bash
# Refresh token/session, and verify authentication
$ export GOOGLE_APPLICATION_CREDENTIALS="~/opt/gcp/hopeful-summer-375416-e9bf81ca5686.json"
$ gcloud auth application-default login
# The environment variable [GOOGLE_APPLICATION_CREDENTIALS] is set to:
#   [/Users/boisalai/.ssh/orbital-concord-373814-d28553f413b2.json]
# Credentials will still be generated to the default location:
#   [/Users/boisalai/.config/gcloud/application_default_credentials.json]
# To use these credentials, unset this environment variable before
# running your application.
#
# Do you want to continue (Y/n)?  Y
```

Select the required account, click on **Allow** button and then Google tells me that **You are now authenticated with
the gcloud CLI!**.

I already installed Terraform. If not, go to [Install Terraform](https://developer.hashicorp.com/terraform/downloads).

We will use Google Cloud Storage (GCS) for Data Lake and BigQuery for Data Warehouse.

In the GCP Console, go to the left menu **IAM**, then click on the pencil to edit permissions of the key that has just
been created. We must add the roles **Storage Admin**, **Storage Object Admin** and **BigQuery Admin**, then click on
the **Save** button.

![s18](dtc/s18.png)

See [Review policy insights for projects](https://cloud.google.com/policy-intelligence/docs/policy-insights) for more
information.

Go to [IAM Service Account Credentials
API](https://console.cloud.google.com/apis/library/iamcredentials.googleapis.com), make sure to select the right project
**dtc-dez** and click **ENABLE** button.

### Workshop: Creating GCP Infrastructure with Terraform

> 2023-01-21.

See [DE Zoomcamp 1.3.2 - Creating GCP Infrastructure with
Terraform](https://www.youtube.com/watch?v=dNkEgO-CExg&list=PL3MmuxUbc_hJed7dXYoJw8DoCuVHhGEQb&index=12).

See also on GitHub repository :

- [1_terraform_overview.md](https://github.com/DataTalksClub/data-engineering-zoomcamp/blob/main/week_1_basics_n_setup/1_terraform_gcp/1_terraform_overview.md)
  on GitHub.

- [Wirkshop](https://github.com/DataTalksClub/data-engineering-zoomcamp/tree/main/week_1_basics_n_setup/1_terraform_gcp/terraform)

Important files to use Terraform are `main.tf` and `variables.tf`. I can have an option the `resources.tf` and
`output.tf` files.

For this section, create a directory and copy these files inside.

``` bash
$ mkdir ~/learning/terraform
$ cp main.tf variables.tf ~/learning/terraform
```

We must specify in `main.tf` the resources we want to use.

Note that I installed the [Terraform extension for Visual Studio
Code](https://marketplace.visualstudio.com/items?itemName=HashiCorp.terraform). See [Terraform Learning
Guides](https://developer.hashicorp.com/terraform/tutorials).

The `main.tf` file contains the instructions to create a new bucket in Google cloud storage service (GCS). See
[google_storage_bucket](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket)
for a predefined definition specific for GCS.

See also [Google Cloud Storage documentation](https://cloud.google.com/storage/docs).

<div class="formalpara-title">

**File `main.tf`**

</div>

``` txt
terraform {
  required_version = ">= 1.0"
  backend "local" {}  # Can change from "local" to "gcs" (for google) or "s3" (for aws), if you would like to preserve your tf-state online
  required_providers {
    google = {
      source  = "hashicorp/google"
    }
  }
}

provider "google" {
  project = var.project
  region = var.region
  // credentials = file(var.credentials)  # Use this if you do not want to set env-var GOOGLE_APPLICATION_CREDENTIALS
}

# Data Lake Bucket
# Ref: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket
resource "google_storage_bucket" "data-lake-bucket" {
  name          = "${local.data_lake_bucket}_${var.project}" # Concatenating DL bucket & Project name for unique naming
  location      = var.region

  # Optional, but recommended settings:
  storage_class = var.storage_class
  uniform_bucket_level_access = true

  versioning {
    enabled     = true
  }

  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      age = 30  // days
    }
  }

  force_destroy = true
}

# DWH
# Ref: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/bigquery_dataset
resource "google_bigquery_dataset" "dataset" {
  dataset_id = var.BQ_DATASET
  project    = var.project
  location   = var.region
}
```

The file `variables.tf` contains configuration. In particular, we must choose the region from
<https://cloud.google.com/about/locations>. In my case, I choose Montréal `northamerica-northeast1` (☘ Low carbon).

<div class="formalpara-title">

**File `variables.tf`**

</div>

``` txt
locals {
  data_lake_bucket = "dtc_data_lake"
}

variable "project" {
  description = "Your GCP Project ID"
}

variable "region" {
  description = "Region for GCP resources. Choose as per your location: https://cloud.google.com/about/locations"
  default = "northamerica-northeast1"
  type = string
}

# Not needed for now
# variable "bucket_name" {
#   description = "The name of the GCS bucket. Must be globally unique."
#   default = ""
# }

variable "storage_class" {
  description = "Storage class type for your bucket. Check official docs for more info."
  default = "STANDARD"
}

variable "BQ_DATASET" {
  description = "BigQuery Dataset that raw data (from GCS) will be written to"
  type = string
  default = "trips_data_all"
}

variable "TABLE_NAME" {
  description = "BigQuery Table"
  type = string
  default = "ny_trips"
}
```

Before running terraform, we must know the execution steps:

1.  `terraform init`: Initializes and configures the backend, installs plugins/providers, and checks out an existing
    configuration from a version control.

2.  `terraform plan`: Matches/previews local changes against a remote state, and proposes an Execution Plan.

3.  `terraform apply`: Asks for approval to the proposed plan, and applies changes to cloud.

4.  `terraform destroy`: Removes your stack from the Cloud.

Run the following commands:

``` bash
# Refresh service-account's auth-token for this session
$ export GOOGLE_APPLICATION_CREDENTIALS="/Users/boisalai/opt/gcp/hopeful-summer-375416-e9bf81ca5686.json"
$ gcloud auth application-default login
# Select your account and enter your password.
# You should see "You are now authenticated with the gcloud CLI!"
```

Next, rather than indicating the project id in the `variables.tf` file, we will pass the Project ID at runtime. My
project ID is **hopeful-summer-375416**.

Execute the following commands.

``` bash
# Initialize state file (.tfstate)
$ terraform init
# Terraform has been successfully initialized!

# Check changes to new infra plan
$ terraform plan
# Enter the project-id: hopeful-summer-375416
```

Note that we could have passed the project id this way.

``` bash
# Check changes to new infra plan
terraform plan -var="project=<your-gcp-project-id>"
# Create new infra
terraform apply -var="project=<your-gcp-project-id>"
```

Terraform tells that it will performa the following actions:

- **google_bigquery_dataset.dataset** will be created

- **google_storage_bucket.data-lake-bucket** will be created

- Plan: 2 to add, 0 to change, 0 to destroy.

Now, execute the following commands.

``` bash
$ terraform apply
```

``` txt
var.project
  Your GCP Project ID

  Enter a value: hopeful-summer-375416


Terraform used the selected providers to generate the following execution plan.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # google_bigquery_dataset.dataset will be created
  + resource "google_bigquery_dataset" "dataset" {
      + creation_time              = (known after apply)
      + dataset_id                 = "trips_data_all"
      + delete_contents_on_destroy = false
      + etag                       = (known after apply)
      + id                         = (known after apply)
      + labels                     = (known after apply)
      + last_modified_time         = (known after apply)
      + location                   = "northamerica-northeast1"
      + project                    = "hopeful-summer-375416"
      + self_link                  = (known after apply)

      + access {
          + domain         = (known after apply)
          + group_by_email = (known after apply)
          + role           = (known after apply)
          + special_group  = (known after apply)
          + user_by_email  = (known after apply)

          + dataset {
              + target_types = (known after apply)

              + dataset {
                  + dataset_id = (known after apply)
                  + project_id = (known after apply)
                }
            }

          + routine {
              + dataset_id = (known after apply)
              + project_id = (known after apply)
              + routine_id = (known after apply)
            }

          + view {
              + dataset_id = (known after apply)
              + project_id = (known after apply)
              + table_id   = (known after apply)
            }
        }
    }

  # google_storage_bucket.data-lake-bucket will be created
  + resource "google_storage_bucket" "data-lake-bucket" {
      + force_destroy               = true
      + id                          = (known after apply)
      + location                    = "NORTHAMERICA-NORTHEAST1"
      + name                        = "dtc_data_lake_hopeful-summer-375416"
      + project                     = (known after apply)
      + public_access_prevention    = (known after apply)
      + self_link                   = (known after apply)
      + storage_class               = "STANDARD"
      + uniform_bucket_level_access = true
      + url                         = (known after apply)

      + lifecycle_rule {
          + action {
              + type = "Delete"
            }

          + condition {
              + age                   = 30
              + matches_prefix        = []
              + matches_storage_class = []
              + matches_suffix        = []
              + with_state            = (known after apply)
            }
        }

      + versioning {
          + enabled = true
        }

      + website {
          + main_page_suffix = (known after apply)
          + not_found_page   = (known after apply)
        }
    }

Plan: 2 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

google_bigquery_dataset.dataset: Creating...
google_storage_bucket.data-lake-bucket: Creating...
google_bigquery_dataset.dataset: Creation complete after 1s [id=projects/hopeful-summer-375416/datasets/trips_data_all]
google_storage_bucket.data-lake-bucket: Creation complete after 1s [id=dtc_data_lake_hopeful-summer-375416]

Apply complete! Resources: 2 added, 0 changed, 0 destroyed.
```

Go to my Google Cloud, click in the left menu on **Cloud Storage**, we should see a new backet with the name
**dtc_data_lake_hopeful-summer-375416** which matches the name that we asked for in the `main.tf`.

![s39](dtc/s39.png)

Similarly for the **Big Query**, we should see this:

![s19](dtc/s19.png)

Above all, never copy the credential file into my project folder! We can have the account stolen by someone who could
mine bitcoins. Better to be careful.

### Setting up the environment on cloud VM

> 2023-01-22.

See [DE Zoomcamp 1.4.1 - Setting up the Environment on Google Cloud (Cloud VM + SSH
access)](https://www.youtube.com/watch?v=ae-CV2KfoN0).

Go to **Google Cloud**, in the left menu, select **Compute Engine**, **VM instances**, make sure you select the right
project (**dtc-dez**), and click on the **ENABLE** button if not already done.

![s40](dtc/s40.png)

We must then generate the SSH key that we will use for this instance. For more information, see:

- [Providing public SSH keys to
  instanc](https://cloud.google.com/compute/docs/instances/connecting-advanced#provide-key)

- [Create SSH keys](https://cloud.google.com/compute/docs/connect/create-ssh-keys)

- [Add SSH keys to VMs](https://cloud.google.com/compute/docs/connect/add-ssh-keys)

- [Run Docker commands without sudo](https://github.com/sindresorhus/guides/blob/main/docker-without-sudo.md)

#### 01:05 Generate ssh keys

``` bash
$ cd ~/.ssh
$ ssh-keygen -t rsa -f gcp -C boisalai -b 2048
$ ls
# gcp  gcp.pub  ...
$ cat gcp.pub | pbcopy
```

####03:41 Upload public key to GCP

We must then provide the public key `gcp.pub` to Google Cloud. To do this, go to **Compute Engine**, **Metadata**, **SSH
KEYS** tab, and click the **ADD SSH KEY** button.

![s20](dtc/s20.png)

#### 04:39 Create VM

Then, let’s go back to **Google Cloud**, **Compute Engine**, **VM instances** then click on **CREATE INSTANCE** with the
following choices.

|                     |                     |
|---------------------|---------------------|
| ![s21](dtc/s21.png) | ![s22](dtc/s22.png) |

We get this.

![s23](dtc/s23.png)

#### 09:24 ssh into VM

Copy the **External IP** (35.203.47.67), go to the terminal and run the following command:

``` bash
$ ssh -i ~/.ssh/gcp boisalai@35.203.47.67
<<comment
The authenticity of host '35.203.47.67 (35.203.47.67)' can't be established.
ED25519 key fingerprint is SHA256:351hRzo7i+H9w2kYc7hFMl2z952Ty9xWap4RVXMinpg.
This key is not known by any other names
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '35.203.47.67' (ED25519) to the list of known hosts.
Welcome to Ubuntu 20.04.5 LTS (GNU/Linux 5.15.0-1027-gcp x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

  System information as of Sun Jan 22 14:12:39 UTC 2023

  System load:  0.03              Processes:             125
  Usage of /:   6.3% of 28.89GB   Users logged in:       0
  Memory usage: 1%                IPv4 address for ens4: 10.162.0.2
  Swap usage:   0%

0 updates can be applied immediately.


The list of available updates is more than a week old.
To check for new updates run: sudo apt update


The programs included with the Ubuntu system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Ubuntu comes with ABSOLUTELY NO WARRANTY, to the extent permitted by
applicable law.
comment
boisalai@de-zoomcamp:~$
```

``` bash
# This command allows to have information on the machine...
boisalai@de-zommcamp:~$ htop
boisalai@de-zommcamp:~$ gcloud --version
<<comment
Google Cloud SDK 413.0.0
alpha 2023.01.06
beta 2023.01.06
bq 2.0.84
bundled-python3-unix 3.9.12
core 2023.01.06
gcloud-crc32c 1.0.0
gsutil 5.17
minikube 1.28.0
skaffold 2.0.4
comment
boisalai@de-zommcamp:~$
```

Download and install **Anaconda for Linux** in our instance. See
[Downloads](https://www.anaconda.com/products/distribution#Downloads) and
<https://repo.anaconda.com/archive/Anaconda3-2022.10-Linux-x86_64.sh>.

``` bash
boisalai@de-zommcamp:~$ wget https://repo.anaconda.com/archive/Anaconda3-2022.10-Linux-x86_64.sh
boisalai@de-zommcamp:~$ bash Anaconda3-2022.10-Linux-x86_64.sh
# Read and accept license.
boisalai@de-zommcamp:~$ ls
# Anaconda3-2022.10-Linux-x86_64.sh  anaconda3  snap
boisalai@de-zommcamp:~$ logout
```

We can press kbd:\[Ctlr+D\] to logout the server.

#### 11:41 Configure VM and setup local \~/.ssh/config

Next, create the `~/.ssh/config` file on my MacBook with this information:

<div class="formalpara-title">

**Fichier `~/.ssh/config`**

</div>

``` txt
Host de-zoomcamp
    HostName 35.203.47.67
    User boisalai
    IdentityFile /Users/boisalai/.ssh/gcp
```

Then, we only have this command to do to enter the server:

``` bash
$ ssh de-zoomcamp
```

In Linux server, we can do this command to know where is python.

``` bash
boisalai@de-zommcamp:~$ source .bashrc
(base) boisalai@de-zommcamp:~$ which python
/home/boisalai/anaconda3/bin/python
(base) boisalai@de-zommcamp:~$
```

Pour quitter le serveur, on peut faire kbd:\[Ctrl+D\] ou exécuter la commande `logout`.

Now let’s install Docker.

``` bash
boisalai@de-zommcamp:~$ sudo apt-get update
boisalai@de-zommcamp:~$ sudo apt-get install docker.io
```

#### 17:53 ssh with VS Code

In VS Code, find and install the **Remote - SSH** extension. Then go to the **Command Palette** (kbd:\[Shift+Cmd+P\])
and select **Remote-SSH: Connect to Host…​** and **de-zoomcamp**.

![s24](dtc/s24.png)

We now have VS Code pointing to the server.

\|== \|![s25](dtc/s25.png)\|![s25b](dtc/s25b.png) \|==

We need to make a clone of the github on the server.

``` bash
boisalai@de-zommcamp:~$ git clone https://github.com/DataTalksClub/data-engineering-zoomcamp.git
<<comment
Cloning into 'data-engineering-zoomcamp'...
remote: Enumerating objects: 2520, done.
remote: Counting objects: 100% (221/221), done.
remote: Compressing objects: 100% (140/140), done.
remote: Total 2520 (delta 83), reused 170 (delta 48), pack-reused 2299
Receiving objects: 100% (2520/2520), 1.29 MiB | 17.17 MiB/s, done.
Resolving deltas: 100% (1373/1373), done.
comment
(base) boisalai@de-zoomcamp:~$
```

Next, we need to authorize docker. Go on at [Run Docker commands without
sudo](https://github.com/sindresorhus/guides/blob/main/docker-without-sudo.md) for instructions.

On the server, run the following commands:

``` bash
(base) boisalai@de-zommcamp:~$ sudo groupadd docker
(base) boisalai@de-zommcamp:~$ sudo gpasswd -a $USER docker
(base) boisalai@de-zommcamp:~$ sudo service docker restart
(base) boisalai@de-zommcamp:~$ logout
$ ssh de-zoomcamp
(base) boisalai@de-zommcamp:~$ docker run hello-world
(base) boisalai@de-zommcamp:~$ docker run -it ubuntu bash
<<comment
Unable to find image 'ubuntu:latest' locally
latest: Pulling from library/ubuntu
6e3729cf69e0: Pull complete
Digest: sha256:27cb6e6ccef575a4698b66f5de06c7ecd61589132d5a91d098f7f3f9285415a9
Status: Downloaded newer image for ubuntu:latest
comment
root@e2ee01058851:/# ls
bin   dev  home  lib32  libx32  mnt  proc  run   srv  tmp  var
boot  etc  lib   lib64  media   opt  root  sbin  sys  usr
root@e2ee01058851:/# exit
# exit
(base) boisalai@de-zommcamp:~$
```

Now let’s install Docker Compose. Go to <https://github.com/docker/compose>, select the **latest releases**, and
**docker-compose-linux-x86_64**, copy the link.

In the server, do the following commands:

``` bash
(base) boisalai@de-zommcamp:~$ mkdir bin
(base) boisalai@de-zommcamp:~$ cd bin
(base) boisalai@de-zommcamp:~/bin$ wget https://github.com/docker/compose/releases/download/v2.15.0/docker-compose-linux-x86_64 -O docker-compose
(base) boisalai@de-zommcamp:~/bin$ ls
# docker-compose
(base) boisalai@de-zommcamp:~/bin$ chmod +x docker-compose
(base) boisalai@de-zommcamp:~/bin$ ./docker-compose version
# Docker Compose version v2.15.0
(base) boisalai@de-zommcamp:~/bin$ cd
(base) boisalai@de-zommcamp:~$ nano .bashrc
```

We need to add the `/bin` directory to the `PATH` by addind this instruction at the bottom of the `.bashrc` file:

``` bash
export PATH="${HOME}/bin:${PATH}"
```

![s26](dtc/s26.png)

Do kbd:\[Ctrl+O\] and kbd:\[Enter\] to save and kbd:\[Ctrl+X\] to quit. Then issue the `source .bashrc` command.

``` bash
(base) boisalai@de-zommcamp:~$ source .bashrc
(base) boisalai@de-zommcamp:~$ which docker-compose
# /home/boisalai/bin/docker-compose
(base) boisalai@de-zommcamp:~$ docker-compose version
# Docker Compose version v2.15.0
(base) boisalai@de-zommcamp:~$
(base) boisalai@de-zommcamp:~$ ls
# Anaconda3-2022.10-Linux-x86_64.sh  anaconda3  bin  data-engineering-zoomcamp  snap
(base) boisalai@de-zommcamp:~$ cd data-engineering-zoomcamp/
(base) boisalai@de-zommcamp:~/data-engineering-zoomcamp$ ls
# README.md            dataset.md             week_3_data_warehouse         week_7_project
# after-sign-up.md     images                 week_4_analytics_engineering
# arch_diagram.md      week_1_basics_n_setup  week_5_batch_processing
# asking-questions.md  week_2_data_ingestion  week_6_stream_processing
(base) boisalai@de-zommcamp:~/data-engineering-zoomcamp$ cd week_1_basics_n_setup/
(base) boisalai@de-zommcamp:~/data-engineering-zoomcamp/week_1_basics_n_setup$ ls
# 1_terraform_gcp  2_docker_sql  README.md  homework.md
(base) boisalai@de-zommcamp:~/data-engineering-zoomcamp/week_1_basics_n_setup$ cd 2_docker_sql/
(base) boisalai@de-zommcamp:~/data-engineering-zoomcamp/week_1_basics_n_setup/2_docker_sql$ ls
# Dockerfile  docker-compose.yaml  pg-test-connection.ipynb  upload-data.ipynb
(base) boisalai@de-zommcamp:~/data-engineering-zoomcamp/week_1_basics_n_setup/2_docker_sql$ docker-compose up -d
<<comment
[+] Running 0/2
...
(base) boisalai@de-zommcamp:~/data-engineering-zoomcamp/week_1_basics_n_setup/2_docker_sql$ docker ps
CONTAINER ID   IMAGE            COMMAND                  CREATED              STATUS              PORTS                                            NAMES
185d52c077d4   postgres:13      "docker-entrypoint.s…"   About a minute ago   Up About a minute   0.0.0.0:5432->5432/tcp, :::5432->5432/tcp        2_docker_sql-pgdatabase-1
73315ebf6416   dpage/pgadmin4   "/entrypoint.sh"         About a minute ago   Up About a minute   443/tcp, 0.0.0.0:8080->80/tcp, :::8080->80/tcp   2_docker_sql-pgadmin-1
comment
(base) boisalai@de-zommcamp:~/data-engineering-zoomcamp/week_1_basics_n_setup/2_docker_sql$
```

We now have postgres and pgadmin installed in a container.

#### 27:50

We must now install **pgcli**.

``` bash
(base) boisalai@de-zommcamp:~$ pip install pgcli
(base) boisalai@de-zommcamp:~$ pgcli -h localhost -U root -d ny_taxi
# Password for root:
```

Enter the password **root**.

#### 28:41

``` txt
Load your password from keyring returned:
No recommended backend was available. Install a recommended 3rd party backend package; or, install the keyrings.alt package if you want to use the non-recommended backends. See https://pypi.org/project/keyring for details.
To remove this message do one of the following:
- prepare keyring as described at: https://keyring.readthedocs.io/en/stable/
- uninstall keyring: pip uninstall keyring
- disable keyring in our configuration: add keyring = False to [main]
Password for root:
Set password in keyring returned:
No recommended backend was available. Install a recommended 3rd party backend package; or, install the keyrings.alt package if you want to use the non-recommended backends. See https://pypi.org/project/keyring for details.
To remove this message do one of the following:
- prepare keyring as described at: https://keyring.readthedocs.io/en/stable/
- uninstall keyring: pip uninstall keyring
- disable keyring in our configuration: add keyring = False to [main]
```

![s27](dtc/s27.png)

Instructor gets the same error message but doesn’t care I think I can go on without doing this procedure for now.

Faire kbd:\[Ctrl+D\] pour quitter **pgcli**.

Now the instructor uninstalls **pgcli** and reinstalls it with **conda**. I didn’t quite understand why.

``` bash
(base) boisalai@de-zoomcamp:~$ pip uninstall pgcli
(base) boisalai@de-zoomcamp:~$ conda install -c conda-forge pgcli
(base) boisalai@de-zoomcamp:~$ pip install -U mycli
```

Unfortunately I am unable to install **pgcli** from conda. I remain stuck at the "Solving environment" step So I
reinstalled `$ pip install pgcli`.

#### 32:17 Setup port forwarding to local machine

The instruction says to open a **PORT 5432** in the server’s VS Code. Then it says we can do the following command from
my MacBook Pro’s terminal, but it doesn’t work.

``` bash
(base) boisalai@de-zoomcamp:~$ pgcli -h localhost -U root -d ny_taxi
# Password for root:
```

Enter the password **root**. Faire kbd:\[Ctrl+D\] pour quitter pgcli.

In VS Code of the server, I open **PORT 5432**.

|                       |                       |
|-----------------------|-----------------------|
| ![s41a](dtc/s41a.png) | ![s41b](dtc/s41b.png) |

I can now use pgcli on the client side (i.e. on my MacBook Pro) to access the database located on the server.

![s42](dtc/s42.png)

In VS Code of the server, I open **PORT 8080** and I open <http://localhost:8080> on my MacBook Pro and pgAdmin appears.
Enter the username `admin@admin.com` and the password `root`.

#### 35:26 Run Jupyter to run upload-data notebook

In VS Code of the server, I need to open **PORT 8888**.

![s44](dtc/s44.png)

I can start jupyter on the server side.

``` bash
(base) boisalai@de-zoomcamp:~$ cd data-engineering-zoomcamp/
(base) boisalai@de-zoomcamp:~$ cd week_1_basics_n_setup/
(base) boisalai@de-zoomcamp:~$ cd 2_docker_sql/
(base) boisalai@de-zoomcamp:~$ ls
(base) boisalai@de-zoomcamp:~$ jupyter notebook
```

![s43](dtc/s43.png)

Open the browser to <http://localhost:8888//?token> and open `upload-data.ipynb`.

On the server, I can download the following files.

``` bash
(base) boisalai@de-zoomcamp:~$ wget https://github.com/DataTalksClub/nyc-tlc-data/releases/download/yellow/yellow_tripdata_2021-01.csv.gz
(base) boisalai@de-zoomcamp:~$ wget https://github.com/DataTalksClub/nyc-tlc-data/releases/download/misc/taxi_zone_lookup.csv
```

Or, we can download these files from my jupyter notebook.

``` bash
!wget https://github.com/DataTalksClub/nyc-tlc-data/releases/download/yellow/yellow_tripdata_2021-01.csv.gz
!wget https://github.com/DataTalksClub/nyc-tlc-data/releases/download/misc/taxi_zone_lookup.csv
```

We can now check if we can load data into a postgres table with this python code in jupyter.

``` python
import pandas as pd

!pip install pyarrow
!pip install psycopg2-binary

df = pd.read_csv('yellow_tripdata_2021-01.csv.gz', nrows=100)

df.tpep_pickup_datetime = pd.to_datetime(df.tpep_pickup_datetime)
df.tpep_dropoff_datetime = pd.to_datetime(df.tpep_dropoff_datetime)

from sqlalchemy import create_engine

engine = create_engine('postgresql://root:root@localhost:5432/ny_taxi')
engine.connect()

df.head(n=0).to_sql(name='yellow_taxi_data', con=engine, if_exists='replace')
```

Check if the table exists on the server.

``` bash
$ ssh de-zoomcamp
(base) boisalai@de-zoomcamp:~$ pgcli -h localhost -U root -d ny_taxi
# Password for root: root
Server: PostgreSQL 13.9 (Debian 13.9-1.pgdg110+1)
Version: 3.5.0
Home: http://pgcli.com
root@localhost:ny_taxi> \dt
+--------+------------------+-------+-------+
| Schema | Name             | Type  | Owner |
|--------+------------------+-------+-------|
| public | yellow_taxi_data | table | root  |
+--------+------------------+-------+-------+
SELECT 1
Time: 0.014s
root@localhost:ny_taxi>
```

Now let’s load the first 100 lines of the file into postgres from jupyter notebook.

``` python
df.head(n=100).to_sql(name='yellow_taxi_data', con=engine, if_exists='append')
```

Vérifier si les 100 records sont insérés dans la table avec la commandesuivante dans pgadmin.

``` txt
root@localhost:ny_taxi> select count(1) from yellow_taxi_data;
+-------+
| count |
|-------|
| 100   |
+-------+
SELECT 1
Time: 0.008s
root@localhost:ny_taxi>
```

#### 38:56 Install Terraform

We now need to install Terraform. One should get the zip file link from
<https://developer.hashicorp.com/terraform/downloads>. We must take **AMD64**.

``` bash
(base) boisalai@de-zommcamp:~$ cd bin
(base) boisalai@de-zommcamp:~/bin$ ls
# docker-compose
(base) boisalai@de-zommcamp:~/bin$ wget https://releases.hashicorp.com/terraform/1.3.7/terraform_1.3.7_linux_amd64.zip
(base) boisalai@de-zommcamp:~/bin$ ls
# docker-compose  terraform_1.3.7_linux_amd64.zip
(base) boisalai@de-zommcamp:~/bin$ sudo apt-get install unzip
(base) boisalai@de-zommcamp:~/bin$ unzip terraform_1.3.7_linux_amd64.zip
# Archive:  terraform_1.3.7_linux_amd64.zip
#   inflating: terraform
(base) boisalai@de-zommcamp:~/bin$ rm terraform_1.3.7_linux_amd64.zip
(base) boisalai@de-zommcamp:~/bin$ ls
docker-compose  terraform  # terraform is green so it's an executable.
(base) boisalai@de-zommcamp:~/bin$ terraform -version
Terraform v1.3.7
on linux_amd64
(base) boisalai@de-zommcamp:~/bin$
```

#### 40:35 sftp Google credentials to VM

Now I want to upload my `/Users/boisalai/opt/gcp/hopeful-summer-375416-e9bf81ca5686.json` file to the server. To do
this, run the following command from the terminal of my MacBook Pro.

``` bash
$ sftp de-zoomcamp
sftp> mkdir .gc
sftp> cd .gc
sftp> put hopeful-summer-375416-e9bf81ca5686.json
```

![s45](dtc/s45.png)

#### 42:14 Configure gcloud

Run these commands on the server.

``` bash
(base) boisalai@de-zommcamp:~/data-engineering-zoomcamp/week_1_basics_n_setup/1_terraform_gcp/terraform$ export GOOGLE_APPLICATION_CREDENTIALS=~/.gc/hopeful-summer-375416-e9bf81ca5686.json
(base) boisalai@de-zommcamp:~/data-engineering-zoomcamp/week_1_basics_n_setup/1_terraform_gcp/terraform$ gcloud auth activate-service-account --key-file $GOOGLE_APPLICATION_CREDENTIALS
# Activated service account credentials for: [dtc-dez-user@hopeful-summer-375416.iam.gserviceaccount.com]
(base) boisalai@de-zommcamp:~/data-engineering-zoomcamp/week_1_basics_n_setup/1_terraform_gcp/terraform$
```

#### 43:38 Run Terraform commands

On the server, I need to change the region in the `variable.tf` file in the `terraform` directory. I can also define a
variable containing my project id.

<div class="formalpara-title">

**File `variable.tf`**

</div>

``` txt
variable "region" {
  description = "Region for GCP resources. Choose as per your location: https://cloud.google.com/about/locations"
  default = "northamerica-northeast1"
  type = string
}

variable "project" {
  description = "Your GCP Project ID"
  default = "hopeful-summer-375416"
  type = string
}
```

Then, on the server, run these commands…​

``` bash
(base) boisalai@de-zommcamp:~/data-engineering-zoomcamp/week_1_basics_n_setup/1_terraform_gcp/terraform$ terraform init
(base) boisalai@de-zommcamp:~/data-engineering-zoomcamp/week_1_basics_n_setup/1_terraform_gcp/terraform$ terraform plan
(base) boisalai@de-zommcamp:~/data-engineering-zoomcamp/week_1_basics_n_setup/1_terraform_gcp/terraform$ terraform apply
```

I get an error message but the instructor says it’s normal since services already exist in Google Cloud Storage.

#### 45:34 Shut down VM

To stop the server, do this command:

``` bash
(base) boisalai@de-zoomcamp:~$ sudo shutdown
# Shutdown scheduled for Sun 2023-01-22 16:10:20 UTC, use 'shutdown -c' to cancel.
(base) boisalai@de-zoomcamp:~$
```

It is also recommended to **STOP** on the instance in the Google Cloud interface.

Go to **Google Cloud**, in the left menu, select **Compute Engine**, **VM instances**, make sure you select the right project (**dtc-dez**), and click on **STOP**.

![s46](dtc/s46.png)

#### 47:34 Start VM back up and update \~/.ssh/config

You can restart the instance by clicking on **START** of the instance in the Google Cloud interface.

I then get a new **External ID** `35.203.47.67` which I have to change in the `~/.ssh/config` file.

Oddly, I get the same IP address, so I don’t need to change the config file.

<div class="formalpara-title">

**Fichier `~/.ssh/config`**

</div>

``` bash
    Host de-zoomcamp
        HostName 35.203.47.67
        User boisalai
        IdentityFile /Users/boisalai/.ssh/gcp
```

Then I can access the server the same way.

``` bash
$ ssh de-zoomcamp
```

And we find our instance with all the software installed.

#### 49:07 Delete VM

The instructor destroys the instance by clicking on **DELETE** next to the instance.

#### 49:32 Explanation of GCP charges

The instructor explains to us that we pay for the CPU and for the storage used.

## See also

- [Fixing TLC Yellow Taxi 2019 Data Parquet Errors Loading Into Big Query](https://www.youtube.com/watch?v=wkgDUsDZKfg)

- [SSH Simplified: Aliasing Credentials with Config Files](https://itsadityagupta.hashnode.dev/ssh-simplified-aliasing-credentials-with-config-files)
