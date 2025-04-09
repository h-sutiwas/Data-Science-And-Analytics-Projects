/*
================
Part-to-Whole
================

Analysis Purpose:
	Analyze how an individual part is performing compared to the overall, 
	allowing us to understand which category has the greatest impact on the business
	Aggregate a Measure by Category Divided over Total Measure.
	Ex: 100 * Sales/Total Sales
		100 * Quantity/Total Quantity.

*/

-- Which categories contribute the most to overall sales?
WITH category_sales AS (
	SELECT
		category,
		SUM(sales_amount) total_sales
	FROM DataWarehouseAnalytics.gold.fact_sales f
	LEFT JOIN DataWarehouseAnalytics.gold.dim_products p
	ON p.product_key = f.product_key
	GROUP BY p.category)

SELECT
	category,
	total_sales,
	SUM(total_sales) OVER () overall_sales,
	CONCAT(ROUND((CAST(total_sales AS FLOAT)/SUM(total_sales) OVER ())*100, 2), '%') percentage_of_total
FROM category_sales
ORDER BY total_sales DESC;