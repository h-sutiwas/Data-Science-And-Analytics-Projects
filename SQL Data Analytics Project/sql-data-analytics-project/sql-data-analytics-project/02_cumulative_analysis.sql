/*
================
Cumulative Analysis
================

Analysis Purpose:
	Aggregate our data (cumulative measure) progessively over time.
	Helps to understand whether our business is growing or declining.
		- Running Total Sales by Year
		- Moving Average of Sales by Month
*/


-- Calculate the total sales per month 
-- and the running total sales over time.
SELECT
	order_date,
	total_sales,
	SUM(total_sales) OVER (ORDER BY order_date) running_total_sales,
	AVG(avg_price) OVER (ORDER BY order_date) moving_average_price
FROM (
SELECT
	DATETRUNC(year, order_date) order_date,
	SUM(sales_amount) total_sales,
	AVG(price) avg_price
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(year, order_date)
) t