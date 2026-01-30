---
name: hr-payroll-developer
description: "Expert HR and payroll system development including employee management, attendance, and salary processing"
---

# HR Payroll Developer

## Overview

Build HR management and payroll systems for employee data and salary processing.

## When to Use This Skill

- Use when building HR systems
- Use when creating payroll solutions

## How It Works

### Step 1: HR Database Schema

```sql
-- Employees
CREATE TABLE employees (
  id SERIAL PRIMARY KEY,
  employee_id VARCHAR(20) UNIQUE,
  first_name VARCHAR(100),
  last_name VARCHAR(100),
  email VARCHAR(255),
  phone VARCHAR(50),
  date_of_birth DATE,
  hire_date DATE,
  department_id INT REFERENCES departments(id),
  position_id INT REFERENCES positions(id),
  manager_id INT REFERENCES employees(id),
  employment_type VARCHAR(20), -- full-time, part-time, contract
  status VARCHAR(20) DEFAULT 'active'
);

-- Salary
CREATE TABLE salaries (
  id SERIAL PRIMARY KEY,
  employee_id INT REFERENCES employees(id),
  base_salary DECIMAL(15,2),
  effective_date DATE,
  currency VARCHAR(3) DEFAULT 'IDR'
);

-- Attendance
CREATE TABLE attendance (
  id SERIAL PRIMARY KEY,
  employee_id INT REFERENCES employees(id),
  date DATE,
  clock_in TIMESTAMP,
  clock_out TIMESTAMP,
  status VARCHAR(20), -- present, absent, late, leave
  notes TEXT
);

-- Leave Requests
CREATE TABLE leave_requests (
  id SERIAL PRIMARY KEY,
  employee_id INT REFERENCES employees(id),
  leave_type VARCHAR(50), -- annual, sick, maternity
  start_date DATE,
  end_date DATE,
  status VARCHAR(20) DEFAULT 'pending',
  approved_by INT REFERENCES employees(id)
);
```

### Step 2: Attendance Processing

```python
from datetime import datetime, time

WORK_START = time(9, 0)  # 09:00
WORK_END = time(18, 0)   # 18:00
LATE_THRESHOLD = 15      # minutes

def process_clock_in(employee_id):
    now = datetime.now()
    
    # Check if late
    status = 'present'
    if now.time() > time(WORK_START.hour, WORK_START.minute + LATE_THRESHOLD):
        status = 'late'
    
    attendance = db.attendance.create(
        employee_id=employee_id,
        date=now.date(),
        clock_in=now,
        status=status
    )
    
    return attendance

def calculate_work_hours(attendance):
    if not attendance.clock_out:
        return 0
    
    delta = attendance.clock_out - attendance.clock_in
    hours = delta.total_seconds() / 3600
    
    # Subtract lunch break (1 hour)
    if hours > 5:
        hours -= 1
    
    return round(hours, 2)
```

### Step 3: Payroll Calculation

```python
def calculate_monthly_salary(employee_id, month, year):
    employee = get_employee(employee_id)
    salary = get_current_salary(employee_id)
    
    # Get attendance
    attendances = get_monthly_attendance(employee_id, month, year)
    work_days = get_work_days_in_month(month, year)
    
    days_present = len([a for a in attendances if a.status in ['present', 'late']])
    days_absent = work_days - days_present
    
    # Calculate components
    base = salary.base_salary
    daily_rate = base / work_days
    
    # Deductions
    absence_deduction = daily_rate * days_absent
    late_deduction = len([a for a in attendances if a.status == 'late']) * 50000
    
    # Allowances
    transport_allowance = 500000
    meal_allowance = 25000 * days_present
    
    # Tax (simplified PPh 21)
    gross = base + transport_allowance + meal_allowance
    tax = calculate_pph21(gross, employee)
    
    # BPJS
    bpjs_kesehatan = base * 0.01  # 1% employee
    bpjs_ketenagakerjaan = base * 0.02  # 2% employee
    
    net_salary = (
        gross 
        - absence_deduction 
        - late_deduction 
        - tax 
        - bpjs_kesehatan 
        - bpjs_ketenagakerjaan
    )
    
    return {
        'gross_salary': gross,
        'deductions': absence_deduction + late_deduction + tax + bpjs_kesehatan + bpjs_ketenagakerjaan,
        'net_salary': net_salary
    }
```

## Best Practices

- ✅ Audit trail for all changes
- ✅ Secure personal data (GDPR/UU PDP)
- ✅ Automate payroll processing
- ❌ Don't skip tax calculations
- ❌ Don't ignore local labor laws

## Related Skills

- `@senior-database-engineer-sql`
- `@senior-backend-developer`
