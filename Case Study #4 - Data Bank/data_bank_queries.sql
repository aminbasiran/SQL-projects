-- A
-- How many unique nodes are there on the Data Bank system?

select count(distinct node_id) from customer_nodes;

-- What is the number of nodes per region?

select r.region_name, r.region_id, count( cn.node_id) 
from customer_nodes cn
inner join regions r on cn.region_id = r.region_id
group by cn.region_id 
order by cn.region_id;

-- How many customers are allocated to each region?

select r.region_name,r.region_id, count(cn.customer_id)
from customer_nodes cn
inner join regions r on cn.region_id = r.region_id
group by cn.region_id 
order by cn.region_id;

-- How many days on average are customers reallocated to a different node?

with table1 as (SELECT *,end_date-start_date as diff 
FROM data_bank.customer_nodes 
where end_date != '9999-12-31' 
GROUP BY customer_id, node_id, start_date, end_date
order by customer_id , node_id),
table2 as (SELECT customer_id, node_id, SUM(table1.diff) AS sum_diff
FROM table1
GROUP BY customer_id, node_id)
select round(avg(table2.sum_diff),2) as avg_cust_reallocated_newNode from table2;

-- What is the median, 80th and 95th percentile for this same reallocation days metric for each region?


-- B
-- What is the unique count and total amount for each transaction type?

select txn_type, count(txn_type) from customer_transactions
group by txn_type;

-- What is the average total historical deposit counts and amounts for all customers?

-- For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?

select *, month(ct.txn_date) as month_id
from customer_nodes cn
inner join customer_transactions ct on cn.customer_id = ct.customer_id
order by month_id;

SELECT 
    customer_id,
    DATE_FORMAT(txn_date, '%M') as month_name,
    SUM(CASE WHEN txn_type = 'deposit' THEN 0 ELSE 1 END) AS deposit_count,
    SUM(CASE WHEN txn_type = 'purchase' THEN 0 ELSE 1 END) AS purchase_count,
    SUM(CASE WHEN txn_type = 'withdrawal' THEN 1 ELSE 0 END) AS withdrawal_count
  FROM customer_transactions
  GROUP BY customer_id, month_name






