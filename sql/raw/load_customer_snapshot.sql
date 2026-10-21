
-- Step 1: Create a temporary table for CSV import
CREATE TEMP TABLE customer_import AS
SELECT
    customer_id,
    gender,
    senior_citizen,
    partner,
    dependents,
    tenure,
    phone_service,
    multiple_lines,
    internet_service,
    online_security,
    online_backup,
    device_protection,
    tech_support,
    streaming_tv,
    streaming_movies,
    contract,
    paperless_billing,
    payment_method,
    monthly_charges,
    total_charges,
    churn
FROM raw.customer_snapshot
WITH NO DATA;

-- Step 2: Import CSV into the temporary table
\copy customer_import FROM 'WA_Fn-UseC_-Telco-Customer-Churn.csv' WITH (FORMAT csv, HEADER true)

-- Step 3: Insert records into the raw table
INSERT INTO raw.customer_snapshot (
    customer_id,
    gender,
    senior_citizen,
    partner,
    dependents,
    tenure,
    phone_service,
    multiple_lines,
    internet_service,
    online_security,
    online_backup,
    device_protection,
    tech_support,
    streaming_tv,
    streaming_movies,
    contract,
    paperless_billing,
    payment_method,
    monthly_charges,
    total_charges,
    churn,
    source_file
)
SELECT
    customer_id,
    gender,
    senior_citizen,
    partner,
    dependents,
    tenure,
    phone_service,
    multiple_lines,
    internet_service,
    online_security,
    online_backup,
    device_protection,
    tech_support,
    streaming_tv,
    streaming_movies,
    contract,
    paperless_billing,
    payment_method,
    monthly_charges,
    total_charges,
    churn,
    'WA_Fn-UseC_-Telco-Customer-Churn.csv'
FROM customer_import;
