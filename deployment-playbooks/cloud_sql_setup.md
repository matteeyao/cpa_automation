# Setting up Cloud SQL PostgreSQL Instance

## Uploading and Running `schema.sql` in Cloud SQL PostgreSQL Instance

> **NOTE:**
>
> Run the `Deploy Cloud SQL` workflow within GitHub Actions

### Step 1: Install the Cloud SQL Proxy

* The Cloud SQL Proxy allows you to connect to your Cloud SQL instance securely from your local machine. Let's install it:

* Using Docker:

```zsh
docker pull gcr.io/cloudsql-docker/gce-proxy:latest
```

### Step 2: Start the Cloud SQL Proxy

* Now that you have the Cloud SQL Proxy installed, let's start it to connect to your instance:

  1. First, get your instance connection name:

```bash
gcloud sql instances describe postgres-instance --format='value(connectionName)'
```

    * This will output something like `project-id:region:instance-name`

  2. Start the Cloud SQL Proxy:

```bash
docker run -d \
  -v /path/to/your/service/account/key.json:/config \
  -p 127.0.0.1:5432:5432 \
  gcr.io/cloudsql-docker/gce-proxy:latest /cloud_sql_proxy \
  -instances=YOUR_INSTANCE_CONNECTION_NAME=tcp:0.0.0.0:5432 \
  -credential_file=/config
```
    * Replace `YOUR_INSTANCE_CONNECTION_NAME` with the connection name you got from the previous command

```bash
docker run -d \
  -v ~/Developer/keys/github-actions-sa-key.json:/config \
  -p 127.0.0.1:5432:5432 \
  gcr.io/cloudsql-docker/gce-proxy:latest /cloud_sql_proxy \
  -instances=sputter-455519:us-central1:postgres-instance=tcp:0.0.0.0:5432 \
  -credential_file=/config
```

  3. The proxy will start and you should see output indicating that it's ready to receive connections.

### Step 3: Connect to Your Database Using psql

Now that the Cloud SQL Proxy is running, you can connect to your PostgreSQL database using the `psql` client:

1. Install the PostgreSQL client if you don't have it already:

  * For macOS (using Homebrew):

```zsh
brew install postgresql
```

2. Connect to your database using psql:

```bash
psql -h localhost -p 5432 -U postgres -d sputter-database
```

  * When prompted, enter the password you set in the GitHub secret `DB_PASSWORD`

3. Verify that you're connected to the correct database:

```sql
SELECT current_database();
```

  * This should return `sputter-database`

4. Check if there are any existing tables:

```sql
\dt
```

  * Since this is a new database, you shouldn't see any tables yet.

Now you're connected to your Cloud SQL PostgreSQL instance and ready to apply your schema

### Step 4: Apply the Schema to Database

Now that you're connected to your database with psql, you can apply your schema:

1. Exit psql if you're still in it:

```txt
\q
```

2. Then run the command to apply the schema from your file:

```bash
psql -h localhost -p 5432 -U postgres -d sputter-database -f db-scripts/schema.sql
```

3. You should see a series of `CREATE TABLE`, `CREATE INDEX`, `CREATE TRIGGER`, etc. messages indicating that each part of the schema was successfully created

4. If you encounter any errors, they will be displayed in the output. Common issues might include:

  * Syntax errors in the schema

  * Permission issues

  * Conflicts with existing objects

5. Once the schema is applied, reconnect to the database to verify:

```bash
psql -h localhost -p 5432 -U postgres -d sputter-database
```
6. Now check that all your tables were created:

```sql
\dt
```

  * You should see all the tables defined in your schema: `cpa_firms`, `businesses`, `employees`, `pay_periods`, `payroll_records`, `deductions`, and `taxes`

7. You can also verify that the custom type was created:

```sql
\dT+
```

8. Check that the triggers were created:

```sql
\dT
```

9. Verify that the indexes were created:

```sql
\di
```

Your schema has now been successfully applied to your Cloud SQL PostgreSQL instance!

### Step 5: Step 5: Verify the Schema Details

Now that you've applied the schema, let's verify that everything was created correctly and explore the structure in more detail:

1. First, let's check all the tables that were created:

```sql
\dt
```

2. To see the detailed structure of a specific table, use the `\d` command followed by the table name. For example, to see the structure of the employees table:

```sql
\d employees
```

  * This will show all columns, their data types, constraints, and indexes for the table

3. Check that your custom ENUM type was created correctly:

```sql
\dT+ pay_type_enum
```

4. Verify that all triggers were created:

```sql
SELECT event_object_table AS table_name,
       trigger_name,
       action_statement AS trigger_logic
FROM information_schema.triggers
ORDER BY table_name, trigger_name;
```

5. Check all the indexes that were created:

```sql
SELECT tablename, indexname, indexdef
FROM pg_indexes
WHERE schemaname = 'public'
ORDER BY tablename, indexname;
```

6. Verify that the foreign key constraints are in place:

