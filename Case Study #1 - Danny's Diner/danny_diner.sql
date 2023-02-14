-- What is the total amount each customer spent at the restaurant?

select s.customer_id, sum(m.price) as total_price 
from sales s 
inner join menu m on s.product_id = m.product_id 
group by s.customer_id;

-- How many days has each customer visited the restaurant?

select customer_id, count(distinct order_date) 
from sales 
group by customer_id;

-- What was the first item from the menu purchased by each customer?

with row_num_table as 
(select s.customer_id, m.product_name , row_number() over(partition by s.customer_id order by m.product_name desc) as row_num_each_cust 
from sales s inner join menu m on s.product_id = m.product_id ) 
select customer_id, product_name from row_num_table rnt where rnt.row_num_each_cust = 1;

-- What is the most purchased item on the menu and how many times was it purchased by all customers?

select m.product_name, count(s.product_id) as freq 
from sales s 
inner join menu m on s.product_id = m.product_id 
group by s.product_id 
ORDER BY freq desc 
limit 1;

-- Which item was the most popular for each customer?

with new_ranking_table as 
(select s.customer_id, m.product_name, count(m.product_id) as freqcount, rank() over(partition by s.customer_id order by count(s.customer_id) ) as newranking  
from sales s inner join menu m on s.product_id = m.product_id GROUP BY s.customer_id, m.product_name)
select customer_id, freqcount, product_name, new_ranking_table.newranking from new_ranking_table where new_ranking_table.newranking = 1;

-- Which item was purchased first by the customer after they became a member?

with new_ranking as (select s.customer_id, s.order_date, mn.product_id, mn.product_name, dense_rank() over(partition by s.customer_id order by s.order_date asc) as ranking
from sales s 
join members mb on s.customer_id = mb.customer_id
join menu mn on s.product_id = mn.product_id
where s.order_date >= mb.join_date)

select customer_id, order_date, product_name from new_ranking where ranking =1;

-- Which item was purchased just before the customer became a member?

with new_ranking as (select s.customer_id, s.order_date , mn.product_id, mn.product_name, dense_rank() over(partition by s.customer_id order by s.order_date desc) as ranking
from sales s 
join members mb on s.customer_id = mb.customer_id
join menu mn on s.product_id = mn.product_id
where s.order_date < mb.join_date
order by s.customer_id asc, s.order_date desc)
select customer_id,order_date, product_name from new_ranking where ranking = 1;

-- What is the total items and amount spent for each member before they became a member?

select s.customer_id, count(distinct mn.product_name), sum(mn.price)
from sales s 
join members mb on s.customer_id = mb.customer_id
join menu mn on s.product_id = mn.product_id
where s.order_date < mb.join_date
group by s.customer_id
order by s.customer_id asc, s.order_date desc;

-- If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

with point_table as (select s.customer_id, mn.product_name, mn.price, case when mn.product_id = 1 then mn.price*2 else mn.price end as points
from sales s 
left join members mb on s.customer_id = mb.customer_id
join menu mn on s.product_id = mn.product_id
order by s.customer_id)
select customer_id, sum(points*10) as real_points_collected from point_table group by customer_id;

-- In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - ho

select s.customer_id, s.order_date, mb.join_date, mn.product_name,s.product_id, mn.price, case when s.order_date >= mb.join_date then price*2 else price end as ref
from sales s 
join menu mn on s.product_id = mn.product_id
join members mb on s.customer_id = mb.customer_id
order by s.customer_id asc, s.order_date asc;


-- Bonus questions

-- First 
with cte as (select s.customer_id, s.order_date as od, mn.product_name, mn.price, mb.join_date as jd
from sales s
inner join menu mn on s.product_id = mn.product_id 
join members mb on s.customer_id = mb.customer_id
order by s.customer_id asc, s.order_date asc)
select *, 
CASE
      WHEN cte.jd > cte.od THEN 'N'
      WHEN cte.jd <= cte.od THEN 'Y'
      ELSE 'N'
      END AS member
from cte;

--  Second

with new_cte as (with cte as (select s.customer_id as ci, s.order_date as od, mn.product_name as pn, mn.price, mb.join_date as jd
from sales s
inner join menu mn on s.product_id = mn.product_id 
join members mb on s.customer_id = mb.customer_id
order by s.customer_id asc, s.order_date asc)
select *, 
CASE
      WHEN cte.jd > cte.od THEN 'N'
      WHEN cte.jd <= cte.od THEN 'Y'
      ELSE 'N'
      END AS member
from cte)
SELECT *, CASE
   WHEN member = 'N' then NULL
   ELSE
      RANK() OVER(PARTITION BY ci, member ORDER BY od) END AS ranking
FROM new_cte;





