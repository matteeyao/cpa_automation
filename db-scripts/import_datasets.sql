-- Clear all data from tables (in reverse order of dependencies)
TRUNCATE taxes, deductions, payroll_records, pay_periods, employees, businesses, cpa_firms CASCADE;

-- Import CPA Firms
\copy cpa_firms(id, firm_name, contact_name, contact_email, contact_phone, address, city, state, zip_code, created_at, updated_at) FROM 'datasets/cpa_firm.csv' WITH (FORMAT csv, HEADER true);

-- Import Businesses
\copy businesses(id, business_name, cpa_firm_id, address, city, state, zip_code, ein, contact_name, contact_phone, contact_email, created_at, updated_at) FROM 'datasets/business.csv' WITH (FORMAT csv, HEADER true);

-- Import Employees
\copy employees(id, business_id, first_name, last_name, address, city, state, zip_code, email, phone_number, hire_date, termination_date, ssn, pay_rate, pay_type, department, job_title, created_at, updated_at) FROM 'datasets/employee.csv' WITH (FORMAT csv, HEADER true);

-- Import Pay Periods
\copy pay_periods(id, business_id, start_date, end_date, pay_date, description, created_at, updated_at) FROM 'datasets/pay_period.csv' WITH (FORMAT csv, HEADER true);

-- Import Payroll Records
\copy payroll_records(id, employee_id, pay_period_id, hours_worked_regular, hours_worked_overtime, gross_pay, total_deductions, total_taxes, net_pay, created_at, updated_at) FROM 'datasets/payroll_record.csv' WITH (FORMAT csv, HEADER true);

-- Import Deductions
\copy deductions(id, payroll_record_id, deduction_type, amount, created_at, updated_at) FROM 'datasets/deduction.csv' WITH (FORMAT csv, HEADER true);

-- Import Taxes
\copy taxes(id, payroll_record_id, tax_type, jurisdiction, amount, created_at, updated_at) FROM 'datasets/tax.csv' WITH (FORMAT csv, HEADER true);
