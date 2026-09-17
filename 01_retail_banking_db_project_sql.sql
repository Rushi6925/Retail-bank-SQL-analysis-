
--  RETAIL BANKING DATABASE

CREATE DATABASE retail_banking_db;
USE retail_banking_db;

--  1. BRANCH

CREATE TABLE branch (
    branch_id INT PRIMARY KEY AUTO_INCREMENT,
    branch_name VARCHAR(60) NOT NULL,
    ifsc_code CHAR(11) NOT NULL UNIQUE,
    city VARCHAR(40) NOT NULL,
    state VARCHAR(40) NOT NULL,
    pincode CHAR(6) NOT NULL,
    phone VARCHAR(15),
    opened_on DATE NOT NULL
);

--  2. EMPLOYEE

CREATE TABLE employee (
    emp_id INT PRIMARY KEY AUTO_INCREMENT,
    branch_id INT NOT NULL,
    first_name VARCHAR(40) NOT NULL,
    last_name VARCHAR(40) NOT NULL,
    designation VARCHAR(40) NOT NULL,
    email VARCHAR(80) UNIQUE,
    phone VARCHAR(15),
    salary DECIMAL(10 , 2 ) CHECK (salary > 0),
    hire_date DATE NOT NULL,
    manager_id INT NULL,
    CONSTRAINT fk_emp_branch FOREIGN KEY (branch_id)
        REFERENCES branch (branch_id),
    CONSTRAINT fk_emp_manager FOREIGN KEY (manager_id)
        REFERENCES employee (emp_id)
);

--  3. CUSTOMER

CREATE TABLE customer (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(40) NOT NULL,
    last_name VARCHAR(40) NOT NULL,
    dob DATE NOT NULL,
    gender ENUM('Male', 'Female', 'Other') NOT NULL,
    email VARCHAR(80) UNIQUE,
    phone VARCHAR(15) NOT NULL UNIQUE,
    aadhaar_no CHAR(12) UNIQUE,
    pan_no CHAR(10) UNIQUE,
    address VARCHAR(120),
    city VARCHAR(40),
    state VARCHAR(40),
    pincode CHAR(6),
    kyc_status ENUM('PENDING', 'VERIFIED', 'REJECTED') DEFAULT 'PENDING',
    registered_on DATE NOT NULL
);

--  4. ACCOUNT_TYPE  (lookup table)

CREATE TABLE account_type (
    acc_type_id INT PRIMARY KEY AUTO_INCREMENT,
    type_name VARCHAR(30) NOT NULL UNIQUE,
    interest_rate DECIMAL(4 , 2 ) NOT NULL,
    min_balance DECIMAL(10 , 2 ) NOT NULL DEFAULT 0,
    description VARCHAR(120)
);

--  5. ACCOUNT

CREATE TABLE account (
    account_no BIGINT PRIMARY KEY,
    customer_id INT NOT NULL,
    branch_id INT NOT NULL,
    acc_type_id INT NOT NULL,
    balance DECIMAL(14 , 2 ) NOT NULL DEFAULT 0 CHECK (balance >= 0),
    opened_on DATE NOT NULL,
    status ENUM('ACTIVE', 'DORMANT', 'CLOSED', 'FROZEN') DEFAULT 'ACTIVE',
    CONSTRAINT fk_acc_cust FOREIGN KEY (customer_id)
        REFERENCES customer (customer_id),
    CONSTRAINT fk_acc_branch FOREIGN KEY (branch_id)
        REFERENCES branch (branch_id),
    CONSTRAINT fk_acc_type FOREIGN KEY (acc_type_id)
        REFERENCES account_type (acc_type_id)
);

--  6. TRANSACTION

CREATE TABLE transaction (
    txn_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    account_no BIGINT NOT NULL,
    txn_type ENUM('DEPOSIT', 'WITHDRAWAL', 'TRANSFER_IN', 'TRANSFER_OUT') NOT NULL,
    amount DECIMAL(14 , 2 ) NOT NULL CHECK (amount > 0),
    txn_date DATETIME NOT NULL,
    mode ENUM('CASH', 'ATM', 'NEFT', 'IMPS', 'UPI', 'CHEQUE', 'ONLINE') NOT NULL,
    balance_after DECIMAL(14 , 2 ) NOT NULL,
    remarks VARCHAR(100),
    CONSTRAINT fk_txn_acc FOREIGN KEY (account_no)
        REFERENCES account (account_no)
);

