-- =================================================== -- 
--                 Analysis_queries                      -- 
-- =================================================== -- 

/*
Database used: retail_banking

Tables: Branch,
		employee,
        customer,
        account_type, 
        account, transaction,
        card,
        loan_type,
        loan, 
        loan_payment,
        beneficiary,
        fixed_deposit
*/

 use  retail_banking_db ; 
 
-- SECTION A — BASIC QUERIES

-- Q1 1. Display the details of all customers whose KYC has been verified.

 select
 *
 from customer 
 where kyc_status = 'VERIFIED' ;
 
 -- 2. Which accounts currently have a balance less than Rs. 20,000?
 
 select 
 *
 from account 
 where balance < 20000 ;
 
-- 3. List all customers whose first name begins with the letter 'A'.

select
	first_name
from customer
where first_name like 'A%' ;

-- 4. Show all the transactions that took place during March 2025.

select 
*
from transaction 
where month(txn_date) = 3 and year(txn_date) =2025 ;

-- 5. Display all employees earning above Rs. 60,000 per month, sorted from highest to lowest salary.

select concat(first_name,' ',last_name) as emp_name ,
		salary
from employee 
where salary > 60000 
order by salary desc ;

-- SECTION B — AGGREGATE FUNCTIONS (GROUP BY / HAVING)

-- Q6. What is the total balance held by each branch?

select 
	b.branch_id,
    b.branch_name,
    sum(acc.balance) as Total_balance 
from branch as b 
join account as acc 
	on b.branch_id  = acc.branch_id 
group by b.branch_id ; 

-- 7. Find the average balance maintained for each type of account.

select acc.acc_type_id,
		act.type_name,
		avg(acc.balance) as avg_balance
from account  as acc
left join account_type as act 
	on acc.acc_type_id = act.acc_type_id
group by acc_type_id ,act.type_name;

-- 8. How many accounts were opened in each calendar year?

select 
		year(opened_on) as years,
        count(account_no) as total_account 
from account 
group by years 
order by years ;

-- 9. Which branches have more than 2 customer accounts? 

select 	branch_id,
		count(account_no) as total_acc 
from account 
group by branch_id 
having total_acc > 2  ; 

-- 10. Find the total amount transacted through each payment mode (cash, UPI, NEFT, etc.).

select 
		mode ,
        sum(amount) as total_transacted
from transaction 
group by mode 
order by total_transacted ;

-- SECTION C — JOIN QUERIES 

-- 11. Display each customer's name along with their account number, branch name, and current balance.

select concat(c.first_name,'_' ,c.last_name) as customers_name,
		account_no,
        balance,
        branch_name 
from customer as c 
left join account as acc 
	on c.customer_id = acc.customer_id 
join branch as b 
	on acc.branch_id = b.branch_id ;
    
-- 12. List every transaction along with the customer's name and the branch where the account is held.

select t.txn_id,
		t.account_no,
		t.txn_type,
		t.amount,
        t.mode,
        t.txn_date,
        concat(c.first_name,'_',c.last_name) as customers_name,
        b.branch_name
from transaction as t 
join account as acc 
		on t.account_no = acc.account_no 
join  customer as c 
		on acc.customer_id = c.customer_id 
join branch as b 
		on acc.branch_id = b.branch_id ;
        

-- 13. Show each employee's name next to the name of their manager (self join on the employee table)

select emp.emp_id,
		concat(emp.first_name,'_',emp.last_name) as emp_name,
        emp.manager_id,
        concat(m.first_name,'_',m.last_name) as manager_name
from employee as emp
join employee as m 
		on emp.manager_id = m.emp_id ;
        
-- 14. List every customer who has taken a loan, showing the type of loan and the name of the employee who approved it.

select 	DISTINCT
		c.customer_id,
        concat(c.first_name,'_',c.last_name) as customer_name,
        lt.type_name,
        l.approved_by,
        concat(emp.first_name,'_',emp.last_name) as emp_name
from customer  as c  
join loan as l 
		on c.customer_id =  l.customer_id 
join loan_type as lt 
		on l.loan_type_id = lt.loan_type_id 
join employee as emp 
		on l.approved_by = emp.emp_id
        order by customer_id ;
        
-- 15. Find accounts that have never had a single transaction recorded against them.

select 
		acc.account_no 
from account as acc 
left join transaction as t
		on acc.account_no = t.account_no 
where t.account_no is null ;

-- 16. Show all customers along with their fixed deposit amount and maturity date, including customers who don't have an FD at all.

select 
		concat(c.first_name,'_',c.last_name) as customer_name,
        fd.amount,
        fd.maturity_date
from customer as c 
left join fixed_deposit as fd 
		on c.customer_id = fd.customer_id
        order by c.customer_id;
        
-- SECTION D — SUBQUERIES 


-- 17. Which customers have a balance higher than the average balance across all accounts?

select 
		c.customer_id,
		concat(c.first_name,'_',c.last_name) as customers_name,
        acc.balance
from customer as c
join account  as acc 
		on c.customer_id = acc.customer_id 
where  acc.balance > (select avg(balance) from account ) ; 


-- 18. Find the customer who made the single largest transaction.

select  
		c.customer_id,
        concat(c.first_name,'_',c.last_name) as customer_name,
        t.mode,
        t.balance_after
from customer as c 
join  account as acc 	
		on c.customer_id = acc.customer_id
join transaction as t 
		on acc.account_no = t.account_no 
order by t.balance_after desc 
limit 1  ; 


-- 19. List customers who have never taken out a loan.

select 	c.customer_id,
		concat(c.first_name,'_',c.last_name) as customers_name,
        l.loan_id,
        l.principal
from customer as c  
left join loan  as l 
		on c.customer_id = l.customer_id 
