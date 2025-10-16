create database walmart_db;
use walmart_db;
show tables;
SELECT * FROM walmart; 
SELECT count(*) FROM walmart;
SELECT * FROM walmart limit 5;
SELECT * FROM Walmart limit 5 offset 2;
SELECT distinct payment_method from walmart;
SELECT payment_method, count(*)
FROM walmart group by payment_method;
SELECT count(distinct Branch) FROM walmart;
SELECT DISTINCT Branch FROM walmart;
SELECT max(quantity) FROM walmart;
-- Q1.find differnt payment method and number of transactions, number of quantity sold
SELECT payment_method, count(*), sum(quantity) FROM walmart GROUP BY payment_method;
-- Q2.Identify the highest -rated category in each branch, displaying the branch,category, average rating
SELECT *
FROM
( SELECT 
      Branch,
      Category, 
      AVG(rating) as avg_rating,
	  RANK() over(partition by Branch order by AVG(rating) DESC) as first
   FROM walmart 
   GROUP BY Branch, Category
) AS high_rated
Where first=1;

-- Q3.Identify the busiest day for each branch based on the number of transactions
SELECT *
FROM
   (SELECT
     Branch,
     DAYNAME(date) as day_name,
	 COUNT(*) as no_transactions,
     Rank() over(partition by branch order by count(*) DESC) as top
  FROM walmart
  GROUP BY Branch, DAYNAME(date)
     ) as busiest
WHERE top=1;     
-- Q4.calculate the total quantity of items sold per payment method.list paymwnt_method and total_quantity
 SELECT payment_method, COUNT(*), SUM(quantity) FROM walmart GROUP BY payment_method;
 
 -- Determine the average ,mim,max rating of products for each city.
 -- List the city, average_rating, min_rating, and max_rating
SELECT 
   city,
   Category,
   min(rating) AS min_rating,
   max(rating) AS max_rating,
   Avg(rating) AS avg_rating
FROM walmart
GROUP BY city, Category;

-- Q6.calculate the total profit for each category by consediring the total_profit as (unit_price *quantity * profir_margin)
-- list category and total_profit, orders from highest to lowest price
SELECT category, sum(total) AS total_revenue, sum(total * profit_margin) AS profit FROM walmart GROUP BY category; 

-- Q7. display most common method for each branch.
-- Display branch and the preferred_payment_method.
with cte
AS
(SELECT 
Branch, 
payment_method, 
COUNT(*) AS total_trans, 
Rank() over(partition by Branch order by count(*) desc) AS top 
FROM walmart 
GROUP BY  Branch, payment_method)
SELECT * 
FROM cte
WHERE top=1; 

-- Q8.categorize sales into 3 groups morning, afternoon and evening
-- find out each of the shift and number of invoices

SELECT
	Branch,
   CASE
      WHEN HOUR(time) < 12 THEN 'Morning'
      WHEN HOUR(time)BETWEEN 12 AND 17 THEN 'Afternoon'
      ELSE 'Evening'
    END AS day_time,
	COUNT(*)
    FROM walmart
    GROUP BY Branch,day_time
    ORDER BY Branch,day_time;
    
    -- Q9. Identify 5 branch with highest decrease ratio in 
-- revenue compare to last year(current year 2023mand last year)
WITH revenue_2022 AS (
    SELECT 
        branch,
        SUM(total) AS revenue
    FROM walmart
    WHERE YEAR(STR_TO_DATE(date, '%d/%m/%Y')) = 2022
    GROUP BY branch
),
revenue_2023 AS (
    SELECT 
        branch,
        SUM(total) AS revenue
    FROM walmart
    WHERE YEAR(STR_TO_DATE(date, '%d/%m/%Y')) = 2023
    GROUP BY branch
)
SELECT 
    r2022.branch,
    r2022.revenue AS last_year_revenue,
    r2023.revenue AS current_year_revenue,
    ROUND(((r2022.revenue - r2023.revenue) / r2022.revenue) * 100, 2) AS revenue_decrease_ratio
FROM revenue_2022 AS r2022
JOIN revenue_2023 AS r2023 ON r2022.branch = r2023.branch
WHERE r2022.revenue > r2023.revenue
ORDER BY revenue_decrease_ratio DESC
LIMIT 5;

 