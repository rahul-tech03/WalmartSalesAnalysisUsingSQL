CREATE DATABASE IF NOT EXISTS WALMART_SALES;
use walmart_sales;
CREATE TABLE IF NOT EXISTS SALES(
	invoice_id varchar(30) not null primary key,
    branch varchar(10) NOT NULL,
    city varchar(30) NOT NULL,
    customer_type varchar(30) NOT NULL,
    gender varchar(10) not null,
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL,
    VAT float(6,4) NOT NULL,
    total DECIMAL(10,2),
    Date datetime not null ,
    time time not null,
    payment_method varchar(15) not null,
    cogs decimal(10,2) not null,
    cogs_margin_pct float(11,9) not null,
    gross_income decimal(12,4) not null,
    rating float(4,2) not null
    
);

select * FROM sales;


-- ----------------------------------------------------------------------------------------------------
-- -----------------------------FEATURE ENGINEERING ---------------------------------------------------
-- time_of_day

select 
	time,
    (case 
		when `time` between "00:00:00" and "12:00:00" then "Morning"
		when `time` between "12:01:00" and "16:00:00" then "Afternoon"
		else "Evening"
	end
    ) as time_of_day
from
	sales;
    
alter table sales add column time_of_day varchar(30);

update sales 
set time_of_day = (
	case 
		when `time` between "00:00:00" and "12:00:00" then "Morning"
		when `time` between "12:01:00" and "16:00:00" then "Afternoon"
		else "Evening"
	end
);
SET SQL_SAFE_UPDATES = 0;

-- ------------DAY_NAME--------------------------
select date, dayname(date) as day_name
from sales;

alter table sales add column day_name varchar(10);

update sales
set day_name = dayname(date);
    
    
-- ------------MONTH_NAME--------------------------
select date, monthname(date) as month_name
from sales;
ALTER table sales add column month_name varchar(10);

update sales
set month_name = monthname(date);

-- --------------------------------------------------------------------
-- --------------------------------------------------------------------

-- --------------------------------------------------------------------
-- ---------------------------- Generic ------------------------------
-- --------------------------------------------------------------------
-- Q.1 How many unique cities does the data have?

SELECT COUNT( DISTINCT city)
FROM sales;

-- -----------------------------------------------------------------------------------------------------
-- Q.2 In which city is each branch?

SELECT DISTINCT city, branch
FROM sales;

-- --------------------------------------------------------------------
-- --------------------------------------------------------------------

-- --------------------------------------------------------------------
-- ---------------------------- Product ------------------------------
-- --------------------------------------------------------------------

-- ------------------------------------------Product---------------------------------------------------
-- Q.1 How many unique product lines does the data have?
SELECT 
    COUNT(DISTINCT product_line)
FROM
    sales; 
-- -----------------------------------------------------------------------------------------------------
-- Q.2  What is the most common payment method?

SELECT 
    payment_method, COUNT(payment_method) AS cnt
FROM
    sales
GROUP BY payment_method
ORDER BY cnt DESC
LIMIT 1;
-- -----------------------------------------------------------------------------------------------------
-- Q.3 What is the most common customer type?

SELECT customer_type, COUNT(customer_type) AS custt_cnt
FROM sales
GROUP BY customer_type
ORDER BY custt_cnt
DESC LIMIT 1;
-- -----------------------------------------------------------------------------------------------------
-- Q.4 Which customer type buys the most?
SELECT 
    customer_type
FROM
    (SELECT 
        COUNT(invoice_id), customer_type
    FROM
        sales
    GROUP BY customer_type
    ORDER BY COUNT(invoice_id) DESC
    LIMIT 1) AS mosyByCustomer;

-- -----------------------------------------------------------------------------------------------------
-- Q.5 What is the total revenue by month?

SELECT SUM(total) AS revenue, month_name
FROM sales
GROUP BY month_name
ORDER BY revenue DESC;


-- -----------------------------------------------------------------------------------------------------
-- Q.6 What month had the largest COGS ?

SELECT 
    SUM(cogs) AS total_cogs, month_name
FROM
    sales
GROUP BY 
	month_name
ORDER BY total_cogs DESC
LIMIT 1;

-- -----------------------------------------------------------------------------------------------------
-- Q.7 What product line had the largest revenue?

SELECT
	product_line, SUM(total) AS total_revenue
FROM
	sales
GROUP BY
	product_line
ORDER BY total_revenue DESC
LIMIT 1;

-- -----------------------------------------------------------------------------------------------------
-- Q.8 What is the city with largest revenue ?

SELECT branch,city, SUM(total) AS total_revenue
FROM sales
GROUP BY branch,city
ORDER BY total_revenue DESC LIMIT 1; 


-- -----------------------------------------------------------------------------------------------------
-- Q.9 What product line had the largect VAT ?

SELECT
	product_line, AVG(VAT) AS total_VAT
FROM
	sales
