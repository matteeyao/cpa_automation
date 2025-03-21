-- CPA Firms Table
CREATE TABLE cpa_firms (
    cpa_firm_id SERIAL PRIMARY KEY,
    firm_name VARCHAR(255) NOT NULL,
    contact_name VARCHAR(255) NOT NULL,
    contact_email VARCHAR(255) NOT NULL,
    contact_phone VARCHAR(20),
    address TEXT,
    city VARCHAR(100),
    state VARCHAR(2),
    zip_code VARCHAR(10),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Businesses Table
CREATE TABLE businesses (
    business_id SERIAL PRIMARY KEY,
    cpa_firm_id INTEGER REFERENCES cpa_firms(cpa_firm_id),
    business_name VARCHAR(255) NOT NULL,
    contact_name VARCHAR(255),
    contact_email VARCHAR(255),
    contact_phone VARCHAR(20),
    address TEXT,
    city VARCHAR(100),
    state VARCHAR(2),
    zip_code VARCHAR(10),
    ein VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Employees Table
CREATE TABLE employees (
    employee_id SERIAL PRIMARY KEY,
    business_id INTEGER REFERENCES businesses(business_id),
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    address TEXT,
    city VARCHAR(100),
    state VARCHAR(2),
    zip_code VARCHAR(10),
    email VARCHAR(255),
    phone_number VARCHAR(20),
    hire_date DATE DEFAULT CURRENT_DATE,
    termination_date DATE,
    ssn VARCHAR(11),
    pay_rate NUMERIC(10,2),
    pay_type VARCHAR(10) CHECK (pay_type IN ('Hourly', 'Salary')),
    department VARCHAR(100),
    job_title VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Pay Periods Table
CREATE TABLE pay_periods (
    pay_period_id SERIAL PRIMARY KEY,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    pay_date DATE NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Payroll Table
CREATE TABLE payroll (
    payroll_id SERIAL PRIMARY KEY,
    employee_id INTEGER REFERENCES employees(employee_id),
    pay_period_id INTEGER REFERENCES pay_periods(pay_period_id),
    hours_worked_regular NUMERIC(5,2),
    hours_worked_overtime NUMERIC(5,2),
    gross_pay NUMERIC(10,2),
    total_deductions NUMERIC(10,2),
    total_taxes NUMERIC(10,2),
    net_pay NUMERIC(10,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Deductions Table
CREATE TABLE deductions (
    deduction_id SERIAL PRIMARY KEY,
    employee_id INTEGER REFERENCES employees(employee_id),
    pay_period_id INTEGER REFERENCES pay_periods(pay_period_id),
    deduction_type VARCHAR(100),
    amount NUMERIC(10,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
