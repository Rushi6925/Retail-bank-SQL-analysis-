# Retail-bank-SQL-analysis-
<P>This is a Retail-bank-sql-analysis-project<P>
<br>
# Retail Banking SQL Analysis

A MySQL project based on a retail banking database. I built this project to practice SQL on a realistic dataset and understand how banking data can be stored, connected, and analyzed.

The database covers customers, accounts, transactions, branches, employees, loans, and loan payments.

## About the Project

The main goal of this project was to work with a relational database and solve different business-related questions using SQL.

I started by creating the database and tables, added sample data, created the ER diagram, and then worked through a set of analysis queries. I also used some advanced MySQL features such as views, stored procedures, transactions, and triggers.

## Database Structure

The main tables in the project are:

* `customer` — customer information
* `account` — customer bank accounts and balances
* `account_type` — different types of bank accounts and minimum balance requirements
* `transaction` — deposits, withdrawals and transfers
* `branch` — bank branch information
* `employee` — bank employees and managers
* `loan` — customer loan information
* `loan_type` — different loan categories
* `loan_payment` — loan repayment details

## SQL Analysis

I worked on 34 SQL questions covering different levels of SQL.

Some of the analysis includes:

* Finding customers and their accounts
* Analyzing account balances
* Finding customers with loans
* Analyzing transactions and payment modes
* Finding top customers based on spending
* Branch-wise account and transaction analysis
* Loan and customer analysis
* Identifying active and overdue loans
* Ranking customers within branches
* Running totals using window functions
* Loan risk classification using `CASE`
* Date-based loan analysis

## SQL Concepts Used

### Basic SQL

* `SELECT`
* `WHERE`
* `ORDER BY`
* `DISTINCT`
* `LIMIT`

### Joins

* `INNER JOIN`
* `LEFT JOIN`
* `SELF JOIN`
* `CROSS JOIN`

### Aggregation

* `GROUP BY`
* `HAVING`
* `COUNT()`
* `SUM()`
* `AVG()`
* `MIN()`
* `MAX()`

### Advanced SQL

* Subqueries
* CTEs
* Set operators
* Window functions
* `RANK()`
* `ROW_NUMBER()`
* `CASE`
* Date and time functions
* Type conversion functions

### Database Features

* Views
* Stored procedures
* Transactions
* Triggers
* Error handling
* Audit table

## Views

I created views for commonly used analysis:

* Customer total balance
* Active loans
* Branch performance

## Project Files

```text
Retail-Banking-SQL-Project/
│
├── 01_Retail_banking_db.sql
├── 02_Analysis_query_retail_banking.sql
├── ER_Diagram.png
└── README.md
```

## Tools Used

* MySQL
* MySQL Workbench
* Git
* GitHub

## What I Practiced

This project helped me get more comfortable with writing SQL on multiple related tables instead of working with small practice datasets.

The main things I practiced were joining tables, writing analytical queries, using window functions, working with dates, and understanding how database features such as views, procedures, and triggers can be used in a real-world type of application.

## Future Improvements

Some things I plan to add later:

* Power BI dashboard
* More loan analysis
* Better data visualizations

## Author

**Rushikesh Panchariya**

GitHub: [Rushi6925](https://github.com/Rushi6925)
