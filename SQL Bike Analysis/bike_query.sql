WITH cte AS (
	SELECT * FROM bike_data.dbo.bike_share_yr_0
	UNION ALL
	SELECT * FROM bike_data.dbo.bike_share_yr_1
)

SELECT
	dteday,
	season,
	cte.yr,
	weekday,
	hr,
	rider_type,
	riders,
	price,
	COGS,
	riders * price AS revenue,
	(riders * price) - COGS AS profit
FROM cte 
LEFT JOIN bike_data.dbo.cost_table cost
ON cte.yr = cost.yr

