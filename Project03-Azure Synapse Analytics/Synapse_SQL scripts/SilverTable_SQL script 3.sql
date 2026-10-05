-- DROP EXTERNAL TABLE silver.SilverTable


--this will now run and create table, only if table and schemas not present in  View -> System views -> sys.schemas & sys.tables repositories
-- i.e if table didn't existed. If exists after once run, it will not recreate table again
SELECT
t.name,t.schema_id,
s.schema_id,s.name
FROM sys.tables t 
JOIN sys.schemas s
ON t.schema_id = s.schema_id


IF NOT EXISTS (SELECT * FROM sys.tables t JOIN sys.schemas s ON t.schema_id=s.schema_id
WHERE t.name='SilverTable' AND s.name='silver')
    CREATE EXTERNAL TABLE silver.SilverTable
    (
        OrderID VARCHAR(100),
        OrderDate DATE,
        CustomerID VARCHAR(100),
        CustomerName VARCHAR(100),
        CustomerEmail VARCHAR(100),
        ProductID VARCHAR(100),
        ProductName VARCHAR(100),
        ProductCategory VARCHAR(100),
        RegionID VARCHAR(100),
        Country VARCHAR(100),
        Quantity VARCHAR(100),
        UnitPrice INT,
        TotalAmount INT,
        Domain VARCHAR(100)
    )
    WITH
    (
        LOCATION='enrichedSales',
        DATA_SOURCE=silver_source,
        FILE_FORMAT = parquet
    )

SELECT * FROM silver.SilverTable

--if to query the files directly instead of table: Openrowset()
