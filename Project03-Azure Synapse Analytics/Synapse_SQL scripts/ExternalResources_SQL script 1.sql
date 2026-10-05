--https://learn.microsoft.com/en-us/sql/t-sql/statements/create-master-key-transact-sql?view=sql-server-ver17

-- CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'enteryourpassword'

--------------------------------
-- DATABASE SCOPED CREDENTIAL
--------------------------------

CREATE DATABASE SCOPED CREDENTIAL neeraj_creds
WITH IDENTITY = 'Managed Identity'

--------------------------------
-- EXTERNAL DATA SOURCE
--https://learn.microsoft.com/en-us/azure/synapse-analytics/sql/develop-tables-external-tables?tabs=hadoop
--------------------------------

-- DROP EXTERNAL DATA SOURCE silver_source

CREATE EXTERNAL DATA SOURCE silver_source
WITH
(
    LOCATION = 'https://primarystorageazuredwh.dfs.core.windows.net/silver/',
    CREDENTIAL = neeraj_creds

)

CREATE EXTERNAL DATA SOURCE gold_source
WITH
(
    LOCATION = 'https://primarystorageazuredwh.dfs.core.windows.net/gold/',
    CREDENTIAL = neeraj_creds

)



--------------------------------
-- EXTERNAL FILE FORMAT
--------------------------------

CREATE EXTERNAL FILE FORMAT parquet
WITH
(
    FORMAT_TYPE = PARQUET,
    DATA_COMPRESSION = 'org.apache.hadoop.io.compress.SnappyCodec'
)


CREATE EXTERNAL FILE FORMAT delta
WITH
(
    FORMAT_TYPE = DELTA
)


CREATE EXTERNAL FILE FORMAT delta
WITH
(
    FORMAT_TYPE = DELTA
)

