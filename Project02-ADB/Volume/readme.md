Volumes in Unity Catalog

A Volume is a Unity Catalog object used to manage files in cloud storage.

<img width="1468" height="536" alt="image" src="https://github.com/user-attachments/assets/1a395b73-8f37-402d-9d83-a10810a1f823" />
<img width="1259" height="708" alt="image" src="https://github.com/user-attachments/assets/9d86ce61-5d1d-488b-bf31-6834bdcf48c4" />


Think:

Unity Catalog
│
└── Catalog: company
      │
      └── Schema: sales
            │
            ├── Table: orders
            │
            └── Volume: raw_files

A table is mainly for structured data:

orders
├── order_id
├── customer_id
└── amount

A Volume is for files:

raw_files/
├── orders.csv
├── customers.json
├── invoice.pdf
└── config.json
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














----

Your SQL:

CREATE TABLE managed_catalog.managed_schema.external_table4 (
    id INT,
    name STRING
)
USING DELTA
LOCATION 'abfss://mycontainer@adlspracticeproject02.dfs.core.windows.net/external_table_data';
Unity Catalog side
managed_catalog
└── managed_schema
    └── external_table4     ← TABLE

It is not:

managed_schema
└── external_table4
    └── mycontainer        ❌
ADLS side

The actual Delta files are here:

adlspracticeproject02
└── mycontainer
    └── external_table_data
        ├── _delta_log/
        └── *.parquet

So there are two separate views of the same table:

Unity Catalog                         ADLS

managed_catalog                       adlspracticeproject02
└── managed_schema                     └── mycontainer
    └── external_table4                    └── external_table_data
             │                                      │
             └────────────── points to ─────────────┘


So:

managed_schema contains the table object.
mycontainer/external_table_data contains the table's physical Delta data.

And because you specified LOCATION, this is an external table, despite the schema being named managed_schema. The schema name itself does not make the table managed.
