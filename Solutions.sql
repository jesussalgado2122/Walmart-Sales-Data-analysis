--Exploring the Data
SELECT * FROM walmart;

DROP TABLE walmart;

SELECT COUNT(*) FROM walmart;

SELECT 
	payment_method,
	COUNT(*)
FROM walmart
GROUP BY payment_method

SELECT COUNT(DISTINCT branch)
FROM walmart

SELECT MIN(quantity) FROM walmart;

--Business Problems
--Q.1 Find different payment method and number of transactions, number on quantity sold
SELECT 
	payment_method,
	COUNT(*) as number_payments,
	SUM(quantity) as number_quantity_sold
FROM walmart
GROUP BY payment_method

--Project Question #2
--Identify the highest-rated category in each branch, displaying the branch, category, AVG Rating

SELECT * 
FROM
( SELECT 
	branch,
	category,
	AVG(rating) as avg_rating,
	RANK() OVER(PARTITION BY branch ORDER BY AVG(rating) DESC) as rank
FROM walmart
GROUP BY 1, 2
ORDER BY 1, 2 DESC
)
WHERE rank = 1

--Q.3 Identify the busiest day for each branch based on the number of transactions
SELECT *
FROM
	(SELECT 
		branch,
		TO_CHAR(TO_Date(date, 'DD/MM/YY'), 'Day') as day_name,
		COUNT(*) as number_transactions,
		RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) as rank
	FROM walmart
	GROUP BY 1, 2
	)
WHERE rank = 1

--Q4.Calculate the total quantity of items sold per payment method. List payment
-- method and total quantity.

SELECT 
	payment_method,
	COUNT(*) as number_payments,
	SUM(quantity) as number_quantity_sold
FROM walmart
GROUP BY payment_method

--Q5. Determine the average, minimum, and maximum rating of products for each city.
--List the city, average_rating, min_rating, and max_rating.

SELECT
	city,
	category,
	MIN(rating) as min_rating,
	MAX(rating) as max_rating,
	AVG(rating) as avg_rating
FROM walmart
GROUP BY 1, 2

--Q.6 Calculate the total profit for each category by considering total_profit as (unit_price * quantity * profit_margin)
--List category and total profit, ordered from highest to lowest profit
	
SELECT
	category,
	SUM(total) as total_revenue,
	SUM(total * profit_margin) as profit
FROM walmart
GROUP BY 1

--Q.7 Determine the most common payment method for each Branch. Display Branch and the preferred_payment_method.
WITH cte
AS
(SELECT
	branch,
	payment_method,
	COUNT(*) as total_trans,
	RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) as rank
FROM walmart
GROUP BY 1, 2
)
SELECT * 
FROM cte
WHERE rank = 1

--Q.8 Categorize sales into 3 group Morning, Afternoon, Evening
-- Find out which of the shift and number of invoices

SELECT
	branch,
	CASE 
		WHEN EXTRACT (HOUR FROM(time::time)) < 12 THEN 'Morning'
		WHEN EXTRACT(HOUR FROM(time::time)) BETWEEN 12 AND 17 THEN 'Afternoon'
		ELSE 'Evening'
	END day_time,
	COUNT(*)
FROM walmart
GROUP BY 1, 2
ORDER BY 1, 3 DESC

--Q.9 Identify 5 branch with highest descrease ratio in revenue compare to last year *(current year 2023)
--and last year 2022

--rdr == last_rev-cr/ls_rev*100

SELECT *, 
    EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) AS formatted_date
FROM walmart;

-- 2022 vs 2023 sales
WITH revenue_2022 AS (
    SELECT
        branch,
        SUM(total) AS revenue
    FROM walmart
    WHERE EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) = 2022
    GROUP BY branch
),
revenue_2023 AS (
    SELECT 
        branch,
        SUM(total) AS revenue
    FROM walmart
    WHERE EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) = 2023
    GROUP BY branch
)
SELECT 
    ls.branch,
    ls.revenue AS last_year_revenue,
    cs.revenue AS cr_year_revenue,
    ROUND(
        ((ls.revenue - cs.revenue)::numeric / ls.revenue::numeric) * 100, 
        2
    ) AS rev_dec_ratio
FROM revenue_2022 AS ls
JOIN revenue_2023 AS cs
    ON ls.branch = cs.branch
WHERE ls.revenue > cs.revenue
ORDER BY rev_dec_ratio DESC
LIMIT 5;