GROUP BY
	product_line
ORDER BY TOTAL_VAT DESC
LIMIT 1;

-- -----------------------------------------------------------------------------------------------------
-- Q.10 which branch sold more products than the average product sold ?

SELECT branch, SUM(quantity)
FROM sales
GROUP BY branch
HAVING SUM(quantity) > (SELECT AVG(quantity) FROM sales);

-- -----------------------------------------------------------------------------------------------------
-- Q.11 which is the most common product line by gender ?

SELECT gender, product_line, COUNT(gender) AS gen_count
FROM sales
GROUP BY gender, product_line
ORDER BY gen_count DESC;


-- -----------------------------------------------------------------------------------------------------
-- Q.12 what is the average rating for each product line?

SELECT product_line, ROUND(AVG(rating),2) AS avg_rating
FROM sales
GROUP BY product_line
ORDER BY avg_rating DESC;


-- Q.13 Fetch each product line and add a column to those product 
-- line showing "Good", "Bad". Good if its greater than average sales

SELECT 
	AVG(quantity) AS avg_qnty
FROM sales;

SELECT
	product_line,
	CASE
		WHEN AVG(quantity) > 6 THEN "Good"
        ELSE "Bad"
    END AS remark
FROM sales
GROUP BY product_line;

-- --------------------------------------------------------------------
-- --------------------------------------------------------------------


-- --------------------------------------------------------------------
-- -------------------------- Customers -------------------------------
-- --------------------------------------------------------------------

-- Q.1 How many unique customer types does the Data have?

SELECT 
    COUNT(DISTINCT customer_type)
FROM
    sales;
    
  -- -----------------------------------------------------------------------------------------------------  
-- Q.2 How many unique payment method does the Data have?

select
	count(distinct payment_method)
from
	sales;
    
-- -----------------------------------------------------------------------------------------------------
-- Q.3 What is the most common customer type?

select
	customer_type,
	count(customer_type) as customers
from sales
group by customer_type
order by customers desc limit 1;

-- -----------------------------------------------------------------------------------------------------
-- Q.4 Which customer type buys the most?

select customer_type, count(*) FROM sales
group by customer_type;

-- Q.5 What is the gender of most of the customers?
SELECT
	COUNT(*), gender
FROM
	sales
GROUP BY
	gender
    ORDER BY count(*) DESC LIMIT 1;
    
  -- -----------------------------------------------------------------------------------------------------  
-- Q.6 What is the gender distribution per branch?

SELECT branch, gender,COUNT(gender)
FROM
	sales
GROUP BY
	branch,gender
order by branch ;

-- -----------------------------------------------------------------------------------------------------
-- Q.7 Which time of the day do the customers gives most ratings?

select
	time_of_day, count(rating) as rating_cnt
from
	sales
group by
	time_of_day
order by rating_cnt desc limit 1;

-- -----------------------------------------------------------------------------------------------------
-- Q.8 Which time of the day do the customers gives most ratings per branch?

select
	time_of_day, branch, count(rating) as rating_cnt
from
	sales
group by
	time_of_day,branch
    order by branch;
 
 -- -----------------------------------------------------------------------------------------------------
-- Q.9 Which day of the week has the best average ratings?

select
	day_name,avg(rating) as avg_rating
from
	sales
group by
	day_name
order by avg_rating desc limit 1;

-- -----------------------------------------------------------------------------------------------------
-- Q.10 Which day of the week has the best average ratings per branch?

select
	day_name,branch,avg(rating) as avg_rating
from
	sales
group by
	day_name, branch
order by avg_rating desc;

-- --------------------------------------------------------------------
-- --------------------------------------------------------------------

-- --------------------------------------------------------------------
-- ---------------------------- Sales ---------------------------------
-- --------------------------------------------------------------------

-- -------------------------------SALES---------------------------------------------
-- Q.1 The number of sales made in each time of day per weekday?

SELECT
	day_name,time_of_day,COUNT(*)
FROM
	sales
GROUP BY
	time_of_day,day_name
ORDER BY day_name;

-- -----------------------------------------------------------------------------------------------------
-- Q.2 Which of the customer types bring the most revenue?

SELECT
	customer_type, SUM(total) AS revenue
FROM 
	sales
GROUP BY
	customer_type
ORDER BY revenue DESC LIMIT 1;

-- -----------------------------------------------------------------------------------------------------
-- Q.3 Which city has the largest tax percent / VAT(value add tax)?

SELECT city, AVG(VAT) AS vat
FROM sales
GROUP BY city
ORDER BY vat DESC LIMIT 1;

-- -----------------------------------------------------------------------------------------------------
-- Q.4 Which customer type pays the most in vat?

SELECT
	customer_type, AVG(VAT) AS vat
FROM
	sales
GROUP BY
	customer_type
ORDER BY vat DESC LIMIT 1;

-- --------------------------------------------------------------------
-- --------------------------------------------------------------------