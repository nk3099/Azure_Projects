SELECT * FROM silver.SilverTable

IF NOT EXISTS (SELECT * FROM sys.tables t JOIN sys.schemas s ON t.schema_id=s.schema_id
WHERE t.name='FactOrders' and s.name='gold')
    CREATE EXTERNAL TABLE gold.FactOrders
    WITH 
    (
        LOCATION = 'FactOrders',
        DATA_SOURCE = gold_source,
        FILE_FORMAT = parquet
    )
    AS
    SELECT
        O.DimOrdersKey,
        C.DimCustomerKey,
        P.DimProductKey,
        G.DimGeographyKey,
        F.Quantity,
        F.UnitPrice,
        F.TotalAmount
    From 
        silver.SilverTable F
    LEFT JOIN 
    gold.DimOrders O ON F.OrderID = O.OrderID
    LEFT JOIN
    gold.DimCustomer C ON F.CustomerID = C.CustomerID
    LEFT JOIN 
    gold.DimProduct P ON F.ProductID = P.ProductID
    LEFT JOIN
    gold.DimGeography G ON F.RegionID=G.RegionId AND F.Country=G.Country


SELECT  * FROM gold.FactOrders