--  7. CARD

CREATE TABLE card (
    card_id INT PRIMARY KEY AUTO_INCREMENT,
    account_no BIGINT NOT NULL,
    card_number CHAR(16) NOT NULL UNIQUE,
    card_type ENUM('DEBIT', 'CREDIT') NOT NULL,
    network ENUM('VISA', 'MASTERCARD', 'RUPAY') NOT NULL,
    issued_on DATE NOT NULL,
    expiry_date DATE NOT NULL,
    credit_limit DECIMAL(12 , 2 ) DEFAULT 0,
    status ENUM('ACTIVE', 'BLOCKED', 'EXPIRED') DEFAULT 'ACTIVE',
    CONSTRAINT fk_card_acc FOREIGN KEY (account_no)
        REFERENCES account (account_no)
);

--  8. LOAN_TYPE (lookup table)

CREATE TABLE loan_type (
    loan_type_id INT PRIMARY KEY AUTO_INCREMENT,
    type_name VARCHAR(30) NOT NULL UNIQUE,
    interest_rate DECIMAL(4 , 2 ) NOT NULL,
    max_tenure_mths INT NOT NULL
);

--  9. LOAN

CREATE TABLE loan (
    loan_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    branch_id INT NOT NULL,
    loan_type_id INT NOT NULL,
    principal DECIMAL(14 , 2 ) NOT NULL CHECK (principal > 0),
    interest_rate DECIMAL(4 , 2 ) NOT NULL,
    tenure_months INT NOT NULL,
    emi_amount DECIMAL(10 , 2 ) NOT NULL,
    sanctioned_on DATE NOT NULL,
    outstanding DECIMAL(14 , 2 ) NOT NULL,
    status ENUM('ACTIVE', 'CLOSED', 'DEFAULTED') DEFAULT 'ACTIVE',
    approved_by INT NULL,
    CONSTRAINT fk_loan_cust FOREIGN KEY (customer_id)
        REFERENCES customer (customer_id),
    CONSTRAINT fk_loan_brnch FOREIGN KEY (branch_id)
        REFERENCES branch (branch_id),
    CONSTRAINT fk_loan_type FOREIGN KEY (loan_type_id)
        REFERENCES loan_type (loan_type_id),
    CONSTRAINT fk_loan_emp FOREIGN KEY (approved_by)
        REFERENCES employee (emp_id)
);

-- 10. LOAN_PAYMENT

CREATE TABLE loan_payment (
    payment_id INT PRIMARY KEY AUTO_INCREMENT,
    loan_id INT NOT NULL,
    payment_date DATE NOT NULL,
    amount_paid DECIMAL(10 , 2 ) NOT NULL CHECK (amount_paid > 0),
    principal_part DECIMAL(10 , 2 ) NOT NULL,
    interest_part DECIMAL(10 , 2 ) NOT NULL,
    mode ENUM('AUTO_DEBIT', 'CASH', 'ONLINE', 'CHEQUE') NOT NULL,
    CONSTRAINT fk_pay_loan FOREIGN KEY (loan_id)
        REFERENCES loan (loan_id)
);


-- 11. BENEFICIARY (payee added by a customer)

CREATE TABLE beneficiary (
    beneficiary_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    nickname VARCHAR(40) NOT NULL,
    payee_acc_no BIGINT NOT NULL,
    payee_name VARCHAR(60) NOT NULL,
    ifsc_code CHAR(11) NOT NULL,
    added_on DATE NOT NULL,
    CONSTRAINT fk_ben_cust FOREIGN KEY (customer_id)
        REFERENCES customer (customer_id)
);

-- 12. FIXED_DEPOSIT

CREATE TABLE fixed_deposit (
    fd_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    account_no BIGINT NOT NULL,
    amount DECIMAL(14 , 2 ) NOT NULL CHECK (amount >= 1000),
    interest_rate DECIMAL(4 , 2 ) NOT NULL,
    start_date DATE NOT NULL,
    maturity_date DATE NOT NULL,
    maturity_amount DECIMAL(14 , 2 ) NOT NULL,
    status ENUM('ACTIVE', 'MATURED', 'PREMATURE_CLOSED') DEFAULT 'ACTIVE',
    CONSTRAINT fk_fd_cust FOREIGN KEY (customer_id)
        REFERENCES customer (customer_id),
    CONSTRAINT fk_fd_acc FOREIGN KEY (account_no)
        REFERENCES account (account_no)
);