where l.loan_id  is null ;

-- 20. Find accounts whose balance exceeds the minimum balance require for their account type.

select 
		acc.account_no,
        act.type_name,
        act.min_balance
from account as acc
join account_type as act 
		on acc.acc_type_id = act.acc_type_id 
where balance > act.min_balance
order by acc.account_no  ;

-- SECTION E — SET OPERATIONS  

-- 21. Find customers who hold both a loan and a fixed deposit.

select  distinct
		concat(c.first_name,'_',c.last_name) as customers_name,
        l.loan_id,
        l.principal,
        fd.account_no,
        fd.amount
from customer as c
join  loan as l 
		on c.customer_id  = l.customer_id 
join fixed_deposit as fd 
		on c.customer_id  = fd.customer_id ;
	
-- USING SET OPERATOR 

SELECT c.customer_id,
       CONCAT(c.first_name, '_', c.last_name) AS customers_name
FROM customer AS c
JOIN loan AS l
    ON c.customer_id = l.customer_id

INTERSECT

SELECT c.customer_id,
       CONCAT(c.first_name, '_', c.last_name) AS customers_name
FROM customer AS c
JOIN fixed_deposit AS fd
    ON c.customer_id = fd.customer_id;
		
-- 22. List all the cities where the bank either has a branch or has a customer registered.

select  
        city
from customer 
union 
select
		city 
from branch ;

-- SECTION F — WINDOW FUNCTIONS, CASE, DATE FUNCTIONS


-- Q23. Rank customers by their account balance within each branch

SELECT
    b.branch_name,
    CONCAT(c.first_name, '_', c.last_name) AS customer_name,
    acc.account_no,
    acc.balance,

    RANK() OVER (
        PARTITION BY acc.branch_id
        ORDER BY acc.balance DESC
    ) AS balance_rank

FROM account AS acc
JOIN customer AS c
    ON acc.customer_id = c.customer_id
JOIN branch AS b
    ON acc.branch_id = b.branch_id

ORDER BY b.branch_name, balance_rank;

-- 24. Running total of deposits for each account

SELECT
    account_no,
    txn_id,
    txn_date,
    amount,

    SUM(amount) OVER (
        PARTITION BY account_no
        ORDER BY txn_date, txn_id
    ) AS running_deposit_total

FROM transaction

WHERE txn_type = 'DEPOSIT'

ORDER BY
    account_no,
    txn_date,
    txn_id;
    
    
-- 25. Classify loans based on outstanding principal

SELECT
    loan_id,
    customer_id,
    principal,
    outstanding,
    ROUND(
        (outstanding / principal) * 100,
        2
    ) AS outstanding_percentage,
    CASE
        WHEN (outstanding / principal) * 100 <= 30
            THEN 'Low Risk'

        WHEN (outstanding / principal) * 100 <= 70
            THEN 'Medium Risk'

        ELSE 'High Risk'
    END AS risk_category
FROM loan; 


-- 26. Active loans that have passed their sanctioned tenure

SELECT
    loan_id,
    customer_id,
    principal,
    sanctioned_on,
    tenure_months,
    status,

    DATE_ADD(
        sanctioned_on,
        INTERVAL tenure_months MONTH
    ) AS expected_end_date

FROM loan

WHERE status = 'ACTIVE'

AND CURDATE() >
    DATE_ADD(
        sanctioned_on,
        INTERVAL tenure_months MONTH
    );
    
    
-- 27. Customer total balance view

CREATE OR REPLACE VIEW customer_total_balance AS
SELECT
    c.customer_id,
    CONCAT(c.first_name,'_',c.last_name) AS customer_name,
    COALESCE(
        SUM(a.balance),
        0
    ) AS total_balance
FROM customer AS c

LEFT JOIN account AS a
    ON c.customer_id = a.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name;
    
-- 28. Active loans view

CREATE OR REPLACE VIEW active_loans AS

SELECT
    l.loan_id,

    CONCAT(
        c.first_name,
        '_',
        c.last_name
    ) AS customer_name,

    lt.type_name AS loan_type,

    l.principal,
    l.outstanding,
    l.sanctioned_on,
    l.tenure_months,

    CONCAT(e.first_name,'_',e.last_name) AS approved_by
FROM loan AS l
JOIN customer AS c
    ON l.customer_id = c.customer_id
JOIN loan_type AS lt
    ON l.loan_type_id = lt.loan_type_id
LEFT JOIN employee AS e
    ON l.approved_by = e.emp_id
WHERE l.status = 'ACTIVE';


-- 29. Branch performance view

CREATE OR REPLACE VIEW branch_performance AS
SELECT
    b.branch_id,
    b.branch_name,
    COALESCE(a.total_accounts, 0) AS total_accounts,
    COALESCE(d.total_deposits, 0) AS total_deposits,
    COALESCE(l.total_loans_disbursed, 0)
        AS total_loans_disbursed
FROM branch AS b
LEFT JOIN
(
    SELECT
        branch_id,
        COUNT(*) AS total_accounts
    FROM account
    GROUP BY branch_id
) AS a
ON b.branch_id = a.branch_id
LEFT JOIN
(
    SELECT
        acc.branch_id,
        SUM(t.amount) AS total_deposits
    FROM account AS acc
    JOIN transaction AS t
        ON acc.account_no = t.account_no
    WHERE t.txn_type = 'DEPOSIT'
    GROUP BY acc.branch_id
) AS d
ON b.branch_id = d.branch_id
LEFT JOIN
(
    SELECT
        branch_id,
        SUM(principal) AS total_loans_disbursed
    FROM loan
    GROUP BY branch_id
) AS l
ON b.branch_id = l.branch_id;


--  THIS WAS IT  :)




 

        
        
        
        
        







