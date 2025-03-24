select * from df_orders


-- Find Top 10 Highest Revenue Generating Products
SELECT
	TOP 10 product_id,
	SUM(sale_price) AS sales
FROM df_orders
GROUP BY product_id
ORDER BY sales DESC;

-- Find Top 5 highest selling product in each region
WITH cte AS (
	SELECT
		region,
		product_id,
		SUM(sale_price) AS sales
	FROM df_orders
	GROUP BY region, product_id
) 
SELECT 
	* 
FROM (
	SELECT
		*,
		ROW_NUMBER() OVER(PARTITION BY region ORDER BY sales DESC) AS rn
	FROM cte
) A
WHERE rn <= 5;

-- Find Month over Month Growth Comparison for 2022 and 2023 sales
-- Ex: JAN 2022 vs JAN 2023
WITH cte AS (
SELECT 
	YEAR(order_date) AS order_year, 
	MONTH(order_date) AS order_month, 
	SUM(sale_price) AS sales
FROM df_orders
GROUP BY YEAR(order_date), MONTH(order_date)
--ORDER BY YEAR(order_date), MONTH(order_date)
)
SELECT 
	order_month,
	ROUND(
		SUM(CASE WHEN order_year=2022 THEN sales ELSE 0 END)
		, 2) AS sales_2022,
	ROUND(
		SUM(CASE WHEN order_year=2023 THEN sales ELSE 0 END)
		, 2) AS sales_2023
FROM cte
GROUP BY order_month
ORDER BY order_month;

-- For each category which month had highest sales
WITH cte AS (
	SELECT
		category,
		FORMAT(order_date, 'yyyyMM') AS order_year_month, 
		SUM(sale_price) AS sales
	FROM df_orders
	GROUP BY category, FORMAT(order_date, 'yyyyMM')
)

SELECT
	* 
FROM(	
	SELECT 
			*,
			ROW_NUMBER() OVER(PARTITION BY category ORDER BY sales DESC) AS rn
	FROM cte
	) a
WHERE rn=1;

-- Which sub category had the highest growth by profit in 2023 compare to 2022
WITH cte AS (
SELECT
	sub_category,
	YEAR(order_date) AS order_year, 
	SUM(profit) AS annual_profit
FROM df_orders
GROUP BY sub_category, YEAR(order_date)
), cte2 AS (
	SELECT 
		sub_category,
		ROUND(
			SUM(CASE WHEN order_year=2022 THEN annual_profit ELSE 0 END)
			, 2) AS annual_profit_2022,
		ROUND(
			SUM(CASE WHEN order_year=2023 THEN annual_profit ELSE 0 END)
			, 2) AS annual_profit_2023
	FROM cte
	GROUP BY sub_category)
SELECT
	TOP 1 *,
	ROUND(
	(annual_profit_2023 - annual_profit_2022)*100/annual_profit_2022, 2
	) AS growth_by_profit
FROM cte2
ORDER BY growth_by_profit DESC;