-- ============================================================
--                      SAMPLE DATA
-- ============================================================

-- ---------- BRANCH ----------

INSERT INTO branch (branch_name, ifsc_code, city, state, pincode, phone, opened_on)
 VALUES
('Shivajinagar Branch',  'RBNK0001234', 'Pune',      'Maharashtra', '411005', '02025551001', '2005-04-12'),
('Andheri East Branch',  'RBNK0002345', 'Mumbai',    'Maharashtra', '400069', '02225551002', '2007-08-23'),
('Koramangala Branch',   'RBNK0003456', 'Bengaluru', 'Karnataka',   '560034', '08025551003', '2010-01-15'),
('Connaught Place Branch','RBNK0004567','New Delhi', 'Delhi',       '110001', '01125551004', '2003-11-30'),
('Banjara Hills Branch', 'RBNK0005678', 'Hyderabad', 'Telangana',   '500034', '04025551005', '2012-06-05');

SELECT 
    *
FROM
    branch;

-- ---------- EMPLOYEE ----------

INSERT INTO employee (branch_id, first_name, last_name, designation, email, phone, salary, hire_date, manager_id)
 VALUES
(1, 'Rajesh',  'Kulkarni', 'Branch Manager', 'rajesh.k@rbnk.in',  '9822011001',  95000.00, '2012-03-01', NULL),
(1, 'Sneha',   'Deshmukh', 'Loan Officer',   'sneha.d@rbnk.in',   '9822011002',  58000.00, '2016-07-19', 1),
(1, 'Amit',    'Pawar',    'Cashier',        'amit.p@rbnk.in',    '9822011003',  34000.00, '2019-02-11', 1),
(2, 'Farhan',  'Shaikh',   'Branch Manager', 'farhan.s@rbnk.in',  '9833011004',  98000.00, '2011-09-05', NULL),
(2, 'Priya',   'Nair',     'Relationship Mgr','priya.n@rbnk.in',  '9833011005',  62000.00, '2018-05-22', 4),
(3, 'Kiran',   'Rao',      'Branch Manager', 'kiran.r@rbnk.in',   '9844011006',  92000.00, '2014-01-20', NULL),
(3, 'Divya',   'Menon',    'Loan Officer',   'divya.m@rbnk.in',   '9844011007',  56000.00, '2020-10-01', 6),
(4, 'Arvind',  'Sharma',   'Branch Manager', 'arvind.s@rbnk.in',  '9811011008', 101000.00, '2009-04-17', NULL),
(4, 'Neha',    'Gupta',    'Cashier',        'neha.g@rbnk.in',    '9811011009',  36000.00, '2021-06-14', 8),
(5, 'Srinivas','Reddy',    'Branch Manager', 'srinivas.r@rbnk.in','9866011010',  94000.00, '2015-12-02', NULL);

SELECT 
    *
FROM
    employee;

-- ---------- ACCOUNT_TYPE ----------

INSERT INTO account_type (type_name, interest_rate, min_balance, description) 
VALUES
('Savings',        3.50,  5000.00,  'Regular savings account for individuals'),
('Current',        0.00, 10000.00,  'Business account with unlimited transactions'),
('Salary',         3.50,     0.00,  'Zero balance account for salaried employees'),
('Senior Citizen', 4.25,  1000.00,  'Higher interest savings for age 60+'),
('NRI Savings',    3.75, 25000.00,  'Savings account for non-resident Indians');

SELECT 
    *
FROM
    account_type;

-- ---------- CUSTOMER ----------

INSERT INTO customer (first_name, last_name, dob, gender, email, phone, aadhaar_no, pan_no, address, city, state, pincode, kyc_status, registered_on)
 VALUES
