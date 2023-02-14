DROP TABLE IF EXISTS runners;
CREATE TABLE runners (
  runner_id INTEGER,
  registration_date DATE
);
INSERT INTO runners
  (runner_id, registration_date)
VALUES
  (1, '2021-01-01'),
  (2, '2021-01-03'),
  (3, '2021-01-08'),
  (4, '2021-01-15');


DROP TABLE IF EXISTS customer_orders;
CREATE TABLE customer_orders (
  order_id INTEGER,
  customer_id INTEGER,
  pizza_id INTEGER,
  exclusions VARCHAR(4),
  extras VARCHAR(4),
  order_time TIMESTAMP
);

INSERT INTO customer_orders
  (order_id, customer_id, pizza_id, exclusions, extras, order_time)
VALUES
  (1, 101, 1, null, null, '2020-01-01 18:05:02'),
  (2, 101, 1, null, null, '2020-01-01 19:00:52'),
  (3, 102, 1, null, null, '2020-01-02 23:51:23'),
  (3, 102, 2, null, NULL, '2020-01-02 23:51:23'),
  (4, 103, 1, '4', null, '2020-01-04 13:23:46'),
  (4, 103, 1, '4', null, '2020-01-04 13:23:46'),
  (4, 103, 2, '4', null, '2020-01-04 13:23:46'),
  (5, 104, 1, null, '1', '2020-01-08 21:00:29'),
  (6, 101, 2, null, null, '2020-01-08 21:03:13'),
  (7, 105, 2, null, '1', '2020-01-08 21:20:29'),
  (8, 102, 1, null, null, '2020-01-09 23:54:33'),
  (9, 103, 1, '4', '1, 5', '2020-01-10 11:22:59'),
  (10, 104, 1, null, null, '2020-01-11 18:34:49'),
  (10, 104, 1, '2, 6', '1, 4', '2020-01-11 18:34:49');


DROP TABLE IF EXISTS runner_orders;
CREATE TABLE runner_orders (
  order_id INTEGER,
  runner_id INTEGER,
  pickup_time VARCHAR(19),
  distance VARCHAR(7),
  duration VARCHAR(10),
  cancellation VARCHAR(23)
);

INSERT INTO runner_orders
  (order_id, runner_id, pickup_time, distance, duration, cancellation)
VALUES
  (1, 1, '2020-01-01 18:15:34', '20km', '32 minutes', null),
  (2, 1, '2020-01-01 19:10:54', '20km', '27 minutes', null),
  (3, 1, '2020-01-03 00:12:37', '13.4km', '20 mins', NULL),
  (4, 2, '2020-01-04 13:53:03', '23.4', '40', NULL),
  (5, 3, '2020-01-08 21:10:57', '10', '15', NULL),
  (6, 3, null, null, null, 'Restaurant Cancellation'),
  (7, 2, '2020-01-08 21:30:45', '25km', '25mins', null),
  (8, 2, '2020-01-10 00:15:02', '23.4 km', '15 minute', null),
  (9, 2, null, null, null, 'Customer Cancellation'),
  (10, 1, '2020-01-11 18:50:20', '10km', '10minutes', null);
  
ALTER TABLE runner_orders
MODIFY pickup_time timestamp;




DROP TABLE IF EXISTS pizza_names;
CREATE TABLE pizza_names (
  pizza_id INTEGER,
  pizza_name varchar(50)
);
INSERT INTO pizza_names
  (pizza_id, pizza_name)
VALUES
  (1, 'Meatlovers'),
  (2, 'Vegetarian');


DROP TABLE IF EXISTS pizza_recipes;
CREATE TABLE pizza_recipes (
  pizza_id INTEGER,
  toppings Varchar(50)
);
INSERT INTO pizza_recipes
  (pizza_id, toppings)
VALUES
  (1, '1, 2, 3, 4, 5, 6, 8, 10'),
  (2, '4, 6, 7, 9, 11, 12');


DROP TABLE IF EXISTS pizza_toppings;
CREATE TABLE pizza_toppings (
  topping_id INTEGER,
  topping_name varchar(50)
);
INSERT INTO pizza_toppings
  (topping_id, topping_name)
VALUES
  (1, 'Bacon'),
  (2, 'BBQ Sauce'),
  (3, 'Beef'),
  (4, 'Cheese'),
  (5, 'Chicken'),
  (6, 'Mushrooms'),
  (7, 'Onions'),
  (8, 'Pepperoni'),
  (9, 'Peppers'),
  (10, 'Salami'),
  (11, 'Tomatoes'),
  (12, 'Tomato Sauce');

-- A
-- How many pizzas were ordered?

select count(order_id) as pizza_count from customer_orders  ;

-- How many unique customer orders were made?

select count(distinct order_id) as unique_pizza_count from customer_orders;

-- How many successful orders were delivered by each runner?

select runner_id, count(order_id) from runner_orders where distance != 0 group by runner_id;

-- How many of each type of pizza was delivered 

select co.pizza_id, pn.pizza_name, (co.pizza_id) as unique_pizza_count 
from customer_orders co  
join runner_orders ro on co.order_id = ro.order_id 
join pizza_names pn on co.pizza_id = pn.pizza_id
where ro.distance != 0 
group by co.pizza_id;

-- How many Vegetarian and Meatlovers were ordered by each customer

select co.customer_id, pn.pizza_name, count(co.pizza_id) from customer_orders co 
join pizza_names pn on co.pizza_id = pn.pizza_id
group by co.customer_id,co.pizza_id
order by co.customer_id;

-- What was the maximum number of pizzas delivered in a single order?

select co.order_id, count(co.order_id)
from customer_orders co 
join runner_orders ro on co.order_id = ro.order_id
where distance != 0 
group by co.order_id;

-- For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
 
 
 
 
-- How many pizzas were delivered that had both exclusions and extras?

with new_table as (select co.order_id as A, co.exclusions as exc, co.extras as ext
from customer_orders co 
join runner_orders ro on co.order_id = ro.order_id 
where ro.distance != 0)
select count(A) from new_table where new_table.exc != null or new_table.ext != null;

-- What was the total volume of pizzas ordered for each hour of the day? 
select  hour(co.order_time) as each_hour, count(co.order_id)
from customer_orders co 
group by each_hour
order by each_hour asc;

-- What was the volume of orders for each day of the week?

SELECT DATE_FORMAT(order_time, '%W') AS day_of_week, count(order_id) FROM customer_orders group by day_of_week;

-- B 
-- How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)

SELECT (DAYOFMONTH(registration_date) - 1) DIV 7 + 1 AS week_of_month, count(runner_id) as num_runner_signed_up
FROM runners group by week_of_month;

-- What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order

select avg(MINUTE(TIMEDIFF(ro.pickup_time, co.order_time))) AS avg_time
from customer_orders co 
join runner_orders ro on co.order_id = ro.order_id
where ro.duration != 0;



-- C
-- What are the standard ingredients for each pizza

select pn.pizza_id, pn.pizza_name, pr.toppings, pt.topping_name
from pizza_names pn 
join pizza_recipes pr on pn.pizza_id = pr.pizza_id
join pizza_toppings pt on pt.topping_id = pr.toppings;









