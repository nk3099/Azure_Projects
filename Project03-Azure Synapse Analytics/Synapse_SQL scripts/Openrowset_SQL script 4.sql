-- -- This is auto-generated code
-- SELECT
--     TOP 100 *
-- FROM
--     OPENROWSET(
--         BULK 'https://primarystorageazuredwh.dfs.core.windows.net/silver/enrichedSales/**',
--         FORMAT = 'PARQUET'
--     ) AS [result]



SELECT
    TOP 100 *
FROM
    OPENROWSET(
        BULK 'enrichedSales',
        DATA_SOURCE='silver_source',
        FORMAT = 'PARQUET'
    ) AS [result]


-- if to rename columns, then specify the number of that column: 
-- example chaning 'ORDERID' to 'ORDER_ID'
SELECT *
FROM
    OPENROWSET(
        BULK 'enrichedSales',
        DATA_SOURCE='silver_source',
        FORMAT = 'PARQUET'
    )
WITH
(
    ORDER_ID VARCHAR(100) 1
) AS query1;
