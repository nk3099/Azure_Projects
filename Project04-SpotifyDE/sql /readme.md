<img width="1469" height="731" alt="image" src="https://github.com/user-attachments/assets/6855ace3-7d26-4f81-a9c6-cbb8e15374a9" />


## Error when add incremental data
<img width="1469" height="680" alt="image" src="https://github.com/user-attachments/assets/12becd01-d233-4b8e-97ef-671a2e5a7db5" />
<img width="1470" height="671" alt="image" src="https://github.com/user-attachments/assets/0046920d-9066-497d-91ae-c8564f0ca613" />

## To get exact PK(primary key) constraint in Azure SQL:
SELECT name FROM sys.key_constraints WHERE type='PK' AND parent_object_id = OBJECT_ID('DimTrack')

ALTER TABLE [dbo].[DimTrack]
DROP CONSTRAINT <constraintId>

<img width="1470" height="664" alt="image" src="https://github.com/user-attachments/assets/12cc441f-8d0f-40ad-8527-965d620610fb" />
