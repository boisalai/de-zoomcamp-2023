# Data Engineering Zoomcamp 2023 Cohort

## Week 1 Homework

In this homework we'll prepare the environment
and practice with Docker and SQL

## Question 1. Knowing docker tags

Run the command to get information on Docker à

```docker --help```

Now run the command to get help on the "docker build" command

Which tag has the following text? - *Write the image ID to the file*

## :thumbsup: Answer to the question 1

- `--imageid string`
- `--iidfile string` 
- `--idimage string`
- `--idfile string`

Here's what I did to find the answer.

```bash
$ docker build --help
```

## Question 2. Understanding docker first run

Run docker with the python:3.9 image in an interactive mode and the entrypoint of bash.
Now check the python modules that are installed (use `pip list`).
How many python packages/modules are installed?

## :thumbsup: Answer to the question 2

- 1
- 6
- 3 
- 7

Here's what I did to find the answer.

```bash
$ docker run -it --entrypoint=bash python:3.9
root@1473ba81970f:/# pip list
Package    Version
---------- -------
pip        22.0.4
setuptools 58.1.0
wheel      0.38.4
WARNING: You are using pip version 22.0.4; however, version 22.3.1 is available.
You should consider upgrading via the '/usr/local/bin/python -m pip install --upgrade pip' command.
root@1473ba81970f:/# 
exit
```

## Prepare Postgres

Run Postgres and load data as shown in the videos
We'll use the green taxi trips from January 2019:

```wget https://github.com/DataTalksClub/nyc-tlc-data/releases/download/green/green_tripdata_2019-01.csv.gz```

You will also need the dataset with zones:

```wget https://s3.amazonaws.com/nyc-tlc/misc/taxi+_zone_lookup.csv```

Download this data and put it into Postgres (with jupyter notebooks or with a pipeline)

## :thumbsup: Here is what I did to prepare postgres

First I started Docker Desktop and ran the following commands.

```bash
cd data-engineering-zoomcamp
cd week_1_basics_n_setup
cd 2_docker_sql
mkdir ny_taxi_postgres_data
docker run -it \
  -e POSTGRES_USER="root" \
  -e POSTGRES_PASSWORD="root" \
  -e POSTGRES_DB="ny_taxi" \
  -v $(pwd)/ny_taxi_postgres_data:/var/lib/postgresql/data \
  -p 5432:5432 \
  postgres:13
```

I then started pgcli.

```bash
pgcli -h localhost -p 5432 -u root -d ny_taxi
```

I started jupyter notebook.

```bash
jupyter notebook
```

I ran the python code below in jupyter notebook.

```python
!wget https://github.com/DataTalksClub/nyc-tlc-data/releases/download/green/green_tripdata_2019-01.csv.gz
!wget https://s3.amazonaws.com/nyc-tlc/misc/taxi+_zone_lookup.csv

df_taxi = pd.read_csv('green_tripdata_2019-01.csv.gz', compression='gzip')
df_taxi.head()
df_taxi.shape
# (630918, 20)

df_taxi.lpep_pickup_datetime = pd.to_datetime(df_taxi.lpep_pickup_datetime)
df_taxi.lpep_dropoff_datetime = pd.to_datetime(df_taxi.lpep_dropoff_datetime)

df_zones = pd.read_csv('taxi+_zone_lookup.csv')
df_zones.head()
df_zones.shape
# (265, 4)

from sqlalchemy import create_engine
engine = create_engine('postgresql://root:root@localhost:5432/ny_taxi')
%time df_taxi.to_sql(name='green_tripdata_201901', con=engine, if_exists='replace')
df_zones.to_sql(name='zones', con=engine, if_exists='replace')
```

## Question 3. Count records

How many taxi trips were totally made on January 15?

Tip: started and finished on 2019-01-15.

Remember that `lpep_pickup_datetime` and `lpep_dropoff_datetime` columns are in the 
format timestamp (date and hour+min+sec) and not in date.

## :thumbsup: Answer to the question 3

- 20689
- 20530 
- 17630
- 21090

Here's what I did with pgcli to find the answer.

```sql
SELECT count(1)
FROM green_tripdata_201901
WHERE lpep_pickup_datetime::date = '2019-01-15'
AND lpep_dropoff_datetime::date = '2019-01-15';
```

## Question 4. Largest trip for each day

Which was the day with the largest trip distance
Use the pick up time for your calculations.

## :thumbsup: Answer to the question 4

- 2019-01-18
- 2019-01-28
- 2019-01-15 
- 2019-01-10

My SQL query below:

```sql
SELECT lpep_pickup_datetime::date AS date, 
       max(trip_distance) AS largest_distance
FROM green_tripdata_201901
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;
```

## Question 5. The number of passengers

In 2019-01-01 how many trips had 2 and 3 passengers?

## :thumbsup: Answer to the question 5

- 2: 1282 ; 3: 266
- 2: 1532 ; 3: 126
- 2: 1282 ; 3: 254 
- 2: 1282 ; 3: 274

My SQL query below:

```sql
SELECT passenger_count, COUNT(1) AS trip_count
FROM green_tripdata_201901
WHERE lpep_pickup_datetime::date = '2019-01-01'
GROUP BY 1
HAVING passenger_count in (2, 3);
```

## Question 6. Largest tip

For the passengers picked up in the Astoria Zone which was the drop off zone that had the largest tip?
We want the name of the zone, not the id.

Note: it's not a typo, it's `tip` , not `trip`

## :thumbsup: Answer to the question 6

- Central Park
- Jamaica
- South Ozone Park
- Long Island City/Queens Plaza 

I ran this SQL query in pgadmin.

```sql
SELECT COALESCE(dropoff."Zone", 'Unknown') AS dropoff_zone,
       MAX(tip_amount) AS largest_tip
FROM green_tripdata_201901 AS taxi
LEFT JOIN zones AS pickup ON taxi."PULocationID" = pickup."LocationID"
LEFT JOIN zones AS dropoff ON taxi."DOLocationID" = dropoff."LocationID"
WHERE pickup."Zone" = 'Astoria'
GROUP BY 1
ORDER BY largest_tip DESC
LIMIT 1;
```

Thanks to the whole [DataTalksClub](https://datatalks.club/) Team!

Alain