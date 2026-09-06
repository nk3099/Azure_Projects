# ADF Project 1 — CSV Ingestion & Sales File Processing

## 1. Project Objective

The objective is to build an **Azure Data Factory (ADF)** solution that:

1. Receives manually uploaded CSV files in the `source` container.
2. Moves those files from `source` to `destination/csvFiles`.
3. Deletes the original files from `source` after successful copying.
4. Fetches CSV files from **Git via HTTPS** and places them directly into `destination/csvFiles`.
5. Identifies files whose names start with `Fact`.
6. Copies only those selected `Fact` files to the `reporting` container.

---

# 2. Overall Architecture

```text
                             ADF PROJECT 1
                                  │
                 ┌────────────────┴─────────────────┐
                 │                                  │
          MANUAL CSV FILES                    GIT CSV FILES
                 │                                  │
                 ▼                                  │
        ┌─────────────────┐                         │
        │ source container│                         │
        │     (ADLS)      │                         │
        └────────┬────────┘                         │
                 │                                  │
                 │ Copy                             │ HTTPS
                 ▼                                  │
        ┌─────────────────────────────┐             │
        │ destination container       │◄────────────┘
        │                             │
        │ /csvFiles/                  │
        └────────────┬────────────────┘
                     │
                     ▼
               Get Metadata
                     │
                     │ Child Items
                     ▼
                  ForEach
                     │
                     │ @item().name
                     ▼
                IF Condition
                     │
                     │ startsWith("Sales")
                     ▼
                Copy Activity
                     │
                     ▼
        ┌─────────────────────────────┐
        │ reporting container         │
        └─────────────────────────────┘
````

---

# 3. Pipeline 1 — Manual CSV Ingestion

## Requirement

Users manually upload CSV files into the `source` container.

Example:

```text
source/
├── Sales_Jan.csv
├── Sales_Feb.csv
├── Customer.csv
└── Product.csv
```

ADF moves these files to:

```text
destination/
└── csvFiles/
    ├── Sales_Jan.csv
    ├── Sales_Feb.csv
    ├── Customer.csv
    └── Product.csv
```

After the files are successfully copied, the original files are deleted from the `source` container.

## Pipeline Flow

```text
source container
       │
       ▼
Copy Activity
       │
       ▼
destination/csvFiles
       │
       ▼
Delete Activity
       │
       ▼
source files removed
```

### Important Concept

```text
Copy Activity
     +
Delete Activity
     =
Move
```

A Copy Activity by itself only **copies** the files.

The Delete Activity removes the original files after the copy.

---

# 4. Pipeline 2 — Git CSV Ingestion

CSV files can also originate from a Git repository.
<br> https://raw.githubusercontent.com/nk3099/ADF-Pipelines/refs/heads/main/raw-data/Fact_Sales_1.csv

ADF accesses the Git-hosted CSV files through **HTTPS** and copies them directly into:

```text
destination/csvFiles/
```

## Pipeline Flow

```text
Git Repository
      │
      │ HTTPS
      ▼
ADF Copy Activity
      │
      ▼
destination/csvFiles/
```

Example:

```text
Git
├── Fact_Sales_1.csv
├── Sales_Apr.csv
└── Customer.csv

          │
          ▼

destination/csvFiles/
├── Sales_Mar.csv
├── Sales_Apr.csv
└── Customer.csv
```

There is no Delete Activity for the Git source because the files are not being temporarily stored in an ADLS source container.

---

# 5. Pipeline 3 — Sales File Processing

At this point, `destination/csvFiles` contains files from both sources:

```text
destination/csvFiles/

├── Sales_Jan.csv
├── Sales_Feb.csv
├── Sales_Mar.csv
├── Customer.csv
├── Product.csv
└── DimDate.csv
```

The requirement is to select only files whose names start with:

```text
Fact_Sales
```

Therefore:

```text
Sales_Jan.csv    → SELECT
Sales_Feb.csv    → SELECT
Sales_Mar.csv    → SELECT

Customer.csv     → IGNORE
Product.csv      → IGNORE
DimDate.csv      → IGNORE
```

The selected files are copied to:

```text
reporting/
```

Final result:

```text
reporting/