```sql
SELECT
    tc.table_schema, 
    tc.constraint_name, 
    tc.table_name, 
    kcu.column_name, 
    ccu.table_schema AS foreign_table_schema,
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name 
FROM 
    information_schema.table_constraints AS tc 
    JOIN information_schema.key_column_usage AS kcu
      ON tc.constraint_name = kcu.constraint_name
      AND tc.table_schema = kcu.table_schema
    JOIN information_schema.constraint_column_usage AS ccu
      ON ccu.constraint_name = tc.constraint_name
      AND ccu.table_schema = tc.table_schema
WHERE tc.constraint_type = 'FOREIGN KEY'
ORDER BY tc.table_name, kcu.column_name;
```

7. Test that the triggers work by updating a record:

```sql
-- First, insert a test record
INSERT INTO cpa_firms (firm_name, contact_name, contact_email)
VALUES ('Test Firm', 'Test Contact', 'test@example.com');

-- Check the created_at and updated_at timestamps
SELECT id, firm_name, created_at, updated_at FROM cpa_firms;

-- Update the record
UPDATE cpa_firms SET firm_name = 'Updated Test Firm' WHERE firm_name = 'Test Firm';

-- Check that updated_at was automatically updated
SELECT id, firm_name, created_at, updated_at FROM cpa_firms;
```

8. When you're done, exit psql:

```sql
\q
```

### Step 6: Secure your Database

1. Update the default user password:

  * If you haven't already, change the default 'postgres' user password:

```sql
ALTER USER postgres WITH PASSWORD 'new_secure_password';
```

2. Create application-specific users:

  * It's a good practice to create separate users for your application with limited permissions:

```sql
CREATE USER payroll_app WITH PASSWORD 'secure_app_password';
GRANT CONNECT ON DATABASE sputter-database TO payroll_app;
GRANT USAGE ON SCHEMA public TO payroll_app;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO payroll_app;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO payroll_app;
```

3. Enable SSL for database connections in your application

### Step 7: Set Up Backups and Maintenance

1. Verify that automated backups are enabled in the Google Cloud Console for your Cloud SQL instance.

2. Set up a maintenance window for your database during off-peak hours.

### Step 8: Monitoring and Logging

1. Set up Cloud Monitoring for your Cloud SQL instance to track metrics like CPU usage, disk space, and active connections

2. Enable detailed query logging for debugging purposes (but be mindful of performance impact in production)

### Step 9: Update Your Application Configuration

1. Update your application's database connection settings to use the Cloud SQL instance

2. If you're using the Cloud SQL Proxy in production, set it up on your application servers

### Step 10: Testing

1. Perform thorough testing of your application with the new Cloud SQL database

2. Test database performance under expected load

### Step 11: Documentation

1. Document the database schema, including any specific design decisions

2. Create documentation for database maintenance procedures, backup and restore processes, and emergency protocols

## Step 12: Clean Up

1. If you were using a local development database before, make sure to migrate all necessary data to the Cloud SQL instance

2. Update any scripts or CI/CD pipelines to use the new Cloud SQL instance

Remember to always follow security best practices, keep your database and application updated, and regularly review and optimize your database performance

## Upload Datasets into Cloud SQL PostgreSQL Database

### Step 1: Prepare the CSV Files

  1. Ensure all your CSV files are properly formatted and match the schema structure

  2. Check that date formats are consistent with PostgreSQL expectations

  3. Make sure the files are accessible from your local machine where you're running the Cloud SQL Proxy

### Step 2: Run the import script:

* From the project directory run:

```bash
psql -h localhost -p 5432 -U postgres -d sputter-database -f db-scripts/import_datasets.sql
```

### Step 3: Query and Verify Your Data

Now that you've successfully imported all your data into the Cloud SQL PostgreSQL database, let's run some queries to verify that everything is working correctly and explore the data:

1. First, let's check how many records we have in each table:

```sql
SELECT 'cpa_firms' AS table_name, COUNT(*) AS record_count FROM cpa_firms
UNION ALL
SELECT 'businesses', COUNT(*) FROM businesses
UNION ALL
SELECT 'employees', COUNT(*) FROM employees
UNION ALL
SELECT 'pay_periods', COUNT(*) FROM pay_periods
UNION ALL
SELECT 'payroll_records', COUNT(*) FROM payroll_records
UNION ALL
SELECT 'deductions', COUNT(*) FROM deductions
UNION ALL
SELECT 'taxes', COUNT(*) FROM taxes
ORDER BY table_name;
```

2. Let's examine the relationship between businesses and their CPA firm:

```sql
SELECT b.id, b.business_name, c.firm_name, b.contact_name, b.contact_email
FROM businesses b
JOIN cpa_firms c ON b.cpa_firm_id = c.id;
```

3. Check employee information for each business:

```sql
SELECT e.id, e.first_name, e.last_name, b.business_name, e.pay_rate, e.pay_type, e.job_title
FROM employees e
JOIN businesses b ON e.business_id = b.id
ORDER BY b.business_name, e.last_name;
```

4. View upcoming pay periods:

```sql
SELECT p.id, b.business_name, p.start_date, p.end_date, p.pay_date, p.description
FROM pay_periods p
JOIN businesses b ON p.business_id = b.id
WHERE p.pay_date > '2025-04-03'
ORDER BY p.pay_date;
```

