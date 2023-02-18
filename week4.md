# Week 4: Analytics Engineering

This week, we’ll dive into Analytics Engineering.

We’ll cover:

- Basics of analytics engineering
- [dbt Labs](https://www.linkedin.com/company/dbtlabs/) (data build tool)
- Testing and documenting
- Deployment to the cloud and locally
- Visualizing the data with Google Data Studio and [Metabase](https://www.linkedin.com/company/metabase/)

**Goal**: Transforming the data loaded in DWH to Analytical Views developing a [dbt
project](https://github.com/DataTalksClub/data-engineering-zoomcamp/blob/main/week_4_analytics_engineering/taxi_rides_ny/README.md).

# Materials

See
[week_4\_analytics_engineering](https://github.com/DataTalksClub/data-engineering-zoomcamp/tree/main/week_4_analytics_engineering)
on GitHub and
[slides](https://docs.google.com/presentation/d/1xSll_jv0T8JF4rYZvLHfkJXYqUjPtThA/edit?usp=sharing&ouid=114544032874539580154&rtpof=true&sd=true)

Youtube videos:

- [DE Zoomcamp 4.1.1 - Analytics Engineering Basics](https://www.youtube.com/watch?v=uF76d5EmdtU)
- [DE Zoomcamp 4.1.2 - What is dbt](https://www.youtube.com/watch?v=4eCouvVOJUw)
- [DE Zoomcamp 4.2.1 - Start Your dbt Project: BigQuery and dbt Cloud (Alternative
  A)](https://www.youtube.com/watch?v=iMxh6s_wL4Q)
- [DE Zoomcamp 4.2.2 - Start Your dbt Project: Postgres and dbt Core Locally (Alternative
  B)](https://www.youtube.com/watch?v=1HmL63e-vRs)
- [DE Zoomcamp 4.3.1 - Build the First dbt Models](https://www.youtube.com/watch?v=UVI30Vxzd6c) (✦ see note below)
- [DE Zoomcamp 4.3.2 - Testing and Documenting the Project](https://www.youtube.com/watch?v=UishFmq1hLM) (✦ see note
  below)
- [DE Zoomcamp 4.4.1 - Deployment Using dbt Cloud (Alternative A)](https://www.youtube.com/watch?v=rjf6yZNGX8I)
- [DE Zoomcamp 4.4.2 - Deployment Using dbt Locally (Alternative B)](https://www.youtube.com/watch?v=Cs9Od1pcrzM)
- [DE Zoomcamp 4.5.1 - Visualising the data with Google Data Studio (Alternative
  A)](https://www.youtube.com/watch?v=39nLTs74A3E)
- [DE Zoomcamp 4.5.2 - Visualising the data with Metabase (Alternative B)](https://www.youtube.com/watch?v=BnLkrA7a6gM)

**✦ Note**: These videos are shown entirely on dbt cloud IDE but the same steps can be followed locally on the IDE of
your choice.

## Prerequisites

### Datasets

- A running warehouse (BigQuery or postgres)
- A set of running pipelines ingesting the project dataset (week 3 completed): Taxi Rides NY dataset
  - Yellow taxi data - Years 2019 and 2020
  - Green taxi data - Years 2019 and 2020
  - fhv data - Year 2019.
- Data can be found here: <https://github.com/DataTalksClub/nyc-tlc-data>

### Setting up dbt for using BigQuery (Alternative A - preferred)

You will need to create a dbt cloud account using [this link](https://www.getdbt.com/signup/) and connect to your
warehouse [following these
instructions](https://docs.getdbt.com/docs/dbt-cloud/cloud-configuring-dbt-cloud/cloud-setting-up-bigquery-oauth). More
detailed instructions in
[dbt_cloud_setup.md](https://github.com/DataTalksClub/data-engineering-zoomcamp/blob/main/week_4_analytics_engineering/dbt_cloud_setup.md).

### Setting up dbt for using Postgres locally (Alternative B)

As an alternative to the cloud, that require to have a cloud database, you will be able to run the project installing
dbt locally. You can follow the [official dbt documentation](https://docs.getdbt.com/dbt-cli/installation) or use a
docker image from official [dbt repo](https://github.com/dbt-labs/dbt/). You will need to install the latest version
(1.0) with the postgres adapter (dbt-postgres). After local installation you will have to set up the connection to PG in
the `profiles.yml`, you can find the templates
[here](https://docs.getdbt.com/reference/warehouse-profiles/postgres-profile).

## What I did to set my tools

**Note**: For the remainder of these notes, I have chosen to continue (or focus more on) with BigQuery, i.e. alternative
A.

### Upload Taxi Rides NY dataset into BigQuery

Start Prefect Orion with the following commands.

``` bash
cd ~/github/de-zoomcamp/week3
conda activate zoom
prefect orion start

## Open a new terminal window.
conda activate zoom
prefect profile use default
prefect config set PREFECT_API_URL=http://127.0.0.1:4200/api
```

Check out the dashboard at <http://127.0.0.1:4200>.

Create a python script to load our data from GitHub repo to Google Cloud Storage (GCS).

**File `web_to_gcs.py`**

``` python
from pathlib import Path
import pandas as pd
from prefect import flow, task
from prefect_gcp.cloud_storage import GcsBucket
from random import randint


@task(retries=3, log_prints=True)
def fetch(dataset_url: str) -> pd.DataFrame:
    print(dataset_url)
    df = pd.read_csv(dataset_url, compression='gzip')
    return df


@task(log_prints=True)
def clean(color: str, df: pd.DataFrame) -> pd.DataFrame:
    """
    yellow 2019
    VendorID                   int64
    tpep_pickup_datetime      object (green=lpep_pickup_datetime)
    tpep_dropoff_datetime     object (green=lpep_dropoff_datetime)
    passenger_count            int64
    trip_distance            float64
    RatecodeID                 int64
    store_and_fwd_flag        object
    PULocationID               int64
    DOLocationID               int64
    payment_type               int64
    fare_amount              float64
    extra                    float64
    mta_tax                  float64
    tip_amount               float64
    tolls_amount             float64
    improvement_surcharge    float64
    total_amount             float64
    congestion_surcharge     float64

    yellow 2020
    VendorID                 float64 (2019=int64)
    tpep_pickup_datetime      object (green=lpep_pickup_datetime)
    tpep_dropoff_datetime     object (green=lpep_dropoff_datetime)
    passenger_count          float64 (2019=int64)
    trip_distance            float64
    RatecodeID               float64 (2019=int64)
    store_and_fwd_flag        object
    PULocationID               int64
    DOLocationID               int64
    payment_type             float64 (2019=int64)
    fare_amount              float64
    extra                    float64
    mta_tax                  float64
    tip_amount               float64
    tolls_amount             float64
    improvement_surcharge    float64
    total_amount             float64
    congestion_surcharge     float64

    green 2019
    VendorID                   int64
    lpep_pickup_datetime      object
    lpep_dropoff_datetime     object
    store_and_fwd_flag        object
    RatecodeID                 int64
    PULocationID               int64
    DOLocationID               int64
    passenger_count            int64
    trip_distance            float64
    fare_amount              float64
    extra                    float64
    mta_tax                  float64
    tip_amount               float64
    tolls_amount             float64
    ehail_fee                float64
    improvement_surcharge    float64
    total_amount             float64
    payment_type               int64
    trip_type                  int64
    congestion_surcharge     float64

    green 2020
    VendorID                 float64 (2019=int64)
    lpep_pickup_datetime      object
    lpep_dropoff_datetime     object
    store_and_fwd_flag        object
    RatecodeID               float64 (2019=int64)
    PULocationID               int64
    DOLocationID               int64
    passenger_count          float64 (2019=int64)
    trip_distance            float64
    fare_amount              float64
    extra                    float64
    mta_tax                  float64
    tip_amount               float64
    tolls_amount             float64
    ehail_fee                float64
    improvement_surcharge    float64
    total_amount             float64
    payment_type             float64 (2019=int64)
    trip_type                float64 (2019=int64)
    congestion_surcharge     float64

    fhv 2019
    dispatching_base_num,pickup_datetime,dropOff_datetime,PUlocationID,DOlocationID,SR_Flag,Affiliated_base_number
    fhv 2020
    dispatching_base_num,pickup_datetime,dropoff_datetime,PULocationID,DOLocationID,SR_Flag,Affiliated_base_number
    """

    if color == "yellow":
        """Fix dtype issues"""
        df["tpep_pickup_datetime"] = pd.to_datetime(df["tpep_pickup_datetime"])
        df["tpep_dropoff_datetime"] = pd.to_datetime(df["tpep_dropoff_datetime"])

    if color == "green":
        """Fix dtype issues"""
        df["lpep_pickup_datetime"] = pd.to_datetime(df["lpep_pickup_datetime"])
        df["lpep_dropoff_datetime"] = pd.to_datetime(df["lpep_dropoff_datetime"])
        df["trip_type"] = df["trip_type"].astype('Int64')

    if color == "yellow" or color == "green":
        df["VendorID"] = df["VendorID"].astype('Int64')
        df["RatecodeID"] = df["RatecodeID"].astype('Int64')
        df["PULocationID"] = df["PULocationID"].astype('Int64')
        df["DOLocationID"] = df["DOLocationID"].astype('Int64')
        df["passenger_count"] = df["passenger_count"].astype('Int64')
        df["payment_type"] = df["payment_type"].astype('Int64')

    if color == "fhv":
        """Rename columns"""
        df.rename({'dropoff_datetime':'dropOff_datetime'}, axis='columns', inplace=True)
        df.rename({'PULocationID':'PUlocationID'}, axis='columns', inplace=True)
        df.rename({'DOLocationID':'DOlocationID'}, axis='columns', inplace=True)

        """Fix dtype issues"""
        df["pickup_datetime"] = pd.to_datetime(df["pickup_datetime"])
        df["dropOff_datetime"] = pd.to_datetime(df["dropOff_datetime"])

        # See https://pandas.pydata.org/docs/user_guide/integer_na.html
        df["PUlocationID"] = df["PUlocationID"].astype('Int64')
        df["DOlocationID"] = df["DOlocationID"].astype('Int64')

    print(df.head(2))
    print(f"columns: {df.dtypes}")
    print(f"rows: {len(df)}")
    return df


@task()
def write_local(color: str, df: pd.DataFrame, dataset_file: str) -> Path:
    """Write DataFrame out locally as csv file"""
    Path(f"data/{color}").mkdir(parents=True, exist_ok=True)

    # path = Path(f"data/fhv/{dataset_file}.csv.gz")
    # df.to_csv(path, compression="gzip")

    path = Path(f"data/{color}/{dataset_file}.parquet")
    df.to_parquet(path, compression="gzip")

    return path


@task
def write_gcs(path: Path) -> None:
    """Upload local parquet file to GCS"""
    gcs_block = GcsBucket.load("zoom-gcs")
    gcs_block.upload_from_path(from_path=path, to_path=path)
    return


@flow()
def web_to_gcs() -> None:

    color = "fhv"
    color = "green"
    color = "yellow"

    year = 2019
    for month in range(1, 13):
        dataset_file = f"{color}_tripdata_{year}-{month:02}"
        dataset_url = f"https://github.com/DataTalksClub/nyc-tlc-data/releases/download/{color}/{dataset_file}.csv.gz"

        df = fetch(dataset_url)
        df_clean = clean(color, df)
        path = write_local(color, df_clean, dataset_file)
        write_gcs(path)


if __name__ == "__main__":
    web_to_gcs()
```

After, I ran this script successively for `color` = `fhv`, `yellow`, `green` and `year` = `2019`, `2020`.

``` bash
python web_to_gcs.py
```

You should see this on Prefect Orion UI.

![w4s14](dtc/w4s14.png)

You should see your buckets on Google Cloud.

![w4s15](dtc/w4s15.png)

Then, in BigQuery, I created the tables `fhv_2019`, `yellow_tripdata` and `green_tripdata` like this.

![w4s16](dtc/w4s16.png)

I now see the three tables under `trips_data_all`.

![w4s17](dtc/w4s17.png)

To check if everything is correct, I counted the number of rows of each of the tables.

``` sql
SELECT COUNT(*) FROM `hopeful-summer-375416.trips_data_all.fhv_2019`;
--- 43,244,696

SELECT COUNT(*) FROM `hopeful-summer-375416.trips_data_all.yellow_tripdata`;
--- 109,047,518

SELECT COUNT(*) FROM `hopeful-summer-375416.trips_data_all.green_tripdata`;
--- 7,778,101
```

### Setting up dbt with BigQuery (Alternative A)

On February 15, 2023, I created a free dbt account with BigQuery. Then I followed the instructions in this file
([dbt_cloud_setup.md](https://github.com/DataTalksClub/data-engineering-zoomcamp/blob/main/week_4_analytics_engineering/dbt_cloud_setup.md)).

In order to connect we need the service account JSON file generated from bigquery:

**Step 1**: Open the [BigQuery credential wizard](https://console.cloud.google.com/apis/credentials/wizard) to create a
service account in your taxi project

- **Select an API**: BigQuery API
- **What data will you be accessing?**: Application data
- **Are you planning to use this API with Compute Engine…​?** No, I’n not using them
- **Service account details**: dbt-service-account
- **Service account ID**: dbt-service-account (Email address:
  <dbt-service-account@hopeful-summer-375416.iam.gserviceaccount.com>)
- **Service account description**: Service account for dbt cloud
- **Role**: BigQuery Data Editor
- **Role**: BigQuery Job User
- **Role**: BigQuery User
- **Role**: BigQuery Admin

Click on **DONE** button.

I reuse the json file (`hopeful-summer-375416-c150de675a7d.json`) created in the previous weeks.

![w4s11](dtc/w4s11.png)

## Introduction to analytics engineering

> 00:00/7:14 (4.1.1) Analytics Engineering Basics

### What is Analytics Engineering?

> 1:02/7:14 (4.1.1) Roles in a data team

Roles in a data team:

- Data Engineer: Prepares and maintain the infrastructure the data team needs.
- Analytics Engineer: Introduces the good software engineering practices to the efforts of data analysts and data
  scientists
- Data Analyst: Uses data to answer questions and solve problems.

> 2:20/7:14 (4.1.1) Tooling

Tooling:

1. Data Loading
2. Data Storing (Cloud data warehouses like [Snowflake](https://www.snowflake.com/en/),
    [Bigquery](https://cloud.google.com/bigquery), [Redshift](https://aws.amazon.com/fr/redshift/))
3. Data modelling (Tools like dbt or Dataform)
4. Data presentation (BI tools like google data studio, [Looker](https://www.looker.com/), [Mode](https://mode.com/) or
    Tableau)

### Data Modelling concepts

> 3:06/7:14 (4.1.1) Data modeling concepts

In the ELP approach, we will transform the data once the date is already in the data warehouse.

<table>
<tr><td>
<img src="dtc/w4s01.png">
</td><td>
<img src="dtc/w4s02.png">
</td></tr>
</table>

**ETL vs ELT**

- ETL
  - Slightly more stable and compliant data analysis
  - Higher storage and compute costs
- ELT
  - Faster and more flexible data analysis.
  - Lower cost and lower maintenance

### Kimball’s Dimensional Modeling

> 4:17/7:14 (4.1.1) Kimball’s Dimensional Modeling

- Objective
  - Deliver data understandable to the business users
  - Deliver fast query performance
- Approach
  - Prioritise user understandability and query performance over non redundant data (3NF)
- Other approaches
  - Bill Inmon
  - Data vault

### Elements of Dimensional Modeling

> 5:05/7:14 (4.1.1) Elements of Dimensional Modeling

- Facts tables
  - Measurements, metrics or facts
  - Corresponds to a business *process*
  - "verbs"
- Dimensions tables
  - Corresponds to a business *entity*
  - Provides context to a business process
  - "nouns"

![w4s06](dtc/w4s06.png)

### Architecture of Dimensional Modeling

> 5:50/7:14 (4.1.1) Architecture of Dimensional Modeling

- Stage Area
  - Contains the raw data
  - Not meant to be exposed to everyone
- Processing area
  - From raw data to data models
  - Focuses in efficiency
  - Ensuring standards
- Presentation area
  - Final presentation of the data
  - Exposure to business stakeholder

## What is dbt?

> 0:00/4:59 (4.1.2) What is dbt?

[dbt](https://docs.getdbt.com/docs/introduction) is a transformation tool that allows anyone that knows SQL to deploy
analytics code following software engineering best practices like modularity, portability, CI/CD, and documentation.

### How does dbt work?

> 1:03/4:59 (4.1.2) How does dbt work?

**How does dbt work?**

![w4s03](dtc/w4s03.png)

- Each model is:
  - A `*.sql` file
  - Select statement, no DDL (*Data Definition Language*) or DML (*Data Manipulation Language*)
  - A file that dbt will compile and run in our DWH (*Data warehouse*)

### How to use dbt?

> 2:04/4:59 (4.1.2) How to use dbt?

- **dbt Core**: Open-source project that allows the data transformation.
  - Builds and runs a dbt project (.sql and .yml files)
  - Includes SQL compilation logic, macros and database adapters
  - Includes a CLI (*Command Line Interface*) interface to run dbt commands locally
  - Opens source and free to use
- **dbt Cloud**: SaaS (*Software As A Service*) application to develop and manage dbt projects.
  - Web-based IDE (*Integrated Development Environment*) to develop, run and test a dbt project
  - Jobs orchestration
  - Logging and Alerting
  - Integrated documentation
  - Free for individuals (one developer seat)

### How are we going to use dbt?

> 3:30/4:59 (4.1.2) How are we going to use dbt?

- **BigQuery (Alternative A)**:
  - Development using cloud IDE
  - No local installation of dbt core
- **Postgres (Alternative B)**:
  - Development using a local IDE of your choice.
  - Local installation of dbt core connecting to the Postgres database
  - Running dbt models through the CLI

At the end, our project will look like this.

**How are we going to use dbt?**

![w4s04](dtc/w4s04.png)

## Starting a dbt project

### Create a new dbt project

> 00:00/5:32 (4.2.1) Create a new dbt project presentation (cloud or terminal)

dbt provides an [starter project](https://github.com/dbt-labs/dbt-starter-project) with all the basic folders and files.

**Starter project structure**

``` txt
taxi_rides_ny/
  analysis/
  data/
  macros/
  models/example/
  snapshots/
  tests/
  .gitignore
  README.md
  dbt_project.yml
```

**Example of `dbt_project.yml`**

``` yaml
name: 'taxi_rides_ny'
version: '1.0.0'
config-version: 2

# This setting configures which "profile" dbt uses for this project.
profile: 'pg-dbt-workshop'  # Using Postgres + dbt core (locally) (Alternative B)
profile: 'default'          # Using BigQuery + dbt cloud (Alternative A)

# These configuration specify where dbt should look for different types of files.
# The `source-paths` config, for example, states that models in this project can be
# found in the "models/" directory. You probably win't need to change these!
model-paths: ["models"]
analysis-paths: ["analysis"]
test-paths: ["tests"]
seed-paths: ["data"]
macro-paths: ["macros"]
snapshot-paths: ["snapshots"]

target-path: "target"  # directory which will store compiled SQL files
clean-targets:         # directories to be removed by `dbt clean`
    - "target"
    - "dbt_packages"

# Configuring models
# Full decumentation: https://docs.getdbt.com/reference/model-configs

# In this example config, we tell dbt to build all models in the example/ directory
# as tables. These settings can be overridden in the individual model files
# using the `{{ config(...) }}` macro.
models:
    taxi_rides_ny:
        # Applies to all files under models/.../
        staging:
            materialized: view
        core:
            materialized: table
vars:
    payment_type_values: [1, 2, 3, 4, 5, 6]
```

See [About dbt projects](https://docs.getdbt.com/docs/build/projects) for more.

## With the CLI

> 1:50/5:32 (4.2.1) With the CLI

After having installed dbt locally and setup the `profiles.yml`, run [dbt
init](https://docs.getdbt.com/reference/commands/init) in the path we want to start the project to clone the starter
project.

But as I wrote before, I have chosen to continue with dbt cloud and BigQuery, i.e. alternative A.

### With dbt cloud

> 2:11/5:32 (4.2.1) With dbt cloud

After having set up the dbt cloud credentials (repo and dwh) we can start the project from the web-based IDE.

### Using BigQuery + dbt cloud (Alternative A)

> 02:25/5:32 (4.2.1) BigQuery dataset and schemas

On Google Cloud, under BigQuery section, we should have these datasets. Under `trips_data_all`, we should see
`green_tripdata` and `yellow_tripdata`.

![w4s12](dtc/w4s12.png)

> 03:10/5:32 (4.2.1) Repository structure

At the end, our github repository structure should look like the one from week 4 of the [Data Engineering
Zoomcamp](https://github.com/DataTalksClub/data-engineering-zoomcamp).

> 03:24/5:32 (4.2.1) Start the project in dbt cloud

On dbt cloud interface, we need to click on **Initialize your project** button. All of the folders are created.

![w4s08](dtc/w4s08.png)

> 04:05/5:32 (4.2.1) dbt_project.yml in dbt cloud

To be able to modify the files, you must first create a new branch and switch to it.

See [Checkout a new git
branch](https://docs.getdbt.com/docs/get-started/getting-started/building-your-first-project/build-your-first-models#checkout-a-new-git-branch).

We should change `dbt_project.yml` file like this.

**File `dbt_project.yml`**

``` yaml
# Name your project! Project names should contain only lowercase characters
# and underscores. A good package name should reflect your organization's
# name or the intended use of these models
name: 'taxi_rides_ny'  
version: '1.0.0'
config-version: 2

# This setting configures which "profile" dbt uses for this project.
profile: 'default'

# These configurations specify where dbt should look for different types of files.
# The `source-paths` config, for example, states that models in this project can be
# found in the "models/" directory. You probably won't need to change these!
model-paths: ["models"]
analysis-paths: ["analysis"]
test-paths: ["tests"]
seed-paths: ["seeds"]
macro-paths: ["macros"]
snapshot-paths: ["snapshots"]

target-path: "target"  # directory which will store compiled SQL files
clean-targets:         # directories to be removed by `dbt clean`
  - "target"
  - "dbt_packages"


# Configuring models
# Full documentation: https://docs.getdbt.com/docs/configuring-models

# In this example config, we tell dbt to build all models in the example/ directory
# as tables. These settings can be overridden in the individual model files
# using the `{{ config(...) }}` macro.
models:
  taxi_rides_ny:  
    # Applies to all files under models/example/
    example:
      materialized: view
```

- Name of the project: `taxi_rides_ny`.
- Name of the model: `taxi_rides_ny`.

## Build the first dbt models

### Anatomy of a dbt model

> 0:00/44:38 (4.3.1) Anatomy of a dbt model

**Anatomy of a dbt model**

![w4s05](dtc/w4s05.png)

In dbt, you can combine SQL with [Jinja](https://jinja.palletsprojects.com/), a templating language.

Using Jinja turns our dbt project into a programming environment for SQL, giving you the ability to do things that
aren’t normally possible in SQL (ie. evaluate an expression, variable or function call or print the result into the
template).

See [Jinja and macros](https://docs.getdbt.com/docs/build/jinja-macros) for more.

Materializations are strategies for persisting dbt models in a warehouse. There are four types of materializations built
into dbt. They are:

- table (most common)
- view (most common)
- incremental (useful for data that doesn’t really change every day)
- ephemeral ()

By default, dbt models are materialized as "views". Models can be configured with a different materialization by
supplying the `materialized` configuration parameter.

Materializations can be configured by default in `dbt-project.yml` or directly inside of the model `sql` files.

``` sql
{{ config(materialized='table') }}

select *
from ...
```

See [Materializations](https://docs.getdbt.com/docs/build/materializations) for more.

### The FROM clause of a dbt model

#### Sources

> 03:15/44:38 (4.3.1) The FROM clause: Sources and seeds

Sources make it possible to name and describe the data loaded into your warehouse by your Extract and Load tools.

- The data loaded to our dwh that we use as sources for our models
- Configuration defined in the yml files in the models folder
- Used with the source macro that will resolve the name to the right schema, plus build the dependencies automatically
- Source freshness can be defined and tested

See [Sources](https://docs.getdbt.com/docs/build/sources) for more.

**Example from file `models/staging/schema.yml`**

``` yaml
sources:
    - name: staging
      database: taxi-rides-ny-339813  # For bigquery
      schema: trips_data_all

      # loaded_at_field: record_loaded_at
      tables:
        - name: green_tripdata
        - name: yellow_tripdata
          freshness:
            error_after: {count: 6, period: hour}
```

The code below keeps only the first row of duplicates with the condition `where rn = 1`. See [4 Ways to Check for
Duplicate Rows in SQL Server](https://database.guide/4-ways-to-check-for-duplicate-rows-in-sql-server/).

**Example from file `models/staging/stg_green_tripdata.sql`**

``` sql
with tripdata as
(
  select *,
    row_number() over(partition by vendorid, lpep_pickup_datetime) as rn
  from {{ source('staging','green_tripdata') }}
  where vendorid is not null
)
```

#### Seeds

> 05:22/44:38 (4.3.1) The FROM clause: Seeds (CSV files)

Seeds are CSV files in your dbt project (typically in your `seeds` directory), that dbt can load into your data
warehouse using the `dbt seed` command.

- CSV files stored in our repository under the seed folder
- Benefits of version controlling
- Equivalent to a copy command
- Recommended for data that doesn’t change frequently
- Runs with `dbt seed -s file_name`

See [Seeds](https://docs.getdbt.com/docs/build/seeds) for more.

**Example `taxi_zone_loopup.csv`**

``` csv
"locationid","borough","zone","service_name"
...
```

**Example `models/core/dim_zones.sql`**

``` sql
select
    locationid,
    borough,
    zone,
    replace(service_zone,'Boro','Green') as service_zone
from {{ ref('taxi_zone_lookup') }}
```

#### Ref

> 06:40/44:38 (4.3.1) The FROM clause: ref macro

The most important function in dbt is `ref()`; it’s impossible to build even moderately complex models without it.
`ref()` is how you reference one model within another. This is a very common behavior, as typically models are built to
be "stacked" on top of one another.

- Macro to reference the underlying tables and views that were building the data warehouse
- Run the same code in any environment, it will resolve the correct schema for you
- Dependencies are built automatically

See [ref](https://docs.getdbt.com/reference/dbt-jinja-functions/ref) for more.

**dbt model (`models/core/fact_trips.sql`)**

``` sql
with green_data as (
    select *,
        'Green' as service_type
    from {{ ref('stg_green_tripdata') }}
),
```

This model will be translated in compiled code.

**Compiled code**

``` sql
with green_data as (
    select *,
        'Green' as service_type
    from "production"."dbt_aboisvert"."stg_green_tripdata"
),
```

### Create our first dbt model

> 08:38/44:38 (4.3.1) Define a source and develop the first model (stg_green_tripdata)

Create these folders and files under the dbt project `taxi_rides_ny` :

- `models/core`
- `models/staging`
  - `schema.yml`
  - `stg_green_tripdata.sql`

**File `models/staging/schema.yml`**

``` yaml
version: 2

sources:
    - name: staging
      # database: taxi-rides-ny-339813
      database: hopeful-summer-375416
      schema: trips_data_all

      tables:
        - name: green_tripdata
        - name: yellow_tripdata
```

**File `models/staging/stg_green_tripdata.sql`**

``` txt
{{ config(materialized="view") }}

select * from {{ source('staging', 'green_tripdata') }}
limit 100
```

![w4s13](dtc/w4s13.png)

Now, we can run this model with one of these following commands:

``` bash
dbt run  # Builds models in your target database.
dbt run --select stg_green_tripdata  # Builds a specific model.
dbt run --select stg_green_tripdata+  # Builds a specific model and its children.
dbt run --select +stg_green_tripdata  # Builds a specific model and its ancestors.
dbt run --select +stg_green_tripdata+  # Builds a specific model and its children and ancestors.
```

This is what appears in dbt Cloud after running the command `dbt run`.

![w4s18](dtc/w4s18.png)

> 16:06/44:38 (4.3.1)

Then we modify the query `models/staging/stg_green_tripdata.sql` by indicating the columns.

**File `models/staging/stg_green_tripdata.sql`**

``` txt
{{ config(materialized="view") }}

select
    -- identifiers
    cast(vendorid as integer) as vendorid,
    cast(ratecodeid as integer) as ratecodeid,
    cast(pulocationid as integer) as  pickup_locationid,
    cast(dolocationid as integer) as dropoff_locationid,

    -- timestamps
    cast(lpep_pickup_datetime as timestamp) as pickup_datetime,
    cast(lpep_dropoff_datetime as timestamp) as dropoff_datetime,

    -- trip info
    store_and_fwd_flag,
    cast(passenger_count as integer) as passenger_count,
    cast(trip_distance as numeric) as trip_distance,
    cast(trip_type as integer) as trip_type,

    -- payment info
    cast(fare_amount as numeric) as fare_amount,
    cast(extra as numeric) as extra,
    cast(mta_tax as numeric) as mta_tax,
    cast(tip_amount as numeric) as tip_amount,
    cast(tolls_amount as numeric) as tolls_amount,
    cast(ehail_fee as numeric) as ehail_fee,
    cast(improvement_surcharge as numeric) as improvement_surcharge,
    cast(total_amount as numeric) as total_amount,
    cast(payment_type as integer) as payment_type,
    cast(congestion_surcharge as numeric) as congestion_surcharge

from {{ source('staging', 'green_tripdata') }}
limit 100
```

I run this command.

``` bash
dbt run --select stg_green_tripdata
```

Then we go to BigQuery and we see that the view `stg_green_tripdata` is created.

![w4s19](dtc/w4s19.png)

### Macros

> 17:24/44:38 (4.3.1) Definition and usage of macros

[Macros](https://docs.getdbt.com/docs/build/jinja-macros#macros) in Jinja are pieces of code that can be reused multiple
times – they are analogous to "functions" in other programming languages, and are extremely useful if you find yourself
repeating code across multiple models. Macros are defined in `.sql` files, typically in your `macros` directory
([docs](https://docs.getdbt.com/reference/project-configs/macro-paths)).

- Use control structures (e.g. if statements and for loops) in SQL
- Use environment variables in your dbt project for production deployments
- Operate on the results of one query to generate another query
- Abstract snippets of SQL into reusable macros — these are analogous to functions in most programming languages.

Create these folders and files under `taxi_rides_ny`:

- `macros`
  - `get_payment_type_description.sql`

**Definition of the macro (`macros/get_payment_type_description.sql`)**

``` sql
{#
    This macro returns the description of the payment_type
#}

{% macro get_payment_type_description(payment_type) -%}

    case {{ payment_type }}
        when 1 then 'Credit card'
        when 2 then 'Cash'
        when 3 then 'No charge'
        when 4 then 'Dispute'
        when 5 then 'Unknown'
        when 6 then 'Voided trip'
    end

{%- endmacro %}
```

**Usage of the macro (`models/staging/stg_green_tripdata.sql`)**

``` sql
select ...
    cast(payment_type as integer) as payment_type,
    {{ get_payment_type_description('payment_type') }} as payment_type_description,
    cast(congestion_surcharge as numeric) as congestion_surcharge
from {{ source('staging', 'green_tripdata') }}
limit 100
```

**Compiled code of the macro**

``` sql
create of alter view production.dbt_aboisvert.stg_green_tripdata as
select ...
    case payment_type
        when 1 then 'Credit card'
        when 2 then 'Cash'
        when 3 then 'No charge'
        when 4 then 'Dispute'
        when 5 then 'Unknown'
        when 6 then 'Voided trip'
    end as payment_type_description,
    cast(congestion_surcharge as numeric) as congestion_surcharge
from "production"."staging"."green_tripdata"
limit 100
```

Then we run this again.

``` bash
dbt run --select stg_green_tripdata
```

Here the logs.

**File `console_output.txt`**

``` txt
16:35:46  Began running node model.taxi_rides_ny.stg_green_tripdata
16:35:46  1 of 1 START sql view model dbt_aboisvert.stg_green_tripdata ................... [RUN]
16:35:46  Acquiring new bigquery connection 'model.taxi_rides_ny.stg_green_tripdata'
16:35:46  Began compiling node model.taxi_rides_ny.stg_green_tripdata
16:35:46  Writing injected SQL for node "model.taxi_rides_ny.stg_green_tripdata"
16:35:46  Timing info for model.taxi_rides_ny.stg_green_tripdata (compile): 2023-02-16 16:35:46.674102 => 2023-02-16 16:35:46.696478
16:35:46  Began executing node model.taxi_rides_ny.stg_green_tripdata
16:35:46  Writing runtime sql for node "model.taxi_rides_ny.stg_green_tripdata"
16:35:46  Opening a new connection, currently in state closed
16:35:46  On model.taxi_rides_ny.stg_green_tripdata: /* {"app": "dbt", "dbt_version": "1.4.1", "profile_name": "user", "target_name": "default", "node_id": "model.taxi_rides_ny.stg_green_tripdata"} */


  create or replace view `hopeful-summer-375416`.`dbt_aboisvert`.`stg_green_tripdata`
  OPTIONS()
  as

select
    -- identifiers
    cast(vendorid as integer) as vendorid,
    cast(ratecodeid as integer) as ratecodeid,
    cast(pulocationid as integer) as  pickup_locationid,
    cast(dolocationid as integer) as dropoff_locationid,

    -- timestamps
    cast(lpep_pickup_datetime as timestamp) as pickup_datetime,
    cast(lpep_dropoff_datetime as timestamp) as dropoff_datetime,

    -- trip info
    store_and_fwd_flag,
    cast(passenger_count as integer) as passenger_count,
    cast(trip_distance as numeric) as trip_distance,
    cast(trip_type as integer) as trip_type,

    -- payment info
    cast(fare_amount as numeric) as fare_amount,
    cast(extra as numeric) as extra,
    cast(mta_tax as numeric) as mta_tax,
    cast(tip_amount as numeric) as tip_amount,
    cast(tolls_amount as numeric) as tolls_amount,
    cast(ehail_fee as numeric) as ehail_fee,
    cast(improvement_surcharge as numeric) as improvement_surcharge,
    cast(total_amount as numeric) as total_amount,
    cast(payment_type as integer) as payment_type,
    case payment_type
        when 1 then 'Credit card'
        when 2 then 'Cash'
        when 3 then 'No charge'
        when 4 then 'Dispute'
        when 5 then 'Unknown'
        when 6 then 'Voided trip'
    end as payment_type_description,
    cast(congestion_surcharge as numeric) as congestion_surcharge

from `hopeful-summer-375416`.`trips_data_all`.`green_tripdata`
limit 100;


16:35:47  BigQuery adapter: https://console.cloud.google.com/bigquery?project=hopeful-summer-375416&j=bq:northamerica-northeast1:381afe21-4234-411c-8b26-fb40d05ccfeb&page=queryresults
16:35:47  Timing info for model.taxi_rides_ny.stg_green_tripdata (execute): 2023-02-16 16:35:46.697099 => 2023-02-16 16:35:47.326019
16:35:47  Sending event: {'category': 'dbt', 'action': 'run_model', 'label': '0b79f185-7d06-49cf-ab1e-1b6cacff236b', 'context': [<snowplow_tracker.self_describing_json.SelfDescribingJson object at 0x7f42700e9fa0>]}
16:35:47  1 of 1 OK created sql view model dbt_aboisvert.stg_green_tripdata .............. CREATE VIEW (0 processed) in 0.65s
16:35:47  Finished running node model.taxi_rides_ny.stg_green_tripdata
```

You can also see the compiled code under **target \> compiled \> taxi_rides_ny \> models \> staging \>
stg_green_tripdata.sql**.

![w4s20](dtc/w4s20.png)

### Packages

> 24:10/44:38 (4.3.1) Importing and using dbt packages

dbt *packages* are in fact standalone dbt projects, with models and macros that tackle a specific problem area. As a dbt
user, by adding a package to your project, the package’s models and macros will become part of your own project

- Like libraries in other programming languages
- Standalone dbt projects, with models and macros that tackle a specific problem area.
- By adding a package to your project, the package’s models and macros will become part of your own project.
- Imported in the `packages.yml` file and imported by running `dbt deps`
- A list of useful packages can be find in [dbt package hub](https://hub.getdbt.com/).

See [Packages](https://docs.getdbt.com/docs/build/packages) for more.

**Specifications of the packages to import in the project (`packages.yml`)**

``` yaml
packages:
  - package: dbt-labs/dbt_utils
    version: 0.8.0
```

To install this package, run this command:

``` bash
dbt deps
```

We should see this logs and a lot of folders and files created under `dbt_packages/dbt_utils`.

<table>
<tr><td>
<img src="dtc/w4s21.png">
</td><td>
<img src="dtc/w4s22.png">
</td></tr>
</table>

Let’s go back to the model.

**Usage of a macro from a package (`models/staging/stg_green_tripdata.sql`).**

``` sql
{{ config(materialized='view') }}

select
    -- identifiers
    {{ dbt_utils.surrogate_key(['vendorid', 'lpep_pickup_datetime']) }} as tripid,
    cast(vendorid as integer) as vendorid,
    cast(ratecodeid as integer) as ratecodeid,
    ...
```

Now, let’s run this with this command.

``` bash
dbt run --select stg_green_tripdata
```

Here the compiled code.

**File `target/compiled/taxi_rides_ny/models/staging/stg_green_tripdata.sql`.**

``` sql
select
    -- identifiers
    to_hex(md5(cast(coalesce(cast(vendorid as
    string
), '') || '-' || coalesce(cast(lpep_pickup_datetime as
    string
), '') as
    string
))) as tripid,
    cast(vendorid as integer) as vendorid,
    cast(ratecodeid as integer) as ratecodeid,
...
```

### Variables

> 29:18/44:38 (4.3.1) Definition of variables and setting a variable from the cli

dbt provides a mechanism, [variables](https://docs.getdbt.com/reference/dbt-jinja-functions/var), to provide data to
models for compilation. Variables can be used to [configure
timezones](https://github.com/dbt-labs/snowplow/blob/0.3.9/dbt_project.yml#L22), [avoid hardcoding table
names](https://github.com/dbt-labs/quickbooks/blob/v0.1.0/dbt_project.yml#L23) or otherwise provide data to models to
configure how they are compiled.

- Variables are useful for defining values that should be used across the project
- With a macro, dbt allows us to provide data to models for compilation
- To use a variable we use the `{{ var('…​') }}` function
- Variables can defined in two ways:
  - In the `dbt_project.yml` file
  - On the command line

See [Project variables](https://docs.getdbt.com/docs/build/project-variables) for more.

**Global variable we define under `dbt_project.yml`.**

``` yaml
vars:
  payment_type_values: [1, 2, 3, 4, 5, 6]
```

**Variable whose value we can change via CLI (`models/staging/stg_green_tripdata.sql`).**

``` sql
from {{ source('staging', 'green_tripdata') }}
where vendorid is not null

-- dbt build --m <model.sql> --var 'is_test_run: false'
{% if var('is_test_run', default=true) %}

  limit 100

{% endif %}
```

Then, we can run the model.

``` bash
dbt build --m stg_green_tripdata --var 'is_test_run: false'
```

> 33:33/44:38 (4.3.1) Add second model (stg_yellow_tripdata)

We make the same changes for `models/staging/stg_yellow_tripdata.sql`.

**File `models/staging/stg_yellow_tripdata.sql`**

``` sql
{{ config(materialized='view') }}

select
   -- identifiers
    {{ dbt_utils.surrogate_key(['vendorid', 'tpep_pickup_datetime']) }} as tripid,
    cast(vendorid as integer) as vendorid,
    cast(ratecodeid as integer) as ratecodeid,
    cast(pulocationid as integer) as  pickup_locationid,
    cast(dolocationid as integer) as dropoff_locationid,

    -- timestamps
    cast(tpep_pickup_datetime as timestamp) as pickup_datetime,
    cast(tpep_dropoff_datetime as timestamp) as dropoff_datetime,

    -- trip info
    store_and_fwd_flag,
    cast(passenger_count as integer) as passenger_count,
    cast(trip_distance as numeric) as trip_distance,
    -- yellow cabs are always street-hail
    1 as trip_type,

    -- payment info
    cast(fare_amount as numeric) as fare_amount,
    cast(extra as numeric) as extra,
    cast(mta_tax as numeric) as mta_tax,
    cast(tip_amount as numeric) as tip_amount,
    cast(tolls_amount as numeric) as tolls_amount,
    cast(0 as numeric) as ehail_fee,
    cast(improvement_surcharge as numeric) as improvement_surcharge,
    cast(total_amount as numeric) as total_amount,
    cast(payment_type as integer) as payment_type,
    {{ get_payment_type_description('payment_type') }} as payment_type_description,
    cast(congestion_surcharge as numeric) as congestion_surcharge

from {{ source('staging', 'yellow_tripdata') }}
where vendorid is not null

-- dbt build --m <model.sql> --var 'is_test_run: false'
{% if var('is_test_run', default=true) %}

  limit 100

{% endif %}
```

Now use `dbt run` because we have two models…​

``` bash
dbt run --var 'is_test_run: false'
```

We should see this log and `stg_yellow_tripdata` created in BigQuery (we need to refresh the page).

<table>
<tr><td>
<img src="dtc/w4s23.png">
</td><td>
<img src="dtc/w4s24.png">
</td></tr>
</table>

> 35:16/44:38 (4.3.1) Creating and using dbt seed (taxi_zones_lookup and dim_zone)

The dbt [seed](https://docs.getdbt.com/reference/commands/seed) command will load `csv` files located in the seed-paths
directory of your dbt project into your data warehouse.

In our dbt cloud, create `seeds` folder, create the file `seeds/taxi_zone_loopup.csv` and paste in it the content of
that [csv
file](https://raw.githubusercontent.com/DataTalksClub/data-engineering-zoomcamp/main/week_4_analytics_engineering/taxi_rides_ny/data/taxi_zone_lookup.csv).

After, run the command `dbt seed` to create table `taxi_zone_loopup` in BigQuery. We should have 265 lines.

We need to specify the data types of the csv file in `dbt_project.yml`.

**File `dbt_project.yml`**

``` yaml
seeds:
    taxi_rides_ny:
        taxi_zone_lookup:
            +column_types:
                locationid: numeric
```

If we slightly modify data (for example, change `1,"EWR","Newark Airport","EWR"` for `1,"NEWR","Newark Airport","EWR"`)
in the csv file, we can run the following command:

``` bash
dbt seed --full-refresh
```

We can see the change in the BigQuery table `taxi_zone_loopup`.

![w4s25](dtc/w4s25.png)

Then, create the file `models/core/dim_zones.sql`.

**File `models/core/dim_zones.sql`**

``` sql
{{ config(materialized='table') }}


select
    locationid,
    borough,
    zone,
    replace(service_zone,'Boro','Green') as service_zone
from {{ ref('taxi_zone_lookup') }}
```

Ideally, we want everything in the directory to be tables to have efficient queries.

![w4s26](dtc/w4s26.png)

> 41:20/44:38 (4.3.1) Unioning our models in fact_trips and understanding dependencies

Now, create the model `models/core/fact_trips.sql`.

**File `models/core/fact_trips.sql`**

``` sql
{{ config(materialized='table') }}

with green_data as (
    select *,
        'Green' as service_type
    from {{ ref('stg_green_tripdata') }}
),

yellow_data as (
    select *,
        'Yellow' as service_type
    from {{ ref('stg_yellow_tripdata') }}
),

trips_unioned as (
    select * from green_data
    union all
    select * from yellow_data
),

dim_zones as (
    select * from {{ ref('dim_zones') }}
    where borough != 'Unknown'
)
select
    trips_unioned.tripid,
    trips_unioned.vendorid,
    trips_unioned.service_type,
    trips_unioned.ratecodeid,
    trips_unioned.pickup_locationid,
    pickup_zone.borough as pickup_borough,
    pickup_zone.zone as pickup_zone,
    trips_unioned.dropoff_locationid,
    dropoff_zone.borough as dropoff_borough,
    dropoff_zone.zone as dropoff_zone,
    trips_unioned.pickup_datetime,
    trips_unioned.dropoff_datetime,
    trips_unioned.store_and_fwd_flag,
    trips_unioned.passenger_count,
    trips_unioned.trip_distance,
    trips_unioned.trip_type,
    trips_unioned.fare_amount,
    trips_unioned.extra,
    trips_unioned.mta_tax,
    trips_unioned.tip_amount,
    trips_unioned.tolls_amount,
    trips_unioned.ehail_fee,
    trips_unioned.improvement_surcharge,
    trips_unioned.total_amount,
    trips_unioned.payment_type,
    trips_unioned.payment_type_description,
    trips_unioned.congestion_surcharge
from trips_unioned
inner join dim_zones as pickup_zone
on trips_unioned.pickup_locationid = pickup_zone.locationid
inner join dim_zones as dropoff_zone
on trips_unioned.dropoff_locationid = dropoff_zone.locationid
```

We have this.

![w4s09](dtc/w4s09.png)

The `dbt run` command will create everything, except the seeds. I we also want to run the seeds, we will use `dbt build`
command.

<table>
<tr><td>
<img src="dtc/w4s27a.png">
</td><td>
<img src="dtc/w4s27b.png">
</td></tr>
</table>

The command `dbt build --select fast_trips` will only run the model `fact_trips`.

The command `dbt build --select +fast_trips` will run everything that `fact_trips` need. dbt already konws the
dependencies.

## Testing and documenting dbt models

### Tests

> 0:00/13:51 (4.3.2) Testing

Tests are assertions you make about your models and other resources in your dbt project (e.g. sources, seeds and
snapshots). When you run dbt test, dbt will tell you if each test in your project passes or fails.

- Assumptions that we make about our data
- Tests in dbt are essentially a `select` sql query
- These assumptions get compiled to sql that returns the amount of failing records
- Test are defined on a column in the .yml file
- dbt provides basic tests to check if the column values are:
  - Unique
  - Not null
  - Accepted values
  - A foreign key to another table
- You can create your custom tests as queries

See [Tests](https://docs.getdbt.com/docs/build/tests) for more.

**Compiled code of the `not_null` test.**

``` sql
select *
from "production"."dbt_aboisvert"."stg_yellow_tripdata"
where tripid is null
```

**Definition of basic tests in the .yml files (`models/staging/schema.yml`)**

``` yaml
- name: Payment_type
  description: >
    A numeric code signifying how the passenger paid for the trip.
  tests:
    - accepted_values:
        values: "{{ var('payment_type_values') }}"  # [1,2,3,4,5]
        severity: warn
        quote: false
[...]
- name: Pickup_locationid
  description: locationid where the meter was engaged.
  tests:
    - relationships:
        to: ref('taxi_zone_lookup')
        field: locationid
        severity: warn
[...]
columns:
    - name: tripid
      description: Primary key for this table, generated with a concatenation of vendorid+pickup_datetime
      tests:
        - unique:
            severity: warn
        - not_null:
            severity: warn
```

**Warnings in the CLI from running `dbt test`.**

![w4s28](dtc/w4s28.png)

### Documentation

> 3:17/13:51 (4.3.2) Documentation

- dbt provides a way to generate documentation for your dbt project and render it as a website.
- The documentation for your project includes:
  - **Information about your project**:
    - Model code (both from the `.sql` file and compiled)
    - Model dependencies
    - Sources
    - Auto generated DAG from the ref and source macros
    - Descriptions (from `.yml` file) and tests
  - **Information about your data warehouse (information_schema)**:
    - Column names and data types
    - Table stats like size and rows

- `dbt docs` can also be hosted in dbt cloud

See [About documentation](https://docs.getdbt.com/docs/collaborate/documentation) for more.

**Example from `models/core/schema.yml`**

``` yaml
version: 2

models:
  - name: dim_zones
    description: >
      List of unique zones idefied by locationid.
      Includes the service zone they correspond to (Green or yellow).
  - name: fact_trips
    description: >
      Taxi trips corresponding to both service zones (Green and yellow).
      The table contains records where both pickup and dropoff locations are valid and known zones.
      Each record corresponds to a trip uniquely identified by tripid.

  - name: dm_monthly_zone_revenue
    description: >
      Aggregated table of all taxi trips corresponding to both service zones (Green and yellow) per pickup zone, month and service.
      The table contains monthly sums of the fare elements used to calculate the monthly revenue.
      The table contains also monthly indicators like number of trips, and average trip distance.
    columns:
      - name: revenue_monthly_total_amount
        description: Monthly sum of the the total_amount of the fare charged for the trip per pickup zone, month and service.
        tests:
            - not_null:
                severity: error
```

## Deploying a dbt project

> 4:28/13:51 (4.3.2) Deployment

We define a model in this file `models/core/dm_monthly_zone_revenue.sql`.

**File `models/core/dm_monthly_zone_revenue.sql`**

``` sql
{{ config(materialized='table') }}

with trips_data as (
    select * from {{ ref('fact_trips') }}
)
    select
    -- Reveneue grouping
    pickup_zone as revenue_zone,
    -- date_trunc('month', pickup_datetime) as revenue_month,
    -- Note: For BQ use instead: date_trunc(pickup_datetime, month) as revenue_month,
    date_trunc(pickup_datetime, month) as revenue_month,

    service_type,

    -- Revenue calculation
    sum(fare_amount) as revenue_monthly_fare,
    sum(extra) as revenue_monthly_extra,
    sum(mta_tax) as revenue_monthly_mta_tax,
    sum(tip_amount) as revenue_monthly_tip_amount,
    sum(tolls_amount) as revenue_monthly_tolls_amount,
    sum(ehail_fee) as revenue_monthly_ehail_fee,
    sum(improvement_surcharge) as revenue_monthly_improvement_surcharge,
    sum(total_amount) as revenue_monthly_total_amount,
    sum(congestion_surcharge) as revenue_monthly_congestion_surcharge,

    -- Additional calculations
    count(tripid) as total_monthly_trips,
    avg(passenger_count) as avg_montly_passenger_count,
    avg(trip_distance) as avg_montly_trip_distance

    from trips_data
    group by 1,2,3
```

Then, we add another section to define the model inside `models/staging/schema.yml`. This section is used in particular
to document the model and to add tests.

**File `models/staging/schema.yml`**

``` yaml
models:
    - name: stg_green_tripdata
      description: >
        Trip made by green taxis, also known as boro taxis and street-hail liveries.
        Green taxis may respond to street hails,but only in the areas indicated in green on the
        map (i.e. above W 110 St/E 96th St in Manhattan and in the boroughs).
        The records were collected and provided to the NYC Taxi and Limousine Commission (TLC) by
        technology service providers.
      columns:
          - name: tripid
            description: Primary key for this table, generated with a concatenation of vendorid+pickup_datetime
            tests:
                - unique:
                    severity: warn
                - not_null:
                    severity: warn
          - name: VendorID
            description: >
                A code indicating the TPEP provider that provided the record.
                1= Creative Mobile Technologies, LLC;
                2= VeriFone Inc.
          - name: pickup_datetime
            description: The date and time when the meter was engaged.
          - name: dropoff_datetime
            description: The date and time when the meter was disengaged.
          - name: Passenger_count
            description: The number of passengers in the vehicle. This is a driver-entered value.
          - name: Trip_distance
            description: The elapsed trip distance in miles reported by the taximeter.
          - name: Pickup_locationid
            description: locationid where the meter was engaged.
            tests:
              - relationships:
                  to: ref('taxi_zone_lookup')
                  field: locationid
                  severity: warn
          - name: dropoff_locationid
            description: locationid where the meter was engaged.
            tests:
              - relationships:
                  to: ref('taxi_zone_lookup')
                  field: locationid
          - name: RateCodeID
            description: >
                The final rate code in effect at the end of the trip.
                  1= Standard rate
                  2=JFK
                  3=Newark
                  4=Nassau or Westchester
                  5=Negotiated fare
                  6=Group ride
          - name: Store_and_fwd_flag
            description: >
              This flag indicates whether the trip record was held in vehicle
              memory before sending to the vendor, aka “store and forward,”
              because the vehicle did not have a connection to the server.
                Y= store and forward trip
                N= not a store and forward trip
          - name: Dropoff_longitude
            description: Longitude where the meter was disengaged.
          - name: Dropoff_latitude
            description: Latitude where the meter was disengaged.
          - name: Payment_type
            description: >
              A numeric code signifying how the passenger paid for the trip.
            tests:
              - accepted_values:
                  values: "{{ var('payment_type_values') }}"  
                  severity: warn
                  quote: false
          - name: payment_type_description
            description: Description of the payment_type code
          - name: Fare_amount
            description: >
              The time-and-distance fare calculated by the meter.
              Extra Miscellaneous extras and surcharges. Currently, this only includes
              the $0.50 and $1 rush hour and overnight charges.
              MTA_tax $0.50 MTA tax that is automatically triggered based on the metered
              rate in use.
          - name: Improvement_surcharge
            description: >
              $0.30 improvement surcharge assessed trips at the flag drop. The
              improvement surcharge began being levied in 2015.
          - name: Tip_amount
            description: >
              Tip amount. This field is automatically populated for credit card
              tips. Cash tips are not included.
          - name: Tolls_amount
            description: Total amount of all tolls paid in trip.
          - name: Total_amount
            description: The total amount charged to passengers. Does not include cash tips.
```

- We define the variable `payment_type_values` in the `dbt_project.yml`.

Next, we define the variable `payment_type_values` in the `dbt_project.yml`.

**File `dbt_project.yml`**

``` yaml
vars:
  payment_type_values: [1, 2, 3, 4, 5, 6]
```

> 9:04/13:51 (4.3.2) Run dbt test

Then, run `dbt test` or one of the following commands:

``` bash
dbt test                               # Run tests on data in deployed models.
dbt test --select stg_green_tripdata   # Run tests on data in specified model.
dbt test --select stg_green_tripdata+  # Run tests on data in specified model and its children.
dbt test --select +stg_green_tripdata  # Run tests on data in specified model and its ancestors.
dbt build  # Run the seeds, run the tests and run the models.
```

![w4s29](dtc/w4s29.png)

We see that the key `tripid` of the `stg_green_tripdata` table is not unique contrary to what we thought.

See [tests](https://docs.getdbt.com/reference/resource-properties/tests) and [Configuring test
`severity`](https://docs.getdbt.com/reference/resource-configs/severity) for more information about tests.

Finally, we add a part at the beginning of the sql files and change the source.

The code below keeps only the first row of duplicates with the condition `where rn = 1`. See [4 Ways to Check for
Duplicate Rows in SQL Server](https://database.guide/4-ways-to-check-for-duplicate-rows-in-sql-server/).

**File `models/staging/stg_green_tripdata.sql`**

``` sql
with tripdata as
(
  select *,
    row_number() over(partition by vendorid, lpep_pickup_datetime) as rn
  from {{ source('staging','green_tripdata') }}
  where vendorid is not null
)
select
...
from tripdata
where rn = 1
```

**File `models/staging/stg_yellow_tripdata.sql`**

``` sql
with tripdata as
(
  select *,
    row_number() over(partition by vendorid, tpep_pickup_datetime) as rn
  from {{ source('staging','yellow_tripdata') }}
  where vendorid is not null
)
select
...
from tripdata
where rn = 1
```

Run `dbt build` command and everything should be green.

<table>
<tr><td>
<img src="dtc/w4s31.png">
</td><td>
<img src="dtc/w4s30.png">
</td></tr>
</table>

Finally, create `models/core/schema.yml` to comple the project.

**File `models/core/schema.yml`**

``` yaml
version: 2

models:
  - name: dim_zones
    description: >
      List of unique zones idefied by locationid.
      Includes the service zone they correspond to (Green or yellow).
  - name: fact_trips
    description: >
      Taxi trips corresponding to both service zones (Green and yellow).
      The table contains records where both pickup and dropoff locations are valid and known zones.
      Each record corresponds to a trip uniquely identified by tripid.

  - name: dm_monthly_zone_revenue
    description: >
      Aggregated table of all taxi trips corresponding to both service zones (Green and yellow) per pickup zone, month and service.
      The table contains monthly sums of the fare elements used to calculate the monthly revenue.
      The table contains also monthly indicators like number of trips, and average trip distance.
    columns:
      - name: revenue_monthly_total_amount
        description: Monthly sum of the the total_amount of the fare charged for the trip per pickup zone, month and service.
        tests:
            - not_null:
                severity: error
```

### What is deployment?

> 0:00/13:56 (4.4.1) Theory

Running dbt in production means setting up a system to run a *dbt job on a schedule*, rather than running dbt commands
manually from the command line.

In addition to setting up a schedule, there are other considerations when setting up dbt to run in production.

- Process of running the models we created in our development environment in a production environment
- Development and later deployment allows us to continue building models and testing them without affecting our
  production environment
- A deployment environment will normally have a different schema in our data warehouse and ideally a different user
- A development - deployment workflow will be something like:
  - Develop in a user branch
  - Open a PR to merge into the main branch
  - Merge the branch to the main branch
  - Run the new models in the production environment using the main branch
  - Schedule the models

![w4s10](dtc/w4s10.png)

See [About deployments](https://docs.getdbt.com/docs/deploy/deployments) for more.

### Running a dbt project in production

> 1:47/13:56 (4.4.1) Running a dbt project in production

- dbt cloud includes a scheduler where to create jobs to run in production
- A single job can run multiple commands
- Jobs can be triggered manually or on schedule
- Each job will keep a log of the runs over time
- Each run will have the logs for each command
- A job could also generate documentation, that could be viewed under the run information
- If dbt source freshness was run, the results can also be viewed at the end of a job

### What is Continuous Integration (CI)?

> 3:35/13:56 (4.4.1) What is Continuous Integration (CI)?

- CI is the practice of regularly merge development branches into a central repository, after which automated builds and
  tests are run.
- The goal is to reduce adding bugs to the production code and maintain a more stable project.
- dbt allows us to enable CI on pull requests (PR)
- Enabled via webhooks from GitHub or GitLab
- When a PR is ready to be merged, a webhooks is received in dbt Cloud that will enqueue a new run of the specified job.
- The run of the CI job will be against a temporary schema
- No PR will be able to be merged unless the run has been completed successfully

### How to do this with dbt cloud (Alternative A)

> 5:10/13:56 (4.4.1) How to do this with dbt cloud (Alternative A)

In dbt cloud, commit **my-new-branch** and pull request. Next, in my GitHub repository
[taxi_rides_ny](https://github.com/boisalai/taxi_rides_ny), I merge this pull request to my **main branch**.

> 6:02/13:56 (4.4.1) Environments

Now go to **Environments** (**Deploy \> Environments**) and click on **Create Environment** button.

Create the new environment with this information:

- **Name**: Production
- **dbt Version**: 1.4 (latest)
- **Dataset**: production

Click on **Save** button.

<table>
<tr><td>
<img src="dtc/w4s32.png">
</td><td>
<img src="dtc/w4s33.png">
</td></tr>
</table>

> 7:05/13:56 (4.4.1) Jobs

Now go to **Jobs** (**Deploy \> Jobs**) and click on **Create New Job** button.

Create the new job with this information:

- **Job Name**: dbt build
- **Environment**: Production
- **dbt Version**: Inherited from Production (1.4 (latest))
- **Target Name**: default
- **Threads**: 4
- **Run Timeout**: 0
- **Generate docs on run**: Selected
- **Commands**:
  - `dbt seed`
  - `dbt run --var 'is_test_run: false'`
  - `dbt test --var 'is_test_run: false'`
- **Triggers**:
  - **Run on schedule**: Selected
  - Every day
  - Every 6 hours (starting at modnight UTC)

Under **Continous Integration (CI)** tab, we could select **Run on Pull Request** if we want to.

Click on **Save** button.

> 8:57/13:56 (4.4.1) Let’s run this.

Let’s run this by clicking on **Run now** button.

**Run Overview**

![w4s34](dtc/w4s34.png)

We should see :

- **Run Timing** tab showing run steps
- **Model Timing** tab (unfortunately, the diagram does not appear)
- **Artifacts** tab showing all generated files
- **View Documentation** link showing the documentation in a beautiful website.

Under **Run Timing** tab, below the log for `dbt run --var 'is_test_run: false'`.

✅ **Invoke** `dbt run --var 'is_test_run: false'`

``` txt
14:53:46  Running with dbt=1.4.1
14:53:46  Found 5 models, 11 tests, 0 snapshots, 0 analyses, 522 macros, 0 operations, 1 seed file, 2 sources, 0 exposures, 0 metrics          376 macros...
14:53:46
14:53:47  Concurrency: 4 threads (target='default')
14:53:47
14:53:47  1 of 5 START sql table model production.dim_zones .............................. [RUN]
14:53:47  2 of 5 START sql view model production.stg_green_tripdata ...................... [RUN]
14:53:47  3 of 5 START sql view model production.stg_yellow_tripdata ..................... [RUN]
14:53:47  3 of 5 OK created sql view model production.stg_yellow_tripdata ................ [CREATE VIEW (0 processed) in 0.60s]
14:53:48  2 of 5 OK created sql view model production.stg_green_tripdata ................. [CREATE VIEW (0 processed) in 0.85s]
14:53:49  1 of 5 OK created sql table model production.dim_zones ......................... [CREATE TABLE (265.0 rows, 14.2 KB processed) in 1.83s]     265
14:53:49  4 of 5 START sql table model production.fact_trips ............................. [RUN]
14:54:04  4 of 5 OK created sql table model production.fact_trips ........................ [CREATE TABLE (61.6m rows, 15.1 GB processed) in 15.00s]    101
14:54:04  5 of 5 START sql table model production.dm_monthly_zone_revenue ................ [RUN]
14:54:07  5 of 5 OK created sql table model production.dm_monthly_zone_revenue ........... [CREATE TABLE (12.0k rows, 13.4 GB processed) in 3.07s]     40
14:54:07
14:54:07  Finished running 2 view models, 3 table models in 0 hours 0 minutes and 20.26 seconds (20.26s).
14:54:07
14:54:07  Completed successfully
14:54:07
14:54:07  Done. PASS=5 WARN=0 ERROR=0 SKIP=0 TOTAL=5
```

Under **Run Timing** tab, below the log for `dbt test --var 'is_test_run: false'`.

✅ **Invoke** `dbt test --var 'is_test_run: false'`

``` txt
15:59:43  Running with dbt=1.4.1
15:59:43  Found 5 models, 11 tests, 0 snapshots, 0 analyses, 522 macros, 0 operations, 1 seed file, 2 sources, 0 exposures, 0 metrics
15:59:43
15:59:44  Concurrency: 4 threads (target='default')
15:59:44
15:59:44  1 of 11 START test accepted_values_stg_green_tripdata_Payment_type__False___var_payment_type_values_  [RUN]
15:59:44  2 of 11 START test accepted_values_stg_yellow_tripdata_Payment_type__False___var_payment_type_values_  [RUN]
15:59:44  3 of 11 START test not_null_dm_monthly_zone_revenue_revenue_monthly_total_amount  [RUN]
15:59:44  4 of 11 START test not_null_stg_green_tripdata_tripid .......................... [RUN]
15:59:44  3 of 11 PASS not_null_dm_monthly_zone_revenue_revenue_monthly_total_amount ..... [PASS in 0.80s]
15:59:44  5 of 11 START test not_null_stg_yellow_tripdata_tripid ......................... [RUN]
15:59:46  2 of 11 PASS accepted_values_stg_yellow_tripdata_Payment_type__False___var_payment_type_values_  [PASS in 2.59s]
15:59:46  6 of 11 START test relationships_stg_green_tripdata_Pickup_locationid__locationid__ref_taxi_zone_lookup_  [RUN]
15:59:47  5 of 11 PASS not_null_stg_yellow_tripdata_tripid ............................... [PASS in 2.26s]
15:59:47  7 of 11 START test relationships_stg_green_tripdata_dropoff_locationid__locationid__ref_taxi_zone_lookup_  [RUN]
15:59:47  1 of 11 PASS accepted_values_stg_green_tripdata_Payment_type__False___var_payment_type_values_  [PASS in 3.09s]
15:59:47  8 of 11 START test relationships_stg_yellow_tripdata_Pickup_locationid__locationid__ref_taxi_zone_lookup_  [RUN]
15:59:49  6 of 11 PASS relationships_stg_green_tripdata_Pickup_locationid__locationid__ref_taxi_zone_lookup_  [PASS in 2.83s]
15:59:49  9 of 11 START test relationships_stg_yellow_tripdata_dropoff_locationid__locationid__ref_taxi_zone_lookup_  [RUN]
15:59:49  8 of 11 PASS relationships_stg_yellow_tripdata_Pickup_locationid__locationid__ref_taxi_zone_lookup_  [PASS in 2.82s]
15:59:49  10 of 11 START test unique_stg_green_tripdata_tripid ........................... [RUN]
15:59:50  7 of 11 PASS relationships_stg_green_tripdata_dropoff_locationid__locationid__ref_taxi_zone_lookup_  [PASS in 3.04s]
15:59:50  11 of 11 START test unique_stg_yellow_tripdata_tripid .......................... [RUN]
15:59:50  4 of 11 PASS not_null_stg_green_tripdata_tripid ................................ [PASS in 6.46s]
15:59:52  9 of 11 PASS relationships_stg_yellow_tripdata_dropoff_locationid__locationid__ref_taxi_zone_lookup_  [PASS in 2.82s]
15:59:53  10 of 11 PASS unique_stg_green_tripdata_tripid ................................. [PASS in 3.06s]
15:59:54  11 of 11 PASS unique_stg_yellow_tripdata_tripid ................................ [PASS in 4.16s]
15:59:54
15:59:54  Finished running 11 tests in 0 hours 0 minutes and 10.41 seconds (10.41s).
15:59:54
15:59:54  Completed successfully
15:59:54
15:59:54  Done. PASS=11 WARN=0 ERROR=0 SKIP=0 TOTAL=11
```

<table>
<tr><td>
<img src="dtc/w4s35.png">
</td><td>
<img src="dtc/w4s36.png">
</td></tr>
</table>

Documentation

> 12:23/13:56 (4.4.1) Account Settings

Go back to dbt cloud, go to **Account Settings**. Select the project **Analytics**. Under **Artifacts**, I could select
the previous job.

Click on **Save** button. Now, I have the documentation of the project directly in dbt cloud.

## Visualize data with Looker Studio (Alternative A)

### Looker Studio (Google Data Studio)

> 0:00/20:00 (4.5.1) Google Data Studio

Looker Studio, formerly Google Data Studio, is an online tool for converting data into customizable informative reports
and dashboards introduced by Google on March 15, 2016 as part of the enterprise Google Analytics 360 suite. In May 2016,
Google announced a free version of Data Studio for individuals and small teams. See
<https://en.wikipedia.org/wiki/Looker_Studio>.

Go to [Looker Studio](https://lookerstudio.google.com/u/0/) and follow these steps:

- Make sure you are in the correct Google account.
- Create a **Data sources**.
- Select **BigQuery**.
- **Authorize** Looker Studio to connect to your **BigQuery** projects.
- Select the project id `dtc-dez`.
- Select dataset `production`.
- Select table `fact_trips`.
- Click on **CONNECT** button.

<table>
<tr><td>
<img src="dtc/w4s37.png">
</td><td>
<img src="dtc/w4s38.png">
</td></tr>
</table>

> 1:50/20:00 (4.5.1) Changes default aggregations

Changes default aggregations. Select **Sum** only for `passenger_count`.

> 3:18/20:00 (4.5.1) Creates report

We create 5 charts:

- Between 4:23 and 8:24, we create a time series chart for **Amount of trip per day and service type**.
- Change default data range from **1 January 2019** to **31 December 2020**.
- Between 8:29 and 9:53, we create a scorecard for **Total trips recorded**
- Between 9:58 and 11:14, we create a pie chart for **Service type distribution**.
- Between 11:33 and 12:58, we create a table for **Trips per pickup zone**.
- Between 13:04 and 18:06, we create a stacked column bar for **Trips per month and year**.

We should some thing like this.

![w4s41](dtc/w4s41.png)

In BigQuery, I run this.

``` sql
SELECT COUNT(*) FROM `hopeful-summer-375416.production.fact_trips`;
-- 61,616,556
```

**Warning**: I may have an error. I should check since I get at 61,616,556 trips recorded while the instructor get at
61,636,714 (see video 4.5.1 at 10:56).

## Advanced knowledge

- [Make a model
  Incremental](https://docs.getdbt.com/docs/building-a-dbt-project/building-models/configuring-incremental-models)
- [Use of tags](https://docs.getdbt.com/reference/resource-configs/tags)
- [Hooks](https://docs.getdbt.com/docs/building-a-dbt-project/hooks-operations)
- [Analysis](https://docs.getdbt.com/docs/building-a-dbt-project/analyses)
- [Snapshots](https://docs.getdbt.com/docs/building-a-dbt-project/snapshots)
- [Exposure](https://docs.getdbt.com/docs/building-a-dbt-project/exposures)
- [Metrics](https://docs.getdbt.com/docs/building-a-dbt-project/metrics)

## Workshop: Maximizing Confidence in Your Data Model Changes with dbt and PipeRider

To learn how to use PipeRider together with dbt for detecting changes in model and data, sign up for a workshop
[here](https://www.eventbrite.com/e/maximizing-confidence-in-your-data-model-changes-with-dbt-and-piperider-tickets-535584366257).

## Useful links

- [Visualizing data with Metabase course](https://www.metabase.com/learn/visualization/)
- [Data Engineer Roadmap 2021](https://github.com/datastacktv/data-engineer-roadmap/blob/master/README.md)
