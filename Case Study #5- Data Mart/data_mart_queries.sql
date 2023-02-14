-- A. data cleansing

DROP temporary TABLE IF EXISTS temp_sales;
CREATE TEMPORARY TABLE temp_sales as 
select 
STR_TO_DATE(week_date, '%d/%m/%y') AS week_date,
WEEK(STR_TO_DATE(week_date, '%d/%m/%y')) AS week_number,
day(STR_TO_DATE(week_date, '%d/%m/%y')) AS day_number,
MONTH(STR_TO_DATE(week_date, '%d/%m/%y')) AS month_number,
YEAR(STR_TO_DATE(week_date, '%d/%m/%y')) AS calendar_year,
region,
platform,
segment,
case 
when right(segment,1) = "1" then "young adults" 
when right(segment,1) = "2" then "middle aged"
when right(segment,1) in ("3","4") then "retiress"
else "unknown" end as age_band,
case 
when left(segment,1) = "C" then "couples" 
when left(segment,1) = "F" then "families"
else "unknown" end as demographic,
transactions,
round((sales/transactions),2) as avg_transactions,
sales
from weekly_sales;
select * from temp_sales;

-- B. Data exploration
-- What day of the week is used for each week_date value?

select week_date, dayname(week_date) from weekly_sales;

-- What range of week numbers are missing from the dataset?

-- How many total transactions were there for each year in the dataset?

select year(week_date), count(transactions) from temp_sales group by year(week_date) order by year(week_date) asc ;

-- What is the total sales for each region for each month?

select region, month_number, sum(sales) as total_sales from temp_sales group by region, month_number order by region;

-- What is the total count of transactions for each platform

select platform, count(transactions) from temp_sales group by platform

-- What is the percentage of sales for Retail vs Shopify for each month?

