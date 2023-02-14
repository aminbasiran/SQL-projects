-- B. Digital analysis 
-- How many users are there

select count(distinct user_id) user_count from users;

-- How many cookies does each user have on average

with cte as (select *, count(user_id) as count_cookies from users group by user_id order by user_id)
select avg(cte.count_cookies) as avg_cookies from cte;

-- What is the unique number of visits by all users per month?

select DATE_FORMAT(event_time, '%M') month_name, count(distinct visit_id) unique_visits from events
group by DATE_FORMAT(event_time, '%M') order by count(distinct visit_id) asc;

-- What is the number of events for each event type?

select event_type, count(visit_id) num_visit from events group by event_type;

-- What is the percentage of visits which have a purchase event?

select (COUNT(DISTINCT e.visit_id)/(SELECT COUNT(DISTINCT visit_id) FROM clique_bait.events))*100 as percentage
from events e 
inner join event_identifier ei on e.event_type=ei.event_type
where ei.event_name = "purchase";

-- What is the percentage of visits which view the checkout page but do not have a purchase event?

with cte as (select visit_id, 
max(case when event_type = 1 and page_id = 12 then 1 else 0 end) as checkout, 
max(case when event_type = 3 then 1 else 0 end) as purchase 
from events
group by visit_id) -- FIXXX
-- select (count(/)*100 from cte where checkout = 1 and purchase = 0;

-- What are the top 3 pages by number of views?

select page_id, COUNT(*) AS page_views
from events
group BY page_id
order BY page_views desc
limit 3;

-- What is the number of views and cart adds for each product category?

select ph.product_category,
sum(case when e.event_type = 1 then 1 else 0 end) as page_views,
sum(case when e.event_type=2 then 1 else 0 end) as add_cart
from events e 
inner join page_hierarchy ph on e.page_id = ph.page_id
where ph.product_category is not null
group by ph.product_category
order by page_views;

-- What are the top 3 products by purchases?

select * 
from events e
inner join page_hierarchy ph on e.page_id = ph.page_id
where e.event_type = 3;

-- C. Product Funnel Analysis

select ph.page_name, ph.product_category,
sum(case when e.event_type = 1 then 1 else 0 end) as product_viewed,
sum(case when e.event_type = 2 then 1 else 0 end) as cart_added
from events e
inner join page_hierarchy ph on e.page_id = ph.page_id
where ph.product_category is not null
group by ph.page_name, ph.product_category
order by ph.product_category