5. Analyze payroll data for a specific business:

```sql
SELECT pr.id, e.first_name, e.last_name, pp.start_date, pp.end_date, 
       pr.hours_worked_regular, pr.hours_worked_overtime, 
       pr.gross_pay, pr.total_deductions, pr.total_taxes, pr.net_pay
FROM payroll_records pr
JOIN employees e ON pr.employee_id = e.id
JOIN pay_periods pp ON pr.pay_period_id = pp.id
JOIN businesses b ON e.business_id = b.id
WHERE b.business_name = 'Sunshine Car Wash'
ORDER BY pp.start_date, e.last_name;
```

6. Check the tax breakdown for a specific payroll record:

```sql
SELECT pr.id AS payroll_id, e.first_name, e.last_name, 
       t.tax_type, t.jurisdiction, t.amount
FROM taxes t
JOIN payroll_records pr ON t.payroll_record_id = pr.id
JOIN employees e ON pr.employee_id = e.id
WHERE pr.id = 1
ORDER BY t.amount DESC;
```

7. View deductions for a specific employee:

```sql
SELECT e.first_name, e.last_name, pp.start_date, pp.end_date,
       d.deduction_type, d.amount
FROM deductions d
JOIN payroll_records pr ON d.payroll_record_id = pr.id
JOIN employees e ON pr.employee_id = e.id
JOIN pay_periods pp ON pr.pay_period_id = pp.id
WHERE e.id = 3
ORDER BY pp.start_date, d.deduction_type;
```

8. Calculate total payroll by business:

```sql
SELECT b.business_name, 
       SUM(pr.gross_pay) AS total_gross_pay,
       SUM(pr.total_deductions) AS total_deductions,
       SUM(pr.total_taxes) AS total_taxes,
       SUM(pr.net_pay) AS total_net_pay
FROM payroll_records pr
JOIN employees e ON pr.employee_id = e.id
JOIN businesses b ON e.business_id = b.id
GROUP BY b.business_name
ORDER BY b.business_name;
```

These queries will help you verify that your data was imported correctly and give you insights into the payroll information stored in your database.

### Step 4: Analyze Your Payroll Data

* Now that your data is successfully imported into your Cloud SQL PostgreSQL database, let's run some analytical queries to gain insights from your payroll data.

#### Upcoming Pay Periods

* Since today is April 3, 2025, let's identify all upcoming pay periods:

```sql
SELECT p.id, b.business_name, p.start_date, p.end_date, p.pay_date, p.description
FROM pay_periods p
JOIN businesses b ON p.business_id = b.id
WHERE p.pay_date > '2025-04-03'
ORDER BY p.pay_date;
```

* This will show all pay periods with pay dates after today, which includes:

  * Monthly pay period for Tech Innovators Inc. (pay date: April 5, 2025)

  * Semi-Monthly pay period for Green Earth Landscaping (pay date: April 20, 2025)

  * Bi-Weekly pay period for Sunshine Car Wash (pay date: May 4, 2025)

  * And several more through June 20, 2025

#### Payroll Summary by Business

* To get a high-level view of your payroll expenses by business:

```sql
SELECT b.business_name, 
       COUNT(DISTINCT pr.id) AS payroll_count,
       SUM(pr.gross_pay) AS total_gross_pay,
       SUM(pr.total_deductions) AS total_deductions,
       SUM(pr.total_taxes) AS total_taxes,
       SUM(pr.net_pay) AS total_net_pay
FROM payroll_records pr
JOIN employees e ON pr.employee_id = e.id
JOIN businesses b ON e.business_id = b.id
GROUP BY b.business_name
ORDER BY total_gross_pay DESC;
```

#### Tax Distribution Analysis

* To understand how taxes are distributed across different jurisdictions:

```sql
SELECT t.jurisdiction, t.tax_type, 
       COUNT(*) AS occurrence_count,
       SUM(t.amount) AS total_amount,
       AVG(t.amount) AS average_amount
FROM taxes t
GROUP BY t.jurisdiction, t.tax_type
ORDER BY total_amount DESC;
```

#### Employee Earnings Report

* To see how much each employee has earned year-to-date:

```sql
SELECT e.id, e.first_name, e.last_name, b.business_name,
       SUM(pr.gross_pay) AS ytd_gross_pay,
       SUM(pr.net_pay) AS ytd_net_pay,
       SUM(pr.hours_worked_regular) AS regular_hours,
       SUM(pr.hours_worked_overtime) AS overtime_hours
FROM employees e
JOIN businesses b ON e.business_id = b.id
JOIN payroll_records pr ON e.id = pr.employee_id
GROUP BY e.id, e.first_name, e.last_name, b.business_name
ORDER BY ytd_gross_pay DESC;
```

#### Deduction Analysis

* To analyze what types of deductions are most common:

```sql
SELECT d.deduction_type, 
       COUNT(*) AS occurrence_count,
       SUM(d.amount) AS total_amount,
       AVG(d.amount) AS average_amount
FROM deductions d
GROUP BY d.deduction_type
ORDER BY total_amount DESC;
```
