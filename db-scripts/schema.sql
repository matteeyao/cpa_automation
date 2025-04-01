-- ENUM for pay type
CREATE TYPE pay_type_enum AS ENUM ('Hourly', 'Salary');

-- CPA Firms Table
CREATE TABLE cpa_firms (
    id SERIAL PRIMARY KEY,
    firm_name VARCHAR(255) NOT NULL,
    contact_name VARCHAR(255) NOT NULL,
    contact_email VARCHAR(255) NOT NULL,
    contact_phone VARCHAR(20),
    address TEXT,
    city VARCHAR(100),
    state VARCHAR(2) CHECK (state ~ '^[A-Z]{2}$'),
    zip_code VARCHAR(10),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Businesses Table
CREATE TABLE businesses (
    id SERIAL PRIMARY KEY,
    cpa_firm_id INTEGER NOT NULL REFERENCES cpa_firms(id),
    business_name VARCHAR(255) NOT NULL,
    contact_name VARCHAR(255),
    contact_email VARCHAR(255),
    contact_phone VARCHAR(20),
    address TEXT,
    city VARCHAR(100),
    state VARCHAR(2) CHECK (state ~ '^[A-Z]{2}$'),
    zip_code VARCHAR(10),
    ein VARCHAR(20) UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Employees Table
CREATE TABLE employees (
    id SERIAL PRIMARY KEY,
    business_id INTEGER NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    address TEXT,
    city VARCHAR(100),
    state VARCHAR(2) CHECK (state ~ '^[A-Z]{2}$'),
    zip_code VARCHAR(10),
    email VARCHAR(255),
    phone_number VARCHAR(20),
    hire_date DATE DEFAULT CURRENT_DATE,
    termination_date DATE,
    ssn VARCHAR(11) UNIQUE,
    pay_rate DECIMAL(10,2),
    pay_type pay_type_enum NOT NULL,
    department VARCHAR(100),
    job_title VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Pay Periods Table
CREATE TABLE pay_periods (
    id SERIAL PRIMARY KEY,
    business_id INTEGER NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    pay_date DATE NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Payroll Table
CREATE TABLE payroll_records (
    id SERIAL PRIMARY KEY,
    employee_id INTEGER NOT NULL REFERENCES employees(id) ON DELETE CASCADE,
    pay_period_id INTEGER NOT NULL REFERENCES pay_periods(id) ON DELETE CASCADE,
    hours_worked_regular DECIMAL(5,2) DEFAULT 0,
    hours_worked_overtime DECIMAL(5,2) DEFAULT 0,
    gross_pay DECIMAL(10,2) DEFAULT 0,
    total_deductions DECIMAL(10,2) DEFAULT 0,
    total_taxes DECIMAL(10,2) DEFAULT 0,
    net_pay DECIMAL(10,2) DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (employee_id, pay_period_id)
);

-- Deductions Table
CREATE TABLE deductions (
    id SERIAL PRIMARY KEY,
    payroll_record_id INTEGER NOT NULL REFERENCES payroll_records(id) ON DELETE CASCADE,
    deduction_type VARCHAR(100) NOT NULL,
    amount DECIMAL(10,2) DEFAULT 0 NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Taxes Table
CREATE TABLE taxes (
    id SERIAL PRIMARY KEY,
    payroll_record_id INT NOT NULL REFERENCES payroll_records(id) ON DELETE CASCADE,
    tax_type VARCHAR(100) NOT NULL,
    jurisdiction VARCHAR(100),
    amount DECIMAL(10,2) DEFAULT 0 NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Trigger function for updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply triggers for updated_at fields
CREATE TRIGGER trg_update_employees BEFORE UPDATE ON employees
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trg_update_businesses BEFORE UPDATE ON businesses
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trg_update_cpa_firms BEFORE UPDATE ON cpa_firms
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trg_update_pay_periods BEFORE UPDATE ON pay_periods
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trg_update_payroll_records BEFORE UPDATE ON payroll_records
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trg_update_deductions BEFORE UPDATE ON deductions
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trg_update_taxes BEFORE UPDATE ON taxes
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Suggested Indexes
CREATE INDEX idx_employee_id ON payroll_records(employee_id);
CREATE INDEX idx_pay_period_id ON payroll_records(pay_period_id);
CREATE INDEX idx_payroll_record_id_deductions ON deductions(payroll_record_id);
CREATE INDEX idx_payroll_record_id_taxes ON taxes(payroll_record_id);
CREATE INDEX idx_business_id_employees ON employees(business_id);
CREATE INDEX idx_business_id_pay_periods ON pay_periods(business_id);
