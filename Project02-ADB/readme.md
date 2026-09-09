Azure Databricks:
<img width="1312" height="608" alt="image" src="https://github.com/user-attachments/assets/e9779a66-0cfe-49a8-be37-b9a30f41b83e" />

Proceed to <https://accounts.azuredatabricks.net/>
Go to Azure -> Microsoft Entra ID (previously called as Azure Active Directory(AAD)) -> Manage > Users > Selecte User principal name
<img width="1021" height="268" alt="image" src="https://github.com/user-attachments/assets/9b518030-c554-4333-a149-38441283893c" />


Login to <https://accounts.azuredatabricks.net/> using that Email (User principal name email address) and will then be logged in as Admin. 
<img width="1466" height="413" alt="image" src="https://github.com/user-attachments/assets/28dbdea5-5509-4540-807f-d2cc27065b1f" />

Note: A metastore is associated with a particular cloud region.  One region can have multiple metastores.

Make username as admin as well., so cn get option of Manage in Databricks for orignal email


Without metastore admin 
<img width="516" height="352" alt="image" src="https://github.com/user-attachments/assets/168220f3-25b7-4cb3-a1a7-61342f7e9fec" />

with METastore admin
gest access to create Catalog
<img width="477" height="410" alt="image" src="https://github.com/user-attachments/assets/847cace0-a3f7-4836-9756-b27578f80dd7" />
<img width="764" height="483" alt="image" src="https://github.com/user-attachments/assets/8d71f1e1-5872-4649-8a61-b94cdf200a3d" />


Volume path

A Unity Catalog volume is accessed like:

/Volumes/company/sales/raw_files/

For example:

df = spark.read.csv(
    "/Volumes/company/sales/raw_files/orders.csv"
)
Types of Volumes

There are two important types:

Type	Where data is stored	Who manages storage location
Managed Volume	Unity Catalog-managed storage	Databricks/UC
External Volume	Your existing cloud storage location	You
Volume vs Table
                    Unity Catalog
                         │
              ┌──────────┴──────────┐
              ↓                     ↓
           TABLE                  VOLUME
              │                     │
       Structured data          Files
              │                     │
       rows + columns        CSV, JSON, PDF, etc.
Volume vs old DBFS mount

This is particularly important given what you were asking earlier:

Old approach:

ADLS
  ↓
DBFS Mount
  ↓
/mnt/raw/

Modern Unity Catalog approach:

Unity Catalog
      ↓
Volume
      ↓
/Volumes/catalog/schema/volume/
      ↓
ADLS

The big advantage is that Volumes are governed by Unity Catalog, so you can control who can access the files using Unity Catalog permissions.
