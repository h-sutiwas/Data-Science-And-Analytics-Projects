select * from artist;
select * from canvas_size;
select * from image_link;
select * from museum;
select * from museum_hours;
select * from product_size;
select * from subject;
select * from work;


-- Problem Number 10
-- Identify the museums which are open on both Sunday and Monday

SELECT 
	m.name museum_name,
	m.city
FROM museum_hours mh1
JOIN museum m 
ON m.museum_id=mh1.museum_id
WHERE day = 'Sunday'
AND EXISTS (
	SELECT 
		1 
	FROM museum_hours mh2
	WHERE mh2.museum_id = mh1.museum_id 
	AND mh2.day = 'Monday');

-- Problem Number 15
-- Which museum is open for the longest during a day.
-- Display museum name, states and hours open and which day?
SELECT
	*
FROM (
	SELECT
		m.name museum_name,
		m.state,
		mh_ct.[day],
		mh_ct.[open],
		mh_ct.[close],
		((mh_ct.close_minutes - mh_ct.open_minutes) / 60.0) AS hours_open,
		RANK() OVER(ORDER BY((mh_ct.close_minutes - mh_ct.open_minutes) / 60.0) DESC) AS rnk
	FROM (
		SELECT
			museum_id,
			day,
			[open],
			[close],
			CASE
				WHEN [open] LIKE '%AM%' AND [open] NOT LIKE '12%' THEN
					(CAST(SUBSTRING([open], 1, CHARINDEX(':', [open])-1) AS INT) * 60) +
					CAST(SUBSTRING([open], CHARINDEX(':', [open])+1, 2) AS INT)
				WHEN [open] LIKE '12%AM%' THEN
					CAST(SUBSTRING([open], CHARINDEX(':', [open])+1, 2) AS INT)
				WHEN [open] LIKE '%PM%' AND [open] NOT LIKE '12%' THEN
					((CAST(SUBSTRING([open], 1, CHARINDEX(':', [open])-1) AS INT) + 12) * 60) +
					CAST(SUBSTRING([open], CHARINDEX(':', [open])+1, 2) AS INT)
				WHEN [open] LIKE '12%PM%' THEN
					(12 * 60) + CAST(SUBSTRING([open], CHARINDEX(':', [open])+1, 2) AS INT)
			END AS open_minutes,
    
			CASE
				WHEN [close] LIKE '%AM%' AND [close] NOT LIKE '12%' THEN
					(CAST(SUBSTRING([close], 1, CHARINDEX(':', [close])-1) AS INT) * 60) +
					CAST(SUBSTRING([close], CHARINDEX(':', [close])+1, 2) AS INT)
				WHEN [close] LIKE '12%AM%' THEN
					CAST(SUBSTRING([close], CHARINDEX(':', [close])+1, 2) AS INT)
				WHEN [close] LIKE '%PM%' AND [close] NOT LIKE '12%' THEN
					((CAST(SUBSTRING([close], 1, CHARINDEX(':', [close])-1) AS INT) + 12) * 60) +
					CAST(SUBSTRING([close], CHARINDEX(':', [close])+1, 2) AS INT)
				WHEN [close] LIKE '12%PM%' THEN
					(12 * 60) + CAST(SUBSTRING([close], CHARINDEX(':', [close])+1, 2) AS INT)
			END AS close_minutes
		FROM museum_hours
	) AS mh_ct
	JOIN museum m ON m.museum_id=mh_ct.museum_id
	WHERE open_minutes IS NOT NULL AND close_minutes IS NOT NULL) osub
WHERE osub.rnk = 1;

-- Problem number 18
-- Display the country and the city with most no. of museum
-- Output 2 seperate columns to mention the city and country
-- If there are multiple value => separate them with comma.

WITH cte_country AS (
	SELECT
		country,
		COUNT(1) count_museum,
		RANK() OVER(ORDER BY COUNT(1) DESC) rnk
	FROM museum
	GROUP BY country
), cte_city AS (
	SELECT
		city,
		COUNT(1) count_museum,
		RANK() OVER(ORDER BY COUNT(1) DESC) rnk
	FRoM museum
	GROUP BY city
) 
SELECT
	STRING_AGG(country, ' , ') WITHIN GROUP (ORDER BY country) country,
	STRING_AGG(city, ' , ') city
FROM cte_country
CROSS JOIN cte_city
WHERE cte_country.rnk = 1
AND cte_city.rnk = 1;