('Aarav',   'Joshi',    '1995-03-14', 'Male', 'aarav.joshi@mail.com',   '9822100001', '321045678901', 'AXJPJ1234K', '12 FC Road',            'Pune',      'Maharashtra', '411004', 'VERIFIED', '2018-06-10'),
('Isha',    'Kapoor',   '1992-11-02', 'Female', 'isha.kapoor@mail.com',   '9822100002', '321045678902', 'BKJPK2345L', '44 Baner Road',         'Pune',      'Maharashtra', '411045', 'VERIFIED', '2019-01-22'),
('Rohan',   'Mehta',    '1988-07-25', 'Male', 'rohan.mehta@mail.com',   '9833100003', '321045678903', 'CMJPM3456M', '7 Linking Road',        'Mumbai',    'Maharashtra', '400050', 'VERIFIED', '2016-09-05'),
('Ananya',  'Iyer',     '1999-02-18', 'Female', 'ananya.iyer@mail.com',   '9844100004', '321045678904', 'DIJPI4567N', '88 5th Block',          'Bengaluru', 'Karnataka',   '560034', 'VERIFIED', '2021-03-17'),
('Vikram',  'Singh',    '1975-05-09', 'Male', 'vikram.singh@mail.com',  '9811100005', '321045678905', 'ESJPS5678O', '3 Barakhamba Road',     'New Delhi', 'Delhi',       '110001', 'VERIFIED', '2010-12-01'),
('Meera',   'Reddy',    '1961-08-30', 'Female', 'meera.reddy@mail.com',   '9866100006', '321045678906', 'FRJPR6789P', '21 Road No.10',         'Hyderabad', 'Telangana',   '500034', 'VERIFIED', '2015-07-14'),
('Karan',   'Malhotra', '1997-12-12', 'Male', 'karan.m@mail.com',       '9811100007', '321045678907', 'GMJPM7890Q', '56 Karol Bagh',         'New Delhi', 'Delhi',       '110005', 'PENDING',  '2023-02-08'),
('Sanya',   'Bose',     '1993-04-06', 'Female', 'sanya.bose@mail.com',    '9833100008', '321045678908', 'HBJPB8901R', '9 Powai Lake View',     'Mumbai',    'Maharashtra', '400076', 'VERIFIED', '2020-11-19'),
('Aditya',  'Kulkarni', '1985-10-21', 'Male', 'aditya.k@mail.com',      '9822100009', '321045678909', 'IKJPK9012S', '31 Kothrud',            'Pune',      'Maharashtra', '411038', 'VERIFIED', '2014-05-30'),
('Nisha',   'Verma',    '2000-06-27', 'Female', 'nisha.verma@mail.com',   '9844100010', '321045678910', 'JVJPV0123T', '14 Indiranagar',        'Bengaluru', 'Karnataka',   '560038', 'VERIFIED', '2022-08-11'),
('Tanmay',  'Patil',    '1991-01-05', 'Male', 'tanmay.patil@mail.com',  '9822100011', '321045678911', 'KPJPP1234U', '67 Hadapsar',           'Pune',      'Maharashtra', '411028', 'VERIFIED', '2019-09-25'),
('Zoya',    'Khan',     '1996-09-16', 'Female', 'zoya.khan@mail.com',     '9833100012', '321045678912', 'LKJPK2345V', '5 Bandra West',         'Mumbai',    'Maharashtra', '400050', 'REJECTED', '2024-01-03');

SELECT 
    *
FROM
    customer;

-- ---------- ACCOUNT ----------
INSERT INTO account (account_no, customer_id, branch_id, acc_type_id, balance, opened_on, status) 
VALUES
(100000000001,  1, 1, 1,   85400.50, '2018-06-10', 'ACTIVE'),
(100000000002,  1, 1, 3,   42300.00, '2020-02-14', 'ACTIVE'),
(100000000003,  2, 1, 1,  156700.75, '2019-01-22', 'ACTIVE'),
(100000000004,  3, 2, 2,  892450.00, '2016-09-05', 'ACTIVE'),
(100000000005,  3, 2, 1,   61200.25, '2017-04-18', 'ACTIVE'),
(100000000006,  4, 3, 3,   28900.00, '2021-03-17', 'ACTIVE'),
(100000000007,  5, 4, 1,  445600.00, '2010-12-01', 'ACTIVE'),
(100000000008,  6, 5, 4,  312000.00, '2015-07-14', 'ACTIVE'),
(100000000009,  7, 4, 1,    3200.00, '2023-02-08', 'FROZEN'),
(100000000010,  8, 2, 1,   97850.60, '2020-11-19', 'ACTIVE'),
(100000000011,  9, 1, 2,  523400.00, '2014-05-30', 'ACTIVE'),
(100000000012, 10, 3, 3,   19750.00, '2022-08-11', 'ACTIVE'),
(100000000013, 11, 1, 1,   74300.00, '2019-09-25', 'DORMANT'),
(100000000014, 12, 2, 1,       0.00, '2024-01-03', 'CLOSED');