├── Sales_Jan.csv
├── Sales_Feb.csv
└── Sales_Mar.csv
```

---

# 6. Why Get Metadata + ForEach?

For this part, we need to inspect the files individually.

## Step 1 — Get Metadata

Use **Get Metadata Activity** on:

```text
destination/csvFiles/
```

Select:

```text
Child items
```

ADF retrieves the files in the directory.

Conceptually:

```text
[
    Sales_Jan.csv,
    Sales_Feb.csv,
    Sales_Mar.csv,
    Customer.csv,
    Product.csv,
    DimDate.csv
]
```

---

# 7. ForEach Activity

The `ForEach` activity loops through the list returned by Get Metadata.

```text
Get Metadata
     │
     │ childItems
     ▼
   ForEach
     │
     ├── Sales_Jan.csv
     ├── Sales_Feb.csv
     ├── Sales_Mar.csv
     ├── Customer.csv
     ├── Product.csv
     └── DimDate.csv
```

Inside the ForEach:

```adf
@item().name
```

means:

> The name of the file currently being processed by this ForEach iteration.

For example:

```text
Iteration 1
item().name = Sales_Jan.csv

Iteration 2
item().name = Sales_Feb.csv

Iteration 3
item().name = Customer.csv
```

---

# 8. Selecting Sales Files

Use an **If Condition** inside the ForEach.

Expression:

```adf
@startsWith(item().name, 'Sales')
```

This returns a Boolean value:

```text
TRUE
```

or

```text
FALSE
```

Example:

```text
Sales_Jan.csv
       │
       ▼
startsWith(item().name, 'Sales')
       │
       ▼
     TRUE
       │
       ▼
     COPY
```

Whereas:

```text
Customer.csv
       │
       ▼
startsWith(item().name, 'Sales')
       │
       ▼
     FALSE
       │
       ▼
    IGNORE
```

---

# 9. Pipeline 3 — Complete Flow

```text
destination/csvFiles
        │
        ▼
  Get Metadata
  (Child items)
        │
        ▼
     ForEach
        │
        │ @item().name
        ▼
   If Condition
        │
        │ @startsWith(item().name, 'Sales')
        │
    ┌───┴────┐
    │        │
  TRUE     FALSE
    │        │
    ▼        ▼
  COPY     IGNORE
    │
    ▼
reporting/
```

---

# 10. Dataset Parameters

Parameters make the pipeline and datasets **reusable**.

Instead of hardcoding:

```text
destination/csvFiles
```

we can create a dataset parameter:

```text
folderPath
```

For example:

```text
folderPath = csvFiles
```

The dataset can then use:

```text
@dataset().folderPath
```

This means the same dataset can potentially be reused for:

```text
csvFiles
archive
reporting
processed
```

without creating a separate dataset for every folder.

---

# 11. File Name Dataset Parameter

We can also create a dataset parameter:

```text
fileName
```

The dataset uses:

```text
@dataset().fileName
```

Inside the ForEach, we can pass:

```text
@item().name
```

to the dataset parameter.

Conceptually:

```text
ForEach
   │
   │ @item().name
   ▼
Dataset Parameter
   │
   │ fileName
   ▼
Copy Activity
```

For example:

```text
Iteration 1:
@item().name
      ↓
Sales_Jan.csv
      ↓
dataset.fileName = Sales_Jan.csv
```

Next iteration:

```text
Iteration 2:
@item().name
      ↓
Sales_Feb.csv
      ↓
dataset.fileName = Sales_Feb.csv
```

---

# 12. Parameter vs ForEach

These two concepts are different.

### Parameter

A parameter **stores or receives a value**.

```text
fileName
   ↓
Sales_Jan.csv
```

### ForEach

ForEach **iterates over multiple values/items**.

```text
ForEach
   │
   ├── Sales_Jan.csv
   ├── Sales_Feb.csv
   ├── Customer.csv
   └── Product.csv
```

### Together

```text
Get Metadata
     │
     │ childItems
     ▼
ForEach
     │
     │ @item().name
     ▼
Dataset Parameter
     │
     │ fileName
     ▼
Copy Activity
```

Therefore:

> **ForEach determines which file is currently being processed.**

> **The dataset parameter tells the dataset which file to read.**

---

# 13. Important Difference — Bulk Copy vs File-by-File Processing

Not every operation requires Metadata + ForEach.

## Bulk Copy

If the requirement is simply:

> Copy all files from `source` to `destination/csvFiles`.

You can use:

```text
Copy Activity
+
Wildcard
```

No ForEach is required.

```text
source/
   │
   │ Copy + Wildcard
   ▼
destination/csvFiles/
```

---

## File-by-File Processing

If the requirement is:

> Look at each filename and copy only files whose names start with `Sales`.

Then:

```text
Get Metadata
      ↓
ForEach
      ↓
