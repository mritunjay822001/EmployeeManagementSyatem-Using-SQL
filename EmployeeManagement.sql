-- Create Departments table
CREATE TABLE Departments (
    department_id NUMBER PRIMARY KEY,
    department_name VARCHAR2(50) NOT NULL,
    location VARCHAR2(100)
);

-- Create Employees table
CREATE TABLE Employees (
    employee_id NUMBER PRIMARY KEY,
    first_name VARCHAR2(50) NOT NULL,
    last_name VARCHAR2(50) NOT NULL,
    email VARCHAR2(100) UNIQUE,
    phone_number VARCHAR2(20),
    hire_date DATE,
    job_title VARCHAR2(50),
    salary NUMBER(10,2),
    department_id NUMBER,
    CONSTRAINT fk_department
        FOREIGN KEY (department_id)
        REFERENCES Departments(department_id)
);

-- Create a sequence for employee_id
CREATE SEQUENCE emp_id_seq
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;

-- Create a trigger to automatically generate employee_id
CREATE OR REPLACE TRIGGER trg_employee_id
BEFORE INSERT ON Employees
FOR EACH ROW
BEGIN
    SELECT emp_id_seq.NEXTVAL
    INTO :new.employee_id
    FROM dual;
END;
/

-- Create a procedure to insert a new employee
CREATE OR REPLACE PROCEDURE add_employee(
    p_first_name IN VARCHAR2,
    p_last_name IN VARCHAR2,
    p_email IN VARCHAR2,
    p_phone_number IN VARCHAR2,
    p_hire_date IN DATE,
    p_job_title IN VARCHAR2,
    p_salary IN NUMBER,
    p_department_id IN NUMBER
)
IS
BEGIN
    INSERT INTO Employees (
        first_name, last_name, email, phone_number,
        hire_date, job_title, salary, department_id
    ) VALUES (
        p_first_name, p_last_name, p_email, p_phone_number,
        p_hire_date, p_job_title, p_salary, p_department_id
    );
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Employee added successfully.');
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/

-- Create a function to calculate years of service
CREATE OR REPLACE FUNCTION calculate_years_of_service(
    p_employee_id IN NUMBER
) RETURN NUMBER
IS
    v_hire_date DATE;
    v_years_of_service NUMBER;
BEGIN
    SELECT hire_date INTO v_hire_date
    FROM Employees
    WHERE employee_id = p_employee_id;
    
    v_years_of_service := TRUNC(MONTHS_BETWEEN(SYSDATE, v_hire_date) / 12);
    
    RETURN v_years_of_service;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN NULL;
END;
/

-- Create a view to display employee details with department name
CREATE OR REPLACE VIEW vw_employee_details AS
SELECT 
    e.employee_id,
    e.first_name,
    e.last_name,
    e.email,
    e.phone_number,
    e.hire_date,
    e.job_title,
    e.salary,
    d.department_name,
    d.location,
    calculate_years_of_service(e.employee_id) AS years_of_service
FROM 
    Employees e
JOIN 
    Departments d ON e.department_id = d.department_id;

-- Insert sample data into Departments
INSERT INTO Departments (department_id, department_name, location) VALUES (1, 'IT', 'New York');
INSERT INTO Departments (department_id, department_name, location) VALUES (2, 'HR', 'Los Angeles');
INSERT INTO Departments (department_id, department_name, location) VALUES (3, 'Finance', 'Chicago');

-- Insert sample data into Employees using the add_employee procedure
BEGIN
    add_employee('John', 'Doe', 'john.doe@example.com', '1234567890', TO_DATE('2020-01-15', 'YYYY-MM-DD'), 'Software Engineer', 75000, 1);
    add_employee('Jane', 'Smith', 'jane.smith@example.com', '9876543210', TO_DATE('2019-05-20', 'YYYY-MM-DD'), 'HR Manager', 80000, 2);
    add_employee('Mike', 'Johnson', 'mike.johnson@example.com', '5555555555', TO_DATE('2021-03-10', 'YYYY-MM-DD'), 'Financial Analyst', 70000, 3);
END;
/

-- Sample query to test the view
SELECT * FROM vw_employee_details;

-- Sample query to test the calculate_years_of_service function
SELECT 
    employee_id, 
    first_name, 
    last_name, 
    calculate_years_of_service(employee_id) AS years_of_service
FROM 
    Employees;