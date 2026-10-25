
# Data Dictionary — TelecomPulse

## 1. Dataset Overview

**Dataset:** IBM Telco Customer Churn  
**Source:** Kaggle — IBM Telco Customer Churn  
**File format:** CSV  
**Source file:** WA_Fn-UseC_-Telco-Customer-Churn.csv  
**Number of records:** 7,043  
**Number of columns:** 21  
**Granularity:** One row per customer  
**Business key:** customerID  

### PostgreSQL Storage

- **Database:** telecompulse
- **Schema:** raw
- **Table:** raw.customer_snapshot

### Description

The IBM Telco Customer Churn dataset contains information about customers of a telecommunications company, including their demographic characteristics, subscribed services, account details, billing information, and churn status.

The dataset is used in the TelecomPulse Data Engineering project to build a data pipeline for customer churn analysis.

The raw layer serves as the initial storage layer for source data before further processing and transformation.

## 2. Dataset Structure

The source CSV contains 21 columns.

| Column | Source Data Type | Description |
|---|---|---|
| customerID | String | Unique identifier assigned to each customer |
| gender | String | Customer gender (Male/Female) |
| SeniorCitizen | Integer | Indicates whether the customer is a senior citizen (1 = Yes, 0 = No) |
| Partner | String | Indicates whether the customer has a partner |
| Dependents | String | Indicates whether the customer has dependents |
| tenure | Integer | Number of months the customer has been with the company |
| PhoneService | String | Indicates whether the customer has phone service |
| MultipleLines | String | Indicates whether the customer has multiple phone lines |
| InternetService | String | Type of internet service (DSL, Fiber optic, No) |
| OnlineSecurity | String | Indicates whether the customer subscribes to online security |
| OnlineBackup | String | Indicates whether the customer subscribes to online backup |
| DeviceProtection | String | Indicates whether the customer subscribes to device protection |
| TechSupport | String | Indicates whether the customer subscribes to technical support |
| StreamingTV | String | Indicates whether the customer uses TV streaming services |
| StreamingMovies | String | Indicates whether the customer uses movie streaming services |
| Contract | String | Customer contract type (Month-to-month, One year, Two year) |
| PaperlessBilling | String | Indicates whether paperless billing is enabled |
| PaymentMethod | String | Customer payment method |
| MonthlyCharges | Decimal | Amount charged to the customer each month |
| TotalCharges | String | Total charges accumulated during the customer's tenure |
| Churn | String | Indicates whether the customer has left the company |

**Note:** TotalCharges is represented as text in the source CSV because some records contain blank strings. Valid values represent decimal amounts.

The PostgreSQL column types and constraints are defined in:

`sql/raw/create_customer_snapshot.sql`

The actual database structure can be inspected using:

```sql
\d raw.customer_snapshot
```

## 3. Business Key

The `customerID` column uniquely identifies each customer in the dataset.

In PostgreSQL, the corresponding column is named `customer_id`.

This column serves as the business key because it identifies a customer independently of the technical database implementation.

### Expected Characteristics

- Each customer should have a unique identifier.
- Customer identifiers should not contain NULL values.
- The same customer should not appear multiple times in a single snapshot.

### Validation Query

```sql
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT customer_id) AS unique_customers
FROM raw.customer_snapshot;
```

Expected results:

- Total records: 7,043
- Unique customer IDs: 7,043

The uniqueness result must be confirmed by executing the query against PostgreSQL.

### Duplicate Detection

```sql
SELECT
    customer_id,
    COUNT(*) AS occurrences
FROM raw.customer_snapshot
GROUP BY customer_id
HAVING COUNT(*) > 1;
```

Expected result: No duplicate customer identifiers.

## 4. Data Quality Assessment

Data quality checks help identify missing values, duplicate records, inconsistent data types, and invalid values.

The following issues and validation rules are relevant to the IBM Telco Customer Churn dataset.

### 4.1 Missing Values in TotalCharges

The original dataset contains 11 records where `TotalCharges` is represented by a blank string.

These values require special handling because they cannot be directly converted into numeric values without additional processing.

Possible handling strategies include:

- Preserving blank values in the raw layer.
- Converting blank values to NULL during ingestion.
- Applying appropriate transformations in downstream processing.

Missing values should not automatically be replaced with zero because a missing value and an actual charge of zero have different meanings.

