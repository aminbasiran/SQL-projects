-- How many customers has Foodie-Fi ever had?

select count( distinct customer_id) as customers from subscriptions;

-- What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value

select DATE_FORMAT(s.start_date, '%Y-%m') AS Month
from subscriptions s 
join plans p on s.plan_id = p.plan_id
where s.plan_id = 0
GROUP BY 
  Month 
ORDER BY 
  Month;
  
-- What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name
select p.plan_name, count(p.plan_id) as number_of_plans
from subscriptions s 
inner join plans p on s.plan_id = p.plan_id
where s.start_date >= '2021-01-01'
group by p.plan_name
order by number_of_plans;





-- What is the customer count and percentage of customers who have churned rounded to 1 decimal place?
select p.plan_id, p.plan_name, count(s.customer_id) as num_cust, round(((select count(distinct customer_id) from subscriptions where plan_id = 4)/(select count(distinct customer_id) from subscriptions))*100,2) as percentage
from subscriptions s 
inner join plans p on s.plan_id = p.plan_id
where p.plan_id = 4;

-- How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?

with cte as (select s.customer_id, s.start_date, p.plan_name, s.plan_id, lead(s.plan_id) over(partition by s.customer_id) as next_plan
from subscriptions s 
inner join plans p on s.plan_id = p.plan_id
order by s.customer_id asc)
select count(*) as num_cust_churn_afterTrial, round((count(*)/(select count(distinct customer_id)from subscriptions))*100,0) as percentage_churn from cte 
where prev_name = 4 and	plan_id = 0 ;

-- What is the number and percentage of customer plans after their initial free trial?

with cte as (select s.customer_id, s.start_date, p.plan_name, s.plan_id, lag(s.plan_id) over(partition by s.customer_id) as prev_plan
from subscriptions s 
inner join plans p on s.plan_id = p.plan_id
order by s.customer_id asc)
select count(plan_id) as num_plan_afterChurn from cte 
where prev_plan = 0
group by plan_id
order by num_plan_afterChurn;

-- How many customers have upgraded to an annual plan in 2020?

select count(distinct s.customer_id) as num_cust_upgradeAnnual
from subscriptions s 
inner join plans p on s.plan_id = p.plan_id
where YEAR(start_date) = 2020 and s.plan_id = 3
order by s.customer_id asc;

-- How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?






