/*
================
Customer Report
================

Report Purpose:
	This report consolidates key customer metrics and behaviors
	- Put every exporations or analysis in one view or table.
	- For stakeholders to give a quick analysis for data-driven decisions making.
	
	Highlights:
		1. Gather essential fields such as names, ages, transaction details.
		2. Segments customers into categories (VIP, Regular, New) and age groups.
		3. Aggregates customer-level metrics:
			- total orders
			- total sales
			- total quantity purchased
			- total products
			- lifespan (in months)
		4. Calculates valuable KPIs:
			- recency (months since last order)
			- average order value = total sales / total n of orders
			- average monthly spend = total sales / n of months
*/

/*-----------------------------------------------
1) Base Query: Retrieves core columns from tables
*/-----------------------------------------------

CREATE VIEW report_customers AS
WITH base_query AS (
	SELECT
		f.order_number,
		f.order_date,
		f.product_key,
		f.sales_amount,
		f.quantity,
		c.customer_key,
		c.customer_number,
		CONCAT(c.first_name, ' ', c.last_name) customer_name,
		DATEDIFF(year, c.birthdate, GETDATE()) age
	FROM DataWarehouseAnalytics.gold.fact_sales f
	LEFT JOIN DataWarehouseAnalytics.gold.dim_customers c
	ON f.customer_key = c.customer_key
	WHERE f.order_date IS NOT NULL), 

/*-------------------------------------
2) Aggregations: Customer-level metrics
*/-------------------------------------
customer_aggregation AS (
	SELECT
		customer_key,
		customer_number,
		customer_name,
		age,
		COUNT(DISTINCT order_number) total_orders,
		SUM(sales_amount) total_sales,
		SUM(quantity) total_quantity,
		COUNT(DISTINCT product_key) total_products,
		MAX(order_date) last_order_date,
		DATEDIFF(month, MIN(order_date), MAX(order_date)) lifespan
	FROM base_query
	GROUP BY 
		customer_key,
		customer_number,
		customer_name,
		age)

/*-----------------------------------------------------------
3) Customer Segmentations: Segments customers into categories
*/-----------------------------------------------------------

SELECT
	customer_key,
	customer_number,
	customer_name,
	age,
	CASE 
		WHEN age <20 THEN 'Under 20'
		WHEN age BETWEEN 20 AND 29 THEN '20-29'
		WHEN age BETWEEN 30 AND 39 THEN '30-39'
		WHEN age BETWEEN 40 AND 49 THEN '40-49'
		ELSE '50 and above'
	END age_segment,
	CASE 
		WHEN lifespan >= 12 AND total_sales > 5000 THEN 'VIP'
		WHEN lifespan >= 12 AND total_sales <= 5000 THEN 'Regular'
		ELSE 'NEW'
	END customer_segment,
	last_order_date,
/*-------------------------------------------------
4) Final Report: Calculates valuable KPIs
*/-------------------------------------------------
	-- recency (months since last order)
	DATEDIFF(month, last_order_date, GETDATE()) recency,
	total_orders,
	total_sales,
	total_quantity,
	total_products,
	lifespan,
	-- Compute average order value (AVO)
	CASE 
		WHEN total_orders = 0 THEN 0
		ELSE total_sales/total_orders 
	END avg_order_value,
	-- Compute average monthly spend
	CASE
		WHEN lifespan = 0 THEN total_sales
		ELSE total_sales/lifespan
	END avg_monthly_spend
FROM customer_aggregation;