Check filename
      ↓
Copy selected files
```

is appropriate.

---

# 14. Final Project Structure

```text
ADF PROJECT 1
│
├── Pipeline 1 — Manual CSV Ingestion
│   │
│   ├── Source: source container
│   ├── Copy → destination/csvFiles
│   └── Delete source files
│
├── Pipeline 2 — Git CSV Ingestion
│   │
│   ├── Source: Git via HTTPS
│   └── Copy → destination/csvFiles
│
└── Pipeline 3 — Sales File Processing
    │
    ├── Source: destination/csvFiles
    │
    ├── Get Metadata
    │   └── Child items
    │
    ├── ForEach
    │   └── @item().name
    │
    ├── If Condition
    │   └── @startsWith(item().name, 'Sales')
    │
    ├── Copy selected files
    │
    └── Destination: reporting
```

---

# 15. Other Concepts

## 15.1 Azure Hierarchy

The basic Azure resource hierarchy is:
<img width="1380" height="768" alt="image" src="https://github.com/user-attachments/assets/6e8d98c9-5595-4340-b9ee-9ec44837b423" />


```text
Azure Account
     │
     ▼
Microsoft Entra ID
     │
     ▼
Subscription
     │
     ├── Resource Group
     │      │
     │      ├── Storage Account
     │      ├── Data Factory
     │      ├── Key Vault
     │      └── Other resources
     │
     └── Other Resource Groups
```

A **Subscription** is a management and billing boundary for Azure resources.

A **Resource Group** is a logical container for related Azure resources.

---

# 16. Resource Provider

A **Resource Provider (RP)** is the Azure service namespace that manages a particular type of resource.

Examples:

| Azure Resource   | Resource Provider       |
| ---------------- | ----------------------- |
| Storage Account  | `Microsoft.Storage`     |
| Data Factory     | `Microsoft.DataFactory` |
| Key Vault        | `Microsoft.KeyVault`    |
| Virtual Machine  | `Microsoft.Compute`     |
| Azure Databricks | `Microsoft.Databricks`  |

For example:

```text
Subscription
     │
     ▼
Microsoft.DataFactory
     │
     ▼
adf-practice-project01
```

Here:

* `Microsoft.DataFactory` → Resource Provider
* `adf-practice-project01` → Actual Data Factory resource

---

# 17. Storage Event Trigger in ADF

Suppose we have:

```text
Storage Account
└── incoming/
    └── sales.csv
```

When `sales.csv` is uploaded, we want ADF to automatically start a pipeline.

The flow is:

```text
User uploads sales.csv
        │
        ▼
ADLS Gen2 / Blob Storage
        │
        ▼
Azure Event Grid
        │
        │ "A blob was created"
        ▼
ADF Storage Event Trigger
        │
        ▼
ADF Pipeline
        │
        ▼
Pipeline starts
```

## Triggers in ADF:
<img width="1214" height="507" alt="image" src="https://github.com/user-attachments/assets/096bde1a-d8bc-47b6-8300-6246b1cecb00" />




### What is Event Grid?

**Azure Event Grid** is the event/notification service.

It allows Azure services to publish events such as:

```text
Blob created
Blob deleted
Resource created
Resource changed
```

ADF can use those events to trigger a pipeline.

Therefore:

> **Event Grid acts as the notification mechanism between the storage event and the ADF trigger.**

---

# 18. Resource Provider vs Event Grid

These are two different concepts.

### Resource Provider

Defines **which Azure service manages a resource**.

Example:

```text
Storage Account
      ↓
Microsoft.Storage
```

### Event Grid

Handles **event notifications**.

Example:

```text
Blob created
     ↓
Event Grid
     ↓
ADF Trigger
     ↓
Pipeline
```

Event Grid itself is also an Azure resource/service, associated with the appropriate Azure resource provider when you create Event Grid resources.

So don't think of:

```text
"Event Grid must be registered as a resource provider for the ADF trigger"
```

as the core concept.

The important concept is:

```text
Azure Subscription
       │
       ├── Storage Account
       │       │
       │       └── emits event
       │
       ├── Event Grid
       │       │
       │       └── delivers event
       │
       └── Data Factory
               │
               └── Storage Event Trigger
```

---

# 19. One-Line Project Summary

> **ADF Project 1 ingests CSV files from both manual ADLS uploads and Git via HTTPS, consolidates them into `destination/csvFiles`, and uses Metadata + ForEach + dynamic dataset parameters to identify and copy only `Sales*` files into the `reporting` container.**

```
```
