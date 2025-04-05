/*
================
Performance Analysis
================

Analysis Purpose:
	Comparing the current value to a target value.
	Helps measure success and compare performance.
		- Current Sales - Average Sales
		- Current Year Sales - Previous Year Sales (YoY analysis)
		- Current Sales - Lowest Sales

*/

-- Analyze the yearly performance of products by comparing their sales
-- to both the average sales performance of the product and 
-- the previous year's sales
WITH yearly_product_sales AS (
SELECT
	YEAR(f.order_date) order_year,
	p.product_name,
	SUM(f.sales_amount) current_sales
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON f.product_key = p.product_key
WHERE order_date IS NOT NULL
GROUP BY YEAR(f.order_date),
p.product_name)
SELECT
	order_year,
	product_name,
	current_sales,
	AVG(current_sales) OVER (PARTITION BY product_name) avg_sales,
	current_sales - AVG(current_sales) OVER (PARTITION BY product_name) diff_avg,
	CASE 
		WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) > 0 THEN 'Above Average'
		WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) < 0 THEN 'Below Average'
		ELSE 'Average'
	END avg_change,
	-- Year-over-Year Analysis
	LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) previous_year_sales,
	current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) diff_current_previous,
	CASE 
		WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) > 0 THEN 'Increase'
		WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) < 0 THEN 'Decrease'
		ELSE 'No Change'
	END previous_year_change
FROM yearly_product_sales
ORDER BY product_name, order_year;