SELECT 
    *
FROM
    account;

-- ---------- TRANSACTION ----------

INSERT INTO transaction (account_no, txn_type, amount, txn_date, mode, balance_after, remarks)
VALUES
(100000000001, 'DEPOSIT',      50000.00, '2025-01-05 10:15:00', 'CASH',    50000.00,  'Initial cash deposit'),
(100000000001, 'WITHDRAWAL',    5000.00, '2025-01-12 17:42:00', 'ATM',     45000.00,  'ATM withdrawal Shivajinagar'),
(100000000001, 'TRANSFER_IN',   4500.00, '2025-02-01 09:00:00', 'UPI',     49500.00,  'UPI from friend'),
(100000000001, 'DEPOSIT',      40000.50, '2025-03-10 11:30:00', 'NEFT',    89500.50,  'Salary credit'),
(100000000001, 'TRANSFER_OUT',  4100.00, '2025-03-15 20:05:00', 'UPI',     85400.50,  'Electricity bill'),
(100000000003, 'DEPOSIT',     120000.00, '2025-01-08 12:00:00', 'CHEQUE', 120000.00,  'Cheque deposit'),
(100000000003, 'TRANSFER_IN',  50000.00, '2025-02-20 14:25:00', 'IMPS',   170000.00,  'Transfer from spouse'),
(100000000003, 'WITHDRAWAL',   13299.25, '2025-03-02 16:10:00', 'ONLINE', 156700.75,  'Online purchase'),
(100000000004, 'DEPOSIT',     500000.00, '2025-01-03 09:45:00', 'NEFT',   500000.00,  'Vendor payment received'),
(100000000004, 'TRANSFER_IN',  450000.00,'2025-02-11 11:20:00', 'NEFT',   950000.00,  'Client settlement'),
(100000000004, 'TRANSFER_OUT',  57550.00,'2025-03-05 15:55:00', 'NEFT',   892450.00,  'Supplier payment'),
(100000000007, 'DEPOSIT',     300000.00, '2025-01-15 10:05:00', 'CASH',   300000.00,  'Business cash deposit'),
(100000000007, 'DEPOSIT',     160000.00, '2025-02-25 13:40:00', 'NEFT',   460000.00,  'Rent income'),
(100000000007, 'WITHDRAWAL',   14400.00, '2025-03-18 18:30:00', 'ATM',    445600.00,  'ATM withdrawal CP'),
(100000000008, 'DEPOSIT',     250000.00, '2025-01-20 10:50:00', 'CHEQUE', 250000.00,  'Pension arrears'),
(100000000008, 'TRANSFER_IN',   62000.00,'2025-03-01 09:15:00', 'IMPS',   312000.00,  'From son'),
(100000000010, 'DEPOSIT',      95000.00, '2025-02-02 11:11:00', 'NEFT',    95000.00,  'Salary credit'),
(100000000010, 'TRANSFER_IN',   8850.60, '2025-03-09 19:20:00', 'UPI',    103850.60,  'Refund'),
(100000000010, 'WITHDRAWAL',    6000.00, '2025-03-21 08:40:00', 'ATM',     97850.60,  'ATM withdrawal Andheri'),
(100000000011, 'DEPOSIT',     600000.00, '2025-01-10 10:00:00', 'NEFT',   600000.00,  'Business receipts'),
(100000000011, 'TRANSFER_OUT',  76600.00,'2025-03-12 17:05:00', 'NEFT',   523400.00,  'GST payment'),
(100000000012, 'DEPOSIT',      25000.00, '2025-02-05 10:30:00', 'NEFT',    25000.00,  'Salary credit'),
(100000000012, 'WITHDRAWAL',    5250.00, '2025-03-14 21:00:00', 'UPI',     19750.00,  'Food delivery'),
(100000000006, 'DEPOSIT',      30000.00, '2025-01-28 10:00:00', 'NEFT',    30000.00,  'Salary credit'),
(100000000006, 'WITHDRAWAL',    1100.00, '2025-03-19 12:45:00', 'UPI',     28900.00,  'Mobile recharge');

