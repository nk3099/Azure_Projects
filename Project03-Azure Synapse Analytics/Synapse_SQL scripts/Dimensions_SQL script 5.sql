--using CETAS : create external table as select
--> first writes the 'SELECT part' data in 'Location' and then creates 'External table' on top of it.
--> when Errors: Cannot create external table. External table location already exists. Location provided
--> So, need to drop table in Datalake and re-run query correctly.


-- DROP EXTERNAL TABLE gold.DimCustomer
-- DROP EXTERNAL TABLE gold.DimOrders
-- DROP EXTERNAL TABLE gold.DimGeography
-- DROP EXTERNAL TABLE gold.DimProduct


SELECT * from silver.SilverTable

-----------------------------------------------------------------
------------   DimCustomer --------------------------------------
-----------------------------------------------------------------

IF NOT EXISTS (SELECT * FROM sys.tables t JOIN sys.schemas s ON t.schema_id=s.schema_id
WHERE t.name='DimCustomer' and s.name='gold')
    CREATE EXTERNAL TABLE gold.DimCustomer
    WITH
    (
        LOCATION = 'DimCustomer',
        DATA_SOURCE = gold_source,
        FILE_FORMAT = parquet
        --changed to parquet, as error:
        --EXTERNAL FILE FORMAT 'delta' has FORMAT_TYPE = DELTA which is not supported by CREATE EXTERNAL TABLE AS SELECT statement.
        
        --therefore, note: But you can still create external table on top of Delta data, but not with CETAS

    )
    AS
    SELECT *, ROW_NUMBER() OVER (ORDER BY T.CustomerID) as DimCustomerKey
    FROM
    (SELECT
        DISTINCT 
        CustomerID,
        CustomerName,
        CustomerEmail,
        Domain
    FROM
        silver.SilverTable
    ) T


-- SELECT * from gold.DimCustomer;
    

-----------------------------------------------------------------
------------   DimProduct --------------------------------------
-----------------------------------------------------------------

-- DROP EXTERNAL TABLE gold.DimProduct

IF NOT EXISTS (SELECT * FROM sys.tables t JOIN sys.schemas s ON t.schema_id=s.schema_id
WHERE t.name='DimProduct' and s.name='gold')
    CREATE EXTERNAL TABLE gold.DimProduct
    WITH
    (
        LOCATION = 'DimProduct',
        DATA_SOURCE = gold_source,
        FILE_FORMAT = parquet
    )
    AS
    SELECT *, ROW_NUMBER() OVER (ORDER BY T.ProductID) as DimProductKey
    FROM
    (SELECT
        DISTINCT 
        ProductID,
        ProductName,
        ProductCategory
    FROM
        silver.SilverTable
    ) T


SELECT * from gold.DimProduct;
    

-----------------------------------------------------------------
------------   DimGeography --------------------------------------
-----------------------------------------------------------------

SELECT * from silver.SilverTable

IF NOT EXISTS (SELECT * FROM sys.tables t JOIN sys.schemas s ON t.schema_id=s.schema_id
WHERE t.name='DimGeography' and s.name='gold')
    CREATE EXTERNAL TABLE gold.DimGeography
    WITH
    (
        LOCATION = 'DimGeography',
        DATA_SOURCE = gold_source,
        FILE_FORMAT = parquet
    )
    AS
    SELECT *, ROW_NUMBER() OVER (ORDER BY T.RegionId) as DimGeographyKey
    FROM
    (SELECT
        DISTINCT 
        RegionID,
        Country
    FROM
        silver.SilverTable
    ) T


SELECT * from gold.DimGeography;
    




-----------------------------------------------------------------
------------   DimOrders --------------------------------------
-----------------------------------------------------------------

SELECT * from silver.SilverTable

IF NOT EXISTS (SELECT * FROM sys.tables t JOIN sys.schemas s ON t.schema_id=s.schema_id
WHERE t.name='DimOrders' and s.name='gold')
    CREATE EXTERNAL TABLE gold.DimOrders
    WITH
    (
        LOCATION = 'DimOrders',
        DATA_SOURCE = gold_source,
        FILE_FORMAT = parquet
    )
    AS
    SELECT
        OrderID,
        CustomerID,
        CustomerName,
        CustomerEmail,
        ProductID,
        ProductName,
        ProductCategory,
        RegionID,
        Country,
        Domain,
        ROW_NUMBER() OVER (ORDER BY CustomerID) as DimOrdersKey
    FROM
        silver.SilverTable


SELECT * from gold.DimOrders;
SELECT * from silver.SilverTable;