### PostgreSQL Validation

If the column is numeric:

```sql
SELECT
    COUNT(*) AS missing_total_charges
FROM raw.customer_snapshot
WHERE total_charges IS NULL;
```

If the column is stored as text:

```sql
SELECT
    COUNT(*) AS missing_total_charges
FROM raw.customer_snapshot
WHERE total_charges IS NULL
   OR TRIM(total_charges) = '';
```

Expected source-level missing values: 11.

Actual PostgreSQL result: To be verified.

### 4.2 Duplicate Customer IDs

Duplicate customer identifiers could lead to incorrect customer counts and inaccurate analytical results.

Validation:

```sql
SELECT
    customer_id,
    COUNT(*)
FROM raw.customer_snapshot
GROUP BY customer_id
HAVING COUNT(*) > 1;
```

Expected result: No duplicate customer IDs.

Actual result: To be verified.

### 4.3 Data Type Consistency

Several columns require appropriate data type validation.

| Column | Validation Rule |
|---|---|
| customer_id | Must contain a non-empty customer identifier |
| tenure | Must be a non-negative integer |
| senior_citizen | Must contain 0 or 1 |
| monthly_charges | Must contain a non-negative numeric value |
| total_charges | Must contain a valid non-negative numeric value or an explicitly handled missing value |
| churn | Must contain Yes or No |

These rules help ensure that source values are suitable for further processing.

### 4.4 Categorical Values

Categorical columns contain a limited set of expected values.

Examples include:

- `gender`: Male, Female
- `churn`: Yes, No
- `contract`: Month-to-month, One year, Two year
- `internet_service`: DSL, Fiber optic, No

Unexpected values should be identified during data validation.

Some service-related columns may also contain `No internet service` or `No phone service`. These are legitimate categories and should not automatically be treated as missing values.

## 5. Raw Layer Design

The PostgreSQL table `raw.customer_snapshot` stores customer data imported from the original source CSV.

The raw layer is the initial stage of the data pipeline.

### Purpose

- Store source records in a structured format.
- Preserve relevant information from the original dataset.
- Provide a reliable input for downstream transformations.
- Enable validation of data quality.
- Support reprocessing when required.

Business transformations, aggregations, and analytical models will be implemented in later stages of the project.

## 6. SQL Scripts

The following scripts are used to manage the raw customer snapshot table.

| Script | Purpose |
|---|---|
| sql/raw/create_customer_snapshot.sql | Creates the customer snapshot table |
| sql/raw/load_customer_snapshot.sql | Loads customer data from the source CSV |

### Table Creation

```bash
psql -v ON_ERROR_STOP=1 -d telecompulse -f sql/raw/create_customer_snapshot.sql
```

### Verify Loaded Records

```sql
SELECT COUNT(*)
FROM raw.customer_snapshot;
```

Verified result:

**7,043 records**

This confirms that the table exists and contains the expected number of records.

## 7. Data Validation Summary

| Validation | Expected Result | Actual Result |
|---|---|---|
| Total records | 7,043 | 7,043 — Verified |
| Unique customer IDs | 7,043 | To be verified |
| Duplicate customer IDs | 0 | To be verified |
| Blank TotalCharges in source | 11 | Known source issue |
| Missing TotalCharges in PostgreSQL | Depends on ingestion handling | To be verified |
| Invalid categorical values | 0 | To be verified |

The remaining validation results should be updated after executing the corresponding SQL queries.

## 8. Security and Version Control

Database credentials and sensitive configuration values must not be committed to GitHub.

Sensitive information should be stored in environment variables or a local `.env` file.

The `.gitignore` file should exclude:

- `.env`
- `.venv/`
- Python cache files
- Other local files containing sensitive information

SQL scripts, documentation, and non-sensitive project configuration should be maintained under version control.

## 9. Conclusion

The IBM Telco Customer Churn dataset has been prepared for use in the TelecomPulse Data Engineering project.

The PostgreSQL database `telecompulse` contains the `raw.customer_snapshot` table with 7,043 customer records.

The dataset provides information about customer demographics, subscribed services, billing, and churn behaviour.

Known data quality considerations include missing TotalCharges values, customer identifier uniqueness, and data type consistency.

The raw customer snapshot will serve as the foundation for subsequent ingestion, transformation, and analytical processing.