SELECT 
    *
FROM
    transaction;

-- ---------- CARD ----------

INSERT INTO card (account_no, card_number, card_type, network, issued_on, expiry_date, credit_limit, status) 
VALUES
(100000000001, '4532100000010001', 'DEBIT',  'VISA',       '2018-06-15', '2028-06-30',       0.00, 'ACTIVE'),
(100000000003, '5241100000010002', 'DEBIT',  'MASTERCARD', '2019-01-28', '2029-01-31',       0.00, 'ACTIVE'),
(100000000003, '5241200000010003', 'CREDIT', 'MASTERCARD', '2021-05-10', '2027-05-31',  200000.00, 'ACTIVE'),
(100000000004, '6521100000010004', 'DEBIT',  'RUPAY',      '2016-09-10', '2026-09-30',       0.00, 'ACTIVE'),
(100000000005, '4532100000010005', 'DEBIT',  'VISA',       '2017-04-25', '2027-04-30',       0.00, 'ACTIVE'),
(100000000007, '4532200000010006', 'CREDIT', 'VISA',       '2019-08-01', '2026-08-31',  500000.00, 'ACTIVE'),
(100000000008, '6521100000010007', 'DEBIT',  'RUPAY',      '2015-07-20', '2025-07-31',       0.00, 'EXPIRED'),
(100000000009, '4532100000010008', 'DEBIT',  'VISA',       '2023-02-14', '2033-02-28',       0.00, 'BLOCKED'),
(100000000010, '5241100000010009', 'DEBIT',  'MASTERCARD', '2020-11-25', '2030-11-30',       0.00, 'ACTIVE'),
(100000000011, '4532200000010010', 'CREDIT', 'VISA',       '2018-03-12', '2027-03-31',  750000.00, 'ACTIVE');

SELECT 
    *
FROM
    card;

-- ---------- LOAN_TYPE ----------
INSERT INTO loan_type (type_name, interest_rate, max_tenure_mths) 
VALUES
('Home Loan',     8.50, 360),
('Car Loan',      9.25,  84),
('Personal Loan',13.50,  60),
('Education Loan',7.75, 120),
('Gold Loan',    10.00,  36);

SELECT 
    *
FROM
    loan_type;

-- ---------- LOAN ----------

INSERT INTO loan (customer_id, branch_id, loan_type_id, principal, interest_rate, tenure_months, emi_amount, sanctioned_on, outstanding, status, approved_by) 
VALUES
( 1, 1, 2,   650000.00,  9.25,  60,  13580.00, '2022-04-15',  310450.00, 'ACTIVE',   2),
( 2, 1, 1,  4500000.00,  8.50, 240,  39050.00, '2021-07-01', 3985600.00, 'ACTIVE',   2),
( 3, 2, 3,   500000.00, 13.50,  48,  13590.00, '2023-01-20',  248900.00, 'ACTIVE',   5),
( 4, 3, 4,   800000.00,  7.75, 120,   9600.00, '2021-09-10',  612300.00, 'ACTIVE',   7),
( 5, 4, 1,  6000000.00,  8.50, 300,  48300.00, '2018-05-05', 4820000.00, 'ACTIVE',   8),
( 6, 5, 5,   300000.00, 10.00,  24,  13840.00, '2023-11-12',        0.00, 'CLOSED',  10),
( 8, 2, 3,   250000.00, 13.50,  36,   8480.00, '2024-02-18',  162700.00, 'ACTIVE',   5),
( 9, 1, 2,   900000.00,  9.25,  72,  16250.00, '2020-08-22',  289000.00, 'ACTIVE',   2),
(10, 3, 4,   400000.00,  7.75,  84,   6180.00, '2023-06-30',  352400.00, 'ACTIVE',   7),
(11, 1, 3,   350000.00, 13.50,  48,   9510.00, '2022-10-05',  198500.00, 'DEFAULTED',2);

SELECT 
    *
FROM
    loan;

-- ---------- LOAN_PAYMENT ----------

