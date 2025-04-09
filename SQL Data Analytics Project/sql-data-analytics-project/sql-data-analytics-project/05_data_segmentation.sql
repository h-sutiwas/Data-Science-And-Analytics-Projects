/*
================
Data-Segmentation
================

Analysis Purpose:
	Group the data based on specific range to help understand the correlation between two measures.
	[Measure] By [Measure].
	Ex: Total Products By Sales Range
		Total Customers By Age.
*/

--Segment products into cost ranges and count how many products fall into each segment
WITH product_segment AS (
SELECT
	product_key,
	product_name,
	cost,
	CASE 
		WHEN cost < 100 THEN 'Below 100'
		WHEN cost BETWEEN 100 AND 500 THEN '100-500'
		WHEN cost BETWEEN 500 AND 1000 THEN '500-1000'
		ELSE 'Above 1000'
	END cost_range
FROM DataWarehouseAnalytics.gold.dim_products)

SELECT
	cost_range,
	COUNT(product_key) total_products
FROM product_segment
GROUP BY cost_range
ORDER BY total_products DESC;

/* SQL TASK
		GROUP customers into three segments based on their spending behavior
			VIP: at least 12 months of history and spending more than 5000.
			Regular: at least 12 months of history but spending 5000 or less.
			New: lifespan less than 12 months.
		And find the total number of customers by each group.
*/		
WITH customer_spending AS (SELECT
	c.customer_key,
	SUM(f.sales_amount) total_spending,
	MIN(order_date) first_order,
	MAX(order_date) last_order,
	DATEDIFF(month, MIN(order_date), MAX(order_date)) lifespan
FROM DataWarehouseAnalytics.gold.fact_sales f
LEFT JOIN DataWarehouseAnalytics.gold.dim_customers c 
ON f.customer_key = c.customer_key
GROUP BY c.customer_key)

SELECT
	customer_segment,
	COUNT(customer_key) total_customers
FROM (
	SELECT
		customer_key,
		CASE 
			WHEN lifespan >= 12 AND total_spending > 5000 THEN 'VIP'
			WHEN lifespan >= 12 AND total_spending <= 5000 THEN 'Regular'
			ELSE 'NEW'
		END customer_segment
	FROM customer_spending) t
GROUP BY customer_segment
ORDER BY total_customers DESC;