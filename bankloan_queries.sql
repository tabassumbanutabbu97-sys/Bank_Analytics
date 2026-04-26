CREATE DATABASE BankLoanProject;

USE BankLoanProject;

CREATE DATABASE IF NOT EXISTS bank_analytics;
USE bank_analytics;

CREATE TABLE finance_data (
    id INT PRIMARY KEY,
    loan_amnt INT,
    funded_amnt INT,
    funded_amnt_inv DECIMAL(15, 4),
    term VARCHAR(20),
    int_rate DECIMAL(10, 2),
    installment DECIMAL(10, 2),
    grade VARCHAR(5),
    sub_grade VARCHAR(5),
    emp_length VARCHAR(50),
    home_ownership VARCHAR(20),
    annual_inc VARCHAR(50),
    verification_status VARCHAR(50),
    issue_d VARCHAR(20),
    loan_status VARCHAR(50),
    purpose VARCHAR(100),
    addr_state VARCHAR(5),
    dti DECIMAL(10, 2),
    delinq_2yrs INT,
    earliest_cr_line VARCHAR(20),
    inq_last_6mths INT,
    open_acc INT,
    pub_rec INT,
    revol_bal INT,
    revol_util VARCHAR(20),
    total_acc INT,
    out_prncp DECIMAL(15, 2),
    out_prncp_inv DECIMAL(15, 2),
    total_pymnt DECIMAL(15, 4),
    total_pymnt_inv DECIMAL(15, 4),
    total_rec_prncp DECIMAL(15, 4),
    total_rec_int DECIMAL(15, 4),
    total_rec_late_fee DECIMAL(15, 2),
    recoveries DECIMAL(15, 2),
    collection_recovery_fee DECIMAL(15, 2),
    last_pymnt_d VARCHAR(20),
    last_pymnt_amnt DECIMAL(15, 2),
    next_pymnt_d VARCHAR(20) NULL,
    last_credit_pull_d VARCHAR(20)
);

SET GLOBAL local_infile = 1;

LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Clean_Data.csv" 
INTO TABLE finance_data
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

SELECT * FROM finance_data;

-- KPI 1 - Year wise loan amount Stats
SELECT 
    YEAR(STR_TO_DATE(issue_d, '%d-%m-%Y')) AS loan_year, 
    SUM(loan_amnt) AS total_loan_amount
FROM finance_data
GROUP BY loan_year
ORDER BY loan_year;

-- KPI 2 - Grade and sub grade wise revol_bal
SELECT 
    grade, 
    sub_grade, 
    SUM(revol_bal) AS total_revolving_balance
FROM finance_data
GROUP BY grade, sub_grade
ORDER BY grade, sub_grade;

-- KPI 3 - Total Payment for Verified Status Vs Total Payment for Non Verified Status
SELECT 
    verification_status, 
    SUM(total_pymnt) AS total_payment_received
FROM finance_data
WHERE verification_status IN ('Verified', 'Not Verified')
GROUP BY verification_status;

-- KPI 4 - State wise and month wise loan status
SELECT 
    addr_state, MONTHNAME(STR_TO_DATE(issue_d, '%d-%m-%Y')) AS issue_month, 
    loan_status, COUNT(id) AS loan_count
FROM finance_data
GROUP BY addr_state, issue_month, loan_status, 
    MONTH(STR_TO_DATE(issue_d, '%d-%m-%Y'))
ORDER BY 
    addr_state, MONTH(STR_TO_DATE(issue_d, '%d-%m-%Y'));

-- KPI 5 - Home ownership Vs last payment date stats
SELECT 
    home_ownership, 
    YEAR(STR_TO_DATE(last_pymnt_d, '%d-%m-%Y')) AS last_pymnt_year,
    MONTHNAME(STR_TO_DATE(last_pymnt_d, '%d-%m-%Y')) AS last_pymnt_month,
    SUM(last_pymnt_amnt) AS total_last_payment_amount
FROM finance_data
WHERE 
    last_pymnt_d IS NOT NULL AND last_pymnt_d != '' AND last_pymnt_d != 'NA'AND home_ownership IS NOT NULL AND home_ownership != ''
GROUP BY 
    home_ownership, 
    last_pymnt_year, 
    last_pymnt_month,
    MONTH(STR_TO_DATE(last_pymnt_d, '%d-%m-%Y'))
ORDER BY 
    last_pymnt_year, 
    MONTH(STR_TO_DATE(last_pymnt_d, '%d-%m-%Y'));
    
SHOW VARIABLES LIKE "secure_file_priv";