INSERT INTO loan_payment (loan_id, payment_date, amount_paid, principal_part, interest_part, mode) 
VALUES
(1, '2025-01-05', 13580.00,  11190.00, 2390.00, 'AUTO_DEBIT'),
(1, '2025-02-05', 13580.00,  11275.00, 2305.00, 'AUTO_DEBIT'),
(1, '2025-03-05', 13580.00,  11362.00, 2218.00, 'AUTO_DEBIT'),
(2, '2025-01-01', 39050.00,  10800.00, 28250.00,'AUTO_DEBIT'),
(2, '2025-02-01', 39050.00,  10876.00, 28174.00,'AUTO_DEBIT'),
(2, '2025-03-01', 39050.00,  10953.00, 28097.00,'AUTO_DEBIT'),
(3, '2025-01-20', 13590.00,   9740.00, 3850.00, 'ONLINE'),
(3, '2025-02-20', 13590.00,   9850.00, 3740.00, 'ONLINE'),
(4, '2025-02-10',  9600.00,   5650.00, 3950.00, 'AUTO_DEBIT'),
(5, '2025-03-05', 48300.00,  14150.00, 34150.00,'AUTO_DEBIT'),
(6, '2025-11-12', 13840.00,  13260.00,   580.00,'CASH'),
(7, '2025-03-18',  8480.00,   6650.00, 1830.00, 'AUTO_DEBIT'),
(8, '2025-03-22', 16250.00,  14020.00, 2230.00, 'AUTO_DEBIT'),
(9, '2025-03-30',  6180.00,   3900.00, 2280.00, 'ONLINE'),
(10,'2025-01-05',  9510.00,   7280.00, 2230.00, 'CHEQUE');

-- ---------- BENEFICIARY ----------

INSERT INTO beneficiary (customer_id, nickname, payee_acc_no, payee_name, ifsc_code, added_on) VALUES
( 1, 'Isha',        100000000003, 'Isha Kapoor',    'RBNK0001234', '2021-05-11'),
( 1, 'Landlord',    100000000011, 'Aditya Kulkarni','RBNK0001234', '2022-01-08'),
( 2, 'Aarav',       100000000001, 'Aarav Joshi',    'RBNK0001234', '2021-05-12'),
( 3, 'Sanya',       100000000010, 'Sanya Bose',     'RBNK0002345', '2022-07-19'),
( 5, 'Meera Aunty', 100000000008, 'Meera Reddy',    'RBNK0005678', '2020-03-04'),
( 8, 'Rohan',       100000000004, 'Rohan Mehta',    'RBNK0002345', '2023-09-27'),
( 9, 'Tanmay',      100000000013, 'Tanmay Patil',   'RBNK0001234', '2021-11-15'),
(10, 'Ananya',      100000000006, 'Ananya Iyer',    'RBNK0003456', '2023-04-02');

-- ---------- FIXED_DEPOSIT ----------

INSERT INTO fixed_deposit (customer_id, account_no, amount, interest_rate, start_date, maturity_date, maturity_amount, status) 
VALUES
( 1, 100000000001,  100000.00, 6.75, '2023-04-01', '2026-04-01', 121650.00, 'ACTIVE'),
( 2, 100000000003,  250000.00, 7.00, '2022-06-15', '2025-06-15', 302500.00, 'MATURED'),
( 3, 100000000004,  500000.00, 6.90, '2024-01-10', '2027-01-10', 610350.00, 'ACTIVE'),
( 5, 100000000007, 1000000.00, 7.10, '2023-09-20', '2028-09-20', 1417500.00,'ACTIVE'),
( 6, 100000000008,  400000.00, 7.60, '2024-03-05', '2027-03-05', 497600.00, 'ACTIVE'),
( 8, 100000000010,  150000.00, 6.75, '2023-12-01', '2025-12-01', 170600.00, 'MATURED'),
( 9, 100000000011,  750000.00, 7.00, '2024-05-18', '2029-05-18', 1042500.00,'ACTIVE'),
(11, 100000000013,   50000.00, 6.50, '2023-02-14', '2025-02-14',  56700.00, 'PREMATURE_CLOSED');

-- ===================================================================================================== -- 
-- 							Quick check of inserted Data                                                 -- 
-- ===================================================================================================== -- 

select * from account ;
select * from account_type ;
select * from beneficiary ;
select * from branch ;
select * from card ;
select * from customer ;
select * from employee ;
select * from fixed_deposit ;
select * from loan ;
select * from loan_payment ;
select * from loan_type ;
select * from transaction ;


